// Tests du CiqualEnrichmentLoader (enrichissement nutritionnel sourcé,
// retour PO 2026-08-26).
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/importers/ciqual_enrichment_loader.dart';
import 'package:path/path.dart' as p;

const _csvHeader =
    'ingredient_id,ciqual_alim_code,aliment_name,component_id,'
    'component_name,normalized_value,normalized_unit,confidence_code,'
    'confidence,source_citation';

String _row(String id, String component, double value, String citation) =>
    '$id,13000,"Abricot, dénoyauté, cru",$component,'
    '"Energie, Règlement UE (kcal/100 g)",$value,kcal,D,0.6,'
    '"ANSES Ciqual 2025-11-03 — $citation"';

Future<String> _writeCsv(Directory dir, String content) async {
  final file = File(p.join(dir.path, 'ciqual_nutrition.csv'));
  await file.writeAsString(content, flush: true);
  return file.path;
}

Future<void> _insertIngredient(AppDatabase db, String id) => db
    .into(db.ingredients)
    .insert(
      IngredientsCompanion.insert(
        ingredientId: id,
        canonicalNameFr: 'Ingrédient $id',
        categoryLevel1: 'végétal',
      ),
    );

void main() {
  late Directory tmp;
  late AppDatabase db;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('ciqual_enrichment_test');
    db = AppDatabase(NativeDatabase.memory());
    await _insertIngredient(db, 'ING-A');
    await _insertIngredient(db, 'ING-B');
  });

  tearDown(() async {
    await db.close();
    await tmp.delete(recursive: true);
  });

  test(
    'insère les records avec source citée, sauf ingrédients déjà couverts',
    () async {
      // ING-A a déjà un record Phase 2 → non enrichi. ING-B non couvert.
      await db
          .into(db.nutritionRecords)
          .insert(
            NutritionRecordsCompanion.insert(
              nutritionRecordId: 'P2-1',
              ingredientId: 'ING-A',
              sourceId: const Value('phase2_source'),
              componentId: const Value('ENERCKCAL'),
              normalizedValue: const Value(30),
            ),
          );

      final csvPath = await _writeCsv(
        tmp,
        '$_csvHeader\n'
        '${_row('ING-A', 'ENERCKCAL', 44, 'Valeur ajustée Ciqual')}\n'
        '${_row('ING-B', 'ENERCKCAL', 89, 'USDA 2014, SR27')}\n',
      );
      final outcome = await CiqualEnrichmentLoader().loadInto(
        db,
        csvPath: csvPath,
      );

      expect(
        outcome.insertedRows,
        1,
        reason: 'seul ING-B (non couvert) est inséré',
      );
      final rows = await db.select(db.nutritionRecords).get();
      final enriched = rows.where((r) => r.ingredientId == 'ING-B').toList();
      expect(enriched, hasLength(1));
      expect(enriched.single.sourceId, CiqualEnrichmentLoader.sourceId);
      expect(
        enriched.single.notes,
        'ANSES Ciqual 2025-11-03 — USDA 2014, SR27',
      );
      expect(enriched.single.sourceFoodName, 'Abricot, dénoyauté, cru');
      expect(enriched.single.confidence, 0.6);
      expect(enriched.single.valueQualifier, 'Code de confiance Ciqual D');
    },
  );

  test(
    'ré-import du même fichier : skip par hash, aucune nouvelle ligne',
    () async {
      final csvPath = await _writeCsv(
        tmp,
        '$_csvHeader\n${_row('ING-B', 'ENERCKCAL', 89, 'USDA')}\n',
      );
      final first = await CiqualEnrichmentLoader().loadInto(
        db,
        csvPath: csvPath,
      );
      expect(first.insertedRows, 1);

      var skipped = false;
      final second = await CiqualEnrichmentLoader().loadInto(
        db,
        csvPath: csvPath,
        onFileSkipped: (s) => skipped = s,
      );
      expect(second.insertedRows, 0);
      expect(skipped, isTrue);
    },
  );

  test('ac-126 : fichier modifié → valeurs corrigées et lignes obsolètes '
      'purgées', () async {
    final v1 = await _writeCsv(
      tmp,
      [
        _csvHeader,
        _row('ING-A', 'ENERCKCAL', 10, 'v1'),
        _row('ING-B', 'ENERCKCAL', 89, 'v1'),
        '',
      ].join('\n'),
    );
    await CiqualEnrichmentLoader().loadInto(db, csvPath: v1);
    final v2 = await _writeCsv(
      tmp,
      [_csvHeader, _row('ING-B', 'ENERCKCAL', 92, 'v2'), ''].join('\n'),
    );
    var skipped = true;
    await CiqualEnrichmentLoader().loadInto(
      db,
      csvPath: v2,
      onFileSkipped: (s) => skipped = s,
    );
    expect(skipped, isFalse);
    final rows = await db.select(db.nutritionRecords).get();
    expect(rows, hasLength(1), reason: 'ING-A retiré du fichier : purgé');
    expect(rows.single.ingredientId, 'ING-B');
    expect(rows.single.normalizedValue, 92, reason: 'valeur corrigée');
  });

  test('Phase 10 : état, variante cuite et note d’approximation', () async {
    const header =
        'ingredient_id,ingredient_state_id,row_kind,ciqual_alim_code,'
        'aliment_name,component_id,component_name,normalized_value,'
        'normalized_unit,confidence_code,confidence,match_type,match_note,'
        'source_citation';
    // ING-A : couvert Phase 2 à l'état raw → seule sa variante cuite
    // (état absent de la Phase 2) est ajoutée.
    await db
        .into(db.nutritionRecords)
        .insert(
          NutritionRecordsCompanion.insert(
            nutritionRecordId: 'P2-1',
            ingredientId: 'ING-A',
            ingredientStateId: const Value('raw'),
            sourceId: const Value('CIQUAL'),
            componentId: const Value('ENERCKCAL'),
            normalizedValue: const Value(30),
          ),
        );
    final path = await _writeCsv(
      tmp,
      [
        header,
        'ING-A,raw,main,1,"Aliment A, cru",ENERCKCAL,E,31,kcal,A,0.95,name,,c',
        'ING-A,boiled,cooked_variant,2,"Aliment A, bouilli",ENERCKCAL,E,25,'
            'kcal,A,0.95,name,,c',
        'ING-B,raw,main,3,"Aliment voisin",ENERCKCAL,E,50,kcal,B,0.85,proxy,'
            'assimilé à un aliment voisin,c',
        '',
      ].join('\n'),
    );
    await CiqualEnrichmentLoader().loadInto(db, csvPath: path);
    final rows = await db.select(db.nutritionRecords).get();
    final a = rows.where((r) => r.ingredientId == 'ING-A').toList();
    expect(a.map((r) => r.ingredientStateId).toSet(), {'raw', 'boiled'});
    expect(
      a.where((r) => r.ingredientStateId == 'raw').single.sourceId,
      'CIQUAL',
      reason: 'la Phase 2 prime sur la ligne main',
    );
    final b = rows.singleWhere((r) => r.ingredientId == 'ING-B');
    expect(b.derivationMethod, contains('assimilé'));
    expect(b.mappingConfidence, 0.6);
  });

  test('fichier inexistant : remonte une exception (phase optionnelle '
      'gérée par le CsvImportService)', () async {
    expect(
      () => CiqualEnrichmentLoader().loadInto(
        db,
        csvPath: p.join(tmp.path, 'absent.csv'),
      ),
      throwsA(anything),
    );
  });
}
