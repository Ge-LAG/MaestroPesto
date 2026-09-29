// Phase 11 Lot A — squelettes de plats et gabarits de procédé.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/importers/csv_toolkit.dart';
import 'package:maestropesto/core/design/dish_skeleton.dart';
import 'package:maestropesto/core/models/process_models.dart';

List<Map<String, String?>> _rows(String path) {
  final lines = File(path).readAsLinesSync().where((l) => l.trim().isNotEmpty);
  final header = parseCsvHeader(lines.first);
  return [
    for (final line in lines.skip(1))
      {
        for (final (i, cell) in parseCsvLine(line).indexed)
          if (i < header.length) header[i]: cell,
      },
  ];
}

DishCatalog _catalog() => DishCatalog.fromRows(
  roleRows: _rows('assets/database-enrichment/dish_skeletons.csv'),
  processRows: _rows('assets/database-enrichment/dish_processes.csv'),
);

void main() {
  group('catalogue embarqué', () {
    final catalog = _catalog();

    test('quatre types de plat et les procédés libres', () {
      expect(
        [for (final f in catalog.dishFamilies) f.id],
        ['sauce_froide', 'legumes_mijotes', 'creme_lactee', 'conserve_sucree'],
      );
      expect(
        {for (final s in catalog.generic) s.process.method},
        {
          CookingMethod.raw,
          CookingMethod.stewed,
          CookingMethod.boiled,
          CookingMethod.roasted,
          CookingMethod.sauteed,
          CookingMethod.steamed,
        },
      );
      expect(catalog.family('libre')!.isGeneric, isTrue);
    });

    test('gabarits couvrant les six recettes de démonstration', () {
      expect(
        catalog.skeleton('sauce_mixee')!.process.method,
        CookingMethod.raw,
      );
      expect(catalog.skeleton('emulsion')!.process.method, CookingMethod.raw);
      expect(
        catalog.skeleton('legumes_mijotes')!.process.method,
        CookingMethod.stewed,
      );
      expect(
        catalog.skeleton('creme_cuite')!.process.method,
        CookingMethod.boiled,
      );
      expect(
        catalog.skeleton('creme_gelifiee')!.process.method,
        CookingMethod.boiled,
      );
      expect(catalog.skeleton('confiture')!.process.hasDuration, isTrue);
    });

    test('rôles cohérents : bornes, candidats, rôles cités par les étapes', () {
      for (final s in catalog.skeletons) {
        final referenced = s.process.referencedRoles;
        for (final r in s.roles) {
          expect(r.minGPerServing, greaterThan(0), reason: '${s.id}/${r.role}');
          expect(r.maxGPerServing, greaterThanOrEqualTo(r.minGPerServing));
          expect(r.maxCount, greaterThanOrEqualTo(r.minCount));
          expect(r.candidates, isNotEmpty);
          expect(
            referenced.contains(r.role) || referenced.contains('*'),
            isTrue,
            reason: '${s.id}/${r.role} absent des étapes',
          );
        }
        final p = s.process;
        expect(p.servingMinG, lessThanOrEqualTo(p.servingMassG));
        expect(p.servingMaxG, greaterThanOrEqualTo(p.servingMassG));
      }
    });

    test('fichiers embarqués identiques à la curation (générateur à jour)', () {
      String norm(String path) =>
          File(path)
              .readAsLinesSync()
              .where((l) => l.trim().isNotEmpty)
              .join('\n');
      expect(
        norm('assets/database-enrichment/dish_skeletons.csv'),
        norm('tool/data/dish_skeletons.csv'),
      );
      expect(
        norm('assets/database-enrichment/dish_processes.csv'),
        norm('tool/data/dish_processes.csv'),
      );
    });
  });

  group('rédaction des étapes', () {
    const template = ProcessTemplate(
      method: CookingMethod.boiled,
      steps: [
        'Faire revenir {aromatique}[ dans {matiere_grasse}] 5 min.',
        'Ajouter {legume;herbe} et cuire {duree} min.',
        'Mixer {finition}.',
        'Servir chaud.',
      ],
      servingMassG: 300,
      servingMinG: 200,
      servingMaxG: 400,
      durationMin: 10,
      durationDefault: 25,
      durationMax: 45,
    );

    test('listes, segments facultatifs, étapes vides retirées', () {
      final steps = template.render({
        'aromatique': ['oignon'],
        'legume': ['carotte', 'poireau'],
        'herbe': ['thym'],
      });
      expect(steps, [
        'Faire revenir oignon 5 min.',
        'Ajouter carotte, poireau et thym et cuire 25 min.',
        'Servir chaud.',
      ]);
    });

    test('segment facultatif rempli et durée réglée', () {
      final steps = template.render({
        'aromatique': ['oignon'],
        'matiere_grasse': ['beurre doux'],
        'legume': ['carotte'],
        'finition': ['crème'],
      }, duration: 12);
      expect(steps[0], 'Faire revenir oignon dans beurre doux 5 min.');
      expect(steps[1], 'Ajouter carotte et cuire 12 min.');
      expect(steps[2], 'Mixer crème.');
    });

    test('rôle générique {*} : tous les ingrédients', () {
      const generic = ProcessTemplate(
        method: CookingMethod.raw,
        steps: ['Mélanger {*}.'],
        servingMassG: 250,
        servingMinG: 100,
        servingMaxG: 600,
      );
      expect(
        generic.render({
          '*': ['a', 'b'],
        }),
        ['Mélanger a et b.'],
      );
    });

    test('joinFr', () {
      expect(ProcessTemplate.joinFr([]), '');
      expect(ProcessTemplate.joinFr(['a']), 'a');
      expect(ProcessTemplate.joinFr(['a', 'b', 'c']), 'a, b et c');
    });
  });

  test('lignes invalides ignorées', () {
    final catalog = DishCatalog.fromRows(
      roleRows: [
        {'skeleton_id': 's', 'role': 'r', 'min_g_per_serving': '5'},
        {
          'skeleton_id': 's',
          'role': 'ok',
          'min_count': '1',
          'max_count': '1',
          'min_g_per_serving': '1',
          'max_g_per_serving': '2',
          'candidates': 'ING-A|ING-B',
        },
      ],
      processRows: [
        {
          'skeleton_id': 's',
          'family_id': 'f',
          'method': 'raw',
          'serving_mass_g': '50',
          'steps': 'Mélanger {ok}.',
        },
        {'skeleton_id': 'x', 'family_id': 'f', 'method': 'inconnu'},
      ],
    );
    expect(catalog.skeletons, hasLength(1));
    expect(catalog.skeletons.single.roles.single.candidates, [
      'ING-A',
      'ING-B',
    ]);
    expect(catalog.skeletons.single.process.servingMinG, 25);
  });
}
