# MaestroPesto - Journal de projet (V5)

> Miroir humain de `PROJET.json` (source de verite machine). Toute modification de l'un doit entrainer la modification de l'autre (BP-17).

## Identite

| Champ | Valeur |
|-------|--------|
| **Projet** | MaestroPesto |
| **Phase courante** | Phase 09 Lots F+G+H livrés sur Ge-LAG/db-connection-strategies (28 commits atomiques, 0 push). Lot I (optionnel) non implémenté. |
| **Etat general** | Bootstrap V5 en cours. Lots A+B+C+D+E livrés (36 commits, 0 push). Phase 09 Lot F livré (11 commits). Phase 09 Lots G+H livrés le 2026-08-26 par Kimi Code CLI (17 commits) : nutrition agrégée par portion, FlavorRepository/FlavorScorer + heatmap aromatique, FunctionalConstraintSolver/FunctionalRepository + alertes physico-chimiques, Recommender + RecommendationSheet, warning live formulaire. ~90 cas de tests écrits mais NON exécutés (aucun SDK Flutter/Dart sur la machine de session, R-07). Aucun push (R-01 strict). |

## Focus immediat

Valider Lots F+G+H sur Windows avec SDK Flutter : `dart analyze`, `flutter test`, `dart format`. Smoke tests DoD §13.3 (nutrition calculée + heatmap) et §13.4 (recommandation Bœuf+Bleu+Thym). Push après validation PO (R-01).

## Prochaines etapes

- PO : valider Lots F+G+H sur Windows — flutter analyze, flutter test, dart format --set-exit-if-changed (0 issue attendu, §12.4).
- PO : smoke test DoD §13.3 — recette ≥2 ingrédients liés : nutrition calculée (badge « Calculé depuis N ingrédients sur M ») + heatmap aromatique.
- PO : smoke test DoD §13.4 — recette Bœuf+Bleu+Thym avec DB importée : bannière recommandation + sheet + substituts (Agneau/Poulet/Porc).
- PO : pousser Ge-LAG/db-connection-strategies vers origin après validation finale (R-01), ouvrir la PR vers main.
- Session dédiée : câblage DB du picker (ac-F-002), intégration IngredientDetailCard (ac-F-003), injection des repositories pour le warning H4 (ac-H-002).
- Décider Lot I (mode batch, §10.4) et l'audit indépendant des Lots G+H.
- Listening gate UX Picker toujours en attente (validation Lot F).

## Questions ouvertes

- Validation Windows : flutter analyze / flutter test / dart format non exécutables dans la session Kimi (aucun SDK détecté). Tous les tests Lots F+G+H sont écrits mais jamais exécutés.
- Lot F v1 : picker ingrédients toujours en fallback AlertDialog (ac-F-002) — câblage DB complet non traité en Lots G/H, session dédiée ?
- IngredientDetailCard toujours NON intégré à recipe_detail_view._IngredientRow (ac-F-003) — session dédiée ?
- H4 : warning live formulaire implémenté mais inactif tant que les repositories ne sont pas injectés par l'appelant (ac-H-002).
- Recommender : candidatesForCategory exclut les lignes Phase 1 sans confidence — vérifier sur données réelles importées.
- Lot I (mode batch CSV de recettes externes, §10.4) : à planifier ou abandonner ?
- Audit du code Lots G+H (comme ac-F-001 pour le Lot F) : par quel harness IA ?
- Pousser Ge-LAG/db-connection-strategies vers origin/main après validation PO finale (R-01).

## Journal des sessions

#### 2026-08-26 - phase-09-lots-G-H
*Phase 09 Lots G+H livrés : 17 commits atomiques BP-22 (69cebe3..cc1e4ce). Lot G (8 commits) : FlavorMatch + catégories, NutritionAggregator synchrone (dp-105) + aggregateForRecipe, FlavorScorer (dp-106, fallback moyenne simple documenté), FlavorRepository (cache), badge source nutrition (calculé N/M vs manuel), FlavorCompatibilityHeatmap (max 5, bottom sheet), intégration advisory panel. Lot H (9 commits) : FunctionalAlert + Recommendation, FunctionalConstraintSolver (dp-107 confidence ×0.5, sévérité heuristique documentée), FunctionalRepository (cache), FunctionalAlertCard (non dismissable), Recommender (formule v1 déterministe, ordre §20 reproduit), RecommendationSheet (dismiss session), warning live formulaire (repositories optionnels), 27 clés i18n cumulées. ~90 cas de tests écrits mais AUCUN exécuté (aucun SDK Flutter/Dart sur la machine, R-07) — validation déferrée au PO sur Windows. Aucun push (R-01). Lot I non implémenté.*
- PO : Ge-LAG
- Agent : Kimi Code CLI (K2)

#### 2026-08-26 - phase-09-lot-F
*Phase 09 Lot F livré : 11 commits atomiques BP-22 sur Ge-LAG/db-connection-strategies (55d5bfb..462f6c2). Modèles purs IngredientSummary/IngredientDetail/NutritionProfile + IngredientAliasIndex (recherche floue) + NutritionRepository.forIngredient + IngredientsPickerPage + IngredientDetailCard + intégration recipe_form_dialog + 16 clés FR. Pivots : opencode CLI KO (UnknownError) → Z.AI API directe ; GLM 5.3 produit du reasoning sans content structuré → Hermes implémente directement. Aucun push (R-01).*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

#### 2026-08-22 - bootstrap-v5
*Bootstrap de la Methode V5 sur MaestroPesto. Creation des fichiers racine + amend METHOD.md (branche PR + commits structures). Branche dediee Ge-LAG/bootstrap-v5-doc, 1 seul commit 'method: bootstrap v5 doc'. Aucun fichier source modifie, aucun push.*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

#### 2026-08-22 - backlog-idees-ocr-recettes
*Ajout d'une section "Backlog idees produit" dans PROJET.md (et miroir PROJET.json, BP-17) avec l'entree IDEA-OCR-RECETTES : integration d'un OCR local pour formaliser les recettes au format MaestroPesto. Aucun fichier source modifie, aucun commit, aucun push (le repo est en bootstrap V5, en attente de validation PO).*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

#### 2026-08-25 - lot-e-cablage-live
*Cablage reel du bouton Importer BDD metier : AppServices (DB + CsvImportService), main.dart async init, drift_flutter retourne QueryExecutor, _MetierStatusAction avec 3 etats (spinner/neutre/vert), db: optionnel passe au RecipeDetailView pour activer le metier advisory panel, assets/database-metier/ bundles (22 CSV, fichiers reels apres fix symlinks). 6 commits atomiques (a900bb6/6f36195/03acea3/b9feb86/072802f/7dcc2cb) + 2 fixes build (c1c7003/920928e). 18/18 tests Dart verts en sandbox.*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

#### 2026-08-25 - phase-09-plan
*Redaction du plan d implementation Phase 09 (plans/phase-09-metier-driven-ux.md, 20 sections, 39 ko) couvrant l exposition des 4 BDD metier (Phase 1 referentiel, Phase 2 nutrition, Phase 3 flavour, Phase 4 functional) + module de recommandation. Phasage 3 lots F/G/H. Aucune modification de code.*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

## Test-dev en cours

Aucun (`test_dev_en_cours` = `null`).

## Backlog test-dev

Vide. Format attendu : `td-NNN` (retours de test manuel), voir BP-10.

## Backlog audit code

Format `ac-NNN` (constats d'audit de code), voir BP-18. Détail complet dans `PROJET.json` (source de vérité).

### Lot F (hérité)
- **ac-F-001** (Medium) — Audit Lot F NON dispatché (opencode KO, GLM reasoning-only). Statut : a_traiter.
- **ac-F-002** (High) — Picker ingrédients en fallback AlertDialog, pas de vrai picker DB. TOUJOURS OUVERT après G+H. Statut : a_traiter.
- **ac-F-003** (Medium) — IngredientDetailCard non intégré à recipe_detail_view._IngredientRow. TOUJOURS OUVERT après G+H. Statut : a_traiter.
- **ac-F-004** (Low) — Cache global IngredientAliasIndex non implémenté (reconstruit à chaque recherche). Statut : a_traiter.
- **ac-F-005** (Medium) — Tests widget picker/detail card + models F toujours absents (G+H ont ajouté leurs propres tests). Statut : a_traiter.
- **ac-F-006** (Low) — Wrapper dispatch GLM : content vide quand reasoning substantiel. Statut : a_traiter.
- **ac-F-007** (Critical) — Opencode CLI KO côté Z.AI (UnknownError persistante). Statut : a_traiter.

### Lots G+H (2026-08-26, Kimi)
- **ac-G-001** (High) — ~90 cas de tests Lots G+H écrits mais JAMAIS exécutés (aucun SDK Flutter/Dart, R-07). Validation Windows requise avant push. Statut : a_traiter.
- **ac-G-002** (Low) — Fallback FlavorScorer en moyenne simple (écart « moyenne pondérée » du plan, dp-108). Statut : a_traiter.
- **ac-G-003** (Low) — waterContent agrégé en somme (sémantique à revoir au lot qualité). Statut : a_traiter.
- **ac-H-001** (Medium) — Sévérité Phase 4 déduite par heuristique (famille safety → danger, decrease* → warning, sinon info) — pas de colonne dédiée dans le CSV. Statut : a_traiter.
- **ac-H-002** (Medium) — Warning live H4 inactif en production : repositories optionnels jamais injectés par l'appelant (lié à ac-F-002). Statut : a_traiter.
- **ac-H-003** (Medium) — Formule score Recommender v1 déterministe ≠ chiffres illustratifs §20 (ordre Poulet>Agneau>Porc reproduit, dp-109). Statut : a_traiter.
- **ac-H-004** (Low) — Dismiss recommandation en mémoire de session seulement (pas de sessionStorage Flutter desktop). Statut : a_traiter.

## Backlog idees produit

Format attendu : `IDEA-<SLUG>` (idees emises par le PO, non chiffrees, non priorisees). A convertir en ADR (voir METHOD.md) avant toute implementation.

#### IDEA-OCR-RECETTES — OCR local pour formalisation de recettes
- **Source** : Gui, session 2026-08-22 (chat Hermes).
- **Pitch** : Integrer un modele local d'OCR dans MaestroPesto pour prendre en photo une recette (livre, magazine, manuscrit…) et que l'app la formalise automatiquement au format interne MaestroPesto (sections ingredients / etapes / quantites / temps).
- **Pourquoi local** : pas d'appel cloud (donnees perso + offline-first + latence).
- **Modeles candidats a evaluer** : Tesseract 5 (baseline, multilingue FR/EN/IT/ES), PaddleOCR (texte imprime structure), EasyOCR (integration rapide), Florence-2 / TrOCR (robustesse manuscrits). Choix apres spike sur photos reelles.
- **Pipeline pressenti** : capture photo → pre-traitement (deskew, denoise, detection zones) → OCR brut → parsing structurant (LLM local leger type Phi-3 mini ou regex+modeles) → validation UI → sauvegarde format MaestroPesto.
- **Dépendances identifiees** : format de recette interne (a verifier dans `lib/models/recipe.dart` ou equivalent), choix modele OCR (perf/RAM mobile), choix parseur structurant.
- **Statut** : 🟡 Idee backlog — non chiffree, non priorisee.
- **Prochain pas** : ouvrir une ADR (cf. methode V5) avant tout code.

## Documents associes

- `METHOD.md`
- `METHOD.json`
- `METHOD-BOOTSTRAP.md`
- `PROJET.md`
- `PROJET.json`
- `INDEX-docs.md`
- `ARCHITECTURE.md`
- `README.md`
