use std::path::Path;

const TRANSCRIPTION_URL: &str = "https://api.groq.com/openai/v1/audio/transcriptions";
const CHAT_URL: &str = "https://api.groq.com/openai/v1/chat/completions";

fn groq_error(status: u16, body: &str) -> String {
    match status {
        401 => "Groq API Key ungültig. Bitte prüfen.".to_string(),
        413 => "Audiodatei zu groß für Groq.".to_string(),
        429 => "Groq Rate Limit erreicht. Kurz warten und erneut versuchen.".to_string(),
        503 => "Groq ist gerade nicht erreichbar. Bitte erneut versuchen.".to_string(),
        _ => {
            // Try to extract message from JSON body
            if let Ok(v) = serde_json::from_str::<serde_json::Value>(body) {
                if let Some(msg) = v["error"]["message"].as_str() {
                    return format!("Groq-Fehler: {}", msg);
                }
            }
            format!("Groq-Fehler (HTTP {})", status)
        }
    }
}

pub async fn transcribe(
    audio_path: &Path,
    api_key: &str,
    model: &str,
    language: Option<&str>,
) -> Result<String, String> {
    let bytes = tokio::fs::read(audio_path)
        .await
        .map_err(|e| format!("Audiodatei konnte nicht gelesen werden: {}", e))?;

    let file_part = reqwest::multipart::Part::bytes(bytes)
        .file_name("audio.wav")
        .mime_str("audio/wav")
        .map_err(|e| e.to_string())?;

    let mut form = reqwest::multipart::Form::new()
        .part("file", file_part)
        .text("model", model.to_string())
        .text("response_format", "text");

    if let Some(lang) = language {
        let lang = lang.trim();
        if !lang.is_empty() {
            form = form.text("language", lang.to_string());
        }
    }

    let client = reqwest::Client::new();
    let response = client
        .post(TRANSCRIPTION_URL)
        .header("Authorization", format!("Bearer {}", api_key))
        .multipart(form)
        .send()
        .await
        .map_err(|e| format!("Netzwerkfehler: {}", e))?;

    let status = response.status().as_u16();
    let body = response.text().await.unwrap_or_default();

    if status != 200 {
        return Err(groq_error(status, &body));
    }

    let text = body.trim().to_string();
    if text.is_empty() {
        return Err("Transkription fehlgeschlagen – leere Antwort.".to_string());
    }

    Ok(text)
}

pub async fn improve_text(text: &str, api_key: &str, model: &str) -> Result<String, String> {
    chat_complete(
        api_key,
        model,
        "Du bist ein Lektor und Schreibassistent. Verbessere den folgenden Text: Korrigiere Rechtschreibung und Grammatik, verbessere die Formulierung und den Lesefluss. Behalte die ursprüngliche Bedeutung bei. Gib NUR den verbesserten Text zurück, keine Erklärungen.",
        text,
        0.3,
        None,
    )
    .await
}

pub async fn test_connection(api_key: &str, model: &str) -> Result<(), String> {
    chat_complete(api_key, model, "Say OK.", "hi", 0.0, Some(1)).await?;
    Ok(())
}

async fn chat_complete(
    api_key: &str,
    model: &str,
    system_prompt: &str,
    user_message: &str,
    temperature: f64,
    max_tokens: Option<u32>,
) -> Result<String, String> {
    let mut body = serde_json::json!({
        "model": model,
        "messages": [
            {"role": "system", "content": system_prompt},
            {"role": "user",   "content": user_message}
        ],
        "temperature": temperature
    });

    if let Some(mt) = max_tokens {
        body["max_tokens"] = serde_json::json!(mt);
    }

    let client = reqwest::Client::new();
    let response = client
        .post(CHAT_URL)
        .header("Authorization", format!("Bearer {}", api_key))
        .header("Content-Type", "application/json")
        .json(&body)
        .send()
        .await
        .map_err(|e| format!("Netzwerkfehler: {}", e))?;

    let status = response.status().as_u16();
    let body_text = response.text().await.unwrap_or_default();

    if status != 200 {
        return Err(groq_error(status, &body_text));
    }

    let json: serde_json::Value =
        serde_json::from_str(&body_text).map_err(|e| format!("Antwort-Parsing: {}", e))?;

    let content = json["choices"][0]["message"]["content"]
        .as_str()
        .unwrap_or("")
        .trim()
        .to_string();

    if content.is_empty() {
        return Err("Keine Antwort erhalten.".to_string());
    }

    Ok(content)
}
