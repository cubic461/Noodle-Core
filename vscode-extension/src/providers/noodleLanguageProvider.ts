import * as vscode from 'vscode';
import { NoodleCompletionProvider } from './noodleCompletionProvider';
import { NoodleDefinitionProvider } from './noodleDefinitionProvider';
import { NoodleDiagnosticProvider } from './noodleDiagnosticProvider';
import { NoodleHoverProvider } from './noodleHoverProvider';
import { NoodleSignatureProvider } from './noodleSignatureProvider';

/**
 * NoodleCore Language Provider
 * 
 * This class manages all language-related functionality for NoodleCore files,
 * including syntax highlighting, completion, diagnostics, and other IntelliSense features.
 */
export class NoodleLanguageProvider {
    private completionProvider: vscode.Disposable;
    private definitionProvider: vscode.Disposable;
    private hoverProvider: vscode.Disposable;
    private signatureProvider: vscode.Disposable;
    private diagnosticProvider: NoodleDiagnosticProvider;

    constructor(private context: vscode.ExtensionContext) {
        this.diagnosticProvider = new NoodleDiagnosticProvider();
        this.registerProviders();
        this.setupEventHandlers();
    }

    /**
     * Register all language providers with VS Code
     */
    private registerProviders(): void {
        // Register completion provider
        this.completionProvider = vscode.languages.registerCompletionItemProvider(
            { scheme: 'file', language: 'noodle' },
            new NoodleCompletionProvider(),
            '.', // Trigger on dot for member access
            '(', // Trigger on opening parenthesis for function calls
            ' ', // Trigger on space for AI commands
            '@' // Trigger on @ for annotations
        );

        // Register definition provider
        this.definitionProvider = vscode.languages.registerDefinitionProvider(
            { scheme: 'file', language: 'noodle' },
            new NoodleDefinitionProvider()
        );

        // Register hover provider
        this.hoverProvider = vscode.languages.registerHoverProvider(
            { scheme: 'file', language: 'noodle' },
            new NoodleHoverProvider()
        );

        // Register signature help provider
        this.signatureProvider = vscode.languages.registerSignatureHelpProvider(
            { scheme: 'file', language: 'noodle' },
            new NoodleSignatureProvider(),
            '(', ',', // Trigger characters
        );

        // Register diagnostic provider
        this.diagnosticProvider.register();
    }

    /**
     * Setup event handlers for document changes
     */
    private setupEventHandlers(): void {
        // Handle document changes for real-time diagnostics
        const changeDisposable = vscode.workspace.onDidChangeTextDocument((event) => {
            if (event.document.languageId === 'noodle') {
                this.diagnosticProvider.updateDiagnostics(event.document);
            }
        });

        // Handle document open for initial diagnostics
        const openDisposable = vscode.workspace.onDidOpenTextDocument((document) => {
            if (document.languageId === 'noodle') {
                this.diagnosticProvider.updateDiagnostics(document);
            }
        });

        this.context.subscriptions.push(changeDisposable, openDisposable);
    }

    /**
     * Dispose all providers
     */
    public dispose(): void {
        this.completionProvider.dispose();
        this.definitionProvider.dispose();
        this.hoverProvider.dispose();
        this.signatureProvider.dispose();
        this.diagnosticProvider.dispose();
    }
}

/**
 * NoodleCore Language Configuration
 */
export const NOODLE_LANGUAGE_CONFIG = {
    // Language configuration
    comments: {
        lineComment: '//',
        blockComment: ['/*', '*/']
    },
    brackets: [
        ['{', '}'],
        ['[', ']'],
        ['(', ')']
    ],
    autoClosingPairs: [
        { open: '{', close: '}' },
        { open: '[', close: ']' },
        { open: '(', close: ')' },
        { open: '"', close: '"' },
        { open: "'", close: "'" },
        { open: '`', close: '`' }
    ],
    surroundingPairs: [
        { open: '{', close: '}' },
        { open: '[', close: ']' },
        { open: '(', close: ')' },
        { open: '"', close: '"' },
        { open: "'", close: "'" },
        { open: '`', close: '`' }
    ],
    folding: {
        markers: {
            start: new RegExp('^\\s*//\\s*#region\\b'),
            end: new RegExp('^\\s*//\\s*#endregion\\b')
        }
    },
    wordPattern: /(-?\d*\.\d\w*)|([^\`\~\!\@\#\%\^\&\*\(\)\-\=\+\[\{\]\}\\\|\;\:\'\"\,\.\<\>\/\?\s]+)/g,
    indentationRules: {
        increaseIndentPattern: new RegExp('^((?!\\/\\/).)*(\\{[^}"\'`]*|\\([^)"\'`]*|\\[[^\\]"\'`]*)$'),
        decreaseIndentPattern: new RegExp('^((?!.*?\\/\\*).*\\*/)?\\s*[\\}\\]].*$')
    }
};

/**
 * NoodleCore Keywords and Built-ins
 */
export const NOODLE_KEYWORDS = {
    // Control flow
    control: [
        'if', 'else', 'elif', 'for', 'while', 'do', 'break', 'continue',
        'switch', 'case', 'default', 'return', 'yield', 'await', 'async'
    ],

    // Declarations
    declaration: [
        'func', 'function', 'let', 'const', 'var', 'type', 'interface',
        'class', 'enum', 'struct', 'implements', 'extends', 'import', 'export',
        'module', 'package'
    ],

    // Types
    types: [
        'int', 'float', 'string', 'bool', 'char', 'byte', 'array', 'list',
        'map', 'set', 'void', 'null', 'true', 'false'
    ],

    // Modifiers
    modifiers: [
        'public', 'private', 'protected', 'static', 'final', 'abstract',
        'virtual', 'override', 'async', 'await', 'yield'
    ],

    // Built-in functions
    builtins: [
        'print', 'println', 'input', 'read', 'write', 'open', 'close',
        'len', 'size', 'append', 'push', 'pop', 'sort', 'filter', 'map'
    ],

    // AI-specific keywords
    ai: [
        'ai', 'agent', 'model', 'train', 'predict', 'transform', 'validate',
        'compile', 'run', 'debug', 'test', 'optimize', 'refactor', 'learn',
        'dataset', 'pipeline', 'neural', 'network', 'tensor', 'matrix'
    ],

    // Exception handling
    exceptions: [
        'try', 'catch', 'finally', 'throw', 'error', 'exception'
    ],

    // Advanced types
    advancedTypes: [
        'String', 'Number', 'Boolean', 'Array', 'Map', 'Set', 'List',
        'Dictionary', 'Function', 'Promise', 'Stream', 'Buffer', 'Tensor',
        'Matrix', 'Vector', 'AIModel', 'NeuralNetwork', 'Dataset', 'Pipeline',
        'Agent', 'Workspace'
    ]
};

/**
 * NoodleCore Snippets
 */
export const NOODLE_SNIPPETS = {
    // Function definition
    'function': {
        prefix: 'func',
        body: [
            'func ${1:functionName}(${2:params}) {',
            '\t${3:// TODO: Implement function}',
            '\treturn ${4:null}',
            '}'
        ],
        description: 'Create a function'
    },

    // AI model definition
    'ai_model': {
        prefix: 'ai_model',
        body: [
            'ai model ${1:modelName} {',
            '\ttype: ${2:neural_network}',
            '\tlayers: [${3:input, hidden, output}]',
            '\tactivation: ${4:relu}',
            '\toptimizer: ${5:adam}',
            '\tloss: ${6:mse}',
            '}'
        ],
        description: 'Create an AI model definition'
    },

    // Agent definition
    'agent': {
        prefix: 'agent',
        body: [
            'agent ${1:agentName} {',
            '\trole: "${2:developer}"',
            '\tcapabilities: [${3:code_analysis, debugging}]',
            '\ttools: [${4:editor, terminal}]',
            '\tprompt: "${5:You are a helpful AI assistant.}"',
            '}'
        ],
        description: 'Create an AI agent definition'
    },

    // If statement
    'if': {
        prefix: 'if',
        body: [
            'if (${1:condition}) {',
            '\t${2:// TODO: Implement if block}',
            '}'
        ],
        description: 'Create an if statement'
    },

    // For loop
    'for': {
        prefix: 'for',
        body: [
            'for (${1:i} = 0; ${1:i} < ${2:array}.len(); ${1:i}++) {',
            '\t${3:// TODO: Implement loop body}',
            '}'
        ],
        description: 'Create a for loop'
    },

    // Class definition
    'class': {
        prefix: 'class',
        body: [
            'class ${1:ClassName} {',
            '\t${2:// Properties}',
            '\t',
            '\tconstructor(${3:params}) {',
            '\t\t${4:// TODO: Initialize properties}',
            '\t}',
            '\t',
            '\t${5:// Methods}',
            '}'
        ],
        description: 'Create a class'
    },

    // Try-catch block
    'try': {
        prefix: 'try',
        body: [
            'try {',
            '\t${1:// TODO: Try block}',
            '} catch (${2:error}) {',
            '\t${3:// TODO: Handle error}',
            '}'
        ],
        description: 'Create a try-catch block'
    },

    // AI training pipeline
    'pipeline': {
        prefix: 'pipeline',
        body: [
            'pipeline ${1:pipelineName} {',
            '\tinput: ${2:dataset}',
            '\tsteps: [',
            '\t\t${3:preprocess},',
            '\t\t${4:train},',
            '\t\t${5:evaluate}',
            '\t]',
            '\toutput: ${6:model}',
            '}'
        ],
        description: 'Create an AI training pipeline'
    }
};