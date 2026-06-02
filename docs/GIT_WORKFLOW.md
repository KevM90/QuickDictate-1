# Git Workflow — QuickDictate

## Remotes

| Remote | URL | Sichtbarkeit |
|--------|-----|--------------|
| `public` | https://github.com/<your-user>/QuickDictate-1 | Öffentlich (Fork) |
| `private` | https://github.com/<your-user>/QuickDictate | Privat |

> Die tatsächlichen Remote-URLs sind lokal im Git-Config gespeichert (`git remote -v`), nicht in dieser Datei.

## Parallel in beide Repos pushen

```bash
git push public main && git push private main
```

Oder als Shell-Alias (einmalig einrichten):

```bash
git config alias.pushall '!git push public main && git push private main'
# Danach einfach:
git push-all   # oder: git pushall
```

## Vor jedem Push — Pflichtcheck

```bash
# API Keys
grep -rn "gsk_[A-Za-z0-9]\{20,\}" . --include="*.swift" --include="*.md" --include="*.sh"

# Persönliche Pfade
grep -rn "/Users/[a-zA-Z]" . --include="*.swift" --include="*.md" --include="*.sh"

# E-Mail-Adressen
grep -rn "@gmail\|@googlemail\|@icloud" . --include="*.swift" --include="*.md"

# Privates / Firmen-Branding
grep -rn "blackboat\|blitztext\.de" . --include="*.md"

# Status
git status && git diff --cached --stat
```

## Commit-Vorlage

```bash
git -c user.name="QuickDictate" -c user.email="noreply@quickdictate" \
    commit -m "$(cat <<'EOF'
<typ>: <beschreibung>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"
```

Typen: `feat`, `fix`, `refactor`, `docs`, `security`, `test`

## Phasen-Branches (empfohlen)

```bash
git checkout -b feature/groq-provider
# ... arbeiten ...
git checkout main && git merge feature/groq-provider
git push public main && git push private main
```
