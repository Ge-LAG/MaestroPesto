import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Lot D — small advisory panel that surfaces Phase 3 + Phase 4
/// matches for the current recipe.
///
/// The panel is intentionally minimal:
/// - If the recipe references Phase 1 ingredients AND the metier DB has
///   interaction rules that mention one of them, list the top 3 rules
///   with their predicted effect.
/// - No matches = the panel renders nothing (no-op).
///
/// The widget is **read-only** and never throws: if the database is
/// empty (CSV import not run yet), it simply returns a `SizedBox.shrink`.
class RecipeMetierAdvisoryPanel extends StatelessWidget {
  const RecipeMetierAdvisoryPanel({
    required this.recipe,
    required this.db,
    super.key,
  });

  final Recipe recipe;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<InteractionRule>>(
      future: _matchingRules(),
      builder: (context, snapshot) {
        final rules = snapshot.data ?? const <InteractionRule>[];
        if (rules.isEmpty) {
          return const SizedBox.shrink();
        }
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
                    Text(
                      'Notes du moteur métier',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${rules.length} règle${rules.length > 1 ? 's' : ''} '
                  'physico-chimique${rules.length > 1 ? 's' : ''} applicable${rules.length > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                for (final rule in rules.take(3))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• ${rule.ruleId} (${rule.ruleFamily}) — '
                      '${rule.predictedEffect} '
                      '(${rule.effectDirection}, ${rule.effectMagnitude})',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (rules.length > 3)
                  Text(
                    '…et ${rules.length - 3} autre${rules.length - 3 > 1 ? 's' : ''}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<InteractionRule>> _matchingRules() async {
    final ingredientIds = recipe.ingredients
        .map((i) => i.ingredientId)
        .whereType<String>()
        .toList();
    if (ingredientIds.isEmpty) {
      return const <InteractionRule>[];
    }
    // The schema stores reactant_or_component_ids as a `|`-separated list
    // (nullable). Match a rule if any of our ingredient ids appears in
    // that list.
    final all = await db.select(db.interactionRules).get();
    final matches = <InteractionRule>[];
    for (final rule in all) {
      final reactants = (rule.reactantOrComponentIds ?? '').split('|');
      for (final id in ingredientIds) {
        if (reactants.contains(id)) {
          matches.add(rule);
          break;
        }
      }
    }
    return matches;
  }
}