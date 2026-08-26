// Lot D test — sanity check the new schema (recipe_images + ingredient_id on recipe_items).
import 'package:drift/drift.dart' show OrderingTerm, Value;
import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppDatabase schema v3', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
    });

    tearDown(() async {
      await db.close();
    });

    test('schemaVersion is 3', () {
      expect(db.schemaVersion, 3);
    });

    test('recipe_images table exists and supports CRUD + cascade', () async {
      // Insert a parent recipe
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'r1',
              title: 'Test',
              description: const Value(''),
              createdAt: '2026-08-25',
              updatedAt: '2026-08-25',
            ),
          );

      // Insert 2 photos
      await db
          .into(db.recipeImages)
          .insert(
            RecipeImagesCompanion.insert(
              id: 'img1',
              recipeId: 'r1',
              position: 0,
              path: '/tmp/a.jpg',
              label: const Value('Hero'),
            ),
          );
      await db
          .into(db.recipeImages)
          .insert(
            RecipeImagesCompanion.insert(
              id: 'img2',
              recipeId: 'r1',
              position: 1,
              path: '/tmp/b.jpg',
              label: const Value(null),
            ),
          );

      final photos =
          await (db.select(db.recipeImages)
                ..where((t) => t.recipeId.equals('r1'))
                ..orderBy([(t) => OrderingTerm.asc(t.position)]))
              .get();

      expect(photos, hasLength(2));
      expect(photos.first.path, '/tmp/a.jpg');
      expect(photos.first.label, 'Hero');
      expect(photos.last.label, isNull);

      // Cascade delete
      await (db.delete(db.recipes)..where((t) => t.id.equals('r1'))).go();
      final stillThere = await (db.select(
        db.recipeImages,
      )..where((t) => t.recipeId.equals('r1'))).get();
      expect(stillThere, isEmpty);
    });

    test('recipe_items supports ingredient_id FK (nullable)', () async {
      // Setup: recipe + ingredient (Phase 1) + item linking to it
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'r1',
              title: 'Test',
              createdAt: '2026-08-25',
              updatedAt: '2026-08-25',
            ),
          );
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: 'ING-PLANT-TOMATE-000001',
              canonicalNameFr: 'Tomate',
              categoryLevel1: 'vegetal',
            ),
          );

      await db
          .into(db.recipeItems)
          .insert(
            RecipeItemsCompanion.insert(
              id: 'ri1',
              recipeId: 'r1',
              position: 0,
              kind: 'ciqual',
              label: 'Tomate',
              quantityG: 200.0,
              ingredientId: const Value('ING-PLANT-TOMATE-000001'),
            ),
          );

      final item = await (db.select(
        db.recipeItems,
      )..where((t) => t.id.equals('ri1'))).getSingle();
      expect(item.ingredientId, 'ING-PLANT-TOMATE-000001');
    });

    test('ingredient_id is optional (nullable), accepts null', () async {
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'r1',
              title: 'Test',
              createdAt: '2026-08-25',
              updatedAt: '2026-08-25',
            ),
          );

      // Item without ingredientId (free entry)
      await db
          .into(db.recipeItems)
          .insert(
            RecipeItemsCompanion.insert(
              id: 'ri1',
              recipeId: 'r1',
              position: 0,
              kind: 'free',
              label: 'Sel',
              quantityG: 5.0,
            ),
          );

      final item = await (db.select(
        db.recipeItems,
      )..where((t) => t.id.equals('ri1'))).getSingle();
      expect(item.ingredientId, isNull);
    });
  });
}
