// Phase 11 Lot B — données de référence du moteur de composition.
//
// Instantané pur (aucun accès à la base, transférable vers un isolate)
// des données qu'utilise l'analyse d'une recette : composition et
// profils cuits mesurés, catégories, composants fonctionnels, pH,
// allergènes, profils sensoriels, soutiens empiriques des accords,
// facteurs de procédé, règles Phase 4 et squelettes de plats. Construit
// par `DesignRepository` (features/design) depuis les mêmes sources que
// `RecipeAnalysisService`.

import 'package:meta/meta.dart';

import '../database/app_database.dart' show InteractionRule;
import '../models/flavor_match.dart';
import '../models/flavor_profile.dart';
import '../models/nutrition_profile.dart';
import '../models/process_models.dart';
import '../scoring/flavor_pairing_engine.dart';
import '../scoring/nutrition_feedback.dart';
import 'dish_skeleton.dart';

/// Ingrédient du référentiel, tel que l'analyse le voit.
@immutable
class DesignIngredient {
  DesignIngredient({
    required this.id,
    required this.name,
    required this.level1,
    required this.level2,
    required this.group,
    required this.fvl,
    required this.raw,
    this.cooked = const <CookingMethod, NutritionProfile>{},
    this.components = const <String, double>{},
    this.ph,
    this.tags = const <String>{},
    this.allergens = const <String>[],
    this.flavor,
  }) : label = labelOf(name),
       stepName = stepNameOf(name);

  final String id;

  /// Nom canonique du référentiel.
  final String name;
  final String level1;
  final String level2;
  final FoodGroup group;
  final FvlClass fvl;

  /// Composition de l'état cru (pour 100 g) ; vide sans donnée.
  final NutritionProfile raw;

  /// Compositions cuites mesurées par mode de cuisson.
  final Map<CookingMethod, NutritionProfile> cooked;

  /// Composants fonctionnels (g pour 100 g).
  final Map<String, double> components;
  final double? ph;

  /// Étiquettes de rôle physico-chimique (egg, liquid_oil…).
  final Set<String> tags;

  /// Allergènes (étiquettes du référentiel corrigées et déduites).
  final List<String> allergens;
  final FlavorProfile? flavor;

  bool get hasNutrition => raw.recordCount > 0;

  /// Libellé de ligne de recette : nom sans « cru ».
  final String label;

  /// Nom cité dans une étape : sans précision entre parenthèses ni état
  /// de préparation (« torréfié », « cuit »… seraient lus comme une
  /// opération par l'analyse des étapes), minuscule initiale sauf sigle.
  final String stepName;

  static final RegExp _raw = RegExp(r' (cru|crue|crus|crues)$');
  static final RegExp _state = RegExp(
    r'\s*\([^)]*\)|\s+(torréfiée?s?|grillée?s?|rôtie?s?|cuite?s?|frite?s?|'
    r'fumée?s?|séchée?s?|sèche?s?|sec)(?=\s|$)',
  );

  static String labelOf(String name) => name.replaceFirst(_raw, '');

  static String stepNameOf(String name) {
    final l = labelOf(name).replaceAll(_state, '').trim();
    if (l.length > 1 &&
        l[1] == l[1].toUpperCase() &&
        l[1] != l[1].toLowerCase()) {
      return l;
    }
    return l.isEmpty ? l : l[0].toLowerCase() + l.substring(1);
  }
}

/// Jeu de données complet.
@immutable
class DesignDataset {
  const DesignDataset({
    required this.ingredients,
    required this.factors,
    required this.rules,
    required this.empirical,
    required this.combinations,
    required this.catalog,
  });

  final Map<String, DesignIngredient> ingredients;
  final Map<(FoodGroup, CookingMethod), CookingFactor> factors;
  final List<InteractionRule> rules;

  /// Soutien empirique des paires (clé : identifiants triés, `|`).
  final Map<String, EmpiricalPairing> empirical;

  /// Combinaisons n-aires observées (clé : identifiants triés, `|`).
  final Map<String, FlavorMatch> combinations;
  final DishCatalog catalog;

  DesignIngredient? operator [](String id) => ingredients[id];

  /// Même règle que `MetierReference.factorFor` : repli sur le groupe
  /// générique ; une matière grasse n'a de facteur qu'en friture.
  CookingFactor? factorFor(FoodGroup group, CookingMethod method) {
    final exact = factors[(group, method)];
    if (exact != null) return exact;
    if (group == FoodGroup.fat) return null;
    return factors[(FoodGroup.other, method)];
  }

  static String pairKey(String a, String b) =>
      a.compareTo(b) <= 0 ? '$a|$b' : '$b|$a';

  static String setKey(Iterable<String> ids) =>
      (ids.toList()..sort()).join('|');
}
