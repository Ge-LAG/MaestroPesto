import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/flavor/presentation/widgets/flavor_compatibility_heatmap.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recommendations/presentation/widgets/recommendation_sheet.dart';
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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (rules.isNotEmpty) _RulesCard(rules: rules),
            // Lot H (H3) — bannière de recommandation dès qu'une
            // mauvaise combinaison est détectée (≥1 paire < 0.40 ou
            // ≥1 alerte danger). Le widget se masque tout seul sinon.
            _RecommendationBanner(recipe: recipe, db: db),
            // Lot G (G5) — heatmap aromatique dès que ≥2 ingrédients
            // sont liés (le widget se masque tout seul sinon).
            FlavorCompatibilityHeatmap(ingredients: recipe.ingredients, db: db),
          ],
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

/// Lot H (H3) — bannière « Mauvaise combinaison détectée » (plan §9.2).
///
/// Visible quand la recette a ≥1 paire flavour < 0.40 OU ≥1 alerte
/// Phase 4 danger. Tap → ouvre le [RecommendationSheet]. Le bouton
/// « Ignorer » persiste en mémoire de session (Set statique, v1).
class _RecommendationBanner extends StatefulWidget {
  const _RecommendationBanner({required this.recipe, required this.db});

  final Recipe recipe;
  final AppDatabase db;

  @override
  State<_RecommendationBanner> createState() => _RecommendationBannerState();
}

class _RecommendationBannerState extends State<_RecommendationBanner> {
  late final Future<RecommendationAnalysis> _analysisFuture;

  @override
  void initState() {
    super.initState();
    _analysisFuture = analyzeRecipeProblems(
      ingredients: widget.recipe.ingredients,
      flavor: FlavorRepository(widget.db),
      functional: FunctionalRepository(widget.db),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (dismissedRecommendationRecipeIds.contains(widget.recipe.id)) {
      return const SizedBox.shrink();
    }
    return FutureBuilder<RecommendationAnalysis>(
      future: _analysisFuture,
      builder: (context, snapshot) {
        final analysis = snapshot.data;
        if (analysis == null || !analysis.hasProblem) {
          return const SizedBox.shrink();
        }
        final strings = context.strings;
        final colorScheme = Theme.of(context).colorScheme;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          color: colorScheme.errorContainer,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_outlined,
                  color: colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    strings.recommendationSheetTitle,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onErrorContainer,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() {
                    dismissedRecommendationRecipeIds.add(widget.recipe.id);
                  }),
                  child: Text(strings.recommendationIgnore),
                ),
                const SizedBox(width: 4),
                FilledButton.tonal(
                  onPressed: () => showRecommendationSheet(
                    context,
                    ingredients: widget.recipe.ingredients,
                    db: widget.db,
                  ),
                  child: Text(strings.recommendationShowSubstitutes),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Card « règles physico-chimiques » (comportement Lot D, inchangé).
class _RulesCard extends StatelessWidget {
  const _RulesCard({required this.rules});

  final List<InteractionRule> rules;

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
                Text(
                  'Notes du moteur métier',
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
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
  }
}
