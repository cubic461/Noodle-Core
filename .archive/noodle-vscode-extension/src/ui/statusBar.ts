/**
 * Status Bar for Noodle VS Code Extension
 * 
 * Provides status bar items for extension status and quick actions.
 */

import * as vscode from 'vscode';

export class NoodleStatusBar {
    private context: vscode.ExtensionContext;
    private statusBarItem: vscode.StatusBarItem;
    private ecosystemBarItem: vscode.StatusBarItem;
    
    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        
        // Create main status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            100
        );
        this.statusBarItem.command = 'noodle.showWelcome';
        this.statusBarItem.tooltip = 'Noodle Extension';
        
        // Create ecosystem status item
        this.ecosystemBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Right,
            100
        );
        this.ecosystemBarItem.command = 'noodle.ecosystem.showStatus';
        this.ecosystemBarItem.tooltip = 'Noodle Ecosystem Status';
    }
    
    /**
     * Initialize status bar
     */
    public async initialize(): Promise<void> {
        // Set initial status
        this.updateStatus('Initializing...');
        
        // Show status bar items
        this.statusBarItem.show();
        this.ecosystemBarItem.show();
        
        // Register disposables
        this.context.subscriptions.push(this.statusBarItem);
        this.context.subscriptions.push(this.ecosystemBarItem);
    }
    
    /**
     * Update status
     */
    public updateStatus(status: string, activeServices?: number): void {
        // Update main status
        this.statusBarItem.text = `$(noodle) ${status}`;
        
        // Update ecosystem status
        if (activeServices !== undefined) {
            this.ecosystemBarItem.text = `$(plug) Ecosystem: ${activeServices}`;
        } else {
            this.ecosystemBarItem.text = '$(plug) Ecosystem';
        }
    }
    
    /**
     * Update ecosystem status
     */
    public updateEcosystemStatus(runningServices: number, totalServices: number): void {
        const percentage = totalServices > 0 ? Math.round((runningServices / totalServices) * 100) : 0;
        let icon = '';
        
        if (percentage === 100) {
            icon = '🟢';
        } else if (percentage >= 75) {
            icon = '🟡';
        } else if (percentage > 0) {
            icon = '🔴';
        } else {
            icon = '⚪';
        }
        
        this.ecosystemBarItem.text = `$(plug) Ecosystem ${icon} ${runningServices}/${totalServices}`;
        this.ecosystemBarItem.tooltip = `Noodle Ecosystem: ${runningServices} of ${totalServices} services running (${percentage}%)`;
    }
    
    /**
     * Show status message
     */
    public showStatusMessage(message: string, type: 'info' | 'warning' | 'error' = 'info'): void {
        let icon = '';
        
        switch (type) {
            case 'info':
                icon = '$(info)';
                break;
            case 'warning':
                icon = '$(warning)';
                break;
            case 'error':
                icon = '$(error)';
                break;
        }
        
        vscode.window.setStatusBarMessage(`${icon} ${message}`, 5000);
    }
    
    /**
     * Dispose status bar
     */
    public dispose(): void {
        if (this.statusBarItem) {
            this.statusBarItem.dispose();
        }
        
        if (this.ecosystemBarItem) {
            this.ecosystemBarItem.dispose();
        }
    }
}