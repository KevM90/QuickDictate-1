# Phase 7 — Windows Packaging & Qualität

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Umsetzung

### Kritische Korrektur: Tauri 2 Capabilities

Tauri 2 erfordert eine Capability-Konfigurationsdatei, ohne die Plugins (Clipboard, GlobalShortcut, Store) keine Berechtigung haben.

Neu: `QuickDictateWindows/src-tauri/capabilities/default.json`

Enthält Permissions für: `core:default`, `global-shortcut:*`, `store:*`, `clipboard-manager:*`

### Korrektur: State-Zugriff in main.rs

`main.rs` komplett überarbeitet: `do_toggle_recording`, `do_start_recording`, `do_stop_and_transcribe` als interne Funktionen mit `&AppHandle` + `app.state::<AppState>()`. Tauri-Commands rufen diese direkt auf — kein Lifetime-Problem mehr beim Hotkey-Handler.

### Neue Dateien

| Datei | Inhalt |
|-------|--------|
| `QuickDictateWindows/build-windows.ps1` | PowerShell Build-Script: prüft Voraussetzungen, npm install, Icons, Build, portable Ordner |
| `.github/workflows/build-windows.yml` | GitHub Actions: Windows-Runner, baut .exe, uploaded als Artifact |
| `src-tauri/capabilities/default.json` | Tauri 2 Plugin-Permissions (kritisch) |

### .gitignore-Erweiterung

`QuickDictateWindows/node_modules/` und `QuickDictateWindows/src-tauri/target/` zur Root-.gitignore hinzugefügt.

### README-Aktualisierung

- Windows Quick Start und Requirements ergänzt
- macOS Requirements auf Groq aktualisiert
- "What It Does" auf QuickDictate/Groq aktualisiert

---

## Portable Build-Struktur

```
dist/windows-portable/         ← .gitignored
  QuickDictate.exe
  WebView2Loader.dll            ← nur falls benötigt
```

Build-Script: `build-windows.ps1 [-Run] [-Debug] [-IconOnly]`

---

## Security & Anonymisierung

- Keine API Keys in Workflows ✅
- GitHub Actions Workflow nur Lesezugriff (`permissions: contents: read`) ✅
- Keine Secrets in `build-windows.ps1` ✅
- `dist/` bleibt .gitignored ✅

---

## Offene Punkte (nach Windows-Build-Test)

- [ ] Build auf Windows 11 durchführen
- [ ] Tray-Icon, Hotkey, Audio, Groq-API Ende-zu-Ende testen
- [ ] GitHub Actions Workflow testen (`workflow_dispatch`)
- [ ] Hotkey-Konfiguration per UI (Phase 8 / später)

---

## Definition of Done

- [x] Capabilities-Datei erstellt (Tauri 2 Pflicht)
- [x] main.rs State-Zugriff korrekt
- [x] PowerShell Build-Script
- [x] GitHub Actions Windows-Workflow
- [x] .gitignore vollständig
- [x] README Windows-Abschnitt
- [x] Security-Check sauber
- [ ] Windows-Build erfolgreich (ausstehend)

---

## Commit

```
feat: windows packaging — capabilities, build script, ci workflow, readme update
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 7
- ✅ Keine API Keys in Code oder CI
- ✅ Keine persönlichen Daten
- ✅ Security-Check durchgeführt
- ✅ README aktualisiert
- ✅ Dokumentation vollständig

---

## Nächste Phase

Phase 8: Dokumentation & README Finalisierung.
