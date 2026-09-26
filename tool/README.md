# Chaîne d'enrichissement des données

`database-metier/` est une source gelée : tout enrichissement passe par les
générateurs de `tool/` et atterrit dans `assets/database-enrichment/`,
importé au démarrage de l'application (import sauté si les fichiers n'ont
pas changé). Chaque valeur produite cite sa source ; la page « Sources des
données » de l'application en donne la liste et les licences.

## Régénérer

```bash
bash tool/fetch_open_sources.sh                 # jeux ouverts → tool/.cache/
dart run tool/generate_ciqual_enrichment.dart    # Ciqual 2025 (dossier ciqual/)
dart run tool/generate_usda_enrichment.dart      # USDA FDC + composition calculée
dart run tool/generate_allergen_enrichment.dart  # allergènes (annexe II UE)
dart run tool/generate_corpus_pairings.dart      # accords Escoffier 1907
dart run tool/generate_metier_enrichment.dart    # pH, portions, rétentions, profils, accords
```

L'ordre compte : le générateur métier lit les sorties des précédents.

## Données curatées (`tool/data/`)

| Fichier | Rôle |
|---|---|
| `ciqual_aliases.csv` | rapprochements Ciqual explicites (`equivalent`, `proxy`, `none` pour interdire un rapprochement par nom erroné) |
| `usda_aliases.csv` | ingrédients absents de Ciqual → aliment USDA FoodData Central |
| `composition_formulas.csv` | préparations de base (roux, mirepoix…) et substances pures, calculées |
| `usda_portions_map.csv` | portion USDA retenue par ingrédient (densité, pièce, gousse, brin…) |
| `fda_ph_2007.csv`, `fda_ph_map.csv` | liste FDA des pH et rapprochement manuel |
| `rf6_map.csv` | couple (groupe, cuisson) → catégories USDA de rétention |
| `corpus_lexicon.csv`, `corpus_pairings.csv` | lexique anglais 1907 et accords observés |
| `allergen_rules.csv`, `allergen_overrides.csv` | règles et corrections d'allergènes |
| `culinary_units.csv`, `physchem_rules.csv`, `flavor_profiles.csv`, `process_factors.csv`, `culinary_pairings.csv` | règles et curation internes (estimations signalées comme telles dans l'application) |
