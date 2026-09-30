import os
from pathlib import Path
from fastapi import FastAPI
from pydantic import BaseModel
import httpx

APP = FastAPI(title="Nusantara Agent", version="0.1.0")
WORKSPACE = Path(os.getenv("NUSANTARA_WORKSPACE", "./workspace")).resolve()
WORKSPACE.mkdir(parents=True, exist_ok=True)

class ChatRequest(BaseModel):
    message: str

def provider_config():
    provider = os.getenv("NUSANTARA_PROVIDER", "ollama").lower()
    if provider == "openrouter":
        return provider, os.getenv("OPENROUTER_API_KEY", ""), os.getenv(
            "OPENROUTER_MODEL", "openai/gpt-4o-mini"
        )
    return "ollama", "", os.getenv("OLLAMA_MODEL", "llama3.2")

async def ask(message: str) -> str:
    provider, key, model = provider_config()
    system = (
        "Kamu adalah Nusantara Agent. Bahasa Indonesia, friendly, presisi, dan terstruktur. "
        "Security hanya untuk aset yang berwenang diuji. Jangan menjalankan perintah destruktif "
        "atau mengambil kredensial. Jelaskan asumsi dan risiko."
    )
    if provider == "openrouter":
        if not key:
            return "OPENROUTER_API_KEY belum diatur."
        headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json"}
        payload = {"model": model, "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": message},
        ]}
        async with httpx.AsyncClient(timeout=120) as client:
            r = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers=headers, json=payload
            )
            r.raise_for_status()
            data = r.json()
        return data["choices"][0]["message"]["content"] + "\n\nby.mazkiplay.com"

    async with httpx.AsyncClient(timeout=120) as client:
        r = await client.post(
            os.getenv("OLLAMA_BASE_URL", "http://127.0.0.1:11434") + "/api/chat",
            json={"model": model, "stream": False, "messages": [
                {"role": "system", "content": system},
                {"role": "user", "content": message},
            ]},
        )
        r.raise_for_status()
        data = r.json()
    return data["message"]["content"] + "\n\nby.mazkiplay.com"

@APP.get("/api/health")
async def health():
    provider, _, model = provider_config()
    return {"status": "online", "provider": provider, "model": model, "workspace": str(WORKSPACE)}

@APP.post("/api/chat")
async def chat(req: ChatRequest):
    return {"content": await ask(req.message)}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(APP, host="127.0.0.1", port=int(os.getenv("PORT", "8787")))
