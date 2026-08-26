// Phase 09 Lot F — IngredientDetailCard (§6.4 du cahier Phase 09).
//
// Card Material 3 affichant le détail d'un ingrédient Phase 1 dans la
// vue détail recette. Remplace/affiche en plus du `_IngredientRow`
// existant quand `ingredientId` est lié à la DB.
//
// Contenu :
// - Nom canonique + nom scientifique (italique)
// - Catégorie breadcrumb
// - Allergènes (chips rouges)
// - Mini nutrition (top 4 : énergie, protéines, lipides, glucides)
// - Badges alcoolisé / fermenté
//
// R-07 : widget tests rédigés mais non exécutables en sandbox.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/ingredient_detail.dart';
import '../../../core/models/nutrition_profile.dart';
import '../../nutrition/data/nutrition_repository.dart';

/// Card de détail d'un ingrédient.
class IngredientDetailCard extends ConsumerWidget {
  const IngredientDetailCard({
    super.key,
    required this.detail,
    this.nutrition,
    this.strings = const _IngredientDetailStrings.fr(),
  });

  final IngredientDetail detail;

  /// Optionnel : nutrition agrégée pour 100 g (déjà chargée).
  final NutritionProfile? nutrition;

  /// Strings localisées (FR par défaut).
  final _IngredientDetailStrings strings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detail.canonicalNameFr,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      if (detail.scientificName != null)
                        Text(
                          detail.scientificName!,
                          style: theme.textTheme.bodySmall
                              ?.copyWith(fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: [
                    if (detail.isAlcoholic)
                      _Badge(
                        icon: Icons.local_bar_outlined,
                        label: strings.alcoholBadge,
                      ),
                    if (detail.isFermented)
                      _Badge(
                        icon: Icons.eco_outlined,
                        label: strings.fermentedBadge,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              detail.categoryBreadcrumb,
              style: theme.textTheme.bodySmall,
            ),
            if (detail.hasAllergens) ...[
              const SizedBox(height: 10),
              Text(strings.allergensTitle,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final a in detail.allergenTags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        a,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.red.shade900,
                        ),
                      ),
                    ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 6),
              Text(strings.noAllergens,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
            ],
            const SizedBox(height: 12),
            _MiniNutritionSection(
              nutrition: nutrition,
              strings: strings,
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.amber.shade900),
          const SizedBox(width: 2),
          Text(label,
              style: TextStyle(fontSize: 11, color: Colors.amber.shade900)),
        ],
      ),
    );
  }
}

class _MiniNutritionSection extends StatelessWidget {
  const _MiniNutritionSection({required this.nutrition, required this.strings});

  final NutritionProfile? nutrition;
  final _IngredientDetailStrings strings;

  @override
  Widget build(BuildContext context) {
    if (nutrition == null) {
      return Text(
        strings.nutritionUnavailable,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final n = nutrition!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.nutritionTitle,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _nutritionChip(strings.energy,
                '${n.energyKcal.toStringAsFixed(0)} kcal'),
            _nutritionChip(strings.proteins,
                '${n.proteins.toStringAsFixed(1)} g'),
            _nutritionChip(strings.fats,
                '${n.fats.toStringAsFixed(1)} g'),
            _nutritionChip(strings.carbs,
                '${n.carbs.toStringAsFixed(1)} g'),
          ],
        ),
      ],
    );
  }

  Widget _nutritionChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(fontSize: 11),
      ),
    );
  }
}

/// Strings localisées (FR par défaut).
class _IngredientDetailStrings {
  const _IngredientDetailStrings({
    this.alcoholBadge = 'Alcoolisé',
    this.fermentedBadge = 'Fermenté',
    this.allergensTitle = 'Allergènes',
    this.noAllergens = 'Aucun allergène déclaré',
    this.nutritionTitle = 'Nutrition · pour 100 g',
    this.nutritionUnavailable = 'Nutrition non disponible',
    this.energy = 'Énergie',
    this.proteins = 'Protéines',
    this.fats = 'Lipides',
    this.carbs = 'Glucides',
  });

  const _IngredientDetailStrings.fr();

  final String alcoholBadge;
  final String fermentedBadge;
  final String allergensTitle;
  final String noAllergens;
  final String nutritionTitle;
  final String nutritionUnavailable;
  final String energy;
  final String proteins;
  final String fats;
  final String carbs;
}

/// Helper public pour FutureBuilder d'un NutritionProfile depuis un
/// NutritionRepository. Réduit le boilerplate dans les widgets parents.
class NutritionFutureBuilder extends StatelessWidget {
  const NutritionFutureBuilder({
    super.key,
    required this.repository,
    required this.ingredientId,
    required this.builder,
  });

  final NutritionRepository repository;
  final String ingredientId;
  final Widget Function(BuildContext, AsyncSnapshot<NutritionProfile?>) builder;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<NutritionProfile?>(
      future: repository.forIngredient(ingredientId),
      builder: builder,
    );
  }
}
