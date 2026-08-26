// Phase 09 Lot H — tests du modèle pur Recommendation (§5.6).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/core/models/recommendation.dart';

const suggested = IngredientSummary(
  ingredientId: 'ING-ANIMAL-POULET-000001',
  canonicalNameFr: 'Poulet',
  categoryLevel1: 'animal',
  confidence: 0.95,
);

Recommendation recommendation({
  String original = 'ING-ANIMAL-BOEUF-000001',
  double score = 0.81,
  ScoringSource source = ScoringSource.flavor,
}) =>
    Recommendation(
      originalIngredientId: original,
      suggestedIngredient: suggested,
      reason: 'Meilleure affinité aromatique',
      score: score,
      scoringSource: source,
    );

void main() {
  group('Recommendation', () {
    test('== and hashCode on identical values', () {
      expect(recommendation(), recommendation());
      expect(recommendation().hashCode, recommendation().hashCode);
    });

    test('== differs when score differs', () {
      expect(recommendation(score: 0.8), isNot(recommendation(score: 0.7)));
    });

    test('== differs when suggested ingredient differs', () {
      final a = recommendation();
      final b = recommendation().copyWith(
        suggestedIngredient: suggested.copyWith(canonicalNameFr: 'Agneau'),
      );
      expect(a, isNot(b));
    });

    test('== differs when scoringSource differs', () {
      expect(
        recommendation(source: ScoringSource.flavor),
        isNot(recommendation(source: ScoringSource.all)),
      );
    });

    test('copyWith preserves untouched fields', () {
      final a = recommendation();
      final b = a.copyWith(reason: 'Résout une incompatibilité existante');
      expect(b.reason, 'Résout une incompatibilité existante');
      expect(b.originalIngredientId, a.originalIngredientId);
      expect(b.suggestedIngredient, a.suggestedIngredient);
      expect(b.score, a.score);
      expect(b.scoringSource, a.scoringSource);
    });
  });
}
