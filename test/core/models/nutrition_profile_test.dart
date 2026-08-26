// Phase 09 — tests du modèle pur NutritionProfile (Lot F, ac-F-005).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';

NutritionProfile profile({
  double energyKcal = 18,
  double proteins = 0.9,
  double carbs = 3.9,
  double fats = 0.2,
  double salt = 0.01,
  double? waterContent = 94.5,
  String stateId = 'raw',
}) {
  return NutritionProfile(
    energyKcal: energyKcal,
    proteins: proteins,
    carbs: carbs,
    sugars: 2.6,
    fats: fats,
    saturatedFats: 0.03,
    fiber: 1.2,
    salt: salt,
    waterContent: waterContent,
    ingredientStateId: stateId,
    confidence: 0.8,
    recordCount: 3,
  );
}

void main() {
  test('empty : tous les nutriments à zéro, état raw, 0 record', () {
    const empty = NutritionProfile.empty;
    expect(empty.energyKcal, 0);
    expect(empty.proteins, 0);
    expect(empty.carbs, 0);
    expect(empty.fats, 0);
    expect(empty.salt, 0);
    expect(empty.waterContent, isNull);
    expect(empty.ingredientStateId, 'raw');
    expect(empty.confidence, 0);
    expect(empty.recordCount, 0);
  });

  test('== et hashCode couvrent tous les champs', () {
    expect(profile(), profile());
    expect(profile().hashCode, profile().hashCode);
    expect(profile(), isNot(profile(energyKcal: 19)));
    expect(profile(), isNot(profile(stateId: 'boiled')));
    expect(profile(), isNot(profile(waterContent: null)));
  });

  test('copyWith préserve les champs non fournis', () {
    final base = profile();
    final copied = base.copyWith(energyKcal: 32, waterContent: null);
    expect(copied.energyKcal, 32);
    expect(copied.waterContent, isNull);
    expect(copied.proteins, base.proteins);
    expect(copied.ingredientStateId, 'raw');
    expect(copied.recordCount, base.recordCount);
  });
}
