// Phase 09 — widget tests du IngredientDetailCard (Lot F, ac-F-005).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/ingredient_detail.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/features/ingredients/presentation/ingredient_detail_card.dart';

const detail = IngredientDetail(
  ingredientId: 'ING-PLANT-TOMATE-000001',
  canonicalNameFr: 'Tomate',
  categoryLevel1: 'vegetal',
  categoryLevel2: 'fruit-légume',
  scientificName: 'Solanum lycopersicum',
  allergenTags: ['lait'],
);

const nutrition = NutritionProfile(
  energyKcal: 18,
  proteins: 0.9,
  carbs: 3.9,
  sugars: 2.6,
  fats: 0.2,
  saturatedFats: 0.03,
  fiber: 1.2,
  salt: 0.01,
  ingredientStateId: 'raw',
  confidence: 0.8,
  recordCount: 3,
);

Widget host({NutritionProfile? n}) {
  return MaterialApp(
    home: Scaffold(
      body: IngredientDetailCard(detail: detail, nutrition: n),
    ),
  );
}

void main() {
  testWidgets('affiche nom, nom scientifique et breadcrumb', (tester) async {
    await tester.pumpWidget(host(n: nutrition));
    expect(find.text('Tomate'), findsOneWidget);
    expect(
      find.text('Solanum lycopersicum', findRichText: true),
      findsOneWidget,
    );
    expect(find.text('vegetal › fruit-légume'), findsOneWidget);
  });

  testWidgets('affiche les allergènes en chips', (tester) async {
    await tester.pumpWidget(host(n: nutrition));
    expect(find.text('Allergènes'), findsOneWidget);
    expect(find.text('lait'), findsOneWidget);
  });

  testWidgets('affiche la mini nutrition quand elle est fournie', (
    tester,
  ) async {
    await tester.pumpWidget(host(n: nutrition));
    expect(find.byType(Text), findsWidgets);
    expect(find.textContaining('18 kcal'), findsOneWidget);
    expect(find.textContaining('Énergie'), findsOneWidget);
  });

  testWidgets('sans nutrition : message « non disponible »', (tester) async {
    await tester.pumpWidget(host());
    expect(find.text('Nutrition non disponible'), findsOneWidget);
  });
}
