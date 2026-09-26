import 'package:drift/drift.dart';

import '../app_database.dart';
import 'csv_toolkit.dart' show CsvLoadOutcome, runCsvImport;

/// Enrichissement nutritionnel Ciqual (session 2026-08-26 ; Phase 10).
///
/// Insère les records du CSV dérivé `assets/database-enrichment/
/// ciqual_nutrition.csv` (généré par `tool/generate_ciqual_enrichment.dart`
/// depuis les XML ANSES Ciqual 2025-11-03 du repo, avec citations par
/// valeur) dans `nutrition_records`, en respectant trois règles :
///
/// 1. **Complément, pas doublon** : la Phase 2 prime. Les lignes
///    `main` d'un ingrédient déjà couvert par la Phase 2 sont ignorées ;
///    ses variantes cuites mesurées (`cooked_variant`) ne sont ajoutées
///    que pour les états absents de la Phase 2.
/// 2. **Ré-import fiable (ac-126)** : quand le fichier change (hash
///    SHA-256 différent), les records de la source sont purgés puis
///    réinsérés — une correction de données atteint les installations
///    existantes. Fichier inchangé → import sauté.
/// 3. **Traçabilité** : `source_id = ciqual_2025_11_03`, aliment Ciqual
///    source, citation complète ; les correspondances approchées
///    (`match_type = proxy`) portent leur justification dans
///    `derivation_method`, restituée in-app.
///
/// Le même chargeur sert les compléments en libre accès (même format de
/// fichier) : USDA FoodData Central et composition calculée, qui ne
/// comblent que les ingrédients sans autre source.
class NutritionEnrichmentSource {
  const NutritionEnrichmentSource({
    required this.name,
    required this.id,
    required this.url,
    required this.recordPrefix,
  });

  /// Nom de la source dans `import_state`.
  final String name;

  /// `source_id` des records produits.
  final String id;
  final String url;

  /// Préfixe des identifiants de records (unicité entre sources).
  final String recordPrefix;

  static const ciqual = NutritionEnrichmentSource(
    name: 'enrichment/ciqual_nutrition',
    id: 'ciqual_2025_11_03',
    url: 'https://ciqual.anses.fr/',
    recordPrefix: 'CIQ',
  );

  /// USDA FoodData Central (SR Legacy, Foundation Foods) — CC0 1.0.
  static const usda = NutritionEnrichmentSource(
    name: 'enrichment/usda_nutrition',
    id: 'usda_fdc',
    url: 'https://fdc.nal.usda.gov/',
    recordPrefix: 'USDA',
  );

  /// Composition calculée (préparations de base, substances pures).
  static const computed = NutritionEnrichmentSource(
    name: 'enrichment/computed_nutrition',
    id: 'calc_composition',
    url: 'https://eur-lex.europa.eu/eli/reg/2011/1169/oj',
    recordPrefix: 'CALC',
  );
}

class CiqualEnrichmentLoader {
  const CiqualEnrichmentLoader({
    this.source = NutritionEnrichmentSource.ciqual,
  });

  /// Source chargée (Ciqual par défaut).
  final NutritionEnrichmentSource source;

  static const String sourceName = 'enrichment/ciqual_nutrition';
  static const String sourceId = 'ciqual_2025_11_03';
  static const String sourceUrl = 'https://ciqual.anses.fr/';

  Future<CsvLoadOutcome> loadInto(
    AppDatabase db, {
    required String csvPath,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    // Règle 1 : états couverts par la Phase 2 (hors enrichissement).
    final coveredRows = await db
        .customSelect(
          'SELECT DISTINCT ingredient_id, ingredient_state_id '
          'FROM nutrition_records '
          'WHERE source_id IS NULL OR source_id != ?',
          variables: [Variable.withString(source.id)],
        )
        .get();
    final coveredIngredients = <String>{};
    final coveredStates = <String>{};
    for (final r in coveredRows) {
      final id = r.read<String>('ingredient_id');
      coveredIngredients.add(id);
      coveredStates.add('$id@${r.readNullable<String>('ingredient_state_id')}');
    }

    var purged = false;
    return runCsvImport<CiqualNutritionRow>(
      db: db,
      csvPath: csvPath,
      sourceName: source.name,
      tableName: db.nutritionRecords.actualTableName,
      parseRow: (row, header) => CiqualNutritionRow.fromCsvRow(row, header),
      insertRows: (batch, rows) async {
        if (!purged) {
          // Règle 2 : fichier modifié → purge de la source avant
          // réinsertion (le premier lot n'est produit que si le hash a
          // changé).
          batch.deleteWhere(
            db.nutritionRecords,
            (t) => t.sourceId.equals(source.id),
          );
          purged = true;
        }
        for (final row in rows) {
          if (row.isMain && coveredIngredients.contains(row.ingredientId)) {
            continue;
          }
          if (!row.isMain &&
              coveredStates.contains('${row.ingredientId}@${row.stateId}')) {
            continue;
          }
          batch.insert(
            db.nutritionRecords,
            row.toCompanion(source),
            mode: InsertMode.insertOrReplace,
          );
        }
      },
      onSkip: onFileSkipped,
    );
  }
}

/// Ligne du CSV d'enrichissement (voir l'en-tête du fichier).
class CiqualNutritionRow {
  const CiqualNutritionRow({
    required this.ingredientId,
    required this.ciqualAlimCode,
    required this.alimentName,
    required this.componentId,
    required this.componentName,
    required this.normalizedValue,
    required this.normalizedUnit,
    required this.confidenceCode,
    required this.confidence,
    required this.sourceCitation,
    this.stateId = 'raw',
    this.isMain = true,
    this.matchType = 'name',
    this.matchNote = '',
  });

  factory CiqualNutritionRow.fromCsvRow(List<String> row, List<String> header) {
    String at(String name) => row[header.indexOf(name)].trim();
    String opt(String name, String fallback) {
      final i = header.indexOf(name);
      if (i == -1 || i >= row.length) return fallback;
      final v = row[i].trim();
      return v.isEmpty ? fallback : v;
    }

    return CiqualNutritionRow(
      ingredientId: at('ingredient_id'),
      ciqualAlimCode: at('ciqual_alim_code'),
      alimentName: at('aliment_name'),
      componentId: at('component_id'),
      componentName: at('component_name'),
      normalizedValue: double.parse(at('normalized_value')),
      normalizedUnit: at('normalized_unit'),
      confidenceCode: at('confidence_code'),
      confidence: double.parse(at('confidence')),
      sourceCitation: at('source_citation'),
      stateId: opt('ingredient_state_id', 'raw'),
      isMain: opt('row_kind', 'main') == 'main',
      matchType: opt('match_type', 'name'),
      matchNote: opt('match_note', ''),
    );
  }

  final String ingredientId;
  final String ciqualAlimCode;
  final String alimentName;
  final String componentId;
  final String componentName;
  final double normalizedValue;
  final String normalizedUnit;
  final String confidenceCode;
  final double confidence;
  final String sourceCitation;

  /// État de préparation déduit du nom Ciqual (raw, dried, boiled…).
  final String stateId;

  /// Ligne de l'aliment principal (vs variante cuite mesurée).
  final bool isMain;

  /// code | name | equivalent | proxy (voir le générateur).
  final String matchType;
  final String matchNote;

  /// Confiance du rapprochement ingrédient ↔ aliment source.
  double get mappingConfidence => switch (matchType) {
    'code' => 0.95,
    'equivalent' => 0.9,
    'name' => 0.8,
    'computed' => 0.75,
    _ => 0.6,
  };

  /// Justification d'une approximation (null pour une correspondance
  /// directe).
  String? get derivationNote => switch (matchType) {
    'proxy' =>
      'Valeur approchée : ${matchNote.isEmpty ? alimentName : matchNote}',
    'computed' => 'Calcul par composition : $matchNote',
    _ => null,
  };

  NutritionRecordsCompanion toCompanion([
    NutritionEnrichmentSource source = NutritionEnrichmentSource.ciqual,
  ]) {
    return NutritionRecordsCompanion.insert(
      nutritionRecordId:
          '${source.recordPrefix}-$ingredientId-$stateId-$componentId',
      ingredientId: ingredientId,
      ingredientStateId: Value(stateId),
      sourceId: Value(source.id),
      sourceFoodId: Value(ciqualAlimCode),
      sourceFoodName: Value(alimentName),
      sourceUrl: Value(source.url),
      componentId: Value(componentId),
      componentName: Value(componentName),
      normalizedValue: Value(normalizedValue),
      normalizedUnit: Value(normalizedUnit),
      confidence: Value(confidence),
      mappingConfidence: Value(mappingConfidence),
      derivationMethod: Value(derivationNote),
      valueQualifier: Value(
        source.id == NutritionEnrichmentSource.ciqual.id
            ? 'Code de confiance Ciqual $confidenceCode'
            : confidenceCode,
      ),
      notes: Value(sourceCitation),
    );
  }
}
