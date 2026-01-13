/**
 * LSP Manager for Noodle VS Code Extension
 * 
 * Manages Language Server Protocol (LSP) connections and provides
 * language intelligence features.
 */

import * as vscode from 'vscode';
import * as path from 'path';
import { EventEmitter } from 'events';
import { spawn } from 'child_process';

// Import infrastructure components
import { ServiceManager } from '../infrastructure/serviceManager';
import { ConfigurationManager } from '../infrastructure/configurationManager';
import { EventBus } from '../infrastructure/eventBus';
import { CacheManager } from '../infrastructure/cacheManager';
import { Logger } from '../infrastructure/logger';

export interface LSPServerConfig {
    name: string;
    language: string;
    command: string;
    args: string[];
    cwd?: string;
    env?: { [key: string]: string };
    settings?: any;
    enabled: boolean;
}

export interface LSPStatus {
    serverId: string;
    status: 'starting' | 'running' | 'stopped' | 'error';
    pid?: number;
    port?: number;
    startTime?: number;
    lastError?: string;
}

export class LSPManager extends EventEmitter {
    private context: vscode.ExtensionContext;
    private serviceManager: ServiceManager;
    private configManager: ConfigurationManager;
    private eventBus: EventBus;
    private cacheManager: CacheManager;
    private logger: Logger;
    
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private servers: Map<string, LSPServerConfig> = new Map();
    private serverStatuses: Map<string, LSPStatus> = new Map();
    private isInitialized = false;
    
    constructor(
        context: vscode.ExtensionContext,
        serviceManager: ServiceManager,
        configManager: ConfigurationManager,
        eventBus: EventBus,
        cacheManager: CacheManager,
        logger: Logger
    ) {
        super();
        this.context = context;
        this.serviceManager = serviceManager;
        this.configManager = configManager;
        this.eventBus = eventBus;
        this.cacheManager = cacheManager;
        this.logger = logger;
        
        this.outputChannel = vscode.window.createOutputChannel('Noodle LSP');
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.statusBarItem.text = '$(server) LSP';
        this.statusBarItem.tooltip = 'Noodle Language Servers';
        this.statusBarItem.command = 'noodle.lsp.status';
    }
    
    /**
     * Initialize the LSP Manager
     */
    public async initialize(): Promise<void> {
        try {
            this.logger.info('Initializing LSP Manager...');
            
            // Load server configurations
            await this.loadServerConfigurations();
            
            // Register event listeners
            this.registerEventListeners();
            
            // Register commands
            this.registerCommands();
            
            // Update status
            this.statusBarItem.show();
            this.updateStatus();
            
            this.isInitialized = true;
            this.logger.info('LSP Manager initialized successfully');
            this.emit('initialized');
        } catch (error) {
            this.logger.error(`Failed to initialize LSP Manager: ${error.message}`);
            this.updateStatus();
            throw error;
        }
    }
    
    /**
     * Load server configurations
     */
    private async loadServerConfigurations(): Promise<void> {
        try {
            // Load default configurations
            this.loadDefaultConfigurations();
            
            // Load custom configurations from settings
            await this.loadCustomConfigurations();
            
            this.logger.info(`Loaded ${this.servers.size} LSP server configurations`);
        } catch (error) {
            this.logger.error(`Failed to load server configurations: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Load default server configurations
     */
    private loadDefaultConfigurations(): void {
        // Noodle Language Server (primary focus)
        this.servers.set('noodle', {
            name: 'NoodleCore Language Server',
            language: 'noodle',
            command: 'python',
            args: ['-m', 'noodlecore.lsp.noodle_lsp_server'],
            enabled: true
        });
        
        // TypeScript/JavaScript (for web development)
        this.servers.set('typescript', {
            name: 'TypeScript Language Server',
            language: 'typescript',
            command: 'typescript-language-server',
            args: ['--stdio'],
            enabled: false // Disabled by default to focus on NoodleCore
        });
        
        // Python (for general Python files)
        this.servers.set('python', {
            name: 'Python Language Server',
            language: 'python',
            command: 'pylsp',
            args: ['--stdio'],
            enabled: false // Disabled by default to focus on NoodleCore
        });
        
        // JSON
        this.servers.set('json', {
            name: 'JSON Language Server',
            language: 'json',
            command: 'vscode-json-languageserver',
            args: ['--stdio'],
            enabled: false // Disabled by default to focus on NoodleCore
        });
        
        // HTML/CSS
        this.servers.set('html', {
            name: 'HTML/CSS Language Server',
            language: 'html',
            command: 'vscode-html-languageserver',
            args: ['--stdio'],
            enabled: false // Disabled by default to focus on NoodleCore
        });
    }
    
    /**
     * Load custom configurations from settings
     */
    private async loadCustomConfigurations(): Promise<void> {
        try {
            const config = vscode.workspace.getConfiguration('noodle.lsp');
            const customServers = config.get<any>('servers') || {};
            
            for (const [serverId, serverConfig] of Object.entries(customServers)) {
                if (serverConfig && typeof serverConfig === 'object') {
                    this.servers.set(serverId, {
                        name: (serverConfig as any).name || serverId,
                        language: (serverConfig as any).language || 'unknown',
                        command: (serverConfig as any).command || '',
                        args: (serverConfig as any).args || [],
                        cwd: (serverConfig as any).cwd,
                        env: (serverConfig as any).env,
                        settings: (serverConfig as any).settings,
                        enabled: (serverConfig as any).enabled !== false
                    });
                }
            }
        } catch (error) {
            this.logger.error(`Failed to load custom configurations: ${error.message}`);
        }
    }
    
    /**
     * Register event listeners
     */
    private registerEventListeners(): void {
        // Configuration changes
        vscode.workspace.onDidChangeConfiguration(async (event) => {
            if (event.affectsConfiguration('noodle.lsp')) {
                this.logger.info('LSP configuration changed, reloading...');
                await this.reloadConfigurations();
            }
        });
        
        // Workspace folder changes
        vscode.workspace.onDidChangeWorkspaceFolders(async () => {
            this.logger.info('Workspace changed, restarting LSP servers...');
            await this.restartAllServers();
        });
    }
    
    /**
     * Register commands
     */
    private registerCommands(): void {
        const commands = [
            vscode.commands.registerCommand('noodle.lsp.status', () => {
                this.showStatus();
            }),
            vscode.commands.registerCommand('noodle.lsp.restart', async () => {
                await this.restartAllServers();
            }),
            vscode.commands.registerCommand('noodle.lsp.restartServer', async (serverId: string) => {
                await this.restartServer(serverId);
            })
        ];
        
        commands.forEach(command => {
            this.context.subscriptions.push(command);
        });
    }
    
    /**
     * Start all enabled servers
     */
    public async startAllServers(): Promise<void> {
        const startPromises = [];
        
        for (const [serverId, config] of this.servers) {
            if (config.enabled) {
                startPromises.push(this.startServer(serverId));
            }
        }
        
        await Promise.all(startPromises);
        this.updateStatus();
    }
    
    /**
     * Start a specific server
     */
    public async startServer(serverId: string): Promise<void> {
        const config = this.servers.get(serverId);
        if (!config) {
            throw new Error(`Unknown server: ${serverId}`);
        }
        
        if (!config.enabled) {
            this.logger.info(`Server ${serverId} is disabled`);
            return;
        }
        
        const status = this.serverStatuses.get(serverId);
        if (status && (status.status === 'starting' || status.status === 'running')) {
            this.logger.info(`Server ${serverId} is already running`);
            return;
        }
        
        try {
            this.logger.info(`Starting LSP server: ${serverId}`);
            this.updateServerStatus(serverId, 'starting');
            
            // Create client options
            const clientOptions: vscode.LanguageClientOptions = {
                documentSelector: [{ scheme: 'file', language: config.language }],
                outputChannel: this.outputChannel,
                initializationOptions: config.settings,
                workspaceFolder: vscode.workspace.workspaceFolders?.[0]
            };
            
            // Create server options
            const serverOptions: vscode.ServerOptions = {
                command: config.command,
                args: config.args,
                options: {
                    cwd: config.cwd || vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    env: { ...process.env, ...config.env }
                }
            };
            
            // Create and start the language client
            const languageClient = new vscode.LanguageClient(
                serverId,
                config.name,
                serverOptions,
                clientOptions
            );
            
            // Start the client
            await languageClient.start();
            
            // Update status
            this.updateServerStatus(serverId, 'running', {
                pid: (languageClient as any)._serverProcess?.pid
            });
            
            this.logger.info(`LSP server ${serverId} started successfully`);
            this.emit('serverStarted', { serverId, config });
        } catch (error) {
            this.logger.error(`Failed to start LSP server ${serverId}: ${error.message}`);
            this.updateServerStatus(serverId, 'error', { lastError: error.message });
            this.emit('serverError', { serverId, error });
        }
        
        this.updateStatus();
    }
    
    /**
     * Stop a specific server
     */
    public async stopServer(serverId: string): Promise<void> {
        const status = this.serverStatuses.get(serverId);
        if (!status || status.status === 'stopped') {
            return;
        }
        
        try {
            this.logger.info(`Stopping LSP server: ${serverId}`);
            
            // Stop the language client
            // Note: In a real implementation, we would store the language client instance
            // and stop it here. For now, we'll just update the status.
            
            this.updateServerStatus(serverId, 'stopped');
            this.logger.info(`LSP server ${serverId} stopped`);
            this.emit('serverStopped', { serverId });
        } catch (error) {
            this.logger.error(`Failed to stop LSP server ${serverId}: ${error.message}`);
            this.updateServerStatus(serverId, 'error', { lastError: error.message });
        }
        
        this.updateStatus();
    }
    
    /**
     * Restart all servers
     */
    public async restartAllServers(): Promise<void> {
        const stopPromises = [];
        
        for (const serverId of this.servers.keys()) {
            stopPromises.push(this.stopServer(serverId));
        }
        
        await Promise.all(stopPromises);
        await this.startAllServers();
    }
    
    /**
     * Restart a specific server
     */
    public async restartServer(serverId: string): Promise<void> {
        await this.stopServer(serverId);
        await this.startServer(serverId);
    }
    
    /**
     * Reload configurations
     */
    private async reloadConfigurations(): Promise<void> {
        // Clear existing configurations
        this.servers.clear();
        
        // Reload configurations
        await this.loadServerConfigurations();
        
        // Restart servers with new configurations
        await this.restartAllServers();
    }
    
    /**
     * Update server status
     */
    private updateServerStatus(
        serverId: string,
        status: LSPStatus['status'],
        extra?: Partial<LSPStatus>
    ): void {
        const current = this.serverStatuses.get(serverId) || { serverId, status: 'stopped' };
        this.serverStatuses.set(serverId, {
            ...current,
            status,
            ...extra,
            startTime: status === 'running' ? Date.now() : current.startTime
        });
        
        this.emit('serverStatusChanged', { serverId, status });
    }
    
    /**
     * Update status bar
     */
    private updateStatus(): void {
        const runningServers = Array.from(this.serverStatuses.values())
            .filter(s => s.status === 'running').length;
        const totalServers = this.servers.size;
        
        let text = '$(server) LSP';
        if (runningServers > 0) {
            text += ` 🟢${runningServers}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Language Servers: ${runningServers}/${totalServers} running`;
    }
    
    /**
     * Show status
     */
    public async showStatus(): Promise<void> {
        try {
            let output = 'LSP Server Status\n';
            output += '=================\n\n';
            
            for (const [serverId, config] of this.servers) {
                const status = this.serverStatuses.get(serverId);
                const statusIcon = status?.status === 'running' ? '🟢' :
                                  status?.status === 'starting' ? '🟡' :
                                  status?.status === 'error' ? '🔴' : '⚪';
                
                output += `${statusIcon} ${config.name} (${serverId})\n`;
                output += `  Language: ${config.language}\n`;
                output += `  Status: ${status?.status || 'stopped'}\n`;
                output += `  Command: ${config.command} ${config.args.join(' ')}\n`;
                
                if (status?.pid) {
                    output += `  PID: ${status.pid}\n`;
                }
                
                if (status?.startTime) {
                    const uptime = Date.now() - status.startTime;
                    output += `  Uptime: ${Math.round(uptime / 1000)}s\n`;
                }
                
                if (status?.lastError) {
                    output += `  Error: ${status.lastError}\n`;
                }
                
                output += '\n';
            }
            
            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            this.logger.error(`Failed to show status: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show LSP status: ${error.message}`);
        }
    }
    
    /**
     * Get server configurations
     */
    public getServerConfigurations(): Map<string, LSPServerConfig> {
        return new Map(this.servers);
    }
    
    /**
     * Get server statuses
     */
    public getServerStatuses(): Map<string, LSPStatus> {
        return new Map(this.serverStatuses);
    }
    
    /**
     * Get server status
     */
    public getServerStatus(serverId: string): LSPStatus | undefined {
        return this.serverStatuses.get(serverId);
    }
    
    /**
     * Dispose the LSP Manager
     */
    public dispose(): void {
        // Stop all servers
        const stopPromises = [];
        for (const serverId of this.servers.keys()) {
            stopPromises.push(this.stopServer(serverId));
        }
        
        // Dispose UI components
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
        
        // Clear data
        this.servers.clear();
        this.serverStatuses.clear();
        this.removeAllListeners();
    }
}