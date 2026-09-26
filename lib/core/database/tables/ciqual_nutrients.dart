import 'package:drift/drift.dart';

import 'ciqual_foods.dart';

class CiqualNutrients extends Table {
  TextColumn get foodCode => text()
      .named('food_code')
      .references(CiqualFoods, #code, onDelete: KeyAction.cascade)();
  TextColumn get nutrientKey => text().named('nutrient_key')();
  RealColumn get valuePer100g => real().named('value_per_100g')();

  @override
  Set<Column> get primaryKey => {foodCode, nutrientKey};
}
