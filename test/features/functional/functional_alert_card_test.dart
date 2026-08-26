// Phase 09 Lot H — H2 : widget tests de la FunctionalAlertCard (§8.3).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/functional/presentation/widgets/functional_alert_card.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

RecipeIngredient ing(String id) => RecipeIngredient(
  label: id,
  quantity: '100 g',
  source: IngredientSource.ciqual,
  ingredientId: id,
);

const rule = InteractionRule(
  ruleId: 'RULE-GEL-GELATINE',
  ruleFamily: 'gelling',
  reactantOrComponentIds: 'PROT_GEL',
  ingredientConstraints: 'gelatine_present',
  predictedEffect: 'thermoreversible_gel',
  effectDirection: 'increase',
  confidence: 0.95,
  notes: 'Force du gel proportionnelle à concentration.',
);

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SingleChildScrollView(child: child)),
);

void main() {
  group('FunctionalAlertCard', () {
    testWidgets('renders nothing without linked ingredients', (tester) async {
      await tester.pumpWidget(
        wrap(
          FunctionalAlertCard(
            ingredients: const [
              RecipeIngredient(
                label: 'Truc libre',
                quantity: '1',
                source: IngredientSource.free,
              ),
            ],
            repository: FunctionalRepository.fromRules(const [rule]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders nothing when no rule matches', (tester) async {
      await tester.pumpWidget(
        wrap(
          FunctionalAlertCard(
            ingredients: [ing('ING-UNKNOWN')],
            repository: FunctionalRepository.fromRules(const [rule]),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsNothing);
    });

    testWidgets('renders alert and expands on tap', (tester) async {
      await tester.pumpWidget(
        wrap(
          FunctionalAlertCard(
            ingredients: [ing('PROT_GEL')],
            repository: FunctionalRepository.fromRules(const [rule]),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alertes physico-chimiques'), findsOneWidget);
      expect(
        find.text('Force du gel proportionnelle à concentration.'),
        findsOneWidget,
      );
      // Conditions masquées avant expansion.
      expect(find.text('• gelatine_present'), findsNothing);

      await tester.tap(find.byType(ExpansionTile));
      await tester.pumpAndSettle();

      expect(find.text('• gelatine_present'), findsOneWidget);
      expect(find.text('thermoreversible_gel'), findsOneWidget);
    });
  });
}
