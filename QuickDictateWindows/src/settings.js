const { invoke } = window.__TAURI__.core;

// ── Elements ─────────────────────────────────────────────────────────────────
const keyDisplayArea    = document.getElementById('keyDisplayArea');
const keyDisplayValue   = document.getElementById('keyDisplayValue');
const keyInputArea      = document.getElementById('keyInputArea');
const apiKeyInput       = document.getElementById('apiKeyInput');
const saveKeyBtn        = document.getElementById('saveKeyBtn');
const pasteKeyBtn       = document.getElementById('pasteKeyBtn');
const changeKeyBtn      = document.getElementById('changeKeyBtn');
const deleteKeyBtn      = document.getElementById('deleteKeyBtn');
const testBtn           = document.getElementById('testBtn');
const keyMsg            = document.getElementById('keyMsg');

const transcriptionModel  = document.getElementById('transcriptionModel');
const chatModel           = document.getElementById('chatModel');
const language            = document.getElementById('language');
const improvementEnabled  = document.getElementById('improvementEnabled');
const saveSettingsBtn     = document.getElementById('saveSettingsBtn');
const settingsMsg         = document.getElementById('settingsMsg');

// ── Helpers ───────────────────────────────────────────────────────────────────
function showKeyMsg(text, type) {
  keyMsg.textContent = text;
  keyMsg.className = `msg ${type}`;
  keyMsg.style.display = 'block';
  setTimeout(() => { keyMsg.style.display = 'none'; }, 4000);
}

function showSettingsMsg(text, type) {
  settingsMsg.textContent = text;
  settingsMsg.className = `msg ${type}`;
  settingsMsg.style.display = 'block';
  setTimeout(() => { settingsMsg.style.display = 'none'; }, 3000);
}

async function refreshKeyDisplay() {
  const hasKey = await invoke('has_api_key');
  if (hasKey) {
    keyDisplayValue.textContent = await invoke('api_key_display');
    keyDisplayArea.style.display = 'block';
    keyInputArea.style.display = 'none';
  } else {
    keyDisplayArea.style.display = 'none';
    keyInputArea.style.display = 'block';
    apiKeyInput.focus();
  }
}

async function loadSettings() {
  const s = await invoke('get_settings');
  transcriptionModel.value = s.transcriptionModel;
  chatModel.value          = s.chatModel;
  language.value           = s.language;
  improvementEnabled.checked = s.improvementEnabled;
}

// ── Init ──────────────────────────────────────────────────────────────────────
(async () => {
  await refreshKeyDisplay();
  await loadSettings();
})();

// ── API Key ───────────────────────────────────────────────────────────────────
saveKeyBtn.addEventListener('click', async () => {
  const key = apiKeyInput.value.trim();
  if (!key) { showKeyMsg('Bitte einen API Key eingeben.', 'error'); return; }
  try {
    await invoke('save_api_key', { key });
    apiKeyInput.value = '';
    await refreshKeyDisplay();
    showKeyMsg('API Key gespeichert.', 'success');
  } catch (e) {
    showKeyMsg(String(e), 'error');
  }
});

pasteKeyBtn.addEventListener('click', async () => {
  try {
    const text = await navigator.clipboard.readText();
    const line = text.split('\n')[0].trim();
    if (!line.startsWith('gsk_')) {
      showKeyMsg('Kein plausiblen Groq API Key in der Zwischenablage (erwartet: gsk_...).', 'error');
      return;
    }
    apiKeyInput.value = line;
    showKeyMsg('Key eingefügt. Bitte speichern.', 'success');
  } catch {
    showKeyMsg('Zwischenablage konnte nicht gelesen werden.', 'error');
  }
});

changeKeyBtn.addEventListener('click', () => {
  keyDisplayArea.style.display = 'none';
  keyInputArea.style.display = 'block';
  apiKeyInput.focus();
});

deleteKeyBtn.addEventListener('click', async () => {
  if (!confirm('Groq API Key wirklich löschen?')) return;
  try {
    await invoke('delete_api_key');
    await refreshKeyDisplay();
    showKeyMsg('API Key gelöscht.', 'success');
  } catch (e) {
    showKeyMsg(String(e), 'error');
  }
});

testBtn.addEventListener('click', async () => {
  testBtn.disabled = true;
  testBtn.textContent = 'Teste ...';
  try {
    await invoke('test_connection');
    showKeyMsg('Verbindung erfolgreich.', 'success');
  } catch (e) {
    showKeyMsg(String(e), 'error');
  } finally {
    testBtn.disabled = false;
    testBtn.textContent = 'Verbindung testen';
  }
});

// ── Settings ──────────────────────────────────────────────────────────────────
saveSettingsBtn.addEventListener('click', async () => {
  try {
    await invoke('save_settings', {
      s: {
        transcriptionModel: transcriptionModel.value,
        chatModel: chatModel.value,
        hotkey: 'Ctrl+Shift+Space',
        hotkeyMode: 'toggle',
        language: language.value,
        improvementEnabled: improvementEnabled.checked,
      }
    });
    showSettingsMsg('Einstellungen gespeichert.', 'success');
  } catch (e) {
    showSettingsMsg(String(e), 'error');
  }
});
