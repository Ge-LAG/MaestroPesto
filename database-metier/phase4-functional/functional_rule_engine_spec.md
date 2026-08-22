# Spécification moteur de règles — Phase 4

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Vue d'ensemble

Le moteur de règles applique le jeu de données `interaction_rules.csv` à une formulation
donnée (composition + process sequence) pour prédire un comportement fonctionnel.

## Entrée

```json
{
  "ingredients": [
    {"ingredient_id": "...", "quantity_g": 100, "state": "..."}
  ],
  "process_sequence": [
    {"op_id": "...", "T_C": ..., "duration_min": ..., ...}
  ],
  "target_properties": [
    "viscosity", "gel_firmness", "stability", "color", "aroma"
  ]
}
```

## Algorithme (concept)

1. Résoudre les composants fonctionnels présents depuis `functional_ingredients.csv` × `functional_components.csv`.
2. Pour chaque règle applicable au set de composants :
   - Vérifier `ingredient_constraints`, `composition_constraints` (calculées depuis les masses).
   - Vérifier `process_constraints` (T, durée, ordre).
   - Vérifier `ph_min/max`, `aw_min/max`, `shear_constraints`.
   - Si tout matche, appliquer `predicted_effect` avec `effect_magnitude`.
3. Cumuler les effets avec gestion des conflits (ex. 2 règles contradictoires).
4. Calculer le score de confiance agrégé :
   - confiance règle * confiance mapping composant * confiance mapping process.
5. Identifier les situations `OUT_OF_DOMAIN` et baisser fortement le score.

## Sortie (concept)

```json
{
  "predictions": [
    {"property": "gel_firmness", "value": 1.2, "unit": "N", "confidence": 0.85, "rule_id": "..."}
  ],
  "risks": [
    {"type": "syneresis", "severity": "medium", "rule_id": "..."}
  ],
  "mechanisms": [
    {"ingredient_ids": [...], "mechanism": "...", "explanation": "..."}
  ],
  "suggested_adjustments": [
    {"action": "increase sugar", "expected_effect": "...", "rule_id": "..."}
  ],
  "confidence": 0.85,
  "out_of_domain": [],
  "evidence_refs": [...]
}
```

## Versionnement

- `score_method_version` dans `interaction_rules.csv` permet la coexistence de règles de
  versions différentes.
- Le moteur DOIT toujours préciser la version utilisée dans les sorties.

## Limites assumées (v1)

- Pas de ML : règles purement expertes + physico-chimiques documentées.
- Pas de simulation CFD : la cinétique est capturée par des modèles semi-empiriques.
- Pas de recommandation de sécurité alimentaire : une couche dédiée est prévue.
