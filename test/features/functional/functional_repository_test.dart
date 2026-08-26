// Phase 09 Lot H — H2 : tests du FunctionalRepository (§8.2).
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/models/functional_alert.dart';
import 'package:maestropesto/features/functional/data/functional_repository.dart';

const ruleGel = InteractionRule(
  ruleId: 'RULE-GEL-GELATINE',
  ruleFamily: 'gelling',
  reactantOrComponentIds: 'PROT_GEL',
  predictedEffect: 'thermoreversible_gel',
  effectDirection: 'increase',
  confidence: 0.95,
);

const ruleAcid = InteractionRule(
  ruleId: 'RULE-GELATIN-ACID',
  ruleFamily: 'gelling',
  reactantOrComponentIds: 'PROT_GEL',
  predictedEffect: 'fragile_gel_syneresis',
  effectDirection: 'decrease_gel_strength',
  confidence: 0.85,
);

void main() {
  group('FunctionalRepository.fromRules (no Drift)', () {
    test('alertsFor évalue les règles injectées, triées par sévérité',
        () async {
      final repo = FunctionalRepository.fromRules(const [ruleGel, ruleAcid]);
      final alerts = await repo.alertsFor(const ['PROT_GEL']);
      expect(alerts.map((a) => a.alertId).toList(),
          ['RULE-GELATIN-ACID', 'RULE-GEL-GELATINE']);
      expect(alerts.first.severity, FunctionalSeverity.warning);
      expect(alerts.first.confidence, closeTo(0.425, 1e-9));
    });

    test('alertsFor sans match → vide', () async {
      final repo = FunctionalRepository.fromRules(const [ruleGel]);
      expect(await repo.alertsFor(const ['ING-UNKNOWN']), isEmpty);
      expect(await repo.alertsFor(const []), isEmpty);
    });

    test('profileFor renvoie null sans DB injectée', () async {
      final repo = FunctionalRepository.fromRules(const [ruleGel]);
      expect(
        await repo.profileFor('ING-A', stateId: 'raw'),
        isNull,
      );
    });
  });

  group('FunctionalRepository (in-memory Drift)', () {
    late AppDatabase db;
    late FunctionalRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      repo = FunctionalRepository(db);
    });

    tearDown(() async {
      await db.close();
    });

    Future<void> insertRule(String ruleId, String reactants) =>
        db.into(db.interactionRules).insert(
              InteractionRulesCompanion.insert(
                ruleId: ruleId,
                ruleFamily: const Value('gelling'),
                reactantOrComponentIds: Value(reactants),
                predictedEffect: const Value('gel'),
                effectDirection: const Value('increase'),
                confidence: const Value(0.9),
              ),
            );

    test('alertsFor lit les règles depuis la DB', () async {
      await insertRule('RULE-A', 'PROT_GEL|SM_CA');
      await insertRule('RULE-B', 'POLY_AGAR');
      final alerts = await repo.alertsFor(const ['SM_CA']);
      expect(alerts.map((a) => a.alertId), ['RULE-A']);
    });

    test('invalidateCache force un rechargement', () async {
      expect(await repo.alertsFor(const ['PROT_GEL']), isEmpty);
      await insertRule('RULE-A', 'PROT_GEL');
      // Cache encore chaud → toujours vide.
      expect(await repo.alertsFor(const ['PROT_GEL']), isEmpty);
      repo.invalidateCache();
      final alerts = await repo.alertsFor(const ['PROT_GEL']);
      expect(alerts.single.alertId, 'RULE-A');
    });

    test('profileFor trouve le profil par ingrédient + état', () async {
      await db.into(db.functionalIngredients).insert(
            FunctionalIngredientsCompanion.insert(
              ingredientId: 'ING-A',
              ingredientStateId: 'raw',
              ph: const Value(4.2),
            ),
          );
      final profile = await repo.profileFor('ING-A', stateId: 'raw');
      expect(profile, isNotNull);
      expect(profile!.ph, 4.2);
      expect(await repo.profileFor('ING-A', stateId: 'boiled'), isNull);
      expect(await repo.profileFor('ING-B', stateId: 'raw'), isNull);
    });
  });
}
