# Phase 5 — Windows Portable Architekturentscheidung

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

Beste Technologie für Windows portable wählen, Windows-Architektur definieren, MVP-Scope festlegen. Kein Code.

---

## Analyse

Vier Optionen verglichen: Tauri, Electron, .NET/WinUI 3, Python/PySide6.

Systemcheck: Rust 1.95 und Node.js 25.9 bereits installiert. .NET nicht vorhanden.

Vollständige Entscheidungsmatrix in `docs/WINDOWS_ARCHITECTURE.md`.

---

## Entscheidung: Tauri 2 + Rust

### Begründung

| Faktor | Wert |
|--------|------|
| Bundle-Größe | ~10–20 MB (Electron: 80–120 MB) |
| Toolchain | Rust bereits installiert — kein Setup |
| Windows 11 | WebView2 vorinstalliert — kein Runtime-Bundling |
| API Key Sicherheit | Windows Credential Manager via `keyring` Crate |
| Antivirus-Risiko | Keines (kein Python/PyInstaller) |
| Audio | `cpal` → WASAPI — professionelle Windows-Audio-API |

---

## Windows MVP — Scope

### Enthalten

- System-Tray-Icon
- Globaler Hotkey (Hold oder Toggle, konfigurierbar)
- Groq Speech-to-Text
- Optionale Textverbesserung
- Ergebnis in Zwischenablage
- Settings-Fenster: API Key, Testbutton, Modellwahl, Hotkey

### Bewusst ausgeschlossen

- Auto-Paste — zu instabil für MVP, als spätere Ausbaustufe dokumentiert
- Lokale Transkription — WhisperKit ist macOS-only
- Installer/MSI — nur portable Ordnerstruktur
- Signierung/Notarisierung

---

## Projektstruktur

```
QuickDictateWindows/   (neu, parallel zu BlitztextMac/)
  src-tauri/
    src/main.rs, audio.rs, groq.rs, settings.rs
    Cargo.toml, tauri.conf.json
  src/
    index.html, main.js, settings.html, style.css
  package.json

dist/windows-portable/  (Build-Output)
  QuickDictate.exe
  resources/
```

---

## Risiken

| Risiko | Bewertung | Gegenmaßnahme |
|--------|-----------|---------------|
| Tauri Cross-Compile macOS→Windows | Hoch — empfohlen: nativ auf Windows | GitHub Actions Windows-Runner für CI |
| WebView2 auf Windows 10 | Mittel — Windows 11 hat es vorinstalliert | Windows 11 als Mindestanforderung setzen |
| `cpal` WASAPI-Latenz | Niedrig | Ausreichend für Push-to-Talk-Use-Case |
| Groq Audio-Format | `cpal` liefert PCM — `hound` encoded WAV — Groq akzeptiert WAV ✅ | Getestet in Phase 6 |

---

## Definition of Done

- [x] Technologieentscheidung begründet: Tauri 2 + Rust
- [x] Alle Alternativen dokumentiert und abgewogen
- [x] Windows-MVP-Scope klar definiert
- [x] Projektstruktur definiert
- [x] Cargo-Abhängigkeiten identifiziert
- [x] Risiken dokumentiert
- [x] Keine Implementierung ohne Konzept

---

## Commit

```
docs: add windows architecture decision — tauri 2 + rust
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 5, kein Code
- ✅ Konzept vor Umsetzung
- ✅ Kritische Prüfung (Risiken dokumentiert)
- ✅ Keine persönlichen Daten
- ✅ Dokumentation vollständig

---

## Nächste Phase

Phase 6: Windows Portable MVP — Tauri-Projekt anlegen, Audio, Groq, Settings implementieren.  
Wartet auf Freigabe.
