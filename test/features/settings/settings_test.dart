import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/app/settings/app_settings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/features/settings/presentation/settings_page.dart';
import 'package:maestropesto/features/sources/presentation/data_sources_page.dart';

void main() {
  group('AppSettings', () {
    test(
      'valeurs par défaut, puis enregistrement à chaque changement',
      () async {
        final store = MemorySettingsStore();
        final settings = await AppSettings.load(store);
        expect(settings.themeMode, ThemeMode.system);
        expect(settings.textSize, TextSizeSetting.standard);

        await settings.setThemeMode(ThemeMode.dark);
        await settings.setTextSize(TextSizeSetting.large);
        expect(store.values, {'themeMode': 'dark', 'textSize': 'large'});

        final reloaded = await AppSettings.load(store);
        expect(reloaded.themeMode, ThemeMode.dark);
        expect(reloaded.textSize, TextSizeSetting.large);
      },
    );

    test('valeur inconnue : réglage par défaut', () async {
      final settings = await AppSettings.load(
        MemorySettingsStore({'themeMode': 'violet', 'textSize': 3}),
      );
      expect(settings.themeMode, ThemeMode.system);
      expect(settings.textSize, TextSizeSetting.standard);
    });

    test('fichier JSON : aller-retour, fichier corrompu ignoré', () async {
      final dir = await Directory.systemTemp.createTemp('mp_settings');
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/sub/maestropesto_settings.json');

      final settings = await AppSettings.load(FileSettingsStore(file));
      await settings.setThemeMode(ThemeMode.light);
      expect(file.existsSync(), isTrue);
      final reloaded = await AppSettings.load(FileSettingsStore(file));
      expect(reloaded.themeMode, ThemeMode.light);

      file.writeAsStringSync('{pas du json');
      final fallback = await AppSettings.load(FileSettingsStore(file));
      expect(fallback.themeMode, ThemeMode.system);
    });
  });

  group('Page Paramètres', () {
    late AppDatabase db;

    setUp(() => db = AppDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    testWidgets('le thème choisi s\'applique à toute l\'application', (
      tester,
    ) async {
      final store = MemorySettingsStore();
      final services = AppServices.forTesting(
        db,
        settings: await AppSettings.load(store),
      );
      await tester.pumpWidget(MaestroPestoApp(services: services));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.settings_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Paramètres'), findsWidgets);

      await tester.tap(find.text('Sombre'));
      await tester.pumpAndSettle();
      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.themeMode, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.text('Apparence'))).brightness,
        Brightness.dark,
      );
      expect(store.values['themeMode'], 'dark');

      await tester.tap(find.text('Grande'));
      await tester.pumpAndSettle();
      expect(
        MediaQuery.textScalerOf(tester.element(find.text('Apparence')))
            .scale(10),
        closeTo(11.5, 0.01),
      );
    });

    Future<void> pumpPage(
      WidgetTester tester,
      ValueNotifier<MetierImportStatus> status,
      VoidCallback onUpdate,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: SettingsPage(
            services: AppServices.forTesting(db),
            importStatus: status,
            onUpdateMetier: onUpdate,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('bases métier : état, mise à jour et sources', (tester) async {
      var updates = 0;
      final status = ValueNotifier(const MetierImportStatus());
      addTearDown(status.dispose);
      await pumpPage(tester, status, () => updates++);

      expect(find.textContaining('Non importées'), findsOneWidget);
      expect(find.textContaining('schéma v6'), findsOneWidget);
      expect(find.text('Base en mémoire (session de test).'), findsOneWidget);

      await tester.tap(find.text('Mettre à jour les bases métier'));
      expect(updates, 1);

      // Import en cours : progression affichée, bouton désactivé.
      status.value = const MetierImportStatus(importing: true, step: 1);
      await tester.pump();
      expect(find.textContaining('nutrition (2/6)'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      await tester.tap(find.text('Mettre à jour les bases métier'));
      expect(updates, 1);

      status.value = const MetierImportStatus(loaded: true);
      await tester.pumpAndSettle();
      expect(find.textContaining('Chargées'), findsOneWidget);

      await tester.ensureVisible(find.text('Sources des données'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sources des données'));
      await tester.pumpAndSettle();
      expect(find.byType(DataSourcesPage), findsOneWidget);
    });
  });
}
