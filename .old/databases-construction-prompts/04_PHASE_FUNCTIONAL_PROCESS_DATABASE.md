# PHASE 4 — Base fonctionnelle, physico-chimique et comportement des mélanges selon le process

## Mission de l'agent

Construire la couche de connaissance permettant d'estimer **comment un mélange va se comporter** en fonction :

- des ingrédients ;
- de leurs proportions ;
- de leur état ;
- des interactions entre composants ;
- du procédé ;
- de l'ordre des opérations ;
- des conditions de transformation.

Cette phase est le cœur du caractère R&D de l'application.

---

## 1. Principe

La propriété d'un produit final n'est généralement pas la somme simple des propriétés de ses ingrédients.

Exemple :

```text
résultat final ≠ propriété(A) + propriété(B) + propriété(C)
```

Le moteur doit représenter des interactions non linéaires telles que :
- gélification ;
- émulsification ;
- dénaturation ;
- coagulation ;
- cristallisation ;
- rétrogradation ;
- synerèse ;
- foisonnement ;
- dissolution ;
- précipitation ;
- complexation ;
- réactions de brunissement ;
- extraction ;
- volatilisation ;
- fermentation.

Le procédé doit être un **objet de première classe** du modèle.

---

## 2. Architecture recommandée

Ne pas chercher à représenter cette phase par un seul tableau plat.

Construire au minimum cinq ensembles de données :

```text
functional_ingredient_properties.csv
functional_components.csv
process_operations.csv
interaction_rules.csv
experimental_validation_cases.csv
```

Puis exposer une vue applicative calculée.

Une base relationnelle ou un graphe de connaissances est préférable au stockage exclusif en CSV.

Les CSV servent de format d'échange et d'audit.

---

## 3. Propriétés intrinsèques des ingrédients

Créer :

`functional_ingredient_properties.csv`

Colonnes minimales :

```text
ingredient_id
ingredient_state_id
temperature_reference
water_content
fat_content
protein_content
starch_content
sugar_content
fiber_content
pectin_content
alcohol_content
salt_content
mineral_content
ph
titratable_acidity
water_activity
brix
density
particle_size
solubility
oil_holding_capacity
water_holding_capacity
emulsifying_capacity
foaming_capacity
gelation_capability
thickening_capability
hygroscopicity
thermal_stability
freeze_thaw_stability
oxidation_sensitivity
source_refs
evidence_type
confidence
validity_conditions
```

Ne remplir que ce qui est supporté.

---

## 4. Composants fonctionnels

Le comportement peut dépendre davantage des composants que du nom de l'ingrédient.

Créer :

`functional_components.csv`

Types à couvrir :

### Protéines
- caséines ;
- protéines sériques ;
- ovalbumine ;
- protéines de soja ;
- protéines de pois ;
- gluten ;
- collagène / gélatine ;
- autres protéines pertinentes.

### Polysaccharides / glucides structurants
- amidon ;
- amylose ;
- amylopectine ;
- pectines ;
- cellulose ;
- hémicelluloses ;
- bêta-glucanes ;
- inuline ;
- carraghénanes ;
- alginates ;
- agar ;
- xanthane ;
- guar ;
- gomme arabique ;
- autres hydrocolloïdes.

### Lipides
- triglycérides ;
- profils de saturation ;
- phospholipides ;
- mono-/diglycérides lorsque pertinents ;
- cristallisation des matières grasses.

### Petites molécules
- sucres ;
- sels ;
- acides ;
- alcool ;
- composés phénoliques ;
- tensioactifs alimentaires ;
- minéraux / ions pertinents.

---

## 5. Processus à représenter

Créer :

`process_operations.csv`

Chaque étape doit pouvoir porter des paramètres.

### Thermiques
- chauffer ;
- cuire ;
- bouillir ;
- frémir ;
- pocher ;
- vapeur ;
- rôtir ;
- griller ;
- frire ;
- torréfier ;
- pasteuriser ;
- stériliser ;
- refroidir ;
- congeler ;
- décongeler.

### Mécaniques
- mélanger ;
- fouetter ;
- homogénéiser ;
- cisailler ;
- pétrir ;
- broyer ;
- mixer ;
- presser ;
- filtrer ;
- centrifuger.

### Transferts / séparation
- infuser ;
- extraire ;
- macérer ;
- réduire ;
- évaporer ;
- déshydrater ;
- égoutter ;
- décanter.

### Biochimiques
- fermenter ;
- faire lever ;
- maturer ;
- enzymatiser ;
- acidifier.

### Paramètres minimaux

```text
process_id
process_name
temperature
temperature_profile
duration
pressure
shear_rate
mixing_speed
energy_input
cooling_rate
heating_rate
target_ph
target_aw
target_brix
particle_size_target
oxygen_exposure
atmosphere
order_index
addition_mode
rest_time
notes
```

Tous les paramètres ne s'appliquent pas à chaque opération.

---

## 6. L'ordre d'incorporation est obligatoire

Le moteur doit distinguer :

```text
huile -> eau -> émulsifiant
```

de :

```text
eau -> émulsifiant -> huile progressive
```

lorsque l'ordre est fonctionnellement pertinent.

Ne jamais réduire une recette à une simple liste `{ingrédient, quantité}`.

Le modèle d'entrée doit contenir une **séquence de process**.

---

## 7. Interactions et règles

Créer :

`interaction_rules.csv`

Une règle doit être bornée à un domaine d'application.

Schéma :

```text
rule_id
rule_family
reactant_or_component_ids
ingredient_constraints
composition_constraints
process_constraints
ph_min
ph_max
temperature_min
temperature_max
time_min
time_max
water_activity_min
water_activity_max
shear_constraints
order_constraints
predicted_effect
effect_direction
effect_magnitude
output_property
equation_or_logic
source_refs
evidence_type
confidence
extrapolation_allowed
notes
```

---

## 8. Familles de phénomènes à couvrir

### Eau / activité de l'eau
- dilution ;
- concentration ;
- liaison de l'eau ;
- hygroscopicité ;
- migration ;
- synerèse.

### Émulsions
- rapport phase aqueuse / huileuse ;
- type d'émulsifiant ;
- taille de gouttelettes ;
- cisaillement ;
- température ;
- sel ;
- pH ;
- stabilité.

### Mousses
- protéines ;
- tensioactifs ;
- lipides perturbateurs ;
- viscosité ;
- gaz incorporé ;
- stabilité.

### Gels
- gélatine ;
- pectine ;
- amidon ;
- agar ;
- carraghénanes ;
- alginates ;
- protéines ;
- ions ;
- pH ;
- sucre ;
- température.

### Amidon
- hydratation ;
- gélatinisation ;
- gonflement ;
- cisaillement ;
- dextrinisation ;
- rétrogradation.

### Protéines
- hydratation ;
- dénaturation ;
- coagulation ;
- agrégation ;
- solubilité ;
- effet du pH ;
- force ionique ;
- interactions protéines-polysaccharides.

### Sucres
- dissolution ;
- concentration ;
- cristallisation ;
- inversion ;
- caramélisation ;
- vitrification.

### Lipides
- fusion ;
- polymorphisme ;
- cristallisation ;
- oxydation ;
- plasticité.

### Réactions thermiques / aromatiques
- réaction de Maillard ;
- caramélisation ;
- pyrolyse ;
- volatilisation ;
- extraction d'arômes.

### Acides / bases / ions
- tamponnage ;
- coagulation acide ;
- pectines ;
- alginates ;
- solubilité des protéines ;
- perception sensorielle.

### Fermentation
- substrat ;
- micro-organisme/culture ;
- température ;
- durée ;
- pH ;
- oxygène ;
- produits de fermentation.

---

## 9. Variables de sortie

Le moteur doit pouvoir représenter, lorsque les données le permettent :

### Structure / texture
- viscosité ;
- comportement newtonien/non newtonien ;
- indice d'écoulement ;
- consistance ;
- contrainte seuil ;
- fermeté ;
- élasticité ;
- cohésion ;
- adhésivité ;
- friabilité ;
- croquant ;
- onctuosité ;
- taille particulaire.

### Stabilité
- séparation de phases ;
- crémage ;
- coalescence ;
- sédimentation ;
- synerèse ;
- stabilité thermique ;
- stabilité au froid ;
- stabilité freeze-thaw.

### Chimie
- pH ;
- acidité titrable ;
- activité de l'eau ;
- °Brix ;
- matière sèche ;
- densité.

### Optique
- couleur ;
- brunissement ;
- opacité ;
- turbidité.

### Sensoriel indirect
- libération aromatique ;
- rétention aromatique ;
- perception de gras ;
- perception de sucrosité/acide lorsque les règles sont suffisamment supportées.

---

## 10. Modélisation des mélanges

Le moteur doit combiner plusieurs niveaux.

### Niveau 1 — Bilans physiques simples

Exemples :
- masse totale ;
- fraction massique ;
- estimation de teneur en eau ;
- teneur en solides ;
- alcool ;
- sel ;
- sucre.

### Niveau 2 — Lois / modèles physico-chimiques documentés

Lorsque disponibles.

### Niveau 3 — Règles expertes

Exemple :

```text
IF pectin_type = HM
AND pH in valid_range
AND soluble_solids >= threshold
THEN gelation_probability increases
```

Les seuils réels doivent venir de sources, pas de cet exemple.

### Niveau 4 — Modèles empiriques

Régressions / modèles ML uniquement avec dataset et validation.

### Niveau 5 — Incertitude

Toute sortie doit inclure :

```text
predicted_value
prediction_interval
confidence
reasoning_trace
applicability_domain
```

---

## 11. Ne pas extrapoler silencieusement

Une règle validée entre 60 et 90 °C ne doit pas être appliquée à 140 °C sans avertissement.

Champ obligatoire :

`applicability_domain`

Si le système sort du domaine :

```text
status = OUT_OF_DOMAIN
```

et baisse fortement le score de confiance.

---

## 12. Source des connaissances

L'agent doit effectuer une recherche structurée par phénomène dans :

- articles scientifiques ;
- revues systématiques ;
- ouvrages de science alimentaire ;
- publications universitaires ;
- données techniques publiques de fournisseurs lorsque clairement identifiées comme telles ;
- normes et documents réglementaires pertinents ;
- bases physico-chimiques ;
- FoodOn pour les processus et concepts ;
- données expérimentales internes futures.

Chaque règle doit conserver ses références.

Une affirmation de type « X stabilise Y » sans contexte, plage de concentration ou référence n'est pas acceptable comme règle de production.

---

## 13. Données expérimentales

Créer :

`experimental_validation_cases.csv`

Schéma :

```text
case_id
formulation_id
ingredient_ids
quantities
units
process_sequence
measured_inputs
measured_outputs
measurement_methods
source
replicates
temperature
ph
aw
notes
```

Ces cas serviront :
- à tester les règles ;
- à calibrer les modèles ;
- à détecter les régressions.

---

## 14. Cas de validation minimum

Préparer des cas couvrant différentes familles :

- mayonnaise / émulsion ;
- vinaigrette instable ;
- crème / sauce épaissie ;
- gel pectine ;
- gel gélatine ;
- amidon gélatinisé ;
- meringue / mousse protéique ;
- pâte à pain ;
- caramel ;
- chocolat / cristallisation ;
- confiture ;
- glace / sorbet ;
- boisson acidifiée ;
- cocktail dilué ;
- fermentation simple.

Ne pas encoder le résultat attendu sans source ou mesure.

---

## 15. Sécurité alimentaire

Cette base peut fournir des **indicateurs** liés à :
- pH ;
- activité de l'eau ;
- temps/température ;
- alcool ;
- conservation.

Cependant :

> ne jamais déclarer un produit « microbiologiquement sûr » uniquement à partir d'une prédiction physico-chimique non validée.

Prévoir ultérieurement une couche dédiée de sécurité alimentaire et réglementation.

---

## 16. Vue applicative

Créer une API ou fonction conceptuelle :

```text
predict_mix(formulation, process_sequence, target_properties)
```

Sortie :

```json
{
  "predictions": [],
  "risks": [],
  "mechanisms": [],
  "suggested_adjustments": [],
  "confidence": 0.0,
  "out_of_domain": [],
  "evidence_refs": []
}
```

Chaque mécanisme doit être explicable.

---

## 17. Critères d'acceptation

La phase n'est pas validée si :
- le procédé n'est pas représenté ;
- l'ordre d'incorporation est perdu ;
- les interactions sont purement additives ;
- les règles n'ont pas de domaine d'application ;
- des extrapolations sont silencieuses ;
- les sources sont absentes ;
- observation et prédiction sont confondues ;
- le moteur ne fournit aucun score de confiance ;
- aucun cas expérimental de validation n'existe.

---

## 18. Livrables

```text
functional_ingredient_properties.csv
functional_components.csv
process_operations.csv
interaction_rules.csv
experimental_validation_cases.csv
functional_schema.md
functional_rule_engine_spec.md
functional_confidence_method.md
functional_coverage_report.md
qa_report.md
qa_anomalies.csv
ingestion_manifest.json
```

Recommandé pour l'application :

- stockage relationnel pour les données structurées ;
- graphe ou tables de relations pour les interactions ;
- moteur de règles versionné ;
- cache de prédictions ;
- CSV comme format d'échange/audit, et non comme seul format d'exécution.
