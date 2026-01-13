import { NoodleHoverProvider } from '../../../src/providers/noodleHoverProvider';

describe('NoodleHoverProvider', () => {
    let provider: NoodleHoverProvider;

    beforeEach(() => {
        provider = new NoodleHoverProvider();
    });

    describe('provideHover', () => {
        it('should return hover information for keywords', () => {
            const document = {
                getText: () => 'if',
                getWordRangeAtPosition: () => ({ start: { line: 0, character: 0 }, end: { line: 0, character: 2 } }),
                lineAt: () => ({ text: 'if' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 1 };
            const token = {};

            const hover = provider.provideHover(document, position, token);

            expect(hover).toBeDefined();
            expect(hover!.contents).toContain('Conditional statement');
        });

        it('should return hover information for functions', () => {
            const document = {
                getText: () => 'print("Hello, World!");',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'print("Hello, World!");' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 6 };
            const token = {};

            const hover = provider.provideHover(document, position, token);

            expect(hover).toBeDefined();
            expect(hover!.contents).toContain('Print output to console');
        });

        it('should return hover information for AI keywords', () => {
            const document = {
                getText: () => 'ai model testModel',
                getWordRangeAtPosition: () => ({ start: { line: 0, character: 3 }, end: { line: 0, character: 16 } }),
                lineAt: () => ({ text: 'ai model testModel' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 10 };
            const token = {};

            const hover = provider.provideHover(document, position, token);

            expect(hover).toBeDefined();
            expect(hover!.contents).toContain('AI model configuration');
        });

        it('should return hover information for types', () => {
            const document = {
                getText: () => 'let data: Array<string> = [];',
                getWordRangeAtPosition: () => ({ start: { line: 0, character: 4 }, end: { line: 0, character: 29 } }),
                lineAt: () => ({ text: 'let data: Array<string> = [];' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 15 };
            const token = {};

            const hover = provider.provideHover(document, position, token);

            expect(hover).toBeDefined();
            expect(hover!.contents).toContain('Array type for string collections');
        });

        it('should return undefined for non-matching position', () => {
            const document = {
                getText: () => 'test code',
                getWordRangeAtPosition: () => undefined,
                lineAt: () => ({ text: 'test code' }),
                uri: { fsPath: '/test/file.nc' },
                languageId: 'noodle'
            };
            const position = { line: 0, character: 5 };
            const token = {};

            const hover = provider.provideHover(document, position, token);

            expect(hover).toBeUndefined();
        });
    });
});