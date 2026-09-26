import 'package:drift/drift.dart';

import 'recipes.dart';
import 'tags.dart';

class RecipeTags extends Table {
  TextColumn get recipeId => text()
      .named('recipe_id')
      .references(Recipes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId => text()
      .named('tag_id')
      .references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {recipeId, tagId};
}
