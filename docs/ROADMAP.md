# Roadmap — QuickDictate

Basis: Blitztext-App (MIT), umgebaut auf Groq API mit macOS + Windows Portable.

## Phase 0 ✅ — Repository-Analyse
Ist-Zustand verstanden, Risiken dokumentiert, Architektur aufgezeichnet.

## Phase 1 ✅ — Architektur- & Umsetzungskonzept
App-Name: **QuickDictate**. Provider-Konzept, Umbau-Strategie, Windows-Voranalyse.

## Phase 2 — Groq Provider Layer
- `GroqTranscriptionService` ersetzt `TranscriptionService`
- `GroqLLMService` ersetzt `LLMService`
- `GroqModelConfig` für zentrale Modellkonfiguration
- `KeychainKey.groqAPIKey` ersetzt `openAIAPIKey`
- Fehlerbehandlung verbessert

## Phase 3 — macOS Settings & Secret Management
- Settings-UI auf Groq umgestellt
- API Key Test-Button
- Modellwahl für Transkription und Chat
- Keychain-Service-Name auf QuickDictate angepasst

## Phase 4 — macOS Funktionalität & Build
- Ende-zu-Ende mit Groq lauffähig
- Build-Prozess geprüft
- App-Name / Bundle-ID auf QuickDictate geändert

## Phase 5 — Windows Portable Architekturentscheidung
- Tauri vs. Electron vs. weitere Optionen
- Entscheidungsmatrix
- Windows-MVP-Scope definiert

## Phase 6 — Windows Portable MVP
- Portable App für Windows 11
- Groq API Anbindung
- Mikrofon + Clipboard

## Phase 7 — Windows Packaging & Qualität
- Reproduzierbarer portable Build
- README Windows-Abschnitt

## Phase 8 — Dokumentation & README Finalisierung

## Phase 9 — Security-, Secret- & Anonymisierungscheck

## Phase 10 — Privates GitHub-Repository & Push

---

## Bekannte Einschränkungen (geplant ehrlich dokumentiert)

- Kein notarisiertes macOS Binary (ad-hoc-signiert, nur für eigenen Rechner)
- Windows: kein Auto-Paste in MVP (nur Clipboard)
- Lokale Transkription nur macOS (WhisperKit)
- Kein Update-Mechanismus (manuell neu bauen)
