import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  testWidgets('shows the MaestroPesto shell', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaestroPestoApp(services: AppServices.forTesting(db)),
    );
    await tester.pump();

    expect(find.text('MaestroPesto'), findsOneWidget);
    expect(find.text('Pesto maison'), findsWidgets);
  });
}
