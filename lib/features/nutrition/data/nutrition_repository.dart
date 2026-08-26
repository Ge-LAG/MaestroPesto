// Phase 09 Lot F — repository Phase 2 nutrition.
//
// Cahier §6.2 :
// - forIngredient(ingredientId, stateId='raw') → Future<NutritionProfile?>
// - aggregateForRecipe(...) : async (résolution) puis calcul pur synchrone
//   via NutritionAggregator (Lot G, dp-105)
//
// Source de vérité : table `nutrition_records` (Lot A schéma Drift).
// Mapping component_id → champ NutritionProfile — les tags réels du
// dictionnaire Phase 2 (`component_dictionary.csv`, style Ciqual) sont
// en premier, les alias génériques en secours :
//   - ENERCKCAL / energy_kcal / energy → energyKcal (kcal)
//   - ENERC / energy_kj / kj           → energyKcal (÷ 4.184)
//   - PROTEIN / protein                → proteins
//   - CARB / carbohydrate / carbs      → carbs
//   - SUGAR / sugar                    → sugars
//   - FAT / fat / lipid                → fats
//   - FAT_SAT / saturated_fat          → saturatedFats
//   - FIBER / fiber / fibres           → fiber
//   - NA / sodium (mg) ou salt (g)     → salt (sel = Na × 2.5, §5.3)
//   - WATER / water                    → waterContent
//
// Si plusieurs records par composant, on moyenne `normalized_value`.

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
  /// Les sources des records consommés sont collectées pour être citées
  /// in-app (retour PO 2026-08-26).
  Future<NutritionAggregation> aggregateForRecipe({
    required List<RecipeIngredient> ingredients,
    required int servings,
    String stateId = 'raw',
  }) async {
    // Résolution async en amont : un seul passage par ingrédient lié,
    // avec cache local pour ne pas requêter deux fois le même id.
    final cache = <String, NutritionProfile?>{};
    final sources = <String, NutritionSource>{};
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty || cache.containsKey(id)) continue;
      final records = await _loadRecords(id, stateId: stateId);
      for (final r in records) {
        final sid = r.sourceId;
        if (sid == null || sid.isEmpty) continue;
        sources.putIfAbsent(
          sid,
          () => NutritionSource(
            id: sid,
            label: sourceLabel(sid),
            citation: r.notes,
          ),
        );
      }
      if (records.isEmpty) {
        cache[id] = (await _ingredientExists(id))
            ? NutritionProfile.empty
            : null;
      } else {
        cache[id] = _aggregate(records, stateId: stateId);
      }
    }
    final aggregation = NutritionAggregator.aggregate(
      ingredients: ingredients,
      lookup: (id) => cache[id],
      servings: servings,
    );
    if (sources.isEmpty) return aggregation;
    final sorted = sources.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return NutritionAggregation(
      profilePerServing: aggregation.profilePerServing,
      resolvedCount: aggregation.resolvedCount,
      totalCount: aggregation.totalCount,
      warnings: aggregation.warnings,
      sources: sorted,
    );
  }

  /// Libellé lisible d'un `source_id` (null → id brut affiché).
  @visibleForTesting
  static String? sourceLabel(String sourceId) {
    final lower = sourceId.toLowerCase();
    if (lower.startsWith('ciqual_2025')) return 'ANSES Ciqual 2025-11-03';
    if (lower.contains('ciqual')) return 'ANSES Ciqual';
    if (lower.contains('usda')) return 'USDA FoodData Central';
    return null;
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
  }) => _aggregate(records, stateId: stateId);

  static NutritionProfile _aggregate(
    List<NutritionRecord> records, {
    required String stateId,
  }) {
    if (records.isEmpty) return NutritionProfile.empty;

    // Bucket par component_id (lowercased)
    final byComponent = <String, List<double>>{};
    // Micronutriments (retour PO n°3) : tag canonique → valeurs + le
    // libellé/unité d'un record source.
    final microValues = <String, List<double>>{};
    final microMeta = <String, (String name, String unit)>{};
    var sampleCount = 0;
    for (final r in records) {
      final cid = (r.componentId ?? '').toLowerCase();
      if (cid.isEmpty) continue;
      final v = r.normalizedValue;
      if (v == null) continue;
      byComponent.putIfAbsent(cid, () => <double>[]).add(v);
      sampleCount++;
      // Tout composant ni macro ni alcool devient un micronutriment.
      final canonical = canonicalMicroTag(cid);
      if (canonical != null && !_macroTags.contains(cid)) {
        microValues.putIfAbsent(canonical, () => <double>[]).add(v);
        microMeta.putIfAbsent(
          canonical,
          () => (
            _cleanComponentName(r.componentName ?? canonical),
            r.normalizedUnit ?? _unitForMicro(canonical),
          ),
        );
      }
    }

    double mean(String cid) {
      final list = byComponent[cid];
      if (list == null || list.isEmpty) return 0;
      return list.reduce((a, b) => a + b) / list.length;
    }

    // Moyenne de la première clé présente (les alias sont des
    // alternatives, jamais cumulées : un dataset n'utilise qu'un tag
    // par composant).
    double meanOf(List<String> aliases) {
      for (final cid in aliases) {
        final list = byComponent[cid];
        if (list != null && list.isNotEmpty) {
          return list.reduce((a, b) => a + b) / list.length;
        }
      }
      return 0;
    }

    final water = mean('water');
    final micros = <String, Micronutrient>{
      for (final e in microValues.entries)
        e.key: Micronutrient(
          tag: e.key,
          name: microMeta[e.key]?.$1 ?? e.key,
          value: e.value.reduce((a, b) => a + b) / e.value.length,
          unit: microMeta[e.key]?.$2 ?? 'mg',
        ),
    }..removeWhere((_, m) => m.value <= 0);

    return NutritionProfile(
      energyKcal: _readEnergy(byComponent),
      proteins: meanOf(const ['protein', 'proteins']),
      carbs: meanOf(const ['carb', 'carbohydrate', 'carbs', 'carbohydrates']),
      sugars: meanOf(const ['sugar', 'sugars']),
      fats: meanOf(const ['fat', 'fats', 'lipid', 'lipids']),
      saturatedFats: meanOf(const [
        'fat_sat',
        'saturated_fat',
        'saturated_fats',
      ]),
      fiber: meanOf(const ['fiber', 'fibre', 'fibres', 'dietary_fiber']),
      salt: _readSalt(byComponent, meanOf),
      alcohol: meanOf(const ['alc', 'alcohol', 'ethanol']),
      waterContent: water > 0 ? water : null,
      micronutrients: micros,
      ingredientStateId: stateId,
      confidence: 0.8, // Lot F v1 simplifiée
      recordCount: sampleCount,
    );
  }

  /// L'énergie peut être stockée en kJ ou kcal — on normalise.
  static double _readEnergy(Map<String, List<double>> byComponent) {
    for (final cid in const ['enerckcal', 'energy_kcal', 'energy']) {
      final list = byComponent[cid];
      if (list != null && list.isNotEmpty) {
        return list.reduce((a, b) => a + b) / list.length;
      }
    }
    for (final cid in const ['enerc', 'energy_kj', 'kj']) {
      final list = byComponent[cid];
      if (list != null && list.isNotEmpty) {
        final kjMean = list.reduce((a, b) => a + b) / list.length;
        return kjMean / 4.184; // kJ → kcal
      }
    }
    return 0;
  }

  /// Sel : soit un record `salt` direct (g), soit le sodium NA (mg)
  /// converti — sel (g) = Na (mg) × 2.5 / 1000 (§5.3 : sel = Na × 2.5).
  static double _readSalt(
    Map<String, List<double>> byComponent,
    double Function(List<String>) meanOf,
  ) {
    final direct = meanOf(const ['salt']);
    if (direct > 0) return direct;
    final naMg = meanOf(const ['na', 'sodium']);
    return naMg * 2.5 / 1000;
  }

  /// Tags des macronutriments (champs nommés du NutritionProfile) —
  /// exclus des micronutriments.
  static const Set<String> _macroTags = {
    'enerckcal',
    'energy_kcal',
    'energy',
    'enerc',
    'energy_kj',
    'kj',
    'protein',
    'proteins',
    'fat',
    'fats',
    'lipid',
    'lipids',
    'fat_sat',
    'saturated_fat',
    'saturated_fats',
    'carb',
    'carbohydrate',
    'carbs',
    'carbohydrates',
    'sugar',
    'sugars',
    'fiber',
    'fibre',
    'fibres',
    'dietary_fiber',
    'salt',
    'na',
    'sodium',
    'water',
    'alc',
    'alcohol',
    'ethanol',
  };

  /// Canonicalise un tag de micronutriment entre les deux familles de
  /// sources : dictionnaire Phase 2 (VITA, THIAMIN, VITB6, FOL, VITD,
  /// VITE, VITK…) et Ciqual 2025-11-03 (RETOL, RAE, THIA, VITB6-,
  /// FOL*, TOCPHA, VITD-, VITK1/2…). Retourne null pour les tags
  /// inconnus à ignorer.
  @visibleForTesting
  static String? canonicalMicroTag(String rawTag) {
    final t = rawTag.toLowerCase();
    return switch (t) {
      'thia' || 'thiamin' => 'THIAMIN',
      'ribf' || 'ribfl' => 'RIBOFLAVINE',
      'nia' => 'NIACINE',
      'pant' || 'pantac' => 'VITB5',
      'vitb6-' || 'vitb6' => 'VITB6',
      'vitb12' => 'VITB12',
      'fol' || 'folac' || 'foldfe' || 'folfd' => 'FOLATES',
      'vitc' => 'VITC',
      'retol' || 'rae' || 'vita' || 'retinol' => 'VITA',
      'cartb' || 'carotene_b' => 'CAROTENE_B',
      'vitd-' || 'vitd' || 'ergcal' => 'VITD',
      'tocpha' || 'vite' || 'vite-' => 'VITE',
      'vitk1' || 'vitk2' || 'vitk' => 'VITK',
      'biot' => 'BIOTINE',
      'choline' => 'CHOLINE',
      'k' => 'K',
      'ca' => 'CA',
      'mg' => 'MG',
      'p' => 'P',
      'fe' => 'FE',
      'zn' => 'ZN',
      'cu' => 'CU',
      'mn' => 'MN',
      'se' => 'SE',
      'id' || 'i' => 'I',
      'cl' || 'cld' => 'CL',
      'chol-' || 'cholest' => 'CHOLEST',
      'starch' => 'STARCH',
      'polyl' || 'polyol' || 'polyols' => 'POLYOLS',
      'oa' || 'orgacid' => 'ACIDES_ORGANIQUES',
      'ash' || 'cendres' => 'CENDRES',
      'fams' || 'fat_mono' => 'AG_MONO',
      'fapu' || 'fat_poly' => 'AG_POLY',
      'frus' || 'fructose' => 'FRUCTOSE',
      'glus' || 'glucose' => 'GLUCOSE',
      'lacs' || 'lactose' => 'LACTOSE',
      'mals' || 'maltose' => 'MALTOSE',
      _ => null,
    };
  }

  /// Retire le suffixe d'unité du libellé source (« Fer (mg/100 g) » →
  /// « Fer ») pour l'affichage.
  static String _cleanComponentName(String name) {
    return name.replaceFirst(RegExp(r'\s*\([^)]*/\s*100\s*g\)\s*$'), '').trim();
  }

  /// Unité par défaut d'un micronutriment quand le record n'en porte
  /// pas (minéraux en mg, iode/sélénium en µg — réf. Ciqual).
  static String _unitForMicro(String canonical) {
    return switch (canonical) {
      'I' ||
      'SE' ||
      'VITA' ||
      'VITD' ||
      'VITK' ||
      'VITB12' ||
      'FOLATES' ||
      'CAROTENE_B' => 'µg',
      _ => 'mg',
    };
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
