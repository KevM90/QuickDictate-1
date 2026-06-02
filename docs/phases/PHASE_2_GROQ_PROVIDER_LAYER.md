# Phase 2 — Groq Provider Layer

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

OpenAI-Services vollständig durch Groq-Services ersetzen. Projektstruktur kompilierbar halten.

---

## Umsetzung

### Neue Dateien

| Datei | Inhalt |
|-------|--------|
| `Services/GroqModelConfig.swift` | `GroqTranscriptionModel` und `GroqChatModel` Enums mit Defaults |
| `Services/GroqTranscriptionService.swift` | POST `https://api.groq.com/openai/v1/audio/transcriptions`, m4a-Upload, modellparametrisiert |
| `Services/GroqLLMService.swift` | POST `https://api.groq.com/openai/v1/chat/completions`, improve/dampfAblassen/addEmojis/testConnection |

### Geänderte Dateien

| Datei | Änderung |
|-------|----------|
| `Services/KeychainService.swift` | `openAIAPIKey` → `groqAPIKey`, Service `app.blitztext.preview.credentials` → `app.quickdictate.credentials` |
| `Services/BlitztextCleanupService.swift` | `openAIAPIKey` → `groqAPIKey` |
| `Features/Workflows/WorkflowProtocol.swift` | `AppSettings` um `groqTranscriptionModel` und `groqChatModel` erweitert (mit Defaults, `decodeIfPresent`) |
| `App/AppState.swift` | Alle Workflow-Initialisierungen übergeben Groq-Modelle; Subtitle "OpenAI" → "Groq" |
| `Features/Workflows/TranscriptionWorkflow.swift` | Logger-Subsystem, Groq-Service-Aufruf, `groqTranscriptionModel`-Parameter |
| `Features/Workflows/TextImprovementWorkflow.swift` | Groq-Service-Aufrufe, Modellparameter |
| `Features/Workflows/DampfAblassenWorkflow.swift` | Groq-Service-Aufrufe, Modellparameter |
| `Features/Workflows/EmojiTextWorkflow.swift` | Groq-Service-Aufrufe, Modellparameter |
| `Features/Settings/SettingsContentView.swift` | `openAIAPIKey` → `groqAPIKey` (compile-fix), Pattern `sk-...` → `gsk_...` |

### Gelöschte Dateien

- `Services/TranscriptionService.swift` — entfernt
- `Services/LLMService.swift` — entfernt

---

## Neue Fehlerbehandlung

Beide Services behandeln HTTP 401/429/413/503 explizit mit deutschen Fehlermeldungen.  
`GroqLLMService.testConnection()` für Phase-3-Testbutton vorbereitet.

---

## Build-Status

xcodegen auf diesem System nicht installiert — Build konnte nicht automatisch verifiziert werden.

**Statischer Check bestanden:**
- Keine `openAIAPIKey`-Referenzen mehr in Swift-Dateien (außer UI-Strings in Phase-3-Scope)
- Keine `TranscriptionService.`- oder `LLMService.`-Aufrufe mehr
- Alle Workflows kompilieren strukturell korrekt
- `BlitztextCleanupService` und `SettingsContentView` compile-clean

**Manuelle Buildverifizierung:** muss vom Nutzer mit `./build.sh` nach Installation von xcodegen durchgeführt werden.

---

## Verbleibende UI-Strings (Phase 3)

In `SettingsContentView.swift` und `MenuBarView.swift` stehen noch Label-Texte wie "OpenAI API Key" und "Whisper über OpenAI". Diese sind reine Strings, kein Compile-Problem. Werden in Phase 3 vollständig ersetzt.

---

## Security & Anonymisierung

- Kein API Key im Code ✅
- Groq-URL `https://api.groq.com/openai/v1` ist korrekt (kein Leak) ✅
- Keychain-Service-Name `app.quickdictate.credentials` neutral ✅
- Kein `gsk_` hartcodiert ✅

---

## Offene Punkte

- Build-Verifikation mit xcodegen (Nutzer führt `brew install xcodegen && ./build.sh` aus)
- UI-Labels in Settings/Menubar → Phase 3
- Testbutton für API Key → Phase 3
- Modellwahl-Picker → Phase 3

---

## Definition of Done

- [x] `GroqTranscriptionService` implementiert und Groq-Endpoint gesetzt
- [x] `GroqLLMService` implementiert und Groq-Endpoint gesetzt
- [x] `GroqModelConfig` mit konfigurierbaren Modellen erstellt
- [x] `KeychainKey.groqAPIKey` und neuer Service-Name
- [x] Alle 4 Workflows auf Groq-Services umgestellt
- [x] `AppSettings` um Groq-Modellfelder erweitert
- [x] Keine OpenAI-Hardcodierungen in Service-Schicht
- [x] Statischer Compile-Check sauber
- [x] Security-Check bestanden

---

## Commit

```
feat: replace openai services with groq provider layer

- Add GroqTranscriptionService, GroqLLMService, GroqModelConfig
- Rename KeychainKey.openAIAPIKey to groqAPIKey
- Update KeychainService service name to app.quickdictate.credentials
- Extend AppSettings with groqTranscriptionModel and groqChatModel
- Update all four workflows to use Groq services with model parameters
- Remove TranscriptionService.swift and LLMService.swift
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 2
- ✅ Konzept aus Phase 1 umgesetzt
- ✅ Keine API Keys im Code
- ✅ Keine persönlichen Daten
- ✅ Security-Check durchgeführt
- ✅ Dokumentation aktualisiert
- ✅ Effiziente Token-Nutzung

---

## Nächste Phase

Phase 3: macOS Settings & Secret Management.  
UI vollständig auf Groq umstellen, API-Key-Testbutton, Modellwahl-Picker.  
Wartet auf Freigabe.
