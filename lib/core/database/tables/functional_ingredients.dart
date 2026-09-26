import 'package:drift/drift.dart';

import 'ingredients.dart';

class FunctionalIngredients extends Table {
  TextColumn get ingredientId =>
      text().named('ingredient_id').references(Ingredients, #ingredientId)();
  TextColumn get ingredientStateId => text().named('ingredient_state_id')();
  RealColumn get temperatureReferenceC =>
      real().named('temperature_reference_C').nullable()();
  RealColumn get waterContent => real().named('water_content').nullable()();
  RealColumn get fatContent => real().named('fat_content').nullable()();
  RealColumn get proteinContent => real().named('protein_content').nullable()();
  RealColumn get starchContent => real().named('starch_content').nullable()();
  RealColumn get sugarContent => real().named('sugar_content').nullable()();
  RealColumn get fiberContent => real().named('fiber_content').nullable()();
  RealColumn get pectinContent => real().named('pectin_content').nullable()();
  RealColumn get alcoholContent => real().named('alcohol_content').nullable()();
  RealColumn get saltContent => real().named('salt_content').nullable()();
  RealColumn get mineralContent => real().named('mineral_content').nullable()();
  RealColumn get ph => real().named('ph').nullable()();
  RealColumn get titratableAcidity =>
      real().named('titratable_acidity').nullable()();
  RealColumn get waterActivity => real().named('water_activity').nullable()();
  RealColumn get brix => real().nullable()();
  RealColumn get densityGPerMl => real().named('density_g_per_mL').nullable()();
  RealColumn get particleSizeUm =>
      real().named('particle_size_um').nullable()();
  TextColumn get solubility => text().nullable()();
  RealColumn get oilHoldingCapacityGG =>
      real().named('oil_holding_capacity_g_g').nullable()();
  RealColumn get waterHoldingCapacityGG =>
      real().named('water_holding_capacity_g_g').nullable()();
  TextColumn get emulsifyingCapacity =>
      text().named('emulsifying_capacity').nullable()();
  TextColumn get foamingCapacity =>
      text().named('foaming_capacity').nullable()();
  TextColumn get gelationCapability =>
      text().named('gelation_capability').nullable()();
  TextColumn get thickeningCapability =>
      text().named('thickening_capability').nullable()();
  TextColumn get hygroscopicity => text().nullable()();
  TextColumn get thermalStability =>
      text().named('thermal_stability').nullable()();
  TextColumn get freezeThawStability =>
      text().named('freeze_thaw_stability').nullable()();
  TextColumn get oxidationSensitivity =>
      text().named('oxidation_sensitivity').nullable()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  TextColumn get evidenceType => text().named('evidence_type').nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get validityConditions =>
      text().named('validity_conditions').nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId, ingredientStateId};
}
