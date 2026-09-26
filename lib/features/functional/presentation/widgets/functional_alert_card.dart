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
import 'package:maestropesto/features/functional/presentation/widgets/functional_alert_tile.dart';

export 'functional_alert_tile.dart';

import 'package:maestropesto/features/recipes/domain/recipe.dart';

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
              FunctionalAlertTile(alert: alert, labels: labels),
          ],
        ),
      ),
    );
  }
}
