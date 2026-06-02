# Privacy — QuickDictate

QuickDictate has no hosted backend. All processing happens either on your device (local mode) or via the Groq API, which you access directly with your own key.

## What Goes Where

### macOS — Online Mode

When you use a transcription or rewriting workflow in online mode, your Mac sends data directly to Groq:

- **Transcription**: audio file → `api.groq.com/openai/v1/audio/transcriptions`
- **Rewriting**: transcribed text + system prompt → `api.groq.com/openai/v1/chat/completions`
- Custom terms and prompt context, if configured, are included in the request.

No data passes through any QuickDictate server.

### macOS — Secure Local Mode

When **Sicherer Lokaler Modus** is enabled and a WhisperKit/CoreML model is installed, transcription runs entirely on your Mac — no audio leaves your device. Rewriting workflows (Dictate+, Vent, Emojis) require Groq and are paused in local mode.

### Windows

All workflows use the Groq API directly. No local transcription is available on Windows.

## What Is Stored Locally

### macOS

| Data | Location |
|------|----------|
| Groq API key | macOS Keychain, service `app.quickdictate.credentials`, this device only |
| App settings | `~/Library/Application Support/QuickDictate/settings.json` |
| WhisperKit models (optional) | `~/Library/Application Support/QuickDictate/models/whisperkit/` |
| Audio files | System temp directory, deleted immediately after transcription |

### Windows

| Data | Location |
|------|----------|
| Groq API key | Windows Credential Manager, service `app.quickdictate` |
| App settings | `%APPDATA%\QuickDictate\settings.json` |
| Audio files | System temp directory, deleted after transcription |

## Clipboard

Workflow output is written to the clipboard so it can be pasted. On macOS, auto-paste marks the entry as concealed for compatible clipboard managers, but the text intentionally remains on the clipboard as a fallback. Clipboard managers and other apps may observe clipboard contents while present.

## Settings Files

Settings files (models, language, prompts) are stored as plain JSON. Do not put secrets into custom prompt or context fields.

## What Is Never Stored

- API key in any settings file, log, or source code
- Transcription results (clipboard only)
- Audio recordings beyond the active transcription

## Groq Data Handling

Audio and text sent to Groq is subject to [Groq's privacy policy](https://groq.com/privacy-policy/). Review it before using QuickDictate with sensitive, confidential, or regulated content.

## Network

The app uses the system TLS trust store for Groq and Hugging Face (model downloads). Certificate pinning is not implemented.

## No Telemetry

QuickDictate does not collect usage data, crash reports, or analytics.

## Sensitive Content

Do not use QuickDictate with confidential, regulated, or legally sensitive content unless you have reviewed the Groq privacy policy, the source code, and your own legal/privacy requirements.
