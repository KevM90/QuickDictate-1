# Technical Documentation

Vorläufiger Projektname: **Blitztext Groq Edition**  
Basis: [blitztext-app](https://github.com/cmagnussen/blitztext-app) (MIT License, © 2026 Blitztext contributors)

---

## 1. Projektziel

Angepasste private Fork der Blitztext macOS-App mit:
- Groq API statt OpenAI (Online-Transkription und Textverbesserung)
- Erweiterter Settings-UI für Groq API Key
- Portabler Windows-11-Version (Technologie: Phase 5)

---

## 2. Ausgangslage

Natives macOS Menubar App, Swift/SwiftUI, OpenAI-hardcodiert in zwei Services.  
Vollständige Ist-Analyse: `docs/ARCHITECTURE.md`.

---

## 3. Komponenten

| Komponente | Datei | Status |
|-----------|-------|--------|
| TranscriptionService | `Services/TranscriptionService.swift` | Umbau auf Groq (Phase 2) |
| LLMService | `Services/LLMService.swift` | Umbau auf Groq (Phase 2) |
| KeychainService | `Services/KeychainService.swift` | Key-Erweiterung (Phase 3) |
| SettingsContentView | `Features/Settings/SettingsContentView.swift` | Groq-UI (Phase 3) |
| AppState | `App/AppState.swift` | Provider-Config (Phase 2–3) |
| AudioRecorder | `Services/AudioRecorder.swift` | Wiederverwenden |
| HotkeyService | `Services/HotkeyService.swift` | Wiederverwenden |
| LocalTranscriptionService | `Services/LocalTranscriptionService.swift` | Erhalten |

---

## 4. OpenAI-Abhängigkeiten (zu ersetzen)

```
TranscriptionService.swift:32  → URL: https://api.openai.com/v1/audio/transcriptions
TranscriptionService.swift:49  → KeychainService.load(key: .openAIAPIKey)
TranscriptionService.swift:9   → "OpenAI API Key fehlt" (Fehlermeldung)
TranscriptionService.swift:18  → "OpenAI-Fehler:" (Fehlermeldung)
TranscriptionService.swift:23  → TranscriptionOpenAIErrorResponse (Typ)

LLMService.swift:60            → URL: https://api.openai.com/v1/chat/completions
LLMService.swift:26            → RewriteModel: gpt-4o-mini / gpt-4o (hardcoded)
LLMService.swift:116           → KeychainService.load(key: .openAIAPIKey)
LLMService.swift:11            → "OpenAI API Key fehlt" (Fehlermeldung)
LLMService.swift:15            → "Fehler von OpenAI:" (Fehlermeldung)

KeychainService.swift:5        → KeychainKey.openAIAPIKey
KeychainService.swift:18       → service = "app.blitztext.preview.credentials"

SettingsContentView.swift:59   → openAIAPIKeyPattern = ^sk-...
SettingsContentView.swift:69   → openAIAPIKey State-Var
SettingsContentView.swift:118  → SectionLabel "OpenAI API Key"
SettingsContentView.swift:145  → SecureField Placeholder "sk-..."
SettingsContentView.swift:157  → Info-Text "OpenAI API"

AppState.swift:111             → "Online: Whisper über OpenAI." (Subtitle)
```

---

## 5. Groq-Integration (Zielzustand)

Basis-URL: `https://api.groq.com/openai/v1`  
Auth: `Authorization: Bearer <GROQ_API_KEY>`

Request/Response-Strukturen sind OpenAI-kompatibel.  
Nur URL, Key-Quelle und Modellnamen ändern sich.

Empfohlene Groq-Modelle (Stand 2026-06):
- Transkription: `whisper-large-v3-turbo` (schnell), `whisper-large-v3` (genau)
- Chat: aktuell von Groq-Docs abhängig, zentral konfigurierbar halten

Details: `docs/API_PROVIDER_GROQ.md` (wird in Phase 2 erstellt).

---

## 6. Secret-Management

### macOS
- Keychain, Service-Name nach Umbenennung anpassen
- Key: `groqAPIKey` (statt `openAIAPIKey`)
- Kein Logging, kein Klartext in UI

### Windows
- Präferenz: Windows Credential Manager
- Fallback: lokale verschlüsselte Konfigurationsdatei
- API Key nie im Repo, nie in Logs

---

## 7. Build-Prozess (macOS)

Voraussetzungen: macOS 14+, Xcode 16+, XcodeGen  
Befehl: `./build.sh --run`  
Details: `docs/BUILD_MACOS.md` (wird in Phase 4 erstellt)

---

## 8. Lizenz

Originalprojekt: MIT License, © 2026 Blitztext contributors  
Diese Fork: MIT License — Lizenzhinweis bleibt erhalten.

---

## 9. Bekannte Risiken

| Risiko | Bewertung | Gegenmaßnahme |
|--------|-----------|---------------|
| Groq Audio-Format (m4a) | Mittel — Groq-Doku prüfen | In Phase 2 verifizieren |
| Groq Rate Limits | Mittel | Fehlermeldung implementieren |
| Windows Hotkey global | Hoch | Erst Clipboard, Hotkey als Bonus |
| Windows Auto-Paste instabil | Hoch | Nur Clipboard in MVP |
| WhisperKit Windows | Nicht anwendbar | Lokal nur macOS |
| Branding-Konflikt "Blitztext" | Mittel | App-Name prüfen, Lizenz erhalten |

---

## 10. Offene Entscheidungen

- [ ] Finaler App-Name (Phase 1)
- [ ] Windows-Technologie (Phase 5)
- [ ] OpenAI als Fallback behalten oder entfernen (Phase 2)
- [ ] GitHub-Repo-URL (Phase 10)
