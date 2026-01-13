"use strict";
/**
 * Welcome Provider for Noodle VS Code Extension
 *
 * Provides welcome screen and getting started guide for new users.
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
exports.NoodleWelcomeProvider = void 0;
const vscode = __importStar(require("vscode"));
class NoodleWelcomeProvider {
    constructor(context) {
        this.context = context;
    }
    /**
     * Initialize the welcome provider
     */
    async initialize() {
        // No initialization needed
    }
    /**
     * Show welcome screen
     */
    showWelcome() {
        if (this.panel) {
            this.panel.reveal();
            return;
        }
        // Create webview panel
        this.panel = vscode.window.createWebviewPanel('noodleWelcome', 'Welcome to Noodle', vscode.ViewColumn.One, {
            enableScripts: true,
            retainContextWhenHidden: true,
            localResourceRoots: [this.context.extensionUri]
        });
        // Set webview HTML
        this.panel.webview.html = this.getWelcomeHtml();
        // Handle messages from webview
        this.panel.webview.onDidReceiveMessage(message => {
            this.handleMessage(message);
        });
        // Handle panel disposal
        this.panel.onDidDispose(() => {
            this.panel = undefined;
        });
    }
    /**
     * Get welcome HTML
     */
    getWelcomeHtml() {
        return `
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Welcome to Noodle</title>
            <style>
                body {
                    font-family: var(--vscode-font-family);
                    background-color: var(--vscode-editor-background);
                    color: var(--vscode-editor-foreground);
                    padding: 20px;
                    margin: 0;
                }
                .container {
                    max-width: 800px;
                    margin: 0 auto;
                }
                .header {
                    text-align: center;
                    margin-bottom: 30px;
                }
                .logo {
                    font-size: 48px;
                    font-weight: bold;
                    margin-bottom: 10px;
                }
                .subtitle {
                    font-size: 18px;
                    color: var(--vscode-descriptionForeground);
                    margin-bottom: 30px;
                }
                .features {
                    display: grid;
                    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
                    gap: 20px;
                    margin-bottom: 30px;
                }
                .feature {
                    background-color: var(--vscode-editor-selectionBackground);
                    border-radius: 8px;
                    padding: 20px;
                    text-align: center;
                }
                .feature h3 {
                    margin-top: 0;
                    color: var(--vscode-editor-foreground);
                }
                .feature p {
                    color: var(--vscode-descriptionForeground);
                    margin-bottom: 15px;
                }
                .button {
                    background-color: var(--vscode-button-background);
                    color: var(--vscode-button-foreground);
                    border: none;
                    padding: 10px 20px;
                    border-radius: 4px;
                    cursor: pointer;
                    font-size: 14px;
                }
                .button:hover {
                    background-color: var(--vscode-button-hoverBackground);
                }
                .actions {
                    text-align: center;
                    margin-top: 30px;
                }
                .actions .button {
                    margin: 0 10px;
                }
            </style>
        </head>
        <body>
            <div class="container">
                <div class="header">
                    <div class="logo">🍜 Noodle</div>
                    <div class="subtitle">AI-Powered Development Environment</div>
                </div>
                
                <div class="features">
                    <div class="feature">
                        <h3>🤖 AI Assistant</h3>
                        <p>Get intelligent code completion, explanations, and refactoring suggestions powered by advanced AI.</p>
                        <button class="button" onclick="openChat()">Open AI Chat</button>
                    </div>
                    
                    <div class="feature">
                        <h3>🔍 Code Analysis</h3>
                        <p>Analyze your code for issues, improvements, and best practices with real-time feedback.</p>
                        <button class="button" onclick="analyzeCode()">Analyze Code</button>
                    </div>
                    
                    <div class="feature">
                        <h3>🚀 Performance Monitoring</h3>
                        <p>Monitor your extension performance and resource usage with detailed metrics.</p>
                        <button class="button" onclick="showMetrics()">Show Metrics</button>
                    </div>
                    
                    <div class="feature">
                        <h3>🔧 Ecosystem Integration</h3>
                        <p>Seamlessly integrate with Git, GitHub, CI/CD pipelines, and monitoring tools.</p>
                        <button class="button" onclick="showStatus()">Show Status</button>
                    </div>
                </div>
                
                <div class="actions">
                    <button class="button" onclick="openSettings()">⚙️ Settings</button>
                    <button class="button" onclick="openDocumentation()">📚 Documentation</button>
                </div>
            </div>
            
            <script>
                const vscode = acquireVsCodeApi();
                
                function openChat() {
                    vscode.postMessage({ command: 'openChat' });
                }
                
                function analyzeCode() {
                    vscode.postMessage({ command: 'analyzeCode' });
                }
                
                function showMetrics() {
                    vscode.postMessage({ command: 'showMetrics' });
                }
                
                function showStatus() {
                    vscode.postMessage({ command: 'showStatus' });
                }
                
                function openSettings() {
                    vscode.postMessage({ command: 'openSettings' });
                }
                
                function openDocumentation() {
                    vscode.postMessage({ command: 'openDocumentation' });
                }
            </script>
        </body>
        </html>
        `;
    }
    /**
     * Handle message from webview
     */
    handleMessage(message) {
        switch (message.command) {
            case 'openChat':
                vscode.commands.executeCommand('noodle.ai.chat');
                break;
            case 'analyzeCode':
                vscode.commands.executeCommand('noodle.analyze.code');
                break;
            case 'showMetrics':
                vscode.commands.executeCommand('noodle.performance.showMetrics');
                break;
            case 'showStatus':
                vscode.commands.executeCommand('noodle.ecosystem.showStatus');
                break;
            case 'openSettings':
                vscode.commands.executeCommand('workbench.action.openSettings', '@ext:noodle');
                break;
            case 'openDocumentation':
                vscode.env.openExternal(vscode.Uri.parse('https://github.com/noodle/noodle-vscode-extension'));
                break;
        }
    }
    /**
     * Dispose the provider
     */
    dispose() {
        if (this.panel) {
            this.panel.dispose();
        }
    }
}
exports.NoodleWelcomeProvider = NoodleWelcomeProvider;
//# sourceMappingURL=welcomeProvider.js.map