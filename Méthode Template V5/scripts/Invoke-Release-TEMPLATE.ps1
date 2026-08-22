#Requires -Version 5.1
<#
.SYNOPSIS
    Pipeline de release automatique locale : test -> build -> (smoke) -> (bundle) -> (tag).

.DESCRIPTION
    Ce script est un TEMPLATE. Copiez-le dans le projet, renommez-le selon la
    convention du repo (ex: Invoke-Release.ps1), puis adaptez les commandes
    et les étapes de packaging au stack du projet.

.PARAMETER Version
    Version de release au format v<MAJOR>.<MINOR>[.<PATCH>], par exemple "v0.2.0".

.PARAMETER SkipSmoke
    Ignore le smoke test de l'artefact.

.PARAMETER SkipTag
    Ne crée pas de tag Git.

.PARAMETER SkipBundle
    Ne génère pas le package de release.

.EXAMPLE
    .\scripts\Invoke-Release.ps1 -Version v0.2.0

.EXAMPLE
    .\scripts\Invoke-Release.ps1 -Version v0.2.0 -SkipSmoke
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$Version,

    [switch]$SkipSmoke,
    [switch]$SkipTag,
    [switch]$SkipBundle
)

$ErrorActionPreference = "Stop"

if ($Version -notmatch '^v\d+\.\d+(\.\d+)?$') {
    throw "Le paramètre -Version doit respecter le format v<MAJOR>.<MINOR>[.<PATCH>] (ex: v0.2.0). Valeur reçue : $Version"
}

# ---------------------------------------------------------------------------
# CONFIGURATION À ADAPTER
# ---------------------------------------------------------------------------
$CommandTest = "<COMMANDE_TEST>"              # ex: "cabal test", "npm test"
$CommandBuild = "<COMMANDE_BUILD>"            # ex: "cabal build", "npm run build"
$CommandSmoke = "<COMMANDE_SMOKE>"            # ex: chemin vers l'exe + --version
$CommandBundle = "<COMMANDE_BUNDLE>"          # ex: "bash scripts/bundle.sh $Version"
$ReleaseDir = "<DOSSIER_RELEASE>"             # ex: "release", "dist"
# ---------------------------------------------------------------------------

$repoRoot = Split-Path -Parent $PSScriptRoot
$releaseFullPath = Join-Path $repoRoot $ReleaseDir

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

    if (-not $SkipSmoke) {
        Invoke-Step "Smoke test ($CommandSmoke)" $CommandSmoke
    }

    if (-not $SkipBundle) {
        Invoke-Step "Packaging ($CommandBundle)" $CommandBundle
    }

    if (-not $SkipTag) {
        Invoke-Step "Tag Git $Version" "git tag -a $Version -m Release $Version"
        Write-Host "`n🏷️  Tag $Version créé. Poussez-le avec : git push origin $Version" -ForegroundColor Yellow
    }

    Write-Host "`n✅ Release $Version préparée avec succès." -ForegroundColor Green
    if (-not $SkipBundle) {
        Write-Host "Artefacts disponibles sous : $releaseFullPath" -ForegroundColor Green
    }
    exit 0
}
catch {
    Write-Host "`n❌ $($_)" -ForegroundColor Red
    exit 1
}
