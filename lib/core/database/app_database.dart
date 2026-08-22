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

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
