// Lot D test — IngredientsRepository lookups.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:test/test.dart';

void main() {
  group('IngredientsRepository', () {
    late AppDatabase db;
    late IngredientsRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = IngredientsRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('getById returns null when not found', () async {
      expect(await repo.getById('DOES-NOT-EXIST'), isNull);
    });

    test('getById returns the row when present', () async {
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'ING-PLANT-TOMATE-000001',
          canonicalNameFr: 'Tomate',
          categoryLevel1: 'vegetal',
          aliasesFr: const Value('tomate|tomate rouge'),
        ),
      );
      final got = await repo.getById('ING-PLANT-TOMATE-000001');
      expect(got, isNotNull);
      expect(got!.canonicalNameFr, 'Tomate');
      expect(got.aliasesFr, 'tomate|tomate rouge');
    });

    test('searchByName matches partial French name (case-insensitive)', () async {
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'A',
          canonicalNameFr: 'Tomate',
          categoryLevel1: 'vegetal',
        ),
      );
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'B',
          canonicalNameFr: 'Pomme',
          categoryLevel1: 'vegetal',
        ),
      );
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'C',
          canonicalNameFr: 'Basilic',
          categoryLevel1: 'vegetal',
        ),
      );

      final results = await repo.searchByName('tom');
      expect(results, hasLength(1));
      expect(results.first.ingredientId, 'A');

      final empty = await repo.searchByName('');
      expect(empty, isEmpty);

      final noMatch = await repo.searchByName('xyz');
      expect(noMatch, isEmpty);
    });

    test('count reflects the number of Phase 1 rows', () async {
      expect(await repo.count(), 0);
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'A',
          canonicalNameFr: 'A',
          categoryLevel1: 'v',
        ),
      );
      await db.into(db.ingredients).insert(
        IngredientsCompanion.insert(
          ingredientId: 'B',
          canonicalNameFr: 'B',
          categoryLevel1: 'v',
        ),
      );
      expect(await repo.count(), 2);
    });
  });
}