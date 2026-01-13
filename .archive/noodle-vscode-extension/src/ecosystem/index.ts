/**
 * Ecosystem Integration Index for Noodle VS Code Extension
 * 
 * Main entry point for ecosystem integration with external tools and services.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';

// Import infrastructure components
import { ServiceManager } from '../infrastructure/serviceManager';
import { ConfigurationManager } from '../infrastructure/ConfigurationManager';
import { EventBus } from '../infrastructure/EventBus';
import { CacheManager } from '../infrastructure/CacheManager';
import { Logger } from '../infrastructure/LoggingMonitoring';

// Import ecosystem components
import { GitIntegrationAdapters } from './gitIntegration';
import { GitHubApiConnectors } from './githubApiConnectors';
import { CICDPipelineIntegration } from './cicdIntegration';
import { MonitoringSystemAdapters } from './monitoringSystemAdapters';
import { ExternalToolAuthentication } from './externalToolAuthentication';
import { CrossPlatformCompatibility } from './crossPlatformCompatibility';
import { PluginMarketplaceIntegration } from './pluginMarketplaceIntegration';
import { DeploymentAutomationScripts } from './deploymentAutomationScripts';
import { ExternalServiceHealthMonitoring } from './externalServiceHealthMonitoring';
import { EcosystemConfigurationManagement } from './ecosystemConfigurationManagement';
import { KubernetesIntegration } from './kubernetesIntegration';

export class EcosystemIntegration extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    
    // Infrastructure components
    private serviceManager: ServiceManager;
    private configManager: ConfigurationManager;
    private eventBus: EventBus;
    private cacheManager: CacheManager;
    private logger: Logger;
    
    // Ecosystem components
    private gitIntegration: GitIntegrationAdapters;
    private githubApiConnectors: GitHubApiConnectors;
    private cicdIntegration: CICDPipelineIntegration;
    private monitoringSystemAdapters: MonitoringSystemAdapters;
    private externalToolAuthentication: ExternalToolAuthentication;
    private crossPlatformCompatibility: CrossPlatformCompatibility;
    private pluginMarketplaceIntegration: PluginMarketplaceIntegration;
    private deploymentAutomationScripts: DeploymentAutomationScripts;
    private externalServiceHealthMonitoring: ExternalServiceHealthMonitoring;
    private ecosystemConfigurationManagement: EcosystemConfigurationManagement;
    private kubernetesIntegration: KubernetesIntegration;
    
    private isInitialized = false;
    
    constructor(context: vscode.ExtensionContext) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Ecosystem');
    }
    
    /**
     * Initialize ecosystem integration
     */
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing ecosystem integration...');
            
            // Initialize infrastructure components
            await this.initializeInfrastructure();
            
            // Initialize ecosystem components
            await this.initializeEcosystemComponents();
            
            this.isInitialized = true;
            this.outputChannel.appendLine('Ecosystem integration initialized successfully');
            this.emit('initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize ecosystem integration: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize infrastructure components
     */
    private async initializeInfrastructure(): Promise<void> {
        try {
            // Initialize service manager
            this.serviceManager = new ServiceManager(this.context);
            await this.serviceManager.initialize();
            
            // Initialize configuration manager
            this.configManager = new ConfigurationManager(this.context);
            await this.configManager.initialize();
            
            // Initialize event bus
            this.eventBus = new EventBus();
            this.eventBus.initialize();
            
            // Initialize cache manager
            this.cacheManager = new CacheManager(this.context);
            await this.cacheManager.initialize();
            
            // Initialize logger
            this.logger = new Logger(this.context);
            await this.logger.initialize();
            
            this.outputChannel.appendLine('Infrastructure components initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize infrastructure: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Initialize ecosystem components
     */
    private async initializeEcosystemComponents(): Promise<void> {
        try {
            // Initialize Git integration
            this.gitIntegration = new GitIntegrationAdapters(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.gitIntegration.initialize();
            
            // Initialize GitHub API connectors
            this.githubApiConnectors = new GitHubApiConnectors(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.githubApiConnectors.initialize();
            
            // Initialize CI/CD integration
            this.cicdIntegration = new CICDPipelineIntegration(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.cicdIntegration.initialize();
            
            // Initialize monitoring system adapters
            this.monitoringSystemAdapters = new MonitoringSystemAdapters(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.monitoringSystemAdapters.initialize();
            
            // Initialize external tool authentication
            this.externalToolAuthentication = new ExternalToolAuthentication(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.externalToolAuthentication.initialize();
            
            // Initialize cross-platform compatibility
            this.crossPlatformCompatibility = new CrossPlatformCompatibility(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.crossPlatformCompatibility.initialize();
            
            // Initialize plugin marketplace integration
            this.pluginMarketplaceIntegration = new PluginMarketplaceIntegration(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.pluginMarketplaceIntegration.initialize();
            
            // Initialize deployment automation scripts
            this.deploymentAutomationScripts = new DeploymentAutomationScripts(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.deploymentAutomationScripts.initialize();
            
            // Initialize external service health monitoring
            this.externalServiceHealthMonitoring = new ExternalServiceHealthMonitoring(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.externalServiceHealthMonitoring.initialize();
            
            // Initialize ecosystem configuration management
            this.ecosystemConfigurationManagement = new EcosystemConfigurationManagement(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.ecosystemConfigurationManagement.initialize();
            
            // Initialize Kubernetes integration
            this.kubernetesIntegration = new KubernetesIntegration(
                this.context,
                this.serviceManager,
                this.configManager,
                this.eventBus,
                this.cacheManager,
                this.logger
            );
            await this.kubernetesIntegration.initialize();
            
            // Set Kubernetes integration reference in deployment automation scripts
            this.deploymentAutomationScripts.setKubernetesIntegration(this.kubernetesIntegration);
            
            this.outputChannel.appendLine('Ecosystem components initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize ecosystem components: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Get service manager
     */
    public getServiceManager(): ServiceManager {
        return this.serviceManager;
    }
    
    /**
     * Get configuration manager
     */
    public getConfigurationManager(): ConfigurationManager {
        return this.configManager;
    }
    
    /**
     * Get event bus
     */
    public getEventBus(): EventBus {
        return this.eventBus;
    }
    
    /**
     * Get cache manager
     */
    public getCacheManager(): CacheManager {
        return this.cacheManager;
    }
    
    /**
     * Get logger
     */
    public getLogger(): Logger {
        return this.logger;
    }
    
    /**
     * Get Git integration
     */
    public getGitIntegration(): GitIntegrationAdapters {
        return this.gitIntegration;
    }
    
    /**
     * Get GitHub API connectors
     */
    public getGitHubApiConnectors(): GitHubApiConnectors {
        return this.githubApiConnectors;
    }
    
    /**
     * Get CI/CD integration
     */
    public getCICDIntegration(): CICDPipelineIntegration {
        return this.cicdIntegration;
    }
    
    /**
     * Get monitoring system adapters
     */
    public getMonitoringSystemAdapters(): MonitoringSystemAdapters {
        return this.monitoringSystemAdapters;
    }
    
    /**
     * Get external tool authentication
     */
    public getExternalToolAuthentication(): ExternalToolAuthentication {
        return this.externalToolAuthentication;
    }
    
    /**
     * Get cross-platform compatibility
     */
    public getCrossPlatformCompatibility(): CrossPlatformCompatibility {
        return this.crossPlatformCompatibility;
    }
    
    /**
     * Get plugin marketplace integration
     */
    public getPluginMarketplaceIntegration(): PluginMarketplaceIntegration {
        return this.pluginMarketplaceIntegration;
    }
    
    /**
     * Get deployment automation scripts
     */
    public getDeploymentAutomationScripts(): DeploymentAutomationScripts {
        return this.deploymentAutomationScripts;
    }
    
    /**
     * Get external service health monitoring
     */
    public getHealthMonitoring(): ExternalServiceHealthMonitoring {
        return this.externalServiceHealthMonitoring;
    }
    
    /**
     * Get ecosystem configuration management
     */
    public getConfigurationManagement(): EcosystemConfigurationManagement {
        return this.ecosystemConfigurationManagement;
    }
    
    /**
     * Get Kubernetes integration
     */
    public getKubernetesIntegration(): KubernetesIntegration {
        return this.kubernetesIntegration;
    }
    
    /**
     * Get integrations
     */
    public getIntegrations(): any[] {
        return [
            {
                id: 'git',
                name: 'Git Integration',
                enabled: this.gitIntegration.isEnabled(),
                status: this.gitIntegration.getStatus()
            },
            {
                id: 'github',
                name: 'GitHub API',
                enabled: this.githubApiConnectors.isEnabled(),
                status: this.githubApiConnectors.getStatus()
            },
            {
                id: 'cicd',
                name: 'CI/CD Pipeline',
                enabled: this.cicdIntegration.isEnabled(),
                status: this.cicdIntegration.getStatus()
            },
            {
                id: 'monitoring',
                name: 'Monitoring Systems',
                enabled: this.monitoringSystemAdapters.isEnabled(),
                status: this.monitoringSystemAdapters.getStatus()
            },
            {
                id: 'auth',
                name: 'External Authentication',
                enabled: this.externalToolAuthentication.isEnabled(),
                status: this.externalToolAuthentication.getStatus()
            },
            {
                id: 'crossPlatform',
                name: 'Cross-Platform Compatibility',
                enabled: this.crossPlatformCompatibility.isEnabled(),
                status: this.crossPlatformCompatibility.getStatus()
            },
            {
                id: 'marketplace',
                name: 'Plugin Marketplace',
                enabled: this.pluginMarketplaceIntegration.isEnabled(),
                status: this.pluginMarketplaceIntegration.getStatus()
            },
            {
                id: 'deployment',
                name: 'Deployment Automation',
                enabled: this.deploymentAutomationScripts.isEnabled(),
                status: this.deploymentAutomationScripts.getStatus()
            },
            {
                id: 'healthMonitoring',
                name: 'Health Monitoring',
                enabled: this.externalServiceHealthMonitoring.isEnabled(),
                status: this.externalServiceHealthMonitoring.getStatus()
            },
            {
                id: 'configuration',
                name: 'Configuration Management',
                enabled: this.ecosystemConfigurationManagement.isEnabled(),
                status: this.ecosystemConfigurationManagement.getStatus()
            },
            {
                id: 'kubernetes',
                name: 'Kubernetes Integration',
                enabled: this.kubernetesIntegration.isEnabled(),
                status: this.kubernetesIntegration.getStatus()
            }
        ];
    }
    
    /**
     * Show status
     */
    public async showStatus(): Promise<void> {
        try {
            const integrations = this.getIntegrations();
            const activeIntegrations = integrations.filter(i => i.enabled).length;
            const totalIntegrations = integrations.length;
            
            let output = 'Ecosystem Integration Status\n';
            output += '================================\n\n';
            
            output += `Integrations (${activeIntegrations} / ${totalIntegrations})\n`;
            output += `Active: ${activeIntegrations} / ${totalIntegrations}\n`;
            output += '================================\n\n';
            
            // Integration details
            for (const integration of integrations) {
                const statusIcon = integration.status === 'healthy' ? '🟢' : 
                                  integration.status === 'degraded' ? '🟡' : '🔴';
                output += `  ${statusIcon} ${integration.name}: ${integration.status}\n`;
                output += `    Enabled: ${integration.enabled}\n`;
                output += `    Status: ${integration.status}\n`;
                output += '\n';
            }
            
            output += '================================\n';
            
            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            this.outputChannel.appendLine(`Failed to show status: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Dispose ecosystem integration
     */
    public dispose(): void {
        // Dispose ecosystem components
        if (this.gitIntegration) this.gitIntegration.dispose();
        if (this.githubApiConnectors) this.githubApiConnectors.dispose();
        if (this.cicdIntegration) this.cicdIntegration.dispose();
        if (this.monitoringSystemAdapters) this.monitoringSystemAdapters.dispose();
        if (this.externalToolAuthentication) this.externalToolAuthentication.dispose();
        if (this.crossPlatformCompatibility) this.crossPlatformCompatibility.dispose();
        if (this.pluginMarketplaceIntegration) this.pluginMarketplaceIntegration.dispose();
        if (this.deploymentAutomationScripts) this.deploymentAutomationScripts.dispose();
        if (this.externalServiceHealthMonitoring) this.externalServiceHealthMonitoring.dispose();
        if (this.ecosystemConfigurationManagement) this.ecosystemConfigurationManagement.dispose();
        if (this.kubernetesIntegration) this.kubernetesIntegration.dispose();
        
        // Dispose infrastructure components
        if (this.serviceManager) this.serviceManager.dispose();
        if (this.configManager) this.configManager.dispose();
        if (this.eventBus) this.eventBus.dispose();
        if (this.cacheManager) this.cacheManager.dispose();
        if (this.logger) this.logger.dispose();
        
        // Dispose output channel
        this.outputChannel.dispose();
        
        this.removeAllListeners();
    }
}