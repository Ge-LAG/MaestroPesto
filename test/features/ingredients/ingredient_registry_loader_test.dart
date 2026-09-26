import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:maestropesto/features/ingredients/data/ingredient_models.dart';
import 'package:flutter_test/flutter_test.dart';

const String header =
    'ingredient_id,canonical_name_fr,canonical_name_en,aliases_fr,aliases_en,'
    'scientific_name,kingdom_or_origin,category_level_1,category_level_2,'
    'category_level_3,source_organism,anatomical_part,ingredient_class,'
    'raw_or_intermediate,processing_state,physical_form,fermented,dried,'
    'smoked,roasted,concentrated,alcoholic,generic_abv_range,'
    'country_or_region_relevance,foodon_id,langual_ids,foodex2_code,'
    'ciqual_ids,usda_fdc_ids,other_external_ids,allergen_tags,'
    'regulatory_notes,source_refs,confidence,review_status,notes';

const String appleRaw =
    'ING-PLANT-POMME-000001,Pomme crue,"Apple, raw",pomme|pomme fraîche,'
    'apple|fresh apple,Malus domestica,Plantae,végétal,fruit,'
    'fruit à pépins,Malus domestica,fruit entier,fruit frais,raw,fresh,whole,'
    'false,false,false,false,false,false,,,FOODON:0330143,B1560,A04HA,13000,'
    '171688,,,,FOODON|LANGUAL|FOODEX2|CIQUAL|USDAFDC|MAESTRO_INTERNAL,0.85,'
    'curated,"Pomme crue avec peau, valeur de référence générique non '
    'variétale."';

const String raisinRaw =
    'ING-PLANT-RAISINSEC-000001,Raisin sec,Raisin,raisins secs,'
    'raisins|dried grapes,Vitis vinifera,Plantae,végétal,fruit,'
    'fruit séché,Vitis vinifera,baie,fruit séché,intermediate,dried,whole,,'
    'true,,,,,,,FOODON:0330173,,,13003,173946,,,,'
    'FOODON|CIQUAL|USDAFDC|MAESTRO_INTERNAL,0.85,curated,';

List<String> h = parseCsvHeader(header);

void main() {
  group('parseCsvLine', () {
    test('splits plain comma-separated fields', () {
      expect(parseCsvLine('a,b,c'), ['a', 'b', 'c']);
    });

    test('keeps commas inside double quotes', () {
      expect(parseCsvLine('"Apple, raw",x'), ['Apple, raw', 'x']);
    });

    test('unescapes doubled double quotes', () {
      expect(parseCsvLine('"say ""hi""",z'), ['say "hi"', 'z']);
    });

    test('keeps empty trailing fields', () {
      expect(parseCsvLine('a,,c,'), ['a', '', 'c', '']);
    });

    test('rejects unterminated quoted field', () {
      expect(() => parseCsvLine('"open,end'), throwsA(isA<FormatException>()));
    });
  });

  group('Sha256', () {
    test('matches FIPS 180-4 test vectors', () {
      final abc = Sha256()..add('abc'.codeUnits);
      expect(
        abc.digestHex(),
        'ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad',
      );
      final empty = Sha256();
      expect(
        empty.digestHex(),
        'e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852'
        'b855',
      );
    });

    test('streams multi-chunk content like a single pass', () {
      final content = 'a,b,c\n1,"x, y",3\n';
      final oneShot = Sha256()..add(content.codeUnits);
      final chunked = Sha256()
        ..add(content.substring(0, 4).codeUnits)
        ..add(content.substring(4, 9).codeUnits)
        ..add(content.substring(9).codeUnits);
      final oneShotHex = oneShot.digestHex();
      expect(chunked.digestHex(), oneShotHex);
      expect(
        oneShotHex,
        '276a3c59d15abfb1ebe196776bb134d9012f2a44488364db1a67714ae17af8f6',
      );
    });
  });

  group('IngredientCsv.fromCsvRow', () {
    test('parses a real phase 1 row (Pomme crue)', () {
      final row = IngredientCsv.fromCsvRow(parseCsvLine(appleRaw), h);
      expect(row.ingredientId, 'ING-PLANT-POMME-000001');
      expect(row.canonicalNameFr, 'Pomme crue');
      expect(row.canonicalNameEn, 'Apple, raw');
      expect(row.aliasesFr, ['pomme', 'pomme fraîche']);
      expect(row.aliasesEn, ['apple', 'fresh apple']);
      expect(row.scientificName, 'Malus domestica');
      expect(row.categoryLevel1, 'végétal');
      expect(row.categoryLevel2, 'fruit');
      expect(row.categoryLevel3, 'fruit à pépins');
      expect(row.ingredientClass, 'fruit frais');
      expect(row.rawOrIntermediate, 'raw');
      expect(row.fermented, isFalse);
      expect(row.dried, isFalse);
      expect(row.alcoholic, isFalse);
      expect(row.foodonId, 'FOODON:0330143');
      expect(row.langualIds, 'B1560');
      expect(row.ciqualIds, ['13000']);
      expect(row.usdaFdcIds, ['171688']);
      expect(row.sourceRefs, [
        'FOODON',
        'LANGUAL',
        'FOODEX2',
        'CIQUAL',
        'USDAFDC',
        'MAESTRO_INTERNAL',
      ]);
      expect(row.confidence, 0.85);
      expect(row.reviewStatus, 'curated');
      expect(
        row.notes,
        'Pomme crue avec peau, valeur de référence générique '
        'non variétale.',
      );
    });

    test('keeps empty cells as null (no zero-for-unknown)', () {
      final row = IngredientCsv.fromCsvRow(parseCsvLine(appleRaw), h);
      expect(row.genericAbvRange, isNull);
      expect(row.countryOrRegionRelevance, isNull);
      expect(row.otherExternalIds, isNull);
      expect(row.allergenTags, isNull);
      expect(row.regulatoryNotes, isNull);
    });

    test('parses lowercase booleans (true case, empty = false)', () {
      final row = IngredientCsv.fromCsvRow(parseCsvLine(raisinRaw), h);
      expect(row.ingredientId, 'ING-PLANT-RAISINSEC-000001');
      expect(row.fermented, isFalse);
      expect(row.dried, isTrue);
      expect(row.smoked, isFalse);
      expect(row.aliasesEn, ['raisins', 'dried grapes']);
      expect(row.langualIds, isNull);
      expect(row.notes, isNull);
    });

    test('round-trips pipe-separated fields through the companion', () {
      final companion = IngredientCsv.fromCsvRow(
        parseCsvLine(appleRaw),
        h,
      ).toCompanion();
      expect(companion.aliasesFr.value, 'pomme|pomme fraîche');
      expect(companion.ciqualIds.value, '13000');
      expect(
        companion.sourceRefs.value,
        'FOODON|LANGUAL|FOODEX2|CIQUAL|USDAFDC|MAESTRO_INTERNAL',
      );
      expect(companion.canonicalNameEn.value, 'Apple, raw');
      expect(companion.confidence.value, 0.85);
      expect(companion.genericAbvRange.present, isTrue);
      expect(companion.genericAbvRange.value, isNull);
    });

    test('is deterministic: parsing twice yields equal objects', () {
      final a = IngredientCsv.fromCsvRow(parseCsvLine(appleRaw), h);
      final b = IngredientCsv.fromCsvRow(parseCsvLine(appleRaw), h);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      final r1 = IngredientCsv.fromCsvRow(parseCsvLine(raisinRaw), h);
      final r2 = IngredientCsv.fromCsvRow(parseCsvLine(raisinRaw), h);
      expect(r1, r2);
    });

    test('throws when a required key is empty', () {
      final broken = appleRaw.replaceFirst(
        'ING-PLANT-POMME-000001,Pomme crue',
        ',',
      );
      expect(
        () => IngredientCsv.fromCsvRow(parseCsvLine(broken), h),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
