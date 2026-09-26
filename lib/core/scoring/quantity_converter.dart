// Phase 10 Lot B (ac-128) — conversion des quantités culinaires en
// grammes.
//
// La quantité d'une ligne de recette reste une chaîne libre (« 60 g »,
// « 2 œufs », « 1 c. à soupe », « 1/2 botte »…). Le convertisseur :
//
// 1. extrait le nombre (décimal FR, fraction « 1/2 » ou « ½ », plage
//    « 2-3 » → moyenne) et l'unité ;
// 2. convertit par ordre de précision :
//    - masses (g, kg, mg) : exact ;
//    - volumes (ml, cl, dl, l, c. à soupe 15 ml, c. à café 5 ml,
//      verre 200 ml, tasse 240 ml, bol 250 ml, filet 5 ml) × densité de
//      l'ingrédient (profil physico-chimique Phase 4, sinon densité de
//      catégorie, sinon 1 — hypothèse signalée) ;
//    - unités de compte (pièce, gousse, feuille, tranche, botte, brin,
//      noix, pincée) × masse unitaire de l'ingrédient (table curatée),
//      sinon masse générique de l'unité (hypothèse signalée) ;
//    - nombre sans unité : pièces si l'ingrédient a une masse unitaire
//      connue (« 2 » œufs), sinon grammes (hypothèse v1 signalée).
//
// Toute hypothèse est remontée dans [QuantityResolution.assumption]
// pour être affichée (décision honest-data-display).

import 'package:meta/meta.dart';

/// Nature de l'unité reconnue.
enum QuantityUnitKind { mass, volume, count, none }

/// Unité culinaire reconnue.
@immutable
class CulinaryUnit {
  const CulinaryUnit(this.id, this.kind, this.factor, this.labelFr);

  /// Identifiant stable (g, ml, cs, cc, piece…).
  final String id;
  final QuantityUnitKind kind;

  /// Masse : grammes par unité ; volume : ml par unité ; compte :
  /// masse générique par défaut (g) quand l'ingrédient n'a pas de masse
  /// unitaire curatée.
  final double factor;
  final String labelFr;
}

/// Résultat de conversion d'une quantité.
@immutable
class QuantityResolution {
  const QuantityResolution({
    required this.grams,
    required this.value,
    required this.unit,
    this.assumption,
  });

  final double grams;

  /// Nombre saisi (après fraction/plage).
  final double value;
  final CulinaryUnit unit;

  /// Hypothèse de conversion à afficher (null = conversion exacte).
  final String? assumption;

  bool get isExact => assumption == null;
}

/// Données culinaires d'un ingrédient pour la conversion.
@immutable
class IngredientUnitData {
  const IngredientUnitData({
    this.densityGPerMl,
    this.densitySource,
    this.unitMasses = const <String, double>{},
    this.unitSources = const <String, String>{},
  });

  /// Densité (g/ml) — null = inconnue.
  final double? densityGPerMl;
  final String? densitySource;

  /// Masse (g) par unité de compte : clé = id d'unité (`piece`,
  /// `gousse`, `feuille`…).
  final Map<String, double> unitMasses;

  /// Source courte de chaque masse unitaire (« USDA FDC », « estimation »).
  final Map<String, String> unitSources;
}

abstract final class QuantityConverter {
  static const CulinaryUnit grams = CulinaryUnit(
    'g',
    QuantityUnitKind.mass,
    1,
    'g',
  );
  static const CulinaryUnit piece = CulinaryUnit(
    'piece',
    QuantityUnitKind.count,
    50,
    'pièce',
  );
  static const CulinaryUnit none = CulinaryUnit(
    '',
    QuantityUnitKind.none,
    1,
    '',
  );

  /// Unités proposées dans le formulaire (ordre d'affichage).
  static const List<CulinaryUnit> formUnits = [
    grams,
    CulinaryUnit('kg', QuantityUnitKind.mass, 1000, 'kg'),
    CulinaryUnit('ml', QuantityUnitKind.volume, 1, 'ml'),
    CulinaryUnit('cl', QuantityUnitKind.volume, 10, 'cl'),
    CulinaryUnit('l', QuantityUnitKind.volume, 1000, 'l'),
    CulinaryUnit('cs', QuantityUnitKind.volume, 15, 'c. à soupe'),
    CulinaryUnit('cc', QuantityUnitKind.volume, 5, 'c. à café'),
    CulinaryUnit('pincee', QuantityUnitKind.count, 0.5, 'pincée'),
    piece,
    CulinaryUnit('gousse', QuantityUnitKind.count, 5, 'gousse'),
    CulinaryUnit('feuille', QuantityUnitKind.count, 1, 'feuille'),
    CulinaryUnit('tranche', QuantityUnitKind.count, 25, 'tranche'),
    CulinaryUnit('brin', QuantityUnitKind.count, 1, 'brin'),
    CulinaryUnit('botte', QuantityUnitKind.count, 100, 'botte'),
  ];

  /// Alias de saisie → unité (minuscules, sans point final).
  static final Map<String, CulinaryUnit> _aliases = () {
    CulinaryUnit u(String id) => formUnits.firstWhere((x) => x.id == id);
    const mg = CulinaryUnit('mg', QuantityUnitKind.mass, 0.001, 'mg');
    const dl = CulinaryUnit('dl', QuantityUnitKind.volume, 100, 'dl');
    const verre = CulinaryUnit('verre', QuantityUnitKind.volume, 200, 'verre');
    const tasse = CulinaryUnit('tasse', QuantityUnitKind.volume, 240, 'tasse');
    const bol = CulinaryUnit('bol', QuantityUnitKind.volume, 250, 'bol');
    const filet = CulinaryUnit('filet', QuantityUnitKind.volume, 5, 'filet');
    const noix = CulinaryUnit('noix', QuantityUnitKind.count, 10, 'noix');
    return <String, CulinaryUnit>{
      'g': grams,
      'gr': grams,
      'gramme': grams,
      'grammes': grams,
      'kg': u('kg'),
      'kilo': u('kg'),
      'kilos': u('kg'),
      'mg': mg,
      'ml': u('ml'),
      'cl': u('cl'),
      'dl': dl,
      'l': u('l'),
      'litre': u('l'),
      'litres': u('l'),
      'cs': u('cs'),
      'càs': u('cs'),
      'cas': u('cs'),
      'c. à soupe': u('cs'),
      'c à soupe': u('cs'),
      'c.à.s': u('cs'),
      'cuillère à soupe': u('cs'),
      'cuillères à soupe': u('cs'),
      'cuillere a soupe': u('cs'),
      'tbsp': u('cs'),
      'cc': u('cc'),
      'càc': u('cc'),
      'cac': u('cc'),
      'c. à café': u('cc'),
      'c à café': u('cc'),
      'c.à.c': u('cc'),
      'cuillère à café': u('cc'),
      'cuillères à café': u('cc'),
      'cuillere a cafe': u('cc'),
      'tsp': u('cc'),
      'pincée': u('pincee'),
      'pincées': u('pincee'),
      'pincee': u('pincee'),
      'pincees': u('pincee'),
      'pièce': piece,
      'pièces': piece,
      'piece': piece,
      'pieces': piece,
      'pce': piece,
      'pcs': piece,
      'unité': piece,
      'unités': piece,
      'u': piece,
      'gousse': u('gousse'),
      'gousses': u('gousse'),
      'feuille': u('feuille'),
      'feuilles': u('feuille'),
      'tranche': u('tranche'),
      'tranches': u('tranche'),
      'brin': u('brin'),
      'brins': u('brin'),
      'branche': u('brin'),
      'branches': u('brin'),
      'botte': u('botte'),
      'bottes': u('botte'),
      'verre': verre,
      'verres': verre,
      'tasse': tasse,
      'tasses': tasse,
      'bol': bol,
      'bols': bol,
      'filet': filet,
      'noix': noix,
    };
  }();

  static final RegExp _numberPattern = RegExp(
    r'^\s*(\d+\s*/\s*\d+|\d+(?:[.,]\d+)?(?:\s*[-–à]\s*\d+(?:[.,]\d+)?)?|[½¼¾⅓⅔])\s*(.*)$',
  );

  /// Unité reconnue en tête de [rest] (plus long alias d'abord).
  static (CulinaryUnit, String)? _unitPrefix(String rest) {
    final lower = rest.trim().toLowerCase();
    if (lower.isEmpty) return null;
    String? best;
    for (final alias in _aliases.keys) {
      if (!lower.startsWith(alias)) continue;
      final after = lower.length == alias.length ? '' : lower[alias.length];
      // L'alias doit être un mot entier (« g » ≠ « gousse »).
      final boundary = after.isEmpty || !RegExp(r'[a-zà-ÿ]').hasMatch(after);
      if (!boundary) continue;
      if (best == null || alias.length > best.length) best = alias;
    }
    if (best == null) return null;
    return (_aliases[best]!, rest.trim().substring(best.length).trim());
  }

  /// Nombre saisi : décimal, fraction, plage (moyenne) ou glyphe.
  static double? _parseNumber(String raw) {
    final s = raw.replaceAll(' ', '');
    const glyphs = {'½': 0.5, '¼': 0.25, '¾': 0.75, '⅓': 1 / 3, '⅔': 2 / 3};
    if (glyphs.containsKey(s)) return glyphs[s];
    if (s.contains('/')) {
      final parts = s.split('/');
      final a = double.tryParse(parts[0]);
      final b = double.tryParse(parts[1]);
      if (a == null || b == null || b == 0) return null;
      return a / b;
    }
    final range = RegExp(r'^([\d.,]+)[-–à]([\d.,]+)$').firstMatch(s);
    if (range != null) {
      final a = double.tryParse(range.group(1)!.replaceAll(',', '.'));
      final b = double.tryParse(range.group(2)!.replaceAll(',', '.'));
      if (a == null || b == null) return null;
      return (a + b) / 2;
    }
    return double.tryParse(s.replaceAll(',', '.'));
  }

  /// Décompose une quantité libre en (nombre, unité). Null sans nombre.
  static (double, CulinaryUnit)? parse(String raw) {
    var text = raw.trim();
    // « une pincée », « un filet » : article indéfini = 1.
    final article = RegExp(r'^(une?)\s+', caseSensitive: false);
    if (article.hasMatch(text)) text = text.replaceFirst(article, '1 ');
    final m = _numberPattern.firstMatch(text);
    if (m == null) return null;
    final value = _parseNumber(m.group(1)!);
    if (value == null) return null;
    final unit = _unitPrefix(m.group(2) ?? '');
    return (value, unit?.$1 ?? none);
  }

  /// Convertit une quantité libre en grammes pour un ingrédient donné.
  static QuantityResolution? resolve(
    String raw, {
    IngredientUnitData data = const IngredientUnitData(),
  }) {
    final parsed = parse(raw);
    if (parsed == null) return null;
    final (value, unit) = parsed;
    switch (unit.kind) {
      case QuantityUnitKind.mass:
        return QuantityResolution(
          grams: value * unit.factor,
          value: value,
          unit: unit,
        );
      case QuantityUnitKind.volume:
        final ml = value * unit.factor;
        final density = data.densityGPerMl;
        return QuantityResolution(
          grams: ml * (density ?? 1),
          value: value,
          unit: unit,
          assumption: density == null
              ? 'densité inconnue : 1 g/ml supposé'
              : 'densité ${_fmt(density)} g/ml'
                    '${data.densitySource == null ? '' : ' (${data.densitySource})'}',
        );
      case QuantityUnitKind.count:
        final specific = data.unitMasses[unit.id];
        final perUnit = specific ?? unit.factor;
        return QuantityResolution(
          grams: value * perUnit,
          value: value,
          unit: unit,
          assumption: specific != null
              ? '1 ${unit.labelFr} ≈ ${_fmt(perUnit)} g'
                    '${_source(data.unitSources[unit.id])}'
              : '1 ${unit.labelFr} ≈ ${_fmt(perUnit)} g (masse générique)',
        );
      case QuantityUnitKind.none:
        final pieceMass = data.unitMasses['piece'];
        if (pieceMass != null) {
          return QuantityResolution(
            grams: value * pieceMass,
            value: value,
            unit: piece,
            assumption:
                '1 pièce ≈ ${_fmt(pieceMass)} g'
                '${_source(data.unitSources['piece'])}',
          );
        }
        return QuantityResolution(
          grams: value,
          value: value,
          unit: grams,
          assumption: 'unité absente : grammes supposés',
        );
    }
  }

  static String _source(String? s) => s == null ? '' : ' ($s)';

  /// Compatibilité : conversion sans données d'ingrédient.
  static double? toGrams(String raw) => resolve(raw)?.grams;

  static String _fmt(double v) => v == v.roundToDouble()
      ? v.toStringAsFixed(0)
      : v.toStringAsFixed(v < 1 ? 2 : 1).replaceAll('.', ',');
}
