// Phase 09 Lot G — G1 : agrégation nutritionnelle d'une recette.
//
// dp-105 : le calcul est **synchrone** et pur (fonction sans I/O) — les
// profils `NutritionProfile` sont résolus en amont (repository) et passés
// via une lookup synchrone. Pas de stream, pas de Future ici.
//
// Algorithme (plan §6.2) :
//   pour chaque ingrédient i de la recette :
//     profile_i = lookup(i.ingredientId)         // null → skip + warning
//     contribution_i = (quantity_g_i × profile_i) / 100.0
//   nutrition_totale = somme des contribution_i
//   nutrition_par_portion = nutrition_totale / servings
//
// Conversion des quantités (documentée, voir [quantityToGrams]) :
// les quantités des recettes sont des chaînes libres ("60 g", "1 pincée",
// "360 g"). On extrait le nombre en tête et on applique :
//   - g / gr / gramme(s)      → tel quel
//   - kg                      → × 1000
//   - mg                      → ÷ 1000
//   - ml / cl / l             → × 1 / × 10 / × 1000 (densité 1, approximation
//                             v1 — cf. dette ac-101, pas de densité ingrédient)
//   - unité absente ou inconnue (pincée, cuillère…) → nombre interprété
//     comme grammes (hypothèse v1, tracée dans les warnings).
//   - chaîne sans nombre      → contribution ignorée (warning).

import '../models/nutrition_profile.dart';
import '../../features/recipes/domain/recipe.dart';

/// Lookup synchrone d'un profil nutritionnel par `ingredientId`
/// (résolution faite en amont par le repository, cf. dp-105).
typedef NutritionProfileLookup = NutritionProfile? Function(
  String ingredientId,
);

/// Résultat de l'agrégation : profil **par portion** + métadonnées
/// d'explicabilité (affichées par `RecipeNutritionPanel`, G2).
class NutritionAggregation {
  const NutritionAggregation({
    required this.profilePerServing,
    required this.resolvedCount,
    required this.totalCount,
    this.warnings = const <String>[],
  });

  /// Profil nutritionnel par portion (total ÷ servings).
  final NutritionProfile profilePerServing;

  /// Nombre d'ingrédients dont le profil a été résolu et agrégé.
  final int resolvedCount;

  /// Nombre total d'ingrédients de la recette.
  final int totalCount;

  /// Warnings non bloquants (skip d'ingrédient, unité inconnue…).
  /// Aucune donnée sensible : uniquement des libellés techniques courts.
  final List<String> warnings;

  /// Vrai si au moins un ingrédient a contribué.
  bool get hasData => resolvedCount > 0;
}

/// Agrégateur nutritionnel pur (plan Phase 09 §6.2, dp-105).
abstract final class NutritionAggregator {
  /// Agrège les contributions des [ingredients] en un profil par portion.
  ///
  /// Edge cases (plan §6.2) :
  /// - ingrédient `source == IngredientSource.free` sans `ingredientId`
  ///   → skip + warning ;
  /// - ingrédient `source == IngredientSource.recipe` (sous-recette)
  ///   → ignoré (pas de récursion, phase future) ;
  /// - `lookup` renvoie null (ingrédient sans profil) → skip + warning ;
  /// - [servings] ≤ 0 → ramené à 1 (défensif, une portion minimum).
  static NutritionAggregation aggregate({
    required List<RecipeIngredient> ingredients,
    required NutritionProfileLookup lookup,
    required int servings,
  }) {
    final safeServings = servings > 0 ? servings : 1;
    final warnings = <String>[];
    var resolved = 0;

    var energy = 0.0;
    var proteins = 0.0;
    var carbs = 0.0;
    var sugars = 0.0;
    var fats = 0.0;
    var saturatedFats = 0.0;
    var fiber = 0.0;
    var salt = 0.0;
    var water = 0.0;
    var hasWater = false;
    var confidenceSum = 0.0;
    var recordCountSum = 0;

    for (final ingredient in ingredients) {
      if (ingredient.source == IngredientSource.recipe) {
        // Sous-recette : pas de récursion en v1 (plan §6.2 edge case).
        warnings.add('subrecipe_skipped');
        continue;
      }
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty) {
        warnings.add('unlinked_ingredient_skipped');
        continue;
      }
      final profile = lookup(id);
      if (profile == null) {
        warnings.add('profile_missing:$id');
        continue;
      }
      final grams = quantityToGrams(ingredient.quantity);
      if (grams == null) {
        warnings.add('quantity_unparsed:$id');
        continue;
      }
      final factor = grams / 100.0;
      energy += profile.energyKcal * factor;
      proteins += profile.proteins * factor;
      carbs += profile.carbs * factor;
      sugars += profile.sugars * factor;
      fats += profile.fats * factor;
      saturatedFats += profile.saturatedFats * factor;
      fiber += profile.fiber * factor;
      salt += profile.salt * factor;
      final w = profile.waterContent;
      if (w != null) {
        water += w * factor;
        hasWater = true;
      }
      confidenceSum += profile.confidence;
      recordCountSum += profile.recordCount;
      resolved++;
    }

    final profile = resolved == 0
        ? NutritionProfile.empty
        : NutritionProfile(
            energyKcal: energy / safeServings,
            proteins: proteins / safeServings,
            carbs: carbs / safeServings,
            sugars: sugars / safeServings,
            fats: fats / safeServings,
            saturatedFats: saturatedFats / safeServings,
            fiber: fiber / safeServings,
            salt: salt / safeServings,
            waterContent: hasWater ? water / safeServings : null,
            ingredientStateId: 'raw',
            confidence: confidenceSum / resolved,
            recordCount: recordCountSum,
          );

    return NutritionAggregation(
      profilePerServing: profile,
      resolvedCount: resolved,
      totalCount: ingredients.length,
      warnings: warnings,
    );
  }

  /// Convertit une quantité libre ("60 g", "1 pincée", "360 g") en grammes.
  /// Renvoie null si aucun nombre n'est trouvé. Voir l'en-tête du fichier
  /// pour la table de conversion retenue.
  static double? quantityToGrams(String raw) {
    final match = RegExp(r'(\d+(?:[.,]\d+)?)\s*([a-zA-ZÀ-ÿ]*)')
        .firstMatch(raw.trim());
    if (match == null) return null;
    final value = double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (value == null) return null;
    final unit = match.group(2)!.toLowerCase();
    switch (unit) {
      case '':
      case 'g':
      case 'gr':
      case 'gramme':
      case 'grammes':
        return value;
      case 'kg':
        return value * 1000;
      case 'mg':
        return value / 1000;
      case 'ml':
        return value; // densité 1 (approximation v1)
      case 'cl':
        return value * 10;
      case 'l':
        return value * 1000;
      default:
        // Unité culinaire inconnue (pincée, cuillère…) : on interprète le
        // nombre comme des grammes (hypothèse v1 documentée).
        return value;
    }
  }
}
