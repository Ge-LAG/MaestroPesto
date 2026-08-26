// Phase 09 Lot H — H3 : tests du Recommender (§9.1 + annexe §20).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/flavor_match.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';
import 'package:maestropesto/core/models/recommendation.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recommendations/data/recommender.dart';

/// Fake Phase 1 (pas de Drift) — implémente IngredientCandidatesSource.
class FakeIngredients implements IngredientCandidatesSource {
  FakeIngredients(this.byId);

  final Map<String, IngredientSummary> byId;

  @override
  Future<IngredientSummary?> summaryFor(String ingredientId) async =>
      byId[ingredientId];

  @override
  Future<List<IngredientSummary>> candidatesForCategory(
    String categoryLevel1, {
    double minConfidence = 0.7,
  }) async =>
      byId.values
          .where((s) =>
              s.categoryLevel1 == categoryLevel1 &&
              s.confidence >= minConfidence)
          .toList();
}

IngredientSummary ing(
  String id,
  String name, {
  String category = 'animal',
  double confidence = 0.95,
}) =>
    IngredientSummary(
      ingredientId: id,
      canonicalNameFr: name,
      categoryLevel1: category,
      confidence: confidence,
    );

FlavorMatch pair(String a, String b, double score) => FlavorMatch(
      ingredientAId: a,
      ingredientBId: b,
      combinationSize: 2,
      overallScore: score,
    );

/// Fixtures de l'annexe §20 du plan : Bœuf + Fromage bleu + Thym.
const boeuf = 'ING-ANIMAL-BOEUF-000001';
const bleu = 'ING-DAIRY-BLEU-000001';
const thym = 'ING-PLANT-THYM-000001';
const agneau = 'ING-ANIMAL-AGNEAU-000001';
const poulet = 'ING-ANIMAL-POULET-000001';
const porc = 'ING-ANIMAL-PORC-000001';

Recommender buildRecommender({
  Map<String, IngredientSummary>? ingredients,
  List<FlavorMatch> matches = const [],
  List<InteractionRule> rules = const [],
}) =>
    Recommender(
      ingredients: FakeIngredients(ingredients ?? {}),
      flavor: FlavorRepository.fromMatches(matches),
      functional: FunctionalRepository.fromRules(rules),
    );

void main() {
  group('Recommender — scénarios §12.1', () {
    test('cible inconnue → liste vide', () async {
      final r = buildRecommender();
      final result = await r.suggestSubstitutes(
        targetIngredientId: 'ING-UNKNOWN',
        currentIngredientIds: const ['ING-UNKNOWN'],
      );
      expect(result, isEmpty);
    });

    test('recette équilibrée : pas de bonus, raison affinité', () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
        },
        matches: [pair(boeuf, thym, 0.85), pair(agneau, thym, 0.80)],
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, thym],
      );
      expect(result, hasLength(1));
      expect(result.single.suggestedIngredient.ingredientId, agneau);
      expect(result.single.score, closeTo(0.80, 1e-9));
      expect(result.single.reason, 'Meilleure affinité aromatique');
      expect(result.single.scoringSource, ScoringSource.flavor);
    });

    test('recette problématique : bonus +0.15 et raison résolution',
        () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
        },
        matches: [pair(boeuf, bleu, 0.32), pair(agneau, bleu, 0.62)],
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, bleu],
      );
      expect(result.single.score, closeTo(0.77, 1e-9)); // 0.62 + 0.15
      expect(result.single.reason, 'Résout une incompatibilité existante');
    });

    test('recette mono-ingrédient : score neutre 0.5 sans paire connue',
        () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
        },
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf],
      );
      expect(result.single.score, 0.5);
    });

    test('recette sans candidat : liste vide', () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          // Candidat sous le seuil de confiance 0.7.
          agneau: ing(agneau, 'Agneau', confidence: 0.5),
          // Candidat d'une autre catégorie.
          thym: ing(thym, 'Thym', category: 'vegetal'),
        },
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf],
      );
      expect(result, isEmpty);
    });

    test('max 5 recommandations triées par score décroissant', () async {
      final ingredients = <String, IngredientSummary>{
        boeuf: ing(boeuf, 'Bœuf'),
        for (var i = 1; i <= 7; i++)
          'ING-ANIMAL-CAND-00000$i': ing(
            'ING-ANIMAL-CAND-00000$i',
            'Candidat $i',
          ),
      };
      final matches = [
        pair(boeuf, thym, 0.80),
        for (var i = 1; i <= 7; i++)
          pair('ING-ANIMAL-CAND-00000$i', thym, 0.5 + i * 0.01),
      ];
      final r = buildRecommender(ingredients: ingredients, matches: matches);
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, thym],
      );
      expect(result, hasLength(5));
      expect(result.first.suggestedIngredient.ingredientId,
          'ING-ANIMAL-CAND-000007');
      for (var i = 1; i < result.length; i++) {
        expect(result[i - 1].score >= result[i].score, isTrue);
      }
    });

    test('candidat introduisant une nouvelle incompatibilité → écarté',
        () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
        },
        matches: [pair(agneau, bleu, 0.20)],
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, bleu],
      );
      expect(result, isEmpty);
    });

    test('candidat déclenchant une nouvelle alerte fonctionnelle → malus',
        () async {
      const rule = InteractionRule(
        ruleId: 'RULE-GEL-GELATINE',
        ruleFamily: 'gelling',
        reactantOrComponentIds: agneau,
        predictedEffect: 'gel',
        effectDirection: 'increase',
        confidence: 0.9,
      );
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
        },
        matches: [pair(agneau, thym, 0.80)],
        rules: const [rule],
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, thym],
      );
      // 0.80 base − 0.20 malus = 0.60, scoringSource = all.
      expect(result.single.score, closeTo(0.60, 1e-9));
      expect(result.single.scoringSource, ScoringSource.all);
    });

    test('candidats déjà dans la recette exclus', () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          agneau: ing(agneau, 'Agneau'),
          porc: ing(porc, 'Porc'),
        },
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, agneau],
      );
      expect(
        result.map((r) => r.suggestedIngredient.ingredientId),
        isNot(contains(agneau)),
      );
    });
  });

  group('Recommender — annexe §20 (Bœuf → Agneau/Poulet/Porc)', () {
    test('3 substituts ordonnés Poulet > Agneau > Porc', () async {
      final r = buildRecommender(
        ingredients: {
          boeuf: ing(boeuf, 'Bœuf'),
          bleu: ing(bleu, 'Fromage bleu', category: 'dairy'),
          thym: ing(thym, 'Thym', category: 'vegetal'),
          agneau: ing(agneau, 'Agneau'),
          poulet: ing(poulet, 'Poulet'),
          porc: ing(porc, 'Porc'),
        },
        matches: [
          pair(boeuf, bleu, 0.32),
          pair(boeuf, thym, 0.71),
          pair(bleu, thym, 0.58),
          pair(agneau, bleu, 0.62),
          pair(agneau, thym, 0.75),
          pair(poulet, bleu, 0.74),
          pair(poulet, thym, 0.80),
          pair(porc, bleu, 0.55),
          pair(porc, thym, 0.65),
        ],
      );
      final result = await r.suggestSubstitutes(
        targetIngredientId: boeuf,
        currentIngredientIds: const [boeuf, bleu, thym],
      );
      expect(
        result.map((r) => r.suggestedIngredient.ingredientId).toList(),
        [poulet, agneau, porc],
      );
      // Formule v1 : moyenne des paires avec {bleu, thym} + bonus 0.15.
      expect(result[0].score, closeTo(0.92, 1e-9)); // (0.74+0.80)/2 + 0.15
      expect(result[1].score, closeTo(0.835, 1e-9)); // (0.62+0.75)/2 + 0.15
      expect(result[2].score, closeTo(0.75, 1e-9)); // (0.55+0.65)/2 + 0.15
      expect(
        result.every((r) => r.originalIngredientId == boeuf),
        isTrue,
      );
    });
  });
}
