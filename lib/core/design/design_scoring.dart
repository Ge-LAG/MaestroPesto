// Phase 11 Lot B — écart d'une composition aux objectifs.
//
// Chaque critère visé donne une valeur obtenue, un statut (atteint,
// proche, manqué, non vérifiable) et un terme d'écart normalisé :
//   - dans la cible : 0 (plage, minimum, maximum) ou une légère
//     attraction vers la valeur visée (≤ 0,1) ;
//   - hors cible : distance à la borne rapportée à l'échelle du critère
//     (tolérance de la valeur visée, 10 % d'une borne), croissance
//     quadratique puis linéaire (un critère très éloigné ne masque pas
//     les autres) ;
//   - non vérifiable (couverture insuffisante) : terme 1, jamais une
//     valeur supposée.
// Score d'aspect = moyenne de ses termes ; écart pondéré = somme des
// scores d'aspect pondérée par les priorités (aspects visés seulement).
// Les contraintes dures (exclusions, allergènes, imposés) sont hors
// score : le moteur ne produit jamais de composition qui les viole.

import 'package:meta/meta.dart';

import 'design_brief.dart';
import 'design_evaluator.dart';
import 'design_metrics.dart';

/// Statut d'un critère.
enum CriterionStatus {
  met,
  near,
  missed,
  unverifiable;

  String get labelFr => switch (this) {
    CriterionStatus.met => 'Atteint',
    CriterionStatus.near => 'Proche',
    CriterionStatus.missed => 'Manqué',
    CriterionStatus.unverifiable => 'Non vérifiable',
  };
}

/// Résultat d'un critère visé.
@immutable
class CriterionResult {
  const CriterionResult({
    required this.metric,
    required this.target,
    required this.status,
    required this.term,
    this.value,
    this.choice,
  });

  final DesignMetric metric;
  final DesignTarget target;
  final double? value;
  final String? choice;
  final CriterionStatus status;

  /// Terme d'écart normalisé (≥ 0).
  final double term;
}

/// Écart d'une composition à la demande.
@immutable
class DesignScore {
  const DesignScore({
    required this.criteria,
    required this.aspectDeviation,
    required this.weightedDeviation,
  });

  final List<CriterionResult> criteria;

  /// Moyenne des termes par aspect visé.
  final Map<DesignAspect, double> aspectDeviation;

  /// Écart pondéré aux objectifs (critère de comparaison des modes).
  final double weightedDeviation;

  int get metCount =>
      criteria.where((c) => c.status == CriterionStatus.met).length;
}

abstract final class DesignScoring {
  /// Terme d'un critère non vérifiable.
  static const double unverifiableTerm = 1;

  static DesignScore score(DesignBrief brief, DesignMeasure measure) {
    final criteria = <CriterionResult>[];
    final sums = <DesignAspect, double>{};
    final counts = <DesignAspect, int>{};
    for (final metric in DesignMetrics.all) {
      final target = brief.targets[metric.id];
      if (target == null) continue;
      final r = criterion(metric, target, measure[metric.id]);
      criteria.add(r);
      sums[metric.aspect] = (sums[metric.aspect] ?? 0) + r.term;
      counts[metric.aspect] = (counts[metric.aspect] ?? 0) + 1;
    }
    final weights = brief.weights;
    final deviation = <DesignAspect, double>{
      for (final a in sums.keys) a: sums[a]! / counts[a]!,
    };
    var weighted = 0.0;
    var weightSum = 0.0;
    for (final e in deviation.entries) {
      final w = weights[e.key] ?? 0;
      weighted += w * e.value;
      weightSum += w;
    }
    if (weightSum <= 0 && deviation.isNotEmpty) {
      // Tous les aspects visés ont un poids nul : moyenne simple.
      weighted = deviation.values.fold<double>(0, (s, v) => s + v);
      weightSum = deviation.length.toDouble();
    }
    return DesignScore(
      criteria: criteria,
      aspectDeviation: deviation,
      weightedDeviation: weightSum <= 0 ? 0 : weighted / weightSum,
    );
  }

  /// Évaluation d'un critère.
  static CriterionResult criterion(
    DesignMetric metric,
    DesignTarget target,
    MeasuredValue? measured,
  ) {
    CriterionResult result(CriterionStatus status, double term) =>
        CriterionResult(
          metric: metric,
          target: target,
          status: status,
          term: term,
          value: measured?.value,
          choice: measured?.choice,
        );

    if (measured == null || !measured.verifiable) {
      return result(CriterionStatus.unverifiable, unverifiableTerm);
    }
    switch (metric.id) {
      case 'cooking_method':
        final ok = measured.choice == target.choice;
        return result(
          ok ? CriterionStatus.met : CriterionStatus.missed,
          ok ? 0 : 1,
        );
      case 'pivot':
        final ok = (measured.choice ?? '').split('|').contains(target.choice);
        return result(
          ok ? CriterionStatus.met : CriterionStatus.missed,
          ok ? 0 : 1,
        );
      case 'nutriscore':
        final score = measured.value;
        final grade = target.choice;
        if (score == null || grade == null) {
          return result(CriterionStatus.unverifiable, unverifiableTerm);
        }
        final dist = score - nutriThreshold(grade);
        if (dist <= 0) return result(CriterionStatus.met, 0);
        final z = dist / 4;
        return result(
          z <= 1 ? CriterionStatus.near : CriterionStatus.missed,
          _outside(z),
        );
      case 'dominant_family':
        if (measured.choice == target.choice) {
          return result(CriterionStatus.met, 0);
        }
        // Retard de la famille visée sur la famille dominante.
        final top = measured.value ?? 0;
        final share = measured.shares[target.choice] ?? 0;
        final z = top <= 0 ? 1.0 : ((top - share) / top).clamp(0.0, 1.0);
        return result(
          z <= 0.5 ? CriterionStatus.near : CriterionStatus.missed,
          0.1 + z,
        );
    }
    final x = measured.value;
    if (x == null) {
      return result(CriterionStatus.unverifiable, unverifiableTerm);
    }
    final b = target.bounds;
    final lo = b.lower;
    final hi = b.upper;
    final floor = metric.scale * 0.02;
    final double s = switch (target.kind) {
      TargetKind.value => _max(target.value!.abs() * target.tolerance, floor),
      TargetKind.range => _max((hi! - lo!).abs() / 2, floor),
      TargetKind.min => _max(lo!.abs() * 0.1, floor),
      TargetKind.max => _max(hi!.abs() * 0.1, floor),
      TargetKind.choice => 1,
    };
    final dist = lo != null && x < lo
        ? lo - x
        : hi != null && x > hi
        ? x - hi
        : 0.0;
    if (dist <= 0) {
      if (target.kind == TargetKind.value) {
        final e = (x - target.value!) / s;
        return result(CriterionStatus.met, 0.1 * e * e);
      }
      return result(CriterionStatus.met, 0);
    }
    final z = dist / s;
    final base = target.kind == TargetKind.value ? 0.1 : 0.0;
    return result(
      z <= 1 ? CriterionStatus.near : CriterionStatus.missed,
      base + _outside(z),
    );
  }

  /// Score Nutri-Score maximal d'une lettre (A ≤ 0, B ≤ 2, C ≤ 10,
  /// D ≤ 18).
  static double nutriThreshold(String grade) => switch (grade) {
    'A' => 0,
    'B' => 2,
    'C' => 10,
    'D' => 18,
    _ => double.infinity,
  };

  static double _outside(double z) => z <= 1 ? z * z : 2 * z - 1;

  static double _max(double a, double b) => a > b ? a : b;
}
