import 'package:drift/drift.dart';

import 'recipes.dart';

class RecipeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()
      .named('recipe_id')
      .references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get body => text()();

  @override
  Set<Column> get primaryKey => {id};
}
