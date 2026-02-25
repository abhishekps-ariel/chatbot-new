#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Document ingestion script for ChatBot
.DESCRIPTION
    This script ingests all documents from the documents/ folder
    and processes them into the database with embeddings.
    
    Only run this when:
    - Adding new documents
    - Updating existing documents
    - Re-indexing is needed
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   AI ChatBot - Document Ingestion" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Step 1: Check if virtual environment exists
Write-Host "[1/3] Checking virtual environment..." -ForegroundColor Yellow
if (-not (Test-Path "venv\Scripts\Activate.ps1")) {
    Write-Host "[X] Virtual environment not found!" -ForegroundColor Red
    Write-Host "Please run start.ps1 first to set up the environment" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Virtual environment found" -ForegroundColor Green
Write-Host ""

# Step 2: Activate virtual environment
Write-Host "[2/3] Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
Write-Host "[OK] Virtual environment activated" -ForegroundColor Green
Write-Host ""

# Step 3: Check for .env file
Write-Host "[3/3] Checking configuration..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "[X] .env file not found!" -ForegroundColor Red
    Write-Host "Please configure your .env file with OPENAI_API_KEY and database credentials" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Configuration file found" -ForegroundColor Green
Write-Host ""

# Step 4: Check for documents
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Scanning Documents" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$documents = Get-ChildItem -Path "documents" -Include *.pdf,*.docx,*.md,*.json -Recurse | Where-Object { $_.Name -ne "README.md" }

if ($documents.Count -eq 0) {
    Write-Host "[!] No documents found in documents/ folder" -ForegroundColor Yellow
    Write-Host "Add your PDF, DOCX, MD, or JSON files to the documents/ folder" -ForegroundColor Yellow
    Write-Host ""
    exit 0
}

Write-Host "Found $($documents.Count) document(s) to ingest:" -ForegroundColor Green
foreach ($doc in $documents) {
    Write-Host "  - $($doc.Name)" -ForegroundColor Cyan
}
Write-Host ""

# Step 5: Confirm ingestion
Write-Host "[!] WARNING: This will use OpenAI API tokens to generate embeddings" -ForegroundColor Yellow
$confirm = Read-Host "Continue with ingestion? (y/n)"

if ($confirm -ne "y") {
    Write-Host "Ingestion cancelled" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Processing Documents" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Run ingestion
.\venv\Scripts\python.exe ingest_documents.py

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "[OK] Document ingestion completed!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can now start the server with: .\start.ps1" -ForegroundColor Cyan
