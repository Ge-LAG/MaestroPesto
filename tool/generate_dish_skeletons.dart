// Générateur des squelettes de plats (Phase 11, recette à l'envers).
//
// Lit la curation `tool/data/dish_skeletons.csv` (rôles, candidats,
// bornes de masse par portion) et `tool/data/dish_processes.csv`
// (gabarits de procédé), les valide puis les écrit dans
// `assets/database-enrichment/`, importés en base comme les autres
// enrichissements (schéma v6).
//
// Contrôles (échec = code de sortie 1, aucun fichier écrit) :
// - chaque candidat existe dans le référentiel gelé (Phase 1) ;
// - bornes cohérentes (min ≤ max, nombre d'ingrédients ≥ 0) ;
// - chaque rôle cité par les étapes existe dans le squelette, chaque
//   rôle obligatoire est cité ;
// - la masse par défaut d'une portion est atteignable avec les bornes
//   des rôles ;
// - le mode de cuisson déclaré est celui que l'analyseur d'étapes de
//   l'application reconnaît (ProcessStepParser) ;
// - une durée réglable est cohérente ({duree} présent, min ≤ défaut ≤
//   max).
//
// Usage : dart run tool/generate_dish_skeletons.dart

import 'dart:convert';
import 'dart:io';

import 'package:maestropesto/core/design/dish_skeleton.dart';
import 'package:maestropesto/core/scoring/process_step_parser.dart';

const _registryPath =
    'database-metier/phase1-referentiel/ingredient_registry_v1.csv';
const _rolesPath = 'tool/data/dish_skeletons.csv';
const _processesPath = 'tool/data/dish_processes.csv';
const _outDir = 'assets/database-enrichment';

void main() {
  final registry = {
    for (final r in _records(_registryPath))
      r['ingredient_id']!: r['canonical_name_fr'] ?? '',
  };
  final roleRows = _records(_rolesPath);
  final processRows = _records(_processesPath);
  final catalog = DishCatalog.fromRows(
    roleRows: roleRows,
    processRows: processRows,
  );
  final errors = <String>[];

  if (catalog.skeletons.length != processRows.length) {
    errors.add('gabarits ignorés : ligne invalide dans $_processesPath');
  }
  final knownSkeletons = {for (final s in catalog.skeletons) s.id};
  for (final r in roleRows) {
    if (!knownSkeletons.contains(r['skeleton_id'])) {
      errors.add('rôle ${r['role']} : squelette inconnu ${r['skeleton_id']}');
    }
  }
  final roleCount = catalog.skeletons.fold<int>(
    0,
    (n, s) => n + s.roles.length,
  );
  if (roleCount != roleRows.length) {
    errors.add('rôles ignorés : ligne invalide dans $_rolesPath');
  }

  for (final s in catalog.skeletons) {
    final p = s.process;
    final referenced = p.referencedRoles;
    for (final role in s.roles) {
      for (final id in role.candidates) {
        if (!registry.containsKey(id)) {
          errors.add('${s.id}/${role.role} : $id absent du référentiel');
        }
      }
      if (role.minCount > role.maxCount || role.minGPerServing <= 0) {
        errors.add('${s.id}/${role.role} : bornes incohérentes');
      }
      if (role.minCount > role.candidates.length) {
        errors.add('${s.id}/${role.role} : trop peu de candidats');
      }
      if (!referenced.contains(role.role) && !referenced.contains('*')) {
        errors.add('${s.id}/${role.role} : rôle absent des étapes');
      }
    }
    for (final r in referenced) {
      if (r != '*' && s.role(r) == null) {
        errors.add('${s.id} : étape citant le rôle inconnu « $r »');
      }
    }
    if (!s.isGeneric) {
      final minMass = s.roles.fold<double>(
        0,
        (m, r) => m + r.minCount * r.minGPerServing,
      );
      final maxMass = s.roles.fold<double>(
        0,
        (m, r) => m + r.maxCount * r.maxGPerServing,
      );
      if (minMass > p.servingMaxG || maxMass < p.servingMinG) {
        errors.add(
          '${s.id} : masse par portion hors de portée des rôles '
          '(${minMass.toStringAsFixed(0)}–${maxMass.toStringAsFixed(0)} g)',
        );
      }
    }
    if (p.servingMinG > p.servingMassG || p.servingMassG > p.servingMaxG) {
      errors.add('${s.id} : masse par portion hors de ses bornes');
    }
    final usesDuration = p.steps.any((t) => t.contains('{duree}'));
    if (usesDuration != p.hasDuration) {
      errors.add('${s.id} : durée réglable incohérente avec les étapes');
    } else if (p.hasDuration &&
        !(p.durationMin! <= p.durationDefault! &&
            p.durationDefault! <= p.durationMax!)) {
      errors.add('${s.id} : durée par défaut hors de ses bornes');
    }

    // Mode de cuisson reconnu par l'analyseur : rendu avec le premier
    // candidat de chaque rôle.
    final names = <String, List<String>>{
      for (final r in s.roles)
        r.role: [_label(registry[r.candidates.first] ?? r.candidates.first)],
    };
    if (s.isGeneric) names['*'] = ['ingrédients'];
    final steps = p.render(names);
    final parsed = ProcessStepParser.parseAll(steps);
    final methods = [
      for (final step in parsed)
        if (step.cookingMethod != null) step.cookingMethod!,
    ];
    final main = methods.isEmpty ? 'raw' : methods.last.id;
    if (main != p.method.id) {
      errors.add(
        '${s.id} : mode déclaré ${p.method.id}, reconnu $main '
        '(${steps.join(' | ')})',
      );
    }
  }

  if (errors.isNotEmpty) {
    stderr.writeln('Squelettes invalides :');
    for (final e in errors) {
      stderr.writeln('  - $e');
    }
    exitCode = 1;
    return;
  }

  File('$_outDir/dish_skeletons.csv')
      .writeAsStringSync(_normalized(_rolesPath));
  File('$_outDir/dish_processes.csv')
      .writeAsStringSync(_normalized(_processesPath));
  final families = catalog.dishFamilies;
  stdout.writeln(
    '${catalog.skeletons.length} gabarits (${families.length} types de '
    'plat + ${catalog.generic.length} procédés libres), $roleCount rôles '
    '→ $_outDir/dish_skeletons.csv, dish_processes.csv',
  );
}

/// Libellé d'étape d'un nom du référentiel (sans « cru »).
String _label(String name) =>
    name.replaceFirst(RegExp(r' (cru|crue|crus|crues)$'), '').toLowerCase();

/// Contenu du fichier source, fins de ligne normalisées.
String _normalized(String path) {
  final lines = File(path)
      .readAsLinesSync(encoding: utf8)
      .where((l) => l.trim().isNotEmpty)
      .toList();
  return '${lines.join('\n')}\n';
}

List<Map<String, String?>> _records(String path) {
  final lines = File(path).readAsLinesSync(encoding: utf8);
  if (lines.isEmpty) return const [];
  final header = _split(lines.first.replaceFirst('﻿', ''));
  return [
    for (final line in lines.skip(1))
      if (line.trim().isNotEmpty)
        {
          for (var i = 0; i < header.length; i++)
            header[i].trim(): i < _split(line).length ? _split(line)[i] : null,
        },
  ];
}

List<String> _split(String line) {
  final out = <String>[];
  final cell = StringBuffer();
  var quoted = false;
  for (var i = 0; i < line.length; i++) {
    final c = line[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < line.length && line[i + 1] == '"') {
          cell.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        cell.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      out.add(cell.toString());
      cell.clear();
    } else {
      cell.write(c);
    }
  }
  out.add(cell.toString());
  return out;
}
