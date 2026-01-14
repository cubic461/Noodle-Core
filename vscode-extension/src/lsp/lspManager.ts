/**
 * Minimal LSP Manager for Noodle VS Code Extension
 * 
 * Simplified version without infrastructure dependencies
 * Properly handles server lifecycle to prevent zombie processes
 */

import * as vscode from 'vscode';
import { spawn, ChildProcess } from 'child_process';
import { EventEmitter } from 'events';

export interface LSPServerConfig {
    name: string;
    language: string;
    command: string;
    args: string[];
    cwd?: string;
    env?: { [key: string]: string };
    enabled: boolean;
}

export interface LSPStatus {
    serverId: string;
    status: 'starting' | 'running' | 'stopped' | 'error';
    pid?: number;
    startTime?: number;
    lastError?: string;
}

export class LSPManager extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private servers: Map<string, LSPServerConfig> = new Map();
    private serverProcesses: Map<string, ChildProcess> = new Map();
    private serverStatuses: Map<string, LSPStatus> = new Map();
    private isInitialized = false;

    constructor(
        context: vscode.ExtensionContext,
        serviceManager: any,
        configManager: any,
        eventBus: any,
        cacheManager: any,
        logger: any
    ) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle LSP');
        
        this.outputChannel.appendLine('LSP Manager created (Minimal Mode)');
    }

    /**
     * Initialize the LSP Manager
     */
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing LSP Manager...');
            
            // In minimal mode, we don't auto-start any servers
            // Servers will only start when explicitly needed
            
            this.isInitialized = true;
            this.outputChannel.appendLine('LSP Manager initialized (Minimal Mode)');
            this.emit('initialized');
        } catch (error) {
            this.outputChannel.appendLine(`LSP Manager initialization error: ${error.message}`);
            throw error;
        }
    }

    /**
     * Start a language server
     */
    public async startServer(serverId: string): Promise<void> {
        if (this.serverProcesses.has(serverId)) {
            this.outputChannel.appendLine(`Server ${serverId} is already running`);
            return;
        }

        const config = this.servers.get(serverId);
        if (!config) {
            throw new Error(`Server configuration not found: ${serverId}`);
        }

        if (!config.enabled) {
            this.outputChannel.appendLine(`Server ${serverId} is disabled`);
            return;
        }

        try {
            this.outputChannel.appendLine(`Starting server: ${serverId}`);
            
            // Update status
            this.serverStatuses.set(serverId, {
                serverId,
                status: 'starting',
                startTime: Date.now()
            });

            // Spawn the server process
            const serverProcess = spawn(config.command, config.args, {
                cwd: config.cwd || process.cwd(),
                env: { ...process.env, ...config.env }
            });

            // Store the process
            this.serverProcesses.set(serverId, serverProcess);

            // Handle process output
            serverProcess.stdout?.on('data', (data) => {
                this.outputChannel.appendLine(`[${serverId}] ${data.toString().trim()}`);
            });

            serverProcess.stderr?.on('data', (data) => {
                this.outputChannel.appendLine(`[${serverId}] ERROR: ${data.toString().trim()}`);
            });

            // Handle process exit
            serverProcess.on('exit', (code, signal) => {
                this.outputChannel.appendLine(`[${serverId}] Process exited with code ${code}, signal ${signal}`);
                this.serverProcesses.delete(serverId);
                this.serverStatuses.set(serverId, {
                    serverId,
                    status: 'stopped',
                    pid: serverProcess.pid,
                    startTime: this.serverStatuses.get(serverId)?.startTime
                });
            });

            // Handle process error
            serverProcess.on('error', (error) => {
                this.outputChannel.appendLine(`[${serverId}] Process error: ${error.message}`);
                this.serverStatuses.set(serverId, {
                    serverId,
                    status: 'error',
                    lastError: error.message,
                    startTime: this.serverStatuses.get(serverId)?.startTime
                });
            });

            // Update status to running
            this.serverStatuses.set(serverId, {
                serverId,
                status: 'running',
                pid: serverProcess.pid,
                startTime: Date.now()
            });

            this.outputChannel.appendLine(`Server ${serverId} started (PID: ${serverProcess.pid})`);
            this.emit('serverStarted', { serverId, pid: serverProcess.pid });

        } catch (error) {
            this.outputChannel.appendLine(`Failed to start server ${serverId}: ${error.message}`);
            this.serverStatuses.set(serverId, {
                serverId,
                status: 'error',
                lastError: error.message
            });
            throw error;
        }
    }

    /**
     * Stop a language server
     */
    public async stopServer(serverId: string): Promise<void> {
        const serverProcess = this.serverProcesses.get(serverId);
        if (!serverProcess) {
            this.outputChannel.appendLine(`Server ${serverId} is not running`);
            return;
        }

        try {
            this.outputChannel.appendLine(`Stopping server: ${serverId}`);

            // Kill the process
            serverProcess.kill('SIGTERM');

            // Wait for process to exit
            await new Promise<void>((resolve) => {
                const timeout = setTimeout(() => {
                    this.outputChannel.appendLine(`Server ${serverId} did not exit gracefully, forcing...`);
                    serverProcess.kill('SIGKILL');
                    resolve();
                }, 5000);

                serverProcess.once('exit', () => {
                    clearTimeout(timeout);
                    resolve();
                });
            });

            this.serverProcesses.delete(serverId);
            this.serverStatuses.set(serverId, {
                serverId,
                status: 'stopped'
            });

            this.outputChannel.appendLine(`Server ${serverId} stopped`);
            this.emit('serverStopped', { serverId });

        } catch (error) {
            this.outputChannel.appendLine(`Failed to stop server ${serverId}: ${error.message}`);
            throw error;
        }
    }

    /**
     * Get server status
     */
    public getServerStatus(serverId: string): LSPStatus | undefined {
        return this.serverStatuses.get(serverId);
    }

    /**
     * Get all server statuses
     */
    public getAllServerStatuses(): LSPStatus[] {
        return Array.from(this.serverStatuses.values());
    }

    /**
     * Register a server configuration
     */
    public registerServer(config: LSPServerConfig): void {
        this.servers.set(config.name, config);
        this.outputChannel.appendLine(`Registered server: ${config.name}`);
    }

    /**
     * Dispose of the LSP Manager
     * CRITICAL: This must properly stop all servers to prevent zombie processes
     */
    public async dispose(): Promise<void> {
        this.outputChannel.appendLine('Disposing LSP Manager...');

        // Create stop promises for all running servers
        const stopPromises: Promise<void>[] = [];
        for (const serverId of this.serverProcesses.keys()) {
            stopPromises.push(this.stopServer(serverId));
        }

        // Wait for ALL servers to stop
        if (stopPromises.length > 0) {
            this.outputChannel.appendLine(`Waiting for ${stopPromises.length} server(s) to stop...`);
            await Promise.all(stopPromises);
        }

        this.outputChannel.appendLine('LSP Manager disposed');
        this.outputChannel.dispose();
    }
}
