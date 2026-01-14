"use strict";
/**
 * Minimal LSP Manager for Noodle VS Code Extension
 *
 * Simplified version without infrastructure dependencies
 * Properly handles server lifecycle to prevent zombie processes
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
const child_process_1 = require("child_process");
const events_1 = require("events");
class LSPManager extends events_1.EventEmitter {
    constructor(context, serviceManager, configManager, eventBus, cacheManager, logger) {
        super();
        this.servers = new Map();
        this.serverProcesses = new Map();
        this.serverStatuses = new Map();
        this.isInitialized = false;
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle LSP');
        this.outputChannel.appendLine('LSP Manager created (Minimal Mode)');
    }
    /**
     * Initialize the LSP Manager
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing LSP Manager...');
            // In minimal mode, we don't auto-start any servers
            // Servers will only start when explicitly needed
            this.isInitialized = true;
            this.outputChannel.appendLine('LSP Manager initialized (Minimal Mode)');
            this.emit('initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`LSP Manager initialization error: ${error.message}`);
            throw error;
        }
    }
    /**
     * Start a language server
     */
    async startServer(serverId) {
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
            const serverProcess = (0, child_process_1.spawn)(config.command, config.args, {
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
        }
        catch (error) {
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
    async stopServer(serverId) {
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
            await new Promise((resolve) => {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to stop server ${serverId}: ${error.message}`);
            throw error;
        }
    }
    /**
     * Get server status
     */
    getServerStatus(serverId) {
        return this.serverStatuses.get(serverId);
    }
    /**
     * Get all server statuses
     */
    getAllServerStatuses() {
        return Array.from(this.serverStatuses.values());
    }
    /**
     * Register a server configuration
     */
    registerServer(config) {
        this.servers.set(config.name, config);
        this.outputChannel.appendLine(`Registered server: ${config.name}`);
    }
    /**
     * Dispose of the LSP Manager
     * CRITICAL: This must properly stop all servers to prevent zombie processes
     */
    async dispose() {
        this.outputChannel.appendLine('Disposing LSP Manager...');
        // Create stop promises for all running servers
        const stopPromises = [];
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
exports.LSPManager = LSPManager;
//# sourceMappingURL=lspManager.js.map