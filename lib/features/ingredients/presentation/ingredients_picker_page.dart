// Phase 09 Lot F — IngredientsPickerPage (§6.3 du cahier Phase 09).
//
// Widget Material 3 de sélection d'un ingrédient depuis le référentiel
// Phase 1. Utilisé par `RecipeFormDialog` quand l'utilisateur tape sur
// un slot ingrédient.
//
// - SearchBar Material 3 (insensible à la casse, accents).
// - Chips horizontales de filtres par `category_level_1`.
// - Liste virtualisée des résultats.
// - Tap row → Navigator.pop avec l'`ingredientId` sélectionné.
//
// La recherche est alimentée par `IngredientAliasIndex` (fourni par
// `ingredientsProvider` — cf. Riverpod §10.1 F4).
//
// R-07 : widget tests rédigés mais non exécutables en sandbox (Flutter SDK absent).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ingredient_summary.dart';
import '../data/ingredient_alias_index.dart';

/// Provider Riverpod de l'index (singleton, construit au boot).
///
/// Sera câblé à l'AppDatabase dans `main.dart` au Lot suivant si besoin.
/// Pour Lot F, on garde un stub qui renvoie un index vide.
final ingredientsIndexProvider = Provider<IngredientAliasIndex>(
  (ref) => IngredientAliasIndex.fromSummaries(const <IngredientSummary>[]),
);

/// Provider Riverpod de la liste brute (pour tests).
final ingredientsRawProvider = Provider<List<IngredientSummary>>(
  (ref) => const <IngredientSummary>[],
);

/// Ouvre le picker en modal et renvoie l'`ingredientId` sélectionné, ou null.
Future<String?> showIngredientsPicker(
  BuildContext context, {
  required List<IngredientSummary> all,
  String? initialCategoryFilter,
}) {
  return Navigator.of(context).push<String>(
    MaterialPageRoute(
      fullscreenDialog: true,
      builder: (_) => ProviderScope(
        overrides: [
          ingredientsRawProvider.overrideWithValue(all),
        ],
        child: IngredientsPickerPage(
          initialCategoryFilter: initialCategoryFilter,
        ),
      ),
    ),
  );
}

/// Résultat d'un picker fallback (Lot F v1 sans DB).
class PickedIngredient {
  const PickedIngredient({required this.label, this.ingredientId});
  final String label;
  final String? ingredientId;
}

/// Fallback simple : un AlertDialog avec un TextField pour le label,
/// utilisé quand l'AppDatabase n'est pas accessible (Lot F v1 hors
/// contexte DB). Renvoie `null` si annulé.
Future<PickedIngredient?> showIngredientsPickerFallback(
  BuildContext context, {
  String? currentLabel,
}) async {
  final controller = TextEditingController(text: currentLabel ?? '');
  final result = await showDialog<PickedIngredient>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Saisir un ingrédient'),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(
          labelText: 'Nom de l\'ingrédient',
          hintText: 'Tomate, Basilic, …',
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () {
            final label = controller.text.trim();
            if (label.isEmpty) return;
            Navigator.of(ctx).pop(
              PickedIngredient(label: label, ingredientId: null),
            );
          },
          child: const Text('OK'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

/// Page picker principale.
class IngredientsPickerPage extends ConsumerStatefulWidget {
  const IngredientsPickerPage({
    super.key,
    this.initialCategoryFilter,
  });

  final String? initialCategoryFilter;

  @override
  ConsumerState<IngredientsPickerPage> createState() =>
      _IngredientsPickerPageState();
}

class _IngredientsPickerPageState extends ConsumerState<IngredientsPickerPage> {
  late final TextEditingController _searchController;
  String? _categoryFilter;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _categoryFilter = widget.initialCategoryFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = ref.watch(ingredientsRawProvider);

    // Liste des catégories distinctes
    final categories = <String>{
      for (final s in all) s.categoryLevel1,
    }.toList()
      ..sort();

    // Filtre catégorie
    final filtered = _categoryFilter == null
        ? all
        : all.where((s) => s.categoryLevel1 == _categoryFilter).toList();

    // Index à la volée (le cahier §11.2 prévoit un cache, mais ici on
    // rebuild à chaque frappe pour la simplicité de Lot F).
    final index = IngredientAliasIndex.fromSummaries(filtered);
    final results = index.search(_query, limit: 50);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choisir un ingrédient'),
        actions: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            tooltip: 'Fermer',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SearchBar(
              controller: _searchController,
              hintText: 'Rechercher (tomate, basilic…)',
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() => _query = value);
              },
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('Toutes'),
                    selected: _categoryFilter == null,
                    onSelected: (_) {
                      setState(() => _categoryFilter = null);
                    },
                  );
                }
                final cat = categories[index - 1];
                return FilterChip(
                  label: Text(cat),
                  selected: _categoryFilter == cat,
                  onSelected: (_) {
                    setState(() => _categoryFilter = cat);
                  },
                );
              },
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: results.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'Aucun ingrédient ne correspond.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: results.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final s = results[index];
                      return _IngredientRow(summary: s);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({required this.summary});

  final IngredientSummary summary;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        summary.canonicalNameFr,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(summary.categoryBreadcrumb),
      trailing: Wrap(
        spacing: 4,
        children: [
          if (summary.isAlcoholic)
            const Icon(Icons.local_bar_outlined, size: 18),
          if (summary.isFermented)
            const Icon(Icons.eco_outlined, size: 18),
          if (summary.hasAllergens)
            Tooltip(
              message: 'Allergènes : ${summary.allergenTags.join(", ")}',
              child: const Icon(Icons.warning_amber_outlined,
                  color: Colors.orange, size: 18),
            ),
        ],
      ),
      onTap: () => Navigator.of(context).pop(summary.ingredientId),
    );
  }
}
