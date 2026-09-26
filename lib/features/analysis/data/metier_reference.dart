// Phase 10 — cache des données de référence métier nécessaires à
// l'analyse d'une recette (catégories du registre, données culinaires,
// composants fonctionnels, facteurs de procédé, règles Phase 4).
//
// Chargé une fois par base (≈ 3 000 lignes, quelques centaines de Ko),
// invalidé après un import CSV.

import 'package:meta/meta.dart';

import '../../../core/database/app_database.dart';
import '../../../core/models/process_models.dart';
import '../../../core/scoring/nutrition_feedback.dart';
import '../../../core/scoring/quantity_converter.dart';

/// Fiche de référence d'un ingrédient pour l'analyse.
@immutable
class IngredientReference {
  const IngredientReference({
    required this.id,
    required this.name,
    required this.level1,
    required this.level2,
    this.processingState,
    this.densityGPerMl,
    this.densityNote,
    this.unitMasses = const <String, double>{},
    this.ph,
    this.components = const <String, double>{},
    this.allergens = const <String>[],
    this.inferredAllergens = const <String>{},
  });

  final String id;
  final String name;
  final String level1;
  final String level2;
  final String? processingState;
  final double? densityGPerMl;
  final String? densityNote;
  final Map<String, double> unitMasses;
  final double? ph;

  /// Composants fonctionnels (g/100 g).
  final Map<String, double> components;

  /// Allergènes de l'ingrédient : étiquettes du référentiel corrigées
  /// et allergènes déduits (enrichissement `ingredient_allergens`).
  final List<String> allergens;

  /// Sous-ensemble de [allergens] déduit par règle (non déclaré au
  /// référentiel).
  final Set<String> inferredAllergens;

  String get normalizedName => _normalize(name);

  /// Groupe d'aliments pour les facteurs de procédé (légumineuse fraîche
  /// traitée comme un légume ; sèche comme légumineuse).
  FoodGroup get foodGroup {
    final g = FoodGroup.fromCategories(level1, level2);
    if (g == FoodGroup.legume) {
      final dry =
          processingState == 'dried' || RegExp(r'\bsec\b').hasMatch(name);
      return dry ? FoodGroup.legume : FoodGroup.vegetable;
    }
    return g;
  }

  IngredientUnitData get unitData {
    final sources = unitSourcesOf(densityNote);
    return IngredientUnitData(
      densityGPerMl: densityGPerMl,
      densitySource: sources['densite'] ?? densityNote,
      unitMasses: unitMasses,
      unitSources: sources,
    );
  }

  /// Sources courtes d'une note culinaire structurée
  /// (« densite : USDA FDC 170000 (…) | piece : estimation par
  /// catégorie (…) ») : clé → « USDA FDC » ou « estimation ».
  static Map<String, String> unitSourcesOf(String? note) {
    final out = <String, String>{};
    for (final segment in (note ?? '').split(' | ')) {
      final i = segment.indexOf(' : ');
      if (i <= 0) continue;
      final key = segment.substring(0, i).trim();
      final rest = segment.substring(i + 3);
      out[key] = rest.startsWith('USDA')
          ? 'USDA FDC'
          : rest.startsWith('estimation')
          ? 'estimation'
          : rest;
    }
    return out;
  }

  /// Classe Nutri-Score « fruits, légumes, légumineuses ».
  FvlClass get fvlClass {
    final n = normalizedName;
    if (level2 == 'fruit') return FvlClass.fruit;
    if (level2 == 'légumineuse') return FvlClass.legume;
    if (level2 == 'légume' || level2 == 'herbe aromatique') {
      if (RegExp(r'pomme de terre|patate douce|manioc|igname|taro')
          .hasMatch(n)) {
        return FvlClass.none;
      }
      return FvlClass.vegetable;
    }
    if (level2 == 'sous-produit' &&
        RegExp(r'compote|coulis|concentre de tomate').hasMatch(n)) {
      return n.contains('tomate') ? FvlClass.vegetable : FvlClass.fruit;
    }
    return FvlClass.none;
  }

  /// Étiquettes de rôle physico-chimique.
  Set<String> get tags {
    final n = normalizedName;
    return {
      if (RegExp(r'^levure boulangere|^levain').hasMatch(n)) 'yeast',
      if (RegExp(r'oeuf').hasMatch(n)) 'egg',
      if (RegExp(r'^lait( |$)|^creme (liquide|double|fraiche|epaisse|entiere)')
          .hasMatch(n))
        'dairy_liquid',
      if (RegExp(
        r'^vinaigre|^citron|^jus de citron|^acide citrique|^acide tartrique|'
        r'^vin |^vin$|^combava|^lime',
      ).hasMatch(n))
        'acidulant',
      if (RegExp(r'^ananas|^kiwi|^papaye').hasMatch(n)) 'protease_fruit',
      if (RegExp(r'^huile').hasMatch(n)) 'liquid_oil',
    };
  }

  static String _normalize(String s) => s
      .toLowerCase()
      .replaceAll('œ', 'oe')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[àâä]'), 'a')
      .replaceAll(RegExp(r'[ùûü]'), 'u')
      .replaceAll(RegExp(r'[ôö]'), 'o')
      .replaceAll(RegExp(r'[ïî]'), 'i')
      .replaceAll('ç', 'c');
}

/// Cache de référence (un par base).
class MetierReference {
  MetierReference._({
    required this.ingredients,
    required this.factors,
    required this.rules,
  });

  final Map<String, IngredientReference> ingredients;
  final Map<(FoodGroup, CookingMethod), CookingFactor> factors;
  final List<InteractionRule> rules;

  static final Expando<Future<MetierReference>> _cache = Expando();

  /// Référence de [db] (chargée à la première demande).
  static Future<MetierReference> of(AppDatabase db) => _cache[db] ??= _load(db);

  /// À appeler après un import CSV.
  static void invalidate(AppDatabase db) => _cache[db] = null;

  /// Facteur (groupe, mode) avec repli sur le groupe générique ; une
  /// matière grasse n'a de facteur qu'en friture.
  CookingFactor? factorFor(FoodGroup group, CookingMethod method) {
    final exact = factors[(group, method)];
    if (exact != null) return exact;
    if (group == FoodGroup.fat) return null;
    return factors[(FoodGroup.other, method)];
  }

  static Future<MetierReference> _load(AppDatabase db) async {
    final culinary = {
      for (final r in await db.select(db.ingredientCulinary).get())
        r.ingredientId: r,
    };
    final components = <String, Map<String, double>>{};
    for (final r in await db.select(db.ingredientFunctionalComponents).get()) {
      components.putIfAbsent(r.ingredientId, () => {})[r.componentId] =
          r.fractionGPer100g;
    }
    // Densités mesurées Phase 4 (prioritaires sur les densités de
    // catégorie).
    final measuredDensity = <String, double>{};
    for (final r in await db.select(db.functionalIngredients).get()) {
      final d = r.densityGPerMl;
      if (d != null) measuredDensity[r.ingredientId] = d;
    }
    final allergenRows = {
      for (final r in await db.select(db.ingredientAllergens).get())
        r.ingredientId: r,
    };
    List<String> split(String? raw) => [
      for (final t in (raw ?? '').split('|'))
        if (t.trim().isNotEmpty) t.trim(),
    ];
    final ingredients = <String, IngredientReference>{};
    for (final r in await db.select(db.ingredients).get()) {
      final enriched = allergenRows[r.ingredientId];
      final inferred = split(enriched?.inferredTags).toSet();
      final allergens = enriched == null
          ? split(r.allergenTags)
          : {...split(enriched.declaredTags), ...inferred}.toList();
      final c = culinary[r.ingredientId];
      final measured = measuredDensity[r.ingredientId];
      ingredients[r.ingredientId] = IngredientReference(
        id: r.ingredientId,
        name: r.canonicalNameFr,
        level1: r.categoryLevel1,
        level2: r.categoryLevel2 ?? '',
        processingState: r.processingState,
        densityGPerMl: measured ?? c?.densityGPerMl,
        densityNote: measured != null ? 'mesurée Phase 4' : c?.densityNote,
        unitMasses: _parseUnitMasses(c?.unitMasses),
        ph: c?.ph,
        components: components[r.ingredientId] ?? const {},
        allergens: allergens,
        inferredAllergens: inferred,
      );
    }
    final factors = <(FoodGroup, CookingMethod), CookingFactor>{};
    for (final r in await db.select(db.processFactors).get()) {
      final g = FoodGroup.fromId(r.foodGroup);
      final m = CookingMethod.fromId(r.method);
      if (g == null || m == null) continue;
      factors[(g, m)] = CookingFactor(
        group: g,
        method: m,
        yieldFactor: r.yieldFactor,
        fatUptakeG: r.fatUptakeG ?? 0,
        fatRetention: r.fatRetention ?? 1,
        retention: _parseRetention(r.retention),
        confidence: r.confidence ?? 0.5,
        source: r.source ?? '',
      );
    }
    final rules = await db.select(db.interactionRules).get();
    return MetierReference._(
      ingredients: ingredients,
      factors: factors,
      rules: rules,
    );
  }

  static Map<String, double> _parseUnitMasses(String? raw) => _parsePairs(raw);

  static Map<String, double> _parseRetention(String? raw) => _parsePairs(raw);

  /// Format `clé:valeur|clé:valeur`.
  static Map<String, double> _parsePairs(String? raw) {
    final out = <String, double>{};
    if (raw == null || raw.isEmpty) return out;
    for (final part in raw.split('|')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final d = double.tryParse(kv[1]);
      if (d != null) out[kv[0].trim()] = d;
    }
    return out;
  }
}
