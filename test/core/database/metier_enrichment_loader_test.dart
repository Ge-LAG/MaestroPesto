// Phase 10 — import des tables d'enrichissement métier (données réelles).
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/importers/metier_enrichment_loader.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test(
    'charge les 10 fichiers réels, puis saute un ré-import inchangé',
    () async {
      final report = await MetierEnrichmentLoader().loadInto(
        db,
        enrichmentDir: 'assets/database-enrichment',
        phase4Dir: 'assets/database-metier/phase4-functional',
      );
      expect(report['enrichment/ingredient_flavor_profiles'], 603);
      expect(report['enrichment/culinary_pairings'], greaterThan(350));
      expect(
        report['enrichment/ingredient_functional_components'],
        greaterThan(1500),
      );
      expect(report['enrichment/process_factors'], greaterThan(60));
      expect(report['phase4/functional_components'], 40);
      expect(report['phase4/experimental_validation_cases'], 10);
      expect(report['enrichment/ingredient_allergens'], greaterThan(200));
      expect(report['enrichment/dish_skeletons'], 42);
      expect(report['enrichment/dish_processes'], 13);

      final skipped = <String>[];
      await MetierEnrichmentLoader().loadInto(
        db,
        enrichmentDir: 'assets/database-enrichment',
        phase4Dir: 'assets/database-metier/phase4-functional',
        onFileSkipped: (source, s) {
          if (s) skipped.add(source);
        },
      );
      expect(skipped, hasLength(10));
      expect(
        await db.select(db.ingredientFlavorProfiles).get(),
        hasLength(603),
        reason: 'le ré-import sauté conserve les données',
      );
    },
  );

  test('dossier absent : aucune erreur, zéro ligne', () async {
    final report = await MetierEnrichmentLoader().loadInto(
      db,
      enrichmentDir: 'dossier/inexistant',
      phase4Dir: 'dossier/inexistant',
    );
    expect(report.values.every((n) => n == 0), isTrue);
  });
}
