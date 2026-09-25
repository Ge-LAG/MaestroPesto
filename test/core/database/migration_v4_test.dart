// Phase 10 — migration v3 → v4 : une base existante gagne les tables
// d'enrichissement et les colonnes de persistance sans perdre ses
// recettes.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:path/path.dart' as p;

void main() {
  test('une base v3 migre en v4 en conservant les recettes', () async {
    final dir = await Directory.systemTemp.createTemp('migration_v4');
    final file = File(p.join(dir.path, 'app.sqlite'));
    try {
      // 1. Base « v3 » : schéma courant ramené à l'état v3.
      var db = AppDatabase(NativeDatabase(file));
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'r1',
              title: 'Recette existante',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
            ),
          );
      for (final table in [
        'ingredient_culinary',
        'process_factors',
        'ingredient_functional_components',
        'functional_components',
        'experimental_validation_cases',
        'ingredient_flavor_profiles',
        'culinary_pairings',
      ]) {
        await db.customStatement('DROP TABLE $table');
      }
      for (final (table, column) in [
        ('recipes', 'nutrition_mode'),
        ('recipes', 'nutrition_json'),
        ('recipe_items', 'quantity_text'),
        ('recipe_items', 'cooking_method'),
        ('recipe_steps', 'op_id'),
        ('recipe_steps', 'temperature_c'),
        ('recipe_steps', 'duration_min'),
      ]) {
        await db.customStatement('ALTER TABLE $table DROP COLUMN $column');
      }
      await db.customStatement('PRAGMA user_version = 3');
      await db.close();

      // 2. Réouverture : la migration v4 s'exécute.
      db = AppDatabase(NativeDatabase(file));
      final recipes = await db.select(db.recipes).get();
      expect(recipes.single.title, 'Recette existante');
      expect(recipes.single.nutritionMode, isNull);
      await db
          .into(db.culinaryPairings)
          .insert(
            CulinaryPairingsCompanion.insert(
              pairId: 'CP-1',
              ingredientAId: 'A',
              ingredientBId: 'B',
              kind: 'classic',
              strength: 0.9,
            ),
          );
      await (db.update(db.recipes)..where((t) => t.id.equals('r1'))).write(
        const RecipesCompanion(nutritionMode: Value('manual')),
      );
      expect((await db.select(db.recipes).getSingle()).nutritionMode, 'manual');
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
