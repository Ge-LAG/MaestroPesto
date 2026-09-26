// Générateur des compléments nutritionnels en libre accès.
//
// Comble les ingrédients du référentiel que Ciqual ne couvre pas :
//
// 1. `assets/database-enrichment/usda_nutrition.csv` — USDA FoodData
//    Central (SR Legacy 04/2018 et Foundation Foods 04/2026), données du
//    domaine public (CC0 1.0). Correspondances curatées dans
//    `tool/data/usda_aliases.csv` (équivalent ou valeur approchée
//    justifiée). Conversions vers les conventions Ciqual/UE :
//    glucides = glucides « par différence » − fibres, sel = sodium ×
//    2,5, énergie recalculée avec les coefficients du règlement (UE)
//    1169/2011 annexe XIV.
// 2. `assets/database-enrichment/computed_nutrition.csv` — composition
//    calculée (`tool/data/composition_formulas.csv`) : préparations de
//    base à partir des profils Ciqual de leurs ingrédients (roux,
//    mirepoix, levain…) et substances pures (polyols, acides, sucres),
//    énergie selon l'annexe XIV.
//
// Prérequis : jeux FoodData Central CSV décompressés dans
// `tool/.cache/sr/` et `tool/.cache/fnd/` (voir tool/README ou la
// page « Sources des données » de l'app).
//
// Usage : dart run tool/generate_usda_enrichment.dart

import 'dart:convert';
import 'dart:io';

const _srDir = 'tool/.cache/sr/FoodData_Central_sr_legacy_food_csv_2018-04';
const _fndDir =
    'tool/.cache/fnd/FoodData_Central_foundation_food_csv_2026-04-30';
const _aliasesPath = 'tool/data/usda_aliases.csv';
const _formulasPath = 'tool/data/composition_formulas.csv';
const _ciqualPath = 'assets/database-enrichment/ciqual_nutrition.csv';
const _usdaOut = 'assets/database-enrichment/usda_nutrition.csv';
const _computedOut = 'assets/database-enrichment/computed_nutrition.csv';

const _header =
    'ingredient_id,ingredient_state_id,row_kind,ciqual_alim_code,'
    'aliment_name,component_id,component_name,normalized_value,'
    'normalized_unit,confidence_code,confidence,match_type,match_note,'
    'source_citation';

/// Numéro de nutriment FoodData Central → étiquette INFOODS (Ciqual).
const _nutrientTags = <String, String>{
  '255': 'WATER',
  '207': 'ASH',
  '203': 'PROCNT',
  '204': 'FAT',
  '291': 'FIB-',
  '269': 'SUGAR',
  '209': 'STARCH',
  '210': 'SUCS',
  '211': 'GLUS',
  '212': 'FRUS',
  '213': 'LACS',
  '214': 'MALS',
  '287': 'GALS',
  '221': 'ALC',
  '606': 'FASAT',
  '645': 'FAMS',
  '646': 'FAPU',
  '601': 'CHOL-',
  '307': 'NA',
  '301': 'CA',
  '303': 'FE',
  '304': 'MG',
  '305': 'P',
  '306': 'K',
  '309': 'ZN',
  '312': 'CU',
  '315': 'MN',
  '317': 'SE',
  '320': 'RAE',
  '319': 'RETOL',
  '321': 'CARTB',
  '328': 'VITD-',
  '401': 'VITC',
  '404': 'THIA',
  '405': 'RIBF',
  '406': 'NIA',
  '410': 'PANTAC',
  '415': 'VITB6-',
  '418': 'VITB12',
  '417': 'FOL',
  '431': 'FOLAC',
  '432': 'FOLFD',
  '435': 'FOLDFE',
  '323': 'TOCPHA',
  '430': 'VITK1',
};

/// Unités des étiquettes produites (identiques à Ciqual).
const _units = <String, String>{
  'ENERC': 'kJ',
  'ENERCKCAL': 'kcal',
  'NA': 'mg',
  'CA': 'mg',
  'FE': 'mg',
  'MG': 'mg',
  'P': 'mg',
  'K': 'mg',
  'ZN': 'mg',
  'CU': 'mg',
  'MN': 'mg',
  'SE': 'µg',
  'RAE': 'µg',
  'RETOL': 'µg',
  'CARTB': 'µg',
  'VITD-': 'µg',
  'VITC': 'mg',
  'THIA': 'mg',
  'RIBF': 'mg',
  'NIA': 'mg',
  'PANTAC': 'mg',
  'VITB6-': 'mg',
  'VITB12': 'µg',
  'FOL': 'µg',
  'FOLAC': 'µg',
  'FOLFD': 'µg',
  'FOLDFE': 'µg',
  'TOCPHA': 'mg',
  'VITK1': 'µg',
  'CHOL-': 'mg',
};

void main() {
  final names = _ciqualComponentNames();
  final ciqualProfiles = _ciqualMainProfiles();

  // --- 1. USDA FoodData Central ---------------------------------------
  final aliases = _records(_aliasesPath);
  final wanted = {for (final a in aliases) a['fdc_id']!};
  final foods = <String, ({String description, String dataset})>{};
  final nutrients = <String, String>{}; // nutrient_id → nutrient_nbr
  final values = <String, Map<String, double>>{}; // fdc → nbr → amount
  for (final (dir, dataset) in [
    (_srDir, 'SR Legacy (04/2018)'),
    (_fndDir, 'Foundation Foods (04/2026)'),
  ]) {
    for (final r in _records('$dir/food.csv')) {
      if (wanted.contains(r['fdc_id'])) {
        foods[r['fdc_id']!] = (
          description: r['description']!,
          dataset: dataset,
        );
      }
    }
    for (final r in _records('$dir/nutrient.csv')) {
      nutrients[r['id']!] = r['nutrient_nbr']!;
    }
    _streamCsv('$dir/food_nutrient.csv', (cells, idx) {
      final fdc = cells[idx['fdc_id']!];
      if (!wanted.contains(fdc)) return;
      final nbr = nutrients[cells[idx['nutrient_id']!]];
      final amount = double.tryParse(cells[idx['amount']!]);
      if (nbr == null || amount == null) return;
      values.putIfAbsent(fdc, () => {})[nbr] = amount;
    });
  }

  final usda = StringBuffer('$_header\n');
  var usdaIngredients = 0;
  for (final a in aliases) {
    final fdc = a['fdc_id']!;
    final food = foods[fdc];
    final v = values[fdc];
    if (food == null || v == null) {
      stderr.writeln('FDC $fdc introuvable pour ${a['ingredient_id']}');
      continue;
    }
    final tags = <String, double>{
      for (final e in _nutrientTags.entries)
        if (v[e.key] != null) e.value: v[e.key]!,
    };
    // Glucides UE = glucides par différence (ou par somme) − fibres.
    final carbDiff = v['205'] ?? v['205.2'];
    if (carbDiff != null) {
      tags['CHOAVL'] = _round(
        (carbDiff - (tags['FIB-'] ?? 0)).clamp(0, 100).toDouble(),
      );
    }
    if (tags['NA'] != null) tags['SALT'] = _round(tags['NA']! * 2.5 / 1000);
    _euEnergy(tags);
    final desc = food.description.toLowerCase();
    final state = desc.contains('cooked') || desc.contains('boiled')
        ? 'boiled'
        : 'raw';
    final citation =
        'USDA FoodData Central, ${food.dataset}, FDC ID $fdc (CC0 1.0) — '
        'glucides hors fibres et énergie recalculés (UE 1169/2011)';
    for (final e in tags.entries) {
      usda.writeln(
        _row(
          ingredientId: a['ingredient_id']!,
          state: state,
          code: 'FDC$fdc',
          alimentName: food.description,
          tag: e.key,
          name: names[e.key] ?? e.key,
          value: e.value,
          confidenceCode: 'USDA',
          confidence: 0.8,
          matchType: a['match_type']!,
          matchNote: a['note'] ?? '',
          citation: citation,
        ),
      );
    }
    usdaIngredients++;
  }
  File(_usdaOut).writeAsStringSync(usda.toString(), encoding: utf8);
  stdout.writeln('$_usdaOut : $usdaIngredients ingrédients.');

  // --- 2. Composition calculée ----------------------------------------
  final computed = StringBuffer('$_header\n');
  var computedIngredients = 0;
  for (final f in _records(_formulasPath)) {
    final id = f['ingredient_id']!;
    final tags = <String, double>{};
    if (f['kind'] == 'mix') {
      final parts = [
        for (final p in f['definition']!.split('|'))
          (p.split(':')[0], double.parse(p.split(':')[1])),
      ];
      final total = parts.fold<double>(0, (s, p) => s + p.$2);
      // Une étiquette n'est retenue que si tous les composants la
      // renseignent (jamais de zéro fabriqué).
      final allTags = <String>{
        for (final (cid, _) in parts) ...?ciqualProfiles[cid]?.keys,
      };
      for (final tag in allTags) {
        if (parts.every((p) => ciqualProfiles[p.$1]?[tag] != null)) {
          tags[tag] = _round(
            parts.fold<double>(
                  0,
                  (s, p) => s + ciqualProfiles[p.$1]![tag]! * p.$2,
                ) /
                total,
          );
        }
      }
      if (parts.any((p) => ciqualProfiles[p.$1] == null)) {
        stderr.writeln('$id : composant sans profil Ciqual, ignoré');
        continue;
      }
    } else {
      for (final p in f['definition']!.split('|')) {
        final kv = p.split(':');
        tags[kv[0]] = double.parse(kv[1]);
      }
      if (tags['NA'] != null) tags['SALT'] = _round(tags['NA']! * 2.5 / 1000);
      _euEnergy(tags, keepGiven: true);
    }
    final citation = '${f['reference']} — ${f['note']}';
    for (final e in tags.entries) {
      computed.writeln(
        _row(
          ingredientId: id,
          state: 'raw',
          code: 'CALC',
          alimentName: f['note']!,
          tag: e.key,
          name: names[e.key] ?? e.key,
          value: e.value,
          confidenceCode: 'CALC',
          confidence: 0.7,
          matchType: 'computed',
          matchNote: f['note']!,
          citation: citation,
        ),
      );
    }
    computedIngredients++;
  }
  File(_computedOut).writeAsStringSync(computed.toString(), encoding: utf8);
  stdout.writeln('$_computedOut : $computedIngredients ingrédients.');
}

/// Énergie selon le règlement (UE) 1169/2011, annexe XIV : glucides 4,
/// polyols 2,4 (érythritol 0 : valeur donnée), protéines 4, lipides 9,
/// fibres 2, alcool 7, acides organiques 3 kcal/g.
void _euEnergy(Map<String, double> t, {bool keepGiven = false}) {
  final polyols = t['POLYL'] ?? 0;
  final kcal =
      4 * ((t['CHOAVL'] ?? 0) - polyols) +
      2.4 * polyols +
      4 * (t['PROCNT'] ?? 0) +
      9 * (t['FAT'] ?? 0) +
      2 * (t['FIB-'] ?? 0) +
      7 * (t['ALC'] ?? 0) +
      3 * (t['OA'] ?? 0);
  final kj =
      17 * ((t['CHOAVL'] ?? 0) - polyols) +
      10 * polyols +
      17 * (t['PROCNT'] ?? 0) +
      37 * (t['FAT'] ?? 0) +
      8 * (t['FIB-'] ?? 0) +
      29 * (t['ALC'] ?? 0) +
      13 * (t['OA'] ?? 0);
  if (keepGiven && t['ENERCKCAL'] != null) {
    t['ENERC'] = _round(t['ENERCKCAL']! * 4.184);
    return;
  }
  t['ENERCKCAL'] = _round(kcal);
  t['ENERC'] = _round(kj);
}

String _row({
  required String ingredientId,
  required String state,
  required String code,
  required String alimentName,
  required String tag,
  required String name,
  required double value,
  required String confidenceCode,
  required double confidence,
  required String matchType,
  required String matchNote,
  required String citation,
}) => [
  ingredientId,
  state,
  'main',
  code,
  _cell(alimentName),
  tag,
  _cell(name),
  value.toString(),
  _units[tag] ?? 'g',
  confidenceCode,
  confidence.toString(),
  matchType,
  _cell(matchNote),
  _cell(citation),
].join(',');

double _round(double v) => double.parse(v.toStringAsFixed(3));

/// Libellés français des étiquettes (ceux de Ciqual).
Map<String, String> _ciqualComponentNames() => {
  for (final r in _records(_ciqualPath))
    r['component_id']!: r['component_name']!,
  'SALT': 'Sel chlorure de sodium (g/100 g)',
  'POLYL': 'Polyols totaux (g/100 g)',
  'OA': 'Acides organiques (g/100 g)',
};

/// Profils Ciqual « main » crus par ingrédient (étiquette → valeur).
Map<String, Map<String, double>> _ciqualMainProfiles() {
  final out = <String, Map<String, double>>{};
  for (final r in _records(_ciqualPath)) {
    if (r['row_kind'] != 'main') continue;
    final v = double.tryParse(r['normalized_value'] ?? '');
    if (v == null) continue;
    out.putIfAbsent(r['ingredient_id']!, () => {})[r['component_id']!] = v;
  }
  out.values.forEach(_massBalance);
  return out;
}

/// Même règle que l'app (NutritionRepository.deriveByMassBalance) :
/// constituants connus ≥ 97 g/100 g → constituants absents à 0 ; sel
/// déduit du sodium.
void _massBalance(Map<String, double> t) {
  const mass = ['WATER', 'PROCNT', 'CHOAVL', 'FAT', 'FIB-', 'ALC', 'SALT'];
  if (t['SALT'] == null && t['NA'] != null) {
    t['SALT'] = _round(t['NA']! * 2.5 / 1000);
  }
  final known = mass.fold<double>(0, (s, k) => s + (t[k] ?? 0));
  if (known >= 97) {
    for (final k in mass) {
      if (k != 'WATER') t.putIfAbsent(k, () => 0);
    }
  }
  if ((t['CHOAVL'] ?? 1) < 0.5) t.putIfAbsent('SUGAR', () => 0);
  if ((t['FAT'] ?? 1) < 0.5) t.putIfAbsent('FASAT', () => 0);
}

void _streamCsv(
  String path,
  void Function(List<String> cells, Map<String, int> idx) onRow,
) {
  Map<String, int>? idx;
  for (final line in File(path).readAsLinesSync(encoding: utf8)) {
    final cells = _splitLine(line);
    if (idx == null) {
      idx = {for (var i = 0; i < cells.length; i++) cells[i]: i};
      continue;
    }
    onRow(cells, idx);
  }
}

List<String> _splitLine(String line) {
  final cells = <String>[];
  final cell = StringBuffer();
  var inQuotes = false;
  for (var i = 0; i < line.length; i++) {
    final ch = line[i];
    if (inQuotes) {
      if (ch == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
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
  cells.add(cell.toString());
  return cells;
}

List<Map<String, String>> _records(String path) {
  final lines = File(path).readAsLinesSync(encoding: utf8);
  if (lines.isEmpty) return const [];
  final header = _splitLine(lines.first).map((h) => h.trim()).toList();
  return [
    for (final line in lines.skip(1))
      if (line.trim().isNotEmpty)
        () {
          final row = _splitLine(line);
          return {
            for (var i = 0; i < header.length; i++)
              header[i]: i < row.length ? row[i] : '',
          };
        }(),
  ];
}

String _cell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
