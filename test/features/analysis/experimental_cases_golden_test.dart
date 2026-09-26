// Phase 10 Lot C (ac-122, critère A3) — les 10 cas expérimentaux
// Phase 4, rejoués avec de VRAIS identifiants d'ingrédients, leurs
// quantités et leur procédé, déclenchent les règles attendues.
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/features/analysis/data/recipe_analysis_service.dart';
import 'package:maestropesto/features/recipes/domain/recipe.dart';

void main() {
  late AppDatabase db;
  final analyses = <String, RecipeAnalysis>{};

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CsvImportService(
      db,
      databaseMetierRoot: 'assets/database-metier',
    ).importAll();
    final service = RecipeAnalysisService(db);
    for (final c in await db.select(db.experimentalValidationCases).get()) {
      final ids = c.ingredientIds!.split('|');
      final quantities = c.quantities!.split('|');
      final ingredients = <RecipeIngredient>[
        for (var i = 0; i < ids.length; i++)
          RecipeIngredient(
            label: ids[i],
            quantity: '${quantities[i]} g',
            source: ids[i].startsWith('ING-')
                ? IngredientSource.ciqual
                : IngredientSource.free,
            ingredientId: ids[i].startsWith('ING-') ? ids[i] : null,
          ),
      ];
      analyses[c.caseId] = await service.analyze(
        ingredients: ingredients,
        steps: c.processSequence!.split(' | '),
        servings: 1,
        withSuggestions: false,
      );
    }
  });

  tearDownAll(() => db.close());

  FunctionalAlert? rule(String caseId, String ruleId) {
    for (final a in analyses[caseId]!.alerts) {
      if (a.alertId == ruleId) return a;
    }
    return null;
  }

  test('les 10 cas sont chargés et analysés', () {
    expect(analyses, hasLength(10));
  });

  test('A3 : gel de pectine HM (EXP-GEL-PEC-001) — règle déclenchée, '
      'conditions réunies', () {
    final a = rule('EXP-GEL-PEC-001', 'RULE-PEC-HM-001');
    expect(a, isNotNull, reason: 'déclenchée par de vrais ING-*');
    expect(a!.status, isNot(RuleStatus.notMet));
    expect(a.severity, FunctionalSeverity.info);
    expect(a.checks.first.met, isTrue, reason: 'Brix ≈ 61 %');
    expect(a.triggerIngredientIds, contains('ING-TECH-PECTINEHM-000001'));
    expect(a.confidence, greaterThan(0.46), reason: 'fin du × 0,5');
  });

  test('mayonnaise (EXP-MAYO-001) : émulsion stable attendue', () {
    final a = rule('EXP-MAYO-001', 'RULE-MAYO-001');
    expect(a, isNotNull);
    expect(a!.status, isNot(RuleStatus.notMet));
    final ph = analyses['EXP-MAYO-001']!.physchem.ph!;
    expect(ph, inInclusiveRange(2.8, 4.8), reason: 'mesure : pH 4,0');
  });

  test('crème pâtissière (EXP-CUSTARD-001) : coagulation + amidon', () {
    expect(
      rule('EXP-CUSTARD-001', 'RULE-EGG-COAG')?.status,
      RuleStatus.conditionsMet,
    );
    expect(rule('EXP-CUSTARD-001', 'RULE-STARCH-GEL'), isNotNull);
    final ph = analyses['EXP-CUSTARD-001']!.physchem.ph!;
    expect(ph, closeTo(6.5, 0.5), reason: 'mesure : pH 6,5');
  });

  test('pain (EXP-BREAD-001) : gluten pétri et Maillard de croûte', () {
    expect(
      rule('EXP-BREAD-001', 'RULE-GLUTEN-DEVEL')?.status,
      RuleStatus.conditionsMet,
    );
    expect(rule('EXP-BREAD-001', 'RULE-MAILLARD')?.checks.first.met, isTrue);
  });

  test('caramel (EXP-CARAMEL-001) : caramélisation à 170 °C', () {
    expect(
      rule('EXP-CARAMEL-001', 'RULE-CARAMEL')?.status,
      RuleStatus.conditionsMet,
    );
  });

  test('meringue (EXP-MERINGUE-001) : coagulation du blanc', () {
    expect(rule('EXP-MERINGUE-001', 'RULE-EGG-COAG'), isNotNull);
  });

  test('vinaigrette (EXP-DRESSING-001) : émulsion instable signalée', () {
    final insights = analyses['EXP-DRESSING-001']!.insights;
    expect(
      insights.map((i) => i.text),
      anyElement(contains('Émulsion temporaire')),
    );
    final ph = analyses['EXP-DRESSING-001']!.physchem.ph!;
    expect(ph, closeTo(3.0, 0.5), reason: 'mesure : pH 3,0');
  });

  test('aw estimée cohérente avec les mesures (± 0,1)', () {
    const measured = {
      'EXP-GEL-PEC-001': 0.85,
      'EXP-CUSTARD-001': 0.93,
      'EXP-DRESSING-001': 0.97,
    };
    measured.forEach((caseId, aw) {
      expect(analyses[caseId]!.physchem.aw, closeTo(aw, 0.1), reason: caseId);
    });
  });

  test('nutrition des cas : procédé appliqué et feedback produit', () {
    final bread = analyses['EXP-BREAD-001']!;
    expect(bread.nutrition.hasData, isTrue);
    expect(bread.nutrition.processApplied, isTrue);
    expect(
      bread.nutrition.cookedMassG,
      lessThan(bread.nutrition.rawMassG),
      reason: 'cuisson au four : évaporation',
    );
    expect(bread.feedback.intakes, isNotEmpty);
  });
}
