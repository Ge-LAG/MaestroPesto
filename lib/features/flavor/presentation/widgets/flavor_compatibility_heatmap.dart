// Phase 09 Lot G / Phase 10 Lots E-H — FlavorCompatibilityHeatmap.
//
// Matrice N×N des ingrédients liés de la recette (jusqu'à 12), cellules
// colorées selon la catégorie d'accord. Phase 10 (ac-123, décision
// honest-data-display) :
// - une PRÉDICTION (profils sensoriels, sans accord documenté) est
//   hachurée et atténuée, et une prédiction basse s'affiche « Peu
//   probable (prédiction) », jamais « À éviter » ;
// - un accord étayé (observé Phase 3 ou curaté) porte un repère ✓ ;
// - le détail au tap donne l'origine, la confiance, les arômes partagés
//   et les sous-scores (similarité, équilibre, contexte, dominance).

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Nombre max d'ingrédients affichés dans la matrice.
const int kHeatmapMaxIngredients = 12;

/// Couleur associée à une catégorie de compatibilité.
Color flavorCategoryColor(FlavorMatchCategory category) {
  switch (category) {
    case FlavorMatchCategory.excellent:
      return const Color(0xFF357A5B); // vert
    case FlavorMatchCategory.good:
      return const Color(0xFF7BAE5E); // vert clair
    case FlavorMatchCategory.average:
      return const Color(0xFFD9A441); // jaune
    case FlavorMatchCategory.questionable:
      return const Color(0xFFD97B41); // orange
    case FlavorMatchCategory.avoid:
      return const Color(0xFFB85C45); // rouge
  }
}

/// Couleur affichée pour un match : une prédiction basse n'est jamais
/// rouge (elle prend la teinte « discutable »).
Color flavorMatchColor(FlavorMatch match) {
  if (match.isPrediction && match.category == FlavorMatchCategory.avoid) {
    return flavorCategoryColor(FlavorMatchCategory.questionable);
  }
  return flavorCategoryColor(match.category);
}

/// Libellé de catégorie d'un match (honnête pour les prédictions).
String flavorMatchLabel(AppStrings strings, FlavorMatch match) {
  if (match.isPrediction && match.category == FlavorMatchCategory.avoid) {
    return strings.flavorUnlikely;
  }
  return switch (match.category) {
    FlavorMatchCategory.excellent => strings.flavorCategoryExcellent,
    FlavorMatchCategory.good => strings.flavorCategoryGood,
    FlavorMatchCategory.average => strings.flavorCategoryAverage,
    FlavorMatchCategory.questionable => strings.flavorCategoryQuestionable,
    FlavorMatchCategory.avoid => strings.flavorCategoryAvoid,
  };
}

String flavorEvidenceLabel(AppStrings strings, FlavorMatch match) =>
    switch (match.evidence) {
      FlavorMatchEvidence.observed => strings.flavorEvidenceObserved,
      FlavorMatchEvidence.curated => strings.flavorEvidenceCurated,
      FlavorMatchEvidence.predicted => strings.flavorEvidencePredicted,
    };

class FlavorCompatibilityHeatmap extends StatelessWidget {
  const FlavorCompatibilityHeatmap({
    required this.ingredients,
    this.db,
    this.repository,
    this.maxIngredients = kHeatmapMaxIngredients,
    this.embedded = false,
    super.key,
  });

  /// Ingrédients de la recette ; seuls ceux avec un `ingredientId` lié
  /// entrent dans la matrice.
  final List<RecipeIngredient> ingredients;

  /// Base Drift (utilisée si [repository] n'est pas fourni).
  final AppDatabase? db;

  /// Repository injectable (tests sans Drift).
  final FlavorRepository? repository;

  final int maxIngredients;

  /// Vrai quand la matrice est intégrée dans une carte parente (pas de
  /// carte ni de titre propres).
  final bool embedded;

  /// Ingrédients liés retenus pour la matrice (dédupliqués, plafonnés).
  static List<RecipeIngredient> linkedIngredients(
    List<RecipeIngredient> ingredients, {
    int maxIngredients = kHeatmapMaxIngredients,
  }) {
    final seen = <String>{};
    final result = <RecipeIngredient>[];
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty || !seen.add(id)) continue;
      result.add(ingredient);
      if (result.length >= maxIngredients) break;
    }
    return result;
  }

  static int linkedCount(List<RecipeIngredient> ingredients) => {
    for (final i in ingredients)
      if (i.ingredientId != null && i.ingredientId!.isNotEmpty) i.ingredientId,
  }.length;

  @override
  Widget build(BuildContext context) {
    final linked = linkedIngredients(
      ingredients,
      maxIngredients: maxIngredients,
    );
    if (linked.length < 2) return const SizedBox.shrink();

    final repo = repository ?? (db != null ? FlavorRepository(db!) : null);
    if (repo == null) return const SizedBox.shrink();

    final ids = [for (final i in linked) i.ingredientId!];
    final hidden = linkedCount(ingredients) - linked.length;
    return FutureBuilder<Map<String, ({FlavorMatch match, int size})>>(
      future: _loadCells(repo, ids),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final cells = snapshot.data ?? const {};
        if (cells.isEmpty) return const SizedBox.shrink();
        final body = _HeatmapBody(
          linked: linked,
          cells: cells,
          hiddenCount: hidden,
        );
        if (embedded) return body;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.grid_on, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        context.strings.flavorHeatmapTitle,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                body,
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<Map<String, ({FlavorMatch match, int size})>> _loadCells(
    FlavorRepository repo,
    List<String> ids,
  ) async {
    final cells = <String, ({FlavorMatch match, int size})>{};
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final match = await repo.bestKnownMatchFor(ids[i], ids[j]);
        if (match != null) {
          cells['$i-$j'] = match;
          cells['$j-$i'] = match;
        }
      }
    }
    return cells;
  }
}

class _HeatmapBody extends StatelessWidget {
  const _HeatmapBody({
    required this.linked,
    required this.cells,
    required this.hiddenCount,
  });

  final List<RecipeIngredient> linked;
  final Map<String, ({FlavorMatch match, int size})> cells;
  final int hiddenCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeaderRow(linked: linked),
              for (var row = 0; row < linked.length; row++)
                _MatrixRow(rowIndex: row, linked: linked, cells: cells),
            ],
          ),
        ),
        if (hiddenCount > 0) ...[
          const SizedBox(height: 6),
          Text(
            context.strings.flavorMore(hiddenCount),
            style: Theme.of(context).textTheme.labelSmall
                ?.copyWith(fontStyle: FontStyle.italic),
          ),
        ],
        const SizedBox(height: 10),
        const _Legend(),
      ],
    );
  }
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.linked});

  final List<RecipeIngredient> linked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: _kLabelWidth),
        for (final ingredient in linked)
          SizedBox(
            width: _kCellSize,
            height: _kLabelWidth,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: RotatedBox(
                quarterTurns: 3,
                child: Text(
                  ingredient.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MatrixRow extends StatelessWidget {
  const _MatrixRow({
    required this.rowIndex,
    required this.linked,
    required this.cells,
  });

  final int rowIndex;
  final List<RecipeIngredient> linked;
  final Map<String, ({FlavorMatch match, int size})> cells;

  @override
  Widget build(BuildContext context) {
    final rowIngredient = linked[rowIndex];
    return Row(
      children: [
        SizedBox(
          width: _kLabelWidth,
          child: Text(
            rowIngredient.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        for (var col = 0; col < linked.length; col++)
          _HeatmapCell(
            rowIngredient: rowIngredient,
            colIngredient: linked[col],
            isDiagonal: rowIndex == col,
            match: cells['$rowIndex-$col'],
          ),
      ],
    );
  }
}

const double _kCellSize = 44;
const double _kLabelWidth = 96;

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.rowIngredient,
    required this.colIngredient,
    required this.isDiagonal,
    required this.match,
  });

  final RecipeIngredient rowIngredient;
  final RecipeIngredient colIngredient;
  final bool isDiagonal;
  final ({FlavorMatch match, int size})? match;

  @override
  Widget build(BuildContext context) {
    final neutral = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (isDiagonal) {
      return Container(
        width: _kCellSize,
        height: _kCellSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: neutral,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final m = match;
    final predicted = m?.match.isPrediction ?? false;
    final base = m == null ? neutral : flavorMatchColor(m.match);
    final color = predicted ? base.withValues(alpha: 0.55) : base;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Tooltip(
        message: m == null
            ? context.strings.flavorPairUnknown
            : '${flavorMatchLabel(context.strings, m.match)} — '
                  '${flavorEvidenceLabel(context.strings, m.match)}',
        child: Material(
          color: color,
          borderRadius: BorderRadius.circular(6),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: m == null
                ? null
                : () => _showDetail(context, m, rowIngredient, colIngredient),
            child: CustomPaint(
              painter: predicted ? const _HatchPainter() : null,
              child: SizedBox(
                width: _kCellSize - 4,
                height: _kCellSize - 4,
                child: Stack(
                  children: [
                    Center(
                      child: m == null
                          ? const SizedBox.shrink()
                          : Text(
                              m.match.overallScore.toStringAsFixed(2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                    if (m != null && !m.match.isPrediction)
                      const Positioned(
                        top: 1,
                        right: 2,
                        child: Icon(Icons.check, size: 10, color: Colors.white),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetail(
    BuildContext context,
    ({FlavorMatch match, int size}) m,
    RecipeIngredient a,
    RecipeIngredient b,
  ) {
    final strings = context.strings;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        final match = m.match;
        final theme = Theme.of(context);
        Widget sub(String label, double? v) => v == null
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    SizedBox(
                      width: 170,
                      child: Text(label, style: theme.textTheme.bodySmall),
                    ),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: v.clamp(0, 1).toDouble(),
                        minHeight: 6,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      v.toStringAsFixed(2),
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                ),
              );
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${a.label} × ${b.label}',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: flavorMatchColor(match),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${strings.flavorOverallScore} : '
                      '${match.overallScore.toStringAsFixed(2)} — '
                      '${flavorMatchLabel(strings, match)}',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                m.size == 2
                    ? '${flavorEvidenceLabel(strings, match)}'
                          '${match.confidence == null ? '' : ' — ${strings.flavorConfidence(match.confidence!)}'}'
                    : strings.flavorSourceCombination(m.size),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
              if (match.sharedDescriptors.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final d in match.sharedDescriptors)
                      Chip(
                        visualDensity: VisualDensity.compact,
                        label: Text(SensoryOntology.label(d)),
                      ),
                  ],
                ),
              ],
              if (match.explanation != null &&
                  match.explanation!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(match.explanation!, style: theme.textTheme.bodyMedium),
              ],
              if (match.evidence != FlavorMatchEvidence.observed ||
                  match.aromaSimilarity != null) ...[
                const SizedBox(height: 12),
                sub('Similarité aromatique', match.aromaSimilarity),
                sub('Complémentarité', match.aromaComplement),
                sub('Équilibre des saveurs', match.tasteBalance),
                sub('Cohérence sucré/salé', match.contextualFit),
                sub('Risque de dominance', match.dominanceRisk),
                sub('Soutien culinaire', match.culinarySupport),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// Hachures diagonales des cellules « prédiction ».
class _HatchPainter extends CustomPainter {
  const _HatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..strokeWidth = 1.5;
    for (var x = -size.height; x < size.width; x += 7) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Légende : catégories, prédictions hachurées, accords étayés, absence.
class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final style = Theme.of(context).textTheme.labelSmall;
    Widget swatch(Color color, {bool hatch = false, bool check = false}) =>
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: CustomPaint(
            foregroundPainter: hatch ? const _HatchPainter() : null,
            child: Container(
              width: 14,
              height: 14,
              color: color,
              child: check
                  ? const Icon(Icons.check, size: 10, color: Colors.white)
                  : null,
            ),
          ),
        );
    final entries = <(Widget, String)>[
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.excellent)),
        strings.flavorCategoryExcellent,
      ),
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.good)),
        strings.flavorCategoryGood,
      ),
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.average)),
        strings.flavorCategoryAverage,
      ),
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.questionable)),
        strings.flavorCategoryQuestionable,
      ),
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.avoid)),
        strings.flavorCategoryAvoid,
      ),
      (
        swatch(
          flavorCategoryColor(FlavorMatchCategory.good).withValues(alpha: 0.55),
          hatch: true,
        ),
        strings.flavorPredictedLegend,
      ),
      (
        swatch(flavorCategoryColor(FlavorMatchCategory.good), check: true),
        strings.flavorEvidenceCurated,
      ),
      (
        swatch(Theme.of(context).colorScheme.surfaceContainerHighest),
        strings.flavorPairUnknown,
      ),
    ];
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      children: [
        for (final (w, label) in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              w,
              const SizedBox(width: 4),
              Text(label, style: style),
            ],
          ),
      ],
    );
  }
}
