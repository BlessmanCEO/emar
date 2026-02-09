@echo off
REM Build rust_core Android libraries using Docker

echo Building rust_core Android libraries using Docker...
echo.

cd /d "%~dp0\..\rust_core"

REM Build using Docker BuildKit and extract output
echo Building Docker image for Android cross-compilation...
docker build -f Dockerfile.android --output type=local,dest=./target/android . || (
    echo Docker build failed!
    exit /b 1
)

echo.
echo Build complete! Libraries are in rust_core/target/android/
echo.

REM Display the built libraries
echo Built libraries:
dir /s /b .\target\android\*.so 2>nul || echo No .so files found yet

echo.
echo Next steps:
echo   1. Run: scripts\copy-rust-to-mobile.bat
echo   2. Or manually copy libraries to mobile\android\app\src\main\jniLibs\
echo   3. Then run: flutter run
echo.

cd /d "%~dp0"
