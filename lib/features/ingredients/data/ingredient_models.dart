import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import '../../../core/database/tables/ingredients.dart';

/// Immutable 1:1 mapping of the [Ingredients] Drift table, populated from
/// `phase1-referentiel/ingredient_registry_v1.csv` (36 columns, UTF-8,
/// comma-separated, `|` for multi-valued fields, LF).
class IngredientCsv {
  final String ingredientId;
  final String canonicalNameFr;
  final String? canonicalNameEn;
  final List<String>? aliasesFr;
  final List<String>? aliasesEn;
  final String? scientificName;
  final String? kingdomOrOrigin;
  final String categoryLevel1;
  final String? categoryLevel2;
  final String? categoryLevel3;
  final String? sourceOrganism;
  final String? anatomicalPart;
  final String? ingredientClass;
  final String? rawOrIntermediate;
  final String? processingState;
  final String? physicalForm;
  final bool fermented;
  final bool dried;
  final bool smoked;
  final bool roasted;
  final bool concentrated;
  final bool alcoholic;
  final String? genericAbvRange;
  final String? countryOrRegionRelevance;
  final String? foodonId;
  final String? langualIds;
  final String? foodex2Code;
  final List<String>? ciqualIds;
  final List<String>? usdaFdcIds;
  final List<String>? otherExternalIds;
  final List<String>? allergenTags;
  final String? regulatoryNotes;
  final List<String>? sourceRefs;
  final double? confidence;
  final String? reviewStatus;
  final String? notes;

  const IngredientCsv({
    required this.ingredientId,
    required this.canonicalNameFr,
    this.canonicalNameEn,
    this.aliasesFr,
    this.aliasesEn,
    this.scientificName,
    this.kingdomOrOrigin,
    required this.categoryLevel1,
    this.categoryLevel2,
    this.categoryLevel3,
    this.sourceOrganism,
    this.anatomicalPart,
    this.ingredientClass,
    this.rawOrIntermediate,
    this.processingState,
    this.physicalForm,
    this.fermented = false,
    this.dried = false,
    this.smoked = false,
    this.roasted = false,
    this.concentrated = false,
    this.alcoholic = false,
    this.genericAbvRange,
    this.countryOrRegionRelevance,
    this.foodonId,
    this.langualIds,
    this.foodex2Code,
    this.ciqualIds,
    this.usdaFdcIds,
    this.otherExternalIds,
    this.allergenTags,
    this.regulatoryNotes,
    this.sourceRefs,
    this.confidence,
    this.reviewStatus,
    this.notes,
  });

  factory IngredientCsv.fromCsvRow(List<String> row, List<String> header) {
    final c = CsvCells(row, columnIndex(header));
    return IngredientCsv(
      ingredientId: c.reqStr('ingredient_id'),
      canonicalNameFr: c.reqStr('canonical_name_fr'),
      canonicalNameEn: c.str('canonical_name_en'),
      aliasesFr: c.strList('aliases_fr'),
      aliasesEn: c.strList('aliases_en'),
      scientificName: c.str('scientific_name'),
      kingdomOrOrigin: c.str('kingdom_or_origin'),
      categoryLevel1: c.reqStr('category_level_1'),
      categoryLevel2: c.str('category_level_2'),
      categoryLevel3: c.str('category_level_3'),
      sourceOrganism: c.str('source_organism'),
      anatomicalPart: c.str('anatomical_part'),
      ingredientClass: c.str('ingredient_class'),
      rawOrIntermediate: c.str('raw_or_intermediate'),
      processingState: c.str('processing_state'),
      physicalForm: c.str('physical_form'),
      fermented: c.boolOf('fermented') ?? false,
      dried: c.boolOf('dried') ?? false,
      smoked: c.boolOf('smoked') ?? false,
      roasted: c.boolOf('roasted') ?? false,
      concentrated: c.boolOf('concentrated') ?? false,
      alcoholic: c.boolOf('alcoholic') ?? false,
      genericAbvRange: c.str('generic_abv_range'),
      countryOrRegionRelevance: c.str('country_or_region_relevance'),
      foodonId: c.str('foodon_id'),
      langualIds: c.str('langual_ids'),
      foodex2Code: c.str('foodex2_code'),
      ciqualIds: c.strList('ciqual_ids'),
      usdaFdcIds: c.strList('usda_fdc_ids'),
      otherExternalIds: c.strList('other_external_ids'),
      allergenTags: c.strList('allergen_tags'),
      regulatoryNotes: c.str('regulatory_notes'),
      sourceRefs: c.strList('source_refs'),
      confidence: c.dbl('confidence'),
      reviewStatus: c.str('review_status'),
      notes: c.str('notes'),
    );
  }

  IngredientsCompanion toCompanion() => IngredientsCompanion(
    ingredientId: Value(ingredientId),
    canonicalNameFr: Value(canonicalNameFr),
    canonicalNameEn: Value(canonicalNameEn),
    aliasesFr: Value(pipeJoin(aliasesFr)),
    aliasesEn: Value(pipeJoin(aliasesEn)),
    scientificName: Value(scientificName),
    kingdomOrOrigin: Value(kingdomOrOrigin),
    categoryLevel1: Value(categoryLevel1),
    categoryLevel2: Value(categoryLevel2),
    categoryLevel3: Value(categoryLevel3),
    sourceOrganism: Value(sourceOrganism),
    anatomicalPart: Value(anatomicalPart),
    ingredientClass: Value(ingredientClass),
    rawOrIntermediate: Value(rawOrIntermediate),
    processingState: Value(processingState),
    physicalForm: Value(physicalForm),
    fermented: Value(fermented),
    dried: Value(dried),
    smoked: Value(smoked),
    roasted: Value(roasted),
    concentrated: Value(concentrated),
    alcoholic: Value(alcoholic),
    genericAbvRange: Value(genericAbvRange),
    countryOrRegionRelevance: Value(countryOrRegionRelevance),
    foodonId: Value(foodonId),
    langualIds: Value(langualIds),
    foodex2Code: Value(foodex2Code),
    ciqualIds: Value(pipeJoin(ciqualIds)),
    usdaFdcIds: Value(pipeJoin(usdaFdcIds)),
    otherExternalIds: Value(pipeJoin(otherExternalIds)),
    allergenTags: Value(pipeJoin(allergenTags)),
    regulatoryNotes: Value(regulatoryNotes),
    sourceRefs: Value(pipeJoin(sourceRefs)),
    confidence: Value(confidence),
    reviewStatus: Value(reviewStatus),
    notes: Value(notes),
  );

  List<Object?> get _props => [
    ingredientId,
    canonicalNameFr,
    canonicalNameEn,
    aliasesFr,
    aliasesEn,
    scientificName,
    kingdomOrOrigin,
    categoryLevel1,
    categoryLevel2,
    categoryLevel3,
    sourceOrganism,
    anatomicalPart,
    ingredientClass,
    rawOrIntermediate,
    processingState,
    physicalForm,
    fermented,
    dried,
    smoked,
    roasted,
    concentrated,
    alcoholic,
    genericAbvRange,
    countryOrRegionRelevance,
    foodonId,
    langualIds,
    foodex2Code,
    ciqualIds,
    usdaFdcIds,
    otherExternalIds,
    allergenTags,
    regulatoryNotes,
    sourceRefs,
    confidence,
    reviewStatus,
    notes,
  ];

  @override
  bool operator ==(Object other) =>
      other is IngredientCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}
