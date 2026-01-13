"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ModernAIChatPanel = void 0;
const vscode = __importStar(require("vscode"));
class ModernAIChatPanel {
    constructor(extensionUri, backendService, context) {
        this._disposables = [];
        this._backendService = backendService;
        this._context = context;
        this._state = {
            messages: [],
            currentProvider: 'openai',
            currentModel: 'gpt-4',
            isTyping: false,
            isThinking: false,
            context: {}
        };
    }
    show() {
        if (this._panel) {
            this._panel.reveal();
            return;
        }
        this._panel = vscode.window.createWebviewPanel('noodleModernAIChat', 'Noodle AI Assistant', vscode.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true,
            localResourceRoots: [this._context.extensionUri]
        });
        this._panel.webview.html = this._getWebviewContent();
        // Handle messages from the webview
        this._panel.webview.onDidReceiveMessage(async (message) => {
            await this._handleWebviewMessage(message);
        }, undefined, this._disposables);
        // Handle panel disposal
        this._panel.onDidDispose(() => {
            this._panel = undefined;
            this._disposables.forEach(d => d.dispose());
            this._disposables = [];
        }, undefined, this._disposables);
        // Update context with current editor information
        this._updateContext();
        // Send initial state
        this._sendState();
    }
    _updateContext() {
        const editor = vscode.window.activeTextEditor;
        if (editor) {
            this._state.context = {
                activeFile: editor.document.fileName,
                selectedCode: editor.document.getText(editor.selection),
                workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                language: editor.document.languageId
            };
        }
    }
    async _handleWebviewMessage(message) {
        switch (message.type) {
            case 'sendMessage':
                await this._handleSendMessage(message.content);
                break;
            case 'clearChat':
                this._clearChat();
                break;
            case 'setProvider':
                this._setProvider(message.provider, message.model);
                break;
            case 'getProviders':
                this._sendProviders();
                break;
            case 'getHistory':
                this._sendHistory();
                break;
            case 'applySuggestion':
                await this._applySuggestion(message.suggestion, message.type);
                break;
            case 'insertCodeAtCursor':
                await this._insertCodeAtCursor(message.code);
                break;
            case 'explainCode':
                await this._explainCode(message.code);
                break;
            case 'fixCode':
                await this._fixCode(message.code);
                break;
            case 'optimizeCode':
                await this._optimizeCode(message.code);
                break;
            case 'generateCode':
                await this._generateCode(message.prompt);
                break;
            case 'updateContext':
                this._updateContext();
                this._sendState();
                break;
        }
    }
    async _handleSendMessage(content) {
        if (!content.trim())
            return;
        this._updateContext();
        const userMessage = {
            id: this._generateId(),
            role: 'user',
            content: content.trim(),
            timestamp: new Date()
        };
        this._state.messages.push(userMessage);
        this._state.isTyping = true;
        this._state.isThinking = true;
        this._sendState();
        try {
            // Get response from backend with context
            const backendResponse = await this._getBackendResponse(content);
            const assistantMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: backendResponse.content,
                timestamp: new Date(),
                provider: this._state.currentProvider,
                model: this._state.currentModel,
                thinking: backendResponse.thinking,
                suggestions: backendResponse.suggestions
            };
            this._state.messages.push(assistantMessage);
        }
        catch (error) {
            // Fallback response when backend fails
            const fallbackResponse = await this._getFallbackResponse(content);
            const assistantMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: fallbackResponse,
                timestamp: new Date(),
                provider: this._state.currentProvider,
                model: this._state.currentModel
            };
            this._state.messages.push(assistantMessage);
        }
        this._state.isTyping = false;
        this._state.isThinking = false;
        this._sendState();
    }
    async _getBackendResponse(content) {
        try {
            const response = await this._backendService.makeAIChatRequest(content, this._state.currentProvider, this._state.currentModel, this._state.messages.slice(-10), // Last 10 messages for context
            this._state.context);
            if (response.success && response.data) {
                return {
                    content: response.data.response || 'No response received',
                    thinking: response.data.thinking,
                    suggestions: response.data.suggestions || []
                };
            }
            else {
                throw new Error(response.error?.message || 'Backend request failed');
            }
        }
        catch (error) {
            console.error('Backend AI request failed:', error);
            throw error;
        }
    }
    async _getFallbackResponse(content) {
        return `I'm sorry, but I'm currently unable to connect to the AI backend. Please ensure the NoodleCore server is running on port 8080.

Your message was: "${content}"

To use AI chat functionality:
1. Make sure the NoodleCore server is running: \`python src/noodlecore/api/server.py\`
2. Check that the server is accessible on http://127.0.0.1:8080
3. Try again once the server is available.

For now, you can use the other Noodle IDE features like code analysis and project exploration.`;
    }
    async _applySuggestion(suggestion, type) {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor found');
            return;
        }
        switch (type) {
            case 'replace':
                await editor.edit(editBuilder => {
                    editBuilder.replace(editor.selection, suggestion);
                });
                break;
            case 'insert':
                await editor.edit(editBuilder => {
                    editBuilder.insert(editor.selection.active, suggestion);
                });
                break;
            case 'newFile':
                const document = await vscode.workspace.openTextDocument({
                    content: suggestion,
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
                break;
        }
    }
    async _insertCodeAtCursor(code) {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor found');
            return;
        }
        await editor.edit(editBuilder => {
            editBuilder.insert(editor.selection.active, code);
        });
    }
    async _explainCode(code) {
        try {
            const response = await this._backendService.analyzeCode(code);
            if (response.success && response.data) {
                const explanation = response.data.explanation || response.data.result;
                if (explanation) {
                    vscode.window.showInformationMessage(explanation, 'Show Details').then(selection => {
                        if (selection === 'Show Details') {
                            const outputChannel = vscode.window.createOutputChannel('Noodle AI Explanation');
                            outputChannel.appendLine('=== Code Explanation ===');
                            outputChannel.appendLine(explanation);
                            outputChannel.appendLine('========================');
                            outputChannel.show();
                        }
                    });
                }
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to explain code: ${error}`);
        }
    }
    async _fixCode(code) {
        try {
            const response = await this._backendService.executeCode(`// Fix: ${code}`);
            if (response.success && response.data) {
                const fixedCode = response.data.result || response.data.output;
                if (fixedCode) {
                    const document = await vscode.workspace.openTextDocument({
                        content: fixedCode,
                        language: 'noodle'
                    });
                    await vscode.window.showTextDocument(document);
                }
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to fix code: ${error}`);
        }
    }
    async _optimizeCode(code) {
        try {
            const response = await this._backendService.executeCode(`// Optimize: ${code}`);
            if (response.success && response.data) {
                const optimizedCode = response.data.result || response.data.output;
                if (optimizedCode) {
                    const document = await vscode.workspace.openTextDocument({
                        content: optimizedCode,
                        language: 'noodle'
                    });
                    await vscode.window.showTextDocument(document);
                }
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to optimize code: ${error}`);
        }
    }
    async _generateCode(prompt) {
        try {
            const response = await this._backendService.executeCode(`// Generate: ${prompt}`);
            if (response.success && response.data) {
                const generatedCode = response.data.result || response.data.output;
                if (generatedCode) {
                    const document = await vscode.workspace.openTextDocument({
                        content: generatedCode,
                        language: 'noodle'
                    });
                    await vscode.window.showTextDocument(document);
                }
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to generate code: ${error}`);
        }
    }
    _clearChat() {
        this._state.messages = [];
        this._sendState();
    }
    _setProvider(provider, model) {
        this._state.currentProvider = provider;
        this._state.currentModel = model;
        this._sendState();
    }
    _sendState() {
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'stateUpdate',
                state: this._state
            });
        }
    }
    _sendProviders() {
        const providers = [
            {
                id: 'openai',
                name: 'OpenAI',
                models: ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'],
                description: 'Powerful general-purpose AI models',
                capabilities: ['code-generation', 'analysis', 'explanation'],
                enabled: true,
                icon: '🤖'
            },
            {
                id: 'anthropic',
                name: 'Anthropic',
                models: ['claude-3-sonnet', 'claude-3-opus'],
                description: 'Advanced reasoning and analysis',
                capabilities: ['code-analysis', 'reasoning', 'explanation'],
                enabled: true,
                icon: '🧠'
            },
            {
                id: 'local',
                name: 'Local NoodleCore',
                models: ['noodle-ai', 'syntax-fixer', 'code-optimizer'],
                description: 'Specialized Noodle language models',
                capabilities: ['syntax-fixing', 'noodle-specific', 'optimization'],
                enabled: true,
                icon: '🍜'
            }
        ];
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'providersUpdate',
                providers: providers
            });
        }
    }
    _sendHistory() {
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'historyUpdate',
                messages: this._state.messages
            });
        }
    }
    _generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }
    _getWebviewContent() {
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Noodle AI Assistant</title>
    <style>
        :root {
            --primary-color: #007acc;
            --secondary-color: #3c3c3c;
            --accent-color: #4ec9b0;
            --background-color: var(--vscode-editor-background);
            --foreground-color: var(--vscode-foreground);
            --border-color: var(--vscode-panel-border);
            --input-background: var(--vscode-input-background);
            --button-background: var(--vscode-button-background);
            --button-foreground: var(--vscode-button-foreground);
            --hover-background: var(--vscode-button-hoverBackground);
            --selection-background: var(--vscode-editor-selectionBackground);
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--foreground-color);
            background-color: var(--background-color);
            height: 100vh;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .header {
            padding: 12px 16px;
            background-color: var(--secondary-color);
            border-bottom: 1px solid var(--border-color);
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-shrink: 0;
        }

        .header-left {
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .logo {
            font-size: 18px;
            font-weight: bold;
            color: var(--accent-color);
        }

        .provider-selector {
            display: flex;
            gap: 8px;
            align-items: center;
        }

        .provider-selector select {
            background-color: var(--input-background);
            color: var(--foreground-color);
            border: 1px solid var(--border-color);
            padding: 6px 10px;
            border-radius: 4px;
            font-size: 12px;
        }

        .status-indicator {
            display: flex;
            align-items: center;
            gap: 6px;
            font-size: 12px;
        }

        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
        }

        .status-dot.online {
            background-color: #4CAF50;
        }

        .status-dot.offline {
            background-color: #f44336;
        }

        .header-actions {
            display: flex;
            gap: 8px;
        }

        .icon-button {
            background: none;
            border: none;
            color: var(--foreground-color);
            cursor: pointer;
            padding: 6px;
            border-radius: 4px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .icon-button:hover {
            background-color: var(--hover-background);
        }

        .chat-container {
            flex: 1;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .messages {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
            display: flex;
            flex-direction: column;
            gap: 16px;
        }

        .message {
            display: flex;
            gap: 12px;
            max-width: 100%;
        }

        .message.user {
            flex-direction: row-reverse;
        }

        .message-avatar {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 16px;
            flex-shrink: 0;
        }

        .message.user .message-avatar {
            background-color: var(--primary-color);
            color: white;
        }

        .message.assistant .message-avatar {
            background-color: var(--accent-color);
            color: white;
        }

        .message-content {
            flex: 1;
            display: flex;
            flex-direction: column;
            gap: 8px;
        }

        .message-bubble {
            padding: 12px 16px;
            border-radius: 16px;
            word-wrap: break-word;
            position: relative;
        }

        .message.user .message-bubble {
            background-color: var(--primary-color);
            color: white;
            border-bottom-right-radius: 4px;
        }

        .message.assistant .message-bubble {
            background-color: var(--input-background);
            border: 1px solid var(--border-color);
            border-bottom-left-radius: 4px;
        }

        .message-meta {
            font-size: 11px;
            opacity: 0.7;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .message.user .message-meta {
            justify-content: flex-end;
        }

        .thinking-indicator {
            font-style: italic;
            opacity: 0.8;
            font-size: 12px;
            padding: 8px 12px;
            background-color: var(--input-background);
            border-radius: 8px;
            margin-bottom: 8px;
        }

        .suggestions {
            display: flex;
            flex-wrap: wrap;
            gap: 8px;
            margin-top: 8px;
        }

        .suggestion {
            background-color: var(--button-background);
            color: var(--button-foreground);
            border: none;
            padding: 6px 12px;
            border-radius: 16px;
            cursor: pointer;
            font-size: 12px;
            transition: background-color 0.2s;
        }

        .suggestion:hover {
            background-color: var(--hover-background);
        }

        .input-container {
            padding: 16px;
            border-top: 1px solid var(--border-color);
            background-color: var(--background-color);
        }

        .input-wrapper {
            display: flex;
            gap: 12px;
            align-items: flex-end;
        }

        .message-input {
            flex: 1;
            background-color: var(--input-background);
            color: var(--foreground-color);
            border: 1px solid var(--border-color);
            padding: 12px 16px;
            border-radius: 20px;
            resize: none;
            font-family: inherit;
            font-size: inherit;
            min-height: 44px;
            max-height: 120px;
            line-height: 1.4;
        }

        .message-input:focus {
            outline: none;
            border-color: var(--primary-color);
        }

        .send-button {
            background-color: var(--primary-color);
            color: white;
            border: none;
            width: 44px;
            height: 44px;
            border-radius: 50%;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: background-color 0.2s;
        }

        .send-button:hover {
            background-color: var(--hover-background);
        }

        .send-button:disabled {
            background-color: var(--border-color);
            cursor: not-allowed;
        }

        .typing-indicator {
            display: flex;
            align-items: center;
            gap: 4px;
            padding: 12px 16px;
            background-color: var(--input-background);
            border: 1px solid var(--border-color);
            border-radius: 16px;
            border-bottom-left-radius: 4px;
            margin-bottom: 8px;
        }

        .typing-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background-color: var(--foreground-color);
            opacity: 0.4;
            animation: typing 1.4s infinite ease-in-out;
        }

        .typing-dot:nth-child(1) { animation-delay: -0.32s; }
        .typing-dot:nth-child(2) { animation-delay: -0.16s; }

        @keyframes typing {
            0%, 80%, 100% { opacity: 0.4; }
            40% { opacity: 1; }
        }

        .welcome-message {
            text-align: center;
            padding: 40px 20px;
            color: var(--foreground-color);
        }

        .welcome-message h2 {
            color: var(--accent-color);
            margin-bottom: 16px;
            font-size: 24px;
        }

        .welcome-message p {
            margin-bottom: 12px;
            line-height: 1.6;
        }

        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 12px;
            margin-top: 24px;
        }

        .quick-action {
            background-color: var(--input-background);
            border: 1px solid var(--border-color);
            border-radius: 8px;
            padding: 16px;
            cursor: pointer;
            transition: all 0.2s;
        }

        .quick-action:hover {
            background-color: var(--hover-background);
            transform: translateY(-2px);
        }

        .quick-action h3 {
            margin-bottom: 8px;
            color: var(--accent-color);
        }

        .quick-action p {
            font-size: 14px;
            opacity: 0.8;
        }

        .code-block {
            background-color: var(--secondary-color);
            border-radius: 4px;
            padding: 12px;
            margin: 8px 0;
            font-family: var(--vscode-editor-font-family);
            font-size: var(--vscode-editor-font-size);
            overflow-x: auto;
        }

        .context-info {
            background-color: var(--input-background);
            border-radius: 4px;
            padding: 8px 12px;
            margin-bottom: 8px;
            font-size: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .context-info .context-icon {
            color: var(--accent-color);
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="header-left">
            <div class="logo">🍜 Noodle AI</div>
            <div class="provider-selector">
                <select id="providerSelect">
                    <option value="openai">OpenAI</option>
                    <option value="anthropic">Anthropic</option>
                    <option value="local">Local NoodleCore</option>
                </select>
                <select id="modelSelect">
                    <option value="gpt-4">GPT-4</option>
                </select>
            </div>
        </div>
        <div class="header-actions">
            <div class="status-indicator">
                <div class="status-dot online" id="statusDot"></div>
                <span id="statusText">Connected</span>
            </div>
            <button class="icon-button" id="clearButton" title="Clear Chat">🗑️</button>
            <button class="icon-button" id="settingsButton" title="Settings">⚙️</button>
        </div>
    </div>

    <div class="chat-container">
        <div class="messages" id="messages">
            <div class="welcome-message">
                <h2>🤖 Welcome to Noodle AI Assistant</h2>
                <p>I'm your intelligent coding companion for NoodleCore development. I can help you with:</p>
                <div class="quick-actions">
                    <div class="quick-action" onclick="sendQuickMessage('Explain the current code')">
                        <h3>📚 Explain Code</h3>
                        <p>Get detailed explanations of your NoodleCore code</p>
                    </div>
                    <div class="quick-action" onclick="sendQuickMessage('Fix any errors in my code')">
                        <h3>🔧 Fix Errors</h3>
                        <p>Identify and fix syntax and logic errors</p>
                    </div>
                    <div class="quick-action" onclick="sendQuickMessage('Optimize this code for performance')">
                        <h3>⚡ Optimize</h3>
                        <p>Improve code performance and efficiency</p>
                    </div>
                    <div class="quick-action" onclick="sendQuickMessage('Generate a new NoodleCore function')">
                        <h3>✨ Generate</h3>
                        <p>Create new code from natural language</p>
                    </div>
                </div>
                <div class="context-info" id="contextInfo" style="display: none;">
                    <span class="context-icon">📄</span>
                    <span id="contextText">No active file</span>
                </div>
            </div>
        </div>
    </div>

    <div class="input-container">
        <div class="input-wrapper">
            <textarea 
                class="message-input" 
                id="messageInput" 
                placeholder="Ask me anything about your NoodleCore code..."
                rows="1"
            ></textarea>
            <button class="send-button" id="sendButton">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M22 2L11 13M22 2l-7 20-4-9-9-4 20-7z"/>
                </svg>
            </button>
        </div>
    </div>

    <script>
        const vscode = acquireVsCodeApi();

        // Elements
        const messagesContainer = document.getElementById('messages');
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const clearButton = document.getElementById('clearButton');
        const settingsButton = document.getElementById('settingsButton');
        const providerSelect = document.getElementById('providerSelect');
        const modelSelect = document.getElementById('modelSelect');
        const statusDot = document.getElementById('statusDot');
        const statusText = document.getElementById('statusText');
        const contextInfo = document.getElementById('contextInfo');
        const contextText = document.getElementById('contextText');

        // State
        let currentState = {
            messages: [],
            currentProvider: 'openai',
            currentModel: 'gpt-4',
            isTyping: false,
            isThinking: false,
            context: {}
        };

        // Event listeners
        sendButton.addEventListener('click', sendMessage);
        messageInput.addEventListener('keydown', (e) => {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                sendMessage();
            }
        });
        clearButton.addEventListener('click', () => {
            vscode.postMessage({ type: 'clearChat' });
        });
        settingsButton.addEventListener('click', () => {
            vscode.postMessage({ type: 'openSettings' });
        });
        providerSelect.addEventListener('change', updateProvider);
        modelSelect.addEventListener('change', updateProvider);

        // Auto-resize textarea
        messageInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 120) + 'px';
        });

        // Message handling from extension
        window.addEventListener('message', event => {
            const message = event.data;
            
            switch (message.type) {
                case 'stateUpdate':
                    currentState = message.state;
                    updateUI();
                    break;
                case 'providersUpdate':
                    updateProviders(message.providers);
                    break;
                case 'historyUpdate':
                    currentState.messages = message.messages;
                    updateUI();
                    break;
            }
        });

        function sendMessage() {
            const content = messageInput.value.trim();
            if (!content || currentState.isTyping) return;

            vscode.postMessage({
                type: 'sendMessage',
                content: content
            });

            messageInput.value = '';
            messageInput.style.height = 'auto';
        }

        function sendQuickMessage(message) {
            messageInput.value = message;
            sendMessage();
        }

        function updateProvider() {
            vscode.postMessage({
                type: 'setProvider',
                provider: providerSelect.value,
                model: modelSelect.value
            });
        }

        function updateUI() {
            // Hide welcome message if there are messages
            const welcomeMessage = messagesContainer.querySelector('.welcome-message');
            if (currentState.messages.length > 0 && welcomeMessage) {
                welcomeMessage.style.display = 'none';
            }

            // Clear existing messages (except welcome)
            const existingMessages = messagesContainer.querySelectorAll('.message, .typing-indicator');
            existingMessages.forEach(msg => msg.remove());

            // Add messages
            currentState.messages.forEach(message => {
                addMessageToUI(message);
            });

            // Add typing indicator
            if (currentState.isTyping) {
                addTypingIndicator();
            }

            // Update controls
            providerSelect.value = currentState.currentProvider;
            modelSelect.value = currentState.currentModel;
            sendButton.disabled = currentState.isTyping;

            // Update context info
            updateContextInfo();

            // Scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }

        function addMessageToUI(message) {
            const messageDiv = document.createElement('div');
            messageDiv.className = \`message \${message.role}\`;
            
            const avatar = document.createElement('div');
            avatar.className = 'message-avatar';
            avatar.textContent = message.role === 'user' ? '👤' : '🤖';
            
            const content = document.createElement('div');
            content.className = 'message-content';
            
            const bubble = document.createElement('div');
            bubble.className = 'message-bubble';
            
            // Add thinking indicator if available
            if (message.thinking) {
                const thinking = document.createElement('div');
                thinking.className = 'thinking-indicator';
                thinking.textContent = '💭 ' + message.thinking;
                bubble.appendChild(thinking);
            }
            
            // Add message content
            const messageText = document.createElement('div');
            messageText.textContent = message.content;
            bubble.appendChild(messageText);
            
            // Add suggestions if available
            if (message.suggestions && message.suggestions.length > 0) {
                const suggestions = document.createElement('div');
                suggestions.className = 'suggestions';
                
                message.suggestions.forEach(suggestion => {
                    const button = document.createElement('button');
                    button.className = 'suggestion';
                    button.textContent = suggestion;
                    button.onclick = () => {
                        vscode.postMessage({
                            type: 'applySuggestion',
                            suggestion: suggestion,
                            suggestionType: 'insert'
                        });
                    };
                    suggestions.appendChild(button);
                });
                
                bubble.appendChild(suggestions);
            }
            
            content.appendChild(bubble);
            
            // Add metadata
            const meta = document.createElement('div');
            meta.className = 'message-meta';
            
            const time = new Date(message.timestamp).toLocaleTimeString();
            meta.textContent = time;
            
            if (message.provider && message.model) {
                const providerInfo = document.createElement('span');
                providerInfo.textContent = \`\${message.provider} - \${message.model}\`;
                meta.appendChild(providerInfo);
            }
            
            content.appendChild(meta);
            
            messageDiv.appendChild(avatar);
            messageDiv.appendChild(content);
            
            messagesContainer.appendChild(messageDiv);
        }

        function addTypingIndicator() {
            const typingDiv = document.createElement('div');
            typingDiv.className = 'message assistant';
            
            const avatar = document.createElement('div');
            avatar.className = 'message-avatar';
            avatar.textContent = '🤖';
            
            const indicator = document.createElement('div');
            indicator.className = 'typing-indicator';
            indicator.innerHTML = \`
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
                <div class="typing-dot"></div>
            \`;
            
            typingDiv.appendChild(avatar);
            typingDiv.appendChild(indicator);
            
            messagesContainer.appendChild(typingDiv);
        }

        function updateProviders(providers) {
            // Update provider options
            providerSelect.innerHTML = '';
            providers.forEach(provider => {
                if (provider.enabled) {
                    const option = document.createElement('option');
                    option.value = provider.id;
                    option.textContent = \`\${provider.icon} \${provider.name}\`;
                    providerSelect.appendChild(option);
                }
            });

            // Update model options based on selected provider
            updateModelOptions(providers);
        }

        function updateModelOptions(providers) {
            const selectedProvider = providers.find(p => p.id === providerSelect.value);
            if (selectedProvider) {
                modelSelect.innerHTML = '';
                selectedProvider.models.forEach(model => {
                    const option = document.createElement('option');
                    option.value = model;
                    option.textContent = model;
                    modelSelect.appendChild(option);
                });
            }
        }

        function updateContextInfo() {
            if (currentState.context.activeFile) {
                contextInfo.style.display = 'flex';
                const fileName = currentState.context.activeFile.split(/[\\\\/]/).pop();
                contextText.textContent = \`📄 \${fileName}\`;
                
                if (currentState.context.selectedCode) {
                    contextText.textContent += ' (selection)';
                }
            } else {
                contextInfo.style.display = 'none';
            }
        }

        // Request initial data
        vscode.postMessage({ type: 'getProviders' });
        vscode.postMessage({ type: 'getHistory' });
        vscode.postMessage({ type: 'updateContext' });
    </script>
</body>
</html>`;
    }
}
exports.ModernAIChatPanel = ModernAIChatPanel;
//# sourceMappingURL=modernAIChatPanel.js.map