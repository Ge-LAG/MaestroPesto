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
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/nutrition/data/nutrition_repository.dart';
import 'package:maestropesto/features/recommendations/data/recommender.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/ingredients/data/ingredients_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';

void main() {
  late AppDatabase db;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    final report = await CsvImportService(
      db,
      databaseMetierRoot: 'database-metier',
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
  });

  tearDownAll(() async {
    await db.close();
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
    // Paire réelle la plus incompatible des données : 0.03.
    const abricot = 'ING-PLANT-ABRICOT-000001';
    const aneth = 'ING-PLANT-ANETH-000001';
    const ail = 'ING-PLANT-AIL-000001';

    test('incompatiblePairs détecte une paire réelle < 0.40', () async {
      final bad = await FlavorRepository(db)
          .incompatiblePairs([abricot, aneth, ail]);
      expect(bad, isNotEmpty);
      expect(bad.every((m) => m.overallScore < 0.40), isTrue);
    });

    test('le Recommender propose des substituts réels et cohérents', () async {
      final ingredientsRepo = IngredientsRepository(db);
      final recommender = Recommender(
        ingredients: ingredientsRepo,
        flavor: FlavorRepository(db),
        functional: FunctionalRepository(db),
      );
      final substitutes = await recommender.suggestSubstitutes(
        targetIngredientId: ail,
        currentIngredientIds: [abricot, ail],
        maxResults: 5,
      );
      expect(
        substitutes,
        isNotEmpty,
        reason: 'la catégorie végétal réelle a > 100 candidats ≥ 0.7',
      );
      expect(substitutes.length, lessThanOrEqualTo(5));

      // Invariants du cahier §9.1 :
      final ids = substitutes.map((r) => r.suggestedIngredient.ingredientId);
      expect(
        ids,
        isNot(anyOf(contains(abricot), contains(ail))),
        reason: 'un substitut ne doit pas déjà être dans la recette',
      );
      final target = await ingredientsRepo.summaryFor(ail);
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
}
