# Rapport QA — Phase 2

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## 1. Contrôles automatisés
- Lignes nutrition: 751
- Mappings ingrédient↔source: 64
- Ingrédients du registre avec au moins une donnée nutritionnelle: 62 (10.3%)
- Doublons (ingredient_id, state, source, component_id): 0
- Ingredients absents du registre: 0
- Composants hors dictionnaire: 0
- Valeurs négatives: 0
- Qualifiers hors vocabulaire: 0
- Sodium > 200 mg/100g (catégories naturellement salées) : 6
- Sodium > 200 mg/100g (à confirmer) : 0
- Conflits cross-source détectés (Δ>20%): 0

## 2. Conclusions
- Phase 2 **validée** sur les contrôles automatisés.
## 3. Détails des anomalies
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000615', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000625', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000634', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000658', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000667', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}
- {'anomaly_type': 'high_sodium_known_high', 'record_id': 'NUTR-0000737', 'detail': 'Na > 200 mg/100g : cohérent avec catégorie (fromage affiné / sauce soja / saindoux / moutarde)'}