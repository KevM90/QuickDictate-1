# Architecture

## Ist-Architektur (Originalprojekt)

### Übersicht

Native macOS Menubar App, Swift 5.10, SwiftUI, macOS 14+.  
Build via XcodeGen → xcodebuild, universelles Binary (arm64 + x86_64).

```
BlitztextMac/
  App/
    BlitztextMacApp.swift       — App-Entry, StatusItem-Setup
    AppState.swift              — Zentrales ViewModel (@Observable), Settings, Workflow-Orchestrierung
    MenuBarStatusController.swift
  Features/
    MenuBar/
      MenuBarView.swift
      WorkflowRowView.swift
    Settings/
      SettingsContentView.swift — Zwei Tabs: "Anpassen" / "Zugang"
    Workflows/
      WorkflowProtocol.swift    — WorkflowType, WorkflowPhase, alle Settings-Structs
      TranscriptionWorkflow.swift
      TextImprovementWorkflow.swift
      DampfAblassenWorkflow.swift
      EmojiTextWorkflow.swift
  Services/
    TranscriptionService.swift  — OpenAI Whisper API (HARDCODED)
    LLMService.swift            — OpenAI Chat Completions (HARDCODED)
    LocalTranscriptionService.swift — WhisperKit/CoreML (lokal)
    KeychainService.swift       — macOS Keychain, Key: openAIAPIKey
    AudioRecorder.swift
    HotkeyService.swift
    AccessibilityPermissionService.swift
    AppSupportPaths.swift
    BlitztextInstallLocationService.swift
    BlitztextCleanupService.swift
    LaunchAtLoginService.swift
    TranscriptionQualityService.swift
  Views/
    WaveformView.swift
```

### Datenfluss (Online)

```
Hotkey / Menubar → AppState.startWorkflow()
  → AudioRecorder (AVFoundation, .m4a)
  → TranscriptionService.transcribe()  → POST https://api.openai.com/v1/audio/transcriptions
  → [optional] LLMService.improve()    → POST https://api.openai.com/v1/chat/completions
  → AppState.handleWorkflowOutput()
  → NSPasteboard + CGEvent (Cmd+V) → Ziel-App
```

### Datenfluss (Lokal)

```
Hotkey → AudioRecorder → LocalTranscriptionService (WhisperKit/CoreML) → Clipboard
```

### API-Provider (Ist-Zustand)

| Dienst | Endpoint | Modell |
|--------|----------|--------|
| Transkription | `https://api.openai.com/v1/audio/transcriptions` | `whisper-1` (hardcoded) |
| Textverbesserung | `https://api.openai.com/v1/chat/completions` | `gpt-4o-mini` / `gpt-4o` (hardcoded) |

### Secret-Speicherung (Ist-Zustand)

- Service: `app.blitztext.preview.credentials`
- Key: `openAIAPIKey`
- Zugriff: `kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly`
- Kein In-Memory-Cache

### Settings-Persistenz

JSON-Datei in `~/Library/Application Support/Blitztext/settings.json`.  
Gespeichert: AppSettings, TranscriptionSettings, TextImprovementSettings, DampfAblassenSettings, EmojiTextSettings.  
API Key **nicht** in dieser Datei — nur Keychain.

### Abhängigkeiten

- `argmax-oss-swift` v0.18.0 (WhisperKit) — nur für lokale Transkription
- Keine weiteren externen Swift-Pakete

### Build-Prozess

```bash
brew install xcodegen
./build.sh [--run] [--install] [--debug]
```

1. `xcodegen generate` aus `BlitztextMac/project.yml`
2. `xcodebuild` → universelles Binary
3. `codesign --force --sign -` (ad-hoc, nicht notarisiert)
4. Output: `Blitztext.app` im Projektverzeichnis

---

## Ziel-Architektur (Groq Edition)

### Provider-Abstraktion (geplant)

```
AIProvider (Protocol)
  ├── SpeechToTextProvider (Protocol)
  │     └── GroqSpeechToTextService
  └── TextRewriteProvider (Protocol)
        └── GroqChatRewriteService

APIKeyStore (Protocol)
  ├── KeychainAPIKeyStore (macOS)
  └── WindowsCredentialStore / LocalConfigStore (Windows)

ProviderSettings
  ├── transcriptionModel: String   (z.B. "whisper-large-v3-turbo")
  └── rewriteModel: String         (konfigurierbar)
```

### Groq-Endpoints

| Dienst | Endpoint |
|--------|----------|
| Transkription | `POST https://api.groq.com/openai/v1/audio/transcriptions` |
| Chat / Rewrite | `POST https://api.groq.com/openai/v1/chat/completions` |
| Auth-Header | `Authorization: Bearer <GROQ_API_KEY>` |

Groq nutzt OpenAI-kompatible Strukturen — die Request/Response-Typen sind wiederverwendbar, nur URL und Key-Herkunft ändern sich.

### Windows-Architektur

Entscheidung in Phase 5. Favorit nach Voranalyse: **Tauri + Rust** (kleines portable Bundle, gute System-Integration).  
Fallback: Electron (schneller Prototyp, aber größer).

Detaillierter Vergleich in `docs/phases/PHASE_1_ARCHITECTURE_CONCEPT.md`.  
Details in `docs/WINDOWS_ARCHITECTURE.md` (wird in Phase 5 erstellt).
