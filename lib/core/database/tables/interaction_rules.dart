import 'package:drift/drift.dart';

class InteractionRules extends Table {
  TextColumn get ruleId => text().named('rule_id')();
  TextColumn get ruleFamily => text().named('rule_family').nullable()();
  TextColumn get reactantOrComponentIds =>
      text().named('reactant_or_component_ids').nullable()();
  TextColumn get ingredientConstraints =>
      text().named('ingredient_constraints').nullable()();
  TextColumn get compositionConstraints =>
      text().named('composition_constraints').nullable()();
  TextColumn get processConstraints =>
      text().named('process_constraints').nullable()();
  RealColumn get phMin => real().named('ph_min').nullable()();
  RealColumn get phMax => real().named('ph_max').nullable()();
  RealColumn get temperatureMin => real().named('temperature_min').nullable()();
  RealColumn get temperatureMax => real().named('temperature_max').nullable()();
  RealColumn get timeMin => real().named('time_min').nullable()();
  RealColumn get timeMax => real().named('time_max').nullable()();
  RealColumn get waterActivityMin =>
      real().named('water_activity_min').nullable()();
  RealColumn get waterActivityMax =>
      real().named('water_activity_max').nullable()();
  TextColumn get shearConstraints =>
      text().named('shear_constraints').nullable()();
  TextColumn get orderConstraints =>
      text().named('order_constraints').nullable()();
  TextColumn get predictedEffect =>
      text().named('predicted_effect').nullable()();
  TextColumn get effectDirection =>
      text().named('effect_direction').nullable()();
  TextColumn get effectMagnitude =>
      text().named('effect_magnitude').nullable()();
  TextColumn get outputProperty => text().named('output_property').nullable()();
  TextColumn get equationOrLogic =>
      text().named('equation_or_logic').nullable()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  TextColumn get evidenceType => text().named('evidence_type').nullable()();
  RealColumn get confidence => real().nullable()();
  BoolColumn get extrapolationAllowed =>
      boolean().named('extrapolation_allowed').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {ruleId};
}
