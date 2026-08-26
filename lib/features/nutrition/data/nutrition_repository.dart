// Phase 09 Lot F — repository Phase 2 nutrition.
//
// Cahier §6.2 :
// - forIngredient(ingredientId, stateId='raw') → Future<NutritionProfile?>
// - aggregateForRecipe(...) : async (résolution) puis calcul pur synchrone
//   via NutritionAggregator (Lot G, dp-105)
//
// Source de vérité : table `nutrition_records` (Lot A schéma Drift).
// Mapping component_id → champ NutritionProfile :
//   - 'energy_kcal' (ou ENERGY_KCAL) → energyKcal
//   - 'proteins' (ou PROTEINS)       → proteins
//   - 'carbs' / 'sugars'             → carbs / sugars
//   - 'fat' / 'saturated_fat'        → fats / saturatedFats
//   - 'fiber'                        → fiber
//   - 'salt' / 'sodium'              → salt (× 2.5 si Na pur)
//   - 'water'                        → waterContent
//
// Si plusieurs records par composant, on moyenne `normalized_value`.

import 'package:drift/drift.dart';
import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/nutrition_profile.dart';
import '../../../core/scoring/nutrition_aggregator.dart';
import '../../recipes/domain/recipe.dart';

/// Repository pour la Phase 2 (nutrition).
///
/// Toutes les méthodes sont tolérantes aux données manquantes :
/// - DB vide → renvoie `null` ou `NutritionProfile.empty`.
/// - Composant absent → 0 dans le profil.
/// - Ingrédient `stateId` non trouvé → fallback sur `raw`.
class NutritionRepository {
  NutritionRepository(this._db);

  final AppDatabase _db;

  /// Renvoie le profil nutritionnel d'un ingrédient pour un état donné.
  ///
  /// Renvoie `null` si l'ingrédient n'existe pas dans la table.
  /// Renvoie `NutritionProfile.empty` si l'ingrédient existe mais n'a
  /// aucun record nutritionnel.
  Future<NutritionProfile?> forIngredient(
    String ingredientId, {
    String stateId = 'raw',
  }) async {
    final records = await _loadRecords(ingredientId, stateId: stateId);
    if (records.isEmpty) {
      // Vérifier que l'ingrédient existe (sinon null)
      final exists = await _ingredientExists(ingredientId);
      return exists ? NutritionProfile.empty : null;
    }
    return _aggregate(records, stateId: stateId);
  }

  /// Lot G (G1) — agrège la nutrition d'une recette entière, par portion.
  ///
  /// Résout les profils de chaque ingrédient lié (`forIngredient`, async),
  /// puis délègue le calcul au [NutritionAggregator] pur et synchrone
  /// (dp-105). Les edge cases (ingrédient libre sans id, sous-recette,
  /// profil manquant) sont gérés par l'agrégateur — voir ses warnings.
  ///
  /// Renvoie un résultat avec `resolvedCount == 0` (fallback gracieux)
  /// si aucun ingrédient n'est résolvable.
  Future<NutritionAggregation> aggregateForRecipe({
    required List<RecipeIngredient> ingredients,
    required int servings,
    String stateId = 'raw',
  }) async {
    // Résolution async en amont : un seul passage par ingrédient lié,
    // avec cache local pour ne pas requêter deux fois le même id.
    final cache = <String, NutritionProfile?>{};
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty || cache.containsKey(id)) continue;
      cache[id] = await forIngredient(id, stateId: stateId);
    }
    return NutritionAggregator.aggregate(
      ingredients: ingredients,
      lookup: (id) => cache[id],
      servings: servings,
    );
  }

  Future<bool> _ingredientExists(String ingredientId) async {
    final query = _db.select(_db.ingredients)
      ..where((t) => t.ingredientId.equals(ingredientId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null;
  }

  Future<List<NutritionRecord>> _loadRecords(
    String ingredientId, {
    required String stateId,
  }) async {
    final query = _db.select(_db.nutritionRecords)
      ..where((t) => t.ingredientId.equals(ingredientId));
    if (stateId != 'raw') {
      query.where((t) => t.ingredientStateId.equals(stateId));
    }
    return query.get();
  }

  /// Agrège les records en un NutritionProfile.
  /// Visible pour tests.
  @visibleForTesting
  static NutritionProfile aggregateRecords(
    List<NutritionRecord> records, {
    String stateId = 'raw',
  }) =>
      _aggregate(records, stateId: stateId);

  static NutritionProfile _aggregate(
    List<NutritionRecord> records, {
    required String stateId,
  }) {
    if (records.isEmpty) return NutritionProfile.empty;

    // Bucket par component_id (lowercased)
    final byComponent = <String, List<double>>{};
    var sampleCount = 0;
    for (final r in records) {
      final cid = (r.componentId ?? '').toLowerCase();
      if (cid.isEmpty) continue;
      final v = r.normalizedValue;
      if (v == null) continue;
      byComponent.putIfAbsent(cid, () => <double>[]).add(v);
      sampleCount++;
    }

    double mean(String cid) {
      final list = byComponent[cid];
      if (list == null || list.isEmpty) return 0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    return NutritionProfile(
      energyKcal: _readEnergy(byComponent),
      proteins: mean('protein') + mean('proteins'),
      carbs: mean('carbohydrate') + mean('carbs') + mean('carbohydrates'),
      sugars: mean('sugars') + mean('sugar'),
      fats: mean('fat') + mean('fats') + mean('lipid') + mean('lipids'),
      saturatedFats: mean('saturated_fat') + mean('saturated_fats'),
      fiber: mean('fiber') + mean('fibres') + mean('dietary_fiber'),
      salt: mean('salt'),
      waterContent: byComponent.containsKey('water')
          ? mean('water')
          : null,
      ingredientStateId: stateId,
      confidence: 0.8, // Lot F v1 simplifiée
      recordCount: sampleCount,
    );
  }

  /// L'énergie peut être stockée en kJ ou kcal — on normalise.
  static double _readEnergy(Map<String, List<double>> byComponent) {
    final kcalList = byComponent['energy_kcal'] ?? byComponent['energy'];
    if (kcalList != null && kcalList.isNotEmpty) {
      return kcalList.reduce((a, b) => a + b) / kcalList.length;
    }
    final kjList = byComponent['energy_kj'] ?? byComponent['kj'];
    if (kjList != null && kjList.isNotEmpty) {
      final kjMean = kjList.reduce((a, b) => a + b) / kjList.length;
      return kjMean / 4.184; // kJ → kcal
    }
    return 0;
  }
}

/// Helper de test : permet de mocker les records sans Drift.
/// Visible uniquement pour tests (R-07 : non exécutable en sandbox).
@visibleForTesting
class FakeNutritionRecord {
  FakeNutritionRecord({this.componentId, this.normalizedValue});
  final String? componentId;
  final double? normalizedValue;
}
