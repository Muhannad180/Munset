from langchain_openai import ChatOpenAI, OpenAIEmbeddings
from langchain_chroma import Chroma
from langchain_core.prompts import ChatPromptTemplate
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import os

# import the .env file
from dotenv import load_dotenv
load_dotenv()

# ==================== Configuration ====================
# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(SCRIPT_DIR, "data")
CHROMA_PATH = os.path.join(SCRIPT_DIR, "chroma_db")

print(f"Loading ChromaDB from: {CHROMA_PATH}")

# Initialize embeddings and LLM
embeddings_model = OpenAIEmbeddings(model="text-embedding-3-large")
llm = ChatOpenAI(temperature=0.5, model='gpt-4o-mini')

# Connect to ChromaDB vector store
vector_store = Chroma(
    collection_name="example_collection",
    embedding_function=embeddings_model,
    persist_directory=CHROMA_PATH, 
)

# Set up the vectorstore as retriever
num_results = 5
retriever = vector_store.as_retriever(search_kwargs={'k': num_results})

# Verify vector store has documents
collection_data = vector_store.get()
num_docs = len(collection_data.get("ids", []))
print(f"✓ Connected to vector store with {num_docs} documents")

# ==================== FastAPI Setup ====================
app = FastAPI(title="RAG Chatbot API")

# Add CORS middleware for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== Request/Response Models ====================
class ChatRequest(BaseModel):
    message: str
    conversation_history: list = None

class ChatResponse(BaseModel):
    reply: str
    sources: list = None

# ==================== RAG System ====================
def get_rag_response(message: str, conversation_history: list = None):
    """
    Generate a RAG-based response using retrieved documents and LLM.
    
    Args:
        message: The user's question
        conversation_history: Previous conversation messages for context
        
    Returns:
        Dictionary with reply and source documents
    """
    
    # Retrieve relevant documents from vector store
    docs = retriever.invoke(message)
    
    # Aggregate document content as knowledge
    knowledge = ""
    sources = []
    has_relevant_docs = len(docs) > 0 and any(doc.page_content.strip() for doc in docs)
    
    for i, doc in enumerate(docs, 1):
        knowledge += doc.page_content + "\n\n"
        
        # Extract source metadata - try multiple fields
        source_info = None
        if "source" in doc.metadata:
            source_info = doc.metadata["source"]
        elif "file_path" in doc.metadata:
            source_info = doc.metadata["file_path"]
        elif "filename" in doc.metadata:
            source_info = doc.metadata["filename"]
        else:
            # If no source found, create a reference
            source_info = f"Document #{i}"
        
        if source_info and source_info not in sources:
            sources.append(source_info)
    
    # Format conversation history if provided
    history_text = ""
    if conversation_history:
        for msg in conversation_history:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            history_text += f"{role}: {content}\n"
    
    # Create RAG prompt
    rag_prompt = ChatPromptTemplate.from_template(
        """You are a helpful assistant powered by a Retrieval-Augmented Generation (RAG) system.

Your Role:
- Answer questions ONLY using information from the knowledge base below
- You have access to a document database that was retrieved based on the user's question
- If information is not in the knowledge base, clearly state that you don't have that information
- Be helpful, concise, and direct

Do NOT mention where your information comes from or that you're using a knowledge base.
Just answer the question naturally.

The question: {question}

Conversation history:
{history}

The knowledge base content:
{knowledge}

Please answer the user's question:"""
    )
    
    # Format the prompt with variables
    formatted_prompt = rag_prompt.format(
        question=message,
        history=history_text if history_text else "No previous conversation",
        knowledge=knowledge if knowledge else "No relevant documents found in knowledge base"
    )
    
    # Generate response from LLM
    response = llm.invoke(formatted_prompt)
    
    # Check if AI found information in the knowledge base
    # If response says "don't have" or "no information", don't show sources
    response_text = response.content.lower()
    has_answer_from_docs = not any(phrase in response_text for phrase in [
        "don't have",
        "no information",
        "don't know",
        "no relevant",
        "i don't have",
        "i don't know"
    ])
    
    return {
        "reply": response.content,
        # Only return sources if AI actually found and answered using the documents
        "sources": list(set(sources)) if has_answer_from_docs and sources else []
    }

# ==================== API Endpoints ====================
@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    """
    Chat endpoint that processes user messages with RAG.
    
    Args:
        request: ChatRequest with message and optional conversation history
        
    Returns:
        ChatResponse with generated reply and source documents
    """
    try:
        if not request.message or request.message.strip() == "":
            raise HTTPException(status_code=400, detail="Message cannot be empty")
        
        # Get RAG response
        result = get_rag_response(request.message, request.conversation_history)
        
        return ChatResponse(
            reply=result["reply"],
            sources=result["sources"]
        )
    except Exception as e:
        print(f"Error in chat endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "message": "RAG Chatbot API is running"}

@app.get("/debug/retrieve")
async def debug_retrieve(query: str):
    """
    Debug endpoint to see what documents are retrieved for a query.
    Useful for understanding what the RAG system finds.
    
    Usage: GET /debug/retrieve?query=what%20is%20CBT
    """
    try:
        # Retrieve documents
        docs = retriever.invoke(query)
        
        retrieved_docs = []
        for i, doc in enumerate(docs):
            retrieved_docs.append({
                "rank": i + 1,
                "content": doc.page_content[:300],  # First 300 chars
                "metadata": doc.metadata
            })
        
        return {
            "query": query,
            "num_results": len(docs),
            "documents": retrieved_docs
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Retrieval error: {str(e)}")# ==================== Streaming Endpoint (Optional) ====================
@app.post("/chat/stream")
async def chat_stream_endpoint(request: ChatRequest):
    """
    Streaming chat endpoint for real-time responses.
    Note: For true streaming to Flutter, consider using websockets or SSE.
    """
    try:
        if not request.message or request.message.strip() == "":
            raise HTTPException(status_code=400, detail="Message cannot be empty")
        
        # Get RAG response (non-streaming for now, can be extended)
        result = get_rag_response(request.message, request.conversation_history)
        
        return ChatResponse(
            reply=result["reply"],
            sources=result["sources"]
        )
    except Exception as e:
        print(f"Error in stream endpoint: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Chat error: {str(e)}")

# ==================== Run the App ====================
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)