// Phase 10 Lot F — tuile d'une règle physico-chimique évaluée.
//
// Titre = comportement attendu du mélange ; sous-titre = état des
// conditions, confiance, part du mix. Au tap : conseil de formulation,
// conditions vérifiées (✓ réunie, ✗ non réunie, ? non évaluable),
// ingrédients concernés, règle et sources.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/models/functional_alert.dart';

/// Couleur associée à une sévérité (exposée pour les tests).
Color functionalSeverityColor(FunctionalSeverity severity) {
  switch (severity) {
    case FunctionalSeverity.info:
      return const Color(0xFF4A7BA6); // bleu
    case FunctionalSeverity.warning:
      return const Color(0xFFD9A441); // jaune
    case FunctionalSeverity.danger:
      return const Color(0xFFB85C45); // rouge
    case FunctionalSeverity.outOfDomain:
      return const Color(0xFF8A8A8A); // gris
  }
}

/// Icône associée à une sévérité (exposée pour les tests).
IconData functionalSeverityIcon(FunctionalSeverity severity) {
  switch (severity) {
    case FunctionalSeverity.info:
      return Icons.info_outline;
    case FunctionalSeverity.warning:
      return Icons.warning_amber_outlined;
    case FunctionalSeverity.danger:
      return Icons.error_outline;
    case FunctionalSeverity.outOfDomain:
      return Icons.help_outline;
  }
}

/// Libellé de l'état des conditions d'une règle.
String ruleStatusLabel(AppStrings strings, RuleStatus status) =>
    switch (status) {
      RuleStatus.conditionsMet => strings.ruleStatusMet,
      RuleStatus.partiallyMet => strings.ruleStatusPartial,
      RuleStatus.notMet => strings.ruleStatusNotMet,
      RuleStatus.unknown => strings.ruleStatusUnknown,
    };

class FunctionalAlertTile extends StatelessWidget {
  const FunctionalAlertTile({
    required this.alert,
    this.labels = const <String, String>{},
    super.key,
  });

  final FunctionalAlert alert;

  /// Labels d'affichage par id d'ingrédient (noms vus par l'utilisateur).
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final color = functionalSeverityColor(alert.severity);
    final share = alert.mixShare;
    final subtitle = StringBuffer(
      '${ruleStatusLabel(strings, alert.status)} — '
      '${strings.functionalConfidence(alert.confidence)}',
    );
    if (share != null && share > 0) {
      subtitle.write(' — ${strings.functionalMixShare(share)}');
    }
    Widget section(String title, List<Widget> children) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: Theme(
          data: theme.copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Icon(functionalSeverityIcon(alert.severity), color: color),
            title: Text(
              alert.expectedOutcome ?? alert.title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            subtitle: Text(
              subtitle.toString(),
              style: theme.textTheme.labelSmall,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alert.advice != null)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${strings.functionalAdvice} : ${alert.advice}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    if (alert.checks.isNotEmpty)
                      section(strings.functionalConditions, [
                        for (final c in alert.checks) _CheckRow(check: c),
                      ])
                    else if (alert.conditions.isNotEmpty)
                      section(strings.functionalConditions, [
                        for (final condition in alert.conditions)
                          Text(
                            '• $condition',
                            style: theme.textTheme.bodySmall,
                          ),
                      ]),
                    if (alert.triggerIngredientIds.isNotEmpty)
                      section(strings.functionalTriggersLabel, [
                        for (final id in alert.triggerIngredientIds)
                          Text(
                            '• ${labels[id] ?? id}',
                            style: theme.textTheme.bodySmall,
                          ),
                        if (share != null && share < 0.05)
                          Text(
                            strings.functionalLowShareNote,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                      ]),
                    Text(
                      '${alert.alertId} — ${alert.title}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (alert.sourceRefs.isNotEmpty)
                      Text(
                        '${strings.nutritionSources} : '
                        '${alert.sourceRefs.join(', ')}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check});

  final RuleCheck check;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final met = check.met;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            met == null
                ? Icons.help_outline
                : met
                ? Icons.check_circle_outline
                : Icons.cancel_outlined,
            size: 14,
            color: met == null
                ? theme.colorScheme.outline
                : met
                ? const Color(0xFF357A5B)
                : const Color(0xFFB85C45),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              check.detail == null
                  ? check.label
                  : '${check.label} — ${check.detail}',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
