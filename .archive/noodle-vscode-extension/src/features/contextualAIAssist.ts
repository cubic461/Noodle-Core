import * as vscode from 'vscode';
import { EnhancedBackendService } from '../services/enhancedBackendService';

export interface AIAssistSuggestion {
    id: string;
    type: 'completion' | 'fix' | 'optimization' | 'explanation';
    title: string;
    description: string;
    code?: string;
    confidence: number;
    priority: 'high' | 'medium' | 'low';
}

export interface CodeContext {
    file: string;
    language: string;
    selection: {
        text: string;
        start: vscode.Position;
        end: vscode.Position;
    } | null;
    surrounding: {
        before: string;
        after: string;
    };
    diagnostics: vscode.Diagnostic[];
}

export class ContextualAIAssist {
    private disposables: vscode.Disposable[] = [];
    private backendService: EnhancedBackendService;
    private decorationType: vscode.TextEditorDecorationType;
    private statusBarItem: vscode.StatusBarItem;
    private outputChannel: vscode.OutputChannel;
    private activeSuggestions: Map<string, AIAssistSuggestion[]> = new Map();

    constructor(backendService: EnhancedBackendService) {
        this.backendService = backendService;
        this.decorationType = vscode.window.createTextEditorDecorationType({
            backgroundColor: new vscode.ThemeColor('editor.wordHighlightBackground'),
            border: '1px solid',
            borderRadius: '3px',
            borderColor: new vscode.ThemeColor('editor.wordHighlightBorder')
        });
        
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Right,
            100
        );
        this.statusBarItem.text = '$(noodle) AI Assist';
        this.statusBarItem.tooltip = 'Noodle AI Contextual Assist';
        this.statusBarItem.command = 'noodle.ai.contextual.toggle';
        
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI Contextual Assist');
        
        this.setupEventHandlers();
        this.setupCommands();
    }

    private setupEventHandlers(): void {
        // Handle document changes
        const onDidChangeTextDocument = vscode.workspace.onDidChangeTextDocument(
            this.debounce(async (event) => {
                if (event.document.languageId === 'noodle') {
                    await this.analyzeDocument(event.document);
                }
            }, 500)
        );
        this.disposables.push(onDidChangeTextDocument);

        // Handle cursor position changes
        const onDidChangeTextEditorSelection = vscode.window.onDidChangeTextEditorSelection(
            this.debounce(async (event) => {
                if (event.textEditor.document.languageId === 'noodle') {
                    await this.analyzeSelection(event.textEditor, event.selections[0]);
                }
            }, 300)
        );
        this.disposables.push(onDidChangeTextEditorSelection);

        // Handle active editor changes
        const onDidChangeActiveTextEditor = vscode.window.onDidChangeActiveTextEditor(
            async (editor) => {
                if (editor && editor.document.languageId === 'noodle') {
                    await this.analyzeDocument(editor.document);
                }
            }
        );
        this.disposables.push(onDidChangeActiveTextEditor);

        // Handle diagnostic changes
        const onDidChangeDiagnostics = vscode.languages.onDidChangeDiagnostics(
            this.debounce(async (event) => {
                for (const uri of event.uris) {
                    const document = vscode.workspace.textDocuments.find(doc => doc.uri === uri);
                    if (document && document.languageId === 'noodle') {
                        await this.analyzeDiagnostics(uri, vscode.languages.getDiagnostics(uri));
                    }
                }
            }, 500)
        );
        this.disposables.push(onDidChangeDiagnostics);
    }

    private setupCommands(): void {
        // Toggle contextual assist
        const toggleCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.toggle',
            () => this.toggleContextualAssist()
        );
        this.disposables.push(toggleCommand);

        // Get suggestions for current selection
        const getSuggestionsCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.getSuggestions',
            () => this.getSuggestionsForCurrentContext()
        );
        this.disposables.push(getSuggestionsCommand);

        // Apply suggestion
        const applySuggestionCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.applySuggestion',
            (suggestionId: string) => this.applySuggestion(suggestionId)
        );
        this.disposables.push(applySuggestionCommand);

        // Explain current code
        const explainCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.explain',
            () => this.explainCurrentCode()
        );
        this.disposables.push(explainCommand);

        // Fix current issues
        const fixCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.fix',
            () => this.fixCurrentIssues()
        );
        this.disposables.push(fixCommand);

        // Optimize current code
        const optimizeCommand = vscode.commands.registerCommand(
            'noodle.ai.contextual.optimize',
            () => this.optimizeCurrentCode()
        );
        this.disposables.push(optimizeCommand);
    }

    private async analyzeDocument(document: vscode.TextDocument): Promise<void> {
        const context = this.getDocumentContext(document);
        if (!context) return;

        try {
            // Get AI suggestions for the entire document
            const response = await this.backendService.analyzeCode(document.getText(), {
                context: {
                    activeFile: context.file,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: context.language
                },
                analysisType: 'semantics'
            });

            if (response.success && response.data) {
                this.processSuggestions(context.file, response.data.suggestions || []);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Error analyzing document: ${error}`);
        }
    }

    private async analyzeSelection(editor: vscode.TextEditor, selection: vscode.Selection): Promise<void> {
        if (selection.isEmpty) return;

        const context = this.getSelectionContext(editor, selection);
        if (!context) return;

        try {
            // Get AI suggestions for the selection
            const response = await this.backendService.analyzeCode(context.selection.text, {
                context: {
                    activeFile: context.file,
                    selectedCode: context.selection.text,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: context.language
                },
                analysisType: 'semantics'
            });

            if (response.success && response.data) {
                this.processSuggestions(context.file, response.data.suggestions || []);
                this.highlightSelection(editor, selection);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Error analyzing selection: ${error}`);
        }
    }

    private async analyzeDiagnostics(uri: vscode.Uri, diagnostics: vscode.Diagnostic[]): Promise<void> {
        const noodleDiagnostics = diagnostics.filter(diag =>
            diag.source === 'NoodleCore' || diag.source === 'noodle'
        );

        if (noodleDiagnostics.length === 0) return;

        const document = vscode.workspace.textDocuments.find(doc => doc.uri === uri);
        if (!document) return;

        try {
            // Get AI suggestions for fixing diagnostics
            const errorCodes = noodleDiagnostics.map(d => d.code).filter(Boolean) as string[];
            const response = await this.backendService.fixCode(document.getText(), {
                context: {
                    activeFile: document.fileName,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: document.languageId
                },
                fixType: 'syntax'
            });

            if (response.success && response.data) {
                this.processSuggestions(document.fileName, response.data.suggestions || []);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Error analyzing diagnostics: ${error}`);
        }
    }

    private getDocumentContext(document: vscode.TextDocument): CodeContext | null {
        return {
            file: document.fileName,
            language: document.languageId,
            selection: null,
            surrounding: {
                before: '',
                after: ''
            },
            diagnostics: vscode.languages.getDiagnostics(document.uri)
        };
    }

    private getSelectionContext(editor: vscode.TextEditor, selection: vscode.Selection): CodeContext | null {
        const document = editor.document;
        const selectionText = document.getText(selection);
        
        // Get surrounding context
        const lineCount = document.lineCount;
        const startLine = Math.max(0, selection.start.line - 3);
        const endLine = Math.min(lineCount - 1, selection.end.line + 3);
        
        const surroundingText = document.getText(
            new vscode.Range(startLine, 0, endLine, document.lineAt(endLine).text.length)
        );
        
        const selectionIndex = surroundingText.indexOf(selectionText);
        const before = surroundingText.substring(0, selectionIndex);
        const after = surroundingText.substring(selectionIndex + selectionText.length);

        return {
            file: document.fileName,
            language: document.languageId,
            selection: {
                text: selectionText,
                start: selection.start,
                end: selection.end
            },
            surrounding: { before, after },
            diagnostics: vscode.languages.getDiagnostics(document.uri)
        };
    }

    private processSuggestions(file: string, suggestions: any[]): void {
        const aiSuggestions: AIAssistSuggestion[] = suggestions.map((s, index) => ({
            id: `${file}-${index}`,
            type: s.type || 'completion',
            title: s.title || 'Suggestion',
            description: s.description || '',
            code: s.code,
            confidence: s.confidence || 0.5,
            priority: s.priority || 'medium'
        }));

        this.activeSuggestions.set(file, aiSuggestions);
        this.updateStatusBar();
        this.showSuggestionsNotification(aiSuggestions);
    }

    private highlightSelection(editor: vscode.TextEditor, selection: vscode.Selection): void {
        editor.setDecorations(this.decorationType, [selection]);
    }

    private showSuggestionsNotification(suggestions: AIAssistSuggestion[]): void {
        const highPrioritySuggestions = suggestions.filter(s => s.priority === 'high');
        
        if (highPrioritySuggestions.length > 0) {
            const message = highPrioritySuggestions.length === 1 
                ? `AI Suggestion: ${highPrioritySuggestions[0].title}`
                : `${highPrioritySuggestions.length} AI suggestions available`;
            
            vscode.window.showInformationMessage(
                message,
                'Show Suggestions',
                'Dismiss'
            ).then(selection => {
                if (selection === 'Show Suggestions') {
                    this.showSuggestionsQuickPick(suggestions);
                }
            });
        }
    }

    private showSuggestionsQuickPick(suggestions: AIAssistSuggestion[]): Promise<void> {
        const items = suggestions.map(s => ({
            label: s.title,
            description: s.description,
            detail: `Confidence: ${Math.round(s.confidence * 100)}%`,
            suggestion: s
        }));

        return vscode.window.showQuickPick(items, {
            placeHolder: 'Select an AI suggestion to apply',
            matchOnDescription: true,
            matchOnDetail: true
        }).then(selected => {
            if (selected) {
                this.applySuggestion(selected.suggestion.id);
            }
        });
    }

    private async applySuggestion(suggestionId: string): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const suggestions = this.activeSuggestions.get(editor.document.fileName) || [];
        const suggestion = suggestions.find(s => s.id === suggestionId);
        
        if (!suggestion) return;

        try {
            switch (suggestion.type) {
                case 'completion':
                await this.applyCompletion(suggestion);
                    break;
                case 'fix':
                    await this.applyFix(suggestion);
                    break;
                case 'optimization':
                    await this.applyOptimization(suggestion);
                    break;
                case 'explanation':
                    await this.showExplanation(suggestion);
                    break;
            }
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to apply suggestion: ${error}`);
        }
    }

    private async applyCompletion(suggestion: AIAssistSuggestion): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor || !suggestion.code) return;

        await editor.edit(editBuilder => {
            const selection = editor.selection;
            if (selection.isEmpty) {
                editBuilder.insert(selection.active, suggestion.code);
            } else {
                editBuilder.replace(selection, suggestion.code);
            }
        });

        vscode.window.showInformationMessage(`Applied completion: ${suggestion.title}`);
    }

    private async applyFix(suggestion: AIAssistSuggestion): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor || !suggestion.code) return;

        await editor.edit(editBuilder => {
            const selection = editor.selection;
            if (selection.isEmpty) {
                // Find the problematic area and replace it
                const diagnostics = vscode.languages.getDiagnostics(editor.document.uri);
                const relevantDiag = diagnostics.find(d => 
                    d.range.contains(selection) && d.severity === vscode.DiagnosticSeverity.Error
                );
                
                if (relevantDiag) {
                    editBuilder.replace(relevantDiag.range, suggestion.code);
                } else {
                    editBuilder.insert(selection.active, suggestion.code);
                }
            } else {
                editBuilder.replace(selection, suggestion.code);
            }
        });

        vscode.window.showInformationMessage(`Applied fix: ${suggestion.title}`);
    }

    private async applyOptimization(suggestion: AIAssistSuggestion): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor || !suggestion.code) return;

        // Show diff for optimization
        const originalDocument = await vscode.workspace.openTextDocument({
            content: editor.document.getText(),
            language: editor.document.languageId
        });

        const optimizedDocument = await vscode.workspace.openTextDocument({
            content: suggestion.code,
            language: editor.document.languageId
        });

        // Show diff view
        vscode.commands.executeCommand(
            'vscode.diff',
            originalDocument.uri,
            optimizedDocument.uri,
            `Original vs Optimized: ${suggestion.title}`
        );
    }

    private async showExplanation(suggestion: AIAssistSuggestion): Promise<void> {
        const explanation = suggestion.description || suggestion.title;
        
        const outputChannel = vscode.window.createOutputChannel('AI Explanation');
        outputChannel.appendLine(`=== ${suggestion.title} ===`);
        outputChannel.appendLine(explanation);
        outputChannel.appendLine('=========================');
        outputChannel.show();
    }

    private async explainCurrentCode(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const selection = editor.selection;
        const code = selection.isEmpty 
            ? editor.document.getText()
            : editor.document.getText(selection);

        try {
            const response = await this.backendService.explainCode(code, {
                context: {
                    activeFile: editor.document.fileName,
                    selectedCode: selection.isEmpty ? undefined : code,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: editor.document.languageId
                },
                explanationType: 'detailed'
            });

            if (response.success && response.data) {
                const outputChannel = vscode.window.createOutputChannel('AI Code Explanation');
                outputChannel.appendLine('=== Code Explanation ===');
                outputChannel.appendLine(response.data.explanation || response.data.result);
                outputChannel.appendLine('========================');
                outputChannel.show();
            }
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to explain code: ${error}`);
        }
    }

    private async fixCurrentIssues(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const diagnostics = vscode.languages.getDiagnostics(editor.document.uri)
            .filter(d => d.severity === vscode.DiagnosticSeverity.Error);

        if (diagnostics.length === 0) {
            vscode.window.showInformationMessage('No issues found in current code');
            return;
        }

        try {
            const response = await this.backendService.fixCode(editor.document.getText(), {
                context: {
                    activeFile: editor.document.fileName,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: editor.document.languageId
                },
                fixType: 'syntax'
            });

            if (response.success && response.data) {
                const fixedCode = response.data.result || response.data.output;
                if (fixedCode) {
                    const document = await vscode.workspace.openTextDocument({
                        content: fixedCode,
                        language: editor.document.languageId
                    });
                    await vscode.window.showTextDocument(document);
                    vscode.window.showInformationMessage('Code issues have been fixed');
                }
            }
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to fix issues: ${error}`);
        }
    }

    private async optimizeCurrentCode(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const selection = editor.selection;
        const code = selection.isEmpty 
            ? editor.document.getText()
            : editor.document.getText(selection);

        try {
            const response = await this.backendService.optimizeCode(code, {
                context: {
                    activeFile: editor.document.fileName,
                    selectedCode: selection.isEmpty ? undefined : code,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: editor.document.languageId
                },
                optimizationType: 'performance'
            });

            if (response.success && response.data) {
                const optimizedCode = response.data.result || response.data.output;
                if (optimizedCode) {
                    const document = await vscode.workspace.openTextDocument({
                        content: optimizedCode,
                        language: editor.document.languageId
                    });
                    await vscode.window.showTextDocument(document);
                    vscode.window.showInformationMessage('Code has been optimized');
                }
            }
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to optimize code: ${error}`);
        }
    }

    private async getSuggestionsForCurrentContext(): Promise<void> {
        const editor = vscode.window.activeTextEditor;
        if (!editor) return;

        const suggestions = this.activeSuggestions.get(editor.document.fileName) || [];
        if (suggestions.length === 0) {
            vscode.window.showInformationMessage('No suggestions available for current context');
            return;
        }

        await this.showSuggestionsQuickPick(suggestions);
    }

    private toggleContextualAssist(): void {
        const config = vscode.workspace.getConfiguration('noodle.ai');
        const enabled = config.get('contextualAssist', true);
        
        config.update('contextualAssist', !enabled, vscode.ConfigurationTarget.Global);
        
        if (enabled) {
            vscode.window.showInformationMessage('Contextual AI Assist disabled');
        } else {
            vscode.window.showInformationMessage('Contextual AI Assist enabled');
        }
    }

    private updateStatusBar(): void {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            this.statusBarItem.hide();
            return;
        }

        const suggestions = this.activeSuggestions.get(editor.document.fileName) || [];
        const highPriorityCount = suggestions.filter(s => s.priority === 'high').length;
        
        if (highPriorityCount > 0) {
            this.statusBarItem.text = `$(noodle) AI Assist (${highPriorityCount})`;
            this.statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.errorBackground');
        } else if (suggestions.length > 0) {
            this.statusBarItem.text = `$(noodle) AI Assist (${suggestions.length})`;
            this.statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.warningBackground');
        } else {
            this.statusBarItem.text = '$(noodle) AI Assist';
            this.statusBarItem.backgroundColor = undefined;
        }
        
        this.statusBarItem.show();
    }

    private debounce<T extends (...args: any[]) => any>(
        func: T,
        wait: number
    ): (...args: Parameters<T>) => void {
        let timeout: NodeJS.Timeout;
        return (...args: Parameters<T>) => {
            clearTimeout(timeout);
            timeout = setTimeout(() => func(...args), wait);
        };
    }

    public dispose(): void {
        this.disposables.forEach(d => d.dispose());
        this.decorationType.dispose();
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}