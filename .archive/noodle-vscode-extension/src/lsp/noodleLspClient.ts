/**
 * NoodleCore Language Server Protocol Client
 * 
 * This module implements the LSP client that communicates with the NoodleCore LSP server,
 * providing deep language understanding and IntelliSense capabilities for NoodleCore files.
 */

import * as vscode from 'vscode';
import { 
    LanguageClient, 
    LanguageClientOptions, 
    ServerOptions, 
    TransportKind,
    State
} from 'vscode-languageclient/node';
import * as path from 'path';
import * as os from 'os';

export class NoodleLspClient {
    private client: LanguageClient | undefined;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private context: vscode.ExtensionContext;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore LSP');
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        this.statusBarItem.text = '$(gear) NoodleCore LSP';
        this.statusBarItem.tooltip = 'NoodleCore Language Server Status';
        this.statusBarItem.command = 'noodle.lsp.showOutput';
        this.statusBarItem.show();
    }

    /**
     * Start the LSP client
     */
    public async start(): Promise<boolean> {
        try {
            this.outputChannel.appendLine('Starting NoodleCore Language Server...');
            this.updateStatus('$(sync~spin) Starting...', 'warning');

            // Get server configuration
            const serverOptions = this.getServerOptions();
            if (!serverOptions) {
                this.outputChannel.appendLine('Failed to get server options');
                this.updateStatus('$(error) Failed', 'error');
                return false;
            }

            // Get client configuration
            const clientOptions: LanguageClientOptions = {
                documentSelector: [
                    { scheme: 'file', language: 'noodle' },
                    { scheme: 'file', language: 'nc' }
                ],
                synchronize: {
                    // Notify the server about file changes
                    fileEvents: vscode.workspace.createFileSystemWatcher('**/*.{nc,noodle}')
                },
                outputChannel: this.outputChannel,
                progressOnInitialization: true,
                initializationOptions: {
                    experimentalFeatures: {
                        patternMatching: true,
                        genericsSupport: true,
                        asyncAwaitSupport: true,
                        aiIntegration: true,
                        advancedDiagnostics: true
                    }
                },
                middleware: {
                    // Custom middleware for enhanced functionality
                    provideCompletionItem: async (document, position, context, token, next) => {
                        const result = await next(document, position, context, token);
                        return this.enhanceCompletionItems(result);
                    },
                    provideHover: async (document, position, token, next) => {
                        const result = await next(document, position, token);
                        return this.enhanceHoverContent(result);
                    }
                }
            };

            // Create and start the client
            this.client = new LanguageClient(
                'noodleCoreLanguageServer',
                'NoodleCore Language Server',
                serverOptions,
                clientOptions
            );

            // Register event handlers
            this.registerEventHandlers();

            // Start the client
            await this.client.start();

            this.outputChannel.appendLine('NoodleCore Language Server started successfully');
            this.updateStatus('$(check) Ready', 'success');
            return true;

        } catch (error) {
            const errorMessage = error instanceof Error ? error.message : String(error);
            this.outputChannel.appendLine(`Failed to start NoodleCore Language Server: ${errorMessage}`);
            this.updateStatus('$(error) Failed', 'error');
            vscode.window.showErrorMessage(`Failed to start NoodleCore Language Server: ${errorMessage}`);
            return false;
        }
    }

    /**
     * Stop the LSP client
     */
    public async stop(): Promise<void> {
        if (this.client) {
            try {
                this.outputChannel.appendLine('Stopping NoodleCore Language Server...');
                this.updateStatus('$(sync~spin) Stopping...', 'warning');
                
                await this.client.stop();
                this.client = undefined;
                
                this.outputChannel.appendLine('NoodleCore Language Server stopped');
                this.updateStatus('$(circle-slash) Stopped', 'warning');
            } catch (error) {
                const errorMessage = error instanceof Error ? error.message : String(error);
                this.outputChannel.appendLine(`Error stopping NoodleCore Language Server: ${errorMessage}`);
            }
        }
    }

    /**
     * Restart the LSP client
     */
    public async restart(): Promise<boolean> {
        await this.stop();
        return await this.start();
    }

    /**
     * Check if the client is running
     */
    public isRunning(): boolean {
        return this.client?.state === State.Running;
    }

    /**
     * Get server options based on configuration
     */
    private getServerOptions(): ServerOptions | null {
        const config = vscode.workspace.getConfiguration('noodle');
        const serverMode = config.get<string>('lsp.serverMode', 'python');

        if (serverMode === 'python') {
            return this.getPythonServerOptions();
        } else if (serverMode === 'node') {
            return this.getNodeServerOptions();
        } else {
            this.outputChannel.appendLine(`Unknown server mode: ${serverMode}`);
            return null;
        }
    }

    /**
     * Get Python server options
     */
    private getPythonServerOptions(): ServerOptions {
        const config = vscode.workspace.getConfiguration('noodle');
        const pythonPath = config.get<string>('lsp.pythonPath', 'python');
        const serverPath = config.get<string>('lsp.serverPath', this.getDefaultPythonServerPath());

        return {
            command: pythonPath,
            args: [serverPath],
            options: {
                cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath || process.cwd(),
                env: {
                    ...process.env,
                    NOODLE_ENV: vscode.env.shell === 'WindowsPowerShell' ? 'windows' : 'unix',
                    NOODLE_LOG_LEVEL: config.get<string>('lsp.logLevel', 'INFO'),
                    PYTHONPATH: this.getPythonPath()
                }
            },
            transport: TransportKind.stdio
        };
    }

    /**
     * Get Node.js server options
     */
    private getNodeServerOptions(): ServerOptions {
        const config = vscode.workspace.getConfiguration('noodle');
        const nodePath = config.get<string>('lsp.nodePath', 'node');
        const serverPath = config.get<string>('lsp.serverPath', this.getDefaultNodeServerPath());

        return {
            command: nodePath,
            args: [serverPath],
            options: {
                cwd: vscode.workspace.workspaceFolders?.[0]?.uri.fsPath || process.cwd(),
                env: {
                    ...process.env,
                    NOODLE_ENV: vscode.env.shell === 'WindowsPowerShell' ? 'windows' : 'unix',
                    NOODLE_LOG_LEVEL: config.get<string>('lsp.logLevel', 'info')
                }
            },
            transport: TransportKind.stdio
        };
    }

    /**
     * Get default Python server path
     */
    private getDefaultPythonServerPath(): string {
        const extensionPath = this.context.extensionPath;
        const serverPath = path.join(extensionPath, 'server', 'noodle_lsp_server.py');
        
        // Fallback to bundled server
        if (!require('fs').existsSync(serverPath)) {
            return path.join(extensionPath, 'out', 'server', 'noodle_lsp_server.py');
        }
        
        return serverPath;
    }

    /**
     * Get default Node.js server path
     */
    private getDefaultNodeServerPath(): string {
        const extensionPath = this.context.extensionPath;
        return path.join(extensionPath, 'out', 'server', 'noodleLspServer.js');
    }

    /**
     * Get Python path for the server
     */
    private getPythonPath(): string {
        const extensionPath = this.context.extensionPath;
        const noodleCorePath = path.join(extensionPath, '..', '..', 'noodle-core', 'src');
        
        return [
            noodleCorePath,
            process.env.PYTHONPATH || ''
        ].filter(Boolean).join(path.delimiter);
    }

    /**
     * Register event handlers
     */
    private registerEventHandlers(): void {
        if (!this.client) return;

        this.client.onDidChangeState((event) => {
            switch (event.newState) {
                case State.Starting:
                    this.updateStatus('$(sync~spin) Starting...', 'warning');
                    break;
                case State.Running:
                    this.updateStatus('$(check) Ready', 'success');
                    break;
                case State.Stopped:
                    this.updateStatus('$(circle-slash) Stopped', 'warning');
                    break;
            }
        });

        this.client.onNotification('noodle/showMessage', (params) => {
            switch (params.type) {
                case 'error':
                    vscode.window.showErrorMessage(params.message);
                    break;
                case 'warning':
                    vscode.window.showWarningMessage(params.message);
                    break;
                case 'info':
                    vscode.window.showInformationMessage(params.message);
                    break;
            }
        });

        this.client.onNotification('noodle/logMessage', (params) => {
            this.outputChannel.appendLine(`[${params.level.toUpperCase()}] ${params.message}`);
        });

        this.client.onRequest('noodle/showProgress', async (params) => {
            return await vscode.window.withProgress(
                {
                    location: vscode.ProgressLocation.Notification,
                    title: params.title,
                    cancellable: params.cancellable
                },
                async (progress, token) => {
                    token.onCancellationRequested(() => {
                        this.client?.sendNotification('noodle/progressCancelled', { id: params.id });
                    });

                    // Handle progress updates from server
                    this.client?.onNotification('noodle/progressUpdate', (update) => {
                        if (update.id === params.id) {
                            progress.report({
                                increment: update.increment,
                                message: update.message
                            });
                        }
                    });

                    return new Promise((resolve) => {
                        // Resolve when server sends completion notification
                        const disposable = this.client?.onNotification('noodle/progressComplete', (complete) => {
                            if (complete.id === params.id) {
                                disposable?.dispose();
                                resolve(complete.result);
                            }
                        });
                    });
                }
            );
        });
    }

    /**
     * Enhance completion items with NoodleCore-specific features
     */
    private enhanceCompletionItems(items: any[]): any[] {
        if (!items) return items;

        return items.map(item => {
            // Add NoodleCore-specific enhancements
            if (item.kind === vscode.CompletionItemKind.Function && item.label.startsWith('ai_')) {
                // AI function enhancements
                item.documentation = new vscode.MarkdownString(
                    `**AI Function**: ${item.documentation || item.label}\n\n` +
                    `This function integrates with NoodleCore's AI capabilities.`
                );
            } else if (item.kind === vscode.CompletionItemKind.Keyword && item.label === 'match') {
                // Pattern matching enhancements
                item.documentation = new vscode.MarkdownString(
                    `**Pattern Matching**: \`match\`\n\n` +
                    `Start a pattern matching expression.\n\n` +
                    `\`\`\`noodle\n` +
                    `match expression {\n` +
                    `    case pattern1:\n` +
                    `        // handle pattern1\n` +
                    `    case pattern2:\n` +
                    `        // handle pattern2\n` +
                    `}\n` +
                    `\`\`\``
                );
            }

            return item;
        });
    }

    /**
     * Enhance hover content with NoodleCore-specific features
     */
    private enhanceHoverContent(hover: any): any {
        if (!hover) return hover;

        // Add NoodleCore-specific enhancements
        if (typeof hover.contents === 'string' && hover.contents.includes('AI')) {
            hover.contents = new vscode.MarkdownString(
                `**AI Integration**\n\n${hover.contents}\n\n` +
                `*This feature leverages NoodleCore's built-in AI capabilities.*`
            );
        }

        return hover;
    }

    /**
     * Update status bar item
     */
    private updateStatus(text: string, color: string): void {
        this.statusBarItem.text = text;
        this.statusBarItem.color = this.getStatusColor(color);
    }

    /**
     * Get status color
     */
    private getStatusColor(status: string): string {
        switch (status) {
            case 'success':
                return '#4CAF50';
            case 'warning':
                return '#FF9800';
            case 'error':
                return '#F44336';
            default:
                return undefined;
        }
    }

    /**
     * Show output channel
     */
    public showOutput(): void {
        this.outputChannel.show();
    }

    /**
     * Dispose resources
     */
    public dispose(): void {
        this.stop();
        this.outputChannel.dispose();
        this.statusBarItem.dispose();
    }
}