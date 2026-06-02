# Roadmap — QuickDictate

This is a preview roadmap, not a promise.

## Current Scope

- macOS menubar app (Swift/SwiftUI)
- Windows 11 portable app (Tauri 2 + Rust)
- Local recording and hotkeys on macOS
- Toggle-mode hotkey (`Ctrl+Shift+Space`) on Windows
- Groq API for online transcription and rewriting
- Optional local transcription via WhisperKit/CoreML (macOS only)
- No hosted backend — API calls go directly to Groq
- No packaged public release (build from source)

## Next Useful Work

- Verify and stabilize macOS build after QuickDictate rename (xcodegen build test)
- Verify and stabilize Windows build (first build on Windows 11)
- Add hotkey configuration per UI on Windows
- Add waveform/audio level visualization on Windows
- Add auto-paste on Windows (Ctrl+V simulation after clipboard write)
- Signed macOS release (Developer ID + notarization)
- Signed Windows release (Authenticode) to remove SmartScreen warning
- Configurable hotkey on macOS
- Model list kept up to date as Groq adds new models
- Automated test layer around Groq provider and text quality filters

## Not In Scope

- Production support
- Accounts, sync, teams, or hosted infrastructure
- App Store distribution
- Claims that the app is offline or privacy-complete
