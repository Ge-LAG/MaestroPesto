// Phase 10 Lots E & H — carte « Accords aromatiques » de la fiche.
//
// Harmonie globale, heatmap de toutes les paires liées (prédictions
// hachurées, accords étayés ✓), ponts aromatiques, arômes dominants
// pondérés par les masses, équilibre des saveurs et accords suggérés
// parmi les 603 ingrédients du référentiel.

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/formatters.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/flavor_analysis.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/features/analysis/presentation/recipe_analysis_scope.dart';
import 'package:maestropesto/features/flavor/presentation/widgets/flavor_compatibility_heatmap.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

class FlavorAnalysisCard extends StatelessWidget {
  const FlavorAnalysisCard({required this.recipe, required this.db, super.key});

  final Recipe recipe;
  final AppDatabase db;

  @override
  Widget build(BuildContext context) {
    return RecipeAnalysisBuilder(
      builder: (context, analysis) {
        final flavor = analysis.flavor;
        final suggestions = analysis.suggestions;
        if (flavor == null && suggestions.isEmpty) {
          return const SizedBox.shrink();
        }
        final labels = <String, String>{
          for (final i in recipe.ingredients)
            if (i.ingredientId != null) i.ingredientId!: i.label,
        };
        final theme = Theme.of(context);
        final strings = context.strings;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.local_florist_outlined, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.flavorHeatmapTitle,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                if (flavor != null) ...[
                  const SizedBox(height: 12),
                  _Harmony(analysis: flavor),
                  const SizedBox(height: 12),
                  FlavorCompatibilityHeatmap(
                    ingredients: recipe.ingredients,
                    db: db,
                    embedded: true,
                  ),
                  if (flavor.bridges.isNotEmpty)
                    _Bridges(bridges: flavor.bridges, labels: labels),
                  if (flavor.dominantAromas.isNotEmpty)
                    _Dominant(aromas: flavor.dominantAromas),
                  _TasteBalance(profile: flavor.tasteProfile),
                ],
                if (suggestions.isNotEmpty)
                  _Suggestions(suggestions: suggestions),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Title extends StatelessWidget {
  const _Title(this.text, {this.hint});

  final String text;
  final String? hint;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 6),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          style: Theme.of(context).textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w800),
        ),
        if (hint != null)
          Text(
            hint!,
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
      ],
    ),
  );
}

class _Harmony extends StatelessWidget {
  const _Harmony({required this.analysis});

  final RecipeFlavorAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    final score = analysis.harmony;
    final pseudo = FlavorMatch(
      ingredientAId: '',
      combinationSize: analysis.ingredientIds.length,
      overallScore: score,
      evidence: analysis.combination != null
          ? FlavorMatchEvidence.observed
          : analysis.supportedPairCount > 0
          ? FlavorMatchEvidence.curated
          : FlavorMatchEvidence.predicted,
    );
    final color = flavorMatchColor(pseudo);
    final supported = analysis.supportedPairCount;
    final total = analysis.pairs.length;
    return Row(
      children: [
        SizedBox(
          width: 52,
          height: 52,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CircularProgressIndicator(
                value: score.clamp(0, 1).toDouble(),
                strokeWidth: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
              Center(
                child: Text(
                  fmtNum(score, 2),
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${strings.flavorHarmony} : ${flavorMatchLabel(strings, pseudo)}',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                analysis.combination != null
                    ? strings.flavorEvidenceObserved
                    : '$supported / $total paires documentées '
                          '(les autres sont des prédictions)',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Bridges extends StatelessWidget {
  const _Bridges({required this.bridges, required this.labels});

  final List<FlavorBridge> bridges;
  final Map<String, String> labels;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(context.strings.flavorBridges),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final b in bridges.take(8))
              Tooltip(
                message: b.ingredientIds
                    .map((id) => labels[id] ?? id)
                    .join(', '),
                child: Chip(
                  visualDensity: VisualDensity.compact,
                  label: Text(
                    '${SensoryOntology.label(b.descriptor)} · '
                    '${b.ingredientIds.length}',
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _Dominant extends StatelessWidget {
  const _Dominant({required this.aromas});

  final List<MapEntry<String, double>> aromas;

  @override
  Widget build(BuildContext context) {
    final max = aromas.first.value;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(context.strings.flavorDominant),
        for (final a in aromas)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    SensoryOntology.label(a.key),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: max <= 0 ? 0 : a.value / max,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: const Color(0xFF7BAE5E),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _TasteBalance extends StatelessWidget {
  const _TasteBalance({required this.profile});

  final Map<String, double> profile;

  @override
  Widget build(BuildContext context) {
    const colors = {
      'sweet': Color(0xFFD9A441),
      'sour': Color(0xFF9BBF3B),
      'salty': Color(0xFF4A7BA6),
      'bitter': Color(0xFF6D5A4B),
      'umami': Color(0xFFB85C45),
      'fatty': Color(0xFFE0B36B),
    };
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(context.strings.flavorTasteBalance),
        for (final e in profile.entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 120,
                  child: Text(
                    SensoryOntology.label(e.key),
                    style: theme.textTheme.bodySmall,
                  ),
                ),
                Expanded(
                  child: LinearProgressIndicator(
                    value: e.value.clamp(0, 1).toDouble(),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                    color: colors[e.key],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Suggestions extends StatelessWidget {
  const _Suggestions({required this.suggestions});

  final List<FlavorSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Title(strings.flavorSuggestions, hint: strings.flavorSuggestionsHint),
        for (final s in suggestions)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  s.supportedPairs > 0
                      ? Icons.add_circle_outline
                      : Icons.auto_awesome_outlined,
                  size: 16,
                  color: const Color(0xFF357A5B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${s.name} — ${fmtNum(s.score, 2)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (s.reasons.isNotEmpty)
                        Text(
                          s.reasons.join(' · '),
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
