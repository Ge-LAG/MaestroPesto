// Phase 09 Lot H / Phase 10 Lots C & F — moteur de règles
// physico-chimiques.
//
// Phase 10 (ac-122) : les règles Phase 4 portent sur des COMPOSANTS
// (POLY_PEC_HM, PROT_GEL…), résolus depuis les ingrédients réels par la
// table `ingredient_functional_components`. Chaque règle est évaluée
// contre l'état estimé du mélange ([PhysChemState]) : dosage, Brix, pH,
// température, durée, cisaillement, refroidissement. Le résultat porte
// l'état des conditions (réunies, partielles, non réunies, non
// évaluables), le détail de chaque vérification, un conseil de
// formulation et une confiance = confiance de la règle × part des
// conditions évaluables (fin du facteur forfaitaire × 0,5 de la v1).
//
// Politique de sévérité :
// - effet recherché, conditions réunies → info (comportement attendu) ;
// - effet recherché compromis (condition déterminante absente) →
//   warning, avec conseil ;
// - effet indésirable probable (gélatine en milieu acide, caillage du
//   lait) → warning ;
// - conditions non évaluables → outOfDomain (« à vérifier ») ;
// - danger est réservé aux risques sanitaires avérés (aucune règle v1).

import '../database/app_database.dart' show InteractionRule;
import '../models/functional_alert.dart';
import 'physchem_estimator.dart';

/// Résultat interne d'un évaluateur de règle.
class _Evaluation {
  _Evaluation({
    required this.checks,
    required this.triggers,
    this.expected,
    this.adviceOnFailure,
    this.negative = false,
    this.warnOnFailure = true,
    this.infoOnly = false,
  });

  final List<_Check> checks;

  /// Composants déclencheurs (pour la part du mix et les ingrédients).
  final List<String> triggers;
  final String? expected;
  final String? adviceOnFailure;

  /// Effet indésirable (conditions réunies = problème).
  final bool negative;

  /// Un effet recherché compromis produit un warning.
  final bool warnOnFailure;

  /// Information uniquement (jamais warning).
  final bool infoOnly;
}

class _Check {
  _Check(this.label, this.met, {this.detail, this.critical = true});

  final String label;
  final bool? met;
  final String? detail;
  final bool critical;
}

abstract final class FunctionalConstraintSolver {
  /// Évalue [rules] contre l'état estimé du mélange. Renvoie les alertes
  /// applicables triées par sévérité puis par identifiant.
  static List<FunctionalAlert> evaluateMix({
    required PhysChemState state,
    required List<InteractionRule> rules,
  }) {
    final alerts = <FunctionalAlert>[];
    for (final rule in rules) {
      final evaluator = _evaluators[rule.ruleId] ?? _generic;
      final eval = evaluator(rule, state);
      if (eval == null) continue;
      final alert = _toAlert(rule, state, eval);
      if (alert != null) alerts.add(alert);
    }
    alerts.sort((a, b) {
      final bySeverity = _severityRank(b.severity) - _severityRank(a.severity);
      return bySeverity != 0 ? bySeverity : a.alertId.compareTo(b.alertId);
    });
    return alerts;
  }

  /// Compatibilité : évaluation à partir d'identifiants de composants ou
  /// d'ingrédients déjà résolus en composants (sans composition ni
  /// procédé : la plupart des conditions sont alors « à vérifier »).
  static List<FunctionalAlert> evaluate({
    required List<String> recipeIngredientIds,
    required List<InteractionRule> allRules,
    Map<String, double>? gramsByIngredient,
  }) {
    final ids = recipeIngredientIds.toSet().toList();
    final lines = <MixLine>[
      for (var i = 0; i < ids.length; i++)
        MixLine(
          index: i,
          label: ids[i],
          ingredientId: ids[i],
          grams: gramsByIngredient?[ids[i]] ?? 1,
          components: {ids[i]: 100},
        ),
    ];
    return evaluateMix(
      state: PhysChemEstimator.estimate(lines),
      rules: allRules,
    );
  }

  static FunctionalAlert? _toAlert(
    InteractionRule rule,
    PhysChemState state,
    _Evaluation eval,
  ) {
    final checks = eval.checks;
    final known = checks.where((c) => c.met != null).toList();
    final RuleStatus status;
    if (known.isEmpty) {
      status = RuleStatus.unknown;
    } else if (known.any((c) => c.met == false && c.critical)) {
      status = RuleStatus.notMet;
    } else if (known.any((c) => c.met == false) ||
        known.length < checks.length) {
      status = RuleStatus.partiallyMet;
    } else {
      status = RuleStatus.conditionsMet;
    }

    FunctionalSeverity severity;
    if (eval.negative) {
      if (status == RuleStatus.notMet || status == RuleStatus.unknown) {
        return null; // effet indésirable improbable : rien à signaler
      }
      severity = status == RuleStatus.conditionsMet
          ? FunctionalSeverity.warning
          : FunctionalSeverity.info;
    } else if (eval.infoOnly) {
      severity = FunctionalSeverity.info;
    } else {
      severity = switch (status) {
        RuleStatus.conditionsMet ||
        RuleStatus.partiallyMet => FunctionalSeverity.info,
        RuleStatus.notMet =>
          eval.warnOnFailure
              ? FunctionalSeverity.warning
              : FunctionalSeverity.info,
        RuleStatus.unknown => FunctionalSeverity.outOfDomain,
      };
    }

    final lines = <int>{
      for (final c in eval.triggers) ...?state.componentSources[c],
    };
    final ingredientIds = <String>[
      for (final i in lines)
        if (state.lineIngredientIds[i] != null) state.lineIngredientIds[i]!,
    ];
    final evaluable = checks.isEmpty ? 0.0 : known.length / checks.length;
    final confidence = (rule.confidence ?? 0.8) * (0.4 + 0.6 * evaluable);

    return FunctionalAlert(
      alertId: rule.ruleId,
      severity: severity,
      title: _titleFor(rule),
      conditions: [
        for (final c in checks)
          c.detail == null ? c.label : '${c.label} — ${c.detail}',
      ],
      predictedEffect: rule.predictedEffect ?? '',
      confidence: double.parse(confidence.toStringAsFixed(3)),
      evidenceType: rule.evidenceType ?? 'expert_rule_with_literature',
      sourceRefs: _splitPipe(rule.sourceRefs),
      triggerIngredientIds: ingredientIds.toSet().toList(),
      mixShare: state.totalMassG > 0 && lines.isNotEmpty
          ? state.shareOfLines(lines)
          : null,
      status: status,
      checks: [
        for (final c in checks)
          RuleCheck(label: c.label, met: c.met, detail: c.detail),
      ],
      advice:
          (status == RuleStatus.notMet ||
              (eval.negative && status == RuleStatus.conditionsMet))
          ? eval.adviceOnFailure
          : null,
      family: rule.ruleFamily,
      expectedOutcome: eval.expected,
    );
  }

  static String _titleFor(InteractionRule rule) {
    final notes = rule.notes?.trim();
    if (notes != null && notes.isNotEmpty) return notes;
    return rule.ruleId;
  }

  static int _severityRank(FunctionalSeverity severity) => switch (severity) {
    FunctionalSeverity.danger => 3,
    FunctionalSeverity.warning => 2,
    FunctionalSeverity.info => 1,
    FunctionalSeverity.outOfDomain => 0,
  };

  static List<String> _splitPipe(String? raw) {
    if (raw == null || raw.trim().isEmpty) return const <String>[];
    return raw
        .split('|')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  // -------------------------------------------------------------------
  // Aides de formatage
  // -------------------------------------------------------------------

  static String _n(double v, [int digits = 1]) =>
      v.toStringAsFixed(digits).replaceAll('.', ',');

  static _Check _phCheck(
    PhysChemState s,
    double? min,
    double? max, {
    double tolerance = 0.5,
    bool critical = true,
  }) {
    final label = 'pH ${_range(min, max)}';
    final ph = s.ph;
    if (ph == null) return _Check(label, null, critical: critical);
    final lo = (min ?? -99) - tolerance;
    final hi = (max ?? 99) + tolerance;
    return _Check(
      label,
      ph >= lo && ph <= hi,
      detail: 'pH estimé ${_n(ph)}',
      critical: critical,
    );
  }

  static String _range(double? min, double? max) {
    if (min != null && max != null) return '${_n(min)}–${_n(max)}';
    if (min != null) return '≥ ${_n(min)}';
    return '≤ ${_n(max ?? 0)}';
  }

  static String? _tempDetail(PhysChemState s) {
    final t = s.maxTemperatureC;
    return t == null ? 'aucune étape chauffée' : 'max ${_n(t, 0)} °C';
  }

  // -------------------------------------------------------------------
  // Évaluateurs par règle (règles Phase 4 réelles)
  // -------------------------------------------------------------------

  static final Map<
    String,
    _Evaluation? Function(InteractionRule, PhysChemState)
  >
  _evaluators = {
    'RULE-PEC-HM-001': (r, s) {
      if (!s.hasComponent('POLY_PEC_HM', minPct: 0.05)) return null;
      final brix = s.brix;
      final t = s.maxTemperatureC;
      return _Evaluation(
        triggers: const ['POLY_PEC_HM', 'SM_SUCROSE'],
        checks: [
          _Check(
            'Sucres 60–65 % de la phase aqueuse',
            brix == null ? null : brix >= 55,
            detail: brix == null ? null : 'Brix estimé ${_n(brix, 0)} %',
            critical: brix == null || brix < 48,
          ),
          _phCheck(s, r.phMin, r.phMax),
          _Check(
            'Cuisson 60–105 °C',
            t == null ? false : t >= 60 && t <= 110,
            detail: _tempDetail(s),
          ),
        ],
        expected:
            'Gel de pectine HM (confiture, gelée, pâte de fruits) : '
            'réseau formé par le sucre et l\'acidité.',
        adviceOnFailure:
            'Pour que la pectine HM gélifie : sucres ≈ 60–65 % de la phase '
            'aqueuse, pH 3,0–3,5 (jus de citron ou acide citrique ajouté '
            'en fin de cuisson) et ébullition. Sinon, utiliser une pectine '
            'LM (gélifie avec peu de sucre, au calcium).',
      );
    },
    'RULE-PEC-LM-001': (r, s) {
      if (!s.hasComponent('POLY_PEC_LM', minPct: 0.05)) return null;
      final pectin = s.componentsG['POLY_PEC_LM'] ?? 0;
      final ca = s.componentsG['SM_CA'] ?? 0;
      final ratio = pectin <= 0 ? 0.0 : ca * 1000 / pectin;
      return _Evaluation(
        triggers: const ['POLY_PEC_LM', 'SM_CA'],
        checks: [
          _Check(
            'Calcium ≥ 10 mg par g de pectine',
            ratio >= 10,
            detail: '${_n(ratio, 0)} mg/g',
          ),
          _phCheck(s, r.phMin, r.phMax, critical: false),
          _Check(
            'Dispersion à chaud',
            s.hasHeating,
            detail: _tempDetail(s),
            critical: false,
          ),
        ],
        expected:
            'Gel de pectine LM par pontage calcique (modèle « boîte à '
            'œufs »), peu dépendant du sucre.',
        adviceOnFailure:
            'La pectine LM a besoin de calcium : ajouter un produit '
            'laitier, un sel de calcium ou une eau riche en calcium.',
      );
    },
    'RULE-GEL-GELATINE': (r, s) {
      if (!s.hasComponent('PROT_GEL', minPct: 0.05)) return null;
      final pct = s.componentPct('PROT_GEL');
      return _Evaluation(
        triggers: const ['PROT_GEL'],
        checks: [
          _Check(
            'Dosage 0,5–3 % du mélange',
            pct >= 0.4 && pct <= 3.5,
            detail: '${_n(pct)} %',
            critical: pct < 0.4,
          ),
          _Check(
            'Dissolution à chaud (> 40 °C)',
            s.hasHeating ||
                s.steps.any((st) => st.primary?.opId == 'PROC_CHAUFFER'),
            detail: _tempDetail(s),
            critical: false,
          ),
          _Check(
            'Prise au froid (< 15 °C)',
            s.hasCooling,
            detail: s.hasCooling ? 'refroidissement prévu' : 'non prévu',
            critical: false,
          ),
          _phCheck(s, r.phMin, r.phMax, critical: false),
        ],
        expected:
            'Gel thermoréversible (fond vers 30–35 °C) : texture '
            'tremblotante, fondante en bouche.',
        adviceOnFailure:
            'Gélatine insuffisante pour gélifier : viser 0,5 à 3 % du '
            'poids total (≈ 2 feuilles de 2 g pour 250 ml de liquide).',
      );
    },
    'RULE-GELATIN-ACID': (r, s) {
      if (!s.hasComponent('PROT_GEL', minPct: 0.05)) return null;
      final ph = s.ph;
      return _Evaluation(
        negative: true,
        triggers: const ['PROT_GEL'],
        checks: [
          _Check(
            'Milieu acide (pH < 4)',
            ph == null ? null : ph < (r.phMax ?? 4.5) - 0.3,
            detail: ph == null ? null : 'pH estimé ${_n(ph)}',
          ),
        ],
        expected:
            'Gel de gélatine fragilisé et exsudant (synérèse) en milieu '
            'acide.',
        adviceOnFailure:
            'Milieu acide : augmenter la dose de gélatine de 20–30 % ou '
            'préférer l\'agar-agar, stable aux fruits acides.',
      );
    },
    'RULE-AGAR-GEL': (r, s) {
      if (!s.hasComponent('POLY_AGAR', minPct: 0.05)) return null;
      final pct = s.componentPct('POLY_AGAR');
      final t = s.maxTemperatureC;
      return _Evaluation(
        triggers: const ['POLY_AGAR'],
        checks: [
          _Check(
            'Dosage 0,5–2 %',
            pct >= 0.3 && pct <= 2.2,
            detail: '${_n(pct)} % (agar pur)',
            critical: pct < 0.3,
          ),
          _Check(
            'Ébullition pour dissoudre (≥ 90 °C)',
            t != null && t >= 90,
            detail: _tempDetail(s),
          ),
          _phCheck(s, r.phMin, r.phMax, critical: false),
        ],
        expected:
            'Gel thermo-irréversible : prend vers 35–40 °C et tient '
            'jusqu\'à 85–90 °C (se sert tiède).',
        adviceOnFailure:
            'L\'agar-agar ne se dissout qu\'à ébullition : porter le '
            'liquide à ébullition 1 à 2 minutes.',
      );
    },
    'RULE-MAYO-001': (r, s) {
      final yolkLike =
          s.hasComponent('PROT_OVALB', minPct: 0.3) &&
          s.hasComponent('LIP_PHOSPH', minPct: 0.2);
      final oilShare = s.totalMassG <= 0 ? 0 : s.liquidOilG / s.totalMassG;
      final t = s.maxTemperatureC;
      if (!yolkLike || oilShare < 0.3 || (t != null && t > 60)) return null;
      final frac = s.oilPhaseFraction;
      return _Evaluation(
        triggers: const ['LIP_PHOSPH', 'PROT_OVALB', 'LIP_TRIGLY'],
        checks: [
          _Check(
            'Phase huile 60–80 %',
            frac == null ? null : frac >= 0.55 && frac <= 0.86,
            detail: frac == null ? null : '${_n(frac * 100, 0)} %',
          ),
          _Check(
            'Incorporation progressive au fouet',
            s.hasShear,
            detail: s.hasShear ? 'fouettage prévu' : 'aucun fouettage',
          ),
          _Check('Température 18–25 °C (sans cuisson)', true),
          _phCheck(s, r.phMin, r.phMax, critical: false),
        ],
        expected:
            'Émulsion huile-dans-eau stable (mayonnaise) : les lécithines '
            'du jaune enrobent les gouttelettes d\'huile.',
        adviceOnFailure:
            'Pour une mayonnaise stable : jaune à température ambiante, '
            'huile versée en filet en fouettant, ≈ 75 % d\'huile.',
      );
    },
    'RULE-HL-EMULSION': (r, s) {
      if (!s.hasComponent('LIP_PHOSPH', minPct: 0.05)) return null;
      if (s.hasComponent('PROT_OVALB', minPct: 0.3)) return null; // mayo
      if (s.fatPct < 5 || s.waterPct < 10) return null;
      final pct = s.componentPct('LIP_PHOSPH');
      return _Evaluation(
        triggers: const ['LIP_PHOSPH'],
        checks: [
          _Check(
            'Lécithine 0,1–1 %',
            pct >= 0.1 && pct <= 1.5,
            detail: '${_n(pct, 2)} %',
            critical: pct < 0.1,
          ),
          _Check('Cisaillement élevé (mixeur, fouet)', s.hasShear),
        ],
        expected: 'Émulsion stabilisée par la lécithine (HLB ≈ 7–9).',
        adviceOnFailure:
            'Mixer vigoureusement : la lécithine n\'émulsionne qu\'avec un '
            'cisaillement élevé.',
      );
    },
    'RULE-MAILLARD': (r, s) {
      final reducing =
          s.hasComponent('SM_GLU_MONO', minPct: 0.05) ||
          s.hasComponent('SM_FRUCTOSE', minPct: 0.05) ||
          s.sugarPct >= 0.5;
      if (!reducing || s.proteinPct < 1) return null;
      final dry = s.maxDryHeatC;
      if (dry == null) return null;
      return _Evaluation(
        warnOnFailure: false,
        triggers: const ['SM_GLU_MONO', 'SM_FRUCTOSE', 'PROT_CASEINE'],
        checks: [
          _Check(
            'Chaleur sèche ≥ 140 °C',
            dry >= 140,
            detail: 'max ${_n(dry, 0)} °C',
          ),
          _Check(
            'Sucres réducteurs et protéines',
            true,
            detail:
                'sucres ${_n(s.sugarPct)} %, protéines ${_n(s.proteinPct)} %',
          ),
          _Check('aw de surface 0,4–0,85', null, critical: false),
        ],
        expected:
            'Réaction de Maillard : brunissement et arômes grillés, '
            'rôtis (pyrazines, furanones).',
        adviceOnFailure:
            'Peu de brunissement attendu : la réaction de Maillard demande '
            'une surface sèche et plus de 140 °C.',
      );
    },
    'RULE-CARAMEL': (r, s) {
      if (!s.hasComponent('SM_SUCROSE', minPct: 1)) return null;
      final caramelStep = s.steps.any(
        (st) => st.text.toLowerCase().contains('caram'),
      );
      final dry = s.maxDryHeatC;
      if (!caramelStep && (dry == null || dry < 150)) return null;
      return _Evaluation(
        warnOnFailure: false,
        triggers: const ['SM_SUCROSE'],
        checks: [
          _Check(
            'Sucre ≥ 160 °C',
            dry == null ? null : dry >= 160,
            detail: dry == null ? null : 'max ${_n(dry, 0)} °C',
          ),
        ],
        expected:
            'Caramélisation du saccharose : couleur ambrée, notes '
            'caramel, amertume croissante au-delà de 180 °C.',
        adviceOnFailure:
            'Caramel blond vers 160–170 °C, brun au-delà de 180 °C.',
      );
    },
    'RULE-STARCH-GEL': (r, s) {
      if (!s.hasComponent('POLY_AMIDON', minPct: 1)) return null;
      if (s.waterG < s.starchG) return null; // système sec (pâte, biscuit)
      final ratio = s.starchG <= 0 ? 0.0 : s.waterG / s.starchG;
      final t = s.maxTemperatureC;
      return _Evaluation(
        triggers: const ['POLY_AMIDON'],
        checks: [
          _Check(
            'Eau / amidon 2–10',
            ratio >= 1.5 && ratio <= 12,
            detail: 'rapport ${_n(ratio)}',
            critical: false,
          ),
          _Check(
            'Chauffage 60–95 °C sous agitation',
            t != null && t >= 60,
            detail: _tempDetail(s),
          ),
        ],
        expected:
            'Gélatinisation de l\'amidon : épaississement (crème, sauce '
            'liée, béchamel) à partir de 60–85 °C selon l\'amidon.',
        adviceOnFailure:
            'L\'amidon n\'épaissit qu\'une fois chauffé au-delà de 60 °C '
            '(blé 65–85 °C, maïs 65–75 °C) en remuant.',
      );
    },
    'RULE-STARCH-RETROGRAD': (r, s) {
      if (!s.hasComponent('POLY_AMYLOSE', minPct: 0.5)) return null;
      if (!s.coolingAfterHeating) return null;
      return _Evaluation(
        infoOnly: true,
        triggers: const ['POLY_AMYLOSE'],
        checks: [_Check('Refroidissement après cuisson', true)],
        expected:
            'Rétrogradation de l\'amylose au froid : raffermissement, '
            'rassissement, exsudation d\'eau (synérèse) au fil des heures.',
      );
    },
    'RULE-GLUTEN-DEVEL': (r, s) {
      if (!s.hasComponent('PROT_GLU', minPct: 1)) return null;
      if (!s.hasKneading && !s.hasTag('yeast')) return null;
      return _Evaluation(
        triggers: const ['PROT_GLU'],
        checks: [
          _Check(
            'Pétrissage 5–15 min',
            s.hasKneading,
            detail: s.hasKneading ? 'pétrissage prévu' : 'aucun pétrissage',
          ),
          _Check(
            'Hydratation suffisante',
            s.waterPct >= 20,
            detail: 'eau ${_n(s.waterPct, 0)} %',
            critical: false,
          ),
        ],
        expected:
            'Développement du réseau de gluten : pâte élastique qui '
            'retient le gaz de fermentation.',
        adviceOnFailure:
            'Pétrir 8 à 12 minutes pour développer le gluten (pâte lisse '
            'et élastique, test de la fenêtre).',
      );
    },
    'RULE-SALT-CASEIN': (r, s) {
      if (!s.hasComponent('PROT_CASEINE', minPct: 0.5)) return null;
      final salt = s.saltPct;
      if (salt < 0.3) return null;
      return _Evaluation(
        infoOnly: true,
        triggers: const ['SM_SALT', 'PROT_CASEINE'],
        checks: [
          _Check(
            'Sel 0,5–3 %',
            salt >= 0.5 && salt <= 3,
            detail: '${_n(salt)} %',
          ),
        ],
        expected:
            'Le sel exalte les notes lactées et umami des matrices '
            'fromagères.',
      );
    },
    'RULE-EGG-COAG': (r, s) {
      if (!s.hasComponent('PROT_OVALB', minPct: 0.3)) return null;
      final t = s.maxTemperatureC;
      if (t == null || t < 55) return null;
      final dairyCustard =
          s.hasTag('dairy_liquid') && !s.steps.any((st) => st.isDryHeat);
      return _Evaluation(
        triggers: const ['PROT_OVALB'],
        checks: [
          _Check('Chauffage ≥ 62 °C', t >= 62, detail: 'max ${_n(t, 0)} °C'),
          if (dairyCustard)
            _Check(
              'Crème aux œufs : rester sous 85 °C',
              t <= 88,
              detail: 'max ${_n(t, 0)} °C',
              critical: false,
            ),
        ],
        expected:
            'Coagulation des protéines d\'œuf (blanc 62–65 °C, jaune '
            '65–70 °C) : prise, liaison, texture.',
        adviceOnFailure:
            'Crème aux œufs : cuire à feu doux sans dépasser 83–85 °C '
            '(nappe) pour éviter le grainage.',
      );
    },
    'RULE-AW-MICRO': (r, s) {
      final aw = s.aw;
      if (aw == null) return null;
      final ph = s.ph;
      final perishable = aw > 0.86 && (ph == null || ph > 4.6);
      return _Evaluation(
        infoOnly: true,
        triggers: const [],
        checks: [
          _Check(
            'aw > 0,86 (croissance microbienne possible)',
            perishable,
            detail:
                'aw estimée ${_n(aw, 2)}'
                '${ph == null ? '' : ', pH ${_n(ph)}'}',
          ),
        ],
        expected: perishable
            ? 'Denrée périssable : conserver au froid (≤ 4 °C) et '
                  'consommer rapidement.'
            : 'Activité de l\'eau ou acidité défavorables aux pathogènes : '
                  'stabilité microbiologique renforcée.',
      );
    },
    'RULE-PH-COAG-CASEIN': (r, s) {
      if (!s.hasComponent('PROT_CASEINE', minPct: 0.5)) return null;
      if (!s.hasTag('dairy_liquid') || !s.hasTag('acidulant')) return null;
      final ph = s.ph;
      return _Evaluation(
        negative: true,
        triggers: const ['PROT_CASEINE'],
        checks: [
          _Check(
            'pH ≤ 5,5 (point isoélectrique des caséines 4,6)',
            ph == null ? null : ph <= 5.5,
            detail: ph == null ? null : 'pH estimé ${_n(ph)}',
          ),
          if (s.hasHeating)
            _Check('Chauffage (accélère le caillage)', true, critical: false),
        ],
        expected:
            'Caillage du lait ou de la crème par l\'acidité (caséines '
            'coagulées au voisinage de pH 4,6).',
        adviceOnFailure:
            'Risque de caillage : incorporer l\'acide hors du feu et en '
            'dernier, préférer une crème riche en matière grasse (≥ 30 %) '
            'plus résistante.',
      );
    },
  };

  /// Évaluateur générique (règles futures) : déclenchement par
  /// composant, vérification des bornes pH/T/aw quand elles sont
  /// estimables.
  static _Evaluation? _generic(InteractionRule rule, PhysChemState s) {
    final reactants = _splitPipe(rule.reactantOrComponentIds);
    if (reactants.isEmpty) return null;
    final present = reactants.where((c) => s.hasComponent(c)).toList();
    if (present.isEmpty) return null;
    final checks = <_Check>[];
    if (rule.phMin != null || rule.phMax != null) {
      checks.add(_phCheck(s, rule.phMin, rule.phMax));
    }
    if (rule.temperatureMin != null) {
      final t = s.maxTemperatureC;
      checks.add(
        _Check(
          'T ≥ ${_n(rule.temperatureMin!, 0)} °C',
          t == null ? null : t >= rule.temperatureMin!,
          detail: _tempDetail(s),
        ),
      );
    }
    if (rule.waterActivityMin != null || rule.waterActivityMax != null) {
      final aw = s.aw;
      checks.add(
        _Check(
          'aw ${_range(rule.waterActivityMin, rule.waterActivityMax)}',
          aw == null
              ? null
              : aw >= (rule.waterActivityMin ?? 0) &&
                    aw <= (rule.waterActivityMax ?? 1),
          detail: aw == null ? null : 'aw estimée ${_n(aw, 2)}',
        ),
      );
    }
    return _Evaluation(
      triggers: present,
      checks: checks,
      negative: (rule.effectDirection ?? '').startsWith('decrease'),
    );
  }
}
