import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/features/analysis/data/metier_reference.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';
import 'package:maestropesto/features/recipes/data/recipes_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_book_panel.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_detail_view.dart';
import 'package:maestropesto/features/sources/presentation/data_sources_page.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_form_dialog.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({required this.services, super.key});

  /// Services bundle (Lot E): owns the [AppDatabase] and the
  /// [CsvImportService]. The button in the AppBar uses this to import
  /// the 4 metier CSVs and to expose the metier advisory panel in the
  /// recipe detail view.
  final AppServices services;

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  final List<Recipe> _recipes = <Recipe>[];
  String _query = '';
  final Set<String> _selectedTags = {};
  String _selectedRecipeId = '';

  bool _importing = false;

  /// Étape courante de l'import (index dans AppServices.importPhases).
  int _importStep = 0;
  bool _metierLoaded = false;
  bool _loadingRecipes = true;

  /// Version des données métier : incrémentée après un import pour
  /// relancer les analyses affichées.
  int _dataVersion = 0;

  late final RecipesRepository _repository = RecipesRepository(
    widget.services.db,
  );

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  /// Phase 10 (ac-125) : les recettes sont persistées. Au premier
  /// lancement, les recettes de démonstration sont semées ; les bases
  /// métier embarquées sont (ré)importées en arrière-plan — import
  /// sauté si leurs empreintes n'ont pas changé.
  Future<void> _bootstrap() async {
    await _reloadRecipes();
    final loaded = await widget.services.isMetierLoaded();
    if (!mounted) return;
    setState(() => _metierLoaded = loaded);
    if (widget.services.autoImportMetier) {
      await _importMetier(context, silentWhenUpToDate: true);
    }
    // Les démos référencent le référentiel (clés étrangères) : semées
    // seulement une fois celui-ci importé.
    if (await widget.services.isMetierLoaded()) {
      final seeded = await _repository.seedDemoRecipesOnce(demoRecipes);
      if (seeded) {
        // Affichage immédiat, puis nutrition stockée calculée.
        await _reloadRecipes();
        await _refreshComputedNutrition();
      }
    }
  }

  /// Nutrition stockée (liste, export) des recettes en mode calculé :
  /// recalculée après le semis des démos et après chaque import qui a
  /// modifié le référentiel.
  Future<void> _refreshComputedNutrition() async {
    final service = RecipeAnalysisService(widget.services.db);
    try {
      for (final recipe in await _repository.listAll()) {
        final updated = await service.refreshStoredNutrition(recipe);
        if (updated != null) await _repository.save(updated, touch: false);
      }
    } catch (e, st) {
      debugPrint('Recalcul nutritionnel impossible : $e\n$st');
    }
    await _reloadRecipes();
  }

  Future<void> _reloadRecipes() async {
    try {
      final recipes = await _repository.listAll();
      if (!mounted) return;
      setState(() {
        _recipes
          ..clear()
          ..addAll(recipes);
        if (!_recipes.any((r) => r.id == _selectedRecipeId)) {
          _selectedRecipeId = recipes.isEmpty ? '' : recipes.first.id;
        }
        _loadingRecipes = false;
      });
    } catch (e, st) {
      debugPrint('Chargement des recettes impossible : $e\n$st');
      if (mounted) setState(() => _loadingRecipes = false);
    }
  }

  Future<void> _persist(Recipe recipe) async {
    try {
      await _repository.save(recipe);
    } catch (e) {
      debugPrint('Enregistrement impossible : $e');
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Enregistrement impossible : $e')));
    }
  }

  List<String> get _tags {
    final tags = _recipes.expand((recipe) => recipe.tags).toSet().toList();
    tags.sort();
    return tags;
  }

  List<Recipe> get _filteredRecipes {
    final normalizedQuery = _query.trim().toLowerCase();
    return _recipes.where((recipe) {
      final matchesQuery =
          normalizedQuery.isEmpty ||
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

  void _clearFilters() {
    setState(() {
      _query = '';
      _selectedTags.clear();
    });
  }

  Future<void> _createRecipe() async {
    final recipe = await showRecipeFormDialog(
      context: context,
      title: context.strings.createRecipeDialogTitle,
      recipe: _emptyRecipe(),
      db: widget.services.db,
    );
    if (recipe == null) {
      return;
    }
    await _persist(recipe);
    if (!mounted) return;

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
      db: widget.services.db,
    );
    if (edited == null) {
      return;
    }
    await _persist(edited);
    if (!mounted) return;

    setState(() {
      final index = _recipes.indexWhere((item) => item.id == edited.id);
      if (index != -1) {
        _recipes[index] = edited;
      }
      _selectedRecipeId = edited.id;
    });
  }

  /// Accord suggéré ajouté depuis l'onglet « Arômes » : l'éditeur
  /// s'ouvre avec la nouvelle ligne, à doser avant d'enregistrer.
  Future<void> _addIngredient(Recipe recipe, RecipeIngredient ingredient) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.strings.flavorSuggestionAdded(ingredient.label)),
      ),
    );
    return _editRecipe(
      recipe.copyWith(ingredients: [...recipe.ingredients, ingredient]),
    );
  }

  Future<void> _duplicateRecipe(Recipe recipe) async {
    final duplicated = recipe.copyWith(
      id: 'recipe-${DateTime.now().microsecondsSinceEpoch}',
      title: context.strings.duplicateRecipeTitle(recipe.title),
      ingredients: List<RecipeIngredient>.from(recipe.ingredients),
      steps: List<String>.from(recipe.steps),
      tags: List<String>.from(recipe.tags),
      images: List<RecipeImage>.from(recipe.images),
    );
    await _persist(duplicated);
    if (!mounted) return;

    setState(() {
      final index = _recipes.indexWhere((item) => item.id == recipe.id);
      _recipes.insert(index == -1 ? 0 : index + 1, duplicated);
      _selectedRecipeId = duplicated.id;
      _query = '';
      _selectedTags.clear();
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
    await _repository.delete(recipe.id);
    if (!mounted) return;

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
      images: const [],
    );
  }

  // Lot E / Phase 10 — import des bases métier (bouton de l'AppBar et
  // démarrage automatique). L'icône reflète 3 états :
  //   * _importing=true   → spinner
  //   * _metierLoaded=true → check_circle (vert)
  //   * sinon             → storage_outlined (neutre)
  Future<void> _importMetier(
    BuildContext context, {
    bool silentWhenUpToDate = false,
  }) async {
    if (_importing) {
      return;
    }
    setState(() {
      _importing = true;
      _importStep = 0;
    });
    final messenger = ScaffoldMessenger.of(context);
    try {
      final report = await widget.services.importMetier(
        onPhaseProgress: (phase, _) {
          final i = AppServices.importPhases.indexWhere((p) => p.$1 == phase);
          if (i >= 0 && i != _importStep && mounted) {
            setState(() => _importStep = i);
          }
        },
      );
      final loaded = await widget.services.isMetierLoaded();
      if (!mounted) {
        return;
      }
      final allSkipped = report.skipped.values.every((skipped) => skipped);
      if (!allSkipped) {
        // Données modifiées : caches de référence et analyses à refaire.
        MetierReference.invalidate(widget.services.db);
      }
      setState(() {
        _metierLoaded = loaded;
        _importing = false;
        if (!allSkipped) _dataVersion++;
      });
      if (!allSkipped) await _refreshComputedNutrition();
      if (allSkipped && silentWhenUpToDate) return;
      final totalImported = report.rowsImported.values.fold<int>(
        0,
        (sum, n) => sum + n,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            allSkipped
                ? 'Bases métier déjà à jour.'
                : 'Bases métier mises à jour ($totalImported nouvelles lignes).',
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('CsvImportService failed: $e\n$st');
      if (!mounted) {
        return;
      }
      setState(() => _importing = false);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Erreur import BDD métier : $e'),
          backgroundColor: Theme.of(this.context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const SizedBox.shrink(),
        actions: [
          IconButton(
            tooltip: context.strings.sourcesTitle,
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () => showDataSourcesPage(context),
          ),
          _MetierStatusAction(
            importing: _importing,
            metierLoaded: _metierLoaded,
            onImport: () => _importMetier(context),
          ),
        ],
        bottom: _importing
            ? _ImportProgressBar(step: _importStep, firstLaunch: !_metierLoaded)
            : null,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isCompact = width < 760;
            final isWide = width >= 1120;
            final selectedRecipe = _selectedRecipe;
            if (_loadingRecipes) {
              return const Center(child: CircularProgressIndicator());
            }

            if (isCompact) {
              return _CompactLayout(
                services: widget.services,
                dataVersion: _dataVersion,
                recipes: _filteredRecipes,
                selectedRecipe: selectedRecipe,
                selectedTags: _selectedTags,
                tags: _tags,
                query: _query,
                onQueryChanged: (value) => setState(() => _query = value),
                onRecipeSelected: _selectRecipe,
                onTagsChanged: _setSelectedTags,
                onClearFilters: _clearFilters,
                onCreateRecipe: _createRecipe,
                onEditRecipe: _editRecipe,
                onDuplicateRecipe: _duplicateRecipe,
                onDeleteRecipe: _deleteRecipe,
                onAddIngredient: _addIngredient,
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                    onClearFilters: _clearFilters,
                    onCreateRecipe: _createRecipe,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(
                  child: selectedRecipe == null
                      ? EmptyRecipeState(onCreateRecipe: _createRecipe)
                      : RecipeDetailView(
                          key: ValueKey('${selectedRecipe.id}@$_dataVersion'),
                          recipe: selectedRecipe,
                          isWide: isWide,
                          db: widget.services.db,
                          onEdit: _editRecipe,
                          onDuplicate: _duplicateRecipe,
                          onDelete: _deleteRecipe,
                          onAddIngredient: (ingredient) =>
                              _addIngredient(selectedRecipe, ingredient),
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
    required this.services,
    required this.dataVersion,
    required this.recipes,
    required this.selectedRecipe,
    required this.selectedTags,
    required this.tags,
    required this.query,
    required this.onQueryChanged,
    required this.onRecipeSelected,
    required this.onTagsChanged,
    required this.onClearFilters,
    required this.onCreateRecipe,
    required this.onEditRecipe,
    required this.onDuplicateRecipe,
    required this.onDeleteRecipe,
    required this.onAddIngredient,
  });

  final AppServices services;
  final int dataVersion;
  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  final Set<String> selectedTags;
  final List<String> tags;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onRecipeSelected;
  final ValueChanged<Set<String>> onTagsChanged;
  final VoidCallback onClearFilters;
  final VoidCallback onCreateRecipe;
  final ValueChanged<Recipe> onEditRecipe;
  final ValueChanged<Recipe> onDuplicateRecipe;
  final ValueChanged<Recipe> onDeleteRecipe;
  final void Function(Recipe recipe, RecipeIngredient ingredient)
  onAddIngredient;

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
            onClearFilters: onClearFilters,
            onCreateRecipe: onCreateRecipe,
            compact: true,
          ),
        ),
        SliverToBoxAdapter(
          child: recipe == null
              ? EmptyRecipeState(onCreateRecipe: onCreateRecipe)
              : RecipeDetailView(
                  key: ValueKey('${recipe.id}@$dataVersion'),
                  recipe: recipe,
                  isWide: false,
                  scrollable: false,
                  db: services.db,
                  onEdit: onEditRecipe,
                  onDuplicate: onDuplicateRecipe,
                  onDelete: onDeleteRecipe,
                  onAddIngredient: (ingredient) =>
                      onAddIngredient(recipe, ingredient),
                ),
        ),
      ],
    );
  }
}

class _MetierStatusAction extends StatelessWidget {
  const _MetierStatusAction({
    required this.onImport,
    required this.importing,
    required this.metierLoaded,
  });

  final VoidCallback onImport;
  final bool importing;
  final bool metierLoaded;

  @override
  Widget build(BuildContext context) {
    if (importing) {
      return IconButton(
        tooltip: context.strings.importMetierRunning,
        icon: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        onPressed: null,
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final IconData icon = metierLoaded
        ? Icons.check_circle_outline
        : Icons.storage_outlined;
    final Color color = metierLoaded ? const Color(0xFF357A5B) : scheme.primary;
    final String tooltip = metierLoaded
        ? context.strings.importMetierReady
        : context.strings.importMetierPending;
    return IconButton(
      tooltip: tooltip,
      icon: Icon(icon, color: color),
      onPressed: onImport,
    );
  }
}

class EmptyRecipeState extends StatelessWidget {
  const EmptyRecipeState({required this.onCreateRecipe, super.key});

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
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
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

/// Progression de l'import des bases métier (premier lancement ou
/// réimport) : barre et étape en cours, sous la barre d'application.
class _ImportProgressBar extends StatelessWidget
    implements PreferredSizeWidget {
  const _ImportProgressBar({required this.step, required this.firstLaunch});

  final int step;
  final bool firstLaunch;

  @override
  Size get preferredSize => const Size.fromHeight(30);

  @override
  Widget build(BuildContext context) {
    final phases = AppServices.importPhases;
    final total = phases.length;
    final current = step.clamp(0, total - 1);
    final theme = Theme.of(context);
    return SizedBox(
      height: 30,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LinearProgressIndicator(value: (current + 0.5) / total, minHeight: 3),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${firstLaunch ? 'Préparation des bases métier (premier lancement)' : 'Mise à jour des bases métier'}'
                  ' — ${phases[current].$2} (${current + 1}/$total)…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
