import 'package:drift/drift.dart';

import 'recipes.dart';

class RecipeSteps extends Table {
  TextColumn get id => text()();
  TextColumn get recipeId => text()
      .named('recipe_id')
      .references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
  TextColumn get body => text()();

  // Phase 10 Lot F (schéma v4) — étape typée : opération Phase 4,
  // température et durée (analysées depuis le texte ou saisies).
  TextColumn get opId => text().named('op_id').nullable()();
  RealColumn get temperatureC => real().named('temperature_c').nullable()();
  RealColumn get durationMin => real().named('duration_min').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
