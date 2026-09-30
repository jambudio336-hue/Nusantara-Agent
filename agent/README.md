# Nusantara Agent Runtime

Optional Python runtime for desktop/terminal use. The Android APK does not require this runtime or a backend server.

## Run

```bash
python -m venv .venv
# activate the environment
pip install -r agent/requirements.txt
python agent/main.py
```

Default dashboard/API: http://127.0.0.1:8787

Environment:
- `NUSANTARA_PROVIDER=ollama` (default) or `openrouter`
- `OLLAMA_BASE_URL=http://127.0.0.1:11434`
- `OLLAMA_MODEL=llama3.2`
- `OPENROUTER_API_KEY=...` (development environment only; never commit secrets)
- `OPENROUTER_MODEL=...`

The runtime intentionally does not execute arbitrary shell commands. Tools are registered explicitly and run inside a scoped workspace.
