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
  String get settingsTodo => 'Paramètres à brancher';
  String get exportAction => 'Exporter';
  String get settingsAction => 'Paramètres';
  String get deleteAction => 'Supprimer';
  String get duplicateAction => 'Dupliquer';
  String duplicateRecipeTitle(String title) => '$title copie';
  String get editAction => 'Modifier';
  String get ingredients => 'Ingrédients';
  String get images => 'Images';
  String get preparation => 'Préparation';
  String get overview => 'Vue d’ensemble';
  String ingredientCount(int count) =>
      '$count ingrédient${count > 1 ? 's' : ''}';
  String stepCount(int count) => '$count étape${count > 1 ? 's' : ''}';
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
  String get addImage => 'Ajouter une photo';
  String get choosePhoto => 'Choisir une photo';
  String get imageLabelField => 'Libellé photo';
  String get imagePathField => 'Chemin de la photo';
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

  // Lot D — added when wiring the CsvImportService into the UI shell.
  String get importMetierAction => 'Importer BDD métier';
  String get importMetierReady => 'BDD métier prêtes';
  String get importMetierPending => 'BDD à importer';
  String get importMetierRunning => 'Import en cours…';
  String get importMetierSnackbar =>
      'Import des 4 bases métier déclenché. Voir le dossier Test-Dev/ pour le détail.';

  // Phase 09 Lot F — UX pilotée par les BDD métier.
  String get pickIngredientTitle => 'Choisir un ingrédient';
  String get pickIngredientSearchHint => 'Rechercher (tomate, basilic…)';
  String get pickIngredientNoResult => 'Aucun ingrédient ne correspond.';
  String get pickIngredientCategoryAll => 'Toutes';
  String get pickIngredientTooltip => 'Choisir depuis le référentiel Phase 1';
  String get pickIngredientFallbackTitle => 'Saisir un ingrédient';
  String get pickIngredientFallbackLabel => "Nom de l'ingrédient";
  String get pickIngredientFallbackHint => 'Tomate, Basilic, …';
  String get pickIngredientFallbackOk => 'OK';
  String get ingredientPhase1Helper => 'Phase 1';
  String get ingredientDetailAlcoholBadge => 'Alcoolisé';
  String get ingredientDetailFermentedBadge => 'Fermenté';
  String get ingredientDetailAllergensTitle => 'Allergènes';
  String get ingredientDetailNoAllergens => 'Aucun allergène déclaré';
  String get ingredientDetailNutritionTitle => 'Nutrition · pour 100 g';
  String get ingredientDetailNutritionUnavailable => 'Nutrition non disponible';
  String get ingredientDetailEnergy => 'Énergie';
  String get ingredientDetailProteins => 'Protéines';
  String get ingredientDetailFats => 'Lipides';
  String get ingredientDetailCarbs => 'Glucides';

  // Phase 09 Lot G — nutrition calculée + heatmap flavour.
  String nutritionComputedFrom(int resolved, int total) =>
      'Calculé depuis $resolved ingrédient${resolved > 1 ? 's' : ''} '
      'sur $total';
  String get nutritionManualEntry => 'Valeur saisie manuellement';
  String nutritionNoDataForLinked(int count) => count > 1
      ? 'Aucune donnée nutritionnelle en base pour les $count '
            'ingrédients liés — la table Ciqual ne couvre pas encore '
            'ces aliments. Saisie manuelle ci-dessous.'
      : 'Aucune donnée nutritionnelle en base pour cet ingrédient '
            'lié — la table Ciqual ne le couvre pas encore. '
            'Saisie manuelle ci-dessous.';
  String get nutritionSources => 'Sources';
  String get mineralsTitle => 'Minéraux';
  String get vitaminsTitle => 'Vitamines';
  String get otherConstituentsTitle => 'Autres constituants';
  String get alcoholLabel => 'Alcool';
  String get nutritionAutoComputed =>
      'Calculée automatiquement depuis les ingrédients liés';
  String get nutritionManualOverride => 'Forcer la saisie manuelle';
  String get flavorHeatmapTitle => 'Compatibilités aromatiques';
  String get flavorPairUnknown => 'Pas de donnée';
  String get flavorSourceDirectPair =>
      'Score d\'accord direct (paire documentée en base Phase 3).';
  String flavorSourceCombination(int size) =>
      'Score approximé : accord connu pour une combinaison de $size '
      'ingrédients contenant cette paire (pas de donnée directe pour la '
      'paire seule).';
  String get flavorOverallScore => 'Score global';
  String get flavorCategoryExcellent => 'Excellente';
  String get flavorCategoryGood => 'Bonne';
  String get flavorCategoryAverage => 'Moyenne';
  String get flavorCategoryQuestionable => 'Discutable';
  String get flavorCategoryAvoid => 'À éviter';

  // Phase 09 Lot H — Phase 4 functional.
  String get functionalAlertsTitle => 'Alertes physico-chimiques';
  String get functionalSeverityInfo => 'Info';
  String get functionalSeverityWarning => 'Attention';
  String get functionalSeverityDanger => 'Danger';
  String get functionalSeverityOutOfDomain => 'Hors domaine';
  String get functionalConditions => 'Conditions';
  String get functionalPredictedEffect => 'Effet prédit';
  String functionalConfidence(double confidence) =>
      'Confiance ${(confidence * 100).round()} %';
  String functionalMixShare(double share) =>
      'Part du mix : ${(share * 100).round()} %';
  String get functionalTriggersLabel => 'Ingrédients concernés';
  String get functionalLowShareNote =>
      'Influence probablement faible : moins de 5 % du mix.';

  // Phase 09 Lot H — recommandations.
  String get recommendationSheetTitle => 'Mauvaise combinaison détectée';
  String get recommendationSheetBody =>
      'Certains ingrédients de cette recette s’opposent aromatiquement '
      'ou déclenchent une alerte physico-chimique.';
  String recommendationProblemPair(String a, String b, double score) =>
      '$a × $b : score ${score.toStringAsFixed(2)}';
  String recommendationSubstitutesFor(String name) =>
      'Substituts proposés pour $name';
  String get recommendationReasonBetterAffinity =>
      'Meilleure affinité aromatique';
  String get recommendationReasonResolvesConflict =>
      'Résout une incompatibilité existante';
  String get recommendationIgnore => 'Ignorer';
  String get recommendationShowSubstitutes => 'Voir les substituts';
  String get recommendationNoSubstitute => 'Aucun substitut trouvé.';
  String get ingredientBadCombinationWarning =>
      'Cet ingrédient crée une mauvaise combinaison avec la recette.';
  String get flavorIncompatibilitiesLabel => 'Incompatibilités aromatiques';
}

const appStrings = AppStrings();

extension AppStringsContext on BuildContext {
  AppStrings get strings => appStrings;
}
