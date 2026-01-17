/**
 * MINIMAL EXTENSION - Noodle VS Code Extension
 * Clean, working version with node-fetch support
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { AIProviderService, AIMessage } from './services/aiProviderService';
import { AIAssistantPanel } from './ai/aiAssistantPanel';

/**
 * AI Chat Webview Panel
 */
class AIChatPanel {
    public static currentPanel: AIChatPanel | undefined;
    private readonly _panel: vscode.WebviewPanel;
    private _disposables: vscode.Disposable[] = [];
    private _messages: AIMessage[] = [];

    public static createOrShow(
        context: vscode.ExtensionContext,
        aiService: AIProviderService
    ) {
        const column = vscode.window.activeTextEditor
            ? vscode.window.activeTextEditor.viewColumn
            : undefined;

        if (AIChatPanel.currentPanel) {
            AIChatPanel.currentPanel._panel.reveal(column);
            return;
        }

        const panel = vscode.window.createWebviewPanel(
            'noodleAIChat',
            'Noodle AI Chat',
            column || vscode.ViewColumn.One,
            {
                enableScripts: true,
                localResourceRoots: [
                    vscode.Uri.file(path.join(context.extensionPath, 'assets'))
                ]
            }
        );

        AIChatPanel.currentPanel = new AIChatPanel(panel, context, aiService);
    }

    private constructor(
        panel: vscode.WebviewPanel,
        private readonly context: vscode.ExtensionContext,
        private readonly aiService: AIProviderService
    ) {
        this._panel = panel;

        this._panel.webview.html = this._getHtmlForWebview(this._panel.webview);

        this._panel.onDidDispose(() => this.dispose(), null, this._disposables);

        this._panel.webview.onDidReceiveMessage(
            async message => {
                switch (message.command) {
                    case 'sendMessage':
                        await this.handleSendMessage(message.text);
                        break;
                }
            },
            null,
            this._disposables
        );
    }

    private async handleSendMessage(userMessage: string) {
        if (!userMessage.trim()) {
            return;
        }

        // Add user message to history
        this._messages.push({ role: 'user', content: userMessage });

        // Update UI with user message
        this._panel.webview.postMessage({
            command: 'addMessage',
            role: 'user',
            content: userMessage
        });

        // Show typing indicator
        this._panel.webview.postMessage({ command: 'showTyping' });

        try {
            // Call AI Provider Service
            const aiResponse = await this.aiService.sendMessage(this._messages);

            const response = aiResponse.content || 'No response from AI';

            // Add assistant response to history
            this._messages.push({ role: 'assistant', content: response });

            // Update UI with assistant message
            this._panel.webview.postMessage({
                command: 'addMessage',
                role: 'assistant',
                content: response
            });

        } catch (error) {
            this._panel.webview.postMessage({
                command: 'addError',
                error: (error as Error).message
            });
        }
    }

    private _getHtmlForWebview(webview: vscode.Webview): string {
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
            font-weight: var(--vscode-font-weight);
            background-color: var(--vscode-editor-background);
            color: var(--vscode-editor-foreground);
            margin: 0;
            padding: 0;
            display: flex;
            flex-direction: column;
            height: 100vh;
        }

        #chat-container {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
        }

        .message {
            margin-bottom: 16px;
            padding: 12px;
            border-radius: 8px;
            max-width: 80%;
        }

        .message.user {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            margin-left: auto;
        }

        .message.assistant {
            background-color: var(--vscode-editor-selectionBackground);
            color: var(--vscode-editor-foreground);
            margin-right: auto;
        }

        .message.error {
            background-color: var(--vscode-errorBackground);
            color: var(--vscode-errorForeground);
            border: 1px solid var(--vscode-errorBorder);
        }

        .message-label {
            font-weight: bold;
            margin-bottom: 4px;
            opacity: 0.8;
            font-size: 0.9em;
        }

        .typing {
            font-style: italic;
            opacity: 0.6;
        }

        #input-container {
            padding: 16px;
            border-top: 1px solid var(--vscode-panel-border);
            display: flex;
            gap: 8px;
        }

        #message-input {
            flex: 1;
            padding: 8px 12px;
            border: 1px solid var(--vscode-input-border);
            background-color: var(--vscode-input-background);
            color: var(--vscode-input-foreground);
            border-radius: 4px;
            font-family: inherit;
            font-size: inherit;
        }

        #send-button {
            padding: 8px 16px;
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        #send-button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }

        #send-button:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
    </style>
</head>
<body>
    <div id="chat-container"></div>
    <div id="input-container">
        <input type="text" id="message-input" placeholder="Type your message..." />
        <button id="send-button">Send</button>
    </div>

    <script>
        const vscode = acquireVsCodeApi();
        const chatContainer = document.getElementById('chat-container');
        const messageInput = document.getElementById('message-input');
        const sendButton = document.getElementById('send-button');

        function addMessage(role, content, isError = false) {
            const messageDiv = document.createElement('div');
            messageDiv.className = 'message' + (isError ? ' error' : ' ' + role);

            const label = document.createElement('div');
            label.className = 'message-label';
            label.textContent = isError ? 'Error' : (role === 'user' ? 'You' : 'Noodle AI');

            const contentDiv = document.createElement('div');
            contentDiv.textContent = content;

            messageDiv.appendChild(label);
            messageDiv.appendChild(contentDiv);
            chatContainer.appendChild(messageDiv);

            chatContainer.scrollTop = chatContainer.scrollHeight;
        }

        function showTyping() {
            const typingDiv = document.createElement('div');
            typingDiv.id = 'typing-indicator';
            typingDiv.className = 'message assistant typing';
            typingDiv.textContent = 'AI is thinking...';
            chatContainer.appendChild(typingDiv);
            chatContainer.scrollTop = chatContainer.scrollHeight;
        }

        function hideTyping() {
            const typingDiv = document.getElementById('typing-indicator');
            if (typingDiv) {
                typingDiv.remove();
            }
        }

        function sendMessage() {
            const text = messageInput.value.trim();
            if (!text) return;

            messageInput.value = '';
            sendButton.disabled = true;

            vscode.postMessage({
                command: 'sendMessage',
                text: text
            });
        }

        sendButton.addEventListener('click', sendMessage);
        messageInput.addEventListener('keypress', (e) => {
            if (e.key === 'Enter') {
                sendMessage();
            }
        });

        window.addEventListener('message', event => {
            const message = event.data;

            switch (message.command) {
                case 'addMessage':
                    hideTyping();
                    addMessage(message.role, message.content);
                    sendButton.disabled = false;
                    break;

                case 'addError':
                    hideTyping();
                    addMessage('assistant', message.error, true);
                    sendButton.disabled = false;
                    break;

                case 'showTyping':
                    showTyping();
                    break;
            }
        });

        // Focus input on load
        messageInput.focus();
    </script>
</body>
</html>`;
    }

    public dispose() {
        AIChatPanel.currentPanel = undefined;
        this._panel.dispose();

        while (this._disposables.length) {
            const disposable = this._disposables.pop();
            if (disposable) {
                disposable.dispose();
            }
        }
    }
}

/**
 * Noodle Extension Minimal
 */
export class NoodleExtensionMinimal {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private isActivated = false;

    // Core services
    private aiProviderService: AIProviderService;

    // UI components
    private statusBarItem: vscode.StatusBarItem;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Extension');
    }

    /**
     * Activate the extension
     */
    public async activate(): Promise<void> {
        try {
            if (this.isActivated) {
                return;
            }

            this.outputChannel.appendLine('=== Noodle Extension Activation Started ===');

            // Step 1: Create Status Bar
            this.outputChannel.appendLine('Creating status bar...');
            this.statusBarItem = vscode.window.createStatusBarItem(
                vscode.StatusBarAlignment.Right,
                100
            );
            this.statusBarItem.text = '$(server) Noodle';
            this.statusBarItem.tooltip = 'Noodle Extension';
            this.statusBarItem.command = 'noodle.showStatus';
            this.statusBarItem.show();
            this.outputChannel.appendLine('âœ“ Status bar created');

            // Step 2: Initialize AI Provider Service
            this.outputChannel.appendLine('Initializing AI provider service...');
            try {
                const config = this.getDefaultAIConfig();
                this.aiProviderService = new AIProviderService(config, this.outputChannel);
                this.outputChannel.appendLine('âœ“ AI provider service initialized');
            } catch (error) {
                this.outputChannel.appendLine(`âš  AI provider service failed: ${(error as Error).message}`);
            }

            // Step 3: Register Commands
            this.outputChannel.appendLine('Registering commands...');
            this.registerCommands();
            this.outputChannel.appendLine('âœ“ Commands registered');

            // Step 4: Show Success Message
            this.isActivated = true;
            this.outputChannel.appendLine('=== Noodle Extension Activated Successfully ===');

            void vscode.window.showInformationMessage(
                'ðŸœ Noodle Extension Active! Use noodle.ai.chat to start chatting.'
            );

        } catch (error) {
            this.outputChannel.appendLine(`âŒ CRITICAL ERROR: ${(error as Error).message}`);
            this.outputChannel.show();
            throw error;
        }
    }

    /**
     * Get default AI configuration from VS Code settings
     */
    private getDefaultAIConfig(): any {
        const config = vscode.workspace.getConfiguration('noodle.ai');
        return {
            provider: config.get('provider', 'openai'),
            apiKey: config.get('apiKey', ''),
            endpoint: config.get('endpoint', 'https://api.openai.com/v1'),
            model: config.get('model', 'gpt-4'),
            apiStyle: config.get('apiStyle', 'openai'),
            temperature: config.get('temperature', 0.7),
            maxTokens: config.get('maxTokens', 2048),
            timeout: config.get('timeout', 30000)
        };
    }

    /**
     * Register commands
     */
    private registerCommands(): void {
        const commands = [
            // Status & Info
            vscode.commands.registerCommand('noodle.showStatus', () => {
                this.showStatus();
            }),

            // AI Commands
            vscode.commands.registerCommand('noodle.ai.chat', () => {
                AIChatPanel.createOrShow(this.context, this.aiProviderService);
            }),

            vscode.commands.registerCommand('noodle.ai.assist', () => {
                AIChatPanel.createOrShow(this.context, this.aiProviderService);
            }),

            vscode.commands.registerCommand('noodle.ai.assistant', () => {
                AIAssistantPanel.createOrShow(this.context, this.aiProviderService);
            }),

            vscode.commands.registerCommand('noodle.ai.testConnection', async () => {
                await this.testAIConnection();
            }),

            vscode.commands.registerCommand('noodle.ai.showConfig', () => {
                this.showAIConfig();
            }),

            // Settings
            vscode.commands.registerCommand('noodle.settings', () => {
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
            }),

            // Development
            vscode.commands.registerCommand('noodle.development.restart', () => {
                vscode.commands.executeCommand('workbench.action.reloadWindow');
            }),

            vscode.commands.registerCommand('noodle.development.showOutput', () => {
                this.outputChannel.show();
            })
        ];

        commands.forEach(cmd => {
            this.context.subscriptions.push(cmd);
        });

        this.outputChannel.appendLine(`  Registered ${commands.length} commands`);
    }

    /**
     * Show extension status
     */
    private showStatus(): void {
        this.outputChannel.clear();
        this.outputChannel.appendLine('=== Noodle Extension Status ===\n');
        this.outputChannel.appendLine(`Extension: ${this.isActivated ? 'âœ“ Active' : 'âœ— Inactive'}`);
        this.outputChannel.appendLine(`AI Provider: ${this.aiProviderService ? 'âœ“ Initialized' : 'âœ— Not initialized'}`);
        this.outputChannel.appendLine('\n=== Commands ===');
        this.outputChannel.appendLine('â€¢ noodle.ai.chat - Open AI chat');
        this.outputChannel.appendLine('â€¢ noodle.ai.testConnection - Test AI provider');
        this.outputChannel.appendLine('â€¢ noodle.ai.showConfig - Show AI configuration');
        this.outputChannel.appendLine('â€¢ noodle.development.showOutput - Show this log');
        this.outputChannel.show();
    }

    /**
     * Test AI provider connection
     */
    private async testAIConnection(): Promise<void> {
        if (!this.aiProviderService) {
            vscode.window.showWarningMessage('AI Provider Service is not initialized');
            return;
        }

        try {
            await this.aiProviderService.sendMessage([
                { role: 'user', content: 'Hello! This is a connection test.' }
            ]);
            vscode.window.showInformationMessage('âœ“ AI provider connection successful!');
        } catch (error) {
            vscode.window.showErrorMessage(`AI provider connection failed: ${(error as Error).message}`);
        }
    }

    /**
     * Show current AI configuration
     */
    private showAIConfig(): void {
        if (!this.aiProviderService) {
            vscode.window.showWarningMessage('AI Provider Service is not initialized');
            return;
        }

        const config = vscode.workspace.getConfiguration('noodle.ai');
        const provider = config.get('provider', 'openai');
        const model = config.get('model', 'gpt-4');
        const apiKey = config.get('apiKey', '');
        const endpoint = config.get('endpoint', '');

        const message = `
Provider: ${provider}
Model: ${model}
API Key: ${apiKey ? 'âœ“ Configured' : 'âš  Not configured'}
Endpoint: ${endpoint || 'Default'}
        `.trim();

        vscode.window.showInformationMessage(message, 'Open Settings').then(selection => {
            if (selection === 'Open Settings') {
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
            }
        });
    }

    /**
     * Deactivate the extension
     */
    public async deactivate(): Promise<void> {
        this.outputChannel.appendLine('Deactivating Noodle extension...');

        if (AIChatPanel.currentPanel) {
            AIChatPanel.currentPanel.dispose();
        }

        if (this.statusBarItem) {
            this.statusBarItem.dispose();
        }

        this.outputChannel.appendLine('Noodle extension deactivated');
    }
}

/**
 * Extension activation entry point
 */
export async function activate(context: vscode.ExtensionContext): Promise<void> {
    const extension = new NoodleExtensionMinimal(context);
    await extension.activate();
}

/**
 * Extension deactivation entry point
 */
export async function deactivate(): Promise<void> {
    // Cleanup is handled by the extension class
}


