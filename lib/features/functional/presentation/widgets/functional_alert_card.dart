// Phase 09 Lot H — H2 : FunctionalAlertCard (plan §8.3).
//
// Liste verticale des [FunctionalAlert] applicables à la recette,
// icône + couleur par sévérité, expansion au tap pour voir les
// conditions + l'effet prédit. **Pas dismissable** (les alertes sont
// des informations, pas des erreurs).
// Intégrée dans `recipe_detail_view.dart` au-dessus du panel nutrition.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

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

class FunctionalAlertCard extends StatelessWidget {
  const FunctionalAlertCard({
    required this.ingredients,
    this.db,
    this.repository,
    super.key,
  });

  /// Ingrédients de la recette ; seuls ceux avec un `ingredientId` lié
  /// participent à l'évaluation des règles.
  final List<RecipeIngredient> ingredients;

  /// Base Drift (utilisée si [repository] n'est pas fourni).
  final AppDatabase? db;

  /// Repository injectable (tests sans Drift).
  final FunctionalRepository? repository;

  /// Ids liés, dédupliqués (ordre conservé).
  static List<String> linkedIngredientIds(List<RecipeIngredient> ingredients) {
    final seen = <String>{};
    final result = <String>[];
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty || !seen.add(id)) continue;
      result.add(id);
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final ids = linkedIngredientIds(ingredients);
    if (ids.isEmpty) return const SizedBox.shrink();

    final repo = repository ?? (db != null ? FunctionalRepository(db!) : null);
    if (repo == null) return const SizedBox.shrink();

    // Retour PO n°3 : les quantités alimentent le calcul de part du
    // mix de chaque alerte (influence potentielle).
    final grams = <String, double>{};
    final labels = <String, String>{};
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty) continue;
      labels.putIfAbsent(id, () => ingredient.label);
      final g = NutritionAggregator.quantityToGrams(ingredient.quantity);
      if (g != null && g > 0) grams.putIfAbsent(id, () => g);
    }

    return FutureBuilder<List<FunctionalAlert>>(
      future: repo.alertsFor(ids, gramsByIngredient: grams),
      builder: (context, snapshot) {
        final alerts = snapshot.data ?? const <FunctionalAlert>[];
        if (alerts.isEmpty) return const SizedBox.shrink();
        return _AlertsCard(
          alerts: alerts,
          labels: labels,
          mixQuantified: grams.isNotEmpty,
        );
      },
    );
  }
}

class _AlertsCard extends StatelessWidget {
  const _AlertsCard({
    required this.alerts,
    required this.labels,
    required this.mixQuantified,
  });

  final List<FunctionalAlert> alerts;

  /// Labels d'affichage par id d'ingrédient.
  final Map<String, String> labels;

  /// Vrai si au moins une quantité exploitable existe (la part du mix
  /// peut être calculée).
  final bool mixQuantified;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.strings.functionalAlertsTitle,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            for (final alert in alerts)
              _AlertTile(alert: alert, labels: labels),
          ],
        ),
      ),
    );
  }
}

/// Une alerte : icône + couleur par sévérité, expansion au tap
/// (conditions + effet prédit). Pas dismissable (plan §8.3).
class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert, required this.labels});

  final FunctionalAlert alert;

  /// Labels d'affichage par id (noms vus par l'utilisateur).
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final color = functionalSeverityColor(alert.severity);
    final share = alert.mixShare;
    final subtitle = StringBuffer(
      '${alert.alertId} — ${strings.functionalConfidence(alert.confidence)}',
    );
    if (share != null)
      subtitle.write(' — ${strings.functionalMixShare(share)}');
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
            childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            leading: Icon(functionalSeverityIcon(alert.severity), color: color),
            title: Text(
              alert.title,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              subtitle.toString(),
              style: Theme.of(context).textTheme.labelSmall,
            ),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (alert.triggerIngredientIds.isNotEmpty) ...[
                      Text(
                        strings.functionalTriggersLabel,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      for (final id in alert.triggerIngredientIds)
                        Text(
                          '• ${labels[id] ?? id}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      if (share != null && share < 0.05) ...[
                        const SizedBox(height: 4),
                        Text(
                          strings.functionalLowShareNote,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                      const SizedBox(height: 8),
                    ],
                    if (alert.conditions.isNotEmpty) ...[
                      Text(
                        strings.functionalConditions,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      for (final condition in alert.conditions)
                        Text(
                          '• $condition',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      const SizedBox(height: 8),
                    ],
                    if (alert.predictedEffect.isNotEmpty) ...[
                      Text(
                        strings.functionalPredictedEffect,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.predictedEffect,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 8),
                    ],
                    if (alert.sourceRefs.isNotEmpty) ...[
                      Text(
                        strings.nutritionSources,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      for (final ref in alert.sourceRefs)
                        Text(
                          '• $ref',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                    ],
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
