import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/core/scoring/nutrition_feedback.dart';
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
    this.coverage,
    this.intakePercents = const <String, double>{},
    this.nutriScore,
    this.nutriScoreNote,
    this.subtitle,
    this.footer = const <Widget>[],
    this.sugars,
    this.saturatedFats,
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

  /// Phase 10 — couverture massique par nutriment (null = saisie
  /// manuelle). 0 → « non renseigné » (jamais un zéro fabriqué).
  final Map<MacroField, double>? coverage;

  /// % des apports de référence par clé (energy, proteins, carbs, fats,
  /// fiber, salt, ou tag de micronutriment).
  final Map<String, double> intakePercents;

  /// Nutri-Score estimé (null = non calculé, voir [nutriScoreNote]).
  final NutriScoreResult? nutriScore;
  final String? nutriScoreNote;

  /// Ligne d'information sous le titre (masse de portion, procédé…).
  final String? subtitle;

  /// Sections additionnelles (feedback, détail, limites).
  final List<Widget> footer;

  /// Sous-lignes « dont sucres » et « dont AGS » (null = masquées).
  final double? sugars;
  final double? saturatedFats;

  double? _coverage(MacroField field) => coverage?[field];

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
                  for (final (i, source) in sources.indexed)
                    Tooltip(
                      message: source.citation ?? source.displayLabel,
                      child: Text(
                        '${source.displayLabel}${i < sources.length - 1 ? ' ·' : ''}',
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
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
            ],
            if (nutriScore != null || nutriScoreNote != null) ...[
              const SizedBox(height: 12),
              NutriScoreBadge(result: nutriScore, note: nutriScoreNote),
            ],
            const SizedBox(height: 18),
            _EnergyBlock(
              value: nutrition.energyKcal,
              coverage: _coverage(MacroField.energy),
              percent: intakePercents['energy'],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _MacroLine(
                  label: context.strings.proteins,
                  value: nutrition.proteins,
                  unit: 'g',
                  ratio: nutrition.proteins / maxMacro,
                  color: const Color(0xFF357A5B),
                  coverage: _coverage(MacroField.proteins),
                  percent: intakePercents['proteins'],
                ),
                _MacroLine(
                  label: context.strings.carbs,
                  value: nutrition.carbs,
                  unit: 'g',
                  ratio: nutrition.carbs / maxMacro,
                  color: const Color(0xFFD9A441),
                  coverage: _coverage(MacroField.carbs),
                  percent: intakePercents['carbs'],
                ),
                if (sugars != null)
                  _SubLine(
                    label: 'dont sucres',
                    value: sugars!,
                    coverage: _coverage(MacroField.sugars),
                    percent: intakePercents['sugars'],
                  ),
                _MacroLine(
                  label: context.strings.fats,
                  value: nutrition.fats,
                  unit: 'g',
                  ratio: nutrition.fats / maxMacro,
                  color: const Color(0xFFB85C45),
                  coverage: _coverage(MacroField.fats),
                  percent: intakePercents['fats'],
                ),
                if (saturatedFats != null)
                  _SubLine(
                    label: 'dont acides gras saturés',
                    value: saturatedFats!,
                    coverage: _coverage(MacroField.saturatedFats),
                    percent: intakePercents['saturatedFats'],
                  ),
                const Divider(height: 22),
                _NutrientLine(
                  label: context.strings.fiber,
                  value: nutrition.fiber,
                  unit: 'g',
                  coverage: _coverage(MacroField.fiber),
                  percent: intakePercents['fiber'],
                ),
                _NutrientLine(
                  label: context.strings.salt,
                  value: nutrition.salt,
                  unit: 'g',
                  coverage: _coverage(MacroField.salt),
                  percent: intakePercents['salt'],
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
                percents: intakePercents,
              ),
              _MicroSection(
                title: context.strings.vitaminsTitle,
                entries: _sortedMicros(
                  micronutrientsPerServing,
                  where: (tag) => kVitaminTags.contains(tag),
                ),
                percents: intakePercents,
              ),
              _MicroSection(
                title: context.strings.otherConstituentsTitle,
                entries: _sortedMicros(
                  micronutrientsPerServing,
                  where: (tag) =>
                      !kMineralTags.contains(tag) &&
                      !kVitaminTags.contains(tag),
                ),
                percents: intakePercents,
              ),
            ],
            ...footer,
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
  const _MicroSection({
    required this.title,
    required this.entries,
    this.percents = const <String, double>{},
  });

  final String title;
  final List<Micronutrient> entries;
  final Map<String, double> percents;

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
                  percent: percents[micro.tag],
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
  const _EnergyBlock({required this.value, this.coverage, this.percent});

  final double value;
  final double? coverage;
  final double? percent;

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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  coverage == 0
                      ? context.strings.nutritionNotProvided
                      : '${value.toStringAsFixed(0)} kcal',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                if (percent != null && coverage != 0)
                  Text(
                    '${percent!.toStringAsFixed(0)} % AR',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                if (coverage != null && coverage! > 0 && coverage! < 0.95)
                  Text(
                    context.strings.nutritionPartialCoverage(
                      (coverage! * 100).round(),
                    ),
                    style: Theme.of(context).textTheme.labelSmall
                        ?.copyWith(fontStyle: FontStyle.italic),
                  ),
              ],
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
    this.coverage,
    this.percent,
  });

  final String label;
  final double value;
  final String unit;
  final double ratio;
  final Color color;
  final double? coverage;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
              Flexible(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: _ValueText(
                    value: value,
                    unit: unit,
                    coverage: coverage,
                    percent: percent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: coverage == 0 ? 0 : ratio.clamp(0, 1).toDouble(),
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
    this.coverage,
    this.percent,
  });

  final String label;
  final double value;
  final String unit;
  final double? coverage;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Flexible(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _ValueText(
                value: value,
                unit: unit,
                coverage: coverage,
                percent: percent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sous-ligne indentée (sucres, AGS).
class _SubLine extends StatelessWidget {
  const _SubLine({
    required this.label,
    required this.value,
    this.coverage,
    this.percent,
  });

  final String label;
  final double value;
  final double? coverage;
  final double? percent;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 14, bottom: 6),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Flexible(
          flex: 2,
          child: Align(
            alignment: Alignment.centerRight,
            child: _ValueText(
              value: value,
              unit: 'g',
              coverage: coverage,
              percent: percent,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Valeur honnête : « non renseigné » sans donnée, couverture partielle
/// signalée, % des apports de référence en exposant.
class _ValueText extends StatelessWidget {
  const _ValueText({
    required this.value,
    required this.unit,
    this.coverage,
    this.percent,
  });

  final double value;
  final String unit;
  final double? coverage;
  final double? percent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (coverage == 0) {
      return Text(
        context.strings.nutritionNotProvided,
        textAlign: TextAlign.end,
        style: theme.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic),
      );
    }
    final digits = value < 1 ? 2 : (value < 10 ? 1 : 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '${value.toStringAsFixed(digits)} $unit',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        if (percent != null)
          Text(
            '${percent!.toStringAsFixed(0)} % AR',
            style: theme.textTheme.labelSmall,
          ),
        if (coverage != null && coverage! > 0 && coverage! < 0.95)
          Text(
            context.strings.nutritionPartialCoverage((coverage! * 100).round()),
            textAlign: TextAlign.end,
            style: theme.textTheme.labelSmall?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}

/// Badge Nutri-Score estimé (A vert foncé … E rouge), avec la note
/// méthodologique en info-bulle.
class NutriScoreBadge extends StatelessWidget {
  const NutriScoreBadge({required this.result, this.note, super.key});

  final NutriScoreResult? result;
  final String? note;

  static const Map<String, Color> colors = {
    'A': Color(0xFF038141),
    'B': Color(0xFF85BB2F),
    'C': Color(0xFFFECB02),
    'D': Color(0xFFEE8100),
    'E': Color(0xFFE63E11),
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = result;
    return Tooltip(
      message: note ?? '',
      child: Row(
        children: [
          Flexible(
            child: Text(
              context.strings.nutriScoreTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          if (r == null)
            Expanded(
              child: Text(
                note ?? '',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
          else ...[
            for (final g in const ['A', 'B', 'C', 'D', 'E'])
              Container(
                width: g == r.grade ? 30 : 22,
                height: g == r.grade ? 30 : 22,
                margin: const EdgeInsets.only(right: 2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: g == r.grade
                      ? colors[g]
                      : colors[g]!.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  g,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: g == r.grade ? 16 : 11,
                  ),
                ),
              ),
            const SizedBox(width: 6),
            Icon(
              Icons.info_outline,
              size: 14,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}
