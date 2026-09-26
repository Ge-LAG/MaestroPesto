import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// Stockage des réglages : un petit fichier JSON à côté de la base locale
/// (les réglages ne sont pas des données métier et ne migrent pas avec le
/// schéma).
abstract class SettingsStore {
  Future<Map<String, Object?>> read();
  Future<void> write(Map<String, Object?> values);
}

class FileSettingsStore implements SettingsStore {
  FileSettingsStore(this.file);

  final File file;

  @override
  Future<Map<String, Object?>> read() async {
    try {
      if (!await file.exists()) return const {};
      final decoded = jsonDecode(await file.readAsString());
      return decoded is Map<String, Object?> ? decoded : const {};
    } on Object catch (e) {
      // Fichier illisible : réglages par défaut plutôt qu'un plantage.
      debugPrint('Réglages ignorés (${file.path}) : $e');
      return const {};
    }
  }

  @override
  Future<void> write(Map<String, Object?> values) async {
    await file.parent.create(recursive: true);
    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(values),
    );
  }
}

/// Stockage en mémoire (tests).
class MemorySettingsStore implements SettingsStore {
  MemorySettingsStore([Map<String, Object?>? initial]) : values = {...?initial};

  Map<String, Object?> values;

  @override
  Future<Map<String, Object?>> read() async => {...values};

  @override
  Future<void> write(Map<String, Object?> values) async {
    this.values = {...values};
  }
}

/// Taille du texte proposée dans les paramètres.
enum TextSizeSetting {
  standard(1.0),
  large(1.15);

  const TextSizeSetting(this.factor);

  final double factor;
}

/// Réglages de l'application, observables (le [MaterialApp] se reconstruit
/// quand ils changent) et enregistrés à chaque modification.
class AppSettings extends ChangeNotifier {
  AppSettings(this._store);

  final SettingsStore _store;

  ThemeMode _themeMode = ThemeMode.system;
  TextSizeSetting _textSize = TextSizeSetting.standard;

  ThemeMode get themeMode => _themeMode;
  TextSizeSetting get textSize => _textSize;

  /// Charge les réglages enregistrés ; toute valeur inconnue garde sa
  /// valeur par défaut.
  static Future<AppSettings> load(SettingsStore store) async {
    final settings = AppSettings(store);
    final values = await store.read();
    settings._themeMode = ThemeMode.values.firstWhere(
      (m) => m.name == values['themeMode'],
      orElse: () => ThemeMode.system,
    );
    settings._textSize = TextSizeSetting.values.firstWhere(
      (s) => s.name == values['textSize'],
      orElse: () => TextSizeSetting.standard,
    );
    return settings;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (mode == _themeMode) return;
    _themeMode = mode;
    notifyListeners();
    await _save();
  }

  Future<void> setTextSize(TextSizeSetting size) async {
    if (size == _textSize) return;
    _textSize = size;
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    try {
      await _store.write({
        'themeMode': _themeMode.name,
        'textSize': _textSize.name,
      });
    } on Object catch (e) {
      debugPrint('Réglages non enregistrés : $e');
    }
  }
}
