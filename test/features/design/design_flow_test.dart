// Phase 11 Lots C-D — assistant, écran de comparaison et reprise dans
// l'éditeur (critères « Interface » de phase11-recette-inversee).
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:maestropesto/app/i18n/app_strings.dart';
import 'package:maestropesto/app/maestro_pesto_app.dart';
import 'package:maestropesto/app/settings/app_settings.dart';
import 'package:maestropesto/app/theme/app_theme.dart';
import 'package:maestropesto/core/database/app_database.dart' hide Recipe;
import 'package:maestropesto/core/database/database_bootstrap.dart';
import 'package:maestropesto/core/database/importers/csv_import_service.dart';
import 'package:maestropesto/core/design/design_brief.dart';
import 'package:maestropesto/core/design/design_dataset.dart';
import 'package:maestropesto/core/design/design_engine.dart';
import 'package:maestropesto/features/design/data/design_repository.dart';
import 'package:maestropesto/features/design/presentation/design_results_page.dart';
import 'package:maestropesto/features/design/presentation/design_wizard_page.dart';
import 'package:maestropesto/features/recipes/data/recipes_repository.dart';

const _strings = AppStrings();

const _brief = DesignBrief(
  familyId: 'sauce_froide',
  servings: 6,
  targets: {
    'fat_phase': DesignTarget.value(55),
    'energy': DesignTarget.value(210),
    'salt': DesignTarget.atMost(0.5),
    'harmony': DesignTarget.atLeast(0.7),
  },
);

void main() {
  late AppDatabase db;
  late DesignDataset data;
  late DesignResult coherent;
  late DesignResult innovation;

  setUpAll(() async {
    db = AppDatabase(NativeDatabase.memory());
    await CsvImportService(
      db,
      databaseMetierRoot: 'assets/database-metier',
    ).importAll();
    data = await DesignRepository(db).dataset();
    coherent = DesignEngine(data).run(_brief);
    innovation = DesignEngine(data)
        .run(_brief.copyWith(mode: DesignMode.pureInnovation));
  });

  tearDownAll(() => db.close());

  Widget app(Widget home, {bool dark = false, double text = 1}) => MaterialApp(
    theme: buildAppTheme(),
    darkTheme: buildAppTheme(brightness: Brightness.dark),
    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(text)),
      child: child!,
    ),
    home: home,
  );

  void size(WidgetTester tester, double width) {
    tester.view.physicalSize = Size(width, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
  }

  group('écran de comparaison', () {
    for (final (dark, text) in [(false, 1.0), (true, 1.15)]) {
      for (final width in [360.0, 800.0, 1400.0]) {
        testWidgets('trois propositions sans débordement à ${width.toInt()} px '
            '(${dark ? 'sombre, grand texte' : 'clair'})', (tester) async {
          size(tester, width);
          await tester.pumpWidget(
            app(
              DesignResultsPage(
                brief: _brief,
                result: Future.value(coherent),
                dataset: Future.value(data),
              ),
              dark: dark,
              text: text,
            ),
          );
          await tester.pumpAndSettle();
          expect(coherent.variants, hasLength(3));
          expect(find.text(_strings.designVariant(1)), findsOneWidget);
          expect(
            find.text(_strings.designInnovationTag),
            findsNothing,
            reason: 'mode cohérent',
          );
          // Tableau objectif / obtenu.
          expect(
            find.textContaining('${_strings.designColTarget} :'),
            findsWidgets,
          );
          await tester.scrollUntilVisible(
            find.byKey(const ValueKey('design-open-3')),
            300,
            scrollable: find.byType(Scrollable).first,
          );
          expect(tester.takeException(), isNull);
        });
      }
    }

    testWidgets('Pure Innovation : bandeau et étiquette sur chaque '
        'proposition', (tester) async {
      size(tester, 1400);
      await tester.pumpWidget(
        app(
          DesignResultsPage(
            brief: innovation.brief,
            result: Future.value(innovation),
            dataset: Future.value(data),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(_strings.designInnovationBanner), findsOneWidget);
      expect(
        find.text(_strings.designInnovationTag),
        findsNWidgets(innovation.variants.length),
      );
    });

    testWidgets('« Ouvrir dans l\'éditeur » renvoie la proposition', (
      tester,
    ) async {
      size(tester, 800);
      DesignVariant? picked;
      await tester.pumpWidget(
        app(
          Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () async {
                  picked = await Navigator.of(context).push<DesignVariant>(
                    MaterialPageRoute(
                      builder: (_) => DesignResultsPage(
                        brief: _brief,
                        result: Future.value(coherent),
                        dataset: Future.value(data),
                      ),
                    ),
                  );
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const ValueKey('design-open-1')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('design-open-1')));
      await tester.pumpAndSettle();
      expect(picked, same(coherent.variants.first));
    });
  });

  group('assistant', () {
    testWidgets('quatre temps, avertissement Pure Innovation une fois par '
        'session, bandeau', (tester) async {
      DesignWizardPage.innovationWarned = false;
      size(tester, 360);
      await tester.pumpWidget(app(DesignWizardPage(db: db)));
      await tester.runAsync(() => DesignRepository(db).dataset());
      await tester.pumpAndSettle();

      // 1. Cadre.
      expect(find.text(_strings.designDishType), findsOneWidget);
      await tester.tap(find.text('Sauces froides et émulsions'));
      await tester.pump();
      // 2. Objectifs : cartes facultatives, aides ⓘ.
      await tester.tap(find.text(_strings.designNext));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designTargetsIntro), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsWidgets);
      await tester.ensureVisible(find.byKey(const ValueKey('target-energy')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('target-energy')));
      await tester.pump();
      expect(find.text(_strings.designKindValue), findsOneWidget);
      // 3. Priorités.
      await tester.tap(find.text(_strings.designNext));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designPrioritiesIntro), findsOneWidget);
      // 4. Mode.
      await tester.tap(find.text(_strings.designNext));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designModeCoherent), findsOneWidget);

      // Activation : avertissement à confirmer ; « Finalement, non ».
      await tester.tap(find.byKey(const ValueKey('design-innovation')));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designInnovationDialogBody), findsOneWidget);
      await tester.tap(find.text(_strings.designInnovationCancel));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designInnovationBanner), findsNothing);
      expect(find.text(_strings.designModeCoherent), findsOneWidget);

      // « Je veux innover » : bandeau visible.
      await tester.tap(find.byKey(const ValueKey('design-innovation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text(_strings.designInnovationConfirm));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designInnovationBanner), findsOneWidget);

      // Une seule fois par session.
      await tester.tap(find.byKey(const ValueKey('design-innovation')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('design-innovation')));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designInnovationDialogBody), findsNothing);
      expect(find.text(_strings.designInnovationBanner), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (dark, width) in [(false, 1400.0), (true, 360.0)]) {
      testWidgets('étapes sans débordement à ${width.toInt()} px '
          '(${dark ? 'sombre, grand texte' : 'clair'})', (tester) async {
        size(tester, width);
        await tester.pumpWidget(
          app(
            DesignWizardPage(db: db, initial: _brief),
            dark: dark,
            text: dark ? 1.15 : 1,
          ),
        );
        await tester.runAsync(() => DesignRepository(db).dataset());
        await tester.pumpAndSettle();
        for (var step = 0; step < 4; step++) {
          expect(tester.takeException(), isNull, reason: 'étape $step');
          if (step < 3) {
            await tester.tap(find.text(_strings.designNext));
            await tester.pumpAndSettle();
          }
        }
        // Demande reprise : objectifs de la recette à ajuster.
        expect(find.text(_strings.designSummaryTargets(4)), findsOneWidget);
      });
    }

    testWidgets('cohérent sans type de plat : message, retour au cadre', (
      tester,
    ) async {
      size(tester, 800);
      await tester.pumpWidget(app(DesignWizardPage(db: db)));
      await tester.runAsync(() => DesignRepository(db).dataset());
      await tester.pumpAndSettle();
      await tester.tap(find.text(_strings.designStepMode));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('design-compose')));
      await tester.pumpAndSettle();
      expect(find.text(_strings.designNeedDishType), findsOneWidget);
      expect(find.text(_strings.designDishType), findsOneWidget);
    });
  });

  group('classeur', () {
    /// Laisse le temps réel s'écouler (isolate, base) en redessinant,
    /// jusqu'à [until] ou [seconds] secondes.
    Future<void> wait(
      WidgetTester tester, {
      bool Function()? until,
      int seconds = 5,
    }) async {
      for (var i = 0; i < seconds * 10; i++) {
        if (until != null && until()) return;
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
    }

    testWidgets('le bouton + propose « Concevoir par objectifs » ; la '
        'proposition ouverte dans l\'éditeur n\'est pas enregistrée sans '
        'validation', (tester) async {
      size(tester, 1400);
      // Base propre à ce test : l'application y garde ses opérations en
      // cours (aucune requête du test ne doit l'attendre).
      final appDb = AppDatabase(NativeDatabase.memory());
      await tester.runAsync(() async {
        await CsvImportService(
          appDb,
          databaseMetierRoot: 'assets/database-metier',
        ).importAll();
        await DesignRepository(appDb).dataset();
      });
      final settings = AppSettings(MemorySettingsStore());
      await tester.pumpWidget(
        MaestroPestoApp(
          services: AppServices.forTesting(appDb, settings: settings),
        ),
      );
      await wait(
        tester,
        until: () => find.text('Pesto maison').evaluate().isNotEmpty,
      );
      final count = find.text(_strings.recipeCount(8));
      expect(count, findsOneWidget, reason: 'recettes de démonstration');

      await tester.tap(find.byTooltip(_strings.newRecipe));
      await wait(tester, seconds: 1);
      expect(find.text(_strings.designRecipe), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('menu-design-recipe')));
      await wait(
        tester,
        until: () =>
            find.text('Sauces froides et émulsions').evaluate().isNotEmpty,
      );
      expect(find.text(_strings.designTitle), findsOneWidget);

      await tester.tap(find.text('Sauces froides et émulsions'));
      await tester.pump();
      await tester.tap(find.text(_strings.designStepMode));
      await wait(tester, seconds: 1);
      await tester.tap(find.byKey(const ValueKey('design-compose')));
      // Composition hors du fil de l'interface (isolate).
      await wait(
        tester,
        seconds: 120,
        until: () =>
            find.byKey(const ValueKey('design-open-1')).evaluate().isNotEmpty,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('design-open-1')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('design-open-1')));
      await wait(
        tester,
        until: () => find.text(_strings.designDraftTitle).evaluate().isNotEmpty,
      );
      expect(find.text(_strings.designDraftTitle), findsOneWidget);

      // Fermer l'éditeur sans enregistrer.
      await tester.tap(find.byIcon(Icons.close).last);
      await wait(tester, seconds: 2);
      expect(find.text(_strings.designDraftTitle), findsNothing);
      expect(count, findsOneWidget, reason: 'brouillon non enregistré');
      // Démonter l'application (minuteries de l'aperçu).
      await tester.pumpWidget(const SizedBox());
      await wait(tester, seconds: 1);
    }, timeout: const Timeout(Duration(minutes: 5)));
  });

  test(
    'lot D : la demande est conservée avec la recette enregistrée',
    () async {
      final variant = coherent.variants.first;
      final recipe = variant.toRecipe(
        id: 'designed',
        brief: _brief,
        servings: 6,
      );
      final repo = RecipesRepository(db);
      await repo.save(recipe);
      final back = await repo.getById('designed');
      expect(back!.designBrief, _brief);
      expect(back.steps, variant.steps);
      expect(back.ingredients.map((i) => i.quantity), [
        for (final i in variant.ingredients) i.quantity,
      ]);
      // Une recette saisie n'a pas de demande.
      await repo.save(recipe.copyWith(id: 'plain', designBrief: null));
      expect((await repo.getById('plain'))!.designBrief, isNull);
      await repo.delete('designed');
      await repo.delete('plain');
    },
  );
}
