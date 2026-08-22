# Méthode de confiance — Phase 4

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Formule composite (par règle)

```
rule_confidence = w1*evidence_quality
                + w2*literature_replication
                + w3*domain_coverage
                + w4*mechanism_clarity
```

avec :

| Composante | Plage | Description | Poids |
|---|---|---|---|
| evidence_quality | 0.5-1.0 | `expert_rule_with_literature` = 1.0 ; `measured` = 0.95 ; `calculated` = 0.7 ; `model_predicted` = 0.5 | 0.40 |
| literature_replication | 0.6-1.0 | Nombre d'études confirmant la règle | 0.25 |
| domain_coverage | 0.4-1.0 | % de la plage de paramètres explorée | 0.20 |
| mechanism_clarity | 0.6-1.0 | Mécanisme physique/chimique documenté | 0.15 |

## Convention

- ≥ 0.85 : règle solide, recommandation forte.
- 0.70–0.84 : fiable.
- 0.50–0.69 : à confirmer.
- 0.25–0.49 : utiliser avec prudence.
- < 0.25 : ne pas utiliser.

## Propagation aux prédictions

```
prediction_confidence = mean(rule_confidence for matching_rules)
                     * mapping_confidence_ingredient
                     * mapping_confidence_process
```

Si une règle est en `OUT_OF_DOMAIN`, sa `rule_confidence` est forcée à 0.10 (et marquée).
