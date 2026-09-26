import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:maestropesto/app/settings/app_settings.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

import 'app_database.dart';
import 'connection/database_connection.dart';
import 'importers/csv_import_service.dart';
import 'importers/csv_toolkit.dart' show activeCsvReader;

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
  AppServices._(this.db, this.metierRoot, this.settings, this.dataDirectory)
    : autoImportMetier = true;

  /// Test-only constructor: wraps an already-built database (typically an
  /// in-memory `NativeDatabase.memory()`) without touching the filesystem.
  @visibleForTesting
  AppServices.forTesting(
    this.db, {
    this.metierRoot = 'assets/database-metier',
    this.autoImportMetier = false,
    AppSettings? settings,
    this.dataDirectory,
  }) : settings = settings ?? AppSettings(MemorySettingsStore());

  final AppDatabase db;

  /// Réglages de l'application (thème, taille du texte).
  final AppSettings settings;

  /// Dossier de la base locale (affiché dans les paramètres) ; `null` en
  /// test (base en mémoire).
  final String? dataDirectory;

  /// Chemin du fichier de la base locale, si elle est sur disque.
  String? get databasePath => dataDirectory == null
      ? null
      : p.join(dataDirectory!, 'maestropesto.sqlite');

  /// Path prefix under which the 4 phase folders live. With bundled
  /// assets this is `assets/database-metier` (relative to the package);
  /// the [CsvImportService] strips the `assets/` part when joining.
  final String metierRoot;

  /// Phase 10 : import automatique des bases métier au démarrage (sauté
  /// si les fichiers embarqués n'ont pas changé). Désactivé par défaut
  /// dans les tests.
  final bool autoImportMetier;

  late final CsvImportService importer = CsvImportService(
    db,
    databaseMetierRoot: metierRoot,
  );

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
    final dir = await resolveDataDirectory();
    final settings = await AppSettings.load(
      FileSettingsStore(File(p.join(dir.path, 'maestropesto_settings.json'))),
    );
    return AppServices._(db, root, settings, dir.path);
  }

  /// Résumé de la base locale pour les paramètres : volumes et date de la
  /// dernière vérification des bases métier.
  Future<DatabaseSummary> databaseSummary() async {
    Future<int> count(String table) async {
      final row = await db
          .customSelect('SELECT COUNT(*) AS n FROM $table')
          .getSingle();
      return row.data['n'] as int? ?? 0;
    }

    DateTime? lastCheck;
    final state = await db
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' "
          "AND name = 'import_state'",
        )
        .get();
    if (state.isNotEmpty) {
      final row = await db
          .customSelect('SELECT MAX(imported_at) AS at FROM import_state')
          .getSingle();
      final at = row.data['at'] as String?;
      lastCheck = at == null ? null : DateTime.tryParse(at)?.toLocal();
    }
    return DatabaseSummary(
      schemaVersion: db.schemaVersion,
      ingredients: await count('ingredients'),
      recipes: await count('recipes'),
      lastCheck: lastCheck,
    );
  }

  /// Checks whether the 4 metier databases have already been imported.
  /// `true` = at least one Phase 1 row is present, `false` = empty.
  Future<bool> isMetierLoaded() async {
    final count = await db
        .customSelect('SELECT COUNT(*) AS n FROM ingredients')
        .getSingle();
    final n = count.data['n'] as int? ?? 0;
    return n > 0;
  }

  /// Runs the 4-phase CSV import and returns the structured report.
  ///
  /// If `metierRoot` starts with `assets/`, switches to a Flutter asset
  /// reader (Lot E) so the bundled CSVs can be loaded at runtime.
  /// Otherwise falls back to the file-based reader (Lot B tests).
  ///
  /// [onPhaseProgress] reçoit chaque avancement de phase (barre de
  /// progression du premier lancement).
  Future<ImportReport> importMetier({
    void Function(String phase, int rowsDone)? onPhaseProgress,
  }) async {
    final useAssets = metierRoot.startsWith('assets/');
    if (useAssets) {
      activeCsvReader = _assetReader;
    }
    try {
      // Attendre la fin de l'import AVANT de retirer le lecteur d'assets :
      // les loaders lisent leurs fichiers de manière asynchrone (sinon
      // l'exécutable release, lancé hors du dossier du projet, cherchait
      // `assets/…` sur le disque).
      return await importer.importAll(onPhaseProgress: onPhaseProgress);
    } finally {
      // Always clear the override so a future import with a file root
      // is not accidentally routed through the asset reader.
      if (useAssets) activeCsvReader = null;
    }
  }

  /// Phases de l'import, dans l'ordre (libellés de progression).
  static const List<(String, String)> importPhases = [
    ('phase1', 'référentiel des ingrédients'),
    ('phase2', 'nutrition'),
    ('phase3', 'arômes'),
    ('phase4', 'interactions fonctionnelles'),
    ('enrichment', 'enrichissement Ciqual'),
    ('metier', 'profils et procédés'),
  ];

  /// Stream a Flutter asset as chunked bytes. The asset path must
  /// match the prefix declared in `pubspec.yaml` (here: `assets/`).
  static Stream<List<int>> _assetReader(String csvPath) async* {
    // csvPath is something like
    // `assets/database-metier/phase1-referentiel/ingredient_registry_v1.csv`.
    // rootBundle.loadString returns a single chunk so we wrap it as a
    // single-element stream to match the byte-stream signature.
    // Les clés d'assets utilisent toujours « / » (p.join produit des
    // « \ » sous Windows).
    final bytes = await rootBundle.load(csvPath.replaceAll(r'\', '/'));
    yield bytes.buffer.asUint8List();
  }

  /// Last import timestamp (ISO 8601). Updated by [importMetier].
  DateTime? lastImportedAt;

  Future<void> close() async {
    await db.close();
  }
}

/// Volumes de la base locale affichés dans les paramètres.
class DatabaseSummary {
  const DatabaseSummary({
    required this.schemaVersion,
    required this.ingredients,
    required this.recipes,
    required this.lastCheck,
  });

  final int schemaVersion;
  final int ingredients;
  final int recipes;

  /// Dernière vérification (ou mise à jour) des bases métier.
  final DateTime? lastCheck;
}

/// Tiny indirection to keep the UI import surface narrow. The
/// [CsvImportService] takes a `databaseMetierRoot` string; with Flutter
/// assets, this is just the asset prefix.
extension AppServicesX on AppServices {
  /// Whether at least one phase CSV has been ingested at least once.
  /// (Distinct from `isMetierLoaded` which only checks Phase 1 rows.)
  Future<bool> hasAnyImportHistory() async {
    final count = await db
        .customSelect('SELECT COUNT(*) AS n FROM import_state')
        .getSingle();
    final n = count.data['n'] as int? ?? 0;
    return n > 0;
  }
}
