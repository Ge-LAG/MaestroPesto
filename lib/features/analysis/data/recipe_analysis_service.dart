// Phase 10 — analyse métier complète d'une recette.
//
// Point d'entrée unique de l'interface : relie les quatre bases métier
// et le procédé.
//
//   étapes (texte)  → ProcessStepParser → opérations, T, durées, mentions
//   lignes          → mode de cuisson (explicite > étape citant la ligne
//                     > étape au four sans mention > étape précédente)
//   nutrition       → NutritionRepository + contexte de procédé
//                     (unités, rendements, rétentions, cuits mesurés)
//   physico-chimie  → PhysChemEstimator (composition, Brix, aw, pH)
//   règles Phase 4  → FunctionalConstraintSolver.evaluateMix
//   arômes          → FlavorRepository.analyze + suggestions
//   feedback        → NutritionFeedbackEngine (Nutri-Score, %AR, allégations)

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart' hide Recipe;
import '../../../core/models/flavor_analysis.dart';
import '../../../core/models/functional_alert.dart';
import '../../../core/models/nutrition_profile.dart';
import '../../../core/models/process_models.dart';
import '../../../core/scoring/functional_constraint_solver.dart';
import '../../../core/scoring/nutrition_aggregator.dart';
import '../../../core/scoring/nutrition_feedback.dart';
import '../../../core/scoring/physchem_estimator.dart';
import '../../../core/scoring/process_step_parser.dart';
import '../../../core/scoring/quantity_converter.dart';
import '../../flavor/data/flavor_repository.dart';
import '../../nutrition/data/nutrition_repository.dart';
import '../../recipes/domain/recipe.dart';
import 'metier_reference.dart';

/// Mode de cuisson résolu d'une ligne.
typedef LineMethod = ({CookingMethod method, bool inferred});

/// Note experte hors base de règles (bonnes pratiques documentées).
@immutable
class ExpertInsight {
  const ExpertInsight({required this.text, this.warning = false});

  final String text;
  final bool warning;
}

@immutable
class RecipeAnalysis {
  const RecipeAnalysis({
    required this.nutrition,
    required this.feedback,
    required this.physchem,
    required this.alerts,
    required this.steps,
    required this.lineMethods,
    required this.insights,
    this.flavor,
    this.suggestions = const <FlavorSuggestion>[],
    this.allergens = const <String, List<int>>{},
  });

  final NutritionAggregation nutrition;
  final NutritionFeedback feedback;
  final PhysChemState physchem;
  final List<FunctionalAlert> alerts;
  final List<ParsedStep> steps;

  /// Mode de cuisson par ligne (index → mode), absent = cru.
  final Map<int, LineMethod> lineMethods;
  final List<ExpertInsight> insights;
  final RecipeFlavorAnalysis? flavor;
  final List<FlavorSuggestion> suggestions;

  /// Allergènes déclarés (étiquette → index des lignes concernées),
  /// d'après le référentiel des ingrédients liés.
  final Map<String, List<int>> allergens;

  List<FunctionalAlert> get warnings =>
      alerts.where((a) => a.severity == FunctionalSeverity.warning).toList();
}

class RecipeAnalysisService {
  RecipeAnalysisService(this.db, {FlavorRepository? flavor})
    : _flavor = flavor ?? FlavorRepository(db);

  final AppDatabase db;
  final FlavorRepository _flavor;

  /// Résumé par portion stocké avec la recette (liste, export) ; null
  /// si aucune ligne n'alimente le calcul.
  static NutritionSummary? summaryOf(NutritionAggregation aggregation) {
    if (!aggregation.hasData) return null;
    final p = aggregation.profilePerServing;
    return NutritionSummary(
      energyKcal: p.energyKcal,
      proteins: p.proteins,
      carbs: p.carbs,
      fats: p.fats,
      fiber: p.fiber,
      salt: p.salt,
    );
  }

  /// Recalcule la nutrition stockée d'une recette en mode calculé
  /// (démos semées, référentiel réimporté). Retourne la recette mise à
  /// jour, ou null si elle est en saisie manuelle, sans donnée ou
  /// inchangée.
  Future<Recipe?> refreshStoredNutrition(Recipe recipe) async {
    if (recipe.nutritionMode != RecipeNutritionMode.computed) return null;
    if (!recipe.ingredients.any((i) => i.ingredientId != null)) return null;
    final analysis = await analyze(
      ingredients: recipe.ingredients,
      steps: recipe.steps,
      servings: recipe.servings,
      withSuggestions: false,
    );
    final summary = summaryOf(analysis.nutrition);
    if (summary == null) return null;
    final old = recipe.nutrition;
    bool same(double a, double b) => (a - b).abs() < 0.05;
    if (same(old.energyKcal, summary.energyKcal) &&
        same(old.proteins, summary.proteins) &&
        same(old.carbs, summary.carbs) &&
        same(old.fats, summary.fats) &&
        same(old.fiber, summary.fiber) &&
        same(old.salt, summary.salt)) {
      return null;
    }
    return recipe.copyWith(nutrition: summary);
  }

  Future<RecipeAnalysis> analyze({
    required List<RecipeIngredient> ingredients,
    required List<String> steps,
    required int servings,
    bool withSuggestions = true,
  }) async {
    final ref = await MetierReference.of(db);
    final parsed = ProcessStepParser.parseAll(
      steps,
      ingredientLabels: [for (final i in ingredients) i.label],
    );
    final methods = resolveLineMethods(ingredients, parsed);

    final nutritionRepo = NutritionRepository(db);
    final nutrition = await nutritionRepo.aggregateForRecipe(
      ingredients: ingredients,
      servings: servings,
      process: NutritionProcessContext(
        unitDataFor: (id) =>
            ref.ingredients[id]?.unitData ?? const IngredientUnitData(),
        groupFor: (id) => ref.ingredients[id]?.foodGroup ?? FoodGroup.other,
        factorFor: ref.factorFor,
        methodForLine: (index, _) => methods[index],
      ),
    );

    // Mélange physico-chimique (masses mises en œuvre).
    final profiles = <String, NutritionProfile?>{};
    final lines = <MixLine>[];
    for (final c in nutrition.contributions) {
      final grams = c.rawGrams;
      if (grams == null || grams <= 0) continue;
      final id = c.ingredientId;
      NutritionProfile? profile;
      if (id != null) {
        profile = profiles.containsKey(id)
            ? profiles[id]
            : profiles[id] = await nutritionRepo.forIngredient(id);
      }
      final r = id == null ? null : ref.ingredients[id];
      lines.add(
        MixLine(
          index: c.index,
          label: c.label,
          ingredientId: id,
          grams: grams,
          profile: profile,
          components: r?.components ?? const {},
          ph: r?.ph,
          isLiquidOil: r?.tags.contains('liquid_oil') ?? false,
          tags: r?.tags ?? const {},
        ),
      );
    }
    final state = PhysChemEstimator.estimate(lines, steps: parsed);
    final alerts = FunctionalConstraintSolver.evaluateMix(
      state: state,
      rules: ref.rules,
    );

    final feedback = NutritionFeedbackEngine.evaluate(
      nutrition,
      fvlFor: (id) => ref.ingredients[id]?.fvlClass ?? FvlClass.none,
      categoryFor: (id) {
        final r = ref.ingredients[id];
        return (
          level1: r?.level1 ?? '',
          level2: r?.level2 ?? '',
          name: r?.name ?? '',
        );
      },
    );

    final weights = <String, double>{};
    for (final l in lines) {
      final id = l.ingredientId;
      if (id != null) weights[id] = (weights[id] ?? 0) + l.grams;
    }
    final ids = [
      for (final i in ingredients)
        if (i.ingredientId != null && i.ingredientId!.isNotEmpty)
          i.ingredientId!,
    ];
    final flavor = await _flavor.analyze(ids, weights: weights);
    final suggestions = withSuggestions && ids.isNotEmpty
        ? await _flavor.suggestComplements(ids)
        : const <FlavorSuggestion>[];

    return RecipeAnalysis(
      nutrition: nutrition,
      feedback: feedback,
      physchem: state,
      alerts: alerts,
      steps: parsed,
      lineMethods: methods,
      insights: expertInsights(state, ref, lines),
      flavor: flavor,
      suggestions: suggestions,
      allergens: allergensOf(ingredients, ref),
    );
  }

  /// Allergènes déclarés par ligne liée (étiquette → index des lignes).
  @visibleForTesting
  static Map<String, List<int>> allergensOf(
    List<RecipeIngredient> ingredients,
    MetierReference ref,
  ) {
    final result = <String, List<int>>{};
    for (var i = 0; i < ingredients.length; i++) {
      final id = ingredients[i].ingredientId;
      if (id == null) continue;
      for (final tag in ref.ingredients[id]?.allergens ?? const <String>[]) {
        result.putIfAbsent(tag, () => []).add(i);
      }
    }
    return result;
  }

  /// Mode de cuisson de chaque ligne (voir l'en-tête du fichier).
  @visibleForTesting
  static Map<int, LineMethod> resolveLineMethods(
    List<RecipeIngredient> ingredients,
    List<ParsedStep> steps,
  ) {
    final out = <int, LineMethod>{};
    final explicit = <int>{};
    for (var i = 0; i < ingredients.length; i++) {
      final m = CookingMethod.fromId(ingredients[i].cookingMethod);
      if (m == null) continue;
      explicit.add(i);
      if (m.isHeated) out[i] = (method: m, inferred: false);
    }
    var previousMentions = <int>[];
    for (final step in steps) {
      final method = step.cookingMethod;
      final mentions = step.mentionedIngredients;
      if (method != null) {
        final List<int> targets;
        if (mentions.isNotEmpty) {
          targets = mentions;
        } else if (step.primary?.opId == 'PROC_ROTIR' ||
            previousMentions.isEmpty) {
          // Enfourner sans précision : toute la préparation.
          targets = [for (var i = 0; i < ingredients.length; i++) i];
        } else {
          targets = previousMentions;
        }
        for (final i in targets) {
          if (explicit.contains(i)) continue;
          out[i] = (method: method, inferred: true);
        }
      }
      if (mentions.isNotEmpty) previousMentions = mentions;
    }
    return out;
  }

  /// Notes expertes (hors règles Phase 4), sources : Damodaran, McGee,
  /// McClements — bonnes pratiques de formulation.
  @visibleForTesting
  static List<ExpertInsight> expertInsights(
    PhysChemState s,
    MetierReference ref,
    List<MixLine> lines,
  ) {
    final out = <ExpertInsight>[];
    final oilShare = s.totalMassG <= 0 ? 0 : s.liquidOilG / s.totalMassG;
    final emulsifier =
        s.hasComponent('LIP_PHOSPH', minPct: 0.05) ||
        s.hasComponent('LIP_MDG', minPct: 0.05) ||
        s.hasComponent('PROT_OVALB', minPct: 0.3);
    if (oilShare >= 0.15 && s.waterPct >= 8 && !emulsifier) {
      out.add(
        const ExpertInsight(
          text:
              'Émulsion temporaire : sans émulsifiant fort (jaune d\'œuf, '
              'lécithine), l\'huile se sépare en quelques minutes. La '
              'moutarde ou le miel la stabilisent un peu ; émulsionner au '
              'dernier moment.',
        ),
      );
    }
    if (s.hasTag('egg') && !s.hasHeating) {
      out.add(
        const ExpertInsight(
          warning: true,
          text:
              'Œuf cru : préparation à conserver au froid et à consommer '
              'dans les 24 h (déconseillé aux personnes fragiles).',
        ),
      );
    }
    if (s.hasTag('protease_fruit') &&
        s.hasComponent('PROT_GEL', minPct: 0.05) &&
        !s.hasHeating) {
      out.add(
        const ExpertInsight(
          warning: true,
          text:
              'Ananas, kiwi ou papaye crus contiennent des protéases qui '
              'empêchent la gélatine de prendre : cuire le fruit quelques '
              'minutes ou utiliser l\'agar-agar.',
        ),
      );
    }
    if (s.alcoholG > 0 && s.hasHeating) {
      out.add(
        const ExpertInsight(
          text:
              'Alcool : la cuisson n\'en évapore qu\'une partie (≈ 40 % '
              'restent après 15–30 min de mijotage ou de four).',
        ),
      );
    }
    final brix = s.brix;
    if (brix != null && brix >= 65 && s.hasCooling) {
      out.add(
        const ExpertInsight(
          text:
              'Sirop très concentré (≥ 65 % de sucres) : risque de '
              'cristallisation au refroidissement — un peu de glucose, de '
              'miel ou d\'acide limite le masquage.',
        ),
      );
    }
    return out;
  }
}
