// Lot D test — RecipesRepository round-trip + cascade + lookup.
import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/recipes/data/recipes_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:flutter_test/flutter_test.dart';

Recipe _sample({String id = 'r1'}) {
  return Recipe(
    id: id,
    title: 'Pesto test',
    description: 'desc',
    tags: const ['sauce', 'rapide'],
    servings: 4,
    prepMinutes: 10,
    cookMinutes: 0,
    ingredients: const [
      RecipeIngredient(
        label: 'Basilic',
        quantity: '60 g',
        source: IngredientSource.ciqual,
        ingredientId: 'ING-PLANT-BASILIC-000001',
      ),
      RecipeIngredient(
        label: 'Huile',
        quantity: '90 g',
        source: IngredientSource.free,
      ),
    ],
    steps: const ['Étape 1', 'Étape 2'],
    nutrition: const NutritionSummary(
      energyKcal: 197,
      proteins: 4.7,
      carbs: 1.9,
      fats: 19.1,
      fiber: 1.0,
      salt: 0.14,
    ),
    images: const [
      RecipeImage(path: '/tmp/a.jpg', label: 'hero'),
      RecipeImage(path: '/tmp/b.jpg', label: ''),
    ],
  );
}

void main() {
  group('RecipesRepository', () {
    late AppDatabase db;
    late RecipesRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = RecipesRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('save + getById round-trips all child collections', () async {
      // Setup: insert the Phase 1 ingredient referenced by the recipe
      // (FK target). In production, the loader creates these rows; for
      // the test we mirror that setup.
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-BASILIC-000001',
              canonicalNameFr: 'Basilic',
              categoryLevel1: 'vegetal',
            ),
          );

      await repo.save(_sample());

      final got = await repo.getById('r1');
      expect(got, isNotNull);
      expect(got!.title, 'Pesto test');
      expect(got.tags, containsAll(['sauce', 'rapide']));
      expect(got.steps, ['Étape 1', 'Étape 2']);
      expect(got.ingredients, hasLength(2));
      expect(got.ingredients.first.ingredientId, 'ING-PLANT-BASILIC-000001');
      expect(got.ingredients.first.source, IngredientSource.ciqual);
      expect(got.ingredients.last.source, IngredientSource.free);
      expect(got.images, hasLength(2));
      expect(got.images.first.path, '/tmp/a.jpg');
      expect(got.images.first.label, 'hero');
      expect(got.images.last.label, '');
    });

    test('save twice replaces children (not duplicates)', () async {
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-BASILIC-000001',
              canonicalNameFr: 'Basilic',
              categoryLevel1: 'vegetal',
            ),
          );

      await repo.save(_sample());
      await repo.save(
        Recipe(
          id: 'r1',
          title: 'Pesto v2',
          description: '',
          tags: const [],
          servings: 1,
          prepMinutes: 0,
          cookMinutes: 0,
          ingredients: const [],
          steps: const ['Seule étape'],
          nutrition: const NutritionSummary(
            energyKcal: 0,
            proteins: 0,
            carbs: 0,
            fats: 0,
            fiber: 0,
            salt: 0,
          ),
          images: const [],
        ),
      );

      final got = await repo.getById('r1');
      expect(got!.title, 'Pesto v2');
      expect(got.steps, ['Seule étape']);
      expect(got.ingredients, isEmpty);
      expect(got.images, isEmpty);
      expect(got.tags, isEmpty);
    });

    test('delete cascades to children', () async {
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-BASILIC-000001',
              canonicalNameFr: 'Basilic',
              categoryLevel1: 'vegetal',
            ),
          );
      await repo.save(_sample());
      await repo.delete('r1');

      final images = await db.select(db.recipeImages).get();
      final items = await db.select(db.recipeItems).get();
      final steps = await db.select(db.recipeSteps).get();
      final joinRows = await db.select(db.recipeTags).get();
      expect(images, isEmpty);
      expect(items, isEmpty);
      expect(steps, isEmpty);
      expect(joinRows, isEmpty);
    });

    test('tag lookup is shared across recipes (label UNIQUE)', () async {
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-BASILIC-000001',
              canonicalNameFr: 'Basilic',
              categoryLevel1: 'vegetal',
            ),
          );
      await repo.save(_sample(id: 'r1'));
      await repo.save(_sample(id: 'r2'));

      final allTags = await db.select(db.tags).get();
      // 'sauce' and 'rapide' appear only once across the two recipes.
      expect(allTags.where((t) => t.label == 'sauce'), hasLength(1));
      expect(allTags.where((t) => t.label == 'rapide'), hasLength(1));
    });

    test('listAll returns every saved recipe', () async {
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-BASILIC-000001',
              canonicalNameFr: 'Basilic',
              categoryLevel1: 'vegetal',
            ),
          );
      await repo.save(_sample(id: 'r1'));
      await repo.save(_sample(id: 'r2'));
      await repo.save(_sample(id: 'r3'));

      final all = await repo.listAll();
      expect(all.map((r) => r.id), containsAll(['r1', 'r2', 'r3']));
    });

    test('getById returns null for unknown id', () async {
      expect(await repo.getById('does-not-exist'), isNull);
    });
  });
}
