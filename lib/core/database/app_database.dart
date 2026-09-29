import 'package:drift/drift.dart';

import 'tables/ciqual_foods.dart';
import 'tables/ciqual_nutrients.dart';
import 'tables/enrichment_tables.dart';
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
    IngredientCulinary,
    ProcessFactors,
    IngredientFunctionalComponents,
    FunctionalComponents,
    ExperimentalValidationCases,
    IngredientFlavorProfiles,
    CulinaryPairings,
    IngredientAllergens,
    DishSkeletonRoles,
    DishProcesses,
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
  /// - v4 (2026-09-26, Phase 10): enrichment tables (culinary data,
  ///   process factors, ingredient → functional components, flavour
  ///   profiles, culinary pairings, Phase 4 orphan CSVs) and recipe
  ///   persistence columns (nutrition + source, quantity text, cooking
  ///   method, typed steps).
  /// - v5 (2026-09-26, refonte UX): `ingredient_allergens` enrichment
  ///   (declared, inferred and corrected EU annex II allergens).
  /// - v6 (2026-09-28, Phase 11) : squelettes de plats et gabarits de
  ///   procédé (recette à l'envers) ; demande de conception conservée
  ///   avec la recette (`recipes.design_brief_json`).
  @override
  int get schemaVersion => 6;

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
      if (from < 4) {
        await m.createTable(ingredientCulinary);
        await m.createTable(processFactors);
        await m.createTable(ingredientFunctionalComponents);
        await m.createTable(functionalComponents);
        await m.createTable(experimentalValidationCases);
        await m.createTable(ingredientFlavorProfiles);
        await m.createTable(culinaryPairings);
        await m.addColumn(recipes, recipes.nutritionMode);
        await m.addColumn(recipes, recipes.nutritionJson);
        await m.addColumn(recipeItems, recipeItems.quantityText);
        await m.addColumn(recipeItems, recipeItems.cookingMethod);
        await m.addColumn(recipeSteps, recipeSteps.opId);
        await m.addColumn(recipeSteps, recipeSteps.temperatureC);
        await m.addColumn(recipeSteps, recipeSteps.durationMin);
      }
      if (from < 5) {
        await m.createTable(ingredientAllergens);
      }
      if (from < 6) {
        await m.createTable(dishSkeletonRoles);
        await m.createTable(dishProcesses);
        await m.addColumn(recipes, recipes.designBriefJson);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
