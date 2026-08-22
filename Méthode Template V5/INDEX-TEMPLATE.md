# INDEX-docs.md — Index documentaire vivant (template généraliste)

> Ce document est un template. Copiez-le à la racine du projet sous le nom `INDEX-docs.md`, puis remplacez les placeholders et ajustez les sections selon les documents réellement présents.

## Documents actifs — racine

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `README.md` | Entrée du dépôt | Actif | Présente le projet, son état, ses fonctionnalités et les commandes rapides. |
| `BUILD.md` | Guide de compilation / build | Actif | Documente les prérequis, les dépendances et les commandes de build. |
| `<ROADMAP>.md` | Vision produit et roadmap | Actif | Décrit le projet, ses phases et les briques fonctionnelles. |
| `METHOD.md` | Méthode locale humaine | Actif | Définit le workflow documentaire, Git et les conventions spécifiques au projet. |
| `METHOD.json` | Méthode locale machine | Actif | Représentation structurée de `METHOD.md` pour le bootstrap agentique. |
| `METHOD-BOOTSTRAP.md` | Digest de démarrage | Actif | Résumé rapide des règles et références essentielles pour démarrer une session. |
| `PROJET.md` | Miroir humain du projet | Actif | Synthèse lisible de l'état courant, de la roadmap et du point de reprise. |
| `PROJET.json` | Source de vérité projet | Actif | État dynamique du projet, des phases et des documents associés. |
| `INDEX-docs.md` | Répertoire documentaire | Actif | Index vivant de la documentation hors code. |
| `SECURITY.md` | Posture de sécurité | Actif | Posture de sécurité, limites, modèle de menace et pistes d'amélioration. |

## Plans — `plans/`

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `plans/README.md` | Ancrage du dossier des plans | Actif | Explique le rôle du dossier et laisse un point d'entrée vers le plan actif. |
| `plans/session-prochaine.md` | Priorités de la session suivante | Actif | Liste des priorités de la prochaine session de travail. |

## Test-Dev — `Test-Dev/`

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `Test-Dev/session-<date>-<lot>.md` | Checklist de tests du lot | Variable | Tests manuels à valider par le PO avant de poursuivre. |
| `Test-Dev/Traité/` | Archive des tests validés | Actif | Contient les checklists de tests une fois validées par le PO. |

## Tests automatisés — `<DOSSIER_TEST>/`

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `<DOSSIER_TEST>/README.md` | Contrat et guide du dossier de tests | Actif | Décrit l'organisation, le cycle rouge/vert et les règles de contribution à la suite anti-régressions. |
| `<DOSSIER_TEST>/<POINT_ENTREE_TEST>.<EXT>` | Point d'entrée de la suite | Actif | Rassemble les modules de test et expose la suite complète à `<COMMANDE_TEST>`. |

## Scripts et CI/CD — `scripts/` (ou équivalent)

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `<SCRIPT_BUILD_WRAPPER>.<EXT>` | Wrapper de build si applicable | Actif | Normalise l'environnement avant de déléguer à `<COMMANDE_BUILD>`. |
| `<SCRIPT_PRE_BUILD>.<EXT>` | Pipeline locale test → build | Actif | Exécute `<COMMANDE_TEST>` puis `<COMMANDE_BUILD>`. Bloque le build si un test échoue. |
| `<SCRIPT_RELEASE>.<EXT>` | Pipeline de release locale | Actif | Exécute tests, build, smoke test, packaging et tag. |

## Extension méthodologique conditionnelle — `safeguard-mistral/`

> Cette extension **ne fait pas partie du socle de la méthode**. Elle ne s'applique que si **les deux conditions cumulatives** de la section A.9 de `METHOD.md` sont réunies : (1) le modèle qui prend en charge l'implémentation du code est un **modèle Mistral AI**, et (2) le **prompt initial de la session mentionne explicitement le skill**. Si l'une des deux conditions manque, le skill est inactif et l'agent suit `METHOD.md` seul.

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `safeguard-mistral/SKILL.md` | Garde-fous d'implémentation pour modèles Mistral AI | **Conditionnel** (cf. A.9) | Impose reconnaissance du dépôt, contrat de tâche, changements conservateurs, vérification prouvée, auto-revue adversariale et passation au relecteur. Se place **après** `METHOD` dans l'ordre de précédence et ne déroge à aucune règle absolue A.0. |
| `safeguard-mistral/references/HIGH-RISK-CHANGES.md` | Checklist changements à haut risque | **Absent** | Référencé par `SKILL.md` mais **non présent dans le dépôt**. Ne pas en inventer le contenu ni prétendre l'avoir lu (R-08). |
| `safeguard-mistral/references/TASK-CONTRACT.md` | Gabarit de contrat de tâche | **Absent** | Référencé par `SKILL.md` mais **non présent dans le dépôt**. Ne pas en inventer le contenu ni prétendre l'avoir lu (R-08). |
| `safeguard-mistral/references/QUALITY-CHECKLISTS.md` | Checklists qualité par domaine | **Absent** | Référencé par `SKILL.md` mais **non présent dans le dépôt**. Ne pas en inventer le contenu ni prétendre l'avoir lu (R-08). |
| `safeguard-mistral/references/REVIEW-HANDOFF.md` | Gabarit de passation au relecteur | **Absent** | Référencé par `SKILL.md` mais **non présent dans le dépôt**. Ne pas en inventer le contenu ni prétendre l'avoir lu (R-08). |

En l'absence de ces fichiers, l'agent déclare la référence indisponible et s'appuie sur les règles écrites directement dans `SKILL.md`, qui sont auto-suffisantes. Si le dossier `references/` est créé un jour, mettre à jour cette section, `SKILL.md` et la section A.9 de `METHOD.md` via le protocole A.8.

## Références projet

| Path | Rôle | Statut | Résumé |
|------|------|--------|--------|
| `<DOSSIER_REFERENCE>/README.md` | Référence technique | Actif | Présente la référence technique, ses modules et les briques réutilisables. |
