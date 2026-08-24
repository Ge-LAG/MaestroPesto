import 'package:maestropesto/features/recipes/domain/recipe.dart';

const demoRecipes = <Recipe>[
  Recipe(
    id: 'pesto',
    title: 'Pesto maison',
    description: 'Une base dense et parfumée pour accompagner des pâtes, des légumes rôtis ou une soupe froide.',
    tags: ['sauce', 'végétarien', 'rapide'],
    servings: 6,
    prepMinutes: 12,
    cookMinutes: 0,
    ingredients: [
      RecipeIngredient(
        label: 'Basilic frais',
        quantity: '60 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Parmesan',
        quantity: '45 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Huile d’olive',
        quantity: '90 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Pignons de pin',
        quantity: '35 g',
        source: IngredientSource.ciqual,
      ),
    ],
    steps: [
      'Mixer le basilic avec les pignons et le parmesan.',
      'Ajouter l’huile progressivement jusqu’à obtenir une texture souple.',
      'Rectifier avec une petite quantité d’eau si nécessaire.',
    ],
    nutrition: NutritionSummary(
      energyKcal: 197,
      proteins: 4.7,
      carbs: 1.9,
      fats: 19.1,
      fiber: 1.0,
      salt: 0.14,
    ),
    images: [],
  ),
  Recipe(
    id: 'pasta-pesto',
    title: 'Pâtes au pesto',
    description: 'Une fiche composée qui utilise le pesto maison comme ingrédient réutilisable.',
    tags: ['plat', 'végétarien'],
    servings: 2,
    prepMinutes: 5,
    cookMinutes: 10,
    ingredients: [
      RecipeIngredient(
        label: 'Pâtes cuites',
        quantity: '360 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Pesto maison',
        quantity: '90 g',
        source: IngredientSource.recipe,
      ),
      RecipeIngredient(
        label: 'Poivre noir',
        quantity: '1 pincée',
        source: IngredientSource.free,
      ),
    ],
    steps: [
      'Cuire les pâtes et conserver un peu d’eau de cuisson.',
      'Ajouter le pesto hors du feu pour garder le basilic vif.',
      'Détendre avec l’eau de cuisson et servir aussitôt.',
    ],
    nutrition: NutritionSummary(
      energyKcal: 313,
      proteins: 10.1,
      carbs: 46.2,
      fats: 10.0,
      fiber: 3.0,
      salt: 0.13,
    ),
    images: [],
  ),
  Recipe(
    id: 'tomato-salad',
    title: 'Salade de tomates',
    description: 'Une recette simple pour tester les tags, les ingrédients libres et la lecture rapide.',
    tags: ['entrée', 'été', 'rapide'],
    servings: 4,
    prepMinutes: 8,
    cookMinutes: 0,
    ingredients: [
      RecipeIngredient(
        label: 'Tomates crues',
        quantity: '520 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Huile d’olive',
        quantity: '24 g',
        source: IngredientSource.ciqual,
      ),
      RecipeIngredient(
        label: 'Fleur de sel',
        quantity: '2 g',
        source: IngredientSource.free,
      ),
    ],
    steps: [
      'Couper les tomates en quartiers réguliers.',
      'Assaisonner juste avant de servir.',
      'Ajouter quelques feuilles de basilic si disponible.',
    ],
    nutrition: NutritionSummary(
      energyKcal: 76,
      proteins: 1.2,
      carbs: 4.0,
      fats: 6.1,
      fiber: 1.6,
      salt: 0.51,
    ),
    images: [],
  ),
];
