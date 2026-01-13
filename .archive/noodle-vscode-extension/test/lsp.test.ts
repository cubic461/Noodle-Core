/**
 * NoodleCore LSP Integration Tests
 * 
 * Comprehensive test suite for Language Server Protocol integration
 * including completion, definition, references, hover, diagnostics,
 * and NoodleCore-specific features like pattern matching and generics.
 */

import * as vscode from 'vscode';
import * as path from 'path';
import * as assert from 'assert';

// Test utilities
interface TestCompletionItem {
    label: string;
    kind?: number;
    detail?: string;
    documentation?: string;
    insertText?: string;
}

interface TestLocation {
    uri: string;
    range: vscode.Range;
}

interface TestHover {
    contents: string;
    range?: vscode.Range;
}

interface TestDiagnostic {
    range: vscode.Range;
    message: string;
    severity: vscode.DiagnosticSeverity;
    source?: string;
}

class NoodleLSPTestSuite {
    private extensionPath: string;
    private workspaceFolder: vscode.WorkspaceFolder | undefined;

    constructor(extensionPath: string) {
        this.extensionPath = extensionPath;
        this.workspaceFolder = vscode.workspace.workspaceFolders?.[0];
    }

    /**
     * Run all LSP tests
     */
    public async runAllTests(): Promise<void> {
        console.log('Starting NoodleCore LSP Test Suite...');
        
        try {
            await this.testBasicLSPConnection();
            await this.testCompletion();
            await this.testDefinition();
            await this.testReferences();
            await this.testHover();
            await this.testDiagnostics();
            await this.testSignatureHelp();
            await this.testCodeActions();
            await this.testFormatting();
            await this.testPatternMatching();
            await this.testGenericsSupport();
            await this.testAsyncAwaitSupport();
            await this.testAIIntegration();
            await this.testPerformance();
            
            console.log('✅ All NoodleCore LSP tests passed!');
            vscode.window.showInformationMessage('NoodleCore LSP integration tests completed successfully!');
            
        } catch (error) {
            console.error('❌ LSP Test Suite failed:', error);
            vscode.window.showErrorMessage(`LSP Test Suite failed: ${error}`);
            throw error;
        }
    }

    /**
     * Test basic LSP server connection
     */
    private async testBasicLSPConnection(): Promise<void> {
        console.log('Testing basic LSP connection...');
        
        // Check if LSP is enabled
        const config = vscode.workspace.getConfiguration('noodle');
        const lspEnabled = config.get<boolean>('lsp.enabled', true);
        assert.strictEqual(lspEnabled, true, 'LSP should be enabled by default');
        
        // Wait for LSP to initialize
        await this.waitForLSPInitialization();
        
        console.log('✅ Basic LSP connection test passed');
    }

    /**
     * Test completion functionality
     */
    private async testCompletion(): Promise<void> {
        console.log('Testing completion functionality...');
        
        // Create a test document
        const testDoc = await this.createTestDocument('completion.nc', this.getCompletionTestContent());
        
        // Test keyword completions
        await this.testKeywordCompletions(testDoc);
        
        // Test symbol completions
        await this.testSymbolCompletions(testDoc);
        
        // Test snippet completions
        await this.testSnippetCompletions(testDoc);
        
        // Test AI-specific completions
        await this.testAICompletions(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Completion functionality test passed');
    }

    /**
     * Test definition functionality
     */
    private async testDefinition(): Promise<void> {
        console.log('Testing definition functionality...');
        
        const testDoc = await this.createTestDocument('definition.nc', this.getDefinitionTestContent());
        
        // Test go-to-definition for functions
        await this.testGoToDefinition(testDoc, 'test_function');
        
        // Test go-to-definition for variables
        await this.testGoToDefinition(testDoc, 'test_variable');
        
        // Test go-to-definition for classes
        await this.testGoToDefinition(testDoc, 'TestClass');
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Definition functionality test passed');
    }

    /**
     * Test references functionality
     */
    private async testReferences(): Promise<void> {
        console.log('Testing references functionality...');
        
        const testDoc = await this.createTestDocument('references.nc', this.getReferencesTestContent());
        
        // Test find references for functions
        await this.testFindReferences(testDoc, 'test_function');
        
        // Test find references for variables
        await this.testFindReferences(testDoc, 'test_var');
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ References functionality test passed');
    }

    /**
     * Test hover functionality
     */
    private async testHover(): Promise<void> {
        console.log('Testing hover functionality...');
        
        const testDoc = await this.createTestDocument('hover.nc', this.getHoverTestContent());
        
        // Test hover on functions
        await this.testHoverOnSymbol(testDoc, 'test_function');
        
        // Test hover on variables
        await this.testHoverOnSymbol(testDoc, 'test_var');
        
        // Test hover on AI annotations
        await this.testHoverOnAIAnnotation(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Hover functionality test passed');
    }

    /**
     * Test diagnostics functionality
     */
    private async testDiagnostics(): Promise<void> {
        console.log('Testing diagnostics functionality...');
        
        // Test syntax error detection
        await this.testSyntaxErrorDetection();
        
        // Test semantic error detection
        await this.testSemanticErrorDetection();
        
        // Test warning detection
        await this.testWarningDetection();
        
        console.log('✅ Diagnostics functionality test passed');
    }

    /**
     * Test signature help functionality
     */
    private async testSignatureHelp(): Promise<void> {
        console.log('Testing signature help functionality...');
        
        const testDoc = await this.createTestDocument('signature.nc', this.getSignatureTestContent());
        
        // Test signature help for function calls
        await this.testSignatureHelpForFunction(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Signature help functionality test passed');
    }

    /**
     * Test code actions functionality
     */
    private async testCodeActions(): Promise<void> {
        console.log('Testing code actions functionality...');
        
        const testDoc = await this.createTestDocument('codeactions.nc', this.getCodeActionsTestContent());
        
        // Test quick fix actions
        await this.testQuickFixActions(testDoc);
        
        // Test refactor actions
        await this.testRefactorActions(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Code actions functionality test passed');
    }

    /**
     * Test formatting functionality
     */
    private async testFormatting(): Promise<void> {
        console.log('Testing formatting functionality...');
        
        const testDoc = await this.createTestDocument('formatting.nc', this.getFormattingTestContent());
        
        // Test document formatting
        await this.testDocumentFormatting(testDoc);
        
        // Test range formatting
        await this.testRangeFormatting(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Formatting functionality test passed');
    }

    /**
     * Test pattern matching support
     */
    private async testPatternMatching(): Promise<void> {
        console.log('Testing pattern matching support...');
        
        const testDoc = await this.createTestDocument('pattern.nc', this.getPatternMatchingTestContent());
        
        // Test pattern completion
        await this.testPatternCompletion(testDoc);
        
        // Test pattern diagnostics
        await this.testPatternDiagnostics(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Pattern matching support test passed');
    }

    /**
     * Test generics support
     */
    private async testGenericsSupport(): Promise<void> {
        console.log('Testing generics support...');
        
        const testDoc = await this.createTestDocument('generics.nc', this.getGenericsTestContent());
        
        // Test generic type completion
        await this.testGenericCompletion(testDoc);
        
        // Test generic type diagnostics
        await this.testGenericDiagnostics(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Generics support test passed');
    }

    /**
     * Test async/await support
     */
    private async testAsyncAwaitSupport(): Promise<void> {
        console.log('Testing async/await support...');
        
        const testDoc = await this.createTestDocument('async.nc', this.getAsyncAwaitTestContent());
        
        // Test async function completion
        await this.testAsyncCompletion(testDoc);
        
        // Test async diagnostics
        await this.testAsyncDiagnostics(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ Async/await support test passed');
    }

    /**
     * Test AI integration
     */
    private async testAIIntegration(): Promise<void> {
        console.log('Testing AI integration...');
        
        const testDoc = await this.createTestDocument('ai.nc', this.getAITestContent());
        
        // Test AI annotation completion
        await this.testAIAnnotationCompletion(testDoc);
        
        // Test AI function completion
        await this.testAIFunctionCompletion(testDoc);
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log('✅ AI integration test passed');
    }

    /**
     * Test performance
     */
    private async testPerformance(): Promise<void> {
        console.log('Testing LSP performance...');
        
        const startTime = Date.now();
        
        // Test large document parsing performance
        const largeDoc = await this.createTestDocument('large.nc', this.getLargeTestContent());
        
        // Measure completion time
        const completionStart = Date.now();
        await vscode.commands.executeCommand('vscode.executeCompletionItemProvider', { 
            document: largeDoc.uri,
            position: new vscode.Position(100, 20)
        });
        const completionTime = Date.now() - completionStart;
        
        // Measure definition time
        const definitionStart = Date.now();
        await vscode.commands.executeCommand('vscode.executeDefinitionProvider', {
            document: largeDoc.uri,
            position: new vscode.Position(100, 10)
        });
        const definitionTime = Date.now() - definitionStart;
        
        // Clean up
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
        
        console.log(`Completion time: ${completionTime}ms`);
        console.log(`Definition time: ${definitionTime}ms`);
        
        // Performance assertions
        assert.ok(completionTime < 1000, 'Completion should be under 1 second');
        assert.ok(definitionTime < 1000, 'Definition should be under 1 second');
        
        const totalTime = Date.now() - startTime;
        console.log(`Total performance test time: ${totalTime}ms`);
        
        console.log('✅ Performance test passed');
    }

    // Helper methods for specific tests
    
    private async testKeywordCompletions(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(5, 10); // Position after "func "
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        assert.ok(completions.items.length > 0, 'Should have keyword completions');
        
        const hasFuncKeyword = completions.items.some(item => item.label === 'func');
        assert.ok(hasFuncKeyword, 'Should include "func" keyword');
    }

    private async testSymbolCompletions(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(6, 15); // Position after "test_"
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasTestFunction = completions.items.some(item => item.label === 'test_function');
        assert.ok(hasTestFunction, 'Should include test_function symbol');
    }

    private async testSnippetCompletions(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(0, 0); // Start of document
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasFuncSnippet = completions.items.some(item => 
            item.label === 'func' && item.insertText && item.insertText.includes('${')
        );
        assert.ok(hasFuncSnippet, 'Should include function snippet');
    }

    private async testAICompletions(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(10, 1); // Position after "@"
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasAIAnnotation = completions.items.some(item => 
            item.label && item.label.startsWith('@ai_')
        );
        assert.ok(hasAIAnnotation, 'Should include AI annotations');
    }

    private async testGoToDefinition(doc: vscode.TextDocument, symbol: string): Promise<void> {
        const symbolPosition = this.findSymbolPosition(doc, symbol);
        assert.ok(symbolPosition, `Should find position for ${symbol}`);
        
        const definitions = await vscode.commands.executeCommand<vscode.Location[]>(
            'vscode.executeDefinitionProvider',
            { document: doc, position: symbolPosition }
        );
        
        assert.ok(definitions.length > 0, `Should find definitions for ${symbol}`);
    }

    private async testFindReferences(doc: vscode.TextDocument, symbol: string): Promise<void> {
        const symbolPosition = this.findSymbolPosition(doc, symbol);
        assert.ok(symbolPosition, `Should find position for ${symbol}`);
        
        const references = await vscode.commands.executeCommand<vscode.Location[]>(
            'vscode.executeReferenceProvider',
            { document: doc, position: symbolPosition }
        );
        
        assert.ok(references.length >= 1, `Should find at least one reference for ${symbol}`);
    }

    private async testHoverOnSymbol(doc: vscode.TextDocument, symbol: string): Promise<void> {
        const symbolPosition = this.findSymbolPosition(doc, symbol);
        assert.ok(symbolPosition, `Should find position for ${symbol}`);
        
        const hover = await vscode.commands.executeCommand<vscode.Hover>(
            'vscode.executeHoverProvider',
            { document: doc, position: symbolPosition }
        );
        
        assert.ok(hover, `Should get hover information for ${symbol}`);
    }

    private async testHoverOnAIAnnotation(doc: vscode.TextDocument): Promise<void> {
        const aiPosition = new vscode.Position(10, 1); // Position after "@ai_"
        const hover = await vscode.commands.executeCommand<vscode.Hover>(
            'vscode.executeHoverProvider',
            { document: doc, position: aiPosition }
        );
        
        assert.ok(hover, 'Should get hover information for AI annotation');
    }

    private async testSyntaxErrorDetection(): Promise<void> {
        const errorDoc = await this.createTestDocument('syntax_error.nc', 'func invalid_syntax() {');
        
        // Wait for diagnostics
        await this.waitForDiagnostics(errorDoc);
        
        const diagnostics = vscode.languages.getDiagnostics(errorDoc.uri);
        const hasSyntaxError = diagnostics.some(d => 
            d.severity === vscode.DiagnosticSeverity.Error && 
            d.message.includes('syntax')
        );
        
        assert.ok(hasSyntaxError, 'Should detect syntax error');
        
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
    }

    private async testSemanticErrorDetection(): Promise<void> {
        const semanticDoc = await this.createTestDocument('semantic_error.nc', 'func test() { return undefined_var; }');
        
        await this.waitForDiagnostics(semanticDoc);
        
        const diagnostics = vscode.languages.getDiagnostics(semanticDoc.uri);
        const hasUndefinedError = diagnostics.some(d => 
            d.severity === vscode.DiagnosticSeverity.Error && 
            d.message.includes('undefined')
        );
        
        assert.ok(hasUndefinedError, 'Should detect undefined variable error');
        
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
    }

    private async testWarningDetection(): Promise<void> {
        const warningDoc = await this.createTestDocument('warning.nc', 'func test() { /* TODO: implement */ }');
        
        await this.waitForDiagnostics(warningDoc);
        
        const diagnostics = vscode.languages.getDiagnostics(warningDoc.uri);
        const hasWarning = diagnostics.some(d => 
            d.severity === vscode.DiagnosticSeverity.Warning
        );
        
        assert.ok(hasWarning, 'Should detect warning');
        
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
    }

    private async testSignatureHelpForFunction(doc: vscode.TextDocument): Promise<void> {
        const functionPosition = new vscode.Position(2, 15); // Position after "test_function("
        const signatureHelp = await vscode.commands.executeCommand<vscode.SignatureHelp>(
            'vscode.executeSignatureHelpProvider',
            { document: doc, position: functionPosition }
        );
        
        assert.ok(signatureHelp, 'Should get signature help for function');
    }

    private async testQuickFixActions(doc: vscode.TextDocument): Promise<void> {
        const errorDoc = await this.createTestDocument('quickfix.nc', 'func invalid_syntax() {');
        
        await this.waitForDiagnostics(errorDoc);
        
        const codeActions = await vscode.commands.executeCommand<vscode.CodeAction[]>(
            'vscode.executeCodeActionProvider',
            { document: errorDoc, range: new vscode.Range(0, 0, 0, 20) }
        );
        
        const hasQuickFix = codeActions.some(action => 
            action.kind?.value === vscode.CodeActionKind.QuickFix.value
        );
        
        assert.ok(hasQuickFix, 'Should provide quick fix actions');
        
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
    }

    private async testRefactorActions(doc: vscode.TextDocument): Promise<void> {
        const refactorDoc = await this.createTestDocument('refactor.nc', 'func old_name() { }');
        
        const codeActions = await vscode.commands.executeCommand<vscode.CodeAction[]>(
            'vscode.executeCodeActionProvider',
            { document: refactorDoc, range: new vscode.Range(0, 5, 0, 15) }
        );
        
        const hasRefactorAction = codeActions.some(action => 
            action.kind?.value === vscode.CodeActionKind.Refactor.value
        );
        
        assert.ok(hasRefactorAction, 'Should provide refactor actions');
        
        await vscode.commands.executeCommand('workbench.action.closeActiveEditor');
    }

    private async testDocumentFormatting(doc: vscode.TextDocument): Promise<void> {
        const edits = await vscode.commands.executeCommand<vscode.TextEdit[]>(
            'vscode.executeDocumentFormattingProvider',
            { document: doc, options: { tabSize: 4, insertSpaces: true } }
        );
        
        assert.ok(Array.isArray(edits), 'Should return formatting edits');
    }

    private async testRangeFormatting(doc: vscode.TextDocument): Promise<void> {
        const edits = await vscode.commands.executeCommand<vscode.TextEdit[]>(
            'vscode.executeDocumentRangeFormattingProvider',
            { 
                document: doc, 
                range: new vscode.Range(0, 0, 5, 20),
                options: { tabSize: 4, insertSpaces: true } 
            }
        );
        
        assert.ok(Array.isArray(edits), 'Should return range formatting edits');
    }

    private async testPatternCompletion(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(6, 10); // Position after "match "
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasCaseKeyword = completions.items.some(item => item.label === 'case');
        assert.ok(hasCaseKeyword, 'Should include "case" keyword for pattern matching');
    }

    private async testPatternDiagnostics(doc: vscode.TextDocument): Promise<void> {
        await this.waitForDiagnostics(doc);
        
        const diagnostics = vscode.languages.getDiagnostics(doc.uri);
        const hasPatternDiagnostic = diagnostics.some(d => 
            d.message.includes('pattern') || d.message.includes('match')
        );
        
        assert.ok(hasPatternDiagnostic, 'Should provide pattern matching diagnostics');
    }

    private async testGenericCompletion(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(2, 15); // Position after "func<T>"
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasGenericKeyword = completions.items.some(item => item.label === 'T');
        assert.ok(hasGenericKeyword, 'Should include "T" generic parameter');
    }

    private async testGenericDiagnostics(doc: vscode.TextDocument): Promise<void> {
        await this.waitForDiagnostics(doc);
        
        const diagnostics = vscode.languages.getDiagnostics(doc.uri);
        const hasGenericDiagnostic = diagnostics.some(d => 
            d.message.includes('generic') || d.message.includes('type')
        );
        
        assert.ok(hasGenericDiagnostic, 'Should provide generic type diagnostics');
    }

    private async testAsyncCompletion(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(1, 15); // Position after "async "
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasAsyncKeyword = completions.items.some(item => item.label === 'async');
        assert.ok(hasAsyncKeyword, 'Should include "async" keyword');
    }

    private async testAsyncDiagnostics(doc: vscode.TextDocument): Promise<void> {
        await this.waitForDiagnostics(doc);
        
        const diagnostics = vscode.languages.getDiagnostics(doc.uri);
        const hasAsyncDiagnostic = diagnostics.some(d => 
            d.message.includes('async') || d.message.includes('await')
        );
        
        assert.ok(hasAsyncDiagnostic, 'Should provide async/await diagnostics');
    }

    private async testAIAnnotationCompletion(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(10, 1); // Position after "@"
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasAIAnnotation = completions.items.some(item => 
            item.label && item.label.startsWith('@ai_')
        );
        assert.ok(hasAIAnnotation, 'Should include AI annotations');
    }

    private async testAIFunctionCompletion(doc: vscode.TextDocument): Promise<void> {
        const position = new vscode.Position(11, 20); // Position after "ai_"
        const completions = await vscode.commands.executeCommand<vscode.CompletionList>(
            'vscode.executeCompletionItemProvider',
            { document: doc, position }
        );
        
        const hasAIFunction = completions.items.some(item => 
            item.label === 'train' || item.label === 'predict'
        );
        assert.ok(hasAIFunction, 'Should include AI functions');
    }

    // Test content generators
    
    private getCompletionTestContent(): string {
        return `
func test_function(param: string) -> int {
    return param.length;
}

func test_variable() -> void {
    let test_var = "hello";
}

class TestClass {
    func method() -> void {
        // TODO: implement
    }
}
`;
    }

    private getDefinitionTestContent(): string {
        return `
func test_function() -> int {
    return 42;
}

func test_variable() -> void {
    let test_var = "hello";
}

class TestClass {
    func method() -> void {
        // TODO: implement
    }
}
`;
    }

    private getReferencesTestContent(): string {
        return `
func test_function() -> int {
    return 42;
}

func main() -> void {
    let result = test_function();
    test_variable = "updated";
    result = test_function();
}
`;
    }

    private getHoverTestContent(): string {
        return `
func test_function(param: string) -> int {
    return param.length;
}

func test_variable() -> void {
    let test_var = "hello";
}

func main() -> void {
    let result = test_function();
    test_variable = "updated";
    result = test_function();
}
`;
    }

    private getSignatureTestContent(): string {
        return `
func test_function(param1: string, param2: int) -> int {
    return param1.length + param2;
}

func main() -> void {
    test_function("hello", 42);
}
`;
    }

    private getCodeActionsTestContent(): string {
        return `
func invalid_syntax() {
    return 42;
}
`;
    }

    private getFormattingTestContent(): string {
        return `
func test_function() -> int {
return 42;
}
`;
    }

    private getPatternMatchingTestContent(): string {
        return `
func test_pattern(value: int) -> string {
    match value {
        case 0:
            return "zero"
        case 1:
            return "one"
        case _:
            return "other"
    }
}
`;
    }

    private getGenericsTestContent(): string {
        return `
func generic_function<T>(value: T) -> T {
    return value;
}

func main() -> void {
    let result = generic_function<string>("hello");
}
`;
    }

    private getAsyncAwaitTestContent(): string {
        return `
async func async_function() -> int {
    await some_async_operation();
    return 42;
}

func main() -> void {
    let result = await async_function();
}
`;
    }

    private getAITestContent(): string {
        return `
@ai_agent
func ai_function() -> string {
    return "ai_result";
}

func main() -> void {
    let result = ai_function();
}
`;
    }

    private getLargeTestContent(): string {
        let content = '';
        for (let i = 0; i < 1000; i++) {
            content += `func function_${i}() -> int {\n    return ${i};\n}\n`;
        }
        return content;
    }

    // Utility methods
    
    private async createTestDocument(fileName: string, content: string): Promise<vscode.TextDocument> {
        const filePath = path.join(this.workspaceFolder?.uri.fsPath || '', fileName);
        const uri = vscode.Uri.file(filePath);
        
        const document = await vscode.workspace.openTextDocument({ content, uri });
        await new Promise(resolve => setTimeout(resolve, 100)); // Wait for document to be processed
        
        return document;
    }

    private findSymbolPosition(doc: vscode.TextDocument, symbol: string): vscode.Position | undefined {
        const text = doc.getText();
        const index = text.indexOf(symbol);
        if (index === -1) return undefined;
        
        const lines = text.split('\n');
        let charCount = 0;
        for (let i = 0; i < lines.length; i++) {
            if (lines[i].includes(symbol)) {
                break;
            }
            charCount += lines[i].length + 1; // +1 for newline
        }
        
        const lineIndex = text.substring(0, index).split('\n').length - 1;
        const charIndex = index - charCount + lines[lineIndex].indexOf(symbol);
        
        return new vscode.Position(lineIndex, charIndex);
    }

    private async waitForLSPInitialization(): Promise<void> {
        // Wait for LSP to initialize (max 10 seconds)
        let attempts = 0;
        while (attempts < 100) { // 10 seconds * 10 attempts per 100ms
            const config = vscode.workspace.getConfiguration('noodle');
            const lspEnabled = config.get<boolean>('lsp.enabled', true);
            
            // Check if LSP is running by trying to get completions
            try {
                await vscode.commands.executeCommand('vscode.executeCompletionItemProvider', {
                    document: await vscode.workspace.openTextDocument({ content: 'test' }),
                    position: new vscode.Position(0, 0)
                });
                return; // Success - LSP is running
            } catch {
                // LSP not ready yet
            }
            
            await new Promise(resolve => setTimeout(resolve, 100));
            attempts++;
        }
        
        throw new Error('LSP initialization timeout');
    }

    private async waitForDiagnostics(doc: vscode.TextDocument): Promise<void> {
        // Wait for diagnostics to be processed
        let attempts = 0;
        while (attempts < 50) { // 5 seconds max
            const diagnostics = vscode.languages.getDiagnostics(doc.uri);
            if (diagnostics.length > 0) {
                return;
            }
            
            await new Promise(resolve => setTimeout(resolve, 100));
            attempts++;
        }
    }
}

// Export test runner
export async function runLSPTests(extensionPath: string): Promise<void> {
    const testSuite = new NoodleLSPTestSuite(extensionPath);
    await testSuite.runAllTests();
}