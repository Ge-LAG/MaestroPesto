import 'package:flutter_test/flutter_test.dart';

import 'package:maestropesto/app/maestro_pesto_app.dart';

void main() {
  testWidgets('shows the MaestroPesto shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MaestroPestoApp());

    expect(find.text('MaestroPesto'), findsOneWidget);
    expect(find.text('Pesto maison'), findsWidgets);
  });
}
