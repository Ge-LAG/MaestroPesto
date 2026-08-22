# MASTER ORCHESTRATION — Base de connaissance pour une application de formulation culinaire R&D

## 1. Finalité du projet

Le produit à construire n'est pas une simple application de recettes.

Il s'agit d'un **moteur de formulation culinaire orienté R&D** capable d'aider un utilisateur à concevoir, modifier, optimiser et expliquer une formulation alimentaire en raisonnant simultanément sur :

1. l'identité et la nature des matières premières / sous-produits ;
2. leur composition nutritionnelle ;
3. leurs profils gustatifs et aromatiques et leurs compatibilités ;
4. leur comportement fonctionnel et physico-chimique dans un mélange ;
5. les effets du procédé de transformation ;
6. l'incertitude et la provenance des données.

À terme, l'application doit pouvoir répondre à des questions du type :

- « Quels ingrédients peuvent apporter une note torréfiée sans augmenter fortement le sucre ? »
- « Que se passe-t-il si je remplace 30 % de la crème par une émulsion végétale ? »
- « Quels troisième et quatrième ingrédients renforcent cet accord sans masquer l'ingrédient principal ? »
- « Comment le pH, la température, le cisaillement et l'ordre d'incorporation vont-ils modifier la texture ? »
- « Comment reformuler cette sauce pour réduire le sodium tout en conservant viscosité, longueur aromatique et stabilité ? »

Le système devra **expliquer ses recommandations** et distinguer clairement :
- donnée mesurée ;
- donnée bibliographique ;
- donnée calculée ;
- règle experte ;
- prédiction ;
- donnée absente ou incertaine.

---

## 2. Architecture générale des données

Les quatre phases sont dépendantes.

```text
PHASE 1 — Référentiel maître des ingrédients
              │
              ├──────────────┐
              ▼              ▼
PHASE 2 — Nutrition     PHASE 3 — Saveur / arômes
              │              │
              └──────┬───────┘
                     ▼
PHASE 4 — Fonctionnel + physico-chimie + process
                     │
                     ▼
          Moteur de formulation R&D
```

### Règle fondamentale

Toutes les bases doivent utiliser le même identifiant canonique :

`ingredient_id`

Ne jamais utiliser le nom d'un aliment comme clé de jointure.

Exemple :

```text
ING-PLANT-TOMATO-000001
```

Les identifiants doivent être :
- stables ;
- non réutilisés ;
- indépendants d'une source externe ;
- associés aux identifiants de chaque source dans une table de correspondance.

---

## 3. Définition du périmètre « matière première / sous-produit »

### 3.1 Inclus

Inclure une entité lorsqu'elle peut raisonnablement être utilisée comme **intrant de formulation** dans une nouvelle recette.

Exemples :

- fruit, légume, céréale, viande, poisson, algue, champignon ;
- farine, amidon, semoule, flocon ;
- huile, graisse, beurre ;
- lait, crème, fromage générique ;
- jus, purée, concentré ;
- confiture, compote ;
- bouillon, fond, fumet ;
- vinaigre ;
- pâte fermentée ;
- miso, sauce soja et autres ingrédients fermentés génériques ;
- chocolat générique, cacao, pâte de cacao ;
- sirop, miel, mélasse ;
- extraits, hydrolats, eaux florales ;
- épices, herbes, aromates ;
- gélifiants, émulsifiants, épaississants et autres auxiliaires culinaires autorisés ;
- boissons génériques utilisées comme ingrédient ;
- vin, bière, cidre, spiritueux et liqueurs génériques nécessaires à la formulation de cocktails ou de recettes.

### 3.2 Exclus

Exclure :

- marques commerciales ;
- références SKU ;
- plats préparés de marque ;
- produits finis dont l'identité commerciale n'apporte rien au moteur de formulation ;
- menus / plats complets ;
- doublons purement marketing.

Exemples à exclure :

- Coca-Cola® ;
- Kinder Bueno® ;
- une pizza industrielle d'une marque donnée ;
- une soupe commerciale spécifique.

### 3.3 Exception importante

Un produit pouvant être consommé seul peut néanmoins être conservé s'il constitue aussi un **intrant culinaire générique utile**.

Exemple : vin rouge, bière stout, café espresso, chocolat noir, yaourt, moutarde, tahini.

Le critère n'est donc pas « peut-il être consommé seul ? », mais :

> « Est-ce une catégorie générique suffisamment stable et utile pour formuler un autre produit ? »

---

## 4. Modèle d'identité à conserver dès la Phase 1

Chaque entité doit pouvoir distinguer :

- espèce/source biologique ;
- partie utilisée ;
- variété/cultivar si pertinent ;
- état ;
- forme ;
- procédé déjà subi ;
- degré de transformation ;
- teneur ou concentration si elle définit réellement l'ingrédient ;
- origine géographique uniquement lorsqu'elle modifie substantiellement l'identité fonctionnelle/sensorielle.

Ne pas fusionner arbitrairement :

- tomate fraîche / tomate séchée ;
- lait entier / lait écrémé ;
- pomme crue / pomme cuite ;
- pois chiche sec / pois chiche cuit ;
- cacao / beurre de cacao ;
- crème liquide / crème épaisse.

---

## 5. Sources structurantes recommandées

### Référentiels / classification

- FoodOn — https://foodon.org/
- LanguaL — https://www.langual.org/
- EFSA FoodEx2 — https://www.efsa.europa.eu/en/data/data-standardisation

FoodOn fournit notamment une ontologie alimentaire et des notions de source biologique, produit, transformation et processus. LanguaL et FoodEx2 peuvent servir de références de classification.

### Nutrition

- ANSES-CIQUAL 2025 — https://ciqual.anses.fr/
- USDA FoodData Central — https://fdc.nal.usda.gov/
- FAO/INFOODS — https://www.fao.org/food-composition/
- EuroFIR FoodEXplorer — https://www.eurofir.org/our-tools/foodexplorer/ lorsque la licence le permet.

### Arômes / chimie alimentaire

- FlavorDB2 — https://cosylab.iiitd.edu.in/flavordb2/
- FooDB — https://foodb.ca/
- PubChem — https://pubchem.ncbi.nlm.nih.gov/
- ChEBI — https://www.ebi.ac.uk/chebi/
- littérature scientifique primaire.

### Attention aux licences

Aucune source ne doit être copiée massivement avant vérification de :
- licence ;
- droits de redistribution ;
- droits d'utilisation commerciale ;
- conditions d'attribution ;
- éventuelles limitations contractuelles.

Exemple : FooDB indique qu'une réutilisation commerciale de ses données requiert une autorisation explicite. EuroFIR peut également imposer des conditions spécifiques selon la base nationale.

Créer obligatoirement :

`DATA_SOURCE_REGISTER.csv`

avec au minimum :

```text
source_id
source_name
source_url
version
retrieval_date
license_name
license_url
commercial_use
redistribution_allowed
attribution_required
notes
approved_for_ingestion
```

Aucune donnée dont `approved_for_ingestion != true` ne doit être intégrée au corpus de production.

---

## 6. Doctrine de qualité des données

### 6.1 Ne jamais halluciner une donnée

Une valeur absente doit rester absente.

Utiliser explicitement :
- `null`
- `unknown`
- `not_reported`
- `trace`
- `estimated`

selon le schéma défini.

### 6.2 Conserver la provenance au niveau de la donnée

Toute valeur importante doit pouvoir être reliée à :
- sa source ;
- sa version ;
- son identifiant d'origine ;
- sa méthode ;
- sa date ;
- éventuellement sa publication scientifique.

### 6.3 Ne pas écraser les contradictions

Deux sources peuvent donner des valeurs différentes sans que l'une soit fausse.

Conserver les valeurs sources puis créer, si nécessaire, une valeur harmonisée avec :
- méthode d'agrégation ;
- justification ;
- score de confiance.

### 6.4 Séparer observation et inférence

Champ obligatoire :

`evidence_type`

Valeurs minimales :

```text
measured
analytical_database
literature
expert_rule
calculated
model_predicted
culinary_observation
unknown
```

---

## 7. Scores de confiance

Utiliser une échelle normalisée `[0,1]`.

Exemple de convention :

- `0.90–1.00` : donnée primaire robuste / mesure bien documentée ;
- `0.75–0.89` : donnée fiable mais contexte imparfait ;
- `0.50–0.74` : estimation ou extrapolation raisonnable ;
- `0.25–0.49` : information faible, indirecte ou très contextuelle ;
- `<0.25` : ne pas utiliser pour une recommandation forte.

Tout score doit être reproductible et documenté.

---

## 8. Gestion des versions

Tous les livrables doivent être versionnés.

Exemple :

```text
dataset_version: 1.0.0
schema_version: 1.0.0
generated_at: 2026-08-22
```

Ne jamais modifier silencieusement une version publiée.

Produire un `CHANGELOG.md`.

---

## 9. Contrôles automatisés communs

Créer une suite de validation exécutée avant chaque livraison.

Contrôles minimaux :

- unicité des identifiants ;
- clés étrangères valides ;
- absence de marque commerciale non autorisée ;
- absence de doublons sémantiques évidents ;
- unités reconnues ;
- valeurs numériques plausibles ;
- provenance présente ;
- licences validées ;
- encodage UTF-8 ;
- séparateur CSV documenté ;
- schéma respecté ;
- taux de champs manquants calculé ;
- anomalies exportées.

Livrables QA :

```text
qa_report.md
qa_anomalies.csv
coverage_report.csv
```

---

## 10. Ordre impératif d'exécution

1. Exécuter `01_PHASE_INGREDIENT_REGISTRY.md`.
2. Faire valider le référentiel et le geler en version `v1`.
3. Exécuter `02_PHASE_NUTRITION_DATABASE.md`.
4. Exécuter `03_PHASE_FLAVOR_AROMA_DATABASE.md`.
5. Exécuter `04_PHASE_FUNCTIONAL_PROCESS_DATABASE.md`.
6. Réaliser une validation croisée des trois bases.
7. Ne développer le moteur de recommandation final qu'après stabilisation des schémas.

---

## 11. Philosophie de l'« exhaustivité »

Dans ce projet, « exhaustif » signifie :

> couverture maximale démontrable du périmètre défini, avec mesure de couverture, provenance et procédure reproductible d'extension.

Ne jamais prétendre posséder « tous les aliments du monde » ou « tous les accords possibles ».

L'exhaustivité doit être mesurée par :
- catégories couvertes ;
- sources couvertes ;
- géographies ;
- nombre d'ingrédients ;
- nombre de synonymes ;
- taux d'appariement aux sources ;
- composés / nutriments couverts ;
- zones manquantes connues.

Cette définition rend la base scientifique, maintenable et extensible.
