// Phase 09 Lot G — G3 : tests du FlavorScorer pur (§7.1, dp-106).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/scoring/flavor_scorer.dart';

FlavorMatch pair(String a, String b, double score) => FlavorMatch(
  ingredientAId: a,
  ingredientBId: b,
  combinationSize: 2,
  overallScore: score,
  aromaSimilarity: score,
  culinarySupport: score,
);

/// Lookup en mémoire : clé = ids triés jointes par '|'.
FlavorLookup lookupOf(Map<String, FlavorMatch> data) =>
    (ids) => data[(List<String>.of(ids)..sort()).join('|')];

void main() {
  group('FlavorScorer.scoreCombination', () {
    test('returns null with fewer than 2 ingredients', () {
      expect(FlavorScorer.scoreCombination(const [], lookupOf({})), isNull);
      expect(
        FlavorScorer.scoreCombination(const ['ING-A'], lookupOf({})),
        isNull,
      );
    });

    test('returns the direct n-ary record when found', () {
      const tomate = 'ING-PLANT-TOMATE-000001';
      const basilic = 'ING-PLANT-BASILIC-000001';
      const mozzarella = 'ING-DAIRY-MOZZARELLA-000001';
      final direct = FlavorMatch(
        ingredientAId: tomate,
        combinationSize: 3,
        overallScore: 0.91,
        explanation: 'Combinaison validée en base',
      );
      // Clé = ids triés (contrat du lookup, cf. FlavorRepository._keyFor).
      final lookup = lookupOf({'$mozzarella|$basilic|$tomate': direct});
      final result = FlavorScorer.scoreCombination(const [
        tomate,
        basilic,
        mozzarella,
      ], lookup);
      expect(result, same(direct));
    });

    test('falls back to pair average when no n-ary record exists', () {
      final lookup = lookupOf({
        'ING-A|ING-B': pair('ING-A', 'ING-B', 0.80),
        'ING-A|ING-C': pair('ING-A', 'ING-C', 0.60),
        'ING-B|ING-C': pair('ING-B', 'ING-C', 0.40),
      });
      final result = FlavorScorer.scoreCombination(const [
        'ING-A',
        'ING-B',
        'ING-C',
      ], lookup);
      expect(result, isNotNull);
      expect(result!.overallScore, closeTo(0.60, 1e-9));
      expect(result.combinationSize, 3);
      expect(result.ingredientBId, isNull);
      expect(result.category, FlavorMatchCategory.average);
    });

    test('partial pairs: averages only the pairs found', () {
      final lookup = lookupOf({'ING-A|ING-B': pair('ING-A', 'ING-B', 0.90)});
      final result = FlavorScorer.scoreCombination(const [
        'ING-A',
        'ING-B',
        'ING-C',
      ], lookup);
      expect(result, isNotNull);
      expect(result!.overallScore, closeTo(0.90, 1e-9));
    });

    test('returns null when no data at all (exotic combination)', () {
      expect(
        FlavorScorer.scoreCombination(const ['ING-X', 'ING-Y'], lookupOf({})),
        isNull,
      );
    });

    test('reference scores §19: Tomate+Basilic+Mozzarella ≈ 0.84 → good', () {
      const tomate = 'ING-PLANT-TOMATE-000001';
      const basilic = 'ING-PLANT-BASILIC-000001';
      const mozzarella = 'ING-DAIRY-MOZZARELLA-000001';
      final lookup = lookupOf({
        // Clés = ids triés (contrat du lookup, cf. FlavorRepository._keyFor).
        '$basilic|$tomate': pair(tomate, basilic, 0.87),
        '$mozzarella|$tomate': pair(tomate, mozzarella, 0.85),
        '$mozzarella|$basilic': pair(basilic, mozzarella, 0.80),
      });
      final result = FlavorScorer.scoreCombination(const [
        tomate,
        basilic,
        mozzarella,
      ], lookup);
      expect(result, isNotNull);
      expect(result!.overallScore, closeTo(0.84, 1e-9));
      expect(result.category, FlavorMatchCategory.good);
    });

    test('synthetic match merges evidence refs without duplicates', () {
      final a = pair(
        'ING-A',
        'ING-B',
        0.8,
      ).copyWith(evidenceRefs: const ['REF-1', 'REF-2']);
      final b = pair(
        'ING-A',
        'ING-C',
        0.7,
      ).copyWith(evidenceRefs: const ['REF-2', 'REF-3']);
      final lookup = lookupOf({'ING-A|ING-B': a, 'ING-A|ING-C': b});
      final result = FlavorScorer.scoreCombination(const [
        'ING-A',
        'ING-B',
        'ING-C',
      ], lookup);
      expect(result!.evidenceRefs, containsAll(['REF-1', 'REF-2', 'REF-3']));
      expect(result.evidenceRefs.length, 3);
    });

    test('nullable sub-scores stay null when no pair provides them', () {
      final lookup = lookupOf({
        'ING-A|ING-B': const FlavorMatch(
          ingredientAId: 'ING-A',
          ingredientBId: 'ING-B',
          combinationSize: 2,
          overallScore: 0.7,
        ),
      });
      final result = FlavorScorer.scoreCombination(const [
        'ING-A',
        'ING-B',
      ], lookup);
      expect(result, isNotNull);
      expect(result!.aromaSimilarity, isNull);
      expect(result.tasteBalance, isNull);
    });
  });
}
