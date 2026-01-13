import * as vscode from 'vscode';
import { RoleBasedAIService, AIRole, RoleBasedAIRequest } from '../services/roleBasedAIService';

export interface ContextInfo {
    fileName: string;
    language: string;
    selection: string;
    cursorPosition: vscode.Position;
    workspaceFolders: string[];
    diagnostics: vscode.Diagnostic[];
    activeEditor: vscode.TextEditor | undefined;
    documentSymbols: vscode.DocumentSymbol[];
    workspaceSymbols: vscode.SymbolInformation[];
    recentFiles: string[];
    gitStatus?: any;
    buildStatus?: any;
    testResults?: any;
}

export interface ContextSwitchRule {
    id: string;
    name: string;
    description: string;
    conditions: {
        fileTypes?: string[];
        filePatterns?: string[];
        workspaceTypes?: string[];
        diagnostics?: string[];
        gitStatus?: string[];
        timeOfDay?: string[];
    };
    recommendedRole: string;
    priority: number;
}

export interface MemoryContext {
    userPreferences: any;
    projectKnowledge: any;
    codePatterns: any;
    recentInteractions: any;
    learningHistory: any;
    workspaceSpecific: { [key: string]: any };
}

export class ContextAwareAIAssistant {
    private roleService: RoleBasedAIService;
    private disposables: vscode.Disposable[] = [];
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private currentContext: ContextInfo;
    private memoryContext: MemoryContext;
    private contextSwitchRules: ContextSwitchRule[];
    private autoSwitchEnabled: boolean;

    constructor(private context: vscode.ExtensionContext) {
        this.roleService = new RoleBasedAIService();
        this.outputChannel = vscode.window.createOutputChannel('Noodle Context-Aware AI');
        
        this.statusBarItem = vscode.window.createStatusBarItem(
            'noodle.contextAwareAI',
            vscode.StatusBarAlignment.Right,
            105
        );

        this.currentContext = this.initializeContext();
        this.memoryContext = this.initializeMemoryContext();
        this.contextSwitchRules = this.initializeContextSwitchRules();
        this.autoSwitchEnabled = true;

        this.setupStatusBar();
        this.registerCommands();
        this.setupEventHandlers();
        this.startContextMonitoring();
    }

    /**
     * Initialize context information
     */
    private initializeContext(): ContextInfo {
        const editor = vscode.window.activeTextEditor;
        return {
            fileName: editor?.document.fileName || '',
            language: editor?.document.languageId || '',
            selection: editor?.document.getText(editor.selection) || '',
            cursorPosition: editor?.selection.active || new vscode.Position(0, 0),
            workspaceFolders: vscode.workspace.workspaceFolders?.map(f => f.uri.fsPath) || [],
            diagnostics: editor ? vscode.languages.getDiagnostics(editor.document.uri) : [],
            activeEditor: editor,
            documentSymbols: [],
            workspaceSymbols: [],
            recentFiles: [],
            gitStatus: undefined,
            buildStatus: undefined,
            testResults: undefined
        };
    }

    /**
     * Initialize memory context
     */
    private initializeMemoryContext(): MemoryContext {
        return {
            userPreferences: this.context.globalState.get('noodleUserPreferences', {}),
            projectKnowledge: this.context.workspaceState.get('noodleProjectKnowledge', {}),
            codePatterns: this.context.globalState.get('noodleCodePatterns', {}),
            recentInteractions: this.context.globalState.get('noodleRecentInteractions', []),
            learningHistory: this.context.globalState.get('noodleLearningHistory', []),
            workspaceSpecific: this.context.globalState.get('noodleWorkspaceSpecific', {})
        };
    }

    /**
     * Initialize context switch rules
     */
    private initializeContextSwitchRules(): ContextSwitchRule[] {
        return [
            {
                id: 'noodlecore-files',
                name: 'NoodleCore Files',
                description: 'Switch to NoodleCore Developer role when working with .nc files',
                conditions: {
                    fileTypes: ['noodle'],
                    filePatterns: ['*.nc', '*.noodle']
                },
                recommendedRole: 'noodlecore-developer',
                priority: 1
            },
            {
                id: 'architecture-files',
                name: 'Architecture Files',
                description: 'Switch to Code Architect role for architectural files',
                conditions: {
                    filePatterns: ['*architecture*', '*design*', '*spec*', 'README.md', 'CHANGELOG.md']
                },
                recommendedRole: 'code-architect',
                priority: 2
            },
            {
                id: 'test-files',
                name: 'Test Files',
                description: 'Switch to Code Reviewer role for test files',
                conditions: {
                    filePatterns: ['*test*', '*spec*', 'test/', 'tests/', '__tests__/']
                },
                recommendedRole: 'code-reviewer',
                priority: 3
            },
            {
                id: 'error-diagnostics',
                name: 'Error Diagnostics',
                description: 'Switch to Debugging Expert when errors are present',
                conditions: {
                    diagnostics: ['error', 'warning']
                },
                recommendedRole: 'debugging-expert',
                priority: 4
            },
            {
                id: 'git-conflict',
                name: 'Git Conflicts',
                description: 'Switch to Code Reviewer role during merge conflicts',
                conditions: {
                    gitStatus: ['conflict', 'merge']
                },
                recommendedRole: 'code-reviewer',
                priority: 5
            },
            {
                id: 'documentation',
                name: 'Documentation Files',
                description: 'Switch to Documentation Specialist for documentation files',
                conditions: {
                    filePatterns: ['*.md', '*.rst', '*.txt', 'docs/', 'documentation/']
                },
                recommendedRole: 'documentation-specialist',
                priority: 6
            },
            {
                id: 'configuration',
                name: 'Configuration Files',
                description: 'Switch to appropriate role for configuration files',
                conditions: {
                    filePatterns: ['*.json', '*.yaml', '*.yml', '*.toml', '*.ini', 'config/', '.env*']
                },
                recommendedRole: 'noodlecore-manager',
                priority: 7
            }
        ];
    }

    /**
     * Setup status bar
     */
    private setupStatusBar(): void {
        this.statusBarItem.command = 'noodle.contextAwareAI.show';
        this.statusBarItem.show();
        this.updateStatusBar();
    }

    /**
     * Update status bar
     */
    private updateStatusBar(): void {
        const currentRole = this.roleService.getCurrentRole();
        const contextScore = this.calculateContextScore();
        
        if (currentRole) {
            this.statusBarItem.text = `$(brain) ${currentRole.name} (${contextScore}%)`;
            this.statusBarItem.tooltip = `Context-Aware AI: ${currentRole.name}\nContext Match: ${contextScore}%\nAuto-switch: ${this.autoSwitchEnabled ? 'Enabled' : 'Disabled'}`;
        } else {
            this.statusBarItem.text = '$(brain) Context-Aware AI';
            this.statusBarItem.tooltip = 'Context-Aware AI Assistant';
        }
    }

    /**
     * Register commands
     */
    private registerCommands(): void {
        // Show context-aware AI assistant
        const showCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.show',
            () => this.showContextAwareAI()
        );
        this.disposables.push(showCommand);

        // Analyze current context
        const analyzeContextCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.analyzeContext',
            () => this.analyzeCurrentContext()
        );
        this.disposables.push(analyzeContextCommand);

        // Toggle auto-switch
        const toggleAutoSwitchCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.toggleAutoSwitch',
            () => this.toggleAutoSwitch()
        );
        this.disposables.push(toggleAutoSwitchCommand);

        // Force role switch
        const forceSwitchCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.forceSwitch',
            () => this.forceRoleSwitch()
        );
        this.disposables.push(forceSwitchCommand);

        // Update memory context
        const updateMemoryCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.updateMemory',
            () => this.updateMemoryContext()
        );
        this.disposables.push(updateMemoryCommand);

        // Clear memory context
        const clearMemoryCommand = vscode.commands.registerCommand(
            'noodle.contextAwareAI.clearMemory',
            () => this.clearMemoryContext()
        );
        this.disposables.push(clearMemoryCommand);
    }

    /**
     * Setup event handlers
     */
    private setupEventHandlers(): void {
        // Handle active editor changes
        const activeEditorChangeDisposable = vscode.window.onDidChangeActiveTextEditor(async () => {
            await this.updateContext();
        });
        this.disposables.push(activeEditorChangeDisposable);

        // Handle document changes
        const documentChangeDisposable = vscode.workspace.onDidChangeTextDocument(async (event) => {
            if (event.document === vscode.window.activeTextEditor?.document) {
                await this.updateContext();
            }
        });
        this.disposables.push(documentChangeDisposable);

        // Handle selection changes
        const selectionChangeDisposable = vscode.window.onDidChangeTextEditorSelection(async () => {
            await this.updateContext();
        });
        this.disposables.push(selectionChangeDisposable);

        // Handle diagnostic changes
        const diagnosticChangeDisposable = vscode.languages.onDidChangeDiagnostics(async () => {
            await this.updateContext();
        });
        this.disposables.push(diagnosticChangeDisposable);

        // Handle workspace symbol changes
        const symbolChangeDisposable = vscode.workspace.onDidChangeWorkspaceSymbols(async () => {
            await this.updateContext();
        });
        this.disposables.push(symbolChangeDisposable);
    }

    /**
     * Start context monitoring
     */
    private startContextMonitoring(): void {
        // Update context every 5 seconds
        setInterval(async () => {
            await this.updateContext();
        }, 5000);
    }

    /**
     * Update current context
     */
    private async updateContext(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        const oldContext = { ...this.currentContext };
        
        this.currentContext = {
            fileName: editor?.document.fileName || '',
            language: editor?.document.languageId || '',
            selection: editor?.document.getText(editor.selection) || '',
            cursorPosition: editor?.selection.active || new vscode.Position(0, 0),
            workspaceFolders: vscode.workspace.workspaceFolders?.map(f => f.uri.fsPath) || [],
            diagnostics: editor ? vscode.languages.getDiagnostics(editor.document.uri) : [],
            activeEditor: editor,
            documentSymbols: await this.getDocumentSymbols(editor),
            workspaceSymbols: await this.getWorkspaceSymbols(),
            recentFiles: await this.getRecentFiles(),
            gitStatus: await this.getGitStatus(),
            buildStatus: await this.getBuildStatus(),
            testResults: await this.getTestResults()
        };

        // Check for context changes that might trigger role switch
        if (this.autoSwitchEnabled) {
            await this.checkForAutoRoleSwitch(oldContext, this.currentContext);
        }

        // Update role service with new context
        this.roleService.updateMemoryContext({
            currentContext: this.currentContext,
            memoryContext: this.memoryContext,
            lastUpdated: new Date().toISOString()
        });

        this.updateStatusBar();
    }

    /**
     * Get document symbols
     */
    private async getDocumentSymbols(editor: vscode.TextEditor | undefined): Promise<vscode.DocumentSymbol[]> {
        if (!editor) return [];
        
        try {
            return await vscode.commands.executeCommand(
                'vscode.executeDocumentSymbolProvider',
                editor.document.uri
            ) as vscode.DocumentSymbol[];
        } catch (error) {
            this.outputChannel.appendLine(`Failed to get document symbols: ${error}`);
            return [];
        }
    }

    /**
     * Get workspace symbols
     */
    private async getWorkspaceSymbols(): Promise<vscode.SymbolInformation[]> {
        try {
            return await vscode.commands.executeCommand(
                'vscode.executeWorkspaceSymbolProvider',
                ''
            ) as vscode.SymbolInformation[];
        } catch (error) {
            this.outputChannel.appendLine(`Failed to get workspace symbols: ${error}`);
            return [];
        }
    }

    /**
     * Get recent files
     */
    private async getRecentFiles(): Promise<string[]> {
        try {
            const history = await vscode.commands.executeCommand(
                'vscode.openRecent'
            ) as string[];
            return history || [];
        } catch (error) {
            this.outputChannel.appendLine(`Failed to get recent files: ${error}`);
            return [];
        }
    }

    /**
     * Get git status
     */
    private async getGitStatus(): Promise<any> {
        try {
            return await vscode.commands.executeCommand('git.status');
        } catch (error) {
            return undefined;
        }
    }

    /**
     * Get build status
     */
    private async getBuildStatus(): Promise<any> {
        try {
            return await vscode.commands.executeCommand('workbench.action.tasks.showTasks');
        } catch (error) {
            return undefined;
        }
    }

    /**
     * Get test results
     */
    private async getTestResults(): Promise<any> {
        try {
            return await vscode.commands.executeCommand('workbench.view.testing.focus');
        } catch (error) {
            return undefined;
        }
    }

    /**
     * Check for automatic role switch
     */
    private async checkForAutoRoleSwitch(oldContext: ContextInfo, newContext: ContextInfo): Promise<void> {
        const applicableRules = this.getApplicableRules(newContext);
        
        if (applicableRules.length === 0) return;

        // Sort by priority (lower number = higher priority)
        applicableRules.sort((a, b) => a.priority - b.priority);
        
        const topRule = applicableRules[0];
        const currentRole = this.roleService.getCurrentRole();
        
        // Only switch if recommended role is different from current
        if (currentRole && currentRole.id === topRule.recommendedRole) {
            return;
        }

        // Switch to recommended role
        const success = await this.roleService.setCurrentRole(topRule.recommendedRole);
        if (success) {
            const newRole = this.roleService.getCurrentRole();
            
            // Add to memory context
            this.memoryContext.recentInteractions.push({
                type: 'auto_role_switch',
                from: currentRole?.name || 'Unknown',
                to: newRole?.name || 'Unknown',
                rule: topRule.name,
                context: newContext,
                timestamp: new Date().toISOString()
            });

            // Save memory context
            await this.saveMemoryContext();
            
            vscode.window.showInformationMessage(
                `Auto-switched to ${newRole?.name} role: ${topRule.description}`,
                'View Details',
                'Undo'
            ).then(selection => {
                if (selection === 'View Details') {
                    this.showContextAnalysis();
                } else if (selection === 'Undo') {
                    this.roleService.setCurrentRole(currentRole?.id || '');
                }
            });
        }
    }

    /**
     * Get applicable context switch rules
     */
    private getApplicableRules(context: ContextInfo): ContextSwitchRule[] {
        return this.contextSwitchRules.filter(rule => {
            const conditions = rule.conditions;
            
            // Check file types
            if (conditions.fileTypes && !conditions.fileTypes.includes(context.language)) {
                return false;
            }
            
            // Check file patterns
            if (conditions.filePatterns) {
                const fileName = context.fileName.toLowerCase();
                const matchesPattern = conditions.filePatterns.some(pattern => {
                    const regex = new RegExp(pattern.replace(/\*/g, '.*'), 'i');
                    return regex.test(fileName);
                });
                if (!matchesPattern) return false;
            }
            
            // Check diagnostics
            if (conditions.diagnostics) {
                const hasMatchingDiagnostics = context.diagnostics.some(diag => 
                    conditions.diagnostics.includes(diag.severity)
                );
                if (!hasMatchingDiagnostics) return false;
            }
            
            // Check git status
            if (conditions.gitStatus && context.gitStatus) {
                const hasMatchingStatus = conditions.gitStatus.some(status => 
                    context.gitStatus.files.some((file: any) => file.status === status)
                );
                if (!hasMatchingStatus) return false;
            }
            
            // Check time of day
            if (conditions.timeOfDay) {
                const currentHour = new Date().getHours();
                const timeMatches = conditions.timeOfDay.some(time => {
                    switch (time) {
                        case 'morning': return currentHour >= 6 && currentHour < 12;
                        case 'afternoon': return currentHour >= 12 && currentHour < 18;
                        case 'evening': return currentHour >= 18 && currentHour < 22;
                        case 'night': return currentHour >= 22 || currentHour < 6;
                        default: return false;
                    }
                });
                if (!timeMatches) return false;
            }
            
            return true;
        });
    }

    /**
     * Calculate context score
     */
    private calculateContextScore(): number {
        const currentRole = this.roleService.getCurrentRole();
        if (!currentRole) return 0;
        
        const applicableRules = this.getApplicableRules(this.currentContext);
        const matchingRule = applicableRules.find(rule => rule.recommendedRole === currentRole.id);
        
        if (matchingRule) {
            // Higher priority = lower number, so invert for score
            return Math.max(0, 100 - (matchingRule.priority * 10));
        }
        
        return 50; // Default score if no specific rule matches
    }

    /**
     * Show context-aware AI assistant
     */
    private async showContextAwareAI(): Promise<void> {
        const panel = vscode.window.createWebviewPanel(
            'noodleContextAwareAI',
            'Noodle Context-Aware AI Assistant',
            vscode.ViewColumn.One,
            {
                enableScripts: true,
                retainContextWhenHidden: true
            }
        );

        panel.webview.html = await this.getContextAwareAIWebviewContent(panel);

        // Handle messages from webview
        panel.webview.onDidReceiveMessage(
            async (message) => {
                await this.handleWebviewMessage(message);
            }
        );
    }

    /**
     * Analyze current context
     */
    private async analyzeCurrentContext(): Promise<void> {
        await this.updateContext();
        this.showContextAnalysis();
    }

    /**
     * Show context analysis
     */
    private showContextAnalysis(): void {
        const analysis = {
            currentRole: this.roleService.getCurrentRole(),
            contextScore: this.calculateContextScore(),
            applicableRules: this.getApplicableRules(this.currentContext),
            contextInfo: this.currentContext,
            memoryContext: this.memoryContext
        };

        const panel = vscode.window.createWebviewPanel(
            'noodleContextAnalysis',
            'Context Analysis',
            vscode.ViewColumn.Two,
            {
                enableScripts: true,
                retainContextWhenHidden: false
            }
        );

        panel.webview.html = this.getContextAnalysisWebviewContent(analysis);
    }

    /**
     * Toggle auto-switch
     */
    private async toggleAutoSwitch(): Promise<void> {
        this.autoSwitchEnabled = !this.autoSwitchEnabled;
        
        const message = this.autoSwitchEnabled ? 
            'Auto role switching enabled' : 
            'Auto role switching disabled';
        
        vscode.window.showInformationMessage(message);
        this.updateStatusBar();
    }

    /**
     * Force role switch
     */
    private async forceRoleSwitch(): Promise<void> {
        const applicableRules = this.getApplicableRules(this.currentContext);
        
        if (applicableRules.length === 0) {
            vscode.window.showInformationMessage('No applicable role switch rules found for current context');
            return;
        }

        const items = applicableRules.map(rule => ({
            label: `${rule.name} (${rule.recommendedRole})`,
            description: rule.description,
            rule: rule
        }));

        const selected = await vscode.window.showQuickPick(items, {
            placeHolder: 'Select role switch rule to apply...'
        });

        if (selected) {
            const success = await this.roleService.setCurrentRole(selected.rule.recommendedRole);
            if (success) {
                vscode.window.showInformationMessage(`Switched to ${selected.rule.recommendedRole} role`);
            }
        }
    }

    /**
     * Update memory context
     */
    private async updateMemoryContext(): Promise<void> {
        const key = await vscode.window.showInputBox({
            prompt: 'Enter memory context key',
            placeHolder: 'e.g., projectType, codingStyle, preferences'
        });

        if (!key) return;

        const value = await vscode.window.showInputBox({
            prompt: `Enter value for ${key}`,
            placeHolder: 'Value to store in memory context'
        });

        if (value !== undefined) {
            this.memoryContext.workspaceSpecific[key] = value;
            await this.saveMemoryContext();
            vscode.window.showInformationMessage(`Memory context updated: ${key} = ${value}`);
        }
    }

    /**
     * Clear memory context
     */
    private async clearMemoryContext(): Promise<void> {
        const confirmation = await vscode.window.showWarningMessage(
            'Clear all memory context? This will remove all learned preferences and patterns.',
            'Clear',
            'Cancel'
        );

        if (confirmation === 'Clear') {
            this.memoryContext = this.initializeMemoryContext();
            await this.saveMemoryContext();
            vscode.window.showInformationMessage('Memory context cleared');
        }
    }

    /**
     * Save memory context
     */
    private async saveMemoryContext(): Promise<void> {
        try {
            await this.context.globalState.update('noodleUserPreferences', this.memoryContext.userPreferences);
            await this.context.workspaceState.update('noodleProjectKnowledge', this.memoryContext.projectKnowledge);
            await this.context.globalState.update('noodleCodePatterns', this.memoryContext.codePatterns);
            await this.context.globalState.update('noodleRecentInteractions', this.memoryContext.recentInteractions);
            await this.context.globalState.update('noodleLearningHistory', this.memoryContext.learningHistory);
            await this.context.globalState.update('noodleWorkspaceSpecific', this.memoryContext.workspaceSpecific);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to save memory context: ${error}`);
        }
    }

    /**
     * Handle webview messages
     */
    private async handleWebviewMessage(message: any): Promise<void> {
        switch (message.type) {
            case 'getContext':
                // Send current context to webview
                break;
            case 'switchRole':
                await this.roleService.setCurrentRole(message.roleId);
                break;
            case 'updateMemory':
                await this.updateMemoryContext();
                break;
            case 'clearMemory':
                await this.clearMemoryContext();
                break;
            case 'analyzeContext':
                await this.analyzeCurrentContext();
                break;
            case 'toggleAutoSwitch':
                await this.toggleAutoSwitch();
                break;
        }
    }

    /**
     * Get context-aware AI webview content
     */
    private async getContextAwareAIWebviewContent(panel: vscode.WebviewPanel): Promise<string> {
        const nonce = this.getNonce();
        const cspSource = [
            `default-src 'none';`,
            `script-src 'nonce-${nonce}' 'unsafe-inline';`,
            `style-src 'nonce-${nonce}' 'unsafe-inline';`
        ].join(' ');

        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="${cspSource}">
    <title>Noodle Context-Aware AI Assistant</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 20px;
            height: 100vh;
            display: flex;
            flex-direction: column;
        }
        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--vscode-panel-border);
        }
        .header h1 {
            margin: 0;
            font-size: 18px;
            color: var(--vscode-foreground);
        }
        .context-info {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            margin-bottom: 20px;
        }
        .context-card {
            border: 1px solid var(--vscode-panel-border);
            border-radius: 6px;
            padding: 16px;
        }
        .context-card h3 {
            margin-top: 0;
            color: var(--vscode-foreground);
        }
        .context-item {
            margin-bottom: 8px;
            display: flex;
            justify-content: space-between;
        }
        .context-label {
            font-weight: bold;
        }
        .context-value {
            color: var(--vscode-descriptionForeground);
        }
        .role-info {
            border: 1px solid var(--vscode-panel-border);
            border-radius: 6px;
            padding: 16px;
            margin-bottom: 20px;
        }
        .role-match {
            background-color: var(--vscode-terminal-ansiGreen);
            color: var(--vscode-terminal-background);
            padding: 4px 8px;
            border-radius: 4px;
            font-weight: bold;
        }
        .role-mismatch {
            background-color: var(--vscode-terminal-ansiRed);
            color: var(--vscode-terminal-background);
            padding: 4px 8px;
            border-radius: 4px;
        }
        .controls {
            display: flex;
            gap: 10px;
            margin-bottom: 20px;
        }
        .button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            border-radius: 4px;
            padding: 8px 16px;
            cursor: pointer;
        }
        .button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        .button.secondary {
            background-color: var(--vscode-button-secondaryBackground);
            color: var(--vscode-button-secondaryForeground);
        }
        .button.secondary:hover {
            background-color: var(--vscode-button-secondaryHoverBackground);
        }
        .auto-switch-indicator {
            display: inline-block;
            width: 8px;
            height: 8px;
            border-radius: 50%;
            margin-right: 5px;
        }
        .auto-switch-indicator.enabled {
            background-color: #4CAF50;
        }
        .auto-switch-indicator.disabled {
            background-color: #f44336;
        }
    </style>
</head>
<body>
    <div class="header">
        <h1>🧠 Context-Aware AI Assistant</h1>
        <div>
            <span class="auto-switch-indicator" id="autoSwitchIndicator"></span>
            <span id="autoSwitchText">Auto-switch: Enabled</span>
        </div>
    </div>

    <div class="context-info">
        <div class="context-card">
            <h3>📄 Current File Context</h3>
            <div class="context-item">
                <span class="context-label">File:</span>
                <span class="context-value" id="fileName">-</span>
            </div>
            <div class="context-item">
                <span class="context-label">Language:</span>
                <span class="context-value" id="language">-</span>
            </div>
            <div class="context-item">
                <span class="context-label">Selection:</span>
                <span class="context-value" id="selection">-</span>
            </div>
            <div class="context-item">
                <span class="context-label">Diagnostics:</span>
                <span class="context-value" id="diagnostics">-</span>
            </div>
        </div>
        
        <div class="context-card">
            <h3>🏗️ Workspace Context</h3>
            <div class="context-item">
                <span class="context-label">Folders:</span>
                <span class="context-value" id="workspaceFolders">-</span>
            </div>
            <div class="context-item">
                <span class="context-label">Recent Files:</span>
                <span class="context-value" id="recentFiles">-</span>
            </div>
        </div>
    </div>

    <div class="role-info">
        <h3>🤖 Current AI Role</h3>
        <div class="context-item">
            <span class="context-label">Role:</span>
            <span class="context-value" id="currentRoleName">-</span>
        </div>
        <div class="context-item">
            <span class="context-label">Context Match:</span>
            <span class="context-value" id="contextScore">-</span>
        </div>
        <div class="context-item">
            <span class="context-label">Applicable Rules:</span>
            <span class="context-value" id="applicableRules">-</span>
        </div>
    </div>

    <div class="controls">
        <button class="button" onclick="analyzeContext()">Analyze Context</button>
        <button class="button" onclick="forceSwitch()">Force Switch</button>
        <button class="button secondary" onclick="toggleAutoSwitch()">Toggle Auto-Switch</button>
        <button class="button secondary" onclick="updateMemory()">Update Memory</button>
        <button class="button secondary" onclick="clearMemory()">Clear Memory</button>
    </div>

    <script nonce="${nonce}">
        const vscode = acquireVsCodeApi();
        
        function updateUI() {
            vscode.postMessage({ type: 'getContext' });
        }

        function analyzeContext() {
            vscode.postMessage({ type: 'analyzeContext' });
        }

        function forceSwitch() {
            vscode.postMessage({ type: 'forceSwitch' });
        }

        function toggleAutoSwitch() {
            vscode.postMessage({ type: 'toggleAutoSwitch' });
        }

        function updateMemory() {
            vscode.postMessage({ type: 'updateMemory' });
        }

        function clearMemory() {
            vscode.postMessage({ type: 'clearMemory' });
        }

        // Request initial data
        updateUI();
    </script>
</body>
</html>`;
    }

    /**
     * Get context analysis webview content
     */
    private getContextAnalysisWebviewContent(analysis: any): string {
        const nonce = this.getNonce();
        const cspSource = [
            `default-src 'none';`,
            `script-src 'nonce-${nonce}' 'unsafe-inline';`,
            `style-src 'nonce-${nonce}' 'unsafe-inline';`
        ].join(' ');

        return `<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta http-equiv="Content-Security-Policy" content="${cspSource}">
    <title>Context Analysis</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 20px;
        }
        .analysis-section {
            margin-bottom: 20px;
            border: 1px solid var(--vscode-panel-border);
            border-radius: 6px;
            padding: 16px;
        }
        .analysis-section h3 {
            margin-top: 0;
            color: var(--vscode-foreground);
        }
        .rule-item {
            margin-bottom: 10px;
            padding: 8px;
            border-left: 3px solid var(--vscode-button-background);
            background-color: var(--vscode-textBlockQuote-background);
        }
        .rule-name {
            font-weight: bold;
            margin-bottom: 4px;
        }
        .rule-description {
            color: var(--vscode-descriptionForeground);
        }
        .rule-match {
            color: var(--vscode-terminal-ansiGreen);
        }
        .rule-mismatch {
            color: var(--vscode-terminal-ansiRed);
        }
    </style>
</head>
<body>
    <h2>🔍 Context Analysis</h2>
    
    <div class="analysis-section">
        <h3>Current Role Analysis</h3>
        <div class="rule-item">
            <div class="rule-name">Role:</div>
            <div>${analysis.currentRole?.name || 'None'}</div>
        </div>
        <div class="rule-item">
            <div class="rule-name">Context Match Score:</div>
            <div>${analysis.contextScore}%</div>
        </div>
    </div>

    <div class="analysis-section">
        <h3>Applicable Context Switch Rules</h3>
        ${analysis.applicableRules.map(rule => `
            <div class="rule-item">
                <div class="rule-name">${rule.name}</div>
                <div class="rule-description">${rule.description}</div>
                <div class="rule-match">
                    Priority: ${rule.priority} | Recommended: ${rule.recommendedRole}
                </div>
            </div>
        `).join('')}
    </div>

    <div class="analysis-section">
        <h3>Context Information</h3>
        <div class="rule-item">
            <div class="rule-name">File:</div>
            <div>${analysis.contextInfo.fileName || 'None'}</div>
        </div>
        <div class="rule-item">
            <div class="rule-name">Language:</div>
            <div>${analysis.contextInfo.language || 'None'}</div>
        </div>
        <div class="rule-item">
            <div class="rule-name">Diagnostics Count:</div>
            <div>${analysis.contextInfo.diagnostics.length}</div>
        </div>
    </div>
</body>
</html>`;
    }

    /**
     * Get nonce for security
     */
    private getNonce(): string {
        let text = '';
        const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (let i = 0; i < 32; i++) {
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
    }

    /**
     * Dispose context-aware AI assistant
     */
    public dispose(): void {
        this.disposables.forEach(disposable => disposable.dispose());
        this.outputChannel.dispose();
        this.statusBarItem.dispose();
        this.roleService.dispose();
    }
}