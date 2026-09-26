import 'package:flutter/material.dart';

const _seed = Color(0xFF356B4F);

/// Couleurs d'interface propres à MaestroPesto, déclinées en clair et en
/// sombre. Les couleurs de données (macronutriments, heatmap, Nutri-Score)
/// sont des tons moyens lisibles sur les deux fonds et restent fixes.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.page,
    required this.surface,
    required this.panel,
    required this.border,
    required this.fieldBorder,
    required this.placeholder,
    required this.track,
    required this.text,
    required this.muted,
    required this.strongMuted,
    required this.success,
    required this.warn,
    required this.warnSurface,
    required this.tagText,
    required this.tagBackgrounds,
    required this.tagBorders,
  });

  final Color page;
  final Color surface;

  /// Fond du classeur (colonne des recettes).
  final Color panel;
  final Color border;
  final Color fieldBorder;

  /// Fond des emplacements de photo et des pastilles neutres.
  final Color placeholder;

  /// Piste des jauges.
  final Color track;
  final Color text;
  final Color muted;
  final Color strongMuted;
  final Color success;
  final Color warn;
  final Color warnSurface;
  final Color tagText;
  final List<Color> tagBackgrounds;
  final List<Color> tagBorders;

  static const light = AppPalette(
    page: Color(0xFFF7F6F2),
    surface: Color(0xFFFFFFFF),
    panel: Color(0xFFF0F1EC),
    border: Color(0xFFE0DED7),
    fieldBorder: Color(0xFFDCD3C2),
    placeholder: Color(0xFFE9ECE4),
    track: Color(0xFFECE7DC),
    text: Color(0xFF22231F),
    muted: Color(0xFF686C63),
    strongMuted: Color(0xFF43473F),
    success: Color(0xFF357A5B),
    warn: Color(0xFFB85C45),
    warnSurface: Color(0xFFFBEDE6),
    tagText: Color(0xFF2E332D),
    tagBackgrounds: [
      Color(0xFFE5F0EA),
      Color(0xFFF3E8D1),
      Color(0xFFE4ECF4),
      Color(0xFFF1E2DF),
      Color(0xFFEAE6F3),
      Color(0xFFE7EED7),
    ],
    tagBorders: [
      Color(0xFFC7DDD0),
      Color(0xFFE2CAA0),
      Color(0xFFC8D7E5),
      Color(0xFFE2C5BF),
      Color(0xFFD5CCE8),
      Color(0xFFD1DEB4),
    ],
  );

  static const dark = AppPalette(
    page: Color(0xFF131512),
    surface: Color(0xFF1C1F1B),
    panel: Color(0xFF181B17),
    border: Color(0xFF34382F),
    fieldBorder: Color(0xFF474C42),
    placeholder: Color(0xFF2A2E27),
    track: Color(0xFF33372F),
    text: Color(0xFFE8E9E3),
    muted: Color(0xFFA7ACA1),
    strongMuted: Color(0xFFC9CDC2),
    success: Color(0xFF6DBF93),
    warn: Color(0xFFE38D74),
    warnSurface: Color(0xFF3B2621),
    tagText: Color(0xFFE4E7DF),
    tagBackgrounds: [
      Color(0xFF1F3329),
      Color(0xFF3A301C),
      Color(0xFF1E2B38),
      Color(0xFF3A2522),
      Color(0xFF2B2638),
      Color(0xFF2A331C),
    ],
    tagBorders: [
      Color(0xFF33523F),
      Color(0xFF5A4A2A),
      Color(0xFF34485C),
      Color(0xFF5A3A34),
      Color(0xFF443C5A),
      Color(0xFF44522C),
    ],
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(ThemeExtension<AppPalette>? other, double t) {
    if (other is! AppPalette) return this;
    return t < 0.5 ? this : other;
  }
}

extension AppPaletteContext on BuildContext {
  AppPalette get palette =>
      Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

ThemeData buildAppTheme({Brightness brightness = Brightness.light}) {
  final dark = brightness == Brightness.dark;
  final p = dark ? AppPalette.dark : AppPalette.light;

  final colorScheme = ColorScheme.fromSeed(
    seedColor: _seed,
    brightness: brightness,
    surface: p.surface,
  );

  return ThemeData(
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: p.page,
    useMaterial3: true,
    fontFamily: 'Segoe UI',
    extensions: [p],
    textTheme: TextTheme(
      displaySmall: TextStyle(
        color: p.text,
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w800,
      ),
      headlineMedium: TextStyle(
        color: p.text,
        fontSize: 26,
        height: 1.18,
        fontWeight: FontWeight.w800,
      ),
      titleLarge: TextStyle(
        color: p.text,
        fontSize: 22,
        height: 1.2,
        fontWeight: FontWeight.w800,
      ),
      titleMedium: TextStyle(
        color: p.text,
        fontSize: 17,
        height: 1.25,
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: p.text, fontSize: 16, height: 1.55),
      bodyMedium: TextStyle(color: p.text, fontSize: 14, height: 1.5),
      bodySmall: TextStyle(color: p.muted, fontSize: 13, height: 1.35),
      labelMedium: TextStyle(
        color: p.muted,
        fontSize: 12,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
      // Lisibilité : aucun texte d'interface sous 12 px.
      labelSmall: TextStyle(color: p.muted, fontSize: 12, height: 1.3),
    ),
    appBarTheme: AppBarTheme(
      centerTitle: false,
      elevation: 0,
      backgroundColor: p.surface,
      foregroundColor: p.text,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: p.surface,
      surfaceTintColor: Colors.transparent,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: p.border),
      ),
    ),
    dividerTheme: DividerThemeData(color: p.border),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      side: BorderSide(color: dark ? p.fieldBorder : const Color(0xFFDADDD3)),
      selectedColor: p.tagBackgrounds.first,
      backgroundColor: Colors.transparent,
      labelStyle: TextStyle(
        fontFamily: 'Segoe UI',
        color: p.text,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: p.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: p.fieldBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: p.fieldBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
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
