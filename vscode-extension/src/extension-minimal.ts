/**
 * MINIMAL VERSION - Noodle VS Code Extension
 * 
 * Simplified activation that focuses on core functionality only.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';
import * as path from 'path';

// Import only essential services
import { NoodleBackendService } from './services/backendService';
import { LSPManager } from './lsp/lspManager';

export class NoodleExtensionMinimal extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private isActivated = false;
    
    // Core services
    private lspManager: LSPManager;
    private backendService: NoodleBackendService;
    
    // UI components
    private statusBarItem: vscode.StatusBarItem;
    
    constructor(context: vscode.ExtensionContext) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Extension');
    }
    
    /**
     * Activate the extension - MINIMAL VERSION
     */
    public async activate(): Promise<void> {
        try {
            if (this.isActivated) {
                return;
            }
            
            this.outputChannel.appendLine('=== Noodle Extension Activation Started ===');
            
            // Step 1: Create Status Bar (always works!)
            this.outputChannel.appendLine('Creating status bar...');
            this.statusBarItem = vscode.window.createStatusBarItem(
                vscode.StatusBarAlignment.Right, 
                100
            );
            this.statusBarItem.text = '$(server) Noodle';
            this.statusBarItem.tooltip = 'Noodle Extension';
            this.statusBarItem.command = 'noodle.showStatus';
            this.statusBarItem.show();
            this.outputChannel.appendLine('✓ Status bar created');
            
            // Step 2: Initialize Backend Service
            this.outputChannel.appendLine('Initializing backend service...');
            try {
                this.backendService = new NoodleBackendService();
                await this.backendService.initialize();
                this.outputChannel.appendLine('✓ Backend service initialized');
            } catch (error) {
                this.outputChannel.appendLine(`⚠ Backend service failed: ${error.message}`);
                this.outputChannel.appendLine('  Continuing without backend...');
            }
            
            // Step 3: Initialize LSP Manager
            this.outputChannel.appendLine('Initializing LSP manager...');
            try {
                this.lspManager = new LSPManager(
                    this.context,
                    null, // serviceManager - not needed for basic LSP
                    null, // configManager
                    null, // eventBus
                    null, // cacheManager
                    null  // logger
                );
                await this.lspManager.initialize();
                this.outputChannel.appendLine('✓ LSP manager initialized');
            } catch (error) {
                this.outputChannel.appendLine(`⚠ LSP manager failed: ${error.message}`);
                this.outputChannel.appendLine('  Continuing without LSP...');
            }
            
            // Step 4: Register Commands
            this.outputChannel.appendLine('Registering commands...');
            this.registerCommands();
            this.outputChannel.appendLine('✓ Commands registered');
            
            // Step 5: Show Success Message
            this.isActivated = true;
            this.outputChannel.appendLine('=== Noodle Extension Activated Successfully ===');
            
            // Show notification
            void vscode.window.showInformationMessage(
                '🍜 Noodle Extension Active! Status bar enabled.'
            );
            
        } catch (error) {
            this.outputChannel.appendLine(`❌ CRITICAL ERROR: ${error.message}`);
            this.outputChannel.show();
            throw error;
        }
    }
    
    /**
     * Register commands
     */
    private registerCommands(): void {
        const commands = [
            // Status & Info
            vscode.commands.registerCommand('noodle.showStatus', () => {
                this.showStatus();
            }),
            
            // LSP Commands
            vscode.commands.registerCommand('noodle.lsp.status', () => {
                this.showLSPStatus();
            }),
            
            vscode.commands.registerCommand('noodle.lsp.restart', async () => {
                await this.restartLSP();
            }),
            
            // AI Commands
            vscode.commands.registerCommand('noodle.ai.chat', () => {
                this.showAIChat();
            }),
            
            vscode.commands.registerCommand('noodle.ai.assist', () => {
                this.showAIAssist();
            }),
            
            // Settings
            vscode.commands.registerCommand('noodle.settings', () => {
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
            }),
            
            // Development
            vscode.commands.registerCommand('noodle.development.restart', () => {
                vscode.commands.executeCommand('workbench.action.reloadWindow');
            }),
            
            vscode.commands.registerCommand('noodle.development.showOutput', () => {
                this.outputChannel.show();
            })
        ];
        
        commands.forEach(cmd => {
            this.context.subscriptions.push(cmd);
        });
        
        this.outputChannel.appendLine(`  Registered ${commands.length} commands`);
    }
    
    /**
     * Show extension status
     */
    private showStatus(): void {
        this.outputChannel.clear();
        this.outputChannel.appendLine('=== Noodle Extension Status ===\n');
        this.outputChannel.appendLine(`Extension: ${this.isActivated ? '✓ Active' : '✗ Inactive'}`);
        this.outputChannel.appendLine(`Backend: ${this.backendService ? '✓ Initialized' : '✗ Not initialized'}`);
        this.outputChannel.appendLine(`LSP Manager: ${this.lspManager ? '✓ Initialized' : '✗ Not initialized'}`);
        this.outputChannel.appendLine(`\n=== Commands ===`);
        this.outputChannel.appendLine('• noodle.lsp.status - Show LSP status');
        this.outputChannel.appendLine('• noodle.ai.chat - Open AI chat');
        this.outputChannel.appendLine('• noodle.development.showOutput - Show this log');
        this.outputChannel.show();
    }
    
    /**
     * Show LSP status
     */
    private showLSPStatus(): void {
        if (this.lspManager) {
            void vscode.commands.executeCommand('noodle.lsp.status');
        } else {
            void vscode.window.showWarningMessage('LSP Manager is not initialized');
        }
    }
    
    /**
     * Restart LSP
     */
    private async restartLSP(): Promise<void> {
        if (this.lspManager) {
            try {
                await this.lspManager.initialize();
                void vscode.window.showInformationMessage('LSP Manager restarted');
            } catch (error) {
                void vscode.window.showErrorMessage(`Failed to restart LSP: ${error.message}`);
            }
        } else {
            void vscode.window.showWarningMessage('LSP Manager is not initialized');
        }
    }
    
    /**
     * Show AI Chat
     */
    private showAIChat(): void {
        void vscode.window.showInformationMessage(
            'AI Chat requires backend running on port 8080',
            'Open Documentation'
        ).then(selection => {
            if (selection === 'Open Documentation') {
                vscode.env.openExternal(vscode.Uri.parse('https://github.com/cubic461/Noodle-Core'));
            }
        });
    }
    
    /**
     * Show AI Assist
     */
    private showAIAssist(): void {
        void vscode.window.showInformationMessage(
            'AI Assist requires backend running on port 8080'
        );
    }
    
    /**
     * Deactivate the extension
     */
    public deactivate(): void {
        this.outputChannel.appendLine('Deactivating Noodle extension...');
        
        if (this.statusBarItem) {
            this.statusBarItem.dispose();
        }
        
        if (this.lspManager) {
            this.lspManager.dispose();
        }
        
        this.outputChannel.appendLine('Noodle extension deactivated');
    }
}

/**
 * Extension activation entry point
 */
export async function activate(context: vscode.ExtensionContext): Promise<void> {
    const extension = new NoodleExtensionMinimal(context);
    await extension.activate();
}

/**
 * Extension deactivation entry point
 */
export function deactivate(): void {
    // Cleanup is handled by the extension class
}
