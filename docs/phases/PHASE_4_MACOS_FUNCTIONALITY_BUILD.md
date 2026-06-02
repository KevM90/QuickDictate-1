# Phase 4 — macOS Funktionalität & Build

**Status:** Teilweise abgeschlossen  
**Datum:** 2026-06-02

---

## Ziel

Bundle-ID, App-Name und alle Blitztext-Referenzen auf QuickDictate umstellen. Build verifizieren.

---

## Umsetzung

### Geänderte Dateien

| Datei | Änderung |
|-------|----------|
| `BlitztextMac/project.yml` | `bundleIdPrefix`, `PRODUCT_NAME`, `PRODUCT_BUNDLE_IDENTIFIER` → QuickDictate |
| `BlitztextMac/Resources/Info.plist` | `NSMicrophoneUsageDescription` → QuickDictate |
| `BlitztextMac/Services/AppSupportPaths.swift` | App-Support-Ordner `Blitztext` → `QuickDictate`, Fallback-Bundle-ID |
| `BlitztextMac/Services/BlitztextInstallLocationService.swift` | Fehlermeldungen → QuickDictate |
| `BlitztextMac/Services/LaunchAtLoginService.swift` | Alle Hilfetexte → QuickDictate |
| `BlitztextMac/Features/Settings/SettingsContentView.swift` | Launch-at-Login-Toggle-Label |
| `build.sh` | Kommentar, `APP_PATH`, `DEST`, Install-Pfad → QuickDictate |

### Nicht umbenannt (interne Klassen, kein Nutzer-Impact)

- `BlitztextMacApp` (Swift struct name)
- `BlitztextInstallLocationService` (interne Klasse)
- `BlitztextCleanupService` (interne Klasse)

---

## Build-Status

**xcodegen nicht installiert** — Build konnte nicht automatisch verifiziert werden.

Manuelle Verifikation: `brew install xcodegen && ./build.sh --run`

Erwartetes Ergebnis nach Build:
- App heißt `QuickDictate.app`
- Bundle-ID: `app.quickdictate.mac`
- App-Support-Ordner: `~/Library/Application Support/QuickDictate/`
- Keychain-Service: `app.quickdictate.credentials`
- Mikrofon-Dialog: "QuickDictate benötigt Mikrofon-Zugriff..."

---

## Security & Anonymisierung

- Kein API Key ✅
- Keine persönlichen Daten ✅
- `app.quickdictate` Bundle-Prefix neutral ✅

---

## Offene Punkte

- [ ] Build-Verifikation mit xcodegen (Nutzer: `brew install xcodegen && ./build.sh`)
- [ ] Ende-zu-Ende-Test mit echtem Groq API Key
- [ ] Groq-Transkription testen
- [ ] Testbutton in Settings testen

---

## Definition of Done

- [x] Bundle-ID auf `app.quickdictate.mac`
- [x] `PRODUCT_NAME` auf `QuickDictate`
- [x] App-Support-Verzeichnis auf `QuickDictate`
- [x] Alle User-facing Strings auf QuickDictate
- [x] build.sh auf `QuickDictate.app`
- [ ] Build erfolgreich (xcodegen fehlt)
- [ ] Ende-zu-Ende-Test

---

## Commit

```
feat: rename app to QuickDictate — bundle id, product name, ui strings
```

---

## Masterprompt-Compliance

- ✅ Phasenweise: nur Phase 4
- ✅ Keine API Keys
- ✅ Keine persönlichen Daten
- ✅ Security-Check sauber
- ✅ Beide Repos gepusht

---

## Nächste Phase

Phase 5: Windows Portable Architekturentscheidung.  
Wartet auf Freigabe.
