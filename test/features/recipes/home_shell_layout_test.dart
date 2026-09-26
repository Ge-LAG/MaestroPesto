import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/app/settings/app_settings.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';

void main() {
  // Clair en texte standard, sombre en grand texte : aucune erreur de
  // mise en page (débordement) du téléphone au grand écran.
  const variants = [('light', 'standard'), ('dark', 'large')];
  for (final (theme, textSize) in variants) {
    for (final w in [360.0, 760.0, 800.0, 1400.0]) {
      testWidgets('shell sans barre supérieure à ${w.toInt()} px '
          '($theme, texte $textSize)', (tester) async {
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
        final settings = await AppSettings.load(
          MemorySettingsStore({'themeMode': theme, 'textSize': textSize}),
        );
        await tester.pumpWidget(
          MaestroPestoApp(
            services: AppServices.forTesting(db, settings: settings),
          ),
        );
        for (
          var i = 0;
          i < 50 && find.text('Pesto maison').evaluate().isEmpty;
          i++
        ) {
          await tester.pump(const Duration(milliseconds: 50));
        }
        final context = tester.element(find.text('MaestroPesto'));
        expect(
          Theme.of(context).brightness,
          theme == 'dark' ? Brightness.dark : Brightness.light,
        );
        final title = tester.getRect(find.text('MaestroPesto'));
        final settingsButton = tester.getRect(
          find.byIcon(Icons.settings_outlined),
        );
        // Pas de barre supérieure ; titre lisible, non recouvert par les
        // actions de l'en-tête du classeur.
        expect(find.byType(AppBar), findsNothing);
        expect(title.width, greaterThan(100));
        expect(title.right, lessThanOrEqualTo(settingsButton.left));
      });
    }
  }
}
