# Schéma — Phase 4 (fonctionnel & process)

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## Tables

### `functional_components.csv`
Ontologie des composants fonctionnels (protéines, polysaccharides, lipides, petites molécules).

### `functional_ingredients.csv`
Propriétés intrinsèques d'un ingrédient dans un état donné. Format : un ingrédient peut avoir
plusieurs lignes (une par état).

### `process_operations.csv`
Catalogue des opérations unitaires applicables.

### `interaction_rules.csv`
Règles physico-chimiques avec domaine d'application, conditions opératoires et sorties.

### `experimental_validation_cases.csv`
Cas expérimentaux servant à tester et calibrer les règles.

## Conventions

- Une règle a **toujours** un `applicability_domain`. Si le système sort du domaine,
  statut `OUT_OF_DOMAIN` et confiance fortement réduite.
- L'ordre d'incorporation est représenté par `order_constraints`.
- Les unités sont explicites (g, mg, %, etc.).
- Les valeurs manquantes restent vides (jamais '0' pour 'inconnu').

## Validations QA

- Au moins 1 référence par règle (`source_refs` non vide).
- `confidence` dans [0, 1].
- Pas d'extrapolation cachée : champ `extrapolation_allowed`.
- Composants référencés doivent exister dans `functional_components.csv`.
