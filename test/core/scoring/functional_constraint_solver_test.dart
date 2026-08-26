// Phase 09 Lot H — H1 : tests du FunctionalConstraintSolver (§8.1).
//
// Les fixtures reprennent les 16 règles réelles de
// `database-metier/phase4-functional/interaction_rules.csv`
// (lecture seule, calibration v1).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/scoring/functional_constraint_solver.dart';

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

void main() {
  group('FunctionalConstraintSolver — vraies règles Phase 4', () {
    test('16 règles dans le jeu de fixtures', () {
      expect(realRules().length, 16);
    });

    test('aucune alerte sans ingrédient correspondant', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['ING-PLANT-TOMATE-000001'],
        allRules: realRules(),
      );
      expect(alerts, isEmpty);
    });

    test('RULE-PEC-HM-001 déclenchée par POLY_PEC_HM (1er réactant)', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_PEC_HM'],
        allRules: realRules(),
      );
      expect(alerts.map((a) => a.alertId), contains('RULE-PEC-HM-001'));
    });

    test('RULE-PEC-HM-001 déclenchée par SM_SUCROSE (2e réactant, pipe-separated)', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['SM_SUCROSE'],
        allRules: realRules(),
      );
      final ids = alerts.map((a) => a.alertId);
      expect(ids, contains('RULE-PEC-HM-001'));
      // SM_SUCROSE déclenche aussi RULE-CARAMEL.
      expect(ids, contains('RULE-CARAMEL'));
    });

    test('SM_SUCROSE ne déclenche pas RULE-PEC-LM-001', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['SM_SUCROSE'],
        allRules: realRules(),
      );
      expect(alerts.map((a) => a.alertId), isNot(contains('RULE-PEC-LM-001')));
    });

    test('PROT_GEL déclenche les 2 règles gélatine', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['PROT_GEL'],
        allRules: realRules(),
      );
      final ids = alerts.map((a) => a.alertId).toList();
      expect(ids, containsAll(['RULE-GEL-GELATINE', 'RULE-GELATIN-ACID']));
    });

    test('PROT_CASEINE déclenche Maillard, sel-caséine et coagulation pH', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['PROT_CASEINE'],
        allRules: realRules(),
      );
      final ids = alerts.map((a) => a.alertId).toList();
      expect(
        ids,
        containsAll([
          'RULE-MAILLARD',
          'RULE-SALT-CASEIN',
          'RULE-PH-COAG-CASEIN',
        ]),
      );
    });

    test('PROT_OVALB déclenche mayo et coagulation œuf', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['PROT_OVALB'],
        allRules: realRules(),
      );
      final ids = alerts.map((a) => a.alertId).toList();
      expect(ids, containsAll(['RULE-MAYO-001', 'RULE-EGG-COAG']));
    });

    test('les règles sans reactant_or_component_ids ne sont jamais déclenchées', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const [
          'POLY_PEC_HM',
          'SM_SUCROSE',
          'PROT_GEL',
          'PROT_CASEINE',
          'PROT_OVALB',
          'POLY_AMIDON',
          'PROT_GLU',
          'SM_SALT',
          'LIP_PHOSPH',
        ],
        allRules: realRules(),
      );
      // RULE-AW-MICRO a reactant_or_component_ids vide → absente.
      expect(alerts.map((a) => a.alertId), isNot(contains('RULE-AW-MICRO')));
    });

    test('confidence dégradée × 0.5 (dp-107)', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_PEC_HM'],
        allRules: realRules(),
      );
      final alert =
          alerts.singleWhere((a) => a.alertId == 'RULE-PEC-HM-001');
      expect(alert.confidence, closeTo(0.46, 1e-9)); // 0.92 × 0.5
    });

    test('confidence null → 1.0 × 0.5 = 0.5', () {
      const rule = InteractionRule(
        ruleId: 'RULE-X',
        reactantOrComponentIds: 'ING-X',
      );
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['ING-X'],
        allRules: const [rule],
      );
      expect(alerts.single.confidence, 0.5);
    });

    test('sévérité : famille safety → danger', () {
      const rule = InteractionRule(
        ruleId: 'RULE-SAFETY-X',
        ruleFamily: 'safety',
        reactantOrComponentIds: 'ING-X',
      );
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['ING-X'],
        allRules: const [rule],
      );
      expect(alerts.single.severity, FunctionalSeverity.danger);
    });

    test('sévérité : effect_direction decrease* → warning', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['PROT_GEL'],
        allRules: realRules(),
      );
      final acid =
          alerts.singleWhere((a) => a.alertId == 'RULE-GELATIN-ACID');
      expect(acid.severity, FunctionalSeverity.warning);
      final gel =
          alerts.singleWhere((a) => a.alertId == 'RULE-GEL-GELATINE');
      expect(gel.severity, FunctionalSeverity.info);
    });

    test('tri par sévérité décroissante (danger > warning > info)', () {
      const rules = [
        InteractionRule(
          ruleId: 'R-INFO',
          ruleFamily: 'gelling',
          reactantOrComponentIds: 'ING-A',
          effectDirection: 'increase',
        ),
        InteractionRule(
          ruleId: 'R-DANGER',
          ruleFamily: 'safety',
          reactantOrComponentIds: 'ING-A',
        ),
        InteractionRule(
          ruleId: 'R-WARNING',
          ruleFamily: 'gelling',
          reactantOrComponentIds: 'ING-A',
          effectDirection: 'decrease_gel_strength',
        ),
      ];
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['ING-A'],
        allRules: rules,
      );
      expect(
        alerts.map((a) => a.alertId).toList(),
        ['R-DANGER', 'R-WARNING', 'R-INFO'],
      );
    });

    test('titre = notes quand présentes, sinon rule_id', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_PEC_HM'],
        allRules: realRules(),
      );
      final alert =
          alerts.singleWhere((a) => a.alertId == 'RULE-PEC-HM-001');
      expect(
        alert.title,
        'Pectine HM gélifie uniquement si sucre > 60% ET pH < 4.0.',
      );
    });

    test('conditions incluent contraintes brutes et bornes pH/T', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_PEC_HM'],
        allRules: realRules(),
      );
      final alert =
          alerts.singleWhere((a) => a.alertId == 'RULE-PEC-HM-001');
      expect(alert.conditions, contains('pectine_HM_presence'));
      expect(alert.conditions, contains('sugar_60-65pct_required'));
      expect(alert.conditions, contains('pH 2.5–4'));
      expect(alert.conditions, contains('T 60–105 °C'));
    });

    test('recette vide → aucune alerte', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const [],
        allRules: realRules(),
      );
      expect(alerts, isEmpty);
    });

    test('liste de règles vide → aucune alerte', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['POLY_PEC_HM'],
        allRules: const [],
      );
      expect(alerts, isEmpty);
    });

    test('espaces autour des ids pipe-separated tolérés', () {
      const rule = InteractionRule(
        ruleId: 'RULE-SPACED',
        reactantOrComponentIds: ' ING-A | ING-B ',
      );
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['ING-B'],
        allRules: const [rule],
      );
      expect(alerts.single.alertId, 'RULE-SPACED');
    });

    test('doublons dans la recette ne dupliquent pas les alertes', () {
      final alerts = FunctionalConstraintSolver.evaluate(
        recipeIngredientIds: const ['PROT_GEL', 'PROT_GEL'],
        allRules: realRules(),
      );
      final ids = alerts.map((a) => a.alertId).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
