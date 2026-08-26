// Phase 09 Lot G — G4 : FlavorCompatibilityHeatmap (plan §7.3).
//
// Matrice N×N des ingrédients liés de la recette, cellules colorées
// selon la catégorie FlavorMatch (vert = excellent … rouge = éviter).
// Tap sur une cellule → bottom sheet avec score + explication.
// Limité à 5 ingrédients (les premiers liés) — au-delà, illisible
// (dette ac-102).

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Nombre max d'ingrédients affichés dans la matrice (plan §7.3).
const int kHeatmapMaxIngredients = 5;

/// Couleur associée à une catégorie de compatibilité (exposée pour les
/// tests et le bottom sheet).
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

class FlavorCompatibilityHeatmap extends StatelessWidget {
  const FlavorCompatibilityHeatmap({
    required this.ingredients,
    this.db,
    this.repository,
    this.maxIngredients = kHeatmapMaxIngredients,
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
    return FutureBuilder(
      // Réchauffe le cache et vérifie qu'au moins une donnée existe.
      future: repo.bestMatchFor(ids),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        return _HeatmapCard(linked: linked, repository: repo);
      },
    );
  }
}

class _HeatmapCard extends StatelessWidget {
  const _HeatmapCard({required this.linked, required this.repository});

  final List<RecipeIngredient> linked;
  final FlavorRepository repository;

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeaderRow(linked: linked),
                  for (var row = 0; row < linked.length; row++)
                    _MatrixRow(
                      rowIndex: row,
                      linked: linked,
                      repository: repository,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
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
    required this.repository,
  });

  final int rowIndex;
  final List<RecipeIngredient> linked;
  final FlavorRepository repository;

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
            repository: repository,
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
    required this.repository,
  });

  final RecipeIngredient rowIngredient;
  final RecipeIngredient colIngredient;
  final bool isDiagonal;
  final FlavorRepository repository;

  @override
  Widget build(BuildContext context) {
    if (isDiagonal) {
      return Container(
        width: _kCellSize,
        height: _kCellSize,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(6),
        ),
      );
    }

    final match = repository.cachedMatchFor([
      rowIngredient.ingredientId!,
      colIngredient.ingredientId!,
    ]);

    final color = match == null
        ? Theme.of(context).colorScheme.surfaceContainerHighest
        : flavorCategoryColor(match.category);

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: match == null
              ? null
              : () => _showDetail(context, match, rowIngredient, colIngredient),
          child: SizedBox(
            width: _kCellSize - 4,
            height: _kCellSize - 4,
            child: Center(
              child: match == null
                  ? const SizedBox.shrink()
                  : Text(
                      match.overallScore.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
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
    FlavorMatch match,
    RecipeIngredient a,
    RecipeIngredient b,
  ) {
    final strings = context.strings;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${a.label} × ${b.label}',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: flavorCategoryColor(match.category),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${strings.flavorOverallScore} : '
                    '${match.overallScore.toStringAsFixed(2)} — '
                    '${_categoryLabel(strings, match.category)}',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ],
              ),
              if (match.explanation != null &&
                  match.explanation!.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  match.explanation!,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _categoryLabel(AppStrings strings, FlavorMatchCategory c) {
    switch (c) {
      case FlavorMatchCategory.excellent:
        return strings.flavorCategoryExcellent;
      case FlavorMatchCategory.good:
        return strings.flavorCategoryGood;
      case FlavorMatchCategory.average:
        return strings.flavorCategoryAverage;
      case FlavorMatchCategory.questionable:
        return strings.flavorCategoryQuestionable;
      case FlavorMatchCategory.avoid:
        return strings.flavorCategoryAvoid;
    }
  }
}
