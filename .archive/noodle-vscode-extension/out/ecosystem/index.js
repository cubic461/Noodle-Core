"use strict";
/**
 * Ecosystem Integration Index for Noodle VS Code Extension
 *
 * Main entry point for ecosystem integration with external tools and services.
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
exports.EcosystemIntegration = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
// Import infrastructure components
const serviceManager_1 = require("../infrastructure/serviceManager");
const ConfigurationManager_1 = require("../infrastructure/ConfigurationManager");
const EventBus_1 = require("../infrastructure/EventBus");
const CacheManager_1 = require("../infrastructure/CacheManager");
const LoggingMonitoring_1 = require("../infrastructure/LoggingMonitoring");
// Import ecosystem components
const gitIntegration_1 = require("./gitIntegration");
const githubApiConnectors_1 = require("./githubApiConnectors");
const cicdIntegration_1 = require("./cicdIntegration");
const monitoringSystemAdapters_1 = require("./monitoringSystemAdapters");
const externalToolAuthentication_1 = require("./externalToolAuthentication");
const crossPlatformCompatibility_1 = require("./crossPlatformCompatibility");
const pluginMarketplaceIntegration_1 = require("./pluginMarketplaceIntegration");
const deploymentAutomationScripts_1 = require("./deploymentAutomationScripts");
const externalServiceHealthMonitoring_1 = require("./externalServiceHealthMonitoring");
const ecosystemConfigurationManagement_1 = require("./ecosystemConfigurationManagement");
const kubernetesIntegration_1 = require("./kubernetesIntegration");
class EcosystemIntegration extends events_1.EventEmitter {
    constructor(context) {
        super();
        this.isInitialized = false;
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Ecosystem');
    }
    /**
     * Initialize ecosystem integration
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing ecosystem integration...');
            // Initialize infrastructure components
            await this.initializeInfrastructure();
            // Initialize ecosystem components
            await this.initializeEcosystemComponents();
            this.isInitialized = true;
            this.outputChannel.appendLine('Ecosystem integration initialized successfully');
            this.emit('initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize ecosystem integration: ${error.message}`);
            throw error;
        }
    }
    /**
     * Initialize infrastructure components
     */
    async initializeInfrastructure() {
        try {
            // Initialize service manager
            this.serviceManager = new serviceManager_1.ServiceManager(this.context);
            await this.serviceManager.initialize();
            // Initialize configuration manager
            this.configManager = new ConfigurationManager_1.ConfigurationManager(this.context);
            await this.configManager.initialize();
            // Initialize event bus
            this.eventBus = new EventBus_1.EventBus();
            this.eventBus.initialize();
            // Initialize cache manager
            this.cacheManager = new CacheManager_1.CacheManager(this.context);
            await this.cacheManager.initialize();
            // Initialize logger
            this.logger = new LoggingMonitoring_1.Logger(this.context);
            await this.logger.initialize();
            this.outputChannel.appendLine('Infrastructure components initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize infrastructure: ${error.message}`);
            throw error;
        }
    }
    /**
     * Initialize ecosystem components
     */
    async initializeEcosystemComponents() {
        try {
            // Initialize Git integration
            this.gitIntegration = new gitIntegration_1.GitIntegrationAdapters(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.gitIntegration.initialize();
            // Initialize GitHub API connectors
            this.githubApiConnectors = new githubApiConnectors_1.GitHubApiConnectors(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.githubApiConnectors.initialize();
            // Initialize CI/CD integration
            this.cicdIntegration = new cicdIntegration_1.CICDPipelineIntegration(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.cicdIntegration.initialize();
            // Initialize monitoring system adapters
            this.monitoringSystemAdapters = new monitoringSystemAdapters_1.MonitoringSystemAdapters(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.monitoringSystemAdapters.initialize();
            // Initialize external tool authentication
            this.externalToolAuthentication = new externalToolAuthentication_1.ExternalToolAuthentication(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.externalToolAuthentication.initialize();
            // Initialize cross-platform compatibility
            this.crossPlatformCompatibility = new crossPlatformCompatibility_1.CrossPlatformCompatibility(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.crossPlatformCompatibility.initialize();
            // Initialize plugin marketplace integration
            this.pluginMarketplaceIntegration = new pluginMarketplaceIntegration_1.PluginMarketplaceIntegration(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.pluginMarketplaceIntegration.initialize();
            // Initialize deployment automation scripts
            this.deploymentAutomationScripts = new deploymentAutomationScripts_1.DeploymentAutomationScripts(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.deploymentAutomationScripts.initialize();
            // Initialize external service health monitoring
            this.externalServiceHealthMonitoring = new externalServiceHealthMonitoring_1.ExternalServiceHealthMonitoring(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.externalServiceHealthMonitoring.initialize();
            // Initialize ecosystem configuration management
            this.ecosystemConfigurationManagement = new ecosystemConfigurationManagement_1.EcosystemConfigurationManagement(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.ecosystemConfigurationManagement.initialize();
            // Initialize Kubernetes integration
            this.kubernetesIntegration = new kubernetesIntegration_1.KubernetesIntegration(this.context, this.serviceManager, this.configManager, this.eventBus, this.cacheManager, this.logger);
            await this.kubernetesIntegration.initialize();
            // Set Kubernetes integration reference in deployment automation scripts
            this.deploymentAutomationScripts.setKubernetesIntegration(this.kubernetesIntegration);
            this.outputChannel.appendLine('Ecosystem components initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize ecosystem components: ${error.message}`);
            throw error;
        }
    }
    /**
     * Get service manager
     */
    getServiceManager() {
        return this.serviceManager;
    }
    /**
     * Get configuration manager
     */
    getConfigurationManager() {
        return this.configManager;
    }
    /**
     * Get event bus
     */
    getEventBus() {
        return this.eventBus;
    }
    /**
     * Get cache manager
     */
    getCacheManager() {
        return this.cacheManager;
    }
    /**
     * Get logger
     */
    getLogger() {
        return this.logger;
    }
    /**
     * Get Git integration
     */
    getGitIntegration() {
        return this.gitIntegration;
    }
    /**
     * Get GitHub API connectors
     */
    getGitHubApiConnectors() {
        return this.githubApiConnectors;
    }
    /**
     * Get CI/CD integration
     */
    getCICDIntegration() {
        return this.cicdIntegration;
    }
    /**
     * Get monitoring system adapters
     */
    getMonitoringSystemAdapters() {
        return this.monitoringSystemAdapters;
    }
    /**
     * Get external tool authentication
     */
    getExternalToolAuthentication() {
        return this.externalToolAuthentication;
    }
    /**
     * Get cross-platform compatibility
     */
    getCrossPlatformCompatibility() {
        return this.crossPlatformCompatibility;
    }
    /**
     * Get plugin marketplace integration
     */
    getPluginMarketplaceIntegration() {
        return this.pluginMarketplaceIntegration;
    }
    /**
     * Get deployment automation scripts
     */
    getDeploymentAutomationScripts() {
        return this.deploymentAutomationScripts;
    }
    /**
     * Get external service health monitoring
     */
    getHealthMonitoring() {
        return this.externalServiceHealthMonitoring;
    }
    /**
     * Get ecosystem configuration management
     */
    getConfigurationManagement() {
        return this.ecosystemConfigurationManagement;
    }
    /**
     * Get Kubernetes integration
     */
    getKubernetesIntegration() {
        return this.kubernetesIntegration;
    }
    /**
     * Get integrations
     */
    getIntegrations() {
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
    async showStatus() {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to show status: ${error.message}`);
            throw error;
        }
    }
    /**
     * Dispose ecosystem integration
     */
    dispose() {
        // Dispose ecosystem components
        if (this.gitIntegration)
            this.gitIntegration.dispose();
        if (this.githubApiConnectors)
            this.githubApiConnectors.dispose();
        if (this.cicdIntegration)
            this.cicdIntegration.dispose();
        if (this.monitoringSystemAdapters)
            this.monitoringSystemAdapters.dispose();
        if (this.externalToolAuthentication)
            this.externalToolAuthentication.dispose();
        if (this.crossPlatformCompatibility)
            this.crossPlatformCompatibility.dispose();
        if (this.pluginMarketplaceIntegration)
            this.pluginMarketplaceIntegration.dispose();
        if (this.deploymentAutomationScripts)
            this.deploymentAutomationScripts.dispose();
        if (this.externalServiceHealthMonitoring)
            this.externalServiceHealthMonitoring.dispose();
        if (this.ecosystemConfigurationManagement)
            this.ecosystemConfigurationManagement.dispose();
        if (this.kubernetesIntegration)
            this.kubernetesIntegration.dispose();
        // Dispose infrastructure components
        if (this.serviceManager)
            this.serviceManager.dispose();
        if (this.configManager)
            this.configManager.dispose();
        if (this.eventBus)
            this.eventBus.dispose();
        if (this.cacheManager)
            this.cacheManager.dispose();
        if (this.logger)
            this.logger.dispose();
        // Dispose output channel
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.EcosystemIntegration = EcosystemIntegration;
//# sourceMappingURL=index.js.map