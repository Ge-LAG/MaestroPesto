// Phase 09 Lot G — G3 : tests du FlavorRepository (§7.2).
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:test/test.dart';

void main() {
  group('FlavorRepository (in-memory Drift)', () {
    late AppDatabase db;
    late FlavorRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = FlavorRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> insertPair(
      String recordId,
      String a,
      String b,
      double score,
    ) =>
        db.into(db.flavorCompatibility).insert(
              FlavorCompatibilityCompanion.insert(
                recordId: recordId,
                combinationSize: const Value(2),
                ingredientIds: Value('$a|$b'),
                overallScore: Value(score),
                explanation: const Value('Accord test'),
              ),
            );

    test('bestMatchFor returns null on empty DB', () async {
      expect(await repo.bestMatchFor(const ['A', 'B']), isNull);
    });

    test('bestMatchFor finds a pair regardless of order', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.87);
      final m1 = await repo.bestMatchFor(const ['ING-A', 'ING-B']);
      final m2 = await repo.bestMatchFor(const ['ING-B', 'ING-A']);
      expect(m1, isNotNull);
      expect(m1!.overallScore, 0.87);
      expect(m2!.overallScore, 0.87);
      expect(m1.category, FlavorMatchCategory.excellent);
    });

    test('bestMatchFor falls back to pair average for n-ary', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.87);
      await insertPair('REC-2', 'ING-A', 'ING-C', 0.85);
      await insertPair('REC-3', 'ING-B', 'ING-C', 0.80);
      final m = await repo.bestMatchFor(const ['ING-A', 'ING-B', 'ING-C']);
      expect(m, isNotNull);
      expect(m!.overallScore, closeTo(0.84, 1e-9));
      expect(m.combinationSize, 3);
      expect(m.category, FlavorMatchCategory.good);
    });

    test('direct n-ary record wins over pair fallback', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.50);
      await db.into(db.flavorCompatibility).insert(
            FlavorCompatibilityCompanion.insert(
              recordId: 'REC-N',
              combinationSize: const Value(3),
              ingredientIds: const Value('ING-A|ING-B|ING-C'),
              overallScore: const Value(0.95),
            ),
          );
      final m = await repo.bestMatchFor(const ['ING-C', 'ING-A', 'ING-B']);
      expect(m!.overallScore, 0.95);
    });

    test('incompatiblePairs returns only pairs below 0.40', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.32);
      await insertPair('REC-2', 'ING-A', 'ING-C', 0.71);
      await insertPair('REC-3', 'ING-B', 'ING-C', 0.58);
      final bad = await repo.incompatiblePairs(const ['ING-A', 'ING-B', 'ING-C']);
      expect(bad.length, 1);
      expect(bad.single.overallScore, 0.32);
      expect(bad.single.category, FlavorMatchCategory.avoid);
    });

    test('invalidateCache forces a reload', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.80);
      expect(await repo.bestMatchFor(const ['A', 'B']), isNull);
      repo.invalidateCache();
      final m = await repo.bestMatchFor(const ['ING-A', 'ING-B']);
      expect(m, isNotNull);
    });
  });

  group('FlavorRepository.fromMatches (no Drift)', () {
    test('serves lookups from injected matches', () async {
      final repo = FlavorRepository.fromMatches(const [
        FlavorMatch(
          ingredientAId: 'ING-A',
          ingredientBId: 'ING-B',
          combinationSize: 2,
          overallScore: 0.87,
        ),
      ]);
      final m = await repo.bestMatchFor(const ['ING-B', 'ING-A']);
      expect(m, isNotNull);
      expect(m!.overallScore, 0.87);
      expect(await repo.bestMatchFor(const ['ING-A', 'ING-X']), isNull);
    });

    test('incompatiblePairs works on injected matches', () async {
      final repo = FlavorRepository.fromMatches(const [
        FlavorMatch(
          ingredientAId: 'ING-A',
          ingredientBId: 'ING-B',
          combinationSize: 2,
          overallScore: 0.30,
        ),
        FlavorMatch(
          ingredientAId: 'ING-A',
          ingredientBId: 'ING-C',
          combinationSize: 2,
          overallScore: 0.90,
        ),
      ]);
      final bad = await repo.incompatiblePairs(const ['ING-A', 'ING-B', 'ING-C']);
      expect(bad.length, 1);
      expect(bad.single.overallScore, 0.30);
    });
  });
}
