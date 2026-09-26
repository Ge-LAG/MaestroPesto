import 'package:drift/drift.dart';

class NutritionComponents extends Table {
  TextColumn get componentId => text().named('component_id')();
  TextColumn get canonicalName => text().named('canonical_name').nullable()();
  TextColumn get synonyms => text().nullable()();
  TextColumn get componentGroup => text().named('component_group').nullable()();
  TextColumn get canonicalUnit => text().named('canonical_unit').nullable()();
  TextColumn get infoodsTagname => text().named('infoods_tagname').nullable()();
  TextColumn get ciqualComponentId =>
      text().named('ciqual_component_id').nullable()();
  TextColumn get usdaNutrientId =>
      text().named('usda_nutrient_id').nullable()();
  TextColumn get otherIds => text().named('other_ids').nullable()();
  TextColumn get definition => text().nullable()();
  TextColumn get conversionNotes =>
      text().named('conversion_notes').nullable()();

  @override
  Set<Column> get primaryKey => {componentId};
}
