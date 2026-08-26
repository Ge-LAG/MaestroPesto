// Générateur d'enrichissement nutritionnel Ciqual → CSV (session
// 2026-08-26, retour PO : « compléter les bases nutritionnelles en
// citant les sources »).
//
// Lit les XML ANSES Ciqual 2025-11-03 du repo (`ciqual/`, ~64 Mo pour
// compo) et le référentiel Phase 1, et produit un CSV filtré :
//
//   assets/database-enrichment/ciqual_nutrition.csv
//
// couvrant uniquement les ingrédients Phase 1 qui ont un `ciqual_ids`
// (104 mappings). Chaque valeur transporte sa citation exacte
// (`sources.xml`) et son code de confiance Ciqual, restitués in-app
// par le panneau nutrition. `database-metier/` et `ciqual/` restent
// intacts (données dérivées versionnées à part).
//
// Usage : dart run tool/generate_ciqual_enrichment.dart
// (chemins surchargeables en arguments : <ciqualDir> <registryCsv> <outCsv>)

import 'dart:convert';
import 'dart:io';

/// Constituants retenus : const_code Ciqual → (tag interne, unité).
/// Choix par code précis pour l'énergie (327 kJ / 328 kcal = Règlement
/// UE 1169/2011) et le sel (10004, sans tag INFOODS).
const Map<String, (String tag, String unit)> selectedByCode = {
  '327': ('ENERC', 'kJ'),
  '328': ('ENERCKCAL', 'kcal'),
  '10004': ('SALT', 'g'),
};

/// code_INFOODS → (tag interne, unité).
const Map<String, (String tag, String unit)> selectedByInfoods = {
  'PROCNT': ('PROTEIN', 'g'),
  'FAT': ('FAT', 'g'),
  'FASAT': ('FAT_SAT', 'g'),
  'CHOAVL': ('CARB', 'g'),
  'SUGAR': ('SUGAR', 'g'),
  'FIBT': ('FIBER', 'g'),
  'NA': ('NA', 'mg'),
  'WATER': ('WATER', 'g'),
};

/// Mots trop génériques ignorés par le garde-fou de cohérence
/// nom d'ingrédient ↔ nom d'aliment Ciqual.
const _stopwords = {
  'cru',
  'crue',
  'cuits',
  'cuite',
  'frais',
  'fraiche',
  'fraîche',
  'sec',
  'seche',
  'sèche',
  'seches',
  'sèches',
  'raw',
  'cooked',
  'fresh',
  'dry',
  'dried',
  'et',
  'de',
  'la',
  'le',
  'les',
  'des',
  'du',
  'aux',
  'au',
  'a',
  'en',
  'sans',
  'avec',
  'pour',
  '100',
  'g',
};

/// Codes écartés malgré un tag INFOODS valide : 25000 = « Protéines,
/// N x facteur de Jones » — on privilégie 25003 « Protéines, N x 6.25 »
/// (facteur du règlement UE 1169/2011, cohérent avec l'énergie 327/328).
const Set<String> deniedCodes = {'25000'};

/// Code de confiance Ciqual → confiance [0,1] (mapping documenté,
/// conservateur).
const Map<String, double> confidenceByCode = {
  'A': 0.95,
  'B': 0.85,
  'C': 0.75,
  'D': 0.6,
  '*': 0.5,
};

void main(List<String> args) {
  final ciqualDir = args.isNotEmpty ? args[0] : 'ciqual';
  final registryPath = args.length > 1
      ? args[1]
      : 'database-metier/phase1-referentiel/ingredient_registry_v1.csv';
  final outPath = args.length > 2
      ? args[2]
      : 'assets/database-enrichment/ciqual_nutrition.csv';

  // 1. Dictionnaire des constituants : const_code → (nom FR, INFOODS).
  final constNames = <String, String>{};
  final constInfoods = <String, String>{};
  _parseXmlBlocks('$ciqualDir/const_2025_11_03.xml', 'CONST', (fields) {
    final code = fields['const_code'] ?? '';
    if (code.isEmpty) return;
    constNames[code] = fields['const_nom_fr'] ?? '';
    constInfoods[code] = fields['code_INFOODS'] ?? '';
  });
  stdout.writeln('const.xml : ${constNames.length} constituants lus');

  // 2. Sélection finale : const_code → (tag, unité).
  final selected = <String, (String, String)>{};
  for (final code in constNames.keys) {
    if (deniedCodes.contains(code)) continue;
    final byCode = selectedByCode[code];
    if (byCode != null) {
      selected[code] = byCode;
      continue;
    }
    final byInfoods = selectedByInfoods[constInfoods[code]];
    if (byInfoods != null) selected[code] = byInfoods;
  }
  // Certaines éditions Ciqual taguent les fibres autrement (FIB-) :
  // fallback par nom FR.
  if (!selected.values.any((s) => s.$1 == 'FIBER')) {
    constNames.forEach((code, name) {
      if (name.toLowerCase().startsWith('fibres') &&
          !selected.containsKey(code)) {
        selected[code] = selectedByInfoods['FIBT']!;
      }
    });
  }
  stdout.writeln(
    'Constituants retenus : '
    '${selected.entries.map((e) => '${e.key}→${e.value.$1}').join(', ')}',
  );

  // 3. Citations sources : source_code → référence complète.
  final citations = <String, String>{};
  _parseXmlBlocks('$ciqualDir/sources_2025_11_03.xml', 'SOURCES', (fields) {
    final code = fields['source_code'] ?? '';
    final ref = fields['ref_citation'] ?? '';
    if (code.isNotEmpty && ref.isNotEmpty) citations[code] = ref;
  });
  stdout.writeln('sources.xml : ${citations.length} citations lisibles');

  // 4. Référentiel Phase 1 : ingredient_id → ciqual_ids.
  final registry = _readCsv(registryPath);
  final header = registry.first;
  final idCol = header.indexOf('ingredient_id');
  final nameCol = header.indexOf('canonical_name_fr');
  final ciqualCol = header.indexOf('ciqual_ids');
  if (idCol == -1 || nameCol == -1 || ciqualCol == -1) {
    stderr.writeln('Colonnes manquantes dans le registre');
    exitCode = 1;
    return;
  }
  final ingredientCiqual = <String, String>{};
  final ingredientNames = <String, String>{};
  for (final row in registry.skip(1)) {
    if (row.length <= ciqualCol) continue;
    final id = row[idCol].trim();
    final ciqual = row[ciqualCol].trim();
    if (id.isEmpty || ciqual.isEmpty) continue;
    // Plusieurs codes possibles séparés par '|' : on garde le premier
    // (l'aliment Ciqual le plus proche du canonique).
    final first = ciqual
        .split('|')
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (first.isNotEmpty) {
      ingredientCiqual[id] = first;
      ingredientNames[id] = row[nameCol].trim();
    }
  }
  stdout.writeln(
    'Registre : ${ingredientCiqual.length} ingrédients avec ciqual_ids',
  );

  // 5. Noms des aliments Ciqual (traçabilité humaine du CSV).
  final alimNames = <String, String>{};
  _parseXmlBlocks('$ciqualDir/alim_2025_11_03.xml', 'ALIM', (fields) {
    final code = fields['alim_code'] ?? '';
    final name = fields['alim_nom_fr'] ?? '';
    if (code.isNotEmpty && name.isNotEmpty) alimNames[code] = name;
  });
  stdout.writeln('alim.xml : ${alimNames.length} aliments lus');

  // 6. Résolution ingrédient → aliment Ciqual. Les ciqual_ids du
  // référentiel Phase 1 proviennent d'une autre édition de la table
  // (la numérotation 2025-11-03 a changé : ex. le code de la banane
  // pointe vers l'abricot). Stratégie :
  //   a) code direct s'il est cohérent avec le nom (garde-fou tokens) ;
  //   b) sinon, résolution PAR NOM dans alim.xml (score de tokens
  //      significatifs, préférence à l'état cru et au nom le plus
  //      court), résolution tracée dans la sortie du script.
  final resolvedAlim = <String, String>{};
  var byCode = 0;
  var byName = 0;
  var unresolved = 0;
  final alimTokens = <String, Set<String>>{
    for (final e in alimNames.entries) e.key: _significantTokens(e.value),
  };
  // Meilleur candidat par ingrédient, avant dédoublonnage.
  final candidate =
      <String, ({String code, int score, bool full, int prefix})>{};
  for (final entry in ingredientCiqual.entries) {
    final ingredientId = entry.key;
    final ingredientName = ingredientNames[ingredientId] ?? '';
    final code = entry.value;
    if (alimNames.containsKey(code) &&
        _namesCoherent(ingredientName, alimNames[code]!)) {
      resolvedAlim[ingredientId] = code;
      byCode++;
      continue;
    }
    // Résolution par nom : le meilleur score de tokens.
    final wanted = _significantTokens(ingredientName);
    final wantedOrdered = _significantTokensInOrder(ingredientName);
    if (wanted.isEmpty || wantedOrdered.isEmpty) {
      unresolved++;
      continue;
    }
    final head = wantedOrdered.first;
    String? bestCode;
    var bestScore = 0;
    var bestFull = false;
    var bestPrefix = 0;
    var bestRawBias = -1;
    var bestLength = 1 << 30;
    alimTokens.forEach((alimCode, tokens) {
      final score = wanted.where(tokens.contains).length;
      if (score == 0) return;
      // Match complet (tous les tokens) OU match partiel à 1 mot près
      // mais porté par le mot-tête de l'ingrédient (ex. « Œuf de
      // poule » → « Oeuf cru » : tête « oeuf » ; « Anis vert » →
      // « Haricot vert » rejeté : tête « anis » absente).
      final full = score == wanted.length;
      final partialOk = score == wanted.length - 1 && tokens.contains(head);
      if (!full && !partialOk) return;
      final prefix =
          _significantTokensInOrder(alimNames[alimCode] ?? '').first == head
          ? 1
          : 0;
      final rawBias = _isRawName(alimNames[alimCode] ?? '') ? 1 : 0;
      final length = tokens.length;
      final better =
          score > bestScore ||
          (score == bestScore && full && !bestFull) ||
          (score == bestScore &&
              full == bestFull &&
              (prefix > bestPrefix ||
                  (prefix == bestPrefix &&
                      (rawBias > bestRawBias ||
                          (rawBias == bestRawBias && length < bestLength)))));
      if (better) {
        bestCode = alimCode;
        bestScore = score;
        bestFull = full;
        bestPrefix = prefix;
        bestRawBias = rawBias;
        bestLength = length;
      }
    });
    if (bestCode != null) {
      candidate[ingredientId] = (
        code: bestCode!,
        score: bestScore,
        full: bestFull,
        prefix: bestPrefix,
      );
    } else {
      unresolved++;
      stdout.writeln(
        '  ✗ non résolu : $ingredientName (code $code → '
        '"${alimNames[code] ?? 'inconnu'}")',
      );
    }
  }
  // Dédoublonnage : deux ingrédients ne doivent pas résoudre vers le
  // même aliment (ex. « Maïs grain » et « Farine de maïs ») — le
  // candidat au meilleur match garde l'aliment, l'autre est écarté.
  final alimOwner = <String, String>{};
  final ownerQuality = <String, int>{};
  final sortedIds = candidate.keys.toList()..sort();
  for (final id in sortedIds) {
    final c = candidate[id]!;
    final quality = c.score * 4 + (c.full ? 2 : 0) + c.prefix;
    final owner = alimOwner[c.code];
    if (owner == null || quality > ownerQuality[owner]!) {
      if (owner != null) {
        stdout.writeln(
          '  ⚠ collision : "${ingredientNames[owner]}" perd '
          '"${alimNames[c.code]}" au profit de "${ingredientNames[id]}"',
        );
      }
      alimOwner[c.code] = id;
      ownerQuality[id] = quality;
    } else {
      stdout.writeln(
        '  ⚠ collision : "${ingredientNames[id]}" écarté de '
        '"${alimNames[c.code]}" (déjà pris par "${ingredientNames[owner]}")',
      );
    }
  }
  for (final e in alimOwner.entries) {
    resolvedAlim[e.value] = e.key;
    byName++;
    stdout.writeln(
      '  ↻ résolu par nom : ${ingredientNames[e.value]} → '
      '"${alimNames[e.key]}" (${e.key}, score ${candidate[e.value]!.score})'
      ' [code registre ${ingredientCiqual[e.value]} incohérent : '
      '"${alimNames[ingredientCiqual[e.value]] ?? '?'}"]',
    );
  }
  stdout.writeln(
    'Résolution : $byCode par code direct, $byName par nom, '
    '$unresolved non résolus',
  );

  final ciqualToIngredient = <String, String>{
    for (final e in resolvedAlim.entries) e.value: e.key,
  };
  final out = StringBuffer()
    ..writeln(
      'ingredient_id,ciqual_alim_code,aliment_name,component_id,'
      'component_name,normalized_value,normalized_unit,confidence_code,'
      'confidence,source_citation',
    );
  var kept = 0;
  var scanned = 0;
  var missingValue = 0;
  final enrichedIngredients = <String>{};
  _parseXmlBlocks('$ciqualDir/compo_2025_11_03.xml', 'COMPO', (fields) {
    scanned++;
    final alim = fields['alim_code'] ?? '';
    final ingredientId = ciqualToIngredient[alim];
    if (ingredientId == null) return;
    final sel = selected[fields['const_code'] ?? ''];
    if (sel == null) return;
    final raw = fields['teneur'] ?? '';
    if (raw.isEmpty) {
      missingValue++;
      return;
    }
    final value = double.tryParse(raw.replaceAll(',', '.'));
    if (value == null) {
      missingValue++;
      return;
    }
    final confidenceCode = fields['code_confiance'] ?? '';
    final confidence = confidenceByCode[confidenceCode] ?? 0.5;
    final citation =
        citations[fields['source_code'] ?? ''] ??
        'ANSES — table Ciqual 2025-11-03';
    enrichedIngredients.add(ingredientId);
    out
      ..write(ingredientId)
      ..write(',')
      ..write(alim)
      ..write(',')
      ..write(_csvCell(alimNames[alim] ?? ''))
      ..write(',')
      ..write(sel.$1)
      ..write(',')
      ..write(_csvCell(constNames[fields['const_code']] ?? ''))
      ..write(',')
      ..write(value)
      ..write(',')
      ..write(sel.$2)
      ..write(',')
      ..write(confidenceCode)
      ..write(',')
      ..write(confidence)
      ..write(',')
      ..writeln(_csvCell('ANSES Ciqual 2025-11-03 — $citation'));
    kept++;
  });

  // 7. Écriture.
  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(out.toString(), flush: true);

  final kb = (outFile.lengthSync() / 1024).toStringAsFixed(0);
  stdout
    ..writeln('compo.xml : $scanned lignes scannées, $missingValue sans valeur')
    ..writeln(
      '→ $outPath : $kept records pour ${enrichedIngredients.length} '
      'ingrédients enrichis ($kb Ko)',
    );
}

/// Vrai si le nom Ciqual désigne l'état brut (« cru », « crue », ou
/// aucun qualificatif de préparation cuit/séché/concentré).
bool _isRawName(String alimName) {
  final n = alimName.toLowerCase();
  if (n.contains('cru')) return true;
  return !RegExp(
    'cuit|cuite|bouilli|bouillie|roti|rôtie|grille|grillée|sec|sèche|'
    'seche|concentre|concentré|surgel|frit|frite|braisé|braise|'
    'sterilise|stérilisé|appertisé|en conserve|en sirop|confit',
  ).hasMatch(n);
}

/// Vrai si le nom canonique FR de l'ingrédient et le nom Ciqual de
/// l'aliment partagent au moins un mot significatif (normalisé sans
/// accents, stopwords exclus).
bool _namesCoherent(String ingredientName, String alimName) {
  final a = _significantTokens(ingredientName);
  final b = _significantTokens(alimName);
  return a.any(b.contains);
}

Set<String> _significantTokens(String name) {
  return {
    for (final token in _significantTokensInOrder(name))
      if (token.length > 2 && !_stopwords.contains(token)) token,
  };
}

/// Tokens significatifs dans l'ordre du nom (le mot-tête sert de
/// critère pour les matchs partiels).
List<String> _significantTokensInOrder(String name) {
  final normalized = _normalizeText(name);
  return [
    for (final token in normalized.split(RegExp(r'[^a-z0-9]+')))
      if (token.length > 2 && !_stopwords.contains(token)) token,
  ];
}

String _normalizeText(String name) {
  return name
      .toLowerCase()
      .replaceAll('œ', 'oe')
      .replaceAll('æ', 'ae')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[àâä]'), 'a')
      .replaceAll(RegExp(r'[ùûü]'), 'u')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ïî]'), 'i')
      .replaceAll(RegExp(r'[ç]'), 'c');
}

/// Parseur minimal des XML plats Ciqual : chaque champ d'un bloc
/// `<RECORD>` est sur sa propre ligne (`<tag> valeur </tag>`). Les
/// champs absents sont notés `<tag missing="…" />` et ne matchent pas.
void _parseXmlBlocks(
  String path,
  String recordTag,
  void Function(Map<String, String>) onRecord,
) {
  var fields = <String, String>{};
  final fieldPattern = RegExp(r'^<([A-Za-z_0-9]+)>(.*)</\1>$');
  for (final rawLine in File(path).readAsLinesSync(encoding: utf8)) {
    final line = rawLine.trim();
    if (line.startsWith('<$recordTag')) {
      fields = {};
    } else if (line.startsWith('</$recordTag>')) {
      onRecord(fields);
    } else {
      final m = fieldPattern.firstMatch(line);
      if (m != null) fields[m.group(1)!] = _decodeXml(m.group(2)!.trim());
    }
  }
}

String _decodeXml(String value) => value
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&apos;', "'");

/// Mini parseur CSV (RFC 4180) : gère les guillemets et les virgules
/// internes du registre Phase 1.
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

String _csvCell(String value) {
  if (value.contains(',') || value.contains('"') || value.contains('\n')) {
    return '"${value.replaceAll('"', '""')}"';
  }
  return value;
}
