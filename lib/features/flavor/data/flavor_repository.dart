// Phase 09 Lot G — G3 : FlavorRepository (plan §7.2).
//
// Charge les ~4 594 enregistrements `flavor_compatibility` en mémoire
// au premier accès (cache §11.2 — ~200 Ko, tient largement en RAM) et
// sert les lookups depuis ce cache. `invalidateCache()` est appelé par
// le flux d'import CSV (§11.3).
//
// dp-106 : l'`overallScore` est lu tel quel depuis la table ; le scoring
// n-aire (fallback paires) est délégué au [FlavorScorer] pur.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/flavor_match.dart';
import '../../../core/scoring/flavor_scorer.dart';

/// Repository pour la Phase 3 (flavour / associations aromatiques).
class FlavorRepository {
  FlavorRepository(this._db) : _preloaded = null;

  /// Constructeur de test : injecte directement des matches (pas de Drift).
  @visibleForTesting
  FlavorRepository.fromMatches(List<FlavorMatch> matches)
    : _db = null,
      _preloaded = matches;

  final AppDatabase? _db;
  final List<FlavorMatch>? _preloaded;

  /// Cache mémoire : clé = ids triés jointes par '|' (ordre indifférent).
  Map<String, FlavorMatch>? _cache;

  static String _keyFor(List<String> ingredientIds) =>
      (List<String>.of(ingredientIds)..sort()).join('|');

  Future<Map<String, FlavorMatch>> _ensureCache() async {
    final cached = _cache;
    if (cached != null) return cached;
    final built = <String, FlavorMatch>{};
    final preloaded = _preloaded;
    if (preloaded != null) {
      for (final m in preloaded) {
        _putBest(built, _keyFor(m.allIngredientIds), m);
      }
    } else {
      final rows = await _db!.select(_db.flavorCompatibility).get();
      for (final row in rows) {
        final parsed = _fromRow(row);
        if (parsed != null) _putBest(built, _keyFor(parsed.ids), parsed.match);
      }
    }
    _cache = built;
    return built;
  }

  /// Cahier §7.2 : « le **meilleur** FlavorMatch pour une combinaison ».
  /// Les données réelles contiennent plusieurs enregistrements par clé
  /// (contextes prédits/observés) : on garde le score le plus élevé de
  /// façon déterministe, indépendante de l'ordre de lecture en base.
  static void _putBest(
    Map<String, FlavorMatch> map,
    String key,
    FlavorMatch match,
  ) {
    final existing = map[key];
    if (existing == null || match.overallScore > existing.overallScore) {
      map[key] = match;
    }
  }

  /// Invalide le cache mémoire (appelé après un import CSV, §11.3).
  void invalidateCache() => _cache = null;

  /// Renvoie le meilleur [FlavorMatch] pour une combinaison d'ingrédients
  /// (ordre indifférent) : enregistrement n-aire direct s'il existe,
  /// sinon fallback [FlavorScorer] sur les paires 2×2. Null si la
  /// combinaison n'a aucune donnée en base.
  Future<FlavorMatch?> bestMatchFor(List<String> ingredientIds) async {
    if (ingredientIds.length < 2) return null;
    final cache = await _ensureCache();
    return FlavorScorer.scoreCombination(
      ingredientIds,
      (ids) => cache[_keyFor(ids)],
    );
  }

  /// Renvoie les paires incompatibles (score < 0.40, catégorie `avoid`)
  /// parmi les ingrédients donnés. Utilisé par le recommender (§9, Lot H).
  Future<List<FlavorMatch>> incompatiblePairs(
    List<String> ingredientIds,
  ) async {
    final cache = await _ensureCache();
    final result = <FlavorMatch>[];
    for (var i = 0; i < ingredientIds.length; i++) {
      for (var j = i + 1; j < ingredientIds.length; j++) {
        final match = cache[_keyFor([ingredientIds[i], ingredientIds[j]])];
        if (match != null && match.overallScore < 0.40) {
          result.add(match);
        }
      }
    }
    return result;
  }

  /// Lookup synchrone d'une paire ou combinaison exacte depuis le cache.
  /// Nécessite que le cache soit déjà chaud (via [bestMatchFor] ou
  /// [incompatiblePairs]) ; sinon renvoie null. Exposé pour les widgets
  /// qui ont déjà déclenché un chargement (heatmap).
  FlavorMatch? cachedMatchFor(List<String> ingredientIds) =>
      _cache?[_keyFor(ingredientIds)];

  /// Retour PO n°3 (vraie heatmap) : meilleure donnée connue pour une
  /// paire {a, b} :
  /// 1. l'enregistrement 2×2 direct s'il existe ;
  /// 2. sinon, à titre d'approximation documentée, la plus petite
  ///    combinaison N-aire connue contenant les deux ingrédients
  ///    (score le plus élevé à taille égale).
  /// Null si aucune donnée ne couvre la paire.
  Future<({FlavorMatch match, int size})?> bestKnownMatchFor(
    String a,
    String b,
  ) async {
    final cache = await _ensureCache();
    final pairKey = _keyFor([a, b]);
    final direct = cache[pairKey];
    if (direct != null) return (match: direct, size: 2);

    ({FlavorMatch match, int size})? best;
    for (final entry in cache.entries) {
      if (entry.key == pairKey) continue;
      final ids = entry.key.split('|');
      if (ids.length < 3 || !ids.contains(a) || !ids.contains(b)) continue;
      final size = ids.length;
      final current = best;
      final better =
          current == null ||
          size < current.size ||
          (size == current.size &&
              entry.value.overallScore > current.match.overallScore);
      if (better) best = (match: entry.value, size: size);
    }
    return best;
  }

  ({List<String> ids, FlavorMatch match})? _fromRow(
    FlavorCompatibilityData row,
  ) {
    final ids = (row.ingredientIds ?? '')
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    final score = row.overallScore;
    if (ids.isEmpty || score == null) return null;
    final match = FlavorMatch(
      ingredientAId: ids.first,
      ingredientBId: ids.length == 2 ? ids[1] : null,
      combinationSize: row.combinationSize ?? ids.length,
      overallScore: score,
      aromaSimilarity: row.aromaSimilarity,
      tasteBalance: row.tasteBalance,
      dominanceRisk: row.dominanceRisk,
      maskingRisk: row.maskingRisk,
      culinarySupport: row.culinarySupport,
      evidenceRefs: (row.evidenceRefs ?? '')
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList(),
      explanation: row.explanation,
    );
    return (ids: ids, match: match);
  }
}

/// Extension interne : tous les ids couverts par un match.
extension on FlavorMatch {
  List<String> get allIngredientIds => [ingredientAId, ?ingredientBId];
}
