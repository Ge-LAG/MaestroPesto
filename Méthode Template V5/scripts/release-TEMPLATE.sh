#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# release.sh — Pipeline de release automatique locale.
# -----------------------------------------------------------------------------
# Ce script est un TEMPLATE. Copiez-le dans le projet, renommez-le si besoin,
# puis adaptez les commandes et les étapes de packaging au stack du projet.
#
# Usage :
#   chmod +x scripts/release.sh
#   ./scripts/release.sh v0.2.0
#
# Options (variables d'environnement) :
#   SKIP_SMOKE=1   : ignore le smoke test
#   SKIP_TAG=1     : ne crée pas de tag Git
#   SKIP_BUNDLE=1  : ne génère pas le package de release
# -----------------------------------------------------------------------------

set -euo pipefail

VERSION="${1:-}"
if [[ -z "$VERSION" ]]; then
    echo "Usage: $0 v<MAJOR>.<MINOR>[.<PATCH>]"
    exit 1
fi

if [[ ! "$VERSION" =~ ^v[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    echo "Erreur : VERSION doit respecter le format v<MAJOR>.<MINOR>[.<PATCH>] (ex: v0.2.0)"
    exit 1
fi

# Configuration à adapter
COMMAND_TEST="<COMMANDE_TEST>"      # ex: "npm test", "cargo test"
COMMAND_BUILD="<COMMANDE_BUILD>"    # ex: "npm run build", "cargo build --release"
COMMAND_SMOKE="<COMMANDE_SMOKE>"    # ex: "./dist/mon-app --version"
COMMAND_BUNDLE="<COMMANDE_BUNDLE>"  # ex: "./scripts/bundle.sh $VERSION"
RELEASE_DIR="<DOSSIER_RELEASE>"     # ex: "release", "dist"

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RELEASE_FULL_PATH="$REPO_ROOT/$RELEASE_DIR"

step() {
    echo ""
    echo "==> $1"
}

run() {
    step "$2 ($1)"
    eval "$1"
}

run "$COMMAND_TEST"  "Tests anti-régressions"
run "$COMMAND_BUILD" "Build"

if [[ -z "${SKIP_SMOKE:-}" ]]; then
    run "$COMMAND_SMOKE" "Smoke test"
fi

if [[ -z "${SKIP_BUNDLE:-}" ]]; then
    mkdir -p "$RELEASE_FULL_PATH"
    run "$COMMAND_BUNDLE" "Packaging"
fi

if [[ -z "${SKIP_TAG:-}" ]]; then
    git tag -a "$VERSION" -m "Release $VERSION"
    echo ""
    echo "🏷️  Tag $VERSION créé. Poussez-le avec : git push origin $VERSION"
fi

echo ""
echo "✅ Release $VERSION préparée avec succès."
if [[ -z "${SKIP_BUNDLE:-}" ]]; then
    echo "Artefacts disponibles sous : $RELEASE_FULL_PATH"
fi
