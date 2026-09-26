// Phase 10 Lot F — estimation physico-chimique d'un mélange (« X-ray »).
//
// À partir des lignes de la recette (masse, composition Ciqual,
// composants fonctionnels, pH typique) et des étapes analysées, estime :
//
// - la composition du mélange (eau, lipides, protéines, sucres,
//   amidon, sel, alcool, fibres) et la matière sèche ;
// - le degré Brix de la phase aqueuse : sucres / (sucres + eau) ;
// - l'activité de l'eau aw (loi de Raoult sur les fractions molaires,
//   correction de Norrish pour le saccharose, K = 6,47) ;
// - le pH (moyenne des [H⁺] pondérée par l'eau de chaque ingrédient ;
//   acidulants secs par dilution d'acide faible, pH = pH₁% − ½ log C) —
//   sans pouvoir tampon : estimation grossière, signalée comme telle ;
// - la fraction de phase grasse liquide d'une émulsion ;
// - le profil thermique et mécanique issu des étapes.
//
// Toutes les grandeurs sont des estimations d'ordre de grandeur, pour
// évaluer les conditions des règles Phase 4 — jamais des mesures.

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../models/nutrition_profile.dart';
import 'process_step_parser.dart';

/// Ligne de mélange (masse réelle mise en œuvre).
@immutable
class MixLine {
  const MixLine({
    required this.index,
    required this.label,
    required this.grams,
    this.ingredientId,
    this.profile,
    this.components = const <String, double>{},
    this.ph,
    this.isLiquidOil = false,
    this.tags = const <String>{},
  });

  final int index;
  final String label;
  final String? ingredientId;
  final double grams;

  /// Composition pour 100 g (null = inconnue).
  final NutritionProfile? profile;

  /// Composants fonctionnels (g pour 100 g d'ingrédient).
  final Map<String, double> components;

  /// pH typique de l'ingrédient (null = inconnu).
  final double? ph;

  /// Huile ou graisse liquide (phase grasse d'une émulsion).
  final bool isLiquidOil;

  /// Étiquettes de rôle (yeast, egg, dairy_liquid, acidulant,
  /// protease_fruit…) dérivées du référentiel par le service d'analyse.
  final Set<String> tags;
}

/// État physico-chimique estimé d'un mélange.
@immutable
class PhysChemState {
  const PhysChemState({
    required this.totalMassG,
    required this.waterG,
    required this.fatG,
    required this.proteinG,
    required this.sugarG,
    required this.starchG,
    required this.saltG,
    required this.alcoholG,
    required this.fiberG,
    required this.componentsG,
    required this.componentSources,
    required this.compositionCoverage,
    required this.liquidOilG,
    required this.steps,
    this.brix,
    this.aw,
    this.ph,
    this.phCoverage = 0,
    this.lineGrams = const <int, double>{},
    this.lineIngredientIds = const <int, String>{},
    this.tags = const <String, List<int>>{},
  });

  final double totalMassG;
  final double waterG;
  final double fatG;
  final double proteinG;
  final double sugarG;
  final double starchG;
  final double saltG;
  final double alcoholG;
  final double fiberG;

  /// Masse de chaque composant fonctionnel dans le mélange (g).
  final Map<String, double> componentsG;

  /// Lignes (indices) qui apportent chaque composant.
  final Map<String, List<int>> componentSources;

  /// Part massique des lignes dont la composition est connue (0..1).
  final double compositionCoverage;

  /// Masse d'huile/graisse liquide (g).
  final double liquidOilG;
  final List<ParsedStep> steps;

  /// Brix de la phase aqueuse (%).
  final double? brix;

  /// Activité de l'eau estimée (null si trop peu d'eau connue).
  final double? aw;

  /// pH estimé (null sans ingrédient au pH connu).
  final double? ph;

  /// Part de l'eau du mélange portée par des ingrédients au pH connu.
  final double phCoverage;

  /// Masse (g) et ingrédient de chaque ligne (index → valeur).
  final Map<int, double> lineGrams;
  final Map<int, String> lineIngredientIds;

  /// Étiquettes de rôle → lignes concernées.
  final Map<String, List<int>> tags;

  bool hasTag(String tag) => tags[tag]?.isNotEmpty ?? false;

  /// Part massique (0..1) d'un ensemble de lignes.
  double shareOfLines(Iterable<int> lines) {
    if (totalMassG <= 0) return 0;
    final g = lines.toSet().fold<double>(0, (s, i) => s + (lineGrams[i] ?? 0));
    return g / totalMassG;
  }

  double _pct(double g) => totalMassG <= 0 ? 0 : g / totalMassG * 100;

  double get waterPct => _pct(waterG);
  double get fatPct => _pct(fatG);
  double get proteinPct => _pct(proteinG);
  double get sugarPct => _pct(sugarG);
  double get starchPct => _pct(starchG);
  double get saltPct => _pct(saltG);
  double get alcoholPct => _pct(alcoholG);
  double get dryMatterPct => totalMassG <= 0 ? 0 : 100 - waterPct;

  /// Part d'un composant fonctionnel dans le mélange (%).
  double componentPct(String componentId) =>
      _pct(componentsG[componentId] ?? 0);

  bool hasComponent(String componentId, {double minPct = 0.05}) =>
      componentPct(componentId) >= minPct;

  /// Fraction de phase grasse liquide : huile / (huile + eau).
  double? get oilPhaseFraction {
    final denom = liquidOilG + waterG;
    if (liquidOilG <= 0 || denom <= 0) return null;
    return liquidOilG / denom;
  }

  /// Température maximale atteinte (°C) sur les étapes chauffées.
  double? get maxTemperatureC {
    double? max;
    for (final s in steps) {
      if (!s.isThermal) continue;
      final t = s.temperatureC;
      if (t != null && (max == null || t > max)) max = t;
    }
    return max;
  }

  /// Température maximale en chaleur sèche (surface, Maillard).
  double? get maxDryHeatC {
    double? max;
    for (final s in steps) {
      if (!s.isDryHeat) continue;
      final t = s.temperatureC;
      if (t != null && (max == null || t > max)) max = t;
    }
    return max;
  }

  /// Durée cumulée des étapes chauffées (min), null si inconnue.
  double? get heatingMinutes {
    double? total;
    for (final s in steps) {
      if (!s.isThermal || s.durationMin == null) continue;
      total = (total ?? 0) + s.durationMin!;
    }
    return total;
  }

  bool get hasHeating => steps.any((s) => s.isThermal);
  bool get hasShear => steps.any((s) => s.hasShear);
  bool get hasCooling => steps.any((s) => s.isCooling);
  bool get hasKneading =>
      steps.any((s) => s.operations.any((o) => o.opId == 'PROC_PETRIR'));

  /// Refroidissement après une étape chauffée.
  bool get coolingAfterHeating {
    var heated = false;
    for (final s in steps) {
      if (s.isThermal) heated = true;
      if (heated && s.isCooling) return true;
    }
    return false;
  }
}

abstract final class PhysChemEstimator {
  /// Estime l'état du mélange.
  static PhysChemState estimate(
    List<MixLine> lines, {
    List<ParsedStep> steps = const <ParsedStep>[],
  }) {
    var total = 0.0;
    var known = 0.0;
    var water = 0.0;
    var fat = 0.0;
    var protein = 0.0;
    var sugar = 0.0;
    var starch = 0.0;
    var salt = 0.0;
    var alcohol = 0.0;
    var fiber = 0.0;
    var oil = 0.0;
    var sucrose = 0.0;
    var monosaccharides = 0.0;
    var polyols = 0.0;
    final components = <String, double>{};
    final sources = <String, List<int>>{};
    final lineGrams = <int, double>{};
    final lineIds = <int, String>{};
    final tags = <String, List<int>>{};

    for (final line in lines) {
      final g = line.grams;
      if (g <= 0) continue;
      total += g;
      lineGrams[line.index] = g;
      if (line.ingredientId != null) lineIds[line.index] = line.ingredientId!;
      for (final tag in line.tags) {
        tags.putIfAbsent(tag, () => []).add(line.index);
      }
      final p = line.profile;
      final f = g / 100;
      if (p != null && p.recordCount > 0) {
        known += g;
        water += (p.waterContent ?? 0) * f;
        fat += p.fats * f;
        protein += p.proteins * f;
        sugar +=
            (p.isKnown(MacroField.sugars)
                ? p.sugars
                : (line.components['SM_SUCROSE'] ?? 0) +
                      (line.components['SM_GLU_MONO'] ?? 0) +
                      (line.components['SM_FRUCTOSE'] ?? 0)) *
            f;
        starch += (p.micronutrients['STARCH']?.value ?? 0) * f;
        salt += p.salt * f;
        alcohol += p.alcohol * f;
        fiber += p.fiber * f;
        polyols += (p.micronutrients['POLYOLS']?.value ?? 0) * f;
        final suc =
            line.components['SM_SUCROSE'] ??
            p.micronutrients['SACCHAROSE']?.value;
        if (suc != null) sucrose += suc * f;
        final glu =
            (line.components['SM_GLU_MONO'] ?? 0) +
            (line.components['SM_FRUCTOSE'] ?? 0);
        monosaccharides += glu * f;
      }
      if (line.isLiquidOil) oil += (p?.fats ?? 100) * f;
      line.components.forEach((cid, per100) {
        components[cid] = (components[cid] ?? 0) + per100 * f;
        sources.putIfAbsent(cid, () => []).add(line.index);
      });
    }

    // Brix de la phase aqueuse.
    double? brix;
    if (water + sugar > 0 && known > 0) {
      brix = sugar / (sugar + water) * 100;
    }

    // aw : Raoult + Norrish (saccharose).
    double? aw;
    if (water > 0 && known > 0) {
      final otherSugar = math.max(0.0, sugar - sucrose - monosaccharides);
      final nWater = water / 18.015;
      final nSucrose = (sucrose + otherSugar) / 342.3;
      final nMono = monosaccharides / 180.16;
      final nSalt = 2 * salt / 58.44;
      final nAlcohol = alcohol / 46.07;
      final nPolyol = polyols / 182.17;
      final nTotal = nWater + nSucrose + nMono + nSalt + nAlcohol + nPolyol;
      final xWater = nWater / nTotal;
      final xSucrose = nSucrose / nTotal;
      aw = (xWater * math.exp(-6.47 * xSucrose * xSucrose)).clamp(0.0, 1.0);
      // Système très sec : la sorption domine, Raoult ne s'applique plus.
      if (water / total < 0.08) aw = math.min(aw, 0.6);
    }

    // pH : [H⁺] pondérée par l'eau + acidulants secs.
    var hSum = 0.0;
    var hWeight = 0.0;
    var dryAcidH = 0.0;
    for (final line in lines) {
      final pH = line.ph;
      if (pH == null || line.grams <= 0) continue;
      final w = (line.profile?.waterContent ?? 0) * line.grams / 100;
      if (w >= line.grams * 0.2) {
        hSum += w * math.pow(10, -pH);
        hWeight += w;
      } else if (pH < 4.5 && water > 0) {
        // Acidulant sec : pH d'une solution à 1 %, dilution d'acide
        // faible (pH = pH₁% − ½·log₁₀(C/1 %)), C rapportée à la phase
        // aqueuse (eau + sucres dissous).
        final c = line.grams / (water + sugar) * 100;
        if (c > 0) {
          final phEff = pH - 0.5 * (math.log(c) / math.ln10);
          dryAcidH += math.pow(10, -phEff);
        }
      }
    }
    double? ph;
    if (hWeight > 0 || dryAcidH > 0) {
      // L'eau sans pH connu (eau ajoutée, sucre dissous…) est neutre.
      final neutral = math.max(0.0, water - hWeight);
      final h =
          (hSum + neutral * 1e-7) / math.max(hWeight + neutral, 1e-9) +
          dryAcidH;
      ph = (-math.log(h) / math.ln10).clamp(1.5, 9.5);
    }
    // Fermentation : levain/levure acidifient la pâte (pH ≈ 5,5) ;
    // lacto-fermentation longue d'un légume salé (pH ≈ 4).
    final fermenting = steps.any(
      (s) => s.operations.any(
        (o) => o.opId == 'PROC_FERMENTER' || o.opId == 'PROC_FAIRE_LEVER',
      ),
    );
    if (fermenting) {
      final yeast = lines.any((l) => l.tags.contains('yeast'));
      if (yeast) ph = math.min(ph ?? 7, 5.6);
      final longFerment = steps.any(
        (s) =>
            s.operations.any((o) => o.opId == 'PROC_FERMENTER') &&
            ((s.durationMin ?? 0) >= 1440 || s.text.contains('jour')),
      );
      if (longFerment && !yeast && salt > 0) ph = math.min(ph ?? 7, 4.2);
    }

    return PhysChemState(
      totalMassG: total,
      waterG: water,
      fatG: fat,
      proteinG: protein,
      sugarG: sugar,
      starchG: starch,
      saltG: salt,
      alcoholG: alcohol,
      fiberG: fiber,
      componentsG: components,
      componentSources: sources,
      compositionCoverage: total <= 0 ? 0 : known / total,
      liquidOilG: oil,
      steps: steps,
      brix: brix,
      aw: aw,
      ph: ph,
      phCoverage: water <= 0 ? 0 : math.min(1.0, hWeight / water),
      lineGrams: lineGrams,
      lineIngredientIds: lineIds,
      tags: tags,
    );
  }
}
