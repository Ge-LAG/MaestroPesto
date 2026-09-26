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
    testWidgets('renders nothing with fewer than 2 linked ingredients', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          FlavorCompatibilityHeatmap(
            ingredients: [ing('ING-A')],
            repository: FlavorRepository.fromMatches(const []),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders a 2×2 matrix with pair scores', (tester) async {
      await tester.pumpWidget(
        wrap(
          FlavorCompatibilityHeatmap(
            ingredients: [ing('ING-A'), ing('ING-B')],
            repository: FlavorRepository.fromMatches([
              pair('ING-A', 'ING-B', 0.87),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Compatibilités aromatiques'), findsOneWidget);
      // La paire apparaît dans les deux cellules symétriques.
      expect(find.text('0,87'), findsNWidgets(2));
    });

    testWidgets('renders a 3×3 matrix and unknown pairs stay blank', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          FlavorCompatibilityHeatmap(
            ingredients: [ing('ING-A'), ing('ING-B'), ing('ING-C')],
            repository: FlavorRepository.fromMatches([
              pair('ING-A', 'ING-B', 0.87),
              pair('ING-A', 'ING-C', 0.32),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0,87'), findsNWidgets(2));
      expect(find.text('0,32'), findsNWidgets(2));
      // Paire ING-B × ING-C inconnue → aucun score affiché pour elle.
      expect(find.text('0,00'), findsNothing);
    });

    testWidgets('tapping a cell opens the detail bottom sheet', (tester) async {
      await tester.pumpWidget(
        wrap(
          FlavorCompatibilityHeatmap(
            ingredients: [ing('ING-A'), ing('ING-B')],
            repository: FlavorRepository.fromMatches([
              pair('ING-A', 'ING-B', 0.87),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('0,87').first);
      await tester.pumpAndSettle();
      expect(find.text('ING-A × ING-B'), findsOneWidget);
      expect(find.text('Explication ING-A × ING-B'), findsOneWidget);
    });

    testWidgets('plafond de 30 ingrédients (au-delà, mention « + N »)', (
      tester,
    ) async {
      final many = [for (var i = 0; i < 35; i++) ing('ING-$i')];
      expect(
        FlavorCompatibilityHeatmap.linkedIngredients(many).length,
        kHeatmapMaxIngredients,
      );
      expect(kHeatmapMaxIngredients, 30);
    });

    test('tri par force d’accord puis alphabétique', () {
      final linked = [ing('C'), ing('A'), ing('B')];
      final cells = <String, HeatmapCellData>{
        for (final (a, b, s) in [('A', 'B', 0.9), ('A', 'C', 0.5)]) ...{
          FlavorCompatibilityHeatmap.cellKey(a, b): (
            match: pair(a, b, s),
            size: 2,
          ),
          FlavorCompatibilityHeatmap.cellKey(b, a): (
            match: pair(a, b, s),
            size: 2,
          ),
        },
      };
      final byStrength = FlavorCompatibilityHeatmap.ordered(
        linked,
        cells,
        HeatmapSort.strength,
      );
      // B : 0,9 ; A : (0,9 + 0,5) / 2 = 0,7 ; C : 0,5.
      expect([for (final i in byStrength) i.label], ['B', 'A', 'C']);
      final alpha = FlavorCompatibilityHeatmap.ordered(
        linked,
        cells,
        HeatmapSort.alphabetical,
      );
      expect([for (final i in alpha) i.label], ['A', 'B', 'C']);
      expect(
        FlavorCompatibilityHeatmap.ordered(linked, cells, HeatmapSort.recipe),
        linked,
      );
    });

    testWidgets('filtre « documentés seulement » : prédictions masquées', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          FlavorCompatibilityHeatmap(
            ingredients: [ing('ING-A'), ing('ING-B'), ing('ING-C')],
            repository: FlavorRepository.fromMatches([
              pair('ING-A', 'ING-B', 0.87),
              pair(
                'ING-A',
                'ING-C',
                0.61,
              ).copyWith(evidence: FlavorMatchEvidence.predicted),
            ]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('0,61'), findsNWidgets(2));
      await tester.tap(find.text('Accords documentés seulement'));
      await tester.pumpAndSettle();
      expect(find.text('0,61'), findsNothing);
      expect(find.text('0,87'), findsNWidgets(2));
    });

    testWidgets('matrice trop grande : défilement dans les deux sens', (
      tester,
    ) async {
      final ids = [for (var i = 0; i < 20; i++) 'ING-$i'];
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 600,
            child: FlavorCompatibilityHeatmap(
              ingredients: [for (final id in ids) ing(id)],
              repository: FlavorRepository.fromMatches([
                for (var i = 1; i < ids.length; i++) pair(ids[0], ids[i], 0.8),
              ]),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final bars = tester
          .widgetList<Scrollbar>(find.byType(Scrollbar))
          .where((s) => s.thumbVisibility ?? false);
      expect(bars.length, 2, reason: 'ascenseurs vertical et horizontal');
      expect(tester.takeException(), isNull);
    });
  });
}
