import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Tags des micronutriments par groupe d'affichage.
const Set<String> kMineralTags = {
  'CA',
  'FE',
  'K',
  'MG',
  'P',
  'ZN',
  'CU',
  'MN',
  'SE',
  'I',
  'CL',
};
const Set<String> kVitaminTags = {
  'VITA',
  'CAROTENE_B',
  'VITD',
  'VITE',
  'VITK',
  'VITC',
  'THIAMIN',
  'RIBOFLAVINE',
  'NIACINE',
  'VITB5',
  'VITB6',
  'FOLATES',
  'VITB12',
  'BIOTINE',
  'CHOLINE',
};

class RecipeNutritionPanel extends StatelessWidget {
  const RecipeNutritionPanel({
    required this.nutrition,
    this.computedFromIngredients,
    this.totalIngredients,
    this.sources = const <NutritionSource>[],
    this.alcoholPerServing = 0,
    this.micronutrientsPerServing = const <String, Micronutrient>{},
    super.key,
  });

  final NutritionSummary nutrition;

  /// Lot G (G2) — nombre d'ingrédients dont le profil a été résolu en
  /// base et agrégé. Quand non null, le panneau affiche
  /// « Calculé depuis N ingrédients sur M » ; sinon
  /// « Valeur saisie manuellement ».
  final int? computedFromIngredients;

  /// Nombre total d'ingrédients de la recette (M du badge G2).
  final int? totalIngredients;

  /// Sources des records nutritionnels consommés (retour PO
  /// 2026-08-26 : citer les sources in-app). Vide → ligne masquée.
  final List<NutritionSource> sources;

  /// Alcool (g) par portion — affiché si > 0 (retour PO n°3).
  final double alcoholPerServing;

  /// Minéraux / vitamines / autres constituants par portion (retour PO
  /// n°3 : exhaustivité), clé = tag canonique.
  final Map<String, Micronutrient> micronutrientsPerServing;

  @override
  Widget build(BuildContext context) {
    final maxMacro = [
      nutrition.proteins,
      nutrition.carbs,
      nutrition.fats,
    ].reduce((a, b) => a > b ? a : b).clamp(1, double.infinity).toDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_heart_outlined, size: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.strings.nutrition,
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                _SourceBadge(
                  computedFrom: computedFromIngredients,
                  total: totalIngredients,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              computedFromIngredients != null && computedFromIngredients! > 0
                  ? context.strings.nutritionComputedFrom(
                      computedFromIngredients!,
                      totalIngredients ?? computedFromIngredients!,
                    )
                  : context.strings.nutritionManualEntry,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (sources.isNotEmpty) ...[
              const SizedBox(height: 2),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${context.strings.nutritionSources} :',
                    style: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  for (final source in sources)
                    Tooltip(
                      message: source.citation ?? source.displayLabel,
                      child: Text(
                        source.displayLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          decoration: TextDecoration.underline,
                          decorationStyle: TextDecorationStyle.dotted,
                        ),
                      ),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            _EnergyBlock(value: nutrition.energyKcal),
            const SizedBox(height: 16),
            Column(
              children: [
                _MacroLine(
                  label: context.strings.proteins,
                  value: nutrition.proteins,
                  unit: 'g',
                  ratio: nutrition.proteins / maxMacro,
                  color: const Color(0xFF357A5B),
                ),
                _MacroLine(
                  label: context.strings.carbs,
                  value: nutrition.carbs,
                  unit: 'g',
                  ratio: nutrition.carbs / maxMacro,
                  color: const Color(0xFFD9A441),
                ),
                _MacroLine(
                  label: context.strings.fats,
                  value: nutrition.fats,
                  unit: 'g',
                  ratio: nutrition.fats / maxMacro,
                  color: const Color(0xFFB85C45),
                ),
                const Divider(height: 22),
                _NutrientLine(
                  label: context.strings.fiber,
                  value: nutrition.fiber,
                  unit: 'g',
                ),
                _NutrientLine(
                  label: context.strings.salt,
                  value: nutrition.salt,
                  unit: 'g',
                ),
                if (alcoholPerServing > 0)
                  _NutrientLine(
                    label: context.strings.alcoholLabel,
                    value: alcoholPerServing,
                    unit: 'g',
                  ),
              ],
            ),
            if (micronutrientsPerServing.isNotEmpty) ...[
              _MicroSection(
                title: context.strings.mineralsTitle,
                entries: _sortedMicros(
                  micronutrientsPerServing,
                  where: (tag) => kMineralTags.contains(tag),
                ),
              ),
              _MicroSection(
                title: context.strings.vitaminsTitle,
                entries: _sortedMicros(
                  micronutrientsPerServing,
                  where: (tag) => kVitaminTags.contains(tag),
                ),
              ),
              _MicroSection(
                title: context.strings.otherConstituentsTitle,
                entries: _sortedMicros(
                  micronutrientsPerServing,
                  where: (tag) =>
                      !kMineralTags.contains(tag) &&
                      !kVitaminTags.contains(tag),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static List<Micronutrient> _sortedMicros(
    Map<String, Micronutrient> micros, {
    required bool Function(String tag) where,
  }) {
    final list = micros.values.where((m) => where(m.tag)).toList()
      ..sort((a, b) => a.tag.compareTo(b.tag));
    return list;
  }
}

/// Section repliable de micronutriments (valeurs par portion).
class _MicroSection extends StatelessWidget {
  const _MicroSection({required this.title, required this.entries});

  final String title;
  final List<Micronutrient> entries;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 22),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: EdgeInsets.zero,
            childrenPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              '$title (${entries.length})',
              style: Theme.of(context).textTheme.labelLarge
                  ?.copyWith(fontWeight: FontWeight.w800),
            ),
            children: [
              for (final micro in entries)
                _NutrientLine(
                  label: micro.name,
                  value: micro.value,
                  unit: micro.unit,
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SourceBadge extends StatelessWidget {
  const _SourceBadge({required this.computedFrom, required this.total});

  final int? computedFrom;
  final int? total;

  @override
  Widget build(BuildContext context) {
    final computed = computedFrom != null && computedFrom! > 0;
    final label = computed
        ? context.strings.nutritionComputedFrom(
            computedFrom!,
            total ?? computedFrom!,
          )
        : context.strings.nutritionManualEntry;
    return Tooltip(
      message: label,
      child: Icon(
        computed ? Icons.calculate_outlined : Icons.edit_note,
        size: 16,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _EnergyBlock extends StatelessWidget {
  const _EnergyBlock({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer
            .withValues(alpha: 0.54),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.bolt_outlined),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                context.strings.energy,
                style: Theme.of(context).textTheme.labelLarge
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} kcal',
              style: Theme.of(context).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _MacroLine extends StatelessWidget {
  const _MacroLine({
    required this.label,
    required this.value,
    required this.unit,
    required this.ratio,
    required this.color,
  });

  final String label;
  final double value;
  final String unit;
  final double ratio;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Text(
                '${value.toStringAsFixed(value < 10 ? 1 : 0)} $unit',
                style: Theme.of(context).textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: ratio.clamp(0, 1).toDouble(),
              minHeight: 8,
              color: color,
              backgroundColor: const Color(0xFFECE7DC),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientLine extends StatelessWidget {
  const _NutrientLine({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final double value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            '${value.toStringAsFixed(value < 10 ? 1 : 0)} $unit',
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
