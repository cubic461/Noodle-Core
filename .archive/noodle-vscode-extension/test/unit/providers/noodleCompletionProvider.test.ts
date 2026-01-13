import * as vscode from 'vscode';
import { NoodleCompletionProvider } from '../../../src/providers/noodleCompletionProvider';
import { MockTextDocument, MockVSCodeAPI } from '../../mocks/vscode-mock';

describe('NoodleCompletionProvider', () => {
    let provider: NoodleCompletionProvider;
    let mockVSCodeAPI: MockVSCodeAPI;

    beforeEach(() => {
        mockVSCodeAPI = MockVSCodeAPI.getInstance();
        provider = new NoodleCompletionProvider();
    });

    afterEach(() => {
        mockVSCodeAPI.reset();
    });

    describe('provideCompletionItems', () => {
        it('should return completion items for control flow keywords', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'if condition {\n    // code\n}',
                'noodle'
            );
            const position = { line: 0, character: 5 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();
            expect(items.length).toBeGreaterThan(0);

            const keywordItems = items.filter(item =>
                item.kind === vscode.CompletionItemKind.Keyword
            );
            expect(keywordItems.length).toBeGreaterThan(0);
        });

        it('should return completion items for AI-specific keywords', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'ai model testModel {\n    // model config\n}',
                'noodle'
            );
            const position = { line: 0, character: 10 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();
            expect(items.length).toBeGreaterThan(0);

            const aiItems = items.filter(item =>
                item.kind === vscode.CompletionItemKind.Keyword ||
                item.kind === vscode.CompletionItemKind.Class
            );
            expect(aiItems.length).toBeGreaterThan(0);
        });

        it('should return completion items for snippets', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func',
                'noodle'
            );
            const position = { line: 0, character: 4 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();
            expect(items.length).toBeGreaterThan(0);

            const snippetItems = items.filter(item =>
                item.kind === vscode.CompletionItemKind.Snippet
            );
            expect(snippetItems.length).toBeGreaterThan(0);
        });

        it('should return context-aware completions in AI context', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'ai model testModel {\n    // model config\n}\nagent testAgent {\n    // agent config\n}',
                'noodle'
            );
            const position = { line: 2, character: 5 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();

            const aiContextItems = items.filter(item =>
                item.detail && item.detail.includes('AI')
            );
            expect(aiContextItems.length).toBeGreaterThan(0);
        });

        it('should return function context completions', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func testFunction() {\n    // function body\n}',
                'noodle'
            );
            const position = { line: 1, character: 15 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();

            const functionContextItems = items.filter(item =>
                item.detail && item.detail.includes('Function')
            );
            expect(functionContextItems.length).toBeGreaterThan(0);
        });

        it('should handle empty document gracefully', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                '',
                'noodle'
            );
            const position = { line: 0, character: 0 };
            const token = {} as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();
            expect(Array.isArray(items)).toBe(true);
        });

        it('should handle cancellation token', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func test()',
                'noodle'
            );
            const position = { line: 0, character: 5 };
            const token = {
                isCancellationRequested: true
            } as vscode.CancellationToken;
            const context = {} as vscode.CompletionContext;

            const items = provider.provideCompletionItems(document, position, token, context);

            expect(items).toBeDefined();
            // Should return empty array or handle cancellation gracefully
            expect(Array.isArray(items)).toBe(true);
        });
    });

    describe('addKeywordCompletions', () => {
        it('should add control flow keyword completions', () => {
            const items: vscode.CompletionItem[] = [];
            const linePrefix = 'if ';
            const currentWord = 'if';

            // Access private method through reflection for testing
            (provider as any).addKeywordCompletions(items, linePrefix, currentWord);

            expect(items.length).toBeGreaterThan(0);

            const controlFlowKeywords = items.filter(item =>
                item.detail === 'Control flow keyword'
            );
            expect(controlFlowKeywords.length).toBeGreaterThan(0);
        });

        it('should add AI keyword completions', () => {
            const items: vscode.CompletionItem[] = [];
            const linePrefix = 'ai ';
            const currentWord = 'ai';

            (provider as any).addAICompletions(items, linePrefix, currentWord);

            expect(items.length).toBeGreaterThan(0);

            const aiKeywords = items.filter(item =>
                item.detail === 'AI keyword'
            );
            expect(aiKeywords.length).toBeGreaterThan(0);
        });
    });

    describe('addSnippetCompletions', () => {
        it('should add code snippets', () => {
            const items: vscode.CompletionItem[] = [];
            const linePrefix = 'func';
            const currentWord = 'func';

            (provider as any).addSnippetCompletions(items, linePrefix, currentWord);

            expect(items.length).toBeGreaterThan(0);

            const snippetItems = items.filter(item =>
                item.kind === vscode.CompletionItemKind.Snippet
            );
            expect(snippetItems.length).toBeGreaterThan(0);
        });
    });

    describe('addContextCompletions', () => {
        it('should add AI context completions', () => {
            const items: vscode.CompletionItem[] = [];
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'ai model testModel {\n    // model config\n}',
                'noodle'
            );
            const position = { line: 1, character: 5 };
            const linePrefix = '    ';

            (provider as any).addContextCompletions(items, document, position, linePrefix);

            expect(items.length).toBeGreaterThan(0);
        });

        it('should add function context completions', () => {
            const items: vscode.CompletionItem[] = [];
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func testFunction() {\n    // function body\n}',
                'noodle'
            );
            const position = { line: 1, character: 15 };
            const linePrefix = '    ';

            (provider as any).addContextCompletions(items, document, position, linePrefix);

            expect(items.length).toBeGreaterThan(0);
        });
    });

    describe('isInAIContext', () => {
        it('should detect AI context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'ai model testModel {\n    // model config\n}',
                'noodle'
            );
            const position = { line: 1, character: 5 };

            const result = (provider as any).isInAIContext(document, position);

            expect(result).toBe(true);
        });

        it('should detect non-AI context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func testFunction() {\n    // function body\n}',
                'noodle'
            );
            const position = { line: 1, character: 15 };

            const result = (provider as any).isInAIContext(document, position);

            expect(result).toBe(false);
        });
    });

    describe('isInFunctionContext', () => {
        it('should detect function context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'func testFunction() {\n    // function body\n}',
                'noodle'
            );
            const position = { line: 1, character: 15 };

            const result = (provider as any).isInFunctionContext(document, position);

            expect(result).toBe(true);
        });

        it('should detect non-function context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'let variable = 5;',
                'noodle'
            );
            const position = { line: 1, character: 15 };

            const result = (provider as any).isInFunctionContext(document, position);

            expect(result).toBe(false);
        });
    });

    describe('isInClassContext', () => {
        it('should detect class context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'class TestClass {\n    // class body\n}',
                'noodle'
            );
            const position = { line: 1, character: 15 };

            const result = (provider as any).isInClassContext(document, position);

            expect(result).toBe(true);
        });

        it('should detect non-class context correctly', () => {
            const document = new MockTextDocument(
                { fsPath: '/test/file.nc', scheme: 'file' },
                'let variable = 5;',
                'noodle'
            );
            const position = { line: 1, character: 15 };

            const result = (provider as any).isInClassContext(document, position);

            expect(result).toBe(false);
        });
    });
});