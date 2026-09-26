import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recommendations/presentation/widgets/recommendation_sheet.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Bannière de recommandation de la fiche recette.
///
/// Phase 10 : la liste brute des règles et la heatmap ont migré vers
/// les cartes d'analyse métier (`FlavorAnalysisCard`,
/// `PhysChemAnalysisCard`) ; ce panneau ne porte plus que la bannière
/// « Mauvaise combinaison détectée » (incompatibilité aromatique ÉTAYÉE
/// ou alerte physico-chimique de type danger).
class RecipeMetierAdvisoryPanel extends StatelessWidget {
  const RecipeMetierAdvisoryPanel({
    required this.recipe,
    required this.db,
    super.key,
  });

  final Recipe recipe;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) =>
      _RecommendationBanner(recipe: recipe, db: db);
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
        // Retour PO 2026-08-26 : la bannière nomme les ingrédients en
        // cause (les paires incompatibles, comme dans le sheet).
        final pairDetail = analysis.problems
            .take(2)
            .map((p) => p.explanation)
            .join(' · ');
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        strings.recommendationSheetTitle,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onErrorContainer,
                        ),
                      ),
                      if (pairDetail.isNotEmpty)
                        Text(
                          pairDetail,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colorScheme.onErrorContainer),
                        ),
                    ],
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
