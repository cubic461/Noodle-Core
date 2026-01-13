"use strict";
/**
 * NoodleCore LSP Manager
 *
 * This module manages the Language Server Protocol integration for NoodleCore,
 * coordinating between the VS Code extension and the LSP client.
 */
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
exports.NoodleLspManager = void 0;
const vscode = __importStar(require("vscode"));
const noodleLspClient_1 = require("./noodleLspClient");
class NoodleLspManager {
    constructor(context, workspaceManager, fileManager) {
        this.disposables = [];
        this.context = context;
        this.workspaceManager = workspaceManager;
        this.fileManager = fileManager;
        this.lspClient = new noodleLspClient_1.NoodleLspClient(context);
    }
    /**
     * Initialize LSP manager
     */
    async initialize() {
        try {
            // Register configuration change handler
            this.disposables.push(vscode.workspace.onDidChangeConfiguration(this.onConfigurationChanged, this));
            // Register workspace change handlers
            this.disposables.push(vscode.workspace.onDidChangeWorkspaceFolders(this.onWorkspaceFoldersChanged, this));
            // Register document change handlers for enhanced LSP functionality
            this.disposables.push(vscode.workspace.onDidOpenTextDocument(this.onDocumentOpened, this), vscode.workspace.onDidCloseTextDocument(this.onDocumentClosed, this), vscode.workspace.onDidChangeTextDocument(this.onDocumentChanged, this), vscode.workspace.onDidSaveTextDocument(this.onDocumentSaved, this));
            // Start LSP client if enabled
            const config = vscode.workspace.getConfiguration('noodle');
            if (config.get('lsp.enabled', true)) {
                await this.startLsp();
            }
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to initialize NoodleCore LSP Manager: ${errorMessage}`);
        }
    }
    /**
     * Start LSP client
     */
    async startLsp() {
        try {
            const success = await this.lspClient.start();
            if (success) {
                vscode.window.showInformationMessage('NoodleCore Language Server started successfully');
                // Notify workspace and file managers
                this.workspaceManager.onLspStarted();
                this.fileManager.onLspStarted();
            }
            return success;
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to start NoodleCore Language Server: ${errorMessage}`);
            return false;
        }
    }
    /**
     * Stop LSP client
     */
    async stopLsp() {
        try {
            await this.lspClient.stop();
            vscode.window.showInformationMessage('NoodleCore Language Server stopped');
            // Notify workspace and file managers
            this.workspaceManager.onLspStopped();
            this.fileManager.onLspStopped();
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to stop NoodleCore Language Server: ${errorMessage}`);
        }
    }
    /**
     * Restart LSP client
     */
    async restartLsp() {
        try {
            vscode.window.showInformationMessage('Restarting NoodleCore Language Server...');
            const success = await this.lspClient.restart();
            if (success) {
                vscode.window.showInformationMessage('NoodleCore Language Server restarted successfully');
                this.workspaceManager.onLspRestarted();
                this.fileManager.onLspRestarted();
            }
            return success;
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            vscode.window.showErrorMessage(`Failed to restart NoodleCore Language Server: ${errorMessage}`);
            return false;
        }
    }
    /**
     * Check if LSP is running
     */
    isLspRunning() {
        return this.lspClient.isRunning();
    }
    /**
     * Show LSP output
     */
    showLspOutput() {
        this.lspClient.showOutput();
    }
    /**
     * Handle configuration changes
     */
    async onConfigurationChanged(event) {
        if (event.affectsConfiguration('noodle.lsp')) {
            const config = vscode.workspace.getConfiguration('noodle');
            const enabled = config.get('lsp.enabled', true);
            const currentlyRunning = this.isLspRunning();
            if (enabled && !currentlyRunning) {
                await this.startLsp();
            }
            else if (!enabled && currentlyRunning) {
                await this.stopLsp();
            }
        }
    }
    /**
     * Handle workspace folder changes
     */
    async onWorkspaceFoldersChanged(event) {
        if (this.isLspRunning()) {
            // Restart LSP to pick up new workspace folders
            await this.restartLsp();
        }
    }
    /**
     * Handle document opened
     */
    onDocumentOpened(document) {
        if (this.isNoodleDocument(document)) {
            // Track document for enhanced LSP features
            this.fileManager.trackDocument(document);
        }
    }
    /**
     * Handle document closed
     */
    onDocumentClosed(document) {
        if (this.isNoodleDocument(document)) {
            // Untrack document
            this.fileManager.untrackDocument(document);
        }
    }
    /**
     * Handle document changed
     */
    onDocumentChanged(event) {
        if (this.isNoodleDocument(event.document)) {
            // Update document tracking
            this.fileManager.updateDocument(event.document, event.contentChanges);
        }
    }
    /**
     * Handle document saved
     */
    async onDocumentSaved(document) {
        if (this.isNoodleDocument(document)) {
            // Trigger enhanced analysis on save
            await this.triggerDocumentAnalysis(document);
        }
    }
    /**
     * Check if document is a NoodleCore file
     */
    isNoodleDocument(document) {
        return document.languageId === 'noodle' ||
            document.fileName.endsWith('.nc') ||
            document.fileName.endsWith('.noodle');
    }
    /**
     * Trigger enhanced document analysis
     */
    async triggerDocumentAnalysis(document) {
        if (!this.isLspRunning()) {
            return;
        }
        try {
            // Get configuration for analysis
            const config = vscode.workspace.getConfiguration('noodle');
            const enableAnalysis = config.get('lsp.enableAnalysis', true);
            if (enableAnalysis) {
                // Trigger background analysis
                await this.performBackgroundAnalysis(document);
            }
        }
        catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            console.error(`Error in document analysis: ${errorMessage}`);
        }
    }
    /**
     * Perform background analysis
     */
    async performBackgroundAnalysis(document) {
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
    getLspClient() {
        return this.lspClient;
    }
    /**
     * Dispose resources
     */
    dispose() {
        this.disposables.forEach(disposable => disposable.dispose());
        this.lspClient.dispose();
    }
}
exports.NoodleLspManager = NoodleLspManager;
//# sourceMappingURL=noodleLspManager.js.map