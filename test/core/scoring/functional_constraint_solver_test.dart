// Phase 09 Lot H / Phase 10 Lots C-F : tests du FunctionalConstraintSolver.
//
// Les fixtures reprennent les 16 règles réelles de
// `database-metier/phase4-functional/interaction_rules.csv`
// (lecture seule, calibration v1).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/core/scoring/functional_constraint_solver.dart';
import 'package:maestropesto/core/scoring/physchem_estimator.dart';
import 'package:maestropesto/core/scoring/process_step_parser.dart';

/// Les 16 règles réelles du CSV Phase 4 (colonnes utiles à la v1).
List<InteractionRule> realRules() => const [
  InteractionRule(
    ruleId: 'RULE-PEC-HM-001',
    ruleFamily: 'gelling',
    reactantOrComponentIds: 'POLY_PEC_HM|SM_SUCROSE',
    ingredientConstraints: 'pectine_HM_presence',
    compositionConstraints: 'sugar_60-65pct_required',
    processConstraints: 'T_below_boiling',
    phMin: 2.5,
    phMax: 4.0,
    temperatureMin: 60,
    temperatureMax: 105,
    predictedEffect: 'gel_formation',
    effectDirection: 'increase_gel_strength',
    evidenceType: 'expert_rule_with_literature',
    confidence: 0.92,
    notes: 'Pectine HM gélifie uniquement si sucre > 60% ET pH < 4.0.',
  ),
  InteractionRule(
    ruleId: 'RULE-PEC-LM-001',
    ruleFamily: 'gelling',
    reactantOrComponentIds: 'POLY_PEC_LM|SM_CA',
    predictedEffect: 'gel_formation',
    effectDirection: 'increase',
    confidence: 0.88,
    notes: 'Pectine LM gélifie au calcium (egg-box model).',
  ),
  InteractionRule(
    ruleId: 'RULE-GEL-GELATINE',
    ruleFamily: 'gelling',
    reactantOrComponentIds: 'PROT_GEL',
    predictedEffect: 'thermoreversible_gel',
    effectDirection: 'increase',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-AGAR-GEL',
    ruleFamily: 'gelling',
    reactantOrComponentIds: 'POLY_AGAR',
    predictedEffect: 'thermo_irreversible_gel',
    effectDirection: 'increase',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-MAYO-001',
    ruleFamily: 'emulsion',
    reactantOrComponentIds: 'LIP_TRIGLY|PROT_OVALB',
    predictedEffect: 'o/w_emulsion_stable',
    effectDirection: 'increase_stability',
    confidence: 0.90,
  ),
  InteractionRule(
    ruleId: 'RULE-HL-EMULSION',
    ruleFamily: 'emulsion',
    reactantOrComponentIds: 'LIP_PHOSPH',
    predictedEffect: 'emulsification',
    effectDirection: 'increase',
    confidence: 0.90,
  ),
  InteractionRule(
    ruleId: 'RULE-MAILLARD',
    ruleFamily: 'browning',
    reactantOrComponentIds: 'SM_GLU_MONO|PROT_CASEINE|PROT_WHEY',
    predictedEffect: 'Maillard_browning_aroma',
    effectDirection: 'increase_color_aroma',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-CARAMEL',
    ruleFamily: 'browning',
    reactantOrComponentIds: 'SM_SUCROSE',
    predictedEffect: 'caramelization_color_aroma',
    effectDirection: 'increase',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-STARCH-GEL',
    ruleFamily: 'starch',
    reactantOrComponentIds: 'POLY_AMIDON',
    predictedEffect: 'gelatinization_viscosity_increase',
    effectDirection: 'increase_viscosity',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-STARCH-RETROGRAD',
    ruleFamily: 'starch',
    reactantOrComponentIds: 'POLY_AMYLOSE',
    predictedEffect: 'retrogradation_syneresis',
    effectDirection: 'increase_firmness_release_water',
    confidence: 0.85,
  ),
  InteractionRule(
    ruleId: 'RULE-GLUTEN-DEVEL',
    ruleFamily: 'protein',
    reactantOrComponentIds: 'PROT_GLU',
    predictedEffect: 'gluten_network_formation',
    effectDirection: 'increase_viscosity_elasticity',
    confidence: 0.92,
  ),
  InteractionRule(
    ruleId: 'RULE-SALT-CASEIN',
    ruleFamily: 'taste',
    reactantOrComponentIds: 'SM_SALT|PROT_CASEINE',
    predictedEffect: 'flavor_enhancement',
    effectDirection: 'increase_umami_perception',
    confidence: 0.75,
  ),
  InteractionRule(
    ruleId: 'RULE-EGG-COAG',
    ruleFamily: 'protein',
    reactantOrComponentIds: 'PROT_OVALB',
    predictedEffect: 'protein_coagulation',
    effectDirection: 'solidify',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-AW-MICRO',
    ruleFamily: 'safety',
    reactantOrComponentIds: '',
    predictedEffect: 'microbiological_stability',
    effectDirection: 'control_micro_growth',
    confidence: 0.95,
    notes: 'Indicateur de sécurité — non prédictif suffisant.',
  ),
  InteractionRule(
    ruleId: 'RULE-PH-COAG-CASEIN',
    ruleFamily: 'protein',
    reactantOrComponentIds: 'PROT_CASEINE',
    predictedEffect: 'isoelectric_coagulation',
    effectDirection: 'solidify',
    confidence: 0.95,
  ),
  InteractionRule(
    ruleId: 'RULE-GELATIN-ACID',
    ruleFamily: 'gelling',
    reactantOrComponentIds: 'PROT_GEL',
    phMin: 3.0,
    phMax: 4.5,
    predictedEffect: 'fragile_gel_syneresis',
    effectDirection: 'decrease_gel_strength',
    confidence: 0.85,
    notes: 'Gélatine ne gélifie pas bien sous pH 3.5.',
  ),
];

NutritionProfile comp({
  double water = 0,
  double sugars = 0,
  double fats = 0,
  double proteins = 0,
  double salt = 0,
}) => NutritionProfile(
  energyKcal: 0,
  proteins: proteins,
  carbs: sugars,
  sugars: sugars,
  fats: fats,
  saturatedFats: 0,
  fiber: 0,
  salt: salt,
  waterContent: water,
  ingredientStateId: 'raw',
  confidence: 0.9,
  recordCount: 5,
);

PhysChemState mix(List<MixLine> lines, [List<String> steps = const []]) =>
    PhysChemEstimator.estimate(lines, steps: ProcessStepParser.parseAll(steps));

List<FunctionalAlert> run(PhysChemState s) =>
    FunctionalConstraintSolver.evaluateMix(state: s, rules: realRules());

FunctionalAlert? find(List<FunctionalAlert> alerts, String id) {
  for (final a in alerts) {
    if (a.alertId == id) return a;
  }
  return null;
}

// Lignes types.
MixLine sugar(double g, [int i = 0]) => MixLine(
  index: i,
  label: 'Sucre',
  ingredientId: 'SUCRE',
  grams: g,
  profile: comp(sugars: 99.8),
  components: const {'SM_SUCROSE': 99.8},
  ph: 7,
);
MixLine water(double g, [int i = 1]) => MixLine(
  index: i,
  label: 'Eau',
  ingredientId: 'EAU',
  grams: g,
  profile: comp(water: 100),
  ph: 7,
);
MixLine pectinHm(double g, [int i = 2]) => MixLine(
  index: i,
  label: 'Pectine HM',
  ingredientId: 'PECTINE',
  grams: g,
  profile: comp(water: 12),
  components: const {'POLY_PEC_HM': 85},
  ph: 3.5,
);
MixLine citric(double g, [int i = 3]) => MixLine(
  index: i,
  label: 'Acide citrique',
  ingredientId: 'CITRIQUE',
  grams: g,
  components: const {'SM_CIT': 99.5},
  ph: 2.2,
);
MixLine gelatin(double g, [int i = 4]) => MixLine(
  index: i,
  label: 'Gélatine',
  ingredientId: 'GELATINE',
  grams: g,
  profile: comp(water: 12, proteins: 86),
  components: const {'PROT_GEL': 86},
  ph: 5.5,
);

void main() {
  group('FunctionalConstraintSolver v2 — vraies règles Phase 4', () {
    test('16 règles dans le jeu de fixtures', () {
      expect(realRules().length, 16);
    });

    test('mélange vide : aucune alerte', () {
      expect(run(mix(const [])), isEmpty);
    });

    test('confiture : pectine HM, sucre 61 %, acide, ébullition → gel', () {
      final alerts = run(
        mix(
          [sugar(600), water(380), pectinHm(12), citric(8)],
          ['Chauffer eau et sucre', 'Porter à ébullition 1 min'],
        ),
      );
      final a = find(alerts, 'RULE-PEC-HM-001')!;
      expect(a.status, RuleStatus.conditionsMet);
      expect(a.severity, FunctionalSeverity.info);
      expect(a.advice, isNull);
      expect(a.triggerIngredientIds, contains('PECTINE'));
      expect(a.mixShare, closeTo(0.6 + 0.012, 0.01));
      expect(a.expectedOutcome, contains('Gel'));
    });

    test('pectine HM sans assez de sucre → warning avec conseil', () {
      final alerts = run(
        mix(
          [sugar(100), water(880), pectinHm(12), citric(8)],
          ['Porter à ébullition'],
        ),
      );
      final a = find(alerts, 'RULE-PEC-HM-001')!;
      expect(a.status, RuleStatus.notMet);
      expect(a.severity, FunctionalSeverity.warning);
      expect(a.advice, contains('60–65 %'));
      expect(a.checks.first.met, isFalse);
    });

    test('confiance = règle × part évaluable (fin du × 0,5)', () {
      final alerts = run(
        mix(
          [sugar(600), water(380), pectinHm(12), citric(8)],
          ['Porter à ébullition'],
        ),
      );
      expect(find(alerts, 'RULE-PEC-HM-001')!.confidence, closeTo(0.92, 1e-9));
    });

    test('gélatine : dose trop faible → warning ; dose correcte → info', () {
      final low = find(
        run(mix([water(500), gelatin(0.5)], ['Chauffer', 'Réfrigérer'])),
        'RULE-GEL-GELATINE',
      )!;
      expect(low.severity, FunctionalSeverity.warning);
      final ok = find(
        run(mix([water(500), gelatin(8)], ['Chauffer', 'Réfrigérer 4 h'])),
        'RULE-GEL-GELATINE',
      )!;
      expect(ok.status, RuleStatus.conditionsMet);
      expect(ok.severity, FunctionalSeverity.info);
    });

    test('gélatine en milieu acide : effet indésirable signalé', () {
      final alerts = run(
        mix([water(500), gelatin(8), citric(10)], ['Chauffer', 'Réfrigérer']),
      );
      final acid = find(alerts, 'RULE-GELATIN-ACID')!;
      expect(acid.severity, FunctionalSeverity.warning);
      expect(acid.advice, contains('agar'));
      // Sans acide : aucune alerte d'acidité.
      expect(
        find(run(mix([water(500), gelatin(8)])), 'RULE-GELATIN-ACID'),
        isNull,
      );
    });

    test('Maillard : seulement avec chaleur sèche ≥ 140 °C', () {
      final dough = [
        MixLine(
          index: 0,
          label: 'Pâte',
          ingredientId: 'PATE',
          grams: 500,
          profile: comp(water: 40, sugars: 5, proteins: 10),
          components: const {'SM_GLU_MONO': 2},
        ),
      ];
      expect(find(run(mix(dough)), 'RULE-MAILLARD'), isNull);
      final baked = find(
        run(mix(dough, ['Enfourner 30 min à 220 °C'])),
        'RULE-MAILLARD',
      )!;
      expect(baked.checks.first.met, isTrue);
    });

    test('Maillard : un rôti de viande brunit sans sucre ajouté', () {
      final roast = [
        MixLine(
          index: 0,
          label: 'Gigot',
          ingredientId: 'GIGOT',
          grams: 1500,
          profile: comp(water: 62, proteins: 17, fats: 20),
        ),
      ];
      final m = find(
        run(mix(roast, ['Enfourner 1 h à 200 °C'])),
        'RULE-MAILLARD',
      )!;
      expect(m.checks.first.met, isTrue);
      expect(m.checks[1].detail, contains('musculaires'));
    });

    test('activité de l’eau : denrée périssable signalée en info', () {
      final a = find(run(mix([water(500), sugar(10)])), 'RULE-AW-MICRO')!;
      expect(a.severity, FunctionalSeverity.info);
      expect(a.expectedOutcome, contains('froid'));
    });

    test('compatibilité : evaluate() par identifiants de composants', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_AGAR'],
        allRules: realRules(),
      );
      final agar = find(alerts, 'RULE-AGAR-GEL');
      expect(agar, isNotNull);
      expect(agar!.status, isNot(RuleStatus.conditionsMet));
    });

    test('tri : warnings avant infos', () {
      final alerts = run(
        mix(
          [sugar(100), water(880), pectinHm(12), citric(8)],
          ['Porter à ébullition'],
        ),
      );
      expect(alerts.first.severity, FunctionalSeverity.warning);
    });
  });
}
