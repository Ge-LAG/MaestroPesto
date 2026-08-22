#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# prebuild-checks.sh — Pipeline CI/CD locale minimale : test -> build.
# -----------------------------------------------------------------------------
# Ce script est un TEMPLATE. Copiez-le dans le projet, renommez-le si besoin,
# puis remplacez les placeholders par les commandes concrètes du stack.
#
# Principe généraliste applicable à tout projet : la suite de tests doit être
# entièrement verte avant toute commande de build. Si un test échoue, le build
# est bloqué.
#
# Usage :
#   chmod +x scripts/prebuild-checks.sh
#   ./scripts/prebuild-checks.sh
# -----------------------------------------------------------------------------

set -euo pipefail

# Configuration à adapter
COMMAND_TEST="<COMMANDE_TEST>"    # ex: "npm test", "cargo test", "pytest", "make test"
COMMAND_BUILD="<COMMANDE_BUILD>"  # ex: "npm run build", "cargo build", "make"

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

echo ""
echo "✅ Pre-build checks terminés avec succès."
