// Phase 09 Lot H — modèle pur Recommendation (plan Phase 09 §5.6).
//
// Immutable, Drift-free, testable avec `package:test/test.dart`.
// Produit par le Recommender
// (lib/features/recommendations/data/recommender.dart) quand une recette
// contient une mauvaise combinaison (paire flavour < 0.40 ou alerte
// Phase 4 danger) : il propose des substituts de la même
// `category_level_1` avec une meilleure affinité.

import 'package:meta/meta.dart';

import 'ingredient_summary.dart';

/// Origine du score de recommandation (plan §5.6).
enum ScoringSource { flavor, nutrition, functional, all }

/// Proposition de substitution pour un ingrédient problématique.
@immutable
class Recommendation {
  const Recommendation({
    required this.originalIngredientId,
    required this.suggestedIngredient,
    required this.reason,
    required this.score,
    required this.scoringSource,
  });

  /// Identifiant Phase 1 de l'ingrédient problématique à remplacer.
  final String originalIngredientId;

  /// Ingrédient de substitution proposé (résumé Phase 1).
  final IngredientSummary suggestedIngredient;

  /// Raison lisible (ex. « Meilleure affinité aromatique »).
  final String reason;

  /// Score de la recommandation [0,1] (tri décroissant).
  final double score;

  /// Origine du scoring (v1 : toujours [ScoringSource.flavor]).
  final ScoringSource scoringSource;

  Recommendation copyWith({
    String? originalIngredientId,
    IngredientSummary? suggestedIngredient,
    String? reason,
    double? score,
    ScoringSource? scoringSource,
  }) {
    return Recommendation(
      originalIngredientId: originalIngredientId ?? this.originalIngredientId,
      suggestedIngredient: suggestedIngredient ?? this.suggestedIngredient,
      reason: reason ?? this.reason,
      score: score ?? this.score,
      scoringSource: scoringSource ?? this.scoringSource,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Recommendation) return false;
    return other.originalIngredientId == originalIngredientId &&
        other.suggestedIngredient == suggestedIngredient &&
        other.reason == reason &&
        other.score == score &&
        other.scoringSource == scoringSource;
  }

  @override
  int get hashCode => Object.hash(
    originalIngredientId,
    suggestedIngredient,
    reason,
    score,
    scoringSource,
  );

  @override
  String toString() =>
      'Recommendation($originalIngredientId → '
      '${suggestedIngredient.ingredientId}, score=$score, '
      '${scoringSource.name})';
}
