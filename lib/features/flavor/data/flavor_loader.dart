import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import 'flavor_models.dart';

/// Streams phase 3 CSV files into the [AppDatabase]: the ingredient aroma
/// compounds first (`ingredient_aroma_compounds`, FK ingredients), then the
/// pairings (`flavor_compatibility`). Idempotent per file via SHA-256
/// fingerprints and `INSERT OR IGNORE`, streaming batches parsed in a
/// background isolate.
class FlavorLoader {
  static const String aromaSourceName = 'phase3/ingredient_aroma_compounds';
  static const String compatibilitySourceName = 'phase3/flavor_compatibility';

  Future<int> loadInto(
    AppDatabase db, {
    required String csvPath,
    String? ingredientAromaCompoundsPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    var inserted = 0;
    final aromaPath =
        ingredientAromaCompoundsPath ??
        p.join(p.dirname(csvPath), 'ingredient_aroma_compounds.csv');
    inserted += await _loadAromaCompounds(db, aromaPath, onFileSkipped);
    inserted += await _loadCompatibility(
      db,
      csvPath,
      onProgress,
      onFileSkipped,
    );
    return inserted;
  }

  Future<int> _loadAromaCompounds(
    AppDatabase db,
    String csvPath,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: aromaSourceName,
      tableName: db.ingredientAromaCompounds.actualTableName,
      parseRow: IngredientAromaCompoundCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.ingredientAromaCompounds,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
          );
        }
      },
      onSkip: onFileSkipped,
    );
    return outcome.insertedRows;
  }

  Future<int> _loadCompatibility(
    AppDatabase db,
    String csvPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: compatibilitySourceName,
      tableName: db.flavorCompatibility.actualTableName,
      parseRow: FlavorCompatibilityCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.flavorCompatibility,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
          );
        }
      },
      onProgress: onProgress,
      onSkip: onFileSkipped,
    );
    return outcome.insertedRows;
  }
}
