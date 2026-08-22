import 'package:drift/drift.dart';

class Ingredients extends Table {
  TextColumn get ingredientId => text().named('ingredient_id')();
  TextColumn get canonicalNameFr => text().named('canonical_name_fr')();
  TextColumn get canonicalNameEn =>
      text().named('canonical_name_en').nullable()();
  TextColumn get aliasesFr => text().named('aliases_fr').nullable()();
  TextColumn get aliasesEn => text().named('aliases_en').nullable()();
  TextColumn get scientificName => text().named('scientific_name').nullable()();
  TextColumn get kingdomOrOrigin =>
      text().named('kingdom_or_origin').nullable()();
  TextColumn get categoryLevel1 => text().named('category_level_1')();
  TextColumn get categoryLevel2 =>
      text().named('category_level_2').nullable()();
  TextColumn get categoryLevel3 =>
      text().named('category_level_3').nullable()();
  TextColumn get sourceOrganism => text().named('source_organism').nullable()();
  TextColumn get anatomicalPart => text().named('anatomical_part').nullable()();
  TextColumn get ingredientClass =>
      text().named('ingredient_class').nullable()();
  TextColumn get rawOrIntermediate =>
      text().named('raw_or_intermediate').nullable()();
  TextColumn get processingState =>
      text().named('processing_state').nullable()();
  TextColumn get physicalForm => text().named('physical_form').nullable()();
  BoolColumn get fermented => boolean().withDefault(const Constant(false))();
  BoolColumn get dried => boolean().withDefault(const Constant(false))();
  BoolColumn get smoked => boolean().withDefault(const Constant(false))();
  BoolColumn get roasted => boolean().withDefault(const Constant(false))();
  BoolColumn get concentrated => boolean().withDefault(const Constant(false))();
  BoolColumn get alcoholic => boolean().withDefault(const Constant(false))();
  TextColumn get genericAbvRange =>
      text().named('generic_abv_range').nullable()();
  TextColumn get countryOrRegionRelevance =>
      text().named('country_or_region_relevance').nullable()();
  TextColumn get foodonId => text().named('foodon_id').nullable()();
  TextColumn get langualIds => text().named('langual_ids').nullable()();
  TextColumn get foodex2Code => text().named('foodex2_code').nullable()();
  TextColumn get ciqualIds => text().named('ciqual_ids').nullable()();
  TextColumn get usdaFdcIds => text().named('usda_fdc_ids').nullable()();
  TextColumn get otherExternalIds =>
      text().named('other_external_ids').nullable()();
  TextColumn get allergenTags => text().named('allergen_tags').nullable()();
  TextColumn get regulatoryNotes =>
      text().named('regulatory_notes').nullable()();
  TextColumn get sourceRefs => text().named('source_refs').nullable()();
  RealColumn get confidence => real().nullable()();
  TextColumn get reviewStatus => text().named('review_status').nullable()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {ingredientId};
}
