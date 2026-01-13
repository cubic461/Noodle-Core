import * as assert from 'assert';
import * as vscode from 'vscode';

// Mock provider class for testing
class NoodleSignatureHelpProvider implements vscode.SignatureHelpProvider {
    provideSignatureHelp(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken,
        context: vscode.SignatureHelpContext
    ): vscode.ProviderResult<vscode.SignatureHelp> {
        const line = document.lineAt(position.line).text;
        const linePrefix = line.substring(0, position.character);

        // Mock implementation for testing
        if (linePrefix.includes('print(')) {
            const signatureHelp = new vscode.SignatureHelp();
            signatureHelp.signatures = [
                new vscode.SignatureInformation(
                    'print(message: string)',
                    'Print output to console'
                )
            ];
            signatureHelp.signatures[0].parameters = [
                new vscode.ParameterInformation(
                    'message: string',
                    'The message to print'
                )
            ];
            signatureHelp.activeSignature = 0;
            signatureHelp.activeParameter = 0;
            return signatureHelp;
        }

        if (linePrefix.includes('ai model ')) {
            const signatureHelp = new vscode.SignatureHelp();
            signatureHelp.signatures = [
                new vscode.SignatureInformation(
                    'ai model <modelName>',
                    'AI model configuration'
                )
            ];
            signatureHelp.signatures[0].parameters = [
                new vscode.ParameterInformation(
                    'modelName',
                    'The name of the AI model'
                )
            ];
            signatureHelp.activeSignature = 0;
            signatureHelp.activeParameter = 0;
            return signatureHelp;
        }

        if (linePrefix.includes('ai prompt ')) {
            const signatureHelp = new vscode.SignatureHelp();
            signatureHelp.signatures = [
                new vscode.SignatureInformation(
                    'ai prompt <prompt>',
                    'AI prompt configuration'
                )
            ];
            signatureHelp.signatures[0].parameters = [
                new vscode.ParameterInformation(
                    'prompt',
                    'The prompt for AI'
                )
            ];
            signatureHelp.activeSignature = 0;
            signatureHelp.activeParameter = 0;
            return signatureHelp;
        }

        if (linePrefix.includes('ai train ')) {
            const signatureHelp = new vscode.SignatureHelp();
            signatureHelp.signatures = [
                new vscode.SignatureInformation(
                    'ai train <modelName> <dataset>',
                    'AI model training'
                )
            ];
            signatureHelp.signatures[0].parameters = [
                new vscode.ParameterInformation(
                    'modelName',
                    'The name of the model to train'
                ),
                new vscode.ParameterInformation(
                    'dataset',
                    'The dataset to use for training'
                )
            ];
            signatureHelp.activeSignature = 0;
            signatureHelp.activeParameter = 0;
            return signatureHelp;
        }

        return undefined;
    }
}

suite('NoodleSignatureHelpProvider Tests', () => {
    let provider: NoodleSignatureHelpProvider;

    setup(() => {
        provider = new NoodleSignatureHelpProvider();
    });

    test('should return signature help for function calls', async () => {
        const document = {
            getText: () => 'print("Hello, World!");',
            lineAt: () => ({ text: 'print("Hello, World!");' }),
            uri: { fsPath: '/test/file.nc' },
            languageId: 'noodle'
        } as vscode.TextDocument;
        const position = new vscode.Position(0, 10);
        const token = {} as vscode.CancellationToken;
        const context = {} as vscode.SignatureHelpContext;

        const signatureHelp = await provider.provideSignatureHelp(document, position, token, context);

        assert.ok(signatureHelp);
        assert.strictEqual(signatureHelp!.signatures.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].label, 'print(message: string)');
        assert.strictEqual(signatureHelp!.signatures[0].parameters!.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].parameters![0].label, 'message: string');
    });

    test('should return signature help for AI model functions', async () => {
        const document = {
            getText: () => 'ai model testModel',
            lineAt: () => ({ text: 'ai model testModel' }),
            uri: { fsPath: '/test/file.nc' },
            languageId: 'noodle'
        } as vscode.TextDocument;
        const position = new vscode.Position(0, 15);
        const token = {} as vscode.CancellationToken;
        const context = {} as vscode.SignatureHelpContext;

        const signatureHelp = await provider.provideSignatureHelp(document, position, token, context);

        assert.ok(signatureHelp);
        assert.strictEqual(signatureHelp!.signatures.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].label, 'ai model <modelName>');
        assert.strictEqual(signatureHelp!.signatures[0].parameters!.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].parameters![0].label, 'modelName');
    });

    test('should return signature help for AI prompt functions', async () => {
        const document = {
            getText: () => 'ai prompt "Generate code"',
            lineAt: () => ({ text: 'ai prompt "Generate code"' }),
            uri: { fsPath: '/test/file.nc' },
            languageId: 'noodle'
        } as vscode.TextDocument;
        const position = new vscode.Position(0, 20);
        const token = {} as vscode.CancellationToken;
        const context = {} as vscode.SignatureHelpContext;

        const signatureHelp = await provider.provideSignatureHelp(document, position, token, context);

        assert.ok(signatureHelp);
        assert.strictEqual(signatureHelp!.signatures.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].label, 'ai prompt <prompt>');
        assert.strictEqual(signatureHelp!.signatures[0].parameters!.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].parameters![0].label, 'prompt');
    });

    test('should return signature help for AI train functions', async () => {
        const document = {
            getText: () => 'ai train myModel dataset.csv',
            lineAt: () => ({ text: 'ai train myModel dataset.csv' }),
            uri: { fsPath: '/test/file.nc' },
            languageId: 'noodle'
        } as vscode.TextDocument;
        const position = new vscode.Position(0, 20);
        const token = {} as vscode.CancellationToken;
        const context = {} as vscode.SignatureHelpContext;

        const signatureHelp = await provider.provideSignatureHelp(document, position, token, context);

        assert.ok(signatureHelp);
        assert.strictEqual(signatureHelp!.signatures.length, 1);
        assert.strictEqual(signatureHelp!.signatures[0].label, 'ai train <modelName> <dataset>');
        assert.strictEqual(signatureHelp!.signatures[0].parameters!.length, 2);
        assert.strictEqual(signatureHelp!.signatures[0].parameters![0].label, 'modelName');
        assert.strictEqual(signatureHelp!.signatures[0].parameters![1].label, 'dataset');
    });

    test('should return undefined for non-function context', async () => {
        const document = {
            getText: () => 'let x = 42;',
            lineAt: () => ({ text: 'let x = 42;' }),
            uri: { fsPath: '/test/file.nc' },
            languageId: 'noodle'
        } as vscode.TextDocument;
        const position = new vscode.Position(0, 8);
        const token = {} as vscode.CancellationToken;
        const context = {} as vscode.SignatureHelpContext;

        const signatureHelp = await provider.provideSignatureHelp(document, position, token, context);

        assert.strictEqual(signatureHelp, undefined);
    });
});