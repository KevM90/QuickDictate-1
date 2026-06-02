# QuickDictate Windows — Build Script
# Voraussetzungen: Rust, Node.js, npm
# Ausfuehren: powershell -ExecutionPolicy Bypass -File build-windows.ps1

param(
    [switch]$Run,
    [switch]$Debug,
    [switch]$IconOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$ProjectDir   = $PSScriptRoot
$DistDir      = Join-Path $ProjectDir "..\dist\windows-portable"
$IconSrc      = Join-Path $ProjectDir "..\BlitztextMac\Resources\Assets.xcassets\AppIcon.appiconset\icon_512x512.png"
$ReleaseExe   = Join-Path $ProjectDir "src-tauri\target\release\quickdictate-windows.exe"
$DebugExe     = Join-Path $ProjectDir "src-tauri\target\debug\quickdictate-windows.exe"

function Write-Step([string]$msg) { Write-Host "`n>> $msg" -ForegroundColor Cyan }
function Write-OK([string]$msg)   { Write-Host "   OK: $msg" -ForegroundColor Green }
function Write-Fail([string]$msg) { Write-Host "   FAIL: $msg" -ForegroundColor Red; exit 1 }

# ── Voraussetzungen pruefen ───────────────────────────────────────────────────

Write-Step "Pruefe Voraussetzungen"

if (-not (Get-Command rustc -ErrorAction SilentlyContinue)) {
    Write-Fail "Rust nicht gefunden. Installiere von https://rustup.rs"
}
Write-OK "Rust $(rustc --version)"

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Fail "Node.js nicht gefunden. Installiere von https://nodejs.org"
}
Write-OK "Node.js $(node --version)"

# ── npm install ───────────────────────────────────────────────────────────────

Write-Step "Installiere npm-Abhaengigkeiten"
Set-Location $ProjectDir
npm install --silent
if ($LASTEXITCODE -ne 0) { Write-Fail "npm install fehlgeschlagen" }
Write-OK "npm install"

# ── Icons generieren (optional) ──────────────────────────────────────────────

if ($IconOnly -or -not (Test-Path (Join-Path $ProjectDir "src-tauri\icons\icon.ico"))) {
    Write-Step "Generiere App-Icons"
    if (Test-Path $IconSrc) {
        npx --yes @tauri-apps/cli icon $IconSrc
        Write-OK "Icons generiert"
    } else {
        Write-Host "   WARN: Icon-Quelldatei nicht gefunden ($IconSrc)." -ForegroundColor Yellow
        Write-Host "         Tauri nutzt Standard-Icons." -ForegroundColor Yellow
    }
}

if ($IconOnly) { Write-Host "`nIcons fertig." -ForegroundColor Green; exit 0 }

# ── Build ─────────────────────────────────────────────────────────────────────

if ($Debug) {
    Write-Step "Baue Debug-Version"
    npm run -- tauri build --debug
    $ExePath = $DebugExe
} else {
    Write-Step "Baue Release-Version"
    npm run build
    $ExePath = $ReleaseExe
}

if ($LASTEXITCODE -ne 0) { Write-Fail "Build fehlgeschlagen" }
if (-not (Test-Path $ExePath)) { Write-Fail "Erwartete .exe nicht gefunden: $ExePath" }
Write-OK "Build erfolgreich: $ExePath"

# ── Portable-Ordner erstellen ────────────────────────────────────────────────

Write-Step "Erstelle portable Ordnerstruktur"

New-Item -ItemType Directory -Force -Path $DistDir | Out-Null
Copy-Item $ExePath (Join-Path $DistDir "QuickDictate.exe") -Force

# WebView2Loader.dll (nur falls vorhanden — auf Win 11 meist nicht benoetigt)
$wv2dll = Join-Path $ProjectDir "src-tauri\target\release\WebView2Loader.dll"
if (Test-Path $wv2dll) {
    Copy-Item $wv2dll $DistDir -Force
    Write-OK "WebView2Loader.dll kopiert"
}

Write-OK "Portable Build: $DistDir"
Write-Host ""
Write-Host "  Inhalt:" -ForegroundColor Gray
Get-ChildItem $DistDir | ForEach-Object { Write-Host "    $($_.Name)" -ForegroundColor Gray }

# ── Starten (optional) ───────────────────────────────────────────────────────

if ($Run) {
    Write-Step "Starte QuickDictate"
    Start-Process (Join-Path $DistDir "QuickDictate.exe")
}

Write-Host ""
Write-Host "Fertig!" -ForegroundColor Green
Write-Host "Portable App: $DistDir\QuickDictate.exe" -ForegroundColor Cyan
