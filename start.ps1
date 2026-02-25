#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Start the ChatBot FastAPI server
.DESCRIPTION
    This script:
    1. Checks/creates the virtual environment
    2. Installs dependencies
    3. Starts the FastAPI server
    
    Note: To ingest documents, run .\ingest.ps1 separately
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   AI ChatBot - Setup & Run Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to script directory
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $scriptPath

# Step 1: Check if virtual environment exists
Write-Host "[1/4] Checking virtual environment..." -ForegroundColor Yellow
if (-not (Test-Path "venv\Scripts\Activate.ps1")) {
    Write-Host "[X] Virtual environment not found!" -ForegroundColor Red
    Write-Host "Creating virtual environment..." -ForegroundColor Yellow
    python -m venv venv
    Write-Host "[OK] Virtual environment created" -ForegroundColor Green
}

# Step 2: Activate virtual environment
Write-Host "[2/4] Activating virtual environment..." -ForegroundColor Yellow
& .\venv\Scripts\Activate.ps1
Write-Host "[OK] Virtual environment activated" -ForegroundColor Green
Write-Host ""

# Step 3: Install/Update dependencies
Write-Host "[3/4] Installing dependencies..." -ForegroundColor Yellow
.\venv\Scripts\python.exe -m pip install --upgrade pip -q
.\venv\Scripts\pip.exe install -r requirements.txt -q
Write-Host "[OK] All dependencies installed" -ForegroundColor Green
Write-Host ""

# Step 4: Check for .env file
Write-Host "[4/4] Checking configuration..." -ForegroundColor Yellow
if (-not (Test-Path ".env")) {
    Write-Host "[X] .env file not found!" -ForegroundColor Red
    Write-Host "Please copy .env.example to .env and configure your settings:" -ForegroundColor Yellow
    Write-Host "  1. Add your OPENAI_API_KEY" -ForegroundColor Yellow
    Write-Host "  2. Configure database credentials" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Then run this script again." -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Configuration file found" -ForegroundColor Green
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   Starting Server" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Server will start on: http://localhost:8002" -ForegroundColor Green
Write-Host "API Documentation: http://localhost:8002/docs" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the server" -ForegroundColor Yellow
Write-Host ""

# Start the server
.\venv\Scripts\python.exe -m uvicorn app.main:app --reload --port 8002