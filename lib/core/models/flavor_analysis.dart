// Phase 10 Lot E/H — analyse aromatique d'une recette.

import 'package:meta/meta.dart';

import 'flavor_match.dart';

/// Pont aromatique : descripteur partagé par plusieurs ingrédients.
@immutable
class FlavorBridge {
  const FlavorBridge({required this.descriptor, required this.ingredientIds});

  final String descriptor;
  final List<String> ingredientIds;
}

/// Ingrédient suggéré pour compléter une recette.
@immutable
class FlavorSuggestion {
  const FlavorSuggestion({
    required this.ingredientId,
    required this.name,
    required this.score,
    required this.supportedPairs,
    this.category,
    this.reasons = const <String>[],
  });

  final String ingredientId;
  final String name;
  final String? category;

  /// Score moyen d'accord avec les ingrédients de la recette.
  final double score;

  /// Nombre d'accords étayés (observés ou curatés) avec la recette.
  final int supportedPairs;

  /// Raisons lisibles (accords reconnus, arômes partagés).
  final List<String> reasons;
}

/// Analyse aromatique complète d'une combinaison d'ingrédients.
@immutable
class RecipeFlavorAnalysis {
  const RecipeFlavorAnalysis({
    required this.ingredientIds,
    required this.pairs,
    required this.harmony,
    required this.bridges,
    required this.tasteProfile,
    required this.dominantAromas,
    this.combination,
  });

  final List<String> ingredientIds;

  /// Score de chaque paire, clé `idA|idB` triée.
  final Map<String, FlavorMatch> pairs;

  /// Harmonie globale 0..1 (combinaison n-aire observée si elle existe,
  /// sinon moyenne pondérée par confiance des paires).
  final double harmony;

  /// Combinaison n-aire observée Phase 3 couvrant exactement la recette.
  final FlavorMatch? combination;
  final List<FlavorBridge> bridges;

  /// Profil gustatif pondéré (sweet, sour, salty, bitter, umami, fatty).
  final Map<String, double> tasteProfile;

  /// Arômes dominants de la recette (descripteur → intensité pondérée).
  final List<MapEntry<String, double>> dominantAromas;

  static String keyFor(String a, String b) =>
      a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';

  FlavorMatch? pair(String a, String b) => pairs[keyFor(a, b)];

  /// Paires triées par score décroissant.
  List<FlavorMatch> get rankedPairs =>
      pairs.values.toList()
        ..sort((x, y) => y.overallScore.compareTo(x.overallScore));

  /// Nombre de paires étayées (observées ou curatées).
  int get supportedPairCount =>
      pairs.values.where((m) => !m.isPrediction).length;
}
