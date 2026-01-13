import * as assert from 'assert';
import * as vscode from 'vscode';

// Mock provider class for testing
class NoodleCompletionProvider implements vscode.CompletionItemProvider {
    provideCompletionItems(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken,
        context: vscode.CompletionContext
    ): vscode.ProviderResult<vscode.CompletionItem[]> {
        const line = document.lineAt(position.line).text;
        const linePrefix = line.substring(0, position.character);

        const items: vscode.CompletionItem[] = [];

        // Basic keywords
        if (linePrefix.includes('if')) {
            items.push(new vscode.CompletionItem('if statement', vscode.CompletionItemKind.Keyword));
        }

        if (linePrefix.includes('let')) {
            items.push(new vscode.CompletionItem('let declaration', vscode.CompletionItemKind.Keyword));
        }

        if (linePrefix.includes('print')) {
            items.push(new vscode.CompletionItem('print function', vscode.CompletionItemKind.Function));
        }

        if (linePrefix.includes('ai')) {
            items.push(new vscode.CompletionItem('ai model', vscode.CompletionItemKind.Keyword));
            items.push(new vscode.CompletionItem('ai train', vscode.CompletionItemKind.Keyword));
            items.push(new vscode.CompletionItem('ai prompt', vscode.CompletionItemKind.Keyword));
        }

        return items;
    }
}

suite('NoodleCompletionProvider Tests', () => {
    let provider: NoodleCompletionProvider;

    setup(() => {
        provider = new NoodleCompletionProvider();
    });

    test('should provide completion items for keywords', () => {
        const document = global.testUtils.createMockDocument('if');
        const position = global.testUtils.createMockPosition(0, 2);

        const result = provider.provideCompletionItems(
            document,
            position,
            {} as vscode.CancellationToken,
            {} as vscode.CompletionContext
        );

        assert.ok(result);
        assert.strictEqual(result!.length, 1);
        assert.strictEqual(result![0].label, 'if statement');
        assert.strictEqual(result![0].kind, vscode.CompletionItemKind.Keyword);
    });

    test('should provide completion items for AI keywords', () => {
        const document = global.testUtils.createMockDocument('ai');
        const position = global.testUtils.createMockPosition(0, 3);

        const result = provider.provideCompletionItems(
            document,
            position,
            {} as vscode.CancellationToken,
            {} as vscode.CompletionContext
        );

        assert.ok(result);
        assert.strictEqual(result!.length, 3);
        assert.strictEqual(result![0].label, 'ai model');
        assert.strictEqual(result![1].label, 'ai train');
        assert.strictEqual(result![2].label, 'ai prompt');
    });

    test('should provide no completion items for unknown context', () => {
        const document = global.testUtils.createMockDocument('unknown');
        const position = global.testUtils.createMockPosition(0, 7);

        const result = provider.provideCompletionItems(
            document,
            position,
            {} as vscode.CancellationToken,
            {} as vscode.CompletionContext
        );

        assert.ok(result);
        assert.strictEqual(result!.length, 0);
    });

    test('should handle cancellation token', () => {
        const document = global.testUtils.createMockDocument('if');
        const position = global.testUtils.createMockPosition(0, 2);
        const token = new vscode.CancellationTokenSource().token;
        token.cancel();

        const result = provider.provideCompletionItems(
            document,
            position,
            token,
            {} as vscode.CompletionContext
        );

        assert.ok(result);
        assert.strictEqual(result!.length, 0); // Should be empty when cancelled
    });

    teardown(() => {
        global.testUtils.cleanup();
    });
});