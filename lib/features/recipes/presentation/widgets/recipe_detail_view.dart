import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_metier_advisory_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_nutrition_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_photo.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_tag_label.dart';

class RecipeDetailView extends StatelessWidget {
  const RecipeDetailView({
    required this.recipe,
    required this.isWide,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
    this.scrollable = true,
    this.db,
    super.key,
  });

  final Recipe recipe;
  final bool isWide;
  final ValueChanged<Recipe> onEdit;
  final ValueChanged<Recipe> onDuplicate;
  final ValueChanged<Recipe> onDelete;
  final bool scrollable;

  /// Optional Drift database. When provided, the metier advisory panel
  /// is enabled (queries Phase 4 interaction rules for matching
  /// ingredient ids). When null, the panel renders nothing.
  final AppDatabase? db;

  @override
  Widget build(BuildContext context) {
    final content = _RecipeContent(
      recipe: recipe,
      onEdit: onEdit,
      onDuplicate: onDuplicate,
      onDelete: onDelete,
    );

    final body = Padding(
      padding: EdgeInsets.all(isWide ? 32 : 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1180),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: content),
                  const SizedBox(width: 22),
                  SizedBox(
                    width: 330,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        RecipeNutritionPanel(nutrition: recipe.nutrition),
                        if (db != null)
                          RecipeMetierAdvisoryPanel(recipe: recipe, db: db!),
                      ],
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  content,
                  const SizedBox(height: 18),
                  RecipeNutritionPanel(nutrition: recipe.nutrition),
                  if (db != null)
                    RecipeMetierAdvisoryPanel(recipe: recipe, db: db!),
                ],
              ),
      ),
    );

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: scrollable ? SingleChildScrollView(child: body) : body,
    );
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RecipeOverviewPanel(
          recipe: recipe,
          onEdit: onEdit,
          onDuplicate: onDuplicate,
          onDelete: onDelete,
        ),
        const SizedBox(height: 18),
        _SectionPanel(
          title: context.strings.ingredients,
          icon: Icons.format_list_bulleted,
          child: Column(
            children: [
              for (final ingredient in recipe.ingredients)
                _IngredientRow(ingredient: ingredient),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _SectionPanel(
          title: context.strings.preparation,
          icon: Icons.checklist,
          child: Column(
            children: [
              for (var index = 0; index < recipe.steps.length; index++)
                _StepRow(index: index + 1, text: recipe.steps[index]),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecipeOverviewPanel extends StatelessWidget {
  const _RecipeOverviewPanel({
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
              children: [
                _MetricPill(
                  icon: Icons.people_alt_outlined,
                  label: '${recipe.servings} portions',
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

class _SectionPanel extends StatelessWidget {
  const _SectionPanel({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

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
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.ingredient});

  final RecipeIngredient ingredient;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 460;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ingredient.quantity,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(ingredient.label),
              ],
            );
          }

          return Row(
            children: [
              SizedBox(
                width: 96,
                child: Text(
                  ingredient.quantity,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Expanded(child: Text(ingredient.label)),
            ],
          );
        },
      ),
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
