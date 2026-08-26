// Phase 09 Lot F — tests unitaires pour IngredientSummary.

import 'package:test/test.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';

void main() {
  group('IngredientSummary', () {
    const tomate = IngredientSummary(
      ingredientId: 'ING-PLANT-TOMATE-000001',
      canonicalNameFr: 'Tomate',
      canonicalNameEn: 'Tomato',
      categoryLevel1: 'vegetal',
      categoryLevel2: 'fruit',
      categoryLevel3: 'fruit-frais',
      allergenTags: <String>[],
    );

    const basilic = IngredientSummary(
      ingredientId: 'ING-PLANT-BASILIC-000001',
      canonicalNameFr: 'Basilic',
      categoryLevel1: 'vegetal',
      categoryLevel2: 'herbe',
    );

    const vin = IngredientSummary(
      ingredientId: 'ING-BOISSON-VIN-000001',
      canonicalNameFr: 'Vin rouge',
      categoryLevel1: 'boisson',
      isAlcoholic: true,
      isFermented: true,
    );

    const arachide = IngredientSummary(
      ingredientId: 'ING-PLANT-ARACHIDE-000001',
      canonicalNameFr: 'Arachide',
      categoryLevel1: 'vegetal',
      allergenTags: <String>['arachide', 'fruit-a-coque'],
    );

    test('displayName retourne le nom FR canonique', () {
      expect(tomate.displayName, 'Tomate');
    });

    test('categoryBreadcrumb assemble level_1/2/3 non-vides', () {
      expect(tomate.categoryBreadcrumb, 'vegetal › fruit › fruit-frais');
    });

    test('categoryBreadcrumb omet les niveaux null/vides', () {
      expect(basilic.categoryBreadcrumb, 'vegetal › herbe');
    });

    test('hasAllergens est faux si la liste est vide', () {
      expect(tomate.hasAllergens, isFalse);
    });

    test('hasAllergens est vrai si la liste contient au moins une entrée', () {
      expect(arachide.hasAllergens, isTrue);
    });

    test('isAlcoholic et isFermented ont des défauts false', () {
      expect(tomate.isAlcoholic, isFalse);
      expect(tomate.isFermented, isFalse);
    });

    test('isAlcoholic/isFermented peuvent être true', () {
      expect(vin.isAlcoholic, isTrue);
      expect(vin.isFermented, isTrue);
    });

    test('copyWith préserve les champs non modifiés', () {
      final updated = tomate.copyWith(categoryLevel2: 'legume');
      expect(updated.ingredientId, tomate.ingredientId);
      expect(updated.canonicalNameFr, tomate.canonicalNameFr);
      expect(updated.categoryLevel1, tomate.categoryLevel1);
      expect(updated.categoryLevel2, 'legume');
      expect(updated.categoryLevel3, tomate.categoryLevel3);
    });

    test('copyWith peut écraser un booléen', () {
      final updated = basilic.copyWith(isAlcoholic: true);
      expect(updated.isAlcoholic, isTrue);
      expect(updated.isFermented, isFalse);
    });

    test('égalité : deux summaries identiques sont égaux', () {
      const a = IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000001',
        canonicalNameFr: 'Tomate',
        categoryLevel1: 'vegetal',
      );
      const b = IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000001',
        canonicalNameFr: 'Tomate',
        categoryLevel1: 'vegetal',
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
    });

    test('égalité : un champ différent => pas égaux', () {
      const a = IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000001',
        canonicalNameFr: 'Tomate',
        categoryLevel1: 'vegetal',
      );
      const b = IngredientSummary(
        ingredientId: 'ING-PLANT-TOMATE-000001',
        canonicalNameFr: 'Tomate',
        categoryLevel1: 'fruit',
      );
      expect(a, isNot(equals(b)));
    });

    test('égalité : allergenTags ordre-respectée', () {
      const a = IngredientSummary(
        ingredientId: 'X',
        canonicalNameFr: 'X',
        categoryLevel1: 'vegetal',
        allergenTags: <String>['a', 'b'],
      );
      const b = IngredientSummary(
        ingredientId: 'X',
        canonicalNameFr: 'X',
        categoryLevel1: 'vegetal',
        allergenTags: <String>['a', 'b'],
      );
      const c = IngredientSummary(
        ingredientId: 'X',
        canonicalNameFr: 'X',
        categoryLevel1: 'vegetal',
        allergenTags: <String>['b', 'a'],
      );
      expect(a, equals(b));
      expect(a, isNot(equals(c))); // ordre différent = différent (List equality)
    });

    test('toString inclut id + nom + catégorie', () {
      expect(
        tomate.toString(),
        contains('ING-PLANT-TOMATE-000001'),
      );
      expect(tomate.toString(), contains('Tomate'));
      expect(tomate.toString(), contains('vegetal'));
    });
  });
}
