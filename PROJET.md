# MaestroPesto - Journal de projet (V5)

> Miroir humain de `PROJET.json` (source de verite machine). Toute modification de l'un doit entrainer la modification de l'autre (BP-17).

## Identite

| Champ | Valeur |
|-------|--------|
| **Projet** | MaestroPesto |
| **Phase courante** | P0 - bootstrap methodologique |
| **Etat general** | Bootstrap V5 en cours sur la branche PR Ge-LAG/bootstrap-v5-doc. Aucune feature de code n'est developpee tant que la methode n'est pas validee par le PO. |

## Focus immediat

Valider avec Gui la branche PR (Ge-LAG/bootstrap-v5-doc) et l'integration des regles PR/commit dans METHOD.md.

## Prochaines etapes

- Attendre validation PO du bootstrap V5 (R-06 / A.8).
- Ouvrir une PR GitHub depuis Ge-LAG/bootstrap-v5-doc vers main.
- Indexer dans INDEX-docs.md les fichiers METHOD/PROJET crees.
- Planifier la premiere feature produit sur une nouvelle branche PR dediee.

## Questions ouvertes

- Valider le format de branche Ge-LAG/<resume-2-3-mots> propose pour toutes les futures branches PR.
- Confirmer la liste des themes de commit acceptes (UI, UX, backend, db, test, docs, build, method, chore, fix).
- Decider si on garde un seul commit par PR ou si on accepte les commits de merge.
- Decider du calendrier d'activation de l'override politique_de_branche.

## Journal des sessions

#### 2026-08-22 - bootstrap-v5
*Bootstrap de la Methode V5 sur MaestroPesto. Creation des fichiers racine + amend METHOD.md (branche PR + commits structures). Branche dediee Ge-LAG/bootstrap-v5-doc, 1 seul commit 'method: bootstrap v5 doc'. Aucun fichier source modifie, aucun push.*
- PO : Ge-LAG
- Agent : Hermes (MiniMax-M3)

## Test-dev en cours

Aucun (`test_dev_en_cours` = `null`).

## Backlog test-dev

Vide. Format attendu : `td-NNN` (retours de test manuel), voir BP-10.

## Backlog audit code

Vide. Format attendu : `ac-NNN` (constats d'audit de code), voir BP-18.

## Documents associes

- `METHOD.md`
- `METHOD.json`
- `METHOD-BOOTSTRAP.md`
- `PROJET.md`
- `PROJET.json`
- `INDEX-docs.md`
- `ARCHITECTURE.md`
- `README.md`