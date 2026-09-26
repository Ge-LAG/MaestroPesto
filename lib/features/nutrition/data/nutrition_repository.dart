// Phase 09 Lot F / Phase 10 Lot A — repository Phase 2 nutrition.
//
// Source de vérité : table `nutrition_records` (records Phase 2 et
// enrichissement Ciqual 2025). Chaque champ du [NutritionProfile] est
// résolu par une **liste d'expressions par priorité** (Phase 10,
// ac-120/ac-121) : la première expression dont au moins un terme est
// présent gagne ; ses termes sont sommés (ex. folates = folates
// intrinsèques + acide folique). On ne moyenne JAMAIS deux expressions
// différentes d'un même nutriment (total vs sous-ensemble, RAE vs
// rétinol) : c'était la cause des vitamines faussées.
//
// Tags acceptés (casse ignorée) :
//   - Phase 2 : ENERCKCAL, ENERC, PROTEIN, CARB, SUGAR, FAT, FAT_SAT,
//     FIBER, NA, WATER, ALCOHOL, VITA, FOL…
//   - Ciqual 2025 (INFOODS) : PROCNT, CHOAVL, FASAT, FIB-, SALT, ALC,
//     RAE, RETOL, CARTB, FOL, FOLFD, FOLAC, FOLDFE, VITD-, CHOCAL,
//     ERGCAL, TOCPHA, VITK1, VITK2…
//   - alias génériques (energy_kcal, proteins, carbohydrate…).
//
// Plusieurs records d'un même tag (ex. Ciqual + USDA pour la pomme) :
// le record de plus haute confiance est retenu (moyenne en cas
// d'égalité).
//
// États (ac-124) : les records d'un ingrédient ne sont jamais mélangés
// entre états. L'état demandé est servi s'il existe, sinon l'état
// `raw`, sinon l'état le mieux documenté — l'état réellement servi est
// porté par le profil.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/nutrient_catalog.dart';
import '../../../core/models/nutrition_profile.dart';
import '../../../core/models/process_models.dart';
import '../../../core/scoring/nutrition_aggregator.dart';
import '../../recipes/domain/recipe.dart';

/// Terme d'une expression nutritionnelle : un tag source × coefficient.
@immutable
class _Term {
  const _Term(this.tag, [this.coef = 1]);

  final String tag;
  final double coef;
}

/// Repository pour la Phase 2 (nutrition).
///
/// Toutes les méthodes sont tolérantes aux données manquantes :
/// - DB vide → renvoie `null` ou `NutritionProfile.empty`.
/// - Composant absent → 0 dans le profil ET champ absent de
///   `knownFields` (affiché « non renseigné »).
/// - État demandé absent → repli documenté (voir en-tête).
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
      final exists = await _ingredientExists(ingredientId);
      return exists ? NutritionProfile.empty : null;
    }
    return _aggregate(records);
  }

  /// Sources distinctes des records d'un ingrédient (fiche détail).
  Future<List<NutritionSource>> sourcesFor(String ingredientId) async {
    final records = await _loadRecords(ingredientId, stateId: 'raw');
    return _sourcesOf(records);
  }

  /// Lot G (G1) — agrège la nutrition d'une recette entière, par portion.
  ///
  /// Résout les profils de chaque ingrédient lié (async), puis délègue
  /// le calcul au [NutritionAggregator] pur et synchrone (dp-105).
  /// [process] (Phase 10 Lot D) : procédé appliqué à chaque ligne
  /// (rendement + rétention) — null = aucun facteur de procédé.
  Future<NutritionAggregation> aggregateForRecipe({
    required List<RecipeIngredient> ingredients,
    required int servings,
    String stateId = 'raw',
    NutritionProcessContext? process,
  }) async {
    final cache = <String, NutritionProfile?>{};
    final byState = <String, Map<String, List<NutritionRecord>>>{};
    final sources = <String, NutritionSource>{};
    for (final ingredient in ingredients) {
      final id = ingredient.ingredientId;
      if (id == null || id.isEmpty || cache.containsKey(id)) continue;
      final all = await (_db.select(
        _db.nutritionRecords,
      )..where((t) => t.ingredientId.equals(id))).get();
      final records = selectState(all, stateId);
      for (final s in _sourcesOf(records)) {
        sources.putIfAbsent(s.id, () => s);
      }
      final states = <String, List<NutritionRecord>>{};
      for (final r in all) {
        states.putIfAbsent(r.ingredientStateId ?? 'raw', () => []).add(r);
      }
      byState[id] = states;
      if (records.isEmpty) {
        cache[id] = (await _ingredientExists(id))
            ? NutritionProfile.empty
            : null;
      } else {
        cache[id] = _aggregate(records);
      }
    }
    // Profils cuits mesurés (variantes Ciqual) fournis au procédé.
    final measuredCache = <String, NutritionProfile?>{};
    NutritionProfile? measured(String id, CookingMethod method) {
      return measuredCache.putIfAbsent('$id@${method.id}', () {
        final states = byState[id];
        if (states == null) return null;
        for (final s in preferredStates(method)) {
          final recs = states[s];
          if (recs != null && recs.isNotEmpty) {
            for (final r in recs) {
              final sid = r.sourceId;
              if (sid != null && sid.isNotEmpty) {
                sources.putIfAbsent(
                  sid,
                  () => NutritionSource(
                    id: sid,
                    label: sourceLabel(sid),
                    citation: r.notes,
                  ),
                );
              }
            }
            return _aggregate(recs);
          }
        }
        return null;
      });
    }

    final context = process == null
        ? null
        : NutritionProcessContext(
            unitDataFor: process.unitDataFor,
            groupFor: process.groupFor,
            factorFor: process.factorFor,
            methodForLine: process.methodForLine,
            measuredCookedFor: process.measuredCookedFor ?? measured,
          );
    final aggregation = NutritionAggregator.aggregate(
      ingredients: ingredients,
      lookup: (id) => cache[id],
      servings: servings,
      process: context,
    );
    if (sources.isEmpty) return aggregation;
    final sorted = sources.values.toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return aggregation.withSources(sorted);
  }

  /// États Ciqual acceptés pour un mode de cuisson, par préférence.
  static List<String> preferredStates(CookingMethod method) => switch (method) {
    CookingMethod.raw => const [],
    CookingMethod.boiled => const ['boiled', 'cooked'],
    CookingMethod.steamed => const ['steamed', 'boiled', 'cooked'],
    CookingMethod.sauteed => const ['sauteed', 'grilled', 'cooked'],
    CookingMethod.roasted => const ['roasted', 'cooked'],
    CookingMethod.grilled => const ['grilled', 'sauteed', 'roasted', 'cooked'],
    CookingMethod.fried => const ['fried'],
    CookingMethod.stewed => const ['stewed', 'boiled', 'cooked'],
    CookingMethod.baked => const ['roasted', 'cooked'],
  };

  /// Libellé lisible d'un `source_id` (null → id brut affiché).
  @visibleForTesting
  static String? sourceLabel(String sourceId) {
    final lower = sourceId.toLowerCase();
    if (lower.startsWith('ciqual_2025')) return 'ANSES Ciqual 2025-11-03';
    if (lower.contains('ciqual')) return 'ANSES Ciqual';
    if (lower.contains('usda')) return 'USDA FoodData Central';
    return null;
  }

  static List<NutritionSource> _sourcesOf(List<NutritionRecord> records) {
    final sources = <String, NutritionSource>{};
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
    return sources.values.toList();
  }

  Future<bool> _ingredientExists(String ingredientId) async {
    final query = _db.select(_db.ingredients)
      ..where((t) => t.ingredientId.equals(ingredientId))
      ..limit(1);
    final row = await query.getSingleOrNull();
    return row != null;
  }

  /// Charge les records d'UN seul état (jamais de mélange d'états).
  Future<List<NutritionRecord>> _loadRecords(
    String ingredientId, {
    required String stateId,
  }) async {
    final all = await (_db.select(
      _db.nutritionRecords,
    )..where((t) => t.ingredientId.equals(ingredientId))).get();
    return selectState(all, stateId);
  }

  /// Sélection d'état documentée : état demandé → `raw` → état non cuit
  /// le plus documenté → état le plus documenté (ordre alphabétique en
  /// cas d'égalité, déterministe).
  @visibleForTesting
  static List<NutritionRecord> selectState(
    List<NutritionRecord> records,
    String stateId,
  ) {
    if (records.isEmpty) return records;
    final byState = <String, List<NutritionRecord>>{};
    for (final r in records) {
      final s = (r.ingredientStateId ?? 'raw').trim();
      byState.putIfAbsent(s.isEmpty ? 'raw' : s, () => []).add(r);
    }
    if (byState.length == 1) return records;
    final requested = byState[stateId];
    if (requested != null) return requested;
    final raw = byState['raw'];
    if (raw != null) return raw;
    // Une demande « cru » ne retombe sur un état cuit (variante mesurée)
    // qu'en dernier recours : on préfère l'état commercial (sec, fermenté…).
    final uncooked = byState.keys
        .where((s) => !kCookedStates.contains(s))
        .toList();
    final keys = (uncooked.isNotEmpty ? uncooked : byState.keys.toList())
      ..sort((a, b) {
        final byCount = byState[b]!.length.compareTo(byState[a]!.length);
        return byCount != 0 ? byCount : a.compareTo(b);
      });
    return byState[keys.first]!;
  }

  /// Agrège les records en un NutritionProfile. Visible pour tests.
  @visibleForTesting
  static NutritionProfile aggregateRecords(List<NutritionRecord> records) =>
      _aggregate(records);

  // ---------------------------------------------------------------------
  // Expressions par priorité (Phase 10, ac-120 / ac-121).
  // ---------------------------------------------------------------------

  static const Map<MacroField, List<List<_Term>>> _macroExpressions = {
    MacroField.proteins: [
      [_Term('procnt')],
      [_Term('protein')],
      [_Term('proteins')],
    ],
    MacroField.carbs: [
      [_Term('choavl')],
      [_Term('carb')],
      [_Term('carbohydrate')],
      [_Term('carbs')],
      [_Term('carbohydrates')],
    ],
    // Sucres totaux : valeur déclarée, sinon somme des sucres
    // individuels (le sucre blanc Phase 2 ne porte que SUCROSE).
    MacroField.sugars: [
      [_Term('sugar')],
      [_Term('sugars')],
      [
        _Term('sucrose'),
        _Term('glucose'),
        _Term('fructose'),
        _Term('lactose'),
        _Term('maltose'),
      ],
      [
        _Term('sucs'),
        _Term('glus'),
        _Term('frus'),
        _Term('lacs'),
        _Term('mals'),
        _Term('gals'),
      ],
    ],
    MacroField.fats: [
      [_Term('fat')],
      [_Term('fats')],
      [_Term('lipid')],
      [_Term('lipids')],
    ],
    MacroField.saturatedFats: [
      [_Term('fasat')],
      [_Term('fat_sat')],
      [_Term('saturated_fat')],
      [_Term('saturated_fats')],
    ],
    MacroField.fiber: [
      [_Term('fib-')],
      [_Term('fiber')],
      [_Term('fibre')],
      [_Term('fibres')],
      [_Term('dietary_fiber')],
    ],
    // Sel (g) : direct, sinon sodium (mg) × 2,5 / 1000 (Ciqual).
    MacroField.salt: [
      [_Term('salt')],
      [_Term('na', 2.5 / 1000)],
      [_Term('sodium', 2.5 / 1000)],
    ],
    MacroField.alcohol: [
      [_Term('alc')],
      [_Term('alcohol')],
      [_Term('ethanol')],
    ],
    MacroField.water: [
      [_Term('water')],
    ],
    // Énergie (kcal) : kcal directe, sinon kJ ÷ 4,184.
    MacroField.energy: [
      [_Term('enerckcal')],
      [_Term('energy_kcal')],
      [_Term('energy')],
      [_Term('enerc', 1 / 4.184)],
      [_Term('energy_kj', 1 / 4.184)],
      [_Term('kj', 1 / 4.184)],
    ],
  };

  /// Micronutriments : tag canonique → expressions par priorité. Les
  /// tags non listés ici passent par [canonicalMicroTag] (1 tag = 1
  /// expression).
  static const Map<String, List<List<_Term>>> _microExpressions = {
    // Activité vitaminique A : RAE mesuré, sinon rétinol + β-carotène
    // ÷ 12 (définition RAE, IOM 2001).
    'VITA': [
      [_Term('rae')],
      [_Term('vita')],
      [_Term('retol'), _Term('cartb', 1 / 12)],
      [_Term('retinol'), _Term('carotene_b', 1 / 12)],
    ],
    // Folates totaux : total mesuré, sinon intrinsèques + acide folique
    // ajouté, sinon équivalents DFE.
    'FOLATES': [
      [_Term('fol')],
      [_Term('folfd'), _Term('folac')],
      [_Term('foldfe')],
    ],
    // Vitamine D totale, sinon D3 + D2.
    'VITD': [
      [_Term('vitd-')],
      [_Term('vitd')],
      [_Term('chocal'), _Term('ergcal')],
    ],
    // Vitamine E : α-tocophérol (base des VNR), sinon activité totale.
    'VITE': [
      [_Term('tocpha')],
      [_Term('vite')],
      [_Term('vite-')],
    ],
    // Vitamine K : total, sinon K1 + K2.
    'VITK': [
      [_Term('vitk')],
      [_Term('vitk1'), _Term('vitk2')],
    ],
  };

  /// Tags sources consommés par les expressions macro — jamais
  /// recanonisés en micronutriment.
  static final Set<String> _macroTags = {
    for (final alts in _macroExpressions.values)
      for (final alt in alts)
        for (final term in alt) term.tag,
  };

  static NutritionProfile _aggregate(List<NutritionRecord> records) {
    if (records.isEmpty) return NutritionProfile.empty;

    // 1. Valeur par tag : record de plus haute confiance, moyenne en
    //    cas d'égalité.
    final byTag = <String, List<NutritionRecord>>{};
    for (final r in records) {
      final cid = (r.componentId ?? '').trim().toLowerCase();
      if (cid.isEmpty || r.normalizedValue == null) continue;
      byTag.putIfAbsent(cid, () => []).add(r);
    }
    final values = <String, double>{};
    var confidenceSum = 0.0;
    var confidenceCount = 0;
    byTag.forEach((tag, list) {
      final best = list
          .map((r) => r.confidence ?? -1)
          .reduce((a, b) => a > b ? a : b);
      final kept = list.where((r) => (r.confidence ?? -1) == best).toList();
      values[tag] =
          kept.map((r) => r.normalizedValue!).reduce((a, b) => a + b) /
          kept.length;
      if (best >= 0) {
        confidenceSum += best;
        confidenceCount++;
      }
    });
    final sampleCount = byTag.values.fold<int>(0, (n, l) => n + l.length);

    double? resolve(List<List<_Term>> alternatives) {
      for (final alt in alternatives) {
        final present = alt.where((t) => values.containsKey(t.tag)).toList();
        if (present.isEmpty) continue;
        return present.fold<double>(0, (s, t) => s + values[t.tag]! * t.coef);
      }
      return null;
    }

    // 2. Macronutriments.
    final macros = <MacroField, double>{};
    _macroExpressions.forEach((field, alts) {
      final v = resolve(alts);
      if (v != null) macros[field] = v;
    });
    var energyEstimated = false;
    if (!macros.containsKey(MacroField.energy)) {
      final estimate = atwaterEnergyKcal(
        proteins: macros[MacroField.proteins],
        carbs: macros[MacroField.carbs],
        fats: macros[MacroField.fats],
        fiber: macros[MacroField.fiber],
        alcohol: macros[MacroField.alcohol],
      );
      if (estimate != null) {
        macros[MacroField.energy] = estimate;
        energyEstimated = true;
      }
    }

    // 3. Micronutriments : expressions spéciales puis tags simples.
    final micros = <String, Micronutrient>{};
    void putMicro(String canonical, double value) {
      if (value <= 0) return;
      final info = NutrientCatalog.of(canonical);
      micros[canonical] = Micronutrient(
        tag: canonical,
        name: info?.labelFr ?? canonical,
        value: value,
        unit: info?.unit ?? _unitForMicro(canonical),
      );
    }

    _microExpressions.forEach((canonical, alts) {
      final v = resolve(alts);
      if (v != null) putMicro(canonical, v);
    });
    final simple = <String, double>{};
    final simpleNames = <String, String>{};
    values.forEach((tag, value) {
      if (_macroTags.contains(tag)) return;
      final canonical = canonicalMicroTag(tag);
      if (canonical == null || _microExpressions.containsKey(canonical)) {
        return;
      }
      // Deux tags sources d'un même canonique simple (ex. THIA et
      // THIAMIN) désignent la même mesure : le premier présent gagne.
      simple.putIfAbsent(canonical, () => value);
      simpleNames.putIfAbsent(
        canonical,
        () => _cleanComponentName(byTag[tag]!.first.componentName ?? canonical),
      );
    });
    simple.forEach((canonical, value) {
      if (value <= 0) return;
      final info = NutrientCatalog.of(canonical);
      micros[canonical] = Micronutrient(
        tag: canonical,
        name: info?.labelFr ?? simpleNames[canonical] ?? canonical,
        value: value,
        unit: info?.unit ?? _unitForMicro(canonical),
      );
    });

    final first = records.first;
    final stateId = (first.ingredientStateId ?? 'raw').trim();
    return NutritionProfile(
      energyKcal: macros[MacroField.energy] ?? 0,
      proteins: macros[MacroField.proteins] ?? 0,
      carbs: macros[MacroField.carbs] ?? 0,
      sugars: macros[MacroField.sugars] ?? 0,
      fats: macros[MacroField.fats] ?? 0,
      saturatedFats: macros[MacroField.saturatedFats] ?? 0,
      fiber: macros[MacroField.fiber] ?? 0,
      salt: macros[MacroField.salt] ?? 0,
      alcohol: macros[MacroField.alcohol] ?? 0,
      waterContent: macros[MacroField.water],
      micronutrients: micros,
      ingredientStateId: stateId.isEmpty ? 'raw' : stateId,
      // ac-113 : confiance réelle = moyenne des confiances des tags
      // retenus (0,8 historique si aucune confiance n'est renseignée).
      confidence: confidenceCount == 0 ? 0.8 : confidenceSum / confidenceCount,
      recordCount: sampleCount,
      knownFields: macros.keys.toSet(),
      energyEstimated: energyEstimated,
      sourceFoodName: first.sourceFoodName,
      approximationNote: _approximationOf(records),
    );
  }

  /// Énergie (kcal/100 g) par les coefficients du règlement (UE)
  /// 1169/2011 annexe XIV : protéines et glucides 4, lipides 9, alcool
  /// 7, fibres 2. Null si aucun macronutriment énergétique n'est connu.
  static double? atwaterEnergyKcal({
    double? proteins,
    double? carbs,
    double? fats,
    double? fiber,
    double? alcohol,
  }) {
    if (proteins == null && carbs == null && fats == null && alcohol == null) {
      return null;
    }
    return (proteins ?? 0) * 4 +
        (carbs ?? 0) * 4 +
        (fats ?? 0) * 9 +
        (alcohol ?? 0) * 7 +
        (fiber ?? 0) * 2;
  }

  /// Note d'approximation portée par les records (colonne
  /// `derivation_method` de l'enrichissement : alias proxy curaté).
  static String? _approximationOf(List<NutritionRecord> records) {
    for (final r in records) {
      final d = r.derivationMethod?.trim();
      if (d != null && d.isNotEmpty) return d;
    }
    return null;
  }

  /// Canonicalise un tag de micronutriment simple entre les deux
  /// familles de sources (dictionnaire Phase 2 et INFOODS Ciqual 2025).
  /// Retourne null pour les tags inconnus à ignorer (acides gras
  /// individuels non retenus, codes numériques…).
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
      'vitd-' || 'vitd' || 'ergcal' || 'chocal' => 'VITD',
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
      'omega3' => 'OMEGA3',
      'omega6' => 'OMEGA6',
      'f18d3n3' => 'ALA',
      'f18d2cn6' => 'LA',
      'f20d5n3' => 'EPA',
      'f22d6n3' => 'DHA',
      'sucs' || 'sucrose' => 'SACCHAROSE',
      'frus' || 'fructose' => 'FRUCTOSE',
      'glus' || 'glucose' => 'GLUCOSE',
      'lacs' || 'lactose' => 'LACTOSE',
      'mals' || 'maltose' => 'MALTOSE',
      'gals' || 'galactose' => 'GALACTOSE',
      'fiber_sol' => 'FIBRES_SOL',
      'fiber_ins' => 'FIBRES_INS',
      'caffeine' => 'CAFFEINE',
      'theobrom' => 'THEOBROMINE',
      'polyphen' => 'POLYPHENOLS',
      _ => null,
    };
  }

  /// Retire le suffixe d'unité du libellé source (« Fer (mg/100 g) » →
  /// « Fer ») pour l'affichage des constituants hors catalogue.
  static String _cleanComponentName(String name) {
    return name.replaceFirst(RegExp(r'\s*\([^)]*/\s*100\s*g\)\s*$'), '').trim();
  }

  /// Unité par défaut d'un micronutriment hors catalogue.
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
