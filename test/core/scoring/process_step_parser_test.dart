// Phase 10 Lot F — analyse des étapes de préparation.
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/process_models.dart';
import 'package:maestropesto/core/scoring/process_step_parser.dart';

void main() {
  test('four : opération, température et durée', () {
    final s = ProcessStepParser.parse(0, 'Enfourner 25 min à 180 °C.');
    expect(s.primary!.opId, 'PROC_ROTIR');
    expect(s.temperatureC, 180);
    expect(s.durationMin, 25);
    expect(s.cookingMethod, CookingMethod.roasted);
    expect(s.isDryHeat, isTrue);
  });

  test('thermostat et durée en heures', () {
    final s = ProcessStepParser.parse(0, 'Cuire au four th. 6 pendant 1 h 30');
    expect(s.temperatureC, 180);
    expect(s.durationMin, 90);
  });

  test('préchauffage : aucune cuisson, température reportée au four', () {
    final steps = ProcessStepParser.parseAll([
      'Préchauffer le four à 200 °C.',
      'Enfourner le gratin 40 minutes.',
    ]);
    expect(steps[0].operations, isEmpty);
    expect(steps[1].temperatureC, 200);
  });

  test('ingrédients cités dans une étape', () {
    final s = ProcessStepParser.parse(
      0,
      'Faire revenir les oignons dans le beurre',
      ingredientLabels: ['Oignon', 'Beurre doux', 'Carotte'],
    );
    expect(s.mentionedIngredients, [0, 1]);
    expect(s.cookingMethod, CookingMethod.sauteed);
  });

  test('mécanique et froid : fouetter, réfrigérer', () {
    final s = ProcessStepParser.parse(0, 'Fouetter les blancs en neige');
    expect(s.hasShear, isTrue);
    expect(s.isHeating, isFalse);
    final c = ProcessStepParser.parse(1, 'Réfrigérer 2 h pour laisser prendre');
    expect(c.isCooling, isTrue);
    expect(c.durationMin, 120);
  });

  test('pas de faux positifs : bouillon, poche à douille, marinière', () {
    expect(
      ProcessStepParser.parse(0, 'Ajouter le bouillon').isHeating,
      isFalse,
    );
    expect(
      ProcessStepParser.parse(0, 'Garnir une poche à douille').isHeating,
      isFalse,
    );
    expect(
      ProcessStepParser.parse(
        0,
        'Servir les moules marinières',
      ).operations.map((o) => o.opId),
      isNot(contains('PROC_MACERER')),
    );
  });

  test('ébullition et mijotage', () {
    expect(
      ProcessStepParser.parse(0, 'Porter à ébullition 1 min').cookingMethod,
      CookingMethod.boiled,
    );
    expect(
      ProcessStepParser.parse(0, 'Laisser mijoter 2 heures').cookingMethod,
      CookingMethod.stewed,
    );
  });
}
