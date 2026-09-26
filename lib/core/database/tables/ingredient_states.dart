import 'package:drift/drift.dart';

class IngredientStates extends Table {
  TextColumn get stateId => text().named('ingredient_state_id')();

  @override
  Set<Column> get primaryKey => {stateId};
}
