// Phase 10 Lot E (ac-123) — moteur d'accords aromatiques v2.
//
// Implémente la formule de `database-metier/phase3-flavour/
// flavor_scoring_method.md` sur les profils sensoriels 603/603 :
//
//   base      = (w1·qualité aromatique + w2·équilibre gustatif
//                + w3·pont aromatique + w5·cohérence de contexte)
//               / (w1 + w2 + w3 + w5)
//   empirique = accord observé Phase 3 ou accord culinaire curaté
//   score     = (1 − α)·base + α·empirique        (α = poids du w4)
//               − w6·dominance − w7·masquage − w8·incertitude
//
// Poids v1 du document : w1 0,25 ; w2 0,15 ; w3 0,10 ; w4 0,20 ;
// w5 0,10 ; w6 0,08 ; w7 0,07 ; w8 0,05. Sans soutien empirique, le
// score est une PRÉDICTION (FlavorMatchEvidence.predicted) : il n'est
// jamais présenté comme une incompatibilité avérée.

import 'dart:math' as math;

import '../models/flavor_match.dart';
import '../models/flavor_profile.dart';

/// Soutien empirique d'une paire (observé Phase 3 ou curaté).
class EmpiricalPairing {
  const EmpiricalPairing({
    required this.score,
    required this.observed,
    this.kind = 'classic',
    this.note,
  });

  /// Score 0..1 (force de l'accord ; bas pour un contraste négatif).
  final double score;

  /// Vrai pour une observation Phase 3, faux pour une curation.
  final bool observed;

  /// classic | regional | modern | contrast_negative | observed.
  final String kind;
  final String? note;

  bool get isNegative => kind == 'contrast_negative' || score < 0.4;
}

abstract final class FlavorPairingEngine {
  static const double w1 = 0.25;
  static const double w2 = 0.15;
  static const double w3 = 0.10;
  static const double w4 = 0.20;
  static const double w5 = 0.10;
  static const double w6 = 0.08;
  static const double w7 = 0.07;
  static const double w8 = 0.05;

  /// Part du soutien empirique dans le score final quand il existe :
  /// une observation (0,7) pèse plus qu'une curation (0,6).
  static const double alphaObserved = 0.8;
  static const double alphaCurated = 0.7;

  /// Score d'une paire (ordre indifférent).
  static FlavorMatch scorePair(
    FlavorProfile a,
    FlavorProfile b, {
    EmpiricalPairing? empirical,
  }) {
    final similarity = aromaHarmony(a, b);
    final balance = tasteBalance(a, b);
    final bridge = familyOverlap(a, b);
    final context = contextFit(a.context, b.context);
    // Qualité et pont centrés : deux arômes différents ne sont pas
    // incompatibles (accords de complément), un partage fort les
    // rapproche d'un accord « par similarité » (food pairing).
    // Un ingrédient sans arôme propre (sel, sucre, farine, huile
    // neutre…) ne permet pas de juger l'accord aromatique : ces deux
    // termes tendent vers une valeur neutre au lieu de pénaliser la
    // paire (retour test visuel : sel « discutable » avec tout).
    final aromaInfo = aromaInformation(a, b);
    final quality = _lerp(0.7, 0.45 + 0.55 * similarity, aromaInfo);
    final bridged = _lerp(0.6, 0.4 + 0.6 * bridge, aromaInfo);
    final base =
        (w1 * quality + w2 * balance + w3 * bridged + w5 * context) /
        (w1 + w2 + w3 + w5);
    final dominance = dominanceRisk(a, b);
    final masking = maskingRisk(a, b);
    final uncertainty = 1 - (a.confidence + b.confidence) / 2;

    double score;
    FlavorMatchEvidence evidence;
    double confidence;
    if (empirical != null) {
      final alpha = empirical.observed ? alphaObserved : alphaCurated;
      score = (1 - alpha) * base + alpha * empirical.score;
      if (empirical.isNegative) score = math.min(score, empirical.score + 0.1);
      evidence = empirical.observed
          ? FlavorMatchEvidence.observed
          : FlavorMatchEvidence.curated;
      confidence = empirical.observed ? 0.85 : 0.75;
    } else {
      score = base;
      evidence = FlavorMatchEvidence.predicted;
      // La prédiction hérite de la confiance des profils, plafonnée :
      // un profil de famille ne vaut pas une mesure.
      confidence = math.min(0.6, (a.confidence + b.confidence) / 2);
    }
    score -= w6 * dominance + w7 * masking + w8 * uncertainty;
    score = score.clamp(0.0, 1.0);

    final shared = sharedAromas(a, b);
    return FlavorMatch(
      ingredientAId: a.ingredientId,
      ingredientBId: b.ingredientId,
      combinationSize: 2,
      overallScore: double.parse(score.toStringAsFixed(3)),
      aromaSimilarity: _round(similarity),
      aromaComplement: _round(bridge),
      tasteBalance: _round(balance),
      contextualFit: _round(context),
      dominanceRisk: _round(dominance),
      maskingRisk: _round(masking),
      culinarySupport: empirical?.score,
      evidence: evidence,
      confidence: _round(confidence),
      sharedDescriptors: shared,
      evidenceRefs: [
        if (empirical == null) 'PROFILS_SENSORIELS',
        if (empirical != null && empirical.observed) 'PHASE3_OBSERVED',
        if (empirical != null && !empirical.observed) 'CULINARY_CURATED',
      ],
      explanation: explain(
        a,
        b,
        shared: shared,
        balance: balance,
        context: context,
        dominance: dominance,
        empirical: empirical,
      ),
    );
  }

  static double _round(double v) => double.parse(v.toStringAsFixed(3));

  /// Vecteur aromatique avec remontée partielle vers la famille (un
  /// agrume partage « fruité » avec une fraise).
  /// Information aromatique d'une paire (0..1) : 0 quand l'un des deux
  /// ingrédients n'a pas d'arôme propre, 1 dès que chacun cumule au
  /// moins 0,8 d'intensité aromatique (hors saveurs).
  static double aromaInformation(FlavorProfile a, FlavorProfile b) {
    double weight(FlavorProfile p) => p.descriptors.entries
        .where((e) => !SensoryOntology.isTaste(e.key))
        .fold(0.0, (s, e) => s + e.value);
    return (math.min(weight(a), weight(b)) / 0.8).clamp(0.0, 1.0);
  }

  static double _lerp(double neutral, double value, double t) =>
      neutral + (value - neutral) * t;

  static Map<String, double> _aromaVector(FlavorProfile p) {
    final v = <String, double>{};
    p.descriptors.forEach((d, x) {
      if (SensoryOntology.isTaste(d)) return;
      v[d] = math.max(v[d] ?? 0, x);
      final fam = SensoryOntology.parent[d];
      if (fam != null) v[fam] = math.max(v[fam] ?? 0, x * 0.5);
    });
    return v;
  }

  /// Similarité aromatique : cosinus des vecteurs aromatiques
  /// (descripteurs partagés, « food pairing » par similarité), 0..1.
  static double aromaHarmony(FlavorProfile a, FlavorProfile b) {
    final va = _aromaVector(a);
    final vb = _aromaVector(b);
    if (va.isEmpty || vb.isEmpty) return 0; // neutre (texturants…)
    var dot = 0.0;
    va.forEach((k, x) => dot += x * (vb[k] ?? 0));
    final na = math.sqrt(va.values.fold(0.0, (s, x) => s + x * x));
    final nb = math.sqrt(vb.values.fold(0.0, (s, x) => s + x * x));
    if (na == 0 || nb == 0) return 0;
    return (dot / (na * nb)).clamp(0.0, 1.0);
  }

  /// Pont aromatique : part des familles aromatiques de chacun
  /// retrouvées chez l'autre.
  static double familyOverlap(FlavorProfile a, FlavorProfile b) {
    Set<String> families(FlavorProfile p) => {
      for (final e in p.descriptors.entries)
        if (!SensoryOntology.isTaste(e.key) && e.value >= 0.3)
          SensoryOntology.family(e.key),
    };
    final fa = families(a);
    final fb = families(b);
    if (fa.isEmpty || fb.isEmpty) return 0;
    final inter = fa.intersection(fb).length;
    return (inter / math.min(fa.length, fb.length)).clamp(0.0, 1.0);
  }

  /// Équilibre gustatif : complémentarités classiques (gras/acide,
  /// sucré/acide, amer/sucré, umami/umami, salé/sucré) et conflits
  /// (double amertume, double acidité forte, double piquant).
  static double tasteBalance(FlavorProfile a, FlavorProfile b) {
    double m(String x, String y) =>
        math.max(math.min(a[x], b[y]), math.min(a[y], b[x]));
    var s = 0.5;
    s += 0.25 * m('fatty', 'sour');
    s += 0.20 * m('sweet', 'sour');
    s += 0.15 * m('bitter', 'sweet');
    s += 0.10 * m('bitter', 'fatty');
    s += 0.20 * math.min(a['umami'], b['umami']);
    s += 0.10 * m('salty', 'sweet');
    s += 0.10 * m('umami', 'sour');
    s += 0.10 * m('fatty', 'salty');
    s -= 0.30 * math.min(a['bitter'], b['bitter']);
    s -= 0.25 * math.max(0, math.min(a['sour'], b['sour']) - 0.5);
    s -= 0.15 * math.max(0, math.min(a['pungent'], b['pungent']) - 0.5);
    s -= 0.20 * math.min(a['astringent'], b['sour']);
    return s.clamp(0.0, 1.0);
  }

  /// Cohérence de contexte (sucré vs salé).
  static double contextFit(FlavorContext a, FlavorContext b) {
    if (a == FlavorContext.both || b == FlavorContext.both) return 0.8;
    return a == b ? 1.0 : 0.35;
  }

  /// Risque de dominance : un ingrédient très puissant face à un
  /// ingrédient délicat.
  static double dominanceRisk(FlavorProfile a, FlavorProfile b) {
    final hi = math.max(a.intensity, b.intensity);
    final lo = math.min(a.intensity, b.intensity);
    if (hi < 0.75) return 0;
    return ((hi - 0.75) * 4 * (hi - lo)).clamp(0.0, 1.0);
  }

  /// Risque de masquage : même descripteur dominant aux intensités
  /// proches (redondance) chez deux ingrédients puissants.
  static double maskingRisk(FlavorProfile a, FlavorProfile b) {
    final ta = a.topAromas;
    final tb = b.topAromas;
    if (ta.isEmpty || tb.isEmpty) return 0;
    if (ta.first.key != tb.first.key) return 0;
    final closeness = 1 - (ta.first.value - tb.first.value).abs();
    return (closeness * math.min(a.intensity, b.intensity)).clamp(0.0, 1.0);
  }

  /// Descripteurs aromatiques partagés (intensité ≥ 0,3 des deux côtés)
  /// triés par force commune.
  static List<String> sharedAromas(FlavorProfile a, FlavorProfile b) {
    final shared = <MapEntry<String, double>>[];
    a.descriptors.forEach((d, x) {
      if (SensoryOntology.isTaste(d)) return;
      final y = b[d];
      if (x >= 0.3 && y >= 0.3) shared.add(MapEntry(d, math.min(x, y)));
    });
    shared.sort((p, q) => q.value.compareTo(p.value));
    return [for (final e in shared.take(4)) e.key];
  }

  /// Explication lisible (FR) du score.
  static String explain(
    FlavorProfile a,
    FlavorProfile b, {
    required List<String> shared,
    required double balance,
    required double context,
    required double dominance,
    EmpiricalPairing? empirical,
  }) {
    final parts = <String>[];
    if (empirical != null) {
      final what = empirical.kind == 'contrast_negative'
          ? 'Contraste reconnu comme désagréable'
          : empirical.observed
          ? 'Accord observé'
          : 'Accord culinaire reconnu';
      parts.add(
        empirical.note == null || empirical.note!.isEmpty
            ? what
            : '$what : ${empirical.note}',
      );
    }
    if (shared.isNotEmpty) {
      parts.add(
        'Arômes partagés : ${shared.map(SensoryOntology.label).join(', ')}',
      );
    }
    final contrasts = _tasteContrasts(a, b);
    if (contrasts.isNotEmpty) {
      parts.add('Équilibre : ${contrasts.join(', ')}');
    }
    if (balance < 0.4) parts.add('Saveurs en conflit');
    if (context < 0.5) parts.add('Contextes sucré et salé opposés');
    if (dominance > 0.3) parts.add('Risque de dominance aromatique');
    if (empirical == null) {
      parts.add(
        aromaInformation(a, b) < 0.5
            ? 'Ingrédient sans arôme propre : accord non discriminant '
                  '(prédiction neutre)'
            : 'Prédiction par profils sensoriels (sans accord documenté)',
      );
    }
    return parts.join(' · ');
  }

  static List<String> _tasteContrasts(FlavorProfile a, FlavorProfile b) {
    final out = <String>[];
    bool pair(String x, String y) =>
        (a[x] >= 0.4 && b[y] >= 0.4) || (a[y] >= 0.4 && b[x] >= 0.4);
    if (pair('fatty', 'sour')) out.add('gras relevé par l’acidité');
    if (pair('sweet', 'sour')) out.add('sucré-acidulé');
    if (pair('bitter', 'sweet')) out.add('amertume adoucie');
    if (a['umami'] >= 0.4 && b['umami'] >= 0.4) out.add('synergie umami');
    if (pair('salty', 'sweet')) out.add('sucré-salé');
    return out;
  }

  // -----------------------------------------------------------------
  // Combinaisons N-aires (recette)
  // -----------------------------------------------------------------

  /// Ponts aromatiques d'une combinaison : descripteurs présents
  /// (≥ 0,4) chez au moins deux ingrédients, avec les ingrédients.
  static Map<String, List<String>> bridges(List<FlavorProfile> profiles) {
    final byDescriptor = <String, List<String>>{};
    for (final p in profiles) {
      p.descriptors.forEach((d, x) {
        if (SensoryOntology.isTaste(d) || x < 0.4) return;
        byDescriptor.putIfAbsent(d, () => []).add(p.ingredientId);
      });
    }
    byDescriptor.removeWhere((_, ids) => ids.length < 2);
    return byDescriptor;
  }

  /// Profil gustatif pondéré d'une combinaison (poids = masse × part
  /// relative) sur les 6 saveurs de base.
  static Map<String, double> tasteProfile(
    List<FlavorProfile> profiles,
    Map<String, double> weights,
  ) {
    const dims = ['sweet', 'sour', 'salty', 'bitter', 'umami', 'fatty'];
    final total = profiles.fold<double>(
      0,
      (s, p) => s + (weights[p.ingredientId] ?? 1),
    );
    return {
      for (final d in dims)
        d: total == 0
            ? 0
            : profiles.fold<double>(
                    0,
                    (s, p) => s + p[d] * (weights[p.ingredientId] ?? 1),
                  ) /
                  total,
    };
  }
}
