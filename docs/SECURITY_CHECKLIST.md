# Security Checklist — QuickDictate

Letzte Prüfung: 2026-06-03 (Phase 9)

## API Keys & Tokens

| Prüfung | Ergebnis |
|---------|----------|
| `gsk_` (Groq Keys) im Code | ✅ Keine gefunden |
| `sk-` (OpenAI Keys) im Code | ✅ Keine gefunden |
| `GROQ_API_KEY=` hartcodiert | ✅ Keine gefunden |
| `github_pat_` / `ghp_` Tokens | ✅ Keine gefunden |
| Bearer-Token in Code (nicht via Keychain) | ✅ Keine gefunden |

## Persönliche Daten

| Prüfung | Ergebnis |
|---------|----------|
| E-Mail-Adressen in Code/Docs | ✅ Keine gefunden |
| Persönliche Pfade `/Users/<name>` | ✅ Keine gefunden |
| Windows-Pfade `C:\Users\<name>` | ✅ Keine gefunden |
| Privater Username in Code/Docs | ✅ Bereinigt (GIT_WORKFLOW.md → Platzhalter) |

## Secrets & Konfiguration

| Prüfung | Ergebnis |
|---------|----------|
| `.env`-Dateien im Repo | ✅ Keine (in .gitignore) |
| `Secrets.swift` im Repo | ✅ Keine (in .gitignore) |
| `*.key`, `*.pem` im Repo | ✅ Keine gefunden |
| Keychain-Service-Name neutral | ✅ `app.quickdictate.credentials` |
| Windows Credential Manager Eintrag neutral | ✅ `app.quickdictate` |

## Drittanbieter-Branding

| Prüfung | Ergebnis |
|---------|----------|
| `blackboat.com` in Code/Docs | ✅ Entfernt (Phase 3) |
| `blitztext.de` in Code/Docs | ✅ Entfernt |
| OpenAI in User-Facing Docs | ✅ Nur in Fork-Notice (bewusst) |

## Git History

| Prüfung | Ergebnis |
|---------|----------|
| Commit-Autor-E-Mail | ✅ `noreply@quickdictate` |
| Commit-Autor-Name | ✅ `QuickDictate` |
| Secrets in Commit-History | ✅ Keine (frisch initialisiertes Repo) |

## Build-Artefakte

| Prüfung | Ergebnis |
|---------|----------|
| `.app`-Bundle im Repo | ✅ In .gitignore |
| `.exe` im Repo | ✅ In .gitignore |
| `dist/` im Repo | ✅ In .gitignore |
| `node_modules/` im Repo | ✅ In .gitignore |
| `target/` (Rust) im Repo | ✅ In .gitignore |

## CI/GitHub Actions

| Prüfung | Ergebnis |
|---------|----------|
| Repository-Secrets in Workflows | ✅ Keine verwendet |
| Workflow-Permissions | ✅ `contents: read` (minimal) |
| Secret-Scan in CI | ✅ `.github/workflows/ci.yml` aktiv |
| `gsk_` in Secret-Scan-Patterns | ✅ Ergänzt (Phase 7) |

## Freigabe-Status

**Push-Freigabe: ✅ ERTEILT**

Keine kritischen Findings. Alle bekannten Findings sind dokumentiert und bewertet.
