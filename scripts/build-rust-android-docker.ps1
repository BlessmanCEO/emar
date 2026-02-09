#!/usr/bin/env pwsh
# Build rust_core Android libraries using Docker

$ErrorActionPreference = "Stop"

Write-Host "Building rust_core Android libraries using Docker..." -ForegroundColor Green

# Change to rust_core directory
$rustCoreDir = Join-Path $PSScriptRoot ".." "rust_core"
Push-Location $rustCoreDir

try {
    # Build using Docker BuildKit for output
    Write-Host "Building Docker image for Android cross-compilation..." -ForegroundColor Yellow
    
    docker build -f Dockerfile.android --output type=local,dest=./target/android .
    
    if ($LASTEXITCODE -ne 0) {
        throw "Docker build failed"
    }
    
    Write-Host "Build complete! Libraries are in rust_core/target/android/" -ForegroundColor Green
    
    # Display the built libraries
    Write-Host "`nBuilt libraries:" -ForegroundColor Cyan
    Get-ChildItem -Path "./target/android" -Recurse -Filter "*.so" | ForEach-Object {
        Write-Host "  - $($_.FullName.Replace($rustCoreDir, '.'))" -ForegroundColor Gray
    }
    
    Write-Host "`nNext steps:" -ForegroundColor Green
    Write-Host "  1. Copy the libraries to mobile/android/app/src/main/jniLibs/" -ForegroundColor White
    Write-Host "  2. Or run: .\scripts\copy-to-mobile.ps1" -ForegroundColor White
    
} finally {
    Pop-Location
}
