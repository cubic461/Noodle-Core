# Noodle VS Code Extension Test Guide

## Testing the Fixed Extension

This guide helps you test that the Noodle VS Code extension now works correctly both inside and outside Noodle workspaces.

## Prerequisites

1. **Install the Extension**: Use the newly created `noodle-ide-1.0.0.vsix` file
2. **Restart VS Code**: Completely close and reopen VS Code after installation

## Test 1: Non-Noodle Workspace

### Steps

1. **Open VS Code**
2. **Open a Regular Folder**: File → Open Folder → Select any non-Noodle folder
3. **Look for Noodle Icon**: Check Activity Bar for the noodle icon
4. **Click the Icon**: The extension should show a welcome interface

### Expected Results

- ✅ Noodle icon visible in Activity Bar
- ✅ Clicking icon shows welcome screen (not empty)
- ✅ Welcome screen contains:
  - "Welcome to NoodleCore" message
  - "Create Noodle Project" button
  - "Open Documentation" link
  - "View Examples" option

### Troubleshooting

If you see a white icon with no interface:

1. Press `Ctrl+Shift+P` → "Developer: Reload Window"
2. Check that extension is enabled in Extensions view
3. Try restarting VS Code completely

## Test 2: Noodle Workspace

### Steps

1. **Create Test Folder**: Create a new folder anywhere on your system
2. **Add Noodle File**: Create a file named `test.nc` with this content:

   ```noodle
   func hello() {
       println("Hello, NoodleCore!");
   }
   
   hello();
   ```

3. **Open in VS Code**: File → Open Folder → Select your test folder
4. **Check Extension**: Look at the Noodle icon in Activity Bar
5. **Click the Icon**: Should show Noodle-specific interface

### Expected Results

- ✅ Noodle icon visible in Activity Bar
- ✅ Clicking icon shows Noodle project interface
- ✅ Interface includes:
  - Project Explorer showing `test.nc` file
  - AI Assistant panel
  - Noodle-specific commands and options

## Test 3: AI Assistant (Optional)

If you have NoodleCore backend running:

### Steps

1. **Open AI Assistant**: Click AI Assistant in the extension
2. **Try Analysis**: Select some code and use "Analyze" feature
3. **Check Response**: Should get AI analysis (or graceful error if backend not running)

### Expected Results

- ✅ AI Assistant interface opens
- ✅ Can analyze code (or shows proper error message)
- ✅ No crashes or unhandled exceptions

## Test 4: Extension Commands

### Steps

1. **Open Command Palette**: `Ctrl+Shift+P`
2. **Search for Noodle**: Type "Noodle"
3. **Check Commands**: Should see various Noodle commands

### Expected Results

- ✅ Commands like "Noodle: Create Project" appear
- ✅ Commands work when executed
- ✅ No "command not found" errors

## Verification Checklist

Mark each test as passed:

- [ ] Extension icon appears in Activity Bar
- [ ] Non-Noodle workspace shows welcome screen
- [ ] Noodle workspace shows project interface
- [ ] No empty/blank interfaces
- [ ] Commands are available and functional
- [ ] No error messages in developer console
- [ ] Extension loads without crashes

## Reporting Issues

If any test fails:

1. **Check Developer Console**: Help → Toggle Developer Tools → Console
2. **Note Error Messages**: Copy any red error messages
3. **Check Extension Log**: View → Output → NoodleCore Extension
4. **Report Issues**: Include:
   - Which test failed
   - Exact error messages
   - Your VS Code version
   - Your operating system

## Success Criteria

The extension is working correctly when:

1. **Icon Always Visible**: Noodle icon appears in Activity Bar regardless of workspace type
2. **Context-Aware UI**: Shows appropriate interface based on workspace detection
3. **No Empty Views**: All interfaces contain meaningful content
4. **Graceful Error Handling**: Backend failures show helpful messages, not crashes
5. **Commands Work**: All registered commands execute properly

## Advanced Testing

For thorough testing, also try:

1. **Workspace Switching**: Open non-Noodle folder, then Noodle folder
2. **File Operations**: Create, rename, delete Noodle files
3. **Syntax Highlighting**: Verify `.nc` files are properly highlighted
4. **Performance**: Extension doesn't slow down VS Code significantly

---

## Conclusion

If all tests pass, the extension has been successfully fixed! The issue where clicking the white icon showed no interface should now be resolved.

The key improvements made:

- ✅ Fixed workspace detection logic
- ✅ Implemented proper fallback UI for non-Noodle workspaces
- ✅ Added comprehensive error handling
- ✅ Fixed TypeScript compilation issues
- ✅ Ensured extension works in all contexts
