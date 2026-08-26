// Phase 09 Lot G — tests du modèle pur FlavorMatch (§5.4).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/flavor_match.dart';

FlavorMatch match({double score = 0.9}) => FlavorMatch(
      ingredientAId: 'ING-A',
      ingredientBId: 'ING-B',
      combinationSize: 2,
      overallScore: score,
      aromaSimilarity: 0.8,
      tasteBalance: 0.7,
      dominanceRisk: 0.1,
      maskingRisk: 0.1,
      culinarySupport: 0.9,
      evidenceRefs: const ['REF-1', 'REF-2'],
      explanation: 'Accord classique',
    );

void main() {
  group('FlavorMatch', () {
    test('== and hashCode on identical values', () {
      expect(match(), match());
      expect(match().hashCode, match().hashCode);
    });

    test('== differs when score differs', () {
      expect(match(score: 0.9), isNot(match(score: 0.8)));
    });

    test('== differs when evidenceRefs order differs', () {
      final a = match();
      final b = match().copyWith(evidenceRefs: const ['REF-2', 'REF-1']);
      expect(a, isNot(b));
    });

    test('copyWith can null out nullable fields', () {
      final m = match().copyWith(ingredientBId: null, explanation: null);
      expect(m.ingredientBId, isNull);
      expect(m.explanation, isNull);
      expect(m.combinationSize, 2);
    });

    group('category thresholds (cahier phase 3)', () {
      test('>= 0.85 → excellent', () {
        expect(match(score: 0.85).category, FlavorMatchCategory.excellent);
        expect(match(score: 1.0).category, FlavorMatchCategory.excellent);
      });

      test('0.70–0.84 → good', () {
        expect(match(score: 0.70).category, FlavorMatchCategory.good);
        expect(match(score: 0.84).category, FlavorMatchCategory.good);
        expect(match(score: 0.8499).category, FlavorMatchCategory.good);
      });

      test('0.55–0.69 → average', () {
        expect(match(score: 0.55).category, FlavorMatchCategory.average);
        expect(match(score: 0.69).category, FlavorMatchCategory.average);
      });

      test('0.40–0.54 → questionable', () {
        expect(match(score: 0.40).category, FlavorMatchCategory.questionable);
        expect(match(score: 0.54).category, FlavorMatchCategory.questionable);
      });

      test('< 0.40 → avoid', () {
        expect(match(score: 0.39).category, FlavorMatchCategory.avoid);
        expect(match(score: 0.0).category, FlavorMatchCategory.avoid);
      });
    });
  });
}
