const { invoke } = window.__TAURI__.core;
const { listen } = window.__TAURI__.event;

const recordBtn    = document.getElementById('recordBtn');
const statusIcon   = document.getElementById('statusIcon');
const statusText   = document.getElementById('statusText');
const resultText   = document.getElementById('resultText');
const settingsBtn  = document.getElementById('settingsBtn');

let isRecording = false;

function setStatus(phase, text, icon) {
  statusIcon.className = `status-icon ${phase}`;
  statusIcon.textContent = icon;
  statusText.textContent = text;
  resultText.style.display = 'none';
}

function showResult(text) {
  setStatus('done', 'Ergebnis in Zwischenablage kopiert.', '✓');
  resultText.textContent = text;
  resultText.style.display = 'block';
  setTimeout(() => setStatus('idle', 'Bereit. Hotkey oder Knopf drücken.', '🎙'), 4000);
}

function showError(message) {
  setStatus('error', message, '⚠');
  recordBtn.textContent = 'Aufnahme starten';
  recordBtn.classList.remove('recording');
  recordBtn.disabled = false;
  isRecording = false;
  setTimeout(() => setStatus('idle', 'Bereit. Hotkey oder Knopf drücken.', '🎙'), 4000);
}

async function handleToggle() {
  try {
    await invoke('toggle_recording');
  } catch (e) {
    showError(String(e));
  }
}

// ── Event listeners ──────────────────────────────────────────────────────────

recordBtn.addEventListener('click', handleToggle);

settingsBtn.addEventListener('click', async () => {
  // Open settings window via Tauri window API
  const { WebviewWindow } = window.__TAURI__.webviewWindow;
  const win = await WebviewWindow.getByLabel('settings');
  if (win) {
    await win.show();
    await win.setFocus();
  }
});

// ── Tauri event listeners ────────────────────────────────────────────────────

listen('recording-started', () => {
  isRecording = true;
  setStatus('recording', 'Aufnahme läuft ...', '🔴');
  recordBtn.textContent = 'Aufnahme stoppen';
  recordBtn.classList.add('recording');
  recordBtn.disabled = false;
});

listen('recording-stopped', () => {
  isRecording = false;
  recordBtn.textContent = 'Aufnahme starten';
  recordBtn.classList.remove('recording');
  recordBtn.disabled = true;
});

listen('status-update', (event) => {
  setStatus('processing', event.payload, '⏳');
});

listen('transcription-result', (event) => {
  recordBtn.disabled = false;
  showResult(event.payload);
});

listen('show-error', (event) => {
  showError(event.payload);
});
