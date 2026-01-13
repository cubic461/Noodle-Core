# NoodleCore IDE Startup Guide

## Issues Fixed

### 1. "File 'l' not found" Error

**Problem**: The batch file was incorrectly passing 'l' as an argument to the Python script.
**Solution**: Removed the stray 'l' character from line 32 in `START_NOODLECORE_IDE.bat`

### 2. NOODLE_ZAI_API_KEY Warning

**Problem**: The IDE expects an API key for AI functionality but shows a warning when not set.
**Solution**: Created `setup_environment.bat` to help users configure API keys properly.

## How to Start the NoodleCore IDE

### Option 1: Quick Start (with API key setup)

1. Run the environment setup script:

   ```cmd
   setup_environment.bat
   ```

2. Follow the prompts to set up your API key (optional but recommended)
3. Start the IDE:

   ```cmd
   START_NOODLECORE_IDE.bat
   ```

### Option 2: Direct Start

1. Set environment variables (optional):

   ```cmd
   set NOODLE_ZAI_API_KEY=your-api-key-here
   ```

2. Start the IDE:

   ```cmd
   START_NOODLECORE_IDE.bat
   ```

### Option 3: Start without AI Features

If you don't have an API key or want to use the IDE without AI features:

1. Simply run:

   ```cmd
   START_NOODLECORE_IDE.bat
   ```

2. The IDE will start with a warning about the missing API key, but will function normally for non-AI features.

## API Key Configuration

### Supported Providers

1. **Z.ai (Primary)**: Set `NOODLE_ZAI_API_KEY`
2. **OpenRouter**: Set `OPENROUTER_API_KEY`
3. **OpenAI**: Set `OPENAI_API_KEY`

### Setting API Keys Permanently (Windows)

1. Press Windows Key + R, type "sysdm.cpl" and press Enter
2. Go to "Advanced" tab → "Environment Variables"
3. Click "New" and add:
   - Variable name: `NOODLE_ZAI_API_KEY`
   - Variable value: your-actual-api-key
4. Click OK on all dialogs
5. Restart your command prompt/terminal

## Syntax Highlighting

The IDE includes enhanced syntax highlighting for:

- Python (.py)
- JavaScript (.js)
- TypeScript (.ts)
- NoodleCore (.nc, .noodle)
- HTML (.html)
- CSS (.css)
- JSON (.json)
- YAML (.yaml, .yml)
- SQL (.sql)

### Changing Themes

1. In the IDE, go to View → Syntax Theme
2. Select from: Dark, Light, Blue, Monokai
3. The theme applies immediately to all open files

## Troubleshooting

### Issue: "Python not found"

**Solution**: Ensure Python 3.9+ is installed and in your PATH

### Issue: Module import errors

**Solution**: Make sure you're running from the noodle-core directory

### Issue: AI features not working

**Solution**:

1. Check that your API key is set correctly
2. Go to AI → AI Settings in the IDE to configure
3. Test with a different provider if needed

### Issue: Syntax highlighting not working

**Solution**:

1. Check that Pygments is installed: `pip install pygments`
2. Restart the IDE after installation
3. Check View → Syntax Theme settings

## Advanced Configuration

### Environment Variables

- `NOODLE_ENV`: Set to 'development' or 'production'
- `NOODLE_PORT`: HTTP server port (default: 8080)
- `NOODLE_ZAI_API_KEY`: Z.ai API key for AI features

### Syntax Fixer Configuration

- `NOODLE_SYNTAX_FIXER_AI`: Enable/disable AI-assisted syntax fixing
- `NOODLE_SYNTAX_FIXER_REALTIME`: Enable/disable real-time validation
- `NOODLE_SYNTAX_FIXER_LEARNING`: Enable/disable learning system
- `NOODLE_SYNTAX_FIXER_TRM`: Enable/disable TRM integration

## Getting Help

1. **In-IDE Help**: Go to Help → About
2. **AI Chat**: Use the AI Chat panel for assistance
3. **Documentation**: Check the `docs/` folder for detailed documentation

## File Structure

```
noodle-core/
├── START_NOODLECORE_IDE.bat    # Main launcher (FIXED)
├── setup_environment.bat            # Environment setup (NEW)
├── IDE_STARTUP_GUIDE.md         # This guide
└── src/noodlecore/desktop/ide/
    ├── launch_native_ide.py        # Canonical launcher
    └── native_gui_ide.py         # Main IDE implementation
```

## Summary of Fixes

1. ✅ Fixed "File 'l' not found" error by removing stray character
2. ✅ Created environment setup script for API key configuration
3. ✅ Verified syntax highlighting integration is working correctly
4. ✅ Provided comprehensive startup instructions

The IDE should now start successfully with or without AI features configured.
