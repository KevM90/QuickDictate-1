# Setup — QuickDictate

## macOS Setup

### 1. Requirements

- macOS 14 or newer
- Full Xcode with Command Line Tools
- XcodeGen: `brew install xcodegen`
- A [Groq API key](https://console.groq.com) (free tier available)
- Optional: WhisperKit/CoreML model for local transcription

### 2. Clone And Build

```bash
git clone <your-repo-url>
cd <project-folder>
./build.sh --run
```

To install into `/Applications`:

```bash
./build.sh --install --run
```

### 3. Configure Groq API Key

Open **Settings → Zugang** and enter your Groq API key (`gsk_...`).

QuickDictate uses:
- `whisper-large-v3-turbo` for transcription (configurable)
- `llama-3.3-70b-versatile` for rewriting (configurable)

The key is stored in the macOS Keychain (`app.quickdictate.credentials`). Never commit it to the repo, paste it in issues, or include it in screenshots.

You can test the connection with the **API-Verbindung testen** button in Settings.

### 4. Optional Local Transcription

Choose a WhisperKit CoreML model in **Settings → Anpassen → Lokales Modell** and click **Installieren**. Models are stored in:

```text
~/Library/Application Support/QuickDictate/models/whisperkit/
```

After installation, enable **Sicherer Lokaler Modus** to use it. Rewriting workflows require Groq and are paused in local mode.

See [local-models.md](local-models.md) for model details.

### 5. macOS Permissions

- **Microphone**: required for recording.
- **Accessibility**: required for automatic paste (Cmd+V simulation). Without it, results are copied to the clipboard and can be pasted manually.

QuickDictate does not need Full Disk Access.

### macOS Troubleshooting

| Problem | Solution |
|---------|----------|
| `xcodebuild` reports wrong developer directory | `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer` |
| XcodeGen not found | `brew install xcodegen` |
| Groq API key error | Check key in Settings → test button |
| Paste doesn't work | Settings → Privacy & Security → Accessibility → enable QuickDictate → restart app |
| Multiple QuickDictate entries in Accessibility | Remove stale entries, relaunch from `/Applications`, re-grant permission |
| Audio is missing | Check Microphone permission and macOS input device settings |
| Local model not found | Check `~/Library/Application Support/QuickDictate/models/whisperkit/` |

---

## Windows Setup

### 1. Requirements

- Windows 11 (WebView2 pre-installed)
- [Rust](https://rustup.rs) stable
- [Node.js](https://nodejs.org) v18+
- A [Groq API key](https://console.groq.com)

### 2. Build

```powershell
cd QuickDictateWindows
npm install
npx @tauri-apps/cli icon ..\BlitztextMac\Resources\Assets.xcassets\AppIcon.appiconset\icon_512x512.png
npm run build
# or:
powershell -ExecutionPolicy Bypass -File build-windows.ps1 -Run
```

Full details: [BUILD_WINDOWS_PORTABLE.md](BUILD_WINDOWS_PORTABLE.md)

### 3. Configure Groq API Key

Open **Settings** from the tray icon context menu. Enter your Groq API key (`gsk_...`). It is stored in the Windows Credential Manager.

### Windows Troubleshooting

| Problem | Solution |
|---------|----------|
| App doesn't start | Install Visual C++ Redistributable |
| WebView2 missing | Download from Microsoft Edge WebView2 page |
| Microphone not found | Windows Settings → Privacy → Microphone → allow app |
| Hotkey not working | Run as Administrator (some apps block global hotkeys) |
| SmartScreen warning | Click "More info → Run anyway" — no malware, unsigned binary |
