# Méthode de scoring — Phase 3 (compatibilité sensorielle)

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Vue d'ensemble

Le score de compatibilité sensorielle pour une combinaison d'ingrédients
`C = {i1, i2, ..., in}` est une combinaison pondérée de cinq dimensions :

```
score(C) =
  + w1 * pair_quality          # qualité moyenne des paires
  + w2 * sensory_balance        # équilibre gustatif
  + w3 * aromatic_bridge        # couverture familles aromatiques
  + w4 * empirical_support      # preuves empiriques (recettes, tradition)
  + w5 * contextual_fit         # cohérence du contexte culinaire
  - w6 * dominance              # pénalité si un ingrédient écrase
  - w7 * masking                # pénalité si masquage
  - w8 * uncertainty            # pénalité d'incertitude globale
```

Poids initiaux (v1) :

| poids | valeur | justification |
|---|---|---|
| w1 | 0.25 | les paires restent la base |
| w2 | 0.15 | équilibre important pour éviter monotonie |
| w3 | 0.10 | pont aromatique : permet de gérer 3-5 ingrédients |
| w4 | 0.20 | accord empirique : fort indice |
| w5 | 0.10 | contexte (sucré vs salé vs cocktail) |
| w6 | 0.08 | dominance |
| w7 | 0.07 | masquage |
| w8 | 0.05 | incertitude |

Score final ∈ [0, 1]. Convention :
- ≥ 0.85 : excellent accord, recommandé
- 0.70–0.84 : bon accord
- 0.55–0.69 : accord moyen
- 0.40–0.54 : accord discutable
- < 0.40 : éviter

## Composantes

### pair_quality(C)

Moyenne des scores binaires sur les paires de C, pondérée par le score de
mapping (mapping_confidence) et la distance Jaccard sur composés aromatiques.

### sensory_balance(C)

Couverture de 5 dimensions sensorielles cibles : sweet / sour / salty / bitter /
umami. Pénalité si une seule dimension dépasse 90% de l'intensité moyenne ou
si une dimension manque complètement.

### aromatic_bridge(C)

Présence d'un ou plusieurs "ponts aromatiques" : ingrédients qui partagent
des descripteurs avec au moins 2 autres membres de C, ce qui favorise
l'harmonie. Calcul : pour chaque descripteur d, compter combien d'ingrédients
de C le possèdent fortement (≥ 0.7). Le score = (nb descripteurs partagés par
≥ 2 ingrédients) / (nb total de descripteurs distincts dans C).

### empirical_support(C)

Présence dans `pairwise_flavor_evidence.csv` ou `higher_order_flavor_evidence.csv`
de la combinaison (matching exact ou partiel). Score = max(support_observé).

### contextual_fit(C)

Cohérence avec le contexte culinaire déclaré (`savory`, `sweet`, `beverage`,
`cocktail`, `bakery`, `sauce`, `fermented`, etc.). Pour la v1, heuristique :
si tous les ingrédients sont typiques du contexte → 1.0 ; si 1 ingrédient
hors contexte → 0.6 ; si plusieurs → pénalité supplémentaire.

### dominance_risk(C)

Si un seul ingrédient dépasse 90% du profil aromatique global (somme des
descripteurs), pénalité proportionnelle à son score et à sa fréquence.

### masking_risk(C)

Si deux ingrédients partagent un descripteur dominant avec des intensités
très proches (risque de redondance) OU si l'un contient un composé masquant
les arômes de l'autre (ex. capsaïcine > 50 mg/100g dans une combinaison
délicate), pénalité.

### uncertainty(C)

`1 - mean(mapping_confidence)`. Plus le mapping est incertain, plus la
pénalité est forte.

## Pondération non-arbitraire

Les poids initiaux ont été choisis comme compromis raisonnable, **mais ils
sont marqués comme calibrables**. La calibration future utilisera :

- panels sensoriels (scores moyens sur 9 points)
- préférences utilisateurs agrégées
- benchmarks culinaires de référence
- ablation studies

## Versions

| version | date | changements |
|---|---|---|
| 1.0.0 | 2026-08-22 | Pondérations initiales, calcul sans ML. |

## Pondération et usage

Les pondérations NE sont PAS scientifiques : ce sont des heuristiques
transparentes. Toute recommandation du moteur doit être accompagnée :
- du niveau de confiance
- des preuves empiriques (recettes, études)
- de l'avertissement que le score est indicatif, pas une vérité universelle
