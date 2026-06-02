use serde::{Deserialize, Serialize};
use tauri::AppHandle;
use tauri_plugin_store::StoreExt;

const KEYRING_SERVICE: &str = "app.quickdictate";
const KEYRING_ACCOUNT: &str = "groq-api-key";
const STORE_PATH: &str = "settings.json";

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct Settings {
    pub transcription_model: String,
    pub chat_model: String,
    pub hotkey: String,
    pub hotkey_mode: String,
    pub language: String,
    pub improvement_enabled: bool,
}

impl Default for Settings {
    fn default() -> Self {
        Settings {
            transcription_model: "whisper-large-v3-turbo".to_string(),
            chat_model: "llama-3.3-70b-versatile".to_string(),
            hotkey: "Ctrl+Shift+Space".to_string(),
            hotkey_mode: "toggle".to_string(),
            language: "de".to_string(),
            improvement_enabled: false,
        }
    }
}

pub fn load(app: &AppHandle) -> Settings {
    app.store(STORE_PATH)
        .ok()
        .and_then(|store| store.get("settings"))
        .and_then(|v| serde_json::from_value(v).ok())
        .unwrap_or_default()
}

pub fn save(app: &AppHandle, settings: &Settings) -> Result<(), String> {
    let store = app.store(STORE_PATH).map_err(|e| e.to_string())?;
    store.set(
        "settings",
        serde_json::to_value(settings).map_err(|e| e.to_string())?,
    );
    store.save().map_err(|e| e.to_string())
}

// ── API key (Windows Credential Manager) ──────────────────────────────────────

pub fn get_api_key() -> Result<String, String> {
    keyring::Entry::new(KEYRING_SERVICE, KEYRING_ACCOUNT)
        .map_err(|e| e.to_string())?
        .get_password()
        .map_err(|_| "Kein Groq API Key gespeichert.".to_string())
}

pub fn save_api_key(key: &str) -> Result<(), String> {
    keyring::Entry::new(KEYRING_SERVICE, KEYRING_ACCOUNT)
        .map_err(|e| e.to_string())?
        .set_password(key)
        .map_err(|e| e.to_string())
}

pub fn delete_api_key() -> Result<(), String> {
    keyring::Entry::new(KEYRING_SERVICE, KEYRING_ACCOUNT)
        .map_err(|e| e.to_string())?
        .delete_credential()
        .map_err(|e| e.to_string())
}

pub fn has_api_key() -> bool {
    get_api_key().is_ok()
}

pub fn api_key_display() -> String {
    match get_api_key() {
        Ok(k) if k.len() > 8 => format!("{} ••••••••", &k[..4]),
        Ok(_) => "••••••••".to_string(),
        Err(_) => String::new(),
    }
}
