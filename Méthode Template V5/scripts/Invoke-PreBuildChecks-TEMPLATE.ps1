#Requires -Version 5.1
<#
.SYNOPSIS
    Pipeline CI/CD locale minimale : test -> build.

.DESCRIPTION
    Ce script est un TEMPLATE. Copiez-le dans le projet, renommez-le selon la
    convention du repo (ex: Invoke-PreBuildChecks.ps1), puis remplacez les
    placeholders par les commandes concrètes du stack.

    Principe généraliste applicable à tout projet : la suite de tests doit
    être entièrement verte avant toute commande de build. Si un test échoue,
    le build est bloqué.

.EXAMPLE
    .\scripts\Invoke-PreBuildChecks.ps1
#>
[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"

# ---------------------------------------------------------------------------
# CONFIGURATION À ADAPTER
# ---------------------------------------------------------------------------
$CommandTest = "<COMMANDE_TEST>"    # ex: "cabal test", "npm test", "cargo test", "pytest"
$CommandBuild = "<COMMANDE_BUILD>"  # ex: "cabal build", "npm run build", "cargo build", "make"

# Si le projet nécessite un environnement spécial (wrapper, PATH, variables) :
# $EnvSetup = { ... }
# & $EnvSetup
# ---------------------------------------------------------------------------

function Write-Step {
    param([string]$Message)
    Write-Host "`n==> $Message" -ForegroundColor Cyan
}

function Invoke-Step {
    param(
        [string]$Caption,
        [string]$Command
    )
    Write-Step $Caption

    # Découpe la commande en exécutable + arguments pour un appel propre
    $parts = $Command -split ' ', 2
    $exe = $parts[0]
    $args = if ($parts.Length -gt 1) { $parts[1] } else { $null }

    if ($args) {
        & $exe $args
    } else {
        & $exe
    }

    $code = $LASTEXITCODE
    if ($code -ne 0) {
        throw "Échec à l'étape : $Caption (exit code $code)"
    }
}

try {
    Invoke-Step "Tests anti-régressions ($CommandTest)" $CommandTest
    Invoke-Step "Build ($CommandBuild)" $CommandBuild

    Write-Host "`n✅ Pre-build checks terminés avec succès." -ForegroundColor Green
    exit 0
}
catch {
    Write-Host "`n❌ $($_)" -ForegroundColor Red
    exit 1
}
