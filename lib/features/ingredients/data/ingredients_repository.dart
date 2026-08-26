import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/ingredient_summary.dart';
import '../../recommendations/data/recommender.dart';
import 'ingredient_mapping.dart';

/// Read-only repository for Phase 1 ingredients. Used by the recipe
/// detail view to resolve the canonical name and metadata of an
/// ingredient from its `ingredient_id` FK.
///
/// All methods are tolerant to missing data: they return empty results
/// when the database has not been populated yet (i.e. the metier CSV
/// importer has not been run).
class IngredientsRepository implements IngredientCandidatesSource {
  IngredientsRepository(this.db);

  final AppDatabase db;

  /// Look up a single ingredient by its canonical id.
  /// Returns null when the row does not exist.
  Future<Ingredient?> getById(String ingredientId) {
    return (db.select(db.ingredients)
          ..where((t) => t.ingredientId.equals(ingredientId))
          ..limit(1))
        .getSingleOrNull();
  }

  /// Search ingredients by partial match on the canonical French name.
  /// Used by an eventual autocomplete in the recipe form.
  Future<List<Ingredient>> searchByName(String query, {int limit = 20}) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) {
      return Future.value(const <Ingredient>[]);
    }
    return (db.select(db.ingredients)
          ..where((t) => t.canonicalNameFr.lower().like('%$needle%'))
          ..orderBy([(t) => OrderingTerm.asc(t.canonicalNameFr)])
          ..limit(limit))
        .get();
  }

  /// Total ingredient count — used by the metier status indicator.
  Future<int> count() async {
    final row = await (db.selectOnly(
      db.ingredients,
    )..addColumns([db.ingredients.ingredientId.count()])).getSingle();
    return row.read(db.ingredients.ingredientId.count()) ?? 0;
  }

  /// Phase 09 (§6.3, câblage picker) — toutes les summaries Phase 1
  /// triées par nom canonique FR. Alimente le picker du formulaire de
  /// recette. Liste vide tant que l'import CSV n'a pas été fait.
  Future<List<IngredientSummary>> allSummaries() async {
    final rows = await (db.select(
      db.ingredients,
    )..orderBy([(t) => OrderingTerm.asc(t.canonicalNameFr)])).get();
    return [
      for (final row in rows)
        IngredientMapping.toSummary(row)
            .copyWith(confidence: row.confidence ?? 1.0),
    ];
  }

  /// Phase 09 Lot H (§9.1) — résumé Phase 1 d'un ingrédient, avec la
  /// `confidence` réelle de la table (contrairement à
  /// [IngredientMapping.toSummary] qui la fixe à 1.0).
  @override
  Future<IngredientSummary?> summaryFor(String ingredientId) async {
    final row = await getById(ingredientId);
    if (row == null) return null;
    return IngredientMapping.toSummary(row)
        .copyWith(confidence: row.confidence ?? 1.0);
  }

  /// Phase 09 Lot H (§9.1) — candidats de substitution : même
  /// `category_level_1`, `confidence >= minConfidence` (défaut 0.7).
  /// Les lignes sans confidence renseignée sont exclues dès que
  /// `minConfidence > 0` (null ≠ ≥ seuil).
  @override
  Future<List<IngredientSummary>> candidatesForCategory(
    String categoryLevel1, {
    double minConfidence = 0.7,
  }) async {
    final rows =
        await (db.select(db.ingredients)
              ..where((t) => t.categoryLevel1.equals(categoryLevel1))
              ..where(
                (t) => minConfidence <= 0
                    ? const Constant(true)
                    : t.confidence.isBiggerOrEqualValue(minConfidence),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.canonicalNameFr)]))
            .get();
    return [
      for (final row in rows)
        IngredientMapping.toSummary(row)
            .copyWith(confidence: row.confidence ?? 1.0),
    ];
  }
}
