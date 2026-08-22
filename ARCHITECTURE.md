# MaestroPesto Architecture

MaestroPesto est une application Flutter local-first pour gerer des recettes, leurs ingredients, leur export PDF et leur bilan nutritionnel Ciqual.

## Cibles

- POC local : Flutter Windows.
- Desktop : Windows, macOS, Linux.
- Mobile : Android, iOS.
- Stockage cible : SQLite via Drift.

## Organisation cible

```text
lib/
  app/                  shell, theme, navigation
  core/
    database/           Drift, migrations, repositories communs
    ids/                generation d'identifiants
  features/
    recipes/            CRUD, classeur, tags, ingredients
    nutrition/          import Ciqual et moteur nutritionnel
    export/             export PDF
    sync/               snapshot puis sync evenementielle
ciqual/                 source Ciqual XML
database/               schema SQL de reference
scripts/                scripts d'import et maintenance
test/                   tests Flutter et domaine
```

## Persistance

Le POC doit demarrer avec une base SQLite locale. Drift servira de couche typage, migrations et requetes reactives.

Les entites principales :

- `recipes`
- `recipe_steps`
- `recipe_items`
- `tags`
- `recipe_tags`
- `ciqual_foods`
- `ciqual_nutrients`
- `sync_events`

Le schema de reference vit dans `database/schema.sql`.

## Sync

Premiere version testable : export/import de snapshot.

Version suivante : dossier de sync partage avec evenements idempotents.

```text
maestropesto-sync/
  devices/
  events/
  snapshots/
```

Politique de conflit POC : last-write-wins au niveau recette, puis merge par champ une fois l'editeur stabilise.

## Nutrition

Le repo conserve uniquement les fichiers XML Ciqual. Ils seront importes vers SQLite pour que l'app puisse chercher les aliments et calculer les nutriments hors ligne.

Nutriments POC :

- energie kcal
- proteines
- glucides
- sucres
- fibres
- lipides
- acides gras satures
- sel

Une recette peut etre utilisee comme ingredient d'une autre recette. Le moteur nutritionnel devra resoudre ces references recursivement et bloquer les cycles.
