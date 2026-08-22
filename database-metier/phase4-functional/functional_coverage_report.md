# Rapport de couverture — Phase 4

- dataset_version: 1.0.0
- generated_at: 2026-08-22

## 1. Volumes
- Composants fonctionnels : **40**
- Ingrédients avec propriétés documentées : **18** / 771 (2.3%)
- Opérations unitaires : **38**
- Règles d'interaction : **16**
- Cas expérimentaux : **10**

## 2. Règles par famille
- gelling: 5
- protein: 3
- emulsion: 2
- browning: 2
- starch: 2
- taste: 1
- safety: 1

## 3. Familles de phénomènes couvertes
- Gélification (pectine HM/LM, gélatine, agar)
- Émulsions (huile/eau, lécithine, jaune d'œuf)
- Mousses (protéines)
- Maillard et caramélisation
- Gélatinisation et rétrogradation amidon
- Coagulation protéique (thermique et acide)
- Activité de l'eau (sécurité)
- Perception sel/umami

## 4. Catégories d'ingrédients couvertes
- végétal: 3 / 242 (1.2%)
- animal: 6 / 103 (5.8%)
- ingrédient technique: 8 / 100 (8.0%)
- boisson: 1 / 73 (1.4%)
- condiment: 0 / 39 (0.0%)
- préparation: 0 / 16 (0.0%)
- sous-produit culinaire: 0 / 9 (0.0%)
- fungi: 0 / 7 (0.0%)
- algue: 0 / 7 (0.0%)
- ferment: 0 / 7 (0.0%)

## 5. Cas de validation
- **EXP-MAYO-001** — F-MAYO-001 : Huile de colza, Jaune d'œuf, Moutarde de Dijon, Vinaigre blanc, Sel fin
- **EXP-GEL-PEC-001** — F-PEC-001 : Sucre blanc, Pectine HM, Acide citrique, Eau
- **EXP-CUSTARD-001** — F-CUSTARD-001 : Lait entier, Jaune d'œuf, Sucre blanc, Farine de blé tendre, Beurre doux
- **EXP-MERINGUE-001** — F-MER-001 : Blanc d'œuf, Sucre blanc, Crème de tartre
- **EXP-BREAD-001** — F-BREAD-001 : Farine de blé tendre, Eau, Sel fin, Levure boulangère sèche
- **EXP-CARAMEL-001** — F-CARAMEL-001 : Sucre blanc, Eau, Crème liquide entière, Beurre doux
- **EXP-CHOCOLATE-001** — F-CHOC-001 : Chocolat noir 70%, Crème liquide entière
- **EXP-DRESSING-001** — F-DRESS-001 : Huile d'olive, Vinaigre de vin rouge, Moutarde de Dijon, Sel fin
- **EXP-SORBET-001** — F-SORB-001 : Eau, Sucre blanc, Jus de citron jaune, Fruit de la passion
- **EXP-KIMCHI-001** — F-KIMCHI-001 : Chou chinois, Sel fin, Piment fort, Ail, Gingembre

## 6. Sources bibliographiques
- Damodaran (Food Proteins, CRC)
- BeMiller (Carbohydrate Chemistry)
- Phillips (Handbook of Hydrocolloids)
- O'Brien (Fats and Oils)
- McClements (Food Emulsions)
- Belitz (Food Chemistry)
- Lund (Maillard Reaction)
- Srivastava/John (Fermentation)

## 7. Zones de faiblesse
- Cinétique des réactions : modèle simplifié (constante d'Arrhenius générique).
- Ingrédients mixtes (préparations) : couverture limitée.
- Paramètres sensoriels (texture humaine) : peu corrélés.
- Couplage avec base aromatique Phase 3 : structurel mais non encore bidirectionnel.

## 8. Doctrine
- Une règle s'applique UNIQUEMENT dans son `applicability_domain`.
- En dehors, le moteur DOIT retourner `OUT_OF_DOMAIN` et baisse du score.
- Aucune valeur « cachée » : si le moteur extrapole, c'est explicite et marqué.