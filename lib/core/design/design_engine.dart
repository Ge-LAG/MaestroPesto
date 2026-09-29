// Phase 11 Lot B — moteur de composition (recette à l'envers).
//
// À partir d'une demande (DesignBrief), compose trois variantes
// distinctes qui s'approchent des objectifs :
//
// 1. Ingrédients : recherche locale sur les compositions complètes
//    (échanger un ingrédient, en ajouter, en retirer), avec présélection
//    des voisins les plus prometteurs puis optimisation rapide de leurs
//    quantités ; mode cohérent : rôles du squelette de chaque gabarit de
//    la famille ; Pure Innovation : tout le référentiel, départs issus
//    du mode cohérent quand un type de plat est donné.
// 2. Quantités : descente par coordonnées multiplicatives sur les
//    masses par portion (bornes des rôles, ou bornes physiques seules
//    en Pure Innovation), sur l'échelle globale et sur la durée du
//    procédé quand le gabarit en a une.
// 3. Variantes : la meilleure, puis les meilleures qui partagent au plus
//    60 % de leurs ingrédients avec chacune des précédentes.
// 4. Rédaction : quantités arrondies (précision de cuisine), recette
//    analysée comme dans l'éditeur, écart aux objectifs recalculé.
//
// Déterministe (aucun hasard, budget compté en évaluations et non en
// temps) : une même demande donne les mêmes variantes. Contraintes dures
// (exclusions, allergènes, ingrédients imposés, 12 ingrédients au plus,
// masses positives) respectées dans les deux modes.

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../features/recipes/domain/recipe.dart';
import '../models/process_models.dart';
import 'design_brief.dart';
import 'design_dataset.dart';
import 'design_evaluator.dart';
import 'design_metrics.dart';
import 'design_scoring.dart';
import 'dish_skeleton.dart';

/// Budget de calcul (compté en évaluations : déterministe).
@immutable
class DesignBudget {
  const DesignBudget({
    this.maxEvaluations = 90000,
    this.maxIterations = 14,
    this.shortlist = 8,
  });

  /// Évaluations rapides au plus pour toute la demande.
  final int maxEvaluations;

  /// Itérations de recherche locale au plus par départ.
  final int maxIterations;

  /// Voisins optimisés par itération (après présélection).
  final int shortlist;
}

/// Variante proposée.
@immutable
class DesignVariant {
  const DesignVariant({
    required this.rank,
    required this.mode,
    required this.composition,
    required this.evaluation,
    required this.score,
  });

  /// Rang (1 = meilleure).
  final int rank;
  final DesignMode mode;
  final DesignComposition composition;
  final DesignFullEvaluation evaluation;
  final DesignScore score;

  DishSkeleton get skeleton => composition.skeleton;
  List<RecipeIngredient> get ingredients => evaluation.ingredients;
  List<String> get steps => evaluation.steps;

  /// Titre proposé : gabarit et ingrédients principaux.
  String get title {
    final base = skeleton.isGeneric
        ? 'Composition'
        : skeleton.label.replaceFirst(RegExp(r'\s*\(.*\)$'), '');
    // Ingrédients caractéristiques d'abord : la matière grasse, le sel,
    // le sucre ou le liquide de cuisson ne distinguent pas deux
    // propositions.
    final lines = [
      for (var i = 0; i < composition.lines.length; i++)
        (composition.lines[i], evaluation.ingredients[i].label),
    ]..sort((a, b) => b.$1.grams.compareTo(a.$1.grams));
    bool neutral((DesignLine, String) e) =>
        _neutralRoles.contains(e.$1.role) || _neutralName.hasMatch(e.$2);
    final characteristic = [
      for (final e in lines)
        if (!neutral(e)) e.$2,
    ];
    // Complément : liant, sucrant… plutôt que matière grasse ou sel.
    final names = <String>{
      ...characteristic,
      for (final e in lines)
        if (!_basicRoles.contains(e.$1.role) && !_neutralName.hasMatch(e.$2))
          e.$2,
      for (final e in lines) e.$2,
    }.take(2).map((n) => n.toLowerCase()).toList();
    return '$base : ${ProcessTemplate.joinFr(names)}';
  }

  static const Set<String> _basicRoles = {
    'matiere_grasse',
    'assaisonnement',
    'liquide',
  };

  static const Set<String> _neutralRoles = {
    'matiere_grasse',
    'assaisonnement',
    'sucrant',
    'liquide',
    'gelifiant',
    'epaississant',
    'emulsifiant',
    'liant_oeuf',
  };

  static final RegExp _neutralName = RegExp(
    r"^(Huile|Sel|Fleur de sel|Sucre|Eau|Poivre|Beurre)",
  );

  /// Minutes de cuisson : durées des étapes chauffées.
  int get cookMinutes {
    var total = 0.0;
    for (final s in evaluation.measure.physchem.steps) {
      if (s.isThermal && s.durationMin != null) total += s.durationMin!;
    }
    return total.round();
  }

  /// Brouillon de recette (non enregistré) pour l'éditeur.
  Recipe toRecipe({
    required String id,
    required DesignBrief brief,
    required int servings,
  }) {
    final innovation = mode == DesignMode.pureInnovation;
    final met = score.metCount;
    final total = score.criteria.length;
    return Recipe(
      id: id,
      title: title,
      description: [
        innovation
            ? 'Proposition calculée en mode Pure Innovation — non testée en '
                  'cuisine.'
            : 'Proposition calculée (Cuisine cohérente) : une base à '
                  'goûter et ajuster, pas une recette éprouvée.',
        if (total > 0) 'Objectifs atteints : $met sur $total.',
      ].join(' '),
      tags: [
        'recette à l’envers',
        if (innovation) 'pure innovation',
        if (!skeleton.isGeneric) skeleton.familyLabel.toLowerCase(),
      ],
      servings: servings,
      prepMinutes: 15,
      cookMinutes: cookMinutes,
      ingredients: evaluation.ingredients,
      steps: evaluation.steps,
      nutrition: NutritionSummary(
        energyKcal: evaluation.nutrition.profilePerServing.energyKcal,
        proteins: evaluation.nutrition.profilePerServing.proteins,
        carbs: evaluation.nutrition.profilePerServing.carbs,
        fats: evaluation.nutrition.profilePerServing.fats,
        fiber: evaluation.nutrition.profilePerServing.fiber,
        salt: evaluation.nutrition.profilePerServing.salt,
      ),
      images: const [],
      designBrief: brief,
    );
  }
}

/// Résultat d'une demande.
@immutable
class DesignResult {
  const DesignResult({
    required this.brief,
    required this.variants,
    this.notices = const <String>[],
    this.evaluations = 0,
  });

  final DesignBrief brief;
  final List<DesignVariant> variants;

  /// Messages à afficher (contrainte impossible, diversité limitée…).
  final List<String> notices;
  final int evaluations;

  DesignVariant? get best => variants.isEmpty ? null : variants.first;
}

/// Demande transférable vers un isolate.
@immutable
class DesignRequest {
  const DesignRequest(
    this.data,
    this.brief, {
    this.budget = const DesignBudget(),
  });

  final DesignDataset data;
  final DesignBrief brief;
  final DesignBudget budget;
}

/// Point d'entrée d'isolate (fonction de haut niveau).
DesignResult runDesignRequest(DesignRequest request) =>
    DesignEngine(request.data, budget: request.budget).run(request.brief);

/// Moteur de composition.
class DesignEngine {
  DesignEngine(this.data, {this.budget = const DesignBudget()});

  final DesignDataset data;
  final DesignBudget budget;

  /// Part maximale d'ingrédients partagés entre deux variantes.
  static const double maxOverlap = 0.6;

  /// Poids de la plausibilité culinaire (harmonie) en mode cohérent.
  static const double harmonyWeight = 0.15;

  /// Poids du rappel vers les quantités typiques d'un rôle.
  static const double typicalWeight = 0.003;

  DesignResult run(DesignBrief brief) {
    final notices = <String>[];
    final evaluator = DesignEvaluator(
      data,
      servings: brief.servings,
      withAromaFamilies: brief.targets.containsKey(
        DesignMetrics.dominantFamily.id,
      ),
      withNutriScore: brief.targets.containsKey(DesignMetrics.nutriScore.id),
    );
    final problem = _Problem.build(data, brief, notices);
    if (problem == null) {
      return DesignResult(brief: brief, variants: const [], notices: notices);
    }
    final search = _Search(problem, evaluator, budget);

    List<_Scored> finalists;
    if (brief.mode == DesignMode.coherent) {
      finalists = search.coherentVariants();
    } else {
      var seeds = <_Scored>[];
      if (problem.family != null) {
        // Départs du mode cohérent : Pure Innovation fait au moins aussi
        // bien sur l'écart aux objectifs.
        final coherent = _Problem.build(
          data,
          brief.copyWith(mode: DesignMode.coherent),
          <String>[],
        );
        if (coherent != null) {
          seeds = _Search(coherent, evaluator, budget).coherentVariants();
        }
      }
      finalists = search.innovationVariants(seeds);
    }
    if (finalists.isEmpty) {
      notices.add(
        'Aucune composition ne respecte toutes les contraintes : '
        'assouplir les exclusions ou les ingrédients imposés.',
      );
    } else if (finalists.length < 3) {
      notices.add(
        'Seulement ${finalists.length} variante${finalists.length > 1 ? 's' : ''} '
        'assez différente${finalists.length > 1 ? 's' : ''} : les '
        'contraintes laissent peu de choix d\'ingrédients.',
      );
    }
    final variants = <DesignVariant>[];
    for (final f in finalists) {
      final full = evaluator.evaluateFull(f.composition);
      variants.add(
        DesignVariant(
          rank: variants.length + 1,
          mode: brief.mode,
          composition: f.composition,
          evaluation: full,
          score: DesignScoring.score(brief, full.measure),
        ),
      );
    }
    return DesignResult(
      brief: brief,
      variants: variants,
      notices: notices,
      evaluations: evaluator.evaluations,
    );
  }

  /// Part maximale de la masse portée par des ingrédients partagés.
  static const double maxMassOverlap = 0.7;

  /// Part de la masse d'une portion portée par les ingrédients communs
  /// (minimum des deux parts, ingrédients [exclude] ignorés).
  static double massOverlap(
    DesignComposition a,
    DesignComposition b, {
    Iterable<String> exclude = const [],
  }) {
    Map<String, double> shares(DesignComposition c) {
      final total = c.servingMassG;
      final out = <String, double>{};
      for (final l in c.lines) {
        out[l.ingredientId] =
            (out[l.ingredientId] ?? 0) + (total <= 0 ? 0 : l.grams / total);
      }
      return out;
    }

    final sa = shares(a);
    final sb = shares(b);
    final skip = exclude.toSet();
    var shared = 0.0;
    sa.forEach((id, x) {
      final y = sb[id];
      if (y != null && !skip.contains(id)) shared += math.min(x, y);
    });
    return shared;
  }

  /// Part d'ingrédients partagés : |A ∩ B| / max(|A|, |B|).
  static double overlap(Iterable<String> a, Iterable<String> b) {
    final sa = a.toSet();
    final sb = b.toSet();
    final m = math.max(sa.length, sb.length);
    if (m == 0) return 0;
    return sa.intersection(sb).length / m;
  }
}

// -------------------------------------------------------------------------
// Problème : gabarits, candidats, bornes.
// -------------------------------------------------------------------------

class _Problem {
  _Problem({
    required this.brief,
    required this.templates,
    required this.pool,
    required this.required,
    required this.family,
  });

  final DesignBrief brief;
  final List<DishSkeleton> templates;

  /// Candidats autorisés (hors imposés), ordre stable.
  final List<String> pool;

  /// Ingrédients imposés (et pivot).
  final List<String> required;
  final DishFamily? family;

  bool get coherent => brief.mode == DesignMode.coherent;

  double get servingMin => family == null
      ? _genericMin
      : family!.skeletons.map((s) => s.process.servingMinG).reduce(math.min);

  double get servingMax => family == null
      ? _genericMax
      : family!.skeletons.map((s) => s.process.servingMaxG).reduce(math.max);

  double get servingMass => family?.servingMassG ?? _genericMass;

  static const double _genericMin = 100;
  static const double _genericMax = 600;
  static const double _genericMass = 250;

  /// Rôles d'un gabarit (candidats filtrés).
  final Map<String, List<SkeletonRole>> _roles = {};

  List<SkeletonRole> rolesOf(DishSkeleton s) => _roles[s.id] ??= [
    for (final r in s.roles)
      SkeletonRole(
        skeletonId: r.skeletonId,
        role: r.role,
        label: r.label,
        minCount: r.minCount,
        maxCount: r.maxCount,
        minGPerServing: r.minGPerServing,
        maxGPerServing: r.maxGPerServing,
        candidates: [
          for (final id in r.candidates)
            if (pool.contains(id) || required.contains(id)) id,
        ],
        note: r.note,
      ),
  ];

  SkeletonRole? role(DishSkeleton s, String role) {
    for (final r in rolesOf(s)) {
      if (r.role == role) return r;
    }
    return null;
  }

  /// Rôle des ingrédients hors squelette (rédaction).
  String mainRole(DishSkeleton s) => s.roles.isEmpty ? '*' : s.roles.first.role;

  /// Bornes (g par portion) d'une ligne.
  (double, double) bounds(DishSkeleton s, DesignLine line) {
    if (!coherent || s.isGeneric) {
      return (0.1, math.max(servingMax, s.process.servingMaxG));
    }
    final r = role(s, line.role);
    if (r != null && r.candidates.contains(line.ingredientId)) {
      return (r.minGPerServing, r.maxGPerServing);
    }
    // Ingrédient imposé hors des rôles du squelette.
    return (0.1, s.process.servingMaxG * 0.5);
  }

  /// Masse typique d'une ligne (rappel doux en mode cohérent).
  double typical(DishSkeleton s, DesignLine line) {
    final (lo, hi) = bounds(s, line);
    return math.sqrt(lo * hi);
  }

  /// Bornes de la masse d'une portion.
  (double, double) servingBounds(DishSkeleton s) => coherent && !s.isGeneric
      ? (s.process.servingMinG, s.process.servingMaxG)
      : (servingMin, servingMax);

  static _Problem? build(
    DesignDataset data,
    DesignBrief brief,
    List<String> notices,
  ) {
    final catalog = data.catalog;
    final family = catalog.family(brief.familyId);
    final coherent = brief.mode == DesignMode.coherent;
    if (coherent && (family == null || family.isGeneric)) {
      notices.add(
        'Choisir un type de plat : il est obligatoire en mode Cuisine '
        'cohérente.',
      );
      return null;
    }
    final excluded = brief.excludedIds.toSet();
    final allergens = brief.excludedAllergens.toSet();
    bool clean(DesignIngredient i) =>
        !excluded.contains(i.id) && !i.allergens.any(allergens.contains);

    final required = <String>[];
    for (final id in brief.requiredIds) {
      final ing = data[id];
      if (ing == null) {
        notices.add('Ingrédient imposé inconnu du référentiel : $id.');
        return null;
      }
      if (!clean(ing)) {
        notices.add(
          '« ${ing.label} » est à la fois imposé et exclu (ingrédient ou '
          'allergène) : lever l\'une des deux contraintes.',
        );
        return null;
      }
      if (!required.contains(id)) required.add(id);
    }
    if (required.length > DesignBrief.maxIngredients) {
      notices.add('Plus de ${DesignBrief.maxIngredients} ingrédients imposés.');
      return null;
    }
    final pool = <String>[
      for (final ing in data.ingredients.values)
        if (clean(ing) &&
            ing.hasNutrition &&
            ing.flavor != null &&
            !required.contains(ing.id))
          ing.id,
    ];

    final method = CookingMethod.fromId(
      brief.targets[DesignMetrics.cookingMethod.id]?.choice,
    );
    List<DishSkeleton> templates;
    if (coherent) {
      templates = [
        for (final s in family!.skeletons)
          if (method == null || s.process.method == method) s,
      ];
      if (templates.isEmpty) {
        notices.add(
          'Aucun gabarit de « ${family.label} » en mode '
          '« ${method!.labelFr.toLowerCase()} » : procédés du type de plat '
          'conservés, critère « mode de cuisson » manqué.',
        );
        templates = family.skeletons;
      }
    } else {
      final methods = method != null
          ? {method}
          : family != null && !family.isGeneric
          ? family.methods
          : {for (final s in catalog.generic) s.process.method};
      templates = [
        for (final s in catalog.generic)
          if (methods.contains(s.process.method)) s,
        if (family != null && !family.isGeneric)
          for (final s in family.skeletons)
            if (method == null || s.process.method == method) s,
      ];
      if (templates.isEmpty) templates = catalog.generic;
    }
    if (templates.isEmpty) {
      notices.add('Aucun gabarit de procédé disponible (bases à importer).');
      return null;
    }
    return _Problem(
      brief: brief,
      templates: templates,
      pool: pool,
      required: required,
      family: family != null && !family.isGeneric ? family : null,
    );
  }
}

// -------------------------------------------------------------------------
// Recherche.
// -------------------------------------------------------------------------

/// Composition évaluée.
class _Scored {
  _Scored(this.composition, this.objective, this.score);

  final DesignComposition composition;

  /// Objectif de recherche (écart + plausibilité + pénalités).
  final double objective;
  final DesignScore score;

  double get deviation => score.weightedDeviation;
  List<String> get ids => composition.ids;
}

class _Search {
  _Search(this.p, this.ev, this.budget);

  final _Problem p;
  final DesignEvaluator ev;
  final DesignBudget budget;

  /// Compositions complètes évaluées (masses optimisées), par clé.
  final Map<String, _Scored> _archive = {};

  /// Candidats présélectionnés (Pure Innovation), recalculés par
  /// [localSearch].
  List<String>? _pool;

  bool get _exhausted => ev.evaluations >= budget.maxEvaluations;

  bool get _regularized => p.coherent || p.brief.targets.isEmpty;

  // ------------------------------------------------------------------
  // Objectif.
  // ------------------------------------------------------------------

  _Scored _score(DesignComposition c) {
    final m = ev.evaluate(c);
    final s = DesignScoring.score(p.brief, m);
    var j = s.weightedDeviation;
    if (_regularized) {
      j += DesignEngine.harmonyWeight * (1 - (m.harmony ?? 0.5));
      for (final l in c.lines) {
        final t = p.typical(c.skeleton, l);
        final r = math.log(l.grams / t);
        j += DesignEngine.typicalWeight * r * r;
      }
    }
    final (lo, hi) = p.servingBounds(c.skeleton);
    final total = c.servingMassG;
    if (total < lo) j += 50 * math.pow((lo - total) / lo, 2);
    if (total > hi) j += 50 * math.pow((total - hi) / hi, 2);
    return _Scored(c, j, s);
  }

  // ------------------------------------------------------------------
  // Quantités.
  // ------------------------------------------------------------------

  /// Descente par coordonnées multiplicatives.
  /// [accept] : contrainte sur les quantités (diversité par masse).
  _Scored optimize(
    DesignComposition c, {
    bool quick = false,
    bool Function(DesignComposition c)? accept,
  }) {
    var best = _score(_clampAll(c));
    final levels = quick ? const [0.3, 0.1] : const [0.4, 0.15, 0.05, 0.015];
    final passes = quick ? 1 : 2;
    final process = c.skeleton.process;
    for (final delta in levels) {
      for (var pass = 0; pass < passes; pass++) {
        if (_exhausted) return best;
        var improved = false;
        final n = best.composition.lines.length;
        for (var i = 0; i <= n; i++) {
          for (final up in const [true, false]) {
            final factor = up ? 1 + delta : 1 / (1 + delta);
            final lines = best.composition.lines;
            final List<DesignLine> next;
            if (i == n) {
              // Échelle globale (masse d'une portion).
              next = [
                for (final l in lines)
                  _clamp(c.skeleton, l.withGrams(l.grams * factor)),
              ];
            } else {
              next = [...lines];
              next[i] = _clamp(
                c.skeleton,
                lines[i].withGrams(lines[i].grams * factor),
              );
              if (next[i].grams == lines[i].grams) continue;
            }
            final moved = best.composition.copyWith(lines: next, sameSet: true);
            if (accept != null && !accept(moved)) continue;
            final cand = _score(moved);
            if (cand.objective < best.objective - 1e-9) {
              best = cand;
              improved = true;
              break;
            }
          }
        }
        // Durée du procédé (minutes entières).
        if (process.hasDuration) {
          final d = best.composition.duration ?? process.durationDefault!;
          final span = process.durationMax! - process.durationMin!;
          final step = math.max(1.0, (span * delta).roundToDouble());
          for (final sign in const [1, -1]) {
            final nd = (d + sign * step).clamp(
              process.durationMin!,
              process.durationMax!,
            );
            if (nd == d) continue;
            final cand = _score(best.composition.copyWith(duration: nd));
            if (cand.objective < best.objective - 1e-9) {
              best = cand;
              improved = true;
              break;
            }
          }
        }
        if (!improved) break;
      }
    }
    if (!quick) _archive[best.composition.setKey] = best;
    return best;
  }

  DesignLine _clamp(DishSkeleton s, DesignLine l) {
    final (lo, hi) = p.bounds(s, l);
    return l.withGrams(l.grams.clamp(lo, hi));
  }

  DesignComposition _clampAll(DesignComposition c) => c.copyWith(
    lines: [for (final l in c.lines) _clamp(c.skeleton, l)],
    sameSet: true,
  );

  // ------------------------------------------------------------------
  // Voisinage.
  // ------------------------------------------------------------------

  bool _isRequired(String id) => p.required.contains(id);

  /// Voisins d'une composition (ingrédients), masses héritées.
  List<DesignComposition> _neighbours(DesignComposition c) {
    final s = c.skeleton;
    final present = c.ids.toSet();
    final out = <DesignComposition>[];
    final lines = c.lines;
    if (p.coherent && !s.isGeneric) {
      final roles = p.rolesOf(s);
      int count(String role) => lines.where((l) => l.role == role).length;
      for (var i = 0; i < lines.length; i++) {
        final l = lines[i];
        if (_isRequired(l.ingredientId)) continue;
        final r = p.role(s, l.role);
        if (r == null) continue;
        for (final cand in r.candidates) {
          if (present.contains(cand) || _isRequired(cand)) continue;
          final next = [...lines];
          next[i] = DesignLine(
            ingredientId: cand,
            role: l.role,
            grams: l.grams,
          );
          out.add(c.copyWith(lines: next));
        }
        if (count(l.role) > r.minCount) {
          out.add(c.copyWith(lines: [...lines]..removeAt(i)));
        }
      }
      if (lines.length < DesignBrief.maxIngredients) {
        for (final r in roles) {
          if (count(r.role) >= r.maxCount) continue;
          for (final cand in r.candidates) {
            if (present.contains(cand) || _isRequired(cand)) continue;
            out.add(
              c.copyWith(
                lines: _ordered(s, [
                  ...lines,
                  DesignLine(
                    ingredientId: cand,
                    role: r.role,
                    grams: math.sqrt(r.minGPerServing * r.maxGPerServing),
                  ),
                ]),
              ),
            );
          }
        }
      }
      return out;
    }
    // Pure Innovation : tout le référentiel, présélection par criblage.
    final pool = _pool ??= _screenedPool(c);
    for (var i = 0; i < lines.length; i++) {
      final l = lines[i];
      if (_isRequired(l.ingredientId)) continue;
      for (final cand in pool) {
        if (present.contains(cand)) continue;
        final next = [...lines];
        next[i] = DesignLine(ingredientId: cand, role: l.role, grams: l.grams);
        out.add(c.copyWith(lines: next));
      }
      if (lines.length > 1) out.add(c.copyWith(lines: [...lines]..removeAt(i)));
    }
    if (lines.length < DesignBrief.maxIngredients) {
      final grams = math.max(1.0, c.servingMassG * 0.1);
      for (final cand in pool) {
        if (present.contains(cand)) continue;
        out.add(
          c.copyWith(
            lines: [
              ...lines,
              DesignLine(ingredientId: cand, role: p.mainRole(s), grams: grams),
            ],
          ),
        );
      }
    }
    return out;
  }

  /// Pure Innovation : candidats les plus utiles (ajout d'une petite
  /// quantité à [c], une évaluation chacun).
  List<String> _screenedPool(DesignComposition c) {
    final present = c.ids.toSet();
    final grams = math.max(1.0, c.servingMassG * 0.1);
    final ranked = <(double, String)>[];
    for (final id in p.pool) {
      if (present.contains(id)) continue;
      if (_exhausted) break;
      final probe = c.copyWith(
        lines: [
          ...c.lines,
          DesignLine(
            ingredientId: id,
            role: p.mainRole(c.skeleton),
            grams: grams,
          ),
        ],
      );
      ranked.add((_score(probe).objective, id));
    }
    ranked.sort((a, b) {
      final byScore = a.$1.compareTo(b.$1);
      return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
    });
    return [for (final r in ranked.take(12)) r.$2];
  }

  /// Lignes rangées par ordre des rôles du squelette.
  List<DesignLine> _ordered(DishSkeleton s, List<DesignLine> lines) {
    if (s.isGeneric) return lines;
    int rank(String role) {
      final i = s.roles.indexWhere((r) => r.role == role);
      return i < 0 ? s.roles.length : i;
    }

    final indexed = [for (var i = 0; i < lines.length; i++) (i, lines[i])];
    indexed.sort((a, b) {
      final byRole = rank(a.$2.role).compareTo(rank(b.$2.role));
      return byRole != 0 ? byRole : a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  /// Recherche locale depuis [start] : meilleur voisin tant qu'il
  /// améliore l'objectif. [accept] filtre les voisins (diversité).
  _Scored localSearch(
    DesignComposition start, {
    bool Function(DesignComposition c)? accept,
  }) {
    var current = optimize(start, accept: accept);
    for (var it = 0; it < budget.maxIterations && !_exhausted; it++) {
      // Pure Innovation : criblage du référentiel toutes les trois
      // itérations (le classement évolue peu d'un pas à l'autre).
      if (it % 3 == 0) _pool = null;
      final candidates = <_Scored>[];
      for (final n in _neighbours(current.composition)) {
        if (accept != null && !accept(n)) continue;
        if (_exhausted) break;
        final known = _known(n.setKey, accept);
        candidates.add(known ?? _score(_clampAll(n)));
      }
      if (candidates.isEmpty) break;
      candidates.sort(_byObjective);
      _Scored? bestNeighbour;
      for (final cand in candidates.take(budget.shortlist)) {
        if (_exhausted) break;
        final known = _known(cand.composition.setKey, accept);
        final quick =
            known ?? optimize(cand.composition, quick: true, accept: accept);
        if (bestNeighbour == null ||
            quick.objective < bestNeighbour.objective) {
          bestNeighbour = quick;
        }
      }
      if (bestNeighbour == null ||
          bestNeighbour.objective >= current.objective - 1e-6) {
        break;
      }
      final known = _known(bestNeighbour.composition.setKey, accept);
      final refined =
          known ?? optimize(bestNeighbour.composition, accept: accept);
      if (refined.objective >= current.objective - 1e-6) break;
      current = refined;
    }
    return current;
  }

  /// Composition déjà optimisée de l'ensemble [key], si elle respecte
  /// [accept].
  _Scored? _known(String key, bool Function(DesignComposition c)? accept) {
    final known = _archive[key];
    if (known == null) return null;
    return accept == null || accept(known.composition) ? known : null;
  }

  static int _byObjective(_Scored a, _Scored b) {
    final byObjective = a.objective.compareTo(b.objective);
    return byObjective != 0
        ? byObjective
        : a.composition.setKey.compareTo(b.composition.setKey);
  }

  // ------------------------------------------------------------------
  // Départs.
  // ------------------------------------------------------------------

  /// Départ du mode cohérent : imposés à leur rôle, puis rôles
  /// obligatoires complétés par le candidat le mieux accordé ; [full] :
  /// chaque rôle facultatif reçoit aussi un ingrédient.
  DesignComposition? _coherentStart(
    DishSkeleton s, {
    Set<String> avoid = const {},
    bool full = false,
  }) {
    final lines = <DesignLine>[];
    for (final id in p.required) {
      final r = s.rolesOf(id).isEmpty ? null : s.rolesOf(id).first;
      if (r != null) {
        lines.add(
          DesignLine(
            ingredientId: id,
            role: r.role,
            grams: math.sqrt(r.minGPerServing * r.maxGPerServing),
          ),
        );
      } else {
        lines.add(
          DesignLine(
            ingredientId: id,
            role: p.mainRole(s),
            grams: s.process.servingMassG * 0.1,
          ),
        );
      }
    }
    for (final r in p.rolesOf(s)) {
      var have = lines.where((l) => l.role == r.role).length;
      final wanted = full
          ? math.min(math.max(r.minCount, 1), r.maxCount)
          : r.minCount;
      final ranked = _rankByAccord(r.candidates, lines, avoid);
      for (final cand in ranked) {
        if (have >= wanted) break;
        if (lines.length >= DesignBrief.maxIngredients) break;
        if (lines.any((l) => l.ingredientId == cand)) continue;
        lines.add(
          DesignLine(
            ingredientId: cand,
            role: r.role,
            grams: math.sqrt(r.minGPerServing * r.maxGPerServing),
          ),
        );
        have++;
      }
      if (have < r.minCount) return null;
    }
    if (lines.isEmpty || lines.length > DesignBrief.maxIngredients) {
      return null;
    }
    return DesignComposition(skeleton: s, lines: _ordered(s, lines));
  }

  /// Candidats triés : non évités d'abord, puis accord moyen avec les
  /// lignes présentes (ordre du fichier à égalité).
  List<String> _rankByAccord(
    List<String> candidates,
    List<DesignLine> lines,
    Set<String> avoid,
  ) {
    double accord(String id) {
      if (lines.isEmpty) return 0;
      var sum = 0.0;
      for (final l in lines) {
        sum += ev.pairScore(id, l.ingredientId);
      }
      return sum / lines.length;
    }

    final indexed = [
      for (var i = 0; i < candidates.length; i++)
        (
          i,
          candidates[i],
          avoid.contains(candidates[i]),
          accord(candidates[i]),
        ),
    ];
    indexed.sort((a, b) {
      if (a.$3 != b.$3) return a.$3 ? 1 : -1;
      final byAccord = b.$4.compareTo(a.$4);
      if (byAccord.abs() > 0 && (a.$4 - b.$4).abs() > 0.05) return byAccord;
      return a.$1.compareTo(b.$1);
    });
    return [for (final e in indexed) e.$2];
  }

  // ------------------------------------------------------------------
  // Variantes.
  // ------------------------------------------------------------------

  /// Diversité : au plus 60 % d'ingrédients partagés et au plus 70 %
  /// de la masse d'une portion portée par des ingrédients partagés
  /// (hors imposés) — deux propositions ne diffèrent pas seulement par
  /// une pincée d'épice.
  bool _diverse(DesignComposition c, List<_Scored> chosen) => chosen.every(
    (v) =>
        DesignEngine.overlap(c.ids, v.ids) <= DesignEngine.maxOverlap + 1e-9 &&
        DesignEngine.massOverlap(c, v.composition, exclude: p.required) <=
            DesignEngine.maxMassOverlap - _roundingMargin,
  );

  /// Meilleure composition trouvée depuis [starts] : chaque départ est
  /// d'abord dégrossi (quantités), puis seuls les [searches] plus
  /// prometteurs sont explorés par recherche locale (budget maîtrisé).
  _Scored? _bestFrom(
    List<DesignComposition> starts,
    List<_Scored> chosen, {
    int searches = 2,
  }) {
    final seen = <String>{};
    final ranked = <_Scored>[];
    for (final start in starts) {
      if (_exhausted) break;
      if (!_diverse(start, chosen) || !seen.add(start.setKey)) continue;
      ranked.add(
        optimize(start, quick: true, accept: (c) => _diverse(c, chosen)),
      );
    }
    ranked.sort(_byObjective);
    _Scored? best;
    for (final r in ranked.take(searches)) {
      final found = localSearch(
        r.composition,
        accept: (c) => _diverse(c, chosen),
      );
      if (!_diverse(found.composition, chosen)) continue;
      if (best == null || _byObjective(found, best) < 0) best = found;
    }
    return best;
  }

  /// Trois variantes du mode cohérent.
  List<_Scored> coherentVariants() {
    final chosen = <_Scored>[];
    for (var k = 0; k < 3 && !_exhausted; k++) {
      final avoid = {for (final v in chosen) ...v.ids};
      final starts = <DesignComposition>[
        for (final s in p.templates) ...[
          ?_coherentStart(s, avoid: avoid),
          ?_coherentStart(s, avoid: avoid, full: true),
          // Meilleure composition déjà rencontrée qui respecte la
          // diversité (départ éprouvé).
          ?_bestArchived(s, chosen),
        ],
      ];
      final best = _bestFrom(starts, chosen, searches: k == 0 ? 3 : 2);
      if (best == null) break;
      chosen.add(best);
    }
    return _finalize(chosen);
  }

  DesignComposition? _bestArchived(DishSkeleton s, List<_Scored> chosen) {
    final entries =
        _archive.values
            .where((e) => e.composition.skeleton.id == s.id)
            .where((e) => _diverse(e.composition, chosen))
            .toList()
          ..sort(_byObjective);
    return entries.isEmpty ? null : entries.first.composition;
  }

  /// Trois variantes Pure Innovation ; [seeds] : variantes du mode
  /// cohérent (même demande), départs prioritaires.
  List<_Scored> innovationVariants(List<_Scored> seeds) {
    final seedFinals = <_Scored>[];
    for (final seed in seeds) {
      final c = seed.composition;
      if (p.templates.any((t) => t.id == c.skeleton.id)) {
        seedFinals.add(_score(c));
      }
    }
    final chosen = <_Scored>[];
    for (var k = 0; k < 3 && !_exhausted; k++) {
      final starts = <DesignComposition>[
        for (final s in seedFinals) s.composition,
        for (final t in p.templates.where((t) => t.isGeneric))
          ?_innovationStart(t, chosen),
        for (final t in p.templates) ?_bestArchived(t, chosen),
      ];
      final best = _bestFrom(starts, chosen);
      if (best == null) break;
      chosen.add(best);
    }
    final finals = _finalize(chosen);
    // Les départs cohérents (déjà arrondis) restent candidats : la
    // meilleure variante n'est jamais moins proche des objectifs.
    final bestSeed = _finalize(seedFinals, prune: false)
      ..sort((a, b) => a.deviation.compareTo(b.deviation));
    if (bestSeed.isNotEmpty &&
        (finals.isEmpty || bestSeed.first.deviation < finals.first.deviation)) {
      final others = [
        for (final f in finals)
          if (_diverse(f.composition, [bestSeed.first])) f,
      ];
      return [bestSeed.first, ...others.take(2)];
    }
    return finals;
  }

  /// Départ Pure Innovation : ingrédients imposés, sinon le meilleur
  /// ingrédient seul au criblage.
  DesignComposition? _innovationStart(DishSkeleton t, List<_Scored> chosen) {
    final mass = p.servingMass;
    if (p.required.isNotEmpty) {
      return DesignComposition(
        skeleton: t,
        lines: [
          for (final id in p.required)
            DesignLine(
              ingredientId: id,
              role: p.mainRole(t),
              grams: mass / p.required.length,
            ),
        ],
      );
    }
    final used = {for (final v in chosen) ...v.ids};
    _Scored? best;
    for (final id in p.pool) {
      if (used.contains(id) || _exhausted) continue;
      final c = DesignComposition(
        skeleton: t,
        lines: [DesignLine(ingredientId: id, role: p.mainRole(t), grams: mass)],
      );
      final s = _score(c);
      if (best == null || _byObjective(s, best) < 0) best = s;
    }
    return best?.composition;
  }

  /// Quantités arrondies (grammes de la recette), meilleur arrondi par
  /// ligne, puis écart recalculé.
  List<_Scored> _finalize(List<_Scored> chosen, {bool prune = true}) {
    final n = p.brief.servings;
    final out = <_Scored>[];
    for (final v in chosen) {
      var c = v.composition.copyWith(
        lines: [
          for (final l in v.composition.lines)
            l.withGrams(roundGrams(l.grams * n) / n),
        ],
        duration: v.composition.duration?.roundToDouble(),
        sameSet: true,
      );
      var best = _score(c);
      if (prune && !p.coherent) best = _prune(best, out);
      for (var i = 0; i < best.composition.lines.length; i++) {
        final g = best.composition.lines[i].grams * n;
        for (final alt in _gridNeighbours(g)) {
          final next = [...best.composition.lines];
          next[i] = next[i].withGrams(alt / n);
          final cand = _score(
            best.composition.copyWith(lines: next, sameSet: true),
          );
          if (cand.objective < best.objective - 1e-12 &&
              _finalDiverse(cand.composition, out)) {
            best = cand;
          }
        }
      }
      out.add(best);
    }
    return out..sort(_byObjective);
  }

  /// Marge de la recherche sur la part de masse commune : l'arrondi
  /// des quantités ne doit pas faire franchir le seuil garanti.
  static const double _roundingMargin = 0.03;

  /// Diversité garantie des variantes finales (seuils publiés).
  bool _finalDiverse(DesignComposition c, List<_Scored> done) => done.every(
    (v) =>
        DesignEngine.overlap(c.ids, v.ids) <= DesignEngine.maxOverlap + 1e-9 &&
        DesignEngine.massOverlap(c, v.composition, exclude: p.required) <=
            DesignEngine.maxMassOverlap + 1e-9,
  );

  /// Pure Innovation : retire les lignes négligeables (moins de 2 % de
  /// la portion) qui n'apportent presque rien à l'écart aux objectifs.
  _Scored _prune(_Scored start, List<_Scored> done) {
    var best = start;
    var changed = true;
    while (changed && best.composition.lines.length > 1) {
      changed = false;
      final c = best.composition;
      final total = c.servingMassG;
      for (var i = 0; i < c.lines.length; i++) {
        final l = c.lines[i];
        if (_isRequired(l.ingredientId) || l.grams >= total * 0.02) continue;
        final cand = _score(c.copyWith(lines: [...c.lines]..removeAt(i)));
        if (cand.objective <= best.objective + 0.005 &&
            _finalDiverse(cand.composition, done)) {
          best = cand;
          changed = true;
          break;
        }
      }
    }
    return best;
  }

  /// Valeurs voisines sur la grille d'arrondi.
  static List<double> _gridNeighbours(double g) {
    final step = g < 1
        ? 0.1
        : g < 10
        ? 0.5
        : g < 100
        ? 1.0
        : 5.0;
    return [
      for (final v in [g - step, g + step])
        if (v >= step) roundGrams(v),
    ];
  }
}
