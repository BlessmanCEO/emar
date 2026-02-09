#!/usr/bin/env pwsh
# Copy built rust_core libraries to mobile Android project

$ErrorActionPreference = "Stop"

Write-Host "Copying rust_core libraries to mobile project..." -ForegroundColor Green

$sourceDir = Join-Path $PSScriptRoot ".." "rust_core" "target" "android"
$destDir = Join-Path $PSScriptRoot ".." "mobile" "android" "app" "src" "main" "jniLibs"

if (-not (Test-Path $sourceDir)) {
    throw "Source directory not found: $sourceDir`nPlease run build-rust-android-docker.ps1 first"
}

# Create destination directory if it doesn't exist
if (-not (Test-Path $destDir)) {
    New-Item -ItemType Directory -Path $destDir -Force | Out-Null
}

# Copy libraries to correct architecture folders
$archMappings = @{
    "armeabi-v7a" = "armv7-linux-androideabi"
    "arm64-v8a"   = "aarch64-linux-android"
    "x86_64"      = "x86_64-linux-android"
    "x86"         = "i686-linux-android"
}

foreach ($arch in $archMappings.Keys) {
    $rustTarget = $archMappings[$arch]
    $sourcePath = Join-Path $sourceDir $rustTarget "release" "librust_core.so"
    $archDestDir = Join-Path $destDir $arch
    
    if (Test-Path $sourcePath) {
        if (-not (Test-Path $archDestDir)) {
            New-Item -ItemType Directory -Path $archDestDir -Force | Out-Null
        }
        
        Copy-Item -Path $sourcePath -Destination $archDestDir -Force
        Write-Host "  ✓ Copied to jniLibs/$arch/" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Not found: $rustTarget" -ForegroundColor Yellow
    }
}

Write-Host "`nDone! Libraries copied to mobile/android/app/src/main/jniLibs/" -ForegroundColor Green
Write-Host "You can now run: flutter run" -ForegroundColor Cyan
