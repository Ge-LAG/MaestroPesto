# Méthode de score de confiance — Phase 2

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Formule composite

```
confidence = w1*source_quality
           + w2*data_nature
           + w3*method_clarity
           + w4*sample_size_factor
           + w5*recency
           + w6*mapping_quality
```

avec :

| Composante | Échelle | Description | Poids |
|---|---|---|---|
| source_quality | 0.5–1.0 | CIQUAL/USDA analytique = 1.0 ; INFOODS annuaire = 0.7 ; autre = 0.6 | 0.30 |
| data_nature | 0.5–1.0 | `measured` = 1.0 ; `analytical_database` = 0.95 ; `calculated` = 0.7 ; `model_predicted` = 0.5 | 0.20 |
| method_clarity | 0.6–1.0 | Méthode analytique documentée = 1.0 ; non documentée = 0.6 | 0.15 |
| sample_size_factor | 0.6–1.0 | n≥10 = 1.0 ; 3≤n<10 = 0.8 ; n<3 ou non documenté = 0.6 | 0.10 |
| recency | 0.5–1.0 | <5 ans = 1.0 ; 5-10 ans = 0.85 ; 10-20 ans = 0.7 ; >20 ans = 0.5 | 0.10 |
| mapping_quality | 0.4–1.0 | match direct (espèce+état+forme) = 1.0 ; sémantique mais avec conflits = 0.6 | 0.15 |

Toutes les pondérations sont normalisées pour que la somme des poids = 1.0 et le score final ∈ [0, 1].

## Convention d'usage

- ≥ 0.90 : données primaires robustes ; usage fort autorisé.
- 0.75–0.89 : fiable mais imparfait ; usage normal.
- 0.50–0.74 : estimation ou extrapolation raisonnable ; signaler comme estimation.
- 0.25–0.49 : information faible ; à contextualiser fortement.
- < 0.25 : ne pas utiliser pour recommandation forte.

## Cas particuliers

- **Composants reconstitués (par différence)** : ex. `glucides totaux = 100 - eau - protéines - lipides - cendres - alcool`. Le confidence est minoré via `data_nature = calculated`.
- **Composants manquants dans la source** : qualifier = `NOT_REPORTED`, normalized_value vide.
- **Composants traces** : qualifier = `TRACE`, normalized_value = 0, confidence ≥ 0.5.
