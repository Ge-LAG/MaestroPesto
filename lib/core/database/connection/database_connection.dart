import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

QueryExecutor openConnection() {
  return driftDatabase(
    name: 'maestropesto',
    native: DriftNativeOptions(
      setup: (db) {
        db.execute('PRAGMA journal_mode = WAL;');
      },
    ),
  );
}
