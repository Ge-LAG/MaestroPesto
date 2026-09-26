import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import '../../../core/database/tables/functional_ingredients.dart';
import '../../../core/database/tables/interaction_rules.dart';
import '../../../core/database/tables/process_operations.dart';

/// Immutable 1:1 mapping of the [FunctionalIngredients] Drift table,
/// populated from `phase4-functional/functional_ingredients.csv`
/// (34 columns).
class FunctionalIngredientCsv {
  final String ingredientId;
  final String ingredientStateId;
  final double? temperatureReferenceC;
  final double? waterContent;
  final double? fatContent;
  final double? proteinContent;
  final double? starchContent;
  final double? sugarContent;
  final double? fiberContent;
  final double? pectinContent;
  final double? alcoholContent;
  final double? saltContent;
  final double? mineralContent;
  final double? ph;
  final double? titratableAcidity;
  final double? waterActivity;
  final double? brix;
  final double? densityGPerMl;
  final double? particleSizeUm;
  final String? solubility;
  final double? oilHoldingCapacityGG;
  final double? waterHoldingCapacityGG;
  final String? emulsifyingCapacity;
  final String? foamingCapacity;
  final String? gelationCapability;
  final String? thickeningCapability;
  final String? hygroscopicity;
  final String? thermalStability;
  final String? freezeThawStability;
  final String? oxidationSensitivity;
  final List<String>? sourceRefs;
  final String? evidenceType;
  final double? confidence;
  final String? validityConditions;

  const FunctionalIngredientCsv({
    required this.ingredientId,
    required this.ingredientStateId,
    this.temperatureReferenceC,
    this.waterContent,
    this.fatContent,
    this.proteinContent,
    this.starchContent,
    this.sugarContent,
    this.fiberContent,
    this.pectinContent,
    this.alcoholContent,
    this.saltContent,
    this.mineralContent,
    this.ph,
    this.titratableAcidity,
    this.waterActivity,
    this.brix,
    this.densityGPerMl,
    this.particleSizeUm,
    this.solubility,
    this.oilHoldingCapacityGG,
    this.waterHoldingCapacityGG,
    this.emulsifyingCapacity,
    this.foamingCapacity,
    this.gelationCapability,
    this.thickeningCapability,
    this.hygroscopicity,
    this.thermalStability,
    this.freezeThawStability,
    this.oxidationSensitivity,
    this.sourceRefs,
    this.evidenceType,
    this.confidence,
    this.validityConditions,
  });

  factory FunctionalIngredientCsv.fromCsvRow(
    List<String> row,
    List<String> header,
  ) {
    final c = CsvCells(row, columnIndex(header));
    return FunctionalIngredientCsv(
      ingredientId: c.reqStr('ingredient_id'),
      ingredientStateId: c.reqStr('ingredient_state_id'),
      temperatureReferenceC: c.dbl('temperature_reference_C'),
      waterContent: c.dbl('water_content'),
      fatContent: c.dbl('fat_content'),
      proteinContent: c.dbl('protein_content'),
      starchContent: c.dbl('starch_content'),
      sugarContent: c.dbl('sugar_content'),
      fiberContent: c.dbl('fiber_content'),
      pectinContent: c.dbl('pectin_content'),
      alcoholContent: c.dbl('alcohol_content'),
      saltContent: c.dbl('salt_content'),
      mineralContent: c.dbl('mineral_content'),
      ph: c.dbl('ph'),
      titratableAcidity: c.dbl('titratable_acidity'),
      waterActivity: c.dbl('water_activity'),
      brix: c.dbl('brix'),
      densityGPerMl: c.dbl('density_g_per_mL'),
      particleSizeUm: c.dbl('particle_size_um'),
      solubility: c.str('solubility'),
      oilHoldingCapacityGG: c.dbl('oil_holding_capacity_g_g'),
      waterHoldingCapacityGG: c.dbl('water_holding_capacity_g_g'),
      emulsifyingCapacity: c.str('emulsifying_capacity'),
      foamingCapacity: c.str('foaming_capacity'),
      gelationCapability: c.str('gelation_capability'),
      thickeningCapability: c.str('thickening_capability'),
      hygroscopicity: c.str('hygroscopicity'),
      thermalStability: c.str('thermal_stability'),
      freezeThawStability: c.str('freeze_thaw_stability'),
      oxidationSensitivity: c.str('oxidation_sensitivity'),
      sourceRefs: c.strList('source_refs'),
      evidenceType: c.str('evidence_type'),
      confidence: c.dbl('confidence'),
      validityConditions: c.str('validity_conditions'),
    );
  }

  FunctionalIngredientsCompanion toCompanion() =>
      FunctionalIngredientsCompanion(
        ingredientId: Value(ingredientId),
        ingredientStateId: Value(ingredientStateId),
        temperatureReferenceC: Value(temperatureReferenceC),
        waterContent: Value(waterContent),
        fatContent: Value(fatContent),
        proteinContent: Value(proteinContent),
        starchContent: Value(starchContent),
        sugarContent: Value(sugarContent),
        fiberContent: Value(fiberContent),
        pectinContent: Value(pectinContent),
        alcoholContent: Value(alcoholContent),
        saltContent: Value(saltContent),
        mineralContent: Value(mineralContent),
        ph: Value(ph),
        titratableAcidity: Value(titratableAcidity),
        waterActivity: Value(waterActivity),
        brix: Value(brix),
        densityGPerMl: Value(densityGPerMl),
        particleSizeUm: Value(particleSizeUm),
        solubility: Value(solubility),
        oilHoldingCapacityGG: Value(oilHoldingCapacityGG),
        waterHoldingCapacityGG: Value(waterHoldingCapacityGG),
        emulsifyingCapacity: Value(emulsifyingCapacity),
        foamingCapacity: Value(foamingCapacity),
        gelationCapability: Value(gelationCapability),
        thickeningCapability: Value(thickeningCapability),
        hygroscopicity: Value(hygroscopicity),
        thermalStability: Value(thermalStability),
        freezeThawStability: Value(freezeThawStability),
        oxidationSensitivity: Value(oxidationSensitivity),
        sourceRefs: Value(pipeJoin(sourceRefs)),
        evidenceType: Value(evidenceType),
        confidence: Value(confidence),
        validityConditions: Value(validityConditions),
      );

  List<Object?> get _props => [
    ingredientId,
    ingredientStateId,
    temperatureReferenceC,
    waterContent,
    fatContent,
    proteinContent,
    starchContent,
    sugarContent,
    fiberContent,
    pectinContent,
    alcoholContent,
    saltContent,
    mineralContent,
    ph,
    titratableAcidity,
    waterActivity,
    brix,
    densityGPerMl,
    particleSizeUm,
    solubility,
    oilHoldingCapacityGG,
    waterHoldingCapacityGG,
    emulsifyingCapacity,
    foamingCapacity,
    gelationCapability,
    thickeningCapability,
    hygroscopicity,
    thermalStability,
    freezeThawStability,
    oxidationSensitivity,
    sourceRefs,
    evidenceType,
    confidence,
    validityConditions,
  ];

  @override
  bool operator ==(Object other) =>
      other is FunctionalIngredientCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}

/// Immutable 1:1 mapping of the [InteractionRules] Drift table, populated
/// from `phase4-functional/interaction_rules.csv` (26 columns).
class InteractionRuleCsv {
  final String ruleId;
  final String? ruleFamily;
  final List<String>? reactantOrComponentIds;
  final String? ingredientConstraints;
  final String? compositionConstraints;
  final String? processConstraints;
  final double? phMin;
  final double? phMax;
  final double? temperatureMin;
  final double? temperatureMax;
  final double? timeMin;
  final double? timeMax;
  final double? waterActivityMin;
  final double? waterActivityMax;
  final String? shearConstraints;
  final String? orderConstraints;
  final String? predictedEffect;
  final String? effectDirection;
  final String? effectMagnitude;
  final String? outputProperty;
  final String? equationOrLogic;
  final List<String>? sourceRefs;
  final String? evidenceType;
  final double? confidence;
  final bool? extrapolationAllowed;
  final String? notes;

  const InteractionRuleCsv({
    required this.ruleId,
    this.ruleFamily,
    this.reactantOrComponentIds,
    this.ingredientConstraints,
    this.compositionConstraints,
    this.processConstraints,
    this.phMin,
    this.phMax,
    this.temperatureMin,
    this.temperatureMax,
    this.timeMin,
    this.timeMax,
    this.waterActivityMin,
    this.waterActivityMax,
    this.shearConstraints,
    this.orderConstraints,
    this.predictedEffect,
    this.effectDirection,
    this.effectMagnitude,
    this.outputProperty,
    this.equationOrLogic,
    this.sourceRefs,
    this.evidenceType,
    this.confidence,
    this.extrapolationAllowed,
    this.notes,
  });

  factory InteractionRuleCsv.fromCsvRow(List<String> row, List<String> header) {
    final c = CsvCells(row, columnIndex(header));
    return InteractionRuleCsv(
      ruleId: c.reqStr('rule_id'),
      ruleFamily: c.str('rule_family'),
      reactantOrComponentIds: c.strList('reactant_or_component_ids'),
      ingredientConstraints: c.str('ingredient_constraints'),
      compositionConstraints: c.str('composition_constraints'),
      processConstraints: c.str('process_constraints'),
      phMin: c.dbl('ph_min'),
      phMax: c.dbl('ph_max'),
      temperatureMin: c.dbl('temperature_min'),
      temperatureMax: c.dbl('temperature_max'),
      timeMin: c.dbl('time_min'),
      timeMax: c.dbl('time_max'),
      waterActivityMin: c.dbl('water_activity_min'),
      waterActivityMax: c.dbl('water_activity_max'),
      shearConstraints: c.str('shear_constraints'),
      orderConstraints: c.str('order_constraints'),
      predictedEffect: c.str('predicted_effect'),
      effectDirection: c.str('effect_direction'),
      effectMagnitude: c.str('effect_magnitude'),
      outputProperty: c.str('output_property'),
      equationOrLogic: c.str('equation_or_logic'),
      sourceRefs: c.strList('source_refs'),
      evidenceType: c.str('evidence_type'),
      confidence: c.dbl('confidence'),
      extrapolationAllowed: c.boolOf('extrapolation_allowed'),
      notes: c.str('notes'),
    );
  }

  InteractionRulesCompanion toCompanion() => InteractionRulesCompanion(
    ruleId: Value(ruleId),
    ruleFamily: Value(ruleFamily),
    reactantOrComponentIds: Value(pipeJoin(reactantOrComponentIds)),
    ingredientConstraints: Value(ingredientConstraints),
    compositionConstraints: Value(compositionConstraints),
    processConstraints: Value(processConstraints),
    phMin: Value(phMin),
    phMax: Value(phMax),
    temperatureMin: Value(temperatureMin),
    temperatureMax: Value(temperatureMax),
    timeMin: Value(timeMin),
    timeMax: Value(timeMax),
    waterActivityMin: Value(waterActivityMin),
    waterActivityMax: Value(waterActivityMax),
    shearConstraints: Value(shearConstraints),
    orderConstraints: Value(orderConstraints),
    predictedEffect: Value(predictedEffect),
    effectDirection: Value(effectDirection),
    effectMagnitude: Value(effectMagnitude),
    outputProperty: Value(outputProperty),
    equationOrLogic: Value(equationOrLogic),
    sourceRefs: Value(pipeJoin(sourceRefs)),
    evidenceType: Value(evidenceType),
    confidence: Value(confidence),
    extrapolationAllowed: Value(extrapolationAllowed),
    notes: Value(notes),
  );

  List<Object?> get _props => [
    ruleId,
    ruleFamily,
    reactantOrComponentIds,
    ingredientConstraints,
    compositionConstraints,
    processConstraints,
    phMin,
    phMax,
    temperatureMin,
    temperatureMax,
    timeMin,
    timeMax,
    waterActivityMin,
    waterActivityMax,
    shearConstraints,
    orderConstraints,
    predictedEffect,
    effectDirection,
    effectMagnitude,
    outputProperty,
    equationOrLogic,
    sourceRefs,
    evidenceType,
    confidence,
    extrapolationAllowed,
    notes,
  ];

  @override
  bool operator ==(Object other) =>
      other is InteractionRuleCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}

/// Immutable 1:1 mapping of the [ProcessOperations] Drift table, populated
/// from `phase4-functional/process_operations.csv` (22 columns, header
/// deduced from the CSV itself).
class ProcessOperationCsv {
  final String opId;
  final String? family;
  final String? name;
  final double? tMinC;
  final double? tMaxC;
  final double? durationMin;
  final String? pressure;
  final double? shearRateS1;
  final String? mixingRpm;
  final double? energyInput;
  final double? coolingRate;
  final double? heatingRate;
  final double? targetPh;
  final double? targetAw;
  final double? targetBrix;
  final double? particleSizeTargetUm;
  final String? oxygenExposure;
  final String? atmosphere;
  final int? orderIndex;
  final String? additionMode;
  final double? restTime;
  final String? notes;

  const ProcessOperationCsv({
    required this.opId,
    this.family,
    this.name,
    this.tMinC,
    this.tMaxC,
    this.durationMin,
    this.pressure,
    this.shearRateS1,
    this.mixingRpm,
    this.energyInput,
    this.coolingRate,
    this.heatingRate,
    this.targetPh,
    this.targetAw,
    this.targetBrix,
    this.particleSizeTargetUm,
    this.oxygenExposure,
    this.atmosphere,
    this.orderIndex,
    this.additionMode,
    this.restTime,
    this.notes,
  });

  factory ProcessOperationCsv.fromCsvRow(
    List<String> row,
    List<String> header,
  ) {
    final c = CsvCells(row, columnIndex(header));
    return ProcessOperationCsv(
      opId: c.reqStr('op_id'),
      family: c.str('family'),
      name: c.str('name'),
      tMinC: c.dbl('T_min_C'),
      tMaxC: c.dbl('T_max_C'),
      durationMin: c.dbl('duration_min'),
      pressure: c.str('pressure'),
      shearRateS1: c.dbl('shear_rate_s-1'),
      mixingRpm: c.str('mixing_rpm'),
      energyInput: c.dbl('energy_input'),
      coolingRate: c.dbl('cooling_rate'),
      heatingRate: c.dbl('heating_rate'),
      targetPh: c.dbl('target_ph'),
      targetAw: c.dbl('target_aw'),
      targetBrix: c.dbl('target_brix'),
      particleSizeTargetUm: c.dbl('particle_size_target_um'),
      oxygenExposure: c.str('oxygen_exposure'),
      atmosphere: c.str('atmosphere'),
      orderIndex: c.intOf('order_index'),
      additionMode: c.str('addition_mode'),
      restTime: c.dbl('rest_time'),
      notes: c.str('notes'),
    );
  }

  ProcessOperationsCompanion toCompanion() => ProcessOperationsCompanion(
    opId: Value(opId),
    family: Value(family),
    name: Value(name),
    tMinC: Value(tMinC),
    tMaxC: Value(tMaxC),
    durationMin: Value(durationMin),
    pressure: Value(pressure),
    shearRateS1: Value(shearRateS1),
    mixingRpm: Value(mixingRpm),
    energyInput: Value(energyInput),
    coolingRate: Value(coolingRate),
    heatingRate: Value(heatingRate),
    targetPh: Value(targetPh),
    targetAw: Value(targetAw),
    targetBrix: Value(targetBrix),
    particleSizeTargetUm: Value(particleSizeTargetUm),
    oxygenExposure: Value(oxygenExposure),
    atmosphere: Value(atmosphere),
    orderIndex: Value(orderIndex),
    additionMode: Value(additionMode),
    restTime: Value(restTime),
    notes: Value(notes),
  );

  List<Object?> get _props => [
    opId,
    family,
    name,
    tMinC,
    tMaxC,
    durationMin,
    pressure,
    shearRateS1,
    mixingRpm,
    energyInput,
    coolingRate,
    heatingRate,
    targetPh,
    targetAw,
    targetBrix,
    particleSizeTargetUm,
    oxygenExposure,
    atmosphere,
    orderIndex,
    additionMode,
    restTime,
    notes,
  ];

  @override
  bool operator ==(Object other) =>
      other is ProcessOperationCsv && csvPropsEquals(_props, other._props);

  @override
  int get hashCode => csvPropsHash(_props);
}
