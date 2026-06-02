# QuickDictate

> **Based on:** [blitztext-app](https://github.com/cmagnussen/blitztext-app) by cmagnussen — MIT License.
> QuickDictate is an independent fork that replaces the OpenAI backend with [Groq](https://groq.com) and adds a portable Windows 11 version.
> The original MIT license and copyright notice are preserved. See [LICENSE](LICENSE).

QuickDictate is a macOS menubar app (and portable Windows 11 app) for turning speech into text — powered by the Groq API.

It is intentionally small and unfinished. The goal is to make a real workflow visible and hackable: press a hotkey, speak, get text back, optionally rewrite it, and paste it into the app you were using.

This is a learning and experimentation project, not a polished product.

> Preview status: bring your own Groq API key, no hosted backend, no warranty, no support guarantee.

## What It Does

**macOS (menubar app):**
- **Dictate**: record speech and transcribe it via Groq Whisper.
- **Dictate+**: transcribe, then improve the text with Groq Chat.
- **Vent**: turn frustrated speech into a calmer message.
- **Emojis**: add fitting emojis to dictated text.

**Windows 11 (portable, system tray):**
- `Ctrl+Shift+Space` → record → text lands in clipboard.
- Optional text improvement via Groq Chat.
- Settings window: API key, model selection, language.

## Important Preview Notes

- Bring your own [Groq API key](https://console.groq.com) — free tier available.
- No hosted backend. Audio goes directly from your device to the Groq API.
- macOS: `./build.sh` creates an ad-hoc-signed app. No notarized binary.
- Windows: portable `.exe`, no installer required. WebView2 must be present (pre-installed on Windows 11).
- Not production ready. No warranty.

## Windows 11 — Quick Start

```powershell
cd QuickDictateWindows
npm install
# Generate icons (once):
npx @tauri-apps/cli icon ..\BlitztextMac\Resources\Assets.xcassets\AppIcon.appiconset\icon_512x512.png
npm run build
# Or use the build script:
powershell -ExecutionPolicy Bypass -File build-windows.ps1 -Run
```

See [docs/BUILD_WINDOWS_PORTABLE.md](docs/BUILD_WINDOWS_PORTABLE.md) for full instructions.

## macOS — Quick Start
- No warranty and no support guarantee.

You are welcome to use, fork, adapt, and share this project under the license terms.

The intent is not to ship a one-click finished app. The intent is to make a real AI workflow understandable: clone it, build it, read the code, change it, break it, fix it, and suggest improvements. If you only want to download something and never look inside, this preview will probably feel rough. If you want to learn how a small native macOS AI app is put together, you are in the right place.

## Screenshots

> Screenshots will be added after the first QuickDictate build is complete.
> The `docs/screenshots/` folder currently contains screenshots from the upstream blitztext-app for reference only.

## macOS Requirements

- macOS 14 or newer
- Xcode 16 or newer (Swift 5.10)
- [XcodeGen](https://github.com/yonaskolb/XcodeGen): `brew install xcodegen`
- A [Groq API key](https://console.groq.com) (free tier available)
- For local transcription: a WhisperKit CoreML model in `~/Library/Application Support/QuickDictate/models/whisperkit/`

Swift Package dependency (pulled automatically):
- [`argmax-oss-swift`](https://github.com/argmaxinc/argmax-oss-swift) (WhisperKit)

## Windows 11 Requirements

- Windows 11 (WebView2 pre-installed)
- [Rust](https://rustup.rs) stable
- [Node.js](https://nodejs.org) v18+
- A [Groq API key](https://console.groq.com)

## macOS Build And Run

```bash
git clone <your-private-repo-url>
cd <project-folder>
brew install xcodegen
./build.sh --run
```

For a local install into `/Applications`:

```bash
./build.sh --install --run
```

The generated `.app` is ad-hoc signed for local development only. Not notarized.

On first launch, enter your Groq API key in Settings → Zugang, or install a WhisperKit CoreML model for local transcription.

For fully local transcription, install a WhisperKit CoreML model and enable **Sicherer Lokaler Modus** in the app.

For a step-by-step walkthrough, see [docs/setup.md](docs/setup.md).

## macOS Permissions

QuickDictate asks for:

- **Microphone**: to record your voice.
- **Accessibility**: to paste the result back into the app you were using.

If you do not grant Accessibility permission, you can still copy results manually.

Full Disk Access is not required. If auto-paste does not work, open **System Settings → Privacy & Security → Accessibility**, enable QuickDictate, restart the app, and make sure the cursor is focused in a text field. If macOS shows multiple QuickDictate entries, remove stale ones and re-grant permission.

## Windows Permissions

Windows may ask for **Microphone** access on first launch — allow it in **Settings → Privacy & Security → Microphone**. Windows SmartScreen may warn on first run of an unsigned binary — click "More info → Run anyway".

## Data Flow

No custom backend. All API calls go directly from your device to Groq.

```text
macOS online transcription:  Your Mac   → Groq Audio Transcriptions API
macOS text rewriting:        Your Mac   → Groq Chat Completions API
macOS local transcription:   Your Mac   → WhisperKit/CoreML (on-device)
Windows transcription:       Your PC    → Groq Audio Transcriptions API
Windows text rewriting:      Your PC    → Groq Chat Completions API
```

API key storage:
- **macOS**: macOS Keychain (`app.quickdictate.credentials`)
- **Windows**: Windows Credential Manager (`app.quickdictate`)

Read [docs/privacy.md](docs/privacy.md) before using with sensitive content.

## Project Structure

```text
BlitztextMac/                   macOS app (Swift/SwiftUI)
  App/                          App lifecycle, paste handling
  Features/                     Workflows, menubar UI, settings
  Services/                     Recording, Groq API, hotkeys, keychain, local models
  Views/                        Shared SwiftUI views
QuickDictateWindows/            Windows portable app (Tauri 2 + Rust)
  src-tauri/src/                Rust backend: audio, groq, settings, main
  src/                          HTML/JS/CSS frontend
build.sh                        macOS build script
QuickDictateWindows/build-windows.ps1   Windows build script
docs/                           Architecture, API docs, phase docs, privacy
```

## Local Models

Local transcription is available as an experimental WhisperKit/CoreML path. The app does not bundle a model; choose one in the app, click install, and then switch on **Sicherer Lokaler Modus** from the menu bar or settings.

See [docs/local-models.md](docs/local-models.md).

## Contributing

Contributions are welcome, especially if they make the preview easier to build, understand, or fork.

Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## Support And Roadmap

This preview has no formal support promise. See [SUPPORT.md](SUPPORT.md) for how to ask for help without sharing secrets.

The current direction is documented in [ROADMAP.md](ROADMAP.md). Maintainer-facing release checks live in [docs/open-source-preflight.md](docs/open-source-preflight.md).

## License

Code is released under the MIT License. See [LICENSE](LICENSE).

Project names, logos, and app icons are not automatically granted as trademarks or brand assets. See [TRADEMARKS.md](TRADEMARKS.md).

## Legal

This is an experimental, non-commercial open-source project, provided as-is under the MIT License without warranty or support. Nothing is sold here and no installation or operation is performed on your behalf.
