import 'package:path/path.dart' as p;

import '../../../features/functional/data/functional_loader.dart';
import '../../../features/flavor/data/flavor_loader.dart';
import '../../../features/ingredients/data/ingredient_registry_loader.dart';
import '../../../features/nutrition/data/nutrition_loader.dart';
import '../app_database.dart';

/// Orchestrates the import of the four database-metier phases, in FK order:
/// phase 1 referentiel, phase 2 nutrition (components then records),
/// phase 3 flavour (aroma compounds then pairings), phase 4 functional
/// (profiles, rules, operations). The whole import runs in a single Drift
/// transaction: any failing phase rolls back everything. Each source file is
/// skipped when its SHA-256 fingerprint is unchanged since the last
/// successful import.
class CsvImportService {
  CsvImportService(this.db, {required this.databaseMetierRoot});

  final AppDatabase db;
  final String databaseMetierRoot;

  Future<ImportReport> importAll({
    void Function(String phase, int rowsDone)? onPhaseProgress,
  }) async {
    final stopwatch = Stopwatch()..start();
    final rowsImported = <String, int>{};
    final skipped = <String, bool>{};

    await db.transaction(() async {
      await _runPhase(
        'phase1',
        rowsImported,
        skipped,
        onPhaseProgress,
        () => IngredientRegistryLoader().loadInto(
          db,
          csvPath: p.join(
            databaseMetierRoot,
            'phase1-referentiel',
            'ingredient_registry_v1.csv',
          ),
          onProgress: (done, _) => onPhaseProgress?.call('phase1', done),
          onFileSkipped: (s) =>
              skipped['phase1'] = (skipped['phase1'] ?? true) && s,
        ),
      );
      await _runPhase(
        'phase2',
        rowsImported,
        skipped,
        onPhaseProgress,
        () => NutritionLoader().loadInto(
          db,
          csvPath: p.join(
            databaseMetierRoot,
            'phase2-nutrition',
            'nutrition_database.csv',
          ),
          onProgress: (done, _) => onPhaseProgress?.call('phase2', done),
          onFileSkipped: (s) =>
              skipped['phase2'] = (skipped['phase2'] ?? true) && s,
        ),
      );
      await _runPhase(
        'phase3',
        rowsImported,
        skipped,
        onPhaseProgress,
        () => FlavorLoader().loadInto(
          db,
          csvPath: p.join(
            databaseMetierRoot,
            'phase3-flavour',
            'flavor_compatibility.csv',
          ),
          onProgress: (done, _) => onPhaseProgress?.call('phase3', done),
          onFileSkipped: (s) =>
              skipped['phase3'] = (skipped['phase3'] ?? true) && s,
        ),
      );
      await _runPhase(
        'phase4',
        rowsImported,
        skipped,
        onPhaseProgress,
        () => FunctionalLoader().loadInto(
          db,
          csvPath: p.join(
            databaseMetierRoot,
            'phase4-functional',
            'functional_ingredients.csv',
          ),
          onProgress: (done, _) => onPhaseProgress?.call('phase4', done),
          onFileSkipped: (s) =>
              skipped['phase4'] = (skipped['phase4'] ?? true) && s,
        ),
      );
    });

    return ImportReport(
      rowsImported: Map.unmodifiable(rowsImported),
      skipped: Map.unmodifiable(skipped),
      totalDuration: stopwatch.elapsed,
    );
  }

  Future<void> _runPhase(
    String phase,
    Map<String, int> rowsImported,
    Map<String, bool> skipped,
    void Function(String phase, int rowsDone)? onPhaseProgress,
    Future<int> Function() load,
  ) async {
    final inserted = await load();
    rowsImported[phase] = inserted;
    skipped.putIfAbsent(phase, () => false);
    onPhaseProgress?.call(phase, inserted);
  }
}

class ImportReport {
  final Map<String, int> rowsImported;
  final Map<String, bool> skipped;
  final Duration totalDuration;

  const ImportReport({
    required this.rowsImported,
    required this.skipped,
    required this.totalDuration,
  });
}
