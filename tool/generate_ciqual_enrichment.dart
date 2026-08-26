// Générateur d'enrichissement nutritionnel Ciqual → CSV (session
// 2026-08-26, retour PO : « compléter les bases nutritionnelles en
// citant les sources »).
//
// Lit les XML ANSES Ciqual 2025-11-03 du repo (`ciqual/`, ~64 Mo pour
// compo) et le référentiel Phase 1, et produit un CSV filtré :
//
//   assets/database-enrichment/ciqual_nutrition.csv
//
// couvrant TOUS les ingrédients Phase 1 (retour PO n°4 : « compléter
// à 100 % ») — par code Ciqual direct s'il est cohérent, sinon par
// résolution de nom. Chaque valeur transporte sa citation exacte
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

/// Codes écartés : autres expressions de l'énergie (N x facteur de
/// Jones — le règlement UE 1169/2011 est retenu via 327/328) et
/// protéines Jones (25000 ; on garde 25003 = N x 6.25).
const Set<String> deniedCodes = {'25000', '332', '333'};

/// Retour PO n°3 (exhaustivité) : TOUS les autres constituants du
/// dictionnaire sont exportés (vitamines, minéraux, alcool, AG
/// détaillés, sucres individuels, amidon, polyols, cholestérol…).
/// Tag = code_INFOODS s'il existe, sinon const_code. L'unité est
/// extraite du nom FR (« …(mg/100 g) »).

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
  // Qualificatifs d'état/procédé (retour n°4 : gardés hors tokens pour
  // ne pas bloquer les matchs — « Amande torréfiée » → amande crue,
  // « Soja cuit » → « Soja, graine entière », « Melon, chair sans
  // peau, sans pépins, cru » → « Melon »).
  'non',
  'iode',
  'iodee',
  'fluore',
  'fluoree',
  'grille',
  'grillee',
  'torrefie',
  'torrefiee',
  'fume',
  'fumee',
  'sale',
  'salee',
  'moulu',
  'moulue',
  'chair',
  'peau',
  'pepins',
  'graine',
  'graines',
  'entiere',
  'entier',
  'pasteurise',
  'pasteurisee',
  'dehydrate',
  'dehydratee',
  'preemballe',
  'preemballee',
  'appertise',
  'appertisee',
};

/// Mots qui désignent un AUTRE aliment que l'ingrédient cherché : un
/// candidat Ciqual qui en contient un (hors tokens de l'ingrédient
/// lui-même) est écarté (« Citron vert cru » doit ignorer « Jus de
/// citron vert, frais » et « Citron, zeste, cru »).
const _transformationDenylist = {
  'jus',
  'zeste',
  'pomme',
  'coco',
  'multifruit',
  'fourrage',
  'fourre',
  'praline',
  'melange',
  'combinee',
};

/// Têtes génériques pour lesquelles un match PARTIEL (seule la tête
/// correspond) est trompeur : « Beurre de cajou » ne doit jamais
/// résoudre vers le beurre laitier, « Huile de carthame » vers une
/// autre huile. Seul le match complet reste admis pour ces têtes.
const _categoryHeads = {
  'beurre',
  'huile',
  'lait',
  'farine',
  'creme',
  'fromage',
  'fond',
  'bouillon',
  'sirop',
  'pate',
  'sucre',
  'sel',
  'miel',
  'cafe',
  'the',
  'vin',
  'vinaigre',
  'moutarde',
  'sauce',
  'poudre',
  'flocon',
  'graisse',
  'levure',
  'gelee',
  'confiture',
  'chocolat',
  'cacao',
};

/// Têtes hypernymes : l'aliment Ciqual nomme la CATÉGORIE puis le
/// membre (« Champignon, cèpe, cru », « Haricot flageolet, sec ») —
/// la tête ne peut pas être un mot de l'ingrédient, ce n'est pas une
/// erreur de résolution.
const _hypernymHeads = {'champignon', 'haricot', 'clam', 'praire'};

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
    // Exhaustivité (retour PO n°3) : tous les autres constituants.
    // Tag = code_INFOODS s'il existe, sinon const_code ; l'unité est
    // extraite du nom FR (« Fibres alimentaires (g/100 g) » → g).
    final name = constNames[code] ?? '';
    final infoods = constInfoods[code] ?? '';
    final tag = infoods.isNotEmpty ? infoods : code;
    selected[code] = (tag, _unitFromName(name));
  }
  stdout.writeln(
    'Constituants retenus : ${selected.length} '
    '(exhaustif — retour PO n°3)',
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
    if (id.isEmpty) continue;
    final name = row[nameCol].trim();
    if (name.isEmpty) continue;
    // Retour PO n°4 : TOUS les ingrédients du registre sont traités
    // (les 450 sans ciqual_ids passent par la résolution par nom).
    ingredientNames[id] = name;
    final ciqual = row[ciqualCol].trim();
    // Plusieurs codes possibles séparés par '|' : on garde le premier
    // (l'aliment Ciqual le plus proche du canonique).
    final first = ciqual
        .split('|')
        .map((s) => s.trim())
        .firstWhere((s) => s.isNotEmpty, orElse: () => '');
    if (first.isNotEmpty) ingredientCiqual[id] = first;
  }
  stdout.writeln(
    'Registre : ${ingredientNames.length} ingrédients, dont '
    '${ingredientCiqual.length} avec ciqual_ids',
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
  // Pré-affectations curatées AVANT la résolution par nom, quand
  // l'entrée Ciqual évidente risque d'être captée par un autre
  // ingrédient (« Chocolat noir 70% » doit prendre l'entrée 70 % de
  // cacao, pas le 50 %).
  const preAssignments = {
    'Chocolat noir 70%': 'Chocolat noir 70 % de cacao environ, de dégustation',
  };
  for (final pre in preAssignments.entries) {
    String? ingredientId;
    for (final e in ingredientNames.entries) {
      if (e.value == pre.key) {
        ingredientId = e.key;
        break;
      }
    }
    if (ingredientId == null) continue;
    final target = _normalizeText(pre.value);
    for (final alim in alimNames.entries) {
      final n = _normalizeText(alim.value);
      if (n == target || n.startsWith(target)) {
        resolvedAlim[ingredientId] = alim.key;
        stdout.writeln(
          '  ⌂ pré-affectation curatée : ${pre.key} → '
          '"${alim.value}" (${alim.key})',
        );
        break;
      }
    }
  }
  // Tous les candidats qualifiés par ingrédient, triés par qualité —
  // le dédoublonnage pourra replier le perdant d'une collision sur
  // son candidat suivant (ex. « Amande torréfiée » → « Amande,
  // grillée, salée » quand « Amande crue » a pris l'amande crue).
  final candidates =
      <
        String,
        List<
          ({
            String code,
            int score,
            bool full,
            int prefix,
            int rawBias,
            int length,
            bool exact,
          })
        >
      >{};
  for (final entry in ingredientNames.entries) {
    final ingredientId = entry.key;
    final ingredientName = entry.value;
    if (resolvedAlim.containsKey(ingredientId)) continue;
    final code = ingredientCiqual[ingredientId];
    if (code != null &&
        alimNames.containsKey(code) &&
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
    final ingredientNorm = _normalizeText(ingredientName).trim();
    final list =
        <
          ({
            String code,
            int score,
            bool full,
            int prefix,
            int rawBias,
            int length,
            bool exact,
          })
        >[];
    alimTokens.forEach((alimCode, tokens) {
      final score = wanted.where(tokens.contains).length;
      if (score == 0) return;
      final prefix =
          _significantTokensInOrder(alimNames[alimCode] ?? '').first == head
          ? 1
          : 0;
      // Les huiles ne doivent résoudre que vers des entrées d'huile
      // (« Huile d'olive » → « Olive noire, à l'huile (grecque) »
      // rejeté : la tête Ciqual doit être « huile »).
      if (head == 'huile' && prefix == 0) return;
      // Match complet (tous les tokens) OU match partiel à 1 mot près
      // mais porté par le mot-tête de l'ingrédient (ex. « Œuf de
      // poule » → « Oeuf cru » : tête « oeuf » ; « Anis vert » →
      // « Haricot vert » rejeté : tête « anis » absente).
      final full = score == wanted.length;
      final extras = tokens.difference(wanted);
      // Garde-fous retour n°4 : un match partiel ne doit apporter
      // AUCUN aliment nouveau (« Huile de carthame » → « Huile
      // d'amande » rejeté) ni porter une tête de catégorie générique
      // (« Beurre de cajou » → « Beurre à 80% MG » rejeté) ; un match
      // complet ne doit pas tomber sur un plat composé long
      // (« Sucre glace » → « Corne de gazelle … sucre glace ») ni sur
      // un aliment transformé interdit (jus, zeste, pomme cajou).
      final partialOk =
          score == wanted.length - 1 &&
          tokens.contains(head) &&
          extras.isEmpty &&
          !_categoryHeads.contains(head);
      if (!full && !partialOk) return;
      if (full && tokens.length > wanted.length + 3) return;
      if (extras.any(_transformationDenylist.contains)) return;
      // La tête du nom Ciqual doit être un mot de l'ingrédient : sans
      // cela « Chèvre frais » replie sur « Pizza au chèvre » et
      // « Graine de cumin » sur « Gouda au cumin ». Deux relâchements
      // assumés : les énumérations de synonymes (« Champignon,
      // chanterelle ou girolle », « Lieu ou colin d'Alaska ») et les
      // têtes hypernymes (« Champignon, cèpe, cru »).
      final alimNorm = _normalizeText(alimNames[alimCode] ?? '').trim();
      final alimHead = _significantTokensInOrder(alimNames[alimCode] ?? '')
          .first;
      final enumeration = alimNorm.contains(' ou ');
      final hypernym = _hypernymHeads.contains(alimHead);
      if (alimHead != head &&
          !wanted.contains(alimHead) &&
          !enumeration &&
          !hypernym) {
        return;
      }
      list.add((
        code: alimCode,
        score: score,
        full: full,
        prefix: prefix,
        rawBias: _isRawName(alimNames[alimCode] ?? '') ? 1 : 0,
        length: tokens.length,
        // Égalité du nom COMPLET normalisé (pas seulement des tokens
        // joints) : « Raisin sec » doit battre « Raisin noir, cru »
        // sans que « Raisin frais » ne vole l'entrée exacte.
        exact: alimNorm == ingredientNorm,
      ));
    });
    if (list.isEmpty) {
      unresolved++;
      final hint = code == null
          ? ''
          : ' (code $code → "${alimNames[code] ?? 'inconnu'}")';
      stdout.writeln('  ✗ non résolu : $ingredientName$hint');
    } else {
      list.sort((a, b) {
        // L'égalité parfaite du nom complet domine tout : « Raisin
        // sec » doit battre « Raisin noir, cru » même cru.
        if (a.exact != b.exact) return a.exact ? -1 : 1;
        final qualityA = a.score * 4 + (a.full ? 2 : 0) + a.prefix;
        final qualityB = b.score * 4 + (b.full ? 2 : 0) + b.prefix;
        if (qualityA != qualityB) return qualityB.compareTo(qualityA);
        if (a.rawBias != b.rawBias) return b.rawBias.compareTo(a.rawBias);
        return a.length.compareTo(b.length);
      });
      candidates[ingredientId] = list;
    }
  }
  // Dédoublonnage : deux ingrédients ne doivent pas résoudre vers le
  // même aliment (ex. « Maïs grain » et « Farine de maïs ») — le
  // candidat au meilleur match garde l'aliment, l'autre est écarté.
  final alimOwner = <String, String>{};
  final ownerQuality = <String, int>{};
  final sortedIds = candidates.keys.toList()..sort();
  for (final id in sortedIds) {
    final c = candidates[id]!.first;
    final quality =
        (c.exact ? 1 << 20 : 0) + c.score * 4 + (c.full ? 2 : 0) + c.prefix;
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
  // Repli : le perdant d'une collision tente son candidat suivant
  // encore libre (retour n°4 — « torréfié » doit trouver l'entrée
  // grillée plutôt que rien).
  for (final id in sortedIds) {
    if (alimOwner.containsValue(id)) continue;
    for (final c in candidates[id]!.skip(1)) {
      if (alimOwner.containsKey(c.code)) continue;
      alimOwner[c.code] = id;
      ownerQuality[id] =
          (c.exact ? 1 << 20 : 0) + c.score * 4 + (c.full ? 2 : 0) + c.prefix;
      stdout.writeln(
        '  ↻ repli collision : "${ingredientNames[id]}" → '
        '"${alimNames[c.code]}" (${c.code})',
      );
      break;
    }
  }
  for (final e in alimOwner.entries) {
    resolvedAlim[e.value] = e.key;
    byName++;
    final registryCode = ingredientCiqual[e.value];
    final hint = registryCode == null
        ? ''
        : ' [code registre $registryCode incohérent : '
              '"${alimNames[registryCode] ?? '?'}"]';
    stdout.writeln(
      '  ↻ résolu par nom : ${ingredientNames[e.value]} → '
      '"${alimNames[e.key]}" (${e.key}, score '
      '${candidates[e.value]!.first.score})'
      '$hint',
    );
  }
  // 6 bis. Standins curatés (retour PO n°4) : quelques ingrédients
  // génériques du référentiel n'ont pas d'entrée Ciqual directe (les
  // viandes y sont déclarées par morceau). On leur associe
  // MANUELLEMENT l'entrée la plus représentative ; l'approximation
  // reste traçable (colonne aliment_name du CSV, visible in-app).
  const standins = <String, String>{
    'Bœuf (viande)': 'Boeuf, steak ou bifteck cru',
    'Agneau (viande)': 'Agneau, gigot cru',
    'Veau (viande)': 'Veau, escalope crue',
    'Canard (viande)': 'Canard, viande et peau crues',
    'Blanc de volaille': 'Poulet, poitrine, viande et peau crues',
    'Crème liquide entière': 'Crème 30% MG, fluide, UHT',
    'Coulis de tomate': 'Tomate, coulis, appertisé',
    'Chèvre frais': 'Fromage de chèvre frais',
    'Melon': 'Melon cantaloup',
    'Sel': 'Sel blanc alimentaire, non iodé, non fluoré',
    'Sel fin': 'Sel blanc alimentaire, non iodé, non fluoré',
    'Sel de Guérande': 'Sel marin gris, non iodé, non fluoré',
    "Sel rose de l'Himalaya": 'Sel blanc alimentaire, non iodé, non fluoré',
    'Cajou crue': 'Noix de cajou, grillée, salée',
    'Cajou torréfiée': 'Noix de cajou, grillée, salée',
    'Pécan crue': 'Noix de pécan, sans sel ajouté',
    'Pécan torréfiée': 'Noix de pécan, sans sel ajouté',
    'Café espresso': 'Café, moulu',
    'Calvados': 'Eau de vie type calvados',
    'Vin doux naturel': 'Vin doux',
  };
  var byStandin = 0;
  for (final entry in standins.entries) {
    String? ingredientId;
    for (final e in ingredientNames.entries) {
      if (e.value == entry.key) {
        ingredientId = e.key;
        break;
      }
    }
    if (ingredientId == null || resolvedAlim.containsKey(ingredientId)) {
      continue;
    }
    final target = _normalizeText(entry.value);
    String? bestCode;
    var bestName = '';
    for (final alim in alimNames.entries) {
      final n = _normalizeText(alim.value);
      if (n != target && !n.startsWith(target)) continue;
      // Préférence à l'état cru puis au nom le plus court.
      final isBetter =
          bestCode == null ||
          (_isRawName(alim.value) && !_isRawName(bestName)) ||
          (_isRawName(alim.value) == _isRawName(bestName) &&
              alim.value.length < bestName.length);
      if (isBetter) {
        bestCode = alim.key;
        bestName = alim.value;
      }
    }
    if (bestCode != null) {
      if (resolvedAlim.containsValue(bestCode)) {
        stdout.writeln(
          '  ⌂ standin ignoré pour ${entry.key} : "$bestName" déjà '
          'attribué',
        );
        continue;
      }
      resolvedAlim[ingredientId] = bestCode;
      byStandin++;
      stdout.writeln(
        '  ⌂ standin curaté : ${entry.key} → "$bestName" ($bestCode)',
      );
    }
  }
  stdout.writeln(
    'Résolution : $byCode par code direct, $byName par nom, '
    '$byStandin standins curatés, $unresolved non résolus',
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

/// Extrait l'unité du nom FR d'un constituant Ciqual
/// (« Énergie … (kcal/100 g) » → kcal). Défaut : g.
String _unitFromName(String name) {
  final m = RegExp(r'\(([a-zA-Zµμ]+)\s*/\s*100\s*g\)').firstMatch(name);
  return m?.group(1) ?? 'g';
}
