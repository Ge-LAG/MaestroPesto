// Phase 09 Lot H — tests du modèle pur FunctionalAlert (§5.5).
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/functional_alert.dart';

FunctionalAlert alert({
  String alertId = 'RULE-PEC-HM-001',
  FunctionalSeverity severity = FunctionalSeverity.warning,
  double confidence = 0.46,
}) => FunctionalAlert(
  alertId: alertId,
  severity: severity,
  title: 'Pectine HM gélifie uniquement si sucre > 60 % ET pH < 4.0.',
  conditions: const ['pH 2.5–4.0', 'sucre > 60 %'],
  predictedEffect: 'gel_formation',
  confidence: confidence,
  evidenceType: 'expert_rule_with_literature',
);

void main() {
  group('FunctionalAlert', () {
    test('== and hashCode on identical values', () {
      expect(alert(), alert());
      expect(alert().hashCode, alert().hashCode);
    });

    test('== differs when severity differs', () {
      expect(
        alert(severity: FunctionalSeverity.warning),
        isNot(alert(severity: FunctionalSeverity.danger)),
      );
    });

    test('== differs when alertId differs', () {
      expect(alert(alertId: 'RULE-A'), isNot(alert(alertId: 'RULE-B')));
    });

    test('== differs when conditions order differs', () {
      final a = alert();
      final b = alert().copyWith(
        conditions: const ['sucre > 60 %', 'pH 2.5–4.0'],
      );
      expect(a, isNot(b));
    });

    test('copyWith preserves untouched fields', () {
      final a = alert();
      final b = a.copyWith(title: 'Autre titre');
      expect(b.title, 'Autre titre');
      expect(b.alertId, a.alertId);
      expect(b.severity, a.severity);
      expect(b.conditions, a.conditions);
      expect(b.predictedEffect, a.predictedEffect);
      expect(b.confidence, a.confidence);
      expect(b.evidenceType, a.evidenceType);
    });

    test('all FunctionalSeverity values are representable', () {
      for (final severity in FunctionalSeverity.values) {
        expect(alert(severity: severity).severity, severity);
      }
    });
  });
}
