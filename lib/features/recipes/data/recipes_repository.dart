import 'dart:convert';

import 'package:drift/drift.dart'
    show OrderingTerm, OrderingMode, Value, Variable, innerJoin;

import '../../../core/database/app_database.dart' hide Recipe;
import '../../../core/scoring/process_step_parser.dart';
import '../../../core/scoring/quantity_converter.dart';
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
/// Round-trip rules (Lot D, étendues en Phase 10 — ac-125) :
/// - `Recipe.images` ↔ `recipe_images` rows (1-N ordered by `position`).
/// - `Recipe.steps` ↔ `recipe_steps` rows (ordered by `position`), avec
///   l'opération, la température et la durée analysées du texte.
/// - `Recipe.tags` ↔ `tags` + `recipe_tags` join rows.
/// - `Recipe.ingredients` ↔ `recipe_items` rows : la quantité saisie est
///   conservée telle quelle (`quantity_text`, « 2 c. à soupe ») et
///   convertie en grammes (`quantity_g`) ; le mode de cuisson de la
///   ligne est persisté.
/// - `Recipe.nutrition` ↔ `recipes.nutrition_json` avec son origine
///   (`nutrition_mode` : calculée ou manuelle).
/// - Cascade delete: removing a recipe drops its steps, items, tags and
///   photos automatically (PRAGMA foreign_keys = ON, set in AppDatabase).
class RecipesRepository {
  RecipesRepository(this.db);

  final AppDatabase db;

  /// Marqueur de semis des recettes de démonstration (table
  /// `import_state`, partagée avec l'import CSV).
  static const String demoSeedMarker = 'app/demo_recipes_seed';

  /// Insert or replace a recipe along with all its children.
  /// [touch] = false conserve la date de modification (recalcul
  /// automatique de la nutrition stockée : l'ordre du classeur ne
  /// bouge pas).
  Future<void> save(Recipe recipe, {bool touch = true}) async {
    await db.transaction(() async {
      await _upsertRecipeHeader(recipe, touch: touch);
      await _replaceChildren(recipe);
    });
  }

  Future<void> delete(String id) async {
    await (db.delete(db.recipes)..where((t) => t.id.equals(id))).go();
  }

  /// Recettes, les plus récemment modifiées d'abord.
  Future<List<Recipe>> listAll() async {
    final rows =
        await (db.select(db.recipes)..orderBy([
              (t) => OrderingTerm(
                expression: t.updatedAt,
                mode: OrderingMode.desc,
              ),
            ]))
            .get();
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

  /// Sème [demos] une seule fois par installation (un classeur vidé par
  /// l'utilisateur n'est pas re-semé). Renvoie vrai si le semis a eu
  /// lieu.
  Future<bool> seedDemoRecipesOnce(List<Recipe> demos) async {
    await db.customStatement(
      'CREATE TABLE IF NOT EXISTS import_state ('
      'source_name TEXT PRIMARY KEY, hash TEXT NOT NULL, '
      'imported_at TEXT NOT NULL)',
    );
    final seeded = await db
        .customSelect(
          'SELECT 1 FROM import_state WHERE source_name = ?',
          variables: [Variable.withString(demoSeedMarker)],
        )
        .get();
    if (seeded.isNotEmpty) return false;
    final existing = await db.select(db.recipes).get();
    if (existing.isEmpty) {
      // Ordre d'affichage : la première démo est la plus récente.
      for (final r in demos.reversed) {
        await save(r);
      }
    }
    await db.customStatement(
      'INSERT OR REPLACE INTO import_state (source_name, hash, imported_at) '
      'VALUES (?, ?, ?)',
      [demoSeedMarker, 'v1', DateTime.now().toUtc().toIso8601String()],
    );
    return existing.isEmpty;
  }

  // ---------- internals ----------

  Future<void> _upsertRecipeHeader(Recipe recipe, {required bool touch}) async {
    final now = DateTime.now().toUtc().toIso8601String();
    final existing =
        await (db.select(db.recipes)
              ..where((t) => t.id.equals(recipe.id))
              ..limit(1))
            .getSingleOrNull();
    final n = recipe.nutrition;
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
            createdAt: existing?.createdAt ?? now,
            updatedAt: touch ? now : existing?.updatedAt ?? now,
            deletedAt: const Value(null),
            nutritionMode: Value(recipe.nutritionMode.name),
            nutritionJson: Value(
              jsonEncode({
                'energyKcal': n.energyKcal,
                'proteins': n.proteins,
                'carbs': n.carbs,
                'fats': n.fats,
                'fiber': n.fiber,
                'salt': n.salt,
              }),
            ),
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

    final parsed = ProcessStepParser.parseAll(
      recipe.steps,
      ingredientLabels: [for (final i in recipe.ingredients) i.label],
    );
    for (var i = 0; i < recipe.steps.length; i++) {
      final step = parsed[i];
      await db
          .into(db.recipeSteps)
          .insert(
            RecipeStepsCompanion.insert(
              id: _IdGen.next('step'),
              recipeId: recipe.id,
              position: i,
              body: recipe.steps[i],
              opId: Value(step.primary?.opId),
              temperatureC: Value(step.temperatureC),
              durationMin: Value(step.durationMin),
            ),
          );
    }

    // Un identifiant absent du référentiel (base non importée, recette
    // importée d'ailleurs) ne doit pas faire échouer l'enregistrement :
    // la ligne est conservée sans lien (clé étrangère respectée).
    final wanted = {
      for (final i in recipe.ingredients)
        if (i.ingredientId != null && i.ingredientId!.isNotEmpty)
          i.ingredientId!,
    };
    final known = wanted.isEmpty
        ? const <String>{}
        : (await (db.select(
                db.ingredients,
              )..where((t) => t.ingredientId.isIn(wanted))).get())
              .map((r) => r.ingredientId)
              .toSet();
    for (var i = 0; i < recipe.ingredients.length; i++) {
      final ing = recipe.ingredients[i];
      final linkedId = known.contains(ing.ingredientId)
          ? ing.ingredientId
          : null;
      await db
          .into(db.recipeItems)
          .insert(
            RecipeItemsCompanion.insert(
              id: _IdGen.next('ri'),
              recipeId: recipe.id,
              position: i,
              kind: ing.source.name,
              label: ing.label,
              // ac-125 : la conversion n'est plus perdue (« 60 g » était
              // relu « 0 g ») ; le texte saisi reste la référence.
              quantityG: QuantityConverter.toGrams(ing.quantity) ?? 0.0,
              quantityText: Value(ing.quantity),
              cookingMethod: Value(ing.cookingMethod),
              ingredientId: Value(linkedId),
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
            quantity: row.quantityText ?? '${_trimNumber(row.quantityG)} g',
            source: _parseSource(row.kind),
            ingredientId: row.ingredientId,
            cookingMethod: row.cookingMethod,
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
      nutrition: _parseNutrition(header.nutritionJson),
      nutritionMode: header.nutritionMode == RecipeNutritionMode.manual.name
          ? RecipeNutritionMode.manual
          : RecipeNutritionMode.computed,
      images: images,
    );
  }

  static String _trimNumber(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  static NutritionSummary _parseNutrition(String? json) {
    const zero = NutritionSummary(
      energyKcal: 0,
      proteins: 0,
      carbs: 0,
      fats: 0,
      fiber: 0,
      salt: 0,
    );
    if (json == null || json.isEmpty) return zero;
    try {
      final m = jsonDecode(json) as Map<String, dynamic>;
      double v(String k) => (m[k] as num?)?.toDouble() ?? 0;
      return NutritionSummary(
        energyKcal: v('energyKcal'),
        proteins: v('proteins'),
        carbs: v('carbs'),
        fats: v('fats'),
        fiber: v('fiber'),
        salt: v('salt'),
      );
    } on FormatException {
      return zero;
    }
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
