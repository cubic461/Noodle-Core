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
exports.AIChatPanel = void 0;
const vscode = __importStar(require("vscode"));
class AIChatPanel {
    constructor(context, backendService) {
        this._disposables = [];
        this._context = context;
        this._backendService = backendService;
        this._state = {
            messages: [],
            currentProvider: 'openai',
            currentModel: 'gpt-3.5-turbo',
            isTyping: false
        };
    }
    show() {
        if (this._panel) {
            this._panel.reveal();
            return;
        }
        this._panel = vscode.window.createWebviewPanel('noodleAIChat', 'Noodle AI Chat', vscode.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true,
            localResourceRoots: [vscode.Uri.joinPath(this._context.extensionUri, 'out')]
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
        // Send initial state
        this._sendState();
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
        }
    }
    async _handleSendMessage(content) {
        if (!content.trim())
            return;
        const userMessage = {
            id: this._generateId(),
            role: 'user',
            content: content.trim(),
            timestamp: new Date()
        };
        this._state.messages.push(userMessage);
        this._state.isTyping = true;
        this._sendState();
        try {
            // Try to get response from backend first
            const backendResponse = await this._getBackendResponse(content);
            const assistantMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: backendResponse,
                timestamp: new Date(),
                provider: this._state.currentProvider,
                model: this._state.currentModel
            };
            this._state.messages.push(assistantMessage);
        }
        catch (error) {
            // Fallback to local AI service if backend fails
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
        this._sendState();
    }
    async _getBackendResponse(content) {
        try {
            const response = await this._backendService.makeAIChatRequest(content, this._state.currentProvider, this._state.currentModel, this._state.messages.slice(-10) // Last 10 messages for context
            );
            if (response.success && response.data) {
                return response.data.response || 'No response received';
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
        // Fallback response when backend is unavailable
        return `I'm sorry, but I'm currently unable to connect to the AI backend. Please ensure the NoodleCore server is running on port 8080.

Your message was: "${content}"

To use AI chat functionality:
1. Make sure the NoodleCore server is running: \`python src/noodlecore/api/server.py\`
2. Check that the server is accessible on http://127.0.0.1:8080
3. Try again once the server is available.

For now, you can use the other Noodle IDE features like code analysis and project exploration.`;
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
                enabled: true
            },
            {
                id: 'anthropic',
                name: 'Anthropic',
                models: ['claude-3-sonnet', 'claude-3-opus'],
                enabled: true
            },
            {
                id: 'local',
                name: 'Local NoodleCore',
                models: ['noodle-ai', 'syntax-fixer'],
                enabled: true
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
    <title>Noodle AI Chat</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 0;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }

        .header {
            padding: 10px;
            background-color: var(--vscode-editor-lineHighlightBackground);
            border-bottom: 1px solid var(--vscode-panel-border);
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .provider-selector {
            display: flex;
            gap: 10px;
            align-items: center;
        }

        .provider-selector select {
            background-color: var(--vscode-dropdown-background);
            color: var(--vscode-dropdown-foreground);
            border: 1px solid var(--vscode-dropdown-border);
            padding: 4px 8px;
            border-radius: 4px;
        }

        .clear-button {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
            border: none;
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
        }

        .clear-button:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }

        .messages {
            flex: 1;
            overflow-y: auto;
            padding: 20px;
            display: flex;
            flex-direction: column;
            gap: 15px;
        }

        .message {
            max-width: 80%;
            padding: 12px 16px;
            border-radius: 12px;
            word-wrap: break-word;
        }

        .message.user {
            align-self: flex-end;
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }

        .message.assistant {
            align-self: flex-start;
            background-color: var(--vscode-input-background);
            border: 1px solid var(--vscode-input-border);
        }

        .message.system {
            align-self: center;
            background-color: var(--vscode-notifications-background);
            color: var(--vscode-notifications-foreground);
            font-style: italic;
            text-align: center;
        }

        .message-meta {
            font-size: 0.8em;
            opacity: 0.7;
            margin-top: 5px;
        }

        .input-container {
            padding: 15px;
            border-top: 1px solid var(--vscode-panel-border);
            display: flex;
            gap: 10px;
        }

        .message-input {
            flex: 1;
            background-color: var(--vscode-input-background);
            color: var(--vscode-input-foreground);
            border: 1px solid var(--vscode-input-border);
            padding: 10px;
            border-radius: 6px;
            resize: none;
            font-family: inherit;
            font-size: inherit;
        }

        .send-button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            padding: 10px 20px;
            border-radius: 6px;
            cursor: pointer;
        }

        .send-button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }

        .send-button:disabled {
            background-color: var(--vscode-button-secondaryBackground);
            cursor: not-allowed;
        }

        .typing-indicator {
            align-self: flex-start;
            background-color: var(--vscode-input-background);
            border: 1px solid var(--vscode-input-border);
            padding: 12px 16px;
            border-radius: 12px;
            font-style: italic;
            opacity: 0.7;
        }

        .welcome-message {
            text-align: center;
            padding: 40px;
            color: var(--vscode-descriptionForeground);
        }

        .welcome-message h2 {
            color: var(--vscode-foreground);
            margin-bottom: 10px;
        }

        .status-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 5px;
        }

        .status-indicator.online {
            background-color: #4CAF50;
        }

        .status-indicator.offline {
            background-color: #f44336;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="provider-selector">
            <span class="status-indicator" id="statusIndicator"></span>
            <select id="providerSelect">
                <option value="openai">OpenAI</option>
                <option value="anthropic">Anthropic</option>
                <option value="local">Local NoodleCore</option>
            </select>
            <select id="modelSelect">
                <option value="gpt-3.5-turbo">GPT-3.5 Turbo</option>
                <option value="gpt-4">GPT-4</option>
            </select>
        </div>
        <button class="clear-button" id="clearButton">Clear Chat</button>
    </div>

    <div class="messages" id="messages">
        <div class="welcome-message">
            <h2>🤖 Noodle AI Chat</h2>
            <p>Welcome to the Noodle AI Assistant! I can help you with:</p>
            <ul style="text-align: left; max-width: 400px; margin: 0 auto;">
                <li>Code analysis and debugging</li>
                <li>Noodle language questions</li>
                <li>Project structure exploration</li>
                <li>Syntax fixing and improvements</li>
                <li>General programming assistance</li>
            </ul>
            <p style="margin-top: 20px;">
                <strong>Note:</strong> This requires the NoodleCore server to be running on port 8080.
            </p>
        </div>
    </div>

    <div class="input-container">
        <textarea 
            class="message-input" 
            id="messageInput" 
            placeholder="Ask me anything about your code..."
            rows="3"
        ></textarea>
        <button class="send-button" id="sendButton">Send</button>
    </div>

    <script>
        const vscode = acquireVsCodeApi();

        // Elements
        const messagesContainer = document.getElementById('messages');
        const messageInput = document.getElementById('messageInput');
        const sendButton = document.getElementById('sendButton');
        const clearButton = document.getElementById('clearButton');
        const providerSelect = document.getElementById('providerSelect');
        const modelSelect = document.getElementById('modelSelect');
        const statusIndicator = document.getElementById('statusIndicator');

        // State
        let currentState = {
            messages: [],
            currentProvider: 'openai',
            currentModel: 'gpt-3.5-turbo',
            isTyping: false
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
        providerSelect.addEventListener('change', updateProvider);
        modelSelect.addEventListener('change', updateProvider);

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

        function updateProvider() {
            vscode.postMessage({
                type: 'setProvider',
                provider: providerSelect.value,
                model: modelSelect.value
            });
        }

        function updateUI() {
            // Clear messages except welcome
            while (messagesContainer.firstChild && !messagesContainer.firstChild.classList.contains('welcome-message')) {
                messagesContainer.removeChild(messagesContainer.lastChild);
            }

            // Hide welcome message if there are messages
            if (currentState.messages.length > 0) {
                const welcomeMessage = messagesContainer.querySelector('.welcome-message');
                if (welcomeMessage) {
                    welcomeMessage.style.display = 'none';
                }
            }

            // Add messages
            currentState.messages.forEach(message => {
                addMessageToUI(message);
            });

            // Add typing indicator
            if (currentState.isTyping) {
                const typingDiv = document.createElement('div');
                typingDiv.className = 'typing-indicator';
                typingDiv.textContent = 'AI is thinking...';
                typingDiv.id = 'typingIndicator';
                messagesContainer.appendChild(typingDiv);
            } else {
                const typingIndicator = document.getElementById('typingIndicator');
                if (typingIndicator) {
                    typingIndicator.remove();
                }
            }

            // Update controls
            providerSelect.value = currentState.currentProvider;
            modelSelect.value = currentState.currentModel;
            sendButton.disabled = currentState.isTyping;

            // Scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;

            // Update status indicator
            updateStatusIndicator();
        }

        function addMessageToUI(message) {
            const messageDiv = document.createElement('div');
            messageDiv.className = \`message \${message.role}\`;
            
            const contentDiv = document.createElement('div');
            contentDiv.textContent = message.content;
            messageDiv.appendChild(contentDiv);

            if (message.provider || message.model) {
                const metaDiv = document.createElement('div');
                metaDiv.className = 'message-meta';
                metaDiv.textContent = \`\${message.provider || 'Unknown'} - \${message.model || 'Unknown'}\`;
                messageDiv.appendChild(metaDiv);
            }

            messagesContainer.appendChild(messageDiv);
        }

        function updateProviders(providers) {
            // Update provider options
            providerSelect.innerHTML = '';
            providers.forEach(provider => {
                if (provider.enabled) {
                    const option = document.createElement('option');
                    option.value = provider.id;
                    option.textContent = provider.name;
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

        function updateStatusIndicator() {
            // Simple status check - in real implementation, this would check backend connectivity
            statusIndicator.className = 'status-indicator online';
        }

        // Auto-resize textarea
        messageInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });

        // Request initial data
        vscode.postMessage({ type: 'getProviders' });
        vscode.postMessage({ type: 'getHistory' });
    </script>
</body>
</html>`;
    }
}
exports.AIChatPanel = AIChatPanel;
//# sourceMappingURL=aiChatPanel.js.map