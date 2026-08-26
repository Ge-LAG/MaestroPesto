// Phase 09 Lot F — modèle pur NutritionProfile (Phase 2 lookup).
//
// Toutes les valeurs sont en grammes (ou kcal pour énergie) **pour 100 g**
// d'ingrédient. La conversion à la portion est faite par
// NutritionRepository.aggregate (cf. §6.2 du cahier Phase 09).
//
// Retour PO n°3 (2026-08-26, exhaustivité) : les macronutriments restent
// des champs nommés ; minéraux, vitamines, alcool et constituants
// détaillés sont exposés dans [NutritionProfile.micronutrients] (clé =
// tag canonique) pour l'affichage groupé.

import 'package:meta/meta.dart';

/// Un micronutriment (minéral, vitamine ou constituant détaillé) :
/// valeur pour 100 g, avec l'unité et le libellé de la source.
@immutable
class Micronutrient {
  const Micronutrient({
    required this.tag,
    required this.name,
    required this.value,
    required this.unit,
  });

  /// Tag canonique (ex. `FE`, `VITC`, `THIAMIN`…).
  final String tag;

  /// Libellé lisible de la source (ex. « Fer (mg/100 g) »).
  final String name;

  /// Valeur pour 100 g.
  final double value;

  /// Unité (g, mg, µg…).
  final String unit;

  Micronutrient copyWith({double? value}) => Micronutrient(
    tag: tag,
    name: name,
    value: value ?? this.value,
    unit: unit,
  );

  @override
  bool operator ==(Object other) =>
      other is Micronutrient &&
      other.tag == tag &&
      other.name == name &&
      other.value == value &&
      other.unit == unit;

  @override
  int get hashCode => Object.hash(tag, name, value, unit);
}

/// Profil nutritionnel d'un ingrédient (par 100 g, état `raw` par défaut).
///
/// dp-105 : le calcul d'agrégation par portion est synchrone (les données
/// sont en RAM après import CSV). Pas de stream, pas de Future.
@immutable
class NutritionProfile {
  const NutritionProfile({
    required this.energyKcal,
    required this.proteins,
    required this.carbs,
    required this.sugars,
    required this.fats,
    required this.saturatedFats,
    required this.fiber,
    required this.salt,
    this.alcohol = 0,
    this.waterContent,
    this.micronutrients = const <String, Micronutrient>{},
    required this.ingredientStateId,
    required this.confidence,
    required this.recordCount,
  });

  /// Énergie en kcal pour 100 g.
  final double energyKcal;

  /// Protéines en grammes pour 100 g.
  final double proteins;

  /// Glucides totaux en grammes pour 100 g.
  final double carbs;

  /// Sucres (sous-ensemble des glucides) en grammes pour 100 g.
  final double sugars;

  /// Lipides totaux en grammes pour 100 g.
  final double fats;

  /// Acides gras saturés (sous-ensemble des lipides) en grammes pour 100 g.
  final double saturatedFats;

  /// Fibres alimentaires en grammes pour 100 g.
  final double fiber;

  /// Sel en grammes pour 100 g (= Na × 2.5, ANSES-Ciqual).
  final double salt;

  /// Alcool (éthanol) en grammes pour 100 g.
  final double alcohol;

  /// Teneur en eau (%) — nullable car pas toujours renseigné.
  final double? waterContent;

  /// Minéraux, vitamines et constituants détaillés (tag canonique →
  /// valeur pour 100 g avec unité et libellé source).
  final Map<String, Micronutrient> micronutrients;

  /// État de l'ingrédient (`raw`, `boiled`, etc. — réf. table
  /// `ingredient_states` Phase 1).
  final String ingredientStateId;

  /// Confiance moyenne des records agrégés (0..1).
  final double confidence;

  /// Nombre de sources qui ont contribué à ce profil.
  final int recordCount;

  /// Profil vide (zéros, état `raw`, confiance 0).
  /// Utilisé comme fallback quand aucun record n'est trouvé.
  static const NutritionProfile empty = NutritionProfile(
    energyKcal: 0,
    proteins: 0,
    carbs: 0,
    sugars: 0,
    fats: 0,
    saturatedFats: 0,
    fiber: 0,
    salt: 0,
    ingredientStateId: 'raw',
    confidence: 0,
    recordCount: 0,
  );

  NutritionProfile copyWith({
    double? energyKcal,
    double? proteins,
    double? carbs,
    double? sugars,
    double? fats,
    double? saturatedFats,
    double? fiber,
    double? salt,
    double? alcohol,
    Object? waterContent = _sentinel,
    Map<String, Micronutrient>? micronutrients,
    String? ingredientStateId,
    double? confidence,
    int? recordCount,
  }) {
    return NutritionProfile(
      energyKcal: energyKcal ?? this.energyKcal,
      proteins: proteins ?? this.proteins,
      carbs: carbs ?? this.carbs,
      sugars: sugars ?? this.sugars,
      fats: fats ?? this.fats,
      saturatedFats: saturatedFats ?? this.saturatedFats,
      fiber: fiber ?? this.fiber,
      salt: salt ?? this.salt,
      alcohol: alcohol ?? this.alcohol,
      waterContent: identical(waterContent, _sentinel)
          ? this.waterContent
          : waterContent as double?,
      micronutrients: micronutrients ?? this.micronutrients,
      ingredientStateId: ingredientStateId ?? this.ingredientStateId,
      confidence: confidence ?? this.confidence,
      recordCount: recordCount ?? this.recordCount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NutritionProfile) return false;
    return other.energyKcal == energyKcal &&
        other.proteins == proteins &&
        other.carbs == carbs &&
        other.sugars == sugars &&
        other.fats == fats &&
        other.saturatedFats == saturatedFats &&
        other.fiber == fiber &&
        other.salt == salt &&
        other.alcohol == alcohol &&
        other.waterContent == waterContent &&
        _mapEq(other.micronutrients, micronutrients) &&
        other.ingredientStateId == ingredientStateId &&
        other.confidence == confidence &&
        other.recordCount == recordCount;
  }

  @override
  int get hashCode => Object.hash(
    energyKcal,
    proteins,
    carbs,
    sugars,
    fats,
    saturatedFats,
    fiber,
    salt,
    alcohol,
    waterContent,
    Object.hashAllUnordered(
      micronutrients.values.map((m) => Object.hash(m.tag, m.value, m.unit)),
    ),
    ingredientStateId,
    confidence,
    recordCount,
  );

  @override
  String toString() =>
      'NutritionProfile(state=$ingredientStateId, energy=$energyKcal kcal, '
      'P=$proteins, G=$carbs, L=$fats, fib=$fiber, sel=$salt, '
      'micro=${micronutrients.length}, n=$recordCount)';
}

bool _mapEq(Map<String, Micronutrient> a, Map<String, Micronutrient> b) {
  if (a.length != b.length) return false;
  for (final e in a.entries) {
    if (b[e.key] != e.value) return false;
  }
  return true;
}

const Object _sentinel = Object();
