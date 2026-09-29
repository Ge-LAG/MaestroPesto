// Phase 11 — migration v5 → v6 : une base existante gagne les squelettes
// de plats et la demande de conception des recettes, sans perdre ses
// recettes.
import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:path/path.dart' as p;

void main() {
  test('une base v5 migre en v6 en conservant les recettes', () async {
    final dir = await Directory.systemTemp.createTemp('migration_v6');
    final file = File(p.join(dir.path, 'app.sqlite'));
    try {
      // 1. Base « v5 » : schéma courant ramené à l'état v5.
      var db = AppDatabase(NativeDatabase(file));
      await db
          .into(db.recipes)
          .insert(
            RecipesCompanion.insert(
              id: 'r1',
              title: 'Recette existante',
              createdAt: '2026-01-01',
              updatedAt: '2026-01-01',
              nutritionMode: const Value('computed'),
            ),
          );
      await db.customStatement('DROP TABLE dish_skeleton_roles');
      await db.customStatement('DROP TABLE dish_processes');
      await db.customStatement(
        'ALTER TABLE recipes DROP COLUMN design_brief_json',
      );
      await db.customStatement('PRAGMA user_version = 5');
      await db.close();

      // 2. Réouverture : la migration v6 s'exécute.
      db = AppDatabase(NativeDatabase(file));
      final recipe = await db.select(db.recipes).getSingle();
      expect(recipe.title, 'Recette existante');
      expect(recipe.nutritionMode, 'computed');
      expect(recipe.designBriefJson, isNull);
      await (db.update(db.recipes)..where((t) => t.id.equals('r1'))).write(
        const RecipesCompanion(designBriefJson: Value('{"version":1}')),
      );
      await db
          .into(db.dishProcesses)
          .insert(
            DishProcessesCompanion.insert(
              skeletonId: 'test',
              familyId: 'f',
              method: 'raw',
              servingMassG: 50,
              steps: 'Mélanger {*}.',
            ),
          );
      await db
          .into(db.dishSkeletonRoles)
          .insert(
            DishSkeletonRolesCompanion.insert(
              skeletonId: 'test',
              role: 'base',
              minCount: 1,
              maxCount: 1,
              minGPerServing: 1,
              maxGPerServing: 2,
              candidates: 'ING-A',
            ),
          );
      expect(
        (await db.select(db.recipes).getSingle()).designBriefJson,
        '{"version":1}',
      );
      expect(await db.select(db.dishProcesses).get(), hasLength(1));
      expect(await db.select(db.dishSkeletonRoles).get(), hasLength(1));
      await db.close();
    } finally {
      await dir.delete(recursive: true);
    }
  });
}
