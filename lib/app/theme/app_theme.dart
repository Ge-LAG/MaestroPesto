import 'package:flutter/material.dart';

ThemeData buildAppTheme() {
  const seed = Color(0xFF356B4F);
  const page = Color(0xFFF7F6F2);
  const surface = Color(0xFFFFFFFF);
  const text = Color(0xFF22231F);
  const muted = Color(0xFF686C63);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seed,
    brightness: Brightness.light,
    surface: surface,
  );

  return ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: page,
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    textTheme: const TextTheme(
      displaySmall: TextStyle(
        color: text,
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: text,
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: text,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: text,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: text, fontSize: 16, height: 1.55),
      bodyMedium: TextStyle(color: text, fontSize: 14, height: 1.5),
      bodySmall: TextStyle(color: muted, fontSize: 13, height: 1.35),
      labelMedium: TextStyle(
        color: muted,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: surface,
      foregroundColor: Color(0xFF25231F),
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFE0DED7)),
      ),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: const BorderSide(color: Color(0xFFDADDD3)),
      selectedColor: const Color(0xFFE5F0EA),
      backgroundColor: Colors.transparent,
      labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCD3C2)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFFDCD3C2)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: seed, width: 1.5),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
  );
}
