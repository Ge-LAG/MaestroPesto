# MaestroPesto — Base de connaissance métier (database-metier)

Construction incrémentale et traçable de la base métier pour le moteur de formulation
culinaire R&D MaestroPesto, conforme à la doctrine « exhaustive démontrable » décrite
dans `databases-construction-prompts/00_MASTER_ORCHESTRATION.md`.

## Vue d'ensemble

4 phases exécutées dans l'ordre chronologique défini :

| Phase | Dossier | Rôle | Lignes principales |
|---|---|---|---|
| 1 | `phase1-referentiel/` | Référentiel maître des ingrédients | 603 ingrédients |
| 2 | `phase2-nutrition/` | Base nutritionnelle harmonisée | 751 lignes, 64 mappings, 62 ingrédients |
| 3 | `phase3-flavour/` | Compatibilité sensorielle | 39 composés, 4560 paires, 5 hyper-interactions |
| 4 | `phase4-functional/` | Fonctionnel & process | 40 composants, 16 règles, 10 cas expérimentaux |

Chaque phase produit un livrable principal + ses fichiers d'audit (schemas, méthodes
de confiance, couverture, QA). Toutes les bases utilisent l'identifiant canonique
`ingredient_id` produit en Phase 1 (`ingredient_registry_v1.csv` est figé).

## Régénération

Chaque phase est reproductible. Exécuter dans l'ordre :

```bash
python3 database-metier/phase1-referentiel/scripts/build_ingredient_registry.py
python3 database-metier/phase2-nutrition/scripts/build_nutrition_database.py
python3 database-metier/phase3-flavour/scripts/build_flavor_database.py
python3 database-metier/phase4-functional/scripts/build_functional_database.py
```

Les scripts écrivent dans leur dossier de phase respectif.

## Politique globale

- Aucune marque commerciale, aucun SKU, aucun produit fini (géré en Phase 1).
- Aucune donnée inventée : valeur absente = champ vide.
- Licences validées avant ingestion (voir `DATA_SOURCE_REGISTER.csv` Phase 1).
- Provenance au niveau de chaque valeur (`source_id`, `source_food_id`).
- `evidence_type` distincte pour mesure / analytique / littérature / règle experte / calcul / prédiction.
- `confidence ∈ [0, 1]` reproductible et documenté.
- Méthodes de confiance formalisées par phase.
- Validation croisée QA à chaque phase.

## Conventions communes

- **Encodage** : UTF-8 (pas de BOM).
- **Séparateur CSV** : virgule.
- **Champs multivalués** : pipe `|`.
- **Identifiant** : `ING-<DOMAIN>-<FAM>-<NNNNNN>` (Phase 1).
- **Nutrition record** : `NUTR-NNNNNNN` (Phase 2).
- **Arome compound** : nom en MAJUSCULES (Phase 3).
- **Rule** : `RULE-<FAM>-<NNN>` (Phase 4).
- **Process op** : `PROC-<NAME>` (Phase 4).

## Limites connues

- Couverture nutritionnelle à 10% des ingrédients : **stratégie incrémentale documentée**.
  L'objectif est de couvrir d'abord les ingrédients prioritaires en profondeur.
- Coverage aromatique : 30 ingrédients principaux (~5%) avec profils riches ;
  le moteur peut extrapoler par composé/descripteur pour les autres.
- Phase 4 : règles expertes + physico-chimiques ; ML et calibration
  sensorielle différés.
- Bases indépendantes les unes des autres : la couche d'unification
  (moteur de recommandation final) sera développée ultérieurement.

## Sources principales

- FoodOn, LanguaL, FoodEx2 (ontologies)
- ANSES-CIQUAL (nutrition FR)
- USDA FoodData Central (nutrition US)
- FlavorDB2, PubChem, ChEBI (arômes / chimie)
- Littérature food science : Damodaran, BeMiller, Phillips, McClements,
  O'Brien, Belitz, Lund, Srivastava/John.

Voir `phase1-referentiel/DATA_SOURCE_REGISTER.csv` pour le détail des licences.
