# MaestroPesto

Application Flutter local-first de gestion de recettes de cuisine.

## État

POC en cours :

- interface responsive desktop/mobile
- classeur de recettes avec recherche et tags
- fiches recettes de démonstration
- données Ciqual conservées au format XML

## Lancer

```powershell
flutter pub get
flutter run -d windows
```

## Tester

```powershell
flutter test
```

## Structure

```text
lib/        application Flutter
test/       tests
ciqual/     source Ciqual XML
database/   schéma SQLite cible
scripts/    scripts projet
```
