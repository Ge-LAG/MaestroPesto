# Phase 08 — Stratégies de connexion des BDD métier (cahier)

> Lot A — Cahier stratégique + Drift schema initial.
> Branche : `Ge-LAG/db-connection-strategies` — aucun push (R-01).
> Date : 2026-08-22. Statut : rédigé, en relecture PO.
> Note de traçabilité (R-08) : le brief PO demande le « format §71 de la méthode
> PO-IA (skill `poia-orchestration-patterns` Pattern 5) ». Ce skill n'est pas
> disponible dans l'environnement d'exécution courant ; il n'a donc pas pu être
> consulté. La structure ci-dessous suit les 10 sections imposées explicitement
> par le brief PO (instruction de niveau 1 dans l'ordre de précédence A.0).

## 1. Résumé exécutif

Décision PO (Gui, rappelée dans le brief) : la persistance de MaestroPesto passe
par **SQLite via Drift**, avec `database/schema.sql` comme source de vérité pour
les tables applicatives et les **4 phases de `database-metier/`** comme unique
source de vérité métier. **CIQUAL est obsolète comme base d'import** : le champ
`ciqual_ids` (Phase 1, séparateur `|`) sert uniquement de mapping externe vers
l'ANSES ; ni le XML CIQUAL ni sa table de composition (2,3 M lignes) ne seront
importés. Les tables `ciqual_foods`/`ciqual_nutrients` de schema.sql sont
conservées dans le schéma Drift (fidélité à schema.sql) mais **ne sont pas
remplies dans ce lot**. Ce lot A livre : le présent cahier, les dépendances
pubspec justifiées, et le schéma Drift initial (17 tables). Les loaders CSV →
SQLite sont reportés au Lot B, les tests fonctionnels au Lot C.

## 2. Dépendances ajoutées à `pubspec.yaml`

Versions vérifiées le 2026-08-22 (API pub.dev + résolution réelle sur Dart 3.13.1
dans un sandbox Dart pur — preuve R-08, voir §7). Le sandbox a été déplacé de
`/tmp/opencode/drift-sandbox` vers `/workspace/.opencode-sandbox` en cours de
lot : `/tmp` est monté `noexec` et empêche l'exécution des snapshots AOT et du
chargement de libsqlite3 (impossibilité contournée, documentée au rapport).

| Package | Version | Rôle / justification |
|---|---|---|
| `drift` | `^2.34.3` | SQLite typé, réactif, migrations. Résolu à 2.34.3 sur Dart 3.13.1. Stack fixée par METHOD.md B.1. |
| `drift_flutter` | `^0.3.1` | Intégration Flutter officielle Drift (2025-2026) : `driftDatabase()` gère chemin, lazy opening et bundling sqlite. Dépend transitivement de `sqlite3 ^3.0.0` (bundling) et de `sqlite3_flutter_libs` (marqué EOL : « update to version 3.x of package:sqlite3 »), d'où l'absence d'ajout explicite de ce dernier. |
| `path_provider` | `^2.1.5` | Chemin du fichier SQLite cross-platform (répertoire applicatif). Exigé `^2.1.5` par drift_flutter 0.3.1. |
| `path` | `^1.9.1` | Manipulation de chemins (jointure dossier/fichier DB). Exigé `^1.9.0` par drift_flutter. |
| `drift_dev` (dev) | `^2.34.5` | Génération de code Drift (`*.g.dart`) côté Gui. Indispensable au pipeline prévu par le brief (« génération des .g.dart côté Gui »). Non listé par le brief, ajouté par décision dp-006 (BP-23 : justification documentée). |
| `build_runner` (dev) | `^2.16.0` | Runner de génération requis par drift_dev (`dart run build_runner build`). |

Exclusions explicites : **pas de `xml`** (CIQUAL obsolète pour l'import), pas de
`sqlite3_flutter_libs` direct (EOL, transitif), aucune dépendance exotique (BP-23).

## 3. Allowed files / Forbidden scope

**Allowed (création/modification)** : `tasks/phase-08-*`, `lib/core/database/`,
`lib/features/{ingredients,nutrition,flavor,functional}/data/` (arborescence
cible documentée ; les fichiers loaders restent vides en Lot A — créés en Lot B),
`test/core/`, `test/features/`, `pubspec.yaml`, `analysis_options.yaml`.

**Forbidden** : `database/schema.sql` (source de vérité, intouchable),
`database-metier/` (figé), `lib/features/recipes/` (collaborateur UI/UX),
`lib/app/`, `lib/main.dart`, `windows/`, `linux/`, `macos/`, `web/`, `ios/`,
`android/`, `ciqual/`, `PROJET*`, `METHOD*`, `INDEX*` (capitalisation Lot C).
Respecté : seuls `tasks/phase-08-db-connection-strategies.md`, `pubspec.yaml` et
`lib/core/database/**` ont été créés/modifiés.

## 4. Architecture cible

### 4.1 Arborescence (Lot A : uniquement `lib/core/database/`)

```text
lib/
  core/
    database/
      app_database.dart              # @DriftDatabase(tables: [17]) — schemaVersion 1
      tables/                        # 1 fichier = 1 table, transcription fidèle
        recipes.dart                 # schema.sql
        recipe_steps.dart            # schema.sql
        recipe_items.dart            # schema.sql (CHECK kind conservé)
        tags.dart                    # schema.sql (label UNIQUE)
        recipe_tags.dart             # schema.sql (PK composite, FK CASCADE)
        ciqual_foods.dart            # schema.sql — table conservée, non remplie ce lot
        ciqual_nutrients.dart        # schema.sql — conservée, non remplie ce lot
        sync_events.dart             # schema.sql — transposée, moteur sync NON implémenté
        ingredients.dart             # database-metier phase1 (603 lignes)
        ingredient_states.dart       # table énumérative : 19 états documentés P1/P2
        nutrition_components.dart    # phase2 component_dictionary (79 composants)
        nutrition_records.dart       # phase2 nutrition_database (751 lignes) — FK ingredients
        ingredient_aroma_compounds.dart  # phase3 (56 lignes) — FK ingredients
        flavor_compatibility.dart    # phase3 flavor_compatibility (4 593 lignes)
        functional_ingredients.dart  # phase4 (18 lignes) — PK (ingredient_id, state) — FK ingredients
        interaction_rules.dart       # phase4 (16 règles)
        process_operations.dart      # phase4 (38 opérations)
      connection/
        database_connection.dart     # openConnection() : driftDatabase + PRAGMA WAL
features/ (ingredients, nutrition, flavor, functional)
  data/  → loaders CSV → SQLite : LOT B (aucun fichier créé en Lot A)
```

### 4.2 Règles de transcription

- Fidélité 1:1 : `columnName` explicites pour reproduire exactement les noms SQL
  (`value_per_100g`, `T_min_C`, `shear_rate_s-1`, …). Aucune colonne ajoutée,
  aucune colonne retirée par rapport au brief et aux headers CSV.
- Tables schema.sql : NOT NULL / DEFAULT / UNIQUE / CHECK (`kind IN
  ('ciqual','recipe','free')`) / FK `ON DELETE CASCADE` transcrits (customConstraint Drift).
- Tables métier : PK selon le brief ; NOT NULL uniquement là où documenté
  (P1 : `ingredient_id`, `canonical_name_fr`, `category_level_1`) ; booléens P1
  `NOT NULL DEFAULT false` (le CSV les renseigne toujours) ; ailleurs nullable
  car la convention QA métier est « valeur manquante = champ vide, jamais 0 »
  (dp-007, §Décisions).
- `AppDatabase` est découplé de la connexion : constructeur `AppDatabase(QueryExecutor)` ;
  le `PRAGMA foreign_keys = ON` est appliqué dans `MigrationStrategy.beforeOpen`
  (pur Drift, testable sans Flutter). `openConnection()` (drift_flutter) reste
  isolé dans `connection/` (dp-002).

### 4.3 Tables non couvertes en Lot A (dette ac-001)

`aroma_compounds.csv`, `sensory_descriptor_ontology.csv` (P3),
`functional_components.csv`, `experimental_validation_cases.csv` (P4),
`pairwise_flavor_evidence.csv`, `higher_order_flavor_evidence.csv` (P3) ne sont
pas dans la liste de tables du brief → non créées ici ; arbitrage Lot B.

## 5. Stratégie d'import (décrite ici, implémentée en Lot B)

- Parsing CSV **ligne à ligne** (utf-8, virgule, pipe multivalué), `INSERT OR
  IGNORE` pour l'idempotence, en isolate (`Isolate.run`/`compute`) — rien sur le
  thread UI, aucune dépendance réseau, déterminisme : même CSV → même DB.
- **Ordre** : Phase 1 `ingredients` (+ `ingredient_states` statique) → Phase 2
  `nutrition_components` puis `nutrition_records` (FK ingredients) → Phase 3
  `ingredient_aroma_compounds` puis `flavor_compatibility` (FK ingredients) →
  Phase 4 `functional_ingredients`, `interaction_rules`, `process_operations`
  (FK ingredients).
- **Idempotence** : SHA-256 du contenu CSV stocké ; import sauté si hash
  inchangé depuis le dernier import.
- **Trigger** : premier lancement de l'app + bouton manuel (UI à coordonner avec
  le collaborateur UI/UX — pas ce lot).
- **Localisation** : CSV bundlés en assets (`assets/database-metier/`) — à
  confirmer en Lot B (volume total ~10 857 lignes, acceptable en asset).

## 6. Sync

Non implémentée en Lot A ni B. `sync_events` (schema.sql) est transposée en
Drift pour fidélité au schéma, mais aucun moteur d'émission/consommation
d'événements n'est écrit. Première version testable de sync = snapshot
(ARCHITECTURE.md §Sync) ; le câblage UI est une phase future.

## 7. Tests et vérifications (R-07/R-08)

- Environnement : Dart 3.13.1 (`/opt/dart-sdk/bin`), **pas de Flutter** →
  `flutter test` et `flutter analyze` impossibles (impossibilité documentée).
- Lot A = schéma uniquement : **aucun test fonctionnel requis** (les tests
  arrivent avec les loaders Lot B ; `dart test` sera utilisé pour la logique pure).
- Preuve réelle effectuée : sandbox Dart pur (drift 2.34.3 + drift_dev 2.34.5 +
  build_runner 2.16.0, `--force-jit` car AOT non exécutable sur tmpfs noexec)
  où le schéma a été copié, **généré par build_runner** (les `.g.dart` produits
  ne sont PAS commités — génération côté Gui prévue par le brief), **analysé
  sans erreur** par `dart analyze` (`No issues found!`), puis **installé dans
  un vrai SQLite in-memory** via Drift + libsqlite3 système : les 17
  `CREATE TABLE` générés s'exécutent tous sans erreur et le SQL produit a été
  comparé ligne à ligne à `database/schema.sql` (DEFAULT, UNIQUE, CHECK `kind`,
  FK `ON DELETE CASCADE`, `value_per_100g` : conformes). Sorties complètes dans
  le rapport de fin de lot.
- `dart analyze lib/` dans le repo : bloqué sans `flutter pub get` (sortie
  réelle documentée dans le rapport).

## 8. Determinism & realtime (principes universels V5)

- Loaders déterministes (même entrée → même sortie), aucune horloge/random dans
  le chemin d'import (horodatages d'audit exclus des données importées).
- Aucun travail bloquant sur le thread UI : import en isolate.
- Aucune dépendance réseau ; accès assets + SQLite locaux uniquement.
- Logs sans chemins utilisateur ni identifiants métier (METHOD.md B.2-6).

## 9. Acceptance criteria

- Schéma Drift compile et s'analyse sans erreur (preuve sandbox ci-dessus).
- Aucune colonne inventée ; transcription vérifiable colonne par colonne contre
  schema.sql / headers CSV / schémas `.md` métier.
- Cahier relu et validé par PO.

## 10. Definition of Done

- [x] Cahier `tasks/phase-08-db-connection-strategies.md` créé et complet.
- [x] `pubspec.yaml` : deps ajoutées et justifiées (§2), sans le flip EOL
  préexistant du working tree (technique documentée dans le rapport).
- [x] `lib/core/database/` créé : 17 tables + `app_database.dart` +
  `connection/database_connection.dart`.
- [x] Pas de loader (Lot B), pas de test fonctionnel (Lot C), pas de `.g.dart`
  commité (génération côté Gui).
- [x] Commits atomiques : `docs: db connection strategies`, puis
  `chore: pubspec deps drift`, puis `db: drift schema initial`.
- [x] Aucun secret/token/donnée réelle au commit (R-03).

## Décisions prises en cours de route

| ID | Décision | Justification |
|---|---|---|
| dp-001 | `drift_flutter` retenu plutôt que `sqlite3_flutter_libs` + drift natif | Option 1 du brief ; meilleure pratique officielle Drift 2025-2026 ; `sqlite3_flutter_libs` est marqué EOL sur pub.dev (bundling via `sqlite3 ^3.0.0` transitif). |
| dp-002 | `AppDatabase(QueryExecutor e)` découplé de `openConnection()` | Testable et analysable sans Flutter (R-07) ; le câblage `AppDatabase(openConnection())` se fera dans l'app (hors lot, `lib/app/` interdit). |
| dp-003 | PRAGMA : `foreign_keys=ON` via `beforeOpen`, `journal_mode=WAL` via `setup` de `driftDatabase` | Reproduction de `PRAGMA foreign_keys = ON` (schema.sql ligne 1) + performance write ; usages canoniques Drift. |
| dp-004 | `columnName` explicites sur toutes les colonnes | Fidélité 1:1 aux noms SQL/CSV (ex. `value_per_100g`, `T_min_C`, `shear_rate_s-1`) que la conversion camelCase→snake_case de Drift ne reproduirait pas. |
| dp-005 | `ingredient_states` créée (table énumérative PK TEXT, 19 états) | Option « enum table » du brief ; alimentée statiquement en Lot B. |
| dp-006 | `drift_dev` + `build_runner` ajoutés en dev_dependencies | Non listés par le brief mais indispensables à la génération `.g.dart` « côté Gui » que le brief prévoit explicitement ; BP-23 (dépendance justifiée). |
| dp-007 | Tables métier : nullable par défaut, sauf PK, 3 champs obligatoires P1 et booléens (NOT NULL DEFAULT false) | Convention QA métier « valeur manquante = champ vide » + « Aucune ligne sans ingredient_id / canonical_name_fr / category_level_1 » (ingredient_schema.md). |
| dp-008 | `ingredient_aroma_compounds` : PK composite (ingredient_id, ingredient_state_id, compound_id) | Brief « PK à déduire du header » : tuple identifiant naturel de la ligne CSV. |

## Dette et écarts signalés (à traiter hors Lot A)

| ID | Description | Priorité |
|---|---|---|
| ac-001 | Tables CSV non couvertes par le brief (aroma_compounds, sensory_descriptor_ontology, functional_components, pairwise/higher_order_flavor_evidence, experimental_validation_cases) — arbitrage Lot B. | Medium |
| ac-002 | `nutrition_database.csv` contient `canonical_name_fr` (dénormalisé, « pour audit humain ») absent de la liste du brief → colonne non transcrite ; divergence à trancher au Lot B. | Low |
| ac-003 | `pubspec.lock` non régénérable ici (Flutter absent) ; Gui devra lancer `flutter pub get` puis `dart run build_runner build` pour produire les `.g.dart`. | High |
| ac-004 | `INDEX-docs.md` non mis à jour (interdit par le brief) alors que la checklist Annexe 1.7 l'exige — écart documenté, capitalisation Lot C. | Low |
| ac-005 | `PROJET.json`/`PROJET.md` non mis à jour (interdit par le brief) — l'état projet reflète encore P0 bootstrap ; capitalisation Lot C. | Low |
