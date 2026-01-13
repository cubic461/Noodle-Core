# VS Code Extension Installation Guide

## Problem

The AI chat panel interface isn't updating after reinstalling the extension. This is typically caused by:

1. VS Code using cached version instead of newly installed one
2. Extension not being properly rebuilt with recent changes
3. Webview caching issues

## Solution Steps

### Step 1: Clear VS Code Extension Cache

1. Open VS Code
2. Press `Ctrl+Shift+P` to open Command Palette
3. Type `> Developer: Reload Window` and press Enter
4. Type `> Developer: Show Running Extensions` and press Enter
5. Find "Noodle IDE" in the list
6. Right-click on "Noodle IDE" and select "Disable"
7. Press `Ctrl+Shift+P` again
8. Type `> Developer: Reload Window` and press Enter
9. Close and restart VS Code completely

### Step 2: Install Updated Extension

1. Copy the new VSIX file: `noodle-ide-1.0.1.vsix`
2. Open VS Code
3. Press `Ctrl+Shift+P` to open Command Palette
4. Type `> Extensions: Install from VSIX...` and press Enter
5. Select the `noodle-ide-1.0.1.vsix` file
6. Click "Install"
7. When prompted, click "Reload Window" when installation completes

### Step 3: Verify Installation

1. Open a `.nc` file to activate Noodle language features
2. Press `Ctrl+Shift+P` to open Command Palette
3. Type `> Noodle: Open AI Chat` and press Enter
4. Verify the AI chat panel opens with updated interface

### Step 4: Test AI Chat Panel

1. In the AI chat panel, try sending a test message
2. Check if the interface reflects your recent changes
3. Verify all buttons and features are working as expected

## Troubleshooting

If the interface still doesn't update after following these steps:

1. **Check Extension Version**:
   - Open Command Palette (`Ctrl+Shift+P`)
   - Type `> Extensions` and check "Noodle IDE" shows version 1.0.1

2. **Manual Extension Reload**:
   - Open Command Palette (`Ctrl+Shift+P`)
   - Type `> Developer: Reload Extensions`
   - Restart VS Code

3. **Check Build Output**:
   - The build process should show "Build completed successfully!" with no errors
   - Check that TypeScript compilation included your changes

4. **Verify File Permissions**:
   - Ensure VS Code has permission to access the extension files
   - Try running VS Code as administrator if needed

## Development Mode Testing

For faster iteration during development:

1. Use `npm run watch:dev` to automatically rebuild on file changes
2. Use `npm run package:dev` to create development package quickly
3. Install development package with `--noVerify` flag for faster testing

## Build Verification

The build output should show:

- ✅ TypeScript compilation completed
- ✅ Resource files copied
- ✅ Build validation passed
- ✅ Build completed successfully!

If any of these steps fail, check the build log for errors.
