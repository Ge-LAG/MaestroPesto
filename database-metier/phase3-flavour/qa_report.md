# Rapport QA — Phase 3

- dataset_version: 1.0.0
- generated_at: 2026-08-22

## 1. Contrôles
- Composés avec seuil olfactif nul : 0
- Composés avec weight < 100 : 6
- Ingrédients référencés dans la base mais absents du registre : 0
- Paires auto-référentielles : 0 (exclues par construction)
- Paires avec overall > 0.85 : 0

## 2. Conclusion
- Phase 3 fournie avec méthodes documentées.
- Pondérations initiales marquées comme calibrables.
- Tous les ingrédients utilisés existent dans `ingredient_registry_v1.csv`.