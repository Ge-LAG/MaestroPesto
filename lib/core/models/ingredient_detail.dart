// Phase 09 Lot F — modèle pur IngredientDetail (DTO, Flutter-free).
//
// Étend IngredientSummary avec les colonnes additionnelles de la table
// `Ingredients` (Lot A schéma Drift) qui ne sont pas utiles au picker
// mais sont affichées dans IngredientDetailCard et utilisées pour
// la recherche floue (aliases).

import 'ingredient_summary.dart';

/// Détail complet d'un ingrédient Phase 1.
///
/// Les aliases FR/EN et le nom scientifique sont affichés dans
/// [`IngredientDetailCard`]. Les IDs externes (foodonId, langualIds,
/// ciqualIds, sourceRefs) sont conservés pour traçabilité / debug
/// mais **pas requêtables** côté UI (cf. dp-101 du cahier Phase 09 §14).
class IngredientDetail extends IngredientSummary {
  const IngredientDetail({
    required super.ingredientId,
    required super.canonicalNameFr,
    super.canonicalNameEn,
    required super.categoryLevel1,
    super.categoryLevel2,
    super.categoryLevel3,
    super.allergenTags,
    super.isAlcoholic,
    super.isFermented,
    super.confidence,
    this.aliasesFr = const <String>[],
    this.aliasesEn = const <String>[],
    this.scientificName,
    this.physicalForm,
    this.processingState,
    this.ingredientClass,
    this.foodonId,
    this.langualIds = const <String>[],
    this.ciqualIds = const <String>[],
    this.sourceRefs = const <String>[],
  });

  final List<String> aliasesFr;
  final List<String> aliasesEn;
  final String? scientificName;
  final String? physicalForm;
  final String? processingState;
  final String? ingredientClass;
  final String? foodonId;
  final List<String> langualIds;
  final List<String> ciqualIds;
  final List<String> sourceRefs;

  /// Tous les aliases FR + EN concaténés (utilisé par IngredientAliasIndex).
  List<String> get allAliases => <String>[...aliasesFr, ...aliasesEn];

  @override
  IngredientDetail copyWith({
    String? ingredientId,
    String? canonicalNameFr,
    String? canonicalNameEn,
    String? categoryLevel1,
    String? categoryLevel2,
    String? categoryLevel3,
    List<String>? allergenTags,
    bool? isAlcoholic,
    bool? isFermented,
    double? confidence,
    List<String>? aliasesFr,
    List<String>? aliasesEn,
    String? scientificName,
    String? physicalForm,
    String? processingState,
    String? ingredientClass,
    String? foodonId,
    List<String>? langualIds,
    List<String>? ciqualIds,
    List<String>? sourceRefs,
  }) {
    return IngredientDetail(
      ingredientId: ingredientId ?? this.ingredientId,
      canonicalNameFr: canonicalNameFr ?? this.canonicalNameFr,
      canonicalNameEn: canonicalNameEn ?? this.canonicalNameEn,
      categoryLevel1: categoryLevel1 ?? this.categoryLevel1,
      categoryLevel2: categoryLevel2 ?? this.categoryLevel2,
      categoryLevel3: categoryLevel3 ?? this.categoryLevel3,
      allergenTags: allergenTags ?? this.allergenTags,
      isAlcoholic: isAlcoholic ?? this.isAlcoholic,
      isFermented: isFermented ?? this.isFermented,
      confidence: confidence ?? this.confidence,
      aliasesFr: aliasesFr ?? this.aliasesFr,
      aliasesEn: aliasesEn ?? this.aliasesEn,
      scientificName: scientificName ?? this.scientificName,
      physicalForm: physicalForm ?? this.physicalForm,
      processingState: processingState ?? this.processingState,
      ingredientClass: ingredientClass ?? this.ingredientClass,
      foodonId: foodonId ?? this.foodonId,
      langualIds: langualIds ?? this.langualIds,
      ciqualIds: ciqualIds ?? this.ciqualIds,
      sourceRefs: sourceRefs ?? this.sourceRefs,
    );
  }

  /// Construit un IngredientSummary à partir de ce détail (pour le picker).
  IngredientSummary toSummary() => IngredientSummary(
        ingredientId: ingredientId,
        canonicalNameFr: canonicalNameFr,
        canonicalNameEn: canonicalNameEn,
        categoryLevel1: categoryLevel1,
        categoryLevel2: categoryLevel2,
        categoryLevel3: categoryLevel3,
        allergenTags: allergenTags,
        isAlcoholic: isAlcoholic,
        isFermented: isFermented,
        confidence: confidence,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! IngredientDetail) return false;
    return super == other &&
        _listEq(other.aliasesFr, aliasesFr) &&
        _listEq(other.aliasesEn, aliasesEn) &&
        other.scientificName == scientificName &&
        other.physicalForm == physicalForm &&
        other.processingState == processingState &&
        other.ingredientClass == ingredientClass &&
        other.foodonId == foodonId &&
        _listEq(other.langualIds, langualIds) &&
        _listEq(other.ciqualIds, ciqualIds) &&
        _listEq(other.sourceRefs, sourceRefs);
  }

  @override
  int get hashCode => Object.hash(
        super.hashCode,
        Object.hashAll(aliasesFr),
        Object.hashAll(aliasesEn),
        scientificName,
        physicalForm,
        processingState,
        ingredientClass,
        foodonId,
        Object.hashAll(langualIds),
        Object.hashAll(ciqualIds),
        Object.hashAll(sourceRefs),
      );

  @override
  String toString() =>
      'IngredientDetail($ingredientId, "$canonicalNameFr", sci=$scientificName)';
}
