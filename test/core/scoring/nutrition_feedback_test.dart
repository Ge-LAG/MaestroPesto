// Phase 10 Lot G — feedback nutritionnel et procédé dans l'agrégateur.
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/models/process_models.dart';
import 'package:maestropesto/core/scoring/nutrition_aggregator.dart';
import 'package:maestropesto/core/scoring/nutrition_feedback.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

NutritionProfile p({
  double kcal = 100,
  double proteins = 5,
  double carbs = 10,
  double sugars = 5,
  double fats = 3,
  double sat = 1,
  double fiber = 2,
  double salt = 0.2,
  double water = 80,
  Map<String, Micronutrient> micros = const {},
  String state = 'raw',
}) => NutritionProfile(
  energyKcal: kcal,
  proteins: proteins,
  carbs: carbs,
  sugars: sugars,
  fats: fats,
  saturatedFats: sat,
  fiber: fiber,
  salt: salt,
  waterContent: water,
  micronutrients: micros,
  ingredientStateId: state,
  confidence: 0.9,
  recordCount: 10,
);

RecipeIngredient line(String id, String qty, {String? method}) =>
    RecipeIngredient(
      label: id,
      quantity: qty,
      source: IngredientSource.ciqual,
      ingredientId: id,
      cookingMethod: method,
    );

void main() {
  group('Nutri-Score 2023 (aliments généraux)', () {
    test('calcul de référence à la main → C', () {
      // 1000 kJ (2 pts), sucres 12 (3), AGS 3,5 (3), sel 0,9 (4) :
      // N = 12 ≥ 11 → protéines non comptées ; fibres 3,5 (1),
      // FLL 50 % (1) : score 10 → C.
      final r = NutritionFeedbackEngine.nutriScore(
        p(
          kcal: 1000 / 4.184,
          sugars: 12,
          sat: 3.5,
          salt: 0.9,
          fiber: 3.5,
          proteins: 8,
        ),
        fvlPercent: 50,
      );
      expect(r.negativePoints, 12);
      expect(r.proceedingCheck(), isTrue);
      expect(r.proteinCounted, isFalse);
      expect(r.score, 10);
      expect(r.grade, 'C');
    });

    test('légumes peu gras et peu salés → A', () {
      final r = NutritionFeedbackEngine.nutriScore(
        p(kcal: 40, sugars: 3, sat: 0.2, salt: 0.1, fiber: 3.2, proteins: 2),
        fvlPercent: 90,
      );
      expect(r.grade, 'A');
    });

    test('bornes des classes', () {
      expect(NutritionFeedbackEngine.grade(0), 'A');
      expect(NutritionFeedbackEngine.grade(2), 'B');
      expect(NutritionFeedbackEngine.grade(10), 'C');
      expect(NutritionFeedbackEngine.grade(18), 'D');
      expect(NutritionFeedbackEngine.grade(19), 'E');
    });
  });

  group('feedback complet', () {
    NutritionAggregation agg() => NutritionAggregator.aggregate(
      ingredients: [line('LEG', '300 g'), line('HUILE', '10 g')],
      lookup: (id) => id == 'LEG'
          ? p(
              kcal: 30,
              proteins: 2,
              carbs: 4,
              sugars: 3,
              fats: 0.3,
              sat: 0.05,
              fiber: 3,
              salt: 0.05,
              water: 90,
              micros: const {
                'VITC': Micronutrient(
                  tag: 'VITC',
                  name: 'Vitamine C',
                  value: 60,
                  unit: 'mg',
                ),
              },
            )
          : p(
              kcal: 900,
              proteins: 0,
              carbs: 0,
              sugars: 0,
              fats: 100,
              sat: 14,
              fiber: 0,
              salt: 0,
              water: 0,
            ),
      servings: 2,
    );

    test('Nutri-Score, %AR, VNR et allégations', () {
      final f = NutritionFeedbackEngine.evaluate(
        agg(),
        fvlFor: (id) => id == 'LEG' ? FvlClass.vegetable : FvlClass.none,
        categoryFor: (id) => (
          level1: id == 'LEG' ? 'végétal' : 'ingrédient technique',
          level2: id == 'LEG' ? 'légume' : 'matière grasse',
          name: id,
        ),
      );
      expect(f.nutriScore, isNotNull);
      expect(f.nutriScore!.fvlPercent, closeTo(96.8, 0.1));
      expect(f.nutriScore!.grade, anyOf('A', 'B'));
      final energy = f.intakes.firstWhere((l) => l.key == 'energy');
      expect(energy.percent, closeTo(energy.value / 2000 * 100, 1e-9));
      final vitC = f.micronutrientIntakes.firstWhere((l) => l.key == 'VITC');
      expect(vitC.percent, closeTo(90 / 80 * 100, 0.01));
      expect(
        f.claims.map((c) => c.label),
        containsAll(['Très pauvre en sel', 'Riche en Vitamine C']),
      );
    });

    test('recette de type boisson : Nutri-Score non calculé', () {
      final f = NutritionFeedbackEngine.evaluate(
        agg(),
        fvlFor: (_) => FvlClass.none,
        categoryFor: (id) => (level1: 'boisson', level2: 'vin', name: id),
      );
      expect(f.nutriScore, isNull);
      expect(f.nutriScoreNote, contains('boisson'));
    });
  });

  group('procédé dans l’agrégateur (Lot D)', () {
    const factor = CookingFactor(
      group: FoodGroup.vegetable,
      method: CookingMethod.boiled,
      yieldFactor: 0.9,
      retention: {'VITC': 0.5},
    );
    NutritionProcessContext ctx({NutritionProfile? measured}) =>
        NutritionProcessContext(
          groupFor: (_) => FoodGroup.vegetable,
          factorFor: (g, m) => factor,
          methodForLine: (i, _) =>
              (method: CookingMethod.boiled, inferred: false),
          measuredCookedFor: (id, m) => measured,
        );
    final raw = p(
      kcal: 30,
      water: 90,
      micros: const {
        'VITC': Micronutrient(tag: 'VITC', name: 'C', value: 40, unit: 'mg'),
      },
    );

    test('rétention des vitamines et rendement massique', () {
      final a = NutritionAggregator.aggregate(
        ingredients: [line('LEG', '200 g')],
        lookup: (_) => raw,
        servings: 1,
        process: ctx(),
      );
      expect(a.processApplied, isTrue);
      expect(a.cookedMassG, closeTo(180, 1e-9));
      expect(
        a.profilePerServing.micronutrients['VITC']!.value,
        closeTo(40, 1e-9),
        reason: '80 mg crus × rétention 0,5',
      );
      // Énergie conservée, concentrée dans une masse plus faible.
      expect(a.profilePerServing.energyKcal, closeTo(60, 1e-9));
      expect(a.profilePer100g!.energyKcal, closeTo(60 / 1.8, 1e-9));
    });

    test('profil cuit mesuré préféré aux facteurs', () {
      final boiled = p(
        kcal: 25,
        water: 92,
        state: 'boiled',
        micros: const {
          'VITC': Micronutrient(tag: 'VITC', name: 'C', value: 22, unit: 'mg'),
        },
      );
      final a = NutritionAggregator.aggregate(
        ingredients: [line('LEG', '200 g')],
        lookup: (_) => raw,
        servings: 1,
        process: ctx(measured: boiled),
      );
      expect(a.contributions.single.measuredCooked, isTrue);
      // 180 g cuits × 25 kcal/100 g.
      expect(a.profilePerServing.energyKcal, closeTo(45, 1e-9));
      expect(
        a.profilePerServing.micronutrients['VITC']!.value,
        closeTo(22 * 1.8, 1e-9),
      );
    });

    test('ingrédient déjà cuit : aucun facteur (pas de double comptage)', () {
      final a = NutritionAggregator.aggregate(
        ingredients: [line('LEG', '200 g')],
        lookup: (_) => p(kcal: 30, state: 'boiled'),
        servings: 1,
        process: ctx(),
      );
      expect(a.processApplied, isFalse);
      expect(a.contributions.single.alreadyCooked, isTrue);
      expect(a.warnings, contains('already_cooked:LEG'));
    });

    test('couverture par nutriment : ligne sans donnée comptée en masse', () {
      final a = NutritionAggregator.aggregate(
        ingredients: [line('A', '100 g'), line('B', '100 g')],
        lookup: (id) => id == 'A' ? raw : NutritionProfile.empty,
        servings: 1,
      );
      expect(a.rawMassG, 200);
      expect(a.nutrientCoverage[MacroField.energy], closeTo(0.5, 1e-9));
      expect(a.profilePerServing.isKnown(MacroField.energy), isTrue);
    });
  });
}

extension on NutriScoreResult {
  bool proceedingCheck() => negativePoints >= 11;
}
