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
