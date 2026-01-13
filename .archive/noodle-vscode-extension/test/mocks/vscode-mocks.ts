/**
 * Mock VS Code API utilities for testing
 */

// Define basic types to avoid import issues
type Thenable<T> = Promise<T>;

/**
 * Mock VS Code API utilities for testing
 */
export class MockVSCodeAPI {
    private static instance: MockVSCodeAPI;
    private disposables: vscode.Disposable[] = [];
    private outputChannels: Map<string, vscode.OutputChannel> = new Map();
    private statusBars: vscode.StatusBarItem[] = [];
    private webviewPanels: vscode.WebviewPanel[] = [];
    private terminals: vscode.Terminal[] = [];
    private treeDataProviders: Map<string, any> = new Map();
    private commands: Map<string, vscode.Disposable> = new Map();
    private diagnostics: Map<string, vscode.Diagnostic[]> = new Map();

    public static getInstance(): MockVSCodeAPI {
        if (!MockVSCodeAPI.instance) {
            MockVSCodeAPI.instance = new MockVSCodeAPI();
        }
        return MockVSCodeAPI.instance;
    }

    private constructor() { }

    // Output Channel mocks
    public createOutputChannel(name: string): vscode.OutputChannel {
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

    public getOutputChannel(name: string): vscode.OutputChannel | undefined {
        return this.outputChannels.get(name);
    }

    // Status Bar mocks
    public createStatusBarItem(alignment?: vscode.StatusBarAlignment, priority?: number): vscode.StatusBarItem {
        const item = {
            text: '',
            tooltip: '',
            command: '',
            color: undefined,
            backgroundColor: undefined,
            alignment: alignment || vscode.StatusBarAlignment.Left,
            priority: priority || 0,
            show: jest.fn(),
            hide: jest.fn(),
            dispose: jest.fn()
        };
        this.statusBars.push(item);
        return item;
    }

    public getStatusBars(): vscode.StatusBarItem[] {
        return [...this.statusBars];
    }

    // Webview Panel mocks
    public createWebviewPanel(
        viewType: string,
        title: string,
        showOptions: vscode.ViewColumn | { viewColumn: vscode.ViewColumn; preserveFocus?: boolean },
        options?: vscode.WebviewPanelOptions & vscode.WebviewOptions
    ): vscode.WebviewPanel {
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

    public getWebviewPanels(): vscode.WebviewPanel[] {
        return [...this.webviewPanels];
    }

    // Terminal mocks
    public createTerminal(options?: vscode.TerminalOptions | vscode.ExtensionTerminalOptions): vscode.Terminal {
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

    public getTerminals(): vscode.Terminal[] {
        return [...this.terminals];
    }

    // Command mocks
    public registerCommand(command: string, callback: (...args: any[]) => any, thisArg?: any): vscode.Disposable {
        const disposable = {
            dispose: jest.fn()
        };
        this.commands.set(command, disposable);
        return disposable;
    }

    public executeCommand(command: string, ...args: any[]): Thenable<any> {
        return Promise.resolve();
    }

    public getCommands(): string[] {
        return Array.from(this.commands.keys());
    }

    // Tree Data Provider mocks
    public registerTreeDataProvider<T>(
        viewId: string,
        treeDataProvider: vscode.TreeDataProvider<T>
    ): vscode.Disposable {
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
    public createDiagnosticCollection(name: string): vscode.DiagnosticCollection {
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

    public getDiagnostics(name: string): vscode.Diagnostic[] {
        return this.diagnostics.get(name) || [];
    }

    public setDiagnostics(name: string, diagnostics: vscode.Diagnostic[]): void {
        this.diagnostics.set(name, diagnostics);
    }

    // Configuration mocks
    public getConfiguration(section?: string): vscode.WorkspaceConfiguration {
        return {
            get: jest.fn(),
            update: jest.fn(),
            has: jest.fn(),
            inspect: jest.fn()
        };
    }

    // Workspace mocks
    public getWorkspaceFolders(): vscode.WorkspaceFolder[] {
        return [
            {
                uri: vscode.Uri.file('/test/workspace'),
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
        selector: vscode.DocumentSelector,
        provider: vscode.CompletionItemProvider,
        ...triggerCharacters: string[]
    ): vscode.Disposable {
        return { dispose: jest.fn() };
    }

    public registerDefinitionProvider(
        selector: vscode.DocumentSelector,
        provider: vscode.DefinitionProvider
    ): vscode.Disposable {
        return { dispose: jest.fn() };
    }

    public registerHoverProvider(
        selector: vscode.DocumentSelector,
        provider: vscode.HoverProvider
    ): vscode.Disposable {
        return { dispose: jest.fn() };
    }

    public registerSignatureHelpProvider(
        selector: vscode.DocumentSelector,
        provider: vscode.SignatureHelpProvider,
        ...triggerCharacters: string[]
    ): vscode.Disposable {
        return { dispose: jest.fn() };
    }

    // Message mocks
    public showInformationMessage(message: string, ...items: string[]): Thenable<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showErrorMessage(message: string, ...items: string[]): Thenable<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showWarningMessage(message: string, ...items: string[]): Thenable<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showInputBox(options?: vscode.InputBoxOptions): Thenable<string | undefined> {
        return Promise.resolve(undefined);
    }

    public showQuickPick<T extends string>(
        items: T[] | vscode.QuickPickItem<T>[],
        options?: vscode.QuickPickOptions,
        token?: vscode.CancellationToken
    ): Thenable<T | undefined> {
        return Promise.resolve(undefined);
    }

    // Progress mocks
    public withProgress<R>(
        options: vscode.ProgressOptions,
        task: (progress: vscode.Progress<{ message?: string; increment?: number }>, token: vscode.CancellationToken) => Thenable<R>
    ): Thenable<R> {
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
export class MockExtensionContext implements vscode.ExtensionContext {
    public subscriptions: vscode.Disposable[] = [];
    public workspaceState: vscode.Memento = new MockMemento();
    public globalState: vscode.Memento = new MockMemento();
    public extensionPath = '/test/extension';
    public storagePath = '/test/storage';
    public globalStoragePath = '/test/global-storage';
    public extensionUri = vscode.Uri.file('/test/extension');

    constructor() { }
}

/**
 * Mock Memento for state management
 */
export class MockMemento implements vscode.Memento {
    private storage: Map<string, any> = new Map();

    get<T>(key: string): T | undefined;
    get<T>(key: string, defaultValue: T): T;
    get<T>(key: string, defaultValue?: T): T | undefined {
        const value = this.storage.get(key);
        return value !== undefined ? value : defaultValue;
    }

    update(key: string, value: any): Thenable<void> {
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
export class MockCancellationToken implements vscode.CancellationToken {
    public isCancellationRequested = false;
    public onCancellationRequested: vscode.Event<any> = jest.fn();
}

/**
 * Mock Text Document
 */
export class MockTextDocument implements vscode.TextDocument {
    public uri: vscode.Uri;
    public fileName: string;
    public isUntitled: boolean = false;
    public languageId: string;
    public version: number = 1;
    public isDirty: boolean = false;
    public isClosed: boolean = false;
    public eol: vscode.EndOfLine = vscode.EndOfLine.LF;
    public lineCount: number = 0;

    constructor(
        uri: vscode.Uri,
        content: string,
        languageId: string = 'noodle'
    ) {
        this.uri = uri;
        this.fileName = uri.fsPath;
        this.languageId = languageId;
        this.lineCount = content.split('\n').length;
    }

    public getText(range?: vscode.Range): string {
        return '';
    }

    public getWordRangeAtPosition(position: vscode.Position): vscode.Range | undefined {
        return undefined;
    }

    public getLineRange(lineNumber: number): vscode.Range {
        const start = new vscode.Position(lineNumber, 0);
        const end = new vscode.Position(lineNumber, 100);
        return new vscode.Range(start, end);
    }

    public lineAt(lineNumber: number): vscode.TextLine {
        return {
            lineNumber,
            text: '',
            range: this.getLineRange(lineNumber),
            firstNonWhitespaceCharacterIndex: 0,
            isEmptyOrWhitespace: true,
            rangeIncludingLineBreak: this.getLineRange(lineNumber)
        };
    }

    public offsetAt(position: vscode.Position): number {
        return 0;
    }

    public positionAt(offset: number): vscode.Position {
        return new vscode.Position(0, 0);
    }

    public save(): Thenable<boolean> {
        return Promise.resolve(true);
    }
}