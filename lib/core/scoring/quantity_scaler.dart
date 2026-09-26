// Mise à l'échelle des quantités d'une recette (portions ajustées).
//
// Multiplie le nombre en tête d'une quantité culinaire en conservant
// son unité : « 250 g » ×2 → « 500 g », « 1/2 c. à café » ×2 →
// « 1 c. à café », « 2-3 gousses » ×2 → « 4-6 gousses », « une pincée »
// ×3 → « 3 pincées ». Une quantité sans nombre (« sel », « QS ») reste
// inchangée. L'arrondi suit l'usage : masses et volumes métriques à
// l'unité au-delà de 10, pièces au quart ou au demi.

abstract final class QuantityScaler {
  static const Map<String, double> _unicodeFractions = {
    '½': 0.5,
    '¼': 0.25,
    '¾': 0.75,
    '⅓': 1 / 3,
    '⅔': 2 / 3,
  };

  /// Unités métriques (arrondi décimal, pas de pluriel).
  static final RegExp _metric = RegExp(
    r'^(mg|g|gr|kg|ml|cl|dl|l|litres?|grammes?|kilos?)\b',
    caseSensitive: false,
  );

  /// Mots invariables se terminant par « s » ou « x ».
  static const Set<String> _invariable = {
    'jus',
    'pois',
    'radis',
    'anis',
    'maïs',
    'cassis',
    'ananas',
    'os',
    'noix',
    'riz',
    'bras',
  };

  static final RegExp _number = RegExp(
    r'^(\d+\s+\d+/\d+|\d+/\d+|\d+(?:[.,]\d+)?|[½¼¾⅓⅔])'
    r'(?:\s*(?:-|–|à)\s*(\d+(?:[.,]\d+)?))?',
  );

  static final RegExp _indefinite = RegExp(r'^(une?)\s+', caseSensitive: false);

  /// Quantité [raw] multipliée par [factor] (inchangée si [factor] = 1
  /// ou si aucun nombre n'est reconnu en tête).
  static String scale(String raw, double factor) {
    if ((factor - 1).abs() < 1e-9) return raw;
    final text = raw.trim();
    if (text.isEmpty) return raw;

    double? low;
    double? high;
    String rest;
    final m = _number.firstMatch(text);
    if (m != null) {
      low = _parse(m.group(1)!);
      high = m.group(2) == null ? null : _parse(m.group(2)!);
      rest = text.substring(m.end);
    } else {
      final ind = _indefinite.firstMatch(text);
      if (ind == null) return raw;
      low = 1;
      rest = ' ${text.substring(ind.end)}';
    }
    if (low == null) return raw;

    final restTrim = rest.trimLeft();
    final metric = _metric.hasMatch(restTrim);
    final newLow = _round(low * factor, metric);
    final newHigh = high == null ? null : _round(high * factor, metric);
    final value = newHigh == null
        ? _fmt(newLow)
        : '${_fmt(newLow)}-${_fmt(newHigh)}';
    // Règle française : pluriel à partir de 2.
    final plural = (newHigh ?? newLow) >= 2;
    final wasPlural = (high ?? low) >= 2;
    return '$value${_agree(rest, plural: plural, wasPlural: wasPlural)}';
  }

  static double? _parse(String s) {
    final u = _unicodeFractions[s];
    if (u != null) return u;
    final mixed = RegExp(r'^(\d+)\s+(\d+)/(\d+)$').firstMatch(s);
    if (mixed != null) {
      final d = double.parse(mixed.group(3)!);
      if (d == 0) return null;
      return double.parse(mixed.group(1)!) + double.parse(mixed.group(2)!) / d;
    }
    final frac = RegExp(r'^(\d+)/(\d+)$').firstMatch(s);
    if (frac != null) {
      final d = double.parse(frac.group(2)!);
      if (d == 0) return null;
      return double.parse(frac.group(1)!) / d;
    }
    return double.tryParse(s.replaceAll(',', '.'));
  }

  static double _round(double v, bool metric) {
    if (metric) {
      if (v >= 10) return v.roundToDouble();
      return (v * 10).roundToDouble() / 10;
    }
    if (v >= 10) return v.roundToDouble();
    if (v >= 2) return (v * 2).roundToDouble() / 2;
    final q = (v * 4).roundToDouble() / 4;
    return q == 0 ? 0.25 : q;
  }

  static String _fmt(double v) {
    if (v == v.roundToDouble()) return v.toStringAsFixed(0);
    var s = v.toStringAsFixed(2);
    s = s.replaceFirst(RegExp(r'0+$'), '');
    return s.replaceAll('.', ',');
  }

  /// Accorde le premier mot (unité ou ingrédient) avec le nouveau
  /// nombre : « 1 gousse » → « 2 gousses », « 2 pincées » → « 1 pincée ».
  static String _agree(
    String rest, {
    required bool plural,
    required bool wasPlural,
  }) {
    final m = RegExp(
      r'^(\s+)([A-Za-zÀ-ÿœŒ]+)(.*)$',
      dotAll: true,
    ).firstMatch(rest);
    if (m == null) return rest;
    final word = m.group(2)!;
    final lower = word.toLowerCase();
    if (_metric.hasMatch(lower) ||
        word.length < 3 ||
        _invariable.contains(lower) ||
        // Abréviations (« c. à soupe ») et mots suivis d'un point.
        m.group(3)!.startsWith('.')) {
      return rest;
    }
    var out = word;
    if (plural && !wasPlural && !RegExp(r'[sxz]$').hasMatch(lower)) {
      out = lower.endsWith('eau') ? '${word}x' : '${word}s';
    } else if (!plural && wasPlural) {
      if (lower.endsWith('eaux') || lower.endsWith('s')) {
        out = word.substring(0, word.length - 1);
      }
    }
    return '${m.group(1)}$out${m.group(3)}';
  }
}
