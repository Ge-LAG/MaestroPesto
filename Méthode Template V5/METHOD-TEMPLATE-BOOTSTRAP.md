# METHOD-TEMPLATE-BOOTSTRAP.md — Digest de démarrage (template généraliste V4)

> Ce document est la version condensée de `METHOD-TEMPLATE.md`. À adapter à chaque projet en remplaçant les placeholders par les valeurs concrètes.
> Les **règles absolues** ci-dessous s'appliquent intégralement même si seul ce digest a été lu.

## Ordre de lecture

1. `METHOD.json`
2. `METHOD.md`
3. `PROJET.json`
4. `PROJET.md`
5. `plans/`
6. Document de roadmap (`<ROADMAP>.md`) si un détail produit ou de phasage manque

## Règles absolues (A.0 — non négociables)

- **R-01** : pas de push vers `<ORIGIN>` sans confirmation explicite du PO dans la session courante.
- **R-02** : pas de mutation Git destructrice (`reset --hard`, rebase réécrivant l'historique, `push --force`, `clean -fd`...) sans validation.
- **R-03** : pas de secret, donnée réelle ni fichier sensible déchiffré au commit.
- **R-04** : pas de build si la suite de tests n'est pas verte juste avant.
- **R-05** : pas de commit de `PROJET.json` sans `PROJET.md` strictement aligné (et inversement).
- **R-06** : pas de modification de `METHOD.md`/`METHOD.json` sans validation PO (protocole A.8 : proposer → valider → appliquer → versionner → journaliser).
- **R-07** : pas de tâche « terminée » sans vérifications exécutées ou impossibilité signalée.
- **R-08** : ne jamais inventer un état, un résultat de test ou un hash : tout fait rapporté doit avoir été observé.
- **R-09** : ne jamais supprimer ou réécrire un document de suivi hors des mises à jour incrémentales prévues.
- **R-10** : en cas de contradiction → ordre de précédence : instruction PO > METHOD > PROJET.json > PROJET.md > autres docs ; si ça ne tranche pas, **s'arrêter et demander**.

## Garde-fous au bootstrap

- `test_dev_en_cours` actif → le rappeler au PO et attendre validation avant de coder (BP-09).
- Suivi (`PROJET*`, `METHOD*`, `INDEX-docs.md`) modifié non commité d'une session précédente → le signaler avant tout travail (BP-19).
- Annoncer après bootstrap : branche, état du working tree, test-dev éventuel, point de reprise.

## Règles courtes

- `PROJET.json` est la source de vérité projet ; `PROJET.md` est le miroir humain.
- `INDEX-docs.md` doit suivre toute création ou déplacement documentaire.
- Retours de test manuel → `backlog_test_dev` (td-NNN) ; constats d'audit de code → `backlog_audit_code` (ac-NNN) — ne jamais mélanger.
- Dérouler la **checklist mécanique pré-commit** (Annexe 1 de `METHOD.md`) avant chaque commit.
- Le skill `safeguard-mistral/SKILL.md` est une **extension conditionnelle inactive par défaut** : il ne s'applique que si (1) le modèle qui code est un modèle **Mistral AI** **et** (2) le **prompt initial** de la session le mentionne explicitement. Sinon : ne pas le lire, ne pas le citer, suivre `METHOD.md` seul (cf. A.9). Les fichiers `safeguard-mistral/references/` sont **absents** : ne jamais en inventer le contenu ni prétendre les avoir lus (R-08).

## Spécificités du projet (à adapter)

- Type d'application : `<TYPE_APPLICATION>`
- Stack technique : `<STACK_TECHNIQUE>`
- Référence technique principale : `<DOSSIER_REFERENCE>/`
- Référence produit principale : `<ROADMAP>.md`
- Points de vigilance : sécurité, dépendances natives, formats de backup, surface d'attaque, **logs sans données sensibles** (B.2-6).
- Politique locale actuelle : voir Partie B.6 de `METHOD.md` (défaut = branches de feature, override possible si documenté).

## Réflexes d'implémentation

- Vérifier d'abord si la référence technique possède déjà la brique recherchée.
- Séparer logique pure et code à effets autant que possible.
- Garder le code sensible simple à relire et à auditer.
- **Créer ou mettre à jour les tests anti-régressions dans `<DOSSIER_TEST>/` en même temps que le code.**
- **Exécuter les tests avant toute commande de build** (`<COMMANDE_TEST>` avant `<COMMANDE_BUILD>`).
- **Utiliser `<SCRIPT_PRE_BUILD>.<EXT>`** pour la vérification automatique locale.
- **Utiliser `<SCRIPT_RELEASE>.<EXT>`** pour préparer un jalon de release.
- **Vérifier la cohérence croisée `PROJET.json` ↔ `PROJET.md` avant tout commit de suivi (BP-17).**
- Mettre à jour `PROJET` après chaque avancée significative et committer le suivi avant la fin de session (BP-19).
