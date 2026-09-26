import 'package:drift/drift.dart';

import 'ingredients.dart';

class NutritionRecords extends Table {
  TextColumn get nutritionRecordId => text().named('nutrition_record_id')();
  TextColumn get ingredientId =>
      text().named('ingredient_id').references(Ingredients, #ingredientId)();
  TextColumn get ingredientStateId =>
      text().named('ingredient_state_id').nullable()();
  TextColumn get sourceId => text().named('source_id').nullable()();
  TextColumn get sourceFoodId => text().named('source_food_id').nullable()();
  TextColumn get sourceFoodName =>
      text().named('source_food_name').nullable()();
  TextColumn get sourceVersion => text().named('source_version').nullable()();
  TextColumn get sourceCountry => text().named('source_country').nullable()();
  TextColumn get componentId => text().named('component_id').nullable()();
  TextColumn get componentName => text().named('component_name').nullable()();
  TextColumn get componentGroup => text().named('component_group').nullable()();
  RealColumn get originalValue => real().named('original_value').nullable()();
  TextColumn get originalUnit => text().named('original_unit').nullable()();
  RealColumn get normalizedValue =>
      real().named('normalized_value').nullable()();
  TextColumn get normalizedUnit => text().named('normalized_unit').nullable()();
  TextColumn get basis => text().nullable()();
  TextColumn get valueQualifier => text().named('value_qualifier').nullable()();
  TextColumn get valueType => text().named('value_type').nullable()();
  RealColumn get minValue => real().named('min_value').nullable()();
  RealColumn get maxValue => real().named('max_value').nullable()();
  IntColumn get sampleCount => integer().named('sample_count').nullable()();
  TextColumn get analyticalMethod =>
      text().named('analytical_method').nullable()();
  TextColumn get derivationMethod =>
      text().named('derivation_method').nullable()();
  TextColumn get dataDate => text().named('data_date').nullable()();
  TextColumn get retrievalDate => text().named('retrieval_date').nullable()();
  TextColumn get sourceUrl => text().named('source_url').nullable()();
  RealColumn get confidence => real().nullable()();
  RealColumn get mappingConfidence =>
      real().named('mapping_confidence').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {nutritionRecordId};
}
