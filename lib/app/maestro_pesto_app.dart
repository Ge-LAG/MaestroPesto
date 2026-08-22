import 'package:flutter/material.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/features/recipes/presentation/recipes_home_page.dart';

class MaestroPestoApp extends StatelessWidget {
  const MaestroPestoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const RecipesHomePage(),
    );
  }
}
