import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import '../../../core/database/tables/nutrition_components.dart';
import '../../../core/database/tables/nutrition_records.dart';

/// Immutable 1:1 mapping of the [NutritionRecords] Drift table, populated
/// from `phase2-nutrition/nutrition_database.csv` (30 columns; the CSV-only
/// column `canonical_name_fr` is denormalized display data and is ignored).
class NutritionRecordCsv {
  final String nutritionRecordId;
  final String ingredientId;
  final String? ingredientStateId;
  final String? sourceId;
  final String? sourceFoodId;
  final String? sourceFoodName;
  final String? sourceVersion;
  final String? sourceCountry;
  final String? componentId;
  final String? componentName;
  final String? componentGroup;
  final double? originalValue;
  final String? originalUnit;
  final double? normalizedValue;
  final String? normalizedUnit;
  final String? basis;
  final String? valueQualifier;
  final String? valueType;
  final double? minValue;
  final double? maxValue;
  final int? sampleCount;
  final String? analyticalMethod;
  final String? derivationMethod;
  final String? dataDate;
  final String? retrievalDate;
  final String? sourceUrl;
  final double? confidence;
  final double? mappingConfidence;
  final String? notes;

  const NutritionRecordCsv({
    required this.nutritionRecordId,
    required this.ingredientId,
    this.ingredientStateId,
    this.sourceId,
    this.sourceFoodId,
    this.sourceFoodName,
    this.sourceVersion,
    this.sourceCountry,
    this.componentId,
    this.componentName,
    this.componentGroup,
    this.originalValue,
    this.originalUnit,
    this.normalizedValue,
    this.normalizedUnit,
    this.basis,
    this.valueQualifier,
    this.valueType,
    this.minValue,
    this.maxValue,
    this.sampleCount,
    this.analyticalMethod,
    this.derivationMethod,
    this.dataDate,
    this.retrievalDate,
    this.sourceUrl,
    this.confidence,
    this.mappingConfidence,
    this.notes,
  });

  factory NutritionRecordCsv.fromCsvRow(List<String> row, List<String> header) {
    final c = CsvCells(row, columnIndex(header));
    return NutritionRecordCsv(
      nutritionRecordId: c.reqStr('nutrition_record_id'),
      ingredientId: c.reqStr('ingredient_id'),
      ingredientStateId: c.str('ingredient_state_id'),
      sourceId: c.str('source_id'),
      sourceFoodId: c.str('source_food_id'),
      sourceFoodName: c.str('source_food_name'),
      sourceVersion: c.str('source_version'),
      sourceCountry: c.str('source_country'),
      componentId: c.str('component_id'),
      componentName: c.str('component_name'),
      componentGroup: c.str('component_group'),
      originalValue: c.dbl('original_value'),
      originalUnit: c.str('original_unit'),
      normalizedValue: c.dbl('normalized_value'),
      normalizedUnit: c.str('normalized_unit'),
      basis: c.str('basis'),
      valueQualifier: c.str('value_qualifier'),
      valueType: c.str('value_type'),
      minValue: c.dbl('min_value'),
      maxValue: c.dbl('max_value'),
      sampleCount: c.intOf('sample_count'),
      analyticalMethod: c.str('analytical_method'),
      derivationMethod: c.str('derivation_method'),
      dataDate: c.str('data_date'),
      retrievalDate: c.str('retrieval_date'),
      sourceUrl: c.str('source_url'),
      confidence: c.dbl('confidence'),
      mappingConfidence: c.dbl('mapping_confidence'),
      notes: c.str('notes'),
    );
  }

  NutritionRecordsCompanion toCompanion() => NutritionRecordsCompanion(
    nutritionRecordId: Value(nutritionRecordId),
    ingredientId: Value(ingredientId),
    ingredientStateId: Value(ingredientStateId),
    sourceId: Value(sourceId),
    sourceFoodId: Value(sourceFoodId),
    sourceFoodName: Value(sourceFoodName),
    sourceVersion: Value(sourceVersion),
    sourceCountry: Value(sourceCountry),
    componentId: Value(componentId),
    componentName: Value(componentName),
    componentGroup: Value(componentGroup),
    originalValue: Value(originalValue),
    originalUnit: Value(originalUnit),
    normalizedValue: Value(normalizedValue),
    normalizedUnit: Value(normalizedUnit),
    basis: Value(basis),
    valueQualifier: Value(valueQualifier),
    valueType: Value(valueType),
    minValue: Value(minValue),
    maxValue: Value(maxValue),
    sampleCount: Value(sampleCount),
    analyticalMethod: Value(analyticalMethod),
    derivationMethod: Value(derivationMethod),
    dataDate: Value(dataDate),
    retrievalDate: Value(retrievalDate),
    sourceUrl: Value(sourceUrl),
    confidence: Value(confidence),
    mappingConfidence: Value(mappingConfidence),
    notes: Value(notes),
  );

  List<Object?> get _props => [
    nutritionRecordId,
    ingredientId,
    ingredientStateId,
    sourceId,
    sourceFoodId,
    sourceFoodName,
    sourceVersion,
    sourceCountry,
    componentId,
    componentName,
    componentGroup,
    originalValue,
    originalUnit,
    normalizedValue,
    normalizedUnit,
    basis,
    valueQualifier,
    valueType,
    minValue,
    maxValue,
    sampleCount,
    analyticalMethod,
    derivationMethod,
    dataDate,
    retrievalDate,
    sourceUrl,
    confidence,
    mappingConfidence,
    notes,
  ];

  @override
  bool operator ==(Object other) =>
      other is NutritionRecordCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}

/// Immutable 1:1 mapping of the [NutritionComponents] Drift table, populated
/// from `phase2-nutrition/component_dictionary.csv` (11 columns).
class NutritionComponentCsv {
  final String componentId;
  final String? canonicalName;
  final List<String>? synonyms;
  final String? componentGroup;
  final String? canonicalUnit;
  final String? infoodsTagname;
  final String? ciqualComponentId;
  final String? usdaNutrientId;
  final List<String>? otherIds;
  final String? definition;
  final String? conversionNotes;

  const NutritionComponentCsv({
    required this.componentId,
    this.canonicalName,
    this.synonyms,
    this.componentGroup,
    this.canonicalUnit,
    this.infoodsTagname,
    this.ciqualComponentId,
    this.usdaNutrientId,
    this.otherIds,
    this.definition,
    this.conversionNotes,
  });

  factory NutritionComponentCsv.fromCsvRow(
    List<String> row,
    List<String> header,
  ) {
    final c = CsvCells(row, columnIndex(header));
    return NutritionComponentCsv(
      componentId: c.reqStr('component_id'),
      canonicalName: c.str('canonical_name'),
      synonyms: c.strList('synonyms'),
      componentGroup: c.str('component_group'),
      canonicalUnit: c.str('canonical_unit'),
      infoodsTagname: c.str('infoods_tagname'),
      ciqualComponentId: c.str('ciqual_component_id'),
      usdaNutrientId: c.str('usda_nutrient_id'),
      otherIds: c.strList('other_ids'),
      definition: c.str('definition'),
      conversionNotes: c.str('conversion_notes'),
    );
  }

  NutritionComponentsCompanion toCompanion() => NutritionComponentsCompanion(
    componentId: Value(componentId),
    canonicalName: Value(canonicalName),
    synonyms: Value(pipeJoin(synonyms)),
    componentGroup: Value(componentGroup),
    canonicalUnit: Value(canonicalUnit),
    infoodsTagname: Value(infoodsTagname),
    ciqualComponentId: Value(ciqualComponentId),
    usdaNutrientId: Value(usdaNutrientId),
    otherIds: Value(pipeJoin(otherIds)),
    definition: Value(definition),
    conversionNotes: Value(conversionNotes),
  );

  List<Object?> get _props => [
    componentId,
    canonicalName,
    synonyms,
    componentGroup,
    canonicalUnit,
    infoodsTagname,
    ciqualComponentId,
    usdaNutrientId,
    otherIds,
    definition,
    conversionNotes,
  ];

  @override
  bool operator ==(Object other) =>
      other is NutritionComponentCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}
