# INDEX-docs.md — Index documentaire vivant (MaestroPesto)

> Index vivant de la documentation hors code. Mis à jour à chaque création, déplacement ou suppression de document (cf. `METHOD.md` A.2, A.4, BP-04).

## Documents actifs — racine

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `README.md` | Entrée du dépôt | Actif | Présente MaestroPesto (POC Flutter local-first de gestion de recettes), son état et les commandes rapides. |
| `ARCHITECTURE.md` | Vision produit et roadmap | Actif | Décrit les cibles (Windows POC, desktop/mobile), l'organisation cible du `lib/` et la persistance SQLite via Drift. |
| `IDEA.md` | Idée initiale | Actif | Concept de base du projet. |
| `LICENSE` | Licence du dépôt | Actif | Licence open-source en vigueur. |
| `METHOD.md` | Méthode locale humaine | Actif | Définit le workflow documentaire, Git, le format de branche `Ge-LAG/...`, le format de commit `theme: 2-3 mots`, et les conventions spécifiques Flutter. |
| `METHOD.json` | Méthode locale machine | Actif | Représentation structurée de `METHOD.md` pour le bootstrap agentique. |
| `METHOD-BOOTSTRAP.md` | Digest de démarrage | Actif | Résumé rapide des règles et références essentielles pour démarrer une session. |
| `PROJET.md` | Miroir humain du projet | Actif | Synthèse lisible de l'état courant, de la roadmap et du point de reprise. |
| `PROJET.json` | Source de vérité projet | Actif | État dynamique du projet, des phases, sessions, questions ouvertes et documents associés. |
| `INDEX-docs.md` | Répertoire documentaire | Actif | Ce document. Index vivant de la documentation hors code. |
| `pubspec.yaml` | Manifeste Flutter / Dart | Actif | Dépendances, version, métadonnées du package `maestropesto`. |
| `pubspec.lock` | Verrouillage des versions | Actif | Versions figées des dépendances (régénéré par `flutter pub get`). |

## Plans — `plans/`

> Dossier créé le 2026-08-25 lors de la rédaction du plan Phase 09.
> Héberge les plans de session ou produit (format §71, aligné sur
> le cahier `tasks/phase-08-db-connection-strategies.md`).

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `plans/phase-09-metier-driven-ux.md` | Plan produit Phase 09 — UX pilotée par les BDD métier | Lots F+G/H implémentés (2026-08-26), Lot I optionnel non fait | Plan détaillé en 20 sections pour transformer MaestroPesto en atelier de formulation culinaire : référentiel ingrédients (Phase 1), nutrition (Phase 2), flavour (Phase 3), functional (Phase 4) + module de recommandation. Amendé dp-108/109/110 + ac-107 à ac-110. |
| `plans/` (à venir) | Plans futurs | À créer | Chaque phase planifiée y créera un fichier `phase-NN-...md`. |

## Test-Dev — `Test-Dev/`

> Dossier **à créer** dès la première session de test manuel. Pas créé au bootstrap V5 pour la même raison.

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `Test-Dev/` (à créer) | Checklist de tests manuels | À créer | Contiendra `session-<date>-<lot>.md` + sous-dossier `Traité/` (BP-09, BP-11). |

## Tests automatisés — `test/`

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `test/widget_test.dart` | Point d'entrée historique | Actif | Test widget par défaut généré par `flutter create`. |
| `test/README.md` | Contrat et guide du dossier de tests | À créer | Décrira l'organisation, le cycle rouge/vert et les règles de contribution (BP-15, BP-16). |

## Données métier

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `ciqual/` | Source Ciqual XML (2025-11-03) | Actif | Données nutritionnelles de référence. À parser et importer en SQLite. |
| `ciqual/README.md` | Note sur les sources Ciqual | Actif | Description rapide du dossier. |
| `database/schema.sql` | Schema SQLite cible | Actif | Schéma de référence à instancier via Drift. |

## Scripts et CI/CD — `scripts/`

> Dossier **existant** dans le projet (cf. `README.md`), mais **pas de pipeline local créé** au V5 bootstrap. Scripts **à créer** dès qu'un pipeline local devient utile (anti-pattern « scripts inutilisés »).

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `scripts/` | Dossier de scripts projet | Actif | Contiendra à terme `prebuild-checks.sh` et `release.sh` (BP-16). |
| `scripts/prebuild-checks.sh` | Pipeline locale `flutter test` → `flutter build` | À créer | Bloque le build si un test échoue. |
| `scripts/release.sh` | Pipeline de release locale | À créer | Tests, build, smoke, tag, artefacts dans `build/`. |

## Méthode Template V5 — `Méthode Template V5/`

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `Méthode Template V5/METHOD-TEMPLATE.md` | Template méthode | Actif | Méthode humaine complète du template V5, utilisée pour générer `METHOD.md`. |
| `Méthode Template V5/METHOD-TEMPLATE.json` | Template méthode machine | Actif | Représentation machine du template. |
| `Méthode Template V5/METHOD-TEMPLATE-BOOTSTRAP.md` | Digest template | Actif | Digest de démarrage du template. |
| `Méthode Template V5/INDEX-TEMPLATE.md` | Template d'index | Actif | Template d'index documentaire vivant. |
| `Méthode Template V5/GUIDE-ADAPTATION.md` | Guide d'adaptation | Actif | Étapes pour adapter le template à un projet concret. |
| `Méthode Template V5/README.md` | README du template | Actif | Vue d'ensemble du template V4/V5. |
| `Méthode Template V5/test/` | Gabarit de dossier de tests | Référence | Gabarit utilisé pour produire `test/README.md` (à créer). |
| `Méthode Template V5/scripts/` | Gabarits de scripts CI/CD | Référence | Gabarits `prebuild-checks.sh` / `release.sh` (PowerShell + Bash). |
| `Méthode Template V5/safeguard-mistral/SKILL.md` | Extension conditionnelle | Inactive | Non copié à la racine (cf. A.9 de `METHOD.md`). |

## Bases de prompts et construction

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `databases-construction-prompts/` | Prompts de construction de BDD | Actif | Prompts utilisés pour générer ou auditer les schémas de base. |

## Plateformes cibles — dossiers générés

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `android/` | Cible Android (Flutter) | Actif | Configuration Gradle/Kotlin de l'app Android. |
| `ios/` | Cible iOS (Flutter) | Actif | Configuration Xcode/Swift de l'app iOS. |
| `linux/` | Cible Linux (Flutter) | Actif | Configuration CMake/C++ de l'app Linux. |
| `macos/` | Cible macOS (Flutter) | Actif | Configuration Xcode/Swift de l'app macOS. |
| `windows/` | Cible Windows (Flutter, POC) | Actif | Configuration CMake/C++ de l'app Windows. |
| `web/` | Cible Web (Flutter) | Actif | Configuration HTML/manifest de l'app Web. |

## Références projet

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `lib/` | Code source Dart / Flutter | Actif | Organisation cible `lib/features/<domaine>/{data,domain,presentation}`. |
| `pubspec.yaml` | Manifeste de build | Actif | Cf. `METHOD.md` B.4. |