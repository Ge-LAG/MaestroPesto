import 'package:drift/drift.dart';

import 'ingredients.dart';

class IngredientAromaCompounds extends Table {
  TextColumn get ingredientId =>
      text().named('ingredient_id').references(Ingredients, #ingredientId)();
  TextColumn get ingredientStateId =>
      text().named('ingredient_state_id').nullable()();
  TextColumn get compoundId => text().named('compound_id')();
  TextColumn get presenceStatus => text().named('presence_status').nullable()();
  RealColumn get concentration => real().nullable()();
  TextColumn get concentrationUnit =>
      text().named('concentration_unit').nullable()();
  RealColumn get concentrationMin =>
      real().named('concentration_min').nullable()();
  RealColumn get concentrationMax =>
      real().named('concentration_max').nullable()();
  TextColumn get analyticalMethod =>
      text().named('analytical_method').nullable()();
  TextColumn get matrix => text().nullable()();
  TextColumn get processState => text().named('process_state').nullable()();
  TextColumn get sourceRef => text().named('source_ref').nullable()();
  TextColumn get evidenceType => text().named('evidence_type').nullable()();
  RealColumn get confidence => real().nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId, ingredientStateId, compoundId};
}
