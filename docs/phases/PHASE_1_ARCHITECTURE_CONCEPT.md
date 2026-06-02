# Phase 1 — Architektur- & Umsetzungskonzept

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

Zielarchitektur definieren. Groq-Provider-Konzept erstellen. macOS-Umbau-Strategie festlegen. Windows-Technologie voranalysen. Kein Code.

---

## Analyse

Erkenntnisse aus Phase 0 als Grundlage. Keine weiteren Dateien gelesen.

---

## Konzept

### App-Name: QuickDictate

**Entschieden durch Nutzer.**

Konsequenzen:
- Bundle ID: `app.quickdictate.mac`
- Keychain Service: `app.quickdictate.credentials`
- App-Binary: `QuickDictate.app`
- `PRODUCT_NAME` in `project.yml`: `QuickDictate`
- Alle "Blitztext"-Bezeichnungen in UI und Code bleiben als Workflow-Namen erhalten (Blitztext, Blitztext+, etc.) — das ist Funktionsname, nicht App-Name. Oder werden umbenannt — Entscheidung: **UI-Workflow-Namen bleiben auf Deutsch / neutral**, z.B. "Diktat", "Diktat+", "Entspannen", "Emojis". Empfehlung: in Phase 3/4 entscheiden, minimal invasiv.

### OpenAI-Fallback

**Entscheidung:** OpenAI vollständig entfernen. Kein Fallback.  
Begründung: Einfacherer Code, kein Risiko alter Keys oder doppelter Konfiguration.

### macOS Umbau-Strategie

**Minimale Abstraktion.** Kein großes Provider-Interface für einen Provider.

Konkrete Umsetzung:

```
Services/
  GroqTranscriptionService.swift   ← ersetzt TranscriptionService.swift
  GroqLLMService.swift             ← ersetzt LLMService.swift
  GroqModelConfig.swift            ← neue Datei, zentrale Modellkonfiguration
  KeychainService.swift            ← KeychainKey.groqAPIKey (angepasst)
```

`TranscriptionService.swift` und `LLMService.swift` werden **ersetzt**, nicht erweitert.  
Referenzen in Workflows und AppState werden direkt umgeschrieben.

### Modellkonfiguration

```swift
// GroqModelConfig.swift
enum GroqTranscriptionModel: String, CaseIterable {
    case turbo = "whisper-large-v3-turbo"   // Default
    case large = "whisper-large-v3"
}

enum GroqChatModel: String, CaseIterable {
    case versatile = "llama-3.3-70b-versatile"   // Default — bei Phase 2 prüfen
    // weitere Modelle nach aktueller Groq-Dokumentation
}
```

Die Modellwahl wird in `AppSettings` gespeichert (zwei neue Felder).  
Default-Werte in `GroqModelConfig`, nicht hardcodiert in Services.

### Keychain-Änderungen

```swift
enum KeychainKey: String {
    case groqAPIKey = "groqAPIKey"     // NEU
    // openAIAPIKey entfernt
}
// Service-Name: "app.quickdictate.credentials"
```

### Settings-UI-Änderungen

- Label "OpenAI API Key" → "Groq API Key"
- Placeholder `sk-...` → `gsk_...`
- Validierungs-Pattern: `^gsk_[A-Za-z0-9]{40,}$`
- Info-Text angepasst
- Neuer Button: "API-Verbindung testen"
- Zwei neue Picker: Transkriptionsmodell, Chat-Modell

### Datenfluss (Ziel, macOS)

```
Hotkey/Menubar → AppState.startWorkflow()
  → AudioRecorder (AVFoundation, .m4a)
  → GroqTranscriptionService.transcribe()
      → POST https://api.groq.com/openai/v1/audio/transcriptions
      → Bearer groqAPIKey (aus Keychain)
  → [optional] GroqLLMService.complete()
      → POST https://api.groq.com/openai/v1/chat/completions
  → AppState.handleWorkflowOutput()
  → Clipboard + Cmd+V → Ziel-App
```

### Fehlerbehandlung (Erweiterung)

Neue Fehlercases für Groq-spezifische Situationen:
- `.invalidAPIKey` (HTTP 401)
- `.rateLimitExceeded` (HTTP 429)
- `.fileTooLarge` (HTTP 413)
- `.serviceUnavailable` (HTTP 503)

---

## Kritische Prüfung

**Risiken:**

1. **Groq Chat-Modell:** `llama-3.3-70b-versatile` ist Stand 2026-06 verfügbar — muss bei Phase 2 gegen aktuelle Groq-Docs verifiziert werden. Modell ist konfigurierbar, kein Showstopper.

2. **Workflow-UI-Namen (Blitztext, Blitztext+):** Enthalten "Blitztext" als funktionalen Namen — kein Branding-Risiko (MIT), aber Kohärenz mit App-Name "QuickDictate" prüfen. Vorschlag: in Phase 4 minimal umbenennen oder weglassen — nicht in Phase 2 blockieren.

3. **`AppSettings`-Migration:** Neue Felder `groqTranscriptionModel` und `groqChatModel` sind optional codiert (`decodeIfPresent`), Defaults greifen automatisch — kein Migrationsproblem.

4. **WhisperKit-Abhängigkeit bleibt:** `argmax-oss-swift` wird weiter gebraucht. Kein Risiko.

5. **Bundle-ID-Änderung:** Wenn App bereits installiert war, kann alte Keychain-Eintrag mit altem Service-Name verwaist bleiben. Cleanup-Service prüft das bereits — wird in Phase 3 berücksichtigt.

---

## Verbesserte Entscheidung

Umbau in dieser Reihenfolge in Phase 2:
1. `GroqModelConfig.swift` erstellen (neue Datei)
2. `KeychainService.swift` anpassen (Key umbenennen)
3. `GroqTranscriptionService.swift` erstellen, alte Datei entfernen
4. `GroqLLMService.swift` erstellen, alte Datei entfernen
5. `AppState.swift` anpassen (neue Settings-Felder, neue Service-Namen)
6. `WorkflowProtocol.swift` anpassen (neue AppSettings-Felder)
7. Workflows anpassen (Service-Aufrufe)

---

## Windows-Technologie — Voranalyse

### Vergleich

| Kriterium | Tauri | Electron | .NET/WinUI | Python/PySide |
|-----------|-------|----------|------------|---------------|
| Bundle-Größe | ~5–15 MB ✅ | ~80–120 MB ❌ | ~30–60 MB | ~50–100 MB |
| Portabilität | ✅ gut | ✅ gut | prüfen | ✅ gut |
| Mikrofon-API | ✅ via Rust/JS | ✅ Node.js | ✅ nativ | ✅ PyAudio |
| Globaler Hotkey | Tauri-Plugin | Electron | nativ | pynput |
| Clipboard | ✅ | ✅ | ✅ | ✅ |
| Antivirus-FP | selten | selten | selten | häufig ❌ |
| Entwicklungsaufwand | mittel | gering | mittel | gering |
| Community/Libs | ✅ aktiv | ✅ sehr aktiv | solide | solide |
| macOS-Code-Sharing | nein (Rust≠Swift) | JS teilbar | nein | nein |

### Empfehlung

**Tauri** für Phase 6 MVP.  
Begründung: Kleinstes Bundle, portabel, moderne Architektur, kein Antivirus-Problem.  
Mikrofon-Aufnahme via Rust (`cpal`) oder Web API (`getUserMedia`).  
Groq-HTTP-Calls via Rust (`reqwest`) oder JS (`fetch`).  
Endentscheidung in Phase 5 nach Detailprüfung.

---

## Umbenennung — Betroffene Stellen (Vollständig)

### project.yml
- `PRODUCT_NAME`: `Blitztext` → `QuickDictate`
- `PRODUCT_BUNDLE_IDENTIFIER`: `app.blitztext.mac` → `app.quickdictate.mac`

### build.sh
- Kommentare: "Blitztext" → "QuickDictate"
- `APP_PATH`: `Blitztext.app` → `QuickDictate.app`
- `DEST`: `Blitztext.app` → `QuickDictate.app`
- Hilfsmeldung: "OpenAI API Key" → "Groq API Key"

### KeychainService.swift
- `service`: `"app.blitztext.preview.credentials"` → `"app.quickdictate.credentials"`
- `KeychainKey.openAIAPIKey` → `KeychainKey.groqAPIKey`

### TranscriptionService → GroqTranscriptionService
- Neue Datei, alte entfernt

### LLMService → GroqLLMService
- Neue Datei, alte entfernt

### AppState.swift
- Subtitle: "Online: Whisper über OpenAI." → "Online: Whisper über Groq."
- `isConfigured` prüft `groqAPIKey`
- Neue Settings-Felder

### SettingsContentView.swift
- Section-Labels, Placeholder, Validierung, Info-Text

### WorkflowProtocol.swift
- `AppSettings` erhält neue Felder

### Info.plist, Resources
- App-Name prüfen (ggf. manuell im Bundle-Infoplist-Key)

### README.md
- Vollständig neu schreiben (Phase 8)

### docs/
- Vorhandene Blitztext-Referenzen schrittweise ersetzen

---

## Betroffene Dateien

Neu erstellt:
- `docs/API_PROVIDER_GROQ.md`
- `docs/ROADMAP.md` (ersetzt ROADMAP.md im Root)
- `docs/phases/PHASE_1_ARCHITECTURE_CONCEPT.md` (diese Datei)

Aktualisiert:
- `docs/PHASE_OVERVIEW.md`
- `docs/ARCHITECTURE.md`

---

## Tests

Kein Code, keine Tests in Phase 1.

---

## Security & Anonymisierung

- App-Name-Entscheidung "QuickDictate" enthält keine persönlichen Daten ✅
- Keychain-Service `app.quickdictate.credentials` ist neutral ✅
- Bundle-ID `app.quickdictate.mac` ist neutral ✅

---

## Offene Punkte

- Workflow-UI-Namen (Blitztext, Blitztext+) → Umbenennung in Phase 4 optional
- Groq Chat-Modell-Default → bei Phase 2 gegen aktuelle Groq-Docs verifizieren
- Windows-Technologie → Phase 5 (Tauri favorisiert)

---

## Definition of Done

- [x] App-Name definiert: QuickDictate
- [x] Provider-Architektur beschrieben (minimal, kein Over-Engineering)
- [x] Groq-Integration technisch geplant
- [x] Alle zu ändernden Stellen identifiziert
- [x] Windows-Technologie voranalysiert (Tauri favorisiert)
- [x] MVP-Scope klar (macOS Phase 2–4, Windows Phase 5–7)
- [x] Risiken dokumentiert
- [x] Keine Implementierung ohne Konzept

---

## Commit

```
docs: add phase 1 architecture concept, groq api docs, roadmap
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 1, kein Code
- ✅ Konzept vor Umsetzung: vollständiges Konzept liegt vor
- ✅ Kritische Prüfung durchgeführt
- ✅ Keine API Keys
- ✅ Keine persönlichen Daten
- ✅ Technische Dokumentation aktualisiert
- ✅ Token-effizient: keine Dateien nochmals gelesen

---

## Nächste Phase

Phase 2: Groq Provider Layer.  
Wartet auf Freigabe durch Nutzer.
