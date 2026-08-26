// Phase 09 Lot F — modèle pur IngredientSummary (DTO, Flutter-free).
//
// Immutable, Drift-free, testable avec `package:test/test.dart`.
// Source de vérité : table Drift `Ingredients` (lib/core/database/tables/ingredients.dart).
// La conversion Drift → pur est dans
// `lib/features/ingredients/data/ingredient_mapping.dart#fromDrift`.
//
// Décision PO dp-101 : les `allergen_tags` sont déjà pipe-split par le loader CSV,
// on les reçoit donc en `List<String>` (pas en String brut).

/// Résumé canonique d'un ingrédient Phase 1.
///
/// C'est le DTO minimal utilisé par :
/// - le picker ([`IngredientsPickerPage`])
/// - les listes courtes (heatmaps flavour)
/// - les badges / chips d'UI
///
/// Pour les détails (aliases, foodon_id, ciqualIds, etc.), voir
/// [`IngredientDetail`].
class IngredientSummary {
  const IngredientSummary({
    required this.ingredientId,
    required this.canonicalNameFr,
    this.canonicalNameEn,
    required this.categoryLevel1,
    this.categoryLevel2,
    this.categoryLevel3,
    this.allergenTags = const <String>[],
    this.isAlcoholic = false,
    this.isFermented = false,
    this.confidence = 1.0,
  });

  /// Identifiant technique Phase 1 (ex. `ING-PLANT-TOMATE-000001`).
  final String ingredientId;

  /// Nom canonique français.
  final String canonicalNameFr;

  /// Nom canonique anglais (nullable : tous les ingrédients n'ont pas de EN).
  final String? canonicalNameEn;

  /// Catégorie Phase 1 niveau 1 (ex. `vegetal`, `animal`, `fungi`).
  final String categoryLevel1;

  /// Catégorie niveau 2 (nullable).
  final String? categoryLevel2;

  /// Catégorie niveau 3 (nullable).
  final String? categoryLevel3;

  /// Allergènes déclarés (split `|` côté CSV loader).
  final List<String> allergenTags;

  /// Drapeau alcoolisé (colonne `alcoholic` du CSV).
  final bool isAlcoholic;

  /// Drapeau fermenté (colonne `fermented` du CSV).
  final bool isFermented;

  /// Confiance Phase 1 (0..1, défaut 1.0 si non fournie).
  final double confidence;

  /// Vrai si au moins un allergène est listé.
  bool get hasAllergens => allergenTags.isNotEmpty;

  /// Nom d'affichage principal (toujours le FR).
  String get displayName => canonicalNameFr;

  /// Breadcrumb catégorie level_1 > level_2 > level_3 (parties non-vides).
  String get categoryBreadcrumb {
    final parts = <String>[categoryLevel1];
    if (categoryLevel2 != null && categoryLevel2!.isNotEmpty) {
      parts.add(categoryLevel2!);
    }
    if (categoryLevel3 != null && categoryLevel3!.isNotEmpty) {
      parts.add(categoryLevel3!);
    }
    return parts.join(' › ');
  }

  IngredientSummary copyWith({
    String? ingredientId,
    String? canonicalNameFr,
    String? canonicalNameEn,
    String? categoryLevel1,
    String? categoryLevel2,
    String? categoryLevel3,
    List<String>? allergenTags,
    bool? isAlcoholic,
    bool? isFermented,
    double? confidence,
  }) {
    return IngredientSummary(
      ingredientId: ingredientId ?? this.ingredientId,
      canonicalNameFr: canonicalNameFr ?? this.canonicalNameFr,
      canonicalNameEn: canonicalNameEn ?? this.canonicalNameEn,
      categoryLevel1: categoryLevel1 ?? this.categoryLevel1,
      categoryLevel2: categoryLevel2 ?? this.categoryLevel2,
      categoryLevel3: categoryLevel3 ?? this.categoryLevel3,
      allergenTags: allergenTags ?? this.allergenTags,
      isAlcoholic: isAlcoholic ?? this.isAlcoholic,
      isFermented: isFermented ?? this.isFermented,
      confidence: confidence ?? this.confidence,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IngredientSummary) return false;
    return other.ingredientId == ingredientId &&
        other.canonicalNameFr == canonicalNameFr &&
        other.canonicalNameEn == canonicalNameEn &&
        other.categoryLevel1 == categoryLevel1 &&
        other.categoryLevel2 == categoryLevel2 &&
        other.categoryLevel3 == categoryLevel3 &&
        _listEq(other.allergenTags, allergenTags) &&
        other.isAlcoholic == isAlcoholic &&
        other.isFermented == isFermented &&
        other.confidence == confidence;
  }

  @override
  int get hashCode => Object.hash(
    ingredientId,
    canonicalNameFr,
    canonicalNameEn,
    categoryLevel1,
    categoryLevel2,
    categoryLevel3,
    Object.hashAll(allergenTags),
    isAlcoholic,
    isFermented,
    confidence,
  );

  @override
  String toString() =>
      'IngredientSummary($ingredientId, "$canonicalNameFr", '
      '$categoryLevel1, allergens=$allergenTags)';
}

bool _listEq<T>(List<T> a, List<T> b) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
