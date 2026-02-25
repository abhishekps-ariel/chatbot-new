# AI ChatBot Backend

A Retrieval Augmented Generation (RAG) chatbot powered by OpenAI GPT-4o-mini and text-embedding-3-small.

## Features

- **RAG Architecture**: Combines document retrieval with AI generation
- **OpenAI Integration**: Uses GPT-4o-mini for chat and text-embedding-3-small for embeddings
- **PostgreSQL Database**: Stores document chunks with JSONB embeddings
- **Document Support**: PDF, DOCX, Markdown, and JSON files
- **RESTful API**: FastAPI with automatic OpenAPI documentation

## Quick Start

### Option 1: Automated Setup (Recommended)

**Windows:**
```bash
.\start.ps1
```

**Linux/Mac:**
```bash
chmod +x start.sh
./start.sh
```

This script will:
1. ✅ Create/activate virtual environment
2. ✅ Install dependencies
3. ✅ Check configuration
4. ✅ Ingest all documents from documents/ folder
5. ✅ Start the server on port 8002

### Option 2: Manual Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and update with your credentials:

```env
OPENAI_API_KEY='your-openai-api-key-here'
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=chatbot_db
POSTGRES_USER=postgres
POSTGRES_PASSWORD=your-password-here
```

### 3. Add Your Documents

Place your knowledge base documents in the `documents/` folder:
- PDF files (.pdf)
- Word documents (.docx)
- Markdown files (.md)
- JSON Q&A datasets (.json)

### 4. Run the Server

```bash
python -m uvicorn app.main:app --reload --port 8002
```

The API will be available at http://localhost:8002

## API Endpoints

### Chat
- **POST** `/chat/` - Ask a question and get an AI-generated answer

### Document Management
- **POST** `/ingest/` - Upload a document (PDF, DOCX, MD, JSON)
- **GET** `/ingest/documents` - List all documents
- **DELETE** `/ingest/{document_name}` - Delete a document

### Health Check
- **GET** `/health` - Check API and database status

## API Documentation

Once running, visit:
- **Swagger UI**: http://localhost:8002/docs
- **ReDoc**: http://localhost:8002/redoc

## Directory Structure

```
ChatbotPython/
├── app/
│   ├── main.py              # FastAPI application
│   ├── config.py            # Configuration settings
│   ├── database.py          # Database connection
│   ├── models.py            # SQLAlchemy models
│   ├── schemas.py           # Pydantic schemas
│   ├── routers/             # API endpoints
│   │   ├── chat.py
│   │   └── ingest.py
│   └── services/            # Business logic
│       ├── chat.py          # OpenAI chat service
│       ├── embeddings.py    # OpenAI embedding service
│       ├── retrieval.py     # Similarity search
│       └── document_processor.py
├── documents/               # Place your documents here
├── requirements.txt
├── .env.example
└── README.md
```

## Usage

### 1. Upload Documents

```bash
curl -X POST "http://localhost:8002/ingest/" \
  -F "file=@your_document.pdf"
```

### 2. Ask Questions

```bash
curl -X POST "http://localhost:8002/chat/" \
  -H "Content-Type: application/json" \
  -d '{"question": "Your question here?"}'
```

## Cost

- **Chat**: $0.15/1M input tokens, $0.60/1M output tokens (gpt-4o-mini)
- **Embeddings**: $0.02/1M tokens (text-embedding-3-small)

## Tech Stack

- **FastAPI** - Modern web framework
- **OpenAI** - GPT-4o-mini & text-embedding-3-small
- **PostgreSQL** - Database with JSONB support
- **SQLAlchemy** - ORM
- **Pydantic** - Data validation
