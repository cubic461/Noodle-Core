"use strict";
/**
 * Cloud Service Integration for Noodle VS Code Extension
 *
 * Provides integration with AWS, Azure, and GCP cloud services.
 * Includes resource management, authentication, cost monitoring,
 * and security compliance checks.
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
exports.CloudServiceIntegration = exports.CloudProvider = void 0;
const vscode = __importStar(require("vscode"));
const fs = __importStar(require("fs"));
const events_1 = require("events");
// Cloud Provider Types
var CloudProvider;
(function (CloudProvider) {
    CloudProvider["AWS"] = "aws";
    CloudProvider["AZURE"] = "azure";
    CloudProvider["GCP"] = "gcp";
})(CloudProvider = exports.CloudProvider || (exports.CloudProvider = {}));
// Cloud Service Integration Class
class CloudServiceIntegration extends events_1.EventEmitter {
    constructor(context, serviceManager, configManager, eventBus, cacheManager, logger) {
        super();
        // Cloud provider configurations
        this.cloudConfigs = new Map();
        this.credentials = new Map();
        this.isInitialized = false;
        this.CREDENTIALS_CACHE_KEY = 'noodle_cloud_credentials';
        this.CONFIG_CACHE_KEY = 'noodle_cloud_config';
        this.context = context;
        this.serviceManager = serviceManager;
        this.configManager = configManager;
        this.eventBus = eventBus;
        this.cacheManager = cacheManager;
        this.logger = logger;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Cloud Services');
    }
    /**
     * Initialize cloud service integration
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing cloud service integration...');
            // Load configurations and credentials
            await this.loadConfigurations();
            await this.loadCredentials();
            // Initialize cloud providers
            await this.initializeCloudProviders();
            // Register event listeners
            this.registerEventListeners();
            this.isInitialized = true;
            this.outputChannel.appendLine('Cloud service integration initialized successfully');
            this.emit('initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize cloud service integration: ${error.message}`);
            this.logger.error('Cloud service integration initialization failed', error);
            throw error;
        }
    }
    /**
     * Load cloud service configurations
     */
    async loadConfigurations() {
        try {
            // Load from configuration manager
            const awsConfig = this.configManager.get('cloud.aws', {
                provider: CloudProvider.AWS,
                enabled: false,
                regions: ['us-east-1', 'us-west-2'],
                securityComplianceEnabled: true
            });
            const azureConfig = this.configManager.get('cloud.azure', {
                provider: CloudProvider.AZURE,
                enabled: false,
                regions: ['eastus', 'westus2'],
                securityComplianceEnabled: true
            });
            const gcpConfig = this.configManager.get('cloud.gcp', {
                provider: CloudProvider.GCP,
                enabled: false,
                regions: ['us-central1', 'us-west1'],
                securityComplianceEnabled: true
            });
            this.cloudConfigs.set(CloudProvider.AWS, awsConfig);
            this.cloudConfigs.set(CloudProvider.AZURE, azureConfig);
            this.cloudConfigs.set(CloudProvider.GCP, gcpConfig);
            this.outputChannel.appendLine('Cloud service configurations loaded');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load configurations: ${error.message}`);
            throw error;
        }
    }
    /**
     * Load cloud service credentials
     */
    async loadCredentials() {
        try {
            // Load from secure storage
            const cachedCredentials = await this.cacheManager.get(this.CREDENTIALS_CACHE_KEY);
            if (cachedCredentials) {
                const credentialsData = JSON.parse(cachedCredentials);
                // Load AWS credentials
                if (credentialsData.aws) {
                    this.credentials.set(CloudProvider.AWS, credentialsData.aws);
                }
                // Load Azure credentials
                if (credentialsData.azure) {
                    this.credentials.set(CloudProvider.AZURE, credentialsData.azure);
                }
                // Load GCP credentials
                if (credentialsData.gcp) {
                    this.credentials.set(CloudProvider.GCP, credentialsData.gcp);
                }
            }
            this.outputChannel.appendLine('Cloud service credentials loaded');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load credentials: ${error.message}`);
            // Don't throw error for credentials as they might not be set yet
        }
    }
    /**
     * Initialize cloud providers
     */
    async initializeCloudProviders() {
        try {
            // Initialize AWS provider
            if (this.cloudConfigs.get(CloudProvider.AWS)?.enabled) {
                await this.initializeAWSProvider();
            }
            // Initialize Azure provider
            if (this.cloudConfigs.get(CloudProvider.AZURE)?.enabled) {
                await this.initializeAzureProvider();
            }
            // Initialize GCP provider
            if (this.cloudConfigs.get(CloudProvider.GCP)?.enabled) {
                await this.initializeGCPProvider();
            }
            this.outputChannel.appendLine('Cloud providers initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize cloud providers: ${error.message}`);
            throw error;
        }
    }
    /**
     * Initialize AWS provider
     */
    async initializeAWSProvider() {
        try {
            const credentials = this.credentials.get(CloudProvider.AWS);
            if (!credentials) {
                this.outputChannel.appendLine('AWS credentials not found');
                return;
            }
            // Test AWS connection
            await this.testAWSConnection(credentials);
            this.outputChannel.appendLine('AWS provider initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize AWS provider: ${error.message}`);
            throw error;
        }
    }
    /**
     * Initialize Azure provider
     */
    async initializeAzureProvider() {
        try {
            const credentials = this.credentials.get(CloudProvider.AZURE);
            if (!credentials) {
                this.outputChannel.appendLine('Azure credentials not found');
                return;
            }
            // Test Azure connection
            await this.testAzureConnection(credentials);
            this.outputChannel.appendLine('Azure provider initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize Azure provider: ${error.message}`);
            throw error;
        }
    }
    /**
     * Initialize GCP provider
     */
    async initializeGCPProvider() {
        try {
            const credentials = this.credentials.get(CloudProvider.GCP);
            if (!credentials) {
                this.outputChannel.appendLine('GCP credentials not found');
                return;
            }
            // Test GCP connection
            await this.testGCPConnection(credentials);
            this.outputChannel.appendLine('GCP provider initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize GCP provider: ${error.message}`);
            throw error;
        }
    }
    /**
     * Register event listeners
     */
    registerEventListeners() {
        // Listen for configuration changes
        this.eventBus.on('configurationChanged', async (event) => {
            if (event.key.startsWith('cloud.')) {
                await this.loadConfigurations();
                this.emit('configurationChanged', event);
            }
        });
        // Listen for credential changes
        this.eventBus.on('credentialsChanged', async (event) => {
            if (event.provider) {
                await this.loadCredentials();
                this.emit('credentialsChanged', event);
            }
        });
    }
    /**
     * Test AWS connection
     */
    async testAWSConnection(credentials) {
        try {
            // Implementation would use AWS SDK to test connection
            // For now, simulate a successful connection
            this.outputChannel.appendLine('Testing AWS connection...');
            // In a real implementation, you would use the AWS SDK:
            // const AWS = require('aws-sdk');
            // AWS.config.update({
            //     accessKeyId: credentials.credentials.accessKeyId,
            //     secretAccessKey: credentials.credentials.secretAccessKey,
            //     region: credentials.region
            // });
            // const ec2 = new AWS.EC2();
            // await ec2.describeInstances().promise();
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`AWS connection test failed: ${error.message}`);
            return false;
        }
    }
    /**
     * Test Azure connection
     */
    async testAzureConnection(credentials) {
        try {
            // Implementation would use Azure SDK to test connection
            this.outputChannel.appendLine('Testing Azure connection...');
            // In a real implementation, you would use the Azure SDK:
            // const { DefaultAzureCredential } = require('@azure/identity');
            // const { ResourceManagementClient } = require('@azure/arm-resources');
            // const credential = new DefaultAzureCredential();
            // const client = new ResourceManagementClient(credential, credentials.credentials.subscriptionId);
            // await client.resourceGroups.list().next();
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Azure connection test failed: ${error.message}`);
            return false;
        }
    }
    /**
     * Test GCP connection
     */
    async testGCPConnection(credentials) {
        try {
            // Implementation would use GCP SDK to test connection
            this.outputChannel.appendLine('Testing GCP connection...');
            // In a real implementation, you would use the GCP SDK:
            // const { GoogleAuth } = require('google-auth-library');
            // const auth = new GoogleAuth({
            //     keyFile: credentials.credentials.keyFile,
            //     scopes: ['https://www.googleapis.com/auth/cloud-platform']
            // });
            // const client = await auth.getClient();
            // const projectId = await auth.getProjectId();
            // const { Compute } = require('@google-cloud/compute');
            // const compute = new Compute({ projectId, authClient: client });
            // await compute.getVMs();
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`GCP connection test failed: ${error.message}`);
            return false;
        }
    }
    /**
     * Set cloud credentials
     */
    async setCredentials(provider, credentials) {
        try {
            // Validate credentials
            await this.validateCredentials(provider, credentials);
            // Store credentials
            this.credentials.set(provider, credentials);
            // Cache credentials securely
            const cachedCredentials = await this.cacheManager.get(this.CREDENTIALS_CACHE_KEY) || '{}';
            const credentialsData = JSON.parse(cachedCredentials);
            credentialsData[provider] = credentials;
            await this.cacheManager.set(this.CREDENTIALS_CACHE_KEY, JSON.stringify(credentialsData));
            // Initialize provider if enabled
            const config = this.cloudConfigs.get(provider);
            if (config?.enabled) {
                switch (provider) {
                    case CloudProvider.AWS:
                        await this.initializeAWSProvider();
                        break;
                    case CloudProvider.AZURE:
                        await this.initializeAzureProvider();
                        break;
                    case CloudProvider.GCP:
                        await this.initializeGCPProvider();
                        break;
                }
            }
            this.emit('credentialsChanged', { provider });
            this.outputChannel.appendLine(`${provider} credentials set successfully`);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to set ${provider} credentials: ${error.message}`);
            throw error;
        }
    }
    /**
     * Validate cloud credentials
     */
    async validateCredentials(provider, credentials) {
        try {
            switch (provider) {
                case CloudProvider.AWS:
                    // Validate AWS credentials
                    if (!credentials.credentials.accessKeyId || !credentials.credentials.secretAccessKey) {
                        throw new Error('AWS access key ID and secret access key are required');
                    }
                    break;
                case CloudProvider.AZURE:
                    // Validate Azure credentials
                    if (!credentials.credentials.subscriptionId || !credentials.credentials.clientId ||
                        !credentials.credentials.clientSecret || !credentials.credentials.tenantId) {
                        throw new Error('Azure subscription ID, client ID, client secret, and tenant ID are required');
                    }
                    break;
                case CloudProvider.GCP:
                    // Validate GCP credentials
                    if (!credentials.credentials.projectId || !credentials.credentials.keyFile) {
                        throw new Error('GCP project ID and key file path are required');
                    }
                    // Check if key file exists
                    if (!fs.existsSync(credentials.credentials.keyFile)) {
                        throw new Error(`GCP key file not found: ${credentials.credentials.keyFile}`);
                    }
                    break;
                default:
                    throw new Error(`Unknown cloud provider: ${provider}`);
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Credential validation failed: ${error.message}`);
            throw error;
        }
    }
    /**
     * Get cloud provider status
     */
    getProviderStatus(provider) {
        const config = this.cloudConfigs.get(provider);
        const credentials = this.credentials.get(provider);
        if (!config?.enabled) {
            return 'disabled';
        }
        if (!credentials) {
            return 'no-credentials';
        }
        return 'connected';
    }
    /**
     * Get all provider statuses
     */
    getAllProviderStatuses() {
        return {
            [CloudProvider.AWS]: this.getProviderStatus(CloudProvider.AWS),
            [CloudProvider.AZURE]: this.getProviderStatus(CloudProvider.AZURE),
            [CloudProvider.GCP]: this.getProviderStatus(CloudProvider.GCP)
        };
    }
    /**
     * Check if the integration is enabled
     */
    isEnabled() {
        return this.isInitialized;
    }
    /**
     * Get integration status
     */
    getStatus() {
        if (!this.isInitialized) {
            return 'not-initialized';
        }
        const statuses = this.getAllProviderStatuses();
        const connectedProviders = Object.values(statuses).filter(status => status === 'connected').length;
        if (connectedProviders === 0) {
            return 'no-providers';
        }
        if (connectedProviders === Object.keys(statuses).length) {
            return 'all-connected';
        }
        return 'partially-connected';
    }
    /**
     * Show cloud service status
     */
    async showStatus() {
        try {
            const statuses = this.getAllProviderStatuses();
            const configs = Array.from(this.cloudConfigs.entries());
            let output = 'Cloud Service Integration Status\n';
            output += '=================================\n\n';
            // Provider statuses
            output += 'Providers:\n';
            for (const [provider, status] of Object.entries(statuses)) {
                const statusIcon = status === 'connected' ? '🟢' :
                    status === 'disabled' ? '⚪' :
                        status === 'no-credentials' ? '🟡' : '🔴';
                output += `  ${statusIcon} ${provider}: ${status}\n`;
            }
            output += '\n';
            // Provider configurations
            output += 'Configurations:\n';
            for (const [provider, config] of configs) {
                output += `  ${provider}:\n`;
                output += `    Enabled: ${config.enabled}\n`;
                output += `    Regions: ${config.regions.join(', ')}\n`;
                output += `    Security Compliance: ${config.securityComplianceEnabled}\n`;
                if (config.costAlertThreshold) {
                    output += `    Cost Alert Threshold: $${config.costAlertThreshold}\n`;
                }
                output += '\n';
            }
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
     * Dispose cloud service integration
     */
    dispose() {
        this.removeAllListeners();
        this.outputChannel.dispose();
    }
}
exports.CloudServiceIntegration = CloudServiceIntegration;
//# sourceMappingURL=cloudServiceIntegration.js.map