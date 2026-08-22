# GUIDE-ADAPTATION.md — Comment personnaliser le template V4

Ce guide explique comment passer du template généraliste à une méthode opérationnelle dans un projet concret.

## Vue d'ensemble

Le dossier `Méthode Template V4/` contient :

| Fichier template | Fichier cible dans le projet | Rôle |
|------------------|------------------------------|------|
| `METHOD-TEMPLATE.md` | `METHOD.md` | Méthode humaine complète |
| `METHOD-TEMPLATE.json` | `METHOD.json` | Méthode machine structurée |
| `METHOD-TEMPLATE-BOOTSTRAP.md` | `METHOD-BOOTSTRAP.md` | Digest de démarrage |
| `INDEX-TEMPLATE.md` | `INDEX-docs.md` | Index documentaire vivant |
| `test/README-TEMPLATE.md` | `test/README.md` | Contrat du dossier de tests |
| `scripts/Invoke-PreBuildChecks-TEMPLATE.ps1` | `scripts/Invoke-PreBuildChecks.ps1` | Script test → build (Windows/PowerShell) |
| `scripts/Invoke-Release-TEMPLATE.ps1` | `scripts/Invoke-Release.ps1` | Script de release (Windows/PowerShell) |
| `scripts/prebuild-checks-TEMPLATE.sh` | `scripts/prebuild-checks.sh` | Script test → build (Unix/Bash) |
| `scripts/release-TEMPLATE.sh` | `scripts/release.sh` | Script de release (Unix/Bash) |
| `safeguard-mistral/SKILL.md` | `safeguard-mistral/SKILL.md` (nom inchangé, **copie facultative**) | Extension conditionnelle — à copier uniquement si le projet est susceptible d'être implémenté par un modèle Mistral AI. Copier ≠ activer : l'**activation** exige deux conditions cumulatives (modèle Mistral AI **et** mention explicite dans le prompt initial), cf. A.9 |

## Ce qui ne s'adapte PAS

Les éléments suivants constituent la **couche anti-dérive** de la V4 et doivent être conservés tels quels (seuls les placeholders qu'ils contiennent sont remplacés) :

- les **règles absolues A.0 (R-01 à R-10)** et l'ordre de précédence ;
- la **conduite en cas de doute (A.7)** ;
- le **protocole de révision de la méthode (A.8)** et BP-20 ;
- les **checklists des Annexes 1 et 2** ;
- les bonnes pratiques **BP-08, BP-17, BP-18, BP-19** (synchronisation et garde-fous de suivi).

Affaiblir ou supprimer un de ces éléments lors de l'adaptation revient à retirer les protections contre la dérive agentique. Si un projet a réellement besoin d'un assouplissement, il se documente comme un override explicite validé par le PO, jamais comme une suppression silencieuse.

## Étape 1 — Remplacer les placeholders

### Dans `METHOD.md` et `METHOD.json`

Les placeholders à remplacer systématiquement sont listés dans `METHOD.json` sous `placeholders_obligatoires.liste`. Les principaux :

| Placeholder | Exemple Haskell-Vault | Exemple Node/React | Exemple Rust |
|-------------|----------------------|-------------------|--------------|
| `<NOM_DU_PROJET>` | `Haskell-Vault` | `mon-portail` | `mon-cli` |
| `<VERSION_METHODE>` | `2.0.0` | `1.0.0` | `1.0.0` |
| `<DATE_ADAPTATION>` | `2026-05-31` | (date du jour) | (date du jour) |
| `<STACK_TECHNIQUE>` | `Haskell, GTK4, SQLCipher` | `TypeScript, React, Node, PostgreSQL` | `Rust, Clap, SQLite` |
| `<LANGAGE_PRINCIPAL>` | `Haskell` | `TypeScript` | `Rust` |
| `<DOSSIER_SOURCE>` | `src/` | `src/` | `src/` |
| `<DOSSIER_TEST>` | `test/` | `test/` | `tests/` |
| `<COMMANDE_BUILD>` | `cabal build` | `npm run build` | `cargo build` |
| `<COMMANDE_TEST>` | `cabal test` | `npm test` | `cargo test` |
| `<DOSSIER_RELEASE>` | `release/` | `dist/` | `target/release/` |
| `<BRANCHE_PRINCIPALE>` | `main` | `main` | `main` |
| `<ORIGIN>` | `origin` | `origin` | `origin` |
| `<MANIFESTE_BUILD>` | `haskell-vault.cabal` | `package.json` | `Cargo.toml` |
| `<NOM_ARTEFACT>` | `haskell-vault` | `bundle.js` / app web | `mon-cli` |
| `<ROADMAP>` | `PLAN-DEVELOPPEMENT` | `ROADMAP` | `ROADMAP` |
| `<DOSSIER_REFERENCE>` | `Application-référence` | `docs/reference` | `docs/reference` |

### Dans les scripts

Remplacez les variables de configuration en début de fichier :

```powershell
$CommandTest = "npm test"
$CommandBuild = "npm run build"
```

ou

```bash
COMMAND_TEST="cargo test"
COMMAND_BUILD="cargo build --release"
```

## Étape 2 — Initialiser le versionnage de la méthode

1. Dans `METHOD.md`, fixez l'en-tête « Version de la méthode » à `1.0.0`.
2. Dans `METHOD.json`, fixez `version_methode` à `"1.0.0"`.
3. Initialisez l'Annexe 3 (journal des révisions) et `journal_revisions` avec une première ligne : date d'adaptation, version `1.0.0`, résumé « Adaptation du template Méthode V4 », validation PO `oui`.

Toute évolution ultérieure de la méthode passera par le protocole A.8 (proposition → validation PO → application → incrément de version → journalisation → commit `docs(method)`).

## Étape 3 — Adapter la politique de branche

Par défaut, le template suppose des branches de feature fusionnées dans `<BRANCHE_PRINCIPALE>`. Si le projet nécessite un override (travail direct sur `main`, mono-développeur, etc.) :

1. Dans `METHOD.md`, mettez à jour la section **B.6 Politique de branche**.
2. Dans `METHOD.json`, passez `politique_de_branche.override` à `true` et documentez `mode`, `motifs` et `regles`.
3. L'override est documenté via le protocole A.8 (c'est une révision de la méthode).

## Étape 4 — Ajuster l'architecture

Dans `METHOD.md` **B.1 Architecture et stack**, adaptez :

- le type d'application (web, desktop, mobile, CLI, API, librairie, data...) ;
- la structure du dossier source (`src/App/`, `src/Domaine/`, `lib/`, `app/`, `packages/`, etc.) ;
- les couches métier et techniques pertinentes.

Dans `METHOD.json`, remplissez `project_specific_extension.architecture` avec les valeurs concrètes.

## Étape 5 — Adapter les tests

1. Créez le dossier `<DOSSIER_TEST>/` s'il n'existe pas.
2. Copiez `test/README-TEMPLATE.md` vers `<DOSSIER_TEST>/README.md`.
3. Remplacez les placeholders.
4. Créez le point d'entrée de la suite si le stack en a besoin (`Spec.hs`, `test.js`, `tests/lib.rs`, etc.).
5. Créez les premiers fichiers de test en miroir de `src/`.

## Étape 6 — Adapter les scripts CI/CD

### Si le projet est principalement Windows/PowerShell

1. Copiez `scripts/Invoke-PreBuildChecks-TEMPLATE.ps1` → `scripts/Invoke-PreBuildChecks.ps1`.
2. Copiez `scripts/Invoke-Release-TEMPLATE.ps1` → `scripts/Invoke-Release.ps1`.
3. Adaptez les variables `$CommandTest`, `$CommandBuild`, `$CommandSmoke`, `$CommandBundle`.
4. Si le projet a besoin d'un wrapper d'environnement (ex: MSYS2), ajoutez-le avant les appels.

### Si le projet est principalement Unix/Bash

1. Copiez `scripts/prebuild-checks-TEMPLATE.sh` → `scripts/prebuild-checks.sh`.
2. Copiez `scripts/release-TEMPLATE.sh` → `scripts/release.sh`.
3. Adaptez les variables `COMMAND_TEST`, `COMMAND_BUILD`, `COMMAND_SMOKE`, `COMMAND_BUNDLE`.
4. N'oubliez pas : `chmod +x scripts/prebuild-checks.sh scripts/release.sh`.

### Vous pouvez aussi conserver les deux

Certains projets ont des contributeurs sur Windows et Unix. Dans ce cas, gardez les deux jeux de scripts et documentez-les dans `INDEX-docs.md`.

## Étape 7 — Créer PROJET.md et PROJET.json

Le template ne fournit pas de `PROJET-TEMPLATE.md/json` car l'état projet est spécifique à chaque contexte. Vous devez créer :

- `PROJET.json` : source de vérité machine avec au minimum :
  - `schema_version`
  - `document_id`
  - `projet`
  - `phase_courante`
  - `etat_general`
  - `focus_immediat`
  - `questions_ouvertes`
  - `journal_des_sessions`
  - `test_dev_en_cours`
  - `backlog_test_dev`
  - `backlog_audit_code`
  - `documents_associes`
- `PROJET.md` : miroir humain de ce JSON.

Les clés `backlog_test_dev` (td-NNN, retours de test manuel) et `backlog_audit_code` (ac-NNN, constats d'audit de code) sont **distinctes** et ne doivent jamais être mélangées (BP-10, BP-18).

## Étape 8 — Mettre à jour l'index documentaire

Copiez `INDEX-TEMPLATE.md` vers `INDEX-docs.md`, puis :

1. Remplacez les placeholders.
2. Supprimez les lignes des documents qui n'existent pas encore.
3. Ajoutez les documents spécifiques au projet.
4. Maintenez `INDEX-docs.md` à jour à chaque création ou déplacement documentaire.

## Étape 9 — Valider le bootstrap

Avant de considérer le template comme adapté, vérifiez :

- [ ] Tous les placeholders `<...>` ont été remplacés dans `METHOD.md`, `METHOD.json`, `METHOD-BOOTSTRAP.md`, `INDEX-docs.md`, `test/README.md`.
- [ ] La version de la méthode est initialisée (`1.0.0`) et le journal des révisions contient sa première ligne.
- [ ] Les règles absolues A.0 et les annexes (checklists) sont intactes.
- [ ] Les commandes des scripts CI/CD sont correctes et exécutables.
- [ ] `<COMMANDE_TEST>` passe dans l'environnement cible.
- [ ] `<COMMANDE_BUILD>` passe après `<COMMANDE_TEST>`.
- [ ] Les documents `PROJET.json` et `PROJET.md` existent et sont cohérents.
- [ ] Le dossier `plans/` existe (même vide avec un `README.md`).
- [ ] Le dossier `Test-Dev/` existe (même vide avec un `README.md` et un sous-dossier `Traité/`).

## Exemple d'adaptation rapide — Node/npm

```text
<NOM_DU_PROJET>           -> mon-portail
<VERSION_METHODE>         -> 1.0.0
<DATE_ADAPTATION>         -> 2026-06-10
<STACK_TECHNIQUE>         -> TypeScript, React, Node, PostgreSQL
<LANGAGE_PRINCIPAL>       -> TypeScript
<DOSSIER_SOURCE>          -> src/
<DOSSIER_TEST>            -> test/
<COMMANDE_BUILD>          -> npm run build
<COMMANDE_TEST>           -> npm test
<DOSSIER_RELEASE>         -> dist/
<BRANCHE_PRINCIPALE>      -> main
<ORIGIN>                  -> origin
<MANIFESTE_BUILD>         -> package.json
<NOM_ARTEFACT>            -> bundle
<ROADMAP>                 -> ROADMAP
<DOSSIER_REFERENCE>       -> docs/reference
```

Adaptation des scripts PowerShell :

```powershell
$CommandTest = "npm test"
$CommandBuild = "npm run build"
$CommandSmoke = "node dist/server.js --smoke-test"
$CommandBundle = "npm run package"
$ReleaseDir = "dist"
```

## Anti-patterns lors de l'adaptation

- **Oublier de remplacer un placeholder** → le document reste un template inutilisable.
- **Affaiblir la couche anti-dérive** (règles absolues, protocole A.8, checklists) → les protections contre la dérive agentique disparaissent ; tout assouplissement se documente comme override validé par le PO.
- **Surcharger la méthode avec des règles contradictoires** → si une règle locale contredit le template, documentez explicitement l'override.
- **Créer des scripts inutilisés** → ne gardez que les scripts correspondant aux OS/stacks cibles.
- **Négliger `METHOD.json`** → c'est la source de vérité machine pour les agents ; elle doit rester synchronisée avec `METHOD.md`.
- **Oublier d'initialiser le journal des révisions** → la traçabilité des évolutions de la méthode commence dès l'adaptation.

## Maintenance du template adapté

Chaque fois qu'une bonne pratique structurante émerge dans le projet :

1. Proposez-la au PO (protocole A.8) — jamais de modification de METHOD sans validation.
2. Une fois validée : mettez à jour `METHOD.md`, puis `METHOD.json`, incrémentez la version, journalisez.
3. Si la BP est généralisable, envisagez de la réintégrer dans le template (en créant une nouvelle version du template, l'ancienne partant en `Archives/`).
4. Mettez à jour `INDEX-docs.md` si un nouveau document ou script apparaît.

### Vérification de synchronisation PROJET.json ↔ PROJET.md (BP-17)

Avant de committer toute modification de suivi (`PROJET.json` ou `PROJET.md`) :

- Relisez les champs sensibles dans les deux documents (`focus_immediat`, `backlog_test_dev`, `backlog_audit_code`, `test_dev_en_cours`, `journal_des_sessions`, `questions_ouvertes`).
- Assurez-vous que les statuts, dates, priorités et descriptions sont strictement identiques.
- Corrigez tout écart immédiatement avant le commit.

Une désynchronisation rend le point de reprise ambigu pour l'humain comme pour l'agent.
