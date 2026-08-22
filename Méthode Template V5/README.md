# Méthode Template V4

Ce dossier contient une **méthode de travail logiciel généralisable** dérivée de la méthode opérationnelle de Haskell-Vault. Elle est applicable à tout projet, quel que soit le langage, le framework ou la taille de l'équipe.

## Objectif

Fournir un template complet et structuré pour :

- documenter la méthode de travail d'un projet (`METHOD.md` + `METHOD.json`) ;
- **résister à la dérive agentique** : règles absolues, ordre de précédence, protocole de révision verrouillé, checklists mécaniques ;
- garantir la qualité par des **tests anti-régressions** systématiques ;
- automatiser localement la chaîne CI/CD (**test → build → release**) ;
- maintenir un **journal de projet vivant** (`PROJET.md` + `PROJET.json`) ;
- gérer les phases de **test manuel** (`Test-Dev/`) et les **audits de code** (`backlog_audit_code`) de façon traçable.

## Nouveautés de la V4

La V4 ajoute une **couche anti-dérive** conçue pour rester efficace même quand la méthode est exécutée par un agent moins capable :

| Ajout | Rôle |
|-------|------|
| **A.0 Règles absolues (R-01 à R-10)** | Dix interdits non négociables (push, git destructif, secrets, build sans tests, désynchro, invention de faits...) qui priment sur tout le reste. |
| **Ordre de précédence des sources** | Tranche mécaniquement les contradictions : instruction PO > METHOD > PROJET.json > PROJET.md > autres docs. |
| **A.7 Conduite en cas de doute** | Liste de déclencheurs imposant de s'arrêter et demander au PO plutôt que d'improviser. |
| **A.8 Protocole de révision de la méthode** | `METHOD.md`/`METHOD.json` deviennent des documents protégés : proposition → validation PO → application ordonnée → versionnage → journalisation → commit dédié. |
| **Versionnage de la méthode + journal des révisions** | Toute évolution de la méthode est tracée (version sémantique, Annexe 3, `journal_revisions`). |
| **BP-17 (définie au complet)** | Double-lecture croisée `PROJET.json` ↔ `PROJET.md` avant tout commit de suivi (référencée mais non définie en V3). |
| **BP-18 Backlog d'audit de code** | Constats d'audit consignés dans `backlog_audit_code` (ac-NNN), distinct du backlog test dev. |
| **BP-19 Garde-fou suivi non commité** | Au bootstrap, tout reliquat non commité de PROJET/METHOD/INDEX est signalé au PO avant travail. |
| **BP-20 Protection des documents de méthode** | Renvoie au protocole A.8 ; toute modification hors protocole = violation R-06. |
| **B.2-6 Logs sans données sensibles** | Les logs n'exposent ni identifiants métier, ni noms de fichiers utilisateur, ni chemins déchiffrés. |
| **Annexe 1 Checklist mécanique pré-commit** | Huit questions oui/non à dérouler littéralement ; un seul « non » bloque le commit. |
| **Bootstrap renforcé** | Étape 6 (garde-fous BP-09/BP-19) + annonce d'état obligatoire au PO après bootstrap. |

## Contenu du template

| Fichier | Description |
|---------|-------------|
| `METHOD-TEMPLATE.md` | Méthode humaine complète (Parties A, B, C + annexes) |
| `METHOD-TEMPLATE.json` | Représentation machine de la méthode, richement structurée |
| `METHOD-TEMPLATE-BOOTSTRAP.md` | Digest rapide pour démarrer une session (porte les règles absolues) |
| `INDEX-TEMPLATE.md` | Template d'index documentaire vivant |
| `GUIDE-ADAPTATION.md` | Guide étape par étape pour adapter le template à un projet concret |
| `test/README-TEMPLATE.md` | Contrat et guide du dossier de tests |
| `scripts/Invoke-PreBuildChecks-TEMPLATE.ps1` | Script PowerShell : test → build |
| `scripts/Invoke-Release-TEMPLATE.ps1` | Script PowerShell : pipeline de release |
| `scripts/prebuild-checks-TEMPLATE.sh` | Script Bash : test → build |
| `scripts/release-TEMPLATE.sh` | Script Bash : pipeline de release |
| `safeguard-mistral/SKILL.md` | **Extension conditionnelle** — garde-fous d'implémentation activés uniquement si (1) le modèle est un modèle Mistral AI **et** (2) le prompt initial mentionne explicitement le skill (cf. A.9) |

## Principe fondateur : tests avant build

> **Avant chaque commande de build (`cabal build`, `npm run build`, `cargo build`, `make`, etc.), la suite de tests du projet doit être entièrement verte.**

Ce principe est généraliste. Il s'applique à tous les stacks et tous les types de projets.

## Comment utiliser ce template

1. **Lisez `GUIDE-ADAPTATION.md`** pour comprendre le processus d'adaptation.
2. **Copiez les fichiers** à la racine de votre projet cible en retirant le suffixe `-TEMPLATE`.
3. **Remplacez tous les placeholders** (`<NOM_DU_PROJET>`, `<COMMANDE_BUILD>`, `<VERSION_METHODE>`, etc.) par les valeurs concrètes.
4. **Initialisez le journal des révisions** (version `1.0.0`, date d'adaptation, validation PO).
5. **Adaptez les scripts** CI/CD aux commandes réelles du stack.
6. **Créez `PROJET.md` et `PROJET.json`** pour capturer l'état dynamique du projet.
7. **Validez le bootstrap** en vérifiant que test → build fonctionne.

## Placeholders principaux

Les placeholders à remplacer sont documentés dans `METHOD-TEMPLATE.json` sous la clé `placeholders_obligatoires.liste`. Les plus courants :

- `<NOM_DU_PROJET>` — nom du projet
- `<VERSION_METHODE>` — version de la méthode locale (initialiser à `1.0.0`)
- `<STACK_TECHNIQUE>` — technologies utilisées
- `<DOSSIER_SOURCE>` — dossier du code source (`src/`, `lib/`, etc.)
- `<DOSSIER_TEST>` — dossier des tests (`test/`, `tests/`, etc.)
- `<COMMANDE_BUILD>` — commande de build
- `<COMMANDE_TEST>` — commande d'exécution des tests
- `<DOSSIER_RELEASE>` — dossier de sortie des artefacts
- `<BRANCHE_PRINCIPALE>` — branche principale (`main`, `master`)

## Conseils de maintenance

- Gardez `METHOD.md` et `METHOD.json` strictement synchronisés — toute évolution passe par le protocole A.8 (validation PO, version, journal).
- Mettez à jour `INDEX-docs.md` à chaque création ou déplacement de document.
- Proposez une bonne pratique (BP) dans la méthode si elle devient structurante pour le projet.
- Réintégrez dans ce template toute BP qui s'avère généralisable (en créant une nouvelle version du template).

## Licence

Ce template hérite de la licence du projet dans lequel il est inclus. Adaptez selon vos besoins.
