import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:maestropesto/features/nutrition/data/nutrition_models.dart';
import 'package:flutter_test/flutter_test.dart';

const String recordsHeader =
    'nutrition_record_id,ingredient_id,ingredient_state_id,canonical_name_fr,'
    'source_id,source_food_id,source_food_name,source_version,source_country,'
    'component_id,component_name,component_group,original_value,original_unit,'
    'normalized_value,normalized_unit,basis,value_qualifier,value_type,'
    'min_value,max_value,sample_count,analytical_method,derivation_method,'
    'data_date,retrieval_date,source_url,confidence,mapping_confidence,notes';

const String kcalRaw =
    'NUTR-0000001,ING-PLANT-POMME-000001,raw,Pomme crue,CIQUAL,13000,'
    '"Pomme, crue, avec peau",2024,France,ENERCKCAL,Énergie (kcal),energy,52,'
    'kcal,52,kcal,per_100g_edible_part,EXACT,measured,,,,,,,2026-08-22,'
    'https://ciqual.anses.fr/,0.95,0.90,';

const String componentsHeader =
    'component_id,canonical_name,synonyms,component_group,canonical_unit,'
    'infoods_tagname,ciqual_component_id,usda_nutrient_id,other_ids,'
    'definition,conversion_notes';

const String energyKjRaw =
    'ENERC,Énergie (kJ),,energy,kJ,ENERCJ,10001,1008,,Energie calculée par '
    'facteurs (Atwater général).,kJ = kcal × 4.184';

List<String> rh = parseCsvHeader(recordsHeader);
List<String> ch = parseCsvHeader(componentsHeader);

void main() {
  group('NutritionRecordCsv.fromCsvRow', () {
    test('parses a real phase 2 row (kcal record)', () {
      final row = NutritionRecordCsv.fromCsvRow(parseCsvLine(kcalRaw), rh);
      expect(row.nutritionRecordId, 'NUTR-0000001');
      expect(row.ingredientId, 'ING-PLANT-POMME-000001');
      expect(row.ingredientStateId, 'raw');
      expect(row.sourceId, 'CIQUAL');
      expect(row.sourceFoodId, '13000');
      expect(row.sourceFoodName, 'Pomme, crue, avec peau');
      expect(row.sourceCountry, 'France');
      expect(row.componentId, 'ENERCKCAL');
      expect(row.componentName, 'Énergie (kcal)');
      expect(row.originalValue, 52);
      expect(row.originalUnit, 'kcal');
      expect(row.normalizedValue, 52);
      expect(row.basis, 'per_100g_edible_part');
      expect(row.valueQualifier, 'EXACT');
      expect(row.valueType, 'measured');
      expect(row.retrievalDate, '2026-08-22');
      expect(row.sourceUrl, 'https://ciqual.anses.fr/');
      expect(row.confidence, 0.95);
      expect(row.mappingConfidence, 0.90);
    });

    test('keeps empty numeric and text cells as null', () {
      final row = NutritionRecordCsv.fromCsvRow(parseCsvLine(kcalRaw), rh);
      expect(row.minValue, isNull);
      expect(row.maxValue, isNull);
      expect(row.sampleCount, isNull);
      expect(row.analyticalMethod, isNull);
      expect(row.derivationMethod, isNull);
      expect(row.dataDate, isNull);
      expect(row.notes, isNull);
    });

    test('is deterministic and companion maps every field', () {
      final a = NutritionRecordCsv.fromCsvRow(parseCsvLine(kcalRaw), rh);
      final b = NutritionRecordCsv.fromCsvRow(parseCsvLine(kcalRaw), rh);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final companion = a.toCompanion();
      expect(companion.nutritionRecordId.value, 'NUTR-0000001');
      expect(companion.ingredientId.value, 'ING-PLANT-POMME-000001');
      expect(companion.originalValue.value, 52);
      expect(companion.minValue.present, isTrue);
      expect(companion.minValue.value, isNull);
      expect(companion.sampleCount.present, isTrue);
      expect(companion.sampleCount.value, isNull);
    });

    test('ignores the CSV-only canonical_name_fr column', () {
      final row = NutritionRecordCsv.fromCsvRow(parseCsvLine(kcalRaw), rh);
      expect(row.toCompanion().ingredientId.value, 'ING-PLANT-POMME-000001');
    });
  });

  group('NutritionComponentCsv.fromCsvRow', () {
    test('parses a real component dictionary row (ENERC)', () {
      final row = NutritionComponentCsv.fromCsvRow(
        parseCsvLine(energyKjRaw),
        ch,
      );
      expect(row.componentId, 'ENERC');
      expect(row.canonicalName, 'Énergie (kJ)');
      expect(row.synonyms, isNull);
      expect(row.componentGroup, 'energy');
      expect(row.canonicalUnit, 'kJ');
      expect(row.infoodsTagname, 'ENERCJ');
      expect(row.ciqualComponentId, '10001');
      expect(row.usdaNutrientId, '1008');
      expect(row.otherIds, isNull);
      expect(
        row.definition,
        'Energie calculée par facteurs (Atwater '
        'général).',
      );
      expect(row.conversionNotes, 'kJ = kcal × 4.184');
    });

    test('is deterministic and companion maps every field', () {
      final a = NutritionComponentCsv.fromCsvRow(parseCsvLine(energyKjRaw), ch);
      final b = NutritionComponentCsv.fromCsvRow(parseCsvLine(energyKjRaw), ch);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final companion = a.toCompanion();
      expect(companion.componentId.value, 'ENERC');
      expect(companion.canonicalName.value, 'Énergie (kJ)');
      expect(companion.synonyms.present, isTrue);
      expect(companion.synonyms.value, isNull);
      expect(companion.conversionNotes.value, 'kJ = kcal × 4.184');
    });
  });
}
