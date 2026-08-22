# Rapport de couverture — Phase 3

- dataset_version: 1.0.0
- schema_version: 1.0.0
- generated_at: 2026-08-22

## 1. Volumes
- Composés aromatiques : **39**
- Ingrédients avec profil composé : **30**
- Paires analysées : **4560**
- Hyper-interactions documentées : **5**
- Lignes flavor_compatibility.csv : **4593**

## 2. Couverture par descripteur (top 20)
- sweet: 29
- fruity: 27
- umami: 20
- sour: 18
- bitter: 13
- fatty: 13
- green: 12
- pungent: 12
- fermented: 10
- dairy: 10
- caramel: 9
- herbal: 9
- spicy: 8
- salty: 8
- roasted: 8
- alcoholic: 8
- woody: 7
- citrus: 6
- tropical: 6
- sulfurous: 6

## 3. Couverture par source (composés)
- FLAVORDB2: 39
- PUBCHEM: 39
- CHEBI: 39

## 4. Sources approuvées
- FLAVORDB2 : CC BY-NC-SA 4.0 — usage non commercial.
- PubChem : public domain.
- ChEBI : CC BY 4.0.
- CULINARY_LIT : corpus culinaire général (public).

## 5. Ingrédients sans profil aromatique
- Abricot crue
- Absinthe
- Acide ascorbique
- Acide citrique
- Acide tartrique
- Agar-agar
- Airelle crue
- Alginate de sodium
- Amande crue
- Amande torréfiée
- Amarante grain
- Amidon de maïs (modifié)
- Amidon de maïs natif
- Amidon de pomme de terre
- Amidon modifié E1422
- Anis vert
- Anis étoilé
- Arachide crue
- Arachide torréfiée
- Armagnac
- Arôme naturel de vanille
- Aubergine
- Avoine grain
- Babeurre
- Bar
- Bergamote cru
- Bette
- Betterave
- Beurre de amande
- Beurre de arachide
- Beurre de cajou
- Beurre de noisette
- Beurre de noix de macadamia
- Beurre de noix du brésil
- Beurre de pistache
- Bicarbonate de soude
- Bière ambrée
- Bière de blé
- Bière pils
- Bière sans alcool
- (513 au total — extension incrémentale)

## 6. Doctrine de couverture
- On ne stocke pas toutes les combinaisons de 3-5 ingrédients :
  le moteur les calcule à la demande depuis les ingrédients, composés et descripteurs.
- Les accords documentés (`PAIRWISE_GOLD`, `HIGHER_ORDER`) servent à calibrer et tester.
- Aucune prédiction n'est présentée comme mesure.