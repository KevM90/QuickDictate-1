# Build — QuickDictate Windows Portable

## Voraussetzungen (Windows 11)

```powershell
# 1. Rust installieren (https://rustup.rs)
rustup update stable

# 2. Node.js installieren (https://nodejs.org) — v18+ empfohlen

# 3. WebView2 ist auf Windows 11 vorinstalliert. Prüfen:
#    Systemsteuerung → Apps → "Microsoft Edge WebView2 Runtime"

# 4. Visual C++ Build Tools (falls noch nicht vorhanden)
#    Im Rust-Installer enthalten, oder separat:
#    https://visualstudio.microsoft.com/visual-cpp-build-tools/
```

## Build-Schritte

```powershell
# Im Projektverzeichnis QuickDictateWindows/
cd QuickDictateWindows

# Dependencies installieren
npm install

# Icons generieren (einmalig, benötigt eine PNG-Quelldatei ≥ 512x512)
npx @tauri-apps/cli icon ../BlitztextMac/Resources/Assets.xcassets/AppIcon.appiconset/icon_512x512.png

# Development-Start (mit DevTools)
npm run dev

# Release Build
npm run build
```

## Build-Output

```
QuickDictateWindows/
  src-tauri/target/release/
    quickdictate-windows.exe       ← direkt lauffähig
  src-tauri/target/release/bundle/
    nsis/QuickDictate_1.0.0_x64-setup.exe   ← Installer
    app/QuickDictate.exe                     ← portable
```

## Portable Ordner erstellen

```powershell
# Manuell portable Struktur bauen:
$dest = "dist\windows-portable"
New-Item -ItemType Directory -Force -Path $dest
Copy-Item "src-tauri\target\release\quickdictate-windows.exe" "$dest\QuickDictate.exe"

# WebView2Loader.dll (falls nötig — auf Windows 11 oft nicht)
# Copy-Item "src-tauri\target\release\WebView2Loader.dll" $dest
```

## Erster Start

1. `QuickDictate.exe` starten
2. Tray-Icon erscheint in der Taskleiste (unten rechts)
3. Auf das Icon klicken → Fenster öffnet sich
4. Einstellungen öffnen → Groq API Key eintragen
5. Hotkey `Ctrl+Shift+Space` drücken → Aufnahme beginnt
6. Nochmal drücken → Aufnahme stoppt → Text erscheint in Zwischenablage

## Fehlerbehebung

| Problem | Lösung |
|---------|--------|
| App startet nicht | Visual C++ Redistributable installieren |
| WebView2 fehlt | https://developer.microsoft.com/microsoft-edge/webview2/ |
| Mikrofon wird nicht gefunden | Windows-Mikrofonzugriff erlauben (Datenschutz → Mikrofon) |
| Hotkey funktioniert nicht | App als Administrator starten (bei manchen Apps nötig) |
| Antivirus blockiert | Ausnahme hinzufügen — keine Malware, aber neue .exe |

## Bekannte Einschränkungen

- Kein Auto-Paste (bewusst nicht im MVP) — Text landet in Zwischenablage, manuell einfügen
- Keine lokale Transkription (WhisperKit ist macOS-only)
- Hotkey ist aktuell nicht in der UI konfigurierbar (Ctrl+Shift+Space, Code-Änderung nötig)
- Keine Code-Signierung — Windows SmartScreen kann beim ersten Start warnen
- WebView2 muss auf dem System vorhanden sein (auf Windows 11 standardmäßig vorhanden)
