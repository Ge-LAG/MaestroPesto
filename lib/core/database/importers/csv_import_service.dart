import 'package:path/path.dart' as p;

import '../../../features/functional/data/functional_loader.dart';
import '../../../features/flavor/data/flavor_loader.dart';
import '../../../features/ingredients/data/ingredient_registry_loader.dart';
import '../../../features/nutrition/data/nutrition_loader.dart';
import '../app_database.dart';
import 'ciqual_enrichment_loader.dart';
import 'metier_enrichment_loader.dart';

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

  // Lot E — Flutter asset reading is handled via a module-level
  // override (`activeCsvReader` in csv_toolkit.dart) so the loaders
  // stay un-parametered. The AppServices layer sets that override
  // before each import and clears it after.

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

      // Enrichissement nutritionnel Ciqual (complément sourcé, session
      // 2026-08-26) : fichier dérivé hors database-metier/ — absent des
      // dossiers de fichiers de test, son absence est un skip silencieux.
      try {
        await _runPhase(
          'enrichment',
          rowsImported,
          skipped,
          onPhaseProgress,
          () async {
            final outcome = await CiqualEnrichmentLoader().loadInto(
              db,
              csvPath: p.join(
                p.dirname(databaseMetierRoot),
                'database-enrichment',
                'ciqual_nutrition.csv',
              ),
              onFileSkipped: (s) =>
                  skipped['enrichment'] = (skipped['enrichment'] ?? true) && s,
            );
            return outcome.insertedRows;
          },
        );
      } catch (_) {
        // Fichier d'enrichissement indisponible (ex. import depuis un
        // dossier de test sans les assets) : phase optionnelle, on
        // continue sans échouer l'import des 4 phases métier.
        rowsImported['enrichment'] = 0;
        skipped['enrichment'] = true;
        onPhaseProgress?.call('enrichment', 0);
      }

      // Compléments nutritionnels en libre accès, après Ciqual (ils ne
      // comblent que les ingrédients sans autre source) : USDA
      // FoodData Central (CC0) puis composition calculée.
      for (final (source, file) in [
        (NutritionEnrichmentSource.usda, 'usda_nutrition.csv'),
        (NutritionEnrichmentSource.computed, 'computed_nutrition.csv'),
      ]) {
        try {
          final outcome = await CiqualEnrichmentLoader(source: source).loadInto(
            db,
            csvPath: p.join(
              p.dirname(databaseMetierRoot),
              'database-enrichment',
              file,
            ),
            onFileSkipped: (s) =>
                skipped['enrichment'] = (skipped['enrichment'] ?? true) && s,
          );
          rowsImported['enrichment'] =
              (rowsImported['enrichment'] ?? 0) + outcome.insertedRows;
        } catch (_) {
          // Complément absent (dossier de test partiel) : ignoré.
        }
      }

      // Phase 10 — enrichissement métier (profils sensoriels, accords,
      // composants fonctionnels, données culinaires, facteurs de
      // procédé) + CSV Phase 4 orphelins. Fichiers optionnels.
      final metierReport = await MetierEnrichmentLoader().loadInto(
        db,
        enrichmentDir: p.join(
          p.dirname(databaseMetierRoot),
          'database-enrichment',
        ),
        phase4Dir: p.join(databaseMetierRoot, 'phase4-functional'),
        onFileSkipped: (_, s) =>
            skipped['metier'] = (skipped['metier'] ?? true) && s,
      );
      rowsImported['metier'] = metierReport.values.fold(0, (a, b) => a + b);
      skipped.putIfAbsent('metier', () => true);
      onPhaseProgress?.call('metier', rowsImported['metier']!);
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
