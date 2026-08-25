import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';

/// Read-only repository for Phase 1 ingredients. Used by the recipe
/// detail view to resolve the canonical name and metadata of an
/// ingredient from its `ingredient_id` FK.
///
/// All methods are tolerant to missing data: they return empty results
/// when the database has not been populated yet (i.e. the metier CSV
/// importer has not been run).
class IngredientsRepository {
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
    final row = await (db.selectOnly(db.ingredients)
          ..addColumns([db.ingredients.ingredientId.count()]))
        .getSingle();
    return row.read(db.ingredients.ingredientId.count()) ?? 0;
  }
}