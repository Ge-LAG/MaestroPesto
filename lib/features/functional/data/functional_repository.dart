// Phase 09 Lot H — H2 : FunctionalRepository (plan §8.2).
//
// Charge les 16 règles `interaction_rules` + les profils
// `functional_ingredients` en mémoire au premier accès (cache §11.2 —
// ~5 Ko) et sert les lookups depuis ce cache. `invalidateCache()` est
// appelé par le flux d'import CSV (§11.3).
//
// dp-107 : l'évaluation des règles (mode dégradé, confidence × 0.5)
// est déléguée au [FunctionalConstraintSolver] pur.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/functional_alert.dart';
import '../../../core/scoring/functional_constraint_solver.dart';

/// Repository pour la Phase 4 (functional / physico-chimie).
class FunctionalRepository {
  FunctionalRepository(this._db) : _preloadedRules = null;

  /// Constructeur de test : injecte directement des règles (pas de Drift).
  @visibleForTesting
  FunctionalRepository.fromRules(List<InteractionRule> rules)
    : _db = null,
      _preloadedRules = rules;

  final AppDatabase? _db;
  final List<InteractionRule>? _preloadedRules;

  /// Cache mémoire des règles (16 lignes, §11.2).
  List<InteractionRule>? _rulesCache;

  Future<List<InteractionRule>> _ensureRules() async {
    final cached = _rulesCache;
    if (cached != null) return cached;
    final preloaded = _preloadedRules;
    final rules = preloaded ?? await _db!.select(_db.interactionRules).get();
    _rulesCache = rules;
    return rules;
  }

  /// Invalide le cache mémoire (appelé après un import CSV, §11.3).
  void invalidateCache() => _rulesCache = null;

  /// Renvoie les alertes applicables aux ingrédients donnés, triées
  /// par sévérité décroissante (cf. [FunctionalConstraintSolver]).
  Future<List<FunctionalAlert>> alertsFor(List<String> ingredientIds) async {
    if (ingredientIds.isEmpty) return const <FunctionalAlert>[];
    final rules = await _ensureRules();
    return FunctionalConstraintSolver.evaluate(
      recipeIngredientIds: ingredientIds,
      allRules: rules,
    );
  }

  /// Lookup synchrone des alertes depuis le cache chaud (widgets qui
  /// ont déjà déclenché un chargement). Renvoie null si cache froid.
  List<FunctionalAlert>? cachedAlertsFor(List<String> ingredientIds) {
    final rules = _rulesCache;
    if (rules == null || ingredientIds.isEmpty) return null;
    return FunctionalConstraintSolver.evaluate(
      recipeIngredientIds: ingredientIds,
      allRules: rules,
    );
  }

  /// Renvoie le profil physico-chimique d'un ingrédient pour un état
  /// donné (`raw`, `boiled`…). Null si absent. Requiert la DB (pas de
  /// profil injectable en v1 — les tests passent par Drift en mémoire).
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
