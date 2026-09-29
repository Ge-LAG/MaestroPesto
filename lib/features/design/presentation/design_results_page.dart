// Phase 11 Lots C-D — écran de comparaison des propositions.
//
// Trois cartes de variantes : tableau objectif visé / valeur obtenue
// (atteint, proche, manqué, non vérifiable), ingrédients et quantités,
// procédé cible et étapes rédigées, harmonie (accords documentés
// distingués des prédits), alertes de sécurité et allergènes, étiquette
// Pure Innovation. « Ouvrir dans l'éditeur » renvoie la variante choisie.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/app/widgets/info_hint.dart';
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_dataset.dart';
import 'package:maestropesto/core/design/design_engine.dart';
import 'package:maestropesto/core/design/design_metrics.dart';
import 'package:maestropesto/core/design/design_scoring.dart';
import 'package:maestropesto/core/models/allergens.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/models/process_models.dart';
import 'package:maestropesto/features/design/presentation/design_wizard_page.dart'
    show InnovationBanner;
import 'package:maestropesto/features/functional/presentation/widgets/functional_alert_tile.dart';

class DesignResultsPage extends StatelessWidget {
  const DesignResultsPage({
    required this.brief,
    required this.result,
    required this.dataset,
    super.key,
  });

  final DesignBrief brief;
  final Future<DesignResult> result;
  final Future<DesignDataset> dataset;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          strings.designResultsTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: FutureBuilder<(DesignResult, DesignDataset)>(
        future: Future.wait([result, dataset])
            .then((r) => (r[0] as DesignResult, r[1] as DesignDataset)),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('${snapshot.error}'),
              ),
            );
          }
          final data = snapshot.data;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 12),
                  Text(strings.designComposing),
                ],
              ),
            );
          }
          final (res, ds) = data;
          return _Results(result: res, data: ds);
        },
      ),
    );
  }
}

class _Results extends StatelessWidget {
  const _Results({required this.result, required this.data});

  final DesignResult result;
  final DesignDataset data;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final innovation = result.brief.mode == DesignMode.pureInnovation;
    return Column(
      children: [
        if (innovation) const InnovationBanner(),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1100
                  ? 3
                  : width >= 720
                  ? 2
                  : 1;
              final cards = [
                for (final v in result.variants)
                  _VariantCard(variant: v, data: data),
              ];
              return ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Text(strings.designResultsIntro),
                  const SizedBox(height: 8),
                  for (final n in result.notices)
                    Card(
                      color: context.palette.warnSurface,
                      child: ListTile(
                        leading: Icon(
                          Icons.info_outline,
                          color: context.palette.warn,
                        ),
                        title: Text(n),
                      ),
                    ),
                  if (result.variants.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(child: Text(strings.designNoResult)),
                    ),
                  if (columns == 1)
                    ...cards
                  else
                    for (var i = 0; i < cards.length; i += columns)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var j = i; j < i + columns; j++)
                            Expanded(
                              child: j < cards.length
                                  ? cards[j]
                                  : const SizedBox.shrink(),
                            ),
                        ],
                      ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _VariantCard extends StatelessWidget {
  const _VariantCard({required this.variant, required this.data});

  final DesignVariant variant;
  final DesignDataset data;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final palette = context.palette;
    final eval = variant.evaluation;
    final score = variant.score;
    final innovation = variant.mode == DesignMode.pureInnovation;
    final measure = eval.measure;
    final physchem = measure.physchem;
    final alerts = [
      for (final a in eval.alerts)
        if ((a.severity == FunctionalSeverity.warning ||
                a.severity == FunctionalSeverity.danger) &&
            a.status != RuleStatus.notMet)
          a,
    ];
    final labels = {
      for (final i in eval.ingredients)
        if (i.ingredientId != null) i.ingredientId!: i.label,
    };
    final temperature = physchem.maxTemperatureC;
    final minutes = physchem.heatingMinutes;
    final heading = theme.textTheme.titleSmall?.copyWith(
      fontWeight: FontWeight.w800,
    );
    return Card(
      key: ValueKey('design-variant-${variant.rank}'),
      margin: const EdgeInsets.all(6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              strings.designVariant(variant.rank),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              variant.title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            if (innovation)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    avatar: Icon(
                      Icons.science_outlined,
                      size: 16,
                      color: palette.warn,
                    ),
                    label: Text(strings.designInnovationTag),
                    backgroundColor: palette.warnSurface,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ),
            const SizedBox(height: 6),
            Text(
              strings.designMetCount(score.metCount, score.criteria.length),
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (measure.harmony != null)
              Text(
                '${strings.designHarmony} '
                '${measure.harmony!.toStringAsFixed(2).replaceAll('.', ',')}'
                ' — ${strings.designPairs(measure.supportedPairs, measure.pairCount - measure.supportedPairs)}',
                style: theme.textTheme.bodySmall,
              ),
            if (score.criteria.isNotEmpty) ...[
              const Divider(height: 20),
              for (final c in score.criteria) _CriterionRow(c, data: data),
            ],
            const Divider(height: 20),
            Text(strings.designIngredients, style: heading),
            const SizedBox(height: 4),
            for (final i in eval.ingredients)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(i.label)),
                    const SizedBox(width: 8),
                    Text(
                      i.quantity,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            const Divider(height: 20),
            Text(strings.designProcess, style: heading),
            const SizedBox(height: 4),
            Text(
              [
                variant.skeleton.process.method.labelFr,
                if (temperature != null)
                  strings.designTemperature(temperature.round()),
                if (minutes != null)
                  strings.designDurationMinutes(minutes.round()),
              ].join(' · '),
            ),
            ExpansionTile(
              tilePadding: EdgeInsets.zero,
              title: Text(strings.designSteps),
              children: [
                for (final (n, s) in eval.steps.indexed)
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 11,
                      child: Text(
                        '${n + 1}',
                        style: const TextStyle(fontSize: 11),
                      ),
                    ),
                    title: Text(s),
                  ),
              ],
            ),
            const Divider(height: 12),
            Text(strings.designAlerts, style: heading),
            const SizedBox(height: 4),
            if (alerts.isEmpty &&
                !eval.insights.any((i) => i.warning) &&
                eval.allergens.isEmpty)
              Text(strings.designNoAlert, style: theme.textTheme.bodySmall),
            for (final a in alerts)
              FunctionalAlertTile(alert: a, labels: labels),
            for (final insight in eval.insights)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      insight.warning
                          ? Icons.warning_amber_rounded
                          : Icons.lightbulb_outline,
                      size: 18,
                      color: insight.warning
                          ? palette.warn
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        insight.text,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            if (eval.allergens.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${strings.designAllergens} : '
                  '${(eval.allergens.keys.toList()..sort((a, b) => allergenRank(a).compareTo(allergenRank(b)))).map(allergenLabelFr).toSet().join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            const SizedBox(height: 12),
            FilledButton.icon(
              key: ValueKey('design-open-${variant.rank}'),
              onPressed: () => Navigator.of(context).pop(variant),
              icon: const Icon(Icons.edit_note),
              label: Text(strings.designOpenInEditor),
            ),
          ],
        ),
      ),
    );
  }
}

/// Ligne « objectif visé / valeur obtenue » d'un critère.
class _CriterionRow extends StatelessWidget {
  const _CriterionRow(this.c, {required this.data});

  final CriterionResult c;
  final DesignDataset data;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final palette = context.palette;
    final (icon, color, label) = switch (c.status) {
      CriterionStatus.met => (
        Icons.check_circle,
        palette.success,
        strings.designStatusMet,
      ),
      CriterionStatus.near => (
        Icons.adjust,
        palette.warn,
        strings.designStatusNear,
      ),
      CriterionStatus.missed => (
        Icons.cancel,
        theme.colorScheme.error,
        strings.designStatusMissed,
      ),
      CriterionStatus.unverifiable => (
        Icons.help_outline,
        palette.muted,
        strings.designStatusUnverifiable,
      ),
    };
    final status = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (c.status == CriterionStatus.unverifiable) ...[
          const SizedBox(width: 4),
          InfoHint(strings.designUnverifiableHelp, size: 14),
        ],
      ],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  c.metric.labelFr,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              status,
            ],
          ),
          Text(
            '${strings.designColTarget} : ${targetText(c.metric, c.target, data)}'
            '  ·  ${strings.designColObtained} : '
            '${c.status == CriterionStatus.unverifiable ? '—' : obtainedText(c, data)}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  /// Objectif visé, en clair.
  static String targetText(DesignMetric m, DesignTarget t, DesignDataset data) {
    String f(double v) => _format(m, v);
    return switch (t.kind) {
      TargetKind.value =>
        '≈ ${f(t.value!)} (± ${(t.tolerance * 100).round()} %)',
      TargetKind.min => '≥ ${f(t.min!)}',
      TargetKind.max => '≤ ${f(t.max!)}',
      TargetKind.range => '${f(t.min!)} – ${f(t.max!)}',
      TargetKind.choice => _choiceLabel(m, t.choice, data),
    };
  }

  static String obtainedText(CriterionResult c, DesignDataset data) {
    final m = c.metric;
    switch (m.id) {
      case 'pivot':
        final present = (c.choice ?? '').split('|').contains(c.target.choice);
        return present ? 'présent' : 'absent';
      case 'nutriscore':
      case 'cooking_method':
      case 'dominant_family':
        return _choiceLabel(m, c.choice, data);
    }
    final v = c.value;
    return v == null ? '—' : _format(m, v);
  }

  static String _format(DesignMetric m, double v) =>
      m.id == 'documented_share' ? '${v.round()} %' : m.format(v);

  static String _choiceLabel(
    DesignMetric m,
    String? choice,
    DesignDataset data,
  ) {
    if (choice == null) return '—';
    return switch (m.id) {
      'cooking_method' => CookingMethod.fromId(choice)?.labelFr ?? choice,
      'dominant_family' => SensoryOntology.label(choice),
      'pivot' => data[choice]?.label ?? choice,
      _ => choice,
    };
  }
}
