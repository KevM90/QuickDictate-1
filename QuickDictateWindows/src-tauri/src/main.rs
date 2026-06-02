// Prevents a console window from opening on Windows in release builds.
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use std::sync::Mutex;
use tauri::{
    menu::{Menu, MenuItem},
    tray::{MouseButton, TrayIconBuilder, TrayIconEvent},
    AppHandle, Emitter, Manager, State,
};
use tauri_plugin_clipboard_manager::ClipboardExt;
use tauri_plugin_global_shortcut::{Code, GlobalShortcutExt, Modifiers, Shortcut, ShortcutState};

mod audio;
mod groq;
mod settings;

// ── App state ─────────────────────────────────────────────────────────────────

#[derive(Default)]
struct RecordingInner {
    is_recording: bool,
    recorder: Option<audio::Recorder>,
}

struct AppState(Mutex<RecordingInner>);

// ── Tauri commands ─────────────────────────────────────────────────────────────

#[tauri::command]
fn get_settings(app: AppHandle) -> settings::Settings {
    settings::load(&app)
}

#[tauri::command]
fn save_settings(app: AppHandle, s: settings::Settings) -> Result<(), String> {
    settings::save(&app, &s)
}

#[tauri::command]
fn save_api_key(key: String) -> Result<(), String> {
    let trimmed = key.trim().to_string();
    if trimmed.is_empty() {
        return Err("Bitte einen Groq API Key eingeben.".to_string());
    }
    settings::save_api_key(&trimmed)
}

#[tauri::command]
fn delete_api_key() -> Result<(), String> {
    settings::delete_api_key()
}

#[tauri::command]
fn has_api_key() -> bool {
    settings::has_api_key()
}

#[tauri::command]
fn api_key_display() -> String {
    settings::api_key_display()
}

#[tauri::command]
async fn test_connection(app: AppHandle) -> Result<(), String> {
    let api_key = settings::get_api_key()?;
    let model = settings::load(&app).chat_model;
    groq::test_connection(&api_key, &model).await
}

#[tauri::command]
async fn toggle_recording(app: AppHandle, state: State<'_, AppState>) -> Result<(), String> {
    let is_recording = {
        let inner = state.0.lock().map_err(|e| e.to_string())?;
        inner.is_recording
    };

    if is_recording {
        stop_and_transcribe_internal(app, state).await
    } else {
        start_recording_internal(app, state)
    }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

fn start_recording_internal(
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    if !settings::has_api_key() {
        app.emit("show-error", "Groq API Key fehlt. Bitte in den Einstellungen eintragen.").ok();
        open_settings_window(&app);
        return Ok(());
    }

    let recorder = audio::Recorder::new()?;
    recorder.start()?;

    {
        let mut inner = state.0.lock().map_err(|e| e.to_string())?;
        inner.recorder = Some(recorder);
        inner.is_recording = true;
    }

    app.emit("recording-started", ()).ok();
    Ok(())
}

async fn stop_and_transcribe_internal(
    app: AppHandle,
    state: State<'_, AppState>,
) -> Result<(), String> {
    let recorder = {
        let mut inner = state.0.lock().map_err(|e| e.to_string())?;
        inner.is_recording = false;
        inner.recorder.take()
    };

    let Some(recorder) = recorder else {
        return Ok(());
    };

    let duration = recorder.recording_duration_seconds();
    app.emit("recording-stopped", duration).ok();

    if duration < 0.4 {
        app.emit("show-error", "Keine Aufnahme erkannt.").ok();
        return Ok(());
    }

    let wav_path = recorder.stop_and_save()?;

    let api_key = settings::get_api_key().map_err(|e| {
        app.emit("show-error", &e).ok();
        e
    })?;

    let s = settings::load(&app);

    app.emit("status-update", "Wird transkribiert...").ok();

    let text = match groq::transcribe(
        &wav_path,
        &api_key,
        &s.transcription_model,
        Some(&s.language),
    )
    .await
    {
        Ok(t) => t,
        Err(e) => {
            let _ = std::fs::remove_file(&wav_path);
            app.emit("show-error", &e).ok();
            return Err(e);
        }
    };

    let _ = std::fs::remove_file(&wav_path);

    if text.trim().is_empty() {
        app.emit("show-error", "Keine Aufnahme erkannt.").ok();
        return Ok(());
    }

    let final_text = if s.improvement_enabled {
        app.emit("status-update", "Text wird verbessert...").ok();
        groq::improve_text(&text, &api_key, &s.chat_model)
            .await
            .unwrap_or(text)
    } else {
        text
    };

    // Copy to clipboard
    app.clipboard()
        .write_text(&final_text)
        .map_err(|e| format!("Clipboard-Fehler: {}", e))?;

    app.emit("transcription-result", &final_text).ok();
    Ok(())
}

fn toggle_main_window(app: &AppHandle) {
    if let Some(win) = app.get_webview_window("main") {
        if win.is_visible().unwrap_or(false) {
            win.hide().ok();
        } else {
            win.show().ok();
            win.set_focus().ok();
        }
    }
}

fn open_settings_window(app: &AppHandle) {
    if let Some(win) = app.get_webview_window("settings") {
        win.show().ok();
        win.set_focus().ok();
    }
}

// ── Main ──────────────────────────────────────────────────────────────────────

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_global_shortcut::Builder::new().build())
        .plugin(tauri_plugin_store::Builder::default().build())
        .plugin(tauri_plugin_clipboard_manager::init())
        .manage(AppState(Mutex::new(RecordingInner::default())))
        .invoke_handler(tauri::generate_handler![
            get_settings,
            save_settings,
            save_api_key,
            delete_api_key,
            has_api_key,
            api_key_display,
            test_connection,
            toggle_recording,
        ])
        .setup(|app| {
            // Tray icon + menu
            let quit_item =
                MenuItem::with_id(app, "quit", "QuickDictate beenden", true, None::<&str>)?;
            let settings_item =
                MenuItem::with_id(app, "settings", "Einstellungen", true, None::<&str>)?;
            let menu = Menu::with_items(app, &[&settings_item, &quit_item])?;

            TrayIconBuilder::new()
                .menu(&menu)
                .tooltip("QuickDictate")
                .on_menu_event(|app, event| match event.id.as_ref() {
                    "quit" => app.exit(0),
                    "settings" => open_settings_window(app),
                    _ => {}
                })
                .on_tray_icon_event(|tray, event| {
                    if let TrayIconEvent::Click {
                        button: MouseButton::Left,
                        ..
                    } = event
                    {
                        toggle_main_window(tray.app_handle());
                    }
                })
                .build(app)?;

            // Global hotkey (default: Ctrl+Shift+Space)
            let app_handle = app.handle().clone();
            let shortcut = Shortcut::new(
                Some(Modifiers::CONTROL | Modifiers::SHIFT),
                Code::Space,
            );

            app.global_shortcut().on_shortcut(shortcut, move |_app, _shortcut, event| {
                if event.state == ShortcutState::Pressed {
                    let handle = app_handle.clone();
                    tauri::async_runtime::spawn(async move {
                        if let Some(state) = handle.try_state::<AppState>() {
                            if let Err(e) = toggle_recording(handle.clone(), state).await {
                                handle.emit("show-error", e).ok();
                            }
                        }
                    });
                }
            })?;

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("QuickDictate konnte nicht gestartet werden");
}
