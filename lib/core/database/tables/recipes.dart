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

  @override
  Set<Column> get primaryKey => {id};
}
