import * as vscode from 'vscode';

export class NoodleFileManager {
    private context: vscode.ExtensionContext;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
    }

    // File management functionality will be implemented here
    public createFile(fileName: string): void {
        // Implementation pending
    }

    public deleteFile(fileName: string): void {
        // Implementation pending
    }

    public listFiles(): string[] {
        // Implementation pending
        return [];
    }
}