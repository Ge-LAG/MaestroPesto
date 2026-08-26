import 'dart:io';

import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_test/flutter_test.dart';

const String ingredientHeader =
    'ingredient_id,canonical_name_fr,canonical_name_en,aliases_fr,aliases_en,'
    'scientific_name,kingdom_or_origin,category_level_1,category_level_2,'
    'category_level_3,source_organism,anatomical_part,ingredient_class,'
    'raw_or_intermediate,processing_state,physical_form,fermented,dried,'
    'smoked,roasted,concentrated,alcoholic,generic_abv_range,'
    'country_or_region_relevance,foodon_id,langual_ids,foodex2_code,'
    'ciqual_ids,usda_fdc_ids,other_external_ids,allergen_tags,'
    'regulatory_notes,source_refs,confidence,review_status,notes';

const String componentHeader =
    'component_id,canonical_name,synonyms,component_group,canonical_unit,'
    'infoods_tagname,ciqual_component_id,usda_nutrient_id,other_ids,'
    'definition,conversion_notes';

const String recordHeader =
    'nutrition_record_id,ingredient_id,ingredient_state_id,canonical_name_fr,'
    'source_id,source_food_id,source_food_name,source_version,source_country,'
    'component_id,component_name,component_group,original_value,original_unit,'
    'normalized_value,normalized_unit,basis,value_qualifier,value_type,'
    'min_value,max_value,sample_count,analytical_method,derivation_method,'
    'data_date,retrieval_date,source_url,confidence,mapping_confidence,notes';

const String aromaHeader =
    'ingredient_id,ingredient_state_id,compound_id,presence_status,'
    'concentration,concentration_unit,concentration_min,concentration_max,'
    'analytical_method,matrix,process_state,source_ref,evidence_type,'
    'confidence';

const String compatibilityHeader =
    'record_id,combination_size,ingredient_ids,ingredient_names,context,'
    'process_context,observed_or_predicted,aroma_similarity,'
    'aroma_complement,aroma_contrast,taste_balance,culinary_support,'
    'sensory_support,dominance_risk,masking_risk,novelty_score,'
    'overall_score,confidence,key_compounds,key_descriptors,'
    'bridge_ingredients,evidence_refs,model_version,explanation';

const String functionalHeader =
    'ingredient_id,ingredient_state_id,temperature_reference_C,water_content,'
    'fat_content,protein_content,starch_content,sugar_content,fiber_content,'
    'pectin_content,alcohol_content,salt_content,mineral_content,ph,'
    'titratable_acidity,water_activity,brix,density_g_per_mL,'
    'particle_size_um,solubility,oil_holding_capacity_g_g,'
    'water_holding_capacity_g_g,emulsifying_capacity,foaming_capacity,'
    'gelation_capability,thickening_capability,hygroscopicity,'
    'thermal_stability,freeze_thaw_stability,oxidation_sensitivity,'
    'source_refs,evidence_type,confidence,validity_conditions';

const String ruleHeader =
    'rule_id,rule_family,reactant_or_component_ids,ingredient_constraints,'
    'composition_constraints,process_constraints,ph_min,ph_max,'
    'temperature_min,temperature_max,time_min,time_max,water_activity_min,'
    'water_activity_max,shear_constraints,order_constraints,predicted_effect,'
    'effect_direction,effect_magnitude,output_property,equation_or_logic,'
    'source_refs,evidence_type,confidence,extrapolation_allowed,notes';

const String operationHeader =
    'op_id,family,name,T_min_C,T_max_C,duration_min,pressure,'
    'shear_rate_s-1,mixing_rpm,energy_input,cooling_rate,heating_rate,'
    'target_ph,target_aw,target_brix,particle_size_target_um,'
    'oxygen_exposure,atmosphere,order_index,addition_mode,rest_time,notes';

String csvRow(String header, Map<String, String> values) {
  return header.split(',').map((column) => values[column] ?? '').join(',');
}

Future<Directory> writeCorpus() async {
  final root = await Directory.systemTemp.createTemp(
    'maestropesto_csv_import_test',
  );
  Future<File> write(String relPath, List<String> lines) async {
    final file = File(p.join(root.path, relPath));
    await file.parent.create(recursive: true);
    return file.writeAsString('${lines.join('\n')}\n');
  }

  await write('phase1-referentiel/ingredient_registry_v1.csv', [
    ingredientHeader,
    csvRow(ingredientHeader, {
      'ingredient_id': 'ING-T-A-000001',
      'canonical_name_fr': 'Synthétique A',
      'canonical_name_en': 'Synthetic A',
      'aliases_fr': 'a|aa',
      'category_level_1': 'test',
      'raw_or_intermediate': 'raw',
      'source_refs': 'SYNTH',
      'confidence': '0.9',
      'review_status': 'draft',
    }),
    csvRow(ingredientHeader, {
      'ingredient_id': 'ING-T-B-000001',
      'canonical_name_fr': 'Synthétique B',
      'category_level_1': 'test',
      'source_refs': 'SYNTH',
      'confidence': '0.9',
      'review_status': 'draft',
    }),
  ]);
  await write('phase2-nutrition/component_dictionary.csv', [
    componentHeader,
    csvRow(componentHeader, {
      'component_id': 'TESTCOMP',
      'canonical_name': 'Composant test',
      'component_group': 'test',
      'canonical_unit': 'g',
      'ciqual_component_id': '1',
      'usda_nutrient_id': '2',
      'definition': 'Définition test.',
    }),
  ]);
  await write('phase2-nutrition/nutrition_database.csv', [
    recordHeader,
    csvRow(recordHeader, {
      'nutrition_record_id': 'NUTR-T-000001',
      'ingredient_id': 'ING-T-A-000001',
      'ingredient_state_id': 'raw',
      'source_id': 'SYNTH',
      'source_food_id': '1',
      'source_food_name': '"Synthetic, A"',
      'source_version': 'v1',
      'source_country': 'Test',
      'component_id': 'TESTCOMP',
      'component_name': 'Composant test',
      'component_group': 'test',
      'original_value': '1.5',
      'original_unit': 'g',
      'normalized_value': '150',
      'normalized_unit': 'mg',
      'basis': 'per_100g_edible_part',
      'value_qualifier': 'EXACT',
      'value_type': 'measured',
      'sample_count': '3',
      'retrieval_date': '2026-01-01',
      'confidence': '1.0',
      'mapping_confidence': '1.0',
    }),
    csvRow(recordHeader, {
      'nutrition_record_id': 'NUTR-T-000002',
      'ingredient_id': 'ING-T-B-000001',
      'ingredient_state_id': 'raw',
      'source_id': 'SYNTH',
      'source_food_id': '2',
      'source_food_name': 'Synthetic B',
      'source_version': 'v1',
      'source_country': 'Test',
      'component_id': 'TESTCOMP',
      'component_name': 'Composant test',
      'component_group': 'test',
      'original_value': '2',
      'original_unit': 'mg',
      'normalized_value': '2',
      'normalized_unit': 'mg',
      'basis': 'per_100g_edible_part',
      'value_qualifier': 'EXACT',
      'value_type': 'measured',
      'retrieval_date': '2026-01-01',
      'confidence': '1.0',
      'mapping_confidence': '1.0',
    }),
  ]);
  await write('phase3-flavour/ingredient_aroma_compounds.csv', [
    aromaHeader,
    csvRow(aromaHeader, {
      'ingredient_id': 'ING-T-A-000001',
      'ingredient_state_id': 'raw',
      'compound_id': 'TESTC',
      'presence_status': 'REPORTED',
      'analytical_method': 'GC-MS',
      'matrix': 'test',
      'process_state': 'raw',
      'source_ref': 'SYNTH',
      'evidence_type': 'measured',
      'confidence': '0.5',
    }),
  ]);
  await write('phase3-flavour/flavor_compatibility.csv', [
    compatibilityHeader,
    csvRow(compatibilityHeader, {
      'record_id': 'COMP-T-000001',
      'combination_size': '2',
      'ingredient_ids': 'ING-T-A-000001|ING-T-B-000001',
      'context': 'all',
      'process_context': 'raw',
      'observed_or_predicted': 'observed',
      'aroma_similarity': '0.1',
      'aroma_complement': '0.2',
      'aroma_contrast': '0.3',
      'taste_balance': '0.4',
      'culinary_support': '0.5',
      'sensory_support': '0.6',
      'dominance_risk': '0.7',
      'masking_risk': '0.8',
      'novelty_score': '0.9',
      'overall_score': '1.0',
      'confidence': '0.95',
      'key_compounds': 'TESTC|TESTD',
      'key_descriptors': 'a|b',
      'bridge_ingredients': 'c|d',
      'evidence_refs': 'SYNTH|TEST',
      'model_version': 'v1',
      'explanation': 'note test',
    }),
  ]);
  await write('phase4-functional/functional_ingredients.csv', [
    functionalHeader,
    csvRow(functionalHeader, {
      'ingredient_id': 'ING-T-A-000001',
      'ingredient_state_id': 'raw',
      'temperature_reference_C': '20',
      'water_content': '80',
      'fat_content': '1',
      'protein_content': '2',
      'starch_content': '3',
      'sugar_content': '4',
      'fiber_content': '5',
      'mineral_content': '6.5',
      'solubility': 'insoluble',
      'source_refs': 'SYNTH',
      'evidence_type': 'measured',
      'confidence': '0.8',
      'validity_conditions': 'ambient',
    }),
  ]);
  await write('phase4-functional/interaction_rules.csv', [
    ruleHeader,
    csvRow(ruleHeader, {
      'rule_id': 'RULE-T-000001',
      'rule_family': 'test',
      'reactant_or_component_ids': 'X|Y',
      'ph_min': '3',
      'ph_max': '4',
      'temperature_min': '5',
      'temperature_max': '6',
      'time_min': '7',
      'time_max': '8',
      'predicted_effect': 'effet',
      'effect_direction': 'direction',
      'effect_magnitude': 'fort',
      'output_property': 'propriété',
      'equation_or_logic': 'IF x THEN y',
      'source_refs': 'SYNTH',
      'evidence_type': 'expert_rule_with_literature',
      'confidence': '0.9',
      'extrapolation_allowed': 'true',
    }),
  ]);
  await write('phase4-functional/process_operations.csv', [
    operationHeader,
    csvRow(operationHeader, {
      'op_id': 'PROC-T-000001',
      'family': 'thermal',
      'name': 'Test',
      'T_min_C': '10',
      'T_max_C': '20',
      'duration_min': '5',
      'pressure': 'atmospheric',
      'atmosphere': 'ambient',
    }),
  ]);
  return root;
}

void main() {
  late AppDatabase db;
  late Directory root;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    root = await writeCorpus();
  });

  tearDown(() async {
    await db.close();
    await root.delete(recursive: true);
  });

  Future<int> count(String table) => countTableRows(db, table);

  test('imports the four phases in order and fills every table', () async {
    final service = CsvImportService(db, databaseMetierRoot: root.path);
    final phases = <String>[];
    final report = await service.importAll(
      onPhaseProgress: (phase, rowsDone) {
        if (!phases.contains(phase)) phases.add(phase);
      },
    );

    expect(phases, ['phase1', 'phase2', 'phase3', 'phase4', 'enrichment']);
    expect(report.rowsImported['phase1'], 2);
    expect(report.rowsImported['phase2'], 3);
    expect(report.rowsImported['phase3'], 2);
    expect(report.rowsImported['phase4'], 3);
    // L'enrichissement Ciqual est une phase optionnelle : sans CSV à
    // côté du root (dossier de test), il est skippé sans erreur.
    expect(report.rowsImported['enrichment'], 0);
    expect(report.skipped['enrichment'], isTrue);
    expect(
      report.skipped.entries
          .where((e) => e.key != 'enrichment')
          .map((e) => e.value),
      everyElement(isFalse),
    );

    expect(await count('ingredients'), 2);
    expect(await count('nutrition_components'), 1);
    expect(await count('nutrition_records'), 2);
    expect(await count('ingredient_aroma_compounds'), 1);
    expect(await count('flavor_compatibility'), 1);
    expect(await count('functional_ingredients'), 1);
    expect(await count('interaction_rules'), 1);
    expect(await count('process_operations'), 1);

    final storedIngredient = await (db.select(
      db.ingredients,
    )..where((t) => t.ingredientId.equals('ING-T-A-000001'))).getSingle();
    expect(storedIngredient.canonicalNameFr, 'Synthétique A');
    expect(storedIngredient.aliasesFr, 'a|aa');

    final storedRecord = await (db.select(
      db.nutritionRecords,
    )..where((t) => t.nutritionRecordId.equals('NUTR-T-000001'))).getSingle();
    expect(storedRecord.sourceFoodName, 'Synthetic, A');
    expect(storedRecord.originalValue, 1.5);
    expect(storedRecord.sampleCount, 3);

    final states = await ImportStateStore(db)
        .currentHash('phase1/ingredient_registry_v1');
    expect(states, isNotNull);
  });

  test(
    'is idempotent: a second run skips every phase and inserts nothing',
    () async {
      final service = CsvImportService(db, databaseMetierRoot: root.path);
      await service.importAll();
      final report = await service.importAll();

      expect(report.rowsImported.values, everyElement(0));
      expect(report.skipped['phase1'], isTrue);
      expect(report.skipped['phase2'], isTrue);
      expect(report.skipped['phase3'], isTrue);
      expect(report.skipped['phase4'], isTrue);
      expect(await count('ingredients'), 2);
      expect(await count('flavor_compatibility'), 1);
    },
  );

  test('rolling back: a failing phase undoes the whole import', () async {
    await File(p.join(root.path, 'phase3-flavour', 'flavor_compatibility.csv'))
        .delete();
    final service = CsvImportService(db, databaseMetierRoot: root.path);

    await expectLater(service.importAll(), throwsA(anything));
    expect(await count('ingredients'), 0);
    expect(await count('nutrition_components'), 0);
    expect(await count('nutrition_records'), 0);
  });

  test('imports the real database-metier corpus end to end', () async {
    final service = CsvImportService(
      db,
      databaseMetierRoot: p.absolute('database-metier'),
    );
    final report = await service.importAll();

    expect(report.rowsImported['phase1'], 603);
    expect(report.rowsImported['phase2'], 830);
    expect(report.rowsImported['phase3'], 4649);
    expect(report.rowsImported['phase4'], 72);

    expect(await count('ingredients'), 603);
    expect(await count('nutrition_components'), 79);
    expect(await count('nutrition_records'), 751);
    expect(await count('ingredient_aroma_compounds'), 56);
    expect(await count('flavor_compatibility'), 4593);
    expect(await count('functional_ingredients'), 18);
    expect(await count('interaction_rules'), 16);
    expect(await count('process_operations'), 38);

    final rerun = await service.importAll();
    expect(rerun.rowsImported.values, everyElement(0));
    expect(rerun.skipped.values, everyElement(isTrue));
    expect(await count('ingredients'), 603);
  }, timeout: const Timeout(Duration(minutes: 2)));
}
