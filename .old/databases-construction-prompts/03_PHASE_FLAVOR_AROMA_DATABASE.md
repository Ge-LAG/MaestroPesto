# PHASE 3 — Base de compatibilité saveurs / arômes et interactions multi-ingrédients

## Mission de l'agent

Construire une base permettant au moteur de formulation R&D d'estimer, expliquer et comparer la compatibilité sensorielle de **2 à 5 ingrédients**, sans réduire le problème à une simple correspondance de molécules aromatiques.

Le référentiel `ingredient_registry_v1.csv` est obligatoire.

---

## 1. Principe scientifique

Un accord culinaire dépend de plusieurs dimensions :

- arômes volatils ;
- saveurs gustatives ;
- intensité ;
- seuils de perception ;
- concentration ;
- matrice alimentaire ;
- température ;
- texture et libération aromatique ;
- transformation ;
- culture culinaire ;
- fréquence d'association observée ;
- contraste ;
- complémentarité ;
- masquage ;
- dominance ;
- synergies et antagonismes.

La présence de composés volatils communs est un signal utile, **mais ne doit jamais être utilisée comme vérité universelle de compatibilité**.

---

## 2. Correction fondamentale : ne pas énumérer toutes les combinaisons

Si le référentiel contient des milliers d'ingrédients, matérialiser toutes les combinaisons de 3, 4 ou 5 ingrédients devient rapidement irréaliste.

La base doit donc être constituée de :

1. **faits élémentaires** ingrédient ↔ composé ↔ descripteur ;
2. **interactions binaires documentées** ;
3. **hyper-interactions explicites** pour des combinaisons de 3–5 ingrédients lorsqu'elles sont réellement observées / documentées ;
4. **un modèle de calcul** capable d'évaluer à la demande une nouvelle combinaison de 3–5 ingrédients.

L'« exhaustivité » porte sur les faits et la capacité de calcul, pas sur la pré-génération de toutes les permutations.

---

## 3. Sources candidates

### Données moléculaires / aromatiques

- FlavorDB2 — https://cosylab.iiitd.edu.in/flavordb2/
- FooDB — https://foodb.ca/
- PubChem — https://pubchem.ncbi.nlm.nih.gov/
- ChEBI — https://www.ebi.ac.uk/chebi/
- littérature scientifique primaire ;
- articles de GC-MS / GC-O ;
- données de seuils olfactifs/gustatifs légalement réutilisables.

### Données culinaires

Utiliser des corpus de recettes ou études scientifiques uniquement lorsque leur licence autorise l'usage envisagé.

### Contrôle de licence impératif

FooDB indique notamment que la réutilisation commerciale de données nécessite une permission explicite.

Ne jamais aspirer ni redistribuer une source sans validation du registre de licences.

---

## 4. Ontologie sensorielle

Construire un vocabulaire contrôlé.

### Goûts de base et sensations

Au minimum :

```text
sweet
sour
salty
bitter
umami
fatty
astringent
pungent
cooling
warming
metallic
kokumi
```

Ne pas traiter toutes ces sensations comme des « goûts fondamentaux » au sens physiologique ; elles constituent ici des dimensions sensorielles utiles au moteur.

### Familles d'odeurs

Exemples :

```text
fruity
citrus
green
herbal
floral
woody
earthy
mushroom
nutty
roasted
toasted
caramel
smoky
spicy
peppery
sulfurous
meaty
marine
dairy
fermented
solvent
medicinal
resinous
vanillic
cocoa
coffee
```

Construire une hiérarchie et des synonymes plutôt qu'une simple liste plate.

---

## 5. Modèle des composés aromatiques

Créer en interne :

`aroma_compounds.csv`

Colonnes minimales :

```text
compound_id
canonical_name
cas_number
pubchem_cid
chebi_id
molecular_formula
molecular_weight
logp
vapor_pressure
boiling_point
functional_groups
odor_descriptors
taste_descriptors
odor_threshold
threshold_unit
threshold_matrix
source_refs
license_source
confidence
```

Ne pas inventer les propriétés manquantes.

---

## 6. Association ingrédient ↔ composé

Créer :

`ingredient_aroma_compounds.csv`

```text
ingredient_id
ingredient_state_id
compound_id
presence_status
concentration
concentration_unit
concentration_min
concentration_max
analytical_method
matrix
process_state
source_ref
evidence_type
confidence
```

`presence_status` :

```text
QUANTIFIED
DETECTED
REPORTED
PREDICTED
UNKNOWN
```

Une donnée « predicted » ne doit jamais être présentée comme une mesure.

---

## 7. Pondération perceptive

Le simple nombre de molécules partagées est insuffisant.

Lorsque les données existent, pondérer selon :
- concentration ;
- seuil olfactif ;
- seuil gustatif ;
- volatilité ;
- matrice ;
- température ;
- état de l'ingrédient.

Créer un indicateur proche d'une notion d'activité odorante lorsqu'elle est calculable, sans l'inventer lorsqu'un seuil ou une concentration manque.

---

## 8. Interactions binaires

Créer :

`pairwise_flavor_evidence.csv`

Colonnes :

```text
pair_id
ingredient_a_id
ingredient_b_id
context
process_context
shared_compound_score
threshold_weighted_similarity
aroma_complement_score
aroma_contrast_score
taste_balance_score
dominance_risk
masking_risk
culinary_cooccurrence_score
cross_cuisine_support
sensory_study_score
literature_support
overall_pair_score
score_method_version
confidence
evidence_refs
explanation
```

Les composantes absentes restent `null`.

---

## 9. Interactions d'ordre supérieur

Créer :

`higher_order_flavor_evidence.csv`

pour les interactions observées/documentées de 3 à 5 ingrédients.

```text
interaction_id
combination_size
ingredient_ids
context
process_context
observed_or_predicted
synergy_score
antagonism_score
dominance_score
balance_score
novelty_score
overall_score
confidence
evidence_refs
model_version
explanation
```

`ingredient_ids` est une liste canonique triée et déterministe.

---

## 10. Modèle multi-ingrédients

Pour une combinaison `C = {i1, i2, ... in}`, calculer au minimum :

1. qualité moyenne des interactions binaires ;
2. interaction la plus faible ;
3. risque de dominance ;
4. couverture des familles aromatiques ;
5. équilibre gustatif ;
6. redondance ;
7. contraste ;
8. cohérence contextuelle ;
9. influence du process ;
10. preuves empiriques ;
11. pénalité d'incertitude.

Exemple conceptuel :

```text
score(C) =
  w1 * pair_compatibility
+ w2 * sensory_balance
+ w3 * aromatic_bridge
+ w4 * empirical_support
+ w5 * contextual_fit
+ w6 * novelty
- w7 * dominance
- w8 * masking
- w9 * uncertainty
```

Les poids ne doivent pas être choisis arbitrairement puis présentés comme scientifiques.

Versionner les poids et prévoir leur calibration future avec :
- panels sensoriels ;
- préférences utilisateurs ;
- données expérimentales ;
- benchmark expert.

---

## 11. Notion de « pont aromatique »

Identifier lorsqu'un ingrédient C peut faciliter l'accord A+B.

Exemple logique :

```text
A partage certains descripteurs avec C
B partage d'autres descripteurs avec C
C possède une intensité compatible
=> C peut agir comme aromatic_bridge
```

Cette propriété est particulièrement importante pour les combinaisons de 3 à 5 ingrédients.

Créer dans les explications :

```text
bridge_ingredients
bridge_descriptors
bridge_compounds
```

---

## 12. Process et arômes

L'état de transformation doit être intégré.

Exemples :
- cru ;
- rôti ;
- grillé ;
- torréfié ;
- fermenté ;
- fumé ;
- caramélisé ;
- réduit ;
- infusé.

Ne pas considérer « oignon cru » et « oignon caramélisé » comme sensoriellement identiques.

---

## 13. Contexte culinaire

Un score doit pouvoir être contextualisé :

```text
savory
sweet
beverage
cocktail
bakery
sauce
fermented
cold
hot
raw
cooked
```

Ajouter si pertinent :
- cuisine / région ;
- rôle de l'ingrédient ;
- intensité cible.

Une association fréquente historiquement ne doit pas être confondue avec une nécessité chimique.

---

## 14. Fichier CSV demandé

Créer un export principal unique :

`flavor_compatibility.csv`

Format long :

```text
record_id
combination_size
ingredient_ids
ingredient_names
context
process_context
observed_or_predicted
aroma_similarity
aroma_complement
aroma_contrast
taste_balance
culinary_support
sensory_support
dominance_risk
masking_risk
novelty_score
overall_score
confidence
key_compounds
key_descriptors
bridge_ingredients
evidence_refs
model_version
explanation
```

Ce fichier doit contenir :
- les interactions binaires validées ;
- les hyper-interactions observées ;
- éventuellement un sous-ensemble de prédictions pré-calculées de haute valeur.

**Ne pas tenter d'y stocker toutes les combinaisons possibles de 3–5 ingrédients.**

Le moteur applicatif doit calculer les nouvelles combinaisons à la demande.

---

## 15. Tests de qualité

### Tests structuraux
- IDs valides ;
- aucune auto-paire ;
- ordre canonique des IDs ;
- absence de doublons ;
- scores dans leur domaine ;
- sources présentes.

### Tests scientifiques
- ne pas confondre présence et concentration ;
- ne pas confondre molécule commune et accord garanti ;
- ne pas traiter une prédiction comme observation ;
- vérifier les unités de seuil ;
- vérifier la matrice du seuil ;
- distinguer cru/cuit.

### Tests culinaires

Créer un benchmark interne :
- accords classiques reconnus ;
- contrastes connus ;
- accords difficiles ;
- combinaisons multi-ingrédients ;
- cas où un ingrédient-pont améliore le résultat.

Ne pas forcer le modèle à « valider la tradition » : utiliser ces cas comme tests, pas comme vérité absolue.

---

## 16. Critères d'acceptation

- toute recommandation est explicable ;
- tout score indique son niveau de confiance ;
- l'état/process est représentable ;
- les interactions 3–5 sont possibles ;
- le système ne repose pas uniquement sur les molécules partagées ;
- les preuves empiriques et moléculaires sont séparées ;
- les données de licence sont validées ;
- un benchmark reproductible est livré ;
- aucune prédiction n'est présentée comme mesure.

---

## 17. Livrables

```text
flavor_compatibility.csv
aroma_compounds.csv
ingredient_aroma_compounds.csv
pairwise_flavor_evidence.csv
higher_order_flavor_evidence.csv
sensory_descriptor_ontology.csv
flavor_scoring_method.md
flavor_benchmark.csv
flavor_coverage_report.md
qa_report.md
ingestion_manifest.json
```

Le livrable public demandé est `flavor_compatibility.csv`; les autres fichiers constituent la base normalisée nécessaire à sa construction et à sa maintenance.
