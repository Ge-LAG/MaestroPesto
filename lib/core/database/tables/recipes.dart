import 'package:drift/drift.dart';

class Recipes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  IntColumn get servings => integer().withDefault(const Constant(4))();
  IntColumn get prepTimeMin =>
      integer().named('prep_time_min').withDefault(const Constant(0))();
  IntColumn get cookTimeMin =>
      integer().named('cook_time_min').withDefault(const Constant(0))();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get updatedAt => text().named('updated_at')();
  TextColumn get deletedAt => text().named('deleted_at').nullable()();

  // Phase 10 (ac-125, schéma v4) — nutrition persistée avec sa source.
  /// `computed` (calculée depuis les ingrédients) ou `manual`.
  TextColumn get nutritionMode => text().named('nutrition_mode').nullable()();

  /// Résumé nutritionnel par portion (JSON : energyKcal, proteins,
  /// carbs, fats, fiber, salt).
  TextColumn get nutritionJson => text().named('nutrition_json').nullable()();

  // Phase 11 (lot D, schéma v6) — demande de conception (recette à
  // l'envers) conservée pour « Régénérer » ou « Ajuster les objectifs ».
  TextColumn get designBriefJson =>
      text().named('design_brief_json').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
