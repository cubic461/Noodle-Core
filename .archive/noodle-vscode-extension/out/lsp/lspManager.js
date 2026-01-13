"use strict";
/**
 * LSP Manager for Noodle VS Code Extension
 *
 * Manages Language Server Protocol (LSP) connections and provides
 * language intelligence features.
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
exports.LSPManager = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class LSPManager extends events_1.EventEmitter {
    constructor(context, serviceManager, configManager, eventBus, cacheManager, logger) {
        super();
        this.servers = new Map();
        this.serverStatuses = new Map();
        this.isInitialized = false;
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
    async initialize() {
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
        }
        catch (error) {
            this.logger.error(`Failed to initialize LSP Manager: ${error.message}`);
            this.updateStatus();
            throw error;
        }
    }
    /**
     * Load server configurations
     */
    async loadServerConfigurations() {
        try {
            // Load default configurations
            this.loadDefaultConfigurations();
            // Load custom configurations from settings
            await this.loadCustomConfigurations();
            this.logger.info(`Loaded ${this.servers.size} LSP server configurations`);
        }
        catch (error) {
            this.logger.error(`Failed to load server configurations: ${error.message}`);
            throw error;
        }
    }
    /**
     * Load default server configurations
     */
    loadDefaultConfigurations() {
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
    async loadCustomConfigurations() {
        try {
            const config = vscode.workspace.getConfiguration('noodle.lsp');
            const customServers = config.get('servers') || {};
            for (const [serverId, serverConfig] of Object.entries(customServers)) {
                if (serverConfig && typeof serverConfig === 'object') {
                    this.servers.set(serverId, {
                        name: serverConfig.name || serverId,
                        language: serverConfig.language || 'unknown',
                        command: serverConfig.command || '',
                        args: serverConfig.args || [],
                        cwd: serverConfig.cwd,
                        env: serverConfig.env,
                        settings: serverConfig.settings,
                        enabled: serverConfig.enabled !== false
                    });
                }
            }
        }
        catch (error) {
            this.logger.error(`Failed to load custom configurations: ${error.message}`);
        }
    }
    /**
     * Register event listeners
     */
    registerEventListeners() {
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
    registerCommands() {
        const commands = [
            vscode.commands.registerCommand('noodle.lsp.status', () => {
                this.showStatus();
            }),
            vscode.commands.registerCommand('noodle.lsp.restart', async () => {
                await this.restartAllServers();
            }),
            vscode.commands.registerCommand('noodle.lsp.restartServer', async (serverId) => {
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
    async startAllServers() {
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
    async startServer(serverId) {
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
            const clientOptions = {
                documentSelector: [{ scheme: 'file', language: config.language }],
                outputChannel: this.outputChannel,
                initializationOptions: config.settings,
                workspaceFolder: vscode.workspace.workspaceFolders?.[0]
            };
            // Create server options
            const serverOptions = {
                command: config.command,
                args: config.args,
                options: {
                    cwd: config.cwd || vscode.workspace.workspaceFolders?.[0]?.uri.fsPath,
                    env: { ...process.env, ...config.env }
                }
            };
            // Create and start the language client
            const languageClient = new vscode.LanguageClient(serverId, config.name, serverOptions, clientOptions);
            // Start the client
            await languageClient.start();
            // Update status
            this.updateServerStatus(serverId, 'running', {
                pid: languageClient._serverProcess?.pid
            });
            this.logger.info(`LSP server ${serverId} started successfully`);
            this.emit('serverStarted', { serverId, config });
        }
        catch (error) {
            this.logger.error(`Failed to start LSP server ${serverId}: ${error.message}`);
            this.updateServerStatus(serverId, 'error', { lastError: error.message });
            this.emit('serverError', { serverId, error });
        }
        this.updateStatus();
    }
    /**
     * Stop a specific server
     */
    async stopServer(serverId) {
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
        }
        catch (error) {
            this.logger.error(`Failed to stop LSP server ${serverId}: ${error.message}`);
            this.updateServerStatus(serverId, 'error', { lastError: error.message });
        }
        this.updateStatus();
    }
    /**
     * Restart all servers
     */
    async restartAllServers() {
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
    async restartServer(serverId) {
        await this.stopServer(serverId);
        await this.startServer(serverId);
    }
    /**
     * Reload configurations
     */
    async reloadConfigurations() {
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
    updateServerStatus(serverId, status, extra) {
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
    updateStatus() {
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
    async showStatus() {
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
        }
        catch (error) {
            this.logger.error(`Failed to show status: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show LSP status: ${error.message}`);
        }
    }
    /**
     * Get server configurations
     */
    getServerConfigurations() {
        return new Map(this.servers);
    }
    /**
     * Get server statuses
     */
    getServerStatuses() {
        return new Map(this.serverStatuses);
    }
    /**
     * Get server status
     */
    getServerStatus(serverId) {
        return this.serverStatuses.get(serverId);
    }
    /**
     * Dispose the LSP Manager
     */
    dispose() {
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
exports.LSPManager = LSPManager;
//# sourceMappingURL=lspManager.js.map