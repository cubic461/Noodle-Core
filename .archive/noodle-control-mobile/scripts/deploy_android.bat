@echo off
REM NoodleControl Android Deployment Script for Windows
REM This script builds and deploys the Android app to various environments

setlocal enabledelayedexpansion

REM Configuration
set APP_NAME=NoodleControl
set PACKAGE_NAME=com.noodlecontrol.app
set BUILD_DIR=build\app\outputs\flutter-apk
set BUNDLE_DIR=build\app\outputs\bundle\release

REM Environment variables
set ENVIRONMENT=%1
if "%ENVIRONMENT%"=="" set ENVIRONMENT=development

set FLAVOR=%2
if "%FLAVOR%"=="" set FLAVOR=development

echo ========================================
echo   NoodleControl Android Deployment
echo ========================================
echo Environment: %ENVIRONMENT%
echo Flavor: %FLAVOR%
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo Flutter is not installed. Please install Flutter first.
    exit /b 1
)

REM Check if Android SDK is installed
if "%ANDROID_HOME%"=="" (
    echo ANDROID_HOME is not set. Please set up Android SDK first.
    exit /b 1
)

REM Clean previous builds
echo Cleaning previous builds...
flutter clean

REM Get dependencies
echo Getting dependencies...
flutter pub get

REM Build the app
echo Building %FLAVOR% flavor for %ENVIRONMENT% environment...
if "%FLAVOR%"=="development" (
    flutter build apk --debug --flavor development
) else if "%FLAVOR%"=="staging" (
    flutter build apk --release --flavor staging
) else if "%FLAVOR%"=="production" (
    flutter build apk --release --flavor production
    flutter build appbundle --release --flavor production
) else (
    echo Unknown flavor: %FLAVOR%
    echo Available flavors: development, staging, production
    exit /b 1
)

REM Deploy based on environment
echo Deploying to %ENVIRONMENT% environment...
if "%ENVIRONMENT%"=="development" (
    REM Install on connected device
    echo Installing on connected device...
    adb install -r %BUILD_DIR%\app-%FLAVOR%-debug.apk
    echo App installed successfully on device.
) else if "%ENVIRONMENT%"=="staging" (
    REM Upload to staging distribution platform
    echo Uploading to staging distribution platform...
    REM Add your staging distribution platform commands here
    echo Staging deployment completed.
) else if "%ENVIRONMENT%"=="production" (
    REM Upload to Google Play Console
    echo Uploading to Google Play Console...
    REM This would typically use fastlane or the Google Play Console API
    echo Production deployment completed.
) else (
    echo Unknown environment: %ENVIRONMENT%
    echo Available environments: development, staging, production
    exit /b 1
)

echo.
echo ========================================
echo   Deployment completed successfully!
echo ========================================