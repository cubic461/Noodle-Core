import * as vscode from 'vscode';
import { NOODLE_KEYWORDS, NOODLE_SNIPPETS } from './noodleLanguageProvider';

/**
 * NoodleCore Completion Provider
 * 
 * Provides intelligent code completion for NoodleCore files including:
 * - Keywords and language constructs
 * - AI-specific functions and agents
 * - Code snippets
 * - Context-aware suggestions
 */
export class NoodleCompletionProvider implements vscode.CompletionItemProvider {

    /**
     * Provide completion items for the given position
     */
    public provideCompletionItems(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken,
        context: vscode.CompletionContext
    ): vscode.CompletionItem[] {
        const linePrefix = document.lineAt(position).text.substring(0, position.character);
        const wordRange = document.getWordRangeAtPosition(position);
        const currentWord = wordRange ? document.getText(wordRange) : '';

        const completionItems: vscode.CompletionItem[] = [];

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
    private addKeywordCompletions(
        items: vscode.CompletionItem[],
        linePrefix: string,
        currentWord: string
    ): void {
        // Control flow keywords
        NOODLE_KEYWORDS.control.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Control flow keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore control flow keyword: \`${keyword}\``);
            items.push(item);
        });

        // Declaration keywords
        NOODLE_KEYWORDS.declaration.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Declaration keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore declaration keyword: \`${keyword}\``);
            items.push(item);
        });

        // Type keywords
        NOODLE_KEYWORDS.types.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'Type keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore type keyword: \`${keyword}\``);
            items.push(item);
        });

        // Built-in functions
        NOODLE_KEYWORDS.builtins.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Function);
            item.detail = 'Built-in function';
            item.documentation = new vscode.MarkdownString(`NoodleCore built-in function: \`${keyword}\``);
            items.push(item);
        });
    }

    /**
     * Add AI-specific completions
     */
    private addAICompletions(
        items: vscode.CompletionItem[],
        linePrefix: string,
        currentWord: string
    ): void {
        // AI keywords
        NOODLE_KEYWORDS.ai.forEach(keyword => {
            const item = new vscode.CompletionItem(keyword, vscode.CompletionItemKind.Keyword);
            item.detail = 'AI keyword';
            item.documentation = new vscode.MarkdownString(`NoodleCore AI keyword: \`${keyword}\``);
            items.push(item);
        });

        // Advanced types
        NOODLE_KEYWORDS.advancedTypes.forEach(keyword => {
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
    private addSnippetCompletions(
        items: vscode.CompletionItem[],
        linePrefix: string,
        currentWord: string
    ): void {
        Object.entries(NOODLE_SNIPPETS).forEach(([key, snippet]) => {
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
    private addContextCompletions(
        items: vscode.CompletionItem[],
        document: vscode.TextDocument,
        position: vscode.Position,
        linePrefix: string
    ): void {
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
    private isInAIContext(document: vscode.TextDocument, position: vscode.Position): boolean {
        const text = document.getText(new vscode.Range(new vscode.Position(0, 0), position));
        return text.includes('ai ') || text.includes('agent ') || text.includes('model ');
    }

    /**
     * Check if we're in a function context
     */
    private isInFunctionContext(document: vscode.TextDocument, position: vscode.Position): boolean {
        const line = document.lineAt(position).text;
        const textBefore = document.getText(new vscode.Range(new vscode.Position(0, 0), position));

        // Check if we're inside a function
        const funcMatch = textBefore.match(/func\s+\w+\s*\([^)]*\)\s*\{/);
        return funcMatch !== null;
    }

    /**
     * Check if we're in a class context
     */
    private isInClassContext(document: vscode.TextDocument, position: vscode.Position): boolean {
        const line = document.lineAt(position).text;
        const textBefore = document.getText(new vscode.Range(new vscode.Position(0, 0), position));

        // Check if we're inside a class
        const classMatch = textBefore.match(/class\s+\w+\s*\{/);
        return classMatch !== null;
    }

    /**
     * Add AI context completions
     */
    private addAIContextCompletions(items: vscode.CompletionItem[], linePrefix: string): void {
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
    private addFunctionContextCompletions(items: vscode.CompletionItem[], linePrefix: string): void {
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
    private addClassContextCompletions(items: vscode.CompletionItem[], linePrefix: string): void {
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