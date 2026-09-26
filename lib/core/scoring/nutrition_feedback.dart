// Phase 10 Lot G — feedback nutritionnel d'une recette.
//
// Référentiels (valeurs publiques, reprises telles quelles) :
// - Nutri-Score, algorithme mis à jour en 2023 pour les aliments
//   généraux (Santé publique France / comité scientifique européen) :
//   points négatifs énergie, sucres, AGS, sel ; positifs fibres,
//   protéines, fruits-légumes-légumineuses ; classes A ≤ 0, B 1–2,
//   C 3–10, D 11–18, E ≥ 19. Calculé ici sur 100 g de plat (après
//   procédé) : ESTIMATION indicative, jamais un étiquetage.
// - Apports de référence et VNR : règlement (UE) 1169/2011 annexe XIII.
// - Allégations nutritionnelles : règlement (CE) 1924/2006, annexe.
// - Répartition énergétique : repères ANSES adulte (protéines 10–20 %,
//   lipides 35–40 %, glucides 40–55 % de l'énergie).
//
// Honnêteté : une allégation ou une composante n'est calculée que si la
// couverture massique du nutriment est suffisante ; sinon elle est
// absente et la raison est donnée.

import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../models/nutrient_catalog.dart';
import '../models/nutrition_profile.dart';
import 'nutrition_aggregator.dart';

/// Classe « fruits, légumes, légumineuses » d'un ingrédient.
enum FvlClass { fruit, vegetable, legume, none }

/// Catégorie Nutri-Score dominante d'une recette.
enum NutriScoreCategory { general, beverage, fatOilNut, cheese }

@immutable
class NutriScoreResult {
  const NutriScoreResult({
    required this.grade,
    required this.score,
    required this.negativePoints,
    required this.positivePoints,
    required this.components,
    required this.fvlPercent,
    this.proteinCounted = true,
    this.redMeatCap = false,
    this.lowCoverage = false,
  });

  /// A..E.
  final String grade;
  final int score;
  final int negativePoints;
  final int positivePoints;

  /// Points par composante (energy, sugars, saturatedFats, salt,
  /// protein, fiber, fvl).
  final Map<String, int> components;
  final double fvlPercent;
  final bool proteinCounted;
  final bool redMeatCap;

  /// Couverture des nutriments insuffisante : score très indicatif.
  final bool lowCoverage;
}

/// Ligne « % des apports de référence » par portion.
@immutable
class ReferenceIntakeLine {
  const ReferenceIntakeLine({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.percent,
    required this.source,
    this.coverage = 1,
  });

  final String key;
  final String label;
  final double value;
  final String unit;
  final double percent;
  final String source;
  final double coverage;
}

/// Allégation nutritionnelle indicative.
@immutable
class NutritionClaim {
  const NutritionClaim({required this.label, required this.basis});

  final String label;

  /// Seuil réglementaire atteint (« 7,2 g de fibres/100 g ≥ 6 g »).
  final String basis;
}

/// Point saillant (positif ou vigilance).
@immutable
class NutritionHighlight {
  const NutritionHighlight({required this.positive, required this.text});

  final bool positive;
  final String text;
}

@immutable
class EnergySplit {
  const EnergySplit({
    required this.proteinPct,
    required this.carbsPct,
    required this.fatPct,
    required this.alcoholPct,
    required this.fiberPct,
  });

  final double proteinPct;
  final double carbsPct;
  final double fatPct;
  final double alcoholPct;
  final double fiberPct;
}

@immutable
class NutritionFeedback {
  const NutritionFeedback({
    required this.category,
    required this.nutriScore,
    required this.nutriScoreNote,
    required this.intakes,
    required this.micronutrientIntakes,
    required this.claims,
    required this.highlights,
    required this.energySplit,
    required this.servingMassG,
    required this.dishMassG,
  });

  final NutriScoreCategory category;

  /// Null quand l'algorithme général ne s'applique pas ou sans données.
  final NutriScoreResult? nutriScore;

  /// Raison d'absence ou hypothèses du Nutri-Score.
  final String nutriScoreNote;
  final List<ReferenceIntakeLine> intakes;
  final List<ReferenceIntakeLine> micronutrientIntakes;
  final List<NutritionClaim> claims;
  final List<NutritionHighlight> highlights;
  final EnergySplit? energySplit;
  final double servingMassG;
  final double dishMassG;
}

abstract final class NutritionFeedbackEngine {
  /// Couverture massique minimale pour calculer une composante.
  static const double minCoverage = 0.8;

  static const List<double> _energyKj = [
    335,
    670,
    1005,
    1340,
    1675,
    2010,
    2345,
    2680,
    3015,
    3350,
  ];
  static const List<double> _sugars2023 = [
    3.4,
    6.8,
    10,
    14,
    17,
    20,
    24,
    27,
    31,
    34,
    37,
    41,
    44,
    48,
    51,
  ];
  static const List<double> _satFat = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
  static final List<double> _salt2023 = [for (var i = 1; i <= 20; i++) i * 0.2];
  static const List<double> _protein2023 = [2.4, 4.8, 7.2, 9.6, 12, 14, 17];
  static const List<double> _fiber2023 = [3.0, 4.1, 5.2, 6.3, 7.4];

  static int _points(double value, List<double> thresholds) {
    var p = 0;
    for (final t in thresholds) {
      if (value > t + 1e-9) p++;
    }
    return p;
  }

  static int fvlPoints(double percent) {
    if (percent > 80) return 5;
    if (percent > 60) return 2;
    if (percent > 40) return 1;
    return 0;
  }

  static String grade(int score) {
    if (score <= 0) return 'A';
    if (score <= 2) return 'B';
    if (score <= 10) return 'C';
    if (score <= 18) return 'D';
    return 'E';
  }

  /// Nutri-Score 2023 (aliments généraux) pour 100 g.
  static NutriScoreResult nutriScore(
    NutritionProfile per100g, {
    required double fvlPercent,
    bool redMeat = false,
    bool lowCoverage = false,
  }) {
    final energyKj = per100g.energyKcal * 4.184;
    final c = <String, int>{
      'energy': _points(energyKj, _energyKj),
      'sugars': _points(per100g.sugars, _sugars2023),
      'saturatedFats': _points(per100g.saturatedFats, _satFat),
      'salt': _points(per100g.salt, _salt2023),
      'fiber': _points(per100g.fiber, _fiber2023),
      'fvl': fvlPoints(fvlPercent),
    };
    var protein = _points(per100g.proteins, _protein2023);
    if (redMeat) protein = math.min(protein, 2);
    final negative =
        c['energy']! + c['sugars']! + c['saturatedFats']! + c['salt']!;
    final proteinCounted = negative < 11 || c['fvl'] == 5;
    c['protein'] = protein;
    final positive = c['fiber']! + c['fvl']! + (proteinCounted ? protein : 0);
    final score = negative - positive;
    return NutriScoreResult(
      grade: grade(score),
      score: score,
      negativePoints: negative,
      positivePoints: positive,
      components: c,
      fvlPercent: fvlPercent,
      proteinCounted: proteinCounted,
      redMeatCap: redMeat,
      lowCoverage: lowCoverage,
    );
  }

  /// Feedback complet d'une agrégation. [fvlFor] classe chaque
  /// ingrédient ; [categoryFor] renvoie sa catégorie de niveau 1 et 2
  /// (boisson, matière grasse, fromage, viande rouge…).
  static NutritionFeedback evaluate(
    NutritionAggregation aggregation, {
    required FvlClass Function(String ingredientId) fvlFor,
    required ({String level1, String level2, String name}) Function(
      String ingredientId,
    )
    categoryFor,
  }) {
    final per100 = aggregation.profilePer100g;
    final serving = aggregation.profilePerServing;
    final coverage = aggregation.nutrientCoverage;
    double cov(MacroField f) => coverage[f] ?? 0;

    // Parts massiques par famille (masse crue).
    var total = 0.0;
    var fvl = 0.0;
    var beverage = 0.0;
    var fatOil = 0.0;
    var cheese = 0.0;
    final redMeatByLine = <double>[];
    var largest = 0.0;
    var largestIsRedMeat = false;
    for (final c in aggregation.contributions) {
      final g = c.rawGrams;
      final id = c.ingredientId;
      if (g == null || g <= 0) continue;
      total += g;
      if (id == null) continue;
      if (fvlFor(id) != FvlClass.none) fvl += g;
      final cat = categoryFor(id);
      if (cat.level1 == 'boisson') beverage += g;
      if (cat.level2 == 'matière grasse' || cat.level2 == 'fruit sec') {
        fatOil += g;
      }
      final isCheese =
          cat.level2 == 'produit laitier' && _cheese.hasMatch(cat.name);
      if (isCheese) cheese += g;
      final isRedMeat =
          cat.level2 == 'viande' && _redMeat.hasMatch(cat.name.toLowerCase());
      if (isRedMeat) redMeatByLine.add(g);
      if (g > largest) {
        largest = g;
        largestIsRedMeat = isRedMeat;
      }
    }
    final fvlPercent = total <= 0 ? 0.0 : fvl / total * 100;
    final category = total <= 0
        ? NutriScoreCategory.general
        : beverage / total >= 0.8
        ? NutriScoreCategory.beverage
        : fatOil / total >= 0.8
        ? NutriScoreCategory.fatOilNut
        : cheese / total >= 0.8
        ? NutriScoreCategory.cheese
        : NutriScoreCategory.general;

    NutriScoreResult? score;
    String note;
    final keyFields = [
      MacroField.energy,
      MacroField.sugars,
      MacroField.saturatedFats,
      MacroField.salt,
      MacroField.proteins,
      MacroField.fiber,
    ];
    final minCov = keyFields.map(cov).fold<double>(1, math.min);
    if (per100 == null || !aggregation.hasData) {
      note = 'Nutri-Score non calculé : aucune donnée nutritionnelle.';
    } else if (category != NutriScoreCategory.general) {
      note = switch (category) {
        NutriScoreCategory.beverage =>
          'Nutri-Score non calculé : recette de type boisson '
              '(algorithme boissons non implémenté).',
        NutriScoreCategory.fatOilNut =>
          'Nutri-Score non calculé : recette à base de matières grasses '
              'ou fruits à coque (algorithme spécifique).',
        _ =>
          'Nutri-Score non calculé : recette à base de fromage '
              '(algorithme spécifique).',
      };
    } else if (minCov < 0.5) {
      note =
          'Nutri-Score non calculé : moins de la moitié de la masse de '
          'la recette a des données nutritionnelles complètes.';
    } else {
      score = nutriScore(
        per100,
        fvlPercent: fvlPercent,
        redMeat: largestIsRedMeat,
        lowCoverage: minCov < minCoverage,
      );
      note =
          'Estimation indicative (algorithme 2023, aliments généraux) '
          'sur 100 g de plat après cuisson ; fruits, légumes et '
          'légumineuses : ${fvlPercent.toStringAsFixed(0)} % de la masse '
          'des ingrédients.'
          '${minCov < minCoverage ? ' Données incomplètes pour certains ingrédients.' : ''}';
    }

    // % des apports de référence par portion.
    ReferenceIntakeLine line(
      String key,
      String label,
      double value,
      String unit,
      double ri,
      String source,
      MacroField field,
    ) => ReferenceIntakeLine(
      key: key,
      label: label,
      value: value,
      unit: unit,
      percent: value / ri * 100,
      source: source,
      coverage: cov(field),
    );
    final intakes = <ReferenceIntakeLine>[
      line(
        'energy',
        'Énergie',
        serving.energyKcal,
        'kcal',
        ReferenceIntakes.energyKcal,
        kArSource,
        MacroField.energy,
      ),
      line(
        'fats',
        'Matières grasses',
        serving.fats,
        'g',
        ReferenceIntakes.fats,
        kArSource,
        MacroField.fats,
      ),
      line(
        'saturatedFats',
        'dont acides gras saturés',
        serving.saturatedFats,
        'g',
        ReferenceIntakes.saturatedFats,
        kArSource,
        MacroField.saturatedFats,
      ),
      line(
        'carbs',
        'Glucides',
        serving.carbs,
        'g',
        ReferenceIntakes.carbs,
        kArSource,
        MacroField.carbs,
      ),
      line(
        'sugars',
        'dont sucres',
        serving.sugars,
        'g',
        ReferenceIntakes.sugars,
        kArSource,
        MacroField.sugars,
      ),
      line(
        'fiber',
        'Fibres',
        serving.fiber,
        'g',
        ReferenceIntakes.fiber,
        kAnsesFiberSource,
        MacroField.fiber,
      ),
      line(
        'proteins',
        'Protéines',
        serving.proteins,
        'g',
        ReferenceIntakes.proteins,
        kArSource,
        MacroField.proteins,
      ),
      line(
        'salt',
        'Sel',
        serving.salt,
        'g',
        ReferenceIntakes.salt,
        kArSource,
        MacroField.salt,
      ),
    ];
    final micro = <ReferenceIntakeLine>[
      for (final m in serving.micronutrients.values)
        if (NutrientCatalog.of(m.tag)?.referenceIntake case final ri?)
          ReferenceIntakeLine(
            key: m.tag,
            label: NutrientCatalog.of(m.tag)!.labelFr,
            value: m.value,
            unit: m.unit,
            percent: m.value / ri * 100,
            source: kVnrSource,
          ),
    ]..sort((a, b) => b.percent.compareTo(a.percent));

    final claims = per100 == null
        ? const <NutritionClaim>[]
        : _claims(per100, cov);
    final split = _energySplit(serving);
    final highlights = _highlights(intakes, micro, split, cov);

    return NutritionFeedback(
      category: category,
      nutriScore: score,
      nutriScoreNote: note,
      intakes: intakes,
      micronutrientIntakes: micro,
      claims: claims,
      highlights: highlights,
      energySplit: split,
      servingMassG: aggregation.servingMassG,
      dishMassG: aggregation.cookedMassG,
    );
  }

  static final RegExp _cheese = RegExp(
    r'fromage|mozzarella|ricotta|mascarpone|chèvre|feta|parmigiano|pecorino|'
    r'comté|emmental|gruyère|camembert|brie|roquefort|cheddar|gorgonzola',
    caseSensitive: false,
  );
  static final RegExp _redMeat = RegExp(
    r'bœuf|boeuf|veau|porc|agneau|mouton|cheval|sanglier|cerf',
  );

  static String _n(double v, [int d = 1]) =>
      v.toStringAsFixed(d).replaceAll('.', ',');

  /// Allégations du règlement (CE) 1924/2006 (pour 100 g, solide).
  static List<NutritionClaim> _claims(
    NutritionProfile p,
    double Function(MacroField) cov,
  ) {
    final out = <NutritionClaim>[];
    bool ok(MacroField f) => cov(f) >= minCoverage;
    final kcal = p.energyKcal;
    if (ok(MacroField.proteins) && ok(MacroField.energy) && kcal > 0) {
      final share = p.proteins * 4 / kcal * 100;
      if (share >= 20) {
        out.add(
          NutritionClaim(
            label: 'Riche en protéines',
            basis: '${_n(share, 0)} % de l\'énergie ≥ 20 %',
          ),
        );
      } else if (share >= 12) {
        out.add(
          NutritionClaim(
            label: 'Source de protéines',
            basis: '${_n(share, 0)} % de l\'énergie ≥ 12 %',
          ),
        );
      }
    }
    if (ok(MacroField.fiber)) {
      final per100kcal = kcal > 0 ? p.fiber / kcal * 100 : 0.0;
      if (p.fiber >= 6 || per100kcal >= 3) {
        out.add(
          NutritionClaim(
            label: 'Riche en fibres',
            basis: '${_n(p.fiber)} g/100 g (seuil 6 g) ou 3 g/100 kcal',
          ),
        );
      } else if (p.fiber >= 3 || per100kcal >= 1.5) {
        out.add(
          NutritionClaim(
            label: 'Source de fibres',
            basis: '${_n(p.fiber)} g/100 g (seuil 3 g) ou 1,5 g/100 kcal',
          ),
        );
      }
    }
    if (ok(MacroField.fats) && p.fats <= 3) {
      out.add(
        NutritionClaim(
          label: 'Faible teneur en matières grasses',
          basis: '${_n(p.fats)} g/100 g ≤ 3 g',
        ),
      );
    }
    if (ok(MacroField.saturatedFats) &&
        p.saturatedFats <= 1.5 &&
        (kcal <= 0 || p.saturatedFats * 9 / kcal <= 0.1)) {
      out.add(
        NutritionClaim(
          label: 'Faible teneur en graisses saturées',
          basis: '${_n(p.saturatedFats)} g/100 g ≤ 1,5 g',
        ),
      );
    }
    if (ok(MacroField.sugars)) {
      if (p.sugars <= 0.5) {
        out.add(
          NutritionClaim(
            label: 'Sans sucres',
            basis: '${_n(p.sugars)} g/100 g ≤ 0,5 g',
          ),
        );
      } else if (p.sugars <= 5) {
        out.add(
          NutritionClaim(
            label: 'Faible teneur en sucres',
            basis: '${_n(p.sugars)} g/100 g ≤ 5 g',
          ),
        );
      }
    }
    if (ok(MacroField.salt)) {
      if (p.salt <= 0.1) {
        out.add(
          NutritionClaim(
            label: 'Très pauvre en sel',
            basis: '${_n(p.salt, 2)} g/100 g ≤ 0,1 g',
          ),
        );
      } else if (p.salt <= 0.3) {
        out.add(
          NutritionClaim(
            label: 'Pauvre en sel',
            basis: '${_n(p.salt, 2)} g/100 g ≤ 0,3 g',
          ),
        );
      }
    }
    if (ok(MacroField.energy) && kcal <= 40) {
      out.add(
        NutritionClaim(
          label: 'Faible valeur énergétique',
          basis: '${_n(kcal, 0)} kcal/100 g ≤ 40 kcal',
        ),
      );
    }
    // Oméga-3.
    final ala = p.micronutrients['ALA']?.value ?? 0;
    final epaDha =
        (p.micronutrients['EPA']?.value ?? 0) +
        (p.micronutrients['DHA']?.value ?? 0);
    if (ala >= 0.6 || epaDha >= 0.08) {
      out.add(
        NutritionClaim(
          label: 'Riche en acides gras oméga-3',
          basis: ala >= 0.6
              ? 'ALA ${_n(ala, 2)} g/100 g ≥ 0,6 g'
              : 'EPA + DHA ${_n(epaDha * 1000, 0)} mg/100 g ≥ 80 mg',
        ),
      );
    } else if (ala >= 0.3 || epaDha >= 0.04) {
      out.add(
        NutritionClaim(
          label: 'Source d\'acides gras oméga-3',
          basis: ala >= 0.3
              ? 'ALA ${_n(ala, 2)} g/100 g ≥ 0,3 g'
              : 'EPA + DHA ${_n(epaDha * 1000, 0)} mg/100 g ≥ 40 mg',
        ),
      );
    }
    // Vitamines et minéraux : ≥ 15 % (source) / 30 % (riche) des VNR
    // pour 100 g.
    final vitamins = <(String, double)>[];
    for (final m in p.micronutrients.values) {
      final share = NutrientCatalog.shareOfReference(m.tag, m.value);
      if (share == null || share < 0.15) continue;
      vitamins.add((m.tag, share));
    }
    vitamins.sort((a, b) => b.$2.compareTo(a.$2));
    for (final (tag, share) in vitamins.take(6)) {
      final label = NutrientCatalog.of(tag)!.labelFr;
      out.add(
        NutritionClaim(
          label: share >= 0.30 ? 'Riche en $label' : 'Source de $label',
          basis:
              '${_n(share * 100, 0)} % des VNR pour 100 g '
              '(seuil ${share >= 0.30 ? 30 : 15} %)',
        ),
      );
    }
    return out;
  }

  static EnergySplit? _energySplit(NutritionProfile p) {
    final kcal =
        p.proteins * 4 + p.carbs * 4 + p.fats * 9 + p.alcohol * 7 + p.fiber * 2;
    if (kcal <= 0) return null;
    return EnergySplit(
      proteinPct: p.proteins * 4 / kcal * 100,
      carbsPct: p.carbs * 4 / kcal * 100,
      fatPct: p.fats * 9 / kcal * 100,
      alcoholPct: p.alcohol * 7 / kcal * 100,
      fiberPct: p.fiber * 2 / kcal * 100,
    );
  }

  static List<NutritionHighlight> _highlights(
    List<ReferenceIntakeLine> intakes,
    List<ReferenceIntakeLine> micro,
    EnergySplit? split,
    double Function(MacroField) cov,
  ) {
    final out = <NutritionHighlight>[];
    ReferenceIntakeLine? byKey(String k) {
      for (final l in intakes) {
        if (l.key == k) return l;
      }
      return null;
    }

    final salt = byKey('salt');
    if (salt != null && salt.coverage >= 0.5 && salt.percent >= 30) {
      out.add(
        NutritionHighlight(
          positive: false,
          text:
              'Sel élevé : ${_n(salt.value)} g par portion '
              '(${_n(salt.percent, 0)} % de l\'apport de référence de 6 g).',
        ),
      );
    }
    final sat = byKey('saturatedFats');
    if (sat != null && sat.coverage >= 0.5 && sat.percent >= 35) {
      out.add(
        NutritionHighlight(
          positive: false,
          text:
              'Acides gras saturés élevés : ${_n(sat.value)} g par portion '
              '(${_n(sat.percent, 0)} % de l\'apport de référence).',
        ),
      );
    }
    final sugars = byKey('sugars');
    if (sugars != null && sugars.coverage >= 0.5 && sugars.percent >= 30) {
      out.add(
        NutritionHighlight(
          positive: false,
          text:
              'Sucres élevés : ${_n(sugars.value, 0)} g par portion '
              '(${_n(sugars.percent, 0)} % de l\'apport de référence).',
        ),
      );
    }
    final energy = byKey('energy');
    if (energy != null && energy.percent >= 40) {
      out.add(
        NutritionHighlight(
          positive: false,
          text:
              'Portion très énergétique : ${_n(energy.value, 0)} kcal '
              '(${_n(energy.percent, 0)} % de 2 000 kcal).',
        ),
      );
    }
    final fiber = byKey('fiber');
    if (fiber != null && fiber.coverage >= 0.8 && fiber.percent >= 20) {
      out.add(
        NutritionHighlight(
          positive: true,
          text:
              'Bon apport en fibres : ${_n(fiber.value)} g par portion '
              '(${_n(fiber.percent, 0)} % du repère de 30 g).',
        ),
      );
    }
    final protein = byKey('proteins');
    if (protein != null && protein.coverage >= 0.8 && protein.percent >= 40) {
      out.add(
        NutritionHighlight(
          positive: true,
          text:
              'Riche en protéines : ${_n(protein.value, 0)} g par portion '
              '(${_n(protein.percent, 0)} % de l\'apport de référence).',
        ),
      );
    }
    final strong = micro.where((m) => m.percent >= 30).take(4).toList();
    if (strong.isNotEmpty) {
      out.add(
        NutritionHighlight(
          positive: true,
          text:
              'Micronutriments bien couverts par portion : '
              '${strong.map((m) => '${m.label} ${_n(m.percent, 0)} %').join(', ')}.',
        ),
      );
    }
    if (split != null) {
      if (split.fatPct > 45) {
        out.add(
          NutritionHighlight(
            positive: false,
            text:
                'Énergie apportée à ${_n(split.fatPct, 0)} % par les lipides '
                '(repère ANSES 35–40 %).',
          ),
        );
      }
      if (split.carbsPct > 65) {
        out.add(
          NutritionHighlight(
            positive: false,
            text:
                'Énergie apportée à ${_n(split.carbsPct, 0)} % par les '
                'glucides (repère ANSES 40–55 %).',
          ),
        );
      }
      if (split.alcoholPct > 5) {
        out.add(
          NutritionHighlight(
            positive: false,
            text:
                'Alcool résiduel estimé : ${_n(split.alcoholPct, 0)} % de '
                'l\'énergie.',
          ),
        );
      }
    }
    return out;
  }
}
