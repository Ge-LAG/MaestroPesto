// Phase 10 Lot B (ac-128) — conversion des quantités culinaires.
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/scoring/quantity_converter.dart';

void main() {
  group('QuantityConverter.parse', () {
    test('fractions, glyphes, plages et articles', () {
      expect(QuantityConverter.parse('1/2 botte')!.$1, 0.5);
      expect(QuantityConverter.parse('½ citron')!.$1, 0.5);
      expect(QuantityConverter.parse('2-3 gousses')!.$1, 2.5);
      expect(QuantityConverter.parse('2 à 3 gousses')!.$1, 2.5);
      expect(QuantityConverter.parse('une pincée')!.$2.id, 'pincee');
      expect(QuantityConverter.parse('au goût'), isNull);
    });

    test('« g » ne capture pas « gousse »', () {
      expect(QuantityConverter.parse('2 gousses')!.$2.id, 'gousse');
      expect(QuantityConverter.parse('2 g')!.$2.id, 'g');
    });
  });

  group('QuantityConverter.resolve', () {
    test('masse exacte, sans hypothèse', () {
      final r = QuantityConverter.resolve('60 g')!;
      expect(r.grams, 60);
      expect(r.isExact, isTrue);
    });

    test('volume × densité de l’ingrédient', () {
      final r = QuantityConverter.resolve(
        '2 c. à soupe',
        data: const IngredientUnitData(densityGPerMl: 0.92),
      )!;
      expect(r.grams, closeTo(27.6, 1e-9));
      expect(r.assumption, contains('0.92'));
    });

    test('volume sans densité : 1 g/ml signalé', () {
      final r = QuantityConverter.resolve('10 cl')!;
      expect(r.grams, 100);
      expect(r.assumption, contains('1 g/ml'));
    });

    test('nombre sans unité : pièces si masse unitaire connue', () {
      final r = QuantityConverter.resolve(
        '2',
        data: const IngredientUnitData(unitMasses: {'piece': 50}),
      )!;
      expect(r.grams, 100);
      expect(r.unit.id, 'piece');
    });

    test('nombre sans unité et sans masse unitaire : grammes signalés', () {
      final r = QuantityConverter.resolve('2')!;
      expect(r.grams, 2);
      expect(r.assumption, isNotNull);
    });

    test('unité de compte : masse spécifique prioritaire', () {
      final r = QuantityConverter.resolve(
        '3 gousses',
        data: const IngredientUnitData(unitMasses: {'gousse': 6}),
      )!;
      expect(r.grams, 18);
    });
  });
}
