import 'package:drift/drift.dart';

class SyncEvents extends Table {
  TextColumn get id => text()();
  TextColumn get deviceId => text().named('device_id')();
  TextColumn get entityType => text().named('entity_type')();
  TextColumn get entityId => text().named('entity_id')();
  TextColumn get operation => text()();
  TextColumn get payloadJson => text().named('payload_json')();
  TextColumn get createdAt => text().named('created_at')();
  TextColumn get appliedAt => text().named('applied_at').nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
