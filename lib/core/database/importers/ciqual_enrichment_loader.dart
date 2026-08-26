import 'package:drift/drift.dart';

import '../app_database.dart';
import 'csv_toolkit.dart' show CsvLoadOutcome, runCsvImport;

/// Enrichissement nutritionnel Ciqual (session 2026-08-26, retour PO).
///
/// Insère les records du CSV dérivé `assets/database-enrichment/
/// ciqual_nutrition.csv` (généré par `tool/generate_ciqual_enrichment.dart`
/// depuis les XML ANSES Ciqual 2025-11-03 du repo, avec citations par
/// valeur) dans `nutrition_records`, en respectant deux règles :
///
/// 1. **Complément, pas doublon** : seuls les ingrédients SANS record
///    Phase 2 préexistant sont enrichis (la base Phase 2 prime).
/// 2. **Idempotent** : `nutrition_record_id` déterministe
///    (`CIQ-<ingredient>-<composant>`) + INSERT OR IGNORE + hash
///    SHA-256 du fichier dans `import_state` (re-import skippé si le
///    fichier n'a pas changé).
///
/// Chaque record porte `source_id = ciqual_2025_11_03`, l'aliment
/// Ciqual source (`source_food_name`) et sa citation complète
/// (`notes`) — restitués in-app par le panneau nutrition.
class CiqualEnrichmentLoader {
  static const String sourceName = 'enrichment/ciqual_nutrition';
  static const String sourceId = 'ciqual_2025_11_03';
  static const String sourceUrl = 'https://ciqual.anses.fr/';

  Future<CsvLoadOutcome> loadInto(
    AppDatabase db, {
    required String csvPath,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    // Règle 1 : ingrédients déjà couverts par la Phase 2.
    final coveredRows = await db
        .customSelect(
          'SELECT DISTINCT ingredient_id FROM nutrition_records '
          'WHERE source_id IS NOT NULL AND source_id != ?',
          variables: [Variable.withString(sourceId)],
        )
        .get();
    final covered = coveredRows
        .map((r) => r.read<String>('ingredient_id'))
        .toSet();

    return runCsvImport<CiqualNutritionRow>(
      db: db,
      csvPath: csvPath,
      sourceName: sourceName,
      tableName: db.nutritionRecords.actualTableName,
      parseRow: (row, header) => CiqualNutritionRow.fromCsvRow(row, header),
      insertRows: (batch, rows) async {
        for (final row in rows) {
          if (covered.contains(row.ingredientId)) continue;
          batch.insert(
            db.nutritionRecords,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
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
  });

  factory CiqualNutritionRow.fromCsvRow(List<String> row, List<String> header) {
    String at(String name) => row[header.indexOf(name)].trim();
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

  NutritionRecordsCompanion toCompanion() {
    return NutritionRecordsCompanion.insert(
      nutritionRecordId: 'CIQ-$ingredientId-$componentId',
      ingredientId: ingredientId,
      ingredientStateId: const Value('raw'),
      sourceId: const Value(CiqualEnrichmentLoader.sourceId),
      sourceFoodId: Value(ciqualAlimCode),
      sourceFoodName: Value(alimentName),
      sourceUrl: const Value(CiqualEnrichmentLoader.sourceUrl),
      componentId: Value(componentId),
      componentName: Value(componentName),
      normalizedValue: Value(normalizedValue),
      normalizedUnit: Value(normalizedUnit),
      confidence: Value(confidence),
      valueQualifier: Value('Code de confiance Ciqual $confidenceCode'),
      notes: Value(sourceCitation),
    );
  }
}
