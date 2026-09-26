// Phase 09 Lot G / Phase 10 Lots A-B-D — agrégation nutritionnelle
// d'une recette.
//
// dp-105 : le calcul est **synchrone** et pur (fonction sans I/O) — les
// profils `NutritionProfile` sont résolus en amont (repository) et passés
// via une lookup synchrone.
//
// Algorithme (Phase 10) :
//   pour chaque ligne i de la recette :
//     grammes_i   = QuantityConverter (unités culinaires, densités,
//                   masses unitaires — hypothèses tracées)
//     profil_i    = lookup(i.ingredientId)
//     procédé_i   = mode de cuisson de la ligne (explicite ou inféré)
//     facteur_i   = (groupe d'aliment, mode) → rendement, rétention,
//                   absorption de gras (ordres de grandeur USDA RF6 /
//                   Bognár) — jamais appliqué si le profil source décrit
//                   déjà un aliment cuit (pas de double comptage)
//     nutriments  = profil × grammes/100 × rétention (+ gras absorbé)
//     masse cuite = grammes × rendement (+ gras absorbé), bornée par la
//                   masse sèche
//   total → par portion (÷ servings) et pour 100 g de plat cuit.
//
// Honnêteté (décision honest-data-display) : une ligne sans donnée
// compte dans la masse du plat mais pas dans les nutriments ; la
// couverture massique de chaque macronutriment est exposée
// ([NutritionAggregation.nutrientCoverage]).

import 'package:meta/meta.dart';

import '../models/nutrition_profile.dart';
import '../models/process_models.dart';
import '../../features/recipes/domain/recipe.dart';
import 'quantity_converter.dart';

/// Lookup synchrone d'un profil nutritionnel par `ingredientId`
/// (résolution faite en amont par le repository, cf. dp-105).
typedef NutritionProfileLookup = NutritionProfile? Function(
  String ingredientId,
);

/// Source d'une donnée nutritionnelle (traçabilité in-app).
class NutritionSource {
  const NutritionSource({required this.id, this.label, this.citation});

  /// Identifiant technique (ex. `ciqual_2025_11_03`).
  final String id;

  /// Libellé court lisible (ex. `ANSES Ciqual 2025-11-03`).
  final String? label;

  /// Citation complète (tooltip).
  final String? citation;

  String get displayLabel => label ?? id;
}

/// Contexte optionnel de conversion et de procédé (Phase 10).
@immutable
class NutritionProcessContext {
  const NutritionProcessContext({
    this.unitDataFor,
    this.groupFor,
    this.factorFor,
    this.methodForLine,
    this.measuredCookedFor,
  });

  /// Densité et masses unitaires d'un ingrédient (conversion d'unités).
  final IngredientUnitData Function(String ingredientId)? unitDataFor;

  /// Groupe d'aliment d'un ingrédient (facteurs de procédé).
  final FoodGroup Function(String ingredientId)? groupFor;

  /// Facteurs moyens (groupe, mode).
  final CookingFactorLookup? factorFor;

  /// Profil cuit mesuré (variante Ciqual) pour un ingrédient et un mode
  /// de cuisson — null si la table n'en contient pas.
  final NutritionProfile? Function(String ingredientId, CookingMethod method)?
  measuredCookedFor;

  /// Mode de cuisson résolu d'une ligne (explicite puis inféré depuis
  /// les étapes) avec l'indicateur « inféré ».
  final ({CookingMethod method, bool inferred})? Function(
    int index,
    RecipeIngredient ingredient,
  )?
  methodForLine;
}

/// Contribution d'une ligne de recette (explicabilité, Nutri-Score).
@immutable
class IngredientContribution {
  const IngredientContribution({
    required this.index,
    required this.label,
    this.ingredientId,
    this.rawGrams,
    this.cookedGrams,
    this.energyKcal = 0,
    this.hasData = false,
    this.method,
    this.methodInferred = false,
    this.factorApplied = false,
    this.measuredCooked = false,
    this.alreadyCooked = false,
    this.quantityAssumption,
    this.sourceFoodName,
    this.approximationNote,
    this.derivedFields = const <MacroField>{},
  });

  final int index;
  final String label;
  final String? ingredientId;

  /// Masse crue (g) — null si la quantité n'est pas interprétable.
  final double? rawGrams;

  /// Masse après procédé (g).
  final double? cookedGrams;
  final double energyKcal;

  /// Vrai si la ligne alimente réellement le calcul.
  final bool hasData;
  final CookingMethod? method;
  final bool methodInferred;

  /// Vrai si des facteurs de rendement/rétention ont été appliqués.
  final bool factorApplied;

  /// Vrai si la composition cuite est MESURÉE (variante Ciqual) plutôt
  /// qu'estimée par facteurs de rétention.
  final bool measuredCooked;

  /// Vrai si le profil source décrit déjà un aliment cuit (aucun
  /// facteur appliqué pour éviter le double comptage).
  final bool alreadyCooked;
  final String? quantityAssumption;
  final String? sourceFoodName;
  final String? approximationNote;

  /// Champs valant 0 par bilan de masse (voir
  /// `NutritionProfile.derivedFields`).
  final Set<MacroField> derivedFields;
}

/// Résultat de l'agrégation : profil **par portion** + métadonnées
/// d'explicabilité.
class NutritionAggregation {
  const NutritionAggregation({
    required this.profilePerServing,
    required this.resolvedCount,
    required this.withDataCount,
    required this.totalCount,
    this.warnings = const <String>[],
    this.sources = const <NutritionSource>[],
    this.contributions = const <IngredientContribution>[],
    this.rawMassG = 0,
    this.cookedMassG = 0,
    this.profilePer100g,
    this.nutrientCoverage = const <MacroField, double>{},
    this.processApplied = false,
    this.servings = 1,
  });

  /// Profil nutritionnel par portion (total ÷ servings).
  final NutritionProfile profilePerServing;

  /// Nombre d'ingrédients dont le profil a été résolu (y compris vides).
  final int resolvedCount;

  /// Nombre d'ingrédients ayant réellement CONTRIBUÉ des données.
  final int withDataCount;

  /// Nombre total d'ingrédients de la recette.
  final int totalCount;

  /// Warnings non bloquants (codes techniques courts, rendus par l'UI).
  final List<String> warnings;

  /// Sources distinctes des records consommés (remplies par le
  /// repository).
  final List<NutritionSource> sources;

  /// Détail par ligne.
  final List<IngredientContribution> contributions;

  /// Masse totale crue des lignes interprétables (g).
  final double rawMassG;

  /// Masse estimée du plat après procédé (g).
  final double cookedMassG;

  /// Profil pour 100 g de plat (après procédé) — null si masse nulle.
  final NutritionProfile? profilePer100g;

  /// Part massique (0..1) des lignes renseignant chaque macronutriment.
  final Map<MacroField, double> nutrientCoverage;

  /// Vrai si au moins un facteur de procédé a été appliqué.
  final bool processApplied;
  final int servings;

  /// Vrai si au moins un ingrédient a contribué des données réelles.
  bool get hasData => withDataCount > 0;

  /// Masse d'une portion (g), plat cuit.
  double get servingMassG => cookedMassG / (servings > 0 ? servings : 1);

  NutritionAggregation withSources(List<NutritionSource> sources) =>
      NutritionAggregation(
        profilePerServing: profilePerServing,
        resolvedCount: resolvedCount,
        withDataCount: withDataCount,
        totalCount: totalCount,
        warnings: warnings,
        sources: sources,
        contributions: contributions,
        rawMassG: rawMassG,
        cookedMassG: cookedMassG,
        profilePer100g: profilePer100g,
        nutrientCoverage: nutrientCoverage,
        processApplied: processApplied,
        servings: servings,
      );
}

/// États sources qui décrivent déjà un aliment cuit.
const Set<String> kCookedStates = {
  'boiled',
  'cooked',
  'baked',
  'roasted',
  'grilled',
  'fried',
  'steamed',
  'stewed',
  'sauteed',
};

/// Accumulateur interne de nutriments absolus (g, kcal, mg…).
class _Totals {
  double energy = 0;
  double proteins = 0;
  double carbs = 0;
  double sugars = 0;
  double fats = 0;
  double saturatedFats = 0;
  double fiber = 0;
  double salt = 0;
  double alcohol = 0;
  final Map<String, double> micros = {};
  final Map<String, String> microNames = {};
  final Map<String, String> microUnits = {};
}

/// Agrégateur nutritionnel pur.
abstract final class NutritionAggregator {
  static NutritionAggregation aggregate({
    required List<RecipeIngredient> ingredients,
    required NutritionProfileLookup lookup,
    required int servings,
    NutritionProcessContext? process,
  }) {
    final safeServings = servings > 0 ? servings : 1;
    final warnings = <String>[];
    final contributions = <IngredientContribution>[];
    final totals = _Totals();
    var resolved = 0;
    var withData = 0;
    var rawMass = 0.0;
    var cookedMass = 0.0;
    var waterCooked = 0.0;
    var waterKnownMass = 0.0;
    var confidenceWeighted = 0.0;
    var confidenceMass = 0.0;
    var recordCountSum = 0;
    var processApplied = false;
    var anyEnergyEstimated = false;
    final knownMass = <MacroField, double>{};

    for (var index = 0; index < ingredients.length; index++) {
      final ingredient = ingredients[index];
      final id = ingredient.ingredientId;
      if (ingredient.source == IngredientSource.recipe) {
        // Sous-recette : pas de récursion en v1 (plan §6.2 edge case).
        warnings.add('subrecipe_skipped');
        contributions.add(
          IngredientContribution(index: index, label: ingredient.label),
        );
        continue;
      }
      final unitData = (id != null && id.isNotEmpty)
          ? process?.unitDataFor?.call(id) ?? const IngredientUnitData()
          : const IngredientUnitData();
      final quantity = QuantityConverter.resolve(
        ingredient.quantity,
        data: unitData,
      );
      if (id == null || id.isEmpty) {
        warnings.add('unlinked_ingredient_skipped');
        // La masse d'un ingrédient libre compte dans le plat.
        if (quantity != null) {
          rawMass += quantity.grams;
          cookedMass += quantity.grams;
        }
        contributions.add(
          IngredientContribution(
            index: index,
            label: ingredient.label,
            rawGrams: quantity?.grams,
            cookedGrams: quantity?.grams,
            quantityAssumption: quantity?.assumption,
          ),
        );
        continue;
      }
      final profile = lookup(id);
      if (profile == null) {
        warnings.add('profile_missing:$id');
        if (quantity != null) {
          rawMass += quantity.grams;
          cookedMass += quantity.grams;
        }
        contributions.add(
          IngredientContribution(
            index: index,
            label: ingredient.label,
            ingredientId: id,
            rawGrams: quantity?.grams,
          ),
        );
        continue;
      }
      if (quantity == null) {
        warnings.add('quantity_unparsed:$id');
        contributions.add(
          IngredientContribution(
            index: index,
            label: ingredient.label,
            ingredientId: id,
            hasData: false,
          ),
        );
        continue;
      }
      if (!quantity.isExact) {
        warnings.add('quantity_assumed:$id');
      }
      final grams = quantity.grams;
      resolved++;
      final hasData = profile.recordCount > 0;

      // Procédé de la ligne.
      final resolvedMethod = process?.methodForLine?.call(index, ingredient);
      final method = resolvedMethod?.method;
      final alreadyCooked = kCookedStates.contains(profile.ingredientStateId);
      CookingFactor? factor;
      if (method != null && method.isHeated && !alreadyCooked) {
        final group = process?.groupFor?.call(id) ?? FoodGroup.other;
        factor = process?.factorFor?.call(group, method);
      }
      if (method != null && method.isHeated && alreadyCooked) {
        warnings.add('already_cooked:$id');
      }

      // Profil cuit MESURÉ (variante Ciqual « bouilli », « rôti »…) :
      // préféré aux facteurs de rétention génériques ; seul le
      // rendement massique reste une estimation.
      NutritionProfile? measured;
      if (method != null && method.isHeated && !alreadyCooked) {
        final m = process?.measuredCookedFor?.call(id, method);
        if (m != null && m.recordCount > 0) measured = m;
      }
      final src = measured ?? profile;
      final double lineCooked;
      final double f; // facteur appliqué au profil source (÷ 100)
      final double fatsAfter;
      final double energy;
      double? lineWater;
      var fatRetention = 1.0;
      if (measured != null) {
        lineCooked = grams * (factor?.yieldFactor ?? 1);
        f = lineCooked / 100.0;
        fatsAfter = src.fats * f;
        energy = src.energyKcal * f;
        final w = src.waterContent;
        if (w != null) lineWater = w * f;
      } else {
        f = grams / 100.0;
        fatRetention = factor?.fatRetention ?? 1;
        final uptake = (factor?.fatUptakeG ?? 0) * f;
        final fatsBefore = profile.fats * f;
        fatsAfter = fatsBefore * fatRetention + uptake;
        energy = profile.energyKcal * f + (fatsAfter - fatsBefore) * 9;
        // Masse après procédé, bornée par la matière sèche.
        var cooked = grams * (factor?.yieldFactor ?? 1) + uptake;
        final waterRaw = profile.waterContent == null
            ? null
            : profile.waterContent! * f;
        if (waterRaw != null) {
          final dry = grams - waterRaw + (fatsAfter - fatsBefore);
          if (cooked < dry) cooked = dry;
          lineWater = cooked - dry;
        }
        lineCooked = cooked;
      }
      rawMass += grams;
      cookedMass += lineCooked;

      if (hasData) {
        withData++;
        totals.energy += energy;
        totals.proteins += src.proteins * f;
        totals.carbs += src.carbs * f;
        totals.sugars += src.sugars * f;
        totals.fats += fatsAfter;
        totals.saturatedFats += src.saturatedFats * f * fatRetention;
        totals.fiber += src.fiber * f;
        totals.salt += src.salt * f;
        // Alcool : ≈ 40 % retenu après cuisson (ordre de grandeur USDA
        // pour mijotage/cuisson au four de 15–30 min).
        totals.alcohol +=
            src.alcohol *
            f *
            (measured == null &&
                    method != null &&
                    method.isHeated &&
                    !alreadyCooked
                ? 0.4
                : 1);
        if (lineWater != null) {
          waterCooked += lineWater;
          waterKnownMass += lineCooked;
        }
        for (final micro in src.micronutrients.values) {
          final r = measured != null
              ? 1.0
              : factor?.retentionFor(micro.tag) ?? 1;
          totals.micros[micro.tag] =
              (totals.micros[micro.tag] ?? 0) + micro.value * f * r;
          totals.microNames.putIfAbsent(micro.tag, () => micro.name);
          totals.microUnits.putIfAbsent(micro.tag, () => micro.unit);
        }
        for (final field in src.knownFields) {
          knownMass[field] = (knownMass[field] ?? 0) + grams;
        }
        confidenceWeighted += src.confidence * grams;
        confidenceMass += grams;
        recordCountSum += src.recordCount;
        if (src.energyEstimated) anyEnergyEstimated = true;
      }
      if (factor != null || measured != null) processApplied = true;

      contributions.add(
        IngredientContribution(
          index: index,
          label: ingredient.label,
          ingredientId: id,
          rawGrams: grams,
          cookedGrams: lineCooked,
          energyKcal: hasData ? energy : 0,
          hasData: hasData,
          method: method,
          methodInferred: resolvedMethod?.inferred ?? false,
          factorApplied: factor != null || measured != null,
          measuredCooked: measured != null,
          alreadyCooked: alreadyCooked,
          quantityAssumption: quantity.assumption,
          sourceFoodName: profile.sourceFoodName,
          approximationNote: profile.approximationNote,
          derivedFields: profile.derivedFields,
        ),
      );
    }

    final coverage = <MacroField, double>{
      for (final field in kAllMacroFields)
        field: rawMass > 0 ? (knownMass[field] ?? 0) / rawMass : 0,
    };
    final known = {
      for (final e in coverage.entries)
        if (e.value > 0) e.key,
    };
    final confidence = confidenceMass > 0
        ? confidenceWeighted / confidenceMass
        : 0.0;
    final stateId = processApplied ? 'cooked' : 'raw';

    NutritionProfile scaled(double divisor) => NutritionProfile(
      energyKcal: totals.energy / divisor,
      proteins: totals.proteins / divisor,
      carbs: totals.carbs / divisor,
      sugars: totals.sugars / divisor,
      fats: totals.fats / divisor,
      saturatedFats: totals.saturatedFats / divisor,
      fiber: totals.fiber / divisor,
      salt: totals.salt / divisor,
      alcohol: totals.alcohol / divisor,
      waterContent: waterKnownMass > 0 ? waterCooked / divisor : null,
      micronutrients: {
        for (final e in totals.micros.entries)
          e.key: Micronutrient(
            tag: e.key,
            name: totals.microNames[e.key] ?? e.key,
            value: e.value / divisor,
            unit: totals.microUnits[e.key] ?? 'mg',
          ),
      },
      ingredientStateId: stateId,
      confidence: confidence,
      recordCount: recordCountSum,
      knownFields: known,
      energyEstimated: anyEnergyEstimated,
    );

    final perServing = resolved == 0
        ? NutritionProfile.empty
        : scaled(safeServings.toDouble());
    NutritionProfile? per100g;
    if (withData > 0 && cookedMass > 0) {
      per100g = scaled(cookedMass / 100);
      // L'eau pour 100 g de plat : part massique des lignes renseignées.
      if (waterKnownMass > 0) {
        per100g = per100g.copyWith(
          waterContent: waterCooked / waterKnownMass * 100,
        );
      }
    }

    return NutritionAggregation(
      profilePerServing: perServing,
      resolvedCount: resolved,
      withDataCount: withData,
      totalCount: ingredients.length,
      warnings: warnings,
      contributions: contributions,
      rawMassG: rawMass,
      cookedMassG: cookedMass,
      profilePer100g: per100g,
      nutrientCoverage: coverage,
      processApplied: processApplied,
      servings: safeServings,
    );
  }

  /// Compatibilité Phase 09 : quantité libre → grammes, sans données
  /// d'ingrédient (voir [QuantityConverter]).
  static double? quantityToGrams(String raw) => QuantityConverter.toGrams(raw);
}
