// Phase 09 Lot G / Phase 10 Lots E-H — FlavorCompatibilityHeatmap.
//
// Matrice N×N des ingrédients liés de la recette (jusqu'à 30), cellules
// colorées selon la catégorie d'accord. Phase 10 (ac-123, décision
// honest-data-display) :
// - une PRÉDICTION (profils sensoriels, sans accord documenté) est
//   hachurée et atténuée, et une prédiction basse s'affiche « Peu
//   probable (prédiction) », jamais « À éviter » ;
// - un accord étayé (observé Phase 3 ou curaté) porte un repère ✓ ;
// - le détail au tap donne l'origine, la confiance, les arômes partagés
//   et les sous-scores (similarité, équilibre, contexte, dominance).
// Refonte UX : défilement vertical et horizontal avec en-têtes figés
// quand la matrice dépasse la place disponible, tri (ordre de la
// recette, force d'accord, alphabétique) et filtre « accords
// documentés seulement ».

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/i18n/formatters.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Nombre max d'ingrédients affichés dans la matrice (au-delà de la
/// place disponible, la matrice défile).
const int kHeatmapMaxIngredients = 30;

/// Ordre des lignes et colonnes de la matrice.
enum HeatmapSort { recipe, strength, alphabetical }

/// Cellule de la matrice : meilleur accord connu et taille de la
/// combinaison source (2 = paire).
typedef HeatmapCellData = ({FlavorMatch match, int size});

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

class FlavorCompatibilityHeatmap extends StatefulWidget {
  const FlavorCompatibilityHeatmap({
    required this.ingredients,
    this.db,
    this.repository,
    this.maxIngredients = kHeatmapMaxIngredients,
    this.embedded = false,
    this.maxGridHeight = 440,
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

  /// Hauteur max de la grille avant défilement vertical.
  final double maxGridHeight;

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

  /// Clé d'une cellule (paire orientée d'identifiants).
  static String cellKey(String a, String b) => '$a|$b';

  /// Ordre des ingrédients selon [sort]. La force d'accord d'un
  /// ingrédient est la moyenne de ses cellules visibles ; sans cellule,
  /// il passe en dernier.
  static List<RecipeIngredient> ordered(
    List<RecipeIngredient> linked,
    Map<String, HeatmapCellData> cells,
    HeatmapSort sort, {
    bool documentedOnly = false,
  }) {
    final list = [...linked];
    switch (sort) {
      case HeatmapSort.recipe:
        return list;
      case HeatmapSort.alphabetical:
        list.sort((a, b) => _fold(a.label).compareTo(_fold(b.label)));
        return list;
      case HeatmapSort.strength:
        double? strength(RecipeIngredient r) {
          var sum = 0.0;
          var n = 0;
          for (final other in linked) {
            if (other.ingredientId == r.ingredientId) continue;
            final c = cells[cellKey(r.ingredientId!, other.ingredientId!)];
            if (c == null) continue;
            if (documentedOnly && c.match.isPrediction) continue;
            sum += c.match.overallScore;
            n++;
          }
          return n == 0 ? null : sum / n;
        }

        final s = {for (final r in list) r.ingredientId!: strength(r)};
        list.sort((a, b) {
          final sa = s[a.ingredientId!];
          final sb = s[b.ingredientId!];
          if (sa == null && sb == null) return 0;
          if (sa == null) return 1;
          if (sb == null) return -1;
          return sb.compareTo(sa);
        });
        return list;
    }
  }

  static String _fold(String s) => s
      .toLowerCase()
      .replaceAll('œ', 'oe')
      .replaceAll(RegExp('[éèêë]'), 'e')
      .replaceAll(RegExp('[àâä]'), 'a')
      .replaceAll(RegExp('[îï]'), 'i')
      .replaceAll(RegExp('[ôö]'), 'o')
      .replaceAll(RegExp('[ùûü]'), 'u')
      .replaceAll('ç', 'c');

  @override
  State<FlavorCompatibilityHeatmap> createState() =>
      _FlavorCompatibilityHeatmapState();
}

class _FlavorCompatibilityHeatmapState
    extends State<FlavorCompatibilityHeatmap> {
  Future<Map<String, HeatmapCellData>>? _future;
  String? _signature;
  HeatmapSort _sort = HeatmapSort.recipe;
  bool _documentedOnly = false;

  List<RecipeIngredient> get _linked =>
      FlavorCompatibilityHeatmap.linkedIngredients(
        widget.ingredients,
        maxIngredients: widget.maxIngredients,
      );

  FlavorRepository? get _repo =>
      widget.repository ??
      (widget.db != null ? FlavorRepository(widget.db!) : null);

  void _load() {
    final ids = [for (final i in _linked) i.ingredientId!];
    _signature = ids.join(',');
    final repo = _repo;
    _future = repo == null || ids.length < 2 ? null : _loadCells(repo, ids);
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant FlavorCompatibilityHeatmap oldWidget) {
    super.didUpdateWidget(oldWidget);
    final ids = [for (final i in _linked) i.ingredientId!].join(',');
    if (ids != _signature ||
        oldWidget.db != widget.db ||
        oldWidget.repository != widget.repository) {
      _load();
    }
  }

  static Future<Map<String, HeatmapCellData>> _loadCells(
    FlavorRepository repo,
    List<String> ids,
  ) async {
    final cells = <String, HeatmapCellData>{};
    for (var i = 0; i < ids.length; i++) {
      for (var j = i + 1; j < ids.length; j++) {
        final match = await repo.bestKnownMatchFor(ids[i], ids[j]);
        if (match != null) {
          cells[FlavorCompatibilityHeatmap.cellKey(ids[i], ids[j])] = match;
          cells[FlavorCompatibilityHeatmap.cellKey(ids[j], ids[i])] = match;
        }
      }
    }
    return cells;
  }

  @override
  Widget build(BuildContext context) {
    final future = _future;
    if (future == null) return const SizedBox.shrink();
    final linked = _linked;
    final hidden =
        FlavorCompatibilityHeatmap.linkedCount(widget.ingredients) -
        linked.length;
    return FutureBuilder<Map<String, HeatmapCellData>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        final cells = snapshot.data ?? const {};
        if (cells.isEmpty) return const SizedBox.shrink();
        final note = Theme.of(context).textTheme.labelSmall
            ?.copyWith(fontStyle: FontStyle.italic);
        final body = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Controls(
              sort: _sort,
              documentedOnly: _documentedOnly,
              onSort: (s) => setState(() => _sort = s),
              onDocumentedOnly: (v) => setState(() => _documentedOnly = v),
            ),
            const SizedBox(height: 10),
            _HeatmapGrid(
              order: FlavorCompatibilityHeatmap.ordered(
                linked,
                cells,
                _sort,
                documentedOnly: _documentedOnly,
              ),
              cells: cells,
              documentedOnly: _documentedOnly,
              maxGridHeight: widget.maxGridHeight,
            ),
            if (hidden > 0) ...[
              const SizedBox(height: 6),
              Text(context.strings.flavorMore(hidden), style: note),
            ],
            if (_documentedOnly) ...[
              const SizedBox(height: 6),
              Text(context.strings.flavorDocumentedOnlyNote, style: note),
            ],
            const SizedBox(height: 10),
            const _Legend(),
          ],
        );
        if (widget.embedded) return body;
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
}

/// Tri et filtre de la matrice.
class _Controls extends StatelessWidget {
  const _Controls({
    required this.sort,
    required this.documentedOnly,
    required this.onSort,
    required this.onDocumentedOnly,
  });

  final HeatmapSort sort;
  final bool documentedOnly;
  final ValueChanged<HeatmapSort> onSort;
  final ValueChanged<bool> onDocumentedOnly;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    return Wrap(
      spacing: 10,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          strings.flavorSortLabel,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        SegmentedButton<HeatmapSort>(
          showSelectedIcon: false,
          style: const ButtonStyle(
            visualDensity: VisualDensity.compact,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          segments: [
            ButtonSegment(
              value: HeatmapSort.recipe,
              label: Text(strings.flavorSortRecipe),
            ),
            ButtonSegment(
              value: HeatmapSort.strength,
              label: Text(strings.flavorSortStrength),
            ),
            ButtonSegment(
              value: HeatmapSort.alphabetical,
              label: Text(strings.flavorSortAlpha),
            ),
          ],
          selected: {sort},
          onSelectionChanged: (s) => onSort(s.first),
        ),
        FilterChip(
          label: Text(strings.flavorDocumentedOnly),
          selected: documentedOnly,
          onSelected: onDocumentedOnly,
          avatar: documentedOnly
              ? null
              : const Icon(Icons.verified_outlined, size: 16),
        ),
      ],
    );
  }
}

const double _kCellSize = 44;
const double _kLabelWidth = 116;
const double _kHeaderHeight = 110;
const double _kScrollbarGutter = 12;

/// Grille avec en-têtes figés : les libellés de colonnes suivent le
/// défilement horizontal, ceux des lignes le défilement vertical.
class _HeatmapGrid extends StatefulWidget {
  const _HeatmapGrid({
    required this.order,
    required this.cells,
    required this.documentedOnly,
    required this.maxGridHeight,
  });

  final List<RecipeIngredient> order;
  final Map<String, HeatmapCellData> cells;
  final bool documentedOnly;
  final double maxGridHeight;

  @override
  State<_HeatmapGrid> createState() => _HeatmapGridState();
}

class _HeatmapGridState extends State<_HeatmapGrid> {
  final _hBody = ScrollController();
  final _vBody = ScrollController();
  final _hHeader = ScrollController();
  final _vLabels = ScrollController();

  @override
  void initState() {
    super.initState();
    _hBody.addListener(() => _follow(_hBody, _hHeader));
    _vBody.addListener(() => _follow(_vBody, _vLabels));
  }

  static void _follow(ScrollController from, ScrollController to) {
    if (!to.hasClients || !from.hasClients) return;
    final target = from.offset.clamp(
      to.position.minScrollExtent,
      to.position.maxScrollExtent,
    );
    if (to.offset != target) to.jumpTo(target);
  }

  @override
  void dispose() {
    _hBody.dispose();
    _vBody.dispose();
    _hHeader.dispose();
    _vLabels.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final n = order.length;
    final gridSize = n * _kCellSize;
    return LayoutBuilder(
      builder: (context, constraints) {
        final available = math.max(
          _kCellSize * 2,
          constraints.maxWidth - _kLabelWidth,
        );
        final overflowY = gridSize > widget.maxGridHeight + 0.5;
        final gutterX = overflowY ? _kScrollbarGutter : 0.0;
        final overflowX = gridSize + gutterX > available + 0.5;
        final gutterY = overflowX ? _kScrollbarGutter : 0.0;
        final viewW = math.min(gridSize + gutterX, available);
        final viewH = math.min(gridSize, widget.maxGridHeight) + gutterY;
        final labelStyle = Theme.of(context).textTheme.labelSmall;

        final header = Padding(
          padding: EdgeInsets.only(right: gutterX),
          child: Row(
            children: [
              for (final ingredient in order)
                SizedBox(
                  width: _kCellSize,
                  height: _kHeaderHeight,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Tooltip(
                      message: ingredient.label,
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: Text(
                          ingredient.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: labelStyle,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        final rowLabels = Padding(
          padding: EdgeInsets.only(bottom: gutterY),
          child: Column(
            children: [
              for (final ingredient in order)
                SizedBox(
                  height: _kCellSize,
                  width: _kLabelWidth,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Tooltip(
                      message: ingredient.label,
                      child: Text(
                        ingredient.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: labelStyle,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
        final grid = Padding(
          padding: EdgeInsets.only(right: gutterX, bottom: gutterY),
          child: Column(
            children: [
              for (var row = 0; row < n; row++)
                Row(
                  children: [
                    for (var col = 0; col < n; col++)
                      _HeatmapCell(
                        rowIngredient: order[row],
                        colIngredient: order[col],
                        isDiagonal: row == col,
                        match: row == col
                            ? null
                            : widget.cells[FlavorCompatibilityHeatmap.cellKey(
                                order[row].ingredientId!,
                                order[col].ingredientId!,
                              )],
                        documentedOnly: widget.documentedOnly,
                      ),
                  ],
                ),
            ],
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: _kLabelWidth, height: _kHeaderHeight),
                SizedBox(
                  width: viewW,
                  height: _kHeaderHeight,
                  child: SingleChildScrollView(
                    controller: _hHeader,
                    scrollDirection: Axis.horizontal,
                    physics: const NeverScrollableScrollPhysics(),
                    child: header,
                  ),
                ),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _kLabelWidth,
                  height: viewH,
                  child: SingleChildScrollView(
                    controller: _vLabels,
                    physics: const NeverScrollableScrollPhysics(),
                    child: rowLabels,
                  ),
                ),
                SizedBox(
                  width: viewW,
                  height: viewH,
                  child: Scrollbar(
                    controller: _hBody,
                    thumbVisibility: overflowX,
                    notificationPredicate: (n) => n.depth == 1,
                    child: Scrollbar(
                      controller: _vBody,
                      thumbVisibility: overflowY,
                      child: SingleChildScrollView(
                        controller: _vBody,
                        child: SingleChildScrollView(
                          controller: _hBody,
                          scrollDirection: Axis.horizontal,
                          child: grid,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.rowIngredient,
    required this.colIngredient,
    required this.isDiagonal,
    required this.match,
    this.documentedOnly = false,
  });

  final RecipeIngredient rowIngredient;
  final RecipeIngredient colIngredient;
  final bool isDiagonal;
  final HeatmapCellData? match;
  final bool documentedOnly;

  @override
  Widget build(BuildContext context) {
    final neutral = Theme.of(context).colorScheme.surfaceContainerHighest;
    if (isDiagonal) {
      return Container(
        width: _kCellSize - 4,
        height: _kCellSize - 4,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: neutral,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final hiddenPrediction =
        documentedOnly && (match?.match.isPrediction ?? false);
    final m = hiddenPrediction ? null : match;
    final predicted = m?.match.isPrediction ?? false;
    final base = m == null ? neutral : flavorMatchColor(m.match);
    final color = predicted ? base.withValues(alpha: 0.55) : base;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Tooltip(
        message: m == null
            ? (hiddenPrediction
                  ? context.strings.flavorEvidencePredicted
                  : context.strings.flavorPairUnknown)
            : '${rowIngredient.label} × ${colIngredient.label} : '
                  '${flavorMatchLabel(context.strings, m.match)} — '
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
                              fmtNum(m.match.overallScore, 2),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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
    HeatmapCellData m,
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
                    Text(fmtNum(v, 2), style: theme.textTheme.labelSmall),
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
                      '${fmtNum(match.overallScore, 2)} — '
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
