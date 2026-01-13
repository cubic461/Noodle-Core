# Noodle VS Code Extension - Installation and Usage Guide

## Overview

The Noodle VS Code Extension provides comprehensive support for NoodleCore development within Visual Studio Code. This guide will help you get started with using the extension to code in NoodleCore with AI assistance.

## Prerequisites

1. **NoodleCore Backend Server**
   - Make sure the NoodleCore API server is running on port 8080
   - The server should be accessible at `http://localhost:8080`
   - Follow the NoodleCore standards for API responses (UUID v4 request IDs)

2. **Visual Studio Code**
   - VS Code 1.74.0 or higher
   - Node.js and npm installed

## Installation

### Option 1: Install from VSIX File (Recommended)

1. Download the latest `noodle-vscode-extension.vsix` file
2. Open VS Code
3. Go to Extensions (Ctrl+Shift+X)
4. Click "Install from VSIX..." in the top-right corner
5. Select the downloaded VSIX file
6. Click "Install"
7. Reload VS Code when prompted

### Option 2: Install from Source (For Development)

1. Clone the repository:
   ```bash
   git clone https://github.com/noodle/noodle-vscode-extension.git
   cd noodle-vscode-extension
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Compile the extension:
   ```bash
   npm run compile
   ```

4. Package the extension:
   ```bash
   npm run package
   ```

5. Install in development mode:
   - Open VS Code
   - Press F5
   - Select "Run Extension"
   - Choose "noodle-vscode-extension"

## Getting Started

### 1. Start NoodleCore Backend

Before using the extension, you need to start the NoodleCore API server:

```bash
cd noodle-core
python src/noodlecore/api/server.py
```

The server will start on `http://localhost:8080` following NoodleCore standards.

### 2. Open a Noodle Project

1. Open VS Code
2. Open a folder containing `.nc` files (NoodleCore files)
3. The extension will automatically detect Noodle files and enable language support

### 3. Use AI Chat

1. Open the Command Palette (Ctrl+Shift+P)
2. Type "Noodle: AI Chat" and press Enter
3. A chat panel will open on the right side
4. Type your question and press Enter or click Send
5. The AI will respond with assistance for NoodleCore development

### 4. Code Analysis and Assistance

1. Select code in a `.nc` file
2. Right-click and choose "Noodle: Analyze Code"
3. The AI will analyze your code and provide suggestions
4. Results appear in the output panel

### 5. Code Execution

1. Open a `.nc` file
2. Right-click and choose "Noodle: Execute Code"
3. The code will be executed using the NoodleCore runtime
4. Results appear in the output panel

## Features

### ✨ AI-Powered Development
- **AI Chat**: Interactive chat interface for asking questions about NoodleCore development
- **Code Analysis**: AI-powered code analysis with suggestions and improvements
- **Code Completion**: Intelligent code completion for NoodleCore files
- **Syntax Highlighting**: Full syntax highlighting for `.nc` files
- **Error Detection**: Real-time error checking and suggestions

### 🔧 NoodleCore Integration
- **Backend Communication**: Direct integration with NoodleCore API server
- **File Operations**: Create, open, save, and execute NoodleCore files
- **Project Management**: Built-in project explorer for NoodleCore projects

## Troubleshooting

### Extension Not Visible
1. Check if the extension is enabled in VS Code Extensions view
2. Reload VS Code window (Ctrl+Shift+P → "Developer: Reload Window")

### Backend Connection Issues
1. Ensure NoodleCore server is running on port 8080
2. Check the output panel for connection status messages
3. Verify the server responds to health checks at `/api/v1/health`

### AI Chat Not Working
1. Check that NoodleCore server is running
2. Look for error messages in the output panel
3. Try restarting both NoodleCore server and VS Code

## Configuration

The extension supports the following VS Code settings:

```json
{
    "noodle.ai.enabled": true,
    "noodle.ai.provider": "openai",
    "noodle.ai.model": "gpt-4",
    "noodle.lsp.enabled": true,
    "noodle.ecosystem.enabled": true
}
```

## Next Steps

1. Explore the AI chat feature for complex development tasks
2. Use the code analysis feature to improve your NoodleCore code quality
3. Try the code execution feature to test your NoodleCore applications
4. Provide feedback to help improve the AI assistance

## Support

For issues and questions:
- Check the output panel for extension messages
- Review the NoodleCore documentation at `noodle-core/docs/`
- Report issues on the GitHub repository

---

**Happy coding with NoodleCore! 🚀**