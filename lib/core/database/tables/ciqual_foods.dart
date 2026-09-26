import 'package:drift/drift.dart';

class CiqualFoods extends Table {
  TextColumn get code => text()();
  TextColumn get name => text()();
  TextColumn get groupCode => text().named('group_code').nullable()();

  @override
  Set<Column> get primaryKey => {code};
}
