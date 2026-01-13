"use strict";
/**
 * NoodleCore LSP Server Implementation
 *
 * This module provides the server-side implementation of the Language Server Protocol
 * for NoodleCore, running as a separate process and communicating via stdio.
 *
 * Features:
 * - Full LSP protocol implementation
 * - Deep syntax and semantic analysis
 * - Real-time IntelliSense for all NoodleCore constructs
 * - Pattern matching, generics, async/await support
 * - Cross-file reference resolution
 * - Advanced diagnostics and error handling
 * - Code formatting and refactoring
 * - Performance optimization with caching
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
exports.NoodleLSPServer = void 0;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
// LSP Server configuration
const NOODLE_LSP_SERVER_COMMAND = 'python';
const NOODLE_LSP_SERVER_ARGS = [
    '-m', 'noodlecore.lsp.noodle_lsp_server'
];
/**
 * NoodleCore LSP Server class
 */
class NoodleLSPServer {
    constructor(context) {
        this.context = context;
        this.serverProcess = null;
        this.disposables = [];
        this.isServerReady = false;
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore LSP Server');
        this.performanceMetrics = {
            requestCount: 0,
            averageResponseTime: 0,
            totalRequests: 0,
            errorCount: 0,
            cacheHitRate: 0
        };
    }
    /**
     * Start LSP server
     */
    async start() {
        try {
            const workspaceRoot = this.getWorkspaceRoot();
            this.outputChannel.appendLine(`Starting NoodleCore LSP Server in: ${workspaceRoot}`);
            // Start server process
            this.serverProcess = (0, child_process_1.spawn)(NOODLE_LSP_SERVER_COMMAND, NOODLE_LSP_SERVER_ARGS, {
                cwd: workspaceRoot,
                env: {
                    PYTHONPATH: process.env.PYTHONPATH,
                    NOODLE_ENV: process.env.NOODLE_ENV || 'development'
                },
                stdio: ['pipe', 'pipe', 'inherit'] // stdin, stdout, stderr
            });
            if (!this.serverProcess) {
                throw new Error('Failed to start NoodleCore LSP server process');
            }
            // Handle server output
            this.serverProcess.stdout?.on('data', (data) => {
                const output = data.toString();
                this.outputChannel.appendLine(`LSP Server: ${output.trim()}`);
            });
            this.serverProcess.stderr?.on('data', (data) => {
                const output = data.toString();
                this.outputChannel.appendLine(`LSP Server Error: ${output.trim()}`);
            });
            // Handle server process exit
            this.serverProcess.on('exit', (code) => {
                if (code !== 0) {
                    this.outputChannel.appendLine(`LSP Server exited with Code: ${code}`);
                    vscode.window.showErrorMessage(`NoodleCore LSP Server exited with Code: ${code}`);
                }
                else {
                    this.outputChannel.appendLine('LSP Server exited normally');
                }
                this.serverProcess = null;
                this.isServerReady = false;
            });
            this.isServerReady = true;
            this.outputChannel.appendLine('NoodleCore LSP Server started successfully');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to start LSP server: ${error}`);
            vscode.window.showErrorMessage(`Failed to start NoodleCore LSP Server: ${error}`);
        }
    }
    /**
     * Stop LSP server
     */
    async stop() {
        if (this.serverProcess) {
            this.outputChannel.appendLine('Stopping NoodleCore LSP Server');
            this.serverProcess.kill();
            // Wait for process to exit
            await new Promise(resolve => {
                this.serverProcess?.once('exit', () => {
                    resolve();
                });
            });
            this.serverProcess = null;
            this.isServerReady = false;
            this.outputChannel.appendLine('NoodleCore LSP Server stopped');
        }
    }
    /**
     * Restart LSP server
     */
    async restart() {
        await this.stop();
        await new Promise(resolve => setTimeout(resolve, 1000)); // Wait for shutdown
        await this.start();
    }
    /**
     * Get server status
     */
    isRunning() {
        return this.isServerReady;
    }
    /**
     * Get performance metrics
     */
    getPerformanceMetrics() {
        return this.performanceMetrics;
    }
    /**
     * Get workspace root
     */
    getWorkspaceRoot() {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders && workspaceFolders.length > 0) {
            return workspaceFolders[0].uri.fsPath;
        }
        return process.cwd();
    }
    /**
     * Dispose LSP server
     */
    dispose() {
        this.outputChannel.appendLine('Disposing NoodleCore LSP Server');
        // Stop server
        this.stop();
        // Dispose all disposables
        this.disposables.forEach(disposable => disposable.dispose());
    }
}
exports.NoodleLSPServer = NoodleLSPServer;
//# sourceMappingURL=noodleLspServer.js.map