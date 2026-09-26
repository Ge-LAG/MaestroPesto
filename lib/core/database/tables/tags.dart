import 'package:drift/drift.dart';

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get label => text().unique()();

  @override
  Set<Column> get primaryKey => {id};
}
