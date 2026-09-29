// Mesure du moteur de composition (Phase 11, recette à l'envers).
//
// Importe les bases métier dans une base en mémoire, construit le jeu
// de données du moteur puis chronomètre des demandes types : aller-retour
// sur les recettes de démonstration couvertes (mode cohérent) et
// demandes Pure Innovation. Compilé en natif, il donne l'ordre de
// grandeur d'un build release (critère : moins de 2 s par demande).
//
// Usage :
//   dart run tool/bench_design.dart                  (JIT)
//   dart compile exe tool/bench_design.dart -o build/bench_design.exe
//   build/bench_design.exe                           (AOT, comme en release)

import 'dart:io';

import 'package:drift/native.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_engine.dart';
import 'package:maestropesto/core/design/design_scoring.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/design/data/design_dataset_loader.dart';
import 'package:maestropesto/features/recipes/data/demo_recipes.dart';

/// Recettes de démonstration couvertes : type de plat et mode de cuisson.
const _covered = {
  'pesto': ('sauce_froide', 'raw'),
  'mayonnaise': ('sauce_froide', 'raw'),
  'ratatouille': ('legumes_mijotes', 'stewed'),
  'creme-patissiere': ('creme_lactee', 'boiled'),
  'panna-cotta': ('creme_lactee', 'boiled'),
  'confiture-fraise': ('conserve_sucree', 'boiled'),
};

Future<void> main(List<String> args) async {
  final verbose = args.contains('-v');
  final db = AppDatabase(NativeDatabase.memory());
  final sw = Stopwatch()..start();
  await CsvImportService(
    db,
    databaseMetierRoot: 'assets/database-metier',
  ).importAll();
  stdout.writeln('Import des bases : ${sw.elapsedMilliseconds} ms');
  sw.reset();
  final data = await DesignDatasetLoader.load(db);
  stdout.writeln(
    'Jeu de données : ${sw.elapsedMilliseconds} ms '
    '(${data.ingredients.length} ingrédients, '
    '${data.catalog.skeletons.length} gabarits)',
  );
  final service = RecipeAnalysisService(db);
  final briefs = <String, DesignBrief>{};
  for (final r in demoRecipes) {
    final covered = _covered[r.id];
    if (covered == null) continue;
    final a = await service.analyze(
      ingredients: r.ingredients,
      steps: r.steps,
      servings: r.servings,
      withSuggestions: false,
    );
    final p = a.nutrition.profilePerServing;
    final s = a.physchem;
    briefs[r.id] = DesignBrief(
      familyId: covered.$1,
      servings: r.servings,
      targets: {
        'cooking_method': DesignTarget.choice(covered.$2),
        'dry_matter': DesignTarget.value(s.dryMatterPct),
        'fat_phase': DesignTarget.value(s.fatPct),
        if (s.ph != null) 'ph': DesignTarget.value(s.ph!),
        'energy': DesignTarget.value(p.energyKcal),
        'proteins': DesignTarget.value(p.proteins),
        'salt': DesignTarget.value(p.salt),
        'harmony': DesignTarget.atLeast(a.flavor!.harmony),
      },
    );
  }
  briefs['pi-soupe-proteinee'] = const DesignBrief(
    familyId: 'legumes_mijotes',
    servings: 4,
    mode: DesignMode.pureInnovation,
    targets: {
      'energy': DesignTarget.value(350),
      'proteins': DesignTarget.atLeast(20),
      'salt': DesignTarget.atMost(1.5),
      'nutriscore': DesignTarget.choice('A'),
    },
  );
  briefs['pi-libre-dessert'] = const DesignBrief(
    servings: 4,
    mode: DesignMode.pureInnovation,
    targets: {
      'cooking_method': DesignTarget.choice('raw'),
      'brix': DesignTarget.value(25),
      'dominant_family': DesignTarget.choice('fruity'),
      'energy': DesignTarget.value(200),
    },
  );

  for (final round in [1, 2]) {
    stdout.writeln('--- passe $round');
    for (final e in briefs.entries) {
      sw.reset();
      final res = DesignEngine(data).run(e.value);
      final ms = sw.elapsedMilliseconds;
      final best = res.best;
      stdout.writeln(
        '${e.key.padRight(22)} ${'$ms ms'.padLeft(8)}  '
        '${res.evaluations} évaluations  '
        'meilleure : ${best?.score.metCount}/${best?.score.criteria.length} '
        'atteints (écart ${best?.score.weightedDeviation.toStringAsFixed(4)})',
      );
      if (verbose && round == 1) {
        for (final v in res.variants) {
          stdout.writeln(
            '   #${v.rank} ${v.skeleton.id} : '
            '${v.ingredients.map((i) => '${i.label} ${i.quantity}').join(', ')}',
          );
          final misses = v.score.criteria
              .where((c) => c.status != CriterionStatus.met)
              .map((c) => '${c.metric.id} ${c.status.name}');
          if (misses.isNotEmpty) stdout.writeln('      ${misses.join(', ')}');
        }
        for (final n in res.notices) {
          stdout.writeln('   ! $n');
        }
      }
    }
  }
  await db.close();
}
