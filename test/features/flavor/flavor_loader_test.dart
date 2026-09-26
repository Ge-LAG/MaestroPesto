import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:maestropesto/features/flavor/data/flavor_models.dart';
import 'package:flutter_test/flutter_test.dart';

const String compatibilityHeader =
    'record_id,combination_size,ingredient_ids,ingredient_names,context,'
    'process_context,observed_or_predicted,aroma_similarity,'
    'aroma_complement,aroma_contrast,taste_balance,culinary_support,'
    'sensory_support,dominance_risk,masking_risk,novelty_score,'
    'overall_score,confidence,key_compounds,key_descriptors,'
    'bridge_ingredients,evidence_refs,model_version,explanation';

const String compatibilityRaw =
    'COMP-000001,2,ING-ANIMAL-AGNEAUVIANDE-000001|ING-PLANT-ABRICOT-000001,,'
    'all,raw_or_cooked,predicted,0.000,0.000,1.000,0.600,,,0.250,0.000,,'
    '0.070,0.700,,,,DESCRIPTOR|AROMA_COMPOUND,1.0.0,Jaccard composés=0.00; '
    'Jaccard descripteurs=0.00; équilibre gustatif=0.60; risque '
    'dominance=0.25; masquage=0.00';

const String aromaHeader =
    'ingredient_id,ingredient_state_id,compound_id,presence_status,'
    'concentration,concentration_unit,concentration_min,concentration_max,'
    'analytical_method,matrix,process_state,source_ref,evidence_type,'
    'confidence';

const String aromaReportedRaw =
    'ING-PLANT-POMME-000001,raw,ETHBUTY,REPORTED,,,,,'
    'GC-MS/GC-O (FlavorDB2 aggregated),fresh/raw,raw,PUBCHEM,measured,0.75';

const String aromaQuantifiedRaw =
    'ING-PLANT-FRAISE-000001,raw,ETHBUTY,QUANTIFIED,0.8,mg/100g,0.4,1.5,'
    'GC-MS/GC-O (FlavorDB2 aggregated),fresh/raw,raw,'
    'FLAVORDB2|PUBCHEM,analytical_database,0.90';

List<String> fh = parseCsvHeader(compatibilityHeader);
List<String> ah = parseCsvHeader(aromaHeader);

void main() {
  group('FlavorCompatibilityCsv.fromCsvRow', () {
    test('parses a real phase 3 pairing row (COMP-000001)', () {
      final row = FlavorCompatibilityCsv.fromCsvRow(
        parseCsvLine(compatibilityRaw),
        fh,
      );
      expect(row.recordId, 'COMP-000001');
      expect(row.combinationSize, 2);
      expect(row.ingredientIds, [
        'ING-ANIMAL-AGNEAUVIANDE-000001',
        'ING-PLANT-ABRICOT-000001',
      ]);
      expect(row.context, 'all');
      expect(row.processContext, 'raw_or_cooked');
      expect(row.observedOrPredicted, 'predicted');
      expect(row.aromaSimilarity, 0.0);
      expect(row.aromaComplement, 0.0);
      expect(row.aromaContrast, 1.0);
      expect(row.tasteBalance, 0.6);
      expect(row.dominanceRisk, 0.25);
      expect(row.maskingRisk, 0.0);
      expect(row.noveltyScore, isNull);
      expect(row.overallScore, 0.07);
      expect(row.confidence, 0.7);
      expect(row.evidenceRefs, ['DESCRIPTOR', 'AROMA_COMPOUND']);
      expect(row.modelVersion, '1.0.0');
      expect(row.explanation, contains('équilibre gustatif=0.60'));
    });

    test('keeps empty score and list cells as null', () {
      final row = FlavorCompatibilityCsv.fromCsvRow(
        parseCsvLine(compatibilityRaw),
        fh,
      );
      expect(row.ingredientNames, isNull);
      expect(row.culinarySupport, isNull);
      expect(row.sensorySupport, isNull);
      expect(row.noveltyScore, isNull);
      expect(row.keyCompounds, isNull);
      expect(row.keyDescriptors, isNull);
      expect(row.bridgeIngredients, isNull);
    });

    test('round-trips pipe-separated fields through the companion', () {
      final companion = FlavorCompatibilityCsv.fromCsvRow(
        parseCsvLine(compatibilityRaw),
        fh,
      ).toCompanion();
      expect(
        companion.ingredientIds.value,
        'ING-ANIMAL-AGNEAUVIANDE-000001|ING-PLANT-ABRICOT-000001',
      );
      expect(companion.evidenceRefs.value, 'DESCRIPTOR|AROMA_COMPOUND');
      expect(companion.combinationSize.value, 2);
      expect(companion.culinarySupport.present, isTrue);
      expect(companion.culinarySupport.value, isNull);
    });

    test('is deterministic: parsing twice yields equal objects', () {
      final a = FlavorCompatibilityCsv.fromCsvRow(
        parseCsvLine(compatibilityRaw),
        fh,
      );
      final b = FlavorCompatibilityCsv.fromCsvRow(
        parseCsvLine(compatibilityRaw),
        fh,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });

  group('IngredientAromaCompoundCsv.fromCsvRow', () {
    test('parses a real reported aroma row with empty numerics', () {
      final row = IngredientAromaCompoundCsv.fromCsvRow(
        parseCsvLine(aromaReportedRaw),
        ah,
      );
      expect(row.ingredientId, 'ING-PLANT-POMME-000001');
      expect(row.ingredientStateId, 'raw');
      expect(row.compoundId, 'ETHBUTY');
      expect(row.presenceStatus, 'REPORTED');
      expect(row.concentration, isNull);
      expect(row.concentrationMin, isNull);
      expect(row.concentrationMax, isNull);
      expect(row.analyticalMethod, 'GC-MS/GC-O (FlavorDB2 aggregated)');
      expect(row.matrix, 'fresh/raw');
      expect(row.sourceRef, ['PUBCHEM']);
      expect(row.evidenceType, 'measured');
      expect(row.confidence, 0.75);
    });

    test('parses a quantified row with range and multi-source refs', () {
      final row = IngredientAromaCompoundCsv.fromCsvRow(
        parseCsvLine(aromaQuantifiedRaw),
        ah,
      );
      expect(row.presenceStatus, 'QUANTIFIED');
      expect(row.concentration, 0.8);
      expect(row.concentrationUnit, 'mg/100g');
      expect(row.concentrationMin, 0.4);
      expect(row.concentrationMax, 1.5);
      expect(row.sourceRef, ['FLAVORDB2', 'PUBCHEM']);
      expect(row.evidenceType, 'analytical_database');
      final companion = row.toCompanion();
      expect(companion.sourceRef.value, 'FLAVORDB2|PUBCHEM');
      expect(companion.concentration.value, 0.8);
    });

    test('is deterministic: parsing twice yields equal objects', () {
      final a = IngredientAromaCompoundCsv.fromCsvRow(
        parseCsvLine(aromaQuantifiedRaw),
        ah,
      );
      final b = IngredientAromaCompoundCsv.fromCsvRow(
        parseCsvLine(aromaQuantifiedRaw),
        ah,
      );
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });
  });
}
