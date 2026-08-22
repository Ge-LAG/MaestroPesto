import 'package:drift/drift.dart';

import 'ciqual_foods.dart';
import 'recipes.dart';

class RecipeItems extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()
      .named('recipe_id')
      .references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get kind => text().customConstraint(
    "NOT NULL CHECK (kind IN ('ciqual', 'recipe', 'free'))",
  )();
  TextColumn get label => text()();
  RealColumn get quantityG => real().named('quantity_g')();
  TextColumn get ciqualCode =>
      text().named('ciqual_code').nullable().references(CiqualFoods, #code)();
  TextColumn get childRecipeId =>
      text().named('child_recipe_id').nullable().references(Recipes, #id)();

  @override
  Set<Column> get primaryKey => {id};
}
