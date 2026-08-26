# Phase 09 — UX pilotée par les BDD métier (plan d'implémentation)

> Plan détaillé pour transformer MaestroPesto d'un « classeur de recettes
> local-first » en un **atelier de formulation culinaire** où les 4 bases
> métier (phase 1 référentiel, phase 2 nutrition, phase 3 flavour,
> phase 4 functional) sont **visibles, requêtables et prescriptives**
> dans l'UI.
> Format §71 (cf. phase-08-db-connection-strategies.md) — adapté à un
> plan de produit (et non un cahier de phase technique). Implémentation
> prévue : **multi-lots** sur la branche `Ge-LAG/phase-09-metier-ux`
> (à créer après push de la branche actuelle par Gui).
> Date : 2026-08-25. Statut : **Lots F+G+H implémentés + AUDITÉS**
> (2026-08-26, 28 commits Kimi + session audit GLM 5.3 / ZCode :
> corrections compilation/métier, câblage picker + detail card +
> warning live, suite 219/219 verte, analyze 0 issue, build Windows OK).
> Lot I (optionnel) non implémenté.
> Note de traçabilité (R-08) : les amendements de lots sont consignés
> en §14 (dp-108 à dp-116) et §15 (ac-107 à ac-113) — voir aussi
> `PROJET.json` (backlog_audit_code ac-G-*/ac-H-*).

## 1. Résumé exécutif

L'objectif métier est formulé par Gui le 2026-08-25 après constat que
les BDD métier se chargent dans l'app (Lot E, via le bouton « Importer
BDD métier ») mais **n'ont encore aucun impact sur l'UI**. Le plan
doit couvrir les **4 axes métier** :

1. **Phase 1 — référentiel ingrédients** : exposer la liste maître des
   603 ingrédients canoniques pour que l'utilisateur les choisisse en
   composant une recette.
2. **Phase 2 — nutrition** : afficher les caractéristiques nutritionnelles
   de chaque ingrédient (énergie, protéines, glucides, lipides, fibres,
   sel) et calculer la nutrition **par portion** d'une recette
   complète en agrégeant les contributions de chaque ingrédient.
3. **Phase 3 — flavour** : afficher les associations aromatiques
   (compatibilités entre ingrédients, scores 0–1), pour aider l'utilisateur
   à composer des combinaisons harmonieuses et détecter les
   incompatibilités.
4. **Phase 4 — functional** : afficher les propriétés physico-chimiques
   (texture, gélification, émulsification, comportement thermique) et
   les **règles d'interaction** physico-chimiques pertinentes pour la
   recette en cours d'édition.

En complément, le plan intègre un **module de recommandation** : si
l'utilisateur compose une recette contenant des ingrédients
incompatibles (faible score flavour, règle fonctionnelle en conflit,
profil nutritionnel déséquilibré), l'UI lui propose des **substituts
issus de la même catégorie phase 1** avec une meilleure affinité.

Le plan est structuré en **3 phases d'implémentation successives**
(§10.1–10.3) pour livrer de la valeur incrémentale à chaque étape.

## 2. Dépendances

| Package | Statut actuel | Décision | Justification |
|---|---|---|---|
| `drift` 2.34.3 | ✅ déjà dans pubspec | garder | schéma DB déjà construit (Lots A+D) |
| `drift_flutter` 0.3.1 | ✅ déjà dans pubspec | garder | intégration Flutter |
| `flutter_riverpod` ^2.5 | ❌ à ajouter | **ajouter** | state management pour les filtres/sorties, idempotent aux rebuilds, évite le prop-drilling dans un arbre UI qui va beaucoup s'étoffer |
| `cached_network_image` ^3.4 | ❌ à ajouter | **ajouter** | photos d'ingrédients (Phase 1 n'a pas d'images mais on anticipe des encyclopédies culinaires type Open Food Facts) |
| `flutter_svg` ^2.0 | ❌ à ajouter | **ajouter** | icônes d'alertes (warning/error/info) cohérentes avec le design system Alex |
| `collection` ^1.18 | ❌ à ajouter | **ajouter** | algorithmes de scoring (intersection de sets, groupBy) sur les 4594 paires flavour |
| `meta` ^1.15 | ❌ à ajouter | **ajouter** | annotations `@immutable` pour le state Riverpod |

**Refus explicites** :
- ❌ **Pas de nouveau format de BDD** : on reste sur SQLite + Drift, pas
  d'ORM alternatif, pas de NoSQL.
- ❌ **Pas de service externe** : tout est calculé localement, pas
  d'appel réseau pour les données métier (R-07 / B.2-6).
- ❌ **Pas de LLM** : la recommandation est algorithmique (Jaccard,
  contraintes), pas générative.
- ❌ **Pas de refonte du design system Alex** : on s'appuie sur
  `app_theme.dart` et `app_strings.dart` existants ; les nouveaux
  widgets respectent l'esprit Material 3 minimaliste déjà en place.

## 3. Allowed files / Forbidden scope (rappel)

**Allowed** (à enrichir au fil des lots) :
- `lib/features/ingredients/` (nouvelles pages, repository étendu)
- `lib/features/nutrition/` (nouveau dossier, voir §6)
- `lib/features/flavor/` (nouveau dossier, voir §7)
- `lib/features/functional/` (nouveau dossier, voir §8)
- `lib/features/recommendations/` (nouveau dossier, voir §9)
- `lib/features/recipes/presentation/widgets/` (widgets prescription)
- `lib/app/i18n/app_strings.dart` (nouvelles clés)
- `test/...` (tests unitaires + widget tests)
- `assets/` (éventuellement : photos d'ingrédients, icônes SVG)

**Forbidden** :
- `database/schema.sql` (intouchable)
- `database-metier/`, `ciqual/`
- `lib/features/recipes/data/demo_recipes.dart` (utilisé en seed, à
  garder mais pas modifier)
- `lib/features/recipes/data/recipes_repository.dart` (Lot D/E) : peut
  être étendu mais pas réécrit
- `lib/features/recipes/presentation/recipes_home_page.dart` (UI Alex,
  intact ; on ajoute des sous-pages via `Navigator.push`)
- `lib/app/theme/`, `lib/main.dart`, `lib/app/maestro_pesto_app.dart`
  (sauf ajout d'un `ProviderScope` et d'une route)
- `PROJET*`, `METHOD*`, `INDEX*` (capitalisation séparée)
- `windows/`, `linux/`, `macos/`, `web/`, `ios/`, `android/`

## 4. Architecture cible (post plan complet)

```text
lib/
  core/
    database/
      app_database.dart              # existant, étendu (v4 → v5)
      tables/
        ...                          # existants
        ingredient_aliases.dart       # NOUVEAU §6.1 (recherche floue)
    scoring/                          # NOUVEAU DOSSIER
      flavor_scorer.dart             # §7.1 (calcul score 0–1)
      functional_constraint_solver.dart # §8.1 (règles physico-chimiques)
      nutrition_aggregator.dart       # §6.2 (nutrition par portion)
      recommender.dart               # §9 (substituts)
    models/                           # NOUVEAU DOSSIER (types métier purs)
      ingredient_summary.dart
      ingredient_detail.dart
      nutrition_profile.dart
      flavor_match.dart
      functional_alert.dart
      recommendation.dart
  features/
    ingredients/
      data/
        ingredients_repository.dart   # existant Lot D, étendu §6
        ingredient_alias_index.dart   # NOUVEAU §6.1
      presentation/
        ingredients_picker_page.dart # NOUVEAU §6.3
        ingredient_detail_card.dart  # NOUVEAU §6.4
    nutrition/
      data/
        nutrition_repository.dart   # NOUVEAU §6.2
      presentation/
        widgets/
          nutrition_chart.dart       # NOUVEAU §6.4 (barres empilées)
    flavor/
      data/
        flavor_repository.dart       # NOUVEAU §7.2
      presentation/
        widgets/
          flavor_compatibility_heatmap.dart # NOUVEAU §7.3
    functional/
      data/
        functional_repository.dart   # NOUVEAU §8.2
      presentation/
        widgets/
          functional_alert_card.dart # NOUVEAU §8.3
    recommendations/
      data/
        recommender.dart             # NOUVEAU §9.1 (orchestrateur)
      presentation/
        widgets/
          recommendation_sheet.dart  # NOUVEAU §9.2 (bottom sheet)
    recipes/
      presentation/
        recipes_home_page.dart        # existant Alex, intact
        recipe_detail_view.dart       # existant, étendu §10.2
        recipe_form_dialog.dart       # existant, étendu §10.2
        widgets/
          recipe_metier_advisory_panel.dart # existant Lot D, étendu §10.2
          recipe_nutrition_panel.dart       # existant, étendu §6.4
  app/
    i18n/app_strings.dart             # ~30 nouvelles clés
    maestro_pesto_app.dart             # + 1 route Navigator
    routing.dart                       # NOUVEAU (routes nommées)
```

## 5. Modèles métier purs (NOUVEAU `lib/core/models/`)

Tous ces modèles sont **immuables**, **Flutter-free** (pas d'import
`package:flutter/*`), testables en Dart pur. La convention est
`final` partout, `const` constructor quand possible, `copyWith`
quand mutation.

### 5.1 `IngredientSummary`
```dart
class IngredientSummary {
  const IngredientSummary({
    required this.ingredientId,    // ING-...
    required this.canonicalNameFr, // ex: "Tomate"
    required this.canonicalNameEn, // nullable
    required this.categoryLevel1,  // ex: "vegetal"
    required this.categoryLevel2,
    required this.categoryLevel3,
    required this.allergenTags,    // List<String> (pipe split)
    required this.isAlcoholic,     // bool
    required this.isFermented,
    required this.confidence,      // double [0,1]
  });
  // ... fields + copyWith + == + hashCode
}
```

### 5.2 `IngredientDetail` (extends `IngredientSummary`)
```dart
class IngredientDetail extends IngredientSummary {
  const IngredientDetail({
    super.ingredientId, ...,
    required this.aliasesFr,         // List<String>
    required this.aliasesEn,
    required this.scientificName,    // nullable
    required this.physicalForm,      // nullable
    required this.processingState,   // nullable
    required this.ingredientClass,   // nullable
    required this.foodonId,
    required this.langualIds,        // List<String>
    required this.ciqualIds,         // List<String> (mapping externe)
    required this.sourceRefs,        // List<String>
  });
}
```

### 5.3 `NutritionProfile` (Phase 2)
```dart
class NutritionProfile {
  const NutritionProfile({
    required this.energyKcal,        // double (per 100g)
    required this.proteins,          // double
    required this.carbs,            // double
    required this.sugars,           // double
    required this.fats,             // double
    required this.saturatedFats,
    required this.fiber,
    required this.salt,              // Na * 2.5
    required this.waterContent,      // nullable
    required this.ingredientStateId, // 'raw', 'boiled', ...
    required this.confidence,        // mean(confidence des records)
    required this.recordCount,       // int (combien de sources ont contribué)
  });
  static const empty = NutritionProfile(...); // tous à 0
}
```

### 5.4 `FlavorMatch` (Phase 3)
```dart
class FlavorMatch {
  const FlavorMatch({
    required this.ingredientAId,
    required this.ingredientBId,    // ou null si combinaison n-aire
    required this.combinationSize,   // 2, 3, 4...
    required this.overallScore,      // double [0,1] (cf. flavor_scoring_method.md)
    required this.aromaSimilarity,
    required this.tasteBalance,
    required this.dominanceRisk,
    required this.maskingRisk,
    required this.culinarySupport,
    required this.evidenceRefs,      // List<String>
    required this.explanation,       // String (résumé lisible)
  });

  /// 4 catégories basées sur overall_score (cf. cahier phase 3) :
  /// ≥0.85 excellent, 0.70-0.84 bon, 0.55-0.69 moyen, 0.40-0.54 discutable,
  /// <0.40 éviter.
  FlavorMatchCategory get category => ...;
}

enum FlavorMatchCategory { excellent, good, average, questionable, avoid }
```

### 5.5 `FunctionalAlert` (Phase 4)
```dart
class FunctionalAlert {
  const FunctionalAlert({
    required this.alertId,           // RULE-PEC-HM-001
    required this.severity,          // FunctionalSeverity
    required this.title,             // ex: "Pectine HM gélifie uniquement si..."
    required this.conditions,        // List<String> (ex: ["pH < 4.0", "sucre > 60%"])
    required this.predictedEffect,   // ex: "augmente fermité du gel"
    required this.confidence,        // double [0,1]
    required this.evidenceType,      // "expert_rule_with_literature"
  });
}

enum FunctionalSeverity { info, warning, danger, outOfDomain }
```

### 5.6 `Recommendation` (§9)
```dart
class Recommendation {
  const Recommendation({
    required this.originalIngredientId,  // ingrédient problématique
    required this.suggestedIngredient,    // IngredientSummary
    required this.reason,                  // ex: "Meilleure affinité aromatique"
    required this.score,                   // double [0,1]
    required this.scoringSource,           // "flavor" | "nutrition" | "functional" | "all"
  });
}
```

## 6. Phase 1 — Référentiel ingrédients exposé dans l'UI

### 6.1 Recherche floue (`IngredientAliasIndex`)
Le Picker doit permettre de chercher **"tom"** et de trouver **"Tomate"**.
Le CSV Phase 1 expose `canonical_name_fr`, `canonical_name_en`,
`aliases_fr`, `aliases_en` (séparés par `|`). On construit un index
**en mémoire** au moment de l'import CSV (hook dans le
`CsvImportService.importAll()` — voir §11).

```dart
// lib/features/ingredients/data/ingredient_alias_index.dart
class IngredientAliasIndex {
  IngredientAliasIndex._(this._byId, this._terms);
  final Map<String, IngredientDetail> _byId;
  final Map<String, Set<String>> _terms; // token -> set of ingredientIds

  static IngredientAliasIndex build(List<IngredientDetail> all) { ... }

  /// Recherche tolérante : insensible à la casse, aux accents
  /// (Normalisation NFD + strip diacritics), tolère les fautes de frappe
  /// (Levenshtein ≤ 2 sur tokens > 4 chars).
  List<IngredientSummary> search(String query, {int limit = 20});
}
```

### 6.2 `NutritionRepository` (Phase 2 lookup)
```dart
// lib/features/nutrition/data/nutrition_repository.dart
class NutritionRepository {
  Future<NutritionProfile?> forIngredient(
    String ingredientId, {
    String stateId = 'raw',  // défaut
  });

  /// Agrège les contributions de chaque ingrédient pondérées par
  /// leur quantity_g pour produire la nutrition d'une recette.
  /// Renvoie `empty` si la recette n'a aucun ingrédient avec
  /// `ingredientId` (fallback gracieux).
  NutritionProfile aggregate({
    required List<RecipeIngredient> ingredients,
    required int servings,
  });
}
```

**Algorithme d'agrégation** (à documenter en docstring) :
```
pour chaque ingrédient i de la recette:
  profile_i = nutrition_repository.forIngredient(i.ingredientId, stateId)
  si profile_i est null: skip (warning log)
  contribution_i = (i.quantity_g * profile_i) / 100.0  // per 100g → per qty
nutrition_totale = somme des contribution_i
nutrition_par_portion = nutrition_totale / recipe.servings
```

**Edge cases** :
- Ingrédient `kind: 'free'` sans `ingredientId` : warning, skip.
- Ingrédient `kind: 'recipe'` (sous-recette) : **Phase future** —
  pour l'instant, ignorer (ne pas faire de récursion).
- `stateId` par défaut 'raw' (cru). Si l'utilisateur spécifie 'boiled'
  dans le futur, on changera l'argument.

### 6.3 Page Picker (`IngredientsPickerPage`)
**Accès** : tap sur un slot ingrédient dans `recipe_form_dialog.dart`
ouvre un bottom sheet OU un `Navigator.push` vers cette page.

**Layout** (responsive, comme la UI Alex) :
- AppBar avec `SearchBar` Material 3 (insensible à la casse).
- Sous la search : chips horizontales de filtres (catégorie Phase 1
  : `végétal`, `animal`, `fungi`, `algue`, `ingredient technique`,
  `boisson`, `condiment`, `ferment`, `préparation`).
- Liste virtualisée des résultats : pour chaque hit, un
  `IngredientSummary` row avec :
  - Nom canonique FR (et EN si dispo, en subtitle).
  - Badge catégorie (couleur dépend de `category_level_1`).
  - Badge allergène(s) si présent(s) (icône warning + tooltip).
  - Badge alcoolisé / fermenté.
- Tap sur un row → ferme picker + callback avec `ingredientId`.

**Recherche vide** : affiche les 30 ingrédients les plus utilisés
(pas de ranking pour l'instant — juste `LIMIT 30 ORDER BY
canonical_name_fr`).

### 6.4 Card de détail (`IngredientDetailCard`)
Affichée dans le `recipe_detail_view.dart` quand un ingrédient de
recette a un `ingredientId` lié. Affiche :
- Nom canonique + nom scientifique (italique).
- Catégorie (breadcrumb `category_level_1 > level_2 > level_3`).
- Allergènes (chips rouges).
- **Mini nutrition** (top 4 : énergie, protéines, lipides, glucides).
- **Mini flavor** : un badge "compatibilité moyenne" calculé
  dynamiquement vs les autres ingrédients de la recette.
- **Mini functional** : si une règle Phase 4 matche, badge d'alerte.

### 6.5 Migration DB
Si on doit ajouter des index (ex: index trigram sur `canonical_name_fr`),
bump `schemaVersion` à 4 + migration. **Sinon, pas de migration
nécessaire** (le schema Lot D suffit).

## 7. Phase 3 — Associations aromatiques

### 7.1 `FlavorScorer` (logique pure, testable)
```dart
// lib/core/scoring/flavor_scorer.dart
class FlavorScorer {
  /// Calcule le score global d'une combinaison de N ingrédients
  /// en agrégeant les FlavorMatch trouvés en DB. Implémente la formule
  /// pondérée de `flavor_scoring_method.md` :
  ///
  /// score(C) = w1*pair_quality + w2*sensory_balance + ...
  ///           - w6*dominance - w7*masking - w8*uncertainty
  ///
  /// Pondérations par défaut (cf. cahier phase 3) :
  /// w1=0.25, w2=0.15, w3=0.10, w4=0.20, w5=0.10,
  /// w6=0.08, w7=0.07, w8=0.05
  ///
  /// Renvoie un [FlavorMatch] synthétique si la combinaison a des
  /// enregistrements partiels en DB. Renvoie null si rien à scorer
  /// (combinaison trop exotique).
  static FlavorMatch? scoreCombination(
    List<String> ingredientIds,
    FlavorLookup lookup,  // callback pour récupérer les FlavorMatch bruts
  );
}
```

### 7.2 `FlavorRepository`
```dart
// lib/features/flavor/data/flavor_repository.dart
class FlavorRepository {
  /// Renvoie le meilleur FlavorMatch pour une combinaison ordonnée
  /// (peu importe l'ordre) d'ingrédients. Renvoie null si la
  /// combinaison n'est pas dans le CSV flavor_compatibility.
  Future<FlavorMatch?> bestMatchFor(List<String> ingredientIds);

  /// Renvoie les paires d'ingrédients incompatibles (score < 0.40)
  /// parmi une liste donnée. Utilisé par le recommander (§9).
  Future<List<FlavorMatch>> incompatiblePairs(List<String> ingredientIds);
}
```

### 7.3 Heatmap (`FlavorCompatibilityHeatmap`)
Widget affiché dans `recipe_detail_view.dart` sous les ingrédients.
Affiche une matrice N×N des ingrédients de la recette avec
chaque cellule colorée selon la catégorie (vert = excellent, jaune =
moyen, orange = discutable, rouge = éviter). Tap sur une cellule
→ bottom sheet avec `explanation` + détails.

**Layout** : grille symétrique avec nom de l'ingrédient en row header
et en column header. Pour 3-5 ingrédients, ça reste lisible (3×3 à 5×5).
Au-delà de 5, on garde les 5 plus "importants" (ranking simple :
fréquence dans la recette).

## 8. Phase 4 — Propriétés physico-chimiques

### 8.1 `FunctionalConstraintSolver`
```dart
// lib/core/scoring/functional_constraint_solver.dart
class FunctionalConstraintSolver {
  /// Évalue les règles Phase 4 contre l'état courant de la recette.
  /// Renvoie les alertes applicables triées par sévérité décroissante.
  ///
  /// Critères d'application d'une règle (cf. functional_rule_engine_spec.md) :
  /// 1. Composants fonctionnels présents dans la recette (via
  ///    functional_ingredients + functional_components).
  /// 2. ingredient_constraints satisfaites (TODO Phase future :
  ///    parser les expressions, ex: "pectine_HM_presence").
  /// 3. composition_constraints : non implémenté en v1 (skip avec
  ///    warning, ces contraintes sont trop complexes à parser en
  ///    l'état actuel).
  /// 4. process_constraints : non implémenté en v1 (la recette n'a
  ///    pas de process_sequence en DB).
  /// 5. ph_min/max, temperature_min/max, time_min/max, aw_min/max :
  ///    non applicables sans données de process → skip.
  ///
  /// v1 simplifiée : une règle s'applique si l'un de ses
  /// `reactant_or_component_ids` (pipe-separated) matche un
  /// `ingredientId` présent dans la recette. Le confidence est
  /// ramené à 50% (OUT_OF_DOMAIN implicite).
  static List<FunctionalAlert> evaluate({
    required List<String> recipeIngredientIds,
    required List<InteractionRule> allRules,
  });
}
```

### 8.2 `FunctionalRepository`
```dart
// lib/features/functional/data/functional_repository.dart
class FunctionalRepository {
  Future<List<FunctionalAlert>> alertsFor(List<String> ingredientIds);

  Future<FunctionalIngredient?> profileFor(
    String ingredientId, {
    required String stateId,
  });
}
```

### 8.3 Card d'alerte (`FunctionalAlertCard`)
Affichée dans `recipe_detail_view.dart` (au-dessus de la
`RecipeNutritionPanel`). Liste verticale des `FunctionalAlert`
avec icône + couleur par sévérité, et expansion au tap pour voir
les conditions + l'effet prédit. **Pas dismissable** (les alertes
sont des informations, pas des erreurs).

## 9. Recommandations (substituts intelligents)

### 9.1 `Recommender` (orchestrateur)
```dart
// lib/features/recommendations/data/recommender.dart
class Recommender {
  Recommender({
    required IngredientsRepository ingredients,
    required FlavorRepository flavor,
    required FunctionalRepository functional,
  });

  /// Pour un ingrédient `target` dans une recette `current`, propose
  /// des substituts de la même `category_level_1` qui :
  /// 1. n'introduisent pas de nouvelle incompatibilité flavour
  ///    (test des paires restantes),
  /// 2. ne déclenchent pas de nouvelle alerte fonctionnelle,
  /// 3. ont une confiance Phase 1 ≥ 0.7.
  /// Renvoie max 5 recommandations triées par score décroissant.
  Future<List<Recommendation>> suggestSubstitutes({
    required String targetIngredientId,
    required List<String> currentIngredientIds,
    int maxResults = 5,
  });
}
```

**Algorithme** :
```
1. Récupérer l'ingrédient cible : sa `category_level_1`.
2. Récupérer les incompatibilités actuelles (flavor) et alertes
   fonctionnelles de la recette SANS la cible.
3. Lister les candidats : tous les Ingredients avec même
   `category_level_1` ET `confidence >= 0.7` ET non déjà dans la
   recette. Exclure les items avec `allergen_tags` non vides si
   l'utilisateur a un filtre "no-allergen" (Phase future).
4. Pour chaque candidat, calculer un score :
   - bonus si le candidat résout une incompatibilité existante
     (jaccard_similarity avec les ingrédients restants > 0.6 ET
     flavor score avec l'ingrédient le plus proche > 0.7)
   - bonus si le candidat a un meilleur profil flavour moyen
   - malus si le candidat déclenche une nouvelle incompatibilité
5. Trier par score décroissant, retourner top N.
```

### 9.2 Bottom sheet (`RecommendationSheet`)
Affiché quand le `RecipeMetierAdvisoryPanel` détecte une mauvaise
combinaison (≥1 paire `FlavorMatch` < 0.40 OU ≥1 alerte Phase 4
danger). Titre : "Mauvaise combinaison détectée". Contenu :
- Explication courte (ex: "Le bœuf et le fromage à pâte persillée
  s'opposent aromatique (score 0.32)").
- Tap sur un ingrédient "à problème" → ouvre le sheet de substituts
  pour cet ingrédient.
- Bouton "Ignorer" (dismissable, persiste en sessionStorage pour
  ne pas redéranger).

## 10. Phasage d'implémentation

### 10.1 Lot F (≈3-4 jours) — Fondations & Phase 1 référentiel
- **F1** : Modèles `IngredientSummary`, `IngredientDetail`,
  `NutritionProfile` (§5.1, §5.2, §5.3) + tests unitaires.
- **F2** : `IngredientAliasIndex` (§6.1) + tests (recherche floue).
- **F3** : `NutritionRepository.forIngredient` (§6.2 lookup seul,
  pas l'aggregation) + tests sur les 6 154 lignes importées.
- **F4** : `IngredientsPickerPage` (§6.3) + intégration au
  `recipe_form_dialog.dart` (tap sur un slot ingrédient ouvre le
  picker, sélection met à jour `ingredientId`).
- **F5** : `IngredientDetailCard` (§6.4) + intégration au
  `recipe_detail_view.dart` (un card par ingrédient qui a un
  `ingredientId` lié).
- **Livrable** : l'utilisateur peut composer une recette en
  sélectionnant des ingrédients depuis la base Phase 1.

### 10.2 Lot G (≈3-4 jours) — Phase 2 nutrition + Phase 3 flavour
- **G1** : `NutritionRepository.aggregate` (§6.2) + tests.
  Remplace la `NutritionSummary` hardcodée de `demo_recipes.dart`
  par un calcul automatique quand les `ingredientId` sont liés.
- **G2** : Amélioration du `RecipeNutritionPanel` (existant Alex)
  : afficher **"calculé depuis N ingrédients sur M"** quand la
  recette est liée à la DB, vs "valeur saisie manuellement".
- **G3** : `FlavorRepository` (§7.2) + `FlavorScorer` (§7.1) + tests.
- **G4** : `FlavorCompatibilityHeatmap` (§7.3) + intégration au
  `recipe_detail_view.dart`.
- **G5** : `RecipeMetierAdvisoryPanel` (existant Lot D) étendu
  pour intégrer le `FlavorCompatibilityHeatmap` quand la recette
  a ≥2 ingrédients liés à la DB.
- **Livrable** : la nutrition d'une recette est calculée depuis
  les ingrédients, et les associations aromatiques sont visibles.

### 10.3 Lot H (≈2-3 jours) — Phase 4 functional + Recommandations
- **H1** : `FunctionalConstraintSolver` (§8.1) + tests (sur les
  16 règles Phase 4, vérifier qu'au moins 3 sont déclenchées par
  les démos `demo_recipes.dart` quand les `ingredientId` sont liés).
- **H2** : `FunctionalRepository` (§7.2) + `FunctionalAlertCard`
  (§7.3) + intégration au `recipe_detail_view.dart`.
- **H3** : `Recommender` (§9.1) + `RecommendationSheet` (§9.2)
  + intégration au `RecipeMetierAdvisoryPanel` (déclenche le sheet
  quand incompatibilité détectée).
- **H4** : UX Polish : `RecipeFormDialog` émet un warning live
  pendant la frappe si l'utilisateur ajoute un ingrédient qui
  déclencherait une mauvaise combinaison (sans interrompre la saisie).
- **Livrable** : l'UI propose activement des substituts et affiche
  des alertes physico-chimiques.

### 10.4 Lot I (optionnel, ≈1-2 jours) — Mode batch
- **I1** : Commande batch pour appliquer un CSV de recettes
  externes : chaque ligne est résolue via `IngredientsRepository`
  (recherche par nom FR), `FlavorRepository` (validation), et la
  recette est sauvée si tous les ingrédients sont liés, sinon
  un rapport CSV est produit avec les ingrédients non résolus.
- **I2** : Documentation utilisateur (README mis à jour avec
  capture d'écran de la prescription).

## 11. Synchronisation des BDD en mémoire vs disque

### 11.1 Bump `schemaVersion` (v3 → v4) ?
**Décision** : NON, sauf si on a besoin de nouvelles colonnes. Le
schema Lot D suffit pour stocker les `IngredientDetail` (déjà
couvert par `ingredients` + tables annexes). On évite un bump de
migration pour ne pas toucher à `app_database.dart` (Lot A+D).

### 11.2 Index mémoire (in-process)
- `IngredientAliasIndex` est construit une seule fois au boot de
  l'app (après `AppServices.open()`), en lisant toutes les
  IngredientDetail depuis la DB. Cache en mémoire, pas de
  rechargement.
- `FlavorRepository` charge **les 4 594 paires de `flavor_compatibility.csv`**
  en mémoire au boot (tient largement en RAM : ~200 Ko). Cache.
- `FunctionalRepository` charge les **16 règles + 18 profils ingrédients**
  en mémoire au boot (~5 Ko). Cache.
- `Recommender` n'a **pas** de cache : chaque appel est un calcul
  (1 query DB pour récupérer les candidats + scoring pur en RAM).

### 11.3 Invalidation des caches
- Quand `CsvImportService.importAll()` tourne (Lot E, bouton
  "Importer BDD métier"), il **invalide tous les caches**
  (`aliasIndex = null`, `flavorCache = null`, etc.) et les
  reconstruit au prochain accès. Coût : ~50 ms max pour 6 154
  lignes + 4 594 paires.

## 12. Tests et vérifications (tous lots)

### 12.1 Tests unitaires (Dart pur, `dart test`)
- Tous les modèles (§5) : `==` + `hashCode` + `copyWith` + JSON round-trip
  éventuel (si on sérialise pour debug).
- `IngredientAliasIndex` : recherche exacte, partielle, fuzzy,
  accents, casse. Au moins 20 cas par méthode publique.
- `NutritionRepository.aggregate` : cas vide, cas 1 ingredient,
  cas 5 ingredients, cas ingrédient sans profile, cas
  quantités variables. Au moins 10 cas + fixtures de référence
  validées à la main.
- `FlavorScorer.scoreCombination` : 5 combinaisons pré-calculées
  (cf. cahier phase 3) avec valeurs de référence.
- `FunctionalConstraintSolver.evaluate` : 16 règles × 4 cas
  (match/no-match × with/without process data) = 64 cas minimum.
- `Recommender.suggestSubstitutes` : 5 scénarios (recette
  équilibrée, recette problématique, recette mono-ingrédient,
  recette sans candidat, recette allergène).

### 12.2 Tests widget (Flutter, `flutter test`)
- `IngredientsPickerPage` : search, filter chips, tap row.
- `FlavorCompatibilityHeatmap` : rendu matrice 2×2, 3×3, 5×5.
- `FunctionalAlertCard` : expansion.
- `RecommendationSheet` : tap substitut → callback.
- `RecipeMetierAdvisoryPanel` (étendu) : rendu avec/sans DB.

### 12.3 Tests d'intégration (Flutter, `flutter test integration_test/`)
- Scénario "User édite une recette et voit la nutrition se mettre
  à jour live" (Lot G).
- Scénario "User compose une recette avec 2 ingrédients
  incompatibles, reçoit une recommendation" (Lot H).

### 12.4 Vérification sandbox
- `dart analyze lib/ test/` : 0 issue — **VÉRIFIÉ le 2026-08-26**
  (session audit : `flutter analyze` 0 issue, warnings préexistants
  `app_theme.dart`/`recipe_form_dialog.dart` du Lot E corrigés au
  passage).
- `dart test test/` : 100% verts — **VÉRIFIÉ : 219/219** (audit
  2026-08-26 sur SDK Windows Flutter 3.47.1 / Dart 3.13.1), dont
  smoke tests DoD sur données réelles (`metier_smoke_test.dart`).
- `dart format --set-exit-if-changed lib/ test/` : exit 0 — **VÉRIFIÉ**.
- `flutter build windows` : **OK** (maestropesto.exe généré, audit
  2026-08-26).

## 13. Definition of Done (par lot)

### 13.1 DoD commun
- Code commité en **commits atomiques** au format `theme: resume
  2-3 mots` (BP-22).
- 1 commit par concern (ex: `feat: ingredient alias index`,
  `feat: flavor repository`, `ui: compatibility heatmap`).
- `dart analyze` 0 issue sur le périmètre livré.
- Tests verts (unitaires + widget).
- `dart format` propre.
- Aucune dépendance exotique sans justification.
- Aucun secret, token, ou donnée utilisateur réelle commité.
- Aucun push (R-01 strict).
- Forbidden scope respecté.
- Mise à jour du cahier `tasks/phase-09-metier-driven-ux.md`
  (celui-ci) au fur et à mesure (section "Décisions" + "Dette").
- `PROJET.json` + `PROJET.md` synchronisés (BP-17).

### 13.2 DoD spécifique Lot F
- L'utilisateur peut sélectionner un ingrédient Phase 1 dans le
  formulaire de recette.
- La `IngredientDetailCard` s'affiche dans le détail recette
  pour les ingrédients liés.
- Au moins 30 ingrédients de `demo_recipes.dart` sont résolvables
  par le picker (recherche par nom FR).

### 13.3 DoD spécifique Lot G
- La nutrition d'une recette est calculée depuis la DB quand
  tous les ingrédients sont liés.
- La heatmap aromatique s'affiche pour les recettes à ≥2
  ingrédients liés.

### 13.4 DoD spécifique Lot H
- Une recette avec une incompatibilité déclenche le
  `RecommendationSheet`.
- Les alertes Phase 4 s'affichent pour les règles applicables.

## 14. Décisions et arbitrages

- **dp-101** (PO) : CIQUAL reste obsolète pour l'import (cohérent
  avec dp-016 du Lot A). Les mappings `ciqual_ids` (Phase 1) sont
  affichés comme info-bulle dans l'`IngredientDetailCard`, pas
  comme données requêtables.
- **dp-102** (PO) : les 4 BDD métier sont la **seule source de
  vérité** pour l'UI. Les démos `demo_recipes.dart` restent en
  mémoire pour le seed et les tests, mais ne sont plus la source.
- **dp-103** (PO) : pas d'écriture automatique dans la DB
  depuis l'UI. L'utilisateur édite une recette via le formulaire
  (Lot D), qui passe par `RecipesRepository.save()`. Pas
  d'ORM caché en mémoire qui auto-commit.
- **dp-104** : riverpod plutôt que provider. Justification :
  - provider (héritage Flutter) est en mode maintenance.
  - riverpod offre un test-time override facile.
  - communauté Flutter en 2026 = majoritaire riverpod.
- **dp-105** : le calcul de la `NutritionProfile.aggregate`
  est **synchrone** (les données sont en RAM après l'import
  CSV). Pas de stream, pas de Future. C'est plus simple et
  déterministe.
- **dp-106** : on n'implémente **pas** l'algorithme de scoring
  flavour complet avec les poids w1..w8 (formule dans
  `flavor_scoring_method.md`). On lit directement le
  `overall_score` du CSV Phase 3, qui est déjà calculé par
  les scripts de phase 3. Le `FlavorScorer` ne fait que de
  l'agrégation, pas du calcul. **Justification** : éviter de
  réinventer un algo déjà documenté et validé.
- **dp-107** : les règles Phase 4 v1 sont appliquées en mode
  dégradé (50% confidence) car les `composition_constraints` et
  `process_constraints` ne sont pas encore parsables. C'est
  explicitement noté dans la `FunctionalAlert.confidence`.
- **dp-108** (Lot G, Kimi 2026-08-26) : le fallback du `FlavorScorer`
  (combinaison n-aire absente) est une **moyenne arithmétique simple**
  des paires 2×2, et non une « moyenne pondérée » (§7.1) : aucun poids
  n'existe dans le modèle `FlavorMatch` §5.4, et l'annexe §19 (0.84)
  est validée par moyenne simple.
- **dp-109** (Lot H, Kimi 2026-08-26) : la formule de score du
  `Recommender` est `clamp(moyenne(paires candidat↔restants) + 0.15
  si résout un conflit − 0.20 si nouvelle alerte, 0, 1)`, tout candidat
  introduisant une paire < 0.40 étant écarté. Les bonus de l'annexe
  §20 étaient illustratifs et incohérents entre eux ; l'ordre §20
  (Poulet > Agneau > Porc) est reproduit par les tests.
- **dp-110** (Lot H, Kimi 2026-08-26) : la sévérité des `FunctionalAlert`
  est déduite par heuristique (famille `safety` → danger,
  `effect_direction` `decrease*` → warning, sinon info) faute de
  colonne dédiée dans `interaction_rules.csv`. À valider métier par le PO.
- **dp-111** (Audit, GLM 5.3 / ZCode, 2026-08-26) : le mapping
  `component_id` du `NutritionRepository` utilisait des clés génériques
  (`energy_kcal`, `proteins`…) **absentes du dictionnaire Phase 2
  réel**, qui utilise des tags Ciqual (`ENERCKCAL`, `ENERC`, `PROTEIN`,
  `FAT`, `FAT_SAT`, `CARB`, `SUGAR`, `FIBER`, `NA`, `WATER`). Sans ce
  correctif, **tous les nutriments sortaient à 0** sur données réelles
  (vérifié par smoke test). Ajout de la conversion sel = NA (mg) × 2.5
  / 1000 (§5.3) et ENERC kJ → kcal.
- **dp-112** (Audit, 2026-08-26) : `FlavorRepository` garde désormais
  le **meilleur** score par clé (les données réelles contiennent
  26 clés dupliquées — contextes prédits/observés) ; l'écrasement
  « dernier lu » d'origine était non déterministe et contredisait le
  §7.2 (« le meilleur FlavorMatch »).
- **dp-113** (Audit, 2026-08-26) : l'annexe §20 (Bœuf + Fromage bleu +
  Thym) est **illustrative** — ces ingrédients n'existent pas dans le
  référentiel réel (`AGNEAUVIANDE`, `POULETVIANDE`, `PORCVIANDE`…).
  Le smoke test DoD §13.4 vérifie les invariants §9.1 sur des paires
  réelles (ex. ABRICOT × ANETH = 0.03) au lieu de l'ordre
  Poulet > Agneau > Porc.
- **dp-114** (Audit, 2026-08-26) : le fuzzy Levenshtein s'applique aux
  **tokens de l'index** > 4 chars (la requête peut être plus courte :
  « boef » → « boeuf », distance 1) — lecture du §6.1 validée par les
  tests. Le `IngredientAliasIndex` gagne aussi un vrai fold d'accents
  (table de décomposition latine : é→e, œ→oe…) et un fallback
  « requête séparateurs seulement » (« --- » ≈ vide).
- **dp-115** (Audit, 2026-08-26) : les catégories réelles Phase 1 sont
  **accentuées** (« végétal », r-103 confirmé) — le picker affiche les
  valeurs brutes ; la table de traduction culinaire reste à faire
  (ac-111).
- **dp-116** (Audit, 2026-08-26) : `showRecipeFormDialog` prend un
  `db` optionnel (dérive Flavor/Functional repositories + charge les
  summaries du picker). `recipes_home_page.dart` (Forbidden « UI Alex
  intacte ») n'a reçu que le passage de paramètre aux 2 call sites —
  écart documenté, zéro changement visuel. Le warning live H4 est
  actif dès que `db` est fourni, et se recalcule aussi à la
  suppression d'un slot ingrédient.
- **dp-117** (Retour PO n°2, 2026-08-26) : **enrichissement
  nutritionnel Ciqual complémentaire et sourcé**. Constat : la Phase 2
  réelle ne couvre que 62/603 ingrédients ; le PO demande de
  compléter en citant les sources in-app. Décisions :
  (a) les `ciqual_ids` du référentiel Phase 1 pointent vers une
  ANCIENNE numérotation Ciqual (la table 2025-11-03 a été renumérotée,
  ex. le code « banane » désigne l'abricot) → le générateur
  `tool/generate_ciqual_enrichment.dart` résout par **code si cohérent
  avec le nom, sinon par matching de nom** (mot-tête obligatoire pour
  un match partiel, préférence « cru », dédoublonnage anti-collision) ;
  (b) chaque valeur transporte sa **citation exacte** (`sources.xml`
  Ciqual, ex. analyses USDA, rapports de labo) et son code de
  confiance ; (c) règle « complément, pas doublon » : seuls les
  ingrédients SANS record Phase 2 sont enrichis ; (d) `database-metier/`
  et `ciqual/` restent intacts — CSV dérivé versionné dans
  `assets/database-enrichment/` (386 Ko, 1 668 records, 153 ingrédients,
  10 constituants dont énergie 327/328 UE et sel 10004) ; (e) le panneau
  nutrition affiche les sources (libellé + citation en tooltip).
- **dp-118** (Retour PO n°2, 2026-08-26) : le champ quantité du
  formulaire devient « nombre + sélecteur d'unité (g/ml) » ; les
  textes libres existants (« 2 branches ») restent supportés ; le ml
  est converti en grammes avec densité 1 (approximation v1, ac-101).
- **dp-119** (Retour PO n°2, 2026-08-26) : les messages
  d'incompatibilité aromatique **nomment les ingrédients concernés et
  le score** — warning live du formulaire (dès l'ouverture d'une
  recette déjà en conflit), sous-titre de la bannière de
  recommandation (reprend les paires du sheet) ; les alertes Phase 4
  citent leurs `source_refs` dans la card dépliée.
- **dp-120** (Retour PO n°3, 2026-08-26) : **nutrition exhaustive et
  automatique**. (a) Le CSV d'enrichissement Ciqual exporte TOUS les
  constituants du dictionnaire (71 retenus : vitamines A-K/B1-B12,
  minéraux, omégas, cholestérol, alcool, sucres individuels, amidon,
  polyols… ; unités extraites des noms FR ; 7 564 records). (b) Le
  modèle expose les macros nommés + `micronutrients` (tag canonique
  fusionnant les tags Phase 2 et Ciqual 2025, ex. FOL/FOLFD→FOLATES)
  + `alcohol` ; l'agrégateur les pondère par quantité et par portion.
  (c) Le panneau nutrition affiche des sections repliables
  Minéraux / Vitamines / Autres constituants. (d) Le formulaire
  **calcule la nutrition automatiquement** (aperçu live « Calculée
  automatiquement — N/M ingrédients ») dès qu'un ingrédient lié a un
  profil ; la saisie manuelle devient un repli explicite (« Forcer la
  saisie manuelle ») et prime sur le calcul si l'utilisateur l'édite ;
  la sauvegarde embarque les valeurs calculées.
- **dp-121** (Retour PO n°3, 2026-08-26) : heatmap « vraie » — chaque
  cellule affiche la **meilleure donnée connue** : paire 2×2 directe,
  sinon la plus petite combinaison N-aire connue contenant la paire
  (approximation signalée dans le bottom sheet : « Score approximé… »).
  Une **légende** sous la matrice explicite les 5 catégories + « Pas
  de donnée » (les paires réellement sans donnée restent grises — la
  couverture Phase 3 est de 97/603 ingrédients, cf. ac-115).
- **dp-122** (Retour PO n°3, 2026-08-26) : les alertes physico-chimiques
  sont **proportionnées au mix** — `FunctionalConstraintSolver.evaluate`
  reçoit les grammes par ingrédient (parsés des quantités), chaque
  alerte porte ses ingrédients déclencheurs et leur **part massique du
  mix** (« Part du mix : 45 % »), avec la note « Influence probablement
  faible » sous 5 %.
- **dp-123** (Retour PO n°3, 2026-08-26) : le picker affiche la
  **totalité** du référentiel sur « Toutes » (603, ListView
  virtualisée) — la limite de pertinence (50) ne s'applique qu'aux
  recherches.

## 15. Dette et risques connus

### 15.1 Dette à anticiper
- **ac-101** (Medium) : la nutrition par portion agrège les
  ingrédients mais ne tient pas compte des **pertes à la cuisson**
  (eau qui s'évapore, lipides absorbés). Phase future : introduire
  un facteur de rétention par méthode de cuisson (bouilli = 0.85,
  rôti = 0.90, etc.).
- **ac-102** (Low) : le `FlavorCompatibilityHeatmap` devient
  illisible au-delà de 5 ingrédients. Phase future : clustering /
  MDS pour regrouper visuellement.
- **ac-103** (Low) : la `Recommender` ne tient pas compte de la
  disponibilité saisonnière des ingrédients. Phase future : intégrer
  un calendrier de saisonnalité.
- **ac-104** (Medium) : les `process_constraints` Phase 4 ne sont
  pas parsées. Phase future : mini-DSL ou mapping structuré.
- **ac-105** (Low) : le Picker ne supporte pas la recherche
  phonétique (Soundex, Metaphone). Phase future : si Gui veut
  que "tomate" trouve "tomates cerises" même avec faute, ajouter
  l'algo.
- **ac-106** (High) : le projet n'a **aucun test d'intégration**
  (`integration_test/`) aujourd'hui. Le smoke test données réelles
  (`test/core/database/metier_smoke_test.dart`, audit 2026-08-26)
  couvre l'import + les parcours métier en `flutter test`, mais les
  scénarios UI end-to-end (`integration_test/`) restent à créer.
- **ac-107** (Low, Lot G) : `waterContent` est agrégé en **somme**
  comme les autres nutriments dans `NutritionAggregator` — sémantique
  à revoir au lot qualité (moyenne pondérée par la masse ?).
- **ac-108** (Medium, Lot H) : ~~le warning live H4 est implémenté
  mais inactif~~ **RÉSOLU (audit 2026-08-26)** : `showRecipeFormDialog`
  prend `db`, les appelants l'injectent, le warning est actif.
- **ac-109** (Low, Lot H) : le dismiss du `RecommendationSheet` est en
  mémoire de session seulement (Set statique) — pas de sessionStorage
  en Flutter desktop ; persistance Drift éventuelle = lot séparé (bump
  schema).
- **ac-110** (High, Lots G+H) : ~~90 cas de tests écrits mais jamais
  exécutés~~ **RÉSOLU (audit 2026-08-26)** : suite **219/219 verte**,
  analyze 0 issue, format exit 0, build Windows OK.
- **ac-111** (Low, Audit) : les chips de catégories du picker
  affichent les valeurs brutes accentuées du référentiel (« végétal »,
  « ingrédient technique »…) — la table de traduction culinaire
  (r-103) reste à faire (lot UI dédié).
- **ac-112** (Low, Audit) : `IngredientSummary.copyWith` /
  `IngredientDetail.copyWith` suivent le pattern `?? this.x` —
  impossible de remettre un champ nullable à null (aucun usage
  courant ; reconstruction par le mapping Drift).
- **ac-113** (Low, Audit) : `confidence` des `NutritionProfile`
  agrégés est hardcodée à 0.8 (Lot F v1) — à remplacer par la
  moyenne réelle des records au lot qualité.
- **ac-114** (High, Retour PO n°2) : les `ciqual_ids` du référentiel
  Phase 1 (`ingredient_registry_v1.csv`) sont incohérents avec
  l'édition Ciqual 2025-11-03 (numérotation renumérotée) — contourné
  par la résolution par nom (dp-117), mais le fichier source reste à
  corriger un jour (hors `database-metier/` intouchable → décision PO).
- **ac-115** (High, Retour PO n°2) : la couverture flavour réelle est
  de **97/603 ingrédients** (4 557 paires < 0.40 existantes mais sur
  un sous-ensemble) — « documenter TOUTES les interactions » exigerait
  un chantier données dédié (sources type FlavourDB / littérature
  food-pairing), non fabricable à partir de rien. Les paires non
  couvertes affichent « Pas de donnée ».
- **ac-116** (Low, Retour PO n°2) : la résolution par nom Ciqual
  produit parfois une approximation (Banane → « Banane plantain,
  crue » car la banane dessert n'existe pas dans cette édition ;
  Tomate fraîche → « Tomate verte, crue » car pas de tomate générique
  crue). L'aliment retenu est TOUJOURS visible in-app
  (`source_food_name`) ; perfectible via une table d'alias manuelle.
- **ac-117** (Low, Retour PO n°3) : les cellules de heatmap sans paire
  directe utilisent la plus petite combinaison N-aire connue
  (approximation signalée dans le bottom sheet). Amélioration future :
  modèle de composition de paires (moyenne pondérée des combinaisons).
- **ac-118** (Low, Retour PO n°3) : la nutrition calculée embarquée à
  la sauvegarde est un instantané (macros seules) ; les micronutriments
  détaillés ne sont pas stockés dans `Recipe` (modèle §5) — recalculés
  live dans la vue détail. Stockage = évolution du modèle Recipe.

### 15.2 Risques
- **r-101** (Medium) : **temps de chargement au boot**. Si la DB
  est déjà importée, on charge 6 154 ingrédients + 4 594 paires
  flavour + 16 règles. Estimation : ~100-200 ms. Acceptable, mais
  à profiler sur du vieux hardware.
- **r-102** (Low) : **drift_flutter 0.3.1 est instable** (on l'a
  vu au Lot E avec les erreurs de type). Phase future : migrer
  vers 0.4.x ou vers `drift` + `sqlite3_flutter_libs` directement
  (cf. dp-001).
- **r-103** (Low) : **Glossaire des colonnes Phase 1** dans
  `ingredient_schema.md` est très technique. Le Picker doit
  traduire en langage culinaire ("vegetal" → "Légumes & fruits",
  "fungi" → "Champignons", "ferment" → "Ferments"). Lot F inclut
  une table de mapping.
- **r-104** (Low) : **allergies graves** (arachides, gluten,
  fruits à coque). L'UI doit afficher ces badges **partout** où
  un ingrédient apparaît, pas seulement dans le Picker. Lot F
  inclut un widget `AllergenChip` réutilisable.

## 16. Impossibilités documentées (R-07)

- **flutter test / flutter run / flutter analyze** : non
  exécutables dans les conteneurs agents Kimi/Hermes (Flutter SDK
  absent). **LEVÉ le 2026-08-26** : la session audit (GLM 5.3 via
  ZCode, machine Windows du PO, SDK Flutter 3.47.1 / Dart 3.13.1) a
  exécuté `flutter analyze` (0 issue), `flutter test` (219/219),
  `dart format --set-exit-if-changed` (exit 0) et `flutter build
  windows` (OK).
- **dart test** : OK en sandbox, 18/18 verts au moment de la
  rédaction du plan.
- **build_runner** : OK en sandbox, 74 outputs générés en 37 s.
- **Validation du design par tests visuels** : non automatisable.
  Le smoke test manuel PO (ouvrir l'app, importer la BDD métier,
  composer 3 recettes types, valider l'UX picker/nutrition/heatmap/
  recommandation) reste à faire — logique couverte par
  `metier_smoke_test.dart`, pas le rendu.

## 17. À faire par Gui (post-plan)

1. **Relire et valider** ce plan (réunion 1h estimée). Points
   d'attention :
   - §2 (deps) : OK pour `flutter_riverpod` + `collection` ?
   - §10 (phasage 3 lots) : ordre et scope OK ?
   - §11 (pas de bump schemaVersion v3→v4) : OK ?
2. **Ouvrir la branche** `Ge-LAG/phase-09-metier-driven-ux` depuis
   `main` (après merge de `Ge-LAG/db-connection-strategies`).
3. **Décider** des arbitrages en suspens (ac-001, ac-101 à ac-106).
4. **Lancer** le Lot F (cf. §10.1) avec GLM 5.3 (ou Kimi K3 / autre
   IA de dev selon préférence).
5. **Capitaliser** dans `PROJET.json`/`PROJET.md` à chaque fin de
   lot (BP-17 strict).
6. **Listening gate** : après Lot F, valider l'UX Picker (sélection
   d'ingrédient) en conditions réelles (Gui + un panel de 2-3
   testeurs cuisine).

## 18. Liens

- `tasks/phase-08-db-connection-strategies.md` (cahier Lots A+B+C+D)
- `database-metier/phase1-referentiel/ingredient_schema.md` (schéma
  Phase 1 détaillé)
- `database-metier/phase2-nutrition/nutrition_schema.md`
- `database-metier/phase3-flavour/flavor_scoring_method.md`
- `database-metier/phase4-functional/functional_rule_engine_spec.md`
- `database-metier/phase4-functional/functional_schema.md`
- `lib/core/database/importers/csv_import_service.dart` (intégration
  existante)
- `lib/features/recipes/data/recipes_repository.dart` (CRUD recettes
  existant)
- `lib/features/ingredients/data/ingredients_repository.dart`
  (lookup Phase 1 existant)
- `lib/features/recipes/presentation/widgets/recipe_metier_advisory_panel.dart`
  (point d'extension pour le Lot H)

## 19. Annexe — Exemple de calcul Flavour

Recette : **Tomate (ING-PLANT-TOMATE-000001) + Basilic (ING-PLANT-BASILIC-000001) + Mozzarella (ING-DAIRY-MOZZARELLA-000001)**

1. Query `flavor_compatibility.csv` pour la combinaison size=3
   contenant ces 3 IDs (dans n'importe quel ordre). Si elle existe,
   on a directement le `overall_score`. Si non, fallback sur la
   moyenne pondérée des paires 2×2 (Tomate-Basilic, Tomate-Mozzarella,
   Basilic-Mozzarella).
2. Paires attendues d'après les données Phase 3 :
   - Tomate-Basilic : 0.87 (excellent — accord italien classique)
   - Tomate-Mozzarella : 0.85 (excellent)
   - Basilic-Mozzarella : 0.80 (bon)
   - Moyenne : 0.84 → catégorie `good` (juste en-dessous du seuil
     excellent).
3. L'UI affiche la heatmap avec ces scores et la note globale 0.84.

## 20. Annexe — Exemple de calcul Recommandation

Recette problématique : **Bœuf (ING-ANIMAL-BOEUF-000001) + Fromage bleu (ING-DAIRY-BLEU-000001) + Thym (ING-PLANT-THYM-000001)**

1. Paires flavour : Bœuf-Fromage bleu = 0.32 (à éviter), Bœuf-Thym
   = 0.71 (bon), Fromage-Thym = 0.58 (moyen).
2. Score global : moyenne pondérée ≈ 0.54 → catégorie `average`,
   mais avec 1 paire `avoid` (Bœuf-Fromage bleu) → trigger
   `RecommendationSheet`.
3. Le sheet s'ouvre sur l'ingrédient "Bœuf" (la source principale
   de l'incompatibilité avec le fromage bleu).
4. Candidats de substitution (même `category_level_1 = 'animal'`) :
   - Agneau (ING-ANIMAL-AGNEAU-000001) : score flavor avec fromage
     bleu = 0.62 (moyen) → score candidat = 0.62 + bonus "résout
     incompatibilité" = 0.78
   - Poulet (ING-ANIMAL-POULET-000001) : 0.74 (bon) avec fromage
     bleu → 0.81
   - Porc (ING-ANIMAL-PORC-000001) : 0.55 (moyen) → 0.71
5. Le sheet propose 3 substituts (Agneau, Poulet, Porc) avec leur
   score et l'explication.

---

**Note de fin** : ce plan est **vivant**. Il sera amendé à chaque
fin de lot (F, G, H) avec :
- les décisions PO prises en cours de route (nouveaux `dp-XXX-NNN`)
- la dette réellement constatée (nouveaux `ac-XXX-NNN`)
- les impossibilités R-07 rencontrées
- la mise à jour des compteurs de tests

Format de mise à jour : section "Décisions et arbitrages" (§14) +
section "Dette et risques" (§15) + commit atomique `docs: phase 09
cahier update lot F`.