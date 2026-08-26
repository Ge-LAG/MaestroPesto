# MaestroPesto - Journal de projet (V5)

> Miroir humain de `PROJET.json` (source de verite machine). Toute modification de l'un doit entrainer la modification de l'autre (BP-17).

## Identite

| Champ | Valeur |
|-------|--------|
| **Projet** | MaestroPesto |
| **Phase courante** | Phase 09 : Lots F+G+H livrés, audités, validés Windows + retours PO n°2 et n°3 traités (237/237 tests, build OK). Dernier lot : nutrition exhaustive et AUTOMATIQUE, heatmap complète avec légende, alertes physico-chimiques proportionnées au mix, picker complet. |
| **Etat general** | Bootstrap V5 en cours. Lots A+B+C+D+E livrés (36 commits). Phase 09 complète + retours PO successifs. Retour n°3 (2026-08-26) : nutrition calculée automatiquement depuis les quantités du mix (aperçu live dans le formulaire, saisie manuelle en repli, valeurs sauvegardées) + exhaustivité (CSV Ciqual 7 564 records : vitamines A-K/B1-B12, minéraux, omégas, cholestérol, alcool ; sections repliables Minéraux/Vitamines/Autres dans le panneau) ; heatmap « vraie » (meilleure donnée connue par cellule — paire directe ou plus petite combinaison n-aire — + légende) ; alertes physico-chimiques avec part massique du mix des déclencheurs (« Part du mix : 45 % », note « influence faible » < 5 %) ; picker « Toutes » liste les 603 ingrédients. 237/237 tests verts (+10), analyze 0, format 0, build windows OK. Aucun push (R-01). |

## Focus immediat

Smoke test MANUEL du PO sur le retour n°3 : relancer l'import (5 phases, l'enrichissement exhaustif s'ajoute), éditer une recette avec girolle → nutrition auto dans le formulaire + Minéraux/Vitamines dans le panneau détail, vérifier la légende de la heatmap et les parts du mix dans les alertes, scroller le picker jusqu'à Z. Puis décision push (R-01).

## Prochaines etapes

- PO : smoke test manuel du retour n°3 (nutrition auto, micros par portion, légende heatmap, parts du mix, picker complet).
- PO : décider du chantier données flavour (ac-115, couverture 97/603 — Pignon de pin/zestes/huiles essentielles sans données) et du traitement des ciqual_ids sources (ac-114).
- PO : pousser Ge-LAG/db-connection-strategies vers origin après validation finale (R-01), ouvrir la PR vers main.
- Session dédiée possible : cache global IngredientAliasIndex (ac-F-004), persistance dismiss (ac-H-004), qualité (ac-107/113/118), traduction catégories (ac-111).

## Questions ouvertes

- Smoke test manuel PO : valider nutrition auto + micros + heatmap légendée + parts du mix en conditions réelles.
- Couverture flavour 97/603 (ac-115) : chantier données dédié sourcé (FlavourDB, littérature food-pairing) pour « documenter toutes les interactions » ? Décision PO.
- ciqual_ids du référentiel Phase 1 incohérents avec l'édition Ciqual 2025 (ac-114) : corriger la source un jour ou maintenir la résolution par nom ?
- Approximations de résolution Ciqual (Banane→plantain, Tomate→verte, ac-116) : acceptable ou table d'alias ?
- Lot I (mode batch, §10.4) : à planifier ou abandonner ?
- Sévérité Phase 4 heuristique (dp-110/ac-H-001) : validation métier Gui.
- Pousser la branche vers origin/main après validation PO finale (R-01).

## Journal des sessions

#### 2026-08-26 - retour-po-3-metier
*Traitement du retour PO n°3 (4 points, avec capture d'écran) : nutrition AUTOMATIQUE (aperçu live « Calculée automatiquement — N/M » dans le formulaire, saisie manuelle en repli explicite qui prime si éditée, valeurs calculées sauvegardées) et EXHAUSTIVE (générateur Ciqual tous constituants : 71 retenus, 7 564 records CSV — vitamines A-K/B1-B12, minéraux, omégas, cholestérol, alcool, amidon, polyols ; modèle Micronutrient à tags canoniques fusionnant Phase 2/Ciqual 2025 ; agrégateur pondéré par quantité/portions ; panneau avec sections repliables Minéraux/Vitamines/Autres) ; heatmap « vraie » (bestKnownMatchFor : paire directe sinon plus petite combinaison n-aire, approximation signalée, toutes cellules préchargées, légende 5 catégories + « Pas de donnée ») — diagnostic honnête : Pignon de pin/Zeste d'orange/Huile essentielle ont 0 donnée en base Phase 3 (couverture 97/603) ; alertes physico-chimiques proportionnées (triggerIngredientIds + mixShare des grammes, « Part du mix : X % », note influence faible < 5 %) ; picker « Toutes » complet (603). 237/237 tests verts (+10), smoke réel étendu (fer girolle 3,47 mg/portion), analyze 0, format 0, build windows OK. Cahier dp-120/121/122/123, dette ac-117/118. Commits BP-22. Aucun push (R-01).*
- PO : Ge-LAG
- Agent : GLM 5.3 (Zcode)

#### 2026-08-26 - retour-po-2-metier
*Traitement du retour PO n°2 : diagnostic couverture (nutrition 62/603, flavour 97/603) ; enrichissement Ciqual sourcé (découverte : ciqual_ids du référentiel d'une ancienne numérotation → résolution par nom avec garde-fous ; générateur tool/ + CSV 1 668 records/153 ingrédients avec citations exactes ; loader en 5e phase du bouton import, complément seulement si non couvert) ; sources citées in-app (panel nutrition + tooltip citation, alertes Phase 4 avec source_refs) ; incompatibilités nommées (« Abricot × Aneth (0.03) » dans le warning live dès l'ouverture + sous-titre de la bannière) ; quantités nombre + unité g/ml. 227/227 tests verts (+8), analyze 0, format 0, build windows OK. Cahier : dp-117/118/119, dette ac-114/115/116. Commits BP-22. Aucun push (R-01).*
- PO : Ge-LAG
- Agent : GLM 5.3 (Zcode)

#### 2026-08-26 - phase-09-audit-correctifs
*Audit du travail Kimi (Lots F+G+H) + correctifs sur machine Windows PO (SDK Flutter 3.47.1). Compilation : 3 erreurs lib corrigées (_listEq manquant, _preloaded non initialisé, constructeur _IngredientDetailStrings.fr() invalide). Tests : 7 fichiers réparés (imports package:test→flutter_test, lot_d_schema_test→package maestropesto, widget_test paramètre services via AppServices.forTesting). Métier : mapping component_id Ciqual réel (dp-111 — tous nutriments à 0 sinon), meilleur score par clé flavor (dp-112), fold d'accents NFD + fuzzy sur tokens d'index (dp-114). Vision : picker DB câblé (ac-F-002), IngredientDetailCard intégré (ac-F-003), warning live H4 actif (dp-116), widgets migrés vers context.strings. +30 tests dont smoke tests DoD sur données réelles (§19 n-aire 0.90 vérifié ; §20 illustratif, dp-113). Résultats : flutter test 219/219, analyze 0 issue, format exit 0, build windows OK. Commits atomiques BP-22. Aucun push (R-01).*
- PO : Ge-LAG
- Agent : GLM 5.3 (Zcode)

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
- **ac-F-001** (Medium) — Audit Lot F NON dispatché. **RÉSOLU (audit 2026-08-26)** : audit réalisé par GLM 5.3 via Zcode. Statut : resolu.
- **ac-F-002** (High) — Picker fallback AlertDialog. **RÉSOLU (audit 2026-08-26, dp-116)** : db injecté au formulaire, vrai picker quand le référentiel est importé. Statut : resolu.
- **ac-F-003** (Medium) — IngredientDetailCard non intégré. **RÉSOLU (audit 2026-08-26)** : card affichée sous chaque row liée dans la vue détail. Statut : resolu.
- **ac-F-004** (Low) — Cache global IngredientAliasIndex non implémenté (reconstruit à chaque recherche). Statut : a_traiter.
- **ac-F-005** (Medium) — Tests manquants. **RÉSOLU (audit 2026-08-26)** : picker (5), detail card (4), models F (9), nutrition mapping (7) — suite 219/219 verte. Statut : resolu.
- **ac-F-006** (Low) — Wrapper dispatch GLM : content vide quand reasoning substantiel. Statut : a_traiter.
- **ac-F-007** (Critical) — Opencode CLI KO côté Z.AI (UnknownError persistante). Statut : a_traiter (contourné : Zcode sur machine PO).

### Lots G+H (2026-08-26, Kimi)
- **ac-G-001** (High) — Tests jamais exécutés. **RÉSOLU (audit 2026-08-26)** : 7 échecs corrigés, 219/219 verts. Statut : resolu.
- **ac-G-002** (Low) — Fallback FlavorScorer moyenne simple. **RÉSOLU (acté dp-108)**. Statut : resolu.
- **ac-G-003** (Low) — waterContent agrégé en somme (sémantique à revoir au lot qualité). Statut : a_traiter.
- **ac-H-001** (Medium) — Sévérité Phase 4 heuristique — validation métier Gui requise. Statut : a_traiter.
- **ac-H-002** (Medium) — Warning live H4 inactif. **RÉSOLU (audit 2026-08-26, dp-116)** : actif via db. Statut : resolu.
- **ac-H-003** (Medium) — Formule Recommender v1. **RÉSOLU (acté dp-109 + dp-113 : §20 illustratif)**. Statut : resolu.
- **ac-H-004** (Low) — Dismiss recommandation en mémoire de session seulement. Statut : a_traiter.

### Audit 2026-08-26 (GLM 5.3 / Zcode)
- **ac-111** (Low) — Catégories accentuées brutes dans le picker (« végétal »…) — traduction culinaire r-103 à faire. Statut : a_traiter.
- **ac-112** (Low) — copyWith modèles ingrédient : remise à null non supportée (pattern `?? this.x`, aucun usage courant). Statut : a_traiter.
- **ac-113** (Low) — Confiance nutrition agrégée hardcodée 0.8. Statut : a_traiter.

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
