// Phase 09 Lot G — G3 : tests du FlavorRepository (§7.2).
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:flutter_test/flutter_test.dart';

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
    ) => db
        .into(db.flavorCompatibility)
        .insert(
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
      await db
          .into(db.flavorCompatibility)
          .insert(
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
      final bad = await repo.incompatiblePairs(const [
        'ING-A',
        'ING-B',
        'ING-C',
      ]);
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

    // Cahier §7.2 : « le MEILLEUR FlavorMatch » — les données réelles
    // contiennent des doublons de clé (contextes prédits/observés), le
    // résultat ne doit pas dépendre de l'ordre d'insertion.
    test(
      'duplicate keys: best score wins regardless of insert order',
      () async {
        await insertPair('REC-1', 'ING-A', 'ING-B', 0.08);
        await insertPair('REC-2', 'ING-A', 'ING-B', 0.92);
        expect(
          (await repo.bestMatchFor(const ['ING-A', 'ING-B']))!.overallScore,
          0.92,
        );

        final db2 = AppDatabase(NativeDatabase.memory());
        addTearDown(db2.close);
        final repo2 = FlavorRepository(db2);
        await db2
            .into(db2.flavorCompatibility)
            .insert(
              FlavorCompatibilityCompanion.insert(
                recordId: 'REC-1',
                combinationSize: const Value(2),
                ingredientIds: const Value('ING-A|ING-B'),
                overallScore: const Value(0.92),
              ),
            );
        await db2
            .into(db2.flavorCompatibility)
            .insert(
              FlavorCompatibilityCompanion.insert(
                recordId: 'REC-2',
                combinationSize: const Value(2),
                ingredientIds: const Value('ING-A|ING-B'),
                overallScore: const Value(0.08),
              ),
            );
        expect(
          (await repo2.bestMatchFor(const ['ING-B', 'ING-A']))!.overallScore,
          0.92,
        );
      },
    );

    // Retour PO n°3 (vraie heatmap) : paire directe, sinon la plus
    // petite combinaison N-aire connue contenant la paire.
    test('bestKnownMatchFor: paire directe', () async {
      await insertPair('REC-1', 'ING-A', 'ING-B', 0.87);
      final r = await repo.bestKnownMatchFor('ING-A', 'ING-B');
      expect(r, isNotNull);
      expect(r!.match.overallScore, 0.87);
      expect(r.size, 2);
    });

    test('bestKnownMatchFor: fallback sur la combinaison N-aire', () async {
      // Pas de paire directe A-B, mais une combinaison à 3 connue.
      await db
          .into(db.flavorCompatibility)
          .insert(
            FlavorCompatibilityCompanion.insert(
              recordId: 'REC-N3',
              combinationSize: const Value(3),
              ingredientIds: const Value('ING-A|ING-B|ING-C'),
              overallScore: const Value(0.75),
            ),
          );
      // Et une combinaison à 4, moins précise, qui doit perdre.
      await db
          .into(db.flavorCompatibility)
          .insert(
            FlavorCompatibilityCompanion.insert(
              recordId: 'REC-N4',
              combinationSize: const Value(4),
              ingredientIds: const Value('ING-A|ING-B|ING-C|ING-D'),
              overallScore: const Value(0.95),
            ),
          );
      final r = await repo.bestKnownMatchFor('ING-B', 'ING-A');
      expect(r, isNotNull);
      expect(r!.size, 3, reason: 'la plus petite combinaison gagne');
      expect(r.match.overallScore, 0.75);
    });

    test('bestKnownMatchFor: null sans aucune donnée', () async {
      expect(await repo.bestKnownMatchFor('ING-X', 'ING-Y'), isNull);
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
      final bad = await repo.incompatiblePairs(const [
        'ING-A',
        'ING-B',
        'ING-C',
      ]);
      expect(bad.length, 1);
      expect(bad.single.overallScore, 0.30);
    });
  });
}
