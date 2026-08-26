// Phase 09 — tests du formulaire de recette (retour PO 2026-08-26) :
// warning live qui NOMME les ingrédients incompatibles, et quantité
// « nombre + unité g/ml ».
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/features/flavor/data/flavor_repository.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';
import 'package:maestropesto/features/recipes/presentation/widgets/recipe_form_dialog.dart';

const _abricot = 'ING-PLANT-ABRICOT-000001';
const _aneth = 'ING-PLANT-ANETH-000001';

Recipe _linkedRecipe() => Recipe(
  id: 'r1',
  title: 'Test',
  description: '',
  tags: const [],
  servings: 2,
  prepMinutes: 5,
  cookMinutes: 0,
  ingredients: const [
    RecipeIngredient(
      label: 'Abricot',
      quantity: '100 g',
      source: IngredientSource.ciqual,
      ingredientId: _abricot,
    ),
    RecipeIngredient(
      label: 'Aneth',
      quantity: '10 g',
      source: IngredientSource.ciqual,
      ingredientId: _aneth,
    ),
  ],
  steps: const [],
  nutrition: const NutritionSummary(
    energyKcal: 0,
    proteins: 0,
    carbs: 0,
    fats: 0,
    fiber: 0,
    salt: 0,
  ),
  images: const [],
);

Future<AppDatabase> _seededDb() async {
  final db = AppDatabase(NativeDatabase.memory());
  for (final id in [_abricot, _aneth]) {
    await db
        .into(db.ingredients)
        .insert(
          IngredientsCompanion.insert(
            ingredientId: id,
            canonicalNameFr: id == _abricot ? 'Abricot crue' : 'Aneth',
            categoryLevel1: 'végétal',
          ),
        );
  }
  await db
      .into(db.flavorCompatibility)
      .insert(
        FlavorCompatibilityCompanion.insert(
          recordId: 'REC-1',
          combinationSize: const Value(2),
          ingredientIds: const Value('$_abricot|$_aneth'),
          overallScore: const Value(0.03),
        ),
      );
  return db;
}

Future<void> openForm(
  WidgetTester tester,
  AppDatabase db, {
  Future<Recipe?>? Function(BuildContext)? opener,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => opener?.call(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  // Le formulaire est un ListView lazy : sur le viewport par défaut
  // (800×600) la section ingrédients et le warning sont hors écran et
  // jamais instanciés. Surface haute pour les tests.
  void bigSurface(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('ouverture d\'une recette incompatible : le warning nomme '
      'les deux ingrédients et le score', (tester) async {
    bigSurface(tester);
    final db = await _seededDb();
    addTearDown(db.close);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: RecipeFormDialog(
            recipe: _linkedRecipe(),
            title: 'Éditer',
            db: db,
            flavorRepository: FlavorRepository(db),
            functionalRepository: FunctionalRepository(db),
          ),
        ),
      ),
    );
    // initState déclenche une chaîne async (cache Drift → setState) :
    // plusieurs pumps pour laisser les microtasks se dérouler.
    await tester.pump();
    await tester.pump();
    await tester.pump();
    await tester.pumpAndSettle();

    // Le banner vit dans le cacheExtent du ListView (sous le pli) :
    // skipOffstage:false pour le trouver.
    expect(
      find.textContaining('Abricot × Aneth (0.03)', skipOffstage: false),
      findsOneWidget,
      reason: 'le warning cite la paire incompatible avec son score',
    );
    expect(
      find.textContaining('Incompatibilités aromatiques', skipOffstage: false),
      findsOneWidget,
    );
  });

  testWidgets('quantité numérique + unité ml : sauvegarde « 150 ml »', (
    tester,
  ) async {
    bigSurface(tester);
    final db = await _seededDb();
    addTearDown(db.close);

    Recipe? saved;
    await openForm(
      tester,
      db,
      opener: (context) => showRecipeFormDialog(
        context: context,
        title: 'Éditer',
        recipe: _linkedRecipe(),
        db: db,
      ).then((r) => saved = r),
    );

    // Champ quantité du premier ingrédient : « 100 » → « 150 ».
    // Un champ rempli n'expose pas de widget Text : find.text matche
    // aussi l'EditableText sous-jacent.
    expect(find.text('100'), findsOneWidget);
    await tester.enterText(find.text('100'), '150');

    // Unité : ouvrir le dropdown d'unité du premier ingrédient (le
    // premier DropdownButtonFormField du formulaire) et choisir « ml ».
    final unitDropdown = find
        .byWidgetPredicate((w) => w is DropdownButtonFormField<String>)
        .first;
    await tester.tap(unitDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('ml').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Enregistrer'));
    await tester.pumpAndSettle();

    expect(saved, isNotNull);
    expect(
      saved!.ingredients.first.quantity,
      '150 ml',
      reason: 'nombre + unité concaténés à la sauvegarde',
    );
  });
}
