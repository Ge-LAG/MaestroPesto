// Fiche recette (refonte UX 2026-09-26).
//
// En tête : titre, portions ajustables (quantités recalculées), puis
// une synthèse (énergie, Nutri-Score, harmonie, points d'attention) et
// les allergènes de la recette. Ensuite la liste d'ingrédients compacte
// (fiche de l'ingrédient au clic) et la préparation, puis les analyses
// détaillées en onglets : Nutrition, Arômes, Procédé.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/i18n/formatters.dart';
import 'package:maestropesto/app/widgets/info_hint.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/allergens.dart';
import 'package:maestropesto/core/models/flavor_analysis.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/models/ingredient_detail.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/nutrition_feedback.dart';
import 'package:maestropesto/core/scoring/quantity_scaler.dart';
import 'package:maestropesto/features/analysis/data/metier_reference.dart';
import 'package:maestropesto/features/analysis/presentation/flavor_analysis_card.dart';
import 'package:maestropesto/features/analysis/presentation/nutrition_analysis_card.dart';
import 'package:maestropesto/features/analysis/presentation/physchem_analysis_card.dart';
import 'package:maestropesto/features/analysis/presentation/recipe_analysis_scope.dart';
import 'package:maestropesto/features/flavor/presentation/widgets/flavor_compatibility_heatmap.dart';
import 'package:maestropesto/features/ingredients/data/ingredient_mapping.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:maestropesto/features/ingredients/presentation/ingredient_detail_card.dart';
import 'package:maestropesto/features/nutrition/data/nutrition_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_metier_advisory_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_nutrition_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_photo.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_tag_label.dart';

/// Onglets d'analyse de la fiche.
enum RecipeAnalysisTab { nutrition, flavor, process }

class RecipeDetailView extends StatefulWidget {
  const RecipeDetailView({
    required this.recipe,
    required this.isWide,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.scrollable = true,
    this.db,
    this.onAddIngredient,
    super.key,
  });

  final Recipe recipe;
  final bool isWide;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDuplicate;
  final ValueChanged<Recipe> onDelete;
  final bool scrollable;

  /// Optional Drift database. When provided, the metier analyses
  /// (synthesis, allergens, tabs) are enabled. When null, only the
  /// stored nutrition is shown.
  final AppDatabase? db;

  /// Ajout d'un ingrédient suggéré (accords aromatiques) : ouvre
  /// l'éditeur avec la nouvelle ligne. Null = bouton masqué.
  final ValueChanged<RecipeIngredient>? onAddIngredient;

  @override
  State<RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<RecipeDetailView> {
  /// Onglet mémorisé d'une fiche à l'autre (session).
  static RecipeAnalysisTab _lastTab = RecipeAnalysisTab.nutrition;

  late int _servings = widget.recipe.servings;
  RecipeAnalysisTab _tab = _lastTab;
  final _tabsKey = GlobalKey();

  double get _factor =>
      widget.recipe.servings <= 0 ? 1 : _servings / widget.recipe.servings;

  void _openTab(RecipeAnalysisTab tab, {bool reveal = false}) {
    setState(() {
      _tab = tab;
      _lastTab = tab;
    });
    if (!reveal) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _tabsKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final db = widget.db;
    final strings = context.strings;

    final overview = _RecipeOverviewPanel(
      recipe: recipe,
      servings: _servings,
      onServings: (v) => setState(() => _servings = v),
      onEdit: widget.onEdit,
      onDuplicate: widget.onDuplicate,
      onDelete: widget.onDelete,
    );
    final ingredients = _IngredientsPanel(
      recipe: recipe,
      db: db,
      factor: _factor,
      servings: _servings,
    );
    final preparation = _SectionPanel(
      title: strings.preparation,
      icon: Icons.checklist,
      child: Column(
        children: [
          for (var index = 0; index < recipe.steps.length; index++)
            _StepRow(index: index + 1, text: recipe.steps[index]),
        ],
      ),
    );

    final Widget analyses = db == null
        ? NutritionAnalysisCard(recipe: recipe)
        : _AnalysisTabs(
            key: _tabsKey,
            recipe: recipe,
            db: db,
            tab: _tab,
            onTab: _openTab,
            onAddSuggestion: widget.onAddIngredient == null
                ? null
                : (s) => widget.onAddIngredient!(
                    RecipeIngredient(
                      label: s.name,
                      quantity: '',
                      source: IngredientSource.ciqual,
                      ingredientId: s.ingredientId,
                    ),
                  ),
          );

    final body = Padding(
      padding: EdgeInsets.all(widget.isWide ? 32 : 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            overview,
            if (db != null) ...[
              const SizedBox(height: 18),
              _SynthesisPanel(
                recipe: recipe,
                servings: _servings,
                onOpenTab: (t) => _openTab(t, reveal: true),
              ),
            ],
            const SizedBox(height: 18),
            LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth >= 900) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: ingredients),
                      const SizedBox(width: 18),
                      Expanded(flex: 6, child: preparation),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ingredients,
                    const SizedBox(height: 18),
                    preparation,
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            analyses,
          ],
        ),
      ),
    );

    return RecipeAnalysisScope(
      recipe: recipe,
      db: db,
      child: ColoredBox(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: widget.scrollable ? SingleChildScrollView(child: body) : body,
      ),
    );
  }
}

// ---------------------------------------------------------------------
// En-tête

class _RecipeOverviewPanel extends StatelessWidget {
  const _RecipeOverviewPanel({
    required this.recipe,
    required this.servings,
    required this.onServings,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Recipe recipe;
  final int servings;
  final ValueChanged<int> onServings;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDuplicate;
  final ValueChanged<Recipe> onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RecipeToolbar(
              recipe: recipe,
              onEdit: onEdit,
              onDuplicate: onDuplicate,
              onDelete: onDelete,
            ),
            if (recipe.images.isNotEmpty) ...[
              const SizedBox(height: 18),
              _RecipeImageGallery(recipe: recipe),
              const SizedBox(height: 20),
            ] else
              const SizedBox(height: 18),
            Text(
              recipe.title,
              style: Theme.of(context).textTheme.displaySmall
                  ?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0),
            ),
            if (recipe.description.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Text(
                  recipe.description,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _ServingsStepper(
                  value: servings,
                  original: recipe.servings,
                  onChanged: onServings,
                ),
                _MetricPill(
                  icon: Icons.timer_outlined,
                  label: '${recipe.totalMinutes} min',
                ),
                _MetricPill(
                  icon: Icons.format_list_bulleted,
                  label: context.strings.ingredientCount(
                    recipe.ingredients.length,
                  ),
                ),
                _MetricPill(
                  icon: Icons.checklist,
                  label: context.strings.stepCount(recipe.steps.length),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Portions ajustables : les quantités affichées sont recalculées.
class _ServingsStepper extends StatelessWidget {
  const _ServingsStepper({
    required this.value,
    required this.original,
    required this.onChanged,
  });

  final int value;
  final int original;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final changed = value != original;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            color: changed
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
                : theme.colorScheme.surface,
            border: Border.all(
              color: changed
                  ? theme.colorScheme.primary
                  : const Color(0xFFE0DED7),
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  tooltip: strings.servingsDecrease,
                  onPressed: value > 1 ? () => onChanged(value - 1) : null,
                  icon: const Icon(Icons.remove),
                ),
                const Icon(Icons.people_alt_outlined, size: 18),
                const SizedBox(width: 6),
                Text(
                  '$value portion${value > 1 ? 's' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  iconSize: 18,
                  tooltip: strings.servingsIncrease,
                  onPressed: value < 99 ? () => onChanged(value + 1) : null,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ),
        if (changed) ...[
          const SizedBox(width: 6),
          TextButton.icon(
            onPressed: () => onChanged(original),
            icon: const Icon(Icons.undo, size: 16),
            label: Text('${strings.servingsReset} ($original)'),
          ),
        ],
      ],
    );
  }
}

class _RecipeImageGallery extends StatelessWidget {
  const _RecipeImageGallery({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recipe.images.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final image = recipe.images[index];
          return SizedBox(
            width: index == 0 ? 280 : 210,
            child: _RecipeImageTile(image: image),
          );
        },
      ),
    );
  }
}

class _RecipeImageTile extends StatelessWidget {
  const _RecipeImageTile({required this.image});

  final RecipeImage image;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            Positioned.fill(
              child: buildRecipePhoto(image.path, fit: BoxFit.cover),
            ),
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x99000000)],
                    stops: [0.46, 1],
                  ),
                ),
              ),
            ),
            if (image.label.trim().isNotEmpty)
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Text(
                  image.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecipeToolbar extends StatelessWidget {
  const _RecipeToolbar({
    required this.recipe,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final Recipe recipe;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDuplicate;
  final ValueChanged<Recipe> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final tags = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [for (final tag in recipe.tags) RecipeTagLabel(label: tag)],
        );
        final actions = Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.end,
          children: [
            IconButton.outlined(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(context.strings.exportPdfTodo)),
                );
              },
              icon: const Icon(Icons.picture_as_pdf_outlined),
              tooltip: context.strings.exportAction,
            ),
            IconButton.outlined(
              onPressed: () => onDelete(recipe),
              icon: const Icon(Icons.delete_outline),
              tooltip: context.strings.deleteAction,
            ),
            IconButton.outlined(
              onPressed: () => onDuplicate(recipe),
              icon: const Icon(Icons.content_copy_outlined),
              tooltip: context.strings.duplicateAction,
            ),
            FilledButton.icon(
              onPressed: () => onEdit(recipe),
              icon: const Icon(Icons.edit_outlined),
              label: Text(context.strings.editAction),
            ),
          ],
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              tags,
              const SizedBox(height: 14),
              Align(alignment: Alignment.centerLeft, child: actions),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: tags),
            const SizedBox(width: 16),
            actions,
          ],
        );
      },
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE0DED7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Synthèse et allergènes

class _SynthesisPanel extends StatelessWidget {
  const _SynthesisPanel({
    required this.recipe,
    required this.servings,
    required this.onOpenTab,
  });

  final Recipe recipe;
  final int servings;
  final ValueChanged<RecipeAnalysisTab> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return RecipeAnalysisBuilder(
      builder: (context, analysis) {
        final strings = context.strings;
        final theme = Theme.of(context);
        final agg = analysis.nutrition;
        final manual = recipe.nutritionMode == RecipeNutritionMode.manual;
        final kcal = manual
            ? recipe.nutrition.energyKcal
            : (agg.hasData ? agg.profilePerServing.energyKcal : null);
        final flavor = analysis.flavor;
        final attention = <(bool, String)>[
          for (final a in analysis.alerts)
            if (a.severity == FunctionalSeverity.warning ||
                a.severity == FunctionalSeverity.danger)
              (true, _short(a)),
          for (final i in analysis.insights)
            if (i.warning) (true, i.text),
          for (final a in analysis.alerts)
            if (a.severity == FunctionalSeverity.info) (false, _short(a)),
        ];

        final tiles = <Widget>[
          _SynthTile(
            icon: Icons.bolt_outlined,
            title: strings.energy,
            onTap: () => onOpenTab(RecipeAnalysisTab.nutrition),
            width: 210,
            child: kcal == null || kcal <= 0
                ? Text(
                    strings.synthesisNoNutrition,
                    style: theme.textTheme.bodySmall,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fmtNum(kcal, 0)} kcal',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        strings.synthesisPerServing,
                        style: theme.textTheme.labelSmall,
                      ),
                      Text(
                        strings.synthesisTotal(
                          fmtNum(kcal * servings, 0),
                          servings,
                        ),
                        style: theme.textTheme.labelSmall,
                      ),
                    ],
                  ),
          ),
          if (!manual)
            _SynthTile(
              icon: Icons.health_and_safety_outlined,
              title: strings.nutriScoreTitle,
              onTap: () => onOpenTab(RecipeAnalysisTab.nutrition),
              width: 230,
              child: _NutriScoreLetters(
                result: analysis.feedback.nutriScore,
                note: analysis.feedback.nutriScoreNote,
              ),
            ),
          if (flavor != null)
            _SynthTile(
              icon: Icons.local_florist_outlined,
              title: strings.flavorHarmony,
              onTap: () => onOpenTab(RecipeAnalysisTab.flavor),
              width: 210,
              child: _HarmonyBadge(harmony: flavor.harmony),
            ),
          _SynthTile(
            icon: Icons.science_outlined,
            title: strings.synthesisAttention,
            onTap: () => onOpenTab(RecipeAnalysisTab.process),
            width: 340,
            child: attention.isEmpty
                ? Text(
                    strings.synthesisNothing,
                    style: theme.textTheme.bodySmall,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (warning, text) in attention.take(3))
                        Padding(
                          padding: const EdgeInsets.only(bottom: 3),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                warning
                                    ? Icons.warning_amber_rounded
                                    : Icons.info_outline,
                                size: 15,
                                color: warning
                                    ? const Color(0xFFD97B41)
                                    : theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  text,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (attention.length > 3)
                        Text(
                          '+ ${attention.length - 3}',
                          style: theme.textTheme.labelSmall,
                        ),
                    ],
                  ),
          ),
        ];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights_outlined, size: 19),
                    const SizedBox(width: 8),
                    Text(
                      strings.synthesisTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: tiles),
                const SizedBox(height: 14),
                _AllergenBanner(recipe: recipe, allergens: analysis.allergens),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Intitulé court d'une règle (« Denrée périssable », « Réaction de
  /// Maillard »…).
  static String _short(FunctionalAlert a) {
    final text = (a.expectedOutcome ?? a.title).trim();
    final colon = text.indexOf(' : ');
    final head = colon > 8 ? text.substring(0, colon) : text;
    return head.length > 90 ? '${head.substring(0, 87)}…' : head;
  }
}

class _SynthTile extends StatelessWidget {
  const _SynthTile({
    required this.icon,
    required this.title,
    required this.child,
    required this.onTap,
    required this.width,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: 180, maxWidth: width),
      child: Material(
        color: theme.colorScheme.surfaceContainerLowest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xFFE0DED7)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Lettres A–E du Nutri-Score, la note estimée en évidence.
class _NutriScoreLetters extends StatelessWidget {
  const _NutriScoreLetters({required this.result, this.note});

  final NutriScoreResult? result;
  final String? note;

  @override
  Widget build(BuildContext context) {
    final r = result;
    if (r == null) {
      return Text(
        note ?? context.strings.synthesisNoNutrition,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final g in const ['A', 'B', 'C', 'D', 'E'])
          Container(
            width: g == r.grade ? 32 : 24,
            height: g == r.grade ? 32 : 24,
            margin: const EdgeInsets.only(right: 3),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: g == r.grade
                  ? NutriScoreBadge.colors[g]
                  : NutriScoreBadge.colors[g]!.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              g,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: g == r.grade ? 17 : 12,
              ),
            ),
          ),
      ],
    );
  }
}

class _HarmonyBadge extends StatelessWidget {
  const _HarmonyBadge({required this.harmony});

  final double harmony;

  @override
  Widget build(BuildContext context) {
    final match = FlavorMatch(
      ingredientAId: '',
      combinationSize: 2,
      overallScore: harmony,
    );
    final color = flavorMatchColor(match);
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 40,
          height: 40,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: harmony.clamp(0, 1).toDouble(),
                strokeWidth: 5,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
              Center(
                child: Text(
                  fmtNum(harmony, 2),
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            flavorMatchLabel(context.strings, match),
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

/// Allergènes à déclaration obligatoire présents dans la recette.
class _AllergenBanner extends StatelessWidget {
  const _AllergenBanner({required this.recipe, required this.allergens});

  final Recipe recipe;
  final Map<String, List<int>> allergens;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final unlinked = recipe.ingredients
        .where((i) => i.ingredientId == null && i.label.trim().isNotEmpty)
        .length;
    final tags = allergens.keys.toList()
      ..sort((a, b) => allergenRank(a).compareTo(allergenRank(b)));
    final present = tags.isNotEmpty;
    const warn = Color(0xFFB85C45);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: present
            ? const Color(0xFFFBEDE6)
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: present ? Border.all(color: warn.withValues(alpha: 0.5)) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            present ? Icons.warning_amber_rounded : Icons.check_circle_outline,
            size: 18,
            color: present ? warn : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (present) ...[
                      Text(
                        '${strings.allergensContains} :',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: warn,
                        ),
                      ),
                      for (final (k, tag) in tags.indexed)
                        Tooltip(
                          message: [
                            for (final i in allergens[tag]!)
                              if (i < recipe.ingredients.length)
                                recipe.ingredients[i].label,
                          ].join(', '),
                          child: Text(
                            '${allergenLabelFr(tag)}${k < tags.length - 1 ? ',' : ''}',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: warn,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dotted,
                            ),
                          ),
                        ),
                    ] else
                      Text(
                        strings.allergensNone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    InfoHint(strings.allergensHint, size: 14),
                  ],
                ),
                if (unlinked > 0)
                  Text(
                    strings.allergensUnlinked(unlinked),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Ingrédients et préparation

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}

class _IngredientsPanel extends StatelessWidget {
  const _IngredientsPanel({
    required this.recipe,
    required this.db,
    required this.factor,
    required this.servings,
  });

  final Recipe recipe;
  final AppDatabase? db;
  final double factor;
  final int servings;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    Widget rows(Map<int, List<String>> allergensByLine) => Column(
      children: [
        for (var i = 0; i < recipe.ingredients.length; i++)
          _IngredientRow(
            ingredient: recipe.ingredients[i],
            quantity: QuantityScaler.scale(
              recipe.ingredients[i].quantity,
              factor,
            ),
            allergens: allergensByLine[i] ?? const [],
            db: db,
            last: i == recipe.ingredients.length - 1,
          ),
      ],
    );
    return _SectionPanel(
      title: strings.ingredients,
      icon: Icons.format_list_bulleted,
      subtitle: servings == recipe.servings
          ? null
          : strings.servingsScaledNote(servings, recipe.servings),
      child: db == null
          ? rows(const {})
          : RecipeAnalysisBuilder(
              placeholder: rows(const {}),
              builder: (context, analysis) {
                final byLine = <int, List<String>>{};
                analysis.allergens.forEach((tag, lines) {
                  for (final l in lines) {
                    byLine.putIfAbsent(l, () => []).add(tag);
                  }
                });
                return rows(byLine);
              },
            ),
    );
  }
}

/// Ligne d'ingrédient compacte ; la fiche de l'ingrédient (catégorie,
/// allergènes, nutrition pour 100 g) se déplie au clic.
class _IngredientRow extends StatefulWidget {
  const _IngredientRow({
    required this.ingredient,
    required this.quantity,
    required this.allergens,
    required this.last,
    this.db,
  });

  final RecipeIngredient ingredient;
  final String quantity;
  final List<String> allergens;
  final bool last;
  final AppDatabase? db;

  @override
  State<_IngredientRow> createState() => _IngredientRowState();
}

class _IngredientRowState extends State<_IngredientRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
    final ingredient = widget.ingredient;
    final db = widget.db;
    final linked = ingredient.ingredientId != null;
    final expandable = db != null && linked;
    final allergens = [...widget.allergens]
      ..sort((a, b) => allergenRank(a).compareTo(allergenRank(b)));

    final quantity = Text(
      widget.quantity.trim().isEmpty ? '—' : widget.quantity,
      style: const TextStyle(fontWeight: FontWeight.w900),
    );
    final label = Text(ingredient.label);
    final badges = [
      for (final a in allergens)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFB85C45)),
          ),
          child: Text(
            allergenLabelFr(a),
            style: theme.textTheme.labelSmall?.copyWith(
              color: const Color(0xFFB85C45),
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      if (!linked)
        Tooltip(
          message: strings.ingredientUnlinkedHint,
          child: Icon(
            Icons.link_off,
            size: 16,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
    ];

    final row = InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: expandable ? () => setState(() => _expanded = !_expanded) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trailing = expandable
                ? Tooltip(
                    message: strings.ingredientDetailShow,
                    child: Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  )
                : const SizedBox(width: 20);
            if (constraints.maxWidth < 380) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        quantity,
                        label,
                        if (badges.isNotEmpty)
                          Wrap(spacing: 4, runSpacing: 4, children: badges),
                      ],
                    ),
                  ),
                  trailing,
                ],
              );
            }
            return Row(
              children: [
                SizedBox(width: 110, child: quantity),
                Expanded(
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [label, ...badges],
                  ),
                ),
                trailing,
              ],
            );
          },
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (_expanded && db != null && linked)
          Padding(
            padding: const EdgeInsets.only(left: 8, bottom: 8),
            child: _IngredientMetierDetail(
              db: db,
              ingredientId: ingredient.ingredientId!,
            ),
          ),
        if (!widget.last) const Divider(height: 1),
      ],
    );
  }
}

/// Résout le détail Phase 1 + nutrition d'un ingrédient lié et rend une
/// [IngredientDetailCard]. Rien pendant le chargement ou si l'ingrédient
/// n'est pas dans le référentiel (fallback gracieux).
class _IngredientMetierDetail extends StatefulWidget {
  const _IngredientMetierDetail({required this.db, required this.ingredientId});

  final AppDatabase db;
  final String ingredientId;

  @override
  State<_IngredientMetierDetail> createState() =>
      _IngredientMetierDetailState();
}

class _IngredientMetierDetailState extends State<_IngredientMetierDetail> {
  late final Future<
    ({
      IngredientDetail? detail,
      NutritionProfile? nutrition,
      List<String> culinary,
    })
  >
  _future = _load();

  Future<
    ({
      IngredientDetail? detail,
      NutritionProfile? nutrition,
      List<String> culinary,
    })
  >
  _load() async {
    final row = await IngredientsRepository(widget.db)
        .getById(widget.ingredientId);
    if (row == null) {
      return (detail: null, nutrition: null, culinary: const <String>[]);
    }
    final culinaryRow =
        await (widget.db.select(widget.db.ingredientCulinary)
              ..where((t) => t.ingredientId.equals(widget.ingredientId)))
            .getSingleOrNull();
    final allergens = await IngredientsRepository(widget.db)
        .enrichedAllergensFor(widget.ingredientId);
    final nutrition = await NutritionRepository(widget.db)
        .forIngredient(widget.ingredientId);
    final detail = IngredientMapping.toDetail(row);
    return (
      detail: allergens == null
          ? detail
          : detail.copyWith(allergenTags: allergens),
      nutrition: nutrition,
      culinary: culinaryLinesOf(culinaryRow),
    );
  }

  /// Lignes « pH / densité / masses unitaires » avec leur source.
  static List<String> culinaryLinesOf(IngredientCulinaryData? row) {
    if (row == null) return const [];
    const unitLabels = {
      'piece': 'pièce',
      'gousse': 'gousse',
      'brin': 'brin ou branche',
      'feuille': 'feuille',
      'tranche': 'tranche',
      'botte': 'botte',
      'sachet': 'sachet',
      'noix': 'noix',
    };
    final sources = IngredientReference.unitSourcesOf(row.densityNote);
    final lines = <String>[];
    final ph = row.ph;
    if (ph != null) {
      final note = row.phNote ?? '';
      lines.add(
        'pH ${fmtNum(ph, 1)} — '
        '${note.startsWith('FDA') ? note : 'estimation par catégorie'}',
      );
    }
    final density = row.densityGPerMl;
    if (density != null) {
      lines.add(
        'Densité ${fmtNum(density, 2)} g/ml'
        ' (${sources['densite'] ?? 'estimation'})',
      );
    }
    for (final pair in (row.unitMasses ?? '').split('|')) {
      final kv = pair.split(':');
      if (kv.length != 2) continue;
      final grams = double.tryParse(kv[1]);
      if (grams == null) continue;
      lines.add(
        '1 ${unitLabels[kv[0]] ?? kv[0]} ≈ ${fmtCompact(grams)} g'
        ' (${sources[kv[0]] ?? 'estimation'})',
      );
    }
    return lines;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({
        IngredientDetail? detail,
        NutritionProfile? nutrition,
        List<String> culinary,
      })
    >(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data;
        final detail = data?.detail;
        if (detail == null) {
          return const SizedBox.shrink();
        }
        return IngredientDetailCard(
          detail: detail,
          nutrition: data?.nutrition,
          culinaryLines: data?.culinary ?? const [],
        );
      },
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Text(
              '$index',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimaryContainer,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Analyses en onglets

class _AnalysisTabs extends StatefulWidget {
  const _AnalysisTabs({
    required this.recipe,
    required this.db,
    required this.tab,
    required this.onTab,
    this.onAddSuggestion,
    super.key,
  });

  final Recipe recipe;
  final AppDatabase db;
  final RecipeAnalysisTab tab;
  final ValueChanged<RecipeAnalysisTab> onTab;
  final ValueChanged<FlavorSuggestion>? onAddSuggestion;

  @override
  State<_AnalysisTabs> createState() => _AnalysisTabsState();
}

class _AnalysisTabsState extends State<_AnalysisTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _controller = TabController(
    length: RecipeAnalysisTab.values.length,
    vsync: this,
    initialIndex: widget.tab.index,
  );

  @override
  void didUpdateWidget(covariant _AnalysisTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.index != widget.tab.index) {
      _controller.animateTo(widget.tab.index);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final recipe = widget.recipe;
    final content = switch (widget.tab) {
      RecipeAnalysisTab.nutrition => NutritionAnalysisCard(
        recipe: recipe,
        embedded: true,
      ),
      RecipeAnalysisTab.flavor => _FlavorTab(
        recipe: recipe,
        db: widget.db,
        onAddSuggestion: widget.onAddSuggestion,
      ),
      RecipeAnalysisTab.process => PhysChemAnalysisCard(
        recipe: recipe,
        embedded: true,
        header: RecipeMetierAdvisoryPanel(recipe: recipe, db: widget.db),
      ),
    };
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TabBar(
            controller: _controller,
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            onTap: (i) => widget.onTab(RecipeAnalysisTab.values[i]),
            tabs: [
              Tab(
                icon: const Icon(Icons.monitor_heart_outlined, size: 18),
                iconMargin: const EdgeInsets.only(bottom: 2),
                text: strings.tabNutrition,
              ),
              Tab(
                icon: const Icon(Icons.local_florist_outlined, size: 18),
                iconMargin: const EdgeInsets.only(bottom: 2),
                text: strings.tabFlavor,
              ),
              Tab(
                icon: const Icon(Icons.science_outlined, size: 18),
                iconMargin: const EdgeInsets.only(bottom: 2),
                text: strings.tabProcess,
              ),
            ],
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(20), child: content),
        ],
      ),
    );
  }
}

class _FlavorTab extends StatelessWidget {
  const _FlavorTab({
    required this.recipe,
    required this.db,
    this.onAddSuggestion,
  });

  final Recipe recipe;
  final AppDatabase db;
  final ValueChanged<FlavorSuggestion>? onAddSuggestion;

  @override
  Widget build(BuildContext context) {
    return RecipeAnalysisBuilder(
      showLoading: true,
      builder: (context, analysis) {
        if (analysis.flavor == null && analysis.suggestions.isEmpty) {
          return Text(
            context.strings.flavorNeedsTwo,
            style: Theme.of(context).textTheme.bodySmall,
          );
        }
        return FlavorAnalysisCard(
          recipe: recipe,
          db: db,
          embedded: true,
          onAddSuggestion: onAddSuggestion,
        );
      },
    );
  }
}
