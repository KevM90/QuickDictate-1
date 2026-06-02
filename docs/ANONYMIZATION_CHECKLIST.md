# Anonymization Checklist — QuickDictate

Letzte Prüfung: 2026-06-03 (Phase 9)

## Ziel

Sicherstellen, dass keine persönlichen, privaten oder identifizierenden Daten im Repository landen.

## Identifizierende Informationen

| Element | Status | Details |
|---------|--------|---------|
| E-Mail-Adressen | ✅ Keine | Commit-E-Mail: `noreply@quickdictate` |
| Privater GitHub-Username in Docs | ✅ Bereinigt | `GIT_WORKFLOW.md` → `<your-user>` |
| Privater GitHub-Username in Code | ✅ Nicht vorhanden | |
| Bürgerlicher Name | ✅ Nicht vorhanden | |
| Lokale Pfade (`/Users/<name>`) | ✅ Nicht vorhanden | |
| Windows-Pfade (`C:\Users\<name>`) | ✅ Nicht vorhanden | |

## App-Identitäten

| Element | Wert | Status |
|---------|------|--------|
| Bundle-ID macOS | `app.quickdictate.mac` | ✅ Neutral |
| Bundle-ID Windows | `app.quickdictate.windows` | ✅ Neutral |
| Keychain-Service macOS | `app.quickdictate.credentials` | ✅ Neutral |
| Windows Credential Manager | `app.quickdictate` | ✅ Neutral |
| App-Support-Pfad | `QuickDictate/` | ✅ Neutral |
| Commit-Autor | `QuickDictate <noreply@quickdictate>` | ✅ Anonym |

## Drittanbieter-Referenzen

| Element | Status |
|---------|--------|
| Originalprojekt-Link in README | ✅ Bewusst: Fork-Hinweis mit MIT-Pflicht |
| Originales Copyright in LICENSE | ✅ Bewusst erhalten (MIT erfordert es) |
| Blackboat/blitztext.de Impressum | ✅ Entfernt (Phase 3) |
| OpenAI-Verweise in User-Docs | ✅ Nur in Fork-Notice |

## README-Platzhalter

Folgende Platzhalter werden in der README genutzt:

| Platzhalter | Bedeutung |
|-------------|-----------|
| `<your-repo-url>` | Private oder öffentliche Repo-URL |
| `<project-folder>` | Lokaler Ordnername |
| `<your-user>` | GitHub-Benutzername |

## Screenshots

| Element | Status |
|---------|--------|
| Original-Screenshots | In `docs/screenshots/` vorhanden (historisch) |
| Persönliche Daten in Screenshots | Keine (Originalscreenshots zeigen keine) |
| Screenshots im README referenziert | ✅ Entfernt, Hinweis hinzugefügt |

## Freigabe-Status

**Anonymisierungs-Freigabe: ✅ ERTEILT**

Das Repository enthält keine identifizierenden persönlichen Daten.  
GitHub-Handle `KevM90` ist ausschließlich in der lokalen Git-Config (remote URLs) und nicht mehr in Dokumentationsdateien.
