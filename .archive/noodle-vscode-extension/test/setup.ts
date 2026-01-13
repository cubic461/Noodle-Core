
// Mock VS Code API for testing
const mockVSCode = {
    window: {
        activeTextEditor: undefined,
        visibleTextEditors: [],
        showErrorMessage: jest.fn(),
        showInformationMessage: jest.fn(),
        showWarningMessage: jest.fn(),
        showQuickPick: jest.fn(),
        showInputBox: jest.fn(),
        showOpenDialog: jest.fn(),
        showSaveDialog: jest.fn(),
        createOutputChannel: jest.fn(() => ({
            name: 'test',
            appendLine: jest.fn(),
            clear: jest.fn(),
            dispose: jest.fn(),
        })),
        createWebviewPanel: jest.fn(() => ({
            webview: {
                html: '',
                onDidReceiveMessage: jest.fn(),
                postMessage: jest.fn(),
            },
            reveal: jest.fn(),
            dispose: jest.fn(),
        })),
    },
    workspace: {
        workspaceFolders: [],
        getConfiguration: jest.fn(() => ({
            get: jest.fn(),
            update: jest.fn(),
        })),
        getWorkspaceFolder: jest.fn(),
        asRelativePath: jest.fn(),
        findFiles: jest.fn(),
        openTextDocument: jest.fn(),
        saveAll: jest.fn(),
    },
    commands: {
        registerCommand: jest.fn(),
        executeCommand: jest.fn(),
        getCommands: jest.fn(),
    },
    languages: {
        registerCompletionItemProvider: jest.fn(),
        registerHoverProvider: jest.fn(),
        registerDefinitionProvider: jest.fn(),
        registerSignatureHelpProvider: jest.fn(),
        registerDiagnosticCollection: jest.fn(),
        registerDocumentSemanticTokensProvider: jest.fn(),
        setLanguageConfiguration: jest.fn(),
    },
    debug: {
        registerDebugConfigurationProvider: jest.fn(),
        registerDebugAdapterDescriptorFactory: jest.fn(),
        startDebugging: jest.fn(),
        addBreakpoints: jest.fn(),
        removeBreakpoints: jest.fn(),
    },
    env: {
        appName: 'VS Code Test',
        appRoot: '/test',
        language: 'en',
        machineId: 'test-machine',
        sessionId: 'test-session',
    },
    Uri: {
        file: jest.fn((path: string) => ({ scheme: 'file', path })),
        parse: jest.fn(),
    },
    Range: jest.fn(),
    Position: jest.fn(),
    Location: jest.fn(),
    Diagnostic: jest.fn(),
    DiagnosticSeverity: {
        Error: 0,
        Warning: 1,
        Information: 2,
        Hint: 3,
    },
    CompletionItem: jest.fn(),
    CompletionItemKind: {
        Text: 1,
        Method: 2,
        Function: 3,
        Constructor: 4,
        Field: 5,
        Variable: 6,
        Class: 7,
        Interface: 8,
        Module: 9,
        Property: 10,
        Unit: 11,
        Value: 12,
        Enum: 13,
        Keyword: 14,
        Snippet: 15,
        Color: 16,
        File: 17,
        Reference: 18,
        Folder: 19,
        EnumMember: 20,
        Constant: 21,
        Struct: 22,
        Event: 23,
        Operator: 24,
        TypeParameter: 25,
    },
    SignatureHelp: jest.fn(),
    SignatureInformation: jest.fn(),
    ParameterInformation: jest.fn(),
    Hover: jest.fn(),
    MarkdownString: jest.fn(),
};

// Mock the vscode module
jest.mock('vscode', () => mockVSCode, { virtual: true });

// Global test utilities
(global as any).testUtils = {
    createMockDocument: (content: string, language = 'noodle') => ({
        getText: () => content,
        lineAt: (line: number) => ({
            text: content.split('\n')[line] || '',
        }),
        getWordRangeAtPosition: jest.fn(),
        uri: { fsPath: '/test/file.nc' },
        languageId: language,
    }),

    createMockPosition: (line: number, character: number) => ({ line, character }),

    createMockRange: (startLine: number, startChar: number, endLine: number, endChar: number) => ({
        start: { line: startLine, character: startChar },
        end: { line: endLine, character: endChar },
    }),

    createMockWorkspaceFolder: (name: string, uri: string) => ({
        name,
        uri,
        index: 0,
    }),

    cleanup: () => {
        jest.clearAllMocks();
    },
};

// Setup global test timeout
jest.setTimeout(30000);