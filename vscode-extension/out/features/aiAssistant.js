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
exports.NoodleAIAssistant = void 0;
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore AI Assistant
 *
 * Provides AI-powered assistance within VS Code, including:
 * - Code completion suggestions
 * - Refactoring recommendations
 * - Code explanation
 * - Error analysis and fixes
 * - Performance optimization suggestions
 */
class NoodleAIAssistant {
    constructor(context) {
        this.context = context;
        this.disposables = [];
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore AI Assistant');
        this.statusBar = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.setupStatusBar();
        this.registerCommands();
        this.setupEventHandlers();
    }
    /**
     * Setup status bar
     */
    setupStatusBar() {
        this.statusBar.text = '$(noodle) AI Assistant';
        this.statusBar.tooltip = 'NoodleCore AI Assistant';
        this.statusBar.command = 'noodle.aiAssistant.show';
        this.statusBar.show();
    }
    /**
     * Register AI assistant commands
     */
    registerCommands() {
        // Show AI assistant panel
        const showCommand = vscode.commands.registerCommand('noodle.aiAssistant.show', () => this.showAIAssistant());
        this.disposables.push(showCommand);
        // Analyze current selection
        const analyzeCommand = vscode.commands.registerCommand('noodle.aiAssistant.analyze', () => this.analyzeSelection());
        this.disposables.push(analyzeCommand);
        // Refactor current selection
        const refactorCommand = vscode.commands.registerCommand('noodle.aiAssistant.refactor', () => this.refactorSelection());
        this.disposables.push(refactorCommand);
        // Explain current selection
        const explainCommand = vscode.commands.registerCommand('noodle.aiAssistant.explain', () => this.explainSelection());
        this.disposables.push(explainCommand);
        // Generate code
        const generateCommand = vscode.commands.registerCommand('noodle.aiAssistant.generate', () => this.generateCode());
        this.disposables.push(generateCommand);
        // Fix errors
        const fixCommand = vscode.commands.registerCommand('noodle.aiAssistant.fix', () => this.fixErrors());
        this.disposables.push(fixCommand);
        // Optimize code
        const optimizeCommand = vscode.commands.registerCommand('noodle.aiAssistant.optimize', () => this.optimizeCode());
        this.disposables.push(optimizeCommand);
        // Review code
        const reviewCommand = vscode.commands.registerCommand('noodle.aiAssistant.review', () => this.reviewCode());
        this.disposables.push(reviewCommand);
    }
    /**
     * Setup event handlers
     */
    setupEventHandlers() {
        // Handle document changes
        const changeDisposable = vscode.workspace.onDidChangeTextDocument((event) => {
            if (event.document.languageId === 'noodle') {
                this.analyzeDocument(event.document);
            }
        });
        this.disposables.push(changeDisposable);
        // Handle diagnostic changes
        const diagnosticDisposable = vscode.languages.onDidChangeDiagnostics((event) => {
            event.uris.forEach(uri => {
                const document = vscode.workspace.textDocuments.find(doc => doc.uri === uri);
                if (document && document.languageId === 'noodle') {
                    this.analyzeDiagnostics(uri, vscode.languages.getDiagnostics(uri));
                }
            });
        });
        this.disposables.push(diagnosticDisposable);
    }
    /**
     * Show AI assistant panel
     */
    async showAIAssistant() {
        const panel = vscode.window.createWebviewPanel('noodleAIAssistant', 'NoodleCore AI Assistant', vscode.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true
        });
        panel.webview.html = await this.getAIAssistantWebviewContent(panel);
        // Handle messages from webview
        panel.webview.onDidReceiveMessage(async (message) => {
            switch (message.command) {
                case 'analyze':
                    await this.analyzeCode(message.code);
                    break;
                case 'refactor':
                    await this.refactorCode(message.code, message.type);
                    break;
                case 'explain':
                    await this.explainCode(message.code);
                    break;
                case 'generate':
                    await this.generateCodeFromPrompt(message.prompt);
                    break;
                case 'fix':
                    await this.fixCodeErrors(message.code);
                    break;
                case 'optimize':
                    await this.optimizeCodePerformance(message.code);
                    break;
            }
        });
    }
    /**
     * Get AI assistant webview content
     */
    async getAIAssistantWebviewContent(panel) {
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
    <title>NoodleCore AI Assistant</title>
    <style>
        body {
            font-family: var(--vscode-font-family);
            font-size: var(--vscode-font-size);
            color: var(--vscode-foreground);
            background-color: var(--vscode-editor-background);
            margin: 0;
            padding: 20px;
        }
        .container {
            max-width: 800px;
            margin: 0 auto;
        }
        .header {
            display: flex;
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
        .tabs {
            display: flex;
            margin-bottom: 20px;
        }
        .tab {
            padding: 8px 16px;
            cursor: pointer;
            border: 1px solid var(--vscode-panel-border);
            background-color: var(--vscode-editor-background);
            margin-right: 2px;
        }
        .tab.active {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
        }
        .content {
            border: 1px solid var(--vscode-panel-border);
            border-radius: 4px;
            padding: 16px;
        }
        .code-area {
            width: 100%;
            height: 200px;
            font-family: var(--vscode-editor-font-family);
            font-size: var(--vscode-editor-font-size);
            background-color: var(--vscode-editor-background);
            color: var(--vscode-editor-foreground);
            border: 1px solid var(--vscode-input-border);
            border-radius: 4px;
            padding: 8px;
            margin-bottom: 16px;
            resize: vertical;
        }
        .button {
            background-color: var(--vscode-button-background);
            color: var(--vscode-button-foreground);
            border: none;
            border-radius: 4px;
            padding: 8px 16px;
            cursor: pointer;
            margin-right: 8px;
        }
        .button:hover {
            background-color: var(--vscode-button-hoverBackground);
        }
        .result-area {
            background-color: var(--vscode-textBlockQuote-background);
            border-left: 4px solid var(--vscode-textBlockQuote-border);
            padding: 12px;
            margin-top: 16px;
            border-radius: 4px;
        }
        .loading {
            text-align: center;
            padding: 20px;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🤖 NoodleCore AI Assistant</h1>
        </div>
        <div class="tabs">
            <div class="tab active" onclick="showTab('analyze')">Analyze</div>
            <div class="tab" onclick="showTab('refactor')">Refactor</div>
            <div class="tab" onclick="showTab('explain')">Explain</div>
            <div class="tab" onclick="showTab('generate')">Generate</div>
            <div class="tab" onclick="showTab('fix')">Fix</div>
            <div class="tab" onclick="showTab('optimize')">Optimize</div>
        </div>
        <div class="content">
            <div id="analyze-tab" class="tab-content">
                <h3>Analyze Code</h3>
                <p>Paste your NoodleCore code below to get AI-powered analysis:</p>
                <textarea id="analyze-code" class="code-area" placeholder="Enter your NoodleCore code here..."></textarea>
                <button class="button" onclick="analyzeCode()">Analyze</button>
                <div id="analyze-result" class="result-area" style="display: none;"></div>
            </div>
            <div id="refactor-tab" class="tab-content" style="display: none;">
                <h3>Refactor Code</h3>
                <p>Paste your NoodleCore code below to get refactoring suggestions:</p>
                <textarea id="refactor-code" class="code-area" placeholder="Enter your NoodleCore code here..."></textarea>
                <select id="refactor-type">
                    <option value="performance">Performance</option>
                    <option value="readability">Readability</option>
                    <option value="maintainability">Maintainability</option>
                    <option value="security">Security</option>
                </select>
                <button class="button" onclick="refactorCode()">Refactor</button>
                <div id="refactor-result" class="result-area" style="display: none;"></div>
            </div>
            <div id="explain-tab" class="tab-content" style="display: none;">
                <h3>Explain Code</h3>
                <p>Paste your NoodleCore code below to get explanations:</p>
                <textarea id="explain-code" class="code-area" placeholder="Enter your NoodleCore code here..."></textarea>
                <button class="button" onclick="explainCode()">Explain</button>
                <div id="explain-result" class="result-area" style="display: none;"></div>
            </div>
            <div id="generate-tab" class="tab-content" style="display: none;">
                <h3>Generate Code</h3>
                <p>Describe what you want to generate:</p>
                <textarea id="generate-prompt" class="code-area" placeholder="Describe the code you want to generate..." rows="3"></textarea>
                <button class="button" onclick="generateCode()">Generate</button>
                <div id="generate-result" class="result-area" style="display: none;"></div>
            </div>
            <div id="fix-tab" class="tab-content" style="display: none;">
                <h3>Fix Code</h3>
                <p>Paste your NoodleCore code below to get error fixes:</p>
                <textarea id="fix-code" class="code-area" placeholder="Enter your NoodleCore code here..."></textarea>
                <button class="button" onclick="fixCode()">Fix</button>
                <div id="fix-result" class="result-area" style="display: none;"></div>
            </div>
            <div id="optimize-tab" class="tab-content" style="display: none;">
                <h3>Optimize Code</h3>
                <p>Paste your NoodleCore code below to get optimization suggestions:</p>
                <textarea id="optimize-code" class="code-area" placeholder="Enter your NoodleCore code here..."></textarea>
                <button class="button" onclick="optimizeCode()">Optimize</button>
                <div id="optimize-result" class="result-area" style="display: none;"></div>
            </div>
        </div>
    </div>

    <script nonce="${nonce}">
        const vscode = acquireVsCodeApi();
        
        function showTab(tabName) {
            // Hide all tabs
            document.querySelectorAll('.tab-content').forEach(tab => {
                tab.style.display = 'none';
            });
            document.querySelectorAll('.tab').forEach(tab => {
                tab.classList.remove('active');
            });
            
            // Show selected tab
            document.getElementById(tabName + '-tab').style.display = 'block';
            event.target.classList.add('active');
        }
        
        function analyzeCode() {
            const code = document.getElementById('analyze-code').value;
            const resultDiv = document.getElementById('analyze-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Analyzing code...</div>';
            
            vscode.postMessage({
                command: 'analyze',
                code: code
            });
        }
        
        function refactorCode() {
            const code = document.getElementById('refactor-code').value;
            const type = document.getElementById('refactor-type').value;
            const resultDiv = document.getElementById('refactor-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Refactoring code...</div>';
            
            vscode.postMessage({
                command: 'refactor',
                code: code,
                type: type
            });
        }
        
        function explainCode() {
            const code = document.getElementById('explain-code').value;
            const resultDiv = document.getElementById('explain-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Explaining code...</div>';
            
            vscode.postMessage({
                command: 'explain',
                code: code
            });
        }
        
        function generateCode() {
            const prompt = document.getElementById('generate-prompt').value;
            const resultDiv = document.getElementById('generate-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Generating code...</div>';
            
            vscode.postMessage({
                command: 'generate',
                prompt: prompt
            });
        }
        
        function fixCode() {
            const code = document.getElementById('fix-code').value;
            const resultDiv = document.getElementById('fix-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Fixing code...</div>';
            
            vscode.postMessage({
                command: 'fix',
                code: code
            });
        }
        
        function optimizeCode() {
            const code = document.getElementById('optimize-code').value;
            const resultDiv = document.getElementById('optimize-result');
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = '<div class="loading">Optimizing code...</div>';
            
            vscode.postMessage({
                command: 'optimize',
                code: code
            });
        }
        
        // Handle responses from extension
        window.addEventListener('message', event => {
            const message = event.data;
            if (message.type === 'result') {
                const resultId = message.command + '-result';
                const resultDiv = document.getElementById(resultId);
                if (resultDiv) {
                    resultDiv.innerHTML = message.result;
                }
            }
        });
    </script>
</body>
</html>`;
    }
    /**
     * Get nonce for security
     */
    getNonce() {
        let text = '';
        const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        for (let i = 0; i < 32; i++) {
            text += possible.charAt(Math.floor(Math.random() * possible.length));
        }
        return text;
    }
    /**
     * Analyze current selection
     */
    async analyzeSelection() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const selection = editor.selection;
        const selectedText = editor.document.getText(selection);
        if (selectedText) {
            await this.analyzeCode(selectedText);
        }
        else {
            vscode.window.showInformationMessage('Please select code to analyze');
        }
    }
    /**
     * Refactor current selection
     */
    async refactorSelection() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const selection = editor.selection;
        const selectedText = editor.document.getText(selection);
        if (selectedText) {
            const refactorType = await vscode.window.showQuickPick([
                { label: 'Performance', value: 'performance' },
                { label: 'Readability', value: 'readability' },
                { label: 'Maintainability', value: 'maintainability' },
                { label: 'Security', value: 'security' }
            ], {
                placeHolder: 'Select refactoring type'
            });
            if (refactorType) {
                await this.refactorCode(selectedText, refactorType.value);
            }
        }
        else {
            vscode.window.showInformationMessage('Please select code to refactor');
        }
    }
    /**
     * Explain current selection
     */
    async explainSelection() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const selection = editor.selection;
        const selectedText = editor.document.getText(selection);
        if (selectedText) {
            await this.explainCode(selectedText);
        }
        else {
            vscode.window.showInformationMessage('Please select code to explain');
        }
    }
    /**
     * Generate code from prompt
     */
    async generateCode() {
        const prompt = await vscode.window.showInputBox({
            prompt: 'What code would you like to generate?',
            placeHolder: 'Describe the code you want to generate...'
        });
        if (prompt) {
            await this.generateCodeFromPrompt(prompt);
        }
    }
    /**
     * Fix errors in current document
     */
    async fixErrors() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const document = editor.document;
        const fullText = document.getText();
        await this.fixCodeErrors(fullText);
    }
    /**
     * Optimize current document
     */
    async optimizeCode() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const document = editor.document;
        const fullText = document.getText();
        await this.optimizeCodePerformance(fullText);
    }
    /**
     * Review current document
     */
    async reviewCode() {
        const editor = vscode.window.activeTextEditor;
        if (!editor) {
            vscode.window.showErrorMessage('No active editor');
            return;
        }
        const document = editor.document;
        const fullText = document.getText();
        await this.performCodeReview(fullText);
    }
    /**
     * Analyze document
     */
    async analyzeDocument(document) {
        if (document.languageId !== 'noodle') {
            return;
        }
        // Get document text
        const text = document.getText();
        // Analyze for potential issues
        const issues = this.analyzeForIssues(text);
        // Show suggestions in output channel
        if (issues.length > 0) {
            this.outputChannel.appendLine('🔍 Code Analysis Results:');
            this.outputChannel.appendLine('');
            issues.forEach(issue => {
                this.outputChannel.appendLine(`⚠️ ${issue.type}: ${issue.message}`);
                this.outputChannel.appendLine(`   Line ${issue.line}: ${issue.code}`);
                this.outputChannel.appendLine(`   Suggestion: ${issue.suggestion}`);
                this.outputChannel.appendLine('');
            });
            this.outputChannel.show();
        }
    }
    /**
     * Analyze diagnostics
     */
    async analyzeDiagnostics(uri, diagnostics) {
        const noodleDiagnostics = diagnostics.filter(diag => diag.source === 'NoodleCore' || diag.source === 'noodle');
        if (noodleDiagnostics.length > 0) {
            this.outputChannel.appendLine('🔍 Diagnostic Analysis:');
            this.outputChannel.appendLine('');
            noodleDiagnostics.forEach(diag => {
                this.outputChannel.appendLine(`❌ ${diag.severity}: ${diag.message}`);
                if (diag.range) {
                    this.outputChannel.appendLine(`   Line ${diag.range.start.line + 1}, Column ${diag.range.start.character + 1}`);
                }
                this.outputChannel.appendLine('');
            });
            this.outputChannel.show();
        }
    }
    /**
     * Analyze code for issues
     */
    analyzeForIssues(code) {
        const issues = [];
        const lines = code.split('\n');
        lines.forEach((line, index) => {
            // Check for common issues
            if (line.includes('TODO:') && !line.includes('TODO: Implement')) {
                issues.push({
                    type: 'Incomplete TODO',
                    message: 'TODO comment without implementation details',
                    line: index + 1,
                    code: line.trim(),
                    suggestion: 'Add implementation details to TODO comment'
                });
            }
            if (line.includes('println(') && !line.includes('\\n')) {
                issues.push({
                    type: 'Debug Code',
                    message: 'Debug print statement found',
                    line: index + 1,
                    code: line.trim(),
                    suggestion: 'Remove debug print statements in production code'
                });
            }
            if (line.includes('func ') && !line.includes('return ')) {
                issues.push({
                    type: 'Missing Return',
                    message: 'Function without return statement',
                    line: index + 1,
                    code: line.trim(),
                    suggestion: 'Add return statement to function'
                });
            }
            if (line.includes('ai model ') && !line.includes('type:')) {
                issues.push({
                    type: 'Incomplete AI Model',
                    message: 'AI model definition missing type',
                    line: index + 1,
                    code: line.trim(),
                    suggestion: 'Add type parameter to AI model definition'
                });
            }
        });
        return issues;
    }
    /**
     * Analyze code with AI
     */
    async analyzeCode(code) {
        try {
            this.outputChannel.appendLine('🤖 Analyzing code with AI...');
            this.outputChannel.show();
            // Call NoodleCore AI service
            const response = await this.callAIService('analyze', { code });
            if (response.success) {
                this.outputChannel.appendLine('✅ Analysis completed:');
                this.outputChannel.appendLine(response.result);
            }
            else {
                this.outputChannel.appendLine('❌ Analysis failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Analysis error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Refactor code with AI
     */
    async refactorCode(code, type) {
        try {
            this.outputChannel.appendLine('🔧 Refactoring code with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('refactor', { code, type });
            if (response.success) {
                this.outputChannel.appendLine('✅ Refactoring completed:');
                this.outputChannel.appendLine(response.result);
                // Show refactored code in new tab
                const document = await vscode.workspace.openTextDocument({
                    content: response.result,
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
            }
            else {
                this.outputChannel.appendLine('❌ Refactoring failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Refactoring error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Explain code with AI
     */
    async explainCode(code) {
        try {
            this.outputChannel.appendLine('📚 Explaining code with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('explain', { code });
            if (response.success) {
                this.outputChannel.appendLine('✅ Explanation:');
                this.outputChannel.appendLine(response.result);
            }
            else {
                this.outputChannel.appendLine('❌ Explanation failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Explanation error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Generate code from prompt
     */
    async generateCodeFromPrompt(prompt) {
        try {
            this.outputChannel.appendLine('✨ Generating code with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('generate', { prompt });
            if (response.success) {
                this.outputChannel.appendLine('✅ Code generated:');
                this.outputChannel.appendLine(response.result);
                // Show generated code in new tab
                const document = await vscode.workspace.openTextDocument({
                    content: response.result,
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
            }
            else {
                this.outputChannel.appendLine('❌ Generation failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Generation error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Fix code errors with AI
     */
    async fixCodeErrors(code) {
        try {
            this.outputChannel.appendLine('🔧 Fixing code errors with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('fix', { code });
            if (response.success) {
                this.outputChannel.appendLine('✅ Code fixed:');
                this.outputChannel.appendLine(response.result);
                // Show fixed code in new tab
                const document = await vscode.workspace.openTextDocument({
                    content: response.result,
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
            }
            else {
                this.outputChannel.appendLine('❌ Fix failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Fix error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Optimize code performance with AI
     */
    async optimizeCodePerformance(code) {
        try {
            this.outputChannel.appendLine('⚡ Optimizing code performance with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('optimize', { code });
            if (response.success) {
                this.outputChannel.appendLine('✅ Code optimized:');
                this.outputChannel.appendLine(response.result);
                // Show optimized code in new tab
                const document = await vscode.workspace.openTextDocument({
                    content: response.result,
                    language: 'noodle'
                });
                await vscode.window.showTextDocument(document);
            }
            else {
                this.outputChannel.appendLine('❌ Optimization failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Optimization error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Perform code review with AI
     */
    async performCodeReview(code) {
        try {
            this.outputChannel.appendLine('👁 Performing code review with AI...');
            this.outputChannel.show();
            const response = await this.callAIService('review', { code });
            if (response.success) {
                this.outputChannel.appendLine('✅ Code review completed:');
                this.outputChannel.appendLine(response.result);
            }
            else {
                this.outputChannel.appendLine('❌ Review failed:');
                this.outputChannel.appendLine(response.error || 'Unknown error');
            }
        }
        catch (error) {
            this.outputChannel.appendLine('❌ Review error:');
            this.outputChannel.appendLine(error.message || 'Unknown error');
        }
    }
    /**
     * Call NoodleCore AI service
     */
    async callAIService(action, data) {
        const config = vscode.workspace.getConfiguration('noodle');
        const backendUrl = config.get('backendUrl', 'http://localhost:8080');
        return new Promise((resolve, reject) => {
            const url = new URL(`${backendUrl}/api/ai/${action}`);
            const postData = JSON.stringify({
                ...data,
                requestId: this.generateRequestId()
            });
            const options = {
                hostname: url.hostname,
                port: url.port || (url.protocol === 'https:' ? 443 : 80),
                path: url.pathname + url.search,
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(postData)
                }
            };
            const client = url.protocol === 'https:' ? https : http;
            const req = client.request(options, (res) => {
                let responseData = '';
                res.on('data', (chunk) => {
                    responseData += chunk;
                });
                res.on('end', () => {
                    try {
                        if (res.statusCode !== 200) {
                            reject(new Error(`AI service request failed: ${res.statusMessage}`));
                            return;
                        }
                        const parsedData = JSON.parse(responseData);
                        resolve(parsedData);
                    }
                    catch (error) {
                        reject(new Error(`Failed to parse AI service response: ${error}`));
                    }
                });
            });
            req.on('error', (error) => {
                reject(new Error(`AI service request failed: ${error.message}`));
            });
            req.write(postData);
            req.end();
        });
    }
    /**
     * Generate request ID
     */
    generateRequestId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }
    /**
     * Dispose AI assistant
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
        this.outputChannel.dispose();
        this.statusBar.dispose();
    }
}
exports.NoodleAIAssistant = NoodleAIAssistant;
//# sourceMappingURL=aiAssistant.js.map