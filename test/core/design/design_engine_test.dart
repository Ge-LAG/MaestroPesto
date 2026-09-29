// Phase 11 Lots A-B — moteur de composition (recette à l'envers) sur les
// vraies bases métier : critères d'acceptation machine du plan
// phase11-recette-inversee.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_dataset.dart';
import 'package:maestropesto/core/design/design_engine.dart';
import 'package:maestropesto/core/design/design_evaluator.dart';
import 'package:maestropesto/core/design/design_metrics.dart';
import 'package:maestropesto/core/design/design_scoring.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/design/data/design_dataset_loader.dart';
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

/// Recettes de démonstration couvertes : type de plat, gabarit, mode.
const _covered = {
  'pesto': ('sauce_froide', 'sauce_mixee', 'raw'),
  'mayonnaise': ('sauce_froide', 'emulsion', 'raw'),
  'ratatouille': ('legumes_mijotes', 'legumes_mijotes', 'stewed'),
  'creme-patissiere': ('creme_lactee', 'creme_cuite', 'boiled'),
  'panna-cotta': ('creme_lactee', 'creme_gelifiee', 'boiled'),
  'confiture-fraise': ('conserve_sucree', 'confiture', 'boiled'),
};

/// Propriétés mesurées d'une recette de démonstration (fixture de
/// l'aller-retour) : seuls les critères vérifiables deviennent des
/// objectifs.
class _Measured {
  _Measured(this.recipe, this.analysis);

  final Recipe recipe;
  final RecipeAnalysis analysis;

  Map<String, DesignTarget> targets(String method) {
    final p = analysis.nutrition.profilePerServing;
    final s = analysis.physchem;
    final cov = analysis.nutrition.nutrientCoverage;
    final composition = s.compositionCoverage >= 0.8;
    bool known(MacroField f) => (cov[f] ?? 0) >= 0.8;
    return {
      'cooking_method': DesignTarget.choice(method),
      if (composition) 'dry_matter': DesignTarget.value(s.dryMatterPct),
      if (composition) 'fat_phase': DesignTarget.value(s.fatPct),
      if (s.ph != null && s.phCoverage >= 0.5) 'ph': DesignTarget.value(s.ph!),
      if (s.aw != null && composition) 'aw': DesignTarget.value(s.aw!),
      if (s.brix != null && composition) 'brix': DesignTarget.value(s.brix!),
      if (known(MacroField.energy)) 'energy': DesignTarget.value(p.energyKcal),
      if (known(MacroField.proteins))
        'proteins': DesignTarget.value(p.proteins),
      if (known(MacroField.salt)) 'salt': DesignTarget.value(p.salt),
      if (known(MacroField.sugars)) 'sugars': DesignTarget.value(p.sugars),
      if (known(MacroField.saturatedFats))
        'saturated_fats': DesignTarget.value(p.saturatedFats),
      if (known(MacroField.fiber)) 'fiber': DesignTarget.value(p.fiber),
      if (analysis.feedback.nutriScore != null)
        'nutriscore': DesignTarget.choice(analysis.feedback.nutriScore!.grade),
      'harmony': DesignTarget.atLeast(analysis.flavor!.harmony),
    };
  }
}

void main() {
  late AppDatabase db;
  late DesignDataset data;
  late RecipeAnalysisService service;
  final measured = <String, _Measured>{};
  final coherent = <String, DesignResult>{};
  final briefs = <String, DesignBrief>{};

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CsvImportService(
      db,
      databaseMetierRoot: 'assets/database-metier',
    ).importAll();
    data = await DesignDatasetLoader.load(db);
    service = RecipeAnalysisService(db);
    for (final r in demoRecipes) {
      final covered = _covered[r.id];
      if (covered == null) continue;
      final m = _Measured(
        r,
        await service.analyze(
          ingredients: r.ingredients,
          steps: r.steps,
          servings: r.servings,
          withSuggestions: false,
        ),
      );
      measured[r.id] = m;
      final brief = DesignBrief(
        familyId: covered.$1,
        servings: r.servings,
        targets: m.targets(covered.$3),
      );
      briefs[r.id] = brief;
      coherent[r.id] = DesignEngine(data).run(brief);
    }
  });

  tearDownAll(() => db.close());

  test('données : squelettes importés, référentiel complet', () {
    expect(data.catalog.dishFamilies, hasLength(4));
    expect(data.ingredients.length, greaterThan(550));
    expect(measured, hasLength(6));
  });

  group('lot A — squelettes', () {
    test('les quantités des six recettes couvertes tombent dans les bornes '
        'des rôles de leur gabarit', () {
      measured.forEach((id, m) {
        final skeleton = data.catalog.skeleton(_covered[id]!.$2)!;
        var total = 0.0;
        for (final c in m.analysis.nutrition.contributions) {
          final perServing = c.rawGrams! / m.recipe.servings;
          total += perServing;
          final roles = skeleton.rolesOf(c.ingredientId!);
          expect(roles, isNotEmpty, reason: '$id : ${c.label} sans rôle');
          expect(
            roles.any(
              (r) =>
                  perServing >= r.minGPerServing - 1e-9 &&
                  perServing <= r.maxGPerServing + 1e-9,
            ),
            isTrue,
            reason:
                '$id : ${c.label} ${perServing.toStringAsFixed(2)} g/portion '
                'hors des bornes de ${roles.map((r) => r.role).join('/')}',
          );
        }
        final p = skeleton.process;
        expect(
          total,
          inInclusiveRange(p.servingMinG, p.servingMaxG),
          reason: '$id : masse par portion',
        );
      });
    });
  });

  group('lot B — critères d\'acceptation', () {
    test('R1 aller-retour (cohérent) : une variante atteint chaque objectif '
        'vérifiable à ± 10 %, harmonie ≥ originale', () {
      coherent.forEach((id, result) {
        expect(result.variants, isNotEmpty, reason: id);
        final ok = result.variants.where(
          (v) => v.score.criteria.every((c) => c.status == CriterionStatus.met),
        );
        expect(
          ok,
          isNotEmpty,
          reason:
              '$id : ${[for (final v in result.variants) v.score.criteria.where((c) => c.status != CriterionStatus.met).map((c) => '${c.metric.id}=${c.value}').join(' ')]}',
        );
        final best = ok.first;
        expect(
          best.evaluation.measure.harmony,
          greaterThanOrEqualTo(measured[id]!.analysis.flavor!.harmony - 1e-9),
          reason: id,
        );
      });
    });

    test('R2 Pure Innovation : écart pondéré de la meilleure variante ≤ '
        'celui du mode cohérent', () {
      for (final id in _covered.keys) {
        final pi = DesignEngine(data)
            .run(briefs[id]!.copyWith(mode: DesignMode.pureInnovation));
        expect(pi.variants, isNotEmpty, reason: id);
        double best(DesignResult r) => r.variants
            .map((v) => v.score.weightedDeviation)
            .reduce((a, b) => a < b ? a : b);
        expect(
          best(pi),
          lessThanOrEqualTo(best(coherent[id]!) + 1e-9),
          reason: id,
        );
        expect(
          pi.variants.every((v) => v.mode == DesignMode.pureInnovation),
          isTrue,
        );
      }
    });

    test('R3 contraintes dures respectées dans les deux modes', () {
      const excluded = 'ING-DAIRY-LAITENTIER-000001';
      const imposed = 'ING-PLANT-VANILLEGOUSS-000001';
      for (final mode in DesignMode.values) {
        final brief = DesignBrief(
          familyId: 'creme_lactee',
          servings: 6,
          mode: mode,
          imposedIds: const [imposed],
          excludedIds: const [excluded],
          excludedAllergens: const ['nuts'],
          targets: const {
            'energy': DesignTarget.value(200),
            'proteins': DesignTarget.atLeast(5),
          },
        );
        final result = DesignEngine(data).run(brief);
        expect(result.variants, isNotEmpty, reason: mode.name);
        for (final v in result.variants) {
          final ids = v.composition.ids;
          expect(ids, contains(imposed), reason: mode.name);
          expect(ids, isNot(contains(excluded)), reason: mode.name);
          for (final id in ids) {
            expect(
              data[id]!.allergens,
              isNot(contains('nuts')),
              reason: '${mode.name} : $id',
            );
          }
          expect(ids.length, lessThanOrEqualTo(DesignBrief.maxIngredients));
          expect(ids.toSet(), hasLength(ids.length), reason: 'doublon');
          for (final l in v.composition.lines) {
            expect(l.grams, greaterThan(0));
          }
        }
      }
    });

    test('R3 contrainte impossible : message, aucune variante', () {
      final result = DesignEngine(data).run(
        const DesignBrief(
          familyId: 'sauce_froide',
          imposedIds: ['ING-PLANT-PIGNONDEPIN-000001'],
          excludedAllergens: ['nuts'],
        ),
      );
      expect(result.variants, isEmpty);
      expect(result.notices.single, contains('imposé et exclu'));
      final noFamily = DesignEngine(data).run(const DesignBrief());
      expect(noFamily.variants, isEmpty);
      expect(noFamily.notices.single, contains('type de plat'));
    });

    test('R4 honnêteté : critère sans couverture « non vérifiable », '
        'alertes de sécurité affichées dans les deux modes', () {
      // Crème liquide : fibres non renseignées → critère non vérifiable
      // (aucun zéro supposé), pénalisé comme un écart.
      final panna = measured['panna-cotta']!;
      expect(
        panna.analysis.nutrition.nutrientCoverage[MacroField.fiber]!,
        lessThan(0.8),
      );
      final ev = DesignEvaluator(data, servings: 6);
      final creamy = ev.evaluate(
        DesignComposition(
          skeleton: data.catalog.skeleton('creme_gelifiee')!,
          lines: const [
            DesignLine(
              ingredientId: 'ING-DAIRY-CRMELIQUIDEE-000001',
              role: 'base_lactee',
              grams: 100,
            ),
            DesignLine(
              ingredientId: 'ING-TECH-SUCREBLANC-000001',
              role: 'sucrant',
              grams: 10,
            ),
          ],
        ),
      );
      expect(creamy['fiber']!.verifiable, isFalse);
      final fiber = DesignScoring.criterion(
        DesignMetrics.fiber,
        const DesignTarget.atLeast(1),
        creamy['fiber'],
      );
      expect(fiber.status, CriterionStatus.unverifiable);
      expect(fiber.term, DesignScoring.unverifiableTerm);
      // Mayonnaise : œuf cru signalé, en cohérent comme en Pure Innovation.
      for (final mode in DesignMode.values) {
        final r = DesignEngine(data)
            .run(briefs['mayonnaise']!.copyWith(mode: mode));
        final egg = r.variants.where(
          (v) =>
              v.evaluation.measure.physchem.hasTag('egg') ||
              v.composition.ids.any((id) => data[id]!.tags.contains('egg')),
        );
        for (final v in egg) {
          expect(
            v.evaluation.insights.any((i) => i.warning),
            isTrue,
            reason: '${mode.name} : œuf cru non signalé',
          );
        }
      }
    });

    test('R4 accords prédits distingués des accords documentés', () {
      for (final r in coherent.values) {
        for (final v in r.variants) {
          final flavor = v.evaluation.flavor!;
          expect(
            flavor.supportedPairCount,
            v.evaluation.measure.supportedPairs,
          );
          expect(
            flavor.pairs.values.where((m) => m.isPrediction).length +
                flavor.supportedPairCount,
            flavor.pairs.length,
          );
        }
      }
    });

    test('R5 déterminisme : même demande, mêmes variantes', () {
      for (final id in ['pesto', 'confiture-fraise']) {
        final again = DesignEngine(data).run(briefs[id]!);
        String sig(DesignResult r) => [
          for (final v in r.variants)
            v.ingredients
                .map((i) => '${i.ingredientId}=${i.quantity}')
                .join(','),
        ].join(' | ');
        expect(sig(again), sig(coherent[id]!), reason: id);
      }
    });

    test('R5 diversité : deux variantes partagent au plus 60 % de leurs '
        'ingrédients', () {
      for (final r in coherent.values) {
        for (var i = 0; i < r.variants.length; i++) {
          for (var j = i + 1; j < r.variants.length; j++) {
            expect(
              DesignEngine.overlap(
                r.variants[i].composition.ids,
                r.variants[j].composition.ids,
              ),
              lessThanOrEqualTo(DesignEngine.maxOverlap + 1e-9),
            );
          }
        }
        expect(r.variants, hasLength(3));
      }
    });

    test('R6 budget : évaluations bornées, résolution rapide', () {
      final sw = Stopwatch()..start();
      final r = DesignEngine(data).run(briefs['ratatouille']!);
      sw.stop();
      expect(
        r.evaluations,
        lessThanOrEqualTo(const DesignBudget().maxEvaluations),
      );
      // Build release sur la machine PO : mesuré par
      // tool/bench_design.dart ; ici (JIT, tests) borne large.
      expect(sw.elapsedMilliseconds, lessThan(20000));
    });
  });

  group('fidélité à l\'analyse de l\'éditeur', () {
    test('évaluation rapide = évaluation complète (compositions retenues)', () {
      for (final r in coherent.values) {
        final ev = DesignEvaluator(data, servings: r.brief.servings);
        for (final v in r.variants) {
          final fast = ev.evaluate(v.composition);
          final full = v.evaluation.measure;
          for (final m in DesignMetrics.all) {
            final a = fast[m.id]!;
            final b = full[m.id]!;
            expect(a.verifiable, b.verifiable, reason: m.id);
            expect(a.choice, b.choice, reason: m.id);
            if (a.value == null || b.value == null) {
              expect(a.value, b.value, reason: m.id);
            } else {
              expect(
                a.value!,
                closeTo(b.value!, 1e-6 * (1 + b.value!.abs())),
                reason: '${v.title} ${m.id}',
              );
            }
          }
        }
      }
    });

    test(
      'la variante ouverte dans l\'éditeur s\'analyse à l\'identique',
      () async {
        for (final r in coherent.values) {
          final v = r.best!;
          final recipe = v.toRecipe(
            id: 'draft',
            brief: r.brief,
            servings: r.brief.servings,
          );
          final a = await service.analyze(
            ingredients: recipe.ingredients,
            steps: recipe.steps,
            servings: recipe.servings,
            withSuggestions: false,
          );
          final mine = v.evaluation;
          expect(
            a.nutrition.profilePerServing.energyKcal,
            closeTo(mine.nutrition.profilePerServing.energyKcal, 1e-9),
          );
          expect(
            a.physchem.dryMatterPct,
            closeTo(mine.measure.physchem.dryMatterPct, 1e-9),
          );
          expect(a.physchem.ph, mine.measure.physchem.ph);
          expect(a.flavor?.harmony, closeTo(mine.flavor!.harmony, 1e-9));
          expect(
            a.alerts.map((x) => x.alertId).toList(),
            mine.alerts.map((x) => x.alertId).toList(),
          );
          expect(recipe.designBrief, r.brief);
          expect(recipe.nutritionMode, RecipeNutritionMode.computed);
          expect(
            a.alerts
                .where((x) => x.severity == FunctionalSeverity.danger)
                .length,
            mine.alerts
                .where((x) => x.severity == FunctionalSeverity.danger)
                .length,
          );
        }
      },
    );
  });
}
