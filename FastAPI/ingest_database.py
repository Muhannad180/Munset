from langchain_community.document_loaders import PyPDFDirectoryLoader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from langchain_openai.embeddings import OpenAIEmbeddings
from langchain_chroma import Chroma
from uuid import uuid4
import os
from pathlib import Path

# import the .env file
from dotenv import load_dotenv
load_dotenv()

# ==================== Configuration ====================
# Get the directory where this script is located
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
DATA_PATH = os.path.join(SCRIPT_DIR, "data")
CHROMA_PATH = os.path.join(SCRIPT_DIR, "chroma_db")

print(f"Data path: {DATA_PATH}")
print(f"Chroma path: {CHROMA_PATH}")

# Verify data directory exists
if not os.path.exists(DATA_PATH):
    print(f"Warning: Data directory '{DATA_PATH}' not found. Creating it...")
    os.makedirs(DATA_PATH, exist_ok=True)

# ==================== Initialize Components ====================
# Initialize embeddings model
embeddings_model = OpenAIEmbeddings(model="text-embedding-3-large")

# Initialize the vector store
vector_store = Chroma(
    collection_name="example_collection",
    embedding_function=embeddings_model,
    persist_directory=CHROMA_PATH,
)

# ==================== Document Processing ====================
def load_documents():
    """
    Load all PDF documents from the data directory.
    
    Returns:
        List of loaded documents
    """
    print(f"Loading PDFs from: {os.path.abspath(DATA_PATH)}")
    
    loader = PyPDFDirectoryLoader(DATA_PATH)
    raw_documents = loader.load()
    
    print(f"Loaded {len(raw_documents)} document pages")
    return raw_documents

def split_documents(raw_documents):
    """
    Split documents into chunks with overlap for better context preservation.
    
    Args:
        raw_documents: List of loaded documents
        
    Returns:
        List of document chunks
    """
    text_splitter = RecursiveCharacterTextSplitter(
        chunk_size=300,        # Size of each chunk
        chunk_overlap=100,     # Overlap between chunks for context
        length_function=len,
        is_separator_regex=False,
    )
    
    chunks = text_splitter.split_documents(raw_documents)
    print(f"Created {len(chunks)} chunks from documents")
    
    return chunks

def add_documents_to_vectorstore(chunks):
    """
    Add document chunks to the vector store with unique IDs.
    
    Args:
        chunks: List of document chunks to add
        
    Returns:
        List of created document IDs
    """
    # Create unique IDs for each chunk
    uuids = [str(uuid4()) for _ in range(len(chunks))]
    
    # Add documents to vector store
    vector_store.add_documents(documents=chunks, ids=uuids)
    
    print(f"Added {len(chunks)} documents to vector store with IDs")
    print("Vector store updated successfully!")
    
    return uuids

# ==================== Main Ingestion Pipeline ====================
def ingest_documents():
    """
    Main function to run the complete ingestion pipeline:
    1. Load PDFs from data directory
    2. Split documents into chunks
    3. Embed and store in Chroma
    """
    try:
        print("=" * 50)
        print("Starting Document Ingestion Pipeline")
        print("=" * 50)
        
        # Step 1: Load documents
        raw_documents = load_documents()
        
        if not raw_documents:
            print("No documents found. Please add PDFs to the 'data' directory.")
            return
        
        # Step 2: Split documents into chunks
        chunks = split_documents(raw_documents)
        
        # Step 3: Add to vector store
        document_ids = add_documents_to_vectorstore(chunks)
        
        print("=" * 50)
        print("✓ Ingestion completed successfully!")
        print(f"Total documents processed: {len(raw_documents)}")
        print(f"Total chunks created: {len(chunks)}")
        print(f"Vector store location: {os.path.abspath(CHROMA_PATH)}")
        print("=" * 50)
        
    except Exception as e:
        print(f"Error during ingestion: {str(e)}")
        raise

# ==================== Clear Vector Store (Optional) ====================
def clear_vectorstore():
    """
    Clear all documents from the vector store.
    Useful for resetting and re-ingesting data.
    """
    try:
        # Get all documents and delete them
        collection = vector_store.get()
        if collection and collection.get("ids"):
            vector_store.delete(ids=collection["ids"])
            print("Vector store cleared successfully!")
        else:
            print("Vector store is already empty")
    except Exception as e:
        print(f"Error clearing vector store: {str(e)}")

# ==================== Get Vector Store Stats ====================
def get_vectorstore_stats():
    """
    Get statistics about the current vector store.
    
    Returns:
        Dictionary with vector store information
    """
    try:
        collection_data = vector_store.get()
        num_docs = len(collection_data.get("ids", []))
        
        stats = {
            "total_documents": num_docs,
            "collection_name": "example_collection",
            "embedding_model": "text-embedding-3-large",
            "persist_directory": os.path.abspath(CHROMA_PATH)
        }
        
        return stats
    except Exception as e:
        print(f"Error getting vector store stats: {str(e)}")
        return {}

# ==================== Run ====================
if __name__ == "__main__":
    import sys
    
    if len(sys.argv) > 1:
        command = sys.argv[1].lower()
        
        if command == "clear":
            clear_vectorstore()
        elif command == "stats":
            stats = get_vectorstore_stats()
            print("\nVector Store Statistics:")
            for key, value in stats.items():
                print(f"  {key}: {value}")
        else:
            print(f"Unknown command: {command}")
            print("Available commands: ingest, clear, stats")
    else:
        # Default: ingest documents
        ingest_documents()
