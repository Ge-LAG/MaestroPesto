// Phase 10 Lot E — moteur d'accords aromatiques (fonction pure).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/flavor_profile.dart';
import 'package:maestropesto/core/scoring/flavor_pairing_engine.dart';

FlavorProfile p(
  String id,
  Map<String, double> d, {
  FlavorContext context = FlavorContext.both,
  double intensity = 0.5,
  double confidence = 0.6,
}) => FlavorProfile(
  ingredientId: id,
  descriptors: d,
  context: context,
  intensity: intensity,
  confidence: confidence,
);

void main() {
  final citron = p('citron', {'citrus': 0.9, 'sour': 0.95, 'green': 0.4});
  final zeste = p('zeste', {'citrus': 0.95, 'floral': 0.4, 'bitter': 0.4});
  final saumon = p('saumon', {'fatty': 0.7, 'marine': 0.4, 'umami': 0.5});
  final vanille = p(
    'vanille',
    {'vanillic': 0.95, 'sweet': 0.6},
    context: FlavorContext.sweet,
    intensity: 0.8,
  );
  final ail = p(
    'ail',
    {'sulfurous': 0.9, 'pungent': 0.8},
    context: FlavorContext.savory,
    intensity: 0.95,
  );

  test('ingrédient sans arôme (sel) : prédiction neutre, pas discutable', () {
    final sel = p('sel', {'salty': 1.0}, intensity: 0.6);
    for (final other in [citron, saumon, vanille]) {
      final m = FlavorPairingEngine.scorePair(sel, other);
      expect(m.evidence, FlavorMatchEvidence.predicted);
      expect(
        m.overallScore,
        greaterThanOrEqualTo(0.55),
        reason: other.ingredientId,
      );
      expect(m.explanation, contains('non discriminant'));
    }
    expect(FlavorPairingEngine.aromaInformation(sel, citron), 0);
    expect(FlavorPairingEngine.aromaInformation(citron, zeste), 1);
  });

  test('sans soutien empirique : prédiction, jamais incompatibilité', () {
    final m = FlavorPairingEngine.scorePair(ail, vanille);
    expect(m.evidence, FlavorMatchEvidence.predicted);
    expect(m.isPrediction, isTrue);
    expect(m.isSupportedIncompatibility, isFalse);
    expect(m.confidence, lessThanOrEqualTo(0.6));
    expect(m.explanation, contains('Prédiction'));
  });

  test('les arômes partagés rapprochent deux ingrédients', () {
    final shared = FlavorPairingEngine.scorePair(citron, zeste);
    final none = FlavorPairingEngine.scorePair(citron, vanille);
    expect(shared.overallScore, greaterThan(none.overallScore));
    expect(shared.sharedDescriptors, contains('citrus'));
  });

  test('gras relevé par l’acidité : équilibre gustatif favorable', () {
    expect(
      FlavorPairingEngine.tasteBalance(saumon, citron),
      greaterThan(FlavorPairingEngine.tasteBalance(saumon, saumon) - 0.2),
    );
    expect(
      FlavorPairingEngine.scorePair(saumon, citron).explanation,
      contains('gras relevé'),
    );
  });

  test('accord curaté classique ≥ 0,70 ; contraste négatif < 0,40', () {
    final classic = FlavorPairingEngine.scorePair(
      saumon,
      citron,
      empirical: const EmpiricalPairing(score: 0.92, observed: false),
    );
    expect(classic.overallScore, greaterThanOrEqualTo(0.70));
    expect(classic.evidence, FlavorMatchEvidence.curated);
    final negative = FlavorPairingEngine.scorePair(
      ail,
      vanille,
      empirical: const EmpiricalPairing(
        score: 0.2,
        observed: false,
        kind: 'contrast_negative',
      ),
    );
    expect(negative.overallScore, lessThan(0.40));
    expect(negative.isSupportedIncompatibility, isTrue);
  });

  test('dominance : un ingrédient très puissant face à un délicat', () {
    final delicate = p('delicat', {'dairy': 0.5}, intensity: 0.1);
    expect(FlavorPairingEngine.dominanceRisk(ail, delicate), greaterThan(0.3));
    expect(FlavorPairingEngine.dominanceRisk(saumon, citron), 0);
  });

  test('contexte sucré × salé opposé pénalisé', () {
    expect(
      FlavorPairingEngine.contextFit(FlavorContext.sweet, FlavorContext.savory),
      lessThan(0.5),
    );
  });

  test('ponts aromatiques d’une combinaison', () {
    final bridges = FlavorPairingEngine.bridges([citron, zeste, saumon]);
    expect(bridges.keys, contains('citrus'));
    expect(bridges['citrus'], containsAll(['citron', 'zeste']));
  });
}
