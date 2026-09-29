// Phase 11 — construction du jeu de données du moteur de composition
// (Dart pur, sans Flutter : utilisable par les outils de mesure).
//
// Mêmes sources que l'analyse d'une recette : MetierReference
// (référentiel, composants, pH, allergènes, facteurs, règles),
// NutritionRepository (profils cru et cuits mesurés), FlavorRepository
// (profils sensoriels, soutiens empiriques) ; squelettes importés
// (schéma v6).

import 'package:drift/drift.dart' show CustomExpression, OrderingTerm;

import '../../../core/database/app_database.dart';
import '../../../core/design/design_dataset.dart';
import '../../../core/design/dish_skeleton.dart';
import '../../analysis/data/metier_reference.dart';
import '../../flavor/data/flavor_repository.dart';
import '../../nutrition/data/nutrition_repository.dart';

abstract final class DesignDatasetLoader {
  static Future<DesignDataset> load(AppDatabase db) async {
    final ref = await MetierReference.of(db);
    final profiles = await NutritionRepository(db).loadAllProfiles();
    final flavor = await FlavorRepository(db).snapshot();
    final ingredients = <String, DesignIngredient>{};
    for (final r in ref.ingredients.values) {
      final nutrition = profiles[r.id];
      if (nutrition == null) continue;
      ingredients[r.id] = DesignIngredient(
        id: r.id,
        name: r.name,
        level1: r.level1,
        level2: r.level2,
        group: r.foodGroup,
        fvl: r.fvlClass,
        raw: nutrition.raw,
        cooked: nutrition.cooked,
        components: r.components,
        ph: r.ph,
        tags: r.tags,
        allergens: r.allergens,
        flavor: flavor.profiles[r.id],
      );
    }
    return DesignDataset(
      ingredients: ingredients,
      factors: ref.factors,
      rules: ref.rules,
      empirical: flavor.empirical,
      combinations: flavor.combinations,
      catalog: await loadCatalog(db),
    );
  }

  /// Squelettes importés (vide si la base n'est pas encore importée).
  static Future<DishCatalog> loadCatalog(AppDatabase db) async {
    // Ordre du fichier curaté (rowid) : il porte l'ordre des rôles.
    final byRowId = [
      OrderingTerm(expression: const CustomExpression<int>('rowid')),
    ];
    final roles = await (db.select(
      db.dishSkeletonRoles,
    )..orderBy([(_) => byRowId.first])).get();
    final processes = await (db.select(
      db.dishProcesses,
    )..orderBy([(_) => byRowId.first])).get();
    String? fmt(double? v) => v?.toString();
    return DishCatalog.fromRows(
      roleRows: [
        for (final r in roles)
          {
            'skeleton_id': r.skeletonId,
            'role': r.role,
            'role_label': r.roleLabel,
            'min_count': '${r.minCount}',
            'max_count': '${r.maxCount}',
            'min_g_per_serving': fmt(r.minGPerServing),
            'max_g_per_serving': fmt(r.maxGPerServing),
            'candidates': r.candidates,
            'note': r.note,
          },
      ],
      processRows: [
        for (final p in _ordered(processes))
          {
            'skeleton_id': p.skeletonId,
            'family_id': p.familyId,
            'family_label': p.familyLabel,
            'skeleton_label': p.skeletonLabel,
            'method': p.method,
            'serving_mass_g': fmt(p.servingMassG),
            'serving_min_g': fmt(p.servingMinG),
            'serving_max_g': fmt(p.servingMaxG),
            'duration_min': fmt(p.durationMin),
            'duration_default': fmt(p.durationDefault),
            'duration_max': fmt(p.durationMax),
            'steps': p.steps,
            'source': p.source,
          },
      ],
    );
  }

  /// Ordre d'affichage stable : ordre du fichier curaté (rowid), les
  /// procédés génériques en dernier.
  static List<DishProcess> _ordered(List<DishProcess> rows) => [
    for (final p in rows)
      if (p.familyId != DishCatalog.genericFamilyId) p,
    for (final p in rows)
      if (p.familyId == DishCatalog.genericFamilyId) p,
  ];
}
