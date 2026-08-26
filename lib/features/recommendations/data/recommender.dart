// Phase 09 Lot H — H3 : Recommender (plan §9.1).
//
// Orchestrateur de substitution : pour un ingrédient `target` d'une
// recette, propose des substituts de la même `category_level_1` qui :
// 1. n'introduisent pas de nouvelle incompatibilité flavour,
// 2. ne déclenchent pas de nouvelle alerte fonctionnelle,
// 3. ont une confiance Phase 1 ≥ 0.7.
// Renvoie max 5 recommandations triées par score décroissant.
//
// Formule de score v1 (déterministe, documentée — les chiffres de
// l'annexe §20 du plan sont illustratifs, la formule ci-dessous est la
// référence d'implémentation) :
//
//   remaining   = recette − target
//   pairScores  = scores flavour des paires (candidat, r) pour r ∈ remaining
//   base        = moyenne des pairScores (0.5 si aucune donnée)
//   bonus       = +0.15 si le target avait ≥ 1 paire incompatible et que
//                 le candidat n'en a aucune (« résout incompatibilité »)
//   malus       = −0.20 si le candidat déclenche une nouvelle alerte
//                 fonctionnelle (info/warning/danger) absente de la recette
//                 sans le target
//   score       = clamp(base + bonus + malus, 0, 1)
//
// Un candidat avec une paire < 0.40 dans remaining est écarté (il
// introduit une nouvelle incompatibilité — étape 1 de l'algo §9.1).

import '../../functional/data/functional_repository.dart';
import '../../../core/models/functional_alert.dart';
import '../../../core/models/ingredient_summary.dart';
import '../../../core/models/recommendation.dart';
import '../../flavor/data/flavor_repository.dart';

/// Seuil d'incompatibilité flavour (catégorie `avoid`, plan §5.4).
const double kIncompatibilityThreshold = 0.40;

/// Bonus « résout une incompatibilité existante » (§9.1 étape 4).
const double kResolveBonus = 0.15;

/// Malus « déclenche une nouvelle alerte fonctionnelle » (§9.1 étape 4).
const double kNewAlertMalus = 0.20;

/// Score neutre quand aucune paire flavour n'est connue.
const double kUnknownPairScore = 0.5;

/// Source de candidats Phase 1 — implémentée par
/// `IngredientsRepository`, fakée en tests (pas de Drift requis).
abstract interface class IngredientCandidatesSource {
  Future<IngredientSummary?> summaryFor(String ingredientId);
  Future<List<IngredientSummary>> candidatesForCategory(
    String categoryLevel1, {
    double minConfidence,
  });
}

/// Orchestrateur de recommandations de substituts (plan §9.1).
class Recommender {
  Recommender({
    required IngredientCandidatesSource ingredients,
    required FlavorRepository flavor,
    required FunctionalRepository functional,
  })  : _ingredients = ingredients,
        _flavor = flavor,
        _functional = functional;

  final IngredientCandidatesSource _ingredients;
  final FlavorRepository _flavor;
  final FunctionalRepository _functional;

  /// Propose jusqu'à [maxResults] substituts pour [targetIngredientId]
  /// dans la recette [currentIngredientIds], triés par score
  /// décroissant. Renvoie une liste vide si la cible est inconnue ou si
  /// aucun candidat ne convient.
  Future<List<Recommendation>> suggestSubstitutes({
    required String targetIngredientId,
    required List<String> currentIngredientIds,
    int maxResults = 5,
  }) async {
    // Étape 1 : catégorie de la cible.
    final target = await _ingredients.summaryFor(targetIngredientId);
    if (target == null) return const <Recommendation>[];

    final remaining = [
      for (final id in currentIngredientIds)
        if (id != targetIngredientId) id,
    ];

    // Étape 2 : incompatibilités et alertes de la recette SANS la cible,
    // et vérifier que la cible était bien en conflit.
    final targetConflicts = await _hasIncompatibility(
      targetIngredientId,
      remaining,
    );
    final alertIdsBefore = (await _functional.alertsFor(remaining))
        .map((a) => a.alertId)
        .toSet();

    // Étape 3 : candidats (même catégorie, confiance ≥ 0.7, pas déjà
    // dans la recette).
    final inRecipe = currentIngredientIds.toSet();
    final candidates = await _ingredients.candidatesForCategory(
      target.categoryLevel1,
      minConfidence: 0.7,
    );

    // Étape 4 : scoring.
    final recommendations = <Recommendation>[];
    for (final candidate in candidates) {
      if (inRecipe.contains(candidate.ingredientId)) continue;

      final pairScores = <double>[];
      var introducesIncompatibility = false;
      for (final other in remaining) {
        final match = await _flavor.bestMatchFor([candidate.ingredientId, other]);
        if (match == null) continue;
        if (match.overallScore < kIncompatibilityThreshold) {
          introducesIncompatibility = true;
          break;
        }
        pairScores.add(match.overallScore);
      }
      if (introducesIncompatibility) continue;

      final base = pairScores.isEmpty
          ? kUnknownPairScore
          : pairScores.reduce((a, b) => a + b) / pairScores.length;

      final bonus = targetConflicts ? kResolveBonus : 0.0;

      final alertsAfter = await _functional.alertsFor(
        [...remaining, candidate.ingredientId],
      );
      final hasNewAlert = alertsAfter.any((a) =>
          a.severity != FunctionalSeverity.outOfDomain &&
          !alertIdsBefore.contains(a.alertId));
      final malus = hasNewAlert ? kNewAlertMalus : 0.0;

      final score = (base + bonus - malus).clamp(0.0, 1.0);
      recommendations.add(
        Recommendation(
          originalIngredientId: targetIngredientId,
          suggestedIngredient: candidate,
          reason: targetConflicts
              ? 'Résout une incompatibilité existante'
              : 'Meilleure affinité aromatique',
          score: score,
          scoringSource: hasNewAlert || alertIdsBefore.isNotEmpty
              ? ScoringSource.all
              : ScoringSource.flavor,
        ),
      );
    }

    // Étape 5 : tri décroissant + top N.
    recommendations.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0
          ? byScore
          : a.suggestedIngredient.ingredientId
              .compareTo(b.suggestedIngredient.ingredientId);
    });
    return recommendations.take(maxResults).toList();
  }

  /// Vrai si [targetId] a au moins une paire incompatible
  /// (< [kIncompatibilityThreshold]) avec [others].
  Future<bool> _hasIncompatibility(
    String targetId,
    List<String> others,
  ) async {
    for (final other in others) {
      final match = await _flavor.bestMatchFor([targetId, other]);
      if (match != null && match.overallScore < kIncompatibilityThreshold) {
        return true;
      }
    }
    return false;
  }
}
