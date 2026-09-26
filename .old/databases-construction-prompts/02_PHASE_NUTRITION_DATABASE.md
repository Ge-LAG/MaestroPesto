# PHASE 2 — Construction de la base nutritionnelle harmonisée

## Mission de l'agent

Construire une base nutritionnelle robuste destinée au moteur de formulation culinaire R&D.

Le référentiel `ingredient_registry_v1.csv` issu de la Phase 1 est l'autorité d'identité.

Aucune ligne nutritionnelle ne doit exister sans tentative explicite de rattachement à un `ingredient_id`.

---

## 1. Objectif

Fournir, pour les matières premières et sous-produits retenus, les données nutritionnelles disponibles avec :

- provenance ;
- version ;
- état de l'aliment ;
- unité normalisée ;
- base de calcul ;
- qualité ;
- incertitude ;
- méthode d'obtention lorsque disponible.

L'objectif n'est pas de créer une moyenne opaque, mais une **base traçable permettant ensuite au moteur d'effectuer des choix appropriés au contexte**.

---

## 2. Hiérarchie des sources

### Source française primaire

**ANSES-CIQUAL 2025**

https://ciqual.anses.fr/

Utiliser CIQUAL en priorité pour les aliments correspondant au contexte français.

Ne pas supposer que CIQUAL est exhaustif.

### Complément international prioritaire

**USDA FoodData Central**

https://fdc.nal.usda.gov/

Privilégier :
1. Foundation Foods ;
2. données analytiques / expérimentales pertinentes ;
3. SR Legacy en complément lorsque nécessaire.

Éviter les Branded Foods pour le corpus canonique, sauf cas exceptionnel de recherche de correspondance, sans intégrer la marque comme ingrédient.

### Compléments

**FAO/INFOODS**

https://www.fao.org/food-composition/

Utiliser son annuaire et ses recommandations pour identifier des tables nationales fiables.

**EuroFIR FoodEXplorer**

https://www.eurofir.org/our-tools/foodexplorer/

Utiliser uniquement lorsque les droits d'accès et de réutilisation sont compatibles avec le projet.

---

## 3. Politique de licence

Avant toute ingestion :

1. enregistrer la source dans `DATA_SOURCE_REGISTER.csv` ;
2. vérifier le droit d'utilisation ;
3. vérifier la redistribution ;
4. vérifier l'utilisation commerciale ;
5. enregistrer l'attribution requise.

Ne jamais contourner un accès payant ou une restriction.

---

## 4. Filtrage

Inclure uniquement les entrées mappables vers le référentiel maître.

Exclure du corpus canonique :
- marques ;
- plats composés complets sans utilité comme sous-produit ;
- produits marketing ;
- duplications de portions commerciales.

Conserver séparément les états pertinents :

```text
raw
cooked
boiled
steamed
fried
roasted
baked
dried
rehydrated
fermented
smoked
frozen
canned
concentrated
```

Ne jamais utiliser automatiquement une donnée « cuite » pour un ingrédient « cru ».

---

## 5. Modèle long obligatoire

Le livrable utilisateur principal doit pouvoir rester **un CSV unique** tout en acceptant un nombre variable de nutriments.

Créer :

`nutrition_database.csv`

Format long :

```text
nutrition_record_id
ingredient_id
ingredient_state_id
canonical_name_fr
source_id
source_food_id
source_food_name
source_version
source_country
component_id
component_name
component_group
original_value
original_unit
normalized_value
normalized_unit
basis
value_qualifier
value_type
min_value
max_value
sample_count
analytical_method
derivation_method
data_date
retrieval_date
source_url
confidence
mapping_confidence
notes
```

---

## 6. Base normalisée

Lorsque possible, utiliser comme base :

`pour 100 g de partie comestible`

Mais conserver la valeur originale.

Pour les liquides, ne convertir `100 ml` vers `100 g` que si une densité adéquate est disponible et référencée.

Ne jamais supposer `1 ml = 1 g` par défaut.

---

## 7. Constituants à couvrir

### Énergie et matrice

- énergie kJ ;
- énergie kcal ;
- eau ;
- matière sèche ;
- cendres si disponible.

### Macronutriments

- protéines ;
- lipides ;
- glucides selon définition de la source ;
- sucres totaux ;
- sucres individuels lorsqu'ils existent ;
- amidon ;
- fibres ;
- alcool ;
- polyols ;
- acides organiques si disponibles.

### Lipides détaillés

- AG saturés ;
- mono-insaturés ;
- poly-insaturés ;
- oméga-3 ;
- oméga-6 ;
- acides gras individuels disponibles ;
- cholestérol.

### Minéraux / électrolytes

- sodium ;
- potassium ;
- calcium ;
- magnésium ;
- phosphore ;
- fer ;
- zinc ;
- cuivre ;
- manganèse ;
- sélénium ;
- iode ;
- autres disponibles.

### Vitamines

Conserver les formes détaillées proposées par la source :
- A et caroténoïdes ;
- groupe B ;
- C ;
- D ;
- E ;
- K ;
- folates / acide folique lorsque distingués.

### Acides aminés

Ajouter lorsqu'une source fiable les fournit.

### Autres composés pertinents

Lorsque disponibles et juridiquement réutilisables :
- caféine ;
- théobromine ;
- phytostérols ;
- composés bioactifs.

Ne pas mélanger ces catégories avec les nutriments réglementaires sans les identifier clairement.

---

## 8. Harmonisation des composants

Créer une table interne :

`component_dictionary.csv`

Colonnes minimales :

```text
component_id
canonical_name
synonyms
component_group
canonical_unit
infoods_tagname
ciqual_component_id
usda_nutrient_id
other_ids
definition
conversion_notes
```

Objectif : empêcher que « carbohydrate by difference », « glucides disponibles » et « total carbohydrate » soient fusionnés sans analyse.

---

## 9. Appariement des aliments

Suivre une approche inspirée des recommandations FAO/INFOODS de food matching.

Le score de correspondance doit prendre en compte :

- identité biologique ;
- partie anatomique ;
- état ;
- traitement ;
- teneur en matière grasse ;
- degré de concentration ;
- cuisson ;
- teneur en eau ;
- fermentation ;
- pays / variété si pertinent.

Créer :

`nutrition_mapping_log.csv`

avec :

```text
ingredient_id
source_id
source_food_id
match_type
match_score
matched_features
conflicting_features
review_required
review_notes
```

---

## 10. Conflits entre sources

Ne jamais remplacer une valeur par une autre sans trace.

Conserver les observations sources.

Si une valeur « recommandée » est calculée, créer explicitement :

```text
harmonized_value
harmonization_method
harmonization_version
harmonization_confidence
```

Méthodes possibles :

```text
PRIORITY_SOURCE
WEIGHTED_MEAN
MEDIAN
STATE_SPECIFIC
COUNTRY_SPECIFIC
MANUAL_REVIEW
NO_HARMONIZATION
```

---

## 11. Valeurs manquantes

Interdit :
- inventer ;
- utiliser `0` pour « inconnu » ;
- confondre « trace » et zéro.

Utiliser :

```text
value_qualifier =
EXACT
TRACE
BELOW_LOQ
BELOW_LOD
ESTIMATED
CALCULATED
IMPUTED
NOT_DETECTED
NOT_REPORTED
UNKNOWN
```

Toute imputation doit être identifiable.

---

## 12. Contrôles de cohérence

Automatiser au minimum :

- énergie plausible par rapport aux macronutriments ;
- somme des constituants majeurs raisonnable ;
- sous-composants ne dépassant pas leurs totaux sans explication ;
- unités reconnues ;
- valeurs négatives interdites sauf convention justifiée ;
- sodium ≠ sel ;
- distinction poids frais / matière sèche ;
- doublons ;
- incohérences de cuisson/état ;
- densité requise pour conversions volumétriques.

Ne pas « corriger » automatiquement une valeur suspecte : la marquer.

---

## 13. Score de confiance

Le score doit tenir compte de :
- nature analytique de la donnée ;
- nombre d'échantillons ;
- récence ;
- qualité de la source ;
- qualité du mapping ;
- proximité de l'état alimentaire ;
- présence de méthode analytique.

Documenter la formule dans :

`nutrition_confidence_method.md`

---

## 14. Rapport de couverture

Créer :

`nutrition_coverage_report.md`

Indiquer :
- % d'ingrédients avec au moins une source ;
- % avec CIQUAL ;
- % avec USDA ;
- % avec autre source ;
- couverture par catégorie ;
- nutriments les moins couverts ;
- ingrédients non mappés ;
- données anciennes ;
- conflits majeurs ;
- distributions de confiance.

---

## 15. Critères d'acceptation

- aucune donnée sans source ;
- aucune valeur inconnue transformée en zéro ;
- toutes les unités sont validées ;
- les états crus/cuits ne sont pas confondus ;
- chaque mapping a un score ;
- la provenance est disponible au niveau de la valeur ;
- les licences sont enregistrées ;
- les anomalies sont exportées ;
- un rapport de couverture est produit ;
- la base est reproductible depuis les scripts d'ingestion.

---

## 16. Livrables

Obligatoires :

```text
nutrition_database.csv
component_dictionary.csv
nutrition_mapping_log.csv
nutrition_schema.md
nutrition_confidence_method.md
nutrition_coverage_report.md
qa_report.md
qa_anomalies.csv
ingestion_manifest.json
```

Le fichier demandé par l'application est :

`nutrition_database.csv`

Les autres fichiers sont nécessaires pour assurer sa fiabilité.
