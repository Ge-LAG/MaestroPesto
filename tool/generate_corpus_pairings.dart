// Accords culinaires observés dans un corpus de recettes du domaine
// public : A. Escoffier, « A Guide to Modern Cookery » (Londres, 1907,
// traduction anglaise du Guide culinaire), Project Gutenberg #71395.
//
// Méthode : chaque recette numérotée (« 661—PURÉE DE TOPINAMBOUR ») est
// une unité ; les ingrédients sont repérés par le lexique curaté
// `tool/data/corpus_lexicon.csv`. Pour chaque paire, on compte les
// recettes qui les réunissent et on calcule le lift (co-occurrence
// observée / attendue si indépendance) : il écarte les associations
// banales (sel, beurre présents partout). Seules les paires fréquentes
// (≥ 6 recettes) et nettement associées (lift ≥ 1,5) sont retenues.
// L'absence d'une paire n'est jamais interprétée comme une
// incompatibilité.
//
// Prérequis : texte brut dans `tool/.cache/escoffier_pg71395.txt`
// (https://www.gutenberg.org/cache/epub/71395/pg71395.txt).
//
// Usage : dart run tool/generate_corpus_pairings.dart

import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

const _corpusPath = 'tool/.cache/escoffier_pg71395.txt';
const _lexiconPath = 'tool/data/corpus_lexicon.csv';
const _outPath = 'tool/data/corpus_pairings.csv';
const _minRecipes = 6;
const _minLift = 1.5;
const _eggParts = {'Œuf de poule', "Jaune d'œuf", "Blanc d'œuf"};

void main() {
  final text = File(_corpusPath).readAsStringSync(encoding: utf8);
  final start = text.indexOf('*** START OF THE PROJECT GUTENBERG EBOOK');
  final end = text.indexOf('*** END OF THE PROJECT GUTENBERG EBOOK');
  final body = text.substring(start, end == -1 ? text.length : end);

  // Découpage en recettes : « 123—TITRE » en début de ligne.
  final header = RegExp(r'^(\d{1,4})—(.+)$', multiLine: true);
  final matches = header.allMatches(body).toList();
  final recipes = <String>[];
  for (var i = 0; i < matches.length; i++) {
    final from = matches[i].start;
    final to = i + 1 < matches.length ? matches[i + 1].start : body.length;
    recipes.add(body.substring(from, to).toLowerCase());
  }

  final lexicon = <(String, RegExp)>[
    for (final r in _records(_lexiconPath))
      (r['canonical_name_fr']!, RegExp(r['pattern']!, caseSensitive: false)),
  ];

  final count = <String, int>{};
  final pairCount = <String, int>{};
  for (final recipe in recipes) {
    final present = <String>{
      for (final (name, pattern) in lexicon)
        if (pattern.hasMatch(recipe)) name,
    };
    for (final a in present) {
      count[a] = (count[a] ?? 0) + 1;
    }
    final list = present.toList()..sort();
    for (var i = 0; i < list.length; i++) {
      for (var j = i + 1; j < list.length; j++) {
        final key = '${list[i]}|${list[j]}';
        pairCount[key] = (pairCount[key] ?? 0) + 1;
      }
    }
  }

  final n = recipes.length;
  final rows = <(String, String, int, double, double)>[];
  pairCount.forEach((key, nab) {
    if (nab < _minRecipes) return;
    final [a, b] = key.split('|');
    // Artefact du lexique : « yolks of eggs » désigne l'œuf ET le jaune.
    if (_eggParts.contains(a) && _eggParts.contains(b)) return;
    final lift = nab * n / (count[a]! * count[b]!);
    if (lift < _minLift) return;
    // Force d'accord modérée : 0,62 (lift 1,5) → 0,92 (lift ≥ 8).
    final strength = (0.62 + 0.12 * (math.log(lift) / math.ln2 - 0.585))
        .clamp(0.62, 0.92)
        .toDouble();
    rows.add((a, b, nab, lift, strength));
  });
  rows.sort((x, y) => y.$3.compareTo(x.$3));

  final out = StringBuffer('ingredient_a,ingredient_b,recipes,lift,strength\n');
  for (final (a, b, nab, lift, strength) in rows) {
    out.writeln(
      [
        _cell(a),
        _cell(b),
        nab,
        lift.toStringAsFixed(2),
        strength.toStringAsFixed(2),
      ].join(','),
    );
  }
  File(_outPath).writeAsStringSync(out.toString(), encoding: utf8);
  stdout.writeln(
    '$n recettes, ${count.length} ingrédients repérés → '
    '${rows.length} accords (≥ $_minRecipes recettes, lift ≥ $_minLift) '
    'dans $_outPath',
  );
}

List<Map<String, String>> _records(String path) {
  final lines = File(path).readAsLinesSync(encoding: utf8);
  final header = lines.first.split(',');
  return [
    for (final line in lines.skip(1))
      if (line.trim().isNotEmpty)
        () {
          final i = line.indexOf(',');
          return {
            header[0]: line.substring(0, i),
            header[1]: line.substring(i + 1),
          };
        }(),
  ];
}

String _cell(String value) {
  if (value.contains(',') || value.contains('"')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
