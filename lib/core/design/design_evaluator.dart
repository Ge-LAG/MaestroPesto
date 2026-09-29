// Phase 11 Lot B — évaluation d'une composition candidate.
//
// Les moteurs d'analyse existants servent de fonction d'évaluation
// (phase11-recette-inversee, « Principe technique ») :
//   étapes rédigées du gabarit → ProcessStepParser → mode de chaque
//   ligne (RecipeProcessRules) → NutritionAggregator (valeurs par
//   portion, rendements, rétentions, cuits mesurés) → PhysChemEstimator
//   (matière sèche, phase grasse, pH, aw, Brix, évaporation) →
//   NutritionFeedbackEngine (Nutri-Score) → RecipeFlavorAnalyzer
//   (harmonie, accords documentés, arômes dominants) ;
//   en évaluation complète : FunctionalConstraintSolver (alertes) et
//   notes expertes.
//
// Deux chemins, mêmes résultats :
// - [evaluate] (recherche) : l'agrégation nutritionnelle, linéaire en
//   masse ligne par ligne, est obtenue en sommant les contributions de
//   chaque ingrédient pour 100 g calculées une fois par le VRAI
//   agrégateur (même mode de cuisson) ; physico-chimie et arômes passent
//   par les mêmes moteurs ;
// - [evaluateFull] (variantes retenues) : la recette rédigée (quantités
//   arrondies) est analysée ligne à ligne comme dans l'éditeur.
// Un test vérifie que les deux chemins coïncident.

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../features/recipes/domain/recipe.dart';
import '../models/flavor_analysis.dart';
import '../models/flavor_match.dart';
import '../models/flavor_profile.dart';
import '../models/functional_alert.dart';
import '../models/nutrition_profile.dart';
import '../models/process_models.dart';
import '../scoring/flavor_pairing_engine.dart';
import '../scoring/functional_constraint_solver.dart';
import '../scoring/nutrition_aggregator.dart';
import '../scoring/nutrition_feedback.dart';
import '../scoring/physchem_estimator.dart';
import '../scoring/process_step_parser.dart';
import '../scoring/recipe_flavor_analyzer.dart';
import '../scoring/recipe_process_rules.dart';
import 'design_dataset.dart';
import 'design_metrics.dart';
import 'dish_skeleton.dart';

/// Ligne d'une composition : ingrédient, rôle (étapes rédigées) et
/// masse PAR PORTION (g).
@immutable
class DesignLine {
  const DesignLine({
    required this.ingredientId,
    required this.role,
    required this.grams,
  });

  final String ingredientId;
  final String role;
  final double grams;

  DesignLine withGrams(double g) =>
      DesignLine(ingredientId: ingredientId, role: role, grams: g);
}

/// Composition candidate : gabarit, lignes et durée du procédé.
class DesignComposition {
  DesignComposition({
    required this.skeleton,
    required this.lines,
    this.duration,
    String? setKey,
  }) : _setKey = setKey; // ignore: prefer_initializing_formals

  final DishSkeleton skeleton;
  final List<DesignLine> lines;

  /// Durée retenue ({duree}, min) ; null = défaut du gabarit.
  final double? duration;

  String? _setKey;

  List<String> get ids => [for (final l in lines) l.ingredientId];

  double get servingMassG => lines.fold<double>(0, (s, l) => s + l.grams);

  /// Clé de l'ensemble (gabarit, ingrédients et rôles), sans les masses.
  String get setKey => _setKey ??=
      '${skeleton.id}|${[for (final l in lines) '${l.ingredientId}:${l.role}'].join(',')}';

  /// Clé de contexte d'évaluation (ensemble et durée).
  late final String frameKey = '$setKey@${duration?.round()}';

  /// Copie. [sameSet] : seules les masses changent (clé conservée).
  DesignComposition copyWith({
    List<DesignLine>? lines,
    double? duration,
    bool sameSet = false,
  }) => DesignComposition(
    skeleton: skeleton,
    lines: lines ?? this.lines,
    duration: duration ?? this.duration,
    setKey: sameSet || lines == null ? _setKey : null,
  );
}

/// Valeur mesurée d'une métrique.
@immutable
class MeasuredValue {
  const MeasuredValue({
    this.value,
    this.choice,
    required this.verifiable,
    this.shares = const <String, double>{},
  });

  final double? value;
  final String? choice;

  /// Parts (0..1) des familles aromatiques dominantes.
  final Map<String, double> shares;

  /// Couverture suffisante (sinon « non vérifiable »).
  final bool verifiable;
}

/// Mesures d'une composition.
@immutable
class DesignMeasure {
  const DesignMeasure({
    required this.values,
    required this.perServing,
    required this.physchem,
    required this.method,
    this.harmony,
    this.supportedPairs = 0,
    this.pairCount = 0,
    this.nutriGrade,
    this.dominantFamily,
  });

  /// Métrique → valeur.
  final Map<String, MeasuredValue> values;

  /// Valeurs par portion (énergie, protéines, sucres, AGS, sel, fibres).
  final NutritionProfile perServing;
  final PhysChemState physchem;
  final CookingMethod method;
  final double? harmony;
  final int supportedPairs;
  final int pairCount;
  final String? nutriGrade;
  final String? dominantFamily;

  MeasuredValue? operator [](String metricId) => values[metricId];
}

/// Évaluation complète d'une variante retenue (affichage).
@immutable
class DesignFullEvaluation {
  const DesignFullEvaluation({
    required this.measure,
    required this.ingredients,
    required this.steps,
    required this.nutrition,
    required this.feedback,
    required this.alerts,
    required this.insights,
    required this.allergens,
    this.flavor,
  });

  final DesignMeasure measure;

  /// Lignes rédigées (quantités arrondies en grammes pour la recette).
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final NutritionAggregation nutrition;
  final NutritionFeedback feedback;
  final RecipeFlavorAnalysis? flavor;

  /// Alertes Phase 4 (sécurité, fonctionnalité) : affichées sans filtre.
  final List<FunctionalAlert> alerts;
  final List<ExpertInsight> insights;

  /// Allergène → index des lignes concernées.
  final Map<String, List<int>> allergens;
}

/// Contribution d'un ingrédient pour 100 g cru, sous un mode de cuisson
/// (sortie du vrai agrégateur, voir l'en-tête).
class _Unit {
  _Unit(NutritionAggregation a)
    : hasData = a.hasData,
      energy = a.profilePerServing.energyKcal,
      proteins = a.profilePerServing.proteins,
      carbs = a.profilePerServing.carbs,
      sugars = a.profilePerServing.sugars,
      fats = a.profilePerServing.fats,
      saturatedFats = a.profilePerServing.saturatedFats,
      fiber = a.profilePerServing.fiber,
      salt = a.profilePerServing.salt,
      alcohol = a.profilePerServing.alcohol,
      cooked = a.cookedMassG,
      water = a.profilePerServing.waterContent,
      known = a.profilePerServing.knownFields;

  final bool hasData;
  final double energy;
  final double proteins;
  final double carbs;
  final double sugars;
  final double fats;
  final double saturatedFats;
  final double fiber;
  final double salt;
  final double alcohol;
  final double cooked;
  final double? water;
  final Set<MacroField> known;
}

/// Contexte d'un ensemble (gabarit, ingrédients, rôles, durée) : étapes
/// rédigées et analysées, modes de cuisson, contributions unitaires.
class _Frame {
  _Frame({
    required this.parsed,
    required this.methods,
    required this.units,
    required this.flavorIds,
    required this.pairScore,
    required this.pairConfidence,
    required this.supportedPairs,
    this.combination,
  });

  final List<ParsedStep> parsed;
  final Map<int, LineMethod> methods;
  final List<_Unit> units;

  /// Ingrédients distincts ayant un profil sensoriel (ordre des lignes).
  final List<String> flavorIds;

  /// Paires (i < j) de [flavorIds] : score, confiance, paires étayées.
  final List<double> pairScore;
  final List<double> pairConfidence;
  final int supportedPairs;

  /// Combinaison n-aire observée couvrant exactement [flavorIds].
  final FlavorMatch? combination;
}

/// Étape de gabarit analysée : rôles cités et texte fixe.
class _TemplateStep {
  _TemplateStep({
    required this.parsed,
    required this.roles,
    required this.staticText,
  });

  final ParsedStep parsed;
  final Set<String> roles;
  final String staticText;
}

/// Évaluateur d'une demande (portions fixées).
class DesignEvaluator {
  DesignEvaluator(
    this.data, {
    required this.servings,
    this.withAromaFamilies = true,
    this.withNutriScore = true,
  });

  final DesignDataset data;
  final int servings;

  /// Calcule les familles aromatiques dominantes en évaluation rapide
  /// (inutile quand la demande ne vise pas de famille).
  final bool withAromaFamilies;

  /// Calcule le Nutri-Score en évaluation rapide (inutile quand la
  /// demande ne le vise pas).
  final bool withNutriScore;

  final Map<String, _Frame> _frames = {};
  final Map<String, _Unit> _units = {};
  final Map<String, FlavorMatch> _pairs = {};

  /// Nombre d'évaluations rapides effectuées (statistiques, budget).
  int evaluations = 0;

  static const int _maxFrames = 4000;

  // ---------------------------------------------------------------------
  // Rédaction.
  // ---------------------------------------------------------------------

  /// Noms cités dans les étapes, par rôle (ordre des lignes).
  Map<String, List<String>> namesByRole(DesignComposition c) {
    final out = <String, List<String>>{};
    for (final l in c.lines) {
      final name = data[l.ingredientId]?.stepName ?? l.ingredientId;
      final list = out.putIfAbsent(l.role, () => []);
      if (!list.contains(name)) list.add(name);
    }
    return out;
  }

  /// Étapes rédigées d'une composition.
  List<String> stepsOf(DesignComposition c) =>
      c.skeleton.process.render(namesByRole(c), duration: c.duration);

  /// Libellé de ligne (nom du référentiel sans « cru »).
  String labelOf(String id) => data[id]?.label ?? id;

  // ---------------------------------------------------------------------
  // Évaluation rapide (recherche).
  // ---------------------------------------------------------------------

  DesignMeasure evaluate(DesignComposition c) {
    evaluations++;
    final frame = _frameOf(c);
    final n = servings.toDouble();

    // Nutrition : somme des contributions unitaires (linéaire en masse).
    var energy = 0.0,
        proteins = 0.0,
        carbs = 0.0,
        sugars = 0.0,
        fats = 0.0,
        satFats = 0.0,
        fiber = 0.0,
        salt = 0.0,
        alcohol = 0.0,
        rawMass = 0.0,
        cookedMass = 0.0,
        waterCooked = 0.0,
        waterKnownMass = 0.0;
    var withData = 0;
    final knownMass = <MacroField, double>{};
    final mix = <MixLine>[];
    final weights = <String, double>{};
    final contributions = <({String? ingredientId, double? rawGrams})>[];
    for (var i = 0; i < c.lines.length; i++) {
      final line = c.lines[i];
      final g = line.grams * n;
      final u = frame.units[i];
      final f = g / 100;
      rawMass += g;
      cookedMass += u.cooked * f;
      if (withNutriScore) {
        contributions.add((ingredientId: line.ingredientId, rawGrams: g));
      }
      final ing = data[line.ingredientId]!;
      weights[line.ingredientId] = (weights[line.ingredientId] ?? 0) + g;
      mix.add(
        MixLine(
          index: i,
          label: ing.label,
          ingredientId: ing.id,
          grams: g,
          profile: ing.raw,
          components: ing.components,
          ph: ing.ph,
          isLiquidOil: ing.tags.contains('liquid_oil'),
          tags: ing.tags,
        ),
      );
      if (!u.hasData) continue;
      withData++;
      energy += u.energy * f;
      proteins += u.proteins * f;
      carbs += u.carbs * f;
      sugars += u.sugars * f;
      fats += u.fats * f;
      satFats += u.saturatedFats * f;
      fiber += u.fiber * f;
      salt += u.salt * f;
      alcohol += u.alcohol * f;
      final w = u.water;
      if (w != null) {
        waterCooked += w * f;
        waterKnownMass += u.cooked * f;
      }
      for (final field in u.known) {
        knownMass[field] = (knownMass[field] ?? 0) + g;
      }
    }
    final coverage = <MacroField, double>{
      for (final field in kAllMacroFields)
        field: rawMass > 0 ? (knownMass[field] ?? 0) / rawMass : 0,
    };
    NutritionProfile scaled(double divisor, {double? water}) =>
        NutritionProfile(
          energyKcal: energy / divisor,
          proteins: proteins / divisor,
          carbs: carbs / divisor,
          sugars: sugars / divisor,
          fats: fats / divisor,
          saturatedFats: satFats / divisor,
          fiber: fiber / divisor,
          salt: salt / divisor,
          alcohol: alcohol / divisor,
          waterContent: water,
          ingredientStateId: 'raw',
          confidence: 1,
          recordCount: withData,
          knownFields: {
            for (final e in coverage.entries)
              if (e.value > 0) e.key,
          },
        );
    final perServing = scaled(n);
    NutritionProfile? per100g;
    if (withData > 0 && cookedMass > 0) {
      per100g = scaled(
        cookedMass / 100,
        water: waterKnownMass > 0 ? waterCooked / waterKnownMass * 100 : null,
      );
    }
    final nutri = !withNutriScore
        ? null
        : NutritionFeedbackEngine.nutriScoreFor(
            per100g: per100g,
            hasData: withData > 0,
            coverage: coverage,
            lines: contributions,
            fvlFor: _fvlFor,
            categoryFor: _categoryFor,
          );
    final state = PhysChemEstimator.estimate(
      mix,
      steps: frame.parsed,
      detailed: false,
    );

    // Arômes.
    double? harmony;
    var supported = 0;
    var pairCount = 0;
    List<MapEntry<String, double>> dominant = const [];
    final ids = frame.flavorIds;
    if (ids.length >= 2) {
      // Même calcul que RecipeFlavorAnalyzer.harmonyOf, paires résolues
      // une fois par ensemble.
      var weighted = 0.0;
      var weightSum = 0.0;
      var k = 0;
      for (var i = 0; i < ids.length; i++) {
        for (var j = i + 1; j < ids.length; j++, k++) {
          final w =
              frame.pairConfidence[k] *
              RecipeFlavorAnalyzer.pairWeight(ids[i], ids[j], weights);
          weighted += frame.pairScore[k] * w;
          weightSum += w;
        }
      }
      harmony =
          frame.combination?.overallScore ??
          (weightSum == 0 ? 0 : weighted / weightSum);
      pairCount = frame.pairScore.length;
      supported = frame.supportedPairs;
      if (withAromaFamilies) {
        dominant = RecipeFlavorAnalyzer.dominantAromas([
          for (final id in ids) data[id]!.flavor!,
        ], weights);
      }
    }
    return _measure(
      c: c,
      perServing: perServing,
      coverage: coverage,
      state: state,
      nutriScore: nutri?.score,
      harmony: harmony,
      supported: supported,
      pairCount: pairCount,
      dominant: dominant,
      flavorCoverage: _flavorCoverage(c),
    );
  }

  // ---------------------------------------------------------------------
  // Évaluation complète (variantes retenues).
  // ---------------------------------------------------------------------

  /// Analyse de la recette rédigée : quantités arrondies pour [servings]
  /// portions, étapes du gabarit, alertes et notes expertes.
  DesignFullEvaluation evaluateFull(DesignComposition c) {
    final steps = stepsOf(c);
    final ingredients = [
      for (final l in c.lines)
        RecipeIngredient(
          label: labelOf(l.ingredientId),
          quantity: formatGrams(l.grams * servings),
          source: IngredientSource.ciqual,
          ingredientId: l.ingredientId,
        ),
    ];
    final parsed = ProcessStepParser.parseAll(
      steps,
      ingredientLabels: [for (final i in ingredients) i.label],
    );
    final methods = RecipeProcessRules.resolveLineMethods(ingredients, parsed);
    final nutrition = NutritionAggregator.aggregate(
      ingredients: ingredients,
      lookup: (id) => data[id]?.raw,
      servings: servings,
      process: NutritionProcessContext(
        groupFor: (id) => data[id]?.group ?? FoodGroup.other,
        factorFor: data.factorFor,
        methodForLine: (index, _) => methods[index],
        measuredCookedFor: (id, method) => data[id]?.cooked[method],
      ),
    );
    final mix = <MixLine>[];
    for (final contribution in nutrition.contributions) {
      final grams = contribution.rawGrams;
      if (grams == null || grams <= 0) continue;
      final ing = data[contribution.ingredientId ?? ''];
      mix.add(
        MixLine(
          index: contribution.index,
          label: contribution.label,
          ingredientId: contribution.ingredientId,
          grams: grams,
          profile: ing?.raw,
          components: ing?.components ?? const {},
          ph: ing?.ph,
          isLiquidOil: ing?.tags.contains('liquid_oil') ?? false,
          tags: ing?.tags ?? const {},
        ),
      );
    }
    final state = PhysChemEstimator.estimate(mix, steps: parsed);
    final alerts = FunctionalConstraintSolver.evaluateMix(
      state: state,
      rules: data.rules,
    );
    final feedback = NutritionFeedbackEngine.evaluate(
      nutrition,
      fvlFor: _fvlFor,
      categoryFor: _categoryFor,
    );
    final weights = <String, double>{};
    for (final l in mix) {
      final id = l.ingredientId;
      if (id != null) weights[id] = (weights[id] ?? 0) + l.grams;
    }
    final flavorIds = [
      for (final id in c.ids.toSet())
        if (data[id]?.flavor != null) id,
    ];
    final flavor = flavorIds.length < 2
        ? null
        : RecipeFlavorAnalyzer.analyze(
            ids: flavorIds,
            profileOf: (id) => data[id]!.flavor!,
            pair: _pair,
            combination: data.combinations[DesignDataset.setKey(flavorIds)],
            weights: weights,
          );
    final allergens = <String, List<int>>{};
    for (var i = 0; i < c.lines.length; i++) {
      for (final tag in data[c.lines[i].ingredientId]?.allergens ?? const []) {
        allergens.putIfAbsent(tag, () => []).add(i);
      }
    }
    final measure = _measure(
      c: c,
      perServing: nutrition.profilePerServing,
      coverage: nutrition.nutrientCoverage,
      state: state,
      nutriScore: feedback.nutriScore,
      harmony: flavor?.harmony,
      supported: flavor?.supportedPairCount ?? 0,
      pairCount: flavor?.pairs.length ?? 0,
      dominant: flavor?.dominantAromas ?? const [],
      flavorCoverage: _flavorCoverage(c),
    );
    return DesignFullEvaluation(
      measure: measure,
      ingredients: ingredients,
      steps: steps,
      nutrition: nutrition,
      feedback: feedback,
      flavor: flavor,
      alerts: alerts,
      insights: RecipeProcessRules.expertInsights(state),
      allergens: allergens,
    );
  }

  // ---------------------------------------------------------------------
  // Mesure des métriques (commune aux deux chemins).
  // ---------------------------------------------------------------------

  DesignMeasure _measure({
    required DesignComposition c,
    required NutritionProfile perServing,
    required Map<MacroField, double> coverage,
    required PhysChemState state,
    required NutriScoreResult? nutriScore,
    required double? harmony,
    required int supported,
    required int pairCount,
    required List<MapEntry<String, double>> dominant,
    required double flavorCoverage,
  }) {
    final values = <String, MeasuredValue>{};
    final method = c.skeleton.process.method;
    values[DesignMetrics.cookingMethod.id] = MeasuredValue(
      choice: method.id,
      verifiable: true,
    );
    final compositionOk =
        state.compositionCoverage >= DesignMetrics.dryMatter.minCoverage;
    values[DesignMetrics.dryMatter.id] = MeasuredValue(
      value: state.totalMassG > 0 ? state.dryMatterPct : null,
      verifiable: compositionOk && state.totalMassG > 0,
    );
    values[DesignMetrics.fatPhase.id] = MeasuredValue(
      value: state.totalMassG > 0 ? state.fatPct : null,
      verifiable: compositionOk && state.totalMassG > 0,
    );
    values[DesignMetrics.ph.id] = MeasuredValue(
      value: state.ph,
      verifiable:
          state.ph != null && state.phCoverage >= DesignMetrics.ph.minCoverage,
    );
    values[DesignMetrics.aw.id] = MeasuredValue(
      value: state.aw,
      verifiable: state.aw != null && compositionOk,
    );
    values[DesignMetrics.brix.id] = MeasuredValue(
      value: state.brix,
      verifiable: state.brix != null && compositionOk,
    );
    values[DesignMetrics.pivot.id] = MeasuredValue(
      choice: c.ids.join('|'),
      verifiable: true,
    );
    String? topFamily;
    if (dominant.isNotEmpty) {
      final families = familyShares(dominant);
      topFamily = families.first.key;
      values[DesignMetrics.dominantFamily.id] = MeasuredValue(
        choice: topFamily,
        value: families.first.value,
        shares: {for (final e in families) e.key: e.value},
        verifiable: flavorCoverage >= DesignMetrics.dominantFamily.minCoverage,
      );
    } else {
      values[DesignMetrics.dominantFamily.id] = const MeasuredValue(
        verifiable: false,
      );
    }
    values[DesignMetrics.harmony.id] = MeasuredValue(
      value: harmony,
      verifiable: harmony != null,
    );
    values[DesignMetrics.documentedShare.id] = MeasuredValue(
      value: pairCount == 0 ? null : supported / pairCount * 100,
      verifiable: pairCount > 0,
    );
    bool cov(MacroField f, DesignMetric m) =>
        (coverage[f] ?? 0) >= m.minCoverage;
    values[DesignMetrics.energy.id] = MeasuredValue(
      value: perServing.energyKcal,
      verifiable: cov(MacroField.energy, DesignMetrics.energy),
    );
    values[DesignMetrics.proteins.id] = MeasuredValue(
      value: perServing.proteins,
      verifiable: cov(MacroField.proteins, DesignMetrics.proteins),
    );
    values[DesignMetrics.salt.id] = MeasuredValue(
      value: perServing.salt,
      verifiable: cov(MacroField.salt, DesignMetrics.salt),
    );
    values[DesignMetrics.sugars.id] = MeasuredValue(
      value: perServing.sugars,
      verifiable: cov(MacroField.sugars, DesignMetrics.sugars),
    );
    values[DesignMetrics.saturatedFats.id] = MeasuredValue(
      value: perServing.saturatedFats,
      verifiable: cov(MacroField.saturatedFats, DesignMetrics.saturatedFats),
    );
    values[DesignMetrics.fiber.id] = MeasuredValue(
      value: perServing.fiber,
      verifiable: cov(MacroField.fiber, DesignMetrics.fiber),
    );
    values[DesignMetrics.nutriScore.id] = MeasuredValue(
      choice: nutriScore?.grade,
      value: nutriScore?.score.toDouble(),
      verifiable: nutriScore != null,
    );
    return DesignMeasure(
      values: values,
      perServing: perServing,
      physchem: state,
      method: method,
      harmony: harmony,
      supportedPairs: supported,
      pairCount: pairCount,
      nutriGrade: nutriScore?.grade,
      dominantFamily: topFamily,
    );
  }

  /// Parts des familles aromatiques parmi les arômes dominants, triées.
  static List<MapEntry<String, double>> familyShares(
    List<MapEntry<String, double>> dominant,
  ) {
    final byFamily = <String, double>{};
    var total = 0.0;
    for (final e in dominant) {
      final f = SensoryOntology.family(e.key);
      byFamily[f] = (byFamily[f] ?? 0) + e.value;
      total += e.value;
    }
    final out =
        [
          for (final e in byFamily.entries)
            MapEntry(e.key, total <= 0 ? 0.0 : e.value / total),
        ]..sort((a, b) {
          final byValue = b.value.compareTo(a.value);
          return byValue != 0 ? byValue : a.key.compareTo(b.key);
        });
    return out;
  }

  // ---------------------------------------------------------------------
  // Caches.
  // ---------------------------------------------------------------------

  _Frame _frameOf(DesignComposition c) {
    final key = c.frameKey;
    final cached = _frames[key];
    if (cached != null) return cached;
    if (_frames.length > _maxFrames) _frames.clear();
    final ingredients = [
      for (final l in c.lines)
        RecipeIngredient(
          label: labelOf(l.ingredientId),
          quantity: '',
          source: IngredientSource.ciqual,
          ingredientId: l.ingredientId,
        ),
    ];
    final parsed = _structuralSteps(c, ingredients);
    final methods = RecipeProcessRules.resolveLineMethods(ingredients, parsed);
    final units = [
      for (var i = 0; i < c.lines.length; i++)
        _unitOf(c.lines[i].ingredientId, methods[i]?.method),
    ];
    final seen = <String>{};
    final flavorIds = [
      for (final id in c.ids)
        if (data[id]?.flavor != null && seen.add(id)) id,
    ];
    final pairs = [
      for (var i = 0; i < flavorIds.length; i++)
        for (var j = i + 1; j < flavorIds.length; j++)
          _pair(flavorIds[i], flavorIds[j]),
    ];
    return _frames[key] = _Frame(
      parsed: parsed,
      methods: methods,
      units: units,
      flavorIds: flavorIds,
      pairScore: [for (final m in pairs) m.overallScore],
      pairConfidence: [for (final m in pairs) m.confidence ?? 0.5],
      supportedPairs: pairs.where((m) => !m.isPrediction).length,
      combination: flavorIds.length < 2
          ? null
          : data.combinations[DesignDataset.setKey(flavorIds)],
    );
  }

  /// Étapes analysées sans rédaction complète : le gabarit est analysé
  /// une fois par ensemble de rôles remplis (opérations, températures,
  /// durées), et une ligne est citée par une étape quand son rôle y
  /// figure ou quand son libellé apparaît dans le texte fixe de l'étape.
  /// Équivalent à l'analyse du texte rédigé, sauf quand un nom
  /// d'ingrédient contient lui-même un verbe de cuisson ou un mot d'un
  /// autre ingrédient : l'évaluation complète des variantes retenues
  /// relit toujours le texte rédigé.
  List<ParsedStep> _structuralSteps(
    DesignComposition c,
    List<RecipeIngredient> ingredients,
  ) {
    final template = _templateOf(c);
    final out = <ParsedStep>[];
    for (final t in template) {
      final mentions = <int>[];
      for (var i = 0; i < c.lines.length; i++) {
        final role = c.lines[i].role;
        final id = c.lines[i].ingredientId;
        // Un nom trop court (« ail ») n'est jamais reconnu dans le texte.
        final nameDetected = _selfMentions[id] ??=
            ProcessStepParser.mentionsLabel(
              data[id]?.stepName ?? id,
              ingredients[i].label,
            );
        final cited =
            (nameDetected && t.roles.contains(role)) ||
            (_staticMentions['${t.staticText}|${ingredients[i].label}'] ??=
                ProcessStepParser.mentionsLabel(
                  t.staticText,
                  ingredients[i].label,
                ));
        if (cited) mentions.add(i);
      }
      final p = t.parsed;
      out.add(
        ParsedStep(
          index: p.index,
          text: p.text,
          operations: p.operations,
          temperatureC: p.temperatureC,
          durationMin: p.durationMin,
          mentionedIngredients: mentions,
        ),
      );
    }
    return out;
  }

  /// Gabarit analysé pour les rôles remplis de [c] : chaque rôle est
  /// rendu par un jeton neutre (caractère d'usage privé) que ni le
  /// lexique des opérations ni les libellés ne reconnaissent.
  List<_TemplateStep> _templateOf(DesignComposition c) {
    final roles = <String>[];
    for (final l in c.lines) {
      if (!roles.contains(l.role)) roles.add(l.role);
    }
    final key = '${c.skeleton.id}|${roles.join(',')}|${c.duration?.round()}';
    return _templates[key] ??= () {
      final tokens = {
        for (var i = 0; i < roles.length; i++)
          roles[i]: String.fromCharCode(0xE000 + i),
      };
      final texts = c.skeleton.process.render({
        for (final e in tokens.entries) e.key: [e.value],
      }, duration: c.duration);
      final parsed = ProcessStepParser.parseAll(texts);
      return [
        for (var i = 0; i < texts.length; i++)
          _TemplateStep(
            parsed: parsed[i],
            roles: {
              for (final e in tokens.entries)
                if (texts[i].contains(e.value)) e.key,
            },
            staticText: texts[i].replaceAll(_privateUse, ' '),
          ),
      ];
    }();
  }

  static final RegExp _privateUse = RegExp(r'[-]');
  final Map<String, List<_TemplateStep>> _templates = {};
  final Map<String, bool> _staticMentions = {};
  final Map<String, bool> _selfMentions = {};

  _Unit _unitOf(String id, CookingMethod? method) {
    final key = '$id@${method?.id}';
    return _units[key] ??= _Unit(
      NutritionAggregator.aggregate(
        ingredients: [
          RecipeIngredient(
            label: id,
            quantity: '100 g',
            source: IngredientSource.ciqual,
            ingredientId: id,
          ),
        ],
        lookup: (i) => data[i]?.raw,
        servings: 1,
        process: NutritionProcessContext(
          groupFor: (i) => data[i]?.group ?? FoodGroup.other,
          factorFor: data.factorFor,
          methodForLine: (_, _) =>
              method == null ? null : (method: method, inferred: true),
          measuredCookedFor: (i, m) => data[i]?.cooked[m],
        ),
      ),
    );
  }

  FlavorMatch _pair(String a, String b) {
    final key = DesignDataset.pairKey(a, b);
    return _pairs[key] ??= FlavorPairingEngine.scorePair(
      data[a]!.flavor!,
      data[b]!.flavor!,
      empirical: data.empirical[key],
    );
  }

  /// Score d'accord (0..1) d'une paire, 0,5 sans profil (préselection).
  double pairScore(String a, String b) {
    if (a == b) return 1;
    if (data[a]?.flavor == null || data[b]?.flavor == null) return 0.5;
    return _pair(a, b).overallScore;
  }

  /// Vrai si l'accord de la paire est étayé (observé ou curaté).
  bool pairSupported(String a, String b) {
    if (a == b || data[a]?.flavor == null || data[b]?.flavor == null) {
      return false;
    }
    return !_pair(a, b).isPrediction;
  }

  double _flavorCoverage(DesignComposition c) {
    var total = 0.0;
    var known = 0.0;
    for (final l in c.lines) {
      total += l.grams;
      if (data[l.ingredientId]?.flavor != null) known += l.grams;
    }
    return total <= 0 ? 0 : known / total;
  }

  FvlClass _fvlFor(String id) => data[id]?.fvl ?? FvlClass.none;

  ({String level1, String level2, String name}) _categoryFor(String id) {
    final r = data[id];
    return (
      level1: r?.level1 ?? '',
      level2: r?.level2 ?? '',
      name: r?.name ?? '',
    );
  }
}

/// Arrondi d'une masse de recette (g) à une précision de cuisine :
/// 0,1 g sous 1 g ; 0,5 g sous 10 g ; 1 g sous 100 g ; 5 g au-delà.
double roundGrams(double g) {
  final step = g < 1
      ? 0.1
      : g < 10
      ? 0.5
      : g < 100
      ? 1.0
      : 5.0;
  final r = (g / step).round() * step;
  return math.max(step, double.parse(r.toStringAsFixed(1)));
}

/// Quantité rédigée (« 12,5 g »), arrondie par [roundGrams].
String formatGrams(double g) {
  final r = roundGrams(g);
  final s = r == r.roundToDouble()
      ? r.toStringAsFixed(0)
      : r.toStringAsFixed(1).replaceAll('.', ',');
  return '$s g';
}
