import 'package:drift/drift.dart';

class FlavorCompatibility extends Table {
  TextColumn get recordId => text().named('record_id')();
  IntColumn get combinationSize =>
      integer().named('combination_size').nullable()();
  TextColumn get ingredientIds => text().named('ingredient_ids').nullable()();
  TextColumn get ingredientNames =>
      text().named('ingredient_names').nullable()();
  TextColumn get context => text().nullable()();
  TextColumn get processContext => text().named('process_context').nullable()();
  TextColumn get observedOrPredicted =>
      text().named('observed_or_predicted').nullable()();
  RealColumn get aromaSimilarity =>
      real().named('aroma_similarity').nullable()();
  RealColumn get aromaComplement =>
      real().named('aroma_complement').nullable()();
  RealColumn get aromaContrast => real().named('aroma_contrast').nullable()();
  RealColumn get tasteBalance => real().named('taste_balance').nullable()();
  RealColumn get culinarySupport =>
      real().named('culinary_support').nullable()();
  RealColumn get sensorySupport => real().named('sensory_support').nullable()();
  RealColumn get dominanceRisk => real().named('dominance_risk').nullable()();
  RealColumn get maskingRisk => real().named('masking_risk').nullable()();
  RealColumn get noveltyScore => real().named('novelty_score').nullable()();
  RealColumn get overallScore => real().named('overall_score').nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get keyCompounds => text().named('key_compounds').nullable()();
  TextColumn get keyDescriptors => text().named('key_descriptors').nullable()();
  TextColumn get bridgeIngredients =>
      text().named('bridge_ingredients').nullable()();
  TextColumn get evidenceRefs => text().named('evidence_refs').nullable()();
  TextColumn get modelVersion => text().named('model_version').nullable()();
  TextColumn get explanation => text().nullable()();

  @override
  Set<Column> get primaryKey => {recordId};
}
