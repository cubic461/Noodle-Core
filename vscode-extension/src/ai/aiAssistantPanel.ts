/**
 * AI Assistant Panel
 * Provides quick AI actions for code in the editor
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { AIProviderService, AIMessage } from '../services/aiProviderService';

interface AIAction {
    id: string;
    label: string;
    icon: string;
    prompt: string;
    description: string;
}

export class AIAssistantPanel {
    public static currentPanel: AIAssistantPanel | undefined;
    private readonly _panel: vscode.WebviewPanel;
    private _disposables: vscode.Disposable[] = [];
    private _messages: AIMessage[] = [];

    // Available AI actions
    private static actions: AIAction[] = [
        {
            id: 'explain',
            label: 'Explain Code',
            icon: 'ðŸ“–',
            prompt: 'Please explain what this code does, how it works, and what its purpose is:',
            description: 'Get a detailed explanation of the selected code'
        },
        {
            id: 'improve',
            label: 'Improve Code',
            icon: 'âœ¨',
            prompt: 'Please improve this code. Make it cleaner, more readable, and follow best practices. Show the improved version:',
            description: 'Improve code quality and readability'
        },
        {
            id: 'optimize',
            label: 'Optimize',
            icon: 'âš¡',
            prompt: 'Please optimize this code for better performance. Consider time and space complexity:',
            description: 'Optimize code for better performance'
        },
        {
            id: 'refactor',
            label: 'Refactor',
            icon: 'ðŸ”§',
            prompt: 'Please refactor this code to be more maintainable and follow SOLID principles:',
            description: 'Refactor code for better structure'
        },
        {
            id: 'convert-noodlecore',
            label: 'Convert to NoodleCore',
            icon: 'ðŸœ',
            prompt: 'Please convert this code to NoodleCore language syntax. NoodleCore is a domain-specific language with its own patterns:',
            description: 'Convert code to NoodleCore format'
        },
        {
            id: 'find-bugs',
            label: 'Find Bugs',
            icon: 'ðŸ›',
            prompt: 'Please analyze this code for potential bugs, edge cases, and issues:',
            description: 'Find potential bugs and issues'
        },
        {
            id: 'add-tests',
            label: 'Generate Tests',
            icon: 'ðŸ§ª',
            prompt: 'Please generate comprehensive unit tests for this code using a testing framework:',
            description: 'Generate unit tests for the code'
        },
        {
            id: 'add-docs',
            label: 'Add Documentation',
            icon: 'ðŸ“',
            prompt: 'Please add comprehensive documentation including JSDoc comments and usage examples:',
            description: 'Add documentation and comments'
        },
        {
            id: 'security',
            label: 'Security Review',
            icon: 'ðŸ”’',
            prompt: 'Please analyze this code for security vulnerabilities and suggest improvements:',
            description: 'Review code for security issues'
        }
    ];

    public static createOrShow(
        context: vscode.ExtensionContext,
        aiService: AIProviderService
    ) {
        const column = vscode.window.activeTextEditor
            ? vscode.window.activeTextEditor.viewColumn
            : undefined;

        if (AIAssistantPanel.currentPanel) {
            AIAssistantPanel.currentPanel._panel.reveal(column);
            return;
        }

        const panel = vscode.window.createWebviewPanel(
            'noodleAIAssistant',
            'Noodle AI Assistant',
            column || vscode.ViewColumn.Two,
            {
                enableScripts: true,
                localResourceRoots: [
                    vscode.Uri.file(path.join(context.extensionPath, 'assets'))
                ],
                retainContextWhenHidden: true
            }
        );

        AIAssistantPanel.currentPanel = new AIAssistantPanel(panel, context, aiService);
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
                    case 'executeAction':
                        await this.executeAction(message.actionId);
                        break;
                    case 'applySuggestion':
                        await this.applySuggestion(message.code);
                        break;
                    case 'insertCode':
                        await this.insertCode(message.code);
                        break;
                    case 'copyToClipboard':
                        await vscode.env.clipboard.writeText(message.code);
                        vscode.window.showInformationMessage('Code copied to clipboard!');
                        break;
                }
            },
            null,
            this._disposables
        );

        // Listen to text editor selection changes
        vscode.window.onDidChangeTextEditorSelection(
            this.onSelectionChanged,
            null,
            this._disposables
        );
    }

    private getSelectedCode(): string {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return '';
        }

        const selection = editor.selection;
        if (selection.isEmpty) {
            return editor.document.getText();
        }

        return editor.document.getText(selection);
    }

    private getLanguage(): string {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            return 'text';
        }

        return editor.document.languageId;
    }

    private onSelectionChanged = () => {
        const selectedCode = this.getSelectedCode();
        const language = this.getLanguage();

        // Send code info to webview
        this._panel.webview.postMessage({
            command: 'updateSelection',
            code: selectedCode,
            language: language,
            hasSelection: selectedCode.length > 0
        });
    };

    private async executeAction(actionId: string) {
        const action = AIAssistantPanel.actions.find(a => a.id === actionId);
        if (!action) {
            return;
        }

        const selectedCode = this.getSelectedCode();
        if (!selectedCode) {
            vscode.window.showWarningMessage('Please select some code first!');
            return;
        }

        const language = this.getLanguage();

        // Build messages for AI
        const messages: AIMessage[] = [
            {
                role: 'system',
                content: `You are an expert programmer and code assistant. You help with ${language} code. Always provide clear, practical solutions.`
            },
            {
                role: 'user',
                content: `${action.prompt}\n\nLanguage: ${language}\n\nCode:\n\`\`\`${language}\n${selectedCode}\n\`\`\``
            }
        ];

        // Show loading state
        this._panel.webview.postMessage({
            command: 'showThinking',
            actionId: action.id
        });

        try {
            const response = await this.aiService.sendMessage(messages);

            // Display result
            this._panel.webview.postMessage({
                command: 'showResult',
                actionId: action.id,
                result: response.content
            });

        } catch (error) {
            this._panel.webview.postMessage({
                command: 'showError',
                error: (error as Error).message
            });
        }
    }

    private async applySuggestion(code: string) {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('No active editor found!');
            return;
        }

        const selection = editor.selection;
        const range = selection.isEmpty
            ? new vscode.Range(
                editor.document.positionAt(0),
                editor.document.positionAt(editor.document.getText().length)
              )
            : selection;

        await editor.edit(editBuilder => {
            editBuilder.replace(range, code);
        });

        vscode.window.showInformationMessage('Code applied successfully!');
    }

    private async insertCode(code: string) {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showWarningMessage('No active editor found!');
            return;
        }

        await editor.edit(editBuilder => {
            editBuilder.insert(editor.selection.active, code);
        });

        vscode.window.showInformationMessage('Code inserted!');
    }

    private _getHtmlForWebview(webview: vscode.Webview): string {
        const actions = AIAssistantPanel.actions;

        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Noodle AI Assistant</title>
    <style>
        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            background-color: var(--vscode-editor-background);
            color: var(--vscode-editor-foreground);
            display: flex;
            flex-direction: column;
            height: 100vh;
            overflow: hidden;
        }

        .header {
            padding: 16px;
            border-bottom: 1px solid var(--vscode-panel-border);
            background-color: var(--vscode-sideBar-background);
        }

        .header h1 {
            font-size: 18px;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .selection-info {
            margin-top: 8px;
            font-size: 12px;
            color: var(--vscode-descriptionForeground);
        }

        .selection-info.has-selection {
            color: var(--vscode-textLink-foreground);
        }

        .content {
            flex: 1;
            overflow-y: auto;
            padding: 16px;
        }

        .actions-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 12px;
            margin-bottom: 20px;
        }

        .action-button {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
            border: 1px solid var(--vscode-button-border);
            border-radius: 6px;
            padding: 16px;
            cursor: pointer;
            display: flex;
            flex-direction: column;
            gap: 8px;
            transition: all 0.2s;
        }

        .action-button:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.2);
        }

        .action-button:active {
            transform: translateY(0);
        }

        .action-button.disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .action-icon {
            font-size: 24px;
        }

        .action-label {
            font-weight: 600;
            font-size: 14px;
        }

        .action-description {
            font-size: 12px;
            opacity: 0.8;
            line-height: 1.4;
        }

        .result-section {
            margin-top: 20px;
            border-top: 1px solid var(--vscode-panel-border);
            padding-top: 16px;
        }

        .result-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }

        .result-title {
            font-weight: 600;
            font-size: 14px;
        }

        .result-actions {
            display: flex;
            gap: 8px;
        }

        .mini-button {
            padding: 4px 12px;
            border-radius: 4px;
            border: 1px solid var(--vscode-button-border);
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            cursor: pointer;
            font-size: 12px;
        }

        .mini-button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }

        .result-content {
            background-color: var(--vscode-textCodeBlock-background);
            border: 1px solid var(--vscode-panel-border);
            border-radius: 6px;
            padding: 12px;
            font-family: var(--vscode-editor-font-family);
            font-size: var(--vscode-editor-font-size);
            white-space: pre-wrap;
            word-wrap: break-word;
            max-height: 400px;
            overflow-y: auto;
        }

        .thinking-indicator {
            padding: 20px;
            text-align: center;
            opacity: 0.6;
            font-style: italic;
        }

        .error-message {
            background-color: var(--vscode-errorBackground);
            color: var(--vscode-errorForeground);
            border: 1px solid var(--vscode-errorBorder);
            border-radius: 6px;
            padding: 12px;
            margin-top: 12px;
        }

        .no-selection {
            text-align: center;
            padding: 40px;
            opacity: 0.6;
        }

        .no-selection-icon {
            font-size: 48px;
            margin-bottom: 16px;
        }

        .code-block {
            position: relative;
        }

        .code-block pre {
            margin: 0;
            white-space: pre-wrap;
            word-wrap: break-word;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>ðŸ¤– Noodle AI Assistant</h1>
        <div class="selection-info" id="selection-info">No code selected</div>
    </div>

    <div class="content" id="content">
        <div class="no-selection" id="no-selection">
            <div class="no-selection-icon">ðŸ“‹</div>
            <p>Select some code in your editor to get AI-powered assistance</p>
        </div>

        <div id="actions-container" style="display: none;">
            <div class="actions-grid">
                ${actions.map(action => `
                    <div class="action-button" onclick="executeAction('${action.id}')" id="action-${action.id}">
                        <div class="action-icon">${action.icon}</div>
                        <div class="action-label">${action.label}</div>
                        <div class="action-description">${action.description}</div>
                    </div>
                `).join('')}
            </div>

            <div class="result-section" id="result-section" style="display: none;">
                <div class="result-header">
                    <div class="result-title" id="result-title">Result</div>
                    <div class="result-actions">
                        <button class="mini-button" onclick="applySuggestion()">Apply</button>
                        <button class="mini-button" onclick="copyToClipboard()">Copy</button>
                    </div>
                </div>
                <div class="result-content" id="result-content"></div>
            </div>
        </div>
    </div>

    <script>
        const vscode = acquireVsCodeApi();
        let currentResult = '';
        let currentLanguage = '';

        function executeAction(actionId) {
            vscode.postMessage({
                command: 'executeAction',
                actionId: actionId
            });
        }

        function showThinking(actionId) {
            document.getElementById('result-section').style.display = 'block';
            document.getElementById('result-title').textContent = 'Thinking...';
            document.getElementById('result-content').innerHTML = '<div class="thinking-indicator">ðŸ¤” AI is thinking...</div>';
        }

        function showResult(actionId, result) {
            currentResult = result;
            const action = ${JSON.stringify(actions)}.find(a => a.id === actionId);
            
            document.getElementById('result-title').textContent = action.label + ' Result';
            document.getElementById('result-content').textContent = result;
        }

        function showError(error) {
            document.getElementById('result-section').style.display = 'block';
            document.getElementById('result-title').textContent = 'Error';
            document.getElementById('result-content').innerHTML = '<div class="error-message">' + error + '</div>';
        }

        function applySuggestion() {
            if (!currentResult) {
                return;
            }
            vscode.postMessage({
                command: 'applySuggestion',
                code: currentResult
            });
        }

        function copyToClipboard() {
            if (!currentResult) {
                return;
            }
            vscode.postMessage({
                command: 'copyToClipboard',
                code: currentResult
            });
        }

        function updateSelection(code, language, hasSelection) {
            const noSelectionEl = document.getElementById('no-selection');
            const actionsContainerEl = document.getElementById('actions-container');
            const selectionInfoEl = document.getElementById('selection-info');

            currentLanguage = language;

            if (hasSelection) {
                noSelectionEl.style.display = 'none';
                actionsContainerEl.style.display = 'block';
                selectionInfoEl.textContent = 'Selected: ' + code.split('\\n').length + ' lines in ' + language;
                selectionInfoEl.classList.add('has-selection');
            } else {
                noSelectionEl.style.display = 'block';
                actionsContainerEl.style.display = 'none';
                selectionInfoEl.textContent = 'No code selected';
                selectionInfoEl.classList.remove('has-selection');
            }
        }

        window.addEventListener('message', event => {
            const message = event.data;

            switch (message.command) {
                case 'showThinking':
                    showThinking(message.actionId);
                    break;
                case 'showResult':
                    showResult(message.actionId, message.result);
                    break;
                case 'showError':
                    showError(message.error);
                    break;
                case 'updateSelection':
                    updateSelection(message.code, message.language, message.hasSelection);
                    break;
            }
        });
    </script>
</body>
</html>`;
    }

    public dispose() {
        AIAssistantPanel.currentPanel = undefined;
        this._panel.dispose();

        while (this._disposables.length) {
            const disposable = this._disposables.pop();
            if (disposable) {
                disposable.dispose();
            }
        }
    }
}

