import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import '../../../core/database/tables/flavor_compatibility.dart';
import '../../../core/database/tables/ingredient_aroma_compounds.dart';

/// Immutable 1:1 mapping of the [FlavorCompatibility] Drift table, populated
/// from `phase3-flavour/flavor_compatibility.csv` (24 columns).
class FlavorCompatibilityCsv {
  final String recordId;
  final int? combinationSize;
  final List<String>? ingredientIds;
  final String? ingredientNames;
  final String? context;
  final String? processContext;
  final String? observedOrPredicted;
  final double? aromaSimilarity;
  final double? aromaComplement;
  final double? aromaContrast;
  final double? tasteBalance;
  final double? culinarySupport;
  final double? sensorySupport;
  final double? dominanceRisk;
  final double? maskingRisk;
  final double? noveltyScore;
  final double? overallScore;
  final double? confidence;
  final List<String>? keyCompounds;
  final List<String>? keyDescriptors;
  final List<String>? bridgeIngredients;
  final List<String>? evidenceRefs;
  final String? modelVersion;
  final String? explanation;

  const FlavorCompatibilityCsv({
    required this.recordId,
    this.combinationSize,
    this.ingredientIds,
    this.ingredientNames,
    this.context,
    this.processContext,
    this.observedOrPredicted,
    this.aromaSimilarity,
    this.aromaComplement,
    this.aromaContrast,
    this.tasteBalance,
    this.culinarySupport,
    this.sensorySupport,
    this.dominanceRisk,
    this.maskingRisk,
    this.noveltyScore,
    this.overallScore,
    this.confidence,
    this.keyCompounds,
    this.keyDescriptors,
    this.bridgeIngredients,
    this.evidenceRefs,
    this.modelVersion,
    this.explanation,
  });

  factory FlavorCompatibilityCsv.fromCsvRow(
    List<String> row,
    List<String> header,
  ) {
    final c = CsvCells(row, columnIndex(header));
    return FlavorCompatibilityCsv(
      recordId: c.reqStr('record_id'),
      combinationSize: c.intOf('combination_size'),
      ingredientIds: c.strList('ingredient_ids'),
      ingredientNames: c.str('ingredient_names'),
      context: c.str('context'),
      processContext: c.str('process_context'),
      observedOrPredicted: c.str('observed_or_predicted'),
      aromaSimilarity: c.dbl('aroma_similarity'),
      aromaComplement: c.dbl('aroma_complement'),
      aromaContrast: c.dbl('aroma_contrast'),
      tasteBalance: c.dbl('taste_balance'),
      culinarySupport: c.dbl('culinary_support'),
      sensorySupport: c.dbl('sensory_support'),
      dominanceRisk: c.dbl('dominance_risk'),
      maskingRisk: c.dbl('masking_risk'),
      noveltyScore: c.dbl('novelty_score'),
      overallScore: c.dbl('overall_score'),
      confidence: c.dbl('confidence'),
      keyCompounds: c.strList('key_compounds'),
      keyDescriptors: c.strList('key_descriptors'),
      bridgeIngredients: c.strList('bridge_ingredients'),
      evidenceRefs: c.strList('evidence_refs'),
      modelVersion: c.str('model_version'),
      explanation: c.str('explanation'),
    );
  }

  FlavorCompatibilityCompanion toCompanion() => FlavorCompatibilityCompanion(
    recordId: Value(recordId),
    combinationSize: Value(combinationSize),
    ingredientIds: Value(pipeJoin(ingredientIds)),
    ingredientNames: Value(ingredientNames),
    context: Value(context),
    processContext: Value(processContext),
    observedOrPredicted: Value(observedOrPredicted),
    aromaSimilarity: Value(aromaSimilarity),
    aromaComplement: Value(aromaComplement),
    aromaContrast: Value(aromaContrast),
    tasteBalance: Value(tasteBalance),
    culinarySupport: Value(culinarySupport),
    sensorySupport: Value(sensorySupport),
    dominanceRisk: Value(dominanceRisk),
    maskingRisk: Value(maskingRisk),
    noveltyScore: Value(noveltyScore),
    overallScore: Value(overallScore),
    confidence: Value(confidence),
    keyCompounds: Value(pipeJoin(keyCompounds)),
    keyDescriptors: Value(pipeJoin(keyDescriptors)),
    bridgeIngredients: Value(pipeJoin(bridgeIngredients)),
    evidenceRefs: Value(pipeJoin(evidenceRefs)),
    modelVersion: Value(modelVersion),
    explanation: Value(explanation),
  );

  List<Object?> get _props => [
    recordId,
    combinationSize,
    ingredientIds,
    ingredientNames,
    context,
    processContext,
    observedOrPredicted,
    aromaSimilarity,
    aromaComplement,
    aromaContrast,
    tasteBalance,
    culinarySupport,
    sensorySupport,
    dominanceRisk,
    maskingRisk,
    noveltyScore,
    overallScore,
    confidence,
    keyCompounds,
    keyDescriptors,
    bridgeIngredients,
    evidenceRefs,
    modelVersion,
    explanation,
  ];

  @override
  bool operator ==(Object other) =>
      other is FlavorCompatibilityCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}

/// Immutable 1:1 mapping of the [IngredientAromaCompounds] Drift table,
/// populated from `phase3-flavour/ingredient_aroma_compounds.csv`
/// (14 columns; `source_ref` carries `|`-separated multi-sources).
class IngredientAromaCompoundCsv {
  final String ingredientId;
  final String? ingredientStateId;
  final String compoundId;
  final String? presenceStatus;
  final double? concentration;
  final String? concentrationUnit;
  final double? concentrationMin;
  final double? concentrationMax;
  final String? analyticalMethod;
  final String? matrix;
  final String? processState;
  final List<String>? sourceRef;
  final String? evidenceType;
  final double? confidence;

  const IngredientAromaCompoundCsv({
    required this.ingredientId,
    this.ingredientStateId,
    required this.compoundId,
    this.presenceStatus,
    this.concentration,
    this.concentrationUnit,
    this.concentrationMin,
    this.concentrationMax,
    this.analyticalMethod,
    this.matrix,
    this.processState,
    this.sourceRef,
    this.evidenceType,
    this.confidence,
  });

  factory IngredientAromaCompoundCsv.fromCsvRow(
    List<String> row,
    List<String> header,
  ) {
    final c = CsvCells(row, columnIndex(header));
    return IngredientAromaCompoundCsv(
      ingredientId: c.reqStr('ingredient_id'),
      ingredientStateId: c.str('ingredient_state_id'),
      compoundId: c.reqStr('compound_id'),
      presenceStatus: c.str('presence_status'),
      concentration: c.dbl('concentration'),
      concentrationUnit: c.str('concentration_unit'),
      concentrationMin: c.dbl('concentration_min'),
      concentrationMax: c.dbl('concentration_max'),
      analyticalMethod: c.str('analytical_method'),
      matrix: c.str('matrix'),
      processState: c.str('process_state'),
      sourceRef: c.strList('source_ref'),
      evidenceType: c.str('evidence_type'),
      confidence: c.dbl('confidence'),
    );
  }

  IngredientAromaCompoundsCompanion toCompanion() =>
      IngredientAromaCompoundsCompanion(
        ingredientId: Value(ingredientId),
        ingredientStateId: Value(ingredientStateId),
        compoundId: Value(compoundId),
        presenceStatus: Value(presenceStatus),
        concentration: Value(concentration),
        concentrationUnit: Value(concentrationUnit),
        concentrationMin: Value(concentrationMin),
        concentrationMax: Value(concentrationMax),
        analyticalMethod: Value(analyticalMethod),
        matrix: Value(matrix),
        processState: Value(processState),
        sourceRef: Value(pipeJoin(sourceRef)),
        evidenceType: Value(evidenceType),
        confidence: Value(confidence),
      );

  List<Object?> get _props => [
    ingredientId,
    ingredientStateId,
    compoundId,
    presenceStatus,
    concentration,
    concentrationUnit,
    concentrationMin,
    concentrationMax,
    analyticalMethod,
    matrix,
    processState,
    sourceRef,
    evidenceType,
    confidence,
  ];

  @override
  bool operator ==(Object other) =>
      other is IngredientAromaCompoundCsv &&
      csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}
