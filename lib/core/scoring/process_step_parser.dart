// Phase 10 Lot F — analyse des étapes de préparation (texte libre FR).
//
// Chaque étape est rapprochée d'une opération Phase 4
// (`process_operations.csv`, 38 opérations) par un lexique de verbes
// culinaires, avec la température (« 180 °C », « thermostat 6 ») et la
// durée (« 25 min », « 1 h 30 ») extraites du texte, et les ingrédients
// de la recette cités. Le mode de cuisson qui en découle alimente le
// calcul nutritionnel (rendement, rétention) et le moteur de règles
// physico-chimiques (T, temps, cisaillement).

import 'package:meta/meta.dart';

import '../models/process_models.dart';

/// Opération reconnue dans une étape.
@immutable
class ParsedOperation {
  const ParsedOperation({
    required this.opId,
    required this.labelFr,
    this.cookingMethod,
    this.defaultTemperatureC,
    this.dryHeat = false,
    this.shear = false,
    this.cooling = false,
  });

  /// Identifiant Phase 4 (`PROC_*`).
  final String opId;
  final String labelFr;

  /// Mode de cuisson équivalent pour la nutrition (null = pas de
  /// cuisson : mélange, repos, refroidissement…).
  final CookingMethod? cookingMethod;

  /// Température typique quand le texte n'en donne pas.
  final double? defaultTemperatureC;
  final bool dryHeat;

  /// Cisaillement mécanique (fouetter, mixer, pétrir).
  final bool shear;

  /// Refroidissement ou congélation.
  final bool cooling;
}

/// Étape analysée.
@immutable
class ParsedStep {
  const ParsedStep({
    required this.index,
    required this.text,
    this.operations = const <ParsedOperation>[],
    this.temperatureC,
    this.durationMin,
    this.mentionedIngredients = const <int>[],
  });

  /// Position de l'étape (0-based).
  final int index;
  final String text;
  final List<ParsedOperation> operations;

  /// Température explicite ou typique de l'opération principale.
  final double? temperatureC;

  /// Durée explicite (minutes).
  final double? durationMin;

  /// Indices des lignes d'ingrédients citées dans l'étape.
  final List<int> mentionedIngredients;

  ParsedOperation? get primary => operations.isEmpty ? null : operations.first;

  /// Mode de cuisson de l'étape (première opération thermique).
  CookingMethod? get cookingMethod {
    for (final op in operations) {
      if (op.cookingMethod != null) return op.cookingMethod;
    }
    return null;
  }

  bool get isHeating => cookingMethod != null;

  /// Étape thermique au sens physico-chimique : cuisson, ou chauffage
  /// sans cuisson (faire fondre, chauffer sur feu doux…), ou température
  /// explicite > 40 °C hors refroidissement.
  bool get isThermal =>
      isHeating ||
      operations.any((o) => o.opId == 'PROC_CHAUFFER') ||
      (!isCooling && (temperatureC ?? 0) > 40);
  bool get hasShear => operations.any((o) => o.shear);
  bool get isCooling => operations.any((o) => o.cooling);
  bool get isDryHeat => operations.any((o) => o.dryHeat);
}

abstract final class ProcessStepParser {
  /// Lexique ordonné : les motifs les plus spécifiques d'abord.
  static final List<(RegExp, ParsedOperation)> _lexicon = [
    (
      RegExp(r'caram[ée]lis|en caramel|\bcaramel\b'),
      const ParsedOperation(
        opId: 'PROC_CHAUFFER',
        labelFr: 'Caraméliser',
        cookingMethod: CookingMethod.sauteed,
        defaultTemperatureC: 170,
        dryHeat: true,
      ),
    ),
    (
      RegExp(r'torr[ée]fi'),
      const ParsedOperation(
        opId: 'PROC_TORREFIER',
        labelFr: 'Torréfier',
        cookingMethod: CookingMethod.roasted,
        defaultTemperatureC: 180,
        dryHeat: true,
      ),
    ),
    (
      RegExp(r'\bfri(re|t|te|ts|tes)\b|friture|bain d.huile'),
      const ParsedOperation(
        opId: 'PROC_FRIRE',
        labelFr: 'Frire',
        cookingMethod: CookingMethod.fried,
        defaultTemperatureC: 175,
        dryHeat: true,
      ),
    ),
    (
      RegExp(r'grill|plancha|barbecue|salamandre'),
      const ParsedOperation(
        opId: 'PROC_GRILLER',
        labelFr: 'Griller',
        cookingMethod: CookingMethod.grilled,
        defaultTemperatureC: 230,
        dryHeat: true,
      ),
    ),
    (
      RegExp(r'vapeur'),
      const ParsedOperation(
        opId: 'PROC_VAPEUR',
        labelFr: 'Cuire à la vapeur',
        cookingMethod: CookingMethod.steamed,
        defaultTemperatureC: 100,
      ),
    ),
    (
      RegExp(r'r[ôo]ti|enfourn|au four|gratin|cuire.{0,20}four|four\b'),
      const ParsedOperation(
        opId: 'PROC_ROTIR',
        labelFr: 'Cuire au four',
        cookingMethod: CookingMethod.roasted,
        defaultTemperatureC: 180,
        dryHeat: true,
      ),
    ),
    (
      RegExp(
        r'po[êe]l|sauter|faire revenir|revenir|saisi|saisir|dorer|rissol|'
        r'suer|fondre les oignons',
      ),
      const ParsedOperation(
        opId: 'PROC_CUIRE',
        labelFr: 'Poêler / faire revenir',
        cookingMethod: CookingMethod.sauteed,
        defaultTemperatureC: 160,
        dryHeat: true,
      ),
    ),
    (
      RegExp(r'pocher|poché|pochez'),
      const ParsedOperation(
        opId: 'PROC_POCHER',
        labelFr: 'Pocher',
        cookingMethod: CookingMethod.boiled,
        defaultTemperatureC: 80,
      ),
    ),
    (
      RegExp(r'mijot|fr[ée]mi|braiser|brais[ée]|[àa] couvert|[ée]touff'),
      const ParsedOperation(
        opId: 'PROC_FREMIR',
        labelFr: 'Mijoter',
        cookingMethod: CookingMethod.stewed,
        defaultTemperatureC: 90,
      ),
    ),
    (
      RegExp(r'bouill(ir|ez|ant|ante|i|ie)\b|[ée]bullition|blanchi'),
      const ParsedOperation(
        opId: 'PROC_BOUILLIR',
        labelFr: 'Bouillir',
        cookingMethod: CookingMethod.boiled,
        defaultTemperatureC: 100,
      ),
    ),
    (
      RegExp(r'r[ée]dui'),
      const ParsedOperation(
        opId: 'PROC_REDUIRE',
        labelFr: 'Réduire',
        cookingMethod: CookingMethod.stewed,
        defaultTemperatureC: 100,
      ),
    ),
    (
      RegExp(r'pasteuris'),
      const ParsedOperation(
        opId: 'PROC_PASTEURISER',
        labelFr: 'Pasteuriser',
        cookingMethod: CookingMethod.boiled,
        defaultTemperatureC: 75,
      ),
    ),
    (
      RegExp(r'\bcui(re|t|te|sson|ts|tes)\b|cuisez'),
      const ParsedOperation(
        opId: 'PROC_CUIRE',
        labelFr: 'Cuire',
        cookingMethod: CookingMethod.boiled,
        defaultTemperatureC: 100,
      ),
    ),
    (
      RegExp(
        r'chauff|faire fondre|fondre|ti[ée]dir|napper chaud|infus|'
        r'feu doux|feu moyen|feu vif|sur le feu|remettre sur feu|[àa] feu',
      ),
      const ParsedOperation(
        opId: 'PROC_CHAUFFER',
        labelFr: 'Chauffer',
        defaultTemperatureC: 60,
      ),
    ),
    (
      RegExp(r'congel|turbin|sorbeti[èe]re|surgel'),
      const ParsedOperation(
        opId: 'PROC_CONGELER',
        labelFr: 'Congeler',
        defaultTemperatureC: -18,
        cooling: true,
      ),
    ),
    (
      RegExp(
        r'refroidi|r[ée]frig[ée]r|au frais|frigo|laisser prendre|'
        r'faire prendre|cristallis',
      ),
      const ParsedOperation(
        opId: 'PROC_REFROIDIR',
        labelFr: 'Refroidir',
        defaultTemperatureC: 4,
        cooling: true,
      ),
    ),
    (
      RegExp(r'p[ée]tri'),
      const ParsedOperation(
        opId: 'PROC_PETRIR',
        labelFr: 'Pétrir',
        shear: true,
      ),
    ),
    (
      RegExp(r'fouett|monter|battre|battez|[ée]mulsionn|foisonn'),
      const ParsedOperation(
        opId: 'PROC_FOUETTER',
        labelFr: 'Fouetter',
        shear: true,
      ),
    ),
    (
      RegExp(r'\bmix|blender|robot|cutter|hach|broy|piler|pilon'),
      const ParsedOperation(opId: 'PROC_MIXER', labelFr: 'Mixer', shear: true),
    ),
    (
      RegExp(r'ferment'),
      const ParsedOperation(
        opId: 'PROC_FERMENTER',
        labelFr: 'Fermenter',
        defaultTemperatureC: 25,
      ),
    ),
    (
      RegExp(r'\blever\b|faire lever|laisser lever|pousser|pointage|appr[êe]t'),
      const ParsedOperation(
        opId: 'PROC_FAIRE_LEVER',
        labelFr: 'Faire lever',
        defaultTemperatureC: 27,
      ),
    ),
    (
      RegExp(r'mac[ée]r|mariner|marinade'),
      const ParsedOperation(opId: 'PROC_MACERER', labelFr: 'Macérer'),
    ),
    (
      RegExp(r'[ée]goutt'),
      const ParsedOperation(opId: 'PROC_EGOUTTER', labelFr: 'Égoutter'),
    ),
    (
      RegExp(r'filtr|chinois|tamis'),
      const ParsedOperation(opId: 'PROC_FILTRER', labelFr: 'Filtrer'),
    ),
    (
      RegExp(r'm[ée]lang|incorpor|ajout|remu|verser|assembl'),
      const ParsedOperation(opId: 'PROC_MELANGER', labelFr: 'Mélanger'),
    ),
  ];

  static final RegExp _tempC = RegExp(
    r'(-?\d{2,3})\s*°\s*c?',
    caseSensitive: false,
  );
  static final RegExp _thermostat = RegExp(
    r'(?:thermostat|th\.?)\s*(\d{1,2})',
    caseSensitive: false,
  );
  static final RegExp _hoursMinutes = RegExp(
    r'(\d+)\s*h\s*(\d{1,2})?(?!\w)',
    caseSensitive: false,
  );
  static final RegExp _minutes = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*(?:min|minutes?|mn)\b',
    caseSensitive: false,
  );
  static final RegExp _hoursWord = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*heures?\b',
    caseSensitive: false,
  );
  static final RegExp _seconds = RegExp(
    r'(\d+)\s*(?:s|sec|secondes?)\b',
    caseSensitive: false,
  );

  /// Analyse une étape. [ingredientLabels] : libellés des lignes de la
  /// recette (pour détecter les ingrédients cités). [ovenTemperatureC] :
  /// température d'un préchauffage annoncé plus tôt.
  static ParsedStep parse(
    int index,
    String text, {
    List<String> ingredientLabels = const <String>[],
    double? ovenTemperatureC,
  }) {
    final lower = text.toLowerCase();
    final ops = <ParsedOperation>[];
    final seen = <String>{};
    // « Préchauffer le four » ne cuit rien : pas d'opération.
    final preheatOnly =
        _preheat.hasMatch(lower) && !_preheatThen.hasMatch(lower);
    if (!preheatOnly) {
      for (final (pattern, op) in _lexicon) {
        if (pattern.hasMatch(lower) && seen.add(op.labelFr)) ops.add(op);
      }
    }
    // Opération principale : la plus « thermique » d'abord.
    ops.sort((a, b) => _rank(b).compareTo(_rank(a)));

    double? temperature;
    final t = _tempC.firstMatch(text);
    if (t != null) {
      temperature = double.tryParse(t.group(1)!);
    } else {
      final th = _thermostat.firstMatch(lower);
      if (th != null) temperature = double.parse(th.group(1)!) * 30;
    }
    if (temperature == null &&
        ops.isNotEmpty &&
        ops.first.opId == 'PROC_ROTIR') {
      temperature = ovenTemperatureC;
    }
    temperature ??= ops.isEmpty ? null : ops.first.defaultTemperatureC;

    return ParsedStep(
      index: index,
      text: text,
      operations: ops,
      temperatureC: temperature,
      durationMin: parseDurationMin(lower),
      mentionedIngredients: _mentions(lower, ingredientLabels),
    );
  }

  /// Analyse toutes les étapes d'une recette.
  static List<ParsedStep> parseAll(
    List<String> steps, {
    List<String> ingredientLabels = const <String>[],
  }) {
    final out = <ParsedStep>[];
    double? oven;
    for (var i = 0; i < steps.length; i++) {
      final step = parse(
        i,
        steps[i],
        ingredientLabels: ingredientLabels,
        ovenTemperatureC: oven,
      );
      if (_preheat.hasMatch(steps[i].toLowerCase()) &&
          step.temperatureC != null) {
        oven = step.temperatureC;
      }
      out.add(step);
    }
    return out;
  }

  static int _rank(ParsedOperation op) {
    if (op.cookingMethod != null) return op.dryHeat ? 4 : 3;
    if (op.cooling) return 2;
    if (op.shear) return 1;
    return 0;
  }

  /// Durée totale citée dans le texte (minutes), null si absente.
  @visibleForTesting
  static double? parseDurationMin(String lower) {
    var total = 0.0;
    var found = false;
    for (final m in _hoursMinutes.allMatches(lower)) {
      total += double.parse(m.group(1)!) * 60;
      if (m.group(2) != null) total += double.parse(m.group(2)!);
      found = true;
    }
    for (final m in _hoursWord.allMatches(lower)) {
      total += double.parse(m.group(1)!.replaceAll(',', '.')) * 60;
      found = true;
    }
    for (final m in _minutes.allMatches(lower)) {
      total += double.parse(m.group(1)!.replaceAll(',', '.'));
      found = true;
    }
    for (final m in _seconds.allMatches(lower)) {
      total += double.parse(m.group(1)!) / 60;
      found = true;
    }
    return found ? total : null;
  }

  /// Lignes d'ingrédients citées : un mot significatif du libellé (≥ 4
  /// lettres, hors mots vides) présent dans l'étape.
  static List<int> _mentions(String lower, List<String> labels) {
    final text = _normalize(lower);
    final out = <int>[];
    for (var i = 0; i < labels.length; i++) {
      for (final pattern in _labelPatterns(labels[i])) {
        if (pattern.hasMatch(text)) {
          out.add(i);
          break;
        }
      }
    }
    return out;
  }

  /// Vrai si l'étape [text] cite l'ingrédient [label] (même règle que
  /// les mentions de [parse]).
  static bool mentionsLabel(String text, String label) {
    final normalized = _normalize(text.toLowerCase());
    for (final pattern in _labelPatterns(label)) {
      if (pattern.hasMatch(normalized)) return true;
    }
    return false;
  }

  /// Motifs des mots significatifs d'un libellé (radical en début de
  /// mot), compilés une fois par libellé : le moteur de composition
  /// analyse les étapes de milliers de compositions.
  static final Map<String, List<RegExp>> _labelPatternCache = {};

  static List<RegExp> _labelPatterns(String label) =>
      _labelPatternCache[label] ??= [
        for (final w in _normalize(label.toLowerCase()).split(_nonWord))
          if (w.length >= 4 && !_stop.contains(w))
            RegExp('\\b${w.length > 5 ? w.substring(0, w.length - 1) : w}'),
      ];

  static final RegExp _preheat = RegExp(r'pr[ée]chauff');
  static final RegExp _preheatThen = RegExp(r'enfourn|puis|ensuite|cuire');
  static final RegExp _nonWord = RegExp(r'[^a-z0-9]+');

  static const Set<String> _stop = {
    'crue',
    'cuit',
    'cuite',
    'frais',
    'fraiche',
    'entier',
    'entiere',
    'viande',
    'grain',
    'poudre',
    'doux',
    'blanc',
    'blanche',
    'rouge',
    'vert',
    'verte',
    'noir',
    'noire',
    'extra',
    'vierge',
    'liquide',
  };

  static String _normalize(String s) => s
      .replaceAll('œ', 'oe')
      .replaceAll(_accentE, 'e')
      .replaceAll(_accentA, 'a')
      .replaceAll(_accentU, 'u')
      .replaceAll(_accentO, 'o')
      .replaceAll(_accentI, 'i')
      .replaceAll('ç', 'c');

  static final RegExp _accentE = RegExp(r'[éèêë]');
  static final RegExp _accentA = RegExp(r'[àâä]');
  static final RegExp _accentU = RegExp(r'[ùûü]');
  static final RegExp _accentO = RegExp(r'[ôö]');
  static final RegExp _accentI = RegExp(r'[ïî]');
}
