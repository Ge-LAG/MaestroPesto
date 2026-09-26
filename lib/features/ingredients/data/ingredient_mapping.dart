// Phase 09 Lot F — mapping Drift Ingredient → modèles purs.
//
// Ce fichier est le seul pont entre le schéma Drift `Ingredients` (Lot A)
// et les DTO Flutter-free `IngredientSummary` / `IngredientDetail`.
// Il est volontairement isolé pour pouvoir être mocké en test.

import 'package:collection/collection.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/ingredient_detail.dart';
import '../../../core/models/ingredient_summary.dart';

/// Mapping Ingredient Drift → DTO purs.
class IngredientMapping {
  const IngredientMapping._();

  /// Convertit une ligne Drift `Ingredient` en DTO pur.
  ///
  /// Le CSV Phase 1 utilise `|` comme séparateur pour les colonnes
  /// multivaluées (aliases_fr, aliases_en, ciqual_ids, etc.).
  /// Le loader CSV (`IngredientCsv.fromCsvRow`) les a déjà splittés
  /// en `List<String>`, mais en cas d'appel direct depuis Drift
  /// on refait le split ici par sécurité.
  static IngredientSummary toSummary(Ingredient row) {
    return IngredientSummary(
      ingredientId: row.ingredientId,
      canonicalNameFr: row.canonicalNameFr,
      canonicalNameEn: row.canonicalNameEn,
      categoryLevel1: row.categoryLevel1,
      categoryLevel2: row.categoryLevel2,
      categoryLevel3: row.categoryLevel3,
      allergenTags: _split(row.allergenTags),
      isAlcoholic: row.alcoholic,
      isFermented: row.fermented,
      confidence: 1.0,
    );
  }

  /// Variante riche : conserve aliases + IDs externes.
  static IngredientDetail toDetail(Ingredient row) {
    return IngredientDetail(
      ingredientId: row.ingredientId,
      canonicalNameFr: row.canonicalNameFr,
      canonicalNameEn: row.canonicalNameEn,
      categoryLevel1: row.categoryLevel1,
      categoryLevel2: row.categoryLevel2,
      categoryLevel3: row.categoryLevel3,
      allergenTags: _split(row.allergenTags),
      isAlcoholic: row.alcoholic,
      isFermented: row.fermented,
      confidence: 1.0,
      aliasesFr: _split(row.aliasesFr),
      aliasesEn: _split(row.aliasesEn),
      scientificName: row.scientificName,
      physicalForm: row.physicalForm,
      processingState: row.processingState,
      ingredientClass: row.ingredientClass,
      foodonId: row.foodonId,
      langualIds: _split(row.langualIds),
      ciqualIds: _split(row.ciqualIds),
      sourceRefs: _split(row.sourceRefs),
    );
  }

  /// Convertit une liste de lignes Drift en liste de DTO summaries.
  static List<IngredientSummary> toSummaries(Iterable<Ingredient> rows) {
    return rows.map(toSummary).toList(growable: false);
  }

  /// Convertit une liste de lignes Drift en liste de DTO details.
  static List<IngredientDetail> toDetails(Iterable<Ingredient> rows) {
    return rows.map(toDetail).toList(growable: false);
  }

  /// Split pipe-separated. Tolère null, vide, espaces.
  static List<String> _split(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    final parts = raw
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty);
    return parts.toList(growable: false);
  }
}

/// Helper d'agrégation pour debug / logs : compte par catégorie niveau 1.
class IngredientCategoryStats {
  IngredientCategoryStats._(this._counts);
  final Map<String, int> _counts;

  factory IngredientCategoryStats.fromSummaries(
    Iterable<IngredientSummary> summaries,
  ) {
    final counts = <String, int>{};
    for (final s in summaries) {
      counts.update(s.categoryLevel1, (v) => v + 1, ifAbsent: () => 1);
    }
    return IngredientCategoryStats._(counts);
  }

  int countOf(String categoryLevel1) => _counts[categoryLevel1] ?? 0;
  int get total => _counts.values.sum;
  Map<String, int> get all => Map.unmodifiable(_counts);
}
