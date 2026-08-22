import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_book_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_detail_view.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_form_dialog.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  final List<Recipe> _recipes = List<Recipe>.from(demoRecipes);
  String _query = '';
  final Set<String> _selectedTags = {};
  String _selectedRecipeId = demoRecipes.first.id;

  List<String> get _tags {
    final tags = _recipes.expand((recipe) => recipe.tags).toSet().toList();
    tags.sort();
    return tags;
  }

  List<Recipe> get _filteredRecipes {
    final normalizedQuery = _query.trim().toLowerCase();
    return _recipes.where((recipe) {
      final matchesQuery = normalizedQuery.isEmpty ||
          '${recipe.title} ${recipe.description} ${recipe.tags.join(' ')}'
              .toLowerCase()
              .contains(normalizedQuery);
      final matchesTag =
          _selectedTags.isEmpty || recipe.tags.any(_selectedTags.contains);
      return matchesQuery && matchesTag;
    }).toList();
  }

  Recipe? get _selectedRecipe {
    final filteredRecipes = _filteredRecipes;
    if (filteredRecipes.isEmpty) {
      return null;
    }

    return filteredRecipes.firstWhere(
      (recipe) => recipe.id == _selectedRecipeId,
      orElse: () => filteredRecipes.first,
    );
  }

  void _selectRecipe(String recipeId) {
    setState(() => _selectedRecipeId = recipeId);
  }

  void _setSelectedTags(Set<String> tags) {
    setState(() {
      _selectedTags
        ..clear()
        ..addAll(tags);
    });
  }

  Future<void> _createRecipe() async {
    final recipe = await showRecipeFormDialog(
      context: context,
      title: context.strings.createRecipeDialogTitle,
      recipe: _emptyRecipe(),
    );
    if (recipe == null) {
      return;
    }

    setState(() {
      _recipes.insert(0, recipe);
      _selectedRecipeId = recipe.id;
      _selectedTags.clear();
      _query = '';
    });
  }

  Future<void> _editRecipe(Recipe recipe) async {
    final edited = await showRecipeFormDialog(
      context: context,
      title: context.strings.editRecipeDialogTitle,
      recipe: recipe,
    );
    if (edited == null) {
      return;
    }

    setState(() {
      final index = _recipes.indexWhere((item) => item.id == edited.id);
      if (index != -1) {
        _recipes[index] = edited;
      }
      _selectedRecipeId = edited.id;
    });
  }

  Future<void> _deleteRecipe(Recipe recipe) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.strings.deleteRecipeDialogTitle),
        content: Text(context.strings.deleteRecipeConfirmation(recipe.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.strings.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: Text(context.strings.deleteAction),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _recipes.removeWhere((item) => item.id == recipe.id);
      _selectedRecipeId = _recipes.isEmpty ? '' : _recipes.first.id;
    });
  }

  Recipe _emptyRecipe() {
    return Recipe(
      id: 'recipe-${DateTime.now().microsecondsSinceEpoch}',
      title: context.strings.newRecipe,
      description: '',
      tags: const [],
      servings: 4,
      prepMinutes: 10,
      cookMinutes: 0,
      ingredients: const [],
      steps: const [],
      nutrition: const NutritionSummary(
        energyKcal: 0,
        proteins: 0,
        carbs: 0,
        fats: 0,
        fiber: 0,
        salt: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 760;
            final isWide = width >= 1120;
            final selectedRecipe = _selectedRecipe;

            if (isCompact) {
              return _CompactLayout(
                recipes: _filteredRecipes,
                selectedRecipe: selectedRecipe,
                selectedTags: _selectedTags,
                tags: _tags,
                query: _query,
                onQueryChanged: (value) => setState(() => _query = value),
                onRecipeSelected: _selectRecipe,
                onTagsChanged: _setSelectedTags,
                onCreateRecipe: _createRecipe,
                onEditRecipe: _editRecipe,
                onDeleteRecipe: _deleteRecipe,
              );
            }

            return Row(
              children: [
                SizedBox(
                  width: isWide ? 360 : 320,
                  child: RecipeBookPanel(
                    recipes: _filteredRecipes,
                    selectedRecipeId: selectedRecipe?.id ?? '',
                    tags: _tags,
                    selectedTags: _selectedTags,
                    query: _query,
                    onQueryChanged: (value) => setState(() => _query = value),
                    onRecipeSelected: _selectRecipe,
                    onTagsChanged: _setSelectedTags,
                    onCreateRecipe: _createRecipe,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedRecipe == null
                      ? EmptyRecipeState(onCreateRecipe: _createRecipe)
                      : RecipeDetailView(
                          recipe: selectedRecipe,
                          isWide: isWide,
                          onEdit: _editRecipe,
                          onDelete: _deleteRecipe,
                        ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CompactLayout extends StatelessWidget {
  const _CompactLayout({
    required this.recipes,
    required this.selectedRecipe,
    required this.selectedTags,
    required this.tags,
    required this.query,
    required this.onQueryChanged,
    required this.onRecipeSelected,
    required this.onTagsChanged,
    required this.onCreateRecipe,
    required this.onEditRecipe,
    required this.onDeleteRecipe,
  });

  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  final Set<String> selectedTags;
  final List<String> tags;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onRecipeSelected;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onCreateRecipe;
  final ValueChanged<Recipe> onEditRecipe;
  final ValueChanged<Recipe> onDeleteRecipe;

  @override
  Widget build(BuildContext context) {
    final recipe = selectedRecipe;

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: RecipeBookPanel(
            recipes: recipes,
            selectedRecipeId: recipe?.id ?? '',
            tags: tags,
            selectedTags: selectedTags,
            query: query,
            onQueryChanged: onQueryChanged,
            onRecipeSelected: onRecipeSelected,
            onTagsChanged: onTagsChanged,
            onCreateRecipe: onCreateRecipe,
            compact: true,
          ),
        ),
        SliverToBoxAdapter(
          child: recipe == null
              ? EmptyRecipeState(onCreateRecipe: onCreateRecipe)
              : RecipeDetailView(
                  recipe: recipe,
                  isWide: false,
                  scrollable: false,
                  onEdit: onEditRecipe,
                  onDelete: onDeleteRecipe,
                ),
        ),
      ],
    );
  }
}

class EmptyRecipeState extends StatelessWidget {
  const EmptyRecipeState({
    required this.onCreateRecipe,
    super.key,
  });

  final VoidCallback onCreateRecipe;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.strings.noRecipeTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.strings.noRecipeBody,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: onCreateRecipe,
                    icon: const Icon(Icons.add),
                    label: Text(context.strings.newRecipe),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
