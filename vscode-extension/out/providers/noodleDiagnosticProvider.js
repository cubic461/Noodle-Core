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
exports.NoodleDiagnosticProvider = void 0;
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore Diagnostic Provider
 *
 * Provides real-time syntax checking and error detection for NoodleCore files.
 * Integrates with NoodleCore backend services for advanced validation.
 */
class NoodleDiagnosticProvider {
    constructor() {
        this.disposables = [];
        this.diagnosticCollection = vscode.languages.createDiagnosticCollection('noodle');
    }
    /**
     * Register the diagnostic provider
     */
    register() {
        // Handle document changes
        const changeDisposable = vscode.workspace.onDidChangeTextDocument((event) => {
            if (event.document.languageId === 'noodle') {
                this.updateDiagnostics(event.document);
            }
        });
        // Handle document open
        const openDisposable = vscode.workspace.onDidOpenTextDocument((document) => {
            if (document.languageId === 'noodle') {
                this.updateDiagnostics(document);
            }
        });
        // Handle configuration changes
        const configDisposable = vscode.workspace.onDidChangeConfiguration((event) => {
            if (event.affectsConfiguration('noodle')) {
                this.refreshAllDiagnostics();
            }
        });
        this.disposables.push(changeDisposable, openDisposable, configDisposable);
    }
    /**
     * Update diagnostics for a specific document
     */
    async updateDiagnostics(document) {
        if (document.languageId !== 'noodle') {
            return;
        }
        const diagnostics = [];
        const text = document.getText();
        // Basic syntax validation
        this.validateBasicSyntax(text, diagnostics);
        // AI-specific validation
        this.validateAIConstructs(text, diagnostics);
        // Structural validation
        this.validateStructure(text, diagnostics);
        // Advanced validation with backend (if available)
        await this.validateWithBackend(document, diagnostics);
        // Set diagnostics for the document
        this.diagnosticCollection.set(document.uri, diagnostics);
    }
    /**
     * Validate basic syntax
     */
    validateBasicSyntax(text, diagnostics) {
        const lines = text.split('\n');
        lines.forEach((line, lineIndex) => {
            // Check for unclosed brackets
            const openBrackets = (line.match(/\{/g) || []).length;
            const closeBrackets = (line.match(/\}/g) || []).length;
            const openParens = (line.match(/\(/g) || []).length;
            const closeParens = (line.match(/\)/g) || []).length;
            const openBrackets2 = (line.match(/\[/g) || []).length;
            const closeBrackets2 = (line.match(/\]/g) || []).length;
            if (openBrackets > closeBrackets) {
                const range = new vscode.Range(new vscode.Position(lineIndex, line.lastIndexOf('{')), new vscode.Position(lineIndex, line.lastIndexOf('{') + 1));
                const diagnostic = new vscode.Diagnostic(range, 'Unclosed bracket', vscode.DiagnosticSeverity.Error);
                diagnostics.push(diagnostic);
            }
            if (openParens > closeParens) {
                const range = new vscode.Range(new vscode.Position(lineIndex, line.lastIndexOf('(')), new vscode.Position(lineIndex, line.lastIndexOf('(') + 1));
                const diagnostic = new vscode.Diagnostic(range, 'Unclosed parenthesis', vscode.DiagnosticSeverity.Error);
                diagnostics.push(diagnostic);
            }
            if (openBrackets2 > closeBrackets2) {
                const range = new vscode.Range(new vscode.Position(lineIndex, line.lastIndexOf('[')), new vscode.Position(lineIndex, line.lastIndexOf('[') + 1));
                const diagnostic = new vscode.Diagnostic(range, 'Unclosed square bracket', vscode.DiagnosticSeverity.Error);
                diagnostics.push(diagnostic);
            }
            // Check for invalid characters
            const invalidChars = line.match(/[^\x20-\x7E]/g);
            if (invalidChars) {
                const range = new vscode.Range(new vscode.Position(lineIndex, 0), new vscode.Position(lineIndex, line.length));
                const diagnostic = new vscode.Diagnostic(range, `Invalid characters found: ${invalidChars.join(', ')}`, vscode.DiagnosticSeverity.Warning);
                diagnostics.push(diagnostic);
            }
        });
    }
    /**
     * Validate AI-specific constructs
     */
    validateAIConstructs(text, diagnostics) {
        const lines = text.split('\n');
        lines.forEach((line, lineIndex) => {
            // Check for AI model definitions
            if (line.includes('ai model')) {
                const modelMatch = line.match(/ai model\s+(\w+)\s*\{/);
                if (!modelMatch) {
                    const range = new vscode.Range(new vscode.Position(lineIndex, 0), new vscode.Position(lineIndex, line.length));
                    const diagnostic = new vscode.Diagnostic(range, 'Invalid AI model definition. Expected format: ai model modelName { ... }', vscode.DiagnosticSeverity.Error);
                    diagnostics.push(diagnostic);
                }
            }
            // Check for agent definitions
            if (line.includes('agent')) {
                const agentMatch = line.match(/agent\s+(\w+)\s*\{/);
                if (!agentMatch) {
                    const range = new vscode.Range(new vscode.Position(lineIndex, 0), new vscode.Position(lineIndex, line.length));
                    const diagnostic = new vscode.Diagnostic(range, 'Invalid agent definition. Expected format: agent agentName { ... }', vscode.DiagnosticSeverity.Error);
                    diagnostics.push(diagnostic);
                }
            }
            // Check for pipeline definitions
            if (line.includes('pipeline')) {
                const pipelineMatch = line.match(/pipeline\s+(\w+)\s*\{/);
                if (!pipelineMatch) {
                    const range = new vscode.Range(new vscode.Position(lineIndex, 0), new vscode.Position(lineIndex, line.length));
                    const diagnostic = new vscode.Diagnostic(range, 'Invalid pipeline definition. Expected format: pipeline pipelineName { ... }', vscode.DiagnosticSeverity.Error);
                    diagnostics.push(diagnostic);
                }
            }
        });
    }
    /**
     * Validate code structure
     */
    validateStructure(text, diagnostics) {
        const lines = text.split('\n');
        let inFunction = false;
        let inClass = false;
        let inAIModel = false;
        let inAgent = false;
        let inPipeline = false;
        lines.forEach((line, lineIndex) => {
            // Track context
            if (line.includes('func ') || line.includes('function ')) {
                inFunction = true;
            }
            else if (line.includes('class ')) {
                inClass = true;
            }
            else if (line.includes('ai model ')) {
                inAIModel = true;
            }
            else if (line.includes('agent ')) {
                inAgent = true;
            }
            else if (line.includes('pipeline ')) {
                inPipeline = true;
            }
            // Check for return statements outside functions
            if (line.includes('return ') && !inFunction) {
                const range = new vscode.Range(new vscode.Position(lineIndex, line.indexOf('return')), new vscode.Position(lineIndex, line.indexOf('return') + 6));
                const diagnostic = new vscode.Diagnostic(range, 'Return statement outside function', vscode.DiagnosticSeverity.Error);
                diagnostics.push(diagnostic);
            }
            // Check for this references outside classes
            if (line.includes('this.') && !inClass) {
                const range = new vscode.Range(new vscode.Position(lineIndex, line.indexOf('this')), new vscode.Position(lineIndex, line.indexOf('this') + 4));
                const diagnostic = new vscode.Diagnostic(range, "'this' reference outside class", vscode.DiagnosticSeverity.Error);
                diagnostics.push(diagnostic);
            }
            // Update context when closing blocks
            if (line.includes('}')) {
                const closeCount = (line.match(/\}/g) || []).length;
                for (let i = 0; i < closeCount; i++) {
                    if (inPipeline) {
                        inPipeline = false;
                    }
                    else if (inAgent) {
                        inAgent = false;
                    }
                    else if (inAIModel) {
                        inAIModel = false;
                    }
                    else if (inFunction) {
                        inFunction = false;
                    }
                    else if (inClass) {
                        inClass = false;
                    }
                }
            }
        });
    }
    /**
     * Validate with backend services
     */
    async validateWithBackend(document, diagnostics) {
        const config = vscode.workspace.getConfiguration('noodle');
        const enableBackendValidation = config.get('enableBackendValidation', false);
        if (!enableBackendValidation) {
            return;
        }
        try {
            // Get NoodleCore backend URL
            const backendUrl = config.get('backendUrl', 'http://localhost:8080');
            // Send code to backend for validation
            const response = await fetch(`${backendUrl}/api/validate`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({
                    code: document.getText(),
                    filename: document.fileName,
                    requestId: this.generateRequestId()
                })
            });
            if (response.ok) {
                const result = await response.json();
                if (result.errors && result.errors.length > 0) {
                    result.errors.forEach((error) => {
                        const range = new vscode.Range(new vscode.Position(error.line - 1, error.column - 1), new vscode.Position(error.line - 1, error.column - 1 + error.length));
                        const diagnostic = new vscode.Diagnostic(range, error.message, this.getSeverity(error.severity));
                        diagnostic.source = 'NoodleCore Backend';
                        diagnostics.push(diagnostic);
                    });
                }
            }
        }
        catch (error) {
            console.error('Backend validation failed:', error);
        }
    }
    /**
     * Get diagnostic severity from backend response
     */
    getSeverity(severity) {
        switch (severity) {
            case 'error':
                return vscode.DiagnosticSeverity.Error;
            case 'warning':
                return vscode.DiagnosticSeverity.Warning;
            case 'info':
                return vscode.DiagnosticSeverity.Information;
            default:
                return vscode.DiagnosticSeverity.Error;
        }
    }
    /**
     * Generate a unique request ID
     */
    generateRequestId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    /**
     * Refresh diagnostics for all NoodleCore documents
     */
    refreshAllDiagnostics() {
        vscode.workspace.textDocuments.forEach(document => {
            if (document.languageId === 'noodle') {
                this.updateDiagnostics(document);
            }
        });
    }
    /**
     * Dispose the diagnostic provider
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
        this.diagnosticCollection.dispose();
    }
}
exports.NoodleDiagnosticProvider = NoodleDiagnosticProvider;
//# sourceMappingURL=noodleDiagnosticProvider.js.map