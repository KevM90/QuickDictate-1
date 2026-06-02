# Groq API Provider

## Basis-URL

```
https://api.groq.com/openai/v1
```

## Auth-Header

```
Authorization: Bearer <GROQ_API_KEY>
```

Groq API Keys beginnen mit `gsk_`.

## Endpoints

### Speech-to-Text

```
POST https://api.groq.com/openai/v1/audio/transcriptions
Content-Type: multipart/form-data
Authorization: Bearer <GROQ_API_KEY>

Felder:
  file        — Audiodatei (m4a, mp3, wav, webm, mp4, mpeg, mpga)
  model       — z.B. "whisper-large-v3-turbo"
  response_format — "text" (plain text zurück)
  language    — optional, z.B. "de"
  prompt      — optional, Eigennamen/Begriffe als Kontexthilfe
```

### Chat Completions (Textverbesserung)

```
POST https://api.groq.com/openai/v1/chat/completions
Content-Type: application/json
Authorization: Bearer <GROQ_API_KEY>

Body (JSON):
{
  "model": "<modell>",
  "messages": [
    {"role": "system", "content": "<system-prompt>"},
    {"role": "user",   "content": "<text>"}
  ],
  "temperature": 0.3
}
```

## Unterstützte Modelle (Stand 2026-06)

### Transkription
| Modell | Charakteristik |
|--------|----------------|
| `whisper-large-v3-turbo` | Schnell, empfohlen als Default |
| `whisper-large-v3` | Genauer, langsamer |

### Chat / Rewriting
Modell ist in den App-Settings konfigurierbar.  
Default: aktuell von Groq-Docs ableiten — **nicht hartcodieren**.  
Empfehlung: `llama-3.3-70b-versatile` oder vergleichbar aktuelles Modell.  
Liste zentral in `GroqModelConfig.swift` pflegen.

## Kompatibilität mit bestehendem Code

Groq verwendet dieselben JSON-Strukturen wie OpenAI:
- `OpenAIChatRequest` → wiederverwendbar, nur URL ändert sich
- `OpenAIChatResponse` → wiederverwendbar
- Error-Response-Format: identisch

Multipart-Upload für Audio: identisch.

## Fehlerbehandlung

| HTTP Status | Bedeutung | Fehlermeldung (DE) |
|-------------|-----------|---------------------|
| 400 | Ungültige Anfrage | "Ungültige Anfrage an Groq." |
| 401 | Ungültiger API Key | "Groq API Key ungültig. Bitte prüfen." |
| 413 | Datei zu groß | "Audiodatei zu groß für Groq." |
| 429 | Rate Limit | "Groq Rate Limit erreicht. Kurz warten." |
| 503 | Service nicht erreichbar | "Groq ist gerade nicht erreichbar." |
| Netzwerkfehler | Keine Verbindung | "Netzwerkfehler. Verbindung prüfen." |

## API Key Validierung

Pattern für Groq Keys: `gsk_[A-Za-z0-9]{48,}`  
(Groq Keys sind deutlich länger als OpenAI-Keys.)

## API Key Test-Endpoint

Für den "Test"-Button in den Settings wird ein günstiger Request verwendet:

```
POST /chat/completions
{"model": "<chat-modell>", "messages": [{"role": "user", "content": "hi"}], "max_tokens": 1}
```

HTTP 200 → Key gültig.  
HTTP 401 → Key ungültig.
