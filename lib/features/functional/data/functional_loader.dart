import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/database/app_database.dart';
import '../../../core/database/importers/csv_toolkit.dart';
import 'functional_models.dart';

/// Streams phase 4 CSV files into the [AppDatabase]: ingredient functional
/// profiles first (`functional_ingredients`, FK ingredients), then the
/// interaction rules (`interaction_rules`), then the process operations
/// (`process_operations`). Idempotent per file via SHA-256 fingerprints and
/// `INSERT OR IGNORE`, streaming batches parsed in a background isolate.
class FunctionalLoader {
  static const String ingredientsSourceName = 'phase4/functional_ingredients';
  static const String rulesSourceName = 'phase4/interaction_rules';
  static const String operationsSourceName = 'phase4/process_operations';

  Future<int> loadInto(
    AppDatabase db, {
    required String csvPath,
    String? interactionRulesPath,
    String? processOperationsPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  }) async {
    var inserted = 0;
    final dir = p.dirname(csvPath);
    final rulesPath =
        interactionRulesPath ?? p.join(dir, 'interaction_rules.csv');
    final operationsPath =
        processOperationsPath ?? p.join(dir, 'process_operations.csv');
    inserted += await _loadFunctionalIngredients(
      db,
      csvPath,
      onProgress,
      onFileSkipped,
    );
    inserted += await _loadRules(db, rulesPath, onFileSkipped);
    inserted += await _loadOperations(db, operationsPath, onFileSkipped);
    return inserted;
  }

  Future<int> _loadFunctionalIngredients(
    AppDatabase db,
    String csvPath,
    void Function(int rowsDone, int? rowsTotal)? onProgress,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: ingredientsSourceName,
      tableName: db.functionalIngredients.actualTableName,
      parseRow: FunctionalIngredientCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.functionalIngredients,
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

  Future<int> _loadRules(
    AppDatabase db,
    String csvPath,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: rulesSourceName,
      tableName: db.interactionRules.actualTableName,
      parseRow: InteractionRuleCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.interactionRules,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
          );
        }
      },
      onSkip: onFileSkipped,
    );
    return outcome.insertedRows;
  }

  Future<int> _loadOperations(
    AppDatabase db,
    String csvPath,
    void Function(bool skipped)? onFileSkipped,
  ) async {
    final outcome = await runCsvImport(
      db: db,
      csvPath: csvPath,
      sourceName: operationsSourceName,
      tableName: db.processOperations.actualTableName,
      parseRow: ProcessOperationCsv.fromCsvRow,
      insertRows: (batch, rows) async {
        for (final row in rows) {
          batch.insert(
            db.processOperations,
            row.toCompanion(),
            mode: InsertMode.insertOrIgnore,
          );
        }
      },
      onSkip: onFileSkipped,
    );
    return outcome.insertedRows;
  }
}
