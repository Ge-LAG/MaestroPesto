import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_tag_label.dart';

enum RecipeBookViewMode { card, list }

class RecipeBookPanel extends StatefulWidget {
  const RecipeBookPanel({
    required this.recipes,
    required this.selectedRecipeId,
    required this.tags,
    required this.selectedTags,
    required this.query,
    required this.onQueryChanged,
    required this.onRecipeSelected,
    required this.onTagsChanged,
    required this.onClearFilters,
    required this.onCreateRecipe,
    this.compact = false,
    super.key,
  });

  final List<Recipe> recipes;
  final String selectedRecipeId;
  final List<String> tags;
  final Set<String> selectedTags;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onRecipeSelected;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateRecipe;
  final bool compact;

  @override
  State<RecipeBookPanel> createState() => _RecipeBookPanelState();
}

class _RecipeBookPanelState extends State<RecipeBookPanel> {
  RecipeBookViewMode _viewMode = RecipeBookViewMode.card;
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.query);
  }

  @override
  void didUpdateWidget(covariant RecipeBookPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.query != _searchController.text) {
      _searchController.text = widget.query;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewMode = widget.compact ? RecipeBookViewMode.card : _viewMode;

    return ColoredBox(
      color: const Color(0xFFF0F1EC),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, widget.compact ? 16 : 20, 20, 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BookHeader(
              compact: widget.compact,
              onCreateRecipe: widget.onCreateRecipe,
            ),
            const SizedBox(height: 18),
            SearchBar(
              controller: _searchController,
              elevation: const WidgetStatePropertyAll(0),
              backgroundColor: WidgetStatePropertyAll(colorScheme.surface),
              hintText: context.strings.search,
              leading: const Icon(Icons.search),
              trailing: [
                if (widget.query.trim().isNotEmpty)
                  IconButton(
                    onPressed: widget.onClearFilters,
                    icon: const Icon(Icons.close),
                    tooltip: context.strings.clearFilters,
                  ),
              ],
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 12),
              ),
              onChanged: widget.onQueryChanged,
            ),
            const SizedBox(height: 10),
            _BookResultBar(
              count: widget.recipes.length,
              query: widget.query,
              viewMode: viewMode,
              compact: widget.compact,
              tags: widget.tags,
              selectedTags: widget.selectedTags,
              onTagsChanged: widget.onTagsChanged,
              onClearFilters: widget.onClearFilters,
              onViewModeChanged: (mode) => setState(() => _viewMode = mode),
            ),
            const SizedBox(height: 18),
            if (widget.compact)
              SizedBox(
                height: widget.recipes.isEmpty ? 92 : 176,
                child: widget.recipes.isEmpty
                    ? const _EmptyBookMessage()
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          final recipe = widget.recipes[index];
                          return SizedBox(
                            width: 264,
                            child: _RecipeCardTile(
                              recipe: recipe,
                              selected: recipe.id == widget.selectedRecipeId,
                              onTap: () => widget.onRecipeSelected(recipe.id),
                            ),
                          );
                        },
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemCount: widget.recipes.length,
                      ),
              )
            else
              Expanded(
                child: widget.recipes.isEmpty
                    ? const _EmptyBookMessage()
                    : ListView.separated(
                        padding: const EdgeInsets.only(right: 10),
                        itemBuilder: (context, index) {
                          final recipe = widget.recipes[index];
                          final selected = recipe.id == widget.selectedRecipeId;
                          return viewMode == RecipeBookViewMode.card
                              ? _RecipeCardTile(
                                  recipe: recipe,
                                  selected: selected,
                                  onTap: () =>
                                      widget.onRecipeSelected(recipe.id),
                                )
                              : _RecipeLineTile(
                                  recipe: recipe,
                                  selected: selected,
                                  onTap: () =>
                                      widget.onRecipeSelected(recipe.id),
                                );
                        },
                        separatorBuilder: (_, __) => SizedBox(
                          height: viewMode == RecipeBookViewMode.card ? 12 : 8,
                        ),
                        itemCount: widget.recipes.length,
                      ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BookResultBar extends StatelessWidget {
  const _BookResultBar({
    required this.count,
    required this.query,
    required this.viewMode,
    required this.compact,
    required this.tags,
    required this.selectedTags,
    required this.onTagsChanged,
    required this.onClearFilters,
    required this.onViewModeChanged,
  });

  final int count;
  final String query;
  final RecipeBookViewMode viewMode;
  final bool compact;
  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onClearFilters;
  final ValueChanged<RecipeBookViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = query.trim().isNotEmpty || selectedTags.isNotEmpty;
    final countLabel = query.trim().isEmpty
        ? context.strings.recipeCount(count)
        : context.strings.resultCount(count);
    final countText = Text(
      countLabel,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodySmall,
    );
    final controls = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasActiveFilters)
          TextButton.icon(
            onPressed: onClearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
            label: Text(context.strings.clearFilters),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        _TagFilterMenu(
          tags: tags,
          selectedTags: selectedTags,
          onChanged: onTagsChanged,
        ),
        if (!compact)
          SegmentedButton<RecipeBookViewMode>(
            showSelectedIcon: false,
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              minimumSize: const WidgetStatePropertyAll(Size(46, 32)),
              padding: const WidgetStatePropertyAll(
                EdgeInsets.symmetric(horizontal: 9),
              ),
            ),
            segments: [
              ButtonSegment(
                value: RecipeBookViewMode.card,
                icon: const Icon(Icons.dashboard_outlined),
                tooltip: context.strings.cardView,
              ),
              ButtonSegment(
                value: RecipeBookViewMode.list,
                icon: const Icon(Icons.view_list_outlined),
                tooltip: context.strings.listView,
              ),
            ],
            selected: {viewMode},
            onSelectionChanged: (selection) =>
                onViewModeChanged(selection.first),
          ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (compact || constraints.maxWidth < 340 || hasActiveFilters) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [countText, const SizedBox(height: 8), controls],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: countText),
            const SizedBox(width: 10),
            controls,
          ],
        );
      },
    );
  }
}

class _TagFilterMenu extends StatelessWidget {
  const _TagFilterMenu({
    required this.tags,
    required this.selectedTags,
    required this.onChanged,
  });

  final List<String> tags;
  final Set<String> selectedTags;
  final ValueChanged<Set<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    final label = selectedTags.isEmpty
        ? strings.tags
        : strings.tagsCount(selectedTags.length);

    return MenuAnchor(
      builder: (context, controller, child) {
        return OutlinedButton(
          onPressed: () {
            controller.isOpen ? controller.close() : controller.open();
          },
          style: OutlinedButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            minimumSize: const Size(0, 32),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label),
              const SizedBox(width: 4),
              Icon(
                controller.isOpen ? Icons.expand_less : Icons.expand_more,
                size: 16,
              ),
            ],
          ),
        );
      },
      menuChildren: [
        MenuItemButton(
          onPressed: selectedTags.isEmpty ? null : () => onChanged({}),
          child: Text(strings.allTags),
        ),
        const Divider(height: 1),
        for (final tag in tags)
          CheckboxMenuButton(
            value: selectedTags.contains(tag),
            onChanged: (checked) {
              final next = Set<String>.from(selectedTags);
              if (checked ?? false) {
                next.add(tag);
              } else {
                next.remove(tag);
              }
              onChanged(next);
            },
            child: Text(tag),
          ),
      ],
    );
  }
}

class _BookHeader extends StatelessWidget {
  const _BookHeader({required this.compact, required this.onCreateRecipe});

  final bool compact;
  final VoidCallback onCreateRecipe;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.local_dining, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MaestroPesto',
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
              if (!compact)
                Text(
                  context.strings.recipeBookSubtitle,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
            ],
          ),
        ),
        IconButton.filled(
          onPressed: onCreateRecipe,
          icon: const Icon(Icons.add),
          tooltip: context.strings.newRecipe,
        ),
      ],
    );
  }
}

class _RecipeCardTile extends StatelessWidget {
  const _RecipeCardTile({
    required this.recipe,
    required this.selected,
    required this.onTap,
  });

  final Recipe recipe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : const Color(0xFFE0DED7);

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.34)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, size: 18),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                recipe.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 10),
              _RecipeQuickFacts(recipe: recipe),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                children: recipe.tags
                    .take(3)
                    .map((tag) => RecipeTagLabel(label: tag))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeLineTile extends StatelessWidget {
  const _RecipeLineTile({
    required this.recipe,
    required this.selected,
    required this.onTap,
  });

  final Recipe recipe;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final borderColor = selected
        ? colorScheme.primary
        : const Color(0xFFE0DED7);

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.34)
          : colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${recipe.totalMinutes} min · ${recipe.ingredients.length} ing.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              if (recipe.tags.isNotEmpty)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 92),
                  child: RecipeTagLabel(label: recipe.tags.first),
                ),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecipeQuickFacts extends StatelessWidget {
  const _RecipeQuickFacts({required this.recipe});

  final Recipe recipe;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 6,
      children: [
        _QuickFact(
          icon: Icons.people_alt_outlined,
          label: '${recipe.servings}',
        ),
        _QuickFact(
          icon: Icons.timer_outlined,
          label: '${recipe.totalMinutes} min',
        ),
        _QuickFact(
          icon: Icons.format_list_bulleted,
          label: '${recipe.ingredients.length}',
        ),
        _QuickFact(
          icon: Icons.bolt_outlined,
          label: '${recipe.nutrition.energyKcal.toStringAsFixed(0)} kcal',
        ),
      ],
    );
  }
}

class _QuickFact extends StatelessWidget {
  const _QuickFact({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: const Color(0xFF43473F),
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _EmptyBookMessage extends StatelessWidget {
  const _EmptyBookMessage();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(color: const Color(0xFFE0DED7)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.filter_alt_off_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(context.strings.noMatchingRecipes)),
          ],
        ),
      ),
    );
  }
}
