import 'package:maestropesto/core/design/design_brief.dart';

class Recipe {
  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.images,
    this.nutritionMode = RecipeNutritionMode.computed,
    this.designBrief,
  });

  final String id;
  final String title;
  final String description;
  final List<String> tags;
  final int servings;
  final int prepMinutes;
  final int cookMinutes;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final NutritionSummary nutrition;
  final List<RecipeImage> images;

  /// Phase 10 (ac-125) — origine de la nutrition affichée : calculée
  /// depuis les ingrédients (défaut) ou saisie manuelle forcée.
  final RecipeNutritionMode nutritionMode;

  /// Phase 11 (lot D) — demande de conception d'une recette composée par
  /// objectifs (« Régénérer », « Ajuster les objectifs ») ; null pour une
  /// recette saisie.
  final DesignBrief? designBrief;

  int get totalMinutes => prepMinutes + cookMinutes;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? tags,
    int? servings,
    int? prepMinutes,
    int? cookMinutes,
    List<RecipeIngredient>? ingredients,
    List<String>? steps,
    NutritionSummary? nutrition,
    List<RecipeImage>? images,
    RecipeNutritionMode? nutritionMode,
    Object? designBrief = _unset,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      tags: tags ?? this.tags,
      servings: servings ?? this.servings,
      prepMinutes: prepMinutes ?? this.prepMinutes,
      cookMinutes: cookMinutes ?? this.cookMinutes,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      nutrition: nutrition ?? this.nutrition,
      images: images ?? this.images,
      nutritionMode: nutritionMode ?? this.nutritionMode,
      designBrief: identical(designBrief, _unset)
          ? this.designBrief
          : designBrief as DesignBrief?,
    );
  }
}

/// Origine de la nutrition d'une recette.
enum RecipeNutritionMode { computed, manual }

class RecipeImage {
  const RecipeImage({required this.path, required this.label});

  final String path;
  final String label;
}

class RecipeIngredient {
  const RecipeIngredient({
    required this.label,
    required this.quantity,
    required this.source,
    this.ingredientId,
    this.cookingMethod,
  });

  final String label;
  final String quantity;
  final IngredientSource source;

  /// Optional Phase 1 ingredient reference (added in Lot D). When set, the
  /// UI can resolve the canonical name, allergens and nutrition profile
  /// from the 4 metier databases.
  final String? ingredientId;

  /// Phase 10 Lot D — mode de cuisson explicite de la ligne
  /// (`CookingMethod.id` : raw, boiled, roasted…). Null = non précisé :
  /// le mode est alors inféré depuis les étapes quand c'est possible.
  final String? cookingMethod;

  RecipeIngredient copyWith({
    String? label,
    String? quantity,
    IngredientSource? source,
    String? ingredientId,
    Object? cookingMethod = _unset,
  }) {
    return RecipeIngredient(
      label: label ?? this.label,
      quantity: quantity ?? this.quantity,
      source: source ?? this.source,
      ingredientId: ingredientId ?? this.ingredientId,
      cookingMethod: identical(cookingMethod, _unset)
          ? this.cookingMethod
          : cookingMethod as String?,
    );
  }
}

const Object _unset = Object();

enum IngredientSource { ciqual, recipe, free }

class NutritionSummary {
  const NutritionSummary({
    required this.energyKcal,
    required this.proteins,
    required this.carbs,
    required this.fats,
    required this.fiber,
    required this.salt,
  });

  final double energyKcal;
  final double proteins;
  final double carbs;
  final double fats;
  final double fiber;
  final double salt;

  NutritionSummary copyWith({
    double? energyKcal,
    double? proteins,
    double? carbs,
    double? fats,
    double? fiber,
    double? salt,
  }) {
    return NutritionSummary(
      energyKcal: energyKcal ?? this.energyKcal,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      fats: fats ?? this.fats,
      fiber: fiber ?? this.fiber,
      salt: salt ?? this.salt,
    );
  }
}
