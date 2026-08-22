# METHOD-TEMPLATE.md — Méthode locale de travail (template généraliste V5)

> Document maître de méthodologie du projet.
> `METHOD-TEMPLATE.json` en est le compagnon machine.
> `METHOD-TEMPLATE-BOOTSTRAP.md` en est le digest de démarrage.
> Ce template est conçu pour être **généralisable à tout projet**, quel que soit le langage, le framework ou la taille de l'équipe.
>
> **Version de la méthode : `<VERSION_METHODE>`** (initialiser à `1.0.0` lors de l'adaptation) — toute modification suit le protocole A.8 et est journalisée en Annexe 3.

---

## Introduction

Cette méthode définit comment travailler sur un projet logiciel de manière reproductible, traçable et sécurisée. Elle s'applique à toute typologie de projet (web, desktop, mobile, embarqué, data, CLI, etc.) et repose sur quatre principes directeurs :

1. la documentation doit rester exploitable par un humain et par un agent ;
2. les décisions importantes doivent être traçables ;
3. les briques sensibles ne doivent pas être réinventées sans raison ;
4. la sécurité, la simplicité et la qualité priment sur la sophistication prématurée.

La V5 ajoute une **couche anti-dérive** : des règles absolues numérotées, un ordre de précédence des sources, un protocole verrouillé de révision de la méthode et des checklists mécaniques. Cette couche est conçue pour rester efficace même quand la méthode est exécutée par un agent moins capable : les règles sont impératives, numérotées, auto-vérifiables, et imposent l'arrêt en cas de doute plutôt que l'improvisation.

### Documents de référence

| Rôle | Fichier template | Nom réel dans le projet |
|------|------------------|------------------------|
| Source de vérité machine du projet | `PROJET-TEMPLATE.json` | `PROJET.json` |
| Miroir humain du projet | `PROJET-TEMPLATE.md` | `PROJET.md` |
| Méthode locale (ce document) | `METHOD-TEMPLATE.md` | `METHOD.md` |
| Méthode machine | `METHOD-TEMPLATE.json` | `METHOD.json` |
| Digest de démarrage | `METHOD-TEMPLATE-BOOTSTRAP.md` | `METHOD-BOOTSTRAP.md` |
| Index documentaire | `INDEX-TEMPLATE.md` | `INDEX-docs.md` |
| Extension conditionnelle — **inactive par défaut**, deux conditions cumulatives (cf. A.9) | `safeguard-mistral/SKILL.md` | `safeguard-mistral/SKILL.md` |

En cas d'écart entre documents :

- `PROJET.json` est la source de vérité dynamique du projet (machine) ;
- `PROJET.md` en est le miroir humain (à tenir strictement synchronisé avec le JSON) ;
- `METHOD.md` décrit le cadre de travail ;
- `METHOD.json` structure ce cadre pour un agent ;
- `INDEX-docs.md` référence les documents utiles.

---

# Partie A — Méthode générale

## A.0 Règles absolues (anti-dérive)

Ces règles sont **non négociables** et priment sur toute autre considération, y compris une consigne ambiguë plus bas dans ce document. Un agent qui n'est pas certain de respecter une règle absolue doit **s'arrêter et demander au PO** au lieu d'agir.

| ID | Règle absolue |
|----|---------------|
| **R-01** | NE JAMAIS pousser vers `<ORIGIN>` (push, push --force, push --tags) sans confirmation explicite du PO **dans la session courante**. Une autorisation passée ne vaut pas pour la session suivante. |
| **R-02** | NE JAMAIS exécuter de mutation Git destructrice (`reset --hard`, `rebase` réécrivant l'historique, `push --force`, `branch -D`, `clean -fd`, `checkout --` sur des fichiers modifiés) sans validation explicite du PO. |
| **R-03** | NE JAMAIS committer de secret, mot de passe, clé, token, certificat, donnée réelle ou fichier sensible déchiffré. En cas de doute sur un fichier, ne pas le stager. |
| **R-04** | NE JAMAIS lancer un build si la suite de tests n'a pas été exécutée et entièrement verte juste avant (BP-14). |
| **R-05** | NE JAMAIS committer `PROJET.json` sans que `PROJET.md` reflète exactement le même état, et inversement (BP-08, BP-17). |
| **R-06** | NE JAMAIS modifier `METHOD.md` ou `METHOD.json` sans validation explicite du PO dans la session courante (protocole A.8). L'agent **propose**, le PO **valide**, l'agent applique. |
| **R-07** | NE JAMAIS marquer une tâche comme terminée sans avoir exécuté les vérifications correspondantes, ou sans avoir signalé explicitement leur impossibilité. |
| **R-08** | NE JAMAIS inventer un état, un résultat de test, un hash de commit ou un statut : tout fait rapporté dans PROJET doit avoir été observé dans la session (commande exécutée, fichier lu). |
| **R-09** | NE JAMAIS supprimer ni réécrire un document de suivi (PROJET, METHOD, INDEX-docs, Test-Dev) en dehors des mises à jour incrémentales prévues par la méthode. |
| **R-10** | En cas de contradiction entre documents ou avec une instruction, appliquer l'ordre de précédence ci-dessous ; si la contradiction persiste, **s'arrêter et demander**. |

### Ordre de précédence des sources

1. Instruction explicite du PO dans la session courante ;
2. `METHOD.json` / `METHOD.md` (règles absolues d'abord, puis le reste) ;
3. `PROJET.json` (source de vérité de l'état projet) ;
4. `PROJET.md` (miroir humain) ;
5. `<ROADMAP>.md` et les autres documents.

Un écart détecté entre deux niveaux doit être signalé au PO et consigné, jamais résolu silencieusement.

Une extension conditionnelle éventuellement active (cf. A.9 — skill `safeguard-mistral`) se place **après** tous ces niveaux et ne peut jamais primer sur eux.

## A.1 Bootstrap de session

Au début d'une session interactive, dans cet ordre :

1. lire `METHOD.json` ;
2. lire `METHOD.md` ;
3. lire `PROJET.json` puis `PROJET.md` ;
4. lire le plan actif dans `plans/` et, si besoin, le document de roadmap produit ;
5. vérifier la branche Git et le `git status` avant toute écriture ;
6. appliquer les garde-fous BP-09 (test-dev en attente) et BP-19 (suivi non commité) : si l'un des deux se déclenche, **le signaler au PO avant tout travail**.

À l'issue du bootstrap, l'agent annonce au PO en quelques lignes : la branche active, l'état du working tree (propre ou non, avec les écarts), le `test_dev_en_cours` éventuel et le point de reprise lu dans `PROJET.json`.

Si `METHOD.md` devient trop lourd à relire entièrement, utiliser `METHOD-BOOTSTRAP.md` comme digest, puis revenir à `METHOD.md` si un arbitrage ou une nuance manque. Le digest ne remplace jamais les règles absolues A.0, qui s'appliquent même quand seul le digest a été lu.

## A.2 Garde-fous de bootstrap

- Ne pas toucher au code source pendant un bootstrap documentaire, sauf demande explicite du PO (Product Owner / responsable produit).
- Toujours vérifier le working directory avant et après création de fichiers racine.
- Ne pas committer automatiquement les documents créés.
- Si une règle locale de projet contredit le défaut général, la règle locale documentée en Partie B prévaut — sauf si elle contredit une règle absolue A.0, auquel cas A.0 prévaut.

## A.3 Workflow Git

Règles communes :

- vérifier la branche en début de session ;
- faire des commits atomiques ;
- revoir le diff ou `git status` avant `git add -A` ;
- ne jamais pousser sur `<BRANCHE_PRINCIPALE>` (souvent `origin/main` ou `origin/master`) sans confirmation explicite du PO (R-01) ;
- ne jamais faire de mutation Git destructrice sans validation explicite (R-02) ;
- dérouler la **checklist mécanique pré-commit** (Annexe 1) avant chaque commit.

Format de commit recommandé :

```text
type(scope): description concise
```

Types usuels :

- `feat` : nouvelle fonctionnalité
- `fix` : correction de bug
- `docs` : documentation
- `refactor` : refonte de code sans changement de comportement
- `test` : ajout ou modification de tests
- `chore` : tâches de maintenance
- `style` : formatage, sans changement sémantique

## A.4 Communication humain ↔ IA

Avant de commencer :

- lire le contexte documentaire ;
- clarifier le scope si une ambiguïté bloque une décision.

Pendant l'implémentation :

- signaler les blocages immédiatement ;
- proposer une alternative simple quand une solution devient trop lourde ;
- noter les idées futures dans `PROJET` plutôt que les implémenter hors scope.

### Signal d'ouverture « Retour test dev »

Quand le PO ouvre une session avec le préfixe exact **« Retour test dev »**, cela indique une phase de **débriefing en vrac** après test manuel. Le PO communique observations, bugs, régressions et idées de fonctionnalités sans structuration préalable.

Conduite attendue de l'agent :

1. Écouter l'ensemble du retour sans interrompre.
2. Consigner chaque point dans `PROJET.json` et `PROJET.md` avec :
   - un libellé clair ;
   - le statut `à_traiter` ;
   - une priorité déduite de l'objectif macro du projet (`Critical`, `High`, `Medium`, `Low`) ;
   - le tag `test_dev` pour traçabilité.
3. Présenter au PO la liste consolidée avec les priorités choisies et la justification.
4. Attendre la validation du PO avant de commencer toute correction de code.

En fin de session :

- résumer ce qui a été fait ;
- proposer la prochaine étape ;
- mettre à jour `PROJET.json` puis `PROJET.md` après changement significatif ;
- committer les documents de suivi immédiatement après la synchronisation (lot dédié `docs(project)` acceptable) — ne pas laisser de reliquat `non_commite` à la session suivante (BP-19) ;
- mettre à jour `INDEX-docs.md` si un document est créé, déplacé ou supprimé ;
- proposer une mise à jour de `METHOD.md` / `METHOD.json` si une bonne pratique structurante émerge (protocole A.8 — jamais de modification sans validation).

## A.5 Qualité minimale attendue

Avant de considérer une tâche comme terminée :

- la suite de tests anti-régressions est entièrement verte avant toute commande de build ;
- les checks adaptés au stack passent (lint, format, type-check, etc.) ;
- l'application démarre ou les processus critiques tournent sans crash bloquant ;
- les parcours critiques touchés ont été testés manuellement ou automatiquement ;
- aucune régression évidente n'est visible ;
- aucun secret, mot de passe, clé, token, certificat ou donnée sensible réelle n'est committé.

## A.6 Gestion du scope

- Une session doit avoir un objectif principal clair.
- Préparer un lot futur est acceptable ; l'implémenter entièrement sans validation ne l'est pas.
- En cas de doute, préférer la solution la plus simple qui fonctionne.
- Documenter les raisons d'un choix, pas l'évidence.

## A.7 Conduite en cas de doute ou d'incertitude

Ces situations imposent de **s'arrêter et de demander au PO** plutôt que d'improviser :

- une règle absolue A.0 semble entrer en conflit avec la tâche demandée ;
- deux documents de référence se contredisent et l'ordre de précédence ne suffit pas à trancher ;
- une action est irréversible ou destructrice (suppression, écrasement, push, purge) et n'est pas explicitement couverte par la demande ;
- l'agent ne parvient pas à exécuter une vérification exigée (tests, build) et serait tenté de « passer outre » ;
- la demande implique de modifier `METHOD.md`, `METHOD.json` ou la structure des documents de suivi.

Formuler alors : ce qui était attendu, ce qui bloque, les options possibles, et la recommandation de l'agent. Ne **jamais** choisir silencieusement l'option la plus risquée.

## A.8 Protocole de révision de la méthode

`METHOD.md` et `METHOD.json` sont des documents **protégés**. Leur modification suit obligatoirement ce protocole :

1. **Proposition** : l'agent formule la modification proposée (texte exact ou résumé fidèle), avec sa justification, et la soumet au PO. Aucune écriture à ce stade.
2. **Validation** : le PO valide explicitement, dans la session courante. Une validation implicite, ancienne ou supposée ne suffit pas.
3. **Application ordonnée** : `METHOD.md` est modifié en premier, puis `METHOD.json` est aligné dans la même session.
4. **Versionnage** : le champ « Version de la méthode » (en-tête de `METHOD.md`) et `version_methode` (`METHOD.json`) sont incrémentés de façon cohérente (MAJEUR pour un changement de règle, MINEUR pour un ajout, CORRECTIF pour une clarification).
5. **Journalisation** : une ligne est ajoutée au « Journal des révisions de la méthode » en Annexe 3 de `METHOD.md` et à `journal_revisions` dans `METHOD.json` (date, version, résumé, validation PO).
6. **Commit dédié** : les deux fichiers sont commités ensemble dans un commit `docs(method)`.

Garde-fous associés :

- toute désynchronisation détectée entre `METHOD.md` et `METHOD.json` est signalée au PO puis corrigée via ce protocole ;
- un agent ne supprime jamais une règle existante au motif qu'elle semble redondante : il propose la suppression ;
- si une session précédente a laissé `METHOD.md`/`METHOD.json` modifiés non commités, appliquer BP-19.

## A.9 Extension conditionnelle — skill `safeguard-mistral`

Le dossier `safeguard-mistral/` contient un skill (`safeguard-mistral/SKILL.md`) qui **n'appartient pas au socle de la méthode**. C'est une **extension conditionnelle**, destinée à compenser les lacunes connues des modèles Mistral AI en implémentation logicielle (reconnaissance du dépôt, scope explicite, conservatisme des changements, preuve de vérification, auto-revue adversariale, passation au relecteur).

### Conditions d'activation (cumulatives)

Le skill ne s'applique **que si les deux conditions suivantes sont vraies simultanément** :

1. **Condition de modèle** — le modèle qui prend en charge l'implémentation du code est un **modèle Mistral AI**. Le skill ne s'applique à aucun autre fournisseur.
2. **Condition d'invocation** — le **prompt initial de la session mentionne explicitement le skill** (par son nom `safeguard-mistral` ou par une consigne non ambiguë de l'appliquer). Une mention tardive, une supposition ou une décision autonome de l'agent ne suffisent pas.

Si **l'une des deux** conditions manque, le skill est **inactif** : il n'est ni lu, ni cité, ni annoncé, ni appliqué ; ses phases, checklists et format de rapport ne sont pas ajoutés à la réponse ; l'agent suit `METHOD.md` seul. En cas de doute sur l'une des conditions, considérer le skill comme inactif et le signaler brièvement au PO.

### Rang dans l'ordre de précédence

Quand il est actif, `safeguard-mistral` se place **en dessous** de la méthode : `METHOD.json` / `METHOD.md` et les règles absolues A.0 (R-01 à R-10) priment sur toute consigne du skill. Un conflit entre le skill et la méthode se résout **toujours** en faveur de la méthode, et se signale au PO (R-10).

Le skill n'ajoute, ne retire ni ne relâche aucune règle absolue. Il ne dispense d'aucune obligation de la méthode : tests avant build (R-04, BP-14), synchronisation `PROJET.json` ↔ `PROJET.md` (R-05, BP-08, BP-17), protection de `METHOD` (R-06, A.8, BP-20), interdiction d'inventer un fait (R-08).

### Fichiers `references/` absents

`SKILL.md` renvoie vers quatre fichiers `safeguard-mistral/references/` (`HIGH-RISK-CHANGES.md`, `TASK-CONTRACT.md`, `QUALITY-CHECKLISTS.md`, `REVIEW-HANDOFF.md`) qui **n'existent pas actuellement dans le dépôt**. Conformément à R-08, un agent ne doit **jamais en inventer le contenu ni prétendre les avoir lus** : il déclare la référence indisponible et s'appuie sur les règles écrites directement dans `SKILL.md`. Si ces fichiers sont créés un jour, `SKILL.md`, `INDEX-docs.md` et la présente section sont mis à jour via le protocole A.8.

---

# Partie B — Conventions spécifiques au projet

## B.1 Architecture et stack

Chaque projet doit déclarer dans `PROJET.md` / `PROJET.json` :

- le **type d'application** (web, desktop, mobile, CLI, API, librairie, etc.) ;
- le **langage principal** et les frameworks critiques ;
- la **persistance** (base de données, fichiers, cache, etc.) ;
- la **plateforme cible** (OS, navigateurs, environnements d'exécution) ;
- la **référence fonctionnelle** (roadmap, cahier des charges, ticket principal) ;
- la **référence technique** (briques existantes à réutiliser, repo de référence, documentation externe).

Architecture type à adapter :

```
<DOSSIER_SOURCE>/
  <Domaine1>/         -- modules métier ou techniques du domaine 1
  <Domaine2>/         -- modules métier ou techniques du domaine 2
  <UI>/               -- interface utilisateur si applicable
  <Infrastructure>/   -- accès données, réseau, fichiers, configuration
  <Utils>/            -- helpers transverses
  <I18n>/             -- internationalisation si applicable
<DOSSIER_TEST>/       -- tests unitaires, d'intégration, E2E
```

## B.2 Sécurité et données sensibles

Règles obligatoires :

1. toute donnée sensible au repos doit être chiffrée ou protégée par les moyens du stack ;
2. la présence effective des garde-fous de sécurité doit être vérifiable au runtime ou au build ;
3. ne jamais committer de mot de passe en dur, de clé, de token, de certificat, ni de donnée réelle ;
4. éviter toute fuite de données déchiffrées ou temporaires persistantes ;
5. toute logique de récupération ou de backup doit rester restaurable à partir d'une copie de secours et des secrets maîtres ;
6. les **logs ne doivent contenir aucune donnée sensible** : pas d'identifiants métier en clair, pas de noms de fichiers utilisateur, pas de chemins de données déchiffrées, pas de contenu. Identifier les objets par leurs IDs techniques. Tout nouveau log est relu sous cet angle avant commit.

Points de vigilance spécifiques à adapter selon le projet :

- gestion des fichiers temporaires déchiffrés ou sensibles ;
- scripts ou dépendances natives critiques (DLLs, binaires, libs système) ;
- formats de backup, d'export, de migration et de réplication ;
- exposition de surface d'attaque (API, ports, CORS, authentification).

## B.3 Conventions de code

- Un module = une responsabilité claire.
- Séparer autant que possible la logique pure du code à effets (I/O, UI, framework).
- Réutiliser d'abord les briques éprouvées du projet ou de la référence technique avant de réinventer.
- Préférer des types métier explicites plutôt que des types primitifs nus (`String`, `Double`, `any`, etc.).
- Utiliser des export lists explicites pour les modules réutilisés.
- Toute nouvelle saisie de date, de monnaie, de mesure ou de locale doit passer par un helper unifié quand il existe.
- Toute évolution UI significative doit être vérifiée sur les tailles d'écran et thèmes pertinents.

## B.4 Variables et constantes critiques

Chaque projet doit lister ici ses variables critiques. Exemples de placeholders :

- projet : `<NOM_DU_PROJET>`
- application de référence : `<DOSSIER_REFERENCE>/`
- plan produit principal : `<ROADMAP>.md`
- fichier manifeste du build : `<MANIFESTE_BUILD>` (ex: `package.json`, `Cargo.toml`, `pom.xml`, `*.cabal`)
- exécutable ou artefact visé : `<NOM_ARTEFACT>`
- bases cibles : `<BASE_DONNEES_1>`, `<BASE_DONNEES_2>`
- format de backup visé : `<EXTENSION_BACKUP>`
- pile de sécurité réutilisée : `<STACK_SECURITE>`

## B.5 Bonnes pratiques locales

### BP-01 — Réutiliser la référence avec discernement

Avant de coder une brique sensible déjà présente dans la référence technique du projet, vérifier si elle peut être reprise telle quelle ou adaptée. Réinventer n'est acceptable que si le besoin du projet diverge réellement.

### BP-02 — Valider les dépendances critiques avant toute confiance

Toute dépendance native, binaire externe ou librairie système critique doit être considérée comme non fiable tant qu'elle n'a pas été vérifiée explicitement au build et au runtime (présence, version, intégrité).

### BP-03 — Aucun artefact sensible au commit

Sont interdits au commit : bases réelles, copies temporaires déchiffrées, fichiers de test sensibles, mots de passe, clés, tokens, certificats, variables d'environnement de production.

### BP-04 — Diff propre avant staging

Toujours relire `git status` et le diff avant de stage, spécialement parce que le projet documente beaucoup dès le départ.

### BP-05 — Push seulement sur confirmation

Le push reste une action explicite du PO, même si le commit local est autorisé.

### BP-06 — Le plan produit ne remplace pas le journal projet

Le document de roadmap décrit la vision et les phases. `PROJET.json` et `PROJET.md` doivent capturer l'état courant réel, les décisions, les questions ouvertes et le point de reprise.

### BP-07 — Le code sensible doit rester lisible

Dans les modules traitant de la sécurité, de la persistance critique ou des règles métier complexes, éviter les abstractions brillantes mais opaques. Une implémentation légèrement plus verbeuse mais auditable est préférable.

### BP-08 — Synchronisation stricte PROJET.json ↔ PROJET.md

Après **chaque changement significatif** (nouvelle phase, nouveau lot livré, changement de focus, décision technique majeure) :

1. `PROJET.json` est mis à jour en premier (source de vérité machine) ;
2. `PROJET.md` est ajusté pour refléter *exactement* le même état ;
3. les deux documents sont commités dans le même lot ou dans un commit `docs(project)` dédié juste après.

Cette règle est **non négociable** : un état projet désynchronisé entre JSON et MD rend le point de reprise ambigu pour l'humain comme pour l'agent.

### BP-09 — Test-Dev et balle dans le camp du PO

Quand un lot de fonctionnalités ou de corrections nécessite une validation manuelle par le PO avant de poursuivre :

1. Créer un document `Test-Dev/session-<date>-<lot>.md` avec une **checklist de tests** claire et reproductible.
2. Mettre à jour `PROJET.json` et `PROJET.md` pour indiquer `test_dev_en_cours` et le chemin du document.
3. **En début de session**, si un `test_dev_en_cours` est actif, l'agent doit **rappeler au PO** qu'un test est en attente et **demander validation** avant toute nouvelle modification de code.
4. Une fois le PO ayant testé et validé, déplacer le `.md` dans `Test-Dev/Traité/` et mettre à jour `PROJET.json` / `PROJET.md` pour fermer le test-dev.

### BP-10 — Consignation structurée des retours test dev

Quand un retour test dev est collecté, chaque point doit être consigné dans `PROJET.json` sous la clé `backlog_test_dev` et reflété dans `PROJET.md`. Format obligatoire :

- `id` : identifiant unique (ex: `td-001`) ;
- `libelle` : titre concis ;
- `description` : contexte + hypothèses ;
- `priorite` : `Critical` / `High` / `Medium` / `Low` ;
- `statut` : `a_traiter` (par défaut) ;
- `tags` : `test_dev` obligatoire + tags thématiques.

La priorité est déduite automatiquement par l'agent selon la grille BP-12.

### BP-11 — Cycle de vie des états Test-Dev

Le champ `test_dev_en_cours.statut` suit les états suivants :

- `en_attente_po` : le PO n'a pas encore testé le lot ;
- `teste_revele_bugs` : le PO a testé et identifié des anomalies ; les points sont consignés dans `backlog_test_dev` ;
- `valide` : le PO a testé et validé le lot ; le document peut être déplacé dans `Test-Dev/Traité/`.

### BP-12 — Grille de priorisation automatique des bugs

En l'absence d'instruction explicite du PO, l'agent affecte la priorité selon :

| Priorité | Critères |
|----------|----------|
| **Critical** | Perte de données, faille de sécurité, crash bloquant au démarrage, corruption de base. |
| **High** | Parcours critique cassé mais contournable ou partiel. |
| **Medium** | UX gênante, ralentissement, warning récurrent, workaround simple existant. |
| **Low** | Cosmétique, nice-to-have, documentation, optimisation mineure. |

L'agent présente la grille appliquée au PO pour validation. La grille vaut pour `backlog_test_dev` **et** `backlog_audit_code`.

### BP-13 — Test rouge avant correction, test vert après

Chaque correction de bug doit être justifiée par un test qui échoue avant la correction et passe après.

### BP-14 — Build bloqué si un test échoue

Avant de lancer une commande de build (`<COMMANDE_BUILD>` ou équivalent sur un autre stack), l'agent doit exécuter la suite de tests. Si un test échoue, il annonce le blocage et propose une correction sans builder.

### BP-15 — Tests créés ou mis à jour en même temps que la feature

Aucune feature n'est considérée comme terminée tant que ses tests anti-régressions correspondants n'ont pas été ajoutés ou mis à jour et ne passent pas.

### BP-16 — Pipeline de vérification scriptisée

Le repo fournit un script local (par langage) qui enchaîne automatiquement tests puis build. L'agent l'utilise avant de proposer un lot comme stable. Le release suit la même séquence avec des étapes supplémentaires optionnelles (smoke, tag, bundle).

### BP-17 — Double-lecture croisée PROJET.json ↔ PROJET.md avant commit de suivi

Avant de committer toute modification de `PROJET.json` ou `PROJET.md` :

1. Relire systématiquement les champs sensibles dans les deux documents : `focus_immediat`, `backlog_test_dev`, `backlog_audit_code`, `test_dev_en_cours`, `journal_des_sessions`, `questions_ouvertes`.
2. S'assurer que tout statut, date, priorité et description sont strictement identiques à la sémantique près.
3. Si un écart est détecté, le corriger immédiatement avant le commit.
4. Ne jamais committer un `PROJET.json` seul sans s'assurer que `PROJET.md` reflète exactement le même état.

Cette règle est un renforcement de BP-08. Une désynchronisation rend le point de reprise ambigu pour l'humain comme pour l'agent.

### BP-18 — Backlog d'audit de code structuré

Les constats issus d'un audit de code (revue complète ou ciblée, hors retours de test manuel du PO) sont consignés dans `PROJET.json` sous la clé `backlog_audit_code` et reflétés dans `PROJET.md`. Format obligatoire, aligné sur BP-10 :

- `id` : identifiant unique au format `ac-NNN` ;
- `libelle` : titre concis ;
- `description` : constat, localisation dans le code, piste de correction ;
- `priorite` : `Critical` / `High` / `Medium` / `Low` selon la grille BP-12 ;
- `statut` : `a_traiter` (par défaut), puis `corrige` ;
- `tags` : `audit_code` obligatoire + tags thématiques.

Les priorités proposées par l'agent sont **présentées au PO pour validation** avant tout traitement. Le backlog d'audit ne se mélange jamais avec `backlog_test_dev` (réservé aux retours de test manuel du PO).

### BP-19 — Garde-fou bootstrap : suivi non commité

Au bootstrap de session (A.1), si `git status` montre des modifications **non commitées** de `PROJET.json`, `PROJET.md`, `METHOD.md`, `METHOD.json` ou `INDEX-docs.md` héritées d'une session précédente :

1. le signaler au PO avant tout travail, en listant les fichiers concernés ;
2. ne pas écraser ni mélanger ces modifications avec le travail de la session courante sans validation ;
3. proposer soit de committer le reliquat en l'état (lot dédié), soit de le faire valider par le PO.

Une entrée de journal `commit: non_commite` dans `PROJET.json` est un signal de déclenchement de ce garde-fou.

### BP-20 — Protection des documents de méthode

`METHOD.md` et `METHOD.json` ne sont modifiables que via le protocole A.8 (proposition → validation PO → application MD puis JSON → incrément de version → journalisation → commit `docs(method)`). Toute autre modification est une violation de la règle absolue R-06.

## B.6 Politique de branche

Défaut général : utiliser `<BRANCHE_PRINCIPALE>` (souvent `main`) avec des branches de feature pour tout travail non trivial.

Si un override local est nécessaire (projet très jeune, mono-développeur, contrainte opérationnelle forte) :

- documenter explicitement l'override dans `METHOD.md` / `METHOD.json` (via le protocole A.8) ;
- le push vers `<ORIGIN>/<BRANCHE_PRINCIPALE>` reste soumis à confirmation explicite du PO ;
- aucune mutation git destructive sans validation.

## B.7 Cycle de release

Cycle recommandé :

1. implémenter sur la branche de travail ;
2. **exécuter la suite de tests anti-régressions** (cf. Partie C) ;
3. vérifier le build, le démarrage et les parcours critiques ;
4. mettre à jour la documentation de suivi ;
5. committer de façon atomique ;
6. pousser seulement après validation explicite du PO ;
7. tagger quand un jalon de release est réellement atteint.

Convention de tag recommandée :

```text
v<MAJOR>.<MINOR>[.<PATCH>]
```

---

# Partie C — Tests anti-régressions et CI/CD local

## C.1 Philosophie

Les tests anti-régressions sont un **garde-fou systématique**, indépendamment du langage ou du framework utilisé. Leur rôle est de capturer le comportement correct attendu du code et de le vérifier automatiquement à chaque itération.

Principes directeurs :

- **Un test qui échoue bloque le build.** Aucune commande de build (`<COMMANDE_BUILD>`, `npm run build`, `cargo build`, `make`, etc.) ne doit être considérée comme saine si la suite de tests n'est pas entièrement verte juste avant.
- **Un bug corrigé doit être accompagné d'un test qui le reproduit.** Cela évite qu'il ne revienne silencieusement plus tard.
- **Les tests vivent avec le code.** Ils sont créés, mis à jour et supprimés en même temps que les fonctionnalités qu'ils couvrent.
- **Les fichiers de test sont isolés dans un dossier dédié** pour préserver la lisibilité du repository et faciliter le filtrage des artefacts de vérification.

## C.2 Organisation des fichiers de test

### Dossier dédié

Quel que soit le langage, les fichiers de test doivent résider dans un **espace dédié**, clairement séparé du code source applicatif :

| Stack typique | Dossier de test | Commande de test |
|---------------|-----------------|------------------|
| Haskell / Cabal | `test/` | `cabal test` |
| Node / npm | `test/` ou `__tests__/` | `npm test` |
| Rust / Cargo | `tests/` + `#[cfg(test)]` | `cargo test` |
| Python | `tests/` | `pytest` |
| Go | `*_test.go` à côté des sources | `go test ./...` |
| Java / Maven | `src/test/java/` | `mvn test` |
| .NET | `*Tests/` ou `tests/` | `dotnet test` |
| Ruby | `test/` ou `spec/` | `rake test` / `rspec` |
| PHP | `tests/` | `phpunit` |
| C/C++ | `tests/` | `ctest` / `make test` |

Pour ce projet, le dossier dédié est **`<DOSSIER_TEST>/`** (à adapter). Sa structure reflète celle de `<DOSSIER_SOURCE>/` quand le langage le permet :

```
<DOSSIER_TEST>/
  <POINT_ENTREE_TEST>.<EXT>    -- point d'entrée de la suite
  README.md                     -- contrat et guide du dossier de tests
  <Domaine1>/
    <Module1>Spec.<EXT>
    <Module2>Spec.<EXT>
  <Domaine2>/
    ...
```

### Règles de nommage

- Un fichier de test porte le nom du module testé suffixé par l'idiome du langage (`*Spec.hs`, `*.test.ts`, `*_test.go`, `*Test.java`, etc.).
- Un test décrit un comportement attendu dans un langage proche du métier, pas de l'implémentation.
- Les fixtures, données d'entrée et helpers de test peuvent vivre dans un sous-dossier `<DOSSIER_TEST>/fixtures/` ou `<DOSSIER_TEST>/helpers/`.

## C.3 Règle d'or : test avant build

> **Avant chaque `<COMMANDE_BUILD>`, `<COMMANDE_BUILD_ALTERNATIVE>` ou équivalent, la suite de tests du projet doit être entièrement verte.**

### Séquence standard

```text
1. tests  → 2. build  →  3. run / smoke test  →  4. commit
   ↑_____________________________________________________|
                    (boucle de correction)
```

### Conduite attendue de l'agent

1. Avant toute commande de build explicite ou implicite, lancer la suite de tests (`<COMMANDE_TEST>`).
2. Si un test échoue, **ne pas builder**. Annoncer le nom du test et le fichier concerné, proposer une correction ou demander des instructions.
3. Si un test échoue à cause d'une évolution de spec légitime, mettre à jour le test **avant** ou **dans le même commit** que la correction de code.
4. Après ajout d'une feature, ajouter ou compléter les tests couvrant les nouveaux chemins critiques.

## C.4 Types de tests attendus

La stratégie est généraliste et s'adapte au stack. Elle privilégie plusieurs niveaux de protection :

| Type | Objectif | Quand l'ajouter |
|------|----------|-----------------|
| **Unitaires** | Vérifier une fonction, un module, un algorithme en isolation. | Dès la création d'une brique pure ou d'une logique métier. |
| **Intégration** | Vérifier l'assemblage de plusieurs modules (DB, fichiers, services). | Dès qu'une I/O ou une dépendance externe entre en jeu. |
| **Property-based** | Vérifier une propriété invariante sur un grand nombre d'entrées aléatoires. | Sur du code à forte valeur de preuve (crypto, parsing, transformation). |
| **Golden / Snapshot** | Capturer une sortie de référence et détecter tout changement non expliqué. | Sur des formats de fichier, des sérialisations, des exports. |
| **Smoke / E2E** | Vérifier que l'application démarre et que les parcours critiques fonctionnent. | À chaque jalon, avant release. |
| **Contrat / API** | Vérifier la stabilité des interfaces publiques (API, SDK, modules). | Dès qu'une interface est exposée à des consommateurs externes. |

Les tests doivent progressivement couvrir :

- les chemins critiques métiers ;
- les sérialisations et formats de fichier (golden) ;
- les fonctions à forte valeur de preuve (property-based) ;
- le démarrage et les parcours utilisateurs (smoke/E2E).

## C.5 Création et mise à jour continue des tests

### À chaque nouvelle feature

1. Identifier les chemins critiques introduits ou modifiés.
2. Ajouter un ou plusieurs tests dans le module de test correspondant.
3. S'assurer que le test échoue avant la correction/implémentation (« test rouge »), puis passe après (« test vert »).
4. Si la feature modifie un contrat existant, mettre à jour les tests existants **dans le même lot**.

### À chaque correction de bug

1. Reproduire le bug dans un test dédié.
2. Vérifier que le test échoue avec l'ancien code.
3. Appliquer la correction.
4. Vérifier que le test passe et que la suite globale reste verte.

### Refactoring

- Avant un refactoring important, s'assurer que la couverture des zones concernées est suffisante.
- Pendant le refactoring, les tests doivent rester verts à chaque étape (refactoring par petits pas).

## C.6 CI/CD local — Contrôle continu et release automatique

Le projet n'a pas obligatoirement besoin d'une infrastructure distante pour appliquer le principe CI/CD. L'objectif est de **scriptiser localement** la chaîne de vérification pour qu'elle soit reproductible.

### Pipeline minimale

```text
[lint/format] → [tests] → [build] → [smoke test] → [tag] → [release artifacts]
```

La partie **obligatoire** est :

```text
[tests] → [build]
```

Tout le reste est progressif. L'agent doit respecter cette séquence quand il prépare un lot pour le PO.

### Scripts fournis (à adapter par stack)

Le repo fournit typiquement :

- `<SCRIPT_BUILD_WRAPPER>.<EXT>` — wrapper pour normaliser l'environnement de build si nécessaire.
- `<SCRIPT_PRE_BUILD>.<EXT>` — exécute `<COMMANDE_TEST>` puis `<COMMANDE_BUILD>`. S'arrête dès la première erreur.
- `<SCRIPT_RELEASE>.<EXT>` — exécute la suite complète (tests, build, smoke test facultatif, création des artefacts dans `<DOSSIER_RELEASE>/`).

### Utilisation type

```bash
# Vérification minimale avant de considérer le code comme stable
<COMMANDE_PRE_BUILD>

# Préparation d'un jalon de release
<COMMANDE_RELEASE> <VERSION>
```

Quel que soit le stack, les scripts portent la même sémantique : vérifier les tests avant de builder, puis builder avant de release.

## C.7 Anti-patterns à éviter

- **Tests sans assertion significative** : un test qui ne vérifie rien n'est pas un garde-fou.
- **Tests couplés à l'environnement du développeur** : utiliser des répertoires temporaires, des fixtures versionnées, jamais de chemins absolus personnels.
- **Tests laissés en échec "parce qu'on sait pourquoi"** : un test rouge = build bloqué, point final.
- **Tests commités avec des données sensibles** : pas de vrais mots de passe, pas de vraies bases, pas de clés, pas de tokens.
- **Tests jamais mis à jour après une évolution de spec** : un test obsolète qui continue de passer est aussi dangereux qu'un test rouge.
- **Tests mélangés au code source applicatif** : respecter le dossier dédié, sauf convention idiomatique du langage (ex. Go).

## C.8 Bonnes pratiques liées — Tests et CI/CD

(Voir BP-13 à BP-16 en Partie B.)

---

## Annexe 1 — Checklist mécanique avant tout commit

À dérouler **littéralement** avant chaque `git commit`. Une seule réponse « non » bloque le commit jusqu'à résolution.

1. Ai-je relu `git status` et le diff de **chaque** fichier stagé ? (BP-04)
2. Le commit contient-il uniquement des fichiers liés au lot annoncé ? (commits atomiques)
3. Y a-t-il un secret, une donnée réelle, un fichier sensible ou un artefact interdit dans le diff ? → si oui, **bloquer** (R-03, BP-03)
4. Si le commit touche du code : la suite de tests a-t-elle été exécutée et est-elle verte ? (R-04, BP-14)
5. Si le commit touche `PROJET.json` ou `PROJET.md` : la double-lecture croisée BP-17 a-t-elle été faite sur les champs sensibles ?
6. Si le commit touche `METHOD.md` ou `METHOD.json` : le protocole A.8 a-t-il été suivi (validation PO, version, journal) ? (R-06)
7. Si un document a été créé, déplacé ou supprimé : `INDEX-docs.md` est-il à jour ?
8. Le message de commit suit-il le format `type(scope): description` ?

## Annexe 2 — Checklist courte de fin de session

- code ou docs produits relus ;
- `PROJET.json` et `PROJET.md` alignés si changement significatif (vérification croisée BP-17) ;
- `INDEX-docs.md` mis à jour si besoin ;
- `METHOD.md` et `METHOD.json` alignés si une règle a été validée par le PO (protocole A.8) ;
- suite de tests anti-régressions verte avant le build ;
- checks adaptés exécutés ou impossibilité signalée ;
- documents de suivi commités (pas de reliquat `non_commite` laissé à la session suivante, cf. BP-19) ;
- prochain point de reprise explicite.

## Annexe 3 — Journal des révisions de la méthode

> Initialiser ce journal lors de l'adaptation du template, puis ajouter une ligne à chaque révision validée (protocole A.8).

| Date | Version | Résumé | Validation PO |
|------|---------|--------|---------------|
| `<DATE_ADAPTATION>` | 1.0.0 | Adaptation du template Méthode V5 au projet `<NOM_DU_PROJET>`. | Oui |
