import 'dart:io';

// Phase 09 — smoke tests DoD §13.3 / §13.4 sur les données métier RÉELLES
// (database-metier/, import CSV complet en mémoire).
//
// Le plan §19/§20 utilise des exemples illustratifs (Bœuf/Bleu) qui
// n'existent pas tels quels dans le référentiel réel : on vérifie donc
// les invariants DoD avec des ingrédients réels :
// - §13.3 : nutrition calculée depuis la DB + combinaison aromatique
//   scorée pour une recette à ≥2 ingrédients liés ;
// - §13.4 : une incompatibilité réelle (< 0.40) est détectée et le
//   Recommender propose des substituts cohérents de la même catégorie.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/nutrition/data/nutrition_repository.dart';
import 'package:maestropesto/features/recommendations/data/recommender.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    // Root « assets/ » : les CSV métier réels ET le CSV d'enrichissement
    // Ciqual (assets/database-enrichment/) sont lus en fichiers.
    final report = await CsvImportService(
      db,
      databaseMetierRoot: 'assets/database-metier',
    ).importAll();
    expect(
      report.rowsImported['phase1'],
      greaterThan(500),
      reason: 'le référentiel réel compte 603 ingrédients',
    );
    expect(
      report.rowsImported['phase3'],
      greaterThan(4000),
      reason: 'la base flavour réelle compte ~4 562 paires',
    );
    expect(
      report.rowsImported['enrichment'],
      greaterThan(1000),
      reason:
          'l\'enrichissement Ciqual apporte ~1 500 records sourcés '
          '(retour PO 2026-08-26)',
    );
  });

  tearDownAll(() async {
    await db.close();
  });

  group('Enrichissement Ciqual (retour PO 2026-08-26)', () {
    test(
      'un ingrédient non couvert par la Phase 2 est enrichi et sourcé',
      () async {
        // La girolle n'a AUCUN record Phase 2 : elle n'est couverte que
        // par l'enrichissement Ciqual (résolu par nom vers « Champignon,
        // chanterelle ou girolle, crue », Ciqual 20103).
        const girolle = 'ING-FUNGUS-GIROLLE-000001';
        final profile = await NutritionRepository(db).forIngredient(girolle);
        expect(profile, isNotNull);
        expect(
          profile!.energyKcal,
          closeTo(24.7, 0.5),
          reason:
              '« Champignon, chanterelle ou girolle, crue » = '
              '24,7 kcal/100 g (Ciqual 2025-11-03)',
        );
        expect(profile.recordCount, greaterThan(5));

        final aggregation = await NutritionRepository(db).aggregateForRecipe(
          ingredients: const [
            RecipeIngredient(
              label: 'Girolle',
              quantity: '200 g',
              source: IngredientSource.ciqual,
              ingredientId: girolle,
            ),
          ],
          servings: 2,
        );
        expect(aggregation.hasData, isTrue);
        expect(
          aggregation.profilePerServing.energyKcal,
          closeTo(24.7, 0.5),
          reason: '200 g ÷ 2 portions = 100 g → 24,7 kcal/portion',
        );
        expect(aggregation.sources, isNotEmpty);
        expect(
          aggregation.sources.map((s) => s.displayLabel),
          contains('ANSES Ciqual 2025-11-03'),
          reason: 'la source est citée in-app',
        );
        final citation = aggregation.sources
            .firstWhere((s) => s.id == 'ciqual_2025_11_03')
            .citation;
        expect(citation, contains('ANSES Ciqual'));

        // Retour PO n°3 (exhaustivité) : minéraux et vitamines par
        // portion. Girolle : fer 3,47 mg/100 g — 200 g ÷ 2 portions =
        // 3,47 mg/portion.
        final micros = aggregation.profilePerServing.micronutrients;
        expect(
          micros,
          isNotEmpty,
          reason: 'l\'enrichissement exhaustif apporte les micros',
        );
        expect(micros['FE']!.value, closeTo(3.47, 0.05));
        expect(micros['FE']!.unit, 'mg');
        expect(micros['CA']!.value, closeTo(15, 0.5));
        expect(
          micros.keys,
          anyElement(contains('VIT')),
          reason: 'au moins une vitamine canonisée est présente',
        );
      },
    );
  });

  group('Phase 10 Lot A — justesse nutrition sur données réelles', () {
    const camembert = 'ING-DAIRY-CAMEMBERT-000001';

    test('A1 : Camembert expose protéines/glucides > 0 cohérents', () async {
      final p = await NutritionRepository(db).forIngredient(camembert);
      expect(p, isNotNull);
      expect(p!.energyKcal, closeTo(275, 1));
      expect(p.proteins, closeTo(18.8, 0.01), reason: 'PROCNT Ciqual');
      expect(p.carbs, closeTo(1.29, 0.01), reason: 'CHOAVL Ciqual');
      expect(p.saturatedFats, closeTo(12.6, 0.01), reason: 'FASAT Ciqual');
      expect(p.fats, closeTo(21.5, 0.01));
      // Cohérence énergie ↔ macros (Atwater UE : P4 G4 L9 fibres 2).
      final atwater = p.proteins * 4 + p.carbs * 4 + p.fats * 9;
      expect((atwater - p.energyKcal).abs() / p.energyKcal, lessThan(0.05));
      // Sucres absents de la source : « non renseigné », pas un zéro.
      expect(p.isKnown(MacroField.sugars), isFalse);
      expect(p.isKnown(MacroField.proteins), isTrue);
      expect(p.sourceFoodName, contains('Camembert'));
    });

    test('A2 : vitamine A = RAE (231 µg), folates = FOLFD + FOLAC', () async {
      final p = (await NutritionRepository(db).forIngredient(camembert))!;
      expect(p.micronutrients['VITA']!.value, closeTo(231, 0.01));
      expect(p.micronutrients['FOLATES']!.value, closeTo(56.8 + 2.3, 0.01));
      expect(p.micronutrients['CAROTENE_B']!.value, closeTo(79, 0.01));
      expect(p.micronutrients['VITA']!.name, contains('Vitamine A'));
      expect(p.confidence, inInclusiveRange(0.5, 0.95));
    });

    test('A1 : aucun ingrédient enrichi n’a protéines=0 avec énergie>200 '
        'sans lipides ni glucides expliquant l’énergie', () async {
      final ids = (await db.select(db.nutritionRecords).get())
          .map((r) => r.ingredientId)
          .toSet();
      final repo = NutritionRepository(db);
      var incoherent = 0;
      for (final id in ids) {
        final p = (await repo.forIngredient(id))!;
        if (p.energyKcal < 50 || p.alcohol > 1) continue;
        if (!p.isKnown(MacroField.proteins) ||
            !p.isKnown(MacroField.carbs) ||
            !p.isKnown(MacroField.fats)) {
          continue;
        }
        final atwater = p.proteins * 4 + p.carbs * 4 + p.fats * 9 + p.fiber * 2;
        if ((atwater - p.energyKcal).abs() / p.energyKcal > 0.25) {
          incoherent++;
        }
      }
      expect(
        incoherent,
        lessThan(ids.length * 0.03),
        reason: 'énergie cohérente avec ses propres macros (ac-120)',
      );
    });
  });

  group('DoD §13.3 — nutrition calculée + associations aromatiques', () {
    const tomate = 'ING-PLANT-TOMATE-000001';
    const basilic = 'ING-PLANT-BASILIC-000001';
    const mozzarella = 'ING-DAIRY-MOZZARELLA-000001';

    test('la nutrition de la recette est calculée depuis la DB', () async {
      final aggregation = await NutritionRepository(db).aggregateForRecipe(
        ingredients: const [
          RecipeIngredient(
            label: 'Tomate',
            quantity: '200 g',
            source: IngredientSource.ciqual,
            ingredientId: tomate,
          ),
          RecipeIngredient(
            label: 'Mozzarella',
            quantity: '125 g',
            source: IngredientSource.ciqual,
            ingredientId: mozzarella,
          ),
        ],
        servings: 2,
      );
      expect(aggregation.hasData, isTrue);
      expect(aggregation.resolvedCount, aggregation.totalCount);
      expect(aggregation.profilePerServing.energyKcal, greaterThan(0));
    });

    test(
      'la combinaison Tomate+Basilic+Mozzarella est scorée (n-aire réel)',
      () async {
        final match = await FlavorRepository(db)
            .bestMatchFor(const [tomate, basilic, mozzarella]);
        expect(
          match,
          isNotNull,
          reason: 'le trio existe en base (enregistrement n-aire 0.90)',
        );
        expect(match!.overallScore, greaterThan(0));
        expect(match.overallScore, lessThanOrEqualTo(1));
      },
    );
  });

  group('DoD §13.4 — incompatibilité détectée + substituts proposés', () {
    // Phase 10 (ac-123) : seule une incompatibilité ÉTAYÉE est une
    // alerte. Chocolat noir × anchois : contraste négatif observé
    // (benchmark Phase 3, 0,20) ; abricot × aneth : prédiction basse
    // sans soutien empirique (plus jamais « À éviter »).
    const chocolat = 'ING-TECH-CHOCOLATNOIR-000001';
    const anchois = 'ING-MARINE-ANCHOIS-000001';
    const abricot = 'ING-PLANT-ABRICOT-000001';
    const aneth = 'ING-PLANT-ANETH-000001';
    const ail = 'ING-PLANT-AIL-000001';

    test('incompatiblePairs détecte une incompatibilité étayée', () async {
      final bad = await FlavorRepository(db)
          .incompatiblePairs([chocolat, anchois, ail]);
      expect(bad, isNotEmpty);
      expect(bad.every((m) => m.overallScore < 0.40), isTrue);
      expect(bad.every((m) => !m.isPrediction), isTrue);
    });

    test('A4 : une prédiction basse n’est pas une incompatibilité', () async {
      final repo = FlavorRepository(db);
      final bad = await repo.incompatiblePairs([abricot, aneth]);
      expect(bad, isEmpty);
      final m = await repo.bestMatchFor([abricot, aneth]);
      expect(m, isNotNull);
      expect(m!.isPrediction, isTrue);
      expect(m.isSupportedIncompatibility, isFalse);
    });

    test('le Recommender propose des substituts réels et cohérents', () async {
      final ingredientsRepo = IngredientsRepository(db);
      final recommender = Recommender(
        ingredients: ingredientsRepo,
        flavor: FlavorRepository(db),
        functional: FunctionalRepository(db),
      );
      final substitutes = await recommender.suggestSubstitutes(
        targetIngredientId: anchois,
        currentIngredientIds: [chocolat, anchois],
        maxResults: 5,
      );
      expect(
        substitutes,
        isNotEmpty,
        reason: 'la catégorie animal réelle a des candidats ≥ 0.7',
      );
      expect(substitutes.length, lessThanOrEqualTo(5));

      // Invariants du cahier §9.1 :
      final ids = substitutes.map((r) => r.suggestedIngredient.ingredientId);
      expect(
        ids,
        isNot(anyOf(contains(chocolat), contains(anchois))),
        reason: 'un substitut ne doit pas déjà être dans la recette',
      );
      final target = await ingredientsRepo.summaryFor(anchois);
      expect(target, isNotNull);
      // NB : la valeur réelle est « végétal » (r-103) — on compare à la
      // catégorie effective de la cible, pas à une chaîne codée en dur.
      final targetCategory = target!.categoryLevel1;
      for (final r in substitutes) {
        expect(
          r.suggestedIngredient.categoryLevel1,
          targetCategory,
          reason: 'même category_level_1 que la cible',
        );
        expect(r.score, greaterThanOrEqualTo(0));
        expect(r.score, lessThanOrEqualTo(1));
      }
      // Tri décroissant par score.
      final scores = substitutes.map((r) => r.score).toList();
      final sorted = List<double>.of(scores)..sort((a, b) => b.compareTo(a));
      expect(scores, orderedEquals(sorted));
    });
  });

  group('Phase 10 Lot E — accords aromatiques', () {
    test('A6 : 603/603 profils sensoriels, toute paire est scorée', () async {
      final repo = FlavorRepository(db);
      final ids = (await db.select(db.ingredients).get())
          .map((r) => r.ingredientId)
          .toList();
      var profiled = 0;
      for (final id in ids) {
        if (await repo.profileFor(id) != null) profiled++;
      }
      expect(profiled, 603);
      // Échantillon déterministe de 25 ingrédients : 300 paires.
      final sample = [for (var i = 0; i < ids.length; i += 24) ids[i]];
      for (var i = 0; i < sample.length; i++) {
        for (var j = i + 1; j < sample.length; j++) {
          final m = await repo.bestMatchFor([sample[i], sample[j]]);
          expect(m, isNotNull);
          expect(m!.overallScore, inInclusiveRange(0, 1));
          expect(m.confidence, isNotNull);
        }
      }
    });

    test('A6 : calibration sur les benchmarks Phase 3', () async {
      final repo = FlavorRepository(db);
      final byName = {
        for (final r in await db.select(db.ingredients).get())
          r.canonicalNameFr: r.ingredientId,
      };
      final lines = File(
        'assets/database-metier/phase3-flavour/flavor_benchmark.csv',
      ).readAsLinesSync().skip(1);
      var checked = 0;
      for (final line in lines) {
        final cells = line.split(',');
        final category = cells[1];
        final names = cells[2].split(' + ');
        final ids = [for (final n in names) byName[n]];
        if (ids.any((id) => id == null)) continue;
        final m = await repo.bestMatchFor(ids.cast<String>());
        expect(m, isNotNull, reason: cells[2]);
        final score = m!.overallScore;
        if (category == 'contrast_negative') {
          expect(score, lessThan(0.40), reason: cells[2]);
        } else if (category == 'classic' || category == 'hyper_interaction') {
          expect(score, greaterThanOrEqualTo(0.70), reason: cells[2]);
        } else {
          expect(score, greaterThanOrEqualTo(0.55), reason: cells[2]);
        }
        checked++;
      }
      expect(checked, greaterThan(25));
    });

    test('analyse de recette et suggestions de complément', () async {
      const tomate = 'ING-PLANT-TOMATE-000001';
      const basilic = 'ING-PLANT-BASILIC-000001';
      const huile = 'ING-TECH-HUILEDOLIVEV-000001';
      final repo = FlavorRepository(db);
      final analysis = await repo.analyze([tomate, basilic, huile]);
      expect(analysis, isNotNull);
      expect(analysis!.pairs, hasLength(3));
      expect(analysis.harmony, greaterThan(0.7));
      expect(analysis.supportedPairCount, greaterThanOrEqualTo(2));
      final suggestions = await repo.suggestComplements([tomate, basilic]);
      expect(suggestions, isNotEmpty);
      expect(
        suggestions.map((s) => s.name),
        anyElement(anyOf('Mozzarella', 'Ail', "Huile d'olive vierge extra")),
      );
    });
  });

  group('Retour PO n°4 — couverture nutrition et tri naturel', () {
    test(
      'la couverture nutrition dépasse 380/603 (enrichissement Ciqual)',
      () async {
        final rows = await db.select(db.nutritionRecords).get();
        final covered = rows.map((r) => r.ingredientId).toSet().length;
        expect(
          covered,
          greaterThan(510),
          reason:
              'Phase 10 : Phase 2 ∪ enrichissement Ciqual avec alias curatés '
              '(518/603 mesurés). Les non-couverts restants (additifs, '
              'sauces asiatiques, préparations) sont absents de Ciqual.',
        );
      },
    );

    test(
      "« Œuf de poule » n'est plus le dernier du registre (tri naturel FR)",
      () async {
        final names = (await IngredientsRepository(
          db,
        ).allSummaries()).map((s) => s.canonicalNameFr).toList();
        expect(names.length, 603, reason: 'la liste « Toutes » est complète');
        final oeuf = names.indexOf('Œuf de poule');
        expect(oeuf, greaterThanOrEqualTo(0));
        final lastZ = names.lastIndexWhere((n) => n.startsWith('Z'));
        expect(
          oeuf < lastZ,
          isTrue,
          reason:
              'le tri codepoint SQL reléguait Œ (U+0152) après Z — le '
              'tri naturel FR place « Œuf » entre « Noix » et « Orange »',
        );
      },
    );
  });

  group('Retour test visuel — nutrition stockée et bilan de masse', () {
    test('démos : nutrition stockée recalculée (kcal > 0)', () async {
      final service = RecipeAnalysisService(db);
      for (final demo in demoRecipes) {
        final updated = await service.refreshStoredNutrition(demo);
        expect(updated, isNotNull, reason: demo.title);
        expect(updated!.nutrition.energyKcal, greaterThan(0));
        // Idempotent : une seconde passe ne change rien.
        expect(await service.refreshStoredNutrition(updated), isNull);
      }
    });

    test('saisie manuelle : jamais écrasée', () async {
      final manual = demoRecipes.first.copyWith(
        nutritionMode: RecipeNutritionMode.manual,
      );
      expect(
        await RecipeAnalysisService(db).refreshStoredNutrition(manual),
        isNull,
      );
    });

    test('sucre blanc : lipides et AGS à 0 par bilan de masse', () async {
      final p = (await NutritionRepository(db)
          .forIngredient('ING-TECH-SUCREBLANC-000001'))!;
      expect(p.isKnown(MacroField.fats), isTrue);
      expect(p.isKnown(MacroField.saturatedFats), isTrue);
      expect(p.derivedFields, contains(MacroField.fats));
      expect(p.fats, 0);
    });
  });
}
