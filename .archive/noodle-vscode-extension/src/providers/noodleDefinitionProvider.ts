import * as vscode from 'vscode';

/**
 * NoodleCore Definition Provider
 * 
 * Provides "go to definition" functionality for NoodleCore files,
 * including functions, classes, variables, and AI constructs.
 */
export class NoodleDefinitionProvider implements vscode.DefinitionProvider {

    /**
     * Provide definition for the given position
     */
    public provideDefinition(
        document: vscode.TextDocument,
        position: vscode.Position,
        token: vscode.CancellationToken
    ): vscode.Definition | undefined {
        const range = document.getWordRangeAtPosition(position);
        if (!range) {
            return undefined;
        }

        const word = document.getText(range);
        const line = document.lineAt(position).text;

        // Find definition in current document
        const definition = this.findDefinitionInDocument(document, word);
        if (definition) {
            return definition;
        }

        // Find definition in workspace
        return this.findDefinitionInWorkspace(word, document.uri);
    }

    /**
     * Find definition in current document
     */
    private findDefinitionInDocument(
        document: vscode.TextDocument,
        word: string
    ): vscode.Definition | undefined {
        const text = document.getText();
        const lines = text.split('\n');

        // Look for function definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const funcMatch = line.match(new RegExp(`func\\s+${word}\\s*\\(`));
            if (funcMatch) {
                const position = new vscode.Position(i, funcMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        // Look for class definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const classMatch = line.match(new RegExp(`class\\s+${word}\\s*\\{`));
            if (classMatch) {
                const position = new vscode.Position(i, classMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        // Look for variable definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const varMatch = line.match(new RegExp(`(let|const|var)\\s+${word}\\s*=`));
            if (varMatch) {
                const position = new vscode.Position(i, varMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        // Look for AI model definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const modelMatch = line.match(new RegExp(`ai\\s+model\\s+${word}\\s*\\{`));
            if (modelMatch) {
                const position = new vscode.Position(i, modelMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        // Look for agent definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const agentMatch = line.match(new RegExp(`agent\\s+${word}\\s*\\{`));
            if (agentMatch) {
                const position = new vscode.Position(i, agentMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        // Look for pipeline definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const pipelineMatch = line.match(new RegExp(`pipeline\\s+${word}\\s*\\{`));
            if (pipelineMatch) {
                const position = new vscode.Position(i, pipelineMatch.index!);
                return new vscode.Location(document.uri, position);
            }
        }

        return undefined;
    }

    /**
     * Find definition in workspace
     */
    private async findDefinitionInWorkspace(
        word: string,
        currentUri: vscode.Uri
    ): Promise<vscode.Definition | undefined> {
        const files = await vscode.workspace.findFiles('**/*.{nc,noodle}', '**/node_modules/**');

        for (const file of files) {
            if (file.toString() === currentUri.toString()) {
                continue; // Skip current file
            }

            try {
                const document = await vscode.workspace.openTextDocument(file);
                const definition = this.findDefinitionInDocument(document, word);
                if (definition) {
                    return definition;
                }
            } catch (error) {
                console.error(`Error opening file ${file}:`, error);
            }
        }

        return undefined;
    }
}