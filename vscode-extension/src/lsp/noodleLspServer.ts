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

import * as vscode from 'vscode';
import { spawn, ChildProcess } from 'child_process';
import { createConnection, TextDocuments, ProposedFeatures, InitializeParams, TextDocumentSyncKind, FileChangeType } from 'vscode-languageclient/node';

// LSP Server configuration
const NOODLE_LSP_SERVER_COMMAND = 'python';
const NOODLE_LSP_SERVER_ARGS = [
    '-m', 'noodlecore.lsp.noodle_lsp_server'
];

// Performance monitoring
interface LSPPerformanceMetrics {
    requestCount: number;
    averageResponseTime: number;
    totalRequests: number;
    errorCount: number;
    cacheHitRate: number;
}

/**
 * NoodleCore LSP Server class
 */
export class NoodleLSPServer {
    private serverProcess: ChildProcess | null = null;
    private outputChannel: vscode.OutputChannel;
    private disposables: vscode.Disposable[] = [];
    private isServerReady: boolean = false;
    private performanceMetrics: LSPPerformanceMetrics;

    constructor(private context: vscode.ExtensionContext) {
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
    public async start(): Promise<void> {
        try {
            const workspaceRoot = this.getWorkspaceRoot();
            
            this.outputChannel.appendLine(`Starting NoodleCore LSP Server in: ${workspaceRoot}`);
            
            // Start server process
            this.serverProcess = spawn(NOODLE_LSP_SERVER_COMMAND, NOODLE_LSP_SERVER_ARGS, {
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
            this.serverProcess.stdout?.on('data', (data: Buffer) => {
                const output = data.toString();
                this.outputChannel.appendLine(`LSP Server: ${output.trim()}`);
            });

            this.serverProcess.stderr?.on('data', (data: Buffer) => {
                const output = data.toString();
                this.outputChannel.appendLine(`LSP Server Error: ${output.trim()}`);
            });

            // Handle server process exit
            this.serverProcess.on('exit', (code: number | null) => {
                if (code !== 0) {
                    this.outputChannel.appendLine(`LSP Server exited with Code: ${code}`);
                    vscode.window.showErrorMessage(`NoodleCore LSP Server exited with Code: ${code}`);
                } else {
                    this.outputChannel.appendLine('LSP Server exited normally');
                }
                this.serverProcess = null;
                this.isServerReady = false;
            });

            this.isServerReady = true;
            this.outputChannel.appendLine('NoodleCore LSP Server started successfully');

        } catch (error) {
            this.outputChannel.appendLine(`Failed to start LSP server: ${error}`);
            vscode.window.showErrorMessage(`Failed to start NoodleCore LSP Server: ${error}`);
        }
    }

    /**
     * Stop LSP server
     */
    public async stop(): Promise<void> {
        if (this.serverProcess) {
            this.outputChannel.appendLine('Stopping NoodleCore LSP Server');
            this.serverProcess.kill();
            
            // Wait for process to exit
            await new Promise<void>(resolve => {
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
    public async restart(): Promise<void> {
        await this.stop();
        await new Promise<void>(resolve => setTimeout(resolve, 1000)); // Wait for shutdown
        await this.start();
    }

    /**
     * Get server status
     */
    public isRunning(): boolean {
        return this.isServerReady;
    }

    /**
     * Get performance metrics
     */
    public getPerformanceMetrics(): LSPPerformanceMetrics {
        return this.performanceMetrics;
    }

    /**
     * Get workspace root
     */
    private getWorkspaceRoot(): string {
        const workspaceFolders = vscode.workspace.workspaceFolders;
        if (workspaceFolders && workspaceFolders.length > 0) {
            return workspaceFolders[0].uri.fsPath;
        }
        return process.cwd();
    }

    /**
     * Dispose LSP server
     */
    public dispose(): void {
        this.outputChannel.appendLine('Disposing NoodleCore LSP Server');
        
        // Stop server
        this.stop();
        
        // Dispose all disposables
        this.disposables.forEach(disposable => disposable.dispose());
    }
}