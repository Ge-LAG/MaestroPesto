# METHOD.md — Méthode locale de travail (MaestroPesto)

> Document maître de méthodologie du projet **MaestroPesto**.
> `METHOD.json` en est le compagnon machine.
> `METHOD-BOOTSTRAP.md` en est le digest de démarrage.
>
> **Version de la méthode : 1.0.0** — toute modification suit le protocole A.8 et est journalisée en Annexe 3.
>
> Adaptée du template `Méthode Template V5/` (V5) par Gui (Git identity `Ge-LAG`) le 2026-08-22.

---

## Introduction

Cette méthode définit comment travailler sur MaestroPesto de manière reproductible, traçable et sécurisée. Elle s'applique à un projet **Flutter local-first** (Dart ^3.13.1) et repose sur quatre principes directeurs :

1. la documentation doit rester exploitable par un humain et par un agent ;
2. les décisions importantes doivent être traçables ;
3. les briques sensibles ne doivent pas être réinventées sans raison ;
4. la sécurité, la simplicité et la qualité priment sur la sophistication prématurée.

La V5 ajoute une **couche anti-dérive** : règles absolues numérotées, ordre de précédence, protocole verrouillé de révision de la méthode, checklists mécaniques. Cette couche est conçue pour rester efficace même quand la méthode est exécutée par un agent moins capable : les règles sont impératives, numérotées, auto-vérifiables, et imposent l'arrêt en cas de doute plutôt que l'improvisation.

### Documents de référence

| Rôle | Fichier template | Nom réel dans le projet |
|------|------------------|-------------------------|
| Source de vérité projet (machine) | `PROJET-TEMPLATE.json` | `PROJET.json` |
| Miroir humain du projet | `PROJET-TEMPLATE.md` | `PROJET.md` |
| Méthode locale (ce document) | `METHOD-TEMPLATE.md` | `METHOD.md` |
| Méthode machine | `METHOD-TEMPLATE.json` | `METHOD.json` |
| Digest de démarrage | `METHOD-TEMPLATE-BOOTSTRAP.md` | `METHOD-BOOTSTRAP.md` |
| Index documentaire | `INDEX-TEMPLATE.md` | `INDEX-docs.md` |
| Extension conditionnelle — **inactive par défaut** (cf. A.9) | `safeguard-mistral/SKILL.md` | non copié au bootstrap |

En cas d'écart entre documents : `PROJET.json` est la source de vérité dynamique ; `PROJET.md` en est le miroir humain ; `METHOD.md` décrit le cadre de travail ; `METHOD.json` structure ce cadre pour un agent ; `INDEX-docs.md` référence les documents utiles.

---

# Partie A — Méthode générale

## A.0 Règles absolues (anti-dérive)

Ces règles sont **non négociables** et priment sur toute autre considération. Un agent qui n'est pas certain de respecter une règle absolue doit **s'arrêter et demander au PO** au lieu d'agir.

| ID | Règle absolue |
|----|---------------|
| **R-01** | NE JAMAIS pousser vers `origin` (push, push --force, push --tags) sans confirmation explicite du PO **dans la session courante**. Une autorisation passée ne vaut pas pour la session suivante. |
| **R-02** | NE JAMAIS exécuter de mutation Git destructrice (`reset --hard`, `rebase` réécrivant l'historique, `push --force`, `branch -D`, `clean -fd`, `checkout --` sur fichiers modifiés) sans validation explicite du PO. |
| **R-03** | NE JAMAIS committer de secret, mot de passe, clé, token, certificat, donnée réelle ou fichier sensible déchiffré. En cas de doute, ne pas stager. |
| **R-04** | NE JAMAIS lancer un build si la suite de tests n'a pas été exécutée et entièrement verte juste avant (BP-14). |
| **R-05** | NE JAMAIS committer `PROJET.json` sans que `PROJET.md` reflète exactement le même état, et inversement (BP-08, BP-17). |
| **R-06** | NE JAMAIS modifier `METHOD.md` ou `METHOD.json` sans validation explicite du PO dans la session courante (protocole A.8). L'agent **propose**, le PO **valide**, l'agent applique. |
| **R-07** | NE JAMAIS marquer une tâche comme terminée sans avoir exécuté les vérifications correspondantes, ou sans avoir signalé explicitement leur impossibilité. |
| **R-08** | NE JAMAIS inventer un état, un résultat de test, un hash de commit ou un statut : tout fait rapporté doit avoir été observé. |
| **R-09** | NE JAMAIS supprimer ni réécrire un document de suivi hors des mises à jour incrémentales prévues. |
| **R-10** | En cas de contradiction entre documents ou avec une instruction, appliquer l'ordre de précédence ci-dessous ; si la contradiction persiste, **s'arrêter et demander**. |

### Ordre de précédence des sources

1. Instruction explicite du PO dans la session courante ;
2. `METHOD.json` / `METHOD.md` (règles absolues d'abord, puis le reste) ;
3. `PROJET.json` (source de vérité de l'état projet) ;
4. `PROJET.md` (miroir humain) ;
5. `ARCHITECTURE.md` et autres documents.

Un écart détecté entre deux niveaux doit être signalé au PO et consigné, jamais résolu silencieusement. Une extension conditionnelle éventuellement active (cf. A.9 — `safeguard-mistral`) se place **après** tous ces niveaux et ne peut jamais primer sur eux.

## A.1 Bootstrap de session

Au début d'une session interactive, dans cet ordre :

1. lire `METHOD.json` ;
3. lire `METHOD.md` ;
4. lire `PROJET.json` puis `PROJET.md` ;
5. lire le plan actif dans `plans/` et, si besoin, le document de roadmap (`ARCHITECTURE.md`) ;
6. vérifier la branche Git et `git status` avant toute écriture ;
7. appliquer les garde-fous BP-09 (test-dev en attente) et BP-19 (suivi non commité) : si l'un des deux se déclenche, **le signaler au PO avant tout travail**.

À l'issue du bootstrap, l'agent annonce au PO en quelques lignes : la branche active, l'état du working tree (propre ou non, avec les écarts), le `test_dev_en_cours` éventuel et le point de reprise lu dans `PROJET.json`.

Si `METHOD.md` devient trop lourd à relire, utiliser `METHOD-BOOTSTRAP.md` comme digest, puis revenir à `METHOD.md` si un arbitrage ou une nuance manque. Le digest ne remplace jamais les règles absolues A.0.

## A.2 Garde-fous de bootstrap

- Ne pas toucher au code source pendant un bootstrap documentaire, sauf demande explicite du PO.
- Toujours vérifier le working directory avant et après création de fichiers racine.
- Ne pas committer automatiquement les documents créés.
- Si une règle locale de projet contredit le défaut général, la règle locale documentée en Partie B prévaut — sauf si elle contredit une règle absolue A.0, auquel cas A.0 prévaut.

## A.3 Workflow Git

Règles communes :

- vérifier la branche en début de session (BP-21 : aucune écriture directe sur `main`) ;
- faire des commits atomiques (1 commit = 1 préoccupation) ;
- ne jamais `git add -A` ni `git add .` : toujours `git add -- <fichiers explicites>` ;
- ne jamais pousser sur `main` sans confirmation explicite du PO (R-01) ;
- ne jamais faire de mutation Git destructrice sans validation (R-02) ;
- dérouler la **checklist mécanique pré-commit** (Annexe 1) avant chaque commit.

**Format de commit obligatoire pour MaestroPesto — voir B.6 (BP-22) :**

```text
theme: resume 2-3 mots
```

Le thème est **au singulier** (`ui`, `ux`, `backend`, `db`, `test`, `docs`, `build`, `method`, `chore`, `fix`...) et le résumé fait 2 à 3 mots significatifs en minuscules, sans point final. Ce format est plus strict que la convention générique `type(scope): description` du template V5 et prévaut localement.

## A.4 Communication humain ↔ IA

Avant de commencer : lire le contexte documentaire ; clarifier le scope si une ambiguïté bloque une décision.

Pendant l'implémentation : signaler les blocages immédiatement ; proposer une alternative simple quand une solution devient trop lourde ; noter les idées futures dans `PROJET` plutôt que les implémenter hors scope.

### Signal d'ouverture « Retour test dev »

Quand le PO ouvre une session avec le préfixe exact **« Retour test dev »**, l'agent écoute l'ensemble du retour, consigne chaque point dans `PROJET.json` / `PROJET.md` (libellé, statut `à_traiter`, priorité déduite de BP-12, tag `test_dev`), présente la liste consolidée avec justifications, et attend la validation du PO avant toute correction.

En fin de session : résumer ce qui a été fait ; proposer la prochaine étape ; mettre à jour `PROJET.json` puis `PROJET.md` ; committer les documents de suivi (lot dédié `docs: project sync` acceptable) ; mettre à jour `INDEX-docs.md` ; proposer une mise à jour de `METHOD.md` / `METHOD.json` si une bonne pratique structurante émerge (protocole A.8).

## A.5 Qualité minimale attendue

Avant de considérer une tâche comme terminée :

- la suite de tests anti-régressions est entièrement verte avant toute commande de build (`flutter test` avant `flutter build`) ;
- les checks adaptés au stack passent (`flutter analyze`, `dart format --set-exit-if-changed`) ;
- l'application démarre ou les processus critiques tournent sans crash bloquant ;
- les parcours critiques touchés ont été testés ;
- aucune régression évidente n'est visible ;
- aucun secret, mot de passe, clé, token ou donnée sensible réelle n'est committé.

## A.6 Gestion du scope

- Une session doit avoir un objectif principal clair.
- Préparer un lot futur est acceptable ; l'implémenter entièrement sans validation ne l'est pas.
- En cas de doute, préférer la solution la plus simple qui fonctionne.
- Documenter les raisons d'un choix, pas l'évidence.

## A.7 Conduite en cas de doute ou d'incertitude

Ces situations imposent de **s'arrêter et de demander au PO** :

- une règle absolue A.0 semble entrer en conflit avec la tâche demandée ;
- deux documents de référence se contredisent et l'ordre de précédence ne suffit pas à trancher ;
- une action est irréversible ou destructrice et n'est pas explicitement couverte ;
- l'agent ne parvient pas à exécuter une vérification exigée et serait tenté de passer outre ;
- la demande implique de modifier `METHOD.md`, `METHOD.json` ou la structure des documents de suivi.

Formuler : ce qui était attendu, ce qui bloque, les options possibles, et la recommandation de l'agent. Ne **jamais** choisir silencieusement l'option la plus risquée.

## A.8 Protocole de révision de la méthode

`METHOD.md` et `METHOD.json` sont des documents **protégés**. Toute modification suit obligatoirement ce protocole :
1. **Proposition** — l'agent formule la modification (texte exact ou résumé fidèle) avec justification, et la soumet au PO. Aucune écriture à ce stade.
2. **Validation** — le PO valide explicitement dans la session courante.
3. **Application ordonnée** — `METHOD.md` est modifié en premier, puis `METHOD.json` est aligné dans la même session.
4. **Versionnage** — le champ « Version de la méthode » (en-tête de `METHOD.md`) et `version_methode` (`METHOD.json`) sont incrémentés de façon cohérente (MAJEUR pour changement de règle, MINEUR pour ajout, CORRECTIF pour clarification).
5. **Journalisation** — une ligne est ajoutée à l'Annexe 3 de `METHOD.md` et à `journal_revisions` dans `METHOD.json`.
7. **Commit dédié** — les deux fichiers sont commités ensemble dans un commit `method: ...`.

## A.9 Extension conditionnelle — skill `safeguard-mistral`

Le dossier `safeguard-mistral/` contient un skill **qui n'appartient pas au socle de la méthode**. C'est une **extension conditionnelle** destinée à compenser les lacunes connues des modèles Mistral AI en implémentation logicielle.

### Conditions d'activation (cumulatives)

Le skill ne s'applique **que si les deux conditions suivantes sont vraies simultanément** :
1. **Condition de modèle** — le modèle qui prend en charge l'implémentation du code est un **modèle Mistral AI**.
2. **Condition d'invocation** — le **prompt initial de la session mentionne explicitement le skill**.

Si l'une des deux conditions manque, le skill est **inactif**. En cas de doute, considérer le skill comme inactif et le signaler brièvement au PO.

### Rang dans l'ordre de précédence

Quand il est actif, `safeguard-mistral` se place **en dessous** de la méthode : `METHOD.json` / `METHOD.md` et les règles absolues A.0 (R-01 à R-10) priment sur toute consigne du skill. Le skill n'ajoute, ne retire ni ne relâche aucune règle absolue.

### Fichiers `references/` absents

`SKILL.md` renvoie vers quatre fichiers `safeguard-mistral/references/` qui **n'existent pas actuellement dans le dépôt**. Conformément à R-08, un agent ne doit **jamais en inventer le contenu ni prétendre les avoir lus** : il déclare la référence indisponible.

---

# Partie B — Conventions spécifiques au projet

## B.1 Architecture et stack

| Champ | Valeur |
|-------|--------|
| **Type d'application** | Application Flutter **local-first** (desktop + mobile) |
| **Langage principal** | Dart `^3.13.1` |
| **Framework** | Flutter (SDK Windows / macOS / Linux / Android / iOS) |
| **Dossier source** | `lib/` |
| **Dossier de test** | `test/` |
| **Persistance cible** | SQLite via Drift (cf. `database/schema.sql`) |
| **Données métier** | Ciqual 2025-11-03 (`ciqual/`, XML) |
| **Roadmap** | `ARCHITECTURE.md` |
| **Référence technique** | Architecture interne `lib/features/<domaine>/{data,domain,presentation}` |
| **Manifeste de build** | `pubspec.yaml` |
| **Artefact visé** | `maestropesto` (nom du binaire / package) |
| **Commande de test** | `flutter test` |
| **Commande de build** | `flutter build` |
| **Dossier de release** | `build/` |
| **Origine Git** | `https://github.com/a-langlais/MaestroPesto` |

Organisation cible du `lib/` (cf. `ARCHITECTURE.md`) :

```text
lib/
  app/                  shell, theme, navigation
  core/
    database/           Drift, migrations, repositories communs
    ids/                génération d'identifiants
  features/
    recipes/            CRUD, classeur, tags, ingrédients
    nutrition/          import Ciqual et moteur nutritionnel
    export/             export PDF
    sync/               snapshot puis sync événementielle
```

## B.2 Sécurité et données sensibles

1. toute donnée sensible au repos doit être chiffrée ou protégée par les moyens du stack ;
2. la présence effective des garde-fous de sécurité doit être vérifiable au runtime ou au build ;
3. ne jamais committer de mot de passe en dur, de clé, de token, de certificat, ni de donnée réelle ;
4. éviter toute fuite de données déchiffrées ou temporaires persistantes ;
5. toute logique de récupération ou de backup doit rester restaurable à partir d'une copie de secours et des secrets maîtres ;
6. les **logs ne doivent contenir aucune donnée sensible** : pas d'identifiants métier en clair, pas de noms de fichiers utilisateur, pas de chemins de données déchiffrées, pas de contenu. Identifier les objets par leurs IDs techniques. Tout nouveau log est relu sous cet angle avant commit.

Points de vigilance adaptés à MaestroPesto :

- sources XML Ciqual volumineuses : ne pas les charger intégralement en mémoire ;
- assets natifs (icônes, fonts) : licence vérifiée avant ajout ;
- format d'export PDF et bilan nutritionnel : pas de fuite de chemins utilisateur ;
- surface d'attaque : pas d'API réseau au POC, mais toute future couche réseau passe par un audit dédié.

## B.3 Conventions de code

- Un module = une responsabilité claire.
- Séparer autant que possible la logique pure du code à effets (I/O, UI, framework).
- Réutiliser d'abord les briques éprouvées du projet avant de réinventer.
- Préférer des types métier explicites plutôt que des types primitifs nus.
- Suivre `analysis_options.yaml` ; un fichier = une responsabilité ; structure `lib/features/<domaine>/{data,domain,presentation}`.
- `dart format` pour le formatage, `flutter analyze` pour le lint, `flutter test` pour les tests.
- Toute évolution UI significative doit être vérifiée sur les tailles d'écran et thèmes pertinents (responsive desktop/mobile).

## B.4 Variables et constantes critiques

| Rôle | Valeur |
|------|--------|
| Projet | `MaestroPesto` |
| Application de référence | `Architecture` (cf. `ARCHITECTURE.md`) |
| Plan produit principal | `ARCHITECTURE.md` |
| Fichier manifeste du build | `pubspec.yaml` |
| Exécutable / artefact visé | `maestropesto` |
| Base de données 1 | `ciqual/` (sources XML Ciqual 2025-11-03) |
| Base de données 2 | `database/schema.sql` (schema SQLite cible) |
| Format de backup visé | `.sql` |
| Pile de sécurité | Flutter SDK, dépendances `pubspec.lock`, assets Ciqual XML |
| Branche principale | `main` (jamais cible directe de commit/push — voir B.6) |
| Origin | `origin` → `https://github.com/a-langlais/MaestroPesto` |
| Identité Git du PO | `Ge-LAG` |

## B.5 Bonnes pratiques locales

### BP-01 à BP-07 (héritées du template V5)

- **BP-01** Réutiliser la référence avec discernement.
- **BP-02** Valider les dépendances critiques avant toute confiance.
- **BP-03** Aucun artefact sensible au commit.
- **BP-04** Diff propre avant staging (jamais `git add -A`).
- **BP-05** Push seulement sur confirmation du PO (R-01).
- **BP-06** Le plan produit ne remplace pas le journal projet.
- **BP-07** Le code sensible doit rester lisible.

### BP-08 — Synchronisation stricte PROJET.json ↔ PROJET.md

Après chaque changement significatif : `PROJET.json` est mis à jour en premier ; `PROJET.md` est ajusté ; les deux documents sont commités dans le même lot ou un commit `docs: project sync` dédié. **Non négociable** (R-05).

### BP-09 — Test-Dev et balle dans le camp du PO

Voir template. Si `test_dev_en_cours` est actif en début de session, l'agent doit **rappeler au PO** et **demander validation** avant toute modification de code.

### BP-10 — Consignation structurée des retours test dev

Format obligatoire dans `PROJET.backlog_test_dev` : `id` (`td-NNN`), `libelle`, `description`, `priorite` (BP-12), `statut`, `tags` dont `test_dev`.

### BP-11 — Cycle de vie des états Test-Dev

`en_attente_po` → `teste_revele_bugs` → `valide` (déplacement dans `Test-Dev/Traité/`).

### BP-12 — Grille de priorisation automatique

| Priorité | Critères |
|----------|----------|
| **Critical** | Perte de données, faille de sécurité, crash bloquant, corruption de base. |
| **High** | Parcours critique cassé mais contournable. |
| **Medium** | UX gênante, ralentissement, workaround simple. |
| **Low** | Cosmétique, doc, optimisation mineure. |

Présentée au PO pour validation. Vaut pour `backlog_test_dev` **et** `backlog_audit_code`.

### BP-13 — Test rouge avant correction, test vert après

Chaque correction de bug est justifiée par un test qui échoue avant la correction et passe après.

### BP-14 — Build bloqué si un test échoue

Avant `flutter build` ou tout build, exécuter `flutter test`. Si un test échoue, bloquer et proposer une correction.

### BP-15 — Tests créés ou mis à jour en même temps que la feature

Aucune feature n'est terminée sans tests anti-régression correspondants qui passent.

### BP-16 — Pipeline de vérification scriptisée

Le repo fournit un script local (`scripts/prebuild-checks.sh` à créer) qui enchaîne `flutter test` puis `flutter build`. **Non créé au bootstrap** (anti-pattern « scripts inutilisés » du template V5).

### BP-17 — Double-lecture croisée PROJET.json ↔ PROJET.md avant commit de suivi

Voir template. Renforcement de BP-08.

### BP-18 — Backlog d'audit de code structuré

Format `ac-NNN` dans `PROJET.backlog_audit_code`. Ne se mélange jamais avec `backlog_test_dev`.

### BP-19 — Garde-fou bootstrap : suivi non commité

Voir template. Au bootstrap, si `git status` montre des modifications non commitées de `PROJET*`, `METHOD*` ou `INDEX-docs.md`, signaler au PO avant tout travail.

### BP-20 — Protection des documents de méthode

`METHOD.md` et `METHOD.json` modifiables uniquement via A.8.

## B.6 Politique de branche et format de commit (override local documenté)

> **Override local du défaut V5.** La règle locale ci-dessous est plus stricte que la convention générique du template et **prévaut localement** (cf. A.2). Elle a été introduite à la demande explicite de Ge-LAG lors de l'adaptation (2026-08-22) et journalisée via A.8.

### Règles de branche (BP-21)

- **Aucune modification directe sur `main`** : pas de commit, pas de push, pas de reset. `main` est une cible de fusion, jamais un espace de travail.
- **Toute évolution** (feature, fix, refactor, doc, chore, method) **ouvre une branche dédiée** au format :
  ```text
  Ge-LAG/<theme>-<resume-2-3-mots>
  ```
  - préfixe obligatoire `Ge-LAG/` ;
  - slug en kebab-case ;
  - 2 à 3 mots significatifs dans le résumé.
- La branche est poussée vers `origin` ; la fusion dans `main` passe par une **Pull Request** (revue PO + checks CI au vert).
- **Pas de squash automatique** qui effacerait le détail des commits : les commits restent visibles après merge.
- **Pas de force-push** (R-02).

Exemples valides :

- `Ge-LAG/recipe-search`
- `Ge-LAG/ciqual-import`
- `Ge-LAG/method-bootstrap-v5-doc`

Exemples invalides :

- `feature/recipe-search` (manque `Ge-LAG/`)
- `Ge-LAG/RecipeSearch` (pas de kebab-case)
- `Ge-LAG/recipe-search-and-pagination-and-filtering` (trop de mots)
- `Ge-LAG/main` (jamais de branche nommée comme la cible)

### Format de commit (BP-22)

**Format obligatoire** sur toutes les branches de ce projet :

```text
theme: resume 2-3 mots
```

Règles précises :

- **Thème au singulier**, par exemple :
  - `ui` (interface utilisateur)
  - `ux` (expérience utilisateur, ergonomie, accessibilité)
  - `backend` (logique métier, services)
  - `db` (schéma, migration, persistance)
  - `test` (ajout ou correction de tests)
  - `docs` (documentation)
  - `build` (outillage, CI, packaging)
  - `method` (méthode elle-même : METHOD, INDEX, bootstrap)
  - `chore` (maintenance, dépendances, nettoyage)
  - `fix` (correction de bug)
  - `refactor` (refonte sans changement de comportement)
  - `feat` (nouvelle fonctionnalité)
- **Séparateur** entre thème et résumé : deux-points puis espace (` : ` interdit — uniquement `: `).
- **Résumé** : 2 à 3 mots significatifs, en minuscules, **sans point final**.
- **1 commit = 1 préoccupation atomique** (1 feature, 1 fix, 1 refactor, 1 doc, 1 chore).
- **Pas de commit fourre-tout** ; pas de WIP commité sans entente PO.
- **Jamais de secret, token, clé, dump ou donnée utilisateur réelle** (R-03).
- Si un changement touche à la fois plusieurs thèmes (ex. UI + backend), faire **plusieurs commits**.

Exemples valides :

- `ui: recipe detail layout`
- `backend: ciqual xml parser`
- `db: drift schema initial`
- `test: recipe search filter`
- `docs: readme quickstart`
- `build: pubspec bump 1.0.0`
- `method: bootstrap v5 doc`
- `chore: clean dead imports`
- `fix: divide-by-zero guard`

Exemples invalides :

- `feat(recipes): add the recipe search feature with filters and sort` (format `mode`)
- `update readme` (pas de thème)
- `WIP` (jamais de WIP)
- `misc: stuff` (thème trop vague)

### Bonnes pratiques de développement actuelles (BP-23)

Règles non négociables ou fortement recommandées, indépendantes du stack :

- **Revue de code obligatoire** avant merge d'une PR (au minimum le PO valide).
- **Tests automatisés verts** avant tout build ou merge (R-04).
- **Anti-régression** : tout fix de bug est accompagné d'un test (BP-13).
- **CI/CD** : `scripts/prebuild-checks.sh` et `scripts/release.sh` à créer dès qu'un pipeline local est nécessaire (anti-pattern « scripts inutilisés »).
- **DRY, séparation logique / effets de bord**, lecture facile du code sensible (BP-07).
- **Logs sans chemins utilisateur ni identifiants métier** (B.2-6).
- **Dépendances** : `flutter pub outdated` au minimum une fois par release ; pas de dépendance ajoutée sans justification documentée dans le commit ou `PROJET`.
- **Versioning semver** dans `pubspec.yaml` ; bump documenté dans `PROJET` à chaque release.
- **Pas de merge --no-ff masqué** : historique linéaire lisible.
- **Pas de rebase d'historique publié** ; pas de force-push (R-02).
- **Pas de TODO non tracés** : tout TODO ouvert devient une entrée dans `PROJET.questions_ouvertes` ou `backlog_test_dev`.
- **Commits sign-offés** quand l'identité du codeur est connue (bonne pratique 2025) — encouragement, non bloquant au bootstrap.
- **Conventional Comments** dans la revue de PR (clarification, blocking, question, etc.) — bonne pratique 2025, à appliquer dès qu'une PR est ouverte.

## B.7 Cycle de release

1. implémenter sur la branche de travail ;
2. exécuter `flutter test` ;
3. vérifier `flutter build` et le démarrage ;
4. mettre à jour la documentation de suivi ;
5. committer de façon atomique (format BP-22) ;
6. pousser seulement après validation explicite du PO (R-01) ;
7. ouvrir la PR ; revue PO + checks au vert ;
8. merger vers `main` (pas de squash) ;
9. tagger `v<MAJOR>.<MINOR>[.<PATCH>]` quand un jalon est atteint.

---

# Partie C — Tests anti-régressions et CI/CD local

## C.1 Philosophie

Les tests anti-régressions sont un **garde-fou systématique**, indépendamment du langage ou du framework. Leur rôle est de capturer le comportement attendu et de le vérifier automatiquement à chaque itération.

Principes :

- un test qui échoue bloque le build ;
- un bug corrigé doit être accompagné d'un test qui le reproduit ;
- les tests vivent avec le code ;
- les fichiers de test sont isolés dans `test/`.

## C.2 Organisation des fichiers de test

Pour ce projet, le dossier dédié est **`test/`**. Sa structure reflète celle de `lib/` quand le langage le permet :

```text
test/
  widget_test.dart                    -- point d'entrée historique de la suite
  README.md                           -- contrat et guide (à créer)
  features/
    recipes/
      recipe_search_test.dart
      recipe_detail_test.dart
    nutrition/
      ciqual_parser_test.dart
      nutrition_engine_test.dart
  core/
    database/
      drift_schema_test.dart
```

### Règles de nommage

- Un fichier de test porte le nom du module testé suffixé `_test.dart`.
- Un test décrit un comportement métier, pas une implémentation.
- Les fixtures peuvent vivre dans `test/fixtures/`.

## C.3 Règle d'or : test avant build

> **Avant chaque `flutter build`, la suite `flutter test` doit être entièrement verte.**

### Séquence standard

```text
1. tests  → 2. build  →  3. run / smoke test  →  4. commit
   ↑_____________________________________________________|
                    (boucle de correction)
```

## C.4 Types de tests attendus

| Type | Objectif | Quand l'ajouter |
|------|----------|-----------------|
| **Unitaires** | Vérifier une fonction, un module, un algorithme en isolation. | Dès la création d'une brique pure ou d'une logique métier (recipe, nutrition, parser Ciqual). |
| **Intégration** | Vérifier l'assemblage (DB, fichiers, services). | Dès qu'une I/O ou une dépendance externe entre en jeu (Drift, export PDF). |
| **Widget** | Vérifier un composant UI en isolation. | Pour les widgets critiques (classeur, fiche recette). |
| **Golden / Snapshot** | Capturer une sortie de référence. | Pour les exports PDF, le rendu des fiches. |
| **Smoke** | Vérifier que l'app démarre. | À chaque jalon, avant release. |

## C.5 Création et mise à jour continue des tests

- À chaque nouvelle feature : identifier les chemins critiques, ajouter un test, vérifier rouge puis vert.
- À chaque correction de bug : reproduire dans un test, vérifier qu'il échoue avec l'ancien, corriger, vérifier vert global.
- Refactoring par petits pas ; tests verts à chaque étape.

## C.6 CI/CD local — Contrôle continu et release automatique

Pipeline minimale :

```text
[flutter analyze] → [flutter test] → [flutter build] → [smoke test] → [tag] → [release artifacts]
```

La partie **obligatoire** est :

```text
[flutter test] → [flutter build]
```

Scripts fournis (à créer par stack) — **non créés au bootstrap** (anti-pattern) :

- `scripts/prebuild-checks.sh` — exécute `flutter test` puis `flutter build`. S'arrête à la première erreur.
- `scripts/release.sh` — pipeline complet (analyze, tests, build, smoke, tag, artefacts dans `build/`).

## C.7 Anti-patterns à éviter

- Tests sans assertion significative.
- Tests couplés à l'environnement du développeur (pas de chemins absolus personnels).
- Tests laissés en échec « parce qu'on sait pourquoi ».
- Tests commités avec des données sensibles.
- Tests jamais mis à jour après une évolution de spec.
- Tests mélangés au code source applicatif.

## C.8 Bonnes pratiques liées — Tests et CI/CD

Voir BP-13 à BP-16 en Partie B.

---

## Annexe 1 — Checklist mécanique avant tout commit

À dérouler **littéralement** avant chaque `git commit`. Une seule réponse « non » bloque le commit.

1. Ai-je relu `git status` et le diff de **chaque** fichier stagé ? (BP-04)
2. Le commit contient-il uniquement des fichiers liés au lot annoncé ? (commits atomiques)
3. Y a-t-il un secret, une donnée réelle, un fichier sensible ou un artefact interdit dans le diff ? → si oui, **bloquer** (R-03, BP-03)
4. Si le commit touche du code : la suite de tests a-t-elle été exécutée et est-elle verte ? (R-04, BP-14)
5. Si le commit touche `PROJET.json` ou `PROJET.md` : la double-lecture croisée BP-17 a-t-elle été faite sur les champs sensibles ?
6. Si le commit touche `METHOD.md` ou `METHOD.json` : le protocole A.8 a-t-il été suivi (validation PO, version, journal) ? (R-06)
7. Si un document a été créé, déplacé ou supprimé : `INDEX-docs.md` est-il à jour ?
8. Le message de commit suit-il le format `theme: resume 2-3 mots` (BP-22) avec 2-3 mots en minuscules, sans point final ?
9. La branche respecte-t-elle le format `Ge-LAG/<theme>-<resume>` (BP-21) ?
10. Aucun fichier hors-scope (permissions, CRLF, IDE) n'est stagé par erreur ?

## Annexe 2 — Checklist courte de fin de session

- code ou docs produits relus ;
- `PROJET.json` et `PROJET.md` alignés si changement significatif (BP-17) ;
- `INDEX-docs.md` mis à jour si besoin ;
- `METHOD.md` et `METHOD.json` alignés si une règle a été validée (A.8) ;
- `flutter test` vert avant tout `flutter build` ;
- `flutter analyze` propre ou warnings documentés ;
- documents de suivi commités (pas de reliquat laissé à la session suivante, BP-19) ;
- prochain point de reprise explicite dans `PROJET`.

## Annexe 3 — Journal des révisions de la méthode

| Date | Version | Résumé | Validation PO |
|------|---------|--------|---------------|
| 2026-08-22 | 1.0.0 | Adaptation du template Méthode V5 au projet MaestroPesto. Ajout des règles locales BP-21 (branche PR obligatoire, préfixe `Ge-LAG/`), BP-22 (format de commit strict `theme: 2-3 mots`), BP-23 (bonnes pratiques dev actuelles). Stack Flutter (Dart ^3.13.1). Aucun script CI/CD créé au bootstrap (anti-pattern « scripts inutilisés »). | Oui |