# Phase 6 — Windows Portable MVP

**Status:** Implementiert (Build-Verifikation auf Windows erforderlich)  
**Datum:** 2026-06-02

---

## Umsetzung

### Neue Dateien

```
QuickDictateWindows/
  .gitignore
  package.json                          — npm + Tauri CLI
  src-tauri/
    Cargo.toml                          — Rust-Abhängigkeiten
    build.rs
    tauri.conf.json                     — App-Konfiguration, Fenster, Tray
    src/
      main.rs                           — Tauri-App, Commands, Hotkey, Tray
      audio.rs                          — cpal WASAPI, WAV-Encoding (hound)
      groq.rs                           — Groq API: Transkription + Chat
      settings.rs                       — keyring (Win Credential Manager) + Store
  src/
    index.html + main.js                — Hauptfenster (Status, Record-Button)
    settings.html + settings.js         — Einstellungen (Key, Modelle, Sprache)
    style.css                           — Dark-Mode UI

docs/BUILD_WINDOWS_PORTABLE.md         — Build-Anleitung
```

### Funktionsumfang MVP

- [x] System-Tray-Icon mit Kontextmenü (Einstellungen / Beenden)
- [x] Linksklick auf Tray öffnet/schließt Hauptfenster
- [x] Globaler Hotkey `Ctrl+Shift+Space` (Toggle-Modus)
- [x] Mikrofon-Aufnahme via `cpal` (WASAPI), WAV-Encoding via `hound`
- [x] Mindestdauer-Check (< 0,4 s → abgelehnt)
- [x] Groq Speech-to-Text (`whisper-large-v3-turbo` default)
- [x] Optionale Textverbesserung via Groq Chat
- [x] Ergebnis in Zwischenablage via `tauri-plugin-clipboard-manager`
- [x] Fehlermeldungen: kein Key, ungültiger Key, Rate Limit, Netzwerkfehler
- [x] Settings-Fenster: API Key (Win Credential Manager), Test-Button, Modellwahl, Sprache
- [x] API Key nie in Code, nie in settings.json, nie in Logs

### Bewusst nicht enthalten

- Auto-Paste — nicht im MVP
- Lokale Transkription — macOS-only (WhisperKit)
- Installer/MSI — portable `.exe` ausreichend
- Hotkey-Konfiguration per UI — in Phase 7 ergänzbar

---

## Build-Status

Rust und Node.js sind auf dem Entwicklungsrechner vorhanden.  
**Build muss auf Windows 11 durchgeführt werden** (oder via GitHub Actions Windows-Runner).

Manuelle Verifikation: siehe `docs/BUILD_WINDOWS_PORTABLE.md`

---

## Security & Anonymisierung

- Kein API Key im Code ✅
- `keyring`-Crate → Windows Credential Manager ✅
- Kein Key in settings.json ✅
- Kein Key in Logs ✅
- Kein Username / keine E-Mail im Code ✅

---

## Definition of Done

- [x] Tauri-Projektstruktur angelegt
- [x] Rust-Backend vollständig implementiert (audio, groq, settings, main)
- [x] Frontend vollständig implementiert (main + settings)
- [x] Build-Dokumentation erstellt
- [x] Security-Check: sauber
- [ ] Build auf Windows 11 erfolgreich
- [ ] Mikrofon-Aufnahme getestet
- [ ] Groq-Transkription getestet
- [ ] Clipboard-Ausgabe getestet
- [ ] Tray + Hotkey getestet

---

## Commit

```
feat: add windows portable mvp — tauri 2, rust audio/groq/settings, frontend ui
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 6
- ✅ Kein API Key im Code
- ✅ Keine persönlichen Daten
- ✅ Security-Check durchgeführt
- ✅ Dokumentation erstellt

---

## Nächste Phase

Phase 7: Windows Packaging & Qualität — portable Ordnerstruktur, Build-Script, Troubleshooting.
