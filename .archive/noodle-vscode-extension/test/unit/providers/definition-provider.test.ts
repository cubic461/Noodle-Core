import { NoodleDefinitionProvider } from '../../../src/providers/noodleDefinitionProvider';

describe('NoodleDefinitionProvider', () => {
    let provider: NoodleDefinitionProvider;

    beforeEach(() => {
        provider = new NoodleDefinitionProvider();
    });

    describe('provideDefinition', () => {
        it('should return definition for function in current document', () => {
            const document = {
                getText: () => 'func testFunction() {\n    // function body\n}',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'func testFunction() {' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 4 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(4);
        });

        it('should return definition for class in current document', () => {
            const document = {
                getText: () => 'class TestClass {\n    // class body\n}',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'class TestClass {' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 6 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(6);
        });

        it('should return definition for variable in current document', () => {
            const document = {
                getText: () => 'let testVariable = 5;',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'let testVariable = 5;' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 4 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(4);
        });

        it('should return definition for AI model in current document', () => {
            const document = {
                getText: () => 'ai model TestModel {\n    // model config\n}',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'ai model TestModel {' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 3 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(3);
        });

        it('should return definition for agent in current document', () => {
            const document = {
                getText: () => 'agent TestAgent {\n    // agent config\n}',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'agent TestAgent {' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 6 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(6);
        });

        it('should return definition for pipeline in current document', () => {
            const document = {
                getText: () => 'pipeline TestPipeline {\n    // pipeline config\n}',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'pipeline TestPipeline {' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 9 };
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeDefined();
            expect(definition!.uri.fsPath).toBe('/test/file.nc');
            expect(definition!.range.start.line).toBe(0);
            expect(definition!.range.start.character).toBe(9);
        });

        it('should search workspace for definition when not found in current document', async () => {
            const document = {
                getText: () => 'testFunction();\n// Call undefined function',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'testFunction();\n// Call undefined function' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 1, character: 15 };
            const token = {};

            // Access private method through reflection for testing
            const findDefinitionInWorkspace = (provider as any).findDefinitionInWorkspace;

            const definition = await provider.provideDefinition(document, position, token);

            expect(findDefinitionInWorkspace).toHaveBeenCalled();
            expect(definition).toBeUndefined();
        });

        it('should handle undefined position gracefully', () => {
            const document = {
                getText: () => 'test function',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'test function' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = undefined;
            const token = {};

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeUndefined();
        });

        it('should handle cancellation token', () => {
            const document = {
                getText: () => 'test function',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'test function' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 4 };
            const token = {
                isCancellationRequested: true
            };

            const definition = provider.provideDefinition(document, position, token);

            expect(definition).toBeUndefined();
        });
    });
});