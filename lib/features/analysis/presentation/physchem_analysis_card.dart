// Phase 10 Lots C & F — carte « Analyse physico-chimique » (X-ray).
//
// Composition estimée du mélange, indicateurs (pH, aw, Brix, phase
// grasse), procédé détecté dans les étapes, règles Phase 4 évaluées
// (points de vigilance, comportements attendus, à vérifier) et notes
// expertes. Toutes les grandeurs sont des estimations signalées.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/scoring/physchem_estimator.dart';
import 'package:maestropesto/core/scoring/process_step_parser.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/analysis/presentation/recipe_analysis_scope.dart';
import 'package:maestropesto/features/functional/presentation/widgets/functional_alert_tile.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

class PhysChemAnalysisCard extends StatelessWidget {
  const PhysChemAnalysisCard({required this.recipe, super.key});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return RecipeAnalysisBuilder(
      builder: (context, analysis) {
        final s = analysis.physchem;
        if (s.totalMassG <= 0) return const SizedBox.shrink();
        final strings = context.strings;
        final theme = Theme.of(context);
        final labels = <String, String>{
          for (final i in recipe.ingredients)
            if (i.ingredientId != null) i.ingredientId!: i.label,
        };
        final warnings = analysis.alerts
            .where(
              (a) =>
                  a.severity == FunctionalSeverity.warning ||
                  a.severity == FunctionalSeverity.danger,
            )
            .toList();
        final expected = analysis.alerts
            .where((a) => a.severity == FunctionalSeverity.info)
            .toList();
        final toCheck = analysis.alerts
            .where((a) => a.severity == FunctionalSeverity.outOfDomain)
            .toList();
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
                        strings.physchemTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${strings.physchemCoverage((s.compositionCoverage * 100).round())}'
                  ' — ${strings.physchemEstimateNote}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                _Composition(state: s),
                _Indicators(state: s),
                _Process(steps: analysis.steps, recipe: recipe),
                if (warnings.isNotEmpty) ...[
                  _Title(strings.physchemRulesWarnings),
                  for (final a in warnings)
                    FunctionalAlertTile(alert: a, labels: labels),
                ],
                if (expected.isNotEmpty) ...[
                  _Title(strings.physchemRulesExpected),
                  for (final a in expected)
                    FunctionalAlertTile(alert: a, labels: labels),
                ],
                if (toCheck.isNotEmpty) ...[
                  _Title(strings.physchemRulesToCheck),
                  for (final a in toCheck)
                    FunctionalAlertTile(alert: a, labels: labels),
                ],
                if (analysis.alerts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      strings.physchemNoRule,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                if (analysis.insights.isNotEmpty)
                  _Insights(items: analysis.insights),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.labelLarge
          ?.copyWith(fontWeight: FontWeight.w800),
    ),
  );
}

String _n(double v, [int d = 1]) => v.toStringAsFixed(d).replaceAll('.', ',');

class _Composition extends StatelessWidget {
  const _Composition({required this.state});

  final PhysChemState state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final rows = <(String, double, Color)>[
      (strings.physchemWater, state.waterPct, const Color(0xFF4A7BA6)),
      (strings.physchemFat, state.fatPct, const Color(0xFFB85C45)),
      (strings.physchemProtein, state.proteinPct, const Color(0xFF357A5B)),
      (strings.physchemSugars, state.sugarPct, const Color(0xFFD9A441)),
      (strings.physchemStarch, state.starchPct, const Color(0xFFC8A26B)),
      (strings.physchemSalt, state.saltPct, const Color(0xFF8A8A8A)),
      if (state.alcoholPct > 0.05)
        (strings.physchemAlcohol, state.alcoholPct, const Color(0xFF7A5BA6)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(strings.physchemComposition),
        for (final (label, pct, color) in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 96,
                  child: Text(label, style: theme.textTheme.bodySmall),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (pct / 100).clamp(0, 1).toDouble(),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: color,
                  ),
                ),
                SizedBox(
                  width: 56,
                  child: Text(
                    '${_n(pct)} %',
                    textAlign: TextAlign.right,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
            ),
          ),
        Text(
          '${strings.physchemDryMatter} : ${_n(state.dryMatterPct, 0)} %'
          '${state.evaporatedG >= 1 ? ' · ≈ ${_n(state.evaporatedG, 0)} g d’eau évaporée à la cuisson' : ''}',
          style: theme.textTheme.labelSmall,
        ),
      ],
    );
  }
}

class _Indicators extends StatelessWidget {
  const _Indicators({required this.state});

  final PhysChemState state;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final items = <(String, String, String?)>[
      if (state.ph != null)
        (
          strings.physchemPh,
          _n(state.ph!),
          state.ph! < 4.6
              ? 'milieu acide (< 4,6) : défavorable aux pathogènes'
              : null,
        ),
      if (state.aw != null)
        (
          strings.physchemAw,
          _n(state.aw!, 2),
          state.aw! > 0.86
              ? 'périssable (> 0,86)'
              : state.aw! < 0.6
              ? 'produit sec (< 0,6)'
              : 'semi-humide',
        ),
      if (state.brix != null && state.sugarPct >= 1)
        (strings.physchemBrix, '${_n(state.brix!, 0)} %', null),
      if (state.oilPhaseFraction != null)
        (
          strings.physchemOilPhase,
          '${_n(state.oilPhaseFraction! * 100, 0)} %',
          null,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(strings.physchemIndicators),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final (label, value, note) in items)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.labelSmall),
                    Text(
                      value,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    if (note != null)
                      Text(
                        note,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Process extends StatelessWidget {
  const _Process({required this.steps, required this.recipe});

  final List<ParsedStep> steps;
  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final recognized = steps.where((s) => s.operations.isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(strings.physchemProcess),
        if (recognized.isEmpty)
          Text(strings.physchemNoStep, style: theme.textTheme.bodySmall)
        else
          for (final s in recognized)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: s.isThermal
                        ? const Color(0xFFD97B41)
                        : s.isCooling
                        ? const Color(0xFF4A7BA6)
                        : theme.colorScheme.surfaceContainerHighest,
                    child: Text(
                      '${s.index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: s.isThermal || s.isCooling ? Colors.white : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          [
                            [
                              s.primary!.labelFr,
                              for (final o in s.operations.skip(1))
                                if (o.shear || o.cooling) o.labelFr,
                            ].join(' + '),
                            if (s.temperatureC != null)
                              '${_n(s.temperatureC!, 0)} °C',
                            if (s.durationMin != null)
                              '${_n(s.durationMin!, 0)} min',
                          ].join(' · '),
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (s.mentionedIngredients.isNotEmpty)
                          Text(
                            s.mentionedIngredients
                                .where((i) => i < recipe.ingredients.length)
                                .map((i) => recipe.ingredients[i].label)
                                .join(', '),
                            style: theme.textTheme.labelSmall,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class _Insights extends StatelessWidget {
  const _Insights({required this.items});

  final List<ExpertInsight> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(context.strings.physchemInsights),
        for (final i in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  i.warning
                      ? Icons.warning_amber_outlined
                      : Icons.tips_and_updates_outlined,
                  size: 15,
                  color: i.warning
                      ? const Color(0xFFD9A441)
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(child: Text(i.text, style: theme.textTheme.bodySmall)),
              ],
            ),
          ),
      ],
    );
  }
}
