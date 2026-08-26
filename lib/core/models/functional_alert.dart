// Phase 09 Lot H — modèle pur FunctionalAlert (Phase 4 functional).
//
// Immutable, Drift-free, testable avec `package:test/test.dart`.
// Source de vérité : table Drift `InteractionRules`
// (lib/core/database/tables/interaction_rules.dart), évaluée par le
// FunctionalConstraintSolver (lib/core/scoring/functional_constraint_solver.dart).
//
// dp-107 : les règles Phase 4 v1 sont appliquées en mode dégradé —
// les `composition_constraints` et `process_constraints` ne sont pas
// parsées, donc la `confidence` de la règle est ramenée à 50 %.

import 'package:meta/meta.dart';

/// Sévérité d'une alerte fonctionnelle (plan Phase 09 §5.5).
enum FunctionalSeverity { info, warning, danger, outOfDomain }

/// Alerte physico-chimique applicable à une recette.
@immutable
class FunctionalAlert {
  const FunctionalAlert({
    required this.alertId,
    required this.severity,
    required this.title,
    this.conditions = const <String>[],
    required this.predictedEffect,
    required this.confidence,
    this.evidenceType = 'expert_rule_with_literature',
    this.sourceRefs = const <String>[],
    this.triggerIngredientIds = const <String>[],
    this.mixShare,
  });

  /// Identifiant de la règle source (ex. `RULE-PEC-HM-001`).
  final String alertId;

  /// Sévérité de l'alerte.
  final FunctionalSeverity severity;

  /// Titre lisible (ex. « Pectine HM gélifie uniquement si… »).
  final String title;

  /// Conditions d'application (ex. `["pH < 4.0", "sucre > 60 %"]`).
  final List<String> conditions;

  /// Effet prédit (ex. « augmente la fermeté du gel »).
  final String predictedEffect;

  /// Confiance [0,1] — déjà dégradée × 0.5 en v1 (dp-107).
  final double confidence;

  /// Type de preuve de la règle source (colonne `evidence_type`).
  final String evidenceType;

  /// Références sources de la règle (colonne `source_refs`, split `|`)
  /// — citées in-app (retour PO 2026-08-26).
  final List<String> sourceRefs;

  /// Ingrédients de la recette qui déclenchent la règle (retour PO
  /// n°3 : expliciter l'influence selon le mix).
  final List<String> triggerIngredientIds;

  /// Part massique des ingrédients déclencheurs dans le mix (0..1).
  /// Null quand les quantités ne sont pas exploitables.
  final double? mixShare;

  FunctionalAlert copyWith({
    String? alertId,
    FunctionalSeverity? severity,
    String? title,
    List<String>? conditions,
    String? predictedEffect,
    double? confidence,
    String? evidenceType,
    List<String>? sourceRefs,
    List<String>? triggerIngredientIds,
    Object? mixShare = _shareSentinel,
  }) {
    return FunctionalAlert(
      alertId: alertId ?? this.alertId,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      conditions: conditions ?? this.conditions,
      predictedEffect: predictedEffect ?? this.predictedEffect,
      confidence: confidence ?? this.confidence,
      evidenceType: evidenceType ?? this.evidenceType,
      sourceRefs: sourceRefs ?? this.sourceRefs,
      triggerIngredientIds: triggerIngredientIds ?? this.triggerIngredientIds,
      mixShare: identical(mixShare, _shareSentinel)
          ? this.mixShare
          : mixShare as double?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FunctionalAlert) return false;
    return other.alertId == alertId &&
        other.severity == severity &&
        other.title == title &&
        _listEq(other.conditions, conditions) &&
        other.predictedEffect == predictedEffect &&
        other.confidence == confidence &&
        other.evidenceType == evidenceType &&
        _listEq(other.sourceRefs, sourceRefs) &&
        _listEq(other.triggerIngredientIds, triggerIngredientIds) &&
        other.mixShare == mixShare;
  }

  @override
  int get hashCode => Object.hash(
    alertId,
    severity,
    title,
    Object.hashAll(conditions),
    predictedEffect,
    confidence,
    evidenceType,
    Object.hashAll(sourceRefs),
    Object.hashAll(triggerIngredientIds),
    mixShare,
  );

  @override
  String toString() =>
      'FunctionalAlert($alertId, ${severity.name}, "$title", '
      'confidence=$confidence)';
}

const Object _shareSentinel = Object();

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
