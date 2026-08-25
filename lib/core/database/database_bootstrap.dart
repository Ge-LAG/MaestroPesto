import 'package:drift/drift.dart' show Value;
import 'package:flutter/services.dart' show rootBundle;

import 'app_database.dart';
import 'connection/database_connection.dart';
import 'importers/csv_import_service.dart';
import 'importers/csv_toolkit.dart' show CsvBytesReader, CsvImportOutcome, ImportReport, activeCsvReader;

/// Single entry point that owns the [AppDatabase] instance and exposes
/// a fully wired [CsvImportService].
///
/// Lifecycle (Lot E, Phase 9 — bootstrap injection):
/// 1. `main.dart` calls [AppServices.open] inside `runZonedGuarded` (or
///    plain `await`) so the database is ready before the first widget
///    builds.
/// 2. The returned [AppServices] is given to the root widget via
///    constructor (no InheritedWidget — keeps the surface minimal).
/// 3. On hot-reload the same instance is reused (Drift `NativeDatabase`
///    is opened in `lazy` mode so the connection is deferred to the
///    first query — no leak risk in dev).
/// 4. On app shutdown, [AppServices.close] closes the database.
///
/// The metier CSV root is **bundled as a Flutter asset** (see
/// `pubspec.yaml` — `assets/database-metier/`). On a real device the
/// files live inside the APK and are read with `rootBundle`. The
/// [CsvImportService] accepts a path that already points to the right
/// location; for assets, [rootBundleCsvReader] resolves each CSV at
/// runtime.
class AppServices {
  AppServices._(this.db, this.metierRoot);

  final AppDatabase db;

  /// Path prefix under which the 4 phase folders live. With bundled
  /// assets this is `assets/database-metier` (relative to the package);
  /// the [CsvImportService] strips the `assets/` part when joining.
  final String metierRoot;

  late final CsvImportService importer =
      CsvImportService(db, databaseMetierRoot: metierRoot);

  /// Opens the database and prepares the metier service. `metierRoot`
  /// defaults to `assets/database-metier` which matches the assets
  /// declared in `pubspec.yaml`.
  static Future<AppServices> open({String? metierRoot}) async {
    final conn = openConnection();
    final db = AppDatabase(conn);
    // Open eagerly so any migration errors surface here, not in a
    // widget build cycle.
    await db.customSelect('SELECT 1').get();
    final root = metierRoot ?? 'assets/database-metier';
    return AppServices._(db, root);
  }

  /// Checks whether the 4 metier databases have already been imported.
  /// `true` = at least one Phase 1 row is present, `false` = empty.
  Future<bool> isMetierLoaded() async {
    final count = await db.customSelect(
      'SELECT COUNT(*) AS n FROM ingredients',
    ).getSingle();
    final n = count.data['n'] as int? ?? 0;
    return n > 0;
  }

  /// Runs the 4-phase CSV import and returns the structured report.
  ///
  /// If `metierRoot` starts with `assets/`, switches to a Flutter asset
  /// reader (Lot E) so the bundled CSVs can be loaded at runtime.
  /// Otherwise falls back to the file-based reader (Lot B tests).
  Future<ImportReport> importMetier() {
    if (metierRoot.startsWith('assets/')) {
      activeCsvReader = _assetReader;
    }
    try {
      return importer.importAll();
    } finally {
      // Always clear the override so a future import with a file root
      // is not accidentally routed through the asset reader.
      activeCsvReader = null;
    }
  }

  /// Stream a Flutter asset as chunked bytes. The asset path must
  /// match the prefix declared in `pubspec.yaml` (here: `assets/`).
  static final CsvBytesReader _assetReader = (String csvPath) async* {
    // csvPath is something like
    // `assets/database-metier/phase1-referentiel/ingredient_registry_v1.csv`.
    // rootBundle.loadString returns a single chunk so we wrap it as a
    // single-element stream to match the byte-stream signature.
    final bytes = await rootBundle.load(csvPath);
    yield bytes.buffer.asUint8List();
  };

  /// Last import outcome exposed for the UI badge.
  CsvImportOutcome? lastOutcome;

  Future<void> close() async {
    await db.close();
  }
}

/// Tiny indirection to keep the UI import surface narrow. The
/// [CsvImportService] takes a `databaseMetierRoot` string; with Flutter
/// assets, this is just the asset prefix.
extension AppServicesX on AppServices {
  /// Whether at least one phase CSV has been ingested at least once.
  /// (Distinct from `isMetierLoaded` which only checks Phase 1 rows.)
  Future<bool> hasAnyImportHistory() async {
    final count = await db.customSelect(
      'SELECT COUNT(*) AS n FROM import_state',
    ).getSingle();
    final n = count.data['n'] as int? ?? 0;
    return n > 0;
  }
}