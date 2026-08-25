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
    return MaterialApp(
      title: appStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: RecipesHomePage(services: services),
    );
  }
}
