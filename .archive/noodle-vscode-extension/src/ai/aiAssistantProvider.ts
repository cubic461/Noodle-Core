/**
 * AI Assistant Provider for Noodle VS Code Extension
 * 
 * Provides AI-powered assistance including code completion, explanation,
 * refactoring, and interactive chat functionality.
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { EventEmitter } from 'events';

// Import infrastructure components
import { ServiceManager } from '../infrastructure/serviceManager';
import { ConfigurationManager } from '../infrastructure/configurationManager';
import { EventBus } from '../infrastructure/eventBus';
import { CacheManager } from '../infrastructure/cacheManager';
import { Logger } from '../infrastructure/logger';

export class AIAssistantProvider extends EventEmitter {
    private context: vscode.ExtensionContext;
    private serviceManager: ServiceManager;
    private configManager: ConfigurationManager;
    private eventBus: EventBus;
    private cacheManager: CacheManager;
    private logger: Logger;
    
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private chatPanel: vscode.WebviewPanel | undefined;
    private isInitialized = false;
    
    constructor(
        context: vscode.ExtensionContext,
        serviceManager: ServiceManager,
        configManager: ConfigurationManager,
        eventBus: EventBus,
        cacheManager: CacheManager,
        logger: Logger
    ) {
        super();
        this.context = context;
        this.serviceManager = serviceManager;
        this.configManager = configManager;
        this.eventBus = eventBus;
        this.cacheManager = cacheManager;
        this.logger = logger;
        
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI Assistant');
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.statusBarItem.text = '$(robot) AI Assistant';
        this.statusBarItem.tooltip = 'Noodle AI Assistant';
        this.statusBarItem.command = 'noodle.ai.chat';
    }
    
    /**
     * Initialize the AI Assistant
     */
    public async initialize(): Promise<void> {
        try {
            this.logger.info('Initializing AI Assistant...');
            
            // Initialize AI services
            await this.initializeAIServices();
            
            // Register event listeners
            this.registerEventListeners();
            
            // Update status
            this.statusBarItem.show();
            this.updateStatus('Ready');
            
            this.isInitialized = true;
            this.logger.info('AI Assistant initialized successfully');
            this.emit('initialized');
        } catch (error) {
            this.logger.error(`Failed to initialize AI Assistant: ${error.message}`);
            this.updateStatus('Error');
            throw error;
        }
    }
    
    /**
     * Initialize AI services
     */
    private async initializeAIServices(): Promise<void> {
        try {
            // Initialize code completion service
            await this.initializeCodeCompletion();
            
            // Initialize chat service
            await this.initializeChatService();
            
            // Initialize code analysis service
            await this.initializeCodeAnalysis();
            
            // Initialize refactoring service
            await this.initializeRefactoring();
            
            this.logger.info('AI services initialized');
        } catch (error) {
            this.logger.error(`Failed to initialize AI services: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize code completion
     */
    private async initializeCodeCompletion(): Promise<void> {
        try {
            // Register completion provider
            const completionProvider = vscode.languages.registerCompletionItemProvider(
                { scheme: 'file' },
                {
                    provideCompletionItems: async (document, position) => {
                        return this.provideCodeCompletion(document, position);
                    }
                },
                '.', ' ', '(', '"', "'"
            );
            
            this.context.subscriptions.push(completionProvider);
            this.logger.info('Code completion provider registered');
        } catch (error) {
            this.logger.error(`Failed to initialize code completion: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize chat service
     */
    private async initializeChatService(): Promise<void> {
        try {
            // Chat service will be initialized when first used
            this.logger.info('Chat service initialized');
        } catch (error) {
            this.logger.error(`Failed to initialize chat service: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize code analysis
     */
    private async initializeCodeAnalysis(): Promise<void> {
        try {
            // Register code analysis provider
            const analysisProvider = vscode.languages.registerCodeActionsProvider(
                { scheme: 'file' },
                {
                    provideCodeActions: async (document, range) => {
                        return this.provideCodeActions(document, range);
                    }
                }
            );
            
            this.context.subscriptions.push(analysisProvider);
            this.logger.info('Code analysis provider registered');
        } catch (error) {
            this.logger.error(`Failed to initialize code analysis: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize refactoring
     */
    private async initializeRefactoring(): Promise<void> {
        try {
            // Register refactoring commands
            const refactorCommand = vscode.commands.registerCommand(
                'noodle.ai.refactor',
                async () => {
                    await this.refactorCode();
                }
            );
            
            this.context.subscriptions.push(refactorCommand);
            this.logger.info('Refactoring commands registered');
        } catch (error) {
            this.logger.error(`Failed to initialize refactoring: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Register event listeners
     */
    private registerEventListeners(): void {
        // Listen to configuration changes
        this.configManager.on('changed', () => {
            this.handleConfigurationChange();
        });
        
        // Listen to service events
        this.serviceManager.on('serviceStatusChanged', (event) => {
            this.handleServiceStatusChange(event);
        });
    }
    
    /**
     * Provide code completion
     */
    private async provideCodeCompletion(
        document: vscode.TextDocument,
        position: vscode.Position
    ): Promise<vscode.CompletionItem[]> {
        try {
            const config = this.configManager.getConfiguration('ai');
            if (!config.enabled) {
                return [];
            }
            
            // Get context around cursor
            const text = document.getText();
            const offset = document.offsetAt(position);
            const prefix = text.substring(Math.max(0, offset - 1000), offset);
            const suffix = text.substring(offset, Math.min(text.length, offset + 1000));
            
            // Check cache first
            const cacheKey = `completion:${prefix.substring(prefix.length - 100)}`;
            const cached = await this.cacheManager.get(cacheKey);
            if (cached) {
                return cached;
            }
            
            // Get AI completion
            const completion = await this.getAICompletion(prefix, suffix);
            
            // Cache result
            await this.cacheManager.set(cacheKey, completion, 300); // 5 minutes
            
            return completion;
        } catch (error) {
            this.logger.error(`Code completion failed: ${error.message}`);
            return [];
        }
    }
    
    /**
     * Get AI completion
     */
    private async getAICompletion(prefix: string, suffix: string): Promise<vscode.CompletionItem[]> {
        try {
            // This would integrate with the actual AI service
            // For now, return some basic completions
            const completions: vscode.CompletionItem[] = [];
            
            // Add common completions based on context
            if (prefix.includes('function')) {
                completions.push(new vscode.CompletionItem('function name() {}', vscode.CompletionItemKind.Function));
            }
            
            if (prefix.includes('class')) {
                completions.push(new vscode.CompletionItem('class ClassName {}', vscode.CompletionItemKind.Class));
            }
            
            if (prefix.includes('import')) {
                completions.push(new vscode.CompletionItem('import module from "module"', vscode.CompletionItemKind.Module));
            }
            
            return completions;
        } catch (error) {
            this.logger.error(`AI completion failed: ${error.message}`);
            return [];
        }
    }
    
    /**
     * Provide code actions
     */
    private async provideCodeActions(
        document: vscode.TextDocument,
        range: vscode.Range
    ): Promise<vscode.CodeAction[]> {
        try {
            const actions: vscode.CodeAction[] = [];
            
            // Add explain action
            const explainAction = new vscode.CodeAction(
                'Explain Code',
                vscode.CodeActionKind.QuickFix
            );
            explainAction.command = {
                command: 'noodle.ai.explain',
                title: 'Explain Code',
                arguments: [document, range]
            };
            actions.push(explainAction);
            
            // Add refactor action
            const refactorAction = new vscode.CodeAction(
                'Refactor Code',
                vscode.CodeActionKind.Refactor
            );
            refactorAction.command = {
                command: 'noodle.ai.refactor',
                title: 'Refactor Code',
                arguments: [document, range]
            };
            actions.push(refactorAction);
            
            return actions;
        } catch (error) {
            this.logger.error(`Code actions failed: ${error.message}`);
            return [];
        }
    }
    
    /**
     * Show chat interface
     */
    public async showChat(): Promise<void> {
        try {
            if (this.chatPanel) {
                this.chatPanel.reveal();
                return;
            }
            
            // Create webview panel
            this.chatPanel = vscode.window.createWebviewPanel(
                'noodleAIChat',
                'Noodle AI Chat',
                vscode.ViewColumn.One,
                {
                    enableScripts: true,
                    retainContextWhenHidden: true,
                    localResourceRoots: [this.context.extensionUri]
                }
            );
            
            // Set webview HTML
            this.chatPanel.webview.html = this.getChatWebviewContent();
            
            // Handle messages from webview
            this.chatPanel.webview.onDidReceiveMessage(
                async (message) => {
                    await this.handleChatMessage(message);
                }
            );
            
            // Handle panel disposal
            this.chatPanel.onDidDispose(() => {
                this.chatPanel = undefined;
            });
            
            this.logger.info('Chat interface opened');
        } catch (error) {
            this.logger.error(`Failed to show chat: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to open chat: ${error.message}`);
        }
    }
    
    /**
     * Get chat webview content
     */
    private getChatWebviewContent(): string {
        return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Noodle AI Chat</title>
            <style>
                body {
                    font-family: var(--vscode-font-family);
                    background-color: var(--vscode-editor-background);
                    color: var(--vscode-editor-foreground);
                    margin: 0;
                    padding: 20px;
                }
                .container {
                    display: flex;
                    flex-direction: column;
                    height: 100vh;
                }
                .chat {
                    flex: 1;
                    overflow-y: auto;
                    border: 1px solid var(--vscode-panel-border);
                    border-radius: 4px;
                    padding: 10px;
                    margin-bottom: 10px;
                }
                .input {
                    display: flex;
                    gap: 10px;
                }
                input {
                    flex: 1;
                    padding: 8px;
                    border: 1px solid var(--vscode-input-border);
                    border-radius: 4px;
                    background-color: var(--vscode-input-background);
                    color: var(--vscode-input-foreground);
                }
                button {
                    padding: 8px 16px;
                    border: none;
                    border-radius: 4px;
                    background-color: var(--vscode-button-background);
                    color: var(--vscode-button-foreground);
                    cursor: pointer;
                }
                button:hover {
                    background-color: var(--vscode-button-hoverBackground);
                }
                .message {
                    margin-bottom: 10px;
                    padding: 8px;
                    border-radius: 4px;
                }
                .user {
                    background-color: var(--vscode-button-background);
                    text-align: right;
                }
                .assistant {
                    background-color: var(--vscode-editor-selectionBackground);
                }
                .loading {
                    font-style: italic;
                    color: var(--vscode-descriptionForeground);
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="chat" id="chat"></div>
                <div class="input">
                    <input type="text" id="messageInput" placeholder="Ask me anything about your code..." />
                    <button onclick="sendMessage()">Send</button>
                </div>
            </div>
            <script>
                const vscode = acquireVsCodeApi();
                const chat = document.getElementById('chat');
                const input = document.getElementById('messageInput');
                
                function addMessage(role, content) {
                    const message = document.createElement('div');
                    message.className = 'message ' + role;
                    message.textContent = content;
                    chat.appendChild(message);
                    chat.scrollTop = chat.scrollHeight;
                }
                
                function sendMessage() {
                    const message = input.value.trim();
                    if (!message) return;
                    
                    addMessage('user', message);
                    input.value = '';
                    
                    addMessage('assistant', 'Thinking...');
                    
                    vscode.postMessage({
                        command: 'chat',
                        message: message
                    });
                }
                
                input.addEventListener('keypress', (e) => {
                    if (e.key === 'Enter') {
                        sendMessage();
                    }
                });
                
                window.addEventListener('message', (event) => {
                    const message = event.data;
                    if (message.command === 'response') {
                        // Remove loading message
                        const loading = chat.querySelector('.loading');
                        if (loading) {
                            loading.remove();
                        }
                        
                        addMessage('assistant', message.response);
                    }
                });
            </script>
        </body>
        </html>
        `;
    }
    
    /**
     * Handle chat message
     */
    private async handleChatMessage(message: any): Promise<void> {
        try {
            if (message.command === 'chat') {
                this.updateStatus('Thinking...');
                
                // Get AI response
                const response = await this.getAIResponse(message.message);
                
                // Send response to webview
                this.chatPanel?.webview.postMessage({
                    command: 'response',
                    response: response
                });
                
                this.updateStatus('Ready');
            }
        } catch (error) {
            this.logger.error(`Chat message failed: ${error.message}`);
            this.chatPanel?.webview.postMessage({
                command: 'response',
                response: `Error: ${error.message}`
            });
            this.updateStatus('Error');
        }
    }
    
    /**
     * Get AI response
     */
    private async getAIResponse(message: string): Promise<string> {
        try {
            // This would integrate with the actual AI service
            // For now, return a simple response
            return `I understand you're asking about: "${message}". This is a placeholder response. In a real implementation, this would connect to the AI service to provide intelligent assistance.`;
        } catch (error) {
            this.logger.error(`AI response failed: ${error.message}`);
            return `Error: ${error.message}`;
        }
    }
    
    /**
     * Show assist interface
     */
    public async showAssist(): Promise<void> {
        try {
            const editor = vscode.window.activeTextEditor;
            if (!editor) {
                vscode.window.showWarningMessage('No active editor');
                return;
            }
            
            const selection = editor.selection;
            const selectedText = editor.document.getText(selection);
            
            if (!selectedText) {
                vscode.window.showWarningMessage('No text selected');
                return;
            }
            
            // Show quick pick with assist options
            const options = [
                'Explain Code',
                'Refactor Code',
                'Generate Tests',
                'Find Bugs',
                'Optimize Code',
                'Add Documentation'
            ];
            
            const selected = await vscode.window.showQuickPick(options, {
                placeHolder: 'Select an AI assistance option'
            });
            
            if (selected) {
                await this.performAssistance(selected, selectedText);
            }
        } catch (error) {
            this.logger.error(`Assist failed: ${error.message}`);
            vscode.window.showErrorMessage(`Assist failed: ${error.message}`);
        }
    }
    
    /**
     * Perform assistance
     */
    private async performAssistance(option: string, code: string): Promise<void> {
        try {
            this.updateStatus('Processing...');
            
            let result = '';
            
            switch (option) {
                case 'Explain Code':
                    result = await this.explainCode(code);
                    break;
                case 'Refactor Code':
                    result = await this.refactorCode(code);
                    break;
                case 'Generate Tests':
                    result = await this.generateTests(code);
                    break;
                case 'Find Bugs':
                    result = await this.findBugs(code);
                    break;
                case 'Optimize Code':
                    result = await this.optimizeCode(code);
                    break;
                case 'Add Documentation':
                    result = await this.addDocumentation(code);
                    break;
            }
            
            // Show result in new document
            const doc = await vscode.workspace.openTextDocument({
                content: result,
                language: 'markdown'
            });
            await vscode.window.showTextDocument(doc);
            
            this.updateStatus('Ready');
        } catch (error) {
            this.logger.error(`Assistance failed: ${error.message}`);
            vscode.window.showErrorMessage(`Assistance failed: ${error.message}`);
            this.updateStatus('Error');
        }
    }
    
    /**
     * Explain code
     */
    private async explainCode(code: string): Promise<string> {
        return `# Code Explanation\n\nThis is a placeholder explanation. In a real implementation, this would provide a detailed explanation of the selected code.\n\n\`\`\`\n${code}\n\`\`\`\n\nThe code appears to be...`;
    }
    
    /**
     * Refactor code
     */
    private async refactorCode(code: string): Promise<string> {
        return `# Refactored Code\n\nThis is a placeholder refactoring. In a real implementation, this would provide an improved version of the code.\n\n\`\`\`\n${code}\n\`\`\`\n\nRefactored version:\n\n\`\`\`\n// Improved version would go here\n\`\`\`\n\nImprovements made:\n- Better variable names\n- Improved structure\n- Added error handling`;
    }
    
    /**
     * Generate tests
     */
    private async generateTests(code: string): Promise<string> {
        return `# Generated Tests\n\nThis is a placeholder test generation. In a real implementation, this would generate comprehensive tests for the selected code.\n\n\`\`\`\n${code}\n\`\`\`\n\nGenerated tests:\n\n\`\`\`javascript\n// Test code would go here\ndescribe('Generated tests', () => {\n  it('should work correctly', () => {\n    // Test implementation\n  });\n});\n\`\`\``;
    }
    
    /**
     * Find bugs
     */
    private async findBugs(code: string): Promise<string> {
        return `# Bug Analysis\n\nThis is a placeholder bug analysis. In a real implementation, this would identify potential bugs and issues in the code.\n\n\`\`\`\n${code}\n\`\`\`\n\nPotential issues found:\n- Null pointer possibility\n- Missing error handling\n- Unreachable code`;
    }
    
    /**
     * Optimize code
     */
    private async optimizeCode(code: string): Promise<string> {
        return `# Code Optimization\n\nThis is a placeholder optimization. In a real implementation, this would provide performance improvements for the code.\n\n\`\`\`\n${code}\n\`\`\`\n\nOptimized version:\n\n\`\`\`\n// Optimized code would go here\n\`\`\`\n\nOptimizations made:\n- Reduced time complexity\n- Improved memory usage\n- Eliminated redundant operations`;
    }
    
    /**
     * Add documentation
     */
    private async addDocumentation(code: string): Promise<string> {
        return `# Documentation\n\nThis is placeholder documentation. In a real implementation, this would generate comprehensive documentation for the code.\n\n\`\`\`\n${code}\n\`\`\`\n\nGenerated documentation:\n\n## Function Description\n\nThis function...\n\n### Parameters\n- \`param1\`: Description of parameter 1\n- \`param2\`: Description of parameter 2\n\n### Returns\n- Description of return value\n\n### Example\n\`\`\`javascript\n// Example usage\nconst result = functionName(param1, param2);\n\`\`\``;
    }
    
    /**
     * Handle configuration change
     */
    private handleConfigurationChange(): void {
        const config = this.configManager.getConfiguration('ai');
        this.updateStatus(config.enabled ? 'Ready' : 'Disabled');
    }
    
    /**
     * Handle service status change
     */
    private handleServiceStatusChange(event: any): void {
        if (event.serviceId === 'ai') {
            this.updateStatus(event.status === 'healthy' ? 'Ready' : 'Error');
        }
    }
    
    /**
     * Update status
     */
    private updateStatus(status: string): void {
        this.statusBarItem.text = `$(robot) AI Assistant: ${status}`;
        this.emit('statusChanged', { status });
    }
    
    /**
     * Dispose the provider
     */
    public dispose(): void {
        this.chatPanel?.dispose();
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}