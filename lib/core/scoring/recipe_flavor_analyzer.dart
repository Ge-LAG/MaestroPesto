// Phase 10 Lot E (extrait en Phase 11) — analyse aromatique pure d'une
// combinaison d'ingrédients : harmonie pondérée, ponts, profil gustatif
// et arômes dominants.
//
// Partagée par FlavorRepository.analyze (fiche recette, éditeur) et le
// moteur de composition (recette à l'envers) : les deux calculent
// exactement la même harmonie.

import 'dart:math' as math;

import '../models/flavor_analysis.dart';
import '../models/flavor_match.dart';
import '../models/flavor_profile.dart';
import 'flavor_pairing_engine.dart';

/// Score d'une paire (ordre indifférent), déjà résolu (moteur v2 et
/// soutien empirique).
typedef FlavorPairScorer = FlavorMatch Function(String a, String b);

abstract final class RecipeFlavorAnalyzer {
  /// Poids d'une paire : racine du produit des masses (une paire
  /// d'ingrédients mineurs pèse moins, sans être ignorée).
  static double pairWeight(String a, String b, Map<String, double> weights) {
    if (weights.isEmpty) return 1;
    final wa = weights[a] ?? 1;
    final wb = weights[b] ?? 1;
    return math.sqrt(math.max(wa, 1) * math.max(wb, 1));
  }

  /// Harmonie : moyenne des scores de paires pondérée par la confiance
  /// et par [pairWeight].
  static double harmonyOf(
    List<String> ids,
    FlavorPairScorer pair,
    Map<String, double> weights,
  ) {
    var weighted = 0.0;
    var weightSum = 0.0;
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final m = pair(ids[i], ids[j]);
        final w = (m.confidence ?? 0.5) * pairWeight(ids[i], ids[j], weights);
        weighted += m.overallScore * w;
        weightSum += w;
      }
    }
    return weightSum == 0 ? 0 : weighted / weightSum;
  }

  /// Arômes dominants : intensité × part de masse (défaut uniforme) ; la
  /// puissance aromatique compense une faible masse (épices).
  static List<MapEntry<String, double>> dominantAromas(
    List<FlavorProfile> profiles,
    Map<String, double> weights, {
    int? take = 6,
  }) {
    final aroma = <String, double>{};
    final total = profiles.fold<double>(
      0,
      (s, p) => s + (weights[p.ingredientId] ?? 1),
    );
    for (final p in profiles) {
      final share = (weights[p.ingredientId] ?? 1) / total;
      final power = math.max(share, p.intensity * 0.25);
      p.descriptors.forEach((d, x) {
        if (SensoryOntology.isTaste(d)) return;
        aroma[d] = (aroma[d] ?? 0) + x * power;
      });
    }
    final dominant = aroma.entries.toList()
      ..sort((a, b) {
        final byValue = b.value.compareTo(a.value);
        return byValue != 0 ? byValue : a.key.compareTo(b.key);
      });
    return take == null ? dominant : dominant.take(take).toList();
  }

  /// Analyse complète. [ids] : ingrédients distincts ayant un profil
  /// (au moins deux). [combination] : combinaison n-aire observée
  /// couvrant exactement [ids], prioritaire pour l'harmonie.
  static RecipeFlavorAnalysis analyze({
    required List<String> ids,
    required FlavorProfile Function(String id) profileOf,
    required FlavorPairScorer pair,
    FlavorMatch? combination,
    Map<String, double> weights = const {},
  }) {
    final pairs = <String, FlavorMatch>{};
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        pairs[RecipeFlavorAnalysis.keyFor(ids[i], ids[j])] = pair(
          ids[i],
          ids[j],
        );
      }
    }
    final profiles = [for (final id in ids) profileOf(id)];
    final bridgeMap = FlavorPairingEngine.bridges(profiles);
    final bridges = [
      for (final e in bridgeMap.entries)
        FlavorBridge(descriptor: e.key, ingredientIds: e.value),
    ]..sort((a, b) => b.ingredientIds.length.compareTo(a.ingredientIds.length));
    return RecipeFlavorAnalysis(
      ingredientIds: ids,
      pairs: pairs,
      harmony:
          combination?.overallScore ??
          harmonyOf(
            ids,
            (a, b) => pairs[RecipeFlavorAnalysis.keyFor(a, b)]!,
            weights,
          ),
      combination: combination,
      bridges: bridges,
      tasteProfile: FlavorPairingEngine.tasteProfile(profiles, weights),
      dominantAromas: dominantAromas(profiles, weights),
    );
  }
}
