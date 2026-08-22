# <DOSSIER_TEST>/ — Suite de tests anti-régressions

Ce dossier contient l'intégralité des tests automatisés du projet. Il est structuré pour refléter le code source sous `<DOSSIER_SOURCE>/` et reste isolé du code applicatif.

## Point d'entrée

- `<POINT_ENTREE_TEST>.<EXT>` — Rassemble tous les modules de test et les expose au runner du projet.
- Commande de lancement : `<COMMANDE_TEST>`

## Organisation

```
<DOSSIER_TEST>/
  <POINT_ENTREE_TEST>.<EXT>     -- entrée principale de la suite
  README.md                       -- ce fichier
  <Domaine1>/
    <Module1>Spec.<EXT>           -- tests du module <Module1>
    <Module2>Spec.<EXT>
  <Domaine2>/
    ...
```

## Règles de contribution

1. **Un fichier de test par module significatif** — Si une logique mérite d'être testée, elle a son fichier de test.
2. **Miroir de `<DOSSIER_SOURCE>/`** — Le chemin sous `<DOSSIER_TEST>/` correspond au chemin du module testé sous `<DOSSIER_SOURCE>/`.
3. **Nommage explicite** — Les descriptions de tests utilisent un langage métier. Exemples :
   - `"rejects invalid input with a clear error message"`
   - `"round-trips a record through save and load"`
   - `"purges temporary resources after external call"`
4. **Pas de données sensibles** — Aucun vrai mot de passe, clé, token, certificat ou base de production ne doit apparaître dans un test.
5. **Répertoires temporaires** — Les tests qui touchent au disque créent leurs propres répertoires temporaires et les nettoient.
6. **Test avant build** — La suite doit être entièrement verte avant `<COMMANDE_BUILD>`.

## Cycle rouge / vert

Quand une nouvelle feature ou un bug est traité :

1. Écrire un test qui reproduit le comportement attendu ou le bug.
2. Vérifier que le test échoue (rouge).
3. Implémenter la correction ou la feature.
4. Vérifier que le test passe (vert) et que la suite complète reste verte.

## Ajouter un nouveau module de test

1. Créer le fichier `<DOSSIER_TEST>/<Chemin>/<Module>Spec.<EXT>` (ou l'idiome du langage).
2. Exporter le point d'entrée attendu par le runner (ex: `spec :: Spec`, `def test_...`, etc.).
3. L'importer et l'enregistrer dans `<DOSSIER_TEST>/<POINT_ENTREE_TEST>.<EXT>` si le runner l'exige.
4. Lancer `<COMMANDE_TEST>` pour valider.
