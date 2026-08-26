import 'package:drift/drift.dart' show OrderingTerm, Value, innerJoin;

import '../../../core/database/app_database.dart' hide Recipe;
import '../domain/recipe.dart';

/// Stable id generator — uses timestamp + a short random suffix so that
/// [save] can produce deterministic-looking ids without pulling a uuid
/// dependency. The values only need to be unique within the device DB,
/// not globally.
class _IdGen {
  static int _seq = 0;

  static String next(String prefix) {
    _seq = (_seq + 1) & 0xFFFFFF;
    return '$prefix-${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}-${_seq.toRadixString(36)}';
  }
}

/// CRUD repository bridging the domain `Recipe` model and the Drift
/// `AppDatabase` schema.
///
/// Round-trip rules (Lot D, integration with the UI/UX pass):
/// - `Recipe.images` ↔ `recipe_images` rows (1-N ordered by `position`).
/// - `Recipe.steps` ↔ `recipe_steps` rows (ordered by `position`).
/// - `Recipe.tags` ↔ `tags` + `recipe_tags` join rows.
/// - `Recipe.ingredients` ↔ `recipe_items` rows (ordered by `position`).
/// - Cascade delete: removing a recipe drops its steps, items, tags and
///   photos automatically (PRAGMA foreign_keys = ON, set in AppDatabase).
///
/// The repository intentionally **does not** compute nutrition or score
/// ingredients against the metier databases — those lookups live in
/// [IngredientsRepository] and [NutritionRepository] (also Lot D) so
/// the recipe detail view can resolve them lazily.
class RecipesRepository {
  RecipesRepository(this.db);

  final AppDatabase db;

  /// Insert or replace a recipe along with all its children.
  Future<void> save(Recipe recipe) async {
    await db.transaction(() async {
      await _upsertRecipeHeader(recipe);
      await _replaceChildren(recipe);
    });
  }

  Future<void> delete(String id) async {
    await (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Recipe>> listAll() async {
    final rows = await db.select(db.recipes).get();
    final result = <Recipe>[];
    for (final row in rows) {
      result.add(await _hydrate(row.id));
    }
    return result;
  }

  Future<Recipe?> getById(String id) async {
    final exists =
        await (db.select(db.recipes)
              ..where((t) => t.id.equals(id))
              ..limit(1))
            .getSingleOrNull();
    if (exists == null) {
      return null;
    }
    return _hydrate(id);
  }

  // ---------- internals ----------

  Future<void> _upsertRecipeHeader(Recipe recipe) async {
    await db
        .into(db.recipes)
        .insertOnConflictUpdate(
          RecipesCompanion.insert(
            id: recipe.id,
            title: recipe.title,
            description: Value(recipe.description),
            servings: Value(recipe.servings),
            prepTimeMin: Value(recipe.prepMinutes),
            cookTimeMin: Value(recipe.cookMinutes),
            createdAt: '1970-01-01T00:00:00Z',
            updatedAt: '1970-01-01T00:00:00Z',
            deletedAt: Value(null),
          ),
        );
  }

  Future<void> _replaceChildren(Recipe recipe) async {
    await (db.delete(
      db.recipeItems,
    )..where((t) => t.recipeId.equals(recipe.id))).go();
    await (db.delete(
      db.recipeSteps,
    )..where((t) => t.recipeId.equals(recipe.id))).go();
    await (db.delete(
      db.recipeImages,
    )..where((t) => t.recipeId.equals(recipe.id))).go();
    await (db.delete(
      db.recipeTags,
    )..where((t) => t.recipeId.equals(recipe.id))).go();

    for (var i = 0; i < recipe.steps.length; i++) {
      await db
          .into(db.recipeSteps)
          .insert(
            RecipeStepsCompanion.insert(
              id: _IdGen.next('step'),
              recipeId: recipe.id,
              position: i,
              body: recipe.steps[i],
            ),
          );
    }

    for (var i = 0; i < recipe.ingredients.length; i++) {
      final ing = recipe.ingredients[i];
      await db
          .into(db.recipeItems)
          .insert(
            RecipeItemsCompanion.insert(
              id: _IdGen.next('ri'),
              recipeId: recipe.id,
              position: i,
              kind: ing.source.name,
              label: ing.label,
              quantityG: 0.0,
              ingredientId: Value(ing.ingredientId),
            ),
          );
    }

    for (var i = 0; i < recipe.images.length; i++) {
      final img = recipe.images[i];
      await db
          .into(db.recipeImages)
          .insert(
            RecipeImagesCompanion.insert(
              id: _IdGen.next('img'),
              recipeId: recipe.id,
              position: i,
              path: img.path,
              label: Value(img.label),
            ),
          );
    }

    // Tags: the join row references `tags.id`, so we upsert each tag
    // using its label as the natural key (label is UNIQUE in the schema).
    // If the label already exists in `tags`, we look up its id; otherwise
    // we insert a new tag row.
    for (final label in recipe.tags) {
      final existing =
          await (db.select(db.tags)
                ..where((t) => t.label.equals(label))
                ..limit(1))
              .getSingleOrNull();
      final tagId = existing?.id ?? _IdGen.next('tag');
      if (existing == null) {
        await db
            .into(db.tags)
            .insert(TagsCompanion.insert(id: tagId, label: label));
      }
      await db
          .into(db.recipeTags)
          .insertOnConflictUpdate(
            RecipeTagsCompanion.insert(recipeId: recipe.id, tagId: tagId),
          );
    }
  }

  Future<Recipe> _hydrate(String recipeId) async {
    final header = await (db.select(
      db.recipes,
    )..where((t) => t.id.equals(recipeId))).getSingle();

    final stepsRows =
        await (db.select(db.recipeSteps)
              ..where((t) => t.recipeId.equals(recipeId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final itemsRows =
        await (db.select(db.recipeItems)
              ..where((t) => t.recipeId.equals(recipeId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final imagesRows =
        await (db.select(db.recipeImages)
              ..where((t) => t.recipeId.equals(recipeId))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final tagRows = await (db.select(db.recipeTags).join([
      innerJoin(db.tags, db.tags.id.equalsExp(db.recipeTags.tagId)),
    ])..where(db.recipeTags.recipeId.equals(recipeId))).get();

    final ingredients = itemsRows
        .map(
          (row) => RecipeIngredient(
            label: row.label,
            quantity: '${row.quantityG.toStringAsFixed(0)} g',
            source: _parseSource(row.kind),
            ingredientId: row.ingredientId,
          ),
        )
        .toList();
    final images = imagesRows
        .map((row) => RecipeImage(path: row.path, label: row.label ?? ''))
        .toList();
    final steps = stepsRows.map((row) => row.body).toList();
    final tags = tagRows.map((row) => row.readTable(db.tags).label).toList();

    return Recipe(
      id: header.id,
      title: header.title,
      description: header.description,
      tags: tags,
      servings: header.servings,
      prepMinutes: header.prepTimeMin,
      cookMinutes: header.cookTimeMin,
      ingredients: ingredients,
      steps: steps,
      nutrition: const NutritionSummary(
        energyKcal: 0,
        proteins: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        salt: 0,
      ),
      images: images,
    );
  }

  IngredientSource _parseSource(String raw) {
    switch (raw) {
      case 'ciqual':
        return IngredientSource.ciqual;
      case 'recipe':
        return IngredientSource.recipe;
      default:
        return IngredientSource.free;
    }
  }
}
