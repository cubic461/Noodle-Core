"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.NoodleCompletionProvider = void 0;
const vscode = __importStar(require("vscode"));
const noodleLanguageProvider_1 = require("./noodleLanguageProvider");
/**
 * NoodleCore Completion Provider
 *
 * Provides intelligent code completion for NoodleCore files including:
 * - Keywords and language constructs
 * - AI-specific functions and agents
 * - Code snippets
 * - Context-aware suggestions
 */
class NoodleCompletionProvider {
    /**
     * Provide completion items for the given position
     */
    provideCompletionItems(document, position, token, context) {
        const linePrefix = document.lineAt(position).text.substring(0, position.character);
        const wordRange = document.getWordRangeAtPosition(position);
        const currentWord = wordRange ? document.getText(wordRange) : '';
        const completionItems = [];
        // Add keyword completions
        this.addKeywordCompletions(completionItems, linePrefix, currentWord);
        // Add AI-specific completions
        this.addAICompletions(completionItems, linePrefix, currentWord);
        // Add snippet completions
        this.addSnippetCompletions(completionItems, linePrefix, currentWord);
        // Add context-aware completions
        this.addContextCompletions(completionItems, document, position, linePrefix);
        return completionItems;
    }
    /**
     * Add keyword completions
     */
    addKeywordCompletions(items, linePrefix, currentWord) {
        // Control flow keywords
        noodleLanguageProvider_1.NOODLE_KEYWORDS.control.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Control flow keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore control flow keyword: \`${keyword}\``);
            items.push(item);
        });
        // Declaration keywords
        noodleLanguageProvider_1.NOODLE_KEYWORDS.declaration.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Declaration keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore declaration keyword: \`${keyword}\``);
            items.push(item);
        });
        // Type keywords
        noodleLanguageProvider_1.NOODLE_KEYWORDS.types.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Type keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore type keyword: \`${keyword}\``);
            items.push(item);
        });
        // Built-in functions
        noodleLanguageProvider_1.NOODLE_KEYWORDS.builtins.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Function);
            item.detail = 'Built-in function';
            item.documentation = new vscode.MarkdownString(`NoodleCore built-in function: \`${keyword}\``);
            items.push(item);
        });
    }
    /**
     * Add AI-specific completions
     */
    addAICompletions(items, linePrefix, currentWord) {
        // AI keywords
        noodleLanguageProvider_1.NOODLE_KEYWORDS.ai.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'AI keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore AI keyword: \`${keyword}\``);
            items.push(item);
        });
        // Advanced types
        noodleLanguageProvider_1.NOODLE_KEYWORDS.advancedTypes.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Class);
            item.detail = 'Advanced type';
            item.documentation = new vscode.MarkdownString(`NoodleCore advanced type: \`${keyword}\``);
            items.push(item);
        });
        // AI-specific completions for @ context
        if (linePrefix.endsWith('@')) {
            const aiAnnotations = [
                { name: '@ai_agent', description: 'Define an AI agent with specific capabilities' },
                { name: '@ai_model', description: 'Define an AI model configuration' },
                { name: '@ai_train', description: 'Train an AI model with specified data' },
                { name: '@ai_predict', description: 'Make predictions using an AI model' },
                { name: '@ai_refactor', description: 'Refactor code using AI assistance' },
                { name: '@ai_optimize', description: 'Optimize code performance using AI' },
                { name: '@ai_test', description: 'Generate tests using AI' },
                { name: '@ai_document', description: 'Generate documentation using AI' }
            ];
            aiAnnotations.forEach(annotation => {
                const item = new vscode.CompletionItem(annotation.name, vscode.CompletionItemKind.Snippet);
                item.detail = 'AI annotation';
                item.documentation = new vscode.MarkdownString(annotation.description);
                item.insertText = new vscode.SnippetString(annotation.name + ' ${1:parameters}');
                items.push(item);
            });
        }
    }
    /**
     * Add snippet completions
     */
    addSnippetCompletions(items, linePrefix, currentWord) {
        Object.entries(noodleLanguageProvider_1.NOODLE_SNIPPETS).forEach(([key, snippet]) => {
            const item = new vscode.CompletionItem(snippet.prefix, vscode.CompletionItemKind.Snippet);
            item.detail = snippet.description;
            item.documentation = new vscode.MarkdownString(`Code snippet: ${snippet.description}`);
            item.insertText = new vscode.SnippetString(snippet.body.join('\n'));
            items.push(item);
        });
    }
    /**
     * Add context-aware completions
     */
    addContextCompletions(items, document, position, linePrefix) {
        // Check if we're in an AI context
        if (this.isInAIContext(document, position)) {
            this.addAIContextCompletions(items, linePrefix);
        }
        // Check if we're in a function context
        if (this.isInFunctionContext(document, position)) {
            this.addFunctionContextCompletions(items, linePrefix);
        }
        // Check if we're in a class context
        if (this.isInClassContext(document, position)) {
            this.addClassContextCompletions(items, linePrefix);
        }
    }
    /**
     * Check if we're in an AI context
     */
    isInAIContext(document, position) {
        const text = document.getText(new vscode.Range(new vscode.Position(0, 0), position));
        return text.includes('ai ') || text.includes('agent ') || text.includes('model ');
    }
    /**
     * Check if we're in a function context
     */
    isInFunctionContext(document, position) {
        const line = document.lineAt(position).text;
        const textBefore = document.getText(new vscode.Range(new vscode.Position(0, 0), position));
        // Check if we're inside a function
        const funcMatch = textBefore.match(/func\s+\w+\s*\([^)]*\)\s*\{/);
        return funcMatch !== null;
    }
    /**
     * Check if we're in a class context
     */
    isInClassContext(document, position) {
        const line = document.lineAt(position).text;
        const textBefore = document.getText(new vscode.Range(new vscode.Position(0, 0), position));
        // Check if we're inside a class
        const classMatch = textBefore.match(/class\s+\w+\s*\{/);
        return classMatch !== null;
    }
    /**
     * Add AI context completions
     */
    addAIContextCompletions(items, linePrefix) {
        const aiCompletions = [
            { name: 'train', description: 'Train AI model' },
            { name: 'predict', description: 'Make predictions' },
            { name: 'validate', description: 'Validate model' },
            { name: 'optimize', description: 'Optimize model' },
            { name: 'dataset', description: 'Define dataset' },
            { name: 'pipeline', description: 'Define AI pipeline' }
        ];
        aiCompletions.forEach(completion => {
            const item = new vscode.CompletionItem(completion.name, vscode.CompletionItemKind.Method);
            item.detail = 'AI method';
            item.documentation = new vscode.MarkdownString(completion.description);
            items.push(item);
        });
    }
    /**
     * Add function context completions
     */
    addFunctionContextCompletions(items, linePrefix) {
        const functionCompletions = [
            { name: 'return', description: 'Return value from function' },
            { name: 'yield', description: 'Yield value from generator' },
            { name: 'await', description: 'Await async operation' }
        ];
        functionCompletions.forEach(completion => {
            const item = new vscode.CompletionItem(completion.name, vscode.CompletionItemKind.Keyword);
            item.detail = 'Function keyword';
            item.documentation = new vscode.MarkdownString(completion.description);
            items.push(item);
        });
    }
    /**
     * Add class context completions
     */
    addClassContextCompletions(items, linePrefix) {
        const classCompletions = [
            { name: 'constructor', description: 'Class constructor' },
            { name: 'this', description: 'Reference to current instance' },
            { name: 'super', description: 'Reference to parent class' },
            { name: 'extends', description: 'Extend parent class' },
            { name: 'implements', description: 'Implement interface' }
        ];
        classCompletions.forEach(completion => {
            const item = new vscode.CompletionItem(completion.name, vscode.CompletionItemKind.Keyword);
            item.detail = 'Class keyword';
            item.documentation = new vscode.MarkdownString(completion.description);
            items.push(item);
        });
    }
}
exports.NoodleCompletionProvider = NoodleCompletionProvider;
//# sourceMappingURL=noodleCompletionProvider.js.map