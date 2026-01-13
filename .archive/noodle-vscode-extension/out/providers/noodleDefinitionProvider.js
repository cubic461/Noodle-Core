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
exports.NoodleDefinitionProvider = void 0;
const vscode = __importStar(require("vscode"));
/**
 * NoodleCore Definition Provider
 *
 * Provides "go to definition" functionality for NoodleCore files,
 * including functions, classes, variables, and AI constructs.
 */
class NoodleDefinitionProvider {
    /**
     * Provide definition for the given position
     */
    provideDefinition(document, position, token) {
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
    findDefinitionInDocument(document, word) {
        const text = document.getText();
        const lines = text.split('\n');
        // Look for function definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const funcMatch = line.match(new RegExp(`func\\s+${word}\\s*\\(`));
            if (funcMatch) {
                const position = new vscode.Position(i, funcMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        // Look for class definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const classMatch = line.match(new RegExp(`class\\s+${word}\\s*\\{`));
            if (classMatch) {
                const position = new vscode.Position(i, classMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        // Look for variable definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const varMatch = line.match(new RegExp(`(let|const|var)\\s+${word}\\s*=`));
            if (varMatch) {
                const position = new vscode.Position(i, varMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        // Look for AI model definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const modelMatch = line.match(new RegExp(`ai\\s+model\\s+${word}\\s*\\{`));
            if (modelMatch) {
                const position = new vscode.Position(i, modelMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        // Look for agent definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const agentMatch = line.match(new RegExp(`agent\\s+${word}\\s*\\{`));
            if (agentMatch) {
                const position = new vscode.Position(i, agentMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        // Look for pipeline definitions
        for (let i = 0; i < lines.length; i++) {
            const line = lines[i];
            const pipelineMatch = line.match(new RegExp(`pipeline\\s+${word}\\s*\\{`));
            if (pipelineMatch) {
                const position = new vscode.Position(i, pipelineMatch.index);
                return new vscode.Location(document.uri, position);
            }
        }
        return undefined;
    }
    /**
     * Find definition in workspace
     */
    async findDefinitionInWorkspace(word, currentUri) {
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
            }
            catch (error) {
                console.error(`Error opening file ${file}:`, error);
            }
        }
        return undefined;
    }
}
exports.NoodleDefinitionProvider = NoodleDefinitionProvider;
//# sourceMappingURL=noodleDefinitionProvider.js.map