import * as vscode from 'vscode';
import { RoleBasedAIService, AIRole, RoleContext } from '../services/roleBasedAIService';

export interface RoleBasedChatMessage {
    id: string;
    role: 'user' | 'assistant' | 'system';
    content: string;
    timestamp: Date;
    roleId?: string;
    roleName?: string;
    provider?: string;
    model?: string;
}

export interface RoleBasedChatState {
    messages: RoleBasedChatMessage[];
    currentRole: AIRole | null;
    availableRoles: AIRole[];
    isTyping: boolean;
    showRoleSelector: boolean;
}

export class RoleBasedAIChatPanel {
    private _panel: vscode.WebviewPanel | undefined;
    private _disposables: vscode.Disposable[] = [];
    private _state: RoleBasedChatState;
    private _roleService: RoleBasedAIService;

    constructor(
        private readonly _extensionUri: vscode.Uri
    ) {
        this._roleService = new RoleBasedAIService();
        this._state = {
            messages: [],
            currentRole: null,
            availableRoles: [],
            isTyping: false,
            showRoleSelector: false
        };

        // Initialize roles
        this.initializeRoles();
    }

    /**
     * Initialize roles from service
     */
    private async initializeRoles(): Promise<void> {
        try {
            await this._roleService.initializeRoles();
            this._state.availableRoles = this._roleService.getAvailableRoles();
            this._state.currentRole = this._roleService.getCurrentRole();
        } catch (error) {
            console.error('Failed to initialize roles:', error);
        }
    }

    /**
     * Show the role-based AI chat panel
     */
    public show() {
        if (this._panel) {
            this._panel.reveal();
            return;
        }

        this._panel = vscode.window.createWebviewPanel(
            'noodleRoleBasedAIChat',
            'Noodle AI Role Assistant',
            vscode.ViewColumn.One,
            {
                enableScripts: true,
                retainContextWhenHidden: true,
                localResourceRoots: [this._extensionUri]
            }
        );

        this._panel.webview.html = this._getWebviewContent();

        // Handle messages from webview
        this._panel.webview.onDidReceiveMessage(
            async (message) => {
                await this._handleWebviewMessage(message);
            },
            undefined,
            this._disposables
        );

        // Handle panel disposal
        this._panel.onDidDispose(
            () => {
                this._panel = undefined;
                this._disposables.forEach(d => d.dispose());
                this._disposables = [];
            },
            undefined,
            this._disposables
        );

        // Send initial state
        this._sendState();
    }

    /**
     * Handle webview messages
     */
    private async _handleWebviewMessage(message: any) {
        switch (message.type) {
            case 'sendMessage':
                await this._handleSendMessage(message.content);
                break;
            case 'switchRole':
                await this._handleSwitchRole(message.roleId);
                break;
            case 'toggleRoleSelector':
                this._toggleRoleSelector();
                break;
            case 'clearChat':
                this._clearChat();
                break;
            case 'getRoleDocument':
                await this._sendRoleDocument(message.roleId);
                break;
            case 'searchRoles':
                this._searchRoles(message.query);
                break;
            case 'getConversationHistory':
                this._sendConversationHistory();
                break;
            case 'analyzeCode':
                await this._handleAnalyzeCode(message.code);
                break;
            case 'generateCode':
                await this._handleGenerateCode(message.prompt);
                break;
            case 'refactorCode':
                await this._handleRefactorCode(message.code, message.refactorType);
                break;
            case 'explainCode':
                await this._handleExplainCode(message.code);
                break;
            case 'fixCode':
                await this._handleFixCode(message.code, message.errors);
                break;
        }
    }

    /**
     * Handle sending a message
     */
    private async _handleSendMessage(content: string) {
        if (!content.trim() || !this._state.currentRole) return;

        const userMessage: RoleBasedChatMessage = {
            id: this._generateId(),
            role: 'user',
            content: content.trim(),
            timestamp: new Date(),
            roleId: this._state.currentRole?.id,
            roleName: this._state.currentRole?.name
        };

        this._state.messages.push(userMessage);
        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.makeRoleBasedRequest({
                message: content,
                role: this._state.currentRole!,
                context: this._getWorkspaceContext()
            });

            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'No response received',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name,
                provider: response.provider,
                model: response.model
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Handle role switching
     */
    private async _handleSwitchRole(roleId: string) {
        const success = await this._roleService.setCurrentRole(roleId);
        if (success) {
            this._state.currentRole = this._roleService.getCurrentRole();
            this._state.showRoleSelector = false;
            
            // Add system message about role change
            const systemMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Switched to ${this._state.currentRole?.name} role`,
                timestamp: new Date()
            };
            
            this._state.messages.push(systemMessage);
            this._sendState();
        }
    }

    /**
     * Toggle role selector visibility
     */
    private _toggleRoleSelector() {
        this._state.showRoleSelector = !this._state.showRoleSelector;
        this._sendState();
    }

    /**
     * Clear chat history
     */
    private _clearChat() {
        this._state.messages = [];
        this._roleService.clearConversationHistory();
        this._sendState();
    }

    /**
     * Send role document content
     */
    private async _sendRoleDocument(roleId: string) {
        const content = await this._roleService.getRoleDocument(roleId);
        
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'roleDocument',
                roleId: roleId,
                content: content
            });
        }
    }

    /**
     * Search roles
     */
    private _searchRoles(query: string) {
        const results = this._roleService.searchRoles(query);
        
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'roleSearchResults',
                query: query,
                results: results
            });
        }
    }

    /**
     * Send conversation history
     */
    private _sendConversationHistory() {
        const history = this._roleService.getConversationHistory();
        
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'conversationHistory',
                history: history
            });
        }
    }

    /**
     * Handle code analysis
     */
    private async _handleAnalyzeCode(code: string) {
        if (!this._state.currentRole) return;

        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.analyzeCodeWithRole(code, this._state.currentRole.id);
            
            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'Analysis complete',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Analysis error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Handle code generation
     */
    private async _handleGenerateCode(prompt: string) {
        if (!this._state.currentRole) return;

        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.generateCodeWithRole(prompt, this._state.currentRole.id);
            
            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'Code generated',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Generation error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Handle code refactoring
     */
    private async _handleRefactorCode(code: string, refactorType: string) {
        if (!this._state.currentRole) return;

        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.refactorCodeWithRole(code, refactorType, this._state.currentRole.id);
            
            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'Code refactored',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Refactoring error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Handle code explanation
     */
    private async _handleExplainCode(code: string) {
        if (!this._state.currentRole) return;

        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.explainCodeWithRole(code, this._state.currentRole.id);
            
            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'Code explained',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Explanation error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Handle code fixing
     */
    private async _handleFixCode(code: string, errors: any[]) {
        if (!this._state.currentRole) return;

        this._state.isTyping = true;
        this._sendState();

        try {
            const response = await this._roleService.fixCodeWithRole(code, errors, this._state.currentRole.id);
            
            const assistantMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'assistant',
                content: response.response || 'Code fixed',
                timestamp: new Date(),
                roleId: this._state.currentRole?.id,
                roleName: this._state.currentRole?.name
            };

            this._state.messages.push(assistantMessage);
        } catch (error) {
            const errorMessage: RoleBasedChatMessage = {
                id: this._generateId(),
                role: 'system',
                content: `Fix error: ${error}`,
                timestamp: new Date()
            };

            this._state.messages.push(errorMessage);
        }

        this._state.isTyping = false;
        this._sendState();
    }

    /**
     * Get workspace context
     */
    private _getWorkspaceContext(): any {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return {};

        return {
            filename: editor.document.fileName,
            language: editor.document.languageId,
            selection: editor.document.getText(editor.selection),
            cursorPosition: editor.selection.active,
            workspaceFolders: vscode.workspace.workspaceFolders?.map(folder => folder.uri.fsPath) || []
        };
    }

    /**
     * Send state to webview
     */
    private _sendState() {
        if (this._panel) {
            this._panel.webview.postMessage({
                type: 'stateUpdate',
                state: this._state
            });
        }
    }

    /**
     * Generate unique ID
     */
    private _generateId(): string {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    /**
     * Get webview content
     */
    private _getWebviewContent(): string {
        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Noodle AI Role Assistant</title>
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
            flex-shrink: 0;
        }

        .role-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .current-role {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            padding: 6px 12px;
            border-radius: 4px;
            cursor: pointer;
            display: flex;
            align-items: center;
            gap: 5px;
        }

        .current-role:hover {
            background-color: var(--vscode-button-hoverBackground);
        }

        .role-selector {
            position: absolute;
            top: 60px;
            right: 10px;
            background-color: var(--vscode-dropdown-background);
            border: 1px solid var(--vscode-dropdown-border);
            border-radius: 4px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.2);
            max-height: 300px;
            overflow-y: auto;
            z-index: 1000;
            min-width: 250px;
        }

        .role-item {
            padding: 10px;
            cursor: pointer;
            border-bottom: 1px solid var(--vscode-panel-border);
        }

        .role-item:hover {
            background-color: var(--vscode-list-hoverBackground);
        }

        .role-item.selected {
            background-color: var(--vscode-list-activeSelectionBackground);
            color: var(--vscode-list-activeSelectionForeground);
        }

        .role-name {
            font-weight: bold;
            margin-bottom: 4px;
        }

        .role-description {
            font-size: 0.9em;
            opacity: 0.8;
        }

        .role-category {
            font-size: 0.8em;
            color: var(--vscode-descriptionForeground);
            margin-top: 4px;
        }

        .controls {
            display: flex;
            gap: 10px;
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
            max-width: 60%;
        }

        .message-meta {
            font-size: 0.8em;
            opacity: 0.7;
            margin-top: 5px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .role-tag {
            background-color: var(--vscode-badge-background);
            color: var(--vscode-badge-foreground);
            padding: 2px 6px;
            border-radius: 3px;
            font-size: 0.8em;
        }

        .input-container {
            padding: 15px;
            border-top: 1px solid var(--vscode-panel-border);
            display: flex;
            gap: 10px;
            flex-shrink: 0;
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

        .code-actions {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }

        .code-button {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
            border: none;
            padding: 4px 8px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 0.8em;
        }

        .code-button:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }

        .hidden {
            display: none;
        }
    </style>
</head>
<body>
    <div class="header">
        <div class="role-info">
            <div class="current-role" id="currentRole">
                <span id="currentRoleName">Select Role</span>
                <span>▼</span>
            </div>
        </div>
        <div class="controls">
            <button class="clear-button" id="clearButton">Clear Chat</button>
        </div>
    </div>

    <div class="role-selector hidden" id="roleSelector"></div>

    <div class="messages" id="messages">
        <div class="welcome-message">
            <h2>🤖 Noodle AI Role Assistant</h2>
            <p>Welcome to the role-based AI assistant! Select a role to get specialized help with your NoodleCore development.</p>
            <p><strong>Available Roles:</strong></p>
            <ul style="text-align: left; max-width: 400px; margin: 0 auto;">
                <li><strong>NoodleCore Manager:</strong> Central orchestrator for IDE operations</li>
                <li><strong>Code Architect:</strong> System design and architecture guidance</li>
                <li><strong>NoodleCore Developer:</strong> Expert in NoodleCore language</li>
                <li><strong>Code Reviewer:</strong> Quality assurance and code review</li>
            </ul>
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
        const currentRole = document.getElementById('currentRole');
        const currentRoleName = document.getElementById('currentRoleName');
        const roleSelector = document.getElementById('roleSelector');

        // State
        let currentState = {
            messages: [],
            currentRole: null,
            availableRoles: [],
            isTyping: false,
            showRoleSelector: false
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
        currentRole.addEventListener('click', () => {
            vscode.postMessage({ type: 'toggleRoleSelector' });
        });

        // Close role selector when clicking outside
        document.addEventListener('click', (e) => {
            if (!currentRole.contains(e.target) && !roleSelector.contains(e.target)) {
                roleSelector.classList.add('hidden');
                currentState.showRoleSelector = false;
            }
        });

        // Message handling from extension
        window.addEventListener('message', event => {
            const message = event.data;
            
            switch (message.type) {
                case 'stateUpdate':
                    currentState = message.state;
                    updateUI();
                    break;
                case 'roleDocument':
                    showRoleDocument(message.roleId, message.content);
                    break;
                case 'roleSearchResults':
                    updateRoleSearchResults(message.query, message.results);
                    break;
                case 'conversationHistory':
                    showConversationHistory(message.history);
                    break;
            }
        });

        function sendMessage() {
            const content = messageInput.value.trim();
            if (!content || currentState.isTyping || !currentState.currentRole) return;

            vscode.postMessage({
                type: 'sendMessage',
                content: content
            });

            messageInput.value = '';
            messageInput.style.height = 'auto';
        }

        function selectRole(roleId) {
            vscode.postMessage({
                type: 'switchRole',
                roleId: roleId
            });
        }

        function showRoleDocument(roleId) {
            vscode.postMessage({
                type: 'getRoleDocument',
                roleId: roleId
            });
        }

        function updateUI() {
            // Update current role display
            if (currentState.currentRole) {
                currentRoleName.textContent = currentState.currentRole.name;
            } else {
                currentRoleName.textContent = 'Select Role';
            }

            // Update role selector visibility
            if (currentState.showRoleSelector) {
                roleSelector.classList.remove('hidden');
                renderRoleSelector();
            } else {
                roleSelector.classList.add('hidden');
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
            sendButton.disabled = currentState.isTyping || !currentState.currentRole;

            // Scroll to bottom
            messagesContainer.scrollTop = messagesContainer.scrollHeight;
        }

        function renderRoleSelector() {
            roleSelector.innerHTML = '';
            
            currentState.availableRoles.forEach(role => {
                const roleItem = document.createElement('div');
                roleItem.className = 'role-item';
                if (currentState.currentRole && currentState.currentRole.id === role.id) {
                    roleItem.classList.add('selected');
                }
                
                roleItem.innerHTML = \`
                    <div class="role-name">\${role.name}</div>
                    <div class="role-description">\${role.description}</div>
                    <div class="role-category">Category: \${role.category}</div>
                \`;
                
                roleItem.addEventListener('click', () => selectRole(role.id));
                roleSelector.appendChild(roleItem);
            });
        }

        function addMessageToUI(message) {
            // Check if message already exists
            const existingMessage = document.getElementById(message.id);
            if (existingMessage) return;

            const messageDiv = document.createElement('div');
            messageDiv.className = \`message \${message.role}\`;
            messageDiv.id = message.id;
            
            const contentDiv = document.createElement('div');
            contentDiv.textContent = message.content;
            messageDiv.appendChild(contentDiv);

            if (message.roleName || message.provider || message.model) {
                const metaDiv = document.createElement('div');
                metaDiv.className = 'message-meta';
                
                if (message.roleName) {
                    const roleTag = document.createElement('span');
                    roleTag.className = 'role-tag';
                    roleTag.textContent = message.roleName;
                    metaDiv.appendChild(roleTag);
                }
                
                const providerInfo = document.createElement('span');
                providerInfo.textContent = \`\${message.provider || 'Unknown'} - \${message.model || 'Unknown'}\`;
                metaDiv.appendChild(providerInfo);
                
                messageDiv.appendChild(metaDiv);
            }

            // Add code action buttons for assistant messages with code
            if (message.role === 'assistant' && message.content.includes('\`\`\`')) {
                const actionsDiv = document.createElement('div');
                actionsDiv.className = 'code-actions';
                
                const analyzeButton = document.createElement('button');
                analyzeButton.className = 'code-button';
                analyzeButton.textContent = 'Analyze';
                analyzeButton.onclick = () => {
                    vscode.postMessage({
                        type: 'analyzeCode',
                        code: extractCodeFromMessage(message.content)
                    });
                };
                
                actionsDiv.appendChild(analyzeButton);
                messageDiv.appendChild(actionsDiv);
            }

            messagesContainer.appendChild(messageDiv);
        }

        function extractCodeFromMessage(content) {
            const start = content.indexOf('```');
            const end = content.lastIndexOf('```');
            if (start !== -1 && end !== -1 && start < end) {
                return content.substring(start, end + 3);
            }
            return content;
        }

        function showRoleDocument(roleId, content) {
            // Create a new webview panel to show the role document
            vscode.postMessage({
                command: 'showRoleDocument',
                roleId: roleId,
                content: content
            });
        }

        function updateRoleSearchResults(query, results) {
            // Update role selector with search results
            renderRoleSelector();
        }

        function showConversationHistory(history) {
            console.log('Conversation history:', history);
        }

        // Auto-resize textarea
        messageInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = this.scrollHeight + 'px';
        });

        // Request initial state
        vscode.postMessage({ type: 'getState' });
    </script>
</body>
</html>`;
    }

    /**
     * Dispose the panel
     */
    public dispose(): void {
        if (this._panel) {
            this._panel.dispose();
        }
        this._disposables.forEach(d => d.dispose());
        this._roleService.dispose();
    }
}