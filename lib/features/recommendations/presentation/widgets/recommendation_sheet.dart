// Phase 09 Lot H — H3 : RecommendationSheet (plan §9.2).
//
// Bottom sheet « Mauvaise combinaison détectée » : explication courte,
// liste des ingrédients à problème (paire flavour < 0.40 ou alerte
// Phase 4 danger), tap sur un ingrédient → substituts proposés par le
// [Recommender], bouton « Ignorer ».
//
// La persistance du dismiss est volontairement simple : un Set en
// mémoire de session (statique), pas de stockage disque (plan §9.2
// « persiste en sessionStorage » — il n'y a pas de sessionStorage en
// Flutter desktop ; la mémoire de session est l'équivalent v1).

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/core/models/recommendation.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/flavor/presentation/widgets/flavor_compatibility_heatmap.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:maestropesto/features/recommendations/data/recommender.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Dismiss en mémoire de session : ids de recettes ignorées (§9.2).
/// Exposé pour les tests.
final Set<String> dismissedRecommendationRecipeIds = <String>{};

/// Problème détecté sur un ingrédient (paire incompatible ou alerte
/// danger le mentionnant).
class RecommendationProblem {
  const RecommendationProblem({
    required this.ingredientId,
    required this.label,
    required this.explanation,
  });

  final String ingredientId;
  final String label;
  final String explanation;
}

/// Analyse pure de la recette : paires incompatibles + alertes danger,
/// réduite en liste de problèmes par ingrédient. Exposée pour les tests.
class RecommendationAnalysis {
  const RecommendationAnalysis({
    required this.incompatiblePairs,
    required this.dangerAlerts,
    required this.problems,
  });

  final List<FlavorMatch> incompatiblePairs;
  final List<FunctionalAlert> dangerAlerts;
  final List<RecommendationProblem> problems;

  bool get hasProblem =>
      incompatiblePairs.isNotEmpty || dangerAlerts.isNotEmpty;
}

/// Calcule l'analyse de la recette (déclencheur du sheet, §9.2) :
/// ≥ 1 paire < 0.40 OU ≥ 1 alerte danger.
Future<RecommendationAnalysis> analyzeRecipeProblems({
  required List<RecipeIngredient> ingredients,
  required FlavorRepository flavor,
  required FunctionalRepository functional,
}) async {
  final ids = <String>[];
  final labels = <String, String>{};
  for (final ingredient in ingredients) {
    final id = ingredient.ingredientId;
    if (id == null || id.isEmpty || labels.containsKey(id)) continue;
    ids.add(id);
    labels[id] = ingredient.label;
  }

  final pairs = await flavor.incompatiblePairs(ids);
  final alerts = (await functional.alertsFor(ids))
      .where((a) => a.severity == FunctionalSeverity.danger)
      .toList();

  final problems = <RecommendationProblem>[];
  final seen = <String>{};
  for (final pair in pairs) {
    for (final id in [pair.ingredientAId, pair.ingredientBId]) {
      if (id == null || !seen.add(id)) continue;
      final other = id == pair.ingredientAId
          ? pair.ingredientBId
          : pair.ingredientAId;
      problems.add(
        RecommendationProblem(
          ingredientId: id,
          label: labels[id] ?? id,
          explanation:
              '${labels[id] ?? id} × ${labels[other] ?? other} : '
              'score ${pair.overallScore.toStringAsFixed(2)}',
        ),
      );
    }
  }
  return RecommendationAnalysis(
    incompatiblePairs: pairs,
    dangerAlerts: alerts,
    problems: problems,
  );
}

/// Ouvre le bottom sheet de recommandation (§9.2).
Future<void> showRecommendationSheet(
  BuildContext context, {
  required List<RecipeIngredient> ingredients,
  AppDatabase? db,
  FlavorRepository? flavorRepository,
  FunctionalRepository? functionalRepository,
  IngredientCandidatesSource? ingredientsSource,
}) {
  final flavor = flavorRepository ?? (db != null ? FlavorRepository(db) : null);
  final functional =
      functionalRepository ?? (db != null ? FunctionalRepository(db) : null);
  final source =
      ingredientsSource ?? (db != null ? IngredientsRepository(db) : null);
  if (flavor == null || functional == null || source == null) {
    return Future.value();
  }
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => RecommendationSheet(
      ingredients: ingredients,
      flavor: flavor,
      functional: functional,
      ingredientsSource: source,
    ),
  );
}

class RecommendationSheet extends StatefulWidget {
  const RecommendationSheet({
    required this.ingredients,
    required this.flavor,
    required this.functional,
    required this.ingredientsSource,
    this.onIgnore,
    super.key,
  });

  final List<RecipeIngredient> ingredients;
  final FlavorRepository flavor;
  final FunctionalRepository functional;
  final IngredientCandidatesSource ingredientsSource;

  /// Callback « Ignorer » (tests + persistance session côté appelant).
  final VoidCallback? onIgnore;

  @override
  State<RecommendationSheet> createState() => _RecommendationSheetState();
}

class _RecommendationSheetState extends State<RecommendationSheet> {
  late final Future<RecommendationAnalysis> _analysisFuture;
  String? _selectedIngredientId;

  @override
  void initState() {
    super.initState();
    _analysisFuture = analyzeRecipeProblems(
      ingredients: widget.ingredients,
      flavor: widget.flavor,
      functional: widget.functional,
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
      child: FutureBuilder<RecommendationAnalysis>(
        future: _analysisFuture,
        builder: (context, snapshot) {
          final analysis = snapshot.data;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.warning_amber_outlined,
                    color: functionalSeverityColorFallback(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      strings.recommendationSheetTitle,
                      style: Theme.of(context).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                strings.recommendationSheetBody,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              if (analysis == null)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                for (final problem in analysis.problems)
                  _ProblemTile(
                    problem: problem,
                    selected: _selectedIngredientId == problem.ingredientId,
                    onTap: () => setState(
                      () => _selectedIngredientId = problem.ingredientId,
                    ),
                  ),
                for (final alert in analysis.dangerAlerts)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '⚠ ${alert.title}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                if (_selectedIngredientId != null)
                  _SubstitutesSection(
                    targetIngredientId: _selectedIngredientId!,
                    currentIngredientIds: [
                      for (final i in widget.ingredients)
                        if (i.ingredientId != null) i.ingredientId!,
                    ],
                    recommender: Recommender(
                      ingredients: widget.ingredientsSource,
                      flavor: widget.flavor,
                      functional: widget.functional,
                    ),
                  ),
              ],
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    widget.onIgnore?.call();
                    Navigator.of(context).maybePop();
                  },
                  child: Text(strings.recommendationIgnore),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Color functionalSeverityColorFallback(BuildContext context) =>
      Theme.of(context).colorScheme.error;
}

class _ProblemTile extends StatelessWidget {
  const _ProblemTile({
    required this.problem,
    required this.selected,
    required this.onTap,
  });

  final RecommendationProblem problem;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: selected
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: flavorCategoryColor(FlavorMatchCategory.avoid),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    problem.explanation,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SubstitutesSection extends StatelessWidget {
  const _SubstitutesSection({
    required this.targetIngredientId,
    required this.currentIngredientIds,
    required this.recommender,
  });

  final String targetIngredientId;
  final List<String> currentIngredientIds;
  final Recommender recommender;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return FutureBuilder<List<Recommendation>>(
      future: recommender.suggestSubstitutes(
        targetIngredientId: targetIngredientId,
        currentIngredientIds: currentIngredientIds,
      ),
      builder: (context, snapshot) {
        final recommendations = snapshot.data;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 24),
            Text(
              strings.recommendationSubstitutesFor(targetIngredientId),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (recommendations == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (recommendations.isEmpty)
              Text(
                strings.recommendationNoSubstitute,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final recommendation in recommendations)
                _SubstituteTile(recommendation: recommendation),
          ],
        );
      },
    );
  }
}

class _SubstituteTile extends StatelessWidget {
  const _SubstituteTile({required this.recommendation});

  final Recommendation recommendation;

  @override
  Widget build(BuildContext context) {
    final IngredientSummary suggested = recommendation.suggestedIngredient;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggested.canonicalNameFr,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  recommendation.reason,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
          Text(
            recommendation.score.toStringAsFixed(2),
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
