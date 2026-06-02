# Phase 0 — Setup und Repository-Analyse

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

Ist-Zustand verstehen, Risiken identifizieren, Dokumentationsgrundlage legen. Keine Codeänderungen.

---

## Analyse

Analysierte Dateien:

- `README.md`, `LICENSE`, `.gitignore`, `build.sh`
- `BlitztextMac/project.yml`
- `BlitztextMac/App/AppState.swift`
- `BlitztextMac/Services/TranscriptionService.swift`
- `BlitztextMac/Services/LLMService.swift`
- `BlitztextMac/Services/KeychainService.swift`
- `BlitztextMac/Features/Settings/SettingsContentView.swift`
- `BlitztextMac/Features/Workflows/WorkflowProtocol.swift`
- `docs/privacy.md`, `ROADMAP.md`, `SECURITY.md`

---

## Ist-Architektur

Vollständig dokumentiert in `docs/ARCHITECTURE.md`.

**Kernpunkte:**
- Swift 5.10 / SwiftUI / macOS 14+
- XcodeGen + xcodebuild, universelles Binary
- OpenAI hardcodiert in genau 2 Services (TranscriptionService, LLMService)
- API Key im macOS Keychain, Key: `openAIAPIKey`, Service: `app.blitztext.preview.credentials`
- Settings-JSON in `~/Library/Application Support/Blitztext/`
- WhisperKit via `argmax-oss-swift` v0.18.0 für lokale Transkription
- Workflows: Transkription, Textverbesserung, Dampfablassen, EmojiText
- Paste via CGEvent (Cmd+V), benötigt Accessibility-Berechtigung

---

## Konzept

Dieser Phase hat kein Umsetzungskonzept — reine Analyse.

---

## Kritische Prüfung

**Potenzielle Probleme:**

1. `TranscriptionService` und `LLMService` sind statische `enum`s ohne Dependency Injection — erschwerter Austausch, aber noch überschaubar durch direkten Umbau.
2. `KeychainKey.openAIAPIKey` ist tief verdrahtet (AppState, Settings-View, Services) — alle Stellen müssen koordiniert umgestellt werden.
3. Groq unterstützt m4a-Audio — laut Groq-Docs unterstützt werden `mp3, mp4, mpeg, mpga, m4a, wav, webm` — ✅ kein Formatproblem.
4. `SettingsContentView` validiert API-Keys gegen `^sk-...`-Pattern (OpenAI-spezifisch) — muss auf Groq `gsk_...` umgestellt werden.
5. Keine Unit Tests vorhanden — muss bei Umbau manuell getestet werden.
6. `app.blitztext.preview.credentials` als Keychain-Service-Name enthält "blitztext" — bei Umbenennung prüfen.

**Lizenzrisiko:** Gering. MIT-Lizenz. Lizenzhinweis muss erhalten bleiben. Keine proprietären Assets erkannt.

**Datenschutzrisiko:** Gering. Kein eigener Backend-Server, Audio geht direkt zu API-Provider. Bei Groq gilt dasselbe Prinzip.

---

## Verbesserte Entscheidung

Provider-Abstraktion minimal halten: Keine übermäßige Abstraktion für einen Provider.  
Stattdessen: `GroqTranscriptionService` und `GroqLLMService` direkt als Ersatz.  
Wenn später ein zweiter Provider gebraucht wird, dann abstrahieren.

---

## Umsetzung

Keine Codeänderungen in Phase 0.

---

## Betroffene Dateien (neu erstellt)

- `docs/PHASE_OVERVIEW.md`
- `docs/ARCHITECTURE.md`
- `docs/TECHNICAL_DOCUMENTATION.md`
- `docs/phases/PHASE_0_SETUP_ANALYSIS.md` (diese Datei)

---

## Tests

Kein Build, keine Code-Tests. Dateien wurden gelesen und geprüft.

---

## Dokumentation

Erstellt: `docs/PHASE_OVERVIEW.md`, `docs/ARCHITECTURE.md`, `docs/TECHNICAL_DOCUMENTATION.md`.

---

## Security & Anonymisierung

- Kein API Key im Code gefunden (`grep -R "sk-" .` → kein Fund in Swift-Dateien)
- Kein `gsk_` im Code
- Keine E-Mail-Adressen im Swift-Code
- Keine privaten Pfade (`/Users/<name>`) im Swift-Code
- `.gitignore` deckt `.env`, `*.local`, `Secrets.swift` ab — ausreichend für Phase 0
- README enthält `https://www.blackboat.com/impressum` — bei Umbau prüfen ob entfernbar oder neutral zu halten

---

## Offene Punkte

- Finaler App-Name → Klärung vor Phase 1 oder Phase 1 als Entscheidungspunkt
- Windows-Technologie → Phase 5
- OpenAI als Fallback behalten? → Empfehlung: entfernen (einfacher, klarer)
- GitHub-Repo-URL → Phase 10

---

## Definition of Done

- [x] Ist-Architektur dokumentiert
- [x] Relevante Dateien identifiziert
- [x] OpenAI-Abhängigkeiten lokalisiert (8 Stellen in 3 Dateien + Settings-View + AppState)
- [x] Settings- und Secret-Speicherung beschrieben
- [x] Build-Prozess verstanden
- [x] Risiken dokumentiert
- [x] Keine Codeänderungen durchgeführt
- [x] Security-Check: sauber

---

## Commit

```
docs: add phase 0 repository analysis and architecture documentation
```

---

## Masterprompt-Compliance

- ✅ Phasenweise Umsetzung: nur Phase 0, keine weiteren Phasen vermischt
- ✅ Konzept vor Umsetzung: reine Analyse
- ✅ Technische Dokumentation erstellt
- ✅ Security- und Anonymisierungscheck durchgeführt
- ✅ Keine API Keys im Code
- ✅ Keine persönlichen Pfade
- ✅ Keine E-Mail-Adressen im Code
- ✅ Effiziente Token-Nutzung: nur relevante Dateien gelesen
- ✅ README-Update: nicht erforderlich in Phase 0
- ✅ Lizenzhinweise geprüft und als erhaltenswert markiert

---

## Nächste Phase

Phase 1: Architektur- und Umsetzungskonzept.  
Wartet auf Freigabe durch Nutzer.
