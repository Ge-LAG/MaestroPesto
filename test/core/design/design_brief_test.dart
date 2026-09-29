// Phase 11 Lot A — modèle d'objectifs (DesignBrief) et catalogue des
// métriques.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_metrics.dart';

void main() {
  group('DesignBrief', () {
    test('valeurs par défaut : cohérent, 4 portions, 60 / 30 / 10', () {
      const brief = DesignBrief();
      expect(brief.mode, DesignMode.coherent);
      expect(brief.servings, 4);
      expect(brief.normalizedPriorities, DesignBrief.defaultPriorities);
      expect(brief.weights, {
        DesignAspect.process: 0.6,
        DesignAspect.flavor: 0.3,
        DesignAspect.nutrition: 0.1,
      });
    });

    test('le classement des aspects fixe les poids du rang', () {
      const brief = DesignBrief(
        priorities: [DesignAspect.nutrition, DesignAspect.process],
      );
      expect(brief.normalizedPriorities, [
        DesignAspect.nutrition,
        DesignAspect.process,
        DesignAspect.flavor,
      ]);
      expect(brief.weights[DesignAspect.nutrition], 0.6);
      expect(brief.weights[DesignAspect.flavor], 0.1);
    });

    test('curseurs avancés : poids normalisés', () {
      const brief = DesignBrief(
        customWeights: {
          DesignAspect.process: 2,
          DesignAspect.flavor: 1,
          DesignAspect.nutrition: 1,
        },
      );
      expect(brief.weights[DesignAspect.process], closeTo(0.5, 1e-12));
      expect(brief.weights[DesignAspect.flavor], closeTo(0.25, 1e-12));
    });

    test('sérialisation aller-retour (JSON)', () {
      const brief = DesignBrief(
        familyId: 'sauce_froide',
        servings: 6,
        imposedIds: ['ING-PLANT-BASILIC-000001'],
        excludedIds: ['ING-PLANT-AIL-000001'],
        excludedAllergens: ['nuts'],
        mode: DesignMode.pureInnovation,
        priorities: [
          DesignAspect.flavor,
          DesignAspect.nutrition,
          DesignAspect.process,
        ],
        customWeights: {DesignAspect.flavor: 3, DesignAspect.process: 1},
        targets: {
          'energy': DesignTarget.value(220, tolerance: 0.05),
          'dry_matter': DesignTarget.range(60, 75),
          'proteins': DesignTarget.atLeast(4),
          'salt': DesignTarget.atMost(0.5),
          'cooking_method': DesignTarget.choice('raw'),
        },
      );
      final json = jsonDecode(jsonEncode(brief.toJson()));
      final back = DesignBrief.fromJson(json as Map<String, Object?>);
      expect(back, brief);
      expect(back.targets['energy']!.tolerance, 0.05);
      expect(back.customWeights![DesignAspect.flavor], 3);
    });

    test('lecture tolérante : valeurs inconnues ignorées', () {
      final brief = DesignBrief.fromJson({
        'servings': 0,
        'mode': 'inconnu',
        'priorities': ['nutrition', 'bidon'],
        'targets': {
          'energy': {'kind': 'value'},
          'salt': {'kind': 'max', 'max': 1.2},
          'x': 'y',
        },
      });
      expect(brief.servings, 1);
      expect(brief.mode, DesignMode.coherent);
      expect(brief.normalizedPriorities.first, DesignAspect.nutrition);
      expect(brief.targets.keys, ['salt']);
    });

    test('ingrédient pivot : exigé dans chaque variante', () {
      const brief = DesignBrief(
        imposedIds: ['ING-A'],
        targets: {'pivot': DesignTarget.choice('ING-B')},
      );
      expect(brief.pivotId, 'ING-B');
      expect(brief.requiredIds, ['ING-A', 'ING-B']);
      expect(brief.withTarget('pivot', null).requiredIds, [
        'ING-A',
      ], reason: 'objectif retiré');
    });

    test('bornes d\'un objectif (± 10 % par défaut)', () {
      expect(const DesignTarget.value(200).bounds, (lower: 180, upper: 220));
      expect(const DesignTarget.atLeast(4).bounds, (lower: 4, upper: null));
      expect(const DesignTarget.atMost(1).bounds, (lower: null, upper: 1));
      expect(const DesignTarget.range(3, 5).bounds, (lower: 3, upper: 5));
    });
  });

  group('DesignMetrics', () {
    test('catalogue complet des trois aspects (plan phase 11)', () {
      final ids = {for (final m in DesignMetrics.all) m.id};
      expect(ids, {
        'cooking_method',
        'dry_matter',
        'fat_phase',
        'ph',
        'aw',
        'brix',
        'pivot',
        'dominant_family',
        'harmony',
        'documented_share',
        'energy',
        'nutriscore',
        'proteins',
        'salt',
        'sugars',
        'saturated_fats',
        'fiber',
      });
      for (final a in DesignAspect.values) {
        expect(DesignMetrics.ofAspect(a), isNotEmpty, reason: a.name);
      }
    });

    test('chaque métrique a son aide, sa règle de couverture et son sens', () {
      for (final m in DesignMetrics.all) {
        expect(m.help, isNotEmpty, reason: m.id);
        expect(m.coverageRule, isNotEmpty, reason: m.id);
        expect(DesignMetrics.of(m.id), same(m));
      }
      expect(DesignMetrics.salt.defaultKind, TargetKind.max);
      expect(DesignMetrics.proteins.defaultKind, TargetKind.min);
      expect(DesignMetrics.energy.defaultKind, TargetKind.value);
      expect(DesignMetrics.nutriScore.isChoice, isTrue);
    });

    test('format français des valeurs', () {
      expect(DesignMetrics.salt.format(0.456), '0,46 g');
      expect(DesignMetrics.energy.format(212.6), '213 kcal');
      expect(DesignMetrics.ph.format(4.26), '4,3');
    });
  });
}
