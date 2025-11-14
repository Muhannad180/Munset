from fastapi import FastAPI
from pydantic import BaseModel
import asyncpg
import openai

# FastAPI instance
app = FastAPI()

# Set your OpenAI API key
openai.api_key = "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"

# Supabase Database Connection Info
DB_CONFIG = {
    "user": "postgres",
    "password": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh6ZG16eWpvY3pjb3ZjenZ6dmFjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk1ODEwMzMsImV4cCI6MjA3NTE1NzAzM30.rkdKcd-ijGxPlSdLtCCkW8V9N0hnSHZZ5AQpLnQrBgA",
    "database": "postgres",
    "host": "xzdmzyjoczcovczvzvac.supabase.co",
    "port": 5432
}

# Define the query input model (embedding + optional filters)
class QueryEmbedding(BaseModel):
    embedding: list[float]  # Embedding vector for the search query
    match_count: int = 5  # Number of matches to retrieve
    filter: dict = {}  # Optional metadata filter

# Function to connect to Supabase (PostgreSQL)
async def get_db_connection():
    conn = await asyncpg.connect(
        user=DB_CONFIG["user"],
        password=DB_CONFIG["password"],
        database=DB_CONFIG["database"],
        host=DB_CONFIG["host"],
        port=DB_CONFIG["port"]
    )
    return conn

# Function to generate embeddings for the search query (using OpenAI API)
def generate_embedding(query: str):
    response = openai.Embedding.create(
        model="text-embedding-ada-002",  # Using OpenAI's embedding model
        input=query
    )
    return response['data'][0]['embedding']

# Chat endpoint to handle messages and use RAG for responses
@app.post("/chat/")
async def chat_endpoint(request: dict):
    message = request.get("message", "")
    session_id = request.get("session_id", "")

    try:
        # Generate embedding for the user's message
        message_embedding = generate_embedding(message)

        # Connect to the database
        conn = await get_db_connection()

        # Search for relevant documents using the embedding
        query_embedding = f"ARRAY{message_embedding}::vector(1536)"
        relevant_docs = await conn.fetch(
            """
            SELECT content, 1 - (documents.embedding <=> $1) AS similarity
            FROM documents
            ORDER BY documents.embedding <=> $1
            LIMIT 3;
            """,
            query_embedding
        )

        # Close the connection
        await conn.close()

        # Prepare context from relevant documents
        context = "\n".join([doc['content'] for doc in relevant_docs])

        # Use context to generate a response
        # For now, we'll just return a simple response with the most relevant content
        if relevant_docs:
            reply = f"Based on my knowledge: {relevant_docs[0]['content']}"
        else:
            reply = "I don't have enough context to provide a specific answer."

        return {
            "reply": reply,
            "session_id": session_id
        }
    except Exception as e:
        print(f"Error in chat endpoint: {e}")
        return {
            "reply": "I encountered an error while processing your message.",
            "session_id": session_id
        }

# Main entry point to test the API with Uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
