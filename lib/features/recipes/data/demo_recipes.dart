// Recettes de démonstration (semées au premier lancement, Phase 10).
//
// Toutes les lignes sont liées au référentiel Phase 1 (identifiants
// `ING-*`) avec des quantités en unités culinaires et des étapes
// décrivant le procédé : elles illustrent le calcul nutritionnel avec
// cuisson, les accords aromatiques et l'analyse physico-chimique. La
// nutrition est CALCULÉE (aucune valeur saisie à la main).

import 'package:maestropesto/features/recipes/domain/recipe.dart';

const _zero = NutritionSummary(
  energyKcal: 0,
  proteins: 0,
  carbs: 0,
  fats: 0,
  fiber: 0,
  salt: 0,
);

RecipeIngredient _ing(
  String label,
  String quantity,
  String id, {
  String? cook,
}) => RecipeIngredient(
  label: label,
  quantity: quantity,
  source: IngredientSource.ciqual,
  ingredientId: id,
  cookingMethod: cook,
);

final demoRecipes = <Recipe>[
  Recipe(
    id: 'pesto',
    title: 'Pesto maison',
    description:
        'Une base dense et parfumée pour accompagner des pâtes, des '
        'légumes rôtis ou une soupe froide.',
    tags: const ['sauce', 'végétarien', 'rapide'],
    servings: 6,
    prepMinutes: 12,
    cookMinutes: 0,
    ingredients: [
      _ing('Basilic frais', '60 g', 'ING-PLANT-BASILIC-000001'),
      _ing('Parmesan', '45 g', 'ING-DAIRY-PARMIGIANORE-000001'),
      _ing(
        'Huile d’olive vierge extra',
        '90 g',
        'ING-TECH-HUILEDOLIVEV-000001',
      ),
      _ing('Pignons de pin', '35 g', 'ING-PLANT-PIGNONDEPIN-000001'),
      _ing('Ail', '1 gousse', 'ING-PLANT-AIL-000001'),
      _ing('Sel fin', '1 pincée', 'ING-TECH-SELFIN-000001'),
    ],
    steps: const [
      'Mixer le basilic avec les pignons, l’ail et le parmesan.',
      'Ajouter l’huile progressivement jusqu’à obtenir une texture souple.',
      'Rectifier avec une petite quantité d’eau si nécessaire.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'caprese',
    title: 'Salade caprese',
    description: 'Tomate, mozzarella et basilic : l’accord classique italien.',
    tags: const ['entrée', 'été', 'végétarien', 'rapide'],
    servings: 4,
    prepMinutes: 10,
    cookMinutes: 0,
    ingredients: [
      _ing('Tomates', '4 pièces', 'ING-PLANT-TOMATE-000001'),
      _ing('Mozzarella', '250 g', 'ING-DAIRY-MOZZARELLA-000001'),
      _ing('Basilic frais', '1 botte', 'ING-PLANT-BASILIC-000001'),
      _ing(
        'Huile d’olive vierge extra',
        '3 c. à soupe',
        'ING-TECH-HUILEDOLIVEV-000001',
      ),
      _ing('Fleur de sel', '1 pincée', 'ING-TECH-FLEURDESEL-000001'),
      _ing('Poivre noir', '1 pincée', 'ING-PLANT-POIVRENOIR-000001'),
    ],
    steps: const [
      'Couper les tomates et la mozzarella en tranches régulières.',
      'Alterner tomate, mozzarella et feuilles de basilic.',
      'Assaisonner d’huile, de fleur de sel et de poivre au moment de servir.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'confiture-fraise',
    title: 'Confiture de fraises',
    description:
        'Confiture classique : la pectine des fruits gélifie grâce au sucre '
        'et à l’acidité du citron.',
    tags: const ['conserve', 'dessert', 'été'],
    servings: 20,
    prepMinutes: 20,
    cookMinutes: 25,
    ingredients: [
      _ing('Fraises', '1 kg', 'ING-PLANT-FRAISE-000001'),
      _ing('Sucre', '750 g', 'ING-TECH-SUCREBLANC-000001'),
      _ing('Citron', '1 pièce', 'ING-PLANT-CITRONJAUNE-000001'),
    ],
    steps: const [
      'Équeuter les fraises, les couper et les mélanger au sucre et au jus '
          'de citron ; laisser macérer 2 h.',
      'Porter à ébullition puis cuire 20 min à feu vif en remuant.',
      'Mettre en pots chauds et laisser refroidir.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'mayonnaise',
    title: 'Mayonnaise maison',
    description:
        'Émulsion huile-dans-eau stabilisée par les lécithines du jaune.',
    tags: const ['sauce', 'base'],
    servings: 8,
    prepMinutes: 10,
    cookMinutes: 0,
    ingredients: [
      _ing('Jaune d’œuf', '1 pièce', 'ING-ANIMAL-JAUNEDUF-000001'),
      _ing('Moutarde de Dijon', '1 c. à café', 'ING-COND-MOUTARDEDEDI-000001'),
      _ing('Huile de colza', '25 cl', 'ING-TECH-HUILEDECOLZA-000001'),
      _ing('Vinaigre blanc', '1 c. à soupe', 'ING-TECH-VINAIGREBLAN-000001'),
      _ing('Sel fin', '1 pincée', 'ING-TECH-SELFIN-000001'),
    ],
    steps: const [
      'Fouetter le jaune avec la moutarde et le sel.',
      'Incorporer l’huile en filet en fouettant sans arrêt.',
      'Ajouter le vinaigre en fin de préparation.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'creme-patissiere',
    title: 'Crème pâtissière à la vanille',
    description: 'Liaison par les œufs et l’amidon de la farine.',
    tags: const ['dessert', 'base', 'pâtisserie'],
    servings: 6,
    prepMinutes: 10,
    cookMinutes: 10,
    ingredients: [
      _ing('Lait entier', '50 cl', 'ING-DAIRY-LAITENTIER-000001'),
      _ing('Jaunes d’œufs', '4 pièces', 'ING-ANIMAL-JAUNEDUF-000001'),
      _ing('Sucre', '100 g', 'ING-TECH-SUCREBLANC-000001'),
      _ing('Farine', '40 g', 'ING-TECH-FARINEDEBLTE-000001'),
      _ing('Vanille', '1 gousse', 'ING-PLANT-VANILLEGOUSS-000001'),
    ],
    steps: const [
      'Faire chauffer le lait avec la vanille fendue.',
      'Fouetter les jaunes avec le sucre puis incorporer la farine.',
      'Verser le lait chaud sur le mélange en fouettant.',
      'Remettre sur feu moyen et cuire jusqu’à épaississement (85 °C) en '
          'fouettant.',
      'Réfrigérer 2 h au contact d’un film.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'gigot-agneau',
    title: 'Gigot d’agneau rôti au romarin',
    description: 'Un rôti du dimanche : Maillard, herbes et pommes de terre.',
    tags: const ['plat', 'four'],
    servings: 6,
    prepMinutes: 20,
    cookMinutes: 60,
    ingredients: [
      _ing('Gigot d’agneau', '1,5 kg', 'ING-ANIMAL-AGNEAUVIANDE-000001'),
      _ing('Pommes de terre', '1 kg', 'ING-PLANT-POMMEDETERRE-000001'),
      _ing('Ail', '6 gousses', 'ING-PLANT-AIL-000001'),
      _ing('Romarin', '3 brins', 'ING-PLANT-ROMARIN-000001'),
      _ing('Thym', '3 brins', 'ING-PLANT-THYM-000001'),
      _ing(
        'Huile d’olive vierge extra',
        '3 c. à soupe',
        'ING-TECH-HUILEDOLIVEV-000001',
      ),
      _ing('Sel fin', '1 c. à café', 'ING-TECH-SELFIN-000001'),
    ],
    steps: const [
      'Préchauffer le four à 200 °C.',
      'Piquer le gigot d’ail et l’enduire d’huile, de romarin et de thym.',
      'Enfourner le gigot entouré des pommes de terre 1 h à 200 °C.',
      'Laisser reposer 10 min avant de trancher.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'panna-cotta',
    title: 'Panna cotta, coulis de framboise',
    description: 'Gel de gélatine à la crème et coulis de fruits rouges.',
    tags: const ['dessert', 'frais'],
    servings: 6,
    prepMinutes: 15,
    cookMinutes: 5,
    ingredients: [
      _ing('Crème liquide entière', '50 cl', 'ING-DAIRY-CRMELIQUIDEE-000001'),
      _ing('Sucre', '60 g', 'ING-TECH-SUCREBLANC-000001'),
      _ing('Gélatine', '3 feuilles', 'ING-TECH-GLATINE-000001'),
      _ing('Vanille', '1 gousse', 'ING-PLANT-VANILLEGOUSS-000001'),
      _ing('Framboises', '250 g', 'ING-PLANT-FRAMBOISE-000001'),
    ],
    steps: const [
      'Faire ramollir la gélatine dans l’eau froide.',
      'Chauffer la crème avec le sucre et la vanille sans bouillir.',
      'Incorporer la gélatine essorée hors du feu, verser en verrines.',
      'Réfrigérer 4 h pour laisser prendre.',
      'Mixer les framboises et napper au moment de servir.',
    ],
    nutrition: _zero,
    images: const [],
  ),
  Recipe(
    id: 'ratatouille',
    title: 'Ratatouille',
    description: 'Légumes du soleil mijotés à l’huile d’olive.',
    tags: const ['plat', 'végétarien', 'été'],
    servings: 6,
    prepMinutes: 25,
    cookMinutes: 60,
    ingredients: [
      _ing('Aubergines', '2 pièces', 'ING-PLANT-AUBERGINE-000001'),
      _ing('Courgettes', '2 pièces', 'ING-PLANT-COURGETTE-000001'),
      _ing('Poivrons rouges', '2 pièces', 'ING-PLANT-POIVRONROUGE-000001'),
      _ing('Tomates', '4 pièces', 'ING-PLANT-TOMATE-000001'),
      _ing('Oignon', '1 pièce', 'ING-PLANT-OIGNON-000001'),
      _ing('Ail', '3 gousses', 'ING-PLANT-AIL-000001'),
      _ing(
        'Huile d’olive vierge extra',
        '4 c. à soupe',
        'ING-TECH-HUILEDOLIVEV-000001',
      ),
      _ing('Thym', '2 brins', 'ING-PLANT-THYM-000001'),
      _ing('Sel fin', '1 c. à café', 'ING-TECH-SELFIN-000001'),
    ],
    steps: const [
      'Couper les légumes en dés.',
      'Faire revenir l’oignon et les poivrons dans l’huile d’olive.',
      'Ajouter aubergines, courgettes, tomates, ail et thym.',
      'Laisser mijoter 45 min à couvert en remuant de temps en temps.',
    ],
    nutrition: _zero,
    images: const [],
  ),
];
