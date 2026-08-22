# Schéma du référentiel — Phase 1

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Identifiant canonique

`ingredient_id` = `ING-<DOMAIN>-<FAM>-<NNNNNN>`

- DOMAIN ∈ {PLANT, ANIMAL, MARINE, FUNGUS, DAIRY, TECH, BEV, COND, FERMENT, MIX}
- FAM = slug ASCII (max 12 chars) de la famille/ingrédient
- NNNNNN = compteur 6 chiffres, jamais réutilisé

Stabilité : l'identifiant n'est jamais réémis après retrait. Tout changement d'identité
crée une nouvelle ligne (avec mention dans `ingredient_merge_log.csv`).

## Caractères séparateurs

- Séparateur CSV : virgule `,`
- Séparateur de champs multivalués : pipe `|`
- Encodage : UTF-8 sans BOM
- Newline : LF (`\n`)

## Colonnes (extrait normalisé)

| colonne | type | description |
|---|---|---|
| ingredient_id | string | Identifiant canonique unique (PK). |
| canonical_name_fr | string | Nom canonique français. |
| canonical_name_en | string | Nom canonique anglais. |
| aliases_fr | string\|pipe | Alias FR séparés par `|`. |
| aliases_en | string\|pipe | Alias EN séparés par `|`. |
| scientific_name | string | Binôme binomial Latin (vide si non applicable). |
| kingdom_or_origin | string | `Plantae`, `Animalia`, `Fungi`, `Minéral`, `Synthétique`, `(multi)`. |
| category_level_1 | string | Végétal / Animal / Boisson / Condiment / Ingrédient technique / Ferment / Préparation. |
| category_level_2 | string | Sous-catégorie principale. |
| category_level_3 | string | Sous-catégorie fine. |
| source_organism | string | Organisme ou mélange d'organismes (ex. « Œuf/Huile/Moutarde »). |
| anatomical_part | string | Partie anatomique utilisée. |
| ingredient_class | string | Classe culinaire. |
| raw_or_intermediate | enum | `raw` \| `intermediate`. |
| processing_state | string | État de transformation (fresh, dried, fermented, etc.). |
| physical_form | string | Forme physique. |
| fermented | bool | `true`/`false`. |
| dried | bool | `true`/`false`. |
| smoked | bool | `true`/`false`. |
| roasted | bool | `true`/`false`. |
| concentrated | bool | `true`/`false`. |
| alcoholic | bool | `true`/`false`. |
| generic_abv_range | string | Plage ABV pour boissons alcoolisées. |
| country_or_region_relevance | string | Origine pertinente (générique). |
| foodon_id | string | Identifiant FoodOn (CC BY 4.0). |
| langual_ids | string | Identifiants LanguaL (pipe-separated). |
| foodex2_code | string | Code FoodEx2. |
| ciqual_ids | string | Code(s) CIQUAL (pipe-separated). |
| usda_fdc_ids | string | Identifiant(s) USDA FDC. |
| other_external_ids | string | Autres identifiants (DBpedia, Wikidata). |
| allergen_tags | string | Allergènes (UE 1169/2011). |
| regulatory_notes | string | Notes réglementaires. |
| source_refs | string\|pipe | Sources référencées (pipe-separated). |
| confidence | float [0-1] | Score de confiance interne. |
| review_status | string | `curated` \| `to_review` \| `rejected`. |
| notes | string | Notes libres. |

## Conventions de qualité

- Aucune marque, aucun SKU, aucun produit fini : voir `excluded_items.csv`.
- Aucune valeur inventée : valeurs manquantes = champ vide.
- Aucune ligne sans `ingredient_id` ni `canonical_name_fr` ni `category_level_1`.

## Règles de validation automatisées (QA)

1. Unicité de `ingredient_id` (PK).
2. `canonical_name_fr` non vide pour 100% des lignes.
3. `category_level_1` ∈ {végétal, animal, fungi, algue, ingredient technique, boisson, condiment, ferment, préparation}.
4. Pas de marque commerciale : regex simple sur liste de suffixes/marques connus.
5. Présence d'au moins une référence externe (FoodOn/LanguaL/CIQUAL/USDA/FoodEx2) pour ≥ 70% des lignes.
6. Conformité UTF-8, séparateur virgule.
7. Pas de doublon exact sur le tuple `(canonical_name_fr, processing_state, source_organism)`.
