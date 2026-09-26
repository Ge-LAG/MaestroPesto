import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:maestropesto/features/functional/data/functional_models.dart';
import 'package:flutter_test/flutter_test.dart';

const String ingredientsHeader =
    'ingredient_id,ingredient_state_id,temperature_reference_C,water_content,'
    'fat_content,protein_content,starch_content,sugar_content,fiber_content,'
    'pectin_content,alcohol_content,salt_content,mineral_content,ph,'
    'titratable_acidity,water_activity,brix,density_g_per_mL,'
    'particle_size_um,solubility,oil_holding_capacity_g_g,'
    'water_holding_capacity_g_g,emulsifying_capacity,foaming_capacity,'
    'gelation_capability,thickening_capability,hygroscopicity,'
    'thermal_stability,freeze_thaw_stability,oxidation_sensitivity,'
    'source_refs,evidence_type,confidence,validity_conditions';

const String butterRaw =
    'ING-DAIRY-BEURREDOUX-000001,churned,20,15.7,81.5,0.7,0,0.6,0,,,0.05,,,'
    ',0.95,,0.911,,insoluble,0.2,,medium_fat,low,no,no,low,'
    'phase_inversion_frying,good,medium,LIT:O\'Brien|LIT:McClements,measured,'
    '0.90,ambient_to_refrigerated';

const String rulesHeader =
    'rule_id,rule_family,reactant_or_component_ids,ingredient_constraints,'
    'composition_constraints,process_constraints,ph_min,ph_max,'
    'temperature_min,temperature_max,time_min,time_max,water_activity_min,'
    'water_activity_max,shear_constraints,order_constraints,predicted_effect,'
    'effect_direction,effect_magnitude,output_property,equation_or_logic,'
    'source_refs,evidence_type,confidence,extrapolation_allowed,notes';

const String pectinHmRaw =
    'RULE-PEC-HM-001,gelling,POLY_PEC_HM|SM_SUCROSE,pectine_HM_presence,'
    'sugar_60-65pct_required,T_below_boiling,2.5,4.0,60,105,5,30,0.85,1.0,'
    'low_avoid_cisaillement,sugar_dispersed_first_then_pectine,'
    'gel_formation,increase_gel_strength,high,gel_firmness_strength,'
    'F_gel = K * [sugar]^n * [H+] * (1 - [Ca2+]/K_Ca),'
    'LIT:Sriamornsak|LIT:Oakenfull,expert_rule_with_literature,0.92,false,'
    'Pectine HM gélifie uniquement si sucre > 60% ET pH < 4.0.';

const String operationsHeader =
    'op_id,family,name,T_min_C,T_max_C,duration_min,pressure,'
    'shear_rate_s-1,mixing_rpm,energy_input,cooling_rate,heating_rate,'
    'target_ph,target_aw,target_brix,particle_size_target_um,'
    'oxygen_exposure,atmosphere,order_index,addition_mode,rest_time,notes';

const String heatRaw =
    'PROC_CHAUFFER,thermal,Chauffer,30,250,1,atmospheric,,,,,,,,,,,ambient,,,'
    ',Élévation contrôlée de la température sans atteinte d\'un seuil.';

List<String> ih = parseCsvHeader(ingredientsHeader);
List<String> rh = parseCsvHeader(rulesHeader);
List<String> oh = parseCsvHeader(operationsHeader);

void main() {
  group('FunctionalIngredientCsv.fromCsvRow', () {
    test('parses a real phase 4 profile row (beurre doux)', () {
      final row = FunctionalIngredientCsv.fromCsvRow(
        parseCsvLine(butterRaw),
        ih,
      );
      expect(row.ingredientId, 'ING-DAIRY-BEURREDOUX-000001');
      expect(row.ingredientStateId, 'churned');
      expect(row.temperatureReferenceC, 20);
      expect(row.waterContent, 15.7);
      expect(row.fatContent, 81.5);
      expect(row.proteinContent, 0.7);
      expect(row.starchContent, 0);
      expect(row.saltContent, 0.05);
      expect(row.waterActivity, 0.95);
      expect(row.densityGPerMl, 0.911);
      expect(row.solubility, 'insoluble');
      expect(row.oilHoldingCapacityGG, 0.2);
      expect(row.emulsifyingCapacity, 'medium_fat');
      expect(row.foamingCapacity, 'low');
      expect(row.thermalStability, 'phase_inversion_frying');
      expect(row.freezeThawStability, 'good');
      expect(row.oxidationSensitivity, 'medium');
      expect(row.sourceRefs, ["LIT:O'Brien", 'LIT:McClements']);
      expect(row.evidenceType, 'measured');
      expect(row.confidence, 0.90);
      expect(row.validityConditions, 'ambient_to_refrigerated');
    });

    test('keeps empty analytical cells as null (pectin, brix...)', () {
      final row = FunctionalIngredientCsv.fromCsvRow(
        parseCsvLine(butterRaw),
        ih,
      );
      expect(row.pectinContent, isNull);
      expect(row.alcoholContent, isNull);
      expect(row.mineralContent, isNull);
      expect(row.ph, isNull);
      expect(row.titratableAcidity, isNull);
      expect(row.brix, isNull);
      expect(row.particleSizeUm, isNull);
      expect(row.waterHoldingCapacityGG, isNull);
    });

    test('is deterministic and companion maps every field', () {
      final a = FunctionalIngredientCsv.fromCsvRow(parseCsvLine(butterRaw), ih);
      final b = FunctionalIngredientCsv.fromCsvRow(parseCsvLine(butterRaw), ih);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final companion = a.toCompanion();
      expect(companion.ingredientId.value, 'ING-DAIRY-BEURREDOUX-000001');
      expect(companion.ingredientStateId.value, 'churned');
      expect(companion.sourceRefs.value, "LIT:O'Brien|LIT:McClements");
      expect(companion.ph.present, isTrue);
      expect(companion.ph.value, isNull);
    });
  });

  group('InteractionRuleCsv.fromCsvRow', () {
    test('parses a real interaction rule (pectine HM)', () {
      final row = InteractionRuleCsv.fromCsvRow(parseCsvLine(pectinHmRaw), rh);
      expect(row.ruleId, 'RULE-PEC-HM-001');
      expect(row.ruleFamily, 'gelling');
      expect(row.reactantOrComponentIds, ['POLY_PEC_HM', 'SM_SUCROSE']);
      expect(row.phMin, 2.5);
      expect(row.phMax, 4.0);
      expect(row.temperatureMin, 60);
      expect(row.temperatureMax, 105);
      expect(row.timeMin, 5);
      expect(row.timeMax, 30);
      expect(row.waterActivityMin, 0.85);
      expect(row.waterActivityMax, 1.0);
      expect(row.predictedEffect, 'gel_formation');
      expect(row.effectMagnitude, 'high');
      expect(
        row.equationOrLogic,
        'F_gel = K * [sugar]^n * [H+] * (1 - [Ca2+]/K_Ca)',
      );
      expect(row.sourceRefs, ['LIT:Sriamornsak', 'LIT:Oakenfull']);
      expect(row.extrapolationAllowed, isFalse);
      expect(row.notes, contains('pH < 4.0'));
    });

    test('is deterministic: parsing twice yields equal objects', () {
      final a = InteractionRuleCsv.fromCsvRow(parseCsvLine(pectinHmRaw), rh);
      final b = InteractionRuleCsv.fromCsvRow(parseCsvLine(pectinHmRaw), rh);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final companion = a.toCompanion();
      expect(companion.extrapolationAllowed.value, isFalse);
      expect(companion.reactantOrComponentIds.value, 'POLY_PEC_HM|SM_SUCROSE');
    });
  });

  group('ProcessOperationCsv.fromCsvRow', () {
    test('parses a real process operation (chauffer)', () {
      final row = ProcessOperationCsv.fromCsvRow(parseCsvLine(heatRaw), oh);
      expect(row.opId, 'PROC_CHAUFFER');
      expect(row.family, 'thermal');
      expect(row.name, 'Chauffer');
      expect(row.tMinC, 30);
      expect(row.tMaxC, 250);
      expect(row.durationMin, 1);
      expect(row.pressure, 'atmospheric');
      expect(row.atmosphere, 'ambient');
      expect(
        row.notes,
        "Élévation contrôlée de la température sans atteinte d'un seuil.",
      );
    });

    test('keeps empty optional cells as null (shear, targets...)', () {
      final row = ProcessOperationCsv.fromCsvRow(parseCsvLine(heatRaw), oh);
      expect(row.shearRateS1, isNull);
      expect(row.mixingRpm, isNull);
      expect(row.energyInput, isNull);
      expect(row.targetPh, isNull);
      expect(row.targetAw, isNull);
      expect(row.targetBrix, isNull);
      expect(row.particleSizeTargetUm, isNull);
      expect(row.orderIndex, isNull);
      expect(row.additionMode, isNull);
      expect(row.restTime, isNull);
    });

    test('is deterministic: parsing twice yields equal objects', () {
      final a = ProcessOperationCsv.fromCsvRow(parseCsvLine(heatRaw), oh);
      final b = ProcessOperationCsv.fromCsvRow(parseCsvLine(heatRaw), oh);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
