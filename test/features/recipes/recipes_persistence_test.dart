// Phase 10 Lot I (ac-125, critère A8) — persistance réelle des recettes.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';
import 'package:maestropesto/features/recipes/data/recipes_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

Future<void> _ingredient(AppDatabase db, String id) => db
    .into(db.ingredients)
    .insert(
      IngredientsCompanion.insert(
        ingredientId: id,
        canonicalNameFr: id,
        categoryLevel1: 'végétal',
      ),
    );

Recipe _recipe() => const Recipe(
  id: 'r1',
  title: 'Soupe',
  description: '',
  tags: ['plat'],
  servings: 4,
  prepMinutes: 5,
  cookMinutes: 20,
  ingredients: [
    RecipeIngredient(
      label: 'Carotte',
      quantity: '60 g',
      source: IngredientSource.ciqual,
      ingredientId: 'ING-A',
      cookingMethod: 'boiled',
    ),
    RecipeIngredient(
      label: 'Huile',
      quantity: '2 c. à soupe',
      source: IngredientSource.ciqual,
      ingredientId: 'ING-B',
    ),
    RecipeIngredient(
      label: 'Inconnu',
      quantity: '1 pincée',
      source: IngredientSource.ciqual,
      ingredientId: 'ING-ABSENT',
    ),
  ],
  steps: ['Cuire 20 min à 90 °C.'],
  nutrition: NutritionSummary(
    energyKcal: 120,
    proteins: 2,
    carbs: 10,
    fats: 8,
    fiber: 3,
    salt: 0.5,
  ),
  nutritionMode: RecipeNutritionMode.manual,
  images: [],
);

void main() {
  late AppDatabase db;
  late RecipesRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = RecipesRepository(db);
    await _ingredient(db, 'ING-A');
    await _ingredient(db, 'ING-B');
  });

  tearDown(() => db.close());

  test('A8 : quantités, cuisson, étapes typées et nutrition relues', () async {
    await repo.save(_recipe());
    final r = (await repo.getById('r1'))!;
    expect(r.ingredients[0].quantity, '60 g', reason: '60 g reste 60 g');
    expect(r.ingredients[1].quantity, '2 c. à soupe');
    expect(r.ingredients[0].cookingMethod, 'boiled');
    expect(r.nutritionMode, RecipeNutritionMode.manual);
    expect(r.nutrition.energyKcal, 120);
    expect(r.nutrition.salt, 0.5);

    final items = await db.select(db.recipeItems).get();
    final carotte = items.firstWhere((i) => i.label == 'Carotte');
    expect(carotte.quantityG, 60);
    final huile = items.firstWhere((i) => i.label == 'Huile');
    expect(huile.quantityG, 30, reason: '2 × 15 ml, densité 1 par défaut');

    final step = (await db.select(db.recipeSteps).get()).single;
    expect(step.opId, 'PROC_CUIRE');
    expect(step.temperatureC, 90);
    expect(step.durationMin, 20);
  });

  test(
    'identifiant absent du référentiel : ligne conservée sans lien',
    () async {
      await repo.save(_recipe());
      final r = (await repo.getById('r1'))!;
      final unknown = r.ingredients.firstWhere((i) => i.label == 'Inconnu');
      expect(unknown.ingredientId, isNull);
      expect(unknown.quantity, '1 pincée');
    },
  );

  test('horodatage : création conservée, modification mise à jour', () async {
    await repo.save(_recipe());
    final first = await db.select(db.recipes).getSingle();
    await Future<void>.delayed(const Duration(milliseconds: 5));
    await repo.save(_recipe().copyWith(title: 'Soupe 2'));
    final second = await db.select(db.recipes).getSingle();
    expect(second.createdAt, first.createdAt);
    expect(second.updatedAt.compareTo(first.updatedAt), greaterThan(0));
  });

  test('démos semées une seule fois (un classeur vidé reste vide)', () async {
    // Référentiel des démos : les lignes restent sans lien si absentes.
    expect(await repo.seedDemoRecipesOnce(demoRecipes), isTrue);
    expect(await repo.listAll(), hasLength(demoRecipes.length));
    for (final r in await repo.listAll()) {
      await repo.delete(r.id);
    }
    expect(await repo.seedDemoRecipesOnce(demoRecipes), isFalse);
    expect(await repo.listAll(), isEmpty);
  });
}
