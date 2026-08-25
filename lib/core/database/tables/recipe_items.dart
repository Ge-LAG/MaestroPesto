import 'package:drift/drift.dart';

import 'ciqual_foods.dart';
import 'ingredients.dart';
import 'recipes.dart';

class RecipeItems extends Table {
  TextColumn get id => text()();

  @ReferenceName('recipe_items')
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

  /// Optional Phase 1 ingredient reference (added in v3, Lot D). When the
  /// UI binds an ingredient to a Phase 1 row via autocomplete, this FK is
  /// populated so the recipe detail can resolve the canonical name, the
  /// allergens and the nutrition profile from the 4 metier databases.
  TextColumn get ingredientId => text()
      .named('ingredient_id')
      .nullable()
      .references(Ingredients, #ingredientId)();

  @override
  Set<Column> get primaryKey => {id};
}
