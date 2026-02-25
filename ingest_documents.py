"""
Bulk ingest documents from the documents/ folder.

Usage:
    python ingest_documents.py
"""

import os
from pathlib import Path
from app.database import SessionLocal
from app.models import DocumentChunk
from app.services.document_processor import DocumentProcessor
from app.services.embeddings import EmbeddingService
from app.config import get_settings

settings = get_settings()


def ingest_file(file_path: Path, db):
    """Ingest a single file directly into the database."""
    try:
        # Read file content
        with open(file_path, 'rb') as f:
            content = f.read()
        
        # Process document
        processor = DocumentProcessor(
            chunk_size=settings.chunk_size,
            chunk_overlap=settings.chunk_overlap
        )
        chunks, metadata = processor.process_document(content, file_path.name)
        
        if not chunks:
            print(f"[!] No chunks extracted from {file_path.name}")
            return
        
        # Create embeddings
        embedding_service = EmbeddingService()
        embeddings = embedding_service.create_embeddings_batch(chunks)
        
        # Delete existing chunks for this document (if re-uploading)
        db.query(DocumentChunk).filter(
            DocumentChunk.document_name == file_path.name
        ).delete()
        
        # Store chunks in database
        for i, (chunk_text, embedding) in enumerate(zip(chunks, embeddings)):
            chunk = DocumentChunk(
                document_name=file_path.name,
                chunk_text=chunk_text,
                chunk_index=i,
                embedding=embedding,
                doc_metadata=metadata
            )
            db.add(chunk)
        
        print(f"[OK] {file_path.name}: {len(chunks)} chunks created")
        
    except Exception as e:
        print(f"[X] Error ingesting {file_path.name}: {e}")



def main():
    """Ingest all documents from the documents/ folder."""
    documents_dir = Path("documents")
    
    # Supported file types
    patterns = ["**/*.pdf", "**/*.docx", "**/*.md", "**/*.json"]
    
    files = []
    for pattern in patterns:
        files.extend(documents_dir.glob(pattern))
    
    # Filter out README files
    files = [f for f in files if f.name.lower() != 'readme.md']
    
    if not files:
        print("No documents found in the documents/ folder")
        return
    
    print(f"Found {len(files)} document(s) to ingest:\n")
    
    # Create database session
    db = SessionLocal()
    try:
        for file_path in files:
            print(f"Ingesting: {file_path}")
            ingest_file(file_path, db)
        
        db.commit()
        print(f"\n[OK] Successfully ingested {len(files)} document(s)")
    except Exception as e:
        db.rollback()
        print(f"\n[X] Error during ingestion: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    main()

