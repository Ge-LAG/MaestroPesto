// Phase 09 Lot F — modèle pur NutritionProfile (Phase 2 lookup).
//
// Toutes les valeurs sont en grammes (ou kcal pour énergie) **pour 100 g**
// d'ingrédient. La conversion à la portion est faite par
// NutritionRepository.aggregate (cf. §6.2 du cahier Phase 09).

import 'package:meta/meta.dart';

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
    this.waterContent,
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

  /// Teneur en eau (%) — nullable car pas toujours renseigné.
  final double? waterContent;

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
    Object? waterContent = _sentinel,
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
      waterContent: identical(waterContent, _sentinel)
          ? this.waterContent
          : waterContent as double?,
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
        other.waterContent == waterContent &&
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
        waterContent,
        ingredientStateId,
        confidence,
        recordCount,
      );

  @override
  String toString() =>
      'NutritionProfile(state=$ingredientStateId, energy=$energyKcal kcal, '
      'P=$proteins, G=$carbs, L=$fats, fib=$fiber, sel=$salt, n=$recordCount)';
}

const Object _sentinel = Object();
