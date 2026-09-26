// Phase 09 Lot H / Phase 10 Lot C — FunctionalRepository.
//
// Charge les règles `interaction_rules` et le maillon ingrédient →
// composants (`ingredient_functional_components`, ac-122) en mémoire au
// premier accès, puis évalue les règles par le
// [FunctionalConstraintSolver] v2.
//
// `alertsFor` est l'évaluation LÉGÈRE (composants + masses, sans
// composition ni procédé : beaucoup de conditions restent « à
// vérifier »), utilisée par le recommender et le formulaire. L'analyse
// complète d'une recette passe par `RecipeAnalysisService`.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/functional_alert.dart';
import '../../../core/scoring/functional_constraint_solver.dart';
import '../../../core/scoring/physchem_estimator.dart';

/// Repository pour la Phase 4 (functional / physico-chimie).
class FunctionalRepository {
  FunctionalRepository(this._db)
    : _preloadedRules = null,
      _preloadedComponents = null;

  /// Constructeur de test : règles et composants injectés (pas de
  /// Drift). Un identifiant sans composant connu est traité comme un
  /// identifiant de composant (compatibilité Phase 09).
  @visibleForTesting
  FunctionalRepository.fromRules(
    List<InteractionRule> rules, {
    Map<String, Map<String, double>> components = const {},
  }) : _db = null,
       _preloadedRules = rules,
       _preloadedComponents = components;

  final AppDatabase? _db;
  final List<InteractionRule>? _preloadedRules;
  final Map<String, Map<String, double>>? _preloadedComponents;

  List<InteractionRule>? _rulesCache;
  Map<String, Map<String, double>>? _componentsCache;

  Future<List<InteractionRule>> _ensureRules() async {
    final cached = _rulesCache;
    if (cached != null) return cached;
    final rules =
        _preloadedRules ?? await _db!.select(_db.interactionRules).get();
    _rulesCache = rules;
    return rules;
  }

  Future<Map<String, Map<String, double>>> _ensureComponents() async {
    final cached = _componentsCache;
    if (cached != null) return cached;
    final preloaded = _preloadedComponents;
    if (preloaded != null) return _componentsCache = preloaded;
    final map = <String, Map<String, double>>{};
    for (final r
        in await _db!.select(_db.ingredientFunctionalComponents).get()) {
      map.putIfAbsent(r.ingredientId, () => {})[r.componentId] =
          r.fractionGPer100g;
    }
    return _componentsCache = map;
  }

  /// Invalide les caches mémoire (appelé après un import CSV, §11.3).
  void invalidateCache() {
    _rulesCache = null;
    _componentsCache = null;
  }

  /// Règles Phase 4 chargées.
  Future<List<InteractionRule>> rules() => _ensureRules();

  /// Évaluation légère : composants des ingrédients + masses.
  Future<List<FunctionalAlert>> alertsFor(
    List<String> ingredientIds, {
    Map<String, double>? gramsByIngredient,
  }) async {
    if (ingredientIds.isEmpty) return const <FunctionalAlert>[];
    final rules = await _ensureRules();
    final components = await _ensureComponents();
    final ids = ingredientIds.toSet().toList();
    final lines = <MixLine>[
      for (var i = 0; i < ids.length; i++)
        MixLine(
          index: i,
          label: ids[i],
          ingredientId: ids[i],
          grams: gramsByIngredient?[ids[i]] ?? 100,
          components: components[ids[i]] ?? {ids[i]: 100},
        ),
    ];
    return FunctionalConstraintSolver.evaluateMix(
      state: PhysChemEstimator.estimate(lines),
      rules: rules,
    );
  }

  /// Évaluation complète d'un état de mélange déjà estimé.
  Future<List<FunctionalAlert>> alertsForState(PhysChemState state) async =>
      FunctionalConstraintSolver.evaluateMix(
        state: state,
        rules: await _ensureRules(),
      );

  /// Renvoie le profil physico-chimique d'un ingrédient pour un état
  /// donné (`raw`, `boiled`…). Null si absent ou sans base.
  Future<FunctionalIngredient?> profileFor(
    String ingredientId, {
    required String stateId,
  }) async {
    final db = _db;
    if (db == null) return null;
    return (db.select(db.functionalIngredients)
          ..where((t) => t.ingredientId.equals(ingredientId))
          ..where((t) => t.ingredientStateId.equals(stateId))
          ..limit(1))
        .getSingleOrNull();
  }
}
