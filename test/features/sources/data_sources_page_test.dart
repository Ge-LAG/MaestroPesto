import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/models/data_sources.dart';
import 'package:maestropesto/features/sources/presentation/data_sources_page.dart';

void main() {
  testWidgets('la page liste toutes les sources avec leur licence', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 6000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MaterialApp(home: DataSourcesPage()));
    for (final s in kDataSources) {
      expect(find.text(s.name), findsOneWidget, reason: s.id);
    }
    expect(find.text(SourceLicense.cc0.labelFr), findsWidgets);
    expect(find.text('https://fdc.nal.usda.gov/'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  test('registre : identifiants uniques, usage renseigné', () {
    final ids = kDataSources.map((s) => s.id).toSet();
    expect(ids.length, kDataSources.length);
    for (final s in kDataSources) {
      expect(s.usage.trim(), isNotEmpty, reason: s.id);
    }
  });
}
