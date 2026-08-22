import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

class RecipeNutritionPanel extends StatelessWidget {
  const RecipeNutritionPanel({
    required this.nutrition,
    super.key,
  });

  final NutritionSummary nutrition;

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
                const Icon(Icons.monitor_heart_outlined, size: 19),
                const SizedBox(width: 8),
                Text(
                  context.strings.nutrition,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _EnergyBlock(value: nutrition.energyKcal),
            const SizedBox(height: 16),
            Column(
              children: [
                _NutrientLine(label: context.strings.proteins, value: nutrition.proteins, unit: 'g'),
                _NutrientLine(label: context.strings.carbs, value: nutrition.carbs, unit: 'g'),
                _NutrientLine(label: context.strings.fats, value: nutrition.fats, unit: 'g'),
                _NutrientLine(label: context.strings.fiber, value: nutrition.fiber, unit: 'g'),
                _NutrientLine(label: context.strings.salt, value: nutrition.salt, unit: 'g'),
              ],
            ),
          ],
        ),
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
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.54),
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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
            ),
            Text(
              '${value.toStringAsFixed(0)} kcal',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
          ],
        ),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          Text(
            '${value.toStringAsFixed(value < 10 ? 1 : 0)} $unit',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
        ],
      ),
    );
  }
}
