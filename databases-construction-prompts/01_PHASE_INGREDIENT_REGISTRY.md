# PHASE 1 — Construction du référentiel maître des matières premières et sous-produits

## Mission de l'agent

Construire le **référentiel canonique des ingrédients** qui servira de colonne vertébrale à toutes les bases de données de l'application de formulation culinaire R&D.

Cette phase doit être terminée et validée avant les bases nutritionnelles, aromatiques ou fonctionnelles.

---

## 1. Objectif

Établir une liste aussi complète que raisonnablement possible de :

- matières premières ;
- ingrédients culinaires ;
- ingrédients techniques alimentaires pertinents ;
- sous-produits / produits intermédiaires génériques ;

utilisables pour :
- cuisine salée ;
- cuisine sucrée ;
- pâtisserie ;
- boulangerie ;
- sauces ;
- condiments ;
- boissons ;
- cocktails ;
- formulation alimentaire expérimentale.

Ne pas construire une liste de plats ou de produits commerciaux.

---

## 2. Définition opérationnelle

### Inclure

Toute entité générique qui peut être utilisée comme intrant d'une formulation.

### Exclure

- marque ;
- SKU ;
- plat complet ;
- menu ;
- produit marketing spécifique ;
- préparation commerciale n'ayant pas de valeur générique.

### Sous-produit admissible

Un sous-produit est admissible lorsqu'il correspond à une transformation générique réutilisable.

Exemples :

- compote ;
- confiture ;
- purée ;
- concentré ;
- extrait ;
- bouillon ;
- fond ;
- fumet ;
- pâte fermentée ;
- beurre de noix ;
- tahini ;
- mélasse ;
- sirop ;
- vinaigre ;
- alcool générique ;
- saumure ;
- lactosérum ;
- gélatine ;
- amidon modifié si son usage est pertinent et légal dans le périmètre choisi.

---

## 3. Taxonomie minimale à couvrir

L'agent doit rechercher activement des éléments dans **toutes** les familles suivantes.

### Végétaux

- fruits ;
- agrumes ;
- baies ;
- fruits tropicaux ;
- légumes-fruits ;
- légumes-feuilles ;
- légumes-racines ;
- tubercules ;
- bulbes ;
- tiges ;
- fleurs ;
- pousses ;
- céréales ;
- pseudo-céréales ;
- légumineuses ;
- noix ;
- graines ;
- algues ;
- plantes aromatiques ;
- épices ;
- piments ;
- champignons ;
- produits végétaux fermentés.

### Produits animaux

- viandes ;
- abats ;
- volailles ;
- gibiers ;
- poissons ;
- mollusques ;
- crustacés ;
- œufs ;
- lait ;
- produits laitiers génériques ;
- graisses animales ;
- gélatine / collagène alimentaire ;
- produits fermentés pertinents.

### Produits dérivés / techniques

- farines ;
- semoules ;
- flocons ;
- amidons ;
- fécules ;
- protéines isolées/concentrées ;
- fibres ;
- sucres ;
- sirops ;
- polyols culinaires autorisés ;
- sels ;
- acides alimentaires ;
- agents levants ;
- gélifiants ;
- épaississants ;
- hydrocolloïdes ;
- émulsifiants ;
- enzymes culinaires pertinentes ;
- cultures / ferments lorsque leur usage est compatible avec le périmètre réglementaire ;
- huiles ;
- matières grasses ;
- extraits ;
- huiles essentielles alimentaires ;
- eaux florales ;
- arômes génériques lorsque pertinents.

### Sous-produits culinaires génériques

- purées ;
- jus ;
- concentrés ;
- coulis ;
- compotes ;
- confitures ;
- marmelades ;
- pâtes ;
- beurres de fruits à coque ;
- bouillons ;
- fonds ;
- fumets ;
- réductions génériques ;
- sauces fermentées pouvant servir d'ingrédient ;
- pâtes fermentées ;
- vinaigres ;
- saumures ;
- pickles génériques lorsque utilisés comme intrants ;
- ingrédients torréfiés, maltés, germés, fermentés, séchés ou fumés.

### Boissons et cocktails

Pour ce domaine, autoriser les catégories génériques même lorsqu'elles constituent un produit fini consommable :

- eau ;
- eau gazeuse ;
- jus ;
- nectars génériques lorsque utiles ;
- café ;
- thé ;
- infusions ;
- cacao boisson non formulé ;
- lait et boissons végétales génériques ;
- kombucha générique ;
- bière par style pertinent ;
- cidre ;
- vin par famille utile ;
- vermouth ;
- spiritueux par catégorie ;
- liqueurs génériques ;
- bitters génériques ;
- sirops ;
- eaux florales ;
- hydrolats.

Ne pas créer de ligne par marque.

---

## 4. Sources de découverte

Utiliser plusieurs stratégies indépendantes afin de maximiser le rappel.

### Sources structurées prioritaires

- FoodOn — https://foodon.org/
- LanguaL — https://www.langual.org/
- EFSA FoodEx2 — https://www.efsa.europa.eu/en/data/data-standardisation
- ANSES-CIQUAL — https://ciqual.anses.fr/
- USDA FoodData Central — https://fdc.nal.usda.gov/
- annuaire FAO/INFOODS — https://www.fao.org/food-composition/tables-and-databases/

### Sources complémentaires

- bases nationales de composition alimentaire ;
- taxonomies botaniques/zoologiques ;
- littérature de science alimentaire ;
- ouvrages de référence culinaires ;
- référentiels réglementaires d'additifs/ingrédients ;
- ressources spécialisées sur les boissons et cocktails.

Toute source doit être enregistrée dans `DATA_SOURCE_REGISTER.csv`.

---

## 5. Schéma du livrable principal

Créer :

`ingredient_registry.csv`

Une ligne = une identité d'ingrédient canonique suffisamment distincte pour produire des propriétés sensorielles, nutritionnelles ou fonctionnelles différentes.

Colonnes minimales :

```text
ingredient_id
canonical_name_fr
canonical_name_en
aliases_fr
aliases_en
scientific_name
kingdom_or_origin
category_level_1
category_level_2
category_level_3
source_organism
anatomical_part
ingredient_class
raw_or_intermediate
processing_state
physical_form
fermented
dried
smoked
roasted
concentrated
alcoholic
generic_abv_range
country_or_region_relevance
foodon_id
langual_ids
foodex2_code
ciqual_ids
usda_fdc_ids
other_external_ids
allergen_tags
regulatory_notes
source_refs
confidence
review_status
notes
```

Utiliser un séparateur stable dans les champs multivalués, par exemple `|`.

---

## 6. Ne pas sur-fragmenter

Créer deux lignes différentes uniquement si la distinction peut raisonnablement modifier :
- nutrition ;
- arôme ;
- fonctionnalité ;
- procédé ;
- utilisation culinaire.

### Exemple utile

```text
Amande crue
Amande torréfiée
Pâte d'amande 100 %
Huile d'amande
```

### Exemple inutile

```text
Amande sachet 250 g
Amande premium
Amande marque X
```

---

## 7. Gestion des synonymes et homonymes

Normaliser :
- accents ;
- singulier/pluriel ;
- tirets ;
- variantes orthographiques ;
- translittérations ;
- noms vernaculaires.

Ne jamais fusionner automatiquement deux entrées uniquement parce que leur nom est proche.

Lorsque le même nom désigne plusieurs espèces ou produits, créer des identités séparées.

---

## 8. Déduplication

Effectuer au moins trois passes :

### Passe A — exacte
- nom normalisé ;
- identifiant externe ;
- nom scientifique.

### Passe B — fuzzy
Détecter les noms très proches.

### Passe C — sémantique
Examiner les cas de quasi-synonymes.

Pour chaque fusion, conserver :
- anciens identifiants ;
- justification ;
- alias.

Créer :

`ingredient_merge_log.csv`

---

## 9. Liste de rejet

Créer :

`excluded_items.csv`

Colonnes :

```text
original_name
source
reason_code
reason_detail
possible_parent_ingredient_id
```

`reason_code` :

```text
BRAND
SKU
FINISHED_DISH
DUPLICATE
OUT_OF_SCOPE
NON_FOOD
INSUFFICIENT_IDENTITY
REGULATORY_EXCLUSION
```

---

## 10. Mesure de couverture

Créer :

`ingredient_coverage_report.md`

Présenter :
- nombre total d'entités ;
- nombre par famille ;
- nombre par source ;
- distribution par degré de transformation ;
- couverture boissons/cocktails ;
- couverture géographique ;
- nombre d'éléments sans correspondance externe ;
- zones de faiblesse connues.

Rechercher spécifiquement les familles sous-représentées avant de considérer la phase terminée.

---

## 11. Critères d'acceptation

La phase n'est validée que si :

- 100 % des lignes ont un `ingredient_id` unique ;
- 100 % ont un nom canonique ;
- 100 % ont une catégorie principale ;
- aucune marque commerciale évidente n'est présente ;
- les doublons probables ont été audités ;
- les principales catégories culinaires sont couvertes ;
- chaque ligne possède au moins une provenance ;
- les licences des sources ont été contrôlées ;
- un rapport de couverture est livré ;
- un journal de rejet est livré ;
- le schéma est documenté.

---

## 12. Livrables

Obligatoires :

```text
ingredient_registry.csv
ingredient_schema.md
ingredient_coverage_report.md
excluded_items.csv
ingredient_merge_log.csv
DATA_SOURCE_REGISTER.csv
qa_report.md
```

À la fin, produire une version figée :

`ingredient_registry_v1.csv`

Cette version devient l'entrée obligatoire des phases suivantes.
