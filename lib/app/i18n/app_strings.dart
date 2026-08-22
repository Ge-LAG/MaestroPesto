import 'package:flutter/widgets.dart';

class AppStrings {
  const AppStrings();

  String get appName => 'MaestroPesto';
  String get recipeBookSubtitle => 'Classeur local';
  String get newRecipe => 'Nouvelle recette';
  String get search => 'Rechercher';
  String get tags => 'Tags';
  String tagsCount(int count) => 'Tags ($count)';
  String get allTags => 'Tous les tags';
  String get clearFilters => 'Réinitialiser';
  String recipeCount(int count) => '$count fiche${count > 1 ? 's' : ''}';
  String resultCount(int count) => '$count résultat${count > 1 ? 's' : ''}';
  String get cardView => 'Vignette';
  String get listView => 'Liste';
  String get noMatchingRecipes => 'Aucune recette ne correspond aux filtres.';
  String get noRecipeTitle => 'Aucune fiche';
  String get noRecipeBody =>
      'Crée une première recette ou ajuste les filtres du classeur.';

  String get exportPdfTodo => 'Export PDF à brancher';
  String get exportAction => 'Exporter';
  String get deleteAction => 'Supprimer';
  String get duplicateAction => 'Dupliquer';
  String duplicateRecipeTitle(String title) => '$title copie';
  String get editAction => 'Modifier';
  String get ingredients => 'Ingrédients';
  String get preparation => 'Préparation';
  String get overview => 'Vue d’ensemble';
  String get sources => 'Sources';
  String ingredientCount(int count) =>
      '$count ingrédient${count > 1 ? 's' : ''}';
  String stepCount(int count) => '$count étape${count > 1 ? 's' : ''}';
  String sourceCount(String source, int count) => '$source · $count';
  String get ciqual => 'Ciqual';
  String get sourceRecipe => 'Recette';
  String get sourceFree => 'Libre';

  String get nutrition => 'Nutrition';
  String get energy => 'Énergie';
  String get proteins => 'Protéines';
  String get carbs => 'Glucides';
  String get fats => 'Lipides';
  String get fiber => 'Fibres';
  String get salt => 'Sel';

  String get createRecipeDialogTitle => 'Nouvelle recette';
  String get editRecipeDialogTitle => 'Modifier la recette';
  String get deleteRecipeDialogTitle => 'Supprimer la recette';
  String deleteRecipeConfirmation(String title) =>
      'Supprimer "$title" du classeur ?';
  String get cancel => 'Annuler';
  String get save => 'Enregistrer';
  String get close => 'Fermer';
  String get recipeFormSection => 'Fiche';
  String get titleField => 'Titre';
  String get titleRequired => 'Titre requis';
  String get descriptionField => 'Description';
  String get tagsField => 'Tags séparés par des virgules';
  String get servingsField => 'Portions';
  String get prepField => 'Préparation';
  String get cookField => 'Cuisson';
  String get addIngredient => 'Ajouter un ingrédient';
  String get quantityField => 'Quantité';
  String get ingredientField => 'Ingrédient';
  String get sourceField => 'Source';
  String get addStep => 'Ajouter une étape';
  String get stepField => 'Étape';
  String get nutritionPerServing => 'Nutrition par portion';
  String get energyKcalField => 'Énergie kcal';
  String get proteinsGField => 'Protéines g';
  String get carbsGField => 'Glucides g';
  String get fatsGField => 'Lipides g';
  String get fiberGField => 'Fibres g';
  String get saltGField => 'Sel g';
  String get numberRequired => 'Nombre requis';
  String minimumValue(num min) => 'Minimum $min';
}

const appStrings = AppStrings();

extension AppStringsContext on BuildContext {
  AppStrings get strings => appStrings;
}
