/**
 * NoodleCore LSP Manager
 * 
 * This module manages the Language Server Protocol integration for NoodleCore,
 * coordinating between the VS Code extension and the LSP client.
 */

import * as vscode from 'vscode';
import { NoodleLspClient } from './noodleLspClient';
import { NoodleWorkspaceManager } from '../workspace/noodleWorkspaceManager';
import { NoodleFileManager } from '../fileManagement/noodleFileManager';

export class NoodleLspManager {
    private lspClient: NoodleLspClient;
    private workspaceManager: NoodleWorkspaceManager;
    private fileManager: NoodleFileManager;
    private context: vscode.ExtensionContext;
    private disposables: vscode.Disposable[] = [];

    constructor(
        context: vscode.ExtensionContext,
        workspaceManager: NoodleWorkspaceManager,
        fileManager: NoodleFileManager
    ) {
        this.context = context;
        this.workspaceManager = workspaceManager;
        this.fileManager = fileManager;
        this.lspClient = new NoodleLspClient(context);
    }

    /**
     * Initialize LSP manager
     */
    public async initialize(): Promise<void> {
        try {
            // Register configuration change handler
            this.disposables.push(
                vscode.workspace.onDidChangeConfiguration(this.onConfigurationChanged, this)
            );

            // Register workspace change handlers
            this.disposables.push(
                vscode.workspace.onDidChangeWorkspaceFolders(this.onWorkspaceFoldersChanged, this)
            );

            // Register document change handlers for enhanced LSP functionality
            this.disposables.push(
                vscode.workspace.onDidOpenTextDocument(this.onDocumentOpened, this),
                vscode.workspace.onDidCloseTextDocument(this.onDocumentClosed, this),
                vscode.workspace.onDidChangeTextDocument(this.onDocumentChanged, this),
                vscode.workspace.onDidSaveTextDocument(this.onDocumentSaved, this)
            );

            // Start LSP client if enabled
            const config = vscode.workspace.getConfiguration('noodle');
            if (config.get<boolean>('lsp.enabled', true)) {
                await this.startLsp();
            }

        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to initialize NoodleCore LSP Manager: ${errorMessage}`);
        }
    }

    /**
     * Start LSP client
     */
    public async startLsp(): Promise<boolean> {
        try {
            const success = await this.lspClient.start();
            if (success) {
                vscode.window.showInformationMessage('NoodleCore Language Server started successfully');
                
                // Notify workspace and file managers
                this.workspaceManager.onLspStarted();
                this.fileManager.onLspStarted();
            }
            return success;
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to start NoodleCore Language Server: ${errorMessage}`);
            return false;
        }
    }

    /**
     * Stop LSP client
     */
    public async stopLsp(): Promise<void> {
        try {
            await this.lspClient.stop();
            vscode.window.showInformationMessage('NoodleCore Language Server stopped');
            
            // Notify workspace and file managers
            this.workspaceManager.onLspStopped();
            this.fileManager.onLspStopped();
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to stop NoodleCore Language Server: ${errorMessage}`);
        }
    }

    /**
     * Restart LSP client
     */
    public async restartLsp(): Promise<boolean> {
        try {
            vscode.window.showInformationMessage('Restarting NoodleCore Language Server...');
            const success = await this.lspClient.restart();
            
            if (success) {
                vscode.window.showInformationMessage('NoodleCore Language Server restarted successfully');
                this.workspaceManager.onLspRestarted();
                this.fileManager.onLspRestarted();
            }
            
            return success;
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to restart NoodleCore Language Server: ${errorMessage}`);
            return false;
        }
    }

    /**
     * Check if LSP is running
     */
    public isLspRunning(): boolean {
        return this.lspClient.isRunning();
    }

    /**
     * Show LSP output
     */
    public showLspOutput(): void {
        this.lspClient.showOutput();
    }

    /**
     * Handle configuration changes
     */
    private async onConfigurationChanged(event: vscode.ConfigurationChangeEvent): Promise<void> {
        if (event.affectsConfiguration('noodle.lsp')) {
            const config = vscode.workspace.getConfiguration('noodle');
            const enabled = config.get<boolean>('lsp.enabled', true);
            const currentlyRunning = this.isLspRunning();

            if (enabled && !currentlyRunning) {
                await this.startLsp();
            } else if (!enabled && currentlyRunning) {
                await this.stopLsp();
            }
        }
    }

    /**
     * Handle workspace folder changes
     */
    private async onWorkspaceFoldersChanged(event: vscode.WorkspaceFoldersChangeEvent): Promise<void> {
        if (this.isLspRunning()) {
            // Restart LSP to pick up new workspace folders
            await this.restartLsp();
        }
    }

    /**
     * Handle document opened
     */
    private onDocumentOpened(document: vscode.TextDocument): void {
        if (this.isNoodleDocument(document)) {
            // Track document for enhanced LSP features
            this.fileManager.trackDocument(document);
        }
    }

    /**
     * Handle document closed
     */
    private onDocumentClosed(document: vscode.TextDocument): void {
        if (this.isNoodleDocument(document)) {
            // Untrack document
            this.fileManager.untrackDocument(document);
        }
    }

    /**
     * Handle document changed
     */
    private onDocumentChanged(event: vscode.TextDocumentChangeEvent): void {
        if (this.isNoodleDocument(event.document)) {
            // Update document tracking
            this.fileManager.updateDocument(event.document, event.contentChanges);
        }
    }

    /**
     * Handle document saved
     */
    private async onDocumentSaved(document: vscode.TextDocument): Promise<void> {
        if (this.isNoodleDocument(document)) {
            // Trigger enhanced analysis on save
            await this.triggerDocumentAnalysis(document);
        }
    }

    /**
     * Check if document is a NoodleCore file
     */
    private isNoodleDocument(document: vscode.TextDocument): boolean {
        return document.languageId === 'noodle' || 
               document.fileName.endsWith('.nc') || 
               document.fileName.endsWith('.noodle');
    }

    /**
     * Trigger enhanced document analysis
     */
    private async triggerDocumentAnalysis(document: vscode.TextDocument): Promise<void> {
        if (!this.isLspRunning()) {
            return;
        }

        try {
            // Get configuration for analysis
            const config = vscode.workspace.getConfiguration('noodle');
            const enableAnalysis = config.get<boolean>('lsp.enableAnalysis', true);
            
            if (enableAnalysis) {
                // Trigger background analysis
                await this.performBackgroundAnalysis(document);
            }
        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            console.error(`Error in document analysis: ${errorMessage}`);
        }
    }

    /**
     * Perform background analysis
     */
    private async performBackgroundAnalysis(document: vscode.TextDocument): Promise<void> {
        // This would integrate with the LSP server for enhanced analysis
        // For now, we'll just log the action
        console.log(`Performing background analysis for ${document.fileName}`);
        
        // TODO: Implement enhanced analysis features:
        // - Pattern matching validation
        // - Generic type checking
        // - Async/await analysis
        // - AI construct validation
        // - Performance analysis
    }

    /**
     * Get LSP client for direct access
     */
    public getLspClient(): NoodleLspClient {
        return this.lspClient;
    }

    /**
     * Dispose resources
     */
    public dispose(): void {
        this.disposables.forEach(disposable => disposable.dispose());
        this.lspClient.dispose();
    }
}