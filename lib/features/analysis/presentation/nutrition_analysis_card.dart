// Phase 10 Lots A, D, G — carte nutrition de la fiche recette.
//
// Nutrition calculée depuis les ingrédients liés ET le procédé
// (rendement, rétention, cuits mesurés), avec :
// - « non renseigné » quand aucune source ne documente un nutriment et
//   couverture partielle signalée (décision honest-data-display) ;
// - Nutri-Score estimé, % des apports de référence, allégations
//   indicatives, points clés, répartition de l'énergie ;
// - détail par ingrédient (masse crue → cuite, cuisson, mesure ou
//   estimation, approximations) et limites du calcul (ac-127).
// Sans donnée liée : valeur saisie manuellement, message honnête.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/core/scoring/nutrition_feedback.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/analysis/presentation/recipe_analysis_scope.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_nutrition_panel.dart';

class NutritionAnalysisCard extends StatelessWidget {
  const NutritionAnalysisCard({required this.recipe, super.key});

  final Recipe recipe;

  bool get _manualIsEmpty {
    final n = recipe.nutrition;
    return n.energyKcal == 0 &&
        n.proteins == 0 &&
        n.carbs == 0 &&
        n.fats == 0 &&
        n.fiber == 0 &&
        n.salt == 0;
  }

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final manual = RecipeNutritionPanel(nutrition: recipe.nutrition);
    // Saisie manuelle forcée par l'utilisateur : elle prime.
    if (recipe.nutritionMode == RecipeNutritionMode.manual) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [manual, _Note(strings.nutritionManualForced)],
      );
    }
    // Jamais de zéros fabriqués : sans calcul ni saisie, on l'explique.
    final fallback = _manualIsEmpty
        ? _NotComputedCard(message: strings.nutritionNotComputed)
        : manual;
    return RecipeAnalysisBuilder(
      placeholder: fallback,
      showLoading: true,
      builder: (context, analysis) {
        final agg = analysis.nutrition;
        if (!agg.hasData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              fallback,
              if (agg.resolvedCount > 0)
                _Note(strings.nutritionNoDataForLinked(agg.resolvedCount)),
            ],
          );
        }
        return _ComputedPanel(analysis: analysis);
      },
    );
  }
}

class _Note extends StatelessWidget {
  const _Note(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 6),
    child: Text(
      text,
      style: Theme.of(context).textTheme.bodySmall
          ?.copyWith(fontStyle: FontStyle.italic),
    ),
  );
}

class _NotComputedCard extends StatelessWidget {
  const _NotComputedCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.monitor_heart_outlined, size: 19),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.strings.nutrition,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(message, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _ComputedPanel extends StatelessWidget {
  const _ComputedPanel({required this.analysis});

  final RecipeAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final agg = analysis.nutrition;
    final fb = analysis.feedback;
    final p = agg.profilePerServing;
    final percents = <String, double>{
      for (final l in fb.intakes) l.key: l.percent,
      for (final l in fb.micronutrientIntakes) l.key: l.percent,
    };
    final subtitle = [
      strings.nutritionServingMass(agg.servingMassG.round()),
      if (agg.processApplied) strings.nutritionProcessApplied,
    ].join(' · ');
    return RecipeNutritionPanel(
      nutrition: NutritionSummary(
        energyKcal: p.energyKcal,
        proteins: p.proteins,
        carbs: p.carbs,
        fats: p.fats,
        fiber: p.fiber,
        salt: p.salt,
      ),
      computedFromIngredients: agg.withDataCount,
      totalIngredients: agg.totalCount,
      sources: agg.sources,
      alcoholPerServing: p.alcohol,
      micronutrientsPerServing: p.micronutrients,
      coverage: agg.nutrientCoverage,
      intakePercents: percents,
      nutriScore: fb.nutriScore,
      nutriScoreNote: fb.nutriScoreNote,
      subtitle: subtitle,
      footer: [
        _SugarSatLines(profile: p, coverage: agg.nutrientCoverage, fb: fb),
        if (fb.energySplit != null) _EnergySplitBar(split: fb.energySplit!),
        if (fb.highlights.isNotEmpty) _Highlights(items: fb.highlights),
        if (fb.claims.isNotEmpty) _Claims(claims: fb.claims),
        _Contributions(aggregation: agg, analysis: analysis),
        _Limits(aggregation: agg),
      ],
    );
  }
}

/// Sucres et AGS (sous-lignes des glucides et lipides).
class _SugarSatLines extends StatelessWidget {
  const _SugarSatLines({
    required this.profile,
    required this.coverage,
    required this.fb,
  });

  final NutritionProfile profile;
  final Map<MacroField, double> coverage;
  final NutritionFeedback fb;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Widget row(String label, double v, MacroField f, String key) {
      final cov = coverage[f] ?? 0;
      final pct = fb.intakes.where((l) => l.key == key).firstOrNull?.percent;
      return Padding(
        padding: const EdgeInsets.only(left: 12, top: 4),
        child: Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.bodySmall)),
            Text(
              cov == 0
                  ? context.strings.nutritionNotProvided
                  : '${v.toStringAsFixed(1)} g'
                        '${pct == null ? '' : '  (${pct.toStringAsFixed(0)} % AR)'}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        row('dont sucres', profile.sugars, MacroField.sugars, 'sugars'),
        row(
          'dont acides gras saturés',
          profile.saturatedFats,
          MacroField.saturatedFats,
          'saturatedFats',
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 18, bottom: 8),
    child: Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 16), const SizedBox(width: 6)],
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
      ],
    ),
  );
}

class _EnergySplitBar extends StatelessWidget {
  const _EnergySplitBar({required this.split});

  final EnergySplit split;

  @override
  Widget build(BuildContext context) {
    final parts = <(String, double, Color)>[
      ('Protéines', split.proteinPct, const Color(0xFF357A5B)),
      ('Glucides', split.carbsPct, const Color(0xFFD9A441)),
      ('Lipides', split.fatPct, const Color(0xFFB85C45)),
      if (split.alcoholPct > 0.5)
        ('Alcool', split.alcoholPct, const Color(0xFF7A5BA6)),
      if (split.fiberPct > 0.5) ('Fibres', split.fiberPct, Colors.brown),
    ];
    final style = Theme.of(context).textTheme.labelSmall;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          context.strings.nutritionEnergySplit,
          icon: Icons.pie_chart_outline,
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Row(
            children: [
              for (final (_, pct, color) in parts)
                if (pct > 0)
                  Expanded(
                    flex: (pct * 10).round().clamp(1, 1000),
                    child: Container(height: 12, color: color),
                  ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 10,
          runSpacing: 2,
          children: [
            for (final (label, pct, color) in parts)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: color),
                  const SizedBox(width: 4),
                  Text('$label ${pct.toStringAsFixed(0)} %', style: style),
                ],
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          'Repères ANSES : protéines 10–20 %, lipides 35–40 %, '
          'glucides 40–55 %.',
          style: style?.copyWith(fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

class _Highlights extends StatelessWidget {
  const _Highlights({required this.items});

  final List<NutritionHighlight> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          context.strings.nutritionHighlights,
          icon: Icons.lightbulb_outline,
        ),
        for (final h in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  h.positive
                      ? Icons.thumb_up_alt_outlined
                      : Icons.error_outline,
                  size: 15,
                  color: h.positive
                      ? const Color(0xFF357A5B)
                      : const Color(0xFFD97B41),
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(h.text, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}

class _Claims extends StatelessWidget {
  const _Claims({required this.claims});

  final List<NutritionClaim> claims;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(
          context.strings.nutritionClaims,
          icon: Icons.verified_outlined,
        ),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final c in claims)
              Tooltip(
                message: '${c.basis} — règlement (CE) 1924/2006',
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  avatar: const Icon(Icons.check, size: 14),
                  label: Text(c.label),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Contributions extends StatelessWidget {
  const _Contributions({required this.aggregation, required this.analysis});

  final NutritionAggregation aggregation;
  final RecipeAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final total =
        aggregation.profilePerServing.energyKcal * aggregation.servings;
    return Theme(
      data: theme.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        dense: true,
        title: Text(
          strings.nutritionPerContribution,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          strings.nutritionDishMass(
            aggregation.rawMassG.round(),
            aggregation.cookedMassG.round(),
          ),
          style: theme.textTheme.labelSmall,
        ),
        children: [
          for (final c in aggregation.contributions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          c.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Text(
                        c.rawGrams == null
                            ? '—'
                            : c.cookedGrams != null &&
                                  (c.cookedGrams! - c.rawGrams!).abs() > 0.5
                            ? '${c.rawGrams!.round()} → ${c.cookedGrams!.round()} g'
                            : '${c.rawGrams!.round()} g',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 64,
                        child: Text(
                          c.hasData
                              ? '${c.energyKcal.round()} kcal'
                                    '${total > 0 ? ' · ${(c.energyKcal / total * 100).round()} %' : ''}'
                              : '—',
                          textAlign: TextAlign.right,
                          style: theme.textTheme.labelSmall,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _detail(strings, c),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  static String _detail(AppStrings strings, IngredientContribution c) {
    final parts = <String>[];
    if (c.ingredientId == null) {
      parts.add(strings.nutritionUnlinked);
    } else if (!c.hasData) {
      parts.add(strings.nutritionNoData);
    }
    final m = c.method;
    if (m != null) {
      parts.add(
        '${m.labelFr}${c.methodInferred ? ' (déduit des étapes)' : ''}',
      );
      if (c.measuredCooked) {
        parts.add(strings.nutritionMeasuredCooked);
      } else if (c.factorApplied) {
        parts.add(strings.nutritionEstimatedCooked);
      }
    }
    if (c.alreadyCooked) parts.add(strings.nutritionAlreadyCooked);
    if (c.quantityAssumption != null) parts.add(c.quantityAssumption!);
    if (c.approximationNote != null) parts.add(c.approximationNote!);
    if (c.sourceFoodName != null && c.approximationNote == null) {
      parts.add('Ciqual : ${c.sourceFoodName}');
    }
    return parts.join(' · ');
  }
}

/// Limites du calcul (ac-127) : warnings de l'agrégateur, en clair.
class _Limits extends StatelessWidget {
  const _Limits({required this.aggregation});

  final NutritionAggregation aggregation;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final labels = {
      for (final c in aggregation.contributions)
        if (c.ingredientId != null) c.ingredientId!: c.label,
    };
    final lines = <String>[];
    var unlinked = 0;
    for (final w in aggregation.warnings) {
      final i = w.indexOf(':');
      final code = i == -1 ? w : w.substring(0, i);
      final id = i == -1 ? null : w.substring(i + 1);
      switch (code) {
        case 'unlinked_ingredient_skipped':
          unlinked++;
        case 'quantity_unparsed':
          lines.add(strings.nutritionWarningUnparsed(labels[id] ?? id ?? ''));
        case 'subrecipe_skipped':
          lines.add(strings.nutritionWarningSubrecipe);
        case 'profile_missing':
          lines.add('« ${labels[id] ?? id} » : ${strings.nutritionNoData}.');
        default:
          break;
      }
    }
    if (unlinked > 0) {
      lines.insert(0, strings.nutritionWarningUnlinked(unlinked));
    }
    for (final c in aggregation.contributions) {
      if (c.ingredientId != null && c.rawGrams != null && !c.hasData) {
        lines.add('« ${c.label} » : ${strings.nutritionNoData} en base.');
      }
    }
    if (lines.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.nutritionWarningsTitle, icon: Icons.rule),
        for (final l in lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text('• $l', style: theme.textTheme.bodySmall),
          ),
      ],
    );
  }
}
