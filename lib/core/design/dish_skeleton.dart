// Phase 11 Lot A — squelettes de plats et gabarits de procédé.
//
// Un squelette décrit une manière culinairement plausible de composer un
// type de plat : des rôles (base, liant, matière grasse, acide,
// aromatique, assaisonnement…), chacun avec ses ingrédients candidats,
// un nombre d'ingrédients et des bornes de masse par portion, et un
// gabarit de procédé (mode de cuisson, masse par portion, durée
// réglable, étapes à trous). Les squelettes d'une même famille (type de
// plat) sont explorés ensemble par le moteur de composition.
//
// Données curatées : tool/data/dish_skeletons.csv et
// dish_processes.csv → assets/database-enrichment/ (générateur
// tool/generate_dish_skeletons.dart), importées en base (schéma v6).
//
// Gabarit d'étape :
//   {role}            ingrédients du rôle (« basilic, ail et parmesan ») ;
//   {role1;role2}     union de plusieurs rôles ;
//   {*}               tous les ingrédients ;
//   {duree}           durée réglable du procédé (min) ;
//   [ … ]             segment facultatif, retiré si ses rôles sont vides.
// Une étape dont tous les rôles cités sont vides est retirée.

import 'package:meta/meta.dart';

import '../models/process_models.dart';

/// Rôle d'un squelette.
@immutable
class SkeletonRole {
  const SkeletonRole({
    required this.skeletonId,
    required this.role,
    required this.label,
    required this.minCount,
    required this.maxCount,
    required this.minGPerServing,
    required this.maxGPerServing,
    required this.candidates,
    this.note,
  });

  final String skeletonId;
  final String role;
  final String label;
  final int minCount;
  final int maxCount;

  /// Bornes de masse (g par portion) de CHAQUE ingrédient du rôle.
  final double minGPerServing;
  final double maxGPerServing;

  /// Identifiants `ING-*` candidats, par ordre de préférence.
  final List<String> candidates;
  final String? note;

  bool get isRequired => minCount > 0;
}

/// Gabarit de procédé d'un squelette.
@immutable
class ProcessTemplate {
  const ProcessTemplate({
    required this.method,
    required this.steps,
    required this.servingMassG,
    required this.servingMinG,
    required this.servingMaxG,
    this.durationMin,
    this.durationDefault,
    this.durationMax,
    this.source,
  });

  /// Mode de cuisson principal (critère « mode de cuisson »).
  final CookingMethod method;

  /// Étapes à trous (voir l'en-tête du fichier).
  final List<String> steps;

  /// Masse d'une portion (g) : défaut et bornes.
  final double servingMassG;
  final double servingMinG;
  final double servingMaxG;

  /// Durée réglable ({duree}, min) ; null = durée fixe.
  final double? durationMin;
  final double? durationDefault;
  final double? durationMax;
  final String? source;

  bool get hasDuration =>
      durationMin != null && durationMax != null && durationDefault != null;

  /// Rôles cités par les étapes.
  Set<String> get referencedRoles => {
    for (final s in steps)
      for (final m in _placeholder.allMatches(s))
        if (m.group(1) != 'duree') ...m.group(1)!.split(';'),
  };

  /// Étapes rédigées. [namesByRole] : noms (déjà mis en forme) des
  /// ingrédients de chaque rôle ; la clé `*` n'est pas nécessaire (tous
  /// les noms sont réunis). [duration] : durée retenue (min).
  List<String> render(
    Map<String, List<String>> namesByRole, {
    double? duration,
  }) {
    final everyone = <String>[for (final names in namesByRole.values) ...names];
    List<String> namesOf(String spec) {
      if (spec == '*') return everyone;
      final out = <String>[];
      for (final role in spec.split(';')) {
        for (final n in namesByRole[role.trim()] ?? const <String>[]) {
          if (!out.contains(n)) out.add(n);
        }
      }
      return out;
    }

    final d = duration ?? durationDefault;
    final out = <String>[];
    for (final template in steps) {
      var anyRole = false;
      var anyFilled = false;
      String fill(String text) => text.replaceAllMapped(_placeholder, (m) {
        final spec = m.group(1)!;
        if (spec == 'duree') return d == null ? '' : _formatMinutes(d);
        anyRole = true;
        final names = namesOf(spec);
        if (names.isNotEmpty) anyFilled = true;
        return joinFr(names);
      });
      // Segments facultatifs : retirés si leurs rôles sont vides.
      final withOptional = template.replaceAllMapped(_optional, (m) {
        final inner = m.group(1)!;
        final roles = [
          for (final p in _placeholder.allMatches(inner))
            if (p.group(1) != 'duree') p.group(1)!,
        ];
        final empty =
            roles.isNotEmpty && roles.every((r) => namesOf(r).isEmpty);
        return empty ? '' : inner;
      });
      final text = fill(withOptional);
      if (anyRole && !anyFilled) continue;
      out.add(_tidy(text));
    }
    return out;
  }

  static final RegExp _placeholder = RegExp(r'\{([^}]+)\}');
  static final RegExp _optional = RegExp(r'\[([^\]]*)\]');

  static String _formatMinutes(double minutes) {
    final m = minutes.round();
    return '$m';
  }

  /// « a », « a et b », « a, b et c ».
  static String joinFr(List<String> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    return '${names.sublist(0, names.length - 1).join(', ')} et ${names.last}';
  }

  static String _tidy(String s) => s
      .replaceAll(RegExp(r'\s+'), ' ')
      .replaceAll(' ,', ',')
      .replaceAll(' .', '.')
      .trim();
}

/// Squelette complet.
@immutable
class DishSkeleton {
  const DishSkeleton({
    required this.id,
    required this.familyId,
    required this.familyLabel,
    required this.label,
    required this.roles,
    required this.process,
  });

  final String id;
  final String familyId;
  final String familyLabel;
  final String label;
  final List<SkeletonRole> roles;
  final ProcessTemplate process;

  /// Squelette générique de Pure Innovation (sans rôles).
  bool get isGeneric => roles.isEmpty;

  SkeletonRole? role(String id) {
    for (final r in roles) {
      if (r.role == id) return r;
    }
    return null;
  }

  /// Rôles dont un candidat est [ingredientId].
  List<SkeletonRole> rolesOf(String ingredientId) => [
    for (final r in roles)
      if (r.candidates.contains(ingredientId)) r,
  ];
}

/// Type de plat (famille de squelettes).
@immutable
class DishFamily {
  const DishFamily({
    required this.id,
    required this.label,
    required this.skeletons,
  });

  final String id;
  final String label;
  final List<DishSkeleton> skeletons;

  /// Famille des procédés génériques (Pure Innovation seulement).
  bool get isGeneric => id == DishCatalog.genericFamilyId;

  /// Masse par portion par défaut de la famille (moyenne des
  /// squelettes).
  double get servingMassG =>
      skeletons.fold<double>(0, (s, k) => s + k.process.servingMassG) /
      skeletons.length;

  Set<CookingMethod> get methods => {
    for (final s in skeletons) s.process.method,
  };
}

/// Catalogue des squelettes.
@immutable
class DishCatalog {
  const DishCatalog(this.skeletons);

  static const String genericFamilyId = 'libre';

  final List<DishSkeleton> skeletons;

  static const DishCatalog empty = DishCatalog(<DishSkeleton>[]);

  bool get isEmpty => skeletons.isEmpty;

  /// Familles, dans l'ordre du fichier.
  List<DishFamily> get families {
    final order = <String>[];
    final byFamily = <String, List<DishSkeleton>>{};
    for (final s in skeletons) {
      if (!byFamily.containsKey(s.familyId)) order.add(s.familyId);
      byFamily.putIfAbsent(s.familyId, () => []).add(s);
    }
    return [
      for (final id in order)
        DishFamily(
          id: id,
          label: byFamily[id]!.first.familyLabel,
          skeletons: byFamily[id]!,
        ),
    ];
  }

  /// Familles proposées à l'utilisateur (hors procédés génériques).
  List<DishFamily> get dishFamilies => [
    for (final f in families)
      if (!f.isGeneric) f,
  ];

  DishFamily? family(String? id) {
    if (id == null) return null;
    for (final f in families) {
      if (f.id == id) return f;
    }
    return null;
  }

  DishSkeleton? skeleton(String id) {
    for (final s in skeletons) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Procédés génériques (Pure Innovation).
  List<DishSkeleton> get generic => [
    for (final s in skeletons)
      if (s.familyId == genericFamilyId) s,
  ];

  /// Construit le catalogue depuis les lignes des deux fichiers (clés =
  /// en-têtes CSV). Les lignes invalides sont ignorées.
  static DishCatalog fromRows({
    required List<Map<String, String?>> roleRows,
    required List<Map<String, String?>> processRows,
  }) {
    String? s(Map<String, String?> r, String k) {
      final v = r[k]?.trim();
      return v == null || v.isEmpty ? null : v;
    }

    double? d(Map<String, String?> r, String k) {
      final v = s(r, k);
      return v == null ? null : double.tryParse(v.replaceAll(',', '.'));
    }

    final roles = <String, List<SkeletonRole>>{};
    for (final r in roleRows) {
      final id = s(r, 'skeleton_id');
      final role = s(r, 'role');
      final minG = d(r, 'min_g_per_serving');
      final maxG = d(r, 'max_g_per_serving');
      final candidates = [
        for (final c in (s(r, 'candidates') ?? '').split('|'))
          if (c.trim().isNotEmpty) c.trim(),
      ];
      if (id == null || role == null || minG == null || maxG == null) {
        continue;
      }
      if (candidates.isEmpty || maxG < minG) continue;
      final minCount = int.tryParse(s(r, 'min_count') ?? '') ?? 0;
      final maxCount = int.tryParse(s(r, 'max_count') ?? '') ?? 1;
      roles
          .putIfAbsent(id, () => [])
          .add(
            SkeletonRole(
              skeletonId: id,
              role: role,
              label: s(r, 'role_label') ?? role,
              minCount: minCount,
              maxCount: maxCount < minCount ? minCount : maxCount,
              minGPerServing: minG,
              maxGPerServing: maxG,
              candidates: candidates,
              note: s(r, 'note'),
            ),
          );
    }
    final skeletons = <DishSkeleton>[];
    for (final r in processRows) {
      final id = s(r, 'skeleton_id');
      final family = s(r, 'family_id');
      final method = CookingMethod.fromId(s(r, 'method'));
      final mass = d(r, 'serving_mass_g');
      final steps = [
        for (final step in (s(r, 'steps') ?? '').split(' | '))
          if (step.trim().isNotEmpty) step.trim(),
      ];
      if (id == null || family == null || method == null || mass == null) {
        continue;
      }
      if (steps.isEmpty) continue;
      skeletons.add(
        DishSkeleton(
          id: id,
          familyId: family,
          familyLabel: s(r, 'family_label') ?? family,
          label: s(r, 'skeleton_label') ?? id,
          roles: roles[id] ?? const [],
          process: ProcessTemplate(
            method: method,
            steps: steps,
            servingMassG: mass,
            servingMinG: d(r, 'serving_min_g') ?? mass * 0.5,
            servingMaxG: d(r, 'serving_max_g') ?? mass * 1.5,
            durationMin: d(r, 'duration_min'),
            durationDefault: d(r, 'duration_default'),
            durationMax: d(r, 'duration_max'),
            source: s(r, 'source'),
          ),
        ),
      );
    }
    return DishCatalog(skeletons);
  }
}
