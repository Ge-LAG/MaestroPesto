import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Base locale (dossier Documents de l'utilisateur par défaut).
///
/// La variable d'environnement `MAESTROPESTO_DB_DIR` place la base dans
/// un autre dossier : essais de l'exécutable release sur une base
/// isolée, sans toucher aux recettes de l'utilisateur.
QueryExecutor openConnection() {
  final override = Platform.environment['MAESTROPESTO_DB_DIR'];
  return driftDatabase(
    name: 'maestropesto',
    native: DriftNativeOptions(
      databaseDirectory: override == null || override.isEmpty
          ? null
          : () async => Directory(override)..createSync(recursive: true),
      setup: (db) {
        db.execute('PRAGMA journal_mode = WAL;');
      },
    ),
  );
}
