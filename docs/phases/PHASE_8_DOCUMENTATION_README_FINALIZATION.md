# Phase 8 — Dokumentation & README Finalisierung

**Status:** Abgeschlossen  
**Datum:** 2026-06-03

---

## Umsetzung

### README.md

| Abschnitt | Änderung |
|-----------|----------|
| Screenshots | Alte Blitztext-Screenshots entfernt, Hinweis auf ausstehende QuickDictate-Screenshots |
| Build And Run | Clone-URL anonymisiert, OpenAI → Groq, Abschnitt "macOS Build And Run" benannt |
| Permissions | macOS und Windows getrennt, QuickDictate statt Blitztext |
| Data Flow | OpenAI → Groq, Windows-Datenfluss ergänzt, API-Key-Speicherorte dokumentiert |
| Project Structure | Windows-Projekt ergänzt, "OpenAI calls" → "Groq API" |
| macOS/Windows Requirements | Bereits in Phase 7 angelegt, Groq-Link ergänzt |

### docs/privacy.md

Vollständig neu geschrieben:
- Getrennte Abschnitte für macOS Online, macOS Lokal, Windows
- Tabellen für lokale Datenspeicherung (macOS + Windows)
- Clipboard-Verhalten dokumentiert
- Groq-Datenschutz-Link
- Keine Telemetrie explizit dokumentiert

### docs/setup.md

Vollständig neu geschrieben:
- macOS und Windows als getrennte Abschnitte
- Groq API Key Setup statt OpenAI
- Troubleshooting-Tabellen für macOS und Windows
- Pfade auf `QuickDictate` aktualisiert

### ROADMAP.md

Neu geschrieben für QuickDictate:
- Aktueller Stand (macOS + Windows + Groq)
- Nächste Schritte (Builds, Hotkey-Config, Signierung)
- Klare "Not In Scope"-Grenzen

---

## Security & Anonymisierung

- Keine API Keys in Dokumentation ✅
- Clone-URL anonymisiert (`<your-repo-url>`) ✅
- Keine privaten Pfade ✅
- Keine E-Mail-Adressen ✅
- Einzige "OpenAI"-Erwähnung: Fork-Notice (bewusst) ✅

---

## Definition of Done

- [x] README vollständig für QuickDictate + Groq aktualisiert
- [x] docs/privacy.md für Groq + Windows neu geschrieben
- [x] docs/setup.md für Groq + Windows aktualisiert
- [x] ROADMAP.md für QuickDictate aktualisiert
- [x] Finaler Scan: keine OpenAI in User-Docs (außer Fork-Notice)
- [x] Keine API Keys, keine persönlichen Daten

---

## Commit

```
docs: finalize readme, privacy, setup and roadmap for quickdictate + groq
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 8
- ✅ README für Nutzer und Entwickler verständlich
- ✅ Alle Datenschutzpunkte dokumentiert
- ✅ Keine Secrets, keine persönlichen Daten
- ✅ Bekannte Einschränkungen ehrlich beschrieben

---

## Nächste Phase

Phase 9: Security-, Secret- & Anonymisierungscheck (vollständiger finaler Scan).
