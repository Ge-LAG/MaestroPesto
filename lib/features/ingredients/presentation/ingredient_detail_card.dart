// Phase 09 Lot F — IngredientDetailCard (§6.4 du cahier Phase 09).
//
// Card Material 3 affichant le détail d'un ingrédient Phase 1 dans la
// vue détail recette. Affichée sous le `_IngredientRow` existant quand
// `ingredientId` est lié à la DB.
//
// Contenu :
// - Nom canonique + nom scientifique (italique)
// - Catégorie breadcrumb
// - Allergènes (chips rouges)
// - Mini nutrition (top 4 : énergie, protéines, lipides, glucides)
// - Badges alcoolisé / fermenté

import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';

import '../../../core/models/ingredient_detail.dart';
import '../../../core/models/nutrition_profile.dart';
import '../../nutrition/data/nutrition_repository.dart';

/// Card de détail d'un ingrédient.
class IngredientDetailCard extends StatelessWidget {
  const IngredientDetailCard({super.key, required this.detail, this.nutrition});

  final IngredientDetail detail;

  /// Optionnel : nutrition pour 100 g (déjà chargée).
  final NutritionProfile? nutrition;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = context.strings;
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
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (detail.scientificName != null)
                        Text(
                          detail.scientificName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                          ),
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
                        label: strings.ingredientDetailAlcoholBadge,
                      ),
                    if (detail.isFermented)
                      _Badge(
                        icon: Icons.eco_outlined,
                        label: strings.ingredientDetailFermentedBadge,
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(detail.categoryBreadcrumb, style: theme.textTheme.bodySmall),
            if (detail.hasAllergens) ...[
              const SizedBox(height: 10),
              Text(
                strings.ingredientDetailAllergensTitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  for (final a in detail.allergenTags)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
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
              Text(
                strings.ingredientDetailNoAllergens,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            const SizedBox(height: 12),
            _MiniNutritionSection(nutrition: nutrition),
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
          Text(
            label,
            style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
          ),
        ],
      ),
    );
  }
}

class _MiniNutritionSection extends StatelessWidget {
  const _MiniNutritionSection({required this.nutrition});

  final NutritionProfile? nutrition;

  @override
  Widget build(BuildContext context) {
    final strings = context.strings;
    if (nutrition == null) {
      return Text(
        strings.ingredientDetailNutritionUnavailable,
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    final n = nutrition!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.ingredientDetailNutritionTitle,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: [
            _nutritionChip(
              strings.ingredientDetailEnergy,
              '${n.energyKcal.toStringAsFixed(0)} kcal',
            ),
            _nutritionChip(
              strings.ingredientDetailProteins,
              '${n.proteins.toStringAsFixed(1)} g',
            ),
            _nutritionChip(
              strings.ingredientDetailFats,
              '${n.fats.toStringAsFixed(1)} g',
            ),
            _nutritionChip(
              strings.ingredientDetailCarbs,
              '${n.carbs.toStringAsFixed(1)} g',
            ),
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
      child: Text('$label: $value', style: const TextStyle(fontSize: 11)),
    );
  }
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
