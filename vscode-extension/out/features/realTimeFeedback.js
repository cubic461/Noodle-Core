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
exports.RealTimeFeedback = void 0;
const vscode = __importStar(require("vscode"));
class RealTimeFeedback {
    constructor(backendService) {
        this.disposables = [];
        this.activeFeedback = new Map();
        this.backendService = backendService;
        this.config = {
            enabled: true,
            debounceTime: 500,
            maxSuggestions: 5,
            showInline: true,
            showInStatusBar: true
        };
        this.feedbackDecorationType = vscode.window.createTextEditorDecorationType({
            backgroundColor: new vscode.ThemeColor('editor.wordHighlightBackground'),
            border: '1px solid',
            borderRadius: '3px',
            borderColor: new vscode.ThemeColor('editor.wordHighlightBorder'),
            after: {
                contentText: '',
                backgroundColor: new vscode.ThemeColor('editorHoverHighlightBackground'),
                color: new vscode.ThemeColor('editorHoverHighlightForeground'),
                margin: '2px',
                borderRadius: '3px'
            }
        });
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 95);
        this.statusBarItem.text = '$(noodle) AI Feedback';
        this.statusBarItem.tooltip = 'Real-time AI Feedback';
        this.statusBarItem.command = 'noodle.ai.feedback.toggle';
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI Feedback');
        this.setupEventHandlers();
        this.setupCommands();
        this.updateConfiguration();
    }
    setupEventHandlers() {
        // Handle text changes
        const onDidChangeTextDocument = vscode.workspace.onDidChangeTextDocument(this.debounce(async (event) => {
            if (event.document.languageId === 'noodle' && this.config.enabled) {
                await this.analyzeDocumentChange(event);
            }
        }, this.config.debounceTime));
        this.disposables.push(onDidChangeTextDocument);
        // Handle cursor position changes
        const onDidChangeTextEditorSelection = vscode.window.onDidChangeTextEditorSelection(this.debounce(async (event) => {
            if (event.textEditor.document.languageId === 'noodle' && this.config.enabled) {
                await this.analyzeCursorPosition(event.textEditor, event.selections[0]);
            }
        }, this.config.debounceTime / 2));
        this.disposables.push(onDidChangeTextEditorSelection);
        // Handle active editor changes
        const onDidChangeActiveTextEditor = vscode.window.onDidChangeActiveTextEditor(async (editor) => {
            if (editor && editor.document.languageId === 'noodle') {
                this.clearFeedback(editor.document.uri.toString());
                await this.analyzeDocument(editor.document);
            }
        });
        this.disposables.push(onDidChangeActiveTextEditor);
        // Handle configuration changes
        const onDidChangeConfiguration = vscode.workspace.onDidChangeConfiguration((event) => {
            if (event.affectsConfiguration('noodle.ai.realTimeFeedback')) {
                this.updateConfiguration();
            }
        });
        this.disposables.push(onDidChangeConfiguration);
    }
    setupCommands() {
        // Toggle feedback
        const toggleCommand = vscode.commands.registerCommand('noodle.ai.feedback.toggle', () => this.toggleFeedback());
        this.disposables.push(toggleCommand);
        // Show feedback details
        const showDetailsCommand = vscode.commands.registerCommand('noodle.ai.feedback.showDetails', () => this.showFeedbackDetails());
        this.disposables.push(showDetailsCommand);
        // Apply feedback suggestion
        const applySuggestionCommand = vscode.commands.registerCommand('noodle.ai.feedback.applySuggestion', (feedbackId) => this.applyFeedbackSuggestion(feedbackId));
        this.disposables.push(applySuggestionCommand);
        // Dismiss feedback
        const dismissCommand = vscode.commands.registerCommand('noodle.ai.feedback.dismiss', (feedbackId) => this.dismissFeedback(feedbackId));
        this.disposables.push(dismissCommand);
    }
    updateConfiguration() {
        const config = vscode.workspace.getConfiguration('noodle.ai.realTimeFeedback');
        this.config.enabled = config.get('enabled', true);
        this.config.debounceTime = config.get('debounceTime', 500);
        this.config.maxSuggestions = config.get('maxSuggestions', 5);
        this.config.showInline = config.get('showInline', true);
        this.config.showInStatusBar = config.get('showInStatusBar', true);
        if (this.config.showInStatusBar) {
            this.statusBarItem.show();
        }
        else {
            this.statusBarItem.hide();
        }
    }
    async analyzeDocumentChange(event) {
        const document = event.document;
        const feedbackId = document.uri.toString();
        // Clear previous feedback for this document
        this.clearFeedback(feedbackId);
        // Get the changed content
        const changes = event.contentChanges;
        if (changes.length === 0)
            return;
        // Analyze the most recent change
        const latestChange = changes[changes.length - 1];
        if (!latestChange || latestChange.text.length === 0)
            return;
        try {
            // Get AI feedback for the change
            const response = await this.backendService.analyzeCode(latestChange.text, {
                context: {
                    activeFile: document.fileName,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: document.languageId
                },
                analysisType: 'semantics'
            });
            if (response.success && response.data) {
                const feedbackItems = this.parseFeedbackResponse(response.data);
                this.activeFeedback.set(feedbackId, feedbackItems);
                this.showFeedback(document, feedbackItems);
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Error analyzing document change: ${error}`);
        }
    }
    async analyzeCursorPosition(editor, selection) {
        if (!editor || selection.isEmpty)
            return;
        const document = editor.document;
        const feedbackId = document.uri.toString();
        const currentPosition = selection.active;
        const currentLine = document.lineAt(currentPosition.line);
        const lineText = currentLine.text;
        try {
            // Get AI feedback for the current position
            const response = await this.backendService.analyzeCode(lineText, {
                context: {
                    activeFile: document.fileName,
                    selectedCode: lineText,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: document.languageId
                },
                analysisType: 'semantics'
            });
            if (response.success && response.data) {
                const feedbackItems = this.parseFeedbackResponse(response.data);
                // Filter feedback relevant to current position
                const positionFeedback = feedbackItems.filter(item => {
                    if (item.range) {
                        return item.range.contains(currentPosition);
                    }
                    return false;
                });
                if (positionFeedback.length > 0) {
                    this.activeFeedback.set(feedbackId, positionFeedback);
                    this.showFeedback(document, positionFeedback);
                }
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Error analyzing cursor position: ${error}`);
        }
    }
    async analyzeDocument(document) {
        const feedbackId = document.uri.toString();
        const text = document.getText();
        try {
            // Get AI feedback for the entire document
            const response = await this.backendService.analyzeCode(text, {
                context: {
                    activeFile: document.fileName,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: document.languageId
                },
                analysisType: 'semantics'
            });
            if (response.success && response.data) {
                const feedbackItems = this.parseFeedbackResponse(response.data);
                this.activeFeedback.set(feedbackId, feedbackItems);
                this.showFeedback(document, feedbackItems);
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Error analyzing document: ${error}`);
        }
    }
    parseFeedbackResponse(data) {
        const feedbackItems = [];
        if (data.suggestions && Array.isArray(data.suggestions)) {
            data.suggestions.forEach((suggestion, index) => {
                feedbackItems.push({
                    id: `feedback-${Date.now()}-${index}`,
                    type: 'suggestion',
                    title: suggestion.title || 'Suggestion',
                    message: suggestion.description || '',
                    code: suggestion.code,
                    confidence: suggestion.confidence || 0.5,
                    timestamp: new Date()
                });
            });
        }
        if (data.warnings && Array.isArray(data.warnings)) {
            data.warnings.forEach((warning, index) => {
                feedbackItems.push({
                    id: `warning-${Date.now()}-${index}`,
                    type: 'warning',
                    title: 'Warning',
                    message: warning.message || '',
                    range: warning.range ? new vscode.Range(warning.range.start.line, warning.range.start.character, warning.range.end.line, warning.range.end.character) : undefined,
                    confidence: 1.0,
                    timestamp: new Date()
                });
            });
        }
        if (data.errors && Array.isArray(data.errors)) {
            data.errors.forEach((error, index) => {
                feedbackItems.push({
                    id: `error-${Date.now()}-${index}`,
                    type: 'error',
                    title: 'Error',
                    message: error.message || '',
                    range: error.range ? new vscode.Range(error.range.start.line, error.range.start.character, error.range.end.line, error.range.end.character) : undefined,
                    confidence: 1.0,
                    timestamp: new Date()
                });
            });
        }
        // Sort by confidence and limit to max suggestions
        return feedbackItems
            .sort((a, b) => b.confidence - a.confidence)
            .slice(0, this.config.maxSuggestions);
    }
    showFeedback(editor, feedbackItems) {
        if (!this.config.enabled)
            return;
        // Clear existing decorations
        editor.setDecorations(this.feedbackDecorationType, []);
        if (!this.config.showInline) {
            this.updateStatusBar();
            return;
        }
        // Create decorations for inline feedback
        const decorations = [];
        const ranges = [];
        feedbackItems.forEach(item => {
            if (item.range) {
                ranges.push(item.range);
                let hoverMessage = `**${item.title}**\n${item.message}`;
                if (item.confidence) {
                    hoverMessage += `\n\nConfidence: ${Math.round(item.confidence * 100)}%`;
                }
                decorations.push({
                    range: item.range,
                    hoverMessage: hoverMessage
                });
            }
        });
        // Apply decorations
        editor.setDecorations(this.feedbackDecorationType, decorations);
        // Update status bar
        this.updateStatusBar();
        // Show notification for high-priority feedback
        const highPriorityItems = feedbackItems.filter(item => item.type === 'error' || (item.type === 'warning' && item.confidence > 0.8));
        if (highPriorityItems.length > 0) {
            const message = highPriorityItems.length === 1
                ? `${highPriorityItems[0].title}: ${highPriorityItems[0].message}`
                : `${highPriorityItems.length} issues detected`;
            vscode.window.showInformationMessage(message, 'Show Details', 'Dismiss').then(selection => {
                if (selection === 'Show Details') {
                    this.showFeedbackDetails();
                }
                else if (selection === 'Dismiss') {
                    this.clearFeedback(editor.document.uri.toString());
                }
            });
        }
    }
    updateStatusBar() {
        if (!this.config.showInStatusBar) {
            this.statusBarItem.hide();
            return;
        }
        let totalFeedbackCount = 0;
        let errorCount = 0;
        let warningCount = 0;
        this.activeFeedback.forEach(feedbackItems => {
            feedbackItems.forEach(item => {
                totalFeedbackCount++;
                if (item.type === 'error')
                    errorCount++;
                if (item.type === 'warning')
                    warningCount++;
            });
        });
        if (errorCount > 0) {
            this.statusBarItem.text = `$(noodle) AI Feedback (${errorCount} errors)`;
            this.statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.errorBackground');
        }
        else if (warningCount > 0) {
            this.statusBarItem.text = `$(noodle) AI Feedback (${warningCount} warnings)`;
            this.statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.warningBackground');
        }
        else if (totalFeedbackCount > 0) {
            this.statusBarItem.text = `$(noodle) AI Feedback (${totalFeedbackCount})`;
            this.statusBarItem.backgroundColor = new vscode.ThemeColor('statusBarItem.prominentBackground');
        }
        else {
            this.statusBarItem.text = '$(noodle) AI Feedback';
            this.statusBarItem.backgroundColor = undefined;
        }
        this.statusBarItem.show();
    }
    async showFeedbackDetails() {
        const editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
        const feedbackId = editor.document.uri.toString();
        const feedbackItems = this.activeFeedback.get(feedbackId) || [];
        if (feedbackItems.length === 0) {
            vscode.window.showInformationMessage('No AI feedback available for current document');
            return;
        }
        // Create quick pick for feedback items
        const items = feedbackItems.map(item => ({
            label: `${this.getTypeIcon(item.type)} ${item.title}`,
            description: item.message,
            detail: `Confidence: ${Math.round(item.confidence * 100)}%`,
            item: item
        }));
        const selected = await vscode.window.showQuickPick(items, {
            placeHolder: 'Select AI feedback to view details',
            matchOnDescription: true,
            matchOnDetail: true
        });
        if (selected) {
            await this.showFeedbackItemDetails(selected.item);
        }
    }
    async showFeedbackItemDetails(item) {
        const actions = ['Apply Suggestion', 'Dismiss'];
        if (item.type === 'error' || item.type === 'warning') {
            actions.unshift('Fix Issue');
        }
        const action = await vscode.window.showQuickPick(actions, {
            placeHolder: 'Select action for this feedback'
        });
        if (action === 'Apply Suggestion' && item.code) {
            await this.applyFeedbackSuggestion(item.id);
        }
        else if (action === 'Fix Issue') {
            await this.fixFeedbackIssue(item);
        }
        else if (action === 'Dismiss') {
            await this.dismissFeedback(item.id);
        }
    }
    async applyFeedbackSuggestion(feedbackId) {
        const editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
        const feedbackId = editor.document.uri.toString();
        const feedbackItems = this.activeFeedback.get(feedbackId) || [];
        const suggestion = feedbackItems.find(item => item.id === feedbackId);
        if (!suggestion || !suggestion.code)
            return;
        try {
            await editor.edit(editBuilder => {
                const selection = editor.selection;
                if (selection.isEmpty) {
                    editBuilder.insert(selection.active, suggestion.code);
                }
                else {
                    editBuilder.replace(selection, suggestion.code);
                }
            });
            vscode.window.showInformationMessage(`Applied suggestion: ${suggestion.title}`);
            await this.dismissFeedback(feedbackId);
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to apply suggestion: ${error}`);
        }
    }
    async fixFeedbackIssue(item) {
        const editor = vscode.window.activeTextEditor;
        if (!editor || !item.range)
            return;
        try {
            const response = await this.backendService.fixCode(editor.document.getText(item.range), {
                context: {
                    activeFile: editor.document.fileName,
                    workspacePath: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    language: editor.document.languageId
                },
                fixType: item.type === 'error' ? 'syntax' : 'logic'
            });
            if (response.success && response.data) {
                const fixedCode = response.data.result || response.data.output;
                if (fixedCode) {
                    await editor.edit(editBuilder => {
                        editBuilder.replace(item.range, fixedCode);
                    });
                    vscode.window.showInformationMessage(`Fixed issue: ${item.title}`);
                    await this.dismissFeedback(item.id);
                }
            }
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to fix issue: ${error}`);
        }
    }
    async dismissFeedback(feedbackId) {
        const editor = vscode.window.activeTextEditor;
        if (!editor)
            return;
        const documentFeedbackId = editor.document.uri.toString();
        const feedbackItems = this.activeFeedback.get(documentFeedbackId) || [];
        const updatedFeedback = feedbackItems.filter(item => item.id !== feedbackId);
        this.activeFeedback.set(documentFeedbackId, updatedFeedback);
        this.showFeedback(editor, updatedFeedback);
    }
    clearFeedback(feedbackId) {
        this.activeFeedback.delete(feedbackId);
        const editor = vscode.window.activeTextEditor;
        if (editor && editor.document.uri.toString() === feedbackId) {
            editor.setDecorations(this.feedbackDecorationType, []);
            this.updateStatusBar();
        }
    }
    toggleFeedback() {
        const config = vscode.workspace.getConfiguration('noodle.ai.realTimeFeedback');
        const enabled = config.get('enabled', true);
        config.update('enabled', !enabled, vscode.ConfigurationTarget.Global);
        if (enabled) {
            vscode.window.showInformationMessage('Real-time AI Feedback disabled');
        }
        else {
            vscode.window.showInformationMessage('Real-time AI Feedback enabled');
        }
    }
    getTypeIcon(type) {
        switch (type) {
            case 'error': return '❌';
            case 'warning': return '⚠️';
            case 'suggestion': return '💡';
            case 'info': return 'ℹ️';
            default: return '•';
        }
    }
    debounce(func, wait) {
        return (...args) => {
            if (this.debounceTimer) {
                clearTimeout(this.debounceTimer);
            }
            this.debounceTimer = setTimeout(() => func(...args), wait);
        };
    }
    dispose() {
        this.disposables.forEach(d => d.dispose());
        this.feedbackDecorationType.dispose();
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
        if (this.debounceTimer) {
            clearTimeout(this.debounceTimer);
        }
    }
}
exports.RealTimeFeedback = RealTimeFeedback;
//# sourceMappingURL=realTimeFeedback.js.map