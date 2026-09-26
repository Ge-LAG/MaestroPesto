import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

/// Base locale (dossier Documents de l'utilisateur par défaut).
///
/// La variable d'environnement `MAESTROPESTO_DB_DIR` place la base dans
/// un autre dossier : essais de l'exécutable release sur une base
/// isolée, sans toucher aux recettes de l'utilisateur.
QueryExecutor openConnection() {
  return driftDatabase(
    name: 'maestropesto',
    native: DriftNativeOptions(
      databaseDirectory: resolveDataDirectory,
      setup: (db) {
        db.execute('PRAGMA journal_mode = WAL;');
      },
    ),
  );
}

/// Dossier des données locales (base et réglages) : Documents de
/// l'utilisateur, ou `MAESTROPESTO_DB_DIR` s'il est défini.
Future<Directory> resolveDataDirectory() async {
  final override = Platform.environment['MAESTROPESTO_DB_DIR'];
  if (override != null && override.isNotEmpty) {
    return Directory(override)..createSync(recursive: true);
  }
  return getApplicationDocumentsDirectory();
}
