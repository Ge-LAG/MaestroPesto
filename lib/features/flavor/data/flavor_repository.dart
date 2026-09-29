// Phase 09 Lot G / Phase 10 Lot E — FlavorRepository.
//
// Phase 10 (ac-123) : les scores ne sont plus lus dans les 4 560 paires
// « prédites » de la Phase 3 (Jaccard ≈ 0 faute de données, rouge
// trompeur). Ils sont calculés par le [FlavorPairingEngine] à partir des
// profils sensoriels 603/603, avec deux sources de soutien empirique :
//   1. les accords OBSERVÉS de la Phase 3 (paires et combinaisons
//      n-aires `observed_or_predicted = observed`) ;
//   2. les accords culinaires CURATÉS (`culinary_pairings`).
// Chaque score porte son origine (observé, curaté, prédit) et sa
// confiance.
//
// Mode hérité : une base sans profils sensoriels (import antérieur,
// tests) sert les enregistrements `flavor_compatibility` tels quels,
// comme en Phase 09.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/flavor_analysis.dart';
import '../../../core/models/flavor_match.dart';
import '../../../core/models/flavor_profile.dart';
import '../../../core/scoring/flavor_pairing_engine.dart';
import '../../../core/scoring/flavor_scorer.dart';
import '../../../core/scoring/recipe_flavor_analyzer.dart';

/// Repository pour la Phase 3 (flavour / associations aromatiques).
class FlavorRepository {
  FlavorRepository(this._db) : _preloaded = null, _preloadedProfiles = null;

  /// Constructeur de test : injecte directement des matches (pas de Drift).
  @visibleForTesting
  FlavorRepository.fromMatches(List<FlavorMatch> matches)
    : _db = null,
      _preloaded = matches,
      _preloadedProfiles = null;

  /// Constructeur de test : profils et accords empiriques injectés.
  @visibleForTesting
  FlavorRepository.fromProfiles(
    List<FlavorProfile> profiles, {
    Map<String, EmpiricalPairing> empirical = const {},
    Map<String, String> names = const {},
  }) : _db = null,
       _preloaded = null,
       _preloadedProfiles = profiles {
    _empirical = {
      for (final e in empirical.entries) _pairKey(e.key.split('|')): e.value,
    };
    _names = names;
  }

  final AppDatabase? _db;
  final List<FlavorMatch>? _preloaded;
  final List<FlavorProfile>? _preloadedProfiles;

  /// Enregistrements hérités / n-aires observés : clé = ids triés.
  Map<String, FlavorMatch>? _cache;
  Map<String, FlavorProfile>? _profiles;
  Map<String, EmpiricalPairing> _empirical = {};
  Map<String, String> _names = {};
  Map<String, String> _categories = {};
  bool _loaded = false;

  static String _keyFor(List<String> ingredientIds) =>
      (List<String>.of(ingredientIds)..sort()).join('|');

  static String _pairKey(List<String> ids) => _keyFor(ids);

  /// Vrai quand les profils sensoriels Phase 10 sont disponibles.
  bool get usesProfiles => (_profiles?.isNotEmpty ?? false);

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    final built = <String, FlavorMatch>{};
    final preloaded = _preloaded;
    final preloadedProfiles = _preloadedProfiles;
    if (preloaded != null) {
      for (final m in preloaded) {
        _putBest(built, _keyFor([m.ingredientAId, ?m.ingredientBId]), m);
      }
      _profiles = const {};
    } else if (preloadedProfiles != null) {
      _profiles = {for (final p in preloadedProfiles) p.ingredientId: p};
    } else {
      final db = _db!;
      final profileRows = await db.select(db.ingredientFlavorProfiles).get();
      _profiles = {
        for (final r in profileRows)
          r.ingredientId: FlavorProfile.fromEncoded(
            ingredientId: r.ingredientId,
            encoded: r.descriptors,
            context: r.context,
            intensity: r.intensity,
            evidence: r.evidenceLevel,
            confidence: r.confidence,
            note: r.note,
          ),
      };
      final useProfiles = _profiles!.isNotEmpty;
      final rows = await db.select(db.flavorCompatibility).get();
      for (final row in rows) {
        final parsed = _fromRow(row);
        if (parsed == null) continue;
        final observed = (row.observedOrPredicted ?? '') == 'observed';
        if (useProfiles) {
          // Phase 10 : seules les observations servent de soutien.
          if (!observed) continue;
          if (parsed.ids.length == 2) {
            _empirical[_pairKey(parsed.ids)] = EmpiricalPairing(
              score: parsed.match.overallScore,
              observed: true,
              kind: 'observed',
              note: parsed.match.explanation,
            );
            continue;
          }
        }
        _putBest(built, _keyFor(parsed.ids), parsed.match);
      }
      if (useProfiles) {
        for (final r in await db.select(db.culinaryPairings).get()) {
          final key = _pairKey([r.ingredientAId, r.ingredientBId]);
          // Une observation Phase 3 prime sur une curation.
          _empirical.putIfAbsent(
            key,
            () => EmpiricalPairing(
              score: r.strength,
              observed: false,
              kind: r.kind,
              note: r.note,
            ),
          );
        }
        final ingredients = await db.select(db.ingredients).get();
        _names = {
          for (final i in ingredients) i.ingredientId: i.canonicalNameFr,
        };
        _categories = {
          for (final i in ingredients)
            i.ingredientId: i.categoryLevel2 ?? i.categoryLevel1,
        };
      }
    }
    _cache = built;
    _loaded = true;
  }

  /// Cahier §7.2 : le **meilleur** FlavorMatch pour une combinaison.
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

  /// Invalide les caches mémoire (appelé après un import CSV, §11.3).
  void invalidateCache() {
    _cache = null;
    _profiles = null;
    _empirical = {};
    _loaded = false;
  }

  /// Profil sensoriel d'un ingrédient (null si absent).
  Future<FlavorProfile?> profileFor(String ingredientId) async {
    await _ensureLoaded();
    return _profiles?[ingredientId];
  }

  /// Score d'une paire par le moteur v2 (null sans profil).
  FlavorMatch? _enginePair(String a, String b) {
    final pa = _profiles?[a];
    final pb = _profiles?[b];
    if (pa == null || pb == null || a == b) return null;
    return FlavorPairingEngine.scorePair(
      pa,
      pb,
      empirical: _empirical[_pairKey([a, b])],
    );
  }

  FlavorMatch? _lookup(List<String> ids) {
    if (usesProfiles) {
      if (ids.length == 2) return _enginePair(ids[0], ids[1]);
      return _cache?[_keyFor(ids)];
    }
    return _cache?[_keyFor(ids)];
  }

  /// Meilleur [FlavorMatch] pour une combinaison (ordre indifférent) :
  /// paire → moteur v2 ; n-aire → combinaison observée, sinon agrégat
  /// des paires. Null si aucune donnée.
  Future<FlavorMatch?> bestMatchFor(List<String> ingredientIds) async {
    if (ingredientIds.length < 2) return null;
    await _ensureLoaded();
    final match = FlavorScorer.scoreCombination(ingredientIds, _lookup);
    if (match == null || !usesProfiles || ingredientIds.length == 2) {
      return match;
    }
    if (_cache?[_keyFor(ingredientIds)] != null) return match;
    // Agrégat de paires : prédiction si aucune paire n'est étayée.
    var supported = false;
    for (var i = 0; i < ingredientIds.length && !supported; i++) {
      for (var j = i + 1; j < ingredientIds.length; j++) {
        final m = _lookup([ingredientIds[i], ingredientIds[j]]);
        if (m != null && !m.isPrediction) {
          supported = true;
          break;
        }
      }
    }
    return match.copyWith(
      evidence: supported
          ? FlavorMatchEvidence.curated
          : FlavorMatchEvidence.predicted,
    );
  }

  /// Paires incompatibles parmi les ingrédients donnés. Phase 10 :
  /// seules les incompatibilités ÉTAYÉES (observées ou curatées) sont
  /// renvoyées — une prédiction basse n'est pas une alerte.
  Future<List<FlavorMatch>> incompatiblePairs(
    List<String> ingredientIds,
  ) async {
    await _ensureLoaded();
    final result = <FlavorMatch>[];
    for (var i = 0; i < ingredientIds.length; i++) {
      for (var j = i + 1; j < ingredientIds.length; j++) {
        final match = _lookup([ingredientIds[i], ingredientIds[j]]);
        if (match == null) continue;
        final bad = usesProfiles
            ? match.isSupportedIncompatibility
            : match.overallScore < 0.40;
        if (bad) result.add(match);
      }
    }
    return result;
  }

  /// Lookup synchrone d'une combinaison exacte (cache chaud requis).
  FlavorMatch? cachedMatchFor(List<String> ingredientIds) =>
      _loaded ? _lookup(ingredientIds) : null;

  /// Meilleure donnée connue pour une paire {a, b} et la taille de la
  /// combinaison source (2 = paire directe). Mode hérité : repli sur la
  /// plus petite combinaison N-aire contenant la paire.
  Future<({FlavorMatch match, int size})?> bestKnownMatchFor(
    String a,
    String b,
  ) async {
    await _ensureLoaded();
    final direct = _lookup([a, b]);
    if (direct != null) return (match: direct, size: 2);
    if (usesProfiles) return null;

    final pairKey = _keyFor([a, b]);
    ({FlavorMatch match, int size})? best;
    for (final entry in _cache!.entries) {
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

  /// Analyse aromatique d'une recette : toutes les paires, harmonie,
  /// ponts, profil gustatif pondéré par [weights] (grammes), arômes
  /// dominants. Null sans profils (mode hérité).
  Future<RecipeFlavorAnalysis?> analyze(
    List<String> ingredientIds, {
    Map<String, double> weights = const {},
  }) async {
    await _ensureLoaded();
    if (!usesProfiles) return null;
    final ids = ingredientIds.toSet().where(_profiles!.containsKey).toList();
    if (ids.length < 2) return null;
    return RecipeFlavorAnalyzer.analyze(
      ids: ids,
      profileOf: (id) => _profiles![id]!,
      pair: (a, b) => _enginePair(a, b)!,
      combination: _cache?[_keyFor(ids)],
      weights: weights,
    );
  }

  /// Données chargées (profils, soutiens empiriques, combinaisons n-aires
  /// observées, noms) pour un calcul hors base (moteur de composition).
  Future<FlavorSnapshot> snapshot() async {
    await _ensureLoaded();
    return FlavorSnapshot(
      profiles: Map.unmodifiable(_profiles ?? const {}),
      empirical: Map.unmodifiable(_empirical),
      combinations: {
        for (final e in (_cache ?? const <String, FlavorMatch>{}).entries)
          if (e.key.split('|').length > 2) e.key: e.value,
      },
    );
  }

  /// Ingrédients du référentiel qui s'accordent le mieux avec la
  /// recette (hors ingrédients présents et texturants neutres), classés
  /// par score moyen puis nombre d'accords étayés.
  Future<List<FlavorSuggestion>> suggestComplements(
    List<String> ingredientIds, {
    int limit = 6,
  }) async {
    await _ensureLoaded();
    if (!usesProfiles) return const [];
    final present = ingredientIds.toSet();
    final base = present.where(_profiles!.containsKey).toList();
    if (base.isEmpty) return const [];
    final suggestions = <FlavorSuggestion>[];
    for (final candidate in _profiles!.values) {
      final id = candidate.ingredientId;
      if (present.contains(id) || candidate.intensity < 0.15) continue;
      var sum = 0.0;
      var supported = 0;
      var negative = false;
      final reasons = <String>[];
      for (final other in base) {
        final m = _enginePair(id, other);
        if (m == null) continue;
        if (m.isSupportedIncompatibility) negative = true;
        sum += m.overallScore;
        if (!m.isPrediction && m.overallScore >= 0.7) {
          supported++;
          final name = _names[other];
          if (name != null && reasons.length < 3) {
            reasons.add('accord reconnu avec $name');
          }
        }
      }
      if (negative) continue;
      final score = sum / base.length;
      if (supported == 0 && score < 0.6) continue;
      if (reasons.isEmpty) {
        final shared = <String>{};
        for (final other in base) {
          shared.addAll(
            FlavorPairingEngine.sharedAromas(candidate, _profiles![other]!),
          );
        }
        if (shared.isNotEmpty) {
          reasons.add(
            'arômes partagés : '
            '${shared.take(3).map(SensoryOntology.label).join(', ')}',
          );
        }
      }
      suggestions.add(
        FlavorSuggestion(
          ingredientId: id,
          name: _names[id] ?? id,
          category: _categories[id],
          score: score,
          supportedPairs: supported,
          reasons: reasons,
        ),
      );
    }
    suggestions.sort((a, b) {
      final bySupport = b.supportedPairs.compareTo(a.supportedPairs);
      if (bySupport != 0) return bySupport;
      return b.score.compareTo(a.score);
    });
    return suggestions.take(limit).toList();
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
    final observed = (row.observedOrPredicted ?? '') == 'observed';
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
      evidence: observed
          ? FlavorMatchEvidence.observed
          : FlavorMatchEvidence.predicted,
      confidence: row.confidence,
    );
    return (ids: ids, match: match);
  }
}

/// Instantané des données aromatiques (pur, transférable vers un
/// isolate). Clés des soutiens et combinaisons : identifiants triés
/// joints par `|`.
class FlavorSnapshot {
  const FlavorSnapshot({
    required this.profiles,
    required this.empirical,
    required this.combinations,
  });

  final Map<String, FlavorProfile> profiles;
  final Map<String, EmpiricalPairing> empirical;
  final Map<String, FlavorMatch> combinations;

  static String keyFor(List<String> ids) =>
      (List<String>.of(ids)..sort()).join('|');
}
