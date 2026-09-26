import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';

void main() {
  for (final w in [360.0, 760.0, 800.0, 1400.0]) {
    testWidgets('shell sans barre supérieure à ${w.toInt()} px', (
      tester,
    ) async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      tester.view.physicalSize = Size(w, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
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
      final title = tester.getRect(find.text('MaestroPesto'));
      final sources = tester.getRect(find.byTooltip('Sources des données'));
      // Pas de barre supérieure ; titre lisible, non recouvert par les
      // actions (sources, bases métier) de l'en-tête du classeur.
      expect(find.byType(AppBar), findsNothing);
      expect(title.width, greaterThan(100));
      expect(title.right, lessThanOrEqualTo(sources.left));
    });
  }
}
