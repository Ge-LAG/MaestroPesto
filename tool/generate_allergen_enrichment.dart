// Générateur de l'enrichissement « allergènes » (refonte UX 2026-09-26).
//
// Le référentiel gelé (`database-metier/phase1-referentiel`) ne déclare
// les allergènes que pour une partie des ingrédients (ex. aucun pour le
// lait entier, le beurre, le saumon, le soja) et comporte des étiquettes
// erronées (lait de coco → arachides). Ce script produit
// `assets/database-enrichment/ingredient_allergens.csv` :
//
// - `declared_tags`  : étiquettes du référentiel conservées ;
// - `inferred_tags`  : allergènes de l'annexe II du règlement (UE)
//   1169/2011 déduits du nom et de la catégorie (règles curatées de
//   `tool/data/allergen_rules.csv`) ;
// - `removed_tags`   : étiquettes du référentiel corrigées
//   (`tool/data/allergen_overrides.csv`, avec justification).
//
// Usage : dart run tool/generate_allergen_enrichment.dart

import 'dart:convert';
import 'dart:io';

const _registryPath =
    'database-metier/phase1-referentiel/ingredient_registry_v1.csv';
const _rulesPath = 'tool/data/allergen_rules.csv';
const _overridesPath = 'tool/data/allergen_overrides.csv';
const _outPath = 'assets/database-enrichment/ingredient_allergens.csv';

class _Rule {
  _Rule(this.allergen, String name, String exclude, String category)
    : name = name.isEmpty ? null : RegExp(name),
      exclude = exclude.isEmpty ? null : RegExp(exclude),
      category = category.isEmpty ? null : RegExp(category);

  final String allergen;
  final RegExp? name;
  final RegExp? exclude;
  final RegExp? category;

  bool matches(String normName, String normCategory) {
    if (exclude != null && exclude!.hasMatch(normName)) return false;
    return (name?.hasMatch(normName) ?? false) ||
        (category?.hasMatch(normCategory) ?? false);
  }
}

void main() {
  final rules = [
    for (final r in _records(_rulesPath))
      _Rule(
        r['allergen']!,
        r['name_pattern'] ?? '',
        r['exclude_pattern'] ?? '',
        r['category_pattern'] ?? '',
      ),
  ];
  final overrides = {
    for (final o in _records(_overridesPath))
      _normalize(o['canonical_name_fr']!): o,
  };

  final out = StringBuffer(
    'ingredient_id,declared_tags,inferred_tags,removed_tags,note\n',
  );
  var withAllergen = 0;
  var inferredOnly = 0;
  final perAllergen = <String, int>{};
  final registry = _records(_registryPath);
  for (final r in registry) {
    final id = r['ingredient_id']!;
    final name = _normalize(r['canonical_name_fr'] ?? '');
    final category = _normalize(r['category_level_2'] ?? '');
    final declared = {
      for (final t in (r['allergen_tags'] ?? '').split('|'))
        if (t.trim().isNotEmpty) t.trim(),
    };
    final override = overrides[name];
    final removed = {
      for (final t in (override?['remove'] ?? '').split('|'))
        if (t.trim().isNotEmpty && declared.contains(t.trim())) t.trim(),
    };
    final inferred = <String>{
      for (final rule in rules)
        if (rule.matches(name, category)) rule.allergen,
      for (final t in (override?['add'] ?? '').split('|'))
        if (t.trim().isNotEmpty) t.trim(),
    };
    // Une étiquette retirée par correction ne peut revenir par règle.
    for (final t in (override?['remove'] ?? '').split('|')) {
      inferred.remove(t.trim());
    }
    final kept = declared.difference(removed);
    inferred.removeAll(kept);
    final all = {...kept, ...inferred};
    if (all.isEmpty && removed.isEmpty) continue;
    if (all.isNotEmpty) withAllergen++;
    if (kept.isEmpty && inferred.isNotEmpty) inferredOnly++;
    for (final t in all) {
      perAllergen[t] = (perAllergen[t] ?? 0) + 1;
    }
    out.writeln(
      [
        id,
        (kept.toList()..sort()).join('|'),
        (inferred.toList()..sort()).join('|'),
        (removed.toList()..sort()).join('|'),
        _cell(override?['note'] ?? ''),
      ].join(','),
    );
  }
  File(_outPath).writeAsStringSync(out.toString(), encoding: utf8);
  stdout.writeln(
    '$_outPath : $withAllergen ingrédients avec allergènes '
    '($inferredOnly uniquement par déduction) sur ${registry.length}.',
  );
  final sorted = perAllergen.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  stdout.writeln(sorted.map((e) => '${e.key}=${e.value}').join(' '));
}

String _normalize(String name) => name
    .toLowerCase()
    .replaceAll('œ', 'oe')
    .replaceAll('æ', 'ae')
    .replaceAll(RegExp(r'[éèêë]'), 'e')
    .replaceAll(RegExp(r'[àâä]'), 'a')
    .replaceAll(RegExp(r'[ùûü]'), 'u')
    .replaceAll(RegExp(r'[ôö]'), 'o')
    .replaceAll(RegExp(r'[ïî]'), 'i')
    .replaceAll('ç', 'c')
    .replaceAll('’', "'");

List<Map<String, String>> _records(String path) {
  final rows = _readCsv(path);
  if (rows.isEmpty) return const [];
  final header = rows.first.map((h) => h.trim()).toList();
  return [
    for (final row in rows.skip(1))
      if (row.any((c) => c.trim().isNotEmpty))
        {
          for (var i = 0; i < header.length; i++)
            header[i]: i < row.length ? row[i] : '',
        },
  ];
}

List<List<String>> _readCsv(String path) {
  final rows = <List<String>>[];
  final cells = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (final rawLine in File(path).readAsLinesSync(encoding: utf8)) {
    if (inQuotes) cell.write('\n');
    for (var i = 0; i < rawLine.length; i++) {
      final ch = rawLine[i];
      if (inQuotes) {
        if (ch == '"') {
          if (i + 1 < rawLine.length && rawLine[i + 1] == '"') {
            cell.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          cell.write(ch);
        }
      } else if (ch == '"') {
        inQuotes = true;
      } else if (ch == ',') {
        cells.add(cell.toString());
        cell.clear();
      } else {
        cell.write(ch);
      }
    }
    if (!inQuotes) {
      cells.add(cell.toString());
      cell.clear();
      rows.add(List.of(cells));
      cells.clear();
    }
  }
  return rows;
}

String _cell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
