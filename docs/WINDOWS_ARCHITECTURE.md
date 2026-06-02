# Windows Portable Architecture — QuickDictate

## Entscheidung

**Gewählt: Tauri 2 + Rust + HTML/JS Frontend**

## Entscheidungsmatrix

| Kriterium | Tauri | Electron | .NET/WinUI 3 | Python/PySide6 |
|-----------|-------|----------|--------------|----------------|
| Bundle-Größe | ✅ ~10–20 MB | ❌ 80–120 MB | ⚠️ 40–60 MB | ❌ 60–100 MB |
| Portabilität | ✅ Ordner + .exe | ✅ Ordner + .exe | ✅ self-contained | ⚠️ PyInstaller |
| Mikrofon | ✅ `cpal` (Rust) | ✅ getUserMedia | ✅ nativ | ✅ sounddevice |
| Globaler Hotkey | ✅ Plugin | ✅ nativ | ✅ nativ | ⚠️ pynput |
| Clipboard | ✅ Plugin | ✅ nativ | ✅ nativ | ✅ pyperclip |
| Groq HTTP | ✅ `reqwest` | ✅ fetch | ✅ HttpClient | ✅ httpx |
| Antivirus FP | ✅ kein Problem | ✅ kein Problem | ✅ kein Problem | ❌ häufig |
| Toolchain hier | ✅ Rust vorhanden | ✅ Node vorhanden | ❌ .NET fehlt | ✅ Python vorhanden |
| Windows 11 ready | ✅ WebView2 vorinstalliert | ✅ Chromium gebündelt | ✅ nativ | ✅ |
| Aufwand MVP | mittel | gering | mittel | gering |

## Warum Tauri

1. **Kleinste portable Bundle** — ~10–20 MB statt 80+ MB (Electron)
2. **Rust-Toolchain bereits installiert** — kein Setup-Overhead
3. **Windows 11 hat WebView2 vorinstalliert** — kein Runtime-Bundling nötig
4. **Sichere Speicherung** — `keyring`-Crate nutzt Windows Credential Manager nativ
5. **Audio via `cpal`** — plattformübergreifende Rust-Library, Windows WASAPI
6. **Kein Antivirus-Risiko** — kein PyInstaller/Python-Interpreter
7. **Groq HTTP via `reqwest`** — async Rust, sauber integriert

## Projektstruktur

```
QuickDictateWindows/
  src-tauri/
    src/
      main.rs          — Tauri app, commands, event handling
      audio.rs         — Mikrofon-Aufnahme via cpal (WASAPI)
      groq.rs          — Groq API client (reqwest)
      settings.rs      — Settings-Persistenz + Windows Credential Manager
    Cargo.toml
    tauri.conf.json    — App-Konfiguration, Bundle, Icons
    build.rs
  src/
    index.html         — Hauptfenster (Tray-Popup)
    settings.html      — Einstellungen
    main.js            — Frontend-Logik, Tauri invoke()
    style.css
  package.json
  build-windows.sh     — Build-Script (Cross-compile oder native)
```

Im Hauptrepo-Root parallel zu `BlitztextMac/`.

## Windows MVP Scope

### Enthalten

1. System-Tray-Icon (analog macOS Menubar)
2. Globaler Hotkey konfigurierbar (Default: `Ctrl+Shift+Space`)
3. Hold-to-record oder Toggle-Modus
4. Groq Speech-to-Text (`whisper-large-v3-turbo`)
5. Optionale Textverbesserung (Groq Chat)
6. Ergebnis in Zwischenablage
7. Settings-Fenster:
   - Groq API Key (Windows Credential Manager)
   - API-Verbindung testen
   - Transkriptionsmodell wählen
   - Chat-Modell wählen
   - Hotkey konfigurieren
   - Aufnahmemodus (Hold / Toggle)
8. Fehlermeldungen: fehlender Key, ungültiger Key, Rate Limit, Netzwerkfehler

### Bewusst nicht im MVP

- Auto-Paste (Cmd+V-Simulation) — zu instabil, Clipboard ist zuverlässiger
- Lokale Transkription (WhisperKit ist macOS-only)
- Installer/MSI (nur portable Ordner)
- Notarisierung / Signierung

Auto-Paste wird als explizite spätere Ausbaustufe dokumentiert.

## Portable Build Output

```
dist/windows-portable/
  QuickDictate.exe
  WebView2Loader.dll    (falls nicht systemweit vorhanden)
  resources/
```

Ziel: Ordner kopieren, `.exe` starten — fertig.

## Datenspeicherung Windows

| Daten | Speicherort |
|-------|-------------|
| Groq API Key | Windows Credential Manager via `keyring` Rust crate |
| App-Settings (Modell, Hotkey, Modus) | `%APPDATA%\QuickDictate\settings.json` |
| Logs | Nicht persistent — nur im Laufzeit-Kontext |

API Key erscheint **nie** in der settings.json und **nie** in Logs.

## Abhängigkeiten (Rust Crates)

```toml
[dependencies]
tauri = { version = "2", features = ["tray-icon", "image-png"] }
tauri-plugin-global-shortcut = "2"
tauri-plugin-clipboard-manager = "2"
tauri-plugin-store = "2"       # settings.json
cpal = "0.15"                  # Mikrofon-Aufnahme
hound = "3"                    # WAV-Encoding für Groq
reqwest = { version = "0.12", features = ["multipart", "json"] }
keyring = "3"                  # Windows Credential Manager
serde = { version = "1", features = ["derive"] }
serde_json = "1"
tokio = { version = "1", features = ["full"] }
```

## Build-Voraussetzungen (Windows)

```
- Windows 11
- Rust (stable) + cargo
- Node.js (für Tauri CLI)
- npm install -g @tauri-apps/cli
- WebView2 (vorinstalliert auf Windows 11)
```

## Build-Voraussetzungen (Cross-Compile von macOS)

Cross-Compilation macOS → Windows ist mit Rust möglich via:
```bash
rustup target add x86_64-pc-windows-gnu
```
Allerdings empfohlen: nativ auf Windows bauen oder GitHub Actions Windows-Runner.
