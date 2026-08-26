// Phase 09 — tests du mapping component_id → NutritionProfile (Lot F).
//
// Le dictionnaire Phase 2 réel (`component_dictionary.csv`) utilise des
// tags Ciqual/INFOODS (ENERCKCAL, PROTEIN, FAT, CARB, FIBER, NA…) :
// ces tests verrouillent le mapping indépendamment des CSV réels.
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/nutrition_profile.dart';
import 'package:maestropesto/features/nutrition/data/nutrition_repository.dart';

void main() {
  late AppDatabase db;
  late NutritionRepository repo;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repo = NutritionRepository(db);
    // `nutrition_records` référence `ingredients` (FK) : créer les
    // parents du référentiel Phase 1 utilisés par les tests.
    for (final id in ['ING-A', 'ING-B', 'ING-C']) {
      await db
          .into(db.ingredients)
          .insert(
            IngredientsCompanion.insert(
              ingredientId: id,
              canonicalNameFr: 'Ingrédient $id',
              categoryLevel1: 'végétal',
            ),
          );
    }
  });

  tearDown(() async {
    await db.close();
  });

  Future<void> insertRecord(
    String ingredientId,
    String componentId,
    double value, {
    String stateId = 'raw',
  }) => db
      .into(db.nutritionRecords)
      .insert(
        NutritionRecordsCompanion.insert(
          nutritionRecordId: '${ingredientId}_$componentId',
          ingredientId: ingredientId,
          ingredientStateId: Value(stateId),
          componentId: Value(componentId),
          normalizedValue: Value(value),
        ),
      );

  test(
    'mappe les tags Ciqual réels (ENERCKCAL, PROTEIN, FAT, CARB…)',
    () async {
      await insertRecord('ING-A', 'ENERCKCAL', 250);
      await insertRecord('ING-A', 'PROTEIN', 18);
      await insertRecord('ING-A', 'FAT', 19);
      await insertRecord('ING-A', 'CARB', 3);
      await insertRecord('ING-A', 'SUGAR', 1);
      await insertRecord('ING-A', 'FAT_SAT', 13);
      await insertRecord('ING-A', 'FIBER', 0);
      await insertRecord('ING-A', 'WATER', 50);

      final p = await repo.forIngredient('ING-A');
      expect(p, isNotNull);
      expect(p!.energyKcal, 250);
      expect(p.proteins, 18);
      expect(p.fats, 19);
      expect(p.carbs, 3);
      expect(p.sugars, 1);
      expect(p.saturatedFats, 13);
      expect(p.fiber, 0);
      expect(p.waterContent, 50);
    },
  );

  test('NA (mg) est converti en sel (g) : sel = Na × 2.5 / 1000', () async {
    await insertRecord('ING-A', 'NA', 380); // 380 mg Na / 100 g
    final p = await repo.forIngredient('ING-A');
    expect(p!.salt, closeTo(0.95, 1e-9)); // 380 × 2.5 / 1000
  });

  test('salt direct (g) prime sur NA', () async {
    await insertRecord('ING-A', 'salt', 1.2);
    await insertRecord('ING-A', 'NA', 380);
    final p = await repo.forIngredient('ING-A');
    expect(p!.salt, 1.2);
  });

  test('ENERC (kJ) est converti en kcal', () async {
    await insertRecord('ING-A', 'ENERC', 418.4); // = 100 kcal
    final p = await repo.forIngredient('ING-A');
    expect(p!.energyKcal, closeTo(100, 1e-9));
  });

  test(
    'les alias génériques restent supportés (energy_kcal, proteins…)',
    () async {
      await insertRecord('ING-B', 'energy_kcal', 120);
      await insertRecord('ING-B', 'proteins', 4);
      await insertRecord('ING-B', 'carbohydrate', 5);
      final p = await repo.forIngredient('ING-B');
      expect(p!.energyKcal, 120);
      expect(p.proteins, 4);
      expect(p.carbs, 5);
    },
  );

  test('plusieurs records du même composant sont moyennés', () async {
    await insertRecord('ING-C', 'ENERCKCAL', 100, stateId: 'raw');
    // Un second record du même composant (autre id) : moyenne.
    await db
        .into(db.nutritionRecords)
        .insert(
          NutritionRecordsCompanion.insert(
            nutritionRecordId: 'ING_C_bis',
            ingredientId: 'ING-C',
            ingredientStateId: const Value('raw'),
            componentId: const Value('ENERCKCAL'),
            normalizedValue: const Value(200),
          ),
        );
    final p = await repo.forIngredient('ING-C');
    expect(p!.energyKcal, 150);
  });

  test('ingrédient sans records → empty ; inconnu → null', () async {
    await db
        .into(db.ingredients)
        .insert(
          IngredientsCompanion.insert(
            ingredientId: 'ING-D',
            canonicalNameFr: 'Ail',
            categoryLevel1: 'végétal',
          ),
        );
    expect(await repo.forIngredient('ING-D'), isNotNull);
    expect(
      (await repo.forIngredient('ING-D'))!.energyKcal,
      NutritionProfile.empty.energyKcal,
    );
    expect(await repo.forIngredient('ING-UNKNOWN'), isNull);
  });
}
