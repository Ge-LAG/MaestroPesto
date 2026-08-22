# METHOD-BOOTSTRAP.md — Digest de démarrage (MaestroPesto)

> Digest rapide de `METHOD.md`. À lire en premier en début de session, puis revenir à `METHOD.md` si un arbitrage ou une nuance manque.
> Les **règles absolues** ci-dessous s'appliquent intégralement même si seul ce digest a été lu.

## Ordre de lecture

1. `METHOD.json`
2. `METHOD.md`
3. `PROJET.json`
4. `PROJET.md`
5. `plans/`
6. `ARCHITECTURE.md` (roadmap) si un détail produit ou de phasage manque

## Règles absolues (A.0 — non négociables)

- **R-01** : pas de push vers `origin` sans confirmation explicite du PO dans la session courante.
- **R-02** : pas de mutation Git destructrice (`reset --hard`, rebase réécrivant l'historique, `push --force`, `clean -fd`...) sans validation.
- **R-03** : pas de secret, donnée réelle ni fichier sensible déchiffré au commit.
- **R-04** : pas de build si la suite de tests n'est pas verte juste avant.
- **R-05** : pas de commit de `PROJET.json` sans `PROJET.md` strictement aligné (et inversement).
- **R-06** : pas de modification de `METHOD.md` / `METHOD.json` sans validation PO (protocole A.8 : proposer → valider → appliquer → versionner → journaliser).
- **R-07** : pas de tâche « terminée » sans vérifications exécutées ou impossibilité signalée.
- **R-08** : ne jamais inventer un état, un résultat de test ou un hash : tout fait rapporté doit avoir été observé.
- **R-09** : ne jamais supprimer ou réécrire un document de suivi hors des mises à jour incrémentales prévues.
- **R-10** : en cas de contradiction → ordre de précédence : instruction PO > METHOD > PROJET.json > PROJET.md > autres docs ; si ça ne tranche pas, **s'arrêter et demander**.

## Garde-fous au bootstrap

- `test_dev_en_cours` actif → le rappeler au PO et attendre validation avant de coder (BP-09).
- Suivi (`PROJET*`, `METHOD*`, `INDEX-docs.md`) modifié non commité d'une session précédente → le signaler avant tout travail (BP-19).
- Annoncer après bootstrap : branche, état du working tree, test-dev éventuel, point de reprise.

## Règles courtes

- `PROJET.json` est la source de vérité projet ; `PROJET.md` est le miroir humain (BP-17 : double-lecture avant commit).
- `INDEX-docs.md` doit suivre toute création ou déplacement documentaire.
- Retours de test manuel → `backlog_test_dev` (td-NNN) ; constats d'audit de code → `backlog_audit_code` (ac-NNN) — ne jamais mélanger (BP-18).
- Dérouler la **checklist mécanique pré-commit** (Annexe 1 de `METHOD.md`) avant chaque commit.
- Le skill `safeguard-mistral/SKILL.md` est une **extension conditionnelle inactive par défaut** : il ne s'applique que si (1) le modèle qui code est un modèle **Mistral AI** **et** (2) le **prompt initial** de la session le mentionne explicitement. Sinon : ne pas le lire, ne pas le citer, suivre `METHOD.md` seul (cf. A.9). Les fichiers `safeguard-mistral/references/` sont **absents** : ne jamais en inventer le contenu ni prétendre les avoir lus (R-08).

## Spécificités du projet

- Type d'application : Flutter **local-first** (desktop + mobile)
- Stack technique : Flutter (Dart `^3.13.1`), cibles Windows / macOS / Linux / Android / iOS, SQLite via Drift, données Ciqual XML
- Référence technique principale : `lib/` (organisation `lib/features/<domaine>/{data,domain,presentation}`)
- Référence produit principale : `ARCHITECTURE.md`
- Points de vigilance : pas de backend au bootstrap, pas de secrets au commit, logs sans chemin de fichier utilisateur (B.2-6).
- Politique locale actuelle : voir Partie B.6 de `METHOD.md` — **override** : branches PR obligatoires avec préfixe `Ge-LAG/`, format de commit strict `theme: resume 2-3 mots`, bonnes pratiques dev 2025 (BP-21, BP-22, BP-23).

## Format de branche et de commit (rappel BP-21 / BP-22)

```text
# Branche
Ge-LAG/<theme>-<resume-2-3-mots>

# Commit
theme: resume 2-3 mots
```

Thèmes acceptés : `ui`, `ux`, `backend`, `db`, `test`, `docs`, `build`, `method`, `chore`, `fix`, `refactor`, `feat`.

Exemples :

- Branche : `Ge-LAG/recipe-search`
- Commits : `ui: recipe detail layout`, `backend: ciqual xml parser`, `db: drift schema initial`, `method: bootstrap v5 doc`.

## Réflexes d'implémentation

- Vérifier d'abord si la référence technique possède déjà la brique recherchée.
- Séparer logique pure et code à effets autant que possible.
- Garder le code sensible simple à relire et à auditer.
- **Créer ou mettre à jour les tests anti-régressions dans `test/` en même temps que le code** (BP-15).
- **Exécuter `flutter test` avant `flutter build`** (R-04, BP-14).
- **Créer `scripts/prebuild-checks.sh` et `scripts/release.sh`** quand un pipeline local devient nécessaire (anti-pattern « scripts inutilisés » → ne pas les créer tant qu'ils ne sont pas utilisés).
- **Vérifier la cohérence croisée `PROJET.json` ↔ `PROJET.md` avant tout commit de suivi (BP-17).**
- Mettre à jour `PROJET` après chaque avancée significative et committer le suivi avant la fin de session (BP-19).