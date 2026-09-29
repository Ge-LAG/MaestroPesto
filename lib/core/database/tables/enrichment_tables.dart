import 'package:drift/drift.dart';

// Phase 10 — tables d'enrichissement métier (schéma v4).
//
// Alimentées par les CSV de `assets/database-enrichment/` (générés par
// `tool/generate_metier_enrichment.dart`) et par les deux CSV Phase 4
// jusque-là orphelins. Pas de clé étrangère vers `ingredients` : ces
// tables sont purgées puis rechargées en bloc quand leur fichier change,
// indépendamment de l'ordre d'import.

/// Données culinaires et physico-chimiques d'un ingrédient : densité,
/// masses unitaires (conversion des quantités), pH typique.
class IngredientCulinary extends Table {
  TextColumn get ingredientId => text().named('ingredient_id')();
  RealColumn get densityGPerMl => real().named('density_g_per_ml').nullable()();
  TextColumn get densityNote => text().named('density_note').nullable()();

  /// Masses unitaires `unité:grammes` séparées par `|` (ex.
  /// `piece:50|gousse:5`).
  TextColumn get unitMasses => text().named('unit_masses').nullable()();
  RealColumn get ph => real().nullable()();
  RealColumn get phConfidence => real().named('ph_confidence').nullable()();
  TextColumn get phNote => text().named('ph_note').nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId};
}

/// Facteurs de procédé par groupe d'aliments et mode de cuisson.
class ProcessFactors extends Table {
  TextColumn get factorId => text().named('factor_id')();
  TextColumn get foodGroup => text().named('food_group')();
  TextColumn get method => text()();
  RealColumn get yieldFactor => real().named('yield_factor')();
  RealColumn get fatUptakeG => real().named('fat_uptake_g').nullable()();
  RealColumn get fatRetention => real().named('fat_retention').nullable()();

  /// Rétentions `TAG:facteur` séparées par `|` (1 si absent).
  TextColumn get retention => text().nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get source => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {factorId};
}

/// Maillon ingrédient → composants fonctionnels Phase 4 (ac-122).
class IngredientFunctionalComponents extends Table {
  TextColumn get ingredientId => text().named('ingredient_id')();
  TextColumn get componentId => text().named('component_id')();

  /// Teneur du composant (g pour 100 g d'ingrédient).
  RealColumn get fractionGPer100g => real().named('fraction_g_per_100g')();
  TextColumn get basis => text().nullable()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId, componentId};
}

/// Dictionnaire des composants fonctionnels (Phase 4, orphelin importé).
class FunctionalComponents extends Table {
  TextColumn get componentId => text().named('component_id')();
  TextColumn get canonicalName => text().named('canonical_name').nullable()();
  TextColumn get category => text().nullable()();
  TextColumn get sourceOrganism => text().named('source_organism').nullable()();
  TextColumn get role => text().nullable()();
  TextColumn get chemistry => text().nullable()();
  TextColumn get thermalBehavior =>
      text().named('thermal_behavior').nullable()();
  TextColumn get solubility => text().nullable()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {componentId};
}

/// Cas expérimentaux de validation (Phase 4, orphelin importé).
class ExperimentalValidationCases extends Table {
  TextColumn get caseId => text().named('case_id')();
  TextColumn get formulationId => text().named('formulation_id').nullable()();
  TextColumn get ingredientIds => text().named('ingredient_ids').nullable()();
  TextColumn get quantities => text().nullable()();
  TextColumn get units => text().nullable()();
  TextColumn get processSequence =>
      text().named('process_sequence').nullable()();
  TextColumn get measuredInputs => text().named('measured_inputs').nullable()();
  TextColumn get measuredOutputs =>
      text().named('measured_outputs').nullable()();
  TextColumn get source => text().nullable()();
  RealColumn get temperatureC => real().named('temperature_C').nullable()();
  RealColumn get ph => real().nullable()();
  RealColumn get aw => real().nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {caseId};
}

/// Profil sensoriel d'un ingrédient (Lot E, 603/603).
class IngredientFlavorProfiles extends Table {
  TextColumn get ingredientId => text().named('ingredient_id')();

  /// Descripteurs de l'ontologie `id:intensité` séparés par `|`.
  TextColumn get descriptors => text()();

  /// Contexte culinaire : sweet | savory | both.
  TextColumn get context => text().nullable()();

  /// Puissance aromatique (risque de dominance) 0..1.
  RealColumn get intensity => real().nullable()();

  /// measured | curated | family | default.
  TextColumn get evidenceLevel => text().named('evidence_level')();
  RealColumn get confidence => real()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId};
}

/// Accords culinaires curatés (soutien empirique w4).
class CulinaryPairings extends Table {
  TextColumn get pairId => text().named('pair_id')();
  TextColumn get ingredientAId => text().named('ingredient_a_id')();
  TextColumn get ingredientBId => text().named('ingredient_b_id')();

  /// classic | regional | modern | contrast_negative.
  TextColumn get kind => text()();
  RealColumn get strength => real()();
  TextColumn get source => text().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {pairId};
}

/// Allergènes par ingrédient (refonte UX 2026-09-26) : étiquettes du
/// référentiel conservées, allergènes déduits (annexe II du règlement UE
/// 1169/2011, règles curatées) et étiquettes erronées retirées.
class IngredientAllergens extends Table {
  TextColumn get ingredientId => text().named('ingredient_id')();

  /// Étiquettes du référentiel conservées, séparées par `|`.
  TextColumn get declaredTags => text().named('declared_tags').nullable()();

  /// Allergènes déduits du nom et de la catégorie, séparés par `|`.
  TextColumn get inferredTags => text().named('inferred_tags').nullable()();

  /// Étiquettes du référentiel corrigées (retirées), séparées par `|`.
  TextColumn get removedTags => text().named('removed_tags').nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId};
}

/// Phase 11 (schéma v6) — rôles des squelettes de plats (recette à
/// l'envers) : candidats, nombre d'ingrédients et bornes de masse par
/// portion. Curation `tool/data/dish_skeletons.csv`.
@DataClassName('DishSkeletonRole')
class DishSkeletonRoles extends Table {
  TextColumn get skeletonId => text().named('skeleton_id')();
  TextColumn get role => text()();
  TextColumn get roleLabel => text().named('role_label').nullable()();
  IntColumn get minCount => integer().named('min_count')();
  IntColumn get maxCount => integer().named('max_count')();
  RealColumn get minGPerServing => real().named('min_g_per_serving')();
  RealColumn get maxGPerServing => real().named('max_g_per_serving')();

  /// Identifiants `ING-*` séparés par `|`.
  TextColumn get candidates => text()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {skeletonId, role};
}

/// Phase 11 (schéma v6) — gabarit de procédé de chaque squelette :
/// famille (type de plat), mode de cuisson, masse par portion, durée
/// réglable et étapes à trous. Curation `tool/data/dish_processes.csv`.
@DataClassName('DishProcess')
class DishProcesses extends Table {
  TextColumn get skeletonId => text().named('skeleton_id')();
  TextColumn get familyId => text().named('family_id')();
  TextColumn get familyLabel => text().named('family_label').nullable()();
  TextColumn get skeletonLabel => text().named('skeleton_label').nullable()();
  TextColumn get method => text()();
  RealColumn get servingMassG => real().named('serving_mass_g')();
  RealColumn get servingMinG => real().named('serving_min_g').nullable()();
  RealColumn get servingMaxG => real().named('serving_max_g').nullable()();
  RealColumn get durationMin => real().named('duration_min').nullable()();
  RealColumn get durationDefault =>
      real().named('duration_default').nullable()();
  RealColumn get durationMax => real().named('duration_max').nullable()();

  /// Étapes séparées par ` | `.
  TextColumn get steps => text()();
  TextColumn get source => text().nullable()();

  @override
  Set<Column> get primaryKey => {skeletonId};
}
