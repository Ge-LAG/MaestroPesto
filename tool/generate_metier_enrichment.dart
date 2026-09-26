// Générateur d'enrichissement métier (Phase 10, lots B, C, D, E).
//
// Combine les tables curatées de `tool/data/` (source de vérité
// relisible, écrite par règles de nom) avec le référentiel Phase 1 gelé,
// la composition nutritionnelle (Phase 2 + enrichissement Ciqual) et les
// composés d'arômes mesurés Phase 3, puis écrit dans
// `assets/database-enrichment/` :
//
// - process_factors.csv              rendements et rétentions (Lot D)
// - ingredient_culinary.csv          densité, masses unitaires, pH (B, F)
// - ingredient_functional_components.csv  ingrédient → composants (C)
// - ingredient_flavor_profiles.csv   profil sensoriel 603/603 (E)
// - culinary_pairings.csv            accords culinaires curatés (E)
//
// Chaque valeur porte son niveau de preuve et sa confiance ; aucune
// donnée n'est inventée hors des règles documentées dans tool/data/.
// `database-metier/` reste intact (source gelée).
//
// Usage : dart run tool/generate_metier_enrichment.dart

import 'dart:convert';
import 'dart:io';

const _registryPath =
    'database-metier/phase1-referentiel/ingredient_registry_v1.csv';
const _phase2Path = 'database-metier/phase2-nutrition/nutrition_database.csv';
const _ciqualPath = 'assets/database-enrichment/ciqual_nutrition.csv';
const _aromaCompoundsPath =
    'database-metier/phase3-flavour/aroma_compounds.csv';
const _ingredientAromaPath =
    'database-metier/phase3-flavour/ingredient_aroma_compounds.csv';
const _ontologyPath =
    'database-metier/phase3-flavour/sensory_descriptor_ontology.csv';
const _outDir = 'assets/database-enrichment';

/// Saveurs de base : jamais déduites des composés volatils.
const Set<String> _tasteDescriptors = {
  'sweet',
  'sour',
  'salty',
  'bitter',
  'umami',
  'acidic',
  'kokumi',
  'metallic',
};

/// Alias de descripteurs hors ontologie → descripteur de l'ontologie.
const Map<String, String> _descriptorAliases = {
  'fresh': 'green',
  'creamy': 'dairy',
  'soapy': 'floral',
  'melon': 'fruity',
  'minty': 'cooling',
  'mint': 'cooling',
  'vanilla': 'vanillic',
  'balsamic': 'resinous',
  'almond': 'nutty',
  'banana': 'fruity',
  'apple': 'fruity',
  'pear': 'fruity',
  'pineapple': 'tropical',
  'coconut': 'tropical',
  'waxy': 'fatty',
  'potato': 'earthy',
  'popcorn': 'toasted',
  'cooked': 'roasted',
  'burnt': 'roasted',
  'caramellic': 'caramel',
  'sweetish': 'sweet',
  'lemon': 'citrus',
  'orange': 'citrus',
  'camphor': 'resinous',
  'pine': 'resinous',
  'clove': 'spicy',
  'cinnamon': 'spicy',
  'anise': 'spicy',
  'garlic': 'sulfurous',
  'onion': 'sulfurous',
  'cabbage': 'sulfurous',
  'plastic': 'solvent',
  'ethereal': 'solvent',
  'wine': 'fermented',
  'rancid': 'cheesy',
  'sour': 'sour',
  'phenolic': 'medicinal',
  'tallow': 'fatty',
  'oily': 'fatty',
  'grass': 'grassy',
  'cucumber': 'green',
  'nut': 'nutty',
  'hazelnut': 'nutty',
  'roast': 'roasted',
  'meat': 'meaty',
  'fish': 'marine',
  'seaweed': 'marine',
  'mushrooms': 'mushroom',
  'honey': 'honey',
  'jam': 'jammy',
  'milky': 'dairy',
  'butter': 'buttery',
  'cheese': 'cheesy',
  'malt': 'malty',
  'bread': 'yeasty',
  'smoke': 'smoky',
  'tobacco': 'woody',
  'leather': 'woody',
};

void main() {
  final ontology = {
    for (final r in _records(_ontologyPath)) r['descriptor_id']!: r,
  };
  final registry = _records(_registryPath);
  final nameToId = <String, String>{};
  final ids = <String>[];
  final rowsById = <String, Map<String, String>>{};
  for (final r in registry) {
    final id = r['ingredient_id']!;
    ids.add(id);
    rowsById[id] = r;
    nameToId[r['canonical_name_fr']!] = id;
  }
  stdout.writeln('Registre : ${ids.length} ingrédients');

  final nutrition = _loadNutrition();
  stdout.writeln('Composition disponible : ${nutrition.length} ingrédients');

  var failures = 0;

  // ---------------------------------------------------------------- D
  final factors = _records('tool/data/process_factors.csv');
  const groups = {
    'vegetable',
    'legume',
    'fruit',
    'cereal',
    'meat',
    'fish',
    'egg',
    'dairy',
    'mushroom',
    'fat',
    'other',
  };
  const methods = {
    'boiled',
    'steamed',
    'sauteed',
    'roasted',
    'grilled',
    'fried',
    'stewed',
    'baked',
  };
  final factorOut = StringBuffer()
    ..writeln(
      'factor_id,food_group,method,yield_factor,fat_uptake_g,fat_retention,'
      'retention,confidence,source,note',
    );
  const nutrientCols = [
    'VITC',
    'THIAMIN',
    'RIBOFLAVINE',
    'NIACINE',
    'VITB6',
    'FOLATES',
    'VITB12',
    'VITA',
    'CAROTENE_B',
    'VITE',
    'VITD',
    'VITB5',
    'MINERALS',
    'K',
  ];
  for (final f in factors) {
    final g = f['food_group']!;
    final m = f['method']!;
    if (!groups.contains(g) || !methods.contains(m)) {
      stderr.writeln('Facteur invalide : $g/$m');
      failures++;
      continue;
    }
    final retention = [
      for (final c in nutrientCols)
        if (double.parse(f[c]!) != 1) '$c:${f[c]}',
    ].join('|');
    factorOut.writeln(
      [
        'PF-$g-$m',
        g,
        m,
        f['yield_factor'],
        f['fat_uptake_g'],
        f['fat_retention'],
        retention,
        f['confidence'],
        _cell(
          'Ordres de grandeur par groupe d\'aliments : USDA Table of '
          'Nutrient Retention Factors Release 6 (2007) ; Bognár (2002)',
        ),
        _cell(f['note'] ?? ''),
      ].join(','),
    );
  }

  // --------------------------------------------------------- B / F
  final unitRules = _rules('tool/data/culinary_units.csv');
  final physRules = _rules('tool/data/physchem_rules.csv');
  // pH mesurés : FDA/CFSAN « Approximate pH of Foods and Food Products »
  // (avril 2007, domaine public) — prioritaires sur les règles.
  final fdaPh = {
    for (final r in _records('tool/data/fda_ph_2007.csv'))
      r['fda_item']!: (double.parse(r['ph_min']!), double.parse(r['ph_max']!)),
  };
  final fdaById = <String, (String, double, double, String, String)>{};
  for (final m in _records('tool/data/fda_ph_map.csv')) {
    final id = nameToId[m['canonical_name_fr']];
    final range = fdaPh[m['fda_item']];
    if (id == null || range == null) {
      throw StateError('fda_ph_map : ligne invalide ${m['canonical_name_fr']}');
    }
    fdaById[id] = (
      m['fda_item']!,
      range.$1,
      range.$2,
      m['match_type']!,
      m['note'] ?? '',
    );
  }
  var fromFda = 0;
  final culinaryOut = StringBuffer()
    ..writeln(
      'ingredient_id,density_g_per_ml,density_note,unit_masses,ph,'
      'ph_confidence,ph_note',
    );
  final componentsOut = StringBuffer()
    ..writeln(
      'ingredient_id,component_id,fraction_g_per_100g,basis,source_refs,'
      'confidence',
    );
  var withDensity = 0;
  var withPh = 0;
  var componentRows = 0;
  final componentIngredients = <String>{};
  final phById = <String, double>{};
  final glutamateById = <String, double>{};
  for (final id in ids) {
    final row = rowsById[id]!;
    final name = _normalize(row['canonical_name_fr']!);
    final cat2 = row['category_level_2'] ?? '';
    final unit = _firstMatch(unitRules, name, cat2);
    final phys = _firstMatch(physRules, name, cat2);
    final density = unit?['density_g_per_ml'] ?? '';
    if (density.isNotEmpty) withDensity++;
    final fda = fdaById[id];
    String fmt(double v) => v.toStringAsFixed(2).replaceAll('.', ',');
    final ph = fda != null
        ? ((fda.$2 + fda.$3) / 2).toStringAsFixed(2)
        : phys?['ph'] ?? '';
    final phConfidence = fda != null
        ? (fda.$4 == 'equivalent' ? '0.85' : '0.7')
        : phys?['confidence'] ?? '';
    final phNote = fda != null
        ? 'FDA/CFSAN 2007, Approximate pH of Foods : « ${fda.$1} » '
              '${fda.$2 == fda.$3 ? fmt(fda.$2) : '${fmt(fda.$2)}–${fmt(fda.$3)}'}'
              '${fda.$5.isEmpty ? '' : ' (${fda.$5})'}'
        : ph.isEmpty
        ? ''
        : 'Estimation par catégorie (règle MaestroPesto) — ${phys!['note']}';
    if (fda != null) fromFda++;
    if (ph.isNotEmpty) {
      withPh++;
      phById[id] = double.parse(ph);
    }
    culinaryOut.writeln(
      [
        id,
        density,
        _cell(density.isEmpty ? '' : unit!['note'] ?? ''),
        unit?['unit_masses'] ?? '',
        ph,
        ph.isEmpty ? '' : phConfidence,
        _cell(phNote),
      ].join(','),
    );

    // Composants fonctionnels : dérivés de la composition + règles.
    final comp = <String, (double, String, String, double)>{};
    final n = nutrition[id];
    void put(String cid, double? v, String basis, String refs, double conf) {
      if (v == null || v < 0.05) return;
      comp.putIfAbsent(
        cid,
        () => (double.parse(v.toStringAsFixed(3)), basis, refs, conf),
      );
    }

    if (phys != null && (phys['components'] ?? '').isNotEmpty) {
      for (final spec in phys['components']!.split('|')) {
        final parts = spec.split('=');
        final cid = parts[0].trim();
        final expr = parts[1].trim();
        double? value;
        if (expr.contains('*')) {
          final e = expr.split('*');
          final base = switch (e[0]) {
            'protein' => n?['protein'],
            'starch' => n?['starch'],
            'sugar' => n?['sugar'],
            'fat' => n?['fat'],
            _ => null,
          };
          value = base == null ? null : base * double.parse(e[1]);
        } else {
          value = switch (expr) {
            'protein' => n?['protein'],
            'starch' => n?['starch'],
            'sugar' => n?['sugar'],
            _ => double.parse(expr),
          };
        }
        put(
          cid,
          value,
          'règle : ${phys['note']}',
          'MAESTRO_INTERNAL|LIT',
          double.parse(phys['confidence'] ?? '0.5'),
        );
      }
    }
    if (n != null) {
      put('LIP_TRIGLY', n['fat'], 'composition : lipides', 'CIQUAL', 0.8);
      put('LIP_SAT', n['fasat'], 'composition : AG saturés', 'CIQUAL', 0.8);
      final ins = (n['fams'] ?? 0) + (n['fapu'] ?? 0);
      put(
        'LIP_INS',
        ins == 0 ? null : ins,
        'composition : AG insaturés',
        'CIQUAL',
        0.8,
      );
      put('POLY_AMIDON', n['starch'], 'composition : amidon', 'CIQUAL', 0.8);
      put('SM_SUCROSE', n['sucs'], 'composition : saccharose', 'CIQUAL', 0.8);
      put('SM_GLU_MONO', n['glus'], 'composition : glucose', 'CIQUAL', 0.8);
      put('SM_FRUCTOSE', n['frus'], 'composition : fructose', 'CIQUAL', 0.8);
      put('SM_SALT', n['salt'], 'composition : sel', 'CIQUAL', 0.8);
      final ca = n['ca'];
      if (ca != null && ca >= 50) {
        put('SM_CA', ca / 1000, 'composition : calcium', 'CIQUAL', 0.8);
      }
    }
    for (final e in comp.entries) {
      componentsOut.writeln(
        [
          id,
          e.key,
          e.value.$1,
          _cell(e.value.$2),
          e.value.$3,
          e.value.$4,
        ].join(','),
      );
      componentRows++;
      componentIngredients.add(id);
      if (e.key == 'SM_GLU') glutamateById[id] = e.value.$1;
    }
  }
  stdout.writeln(
    'Culinaire : densité $withDensity, pH $withPh (dont $fromFda FDA) ; composants : '
    '$componentRows lignes pour ${componentIngredients.length} ingrédients',
  );

  // ---------------------------------------------------------------- E
  final measured = _measuredDescriptors(ontology.keys.toSet());
  final flavorRules = _rules('tool/data/flavor_profiles.csv');
  final flavorOut = StringBuffer()
    ..writeln(
      'ingredient_id,descriptors,context,intensity,evidence_level,'
      'confidence,source_refs,note',
    );
  final evidenceCount = <String, int>{};
  for (final id in ids) {
    final row = rowsById[id]!;
    final name = _normalize(row['canonical_name_fr']!);
    final cat2 = row['category_level_2'] ?? '';
    final rule = _firstMatch(flavorRules, name, cat2);
    final descriptors = <String, double>{};
    var evidence = 'default';
    var confidence = 0.25;
    var context = 'both';
    var intensity = 0.1;
    var note = 'profil neutre par défaut (aucune règle)';
    final refs = <String>{'MAESTRO_INTERNAL'};
    if (rule != null) {
      for (final spec in rule['descriptors']!.split('|')) {
        final parts = spec.split(':');
        final raw = parts[0].trim();
        final d = ontology.containsKey(raw) ? raw : _descriptorAliases[raw];
        if (d == null || !ontology.containsKey(d)) {
          stderr.writeln('Descripteur inconnu « $raw » (${rule['note']})');
          failures++;
          continue;
        }
        final v = double.parse(parts[1]);
        descriptors[d] = (descriptors[d] ?? 0) > v ? descriptors[d]! : v;
      }
      final isFamily = (rule['name_regex'] ?? '').isEmpty;
      evidence = isFamily ? 'family' : 'curated';
      confidence = isFamily ? 0.4 : 0.6;
      context = rule['context'] ?? 'both';
      intensity = double.parse(rule['intensity'] ?? '0.3');
      note = rule['note'] ?? '';
      refs.add(isFamily ? 'FAMILY_RULE' : 'CULINARY_EXPERT');
    }
    final m = measured[id];
    if (m != null && m.isNotEmpty) {
      m.forEach((d, v) {
        descriptors[d] = (descriptors[d] ?? 0) > v ? descriptors[d]! : v;
      });
      evidence = 'measured';
      confidence = 0.75;
      refs.addAll(['FLAVORDB2', 'PUBCHEM']);
      note = '$note ; composés mesurés Phase 3';
    }
    // Saveurs dérivées de la composition mesurée (Ciqual) et du pH.
    final n = nutrition[id];
    void taste(String d, double? v) {
      if (v == null || v <= 0.05) return;
      final clamped = v > 1 ? 1.0 : v;
      if ((descriptors[d] ?? 0) < clamped) descriptors[d] = clamped;
    }

    if (n != null) {
      taste('sweet', n['sugar'] == null ? null : n['sugar']! / 30);
      taste('salty', n['salt'] == null ? null : n['salt']! / 2.5);
      taste('fatty', n['fat'] == null ? null : n['fat']! / 70);
      refs.add('CIQUAL');
    }
    final ph = phById[id];
    if (ph != null && ph < 4.6) taste('sour', (4.6 - ph) / 2.4);
    final glu = glutamateById[id];
    if (glu != null) taste('umami', 0.3 + glu / 1.5);
    evidenceCount[evidence] = (evidenceCount[evidence] ?? 0) + 1;
    final sorted = descriptors.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    flavorOut.writeln(
      [
        id,
        sorted.map((e) => '${e.key}:${e.value.toStringAsFixed(2)}').join('|'),
        context,
        intensity,
        evidence,
        confidence,
        refs.join('|'),
        _cell(note),
      ].join(','),
    );
  }
  stdout.writeln('Profils sensoriels : ${ids.length} — $evidenceCount');

  // Accords curatés.
  final pairingsOut = StringBuffer()
    ..writeln(
      'pair_id,ingredient_a_id,ingredient_b_id,kind,strength,source,note',
    );
  var pairs = 0;
  final unknownNames = <String>{};
  final seenPairs = <String>{};
  for (final p in _records('tool/data/culinary_pairings.csv')) {
    final a = nameToId[p['ingredient_a']];
    final b = nameToId[p['ingredient_b']];
    if (a == null) unknownNames.add(p['ingredient_a']!);
    if (b == null) unknownNames.add(p['ingredient_b']!);
    if (a == null || b == null || a == b) continue;
    final key = ([a, b]..sort()).join('|');
    if (!seenPairs.add(key)) continue;
    final sortedPair = [a, b]..sort();
    pairs++;
    pairingsOut.writeln(
      [
        'CP-${pairs.toString().padLeft(4, '0')}',
        sortedPair[0],
        sortedPair[1],
        p['kind'],
        p['strength'],
        'CULINARY_CURATED',
        _cell(p['note'] ?? ''),
      ].join(','),
    );
  }
  if (unknownNames.isNotEmpty) {
    stdout.writeln(
      'Accords ignorés (ingrédients absents du référentiel) : '
      '${unknownNames.join(' ; ')}',
    );
  }
  stdout.writeln('Accords curatés : $pairs');

  if (failures > 0) {
    stderr.writeln('$failures erreur(s) de validation : aucune écriture.');
    exitCode = 1;
    return;
  }
  Directory(_outDir).createSync(recursive: true);
  File('$_outDir/process_factors.csv').writeAsStringSync('$factorOut');
  File('$_outDir/ingredient_culinary.csv').writeAsStringSync('$culinaryOut');
  File('$_outDir/ingredient_functional_components.csv')
      .writeAsStringSync('$componentsOut');
  File('$_outDir/ingredient_flavor_profiles.csv')
      .writeAsStringSync('$flavorOut');
  File('$_outDir/culinary_pairings.csv').writeAsStringSync('$pairingsOut');
  stdout.writeln('→ 5 fichiers écrits dans $_outDir');
}

/// Composition utile par ingrédient (g ou mg pour 100 g) : Phase 2 si
/// présente, sinon ligne principale Ciqual.
Map<String, Map<String, double>> _loadNutrition() {
  const phase2Tags = {
    'PROTEIN': 'protein',
    'STARCH': 'starch',
    'SUGAR': 'sugar',
    'FAT': 'fat',
    'FAT_SAT': 'fasat',
    'FAT_MONO': 'fams',
    'FAT_POLY': 'fapu',
    'SUCROSE': 'sucs',
    'GLUCOSE': 'glus',
    'FRUCTOSE': 'frus',
    'CA': 'ca',
  };
  const ciqualTags = {
    'PROCNT': 'protein',
    'STARCH': 'starch',
    'SUGAR': 'sugar',
    'FAT': 'fat',
    'FASAT': 'fasat',
    'FAMS': 'fams',
    'FAPU': 'fapu',
    'SUCS': 'sucs',
    'GLUS': 'glus',
    'FRUS': 'frus',
    'SALT': 'salt',
    'CA': 'ca',
  };
  final out = <String, Map<String, double>>{};
  for (final r in _records(_phase2Path)) {
    if ((r['ingredient_state_id'] ?? 'raw') != 'raw') continue;
    final key = phase2Tags[r['component_id']];
    final v = double.tryParse(r['normalized_value'] ?? '');
    if (key == null || v == null) continue;
    out.putIfAbsent(r['ingredient_id']!, () => {})[key] = v;
    if (r['component_id'] == 'NA') {
      out[r['ingredient_id']]!['salt'] = v * 2.5 / 1000;
    }
  }
  // Compléments dans l'ordre de priorité de l'app : Ciqual, puis USDA
  // FoodData Central, puis composition calculée (même format).
  for (final path in [
    _ciqualPath,
    'assets/database-enrichment/usda_nutrition.csv',
    'assets/database-enrichment/computed_nutrition.csv',
  ]) {
    final covered = out.keys.toSet();
    for (final r in _records(path)) {
      if (r['row_kind'] != 'main') continue;
      final id = r['ingredient_id']!;
      if (covered.contains(id)) continue;
      final key = ciqualTags[r['component_id']];
      final v = double.tryParse(r['normalized_value'] ?? '');
      if (key == null || v == null) continue;
      out.putIfAbsent(id, () => {})[key] = v;
    }
  }
  return out;
}

/// Descripteurs issus des composés mesurés Phase 3 (poids 0,8).
Map<String, Map<String, double>> _measuredDescriptors(Set<String> ontology) {
  final compoundDescriptors = <String, List<String>>{};
  for (final r in _records(_aromaCompoundsPath)) {
    compoundDescriptors[r['compound_id']!] = (r['odor_descriptors'] ?? '')
        .split('|')
        .map((s) => s.trim().toLowerCase())
        .where((s) => s.isNotEmpty)
        .toList();
  }
  final out = <String, Map<String, double>>{};
  for (final r in _records(_ingredientAromaPath)) {
    final id = r['ingredient_id']!;
    final conf = double.tryParse(r['confidence'] ?? '') ?? 0.7;
    for (final raw in compoundDescriptors[r['compound_id']] ?? const []) {
      final d = ontology.contains(raw) ? raw : _descriptorAliases[raw];
      // Un descripteur d'odeur « bitter » ou « sweet » n'est pas une
      // saveur : les saveurs viennent de la composition, pas des
      // composés volatils.
      if (d == null || _tasteDescriptors.contains(d)) continue;
      final v = 0.8 * conf;
      final map = out.putIfAbsent(id, () => {});
      if ((map[d] ?? 0) < v) map[d] = v;
    }
  }
  return out;
}

/// Règle compilée : regex de nom et de catégorie.
typedef _Rule = ({RegExp? name, RegExp? category, Map<String, String> row});

List<_Rule> _rules(String path) => [
  for (final r in _records(path))
    (
      name: (r['name_regex'] ?? '').isEmpty ? null : RegExp(r['name_regex']!),
      category: (r['category2_regex'] ?? '').isEmpty
          ? null
          : RegExp(r['category2_regex']!),
      row: r,
    ),
];

Map<String, String>? _firstMatch(
  List<_Rule> rules,
  String normalizedName,
  String category2,
) {
  for (final rule in rules) {
    if (rule.name == null && rule.category == null) continue;
    if (rule.name != null && !rule.name!.hasMatch(normalizedName)) continue;
    if (rule.category != null && !rule.category!.hasMatch(category2)) {
      continue;
    }
    return rule.row;
  }
  return null;
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

/// Lecture CSV (RFC 4180) en maps ; les champs excédentaires d'une ligne
/// (virgules non protégées dans une note) sont recollés dans la
/// dernière colonne.
List<Map<String, String>> _records(String path) {
  final rows = _readCsv(path);
  if (rows.isEmpty) return const [];
  final header = rows.first.map((h) => h.trim()).toList();
  return [
    for (final row in rows.skip(1))
      if (row.any((c) => c.trim().isNotEmpty))
        {
          for (var i = 0; i < header.length; i++)
            header[i]: i < row.length
                ? (i == header.length - 1 && row.length > header.length
                      ? row.sublist(i).join(',')
                      : row[i])
                : '',
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
