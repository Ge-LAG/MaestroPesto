// Phase 09 Lot G — G4 : widget tests de la heatmap (§7.3).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/flavor/presentation/widgets/flavor_compatibility_heatmap.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

RecipeIngredient ing(String id) => RecipeIngredient(
      label: id,
      quantity: '100 g',
      source: IngredientSource.ciqual,
      ingredientId: id,
    );

FlavorMatch pair(String a, String b, double score) => FlavorMatch(
      ingredientAId: a,
      ingredientBId: b,
      combinationSize: 2,
      overallScore: score,
      explanation: 'Explication $a × $b',
    );

Widget wrap(Widget child) => MaterialApp(
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );

void main() {
  group('FlavorCompatibilityHeatmap', () {
    testWidgets('renders nothing with fewer than 2 linked ingredients',
        (tester) async {
      await tester.pumpWidget(wrap(
        FlavorCompatibilityHeatmap(
          ingredients: [ing('ING-A')],
          repository: FlavorRepository.fromMatches(const []),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders a 2×2 matrix with pair scores', (tester) async {
      await tester.pumpWidget(wrap(
        FlavorCompatibilityHeatmap(
          ingredients: [ing('ING-A'), ing('ING-B')],
          repository: FlavorRepository.fromMatches([
            pair('ING-A', 'ING-B', 0.87),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Compatibilités aromatiques'), findsOneWidget);
      // La paire apparaît dans les deux cellules symétriques.
      expect(find.text('0.87'), findsNWidgets(2));
    });

    testWidgets('renders a 3×3 matrix and unknown pairs stay blank',
        (tester) async {
      await tester.pumpWidget(wrap(
        FlavorCompatibilityHeatmap(
          ingredients: [ing('ING-A'), ing('ING-B'), ing('ING-C')],
          repository: FlavorRepository.fromMatches([
            pair('ING-A', 'ING-B', 0.87),
            pair('ING-A', 'ING-C', 0.32),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      expect(find.text('0.87'), findsNWidgets(2));
      expect(find.text('0.32'), findsNWidgets(2));
      // Paire ING-B × ING-C inconnue → aucun score affiché pour elle.
      expect(find.text('0.00'), findsNothing);
    });

    testWidgets('tapping a cell opens the detail bottom sheet',
        (tester) async {
      await tester.pumpWidget(wrap(
        FlavorCompatibilityHeatmap(
          ingredients: [ing('ING-A'), ing('ING-B')],
          repository: FlavorRepository.fromMatches([
            pair('ING-A', 'ING-B', 0.87),
          ]),
        ),
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('0.87').first);
      await tester.pumpAndSettle();
      expect(find.text('ING-A × ING-B'), findsOneWidget);
      expect(find.text('Explication ING-A × ING-B'), findsOneWidget);
    });

    testWidgets('caps the matrix at 5 ingredients', (tester) async {
      final many = [for (var i = 0; i < 7; i++) ing('ING-$i')];
      expect(
        FlavorCompatibilityHeatmap.linkedIngredients(many).length,
        5,
      );
    });
  });
}
