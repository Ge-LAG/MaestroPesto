// Phase 09 Lot H — H1 : FunctionalConstraintSolver (plan §8.1).
//
// Fonction pure : évalue les règles Phase 4 (`InteractionRules`) contre
// la liste des ingredientIds d'une recette et renvoie les
// [FunctionalAlert] applicables, triées par sévérité décroissante.
//
// dp-107 — v1 en mode dégradé :
// - une règle s'applique si l'un de ses `reactant_or_component_ids`
//   (pipe-separated) matche un `ingredientId` de la recette ;
// - les `ingredient_constraints`, `composition_constraints` et
//   `process_constraints` ne sont PAS parsées (expressions libres) ;
// - `ph_min/max`, `temperature_min/max`, `time_min/max`, `aw_min/max`
//   sont ignorés (pas de données de process dans la recette) ;
// - la `confidence` de la règle est ramenée à 50 %
//   (OUT_OF_DOMAIN implicite, signalé dans la doc de FunctionalAlert).
//
// Règles sans `reactant_or_component_ids` (ex. RULE-AW-MICRO, règles
// « any ») ne sont jamais déclenchées en v1 : on ne peut pas les lier
// à un ingrédient de la recette.
//
// Sévérité v1 (heuristique documentée, faute de colonne dédiée) :
// - `rule_family == 'safety'` → danger ;
// - `effect_direction` négatif (`decrease*`) → warning ;
// - sinon → info.

import '../database/app_database.dart' show InteractionRule;
import '../models/functional_alert.dart';

/// Facteur de dégradation de la confiance en v1 (dp-107).
const double kFunctionalDegradedConfidenceFactor = 0.5;

/// Solveur de contraintes physico-chimiques pur (plan Phase 09 §8.1).
abstract final class FunctionalConstraintSolver {
  /// Évalue [allRules] contre [recipeIngredientIds] et renvoie les
  /// alertes applicables triées par sévérité décroissante
  /// (danger > warning > info > outOfDomain), puis par `alertId` pour
  /// un ordre déterministe.
  static List<FunctionalAlert> evaluate({
    required List<String> recipeIngredientIds,
    required List<InteractionRule> allRules,
  }) {
    final ids = recipeIngredientIds.toSet();
    final alerts = <FunctionalAlert>[];
    for (final rule in allRules) {
      final reactants = _splitPipe(rule.reactantOrComponentIds);
      if (reactants.isEmpty) continue; // règle « any » : non déclenchée en v1
      final matches = reactants.any(ids.contains);
      if (!matches) continue;
      alerts.add(_toAlert(rule, reactants));
    }
    alerts.sort((a, b) {
      final bySeverity = _severityRank(b.severity) - _severityRank(a.severity);
      return bySeverity != 0 ? bySeverity : a.alertId.compareTo(b.alertId);
    });
    return alerts;
  }

  static FunctionalAlert _toAlert(
    InteractionRule rule,
    List<String> reactants,
  ) {
    return FunctionalAlert(
      alertId: rule.ruleId,
      severity: _severityFor(rule),
      title: _titleFor(rule),
      conditions: _conditionsFor(rule),
      predictedEffect: rule.predictedEffect ?? '',
      confidence: (rule.confidence ?? 1.0) * kFunctionalDegradedConfidenceFactor,
      evidenceType: rule.evidenceType ?? 'expert_rule_with_literature',
    );
  }

  /// Heuristique de sévérité v1 (voir en-tête du fichier).
  static FunctionalSeverity _severityFor(InteractionRule rule) {
    final family = (rule.ruleFamily ?? '').trim().toLowerCase();
    if (family == 'safety') return FunctionalSeverity.danger;
    final direction = (rule.effectDirection ?? '').trim().toLowerCase();
    if (direction.startsWith('decrease')) return FunctionalSeverity.warning;
    return FunctionalSeverity.info;
  }

  /// Titre lisible : la colonne `notes` (FR, rédigée) si disponible,
  /// sinon le `rule_id`.
  static String _titleFor(InteractionRule rule) {
    final notes = rule.notes?.trim();
    if (notes != null && notes.isNotEmpty) return notes;
    return rule.ruleId;
  }

  /// Conditions affichables : les champs de contraintes bruts (non
  /// parsés en v1, mais informatifs) + les bornes pH/T/temps/aw.
  static List<String> _conditionsFor(InteractionRule rule) {
    final conditions = <String>[];
    void add(String? raw) {
      final value = raw?.trim();
      if (value != null && value.isNotEmpty) conditions.add(value);
    }

    add(rule.ingredientConstraints);
    add(rule.compositionConstraints);
    add(rule.processConstraints);
    if (rule.phMin != null || rule.phMax != null) {
      conditions.add('pH ${_range(rule.phMin, rule.phMax)}');
    }
    if (rule.temperatureMin != null || rule.temperatureMax != null) {
      conditions.add('T ${_range(rule.temperatureMin, rule.temperatureMax)} °C');
    }
    if (rule.timeMin != null || rule.timeMax != null) {
      conditions.add('durée ${_range(rule.timeMin, rule.timeMax)} min');
    }
    if (rule.waterActivityMin != null || rule.waterActivityMax != null) {
      conditions.add('aw ${_range(rule.waterActivityMin, rule.waterActivityMax)}');
    }
    return conditions;
  }

  static String _range(double? min, double? max) {
    String fmt(double v) => v == v.roundToDouble()
        ? v.toStringAsFixed(0)
        : v.toString();
    if (min != null && max != null) return '${fmt(min)}–${fmt(max)}';
    if (min != null) return '≥ ${fmt(min)}';
    return '≤ ${fmt(max!)}';
  }

  static int _severityRank(FunctionalSeverity severity) {
    switch (severity) {
      case FunctionalSeverity.danger:
        return 3;
      case FunctionalSeverity.warning:
        return 2;
      case FunctionalSeverity.info:
        return 1;
      case FunctionalSeverity.outOfDomain:
        return 0;
    }
  }

  static List<String> _splitPipe(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    return raw
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }
}
