# MaestroPesto - Journal de projet (V5)

> Miroir humain de `PROJET.json` (source de verite machine). Toute modification de l'un doit entrainer la modification de l'autre (BP-17).

## Identite

| Champ | Valeur |
|-------|--------|
| **Projet** | MaestroPesto |
| **Phase courante** | Phase 09 : Lots F+G+H livrés, audités, validés Windows + retours PO n°2, n°3 et n°4 traités (244/244 tests, build OK). Dernier lot (n°4) : enrichissement Ciqual étendu aux 603 (union 371/603), compteur nutrition honnête, tri naturel FR du picker, chips lisibles. |
| **Etat general** | Bootstrap V5 en cours. Lots A+B+C+D+E livrés (36 commits). Phase 09 complète + retours PO successifs. Retour n°4 (2026-08-26) : (1) enrichissement Ciqual étendu à TOUS les ingrédients via résolution par nom durcie (garde-fous anti faux-amis, repli du perdant de collision, standins curatés — dp-124) → 18 339 records/367 ingrédients, union Phase 2 = 371/603, les 221 restants étant absents de Ciqual 2025-11-03 (ac-119) ; (2) compteur honnête withDataCount : plus de « Calculée automatiquement (4/4) » à zéros — message explicite + saisie manuelle quand les liés n'ont pas de données (dp-125) ; (3) tri naturel français du registre : « Œuf de poule » n'est plus après Z, la liste 603 est complète (dp-126) ; (4) chips du picker en texte noir (dp-127). 244/244 tests verts (+7), analyze 0, format 0, build windows OK. Aucun push (R-01). |

## Focus immediat

Smoke test MANUEL du PO sur le retour n°4 : relancer l'import BDD métier (couverture 371/603), éditer une recette avec bœuf/poulet/crème liquide (enrichis), lier un non-couvert (wakamé) pour lire le message « Aucune donnée nutritionnelle en base », scroller le picker (Œuf de poule entre Noix et Orange, chips lisibles). Puis décision push (R-01).

## Prochaines etapes

- PO : smoke test manuel du retour n°4 (couverture 371, message honnête, tri du picker, chips).
- PO : décider des chantiers données (flavour ac-115 97/603 ; nutrition 2e source ac-119 221/603 absents Ciqual) et des ciqual_ids sources (ac-114).
- PO : pousser Ge-LAG/db-connection-strategies vers origin après validation finale (R-01), ouvrir la PR vers main.
- Session dédiée possible : cache global IngredientAliasIndex (ac-F-004), persistance dismiss (ac-H-004), qualité (ac-107/113/118), traduction catégories (ac-111).

## Questions ouvertes

- Smoke test manuel PO : valider enrichissement étendu + message honnête + tri picker + chips en conditions réelles.
- Couverture flavour 97/603 (ac-115) : chantier données dédié sourcé (FlavourDB, littérature food-pairing) pour « documenter toutes les interactions » ? Décision PO.
- Couverture nutrition 371/603 (ac-119) : 221 ingrédients absents de Ciqual (algues, zestes, beurres de noix, épices exotiques…) — deuxième source sourcée (USDA FDC) ? Décision PO.
- ciqual_ids du référentiel Phase 1 incohérents avec l'édition Ciqual 2025 (ac-114) : corriger la source un jour ou maintenir la résolution par nom ?
- Approximations de résolution Ciqual (Banane→plantain, ac-116 ; standins curatés dp-124 type Bœuf→steak cru) : acceptable ou table d'alias ?
- Lot I (mode batch, §10.4) : à planifier ou abandonner ?
- Sévérité Phase 4 heuristique (dp-110/ac-H-001) : validation métier Gui.
- Pousser la branche vers origin/main après validation PO finale (R-01).

## Journal des sessions

#### 2026-08-26 - retour-po-4-metier
*Traitement du retour PO n°4 (capture « 4/4 sans score nutrition ») : (1) NUTRITION 371/603 — le générateur Ciqual résout désormais par nom TOUS les ingrédients du registre avec des garde-fous durcis et itérés sur le log de résolution (matchs partiels sans aliment nouveau ni tête de catégorie — anti « Huile de carthame »→« Huile d'amande » et « Beurre de cajou »→beurre laitier ; match complet borné en longueur — anti « Sucre glace »→« Corne de gazelle » ; exclusions jus/zeste/pomme cajou/coco/fourré/mélange ; cohérence du mot-tête — anti « Chèvre frais »→« Pizza au chèvre » — sauf énumérations « Champignon, chanterelle ou girolle » et hypernymes « Champignon, cèpe » ; égalité exacte dominante — « Raisin sec » ; repli du perdant de collision sur son 2ᵉ candidat — torréfiés→grillées ; standins curatés manuels — Bœuf→steak cru, sels, cajou, chèvre frais, chocolat 70 %, café, calvados) → CSV 18 339 records/367 ingrédients, union Phase 2 = 371/603 ; les 221 restants sont absents de Ciqual 2025-11-03 (ac-119, décision PO pour une 2ᵉ source). (2) COMPTEUR HONNÊTE — NutritionAggregation distingue resolvedCount (liés) de withDataCount (avec données réelles) : le formulaire n'affiche plus « Calculée automatiquement (4/4) » à zéros mais explique (« Aucune donnée nutritionnelle en base pour les N ingrédients liés ») et propose la saisie manuelle. (3) TRI NATUREL FR — compareNaturalFr (œ→oe) dans allSummaries/candidatesForCategory : le tri codepoint SQL plaçait « Œuf de poule » (U+0152 > Z) en DERNIER — la liste était complète mais paraissait tronquée. (4) CHIPS LISIBLES — texte noir explicite sur « Toutes » et catégories. Flavour inchangée (97/603, composés d'arômes = 9 ingrédients — ac-115). 244/244 tests verts (+7), analyze 0, format 0, build windows OK. Cahier dp-124→127, dette ac-119. Commits BP-22. Aucun push (R-01).*
- PO : Ge-LAG
- Agent : GLM 5.3 (Zcode)

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
