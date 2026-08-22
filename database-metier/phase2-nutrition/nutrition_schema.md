# Schéma — `nutrition_database.csv`

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22
- Format: long (un couple ingrédient × composant × source = une ligne).
- Base normalisée : `pour 100 g de partie comestible` (1 unité = g ou mg ou µg ou kJ ou kcal).
- Les volumes (100 ml) ne sont convertis en 100 g qu'avec densité référencée ; sinon conservés tels quels.

## Colonnes

| colonne | type | description |
|---|---|---|
| nutrition_record_id | string | PK locale `NUTR-NNNNNNN`. |
| ingredient_id | string | FK vers `ingredient_registry_v1.csv`. |
| ingredient_state_id | enum | `raw`, `boiled`, `roasted`, `fried`, `dried`, `grilled`, `baked`, `steamed`, `sauteed`, `boiled_drained`, `pasteurized`, `fermented`, `churned`, `milled`, `conched`, `extracted`, `brewed`, `concentrated`, `crystallized`. |
| canonical_name_fr | string | Dénormalisé pour audit humain (source of truth = `ingredient_id`). |
| source_id | enum | `CIQUAL`, `USDAFDC`, `INFOODS`, `OTHER`. |
| source_food_id | string | Identifiant de l'aliment dans la source. |
| source_food_name | string | Nom source. |
| source_version | string | Version de la table source. |
| source_country | string | Pays de référence (ex. `France` pour CIQUAL). |
| component_id | string | FK vers `component_dictionary.csv`. |
| component_name | string | Dénormalisé. |
| component_group | enum | `energy`, `matrix`, `macronutrient`, `carbohydrate`, `lipid`, `mineral`, `vitamin`, `amino_acid`, `bioactive`. |
| original_value | numeric | Valeur brute publiée par la source. |
| original_unit | enum | g, mg, µg, kJ, kcal, % (rare), IU (rare — converti en RE/TE). |
| normalized_value | numeric | Valeur normalisée (cf. base ci-dessus). |
| normalized_unit | enum | idem. |
| basis | enum | `per_100g_edible_part`, `per_100g_as_sold`, `per_100ml` (si conversion documentée). |
| value_qualifier | enum | `EXACT`, `TRACE`, `BELOW_LOQ`, `BELOW_LOD`, `ESTIMATED`, `CALCULATED`, `IMPUTED`, `NOT_DETECTED`, `NOT_REPORTED`, `UNKNOWN`. |
| value_type | enum | `measured`, `analytical_database`, `literature`, `expert_rule`, `calculated`, `model_predicted`, `culinary_observation`, `unknown`. |
| min_value | numeric | Borne basse (si connue). |
| max_value | numeric | Borne haute (si connue). |
| sample_count | integer | Nombre d'échantillons (si documenté). |
| analytical_method | string | Méthode analytique. |
| derivation_method | string | Méthode de dérivation (ex. `N×6.25`). |
| data_date | date | Date de la mesure. |
| retrieval_date | date | Date d'extraction. |
| source_url | string | URL de référence. |
| confidence | float [0-1] | Score qualité de la donnée. |
| mapping_confidence | float [0-1] | Score qualité du mapping. |
| notes | string | Notes libres. |

## Conventions de qualité

- Pas d'invention : valeur absente = champ vide, jamais '0' pour « inconnu ».
- Sodium ≠ sel : la table stocke Na élément ; pour calculer l'équivalent sel multiplier par 2.5.
- Calories : on stocke l'énergie publiée ; les contrôles vérifient la cohérence kJ/kcal (× 4.184 ± 5%).
- Gras saturés < gras totaux : contrôle systématique.
- Sucres totaux ≤ glucides totaux.
- Fibres ≤ glucides totaux.
- États crus/cuits strictement séparés (state_id obligatoire).
