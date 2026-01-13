@echo off
echo Starting NoodleCore Native GUI IDE - Persistent Settings...
echo.
echo This version will remember your AI settings, API keys, and preferences!
echo.
python native_gui_ide_persistent.py
if errorlevel 1 (
    echo.
    echo Error starting IDE. Press any key to exit...
    pause >nul
)