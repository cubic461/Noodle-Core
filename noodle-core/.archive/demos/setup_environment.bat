@echo off
echo ========================================
echo   NoodleCore Environment Setup
echo ========================================
echo.

REM This script sets up the environment for NoodleCore IDE
REM It helps configure API keys and other settings

echo.
echo Setting up NoodleCore environment...
echo.

REM Check if Z.ai API key is set
if defined NOODLE_ZAI_API_KEY (
    echo [OK] NOODLE_ZAI_API_KEY is already set
) else (
    echo.
    echo Z.ai API Key Configuration:
    echo -----------------------------
    echo.
    echo Option 1: Set Z.ai API key (recommended for AI features)
    set /p NOODLE_ZAI_KEY=Enter your Z.ai API key (or press Enter to skip): 
    if not "!NOODLE_ZAI_KEY!"=="" (
        set NOODLE_ZAI_API_KEY=!NOODLE_ZAI_KEY!
        echo [OK] NOODLE_ZAI_API_KEY set for this session
        echo.
        echo To make this permanent, add to Windows Environment Variables:
        echo   Variable name: NOODLE_ZAI_API_KEY
        echo   Variable value: !NOODLE_ZAI_KEY!
        echo.
    ) else (
        echo [INFO] Skipping API key configuration
        echo.
        echo Note: AI features will be limited without an API key
        echo You can configure this later in the IDE Settings menu
    )
)

REM Check for alternative providers
echo.
echo Alternative AI Providers:
echo ------------------------
echo.
echo If you prefer to use a different provider, set one of these:
echo   - OpenRouter: set OPENROUTER_API_KEY=your-key
echo   - OpenAI: set OPENAI_API_KEY=your-key
echo.

REM Set other useful environment variables
if not defined NOODLE_ENV (
    set NOODLE_ENV=development
    echo [INFO] Set NOODLE_ENV=development
)

if not defined NOODLE_PORT (
    set NOODLE_PORT=8080
    echo [INFO] Set NOODLE_PORT=8080
)

echo.
echo Environment setup complete!
echo.
echo You can now start the IDE with: START_NOODLECORE_IDE.bat
echo.
pause