import 'package:drift/drift.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import 'ingredient_models.dart';

/// Streams `ingredient_registry_v1.csv` (phase 1) into the [AppDatabase]
/// `ingredients` table: streaming read, batches of [csvBatchSize] rows with
/// `INSERT OR IGNORE`, parsing in a background isolate, skipped when the
/// SHA-256 of the file is unchanged since the last successful import.
class IngredientRegistryLoader {
  static const String sourceName = 'phase1/ingredient_registry_v1';

  Future<int> loadInto(
    AppDatabase db, {
    required String csvPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: sourceName,
      tableName: db.ingredients.actualTableName,
      parseRow: IngredientCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.ingredients,
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
