#!/bin/bash
# Complete setup and run script for ChatBot backend

echo "========================================"
echo "   AI ChatBot - Setup & Run Script"
echo "========================================"
echo ""

# Change to script directory
cd "$(dirname "$0")"

# Step 1: Check if virtual environment exists
echo "[1/4] Checking virtual environment..."
if [ ! -d "venv" ]; then
    echo "✗ Virtual environment not found!"
    echo "Creating virtual environment..."
    python3 -m venv venv
    echo "✓ Virtual environment created"
fi

# Step 2: Activate virtual environment
echo "[2/4] Activating virtual environment..."
source venv/bin/activate
echo "✓ Virtual environment activated"
echo ""

# Step 3: Install/Update dependencies
echo "[3/4] Installing dependencies..."
pip install --upgrade pip -q
pip install -r requirements.txt -q
echo "✓ All dependencies installed"
echo ""

# Step 4: Check for .env file
echo "[4/4] Checking configuration..."
if [ ! -f ".env" ]; then
    echo "✗ .env file not found!"
    echo "Please copy .env.example to .env and configure your settings:"
    echo "  1. Add your OPENAI_API_KEY"
    echo "  2. Configure database credentials"
    echo ""
    echo "Then run this script again."
    exit 1
fi
echo "✓ Configuration file found"
echo ""

# Step 5: Ingest documents
echo "========================================"
echo "   Document Ingestion"
echo "========================================"
echo ""

doc_count=$(find documents -type f \( -name "*.pdf" -o -name "*.docx" -o -name "*.md" -o -name "*.json" \) ! -name "README.md" | wc -l)

if [ "$doc_count" -eq 0 ]; then
    echo "⚠ No documents found in documents/ folder"
    echo "Add your PDF, DOCX, MD, or JSON files to the documents/ folder"
    echo ""
    read -p "Continue without ingesting documents? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 0
    fi
else
    echo "Found $doc_count document(s) to ingest"
    echo "Starting ingestion..."
    echo ""
    
    python ingest_documents.py
    
    echo ""
    echo "✓ Document ingestion completed"
fi

echo ""
echo "========================================"
echo "   Starting Server"
echo "========================================"
echo ""
echo "Server will start on: http://localhost:8002"
echo "API Documentation: http://localhost:8002/docs"
echo ""
echo "Press Ctrl+C to stop the server"
echo ""

# Start the server
python -m uvicorn app.main:app --reload --port 8002
