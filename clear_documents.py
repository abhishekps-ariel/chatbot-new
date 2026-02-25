"""
Clear all documents from the database.

Usage:
    python clear_documents.py
"""

from app.database import SessionLocal
from app.models import DocumentChunk


def clear_all_documents():
    """Delete all document chunks from the database."""
    db = SessionLocal()
    try:
        deleted = db.query(DocumentChunk).delete()
        db.commit()
        print(f"✓ Successfully deleted {deleted} document chunks")
    except Exception as e:
        db.rollback()
        print(f"✗ Error clearing documents: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    confirm = input("Are you sure you want to delete ALL documents? (yes/no): ")
    if confirm.lower() == 'yes':
        clear_all_documents()
    else:
        print("Operation cancelled")
