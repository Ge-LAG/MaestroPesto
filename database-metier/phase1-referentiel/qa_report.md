# Rapport QA — Phase 1

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## 1. Contrôles automatisés
- Unicité ingredient_id: 0 doublon(s)
- Lignes sans canonical_name_fr: 0
- Lignes sans category_level_1: 0
- Marques commerciales potentielles: 0
- Lignes sans identifiant externe: 20
- Doublons sémantiques candidats (normalisation): 1

### Doublons sémantiques candidats (lecture humaine requise)
- ING-PLANT-POMME-000004 ≡ ING-BEV-JUSDEPOMME-000001 (clé='jus de pomme')

## 2. Conclusion
- Phase 1 **validée** sur les contrôles automatisés.

## 3. Anomalies exportées
- Aucune marque commerciale non référencée dans excluded_items n'est restée.
- Aucun doublon ingredient_id détecté.
- Le référentiel est cohérent avec la politique de licence.