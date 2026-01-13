"use strict";
/**
 * Status Bar for Noodle VS Code Extension
 *
 * Provides status bar items for extension status and quick actions.
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
exports.NoodleStatusBar = void 0;
const vscode = __importStar(require("vscode"));
class NoodleStatusBar {
    constructor(context) {
        this.context = context;
        // Create main status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
        this.statusBarItem.command = 'noodle.showWelcome';
        this.statusBarItem.tooltip = 'Noodle Extension';
        // Create ecosystem status item
        this.ecosystemBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.ecosystemBarItem.command = 'noodle.ecosystem.showStatus';
        this.ecosystemBarItem.tooltip = 'Noodle Ecosystem Status';
    }
    /**
     * Initialize status bar
     */
    async initialize() {
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
    updateStatus(status, activeServices) {
        // Update main status
        this.statusBarItem.text = `$(noodle) ${status}`;
        // Update ecosystem status
        if (activeServices !== undefined) {
            this.ecosystemBarItem.text = `$(plug) Ecosystem: ${activeServices}`;
        }
        else {
            this.ecosystemBarItem.text = '$(plug) Ecosystem';
        }
    }
    /**
     * Update ecosystem status
     */
    updateEcosystemStatus(runningServices, totalServices) {
        const percentage = totalServices > 0 ? Math.round((runningServices / totalServices) * 100) : 0;
        let icon = '';
        if (percentage === 100) {
            icon = '🟢';
        }
        else if (percentage >= 75) {
            icon = '🟡';
        }
        else if (percentage > 0) {
            icon = '🔴';
        }
        else {
            icon = '⚪';
        }
        this.ecosystemBarItem.text = `$(plug) Ecosystem ${icon} ${runningServices}/${totalServices}`;
        this.ecosystemBarItem.tooltip = `Noodle Ecosystem: ${runningServices} of ${totalServices} services running (${percentage}%)`;
    }
    /**
     * Show status message
     */
    showStatusMessage(message, type = 'info') {
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
    dispose() {
        if (this.statusBarItem) {
            this.statusBarItem.dispose();
        }
        if (this.ecosystemBarItem) {
            this.ecosystemBarItem.dispose();
        }
    }
}
exports.NoodleStatusBar = NoodleStatusBar;
//# sourceMappingURL=statusBar.js.map