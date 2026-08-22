import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import 'nutrition_models.dart';

/// Streams phase 2 CSV files into the [AppDatabase]: the component
/// dictionary first (`nutrition_components`), then the nutrition values
/// (`nutrition_records`, FK ingredients). Both are idempotent per file via
/// SHA-256 fingerprints and `INSERT OR IGNORE`, in streaming batches parsed
/// in a background isolate.
class NutritionLoader {
  static const String componentsSourceName = 'phase2/component_dictionary';
  static const String recordsSourceName = 'phase2/nutrition_database';

  Future<int> loadInto(
    AppDatabase db, {
    required String csvPath,
    String? componentDictionaryPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    var inserted = 0;
    final dictionaryPath =
        componentDictionaryPath ??
        p.join(p.dirname(csvPath), 'component_dictionary.csv');
    inserted += await _loadComponents(db, dictionaryPath, onFileSkipped);
    inserted += await _loadRecords(db, csvPath, onProgress, onFileSkipped);
    return inserted;
  }

  Future<int> _loadComponents(
    AppDatabase db,
    String csvPath,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: componentsSourceName,
      tableName: db.nutritionComponents.actualTableName,
      parseRow: NutritionComponentCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.nutritionComponents,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
          );
        }
      },
      onSkip: onFileSkipped,
    );
    return outcome.insertedRows;
  }

  Future<int> _loadRecords(
    AppDatabase db,
    String csvPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: recordsSourceName,
      tableName: db.nutritionRecords.actualTableName,
      parseRow: NutritionRecordCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.nutritionRecords,
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
