// Régression : l'import des bases métier embarquées (assets) doit
// fonctionner quel que soit le dossier courant — cas de l'exécutable
// release lancé depuis l'explorateur. Le lecteur d'assets était retiré
// avant la fin de l'import asynchrone, et les fichiers étaient alors
// cherchés sur le disque (`assets/…`) relativement au dossier courant.
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/core/database/app_database.dart';
import 'package:maestropesto/core/database/database_bootstrap.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('import depuis les assets hors du dossier du projet', () async {
    final db = AppDatabase(NativeDatabase.memory());
    final services = AppServices.forTesting(db);
    final previous = Directory.current;
    final elsewhere = await Directory.systemTemp.createTemp('mp_cwd_');
    Directory.current = elsewhere;
    try {
      final phases = <String>[];
      await services.importMetier(onPhaseProgress: (p, _) => phases.add(p));
      expect(await services.isMetierLoaded(), isTrue);
      expect(
        phases.toSet(),
        containsAll(<String>['phase1', 'phase2', 'phase3', 'phase4', 'metier']),
      );
    } finally {
      Directory.current = previous;
      await db.close();
      await elsewhere.delete(recursive: true);
    }
  }, timeout: const Timeout(Duration(minutes: 3)));
}
