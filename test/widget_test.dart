import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows the MaestroPesto shell', (WidgetTester tester) async {
    // Référentiel importé (fichiers) avant le démarrage : les recettes de
    // démonstration, liées au référentiel, sont semées au premier
    // lancement (Phase 10).
    await tester.runAsync(
      () => CsvImportService(
        db,
        databaseMetierRoot: 'assets/database-metier',
      ).importAll(),
    );
    await tester.pumpWidget(
      MaestroPestoApp(services: AppServices.forTesting(db)),
    );
    for (
      var i = 0;
      i < 50 && find.text('Pesto maison').evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.text('MaestroPesto'), findsOneWidget);
    expect(find.text('Pesto maison'), findsWidgets);
    // Pas de barre supérieure : sources et bases métier sont dans
    // l'en-tête du classeur.
    expect(find.byType(AppBar), findsNothing);
    expect(find.byTooltip('Sources des données'), findsOneWidget);
    expect(find.byIcon(Icons.menu_book_outlined), findsWidgets);
  });
}
