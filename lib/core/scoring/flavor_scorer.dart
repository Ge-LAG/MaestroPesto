// Phase 09 Lot G — G3 : FlavorScorer (agrégation pure, plan §7.1).
//
// dp-106 : on NE réimplémente PAS la formule w1..w8 de
// `flavor_scoring_method.md`. Le scorer lit directement l'`overallScore`
// des enregistrements Phase 3 et ne fait que de l'**agrégation** :
//
// 1. Combinaison n-aire exacte trouvée en base → renvoyée telle quelle.
// 2. Sinon, fallback : moyenne (v1 : moyenne arithmétique simple, cf.
//    annexe §19 du plan — Tomate+Basilic+Mozzarella ≈ 0.84) des
//    `overallScore` de toutes les paires 2×2 trouvées.
// 3. Aucune donnée → null (combinaison trop exotique).

import '../models/flavor_match.dart';

/// Lookup synchrone d'un [FlavorMatch] pour une combinaison donnée
/// (ordre indifférent). Résolution faite en amont (repository / cache).
typedef FlavorLookup = FlavorMatch? Function(List<String> ingredientIds);

/// Scorer aromatique pur (plan Phase 09 §7.1, dp-106).
abstract final class FlavorScorer {
  /// Score global d'une combinaison de N ingrédients.
  ///
  /// - < 2 ingrédients → null (rien à scorer).
  /// - enregistrement n-aire exact trouvé → renvoyé directement.
  /// - sinon, fallback paires : moyenne simple des `overallScore` des
  ///   paires trouvées ; sous-scores moyennés de la même façon.
  ///   Le [FlavorMatch] renvoyé est synthétique (`combinationSize = N`,
  ///   `ingredientBId == null`, explication null).
  /// - aucune paire trouvée → null.
  static FlavorMatch? scoreCombination(
    List<String> ingredientIds,
    FlavorLookup lookup,
  ) {
    if (ingredientIds.length < 2) return null;

    // 1. Combinaison n-aire directe.
    final direct = lookup(ingredientIds);
    if (direct != null) return direct;

    // 2. Fallback : toutes les paires 2×2.
    final pairs = <FlavorMatch>[];
    for (var i = 0; i < ingredientIds.length; i++) {
      for (var j = i + 1; j < ingredientIds.length; j++) {
        final match = lookup([ingredientIds[i], ingredientIds[j]]);
        if (match != null) pairs.add(match);
      }
    }
    if (pairs.isEmpty) return null;

    double meanOf(double? Function(FlavorMatch) pick) {
      final values = pairs.map(pick).whereType<double>().toList();
      if (values.isEmpty) return double.nan;
      return values.reduce((a, b) => a + b) / values.length;
    }

    double? nullableMean(double? Function(FlavorMatch) pick) {
      final v = meanOf(pick);
      return v.isNaN ? null : v;
    }

    final evidence = <String>{for (final p in pairs) ...p.evidenceRefs}
        .toList();

    return FlavorMatch(
      ingredientAId: ingredientIds.first,
      combinationSize: ingredientIds.length,
      overallScore: meanOf((p) => p.overallScore),
      aromaSimilarity: nullableMean((p) => p.aromaSimilarity),
      tasteBalance: nullableMean((p) => p.tasteBalance),
      dominanceRisk: nullableMean((p) => p.dominanceRisk),
      maskingRisk: nullableMean((p) => p.maskingRisk),
      culinarySupport: nullableMean((p) => p.culinarySupport),
      evidenceRefs: evidence,
    );
  }
}
