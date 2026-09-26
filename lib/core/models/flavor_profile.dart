// Phase 10 Lot E — profil sensoriel d'un ingrédient.
//
// Vecteur de descripteurs de l'ontologie Phase 3
// (`sensory_descriptor_ontology.csv`, 53 descripteurs) : arômes,
// saveurs et sensations chimiques, intensité 0..1. Chaque profil porte
// son niveau de preuve (composés mesurés, curation experte, règle de
// famille) et une confiance : la heatmap ne présente jamais une
// prédiction comme une mesure.

import 'package:meta/meta.dart';

/// Niveau de preuve d'un profil sensoriel.
enum FlavorEvidenceLevel {
  measured,
  curated,
  family,
  unknown;

  static FlavorEvidenceLevel parse(String? raw) => switch (raw) {
    'measured' => FlavorEvidenceLevel.measured,
    'curated' => FlavorEvidenceLevel.curated,
    'family' => FlavorEvidenceLevel.family,
    _ => FlavorEvidenceLevel.unknown,
  };
}

/// Contexte culinaire dominant d'un ingrédient.
enum FlavorContext {
  sweet,
  savory,
  both;

  static FlavorContext parse(String? raw) => switch (raw) {
    'sweet' => FlavorContext.sweet,
    'savory' => FlavorContext.savory,
    _ => FlavorContext.both,
  };
}

@immutable
class FlavorProfile {
  const FlavorProfile({
    required this.ingredientId,
    required this.descriptors,
    this.context = FlavorContext.both,
    this.intensity = 0.3,
    this.evidence = FlavorEvidenceLevel.unknown,
    this.confidence = 0.25,
    this.note,
  });

  /// Parse le format CSV `id:0.9|id2:0.4`.
  factory FlavorProfile.fromEncoded({
    required String ingredientId,
    required String encoded,
    String? context,
    double? intensity,
    String? evidence,
    double? confidence,
    String? note,
  }) {
    final map = <String, double>{};
    for (final part in encoded.split('|')) {
      final kv = part.split(':');
      if (kv.length != 2) continue;
      final v = double.tryParse(kv[1]);
      if (v != null && v > 0) map[kv[0].trim()] = v;
    }
    return FlavorProfile(
      ingredientId: ingredientId,
      descriptors: map,
      context: FlavorContext.parse(context),
      intensity: intensity ?? 0.3,
      evidence: FlavorEvidenceLevel.parse(evidence),
      confidence: confidence ?? 0.25,
      note: note,
    );
  }

  final String ingredientId;
  final Map<String, double> descriptors;
  final FlavorContext context;

  /// Puissance aromatique 0..1 (risque de dominance).
  final double intensity;
  final FlavorEvidenceLevel evidence;
  final double confidence;
  final String? note;

  double operator [](String descriptor) => descriptors[descriptor] ?? 0;

  /// Descripteurs aromatiques (hors saveurs et sensations) triés par
  /// intensité décroissante.
  List<MapEntry<String, double>> get topAromas =>
      descriptors.entries.where((e) => !SensoryOntology.isTaste(e.key)).toList()
        ..sort((a, b) => b.value.compareTo(a.value));
}

/// Ontologie sensorielle Phase 3 (libellés FR et hiérarchie parent).
abstract final class SensoryOntology {
  /// Saveurs et sensations chimiques (dimension « goût »).
  static const Set<String> tasteDimensions = {
    'sweet',
    'sour',
    'salty',
    'bitter',
    'umami',
    'fatty',
    'astringent',
    'pungent',
    'cooling',
    'warming',
    'metallic',
    'kokumi',
    'acidic',
    'spicy',
    'peppery',
  };

  static bool isTaste(String descriptor) =>
      tasteDimensions.contains(descriptor);

  /// Hiérarchie parent (colonne `parent` de l'ontologie).
  static const Map<String, String> parent = {
    'citrus': 'fruity',
    'berry': 'fruity',
    'stone_fruit': 'fruity',
    'tropical': 'fruity',
    'jammy': 'fruity',
    'herbal': 'green',
    'grassy': 'green',
    'leafy': 'green',
    'rose': 'floral',
    'violet': 'floral',
    'mushroom': 'earthy',
    'truffle': 'earthy',
    'toasted': 'roasted',
    'coffee': 'roasted',
    'malty': 'roasted',
    'honey': 'caramel',
    'peppery': 'spicy',
    'buttery': 'dairy',
    'cheesy': 'fermented',
    'yeasty': 'fermented',
    'acidic': 'sour',
  };

  /// Famille aromatique d'un descripteur (lui-même s'il est racine).
  static String family(String descriptor) => parent[descriptor] ?? descriptor;

  static const Map<String, String> labelsFr = {
    'sweet': 'Sucré',
    'sour': 'Acide',
    'salty': 'Salé',
    'bitter': 'Amer',
    'umami': 'Umami',
    'fatty': 'Gras',
    'astringent': 'Astringent',
    'pungent': 'Piquant',
    'cooling': 'Frais',
    'warming': 'Chaud',
    'metallic': 'Métallique',
    'kokumi': 'Kokumi',
    'fruity': 'Fruité',
    'citrus': 'Agrume',
    'berry': 'Fruits rouges',
    'stone_fruit': 'Fruits à noyau',
    'tropical': 'Fruits tropicaux',
    'green': 'Végétal vert',
    'herbal': 'Herbacé',
    'grassy': 'Herbe fraîche',
    'leafy': 'Feuille',
    'floral': 'Floral',
    'rose': 'Rose',
    'violet': 'Violette',
    'woody': 'Boisé',
    'earthy': 'Terreux',
    'mushroom': 'Champignon',
    'truffle': 'Truffe',
    'nutty': 'Noisette',
    'roasted': 'Rôti',
    'toasted': 'Grillé/torréfié',
    'caramel': 'Caramel',
    'smoky': 'Fumé',
    'spicy': 'Épicé',
    'peppery': 'Poivré',
    'sulfurous': 'Soufré',
    'meaty': 'Charnu',
    'marine': 'Marin',
    'dairy': 'Laitier',
    'fermented': 'Fermenté',
    'solvent': 'Solvant',
    'medicinal': 'Médicinal',
    'resinous': 'Résineux',
    'vanillic': 'Vanillé',
    'cocoa': 'Cacao',
    'coffee': 'Café',
    'buttery': 'Beurré',
    'cheesy': 'Fromager',
    'yeasty': 'Levure',
    'acidic': 'Acidulé',
    'malty': 'Malté',
    'honey': 'Miel',
    'jammy': 'Confiture',
  };

  static String label(String descriptor) => labelsFr[descriptor] ?? descriptor;
}
