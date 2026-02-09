@echo off
REM Copy built rust_core libraries to mobile Android project

echo Copying rust_core libraries to mobile project...

set "SOURCE_DIR=%~dp0..\rust_core\target\android"
set "DEST_DIR=%~dp0..\mobile\android\app\src\main\jniLibs"

if not exist "%SOURCE_DIR%" (
    echo Source directory not found: %SOURCE_DIR%
    echo Please run build-rust-android.bat first
    exit /b 1
)

REM Create destination directory if it doesn't exist
if not exist "%DEST_DIR%" mkdir "%DEST_DIR%"

REM Copy libraries to correct architecture folders
REM Note: Adjust these paths based on actual cargo-ndk output structure

if exist "%SOURCE_DIR%\armv7-linux-androideabi\release\librust_core.so" (
    if not exist "%DEST_DIR%\armeabi-v7a" mkdir "%DEST_DIR%\armeabi-v7a"
    copy /Y "%SOURCE_DIR%\armv7-linux-androideabi\release\librust_core.so" "%DEST_DIR%\armeabi-v7a\"
    echo   [OK] Copied to jniLibs/armeabi-v7a/
) else (
    echo   [MISSING] armeabi-v7a library not found
)

if exist "%SOURCE_DIR%\aarch64-linux-android\release\librust_core.so" (
    if not exist "%DEST_DIR%\arm64-v8a" mkdir "%DEST_DIR%\arm64-v8a"
    copy /Y "%SOURCE_DIR%\aarch64-linux-android\release\librust_core.so" "%DEST_DIR%\arm64-v8a\"
    echo   [OK] Copied to jniLibs/arm64-v8a/
) else (
    echo   [MISSING] arm64-v8a library not found
)

if exist "%SOURCE_DIR%\x86_64-linux-android\release\librust_core.so" (
    if not exist "%DEST_DIR%\x86_64" mkdir "%DEST_DIR%\x86_64"
    copy /Y "%SOURCE_DIR%\x86_64-linux-android\release\librust_core.so" "%DEST_DIR%\x86_64\"
    echo   [OK] Copied to jniLibs/x86_64/
) else (
    echo   [MISSING] x86_64 library not found
)

echo.
echo Done! Libraries copied to mobile/android/app/src/main/jniLibs/
echo You can now run: flutter run
echo.
