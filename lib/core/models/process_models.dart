// Phase 10 Lot D — modèles purs du procédé culinaire.
//
// Un [CookingMethod] est appliqué à une ligne de recette ; un
// [CookingFactor] décrit l'effet moyen de ce mode de cuisson sur un
// [FoodGroup] : rendement massique (eau perdue ou absorbée), rétention
// des nutriments (vitamines thermosensibles, lessivage des minéraux),
// absorption de matière grasse en friture.
//
// Les facteurs sont des ORDRES DE GRANDEUR par groupe d'aliments
// (USDA Table of Nutrient Retention Factors, Release 6, 2007 ; Bognár,
// 2002), jamais spécifiques à l'aliment : ils sont signalés comme
// estimations (confiance ≤ 0,6) partout où ils sont affichés.

import 'package:meta/meta.dart';

/// Mode de cuisson d'une ligne de recette.
enum CookingMethod {
  raw,
  boiled,
  steamed,
  sauteed,
  roasted,
  grilled,
  fried,
  stewed,
  baked;

  /// Identifiant stable persisté (`recipe_items.cooking_method`).
  String get id => name;

  static CookingMethod? fromId(String? id) {
    if (id == null || id.isEmpty) return null;
    for (final m in CookingMethod.values) {
      if (m.name == id) return m;
    }
    return null;
  }

  /// Libellé FR court.
  String get labelFr => switch (this) {
    CookingMethod.raw => 'Cru',
    CookingMethod.boiled => 'Bouilli / poché',
    CookingMethod.steamed => 'Vapeur',
    CookingMethod.sauteed => 'Poêlé / sauté',
    CookingMethod.roasted => 'Rôti',
    CookingMethod.grilled => 'Grillé',
    CookingMethod.fried => 'Frit',
    CookingMethod.stewed => 'Mijoté / braisé',
    CookingMethod.baked => 'Cuit au four (pâte)',
  };

  /// Opération Phase 4 correspondante (`process_operations.op_id`).
  String get processOpId => switch (this) {
    CookingMethod.raw => 'PROC_MELANGER',
    CookingMethod.boiled => 'PROC_BOUILLIR',
    CookingMethod.steamed => 'PROC_VAPEUR',
    CookingMethod.sauteed => 'PROC_CUIRE',
    CookingMethod.roasted => 'PROC_ROTIR',
    CookingMethod.grilled => 'PROC_GRILLER',
    CookingMethod.fried => 'PROC_FRIRE',
    CookingMethod.stewed => 'PROC_FREMIR',
    CookingMethod.baked => 'PROC_CUIRE',
  };

  /// Chaleur sèche (surface > 140 °C possible : Maillard).
  bool get isDryHeat =>
      this == CookingMethod.roasted ||
      this == CookingMethod.grilled ||
      this == CookingMethod.fried ||
      this == CookingMethod.sauteed ||
      this == CookingMethod.baked;

  bool get isHeated => this != CookingMethod.raw;
}

/// Groupe d'aliments pour les facteurs de procédé (dérivé des
/// catégories du référentiel Phase 1).
enum FoodGroup {
  vegetable,
  legume,
  fruit,
  cereal,
  meat,
  fish,
  egg,
  dairy,
  mushroom,
  fat,
  other;

  static FoodGroup? fromId(String? id) {
    for (final g in FoodGroup.values) {
      if (g.name == id) return g;
    }
    return null;
  }

  /// Mapping documenté depuis `category_level_1` / `category_level_2`.
  static FoodGroup fromCategories(String? level1, String? level2) {
    final l1 = (level1 ?? '').toLowerCase();
    final l2 = (level2 ?? '').toLowerCase();
    if (l1 == 'fungi' || l2.contains('champignon')) return FoodGroup.mushroom;
    if (l2.contains('légumineuse')) return FoodGroup.legume;
    if (l2.contains('céréale') || l2 == 'produit dérivé') {
      return FoodGroup.cereal;
    }
    if (l2.contains('fruit') && !l2.contains('fruit sec')) {
      return FoodGroup.fruit;
    }
    if (l2.contains('légume') ||
        l2.contains('herbe') ||
        l1 == 'algue' ||
        l2 == 'sous-produit') {
      return FoodGroup.vegetable;
    }
    if (l2.contains('viande') || l2.contains('abats')) return FoodGroup.meat;
    if (l2.contains('poisson') ||
        l2.contains('mollusque') ||
        l2.contains('crustacé')) {
      return FoodGroup.fish;
    }
    if (l2.contains('œuf') || l2.contains('oeuf')) return FoodGroup.egg;
    if (l2.contains('laitier')) return FoodGroup.dairy;
    if (l2.contains('matière grasse')) return FoodGroup.fat;
    return FoodGroup.other;
  }
}

/// Facteurs moyens d'un mode de cuisson sur un groupe d'aliments.
@immutable
class CookingFactor {
  const CookingFactor({
    required this.group,
    required this.method,
    required this.yieldFactor,
    this.fatUptakeG = 0,
    this.fatRetention = 1,
    this.retention = const <String, double>{},
    this.confidence = 0.5,
    this.source = '',
  });

  final FoodGroup group;
  final CookingMethod method;

  /// Masse cuite ÷ masse crue (< 1 : eau évaporée/exsudée ; > 1 : eau
  /// absorbée, ex. légumineuses sèches bouillies).
  final double yieldFactor;

  /// Matière grasse absorbée (g pour 100 g cru) — friture, poêle.
  final double fatUptakeG;

  /// Rétention des lipides propres de l'aliment (fonte, égouttage).
  final double fatRetention;

  /// Rétention par tag canonique de micronutriment (VITC, THIAMIN…) ;
  /// clé `MINERALS` = minéraux hors potassium/sodium, `K` = potassium.
  final Map<String, double> retention;

  final double confidence;
  final String source;

  /// Rétention d'un micronutriment (1 si non documentée).
  double retentionFor(String canonicalTag) {
    final direct = retention[canonicalTag];
    if (direct != null) return direct;
    if (_mineralTags.contains(canonicalTag)) {
      return retention['MINERALS'] ?? 1;
    }
    return 1;
  }

  static const Set<String> _mineralTags = {
    'CA',
    'FE',
    'MG',
    'P',
    'ZN',
    'CU',
    'MN',
    'SE',
    'I',
    'CL',
  };
}

/// Lookup d'un facteur de procédé : (groupe, mode) → facteur.
typedef CookingFactorLookup = CookingFactor? Function(
  FoodGroup group,
  CookingMethod method,
);
