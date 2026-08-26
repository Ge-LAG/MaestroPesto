// Phase 09 Lot G — G1 : tests de l'agrégateur nutritionnel pur (§6.2).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

NutritionProfile profile({
  double energyKcal = 100,
  double proteins = 10,
  double carbs = 20,
  double sugars = 5,
  double fats = 8,
  double saturatedFats = 3,
  double fiber = 2,
  double salt = 1,
  double? waterContent = 80,
  double confidence = 0.9,
  int recordCount = 4,
}) =>
    NutritionProfile(
      energyKcal: energyKcal,
      proteins: proteins,
      carbs: carbs,
      sugars: sugars,
      fats: fats,
      saturatedFats: saturatedFats,
      fiber: fiber,
      salt: salt,
      waterContent: waterContent,
      ingredientStateId: 'raw',
      confidence: confidence,
      recordCount: recordCount,
    );

RecipeIngredient linked(String id, String quantity) => RecipeIngredient(
      label: id,
      quantity: quantity,
      source: IngredientSource.ciqual,
      ingredientId: id,
    );

void main() {
  group('NutritionAggregator.aggregate', () {
    test('empty recipe → empty profile, 0 resolved', () {
      final result = NutritionAggregator.aggregate(
        ingredients: const [],
        lookup: (_) => profile(),
        servings: 4,
      );
      expect(result.profilePerServing, NutritionProfile.empty);
      expect(result.resolvedCount, 0);
      expect(result.totalCount, 0);
      expect(result.hasData, isFalse);
    });

    test('single ingredient, 100 g, 1 serving → profile as-is', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g')],
        lookup: (_) => profile(),
        servings: 1,
      );
      expect(result.resolvedCount, 1);
      expect(result.profilePerServing.energyKcal, closeTo(100, 1e-9));
      expect(result.profilePerServing.proteins, closeTo(10, 1e-9));
      expect(result.profilePerServing.salt, closeTo(1, 1e-9));
    });

    test('quantity scaling: 50 g halves the contribution', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '50 g')],
        lookup: (_) => profile(),
        servings: 1,
      );
      expect(result.profilePerServing.energyKcal, closeTo(50, 1e-9));
      expect(result.profilePerServing.proteins, closeTo(5, 1e-9));
    });

    test('servings division: 200 g over 4 servings', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '200 g')],
        lookup: (_) => profile(),
        servings: 4,
      );
      expect(result.profilePerServing.energyKcal, closeTo(50, 1e-9));
    });

    test('multiple ingredients sum their contributions', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g'), linked('ING-B', '100 g')],
        lookup: (id) => id == 'ING-A' ? profile() : profile(energyKcal: 300),
        servings: 1,
      );
      expect(result.resolvedCount, 2);
      expect(result.profilePerServing.energyKcal, closeTo(400, 1e-9));
      expect(result.profilePerServing.recordCount, 8);
      expect(result.profilePerServing.confidence, closeTo(0.9, 1e-9));
    });

    test('ingredient without profile is skipped with warning', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g'), linked('ING-MISSING', '100 g')],
        lookup: (id) => id == 'ING-MISSING' ? null : profile(),
        servings: 1,
      );
      expect(result.resolvedCount, 1);
      expect(result.totalCount, 2);
      expect(result.warnings, contains('profile_missing:ING-MISSING'));
      expect(result.profilePerServing.energyKcal, closeTo(100, 1e-9));
    });

    test('free ingredient without ingredientId is skipped with warning', () {
      final result = NutritionAggregator.aggregate(
        ingredients: const [
          RecipeIngredient(
            label: 'Pincée de sel',
            quantity: '1 pincée',
            source: IngredientSource.free,
          ),
        ],
        lookup: (_) => profile(),
        servings: 1,
      );
      expect(result.resolvedCount, 0);
      expect(result.warnings, contains('unlinked_ingredient_skipped'));
    });

    test('sub-recipe ingredient is ignored (no recursion)', () {
      final result = NutritionAggregator.aggregate(
        ingredients: const [
          RecipeIngredient(
            label: 'Sauce',
            quantity: '100 g',
            source: IngredientSource.recipe,
            ingredientId: 'REC-X',
          ),
        ],
        lookup: (_) => profile(),
        servings: 1,
      );
      expect(result.resolvedCount, 0);
      expect(result.warnings, contains('subrecipe_skipped'));
    });

    test('unparsable quantity skips contribution with warning', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', 'au goût')],
        lookup: (_) => profile(),
        servings: 1,
      );
      expect(result.resolvedCount, 0);
      expect(result.warnings, contains('quantity_unparsed:ING-A'));
    });

    test('servings <= 0 is defensive (treated as 1)', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g')],
        lookup: (_) => profile(),
        servings: 0,
      );
      expect(result.profilePerServing.energyKcal, closeTo(100, 1e-9));
    });

    test('waterContent stays null when no profile provides it', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g')],
        lookup: (_) => profile(waterContent: null),
        servings: 1,
      );
      expect(result.profilePerServing.waterContent, isNull);
    });

    test('mixed water: only contributing profiles count', () {
      final result = NutritionAggregator.aggregate(
        ingredients: [linked('ING-A', '100 g'), linked('ING-B', '100 g')],
        lookup: (id) => id == 'ING-A' ? profile() : profile(waterContent: 40),
        servings: 1,
      );
      // (80 + 40) / 1 portion → moyenne pondérée par 100 g chacun
      expect(result.profilePerServing.waterContent, closeTo(120, 1e-9));
    });
  });

  group('NutritionAggregator.quantityToGrams', () {
    test('parses plain grams', () {
      expect(NutritionAggregator.quantityToGrams('60 g'), 60);
      expect(NutritionAggregator.quantityToGrams('60g'), 60);
      expect(NutritionAggregator.quantityToGrams('360 g'), 360);
    });

    test('converts kg / mg / cl / l', () {
      expect(NutritionAggregator.quantityToGrams('1 kg'), 1000);
      expect(NutritionAggregator.quantityToGrams('500 mg'), 0.5);
      expect(NutritionAggregator.quantityToGrams('10 cl'), 100);
      expect(NutritionAggregator.quantityToGrams('0.5 l'), 500);
    });

    test('unitless number is treated as grams', () {
      expect(NutritionAggregator.quantityToGrams('2'), 2);
    });

    test('unknown culinary unit falls back to grams (documented v1)', () {
      expect(NutritionAggregator.quantityToGrams('1 pincée'), 1);
    });

    test('decimal comma is supported', () {
      expect(NutritionAggregator.quantityToGrams('1,5 kg'), 1500);
    });

    test('returns null when no number found', () {
      expect(NutritionAggregator.quantityToGrams('au goût'), isNull);
      expect(NutritionAggregator.quantityToGrams(''), isNull);
    });
  });
}
