/**
 * Basic VS Code type definitions for testing
 */

export interface Disposable {
    dispose(): void;
}

export interface OutputChannel {
    name: string;
    append(value: string): void;
    appendLine(value: string): void;
    clear(): void;
    show(): void;
    hide(): void;
    dispose(): void;
}

export interface StatusBarItem {
    text: string;
    tooltip?: string;
    command?: string;
    color?: string;
    backgroundColor?: string;
    alignment: StatusBarAlignment;
    priority: number;
    show(): void;
    hide(): void;
    dispose(): void;
}

export interface WebviewPanel {
    viewType: string;
    title: string;
    webview: Webview;
    visible: boolean;
    viewColumn: ViewColumn;
    active: boolean;
    onDidChangeViewState: Event<WebviewPanelOnDidChangeViewStateEvent>;
    onDidDispose: Event<void>;
    reveal(viewColumn?: ViewColumn): void;
    dispose(): void;
}

export interface Webview {
    html: string;
    options: WebviewOptions;
    onDidReceiveMessage: Event<any>;
    postMessage(message: any): void;
    asWebviewUri(localResource: string): Uri;
    cspSource: string;
}

export interface Terminal {
    name: string;
    creationOptions?: TerminalOptions | ExtensionTerminalOptions;
    exitStatus?: TerminalExitStatus;
    processId?: number;
    sendText(text: string): void;
    show(): void;
    hide(): void;
    dispose(): void;
    onDidClose: Event<void>;
    onDidInput: Event<TerminalDataWriteEvent>;
}

export interface DiagnosticCollection {
    name: string;
    get(uri: Uri): Diagnostic[];
    has(uri: Uri): boolean;
    set(uri: Uri, diagnostics: Diagnostic[]): void;
    delete(uri: Uri): void;
    clear(): void;
    dispose(): void;
    forEach(callback: (uri: Uri, diagnostics: Diagnostic[]) => void): void;
}

export interface WorkspaceConfiguration {
    get<T>(section: string, defaultValue?: T): T;
    update(section: string, value: any, configurationTarget?: ConfigurationTarget): Thenable<void>;
    has(section: string): boolean;
    inspect<T>(section: string): { key: string; defaultValue?: T; globalValue?: T; workspaceValue?: T; workspaceFolderValue?: T };
}

export interface Memento {
    get<T>(key: string): T | undefined;
    get<T>(key: string, defaultValue: T): T;
    update(key: string, value: any): Thenable<void>;
    keys(): readonly string[];
    setKeysForSync(keys: string[]): void;
}

export interface ExtensionContext {
    subscriptions: Disposable[];
    workspaceState: Memento;
    globalState: Memento;
    extensionPath: string;
    storagePath: string;
    globalStoragePath: string;
    extensionUri: Uri;
}

export interface TextDocument {
    uri: Uri;
    fileName: string;
    isUntitled: boolean;
    languageId: string;
    version: number;
    isDirty: boolean;
    isClosed: boolean;
    eol: EndOfLine;
    lineCount: number;
    getText(range?: Range): string;
    getWordRangeAtPosition(position: Position): Range | undefined;
    lineAt(lineNumber: number): TextLine;
    offsetAt(position: Position): number;
    positionAt(offset: number): Position;
    save(): Thenable<boolean>;
}

export interface TextLine {
    lineNumber: number;
    text: string;
    range: Range;
    firstNonWhitespaceCharacterIndex: number;
    isEmptyOrWhitespace: boolean;
    rangeIncludingLineBreak: Range;
}

export interface CancellationToken {
    isCancellationRequested: boolean;
    onCancellationRequested: Event<any>;
}

export enum StatusBarAlignment {
    Left = 1,
    Right = 2
}

export enum ViewColumn {
    One = 1,
    Two = 2,
    Three = 3
}

export enum EndOfLine {
    LF = 1,
    CRLF = 2,
    CR = 3
}

export enum ConfigurationTarget {
    Global = 1,
    Workspace = 2,
    WorkspaceFolder = 3
}

export interface WorkspaceFolder {
    uri: Uri;
    name: string;
    index: number;
}

export interface Uri {
    fsPath: string;
    scheme: string;
    path: string;
    query: string;
    fragment: string;
    with(change: { scheme?: string; authority?: string; path?: string; query?: string; fragment?: string }): Uri;
}

export interface Position {
    line: number;
    character: number;
}

export interface Range {
    start: Position;
    end: Position;
}

export interface Diagnostic {
    range: Range;
    message: string;
    severity: DiagnosticSeverity;
    source?: string;
    code?: string | number;
}

export enum DiagnosticSeverity {
    Error = 0,
    Warning = 1,
    Information = 2,
    Hint = 3
}

export interface TerminalOptions {
    name?: string;
    shellPath?: string;
    shellArgs?: string[];
    cwd?: string;
    env?: { [key: string]: string | null };
    strictEnv?: boolean;
}

export interface ExtensionTerminalOptions {
    name?: string;
    pty?: Pseudoterminal;
}

export interface TerminalExitStatus {
    code?: number;
}

export interface TerminalDataWriteEvent {
    data: string;
}

export interface Pseudoterminal {
    open: (initialDimensions: { columns: number; rows: number } | undefined) => void;
    close: () => void;
    input: (data: string) => void;
    setDimensions: (dimensions: { columns: number; rows: number }) => void;
    write: (data: string) => void;
}

export interface WebviewOptions {
    enableScripts?: boolean;
    retainContextWhenHidden?: boolean;
    localResourceRoots?: Uri[];
}

export interface WebviewPanelOptions {
    enableScripts?: boolean;
    retainContextWhenHidden?: boolean;
    localResourceRoots?: Uri[];
}

export interface WebviewPanelOnDidChangeViewStateEvent {
    webviewPanel: WebviewPanel;
}

export type Thenable<T> = Promise<T>;

export type Event<T> = (listener: (e: T) => any) => Disposable;