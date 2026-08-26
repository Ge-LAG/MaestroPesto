// Phase 09 — widget tests du IngredientsPickerPage (Lot F, ac-F-005).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/features/ingredients/presentation/ingredients_picker_page.dart';

const corpus = <IngredientSummary>[
  IngredientSummary(
    ingredientId: 'ING-PLANT-TOMATE-000001',
    canonicalNameFr: 'Tomate',
    categoryLevel1: 'vegetal',
  ),
  IngredientSummary(
    ingredientId: 'ING-PLANT-BASILIC-000001',
    canonicalNameFr: 'Basilic',
    categoryLevel1: 'vegetal',
  ),
  IngredientSummary(
    ingredientId: 'ING-DAIRY-MOZZARELLA-000001',
    canonicalNameFr: 'Mozzarella',
    categoryLevel1: 'animal',
    allergenTags: ['lait'],
  ),
];

Future<IngredientSummary?>? pickerFuture;

Widget host() {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => Center(
          child: TextButton(
            onPressed: () =>
                pickerFuture = showIngredientsPicker(context, all: corpus),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
}

Future<void> openPicker(WidgetTester tester) async {
  pickerFuture = null;
  await tester.pumpWidget(host());
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('affiche tous les ingrédients sans recherche', (tester) async {
    await openPicker(tester);
    expect(find.text('Tomate'), findsOneWidget);
    expect(find.text('Basilic'), findsOneWidget);
    expect(find.text('Mozzarella'), findsOneWidget);
  });

  testWidgets('la recherche filtre les résultats (insensible casse)', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.enterText(find.byType(EditableText), 'TOMATE');
    await tester.pump();
    expect(find.text('Tomate'), findsOneWidget);
    expect(find.text('Basilic'), findsNothing);
  });

  testWidgets('aucun résultat affiche le message dédié', (tester) async {
    await openPicker(tester);
    await tester.enterText(find.byType(EditableText), 'zzzzzz');
    await tester.pump();
    expect(find.text('Aucun ingrédient ne correspond.'), findsOneWidget);
  });

  testWidgets('le chip de catégorie filtre la liste', (tester) async {
    await openPicker(tester);
    // Cible le chip (le mot « animal » apparaît aussi dans le
    // breadcrumb de la row Mozzarella).
    final animalChip = find.descendant(
      of: find.byType(FilterChip),
      matching: find.text('animal'),
    );
    await tester.tap(animalChip);
    await tester.pump();
    expect(find.text('Mozzarella'), findsOneWidget);
    expect(find.text('Tomate'), findsNothing);
  });

  testWidgets('tap sur un row renvoie l\'ingrédient sélectionné', (
    tester,
  ) async {
    await openPicker(tester);
    await tester.tap(find.text('Basilic'));
    await tester.pumpAndSettle();

    final result = await pickerFuture!;
    expect(result, isNotNull);
    expect(result!.ingredientId, 'ING-PLANT-BASILIC-000001');
    expect(result.canonicalNameFr, 'Basilic');
  });

  testWidgets('chips de filtre lisibles : texte noir (retour PO n°4)', (
    tester,
  ) async {
    await openPicker(tester);
    final chips = find.byType(FilterChip);
    // « Toutes » + les catégories du corpus.
    expect(chips, findsNWidgets(3));
    for (final chip in tester.widgetList<FilterChip>(chips)) {
      final label = chip.label;
      expect(label, isA<Text>(), reason: 'label Text attendu');
      final style = (label as Text).style;
      expect(style?.color, Colors.black87, reason: 'texte noir sur fond clair');
    }
  });
}
