// Phase 09 — tests du modèle pur IngredientDetail (Lot F, ac-F-005).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/ingredient_detail.dart';
import 'package:maestropesto/core/models/ingredient_summary.dart';

IngredientDetail detail({
  String id = 'ING-PLANT-TOMATE-000001',
  List<String> aliasesFr = const ['tomate fraîche'],
  List<String> aliasesEn = const [],
  String? scientificName = 'Solanum lycopersicum',
}) {
  return IngredientDetail(
    ingredientId: id,
    canonicalNameFr: 'Tomate',
    categoryLevel1: 'vegetal',
    aliasesFr: aliasesFr,
    aliasesEn: aliasesEn,
    scientificName: scientificName,
  );
}

void main() {
  test('== : deux détails identiques (listes incluses) sont égaux', () {
    expect(detail(), detail());
    expect(detail().hashCode, detail().hashCode);
  });

  test('== : une différence d\'alias rompt l\'égalité', () {
    expect(detail(), isNot(detail(aliasesFr: ['autre'])));
    expect(detail(), isNot(detail(aliasesEn: ['tomato'])));
    expect(detail(), isNot(detail(scientificName: null)));
  });

  test('== : un détail n\'est pas égal à un summary nu', () {
    expect(detail() == detail().toSummary(), isFalse);
  });

  test('copyWith ne touche que les champs fournis', () {
    final base = detail();
    final copied = base.copyWith(aliasesFr: ['a', 'b']);
    expect(copied.canonicalNameFr, base.canonicalNameFr);
    expect(copied.scientificName, base.scientificName);
    expect(copied.aliasesFr, ['a', 'b']);
    expect(copied.aliasesEn, base.aliasesEn);
    // Note : le copyWith suit le pattern `?? this.x` — remettre un champ
    // nullable à null n'est pas supporté (aucun usage courant n'en a
    // besoin ; la reconstruction passe par le mapping Drift).
  });

  test('allAliases concatène FR puis EN', () {
    final d = detail(
      aliasesFr: ['tomate fraîche', 'tomate ronde'],
      aliasesEn: ['tomato'],
    );
    expect(d.allAliases, ['tomate fraîche', 'tomate ronde', 'tomato']);
  });

  test('toSummary porte les champs du summary sans les champs détail', () {
    final summary = detail().toSummary();
    expect(summary, isA<IngredientSummary>());
    expect(summary.ingredientId, 'ING-PLANT-TOMATE-000001');
    expect(summary.canonicalNameFr, 'Tomate');
    expect(summary.categoryBreadcrumb, 'vegetal');
  });
}
