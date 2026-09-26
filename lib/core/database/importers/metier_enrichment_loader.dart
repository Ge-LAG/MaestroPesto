import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../app_database.dart';
import 'csv_toolkit.dart';

/// Phase 10 — import des tables d'enrichissement métier.
///
/// Chaque fichier est la source exclusive de sa table : quand son hash
/// change, la table est purgée puis rechargée (ré-import fiable,
/// ac-126) ; fichier inchangé → import sauté. Un fichier absent (dossier
/// de test partiel) est ignoré sans échouer l'import global.
class MetierEnrichmentLoader {
  /// Charge les fichiers d'enrichissement de [enrichmentDir] et les deux
  /// CSV Phase 4 orphelins de [phase4Dir]. Renvoie le nombre de lignes
  /// insérées par table.
  Future<Map<String, int>> loadInto(
    AppDatabase db, {
    required String enrichmentDir,
    required String phase4Dir,
    void Function(String source, bool skipped)? onFileSkipped,
  }) async {
    final report = <String, int>{};
    Future<void> load<T extends Table, D>(
      String sourceName,
      String path,
      TableInfo<T, D> table,
      Insertable<D> Function(List<String>, List<String>) parse,
    ) async {
      try {
        var purged = false;
        final outcome = await runCsvImport<Insertable<D>>(
          db: db,
          csvPath: path,
          sourceName: sourceName,
          tableName: table.actualTableName,
          parseRow: parse,
          insertRows: (batch, rows) async {
            if (!purged) {
              batch.deleteAll(table);
              purged = true;
            }
            batch.insertAll(table, rows, mode: InsertMode.insertOrReplace);
          },
          onSkip: (s) => onFileSkipped?.call(sourceName, s),
        );
        report[sourceName] = outcome.insertedRows;
      } on Object catch (e) {
        // Fichier absent ou illisible : phase optionnelle.
        if (e is FormatException) rethrow;
        report[sourceName] = 0;
        onFileSkipped?.call(sourceName, true);
      }
    }

    await load(
      'enrichment/ingredient_culinary',
      p.join(enrichmentDir, 'ingredient_culinary.csv'),
      db.ingredientCulinary,
      parseIngredientCulinary,
    );
    await load(
      'enrichment/process_factors',
      p.join(enrichmentDir, 'process_factors.csv'),
      db.processFactors,
      parseProcessFactor,
    );
    await load(
      'enrichment/ingredient_functional_components',
      p.join(enrichmentDir, 'ingredient_functional_components.csv'),
      db.ingredientFunctionalComponents,
      parseIngredientComponent,
    );
    await load(
      'enrichment/ingredient_flavor_profiles',
      p.join(enrichmentDir, 'ingredient_flavor_profiles.csv'),
      db.ingredientFlavorProfiles,
      parseFlavorProfile,
    );
    await load(
      'enrichment/culinary_pairings',
      p.join(enrichmentDir, 'culinary_pairings.csv'),
      db.culinaryPairings,
      parseCulinaryPairing,
    );
    await load(
      'enrichment/ingredient_allergens',
      p.join(enrichmentDir, 'ingredient_allergens.csv'),
      db.ingredientAllergens,
      parseIngredientAllergens,
    );
    await load(
      'phase4/functional_components',
      p.join(phase4Dir, 'functional_components.csv'),
      db.functionalComponents,
      parseFunctionalComponent,
    );
    await load(
      'phase4/experimental_validation_cases',
      p.join(phase4Dir, 'experimental_validation_cases.csv'),
      db.experimentalValidationCases,
      parseValidationCase,
    );
    return report;
  }
}

// Parseurs top-level (exécutés dans un isolate par runCsvImport).

Insertable<IngredientCulinaryData> parseIngredientCulinary(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return IngredientCulinaryCompanion(
    ingredientId: Value(c.reqStr('ingredient_id')),
    densityGPerMl: Value(c.dbl('density_g_per_ml')),
    densityNote: Value(c.str('density_note')),
    unitMasses: Value(c.str('unit_masses')),
    ph: Value(c.dbl('ph')),
    phConfidence: Value(c.dbl('ph_confidence')),
    phNote: Value(c.str('ph_note')),
  );
}

Insertable<IngredientAllergen> parseIngredientAllergens(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return IngredientAllergensCompanion(
    ingredientId: Value(c.reqStr('ingredient_id')),
    declaredTags: Value(c.str('declared_tags')),
    inferredTags: Value(c.str('inferred_tags')),
    removedTags: Value(c.str('removed_tags')),
    note: Value(c.str('note')),
  );
}

Insertable<ProcessFactor> parseProcessFactor(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return ProcessFactorsCompanion(
    factorId: Value(c.reqStr('factor_id')),
    foodGroup: Value(c.reqStr('food_group')),
    method: Value(c.reqStr('method')),
    yieldFactor: Value(c.dbl('yield_factor') ?? 1),
    fatUptakeG: Value(c.dbl('fat_uptake_g')),
    fatRetention: Value(c.dbl('fat_retention')),
    retention: Value(c.str('retention')),
    confidence: Value(c.dbl('confidence')),
    source: Value(c.str('source')),
    note: Value(c.str('note')),
  );
}

Insertable<IngredientFunctionalComponent> parseIngredientComponent(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return IngredientFunctionalComponentsCompanion(
    ingredientId: Value(c.reqStr('ingredient_id')),
    componentId: Value(c.reqStr('component_id')),
    fractionGPer100g: Value(c.dbl('fraction_g_per_100g') ?? 0),
    basis: Value(c.str('basis')),
    sourceRefs: Value(c.str('source_refs')),
    confidence: Value(c.dbl('confidence')),
  );
}

Insertable<IngredientFlavorProfile> parseFlavorProfile(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return IngredientFlavorProfilesCompanion(
    ingredientId: Value(c.reqStr('ingredient_id')),
    descriptors: Value(c.str('descriptors') ?? ''),
    context: Value(c.str('context')),
    intensity: Value(c.dbl('intensity')),
    evidenceLevel: Value(c.str('evidence_level') ?? 'default'),
    confidence: Value(c.dbl('confidence') ?? 0.25),
    sourceRefs: Value(c.str('source_refs')),
    note: Value(c.str('note')),
  );
}

Insertable<CulinaryPairing> parseCulinaryPairing(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return CulinaryPairingsCompanion(
    pairId: Value(c.reqStr('pair_id')),
    ingredientAId: Value(c.reqStr('ingredient_a_id')),
    ingredientBId: Value(c.reqStr('ingredient_b_id')),
    kind: Value(c.str('kind') ?? 'classic'),
    strength: Value(c.dbl('strength') ?? 0.8),
    source: Value(c.str('source')),
    note: Value(c.str('note')),
  );
}

Insertable<FunctionalComponent> parseFunctionalComponent(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return FunctionalComponentsCompanion(
    componentId: Value(c.reqStr('component_id')),
    canonicalName: Value(c.str('canonical_name')),
    category: Value(c.str('category')),
    sourceOrganism: Value(c.str('source_organism')),
    role: Value(c.str('role')),
    chemistry: Value(c.str('chemistry')),
    thermalBehavior: Value(c.str('thermal_behavior')),
    solubility: Value(c.str('solubility')),
    sourceRefs: Value(c.str('source_refs')),
    confidence: Value(c.dbl('confidence')),
  );
}

Insertable<ExperimentalValidationCase> parseValidationCase(
  List<String> row,
  List<String> header,
) {
  final c = CsvCells(row, columnIndex(header));
  return ExperimentalValidationCasesCompanion(
    caseId: Value(c.reqStr('case_id')),
    formulationId: Value(c.str('formulation_id')),
    ingredientIds: Value(c.str('ingredient_ids')),
    quantities: Value(c.str('quantities')),
    units: Value(c.str('units')),
    processSequence: Value(c.str('process_sequence')),
    measuredInputs: Value(c.str('measured_inputs')),
    measuredOutputs: Value(c.str('measured_outputs')),
    source: Value(c.str('source')),
    temperatureC: Value(c.dbl('temperature_C')),
    ph: Value(c.dbl('ph')),
    aw: Value(c.dbl('aw')),
    notes: Value(c.str('notes')),
  );
}
