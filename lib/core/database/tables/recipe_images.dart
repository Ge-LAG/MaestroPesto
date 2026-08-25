import 'package:drift/drift.dart';

import 'recipes.dart';

/// Stores the ordered list of photos attached to a recipe.
///
/// This table exists to back the UI field `Recipe.images` introduced by
/// the UI/UX pass (commit 4f549b7). One row per photo. The order is
/// preserved via the `position` integer (smallest = first).
///
/// On cascade: deleting a recipe deletes its photos. Photos survive a
/// recipe duplication: the duplication flow creates new ids and copies
/// the path/label verbatim.
@DataClassName('RecipeImageRow')
class RecipeImages extends Table {
  TextColumn get id => text()();

  @ReferenceName('recipe_photos')
  TextColumn get recipeId => text()
      .named('recipe_id')
      .references(Recipes, #id, onDelete: KeyAction.cascade)();

  IntColumn get position => integer()();

  TextColumn get path => text()();

  TextColumn get label => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
