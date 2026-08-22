# Rapport de couverture — Phase 1

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## 1. Totaux
- Lignes totales : **603**
- Ingrédients avec au moins une correspondance externe : **583** (96.7%)
- Sans correspondance externe : **20** (3.3%)
- Domaines couverts : **10** (préfixes ingredient_id)

## 2. Distribution par `category_level_1`
- végétal: 242
- animal: 103
- ingrédient technique: 100
- boisson: 73
- condiment: 39
- préparation: 16
- sous-produit culinaire: 9
- fungi: 7
- algue: 7
- ferment: 7

## 3. Distribution par `category_level_2` (top 25)
- légume: 45
- fruit: 40
- produit laitier: 38
- sauce fermentée: 27
- légumineuse: 26
- produit dérivé: 26
- sous-produit: 23
- fruit sec: 22
- épice: 21
- matière grasse: 18
- hydrocolloïde: 18
- spiritueux/liqueur: 18
- herbe aromatique: 16
- viande: 16
- sucre: 16
- soft/ingrédient cocktail: 16
- pâte/sauce: 16
- poisson: 15
- café/thé/infusion: 14
- vin/cidre: 13
- graine aromatique: 12
- sauce: 12
- céréale: 10
- abats: 9
- bouillon/fond: 9

## 4. Distribution par `category_level_3` (top 30)
- sauce fermentée: 27
- graine: 25
- spiritueux: 18
- feuille fraîche: 16
- pièce de viande: 16
- sucrant: 16
- légume-feuille: 15
- épice moulue: 15
- huile végétale: 15
- poisson entier: 14
- graine sèche: 13
- graine cuite: 13
- farine: 13
- flocons: 13
- boisson chaude: 13
- fruit tropical: 12
- sauce: 12
- fruit à coque: 11
- fruit à coque torréfié: 11
- lait: 11
- vin: 11
- baie: 10
- légume-bulbe: 10
- abats divers: 9
- bouillon: 9
- jus: 8
- agrume: 8
- mollusque: 8
- crème: 8
- bière: 8

## 5. Distribution par `processing_state`
- fresh: 180
- fermented: 77
- dried: 74
- processed: 64
- distilled: 27
- cooked: 23
- mixed: 16
- extracted: 15
- pasteurized: 14
- boiled: 13
- milled: 13
- rolled: 13
- roasted: 12
- pressed: 9
- ground: 9
- liquid: 8
- crystallized: 5
- brewed: 5
- concentrated: 4
- bottled: 4
- powder: 3
- emulsified: 3
- churned: 2
- separated: 2
- rendered: 2
- sieved: 1
- smoked: 1
- raw: 1
- UHT: 1
- clarified: 1
- instant: 1

## 6. Distribution par source
- MAESTRO_INTERNAL: 603
- FOODON: 583
- CIQUAL: 217
- USDAFDC: 144
- FOODEX2: 9
- LANGUAL: 1

## 7. Distribution par domaine (préfixe d'identifiant)
- ANIMAL: 34
- BEV: 73
- COND: 39
- DAIRY: 38
- FERMENT: 21
- FUNGUS: 7
- MARINE: 35
- MIX: 16
- PLANT: 204
- TECH: 136

## 8. Zones de faiblesse connues
- Fromages affinés : on a les grandes familles mais pas tous les AOP ;
  intentionnellement, ce sont des références de marque (voir excluded_items).
- Boissons asiatiques traditionnelles (boba/tapioca, lait de soja fermenté) : peu couvertes ; ajoutables en v1.1.
- Insectes comestibles : hors périmètre (réglementation UE stricte).
- Variétés botaniques fines (ex. 100 cultivars de pomme) : non fragmentées volontairement, elles sont gérées par le moteur comme variation d'une même identité générique.
- Sous-produits carnés (gelatine, saindoux) : présents ; certains abats rares absents.

## 9. Conformité politique de licence
- Sources NON approuvées pour ingestion : ['EUROFIR', 'FOODB']
- Toutes les autres sources (CIQUAL, USDA FoodData Central, FoodOn, FAO/INFOODS, PubChem, ChEBI, LanguaL, FoodEx2) sont sous licences compatibles (CC/Licence Ouverte / public domain) — voir DATA_SOURCE_REGISTER.csv.