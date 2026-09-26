import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/features/recipes/presentation/recipes_home_page.dart';

class MaestroPestoApp extends StatelessWidget {
  const MaestroPestoApp({required this.services, super.key});

  /// Services bundle (Lot E): owns the [AppDatabase] and the
  /// [CsvImportService]. Created in `main.dart` after
  /// [WidgetsFlutterBinding.ensureInitialized].
  final AppServices services;

  @override
  Widget build(BuildContext context) {
    final settings = services.settings;
    // Thème et taille du texte suivent les paramètres, sans redémarrage.
    return ListenableBuilder(
      listenable: settings,
      builder: (context, _) => MaterialApp(
        title: appStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        darkTheme: buildAppTheme(brightness: Brightness.dark),
        themeMode: settings.themeMode,
        builder: (context, child) {
          final media = MediaQuery.of(context);
          final factor = settings.textSize.factor;
          if (factor == 1.0) return child!;
          return MediaQuery(
            data: media.copyWith(
              textScaler: TextScaler.linear(media.textScaler.scale(1) * factor),
            ),
            child: child!,
          );
        },
        home: RecipesHomePage(services: services),
      ),
    );
  }
}
