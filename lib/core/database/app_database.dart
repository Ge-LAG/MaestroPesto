import 'package:drift/drift.dart';

import 'tables/ciqual_foods.dart';
import 'tables/ciqual_nutrients.dart';
import 'tables/flavor_compatibility.dart';
import 'tables/functional_ingredients.dart';
import 'tables/ingredient_aroma_compounds.dart';
import 'tables/ingredient_states.dart';
import 'tables/ingredients.dart';
import 'tables/interaction_rules.dart';
import 'tables/nutrition_components.dart';
import 'tables/nutrition_records.dart';
import 'tables/process_operations.dart';
import 'tables/recipe_images.dart';
import 'tables/recipe_items.dart';
import 'tables/recipe_steps.dart';
import 'tables/recipe_tags.dart';
import 'tables/recipes.dart';
import 'tables/sync_events.dart';
import 'tables/tags.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Recipes,
    RecipeImages,
    RecipeSteps,
    RecipeItems,
    Tags,
    RecipeTags,
    CiqualFoods,
    CiqualNutrients,
    SyncEvents,
    Ingredients,
    IngredientStates,
    NutritionComponents,
    NutritionRecords,
    IngredientAromaCompounds,
    FlavorCompatibility,
    FunctionalIngredients,
    InteractionRules,
    ProcessOperations,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// Schema versions:
  /// - v1 (2026-08-22, Lot A): initial schema, 17 tables.
  /// - v2 (2026-08-25, Lot D): adds `recipe_images` table for the UI/UX
  ///   field `Recipe.images` introduced by the UI/UX pass.
  /// - v3 (2026-08-25, Lot D): adds nullable `recipe_items.ingredient_id`
  ///   FK to `ingredients` so the UI can resolve Phase 1 canonical names.
  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(recipeImages);
      }
      if (from < 3) {
        // Add nullable ingredient_id with FK to phase1 ingredients.
        // ALTER TABLE supports adding a column with REFERENCES in SQLite
        // when the column is nullable and the FK is enforced by the engine
        // (PRAGMA foreign_keys = ON, set in beforeOpen).
        await m.addColumn(recipeItems, recipeItems.ingredientId);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
