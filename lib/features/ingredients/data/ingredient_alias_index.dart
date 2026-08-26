// Phase 09 Lot F — index de recherche floue sur les ingrédients Phase 1.
//
// Cahier §6.1 :
// - Construit en mémoire au boot de l'app (cf. §11.2 cache in-process)
// - Insensible à la casse
// - Insensible aux accents (NFD + strip diacritics)
// - Tolère fautes de frappe : Levenshtein ≤ 2 sur tokens > 4 chars
// - 20+ tests exigés : exact, partiel, fuzzy, accents, casse, vide
//
// La recherche retourne des `IngredientSummary` (pas des `IngredientDetail`)
// car le picker n'a pas besoin des colonnes détaillées (aliases, etc.).
//
// Construction : passer directement la liste de (id, aliases) où aliases
// = nom canonique FR + aliases FR + aliases EN (cf. extractAliases).
//
// Utilisation :
//   final index = IngredientAliasIndex.build(entries);
//   final results = index.search('tomate');

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import '../../../core/models/ingredient_summary.dart';

/// Entrée d'index : (id, liste d'aliases normalisés).
///
/// Construction typique depuis le loader CSV :
///   final entries = rows.map((r) => IndexEntry(
///     id: r.ingredientId,
///     aliases: [r.canonicalNameFr, ...r.aliasesFr, ...r.aliasesEn],
///   ));
///   final index = IngredientAliasIndex.build(entries);
class IndexEntry {
  IndexEntry({required this.id, required this.aliases});
  final String id;
  final List<String> aliases;
}

/// Index de recherche floue construit une fois pour toute la session.
class IngredientAliasIndex {
  IngredientAliasIndex._({
    required Map<String, List<String>> exact,
    required Map<String, List<String>> tokens,
    required Map<String, IngredientSummary> byId,
  })  : _exact = exact,
        _tokens = tokens,
        _byId = byId;

  /// Map normalized_query → liste d'ids (ranked).
  final Map<String, List<String>> _exact;

  /// Map normalized_token → liste d'ids.
  final Map<String, List<String>> _tokens;

  /// Map id → summary pour reconstitution des résultats.
  final Map<String, IngredientSummary> _byId;

  /// Construit l'index à partir des summaries + aliases.
  ///
  /// [summariesById] : map id → summary
  /// [aliasesById]   : map id → liste d'aliases (incluant canonical_name_fr)
  factory IngredientAliasIndex.build({
    required Map<String, IngredientSummary> summariesById,
    required Map<String, List<String>> aliasesById,
  }) {
    final exact = <String, List<String>>{};
    final tokens = <String, List<String>>{};

    for (final entry in aliasesById.entries) {
      final id = entry.key;
      for (final alias in entry.value) {
        final normalized = normalize(alias);
        if (normalized.isEmpty) continue;

        exact.putIfAbsent(normalized, () => <String>[]);
        if (!exact[normalized]!.contains(id)) {
          exact[normalized]!.add(id);
        }

        for (final token in normalized.split(_separatorPattern)) {
          if (token.isEmpty) continue;
          tokens.putIfAbsent(token, () => <String>[]);
          if (!tokens[token]!.contains(id)) {
            tokens[token]!.add(id);
          }
        }
      }
    }

    return IngredientAliasIndex._(
      exact: exact,
      tokens: tokens,
      byId: summariesById,
    );
  }

  /// Variante simplifiée : construction directe depuis summaries.
  ///
  /// Les aliases par défaut sont uniquement `canonical_name_fr` + `canonical_name_en`.
  /// Pour les datasets avec aliases FR/EN riches, utiliser `build(...)` ci-dessus.
  factory IngredientAliasIndex.fromSummaries(
    Iterable<IngredientSummary> summaries,
  ) {
    final byId = <String, IngredientSummary>{};
    final aliases = <String, List<String>>{};

    for (final s in summaries) {
      byId[s.ingredientId] = s;
      final list = <String>[s.canonicalNameFr];
      if (s.canonicalNameEn != null && s.canonicalNameEn!.isNotEmpty) {
        list.add(s.canonicalNameEn!);
      }
      aliases[s.ingredientId] = list;
    }

    return IngredientAliasIndex.build(
      summariesById: byId,
      aliasesById: aliases,
    );
  }

  /// Recherche l'utilisateur. Renvoie les meilleurs matches triés.
  ///
  /// [limit] plafonne le nombre de résultats (défaut 30).
  /// Une requête vide renvoie les 30 premiers par nom canonique.
  List<IngredientSummary> search(String query, {int limit = 30}) {
    final q = query.trim();
    if (q.isEmpty) {
      return _byId.values
          .sorted((a, b) => a.canonicalNameFr.compareTo(b.canonicalNameFr))
          .take(limit)
          .toList(growable: false);
    }

    final normalized = normalize(q);
    if (normalized.isEmpty) {
      return _byId.values
          .sorted((a, b) => a.canonicalNameFr.compareTo(b.canonicalNameFr))
          .take(limit)
          .toList(growable: false);
    }

    final scores = <_ScoredResult>[];
    final seen = <String>{};

    // 1. Match exact (normalisé) — score 100
    final exactHits = _exact[normalized];
    if (exactHits != null) {
      for (final id in exactHits) {
        if (seen.add(id)) {
          scores.add(_ScoredResult(id, 100.0));
        }
      }
    }

    // 2. Match token exact — score 80
    final tokens = normalized
        .split(_separatorPattern)
        .where((t) => t.isNotEmpty)
        .toList(growable: false);
    for (final token in tokens) {
      final tokenHits = _tokens[token];
      if (tokenHits != null) {
        for (final id in tokenHits) {
          if (seen.add(id)) {
            scores.add(_ScoredResult(id, 80.0));
          }
        }
      }
    }

    // 3. Prefix match sur tokens — score 60
    for (final id in _byId.keys) {
      if (seen.contains(id)) continue;
      final s = _byId[id]!;
      final canonical = normalize(s.canonicalNameFr);
      if (canonical.contains(normalized)) {
        scores.add(_ScoredResult(id, 60.0));
        seen.add(id);
        continue;
      }
      bool matched = false;
      for (final token in tokens) {
        for (final entry in _tokens.entries) {
          if (entry.key.startsWith(token) && entry.value.contains(id)) {
            scores.add(_ScoredResult(id, 50.0));
            seen.add(id);
            matched = true;
            break;
          }
        }
        if (matched) break;
      }
    }

    // 4. Fuzzy Levenshtein ≤ 2 sur tokens > 4 chars — score 40-30-20
    for (final token in tokens) {
      if (token.length <= 4) continue;
      for (final entry in _tokens.entries) {
        if (entry.key == token) continue;
        if ((entry.key.length - token.length).abs() > 2) continue;
        final distance = _levenshtein(entry.key, token, maxDistance: 2);
        if (distance <= 2 && distance > 0) {
          for (final id in entry.value) {
            if (!seen.contains(id)) {
              scores.add(_ScoredResult(id, 40.0 - distance * 5));
              seen.add(id);
            }
          }
        }
      }
    }

    // Tri par score décroissant, puis par nom canonique pour stabilité.
    scores.sort((a, b) {
      final cmp = b.score.compareTo(a.score);
      if (cmp != 0) return cmp;
      final sa = _byId[a.id];
      final sb = _byId[b.id];
      if (sa == null || sb == null) return 0;
      return sa.canonicalNameFr.compareTo(sb.canonicalNameFr);
    });

    final out = <IngredientSummary>[];
    for (final sr in scores) {
      final s = _byId[sr.id];
      if (s != null) out.add(s);
      if (out.length >= limit) break;
    }
    return out;
  }

  /// Accès direct à tous les ingrédients (pour tests / debug).
  List<IngredientSummary> get all => List.unmodifiable(_byId.values);

  /// Taille de l'index.
  int get size => _byId.length;
}

/// Normalisation : lowercase + strip diacritiques NFD + collapse whitespace.
@visibleForTesting
String normalize(String input) {
  final lower = input.toLowerCase();
  final decomposed = _decompose(lower);
  return decomposed.replaceAll(_whitespacePattern, ' ').trim();
}

/// Retire les marques diacritiques (U+0300..U+036F Combining Diacritical Marks).
String _decompose(String input) {
  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune < 0x0300 || rune > 0x036F) {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

final _separatorPattern = RegExp(r'[\s\-_/]+');
final _whitespacePattern = RegExp(r'\s+');

/// Levenshtein avec élagage (early exit si > maxDistance).
@visibleForTesting
int levenshtein(String a, String b, {int maxDistance = 2}) =>
    _levenshtein(a, b, maxDistance: maxDistance);

int _levenshtein(String a, String b, {required int maxDistance}) {
  if (a == b) return 0;
  if ((a.length - b.length).abs() > maxDistance) return maxDistance + 1;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;

  var previous = List<int>.generate(b.length + 1, (i) => i);
  var current = List<int>.filled(b.length + 1, 0);

  for (var i = 1; i <= a.length; i++) {
    current[0] = i;
    var rowMin = current[0];
    for (var j = 1; j <= b.length; j++) {
      final cost = a.codeUnitAt(i - 1) == b.codeUnitAt(j - 1) ? 0 : 1;
      current[j] = [
        current[j - 1] + 1, // insertion
        previous[j] + 1, // deletion
        previous[j - 1] + cost, // substitution
      ].reduce((x, y) => x < y ? x : y);
      if (current[j] < rowMin) rowMin = current[j];
    }
    if (rowMin > maxDistance) return maxDistance + 1;
    final tmp = previous;
    previous = current;
    current = tmp;
  }
  return previous[b.length];
}

class _ScoredResult {
  _ScoredResult(this.id, this.score);
  final String id;
  final double score;
}
