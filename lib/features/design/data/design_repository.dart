// Phase 11 — accès aux données de la conception par objectifs.
//
// Construit l'instantané pur `DesignDataset` depuis les mêmes sources
// que l'analyse d'une recette (MetierReference, NutritionRepository,
// FlavorRepository) et les squelettes importés (schéma v6), puis lance
// le moteur hors du fil de l'interface (isolate ; en ligne sur le web).

import 'package:flutter/foundation.dart';

import '../../../core/database/app_database.dart';
import '../../../core/design/design_brief.dart';
import '../../../core/design/design_dataset.dart';
import '../../../core/design/design_engine.dart';
import '../../../core/design/dish_skeleton.dart';
import 'design_dataset_loader.dart';

class DesignRepository {
  DesignRepository(this.db);

  final AppDatabase db;

  static final Expando<Future<DesignDataset>> _cache = Expando();

  /// Jeu de données de [db] (chargé à la première demande, ≈ 1 s).
  Future<DesignDataset> dataset() =>
      _cache[db] ??= DesignDatasetLoader.load(db);

  /// À appeler après un import des bases métier.
  static void invalidate(AppDatabase db) => _cache[db] = null;

  /// Catalogue des squelettes (types de plat).
  Future<DishCatalog> catalog() async => (await dataset()).catalog;

  /// Compose les variantes d'une demande, hors du fil de l'interface.
  Future<DesignResult> design(
    DesignBrief brief, {
    DesignBudget budget = const DesignBudget(),
  }) async {
    final data = await dataset();
    final request = DesignRequest(data, brief, budget: budget);
    if (kIsWeb) return runDesignRequest(request);
    return compute(runDesignRequest, request);
  }
}
