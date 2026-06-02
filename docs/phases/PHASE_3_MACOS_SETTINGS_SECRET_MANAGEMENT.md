# Phase 3 — macOS Settings & Secret Management

**Status:** Abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

Settings-UI vollständig auf Groq umstellen, API-Testbutton einbauen, Groq-Modellwahl ergänzen, App-Name "Blitztext" in UI-Texten auf "QuickDictate" aktualisieren. Fork-Hinweis in README und LICENSE eintragen.

---

## Umsetzung

### Fork-Hinweis

- `README.md`: Projekttitel auf "QuickDictate" geändert, prominenter Fork-Hinweis mit Link zu `cmagnussen/blitztext-app` und MIT-Lizenzreferenz
- `LICENSE`: Originales Copyright erhalten, Fork-Copyright ergänzt

### SettingsContentView.swift — AccessSettingsView

| Vorher | Nachher |
|--------|---------|
| `SectionLabel("OpenAI API Key")` | `SectionLabel("Groq API Key")` |
| `SecureField("sk-...")` | `SecureField("gsk_...")` |
| Info-Text "an die OpenAI API" | "an die Groq API" |
| Fehlermeldungen "OpenAI API Key" | "Groq API Key" |
| Clipboard-Fehler "OpenAI Key" | "Groq API Key (erwartet: gsk_...)" |
| Accessibility-Text "Blitztext aktivieren" | "QuickDictate aktivieren" |
| Installations-/Cleanup-Texte "Blitztext" | "QuickDictate" |

**Neu:** API-Testbutton
- Erscheint nur wenn Key gespeichert und nicht im Edit-Modus
- Ruft `GroqLLMService.testConnection()` mit konfiguriertem Chat-Modell auf
- Zeigt grünen Erfolgstext oder roten Fehlertext
- States: `isTesting`, `testStatusText`, `testErrorText`

### SettingsContentView.swift — CustomizeSettingsView

**Neu:** Abschnitt "Groq Modelle" (über Lokalem Modus)
- Picker für `groqTranscriptionModel` → `GroqTranscriptionModel.allCases`
- Picker für `groqChatModel` → `GroqChatModel.allCases`
- Binden direkt an `appState.appSettings.groqTranscriptionModel/groqChatModel`
- Hinweis: sofortige Übernahme, kein Neustart nötig

### MenuBarView.swift

| Vorher | Nachher |
|--------|---------|
| "Blitztext nutzt gerade die OpenAI-Transkription." | "QuickDictate nutzt gerade die Groq-Transkription." |
| "Eigenen OpenAI API Key eintragen." | "Eigenen Groq API Key eintragen." |
| Onboarding: "OpenAI Key speichern" | "Groq Key speichern" |

### build.sh

- Hinweis am Ende: "OpenAI API Key" → "Groq API Key"

---

## Security & Anonymisierung

- Kein API Key in UI-Strings ✅
- `testConnection()` loggt keinen Key ✅
- Test-Fehlertext zeigt keine Key-Informationen ✅
- Fork-Hinweis enthält keine privaten Daten ✅

---

## Offene Punkte

- Build-Verifikation mit xcodegen (xcodegen auf diesem System nicht installiert)
- App-Bundle-Name, Bundle-ID, Info.plist → Phase 4
- `BlitztextInstallLocationService` sucht noch nach "Blitztext.app" → Phase 4
- `LaunchAtLoginService` Label noch "Blitztext automatisch starten" → Phase 4

---

## Definition of Done

- [x] Alle OpenAI-Strings aus Swift-UI entfernt
- [x] Groq API Key Section vollständig auf Groq umgestellt
- [x] API-Testbutton implementiert
- [x] Groq-Modellwahl-Picker in Settings
- [x] MenuBarView auf Groq/QuickDictate aktualisiert
- [x] Fork-Hinweis in README und LICENSE
- [x] Statischer Compile-Check sauber
- [x] Security-Check: kein Key in Code oder UI

---

## Commit

```
feat: update settings ui to groq, add api test button and model pickers

- Replace all OpenAI labels/text with Groq equivalents
- Add Groq API test button with live status feedback
- Add Groq transcription and chat model pickers in settings
- Update MenuBarView onboarding texts
- Update app name references Blitztext → QuickDictate in UI strings
- Add fork notice to README and LICENSE
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 3
- ✅ Keine API Keys in Code oder UI
- ✅ Fork-Hinweis korrekt (MIT erhalten)
- ✅ Security-Check durchgeführt
- ✅ Dokumentation aktualisiert
- ✅ Anonymisierungscheck: keine privaten Daten

---

## Nächste Phase

Phase 4: macOS Funktionalität & Build — Bundle-ID, App-Name in project.yml und build.sh, Ende-zu-Ende-Test, Build-Verifikation.  
Wartet auf Freigabe.
