// Phase 11 Lot A — demande de conception « recette à l'envers ».
//
// L'utilisateur décrit le plat voulu (cadre, objectifs par aspect,
// priorités, mode) ; le moteur de composition (lot B) compose trois
// recettes candidates qui s'en approchent. La demande est sérialisable
// (JSON) : elle est conservée avec la recette retenue pour
// « Régénérer » ou « Ajuster les objectifs » (lot D, schéma v6).
//
// Décisions PO : phase11-cadrage (D1 à D7).

import 'package:meta/meta.dart';

/// Mode de conception (phase11-cadrage D1).
enum DesignMode {
  /// Cuisine cohérente (défaut) : squelette par type de plat, quantités
  /// bornées par rôle, ingrédients présélectionnés.
  coherent,

  /// Pure Innovation : tout le référentiel est candidat, seuls les
  /// chiffres commandent (bornes physiques seulement).
  pureInnovation;

  static DesignMode parse(String? raw) => raw == DesignMode.pureInnovation.name
      ? DesignMode.pureInnovation
      : DesignMode.coherent;
}

/// Aspect visé (les trois cartes d'objectifs).
enum DesignAspect {
  process,
  flavor,
  nutrition;

  static DesignAspect? parse(String? raw) {
    for (final a in DesignAspect.values) {
      if (a.name == raw) return a;
    }
    return null;
  }

  String get labelFr => switch (this) {
    DesignAspect.process => 'Procédé et physico-chimie',
    DesignAspect.flavor => 'Accords aromatiques',
    DesignAspect.nutrition => 'Nutrition',
  };
}

/// Forme d'un objectif.
enum TargetKind {
  /// Valeur visée, avec une tolérance relative.
  value,

  /// Plage [min, max].
  range,

  /// Minimum.
  min,

  /// Maximum.
  max,

  /// Choix dans une liste (mode de cuisson, Nutri-Score, famille
  /// aromatique, ingrédient pivot).
  choice;

  static TargetKind parse(String? raw) {
    for (final k in TargetKind.values) {
      if (k.name == raw) return k;
    }
    return TargetKind.value;
  }
}

/// Objectif d'un critère.
@immutable
class DesignTarget {
  const DesignTarget._({
    required this.kind,
    this.value,
    this.min,
    this.max,
    this.choice,
    this.tolerance = defaultTolerance,
  });

  const DesignTarget.value(double value, {double tolerance = defaultTolerance})
    : this._(kind: TargetKind.value, value: value, tolerance: tolerance);

  const DesignTarget.range(double min, double max)
    : this._(kind: TargetKind.range, min: min, max: max);

  const DesignTarget.atLeast(double min)
    : this._(kind: TargetKind.min, min: min);

  const DesignTarget.atMost(double max)
    : this._(kind: TargetKind.max, max: max);

  const DesignTarget.choice(String choice)
    : this._(kind: TargetKind.choice, choice: choice);

  /// Tolérance relative par défaut d'une valeur visée (± 10 %).
  static const double defaultTolerance = 0.10;

  final TargetKind kind;
  final double? value;
  final double? min;
  final double? max;
  final String? choice;

  /// Tolérance relative (0..1) d'une valeur visée.
  final double tolerance;

  /// Bornes acceptées : [lower, upper] (null = non borné).
  ({double? lower, double? upper}) get bounds => switch (kind) {
    TargetKind.value => (
      lower: value! - value!.abs() * tolerance,
      upper: value! + value!.abs() * tolerance,
    ),
    TargetKind.range => (lower: min, upper: max),
    TargetKind.min => (lower: min, upper: null),
    TargetKind.max => (lower: null, upper: max),
    TargetKind.choice => (lower: null, upper: null),
  };

  Map<String, Object?> toJson() => {
    'kind': kind.name,
    if (value != null) 'value': value,
    if (min != null) 'min': min,
    if (max != null) 'max': max,
    if (choice != null) 'choice': choice,
    if (kind == TargetKind.value && tolerance != defaultTolerance)
      'tolerance': tolerance,
  };

  static DesignTarget? fromJson(Object? json) {
    if (json is! Map) return null;
    double? d(String k) => (json[k] as num?)?.toDouble();
    final kind = TargetKind.parse(json['kind'] as String?);
    return switch (kind) {
      TargetKind.value when d('value') != null => DesignTarget.value(
        d('value')!,
        tolerance: d('tolerance') ?? defaultTolerance,
      ),
      TargetKind.range when d('min') != null && d('max') != null =>
        DesignTarget.range(d('min')!, d('max')!),
      TargetKind.min when d('min') != null => DesignTarget.atLeast(d('min')!),
      TargetKind.max when d('max') != null => DesignTarget.atMost(d('max')!),
      TargetKind.choice when json['choice'] is String => DesignTarget.choice(
        json['choice'] as String,
      ),
      _ => null,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is DesignTarget &&
      other.kind == kind &&
      other.value == value &&
      other.min == min &&
      other.max == max &&
      other.choice == choice &&
      other.tolerance == tolerance;

  @override
  int get hashCode => Object.hash(kind, value, min, max, choice, tolerance);

  @override
  String toString() => 'DesignTarget(${toJson()})';
}

/// Demande de conception complète.
@immutable
class DesignBrief {
  const DesignBrief({
    this.familyId,
    this.servings = 4,
    this.imposedIds = const <String>[],
    this.excludedIds = const <String>[],
    this.excludedAllergens = const <String>[],
    this.mode = DesignMode.coherent,
    this.priorities = defaultPriorities,
    this.customWeights,
    this.targets = const <String, DesignTarget>{},
  });

  /// Ordre par défaut des priorités (phase11-cadrage D4).
  static const List<DesignAspect> defaultPriorities = [
    DesignAspect.process,
    DesignAspect.flavor,
    DesignAspect.nutrition,
  ];

  /// Poids associés au rang 1, 2, 3 (phase11-cadrage D4).
  static const List<double> rankWeights = [0.6, 0.3, 0.1];

  /// Nombre maximal d'ingrédients d'une recette composée.
  static const int maxIngredients = 12;

  /// Type de plat (famille de squelettes) ; obligatoire en mode
  /// cohérent, facultatif en Pure Innovation (D3).
  final String? familyId;
  final int servings;

  /// Ingrédients imposés (contrainte dure).
  final List<String> imposedIds;

  /// Ingrédients exclus (contrainte dure).
  final List<String> excludedIds;

  /// Allergènes exclus (étiquettes du référentiel : gluten, milk…).
  final List<String> excludedAllergens;
  final DesignMode mode;

  /// Aspects classés du plus au moins important.
  final List<DesignAspect> priorities;

  /// Poids réglés en mode avancé (somme quelconque, normalisée) ; null
  /// = poids du rang (60 / 30 / 10).
  final Map<DesignAspect, double>? customWeights;

  /// Objectifs par identifiant de métrique (voir `DesignMetrics`).
  final Map<String, DesignTarget> targets;

  /// Poids normalisés (somme 1) de chaque aspect.
  Map<DesignAspect, double> get weights {
    final custom = customWeights;
    if (custom != null) {
      final sum = custom.values.fold<double>(0, (s, w) => s + w);
      if (sum > 0) {
        return {for (final a in DesignAspect.values) a: (custom[a] ?? 0) / sum};
      }
    }
    final order = normalizedPriorities;
    return {for (var i = 0; i < order.length; i++) order[i]: rankWeights[i]};
  }

  /// Priorités complétées et dédoublonnées (les trois aspects).
  List<DesignAspect> get normalizedPriorities {
    final out = <DesignAspect>[];
    for (final a in [...priorities, ...defaultPriorities]) {
      if (!out.contains(a)) out.add(a);
    }
    return out;
  }

  /// Ingrédient pivot (objectif aromatique), s'il est demandé.
  String? get pivotId => targets['pivot']?.choice;

  /// Ingrédients qui doivent figurer dans chaque variante (imposés et
  /// pivot).
  List<String> get requiredIds => [
    ...imposedIds,
    if (pivotId != null && !imposedIds.contains(pivotId)) pivotId!,
  ];

  DesignBrief copyWith({
    Object? familyId = _unset,
    int? servings,
    List<String>? imposedIds,
    List<String>? excludedIds,
    List<String>? excludedAllergens,
    DesignMode? mode,
    List<DesignAspect>? priorities,
    Object? customWeights = _unset,
    Map<String, DesignTarget>? targets,
  }) {
    return DesignBrief(
      familyId: identical(familyId, _unset)
          ? this.familyId
          : familyId as String?,
      servings: servings ?? this.servings,
      imposedIds: imposedIds ?? this.imposedIds,
      excludedIds: excludedIds ?? this.excludedIds,
      excludedAllergens: excludedAllergens ?? this.excludedAllergens,
      mode: mode ?? this.mode,
      priorities: priorities ?? this.priorities,
      customWeights: identical(customWeights, _unset)
          ? this.customWeights
          : customWeights as Map<DesignAspect, double>?,
      targets: targets ?? this.targets,
    );
  }

  /// Copie avec un objectif ajouté, remplacé ou retiré (null).
  DesignBrief withTarget(String metricId, DesignTarget? target) {
    final next = {...targets};
    if (target == null) {
      next.remove(metricId);
    } else {
      next[metricId] = target;
    }
    return copyWith(targets: next);
  }

  Map<String, Object?> toJson() => {
    'version': 1,
    if (familyId != null) 'family': familyId,
    'servings': servings,
    if (imposedIds.isNotEmpty) 'imposed': imposedIds,
    if (excludedIds.isNotEmpty) 'excluded': excludedIds,
    if (excludedAllergens.isNotEmpty) 'excludedAllergens': excludedAllergens,
    'mode': mode.name,
    'priorities': [for (final a in normalizedPriorities) a.name],
    if (customWeights != null)
      'weights': {for (final e in customWeights!.entries) e.key.name: e.value},
    'targets': {for (final e in targets.entries) e.key: e.value.toJson()},
  };

  static DesignBrief fromJson(Map<String, Object?> json) {
    List<String> strings(Object? raw) => [
      if (raw is List)
        for (final v in raw)
          if (v is String && v.isNotEmpty) v,
    ];
    final priorities = <DesignAspect>[
      if (json['priorities'] is List)
        for (final p in json['priorities'] as List)
          ?DesignAspect.parse(p as String?),
    ];
    Map<DesignAspect, double>? weights;
    final rawWeights = json['weights'];
    if (rawWeights is Map) {
      weights = {
        for (final e in rawWeights.entries)
          if (DesignAspect.parse(e.key as String?) case final a?)
            if (e.value is num) a: (e.value as num).toDouble(),
      };
    }
    final targets = <String, DesignTarget>{};
    final rawTargets = json['targets'];
    if (rawTargets is Map) {
      for (final e in rawTargets.entries) {
        final t = DesignTarget.fromJson(e.value);
        if (t != null && e.key is String) targets[e.key as String] = t;
      }
    }
    final servings = (json['servings'] as num?)?.toInt() ?? 4;
    return DesignBrief(
      familyId: json['family'] as String?,
      servings: servings < 1 ? 1 : servings,
      imposedIds: strings(json['imposed']),
      excludedIds: strings(json['excluded']),
      excludedAllergens: strings(json['excludedAllergens']),
      mode: DesignMode.parse(json['mode'] as String?),
      priorities: priorities.isEmpty ? defaultPriorities : priorities,
      customWeights: weights,
      targets: targets,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is DesignBrief && _jsonEquals(toJson(), other.toJson());

  @override
  int get hashCode => toJson().toString().hashCode;

  static bool _jsonEquals(Object? a, Object? b) {
    if (a is Map && b is Map) {
      if (a.length != b.length) return false;
      for (final k in a.keys) {
        if (!b.containsKey(k) || !_jsonEquals(a[k], b[k])) return false;
      }
      return true;
    }
    if (a is List && b is List) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (!_jsonEquals(a[i], b[i])) return false;
      }
      return true;
    }
    return a == b;
  }
}

const Object _unset = Object();
