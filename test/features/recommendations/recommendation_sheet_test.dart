// Phase 09 Lot H — H3 : widget tests de la RecommendationSheet (§9.2).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recommendations/data/recommender.dart';
import 'package:maestropesto/features/recommendations/presentation/widgets/recommendation_sheet.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

class FakeIngredients implements IngredientCandidatesSource {
  FakeIngredients(this.byId);
  final Map<String, IngredientSummary> byId;

  @override
  Future<IngredientSummary?> summaryFor(String ingredientId) async =>
      byId[ingredientId];

  @override
  Future<List<IngredientSummary>> candidatesForCategory(
    String categoryLevel1, {
    double minConfidence = 0.7,
  }) async => byId.values
      .where(
        (s) =>
            s.categoryLevel1 == categoryLevel1 && s.confidence >= minConfidence,
      )
      .toList();
}

RecipeIngredient ing(String id, String label) => RecipeIngredient(
  label: label,
  quantity: '100 g',
  source: IngredientSource.ciqual,
  ingredientId: id,
);

void main() {
  group('RecommendationSheet', () {
    testWidgets('tap sur un problème → substituts proposés', (tester) async {
      final flavor = FlavorRepository.fromMatches([
        const FlavorMatch(
          ingredientAId: 'ING-BOEUF',
          ingredientBId: 'ING-BLEU',
          combinationSize: 2,
          overallScore: 0.32,
        ),
        const FlavorMatch(
          ingredientAId: 'ING-POULET',
          ingredientBId: 'ING-BLEU',
          combinationSize: 2,
          overallScore: 0.74,
        ),
      ]);
      final sheet = RecommendationSheet(
        ingredients: [
          ing('ING-BOEUF', 'Bœuf'),
          ing('ING-BLEU', 'Fromage bleu'),
        ],
        flavor: flavor,
        functional: FunctionalRepository.fromRules(const []),
        ingredientsSource: FakeIngredients({
          'ING-BOEUF': const IngredientSummary(
            ingredientId: 'ING-BOEUF',
            canonicalNameFr: 'Bœuf',
            categoryLevel1: 'animal',
          ),
          'ING-POULET': const IngredientSummary(
            ingredientId: 'ING-POULET',
            canonicalNameFr: 'Poulet',
            categoryLevel1: 'animal',
          ),
        }),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: SingleChildScrollView(child: sheet)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mauvaise combinaison détectée'), findsOneWidget);
      // Les deux ingrédients de la paire incompatible sont listés.
      expect(find.textContaining('Bœuf × Fromage bleu'), findsOneWidget);

      // Tap sur le problème « Bœuf » → section substituts.
      await tester.tap(find.textContaining('Bœuf × Fromage bleu'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Substituts proposés'), findsOneWidget);
      expect(find.text('Poulet'), findsOneWidget);
    });

    testWidgets('bouton Ignorer déclenche le callback', (tester) async {
      var ignored = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: RecommendationSheet(
                ingredients: [ing('ING-BOEUF', 'Bœuf')],
                flavor: FlavorRepository.fromMatches(const []),
                functional: FunctionalRepository.fromRules(const []),
                ingredientsSource: FakeIngredients(const {}),
                onIgnore: () => ignored = true,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ignorer'));
      await tester.pumpAndSettle();
      expect(ignored, isTrue);
    });
  });
}
