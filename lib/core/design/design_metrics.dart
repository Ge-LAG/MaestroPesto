// Phase 11 Lot A — catalogue des métriques de la conception par
// objectifs.
//
// Chaque métrique décrit un critère que l'utilisateur peut viser :
// identifiant stable (clé des objectifs de `DesignBrief`), aspect,
// unité, sens par défaut (minimum, maximum, cible, choix), moteur
// d'évaluation et règle de couverture. Un critère dont la couverture
// est insuffisante est déclaré « non vérifiable » : jamais de valeur
// supposée (décision honest-data-display).

import 'package:meta/meta.dart';

import 'design_brief.dart';

/// Moteur existant qui mesure la métrique.
enum MetricEngine {
  /// Procédé du gabarit (mode de cuisson).
  process,

  /// `PhysChemEstimator` (composition, Brix, aw, pH).
  physchem,

  /// `FlavorPairingEngine` via l'analyse aromatique de la recette.
  flavor,

  /// `NutritionAggregator` (valeurs par portion).
  nutrition,

  /// `NutritionFeedbackEngine` (Nutri-Score).
  feedback,
}

/// Métrique visable.
@immutable
class DesignMetric {
  const DesignMetric({
    required this.id,
    required this.aspect,
    required this.labelFr,
    required this.unit,
    required this.defaultKind,
    required this.engine,
    required this.coverageRule,
    required this.help,
    this.scale = 1,
    this.digits = 1,
    this.minCoverage = 0.8,
    this.lowerBound = 0,
    this.upperBound,
  });

  final String id;
  final DesignAspect aspect;
  final String labelFr;

  /// Unité affichée (vide pour une grandeur sans unité).
  final String unit;

  /// Sens proposé par défaut dans l'assistant.
  final TargetKind defaultKind;
  final MetricEngine engine;

  /// Règle de couverture (texte affiché dans l'aide et les résultats).
  final String coverageRule;

  /// Aide en langage courant (bouton ⓘ).
  final String help;

  /// Échelle absolue minimale d'un écart (évite qu'une petite valeur
  /// visée rende l'écart relatif démesuré) : l'écart normalisé est
  /// rapporté à max(|visé| × tolérance, scale × tolérance).
  final double scale;

  /// Décimales affichées.
  final int digits;

  /// Couverture minimale (0..1) pour que la valeur soit vérifiable.
  final double minCoverage;

  /// Bornes de saisie.
  final double lowerBound;
  final double? upperBound;

  bool get isChoice => defaultKind == TargetKind.choice;

  String format(double v) {
    final s = v.toStringAsFixed(digits).replaceAll('.', ',');
    return unit.isEmpty ? s : '$s $unit';
  }
}

/// Catalogue (ordre d'affichage dans l'assistant).
abstract final class DesignMetrics {
  static const DesignMetric cookingMethod = DesignMetric(
    id: 'cooking_method',
    aspect: DesignAspect.process,
    labelFr: 'Mode de cuisson',
    unit: '',
    defaultKind: TargetKind.choice,
    engine: MetricEngine.process,
    coverageRule: 'Toujours vérifiable : fixé par le procédé retenu.',
    help:
        'Comment le plat est préparé : cru, mijoté, bouilli, rôti… Le '
        'procédé change la texture, l\'eau qui s\'évapore et les '
        'vitamines conservées.',
  );

  static const DesignMetric dryMatter = DesignMetric(
    id: 'dry_matter',
    aspect: DesignAspect.process,
    labelFr: 'Matière sèche',
    unit: '%',
    defaultKind: TargetKind.value,
    engine: MetricEngine.physchem,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a une composition connue.',
    help:
        'Tout ce qui n\'est pas de l\'eau. Plus elle est haute, plus le '
        'plat est dense ou épais (une soupe ≈ 10 %, une confiture ≈ 65 %).',
    scale: 5,
    upperBound: 100,
  );

  static const DesignMetric fatPhase = DesignMetric(
    id: 'fat_phase',
    aspect: DesignAspect.process,
    labelFr: 'Phase grasse',
    unit: '%',
    defaultKind: TargetKind.value,
    engine: MetricEngine.physchem,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a une composition connue.',
    help:
        'Part de matières grasses dans le mélange. Une mayonnaise en '
        'contient ≈ 80 %, une vinaigrette ≈ 70 %, une ratatouille ≈ 5 %.',
    scale: 3,
    upperBound: 100,
  );

  static const DesignMetric ph = DesignMetric(
    id: 'ph',
    aspect: DesignAspect.process,
    labelFr: 'Acidité (pH)',
    unit: '',
    defaultKind: TargetKind.value,
    engine: MetricEngine.physchem,
    coverageRule:
        'Vérifiable si au moins 50 % de l\'eau du mélange vient '
        'd\'ingrédients au pH documenté.',
    help:
        'Plus le pH est bas, plus c\'est acide (citron ≈ 2,3 ; tomate ≈ '
        '4,3 ; lait ≈ 6,7). Sous 4,6, la conservation est plus sûre.',
    scale: 3,
    digits: 1,
    minCoverage: 0.5,
    lowerBound: 1.5,
    upperBound: 9.5,
  );

  static const DesignMetric aw = DesignMetric(
    id: 'aw',
    aspect: DesignAspect.process,
    labelFr: 'Activité de l\'eau (aw)',
    unit: '',
    defaultKind: TargetKind.max,
    engine: MetricEngine.physchem,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a une composition connue.',
    help:
        'L\'eau « disponible » pour les microbes, de 0 à 1. Sous 0,85 la '
        'plupart des bactéries ne se développent plus (confiture ≈ 0,8).',
    scale: 0.5,
    digits: 2,
    upperBound: 1,
  );

  static const DesignMetric brix = DesignMetric(
    id: 'brix',
    aspect: DesignAspect.process,
    labelFr: 'Sucre dissous (Brix)',
    unit: '%',
    defaultKind: TargetKind.value,
    engine: MetricEngine.physchem,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a une composition connue.',
    help:
        'Part de sucre dans l\'eau du plat. Une confiture « prend » vers '
        '60 à 65 % ; un sirop léger est vers 20 %.',
    scale: 5,
    upperBound: 100,
  );

  static const DesignMetric pivot = DesignMetric(
    id: 'pivot',
    aspect: DesignAspect.flavor,
    labelFr: 'Ingrédient pivot',
    unit: '',
    defaultKind: TargetKind.choice,
    engine: MetricEngine.flavor,
    coverageRule: 'Toujours vérifiable : présent ou absent.',
    help:
        'L\'ingrédient autour duquel le plat est construit : il figure '
        'dans chaque proposition et les autres sont choisis pour '
        's\'accorder avec lui.',
  );

  static const DesignMetric dominantFamily = DesignMetric(
    id: 'dominant_family',
    aspect: DesignAspect.flavor,
    labelFr: 'Famille aromatique dominante',
    unit: '',
    defaultKind: TargetKind.choice,
    engine: MetricEngine.flavor,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a un profil sensoriel.',
    help:
        'La note qui doit ressortir en premier : fruitée, herbacée, '
        'épicée, lactée, grillée…',
  );

  static const DesignMetric harmony = DesignMetric(
    id: 'harmony',
    aspect: DesignAspect.flavor,
    labelFr: 'Harmonie aromatique',
    unit: '',
    defaultKind: TargetKind.min,
    engine: MetricEngine.flavor,
    coverageRule:
        'Vérifiable si au moins deux ingrédients ont un profil sensoriel.',
    help:
        'Note de 0 à 1 de l\'entente des ingrédients deux à deux. Au-dessus '
        'de 0,7 les accords sont bons ; au-dessus de 0,8 ils sont '
        'remarquables.',
    scale: 1,
    digits: 2,
    minCoverage: 0,
    upperBound: 1,
  );

  static const DesignMetric documentedShare = DesignMetric(
    id: 'documented_share',
    aspect: DesignAspect.flavor,
    labelFr: 'Accords documentés',
    unit: '%',
    defaultKind: TargetKind.min,
    engine: MetricEngine.flavor,
    coverageRule:
        'Vérifiable si au moins deux ingrédients ont un profil sensoriel.',
    help:
        'Part des paires d\'ingrédients dont l\'accord est attesté '
        '(observé ou reconnu en cuisine) plutôt que seulement prédit.',
    scale: 100,
    digits: 0,
    minCoverage: 0,
    upperBound: 100,
  );

  static const DesignMetric energy = DesignMetric(
    id: 'energy',
    aspect: DesignAspect.nutrition,
    labelFr: 'Énergie par portion',
    unit: 'kcal',
    defaultKind: TargetKind.value,
    engine: MetricEngine.nutrition,
    coverageRule:
        'Vérifiable si au moins 80 % de la masse a une valeur '
        'énergétique connue.',
    help: 'Les calories d\'une portion (un repas complet ≈ 600 à 800 kcal).',
    scale: 100,
    digits: 0,
    upperBound: 5000,
  );

  static const DesignMetric nutriScore = DesignMetric(
    id: 'nutriscore',
    aspect: DesignAspect.nutrition,
    labelFr: 'Nutri-Score visé',
    unit: '',
    defaultKind: TargetKind.choice,
    engine: MetricEngine.feedback,
    coverageRule:
        'Vérifiable si le Nutri-Score est calculable (plat « général », '
        'données suffisantes).',
    help:
        'La lettre visée, de A (meilleur) à E. Le plat doit obtenir cette '
        'lettre ou mieux.',
  );

  static const DesignMetric proteins = DesignMetric(
    id: 'proteins',
    aspect: DesignAspect.nutrition,
    labelFr: 'Protéines par portion',
    unit: 'g',
    defaultKind: TargetKind.min,
    engine: MetricEngine.nutrition,
    coverageRule: 'Vérifiable si au moins 80 % de la masse est renseignée.',
    help: 'Quantité minimale de protéines d\'une portion.',
    scale: 5,
    upperBound: 300,
  );

  static const DesignMetric salt = DesignMetric(
    id: 'salt',
    aspect: DesignAspect.nutrition,
    labelFr: 'Sel par portion',
    unit: 'g',
    defaultKind: TargetKind.max,
    engine: MetricEngine.nutrition,
    coverageRule: 'Vérifiable si au moins 80 % de la masse est renseignée.',
    help:
        'Quantité maximale de sel d\'une portion (repère : 6 g par jour '
        'pour un adulte).',
    scale: 0.5,
    digits: 2,
    upperBound: 50,
  );

  static const DesignMetric sugars = DesignMetric(
    id: 'sugars',
    aspect: DesignAspect.nutrition,
    labelFr: 'Sucres par portion',
    unit: 'g',
    defaultKind: TargetKind.max,
    engine: MetricEngine.nutrition,
    coverageRule: 'Vérifiable si au moins 80 % de la masse est renseignée.',
    help:
        'Quantité maximale de sucres d\'une portion (repère : 90 g par jour).',
    scale: 5,
    upperBound: 500,
  );

  static const DesignMetric saturatedFats = DesignMetric(
    id: 'saturated_fats',
    aspect: DesignAspect.nutrition,
    labelFr: 'Graisses saturées par portion',
    unit: 'g',
    defaultKind: TargetKind.max,
    engine: MetricEngine.nutrition,
    coverageRule: 'Vérifiable si au moins 80 % de la masse est renseignée.',
    help:
        'Quantité maximale d\'acides gras saturés d\'une portion (repère : '
        '20 g par jour).',
    scale: 2,
    upperBound: 300,
  );

  static const DesignMetric fiber = DesignMetric(
    id: 'fiber',
    aspect: DesignAspect.nutrition,
    labelFr: 'Fibres par portion',
    unit: 'g',
    defaultKind: TargetKind.min,
    engine: MetricEngine.nutrition,
    coverageRule: 'Vérifiable si au moins 80 % de la masse est renseignée.',
    help:
        'Quantité minimale de fibres d\'une portion (repère : 30 g par jour).',
    scale: 2,
    upperBound: 200,
  );

  static const List<DesignMetric> all = [
    cookingMethod,
    dryMatter,
    fatPhase,
    ph,
    aw,
    brix,
    pivot,
    dominantFamily,
    harmony,
    documentedShare,
    energy,
    nutriScore,
    proteins,
    salt,
    sugars,
    saturatedFats,
    fiber,
  ];

  static final Map<String, DesignMetric> byId = {for (final m in all) m.id: m};

  static DesignMetric? of(String id) => byId[id];

  static List<DesignMetric> ofAspect(DesignAspect aspect) => [
    for (final m in all)
      if (m.aspect == aspect) m,
  ];

  /// Grades du Nutri-Score, du meilleur au moins bon.
  static const List<String> nutriGrades = ['A', 'B', 'C', 'D', 'E'];

  /// Familles aromatiques proposées (racines de l'ontologie Phase 3).
  static const List<String> aromaFamilies = [
    'fruity',
    'green',
    'floral',
    'spicy',
    'earthy',
    'nutty',
    'roasted',
    'caramel',
    'dairy',
    'vanillic',
    'woody',
    'marine',
    'meaty',
    'cocoa',
    'fermented',
    'smoky',
    'sulfurous',
  ];
}
