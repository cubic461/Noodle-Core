import * as vscodeTypes from './vscode-types';

/**
 * Simplified Mock VS Code API for testing
 */
export class MockVSCodeAPI {
    private static instance: MockVSCodeAPI;
    private disposables: vscodeTypes.Disposable[] = [];
    private outputChannels: Map<string, vscodeTypes.OutputChannel> = new Map();
    private statusBars: vscodeTypes.StatusBarItem[] = [];
    private webviewPanels: vscodeTypes.WebviewPanel[] = [];
    private terminals: vscodeTypes.Terminal[] = [];
    private treeDataProviders: Map<string, any> = new Map();
    private commands: Map<string, vscodeTypes.Disposable> = new Map();
    private diagnostics: Map<string, vscodeTypes.Diagnostic[]> = new Map();

    public static getInstance(): MockVSCodeAPI {
        if (!MockVSCodeAPI.instance) {
            MockVSCodeAPI.instance = new MockVSCodeAPI();
        }
        return MockVSCodeAPI.instance;
    }

    private constructor() { }

    // Output Channel mocks
    public createOutputChannel(name: string): vscodeTypes.OutputChannel {
        const channel = {
            name,
            append: jest.fn(),
            appendLine: jest.fn(),
            clear: jest.fn(),
            show: jest.fn(),
            hide: jest.fn(),
            dispose: jest.fn()
        };
        this.outputChannels.set(name, channel);
        return channel;
    }

    public getOutputChannel(name: string): vscodeTypes.OutputChannel | undefined {
        return this.outputChannels.get(name);
    }

    // Status Bar mocks
    public createStatusBarItem(alignment?: vscodeTypes.StatusBarAlignment, priority?: number): vscodeTypes.StatusBarItem {
        const item = {
            text: '',
            tooltip: '',
            command: '',
            color: undefined,
            backgroundColor: undefined,
            alignment: alignment || vscodeTypes.StatusBarAlignment.Left,
            priority: priority || 0,
            show: jest.fn(),
            hide: jest.fn(),
            dispose: jest.fn()
        };
        this.statusBars.push(item);
        return item;
    }

    public getStatusBars(): vscodeTypes.StatusBarItem[] {
        return [...this.statusBars];
    }

    // Webview Panel mocks
    public createWebviewPanel(
        viewType: string,
        title: string,
        showOptions: vscodeTypes.ViewColumn | { viewColumn: vscodeTypes.ViewColumn; preserveFocus?: boolean },
        options?: any
    ): vscodeTypes.WebviewPanel {
        const panel = {
            viewType,
            title,
            webview: {
                html: '',
                options: options || {},
                onDidReceiveMessage: jest.fn(),
                postMessage: jest.fn(),
                asWebviewUri: jest.fn(),
                cspSource: ''
            },
            visible: true,
            viewColumn: typeof showOptions === 'object' ? showOptions.viewColumn : showOptions,
            active: true,
            onDidChangeViewState: jest.fn(),
            onDidDispose: jest.fn(),
            reveal: jest.fn(),
            dispose: jest.fn()
        };
        this.webviewPanels.push(panel);
        return panel;
    }

    public getWebviewPanels(): vscodeTypes.WebviewPanel[] {
        return [...this.webviewPanels];
    }

    // Terminal mocks
    public createTerminal(options?: any): vscodeTypes.Terminal {
        const terminal = {
            name: options?.name || 'Test Terminal',
            creationOptions: options,
            exitStatus: undefined,
            processId: undefined,
            sendText: jest.fn(),
            show: jest.fn(),
            hide: jest.fn(),
            dispose: jest.fn(),
            onDidClose: jest.fn(),
            onDidInput: jest.fn()
        };
        this.terminals.push(terminal);
        return terminal;
    }

    public getTerminals(): vscodeTypes.Terminal[] {
        return [...this.terminals];
    }

    // Command mocks
    public registerCommand(command: string, callback: (...args: any[]) => any, thisArg?: any): vscodeTypes.Disposable {
        const disposable = {
            dispose: jest.fn()
        };
        this.commands.set(command, disposable);
        return disposable;
    }

    public executeCommand(command: string, ...args: any[]): Promise<any> {
        return Promise.resolve();
    }

    public getCommands(): string[] {
        return Array.from(this.commands.keys());
    }

    // Tree Data Provider mocks
    public registerTreeDataProvider<T>(
        viewId: string,
        treeDataProvider: any
    ): vscodeTypes.Disposable {
        const disposable = {
            dispose: jest.fn()
        };
        this.treeDataProviders.set(viewId, treeDataProvider);
        return disposable;
    }

    public getTreeDataProvider(viewId: string): any {
        return this.treeDataProviders.get(viewId);
    }

    // Diagnostic mocks
    public createDiagnosticCollection(name: string): vscodeTypes.DiagnosticCollection {
        const collection = {
            name,
            get: jest.fn(),
            has: jest.fn(),
            set: jest.fn(),
            delete: jest.fn(),
            clear: jest.fn(),
            dispose: jest.fn(),
            forEach: jest.fn()
        };
        this.diagnostics.set(name, []);
        return collection;
    }

    public getDiagnostics(name: string): vscodeTypes.Diagnostic[] {
        return this.diagnostics.get(name) || [];
    }

    public setDiagnostics(name: string, diagnostics: vscodeTypes.Diagnostic[]): void {
        this.diagnostics.set(name, diagnostics);
    }

    // Configuration mocks
    public getConfiguration(section?: string): vscodeTypes.WorkspaceConfiguration {
        return {
            get: jest.fn(),
            update: jest.fn(),
            has: jest.fn(),
            inspect: jest.fn()
        };
    }

    // Workspace mocks
    public getWorkspaceFolders(): vscodeTypes.WorkspaceFolder[] {
        return [
            {
                uri: { fsPath: '/test/workspace', scheme: 'file' },
                name: 'test-workspace',
                index: 0
            }
        ];
    }

    // File System mocks
    public getFileSystem(): any {
        return {
            stat: jest.fn(),
            readFile: jest.fn(),
            writeFile: jest.fn(),
            createDirectory: jest.fn(),
            readDirectory: jest.fn(),
            delete: jest.fn(),
            rename: jest.fn(),
            copy: jest.fn()
        };
    }

    // Language Provider mocks
    public registerCompletionItemProvider(
        selector: any,
        provider: any,
        ...triggerCharacters: string[]
    ): vscodeTypes.Disposable {
        return { dispose: jest.fn() };
    }

    public registerDefinitionProvider(
        selector: any,
        provider: any
    ): vscodeTypes.Disposable {
        return { dispose: jest.fn() };
    }

    public registerHoverProvider(
        selector: any,
        provider: any
    ): vscodeTypes.Disposable {
        return { dispose: jest.fn() };
    }

    public registerSignatureHelpProvider(
        selector: any,
        provider: any,
        ...triggerCharacters: string[]
    ): vscodeTypes.Disposable {
        return { dispose: jest.fn() };
    }

    // Message mocks
    public showInformationMessage(message: string, ...items: string[]): Promise<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showErrorMessage(message: string, ...items: string[]): Promise<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showWarningMessage(message: string, ...items: string[]): Promise<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showInputBox(options?: any): Promise<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showQuickPick<T extends string>(
        items: T[] | any[],
        options?: any,
        token?: any
    ): Promise<T | undefined> {
        return Promise.resolve(undefined);
    }

    // Progress mocks
    public withProgress<R>(
        options: any,
        task: (progress: any, token: any) => Promise<R>
    ): Promise<R> {
        return Promise.resolve(undefined as R);
    }

    // Cleanup
    public dispose(): void {
        this.disposables.forEach(disposable => disposable.dispose());
        this.disposables = [];
        this.outputChannels.clear();
        this.statusBars = [];
        this.webviewPanels = [];
        this.terminals = [];
        this.treeDataProviders.clear();
        this.commands.clear();
        this.diagnostics.clear();
    }

    // Reset all mocks
    public reset(): void {
        this.dispose();
    }
}

/**
 * Mock Extension Context
 */
export class MockExtensionContext implements vscodeTypes.ExtensionContext {
    public subscriptions: vscodeTypes.Disposable[] = [];
    public workspaceState: vscodeTypes.Memento = new MockMemento();
    public globalState: vscodeTypes.Memento = new MockMemento();
    public extensionPath = '/test/extension';
    public storagePath = '/test/storage';
    public globalStoragePath = '/test/global-storage';
    public extensionUri = { fsPath: '/test/extension', scheme: 'file' };

    constructor() { }
}

/**
 * Mock Memento for state management
 */
export class MockMemento implements vscodeTypes.Memento {
    private storage: Map<string, any> = new Map();

    get<T>(key: string): T | undefined;
    get<T>(key: string, defaultValue: T): T;
    get<T>(key: string, defaultValue?: T): T | undefined {
        const value = this.storage.get(key);
        return value !== undefined ? value : defaultValue;
    }

    update(key: string, value: any): Promise<void> {
        this.storage.set(key, value);
        return Promise.resolve();
    }

    keys(): readonly string[] {
        return Array.from(this.storage.keys());
    }

    setKeysForSync(keys: string[]): void {
        // Mock implementation
    }
}

/**
 * Mock CancellationToken
 */
export class MockCancellationToken implements vscodeTypes.CancellationToken {
    public isCancellationRequested = false;
    public onCancellationRequested: vscodeTypes.Event<any> = jest.fn();
}

/**
 * Mock Text Document
 */
export class MockTextDocument implements vscodeTypes.TextDocument {
    public uri: vscodeTypes.Uri;
    public fileName: string;
    public isUntitled: boolean = false;
    public languageId: string;
    public version: number = 1;
    public isDirty: boolean = false;
    public isClosed: boolean = false;
    public eol: vscodeTypes.EndOfLine = vscodeTypes.EndOfLine.LF;
    public lineCount: number = 0;

    constructor(
        uri: vscodeTypes.Uri,
        content: string,
        languageId: string = 'noodle'
    ) {
        this.uri = uri;
        this.fileName = uri.fsPath;
        this.languageId = languageId;
        this.lineCount = content.split('\n').length;
    }

    public getText(range?: vscodeTypes.Range): string {
        return '';
    }

    public getWordRangeAtPosition(position: vscodeTypes.Position): vscodeTypes.Range | undefined {
        return undefined;
    }

    public getLineRange(lineNumber: number): vscodeTypes.Range {
        const start = { line: lineNumber, character: 0 };
        const end = { line: lineNumber, character: 100 };
        return { start, end };
    }

    public lineAt(lineNumber: number): vscodeTypes.TextLine {
        return {
            lineNumber,
            text: '',
            range: this.getLineRange(lineNumber),
            firstNonWhitespaceCharacterIndex: 0,
            isEmptyOrWhitespace: true,
            rangeIncludingLineBreak: this.getLineRange(lineNumber)
        };
    }

    public offsetAt(position: vscodeTypes.Position): number {
        return 0;
    }

    public positionAt(offset: number): vscodeTypes.Position {
        return { line: 0, character: 0 };
    }

    public save(): Promise<boolean> {
        return Promise.resolve(true);
    }
}