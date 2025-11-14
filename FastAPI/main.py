# backend.py
# FastAPI backend for AI Therapist project (deployable version)

import os
from fastapi import FastAPI, Request, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

OPENAI_API_KEY = os.getenv("OPENAI_API_KEY")
MODEL = os.getenv("MODEL", "gpt-4o-mini")
TEMPERATURE = float(os.getenv("TEMPERATURE", "0.3"))
MAX_TOKENS = int(os.getenv("MAX_TOKENS", "256"))

if not OPENAI_API_KEY:
    raise RuntimeError("OPENAI_API_KEY not set. Create a .env or set it in Render environment vars.")

client = OpenAI(api_key=OPENAI_API_KEY)

app = FastAPI(title="AI Therapist API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

class ChatIn(BaseModel):
    message: str
    session_id: str | None = None

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/chat")
async def chat(payload: ChatIn):
    text = payload.message.strip()
    if not text:
        raise HTTPException(status_code=400, detail="message is required")

    crisis_words = ["suicide", "kill myself", "hurt myself", "end my life"]
    if any(w in text.lower() for w in crisis_words):
        return {
            "reply": "If you're thinking about harming yourself, please contact a crisis hotline or local emergency service immediately. You're not alone.",
            "crisis": True
        }

    messages = [
        {"role": "system", "content": "You are a CBT-based AI therapist assistant. Follow CBT rules and maintain empathy."},
        {"role": "user", "content": text}
    ]

    try:
        resp = client.chat.completions.create(
            model=MODEL,
            messages=messages,
            temperature=TEMPERATURE,
            max_tokens=MAX_TOKENS
        )
        reply = resp.choices[0].message.content
        return {"reply": reply, "crisis": False}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"OpenAI API error: {e}")