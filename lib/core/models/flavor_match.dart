// Phase 09 Lot G — modèle pur FlavorMatch (Phase 3 flavour).
//
// Immutable, Drift-free, testable avec `package:test/test.dart`.
// Source de vérité : table Drift `FlavorCompatibility`
// (lib/core/database/tables/flavor_compatibility.dart).
//
// dp-106 : le `overallScore` est lu directement depuis le CSV/table
// Phase 3 (déjà calculé par les scripts de phase 3). On NE réimplémente
// PAS la formule w1..w8 de `flavor_scoring_method.md`.

import 'package:meta/meta.dart';

/// Catégories de compatibilité aromatique, dérivées de `overallScore`
/// (cf. cahier phase 3 et plan Phase 09 §5.4).
enum FlavorMatchCategory { excellent, good, average, questionable, avoid }

/// Origine du score (Phase 10, ac-123 — décision honest-data-display).
enum FlavorMatchEvidence {
  /// Accord observé documenté en base Phase 3.
  observed,

  /// Accord culinaire curaté (tradition, soutien empirique w4).
  curated,

  /// Prédiction du moteur de profils sensoriels (pas de soutien
  /// empirique) : jamais présentée comme une incompatibilité avérée.
  predicted,
}

/// Association aromatique entre ingrédients (paire ou combinaison n-aire).
@immutable
class FlavorMatch {
  const FlavorMatch({
    required this.ingredientAId,
    this.ingredientBId,
    required this.combinationSize,
    required this.overallScore,
    this.aromaSimilarity,
    this.tasteBalance,
    this.dominanceRisk,
    this.maskingRisk,
    this.culinarySupport,
    this.evidenceRefs = const <String>[],
    this.explanation,
    this.evidence = FlavorMatchEvidence.observed,
    this.confidence,
    this.aromaComplement,
    this.contextualFit,
    this.sharedDescriptors = const <String>[],
  });

  /// Identifiant Phase 1 du premier ingrédient de la combinaison.
  final String ingredientAId;

  /// Identifiant du second ingrédient — null pour les combinaisons
  /// n-aires (size > 2) où la paire n'a pas de sens.
  final String? ingredientBId;

  /// Taille de la combinaison (2, 3, 4…).
  final int combinationSize;

  /// Score global [0,1] lu tel quel depuis la table Phase 3 (dp-106),
  /// ou moyenne des paires pour un match synthétique (FlavorScorer).
  final double overallScore;

  /// Similarité aromatique [0,1] (nullable : pas toujours renseignée).
  final double? aromaSimilarity;

  /// Équilibre gustatif [0,1] (nullable).
  final double? tasteBalance;

  /// Risque de dominance [0,1] (nullable).
  final double? dominanceRisk;

  /// Risque de masquage [0,1] (nullable).
  final double? maskingRisk;

  /// Support culinaire / littérature [0,1] (nullable).
  final double? culinarySupport;

  /// Références bibliographiques (split `|` côté loader CSV).
  final List<String> evidenceRefs;

  /// Résumé lisible de l'association (nullable).
  final String? explanation;

  /// Origine du score (observé, curaté, prédit).
  final FlavorMatchEvidence evidence;

  /// Confiance du score 0..1 (null = non documentée).
  final double? confidence;

  /// Complémentarité aromatique (familles partagées) 0..1.
  final double? aromaComplement;

  /// Cohérence de contexte culinaire (sucré/salé) 0..1.
  final double? contextualFit;

  /// Descripteurs aromatiques partagés (ids de l'ontologie), du plus
  /// fort au plus faible.
  final List<String> sharedDescriptors;

  /// Vrai si le score est une prédiction sans soutien empirique.
  bool get isPrediction => evidence == FlavorMatchEvidence.predicted;

  /// Vrai si le score désigne une incompatibilité étayée (observée ou
  /// curatée) — une prédiction basse n'est jamais une incompatibilité.
  bool get isSupportedIncompatibility =>
      !isPrediction && category == FlavorMatchCategory.avoid;

  /// Catégorie dérivée de [overallScore] (seuils du cahier phase 3) :
  /// ≥ 0.85 excellent, 0.70–0.84 good, 0.55–0.69 average,
  /// 0.40–0.54 questionable, < 0.40 avoid.
  FlavorMatchCategory get category {
    if (overallScore >= 0.85) return FlavorMatchCategory.excellent;
    if (overallScore >= 0.70) return FlavorMatchCategory.good;
    if (overallScore >= 0.55) return FlavorMatchCategory.average;
    if (overallScore >= 0.40) return FlavorMatchCategory.questionable;
    return FlavorMatchCategory.avoid;
  }

  FlavorMatch copyWith({
    String? ingredientAId,
    Object? ingredientBId = _sentinel,
    int? combinationSize,
    double? overallScore,
    Object? aromaSimilarity = _sentinel,
    Object? tasteBalance = _sentinel,
    Object? dominanceRisk = _sentinel,
    Object? maskingRisk = _sentinel,
    Object? culinarySupport = _sentinel,
    List<String>? evidenceRefs,
    Object? explanation = _sentinel,
    FlavorMatchEvidence? evidence,
    Object? confidence = _sentinel,
    List<String>? sharedDescriptors,
  }) {
    return FlavorMatch(
      ingredientAId: ingredientAId ?? this.ingredientAId,
      ingredientBId: identical(ingredientBId, _sentinel)
          ? this.ingredientBId
          : ingredientBId as String?,
      combinationSize: combinationSize ?? this.combinationSize,
      overallScore: overallScore ?? this.overallScore,
      aromaSimilarity: identical(aromaSimilarity, _sentinel)
          ? this.aromaSimilarity
          : aromaSimilarity as double?,
      tasteBalance: identical(tasteBalance, _sentinel)
          ? this.tasteBalance
          : tasteBalance as double?,
      dominanceRisk: identical(dominanceRisk, _sentinel)
          ? this.dominanceRisk
          : dominanceRisk as double?,
      maskingRisk: identical(maskingRisk, _sentinel)
          ? this.maskingRisk
          : maskingRisk as double?,
      culinarySupport: identical(culinarySupport, _sentinel)
          ? this.culinarySupport
          : culinarySupport as double?,
      evidenceRefs: evidenceRefs ?? this.evidenceRefs,
      explanation: identical(explanation, _sentinel)
          ? this.explanation
          : explanation as String?,
      evidence: evidence ?? this.evidence,
      confidence: identical(confidence, _sentinel)
          ? this.confidence
          : confidence as double?,
      aromaComplement: aromaComplement,
      contextualFit: contextualFit,
      sharedDescriptors: sharedDescriptors ?? this.sharedDescriptors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FlavorMatch) return false;
    return other.ingredientAId == ingredientAId &&
        other.ingredientBId == ingredientBId &&
        other.combinationSize == combinationSize &&
        other.overallScore == overallScore &&
        other.aromaSimilarity == aromaSimilarity &&
        other.tasteBalance == tasteBalance &&
        other.dominanceRisk == dominanceRisk &&
        other.maskingRisk == maskingRisk &&
        other.culinarySupport == culinarySupport &&
        _listEq(other.evidenceRefs, evidenceRefs) &&
        other.explanation == explanation &&
        other.evidence == evidence &&
        other.confidence == confidence &&
        _listEq(other.sharedDescriptors, sharedDescriptors);
  }

  @override
  int get hashCode => Object.hash(
    ingredientAId,
    ingredientBId,
    combinationSize,
    overallScore,
    aromaSimilarity,
    tasteBalance,
    dominanceRisk,
    maskingRisk,
    culinarySupport,
    Object.hashAll(evidenceRefs),
    explanation,
    evidence,
    confidence,
    Object.hashAll(sharedDescriptors),
  );

  @override
  String toString() =>
      'FlavorMatch($ingredientAId × ${ingredientBId ?? '…'}, '
      'n=$combinationSize, score=$overallScore, ${category.name})';
}

const Object _sentinel = Object();

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
