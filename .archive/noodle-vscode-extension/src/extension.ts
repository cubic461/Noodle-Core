/**
 * Noodle VS Code Extension
 *
 * Main entry point for the Noodle VS Code extension with AI-powered
 * development tools, ecosystem integration, and modern infrastructure.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';
import * as path from 'path';
import * as fs from 'fs';

// Import all infrastructure components
import { EcosystemIntegration } from './ecosystem/index';

// Import AI and development tools
import { AIAssistantProvider } from './ai/aiAssistantProvider';
import { LSPManager } from './lsp/lspManager';

// Import UI components
import { NoodleWelcomeProvider } from './ui/welcomeProvider';
import { NoodleTreeProvider } from './ui/treeProvider';
import { NoodleStatusBar } from './ui/statusBar';

// Import chat panel
import { AIChatPanel } from './components/aiChatPanel';

// Import backend service
import { NoodleBackendService } from './services/backendService';

export class NoodleExtension extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private isInitialized = false;
    private isActivated = false;
    
    // Infrastructure components
    private ecosystemIntegration: EcosystemIntegration;
    private serviceManager: any;
    
    // Core services
    private aiAssistant: AIAssistantProvider;
    private lspManager: LSPManager;
    private backendService: NoodleBackendService;
    private chatPanel: AIChatPanel | undefined;
    
    // UI components
    private welcomeProvider: NoodleWelcomeProvider;
    private treeProvider: NoodleTreeProvider;
    private statusBar: NoodleStatusBar;
    private statusBarItem: vscode.StatusBarItem;
    
    /**
     * Activate the extension
     */
    public async activate(): Promise<void> {
        try {
            if (this.isActivated) {
                return;
            }
            
            // Initialize output channel
            this.outputChannel = vscode.window.createOutputChannel('Noodle Extension');
            
            // Initialize infrastructure
            await this.initializeInfrastructure();
            
            // Activate core services
            await this.activateCoreServices();
            
            // Activate UI components
            await this.activateUIComponents();
            
            // Register commands and event listeners
            await this.registerCommands();
            await this.registerEventListeners();
            
            // Set activation completion
            this.isActivated = true;
            
            this.outputChannel.appendLine('Noodle extension activated successfully');
            this.emit('activated');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to activate extension: ${error.message}`);
            throw error;
        }
    }

    /**
     * Initialize infrastructure
     */
    private async initializeInfrastructure(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing infrastructure...');
            
            // Initialize ecosystem integration
            this.ecosystemIntegration = new EcosystemIntegration(this.context);
            await this.ecosystemIntegration.initialize();
            
            // Initialize service manager
            this.serviceManager = this.ecosystemIntegration.getServiceManager();
            
            this.outputChannel.appendLine('Infrastructure initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Infrastructure initialization failed: ${error.message}`);
            throw error;
        }
    }

    /**
     * Activate core services
     */
    private async activateCoreServices(): Promise<void> {
        this.outputChannel.appendLine('Activating core services...');
        
        // Get services from ecosystem integration
        const serviceManager = this.ecosystemIntegration.getServiceManager();
        const configManager = this.ecosystemIntegration.getConfigurationManager();
        const eventBus = this.ecosystemIntegration.getEventBus();
        const cacheManager = this.ecosystemIntegration.getCacheManager();
        const logger = this.ecosystemIntegration.getLogger();
        
        // Initialize Backend Service
        this.backendService = new NoodleBackendService(
            serviceManager,
            configManager,
            eventBus,
            cacheManager,
            logger
        );
        await this.backendService.initialize();
        
        // Initialize AI Assistant
        this.aiAssistant = new AIAssistantProvider(
            this.context,
            serviceManager,
            configManager,
            eventBus,
            cacheManager,
            logger
        );
        await this.aiAssistant.initialize();
        
        // Initialize LSP Manager
        this.lspManager = new LSPManager(
            this.context,
            serviceManager,
            configManager,
            eventBus,
            cacheManager,
            logger
        );
        await this.lspManager.initialize();
        
        this.outputChannel.appendLine('Core services activated');
    }

    /**
     * Activate ecosystem integration
     */
    // Remove this method as ecosystem integration is already initialized in initializeInfrastructure

    /**
     * Activate UI components
     */
    private async activateUIComponents(): Promise<void> {
        this.outputChannel.appendLine('Activating UI components...');
        
        // Initialize welcome provider
        this.welcomeProvider = new NoodleWelcomeProvider(this.context);
        await this.welcomeProvider.initialize();
        
        // Initialize tree provider
        this.treeProvider = new NoodleTreeProvider(this.context);
        await this.treeProvider.initialize();
        
        // Initialize status bar
        this.statusBar = new NoodleStatusBar(this.context);
        await this.statusBar.initialize();
        
        this.outputChannel.appendLine('UI components activated');
    }

    /**
     * Register commands
     */
    private async registerCommands(): Promise<void> {
        this.outputChannel.appendLine('Registering commands...');
        
        // Core commands
        const disposables = [
            vscode.commands.registerCommand('noodle.showWelcome', () => {
                this.welcomeProvider.showWelcome();
            }),
            
            vscode.commands.registerCommand('noodle.ai.chat', () => {
                this.showChatPanel();
            }),
            
            vscode.commands.registerCommand('noodle.ai.assist', () => {
                this.aiAssistant.showAssist();
            }),
            
            vscode.commands.registerCommand('noodle.lsp.status', () => {
                this.lspManager.showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.ecosystem.showStatus', () => {
                this.ecosystemIntegration.showStatus();
            }),
            
            // Git commands
            vscode.commands.registerCommand('noodle.git.status', () => {
                this.ecosystemIntegration.getGitIntegration().showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.git.showStatus', () => {
                this.ecosystemIntegration.getGitIntegration().showDetailedStatus();
            }),
            
            vscode.commands.registerCommand('noodle.git.createBranch', async () => {
                const branchName = await vscode.window.showInputBox({
                    prompt: 'Enter branch name',
                    placeHolder: 'feature/new-feature'
                });
                if (branchName) {
                    await this.ecosystemIntegration.getGitIntegration().createBranch(branchName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.git.checkoutBranch', async () => {
                const branches = await this.ecosystemIntegration.getGitIntegration().getBranches();
                const branchName = await vscode.window.showQuickPick(branches, {
                    placeHolder: 'Select branch to checkout'
                });
                if (branchName) {
                    await this.ecosystemIntegration.getGitIntegration().checkoutBranch(branchName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.git.deleteBranch', async () => {
                const branches = await this.ecosystemIntegration.getGitIntegration().getBranches();
                const branchName = await vscode.window.showQuickPick(branches, {
                    placeHolder: 'Select branch to delete'
                });
                if (branchName) {
                    await this.ecosystemIntegration.getGitIntegration().deleteBranch(branchName);
                }
            }),
            
            // GitHub commands
            vscode.commands.registerCommand('noodle.github.showStatus', () => {
                this.ecosystemIntegration.getGitHubApiConnectors().showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.github.createIssue', async () => {
                const title = await vscode.window.showInputBox({
                    prompt: 'Enter issue title',
                    placeHolder: 'Issue title'
                });
                if (title) {
                    const body = await vscode.window.showInputBox({
                        prompt: 'Enter issue description',
                        placeHolder: 'Issue description'
                    });
                    await this.ecosystemIntegration.getGitHubApiConnectors().createIssue(title, body || '');
                }
            }),
            
            // CI/CD commands
            vscode.commands.registerCommand('noodle.cicd.showStatus', () => {
                this.ecosystemIntegration.getCICDIntegration().showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.cicd.createConfig', async () => {
                const platform = await vscode.window.showQuickPick([
                    'GitHub Actions',
                    'GitLab CI',
                    'Jenkins',
                    'Azure DevOps'
                ], {
                    placeHolder: 'Select CI/CD platform'
                });
                if (platform) {
                    await this.ecosystemIntegration.getCICDIntegration().createConfig(platform);
                }
            }),
            
            // Deployment automation commands
            vscode.commands.registerCommand('noodle.deployment.showStatus', () => {
                this.ecosystemIntegration.getDeploymentAutomationScripts().showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.deployment.createK8sEnvironment', async () => {
                const name = await vscode.window.showInputBox({
                    prompt: 'Enter environment name',
                    placeHolder: 'production'
                });
                if (name) {
                    const namespace = await vscode.window.showInputBox({
                        prompt: 'Enter Kubernetes namespace',
                        placeHolder: 'default'
                    });
                    if (namespace) {
                        await this.ecosystemIntegration.getDeploymentAutomationScripts().createKubernetesEnvironment(name, namespace);
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.deployToK8s', async () => {
                const manifestPath = await vscode.window.showInputBox({
                    prompt: 'Enter manifest file path',
                    placeHolder: './k8s/deployment.yaml'
                });
                if (manifestPath) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().deployToKubernetes(manifestPath);
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.scaleK8sDeployment', async () => {
                const deploymentName = await vscode.window.showInputBox({
                    prompt: 'Enter deployment name',
                    placeHolder: 'my-app'
                });
                if (deploymentName) {
                    const replicas = await vscode.window.showInputBox({
                        prompt: 'Enter number of replicas',
                        placeHolder: '3'
                    });
                    if (replicas) {
                        await this.ecosystemIntegration.getDeploymentAutomationScripts().scaleKubernetesDeployment(deploymentName, parseInt(replicas));
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.getK8sPodLogs', async () => {
                const podName = await vscode.window.showInputBox({
                    prompt: 'Enter pod name',
                    placeHolder: 'my-app-pod-12345'
                });
                if (podName) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().getKubernetesPodLogs(podName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.deleteK8sResource', async () => {
                const resourceType = await vscode.window.showQuickPick([
                    'pod',
                    'deployment',
                    'service',
                    'ingress'
                ], {
                    placeHolder: 'Select resource type'
                });
                if (resourceType) {
                    const resourceName = await vscode.window.showInputBox({
                        prompt: `Enter ${resourceType} name`,
                        placeHolder: 'my-resource'
                    });
                    if (resourceName) {
                        await this.ecosystemIntegration.getDeploymentAutomationScripts().deleteKubernetesResource(resourceType, resourceName);
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.setupK8sPortForward', async () => {
                const podName = await vscode.window.showInputBox({
                    prompt: 'Enter pod name',
                    placeHolder: 'my-app-pod-12345'
                });
                if (podName) {
                    const localPort = await vscode.window.showInputBox({
                        prompt: 'Enter local port',
                        placeHolder: '8080'
                    });
                    if (localPort) {
                        const remotePort = await vscode.window.showInputBox({
                            prompt: 'Enter remote port',
                            placeHolder: '80'
                        });
                        if (remotePort) {
                            await this.ecosystemIntegration.getDeploymentAutomationScripts().setupKubernetesPortForward(podName, parseInt(localPort), parseInt(remotePort));
                        }
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.deployment.createK8sManifest', async () => {
                const resourceType = await vscode.window.showQuickPick([
                    'deployment',
                    'service',
                    'ingress',
                    'configmap',
                    'secret'
                ], {
                    placeHolder: 'Select resource type'
                });
                if (resourceType) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().createKubernetesManifest(resourceType);
                }
            }),
            
            // Monitoring commands
            vscode.commands.registerCommand('noodle.monitoring.showStatus', () => {
                this.ecosystemIntegration.getMonitoringSystemAdapters().showStatus();
            }),
            
            // Docker commands
            vscode.commands.registerCommand('noodle.docker.showStatus', () => {
                this.ecosystemIntegration.getDeploymentAutomationScripts().showDockerStatus();
            }),
            
            vscode.commands.registerCommand('noodle.docker.buildImage', async () => {
                const imageName = await vscode.window.showInputBox({
                    prompt: 'Enter image name',
                    placeHolder: 'my-app:latest'
                });
                if (imageName) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().buildDockerImage(imageName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.docker.runContainer', async () => {
                const imageName = await vscode.window.showInputBox({
                    prompt: 'Enter image name',
                    placeHolder: 'my-app:latest'
                });
                if (imageName) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().runDockerContainer(imageName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.docker.stopContainer', async () => {
                const containerId = await vscode.window.showInputBox({
                    prompt: 'Enter container ID or name',
                    placeHolder: 'container-id'
                });
                if (containerId) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().stopDockerContainer(containerId);
                }
            }),
            
            vscode.commands.registerCommand('noodle.docker.startContainer', async () => {
                const containerId = await vscode.window.showInputBox({
                    prompt: 'Enter container ID or name',
                    placeHolder: 'container-id'
                });
                if (containerId) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().startDockerContainer(containerId);
                }
            }),
            
            vscode.commands.registerCommand('noodle.docker.removeContainer', async () => {
                const containerId = await vscode.window.showInputBox({
                    prompt: 'Enter container ID or name',
                    placeHolder: 'container-id'
                });
                if (containerId) {
                    await this.ecosystemIntegration.getDeploymentAutomationScripts().removeDockerContainer(containerId);
                }
            }),
            
            // Kubernetes commands
            vscode.commands.registerCommand('noodle.kubernetes.showStatus', () => {
                this.ecosystemIntegration.getKubernetesIntegration().showStatus();
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.deploy', async () => {
                const manifestPath = await vscode.window.showInputBox({
                    prompt: 'Enter manifest file path',
                    placeHolder: './k8s/deployment.yaml'
                });
                if (manifestPath) {
                    await this.ecosystemIntegration.getKubernetesIntegration().deploy(manifestPath);
                }
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.scale', async () => {
                const deploymentName = await vscode.window.showInputBox({
                    prompt: 'Enter deployment name',
                    placeHolder: 'my-app'
                });
                if (deploymentName) {
                    const replicas = await vscode.window.showInputBox({
                        prompt: 'Enter number of replicas',
                        placeHolder: '3'
                    });
                    if (replicas) {
                        await this.ecosystemIntegration.getKubernetesIntegration().scale(deploymentName, parseInt(replicas));
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.getLogs', async () => {
                const podName = await vscode.window.showInputBox({
                    prompt: 'Enter pod name',
                    placeHolder: 'my-app-pod-12345'
                });
                if (podName) {
                    await this.ecosystemIntegration.getKubernetesIntegration().getLogs(podName);
                }
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.deleteResource', async () => {
                const resourceType = await vscode.window.showQuickPick([
                    'pod',
                    'deployment',
                    'service',
                    'ingress'
                ], {
                    placeHolder: 'Select resource type'
                });
                if (resourceType) {
                    const resourceName = await vscode.window.showInputBox({
                        prompt: `Enter ${resourceType} name`,
                        placeHolder: 'my-resource'
                    });
                    if (resourceName) {
                        await this.ecosystemIntegration.getKubernetesIntegration().deleteResource(resourceType, resourceName);
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.portForward', async () => {
                const podName = await vscode.window.showInputBox({
                    prompt: 'Enter pod name',
                    placeHolder: 'my-app-pod-12345'
                });
                if (podName) {
                    const localPort = await vscode.window.showInputBox({
                        prompt: 'Enter local port',
                        placeHolder: '8080'
                    });
                    if (localPort) {
                        const remotePort = await vscode.window.showInputBox({
                            prompt: 'Enter remote port',
                            placeHolder: '80'
                        });
                        if (remotePort) {
                            await this.ecosystemIntegration.getKubernetesIntegration().portForward(podName, parseInt(localPort), parseInt(remotePort));
                        }
                    }
                }
            }),
            
            vscode.commands.registerCommand('noodle.kubernetes.createManifest', async () => {
                const resourceType = await vscode.window.showQuickPick([
                    'deployment',
                    'service',
                    'ingress',
                    'configmap',
                    'secret'
                ], {
                    placeHolder: 'Select resource type'
                });
                if (resourceType) {
                    await this.ecosystemIntegration.getKubernetesIntegration().createManifest(resourceType);
                }
            })
        ];
        
        // Register all commands
        disposables.forEach(disposable => {
            this.context.subscriptions.push(disposable);
        });
        
        this.outputChannel.appendLine(`Registered ${disposables.length} commands`);
    }

    /**
     * Show the AI chat panel
     */
    private async showChatPanel(): Promise<void> {
        try {
            if (!this.chatPanel) {
                this.chatPanel = new AIChatPanel(this.context, this.backendService);
            }
            await this.chatPanel.show();
        } catch (error) {
            this.outputChannel.appendLine(`Failed to show chat panel: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show chat panel: ${error.message}`);
        }
    }

    /**
     * Register event listeners
     */
    private async registerEventListeners(): Promise<void> {
        this.outputChannel.appendLine('Registering event listeners...');
        
        // Configuration changes
        vscode.workspace.onDidChangeConfiguration(async (event) => {
            if (event.affectsConfiguration('noodle')) {
                this.outputChannel.appendLine('Configuration changed, reloading...');
                // Handle configuration changes
            }
        });
        
        // Document changes
        vscode.workspace.onDidChangeTextDocument((event) => {
            // Handle document changes
        });
        
        // Active editor changes
        vscode.window.onDidChangeActiveTextEditor((event) => {
            // Handle editor changes
        });
        
        // Workspace changes
        vscode.workspace.onDidChangeWorkspaceFolders(() => {
            // Handle workspace changes
        });
        
        this.outputChannel.appendLine('Event listeners registered');
    }

    /**
     * Update status bar
     */
    private updateStatusBar(): void {
        const services = this.ecosystemIntegration.getServiceManager().getServices();
        const activeServices = services.filter(s => s.status === 'running').length;
        
        let text = `$(plug) Ecosystem`;
        if (activeServices > 0) {
            text += ` 🟢${activeServices}`;
        }
        
        if (!this.statusBarItem) {
            this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Right, 100);
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Ecosystem: ${activeServices} active services`;
        this.statusBarItem.show();
    }

    /**
     * Show status
     */
    public async showStatus(): Promise<void> {
        try {
            const services = this.ecosystemIntegration.getServiceManager().getServices();
            const activeServices = services.filter(s => s.status === 'running').length;
            
            let output = `Ecosystem Status\n`;
            output += `================================\n\n`;
            
            output += `Services (${services.length} total)\n`;
            output += `Active: ${activeServices} / ${services.length}\n`;
            output += `================================\n\n`;
            
            // Service details
            for (const service of services) {
                const statusIcon = service.status === 'running' ? '🟢' :
                                 service.status === 'starting' ? '🟡' : '🔴';
                output += `  ${statusIcon} ${service.config.name}: ${service.status}\n`;
                output += `    Status: ${service.status}\n`;
                if (service.status.startTime) {
                    const uptime = Date.now() - service.status.startTime;
                    output += `    Uptime: ${Math.round(uptime / 1000)}s\n`;
                }
                if (service.status.lastError) {
                    output += `    Last Error: ${service.status.lastError}\n`;
                }
                output += '\n';
            }
            
            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            this.outputChannel.appendLine(`Failed to show status: ${error.message}`);
            throw error;
        }
    }

    /**
     * Dispose extension
     */
    public dispose(): void {
        // Dispose UI components
        if (this.welcomeProvider) this.welcomeProvider.dispose();
        if (this.treeProvider) this.treeProvider.dispose();
        if (this.statusBar) this.statusBar.dispose();
        if (this.statusBarItem) this.statusBarItem.dispose();
        
        // Dispose infrastructure
        if (this.ecosystemIntegration) this.ecosystemIntegration.dispose();
        
        // Dispose core services
        if (this.aiAssistant) this.aiAssistant.dispose();
        if (this.lspManager) this.lspManager.dispose();
        
        // Dispose output channel
        if (this.outputChannel) this.outputChannel.dispose();
        
        this.removeAllListeners();
    }
}

// Export extension
export async function activate(context: vscode.ExtensionContext): Promise<void> {
    const extension = new NoodleExtension();
    extension.context = context;
    await extension.activate();
}

export function deactivate(): void {
    // Cleanup will be handled by the extension's dispose method
}