/**
 * NoodleCore Ecosystem Configuration Management
 * 
 * Provides comprehensive configuration management for the entire ecosystem
 * including external services, integrations, and environment-specific settings.
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';

export interface EcosystemConfig {
    id: string;
    name: string;
    version: string;
    description: string;
    environments: EnvironmentConfig[];
    services: ServiceConfig[];
    integrations: IntegrationConfig[];
    monitoring: MonitoringConfig;
    security: SecurityConfig;
    performance: PerformanceConfig;
    logging: LoggingConfig;
}

export interface EnvironmentConfig {
    id: string;
    name: string;
    type: 'development' | 'staging' | 'production' | 'testing';
    variables: { [key: string]: string };
    features: string[];
    limits: {
        maxMemory: number;
        maxCpu: number;
        maxConcurrentRequests: number;
        timeout: number;
    };
}

export interface ServiceConfig {
    id: string;
    name: string;
    type: 'api' | 'database' | 'cache' | 'storage' | 'message-queue' | 'external-api';
    endpoint: string;
    authentication: {
        type: 'none' | 'api-key' | 'oauth' | 'basic' | 'bearer';
        credentials?: { [key: string]: string };
    };
    healthCheck: {
        enabled: boolean;
        endpoint: string;
        interval: number;
        timeout: number;
        expectedStatus: number[];
    };
    rateLimit: {
        enabled: boolean;
        requests: number;
        window: number;
    };
    caching: {
        enabled: boolean;
        ttl: number;
        maxSize: number;
    };
}

export interface IntegrationConfig {
    id: string;
    name: string;
    type: 'git' | 'github' | 'gitlab' | 'docker' | 'kubernetes' | 'aws' | 'azure' | 'gcp';
    enabled: boolean;
    config: { [key: string]: any };
    auth: {
        type: 'none' | 'api-key' | 'oauth' | 'service-account';
        credentials?: { [key: string]: string };
    };
}

export interface MonitoringConfig {
    enabled: boolean;
    metrics: {
        enabled: boolean;
        endpoints: string[];
        interval: number;
        retention: number;
    };
    alerts: {
        enabled: boolean;
        channels: string[];
        webhook?: string;
        rules: AlertRule[];
    };
    tracing: {
        enabled: boolean;
        sampling: number;
        exporters: string[];
    };
}

export interface AlertRule {
    id: string;
    name: string;
    condition: string;
    threshold: number;
    severity: 'critical' | 'warning' | 'info';
    enabled: boolean;
}

export interface SecurityConfig {
    authentication: {
        enabled: boolean;
        method: 'jwt' | 'oauth' | 'api-key';
        tokenExpiry: number;
    };
    authorization: {
        enabled: boolean;
        roles: RoleConfig[];
    };
    encryption: {
        enabled: boolean;
        algorithm: 'aes-256' | 'rsa-2048' | 'ecdsa-p256';
        keyRotation: number;
    };
    audit: {
        enabled: boolean;
        level: 'none' | 'minimal' | 'normal' | 'verbose';
        retention: number;
    };
}

export interface RoleConfig {
    id: string;
    name: string;
    permissions: string[];
    resources: string[];
}

export interface PerformanceConfig {
    optimization: {
        enabled: boolean;
        caching: boolean;
        compression: boolean;
        minification: boolean;
    };
    limits: {
        maxMemory: number;
        maxCpu: number;
        maxConcurrentRequests: number;
        requestTimeout: number;
    };
    profiling: {
        enabled: boolean;
        sampling: number;
        retention: number;
    };
}

export interface LoggingConfig {
    level: 'debug' | 'info' | 'warn' | 'error';
    format: 'json' | 'text' | 'structured';
    outputs: LogOutput[];
    retention: number;
}

export interface LogOutput {
    type: 'console' | 'file' | 'remote' | 'elasticsearch';
    config: { [key: string]: any };
}

export class EcosystemConfigurationManagement {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private currentConfig: EcosystemConfig | null = null;
    private environments: Map<string, EnvironmentConfig> = new Map();
    private services: Map<string, ServiceConfig> = new Map();
    private integrations: Map<string, IntegrationConfig> = new Map();
    private context: vscode.ExtensionContext;
    private configFilePath: string;
    private backupConfigs: Map<string, EcosystemConfig> = new Map();

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Ecosystem Config');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            105
        );
        this.statusBarItem.command = 'noodle.config.showStatus';
        
        this.configFilePath = path.join(this.context.globalStorageUri.fsPath, 'ecosystem-config.yaml');
        this.initializeConfigurationManagement();
    }

    /**
     * Initialize configuration management
     */
    private async initializeConfigurationManagement(): Promise<void> {
        try {
            // Load existing configuration
            await this.loadConfiguration();
            
            // Initialize default configuration if none exists
            if (!this.currentConfig) {
                await this.createDefaultConfiguration();
            }
            
            // Load configuration components
            await this.loadEnvironments();
            await this.loadServices();
            await this.loadIntegrations();
            
            // Start configuration monitoring
            this.startConfigurationMonitoring();
            
            this.outputChannel.appendLine('Ecosystem configuration management initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Configuration management initialization failed: ${error.message}`);
        }
    }

    /**
     * Load ecosystem configuration
     */
    private async loadConfiguration(): Promise<void> {
        try {
            if (fs.existsSync(this.configFilePath)) {
                const configData = yaml.load(fs.readFileSync(this.configFilePath, 'utf8'));
                this.currentConfig = configData as EcosystemConfig;
                
                this.outputChannel.appendLine(`Loaded configuration: ${this.currentConfig.name} v${this.currentConfig.version}`);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load configuration: ${error.message}`);
        }
    }

    /**
     * Create default configuration
     */
    private async createDefaultConfiguration(): Promise<void> {
        const defaultConfig: EcosystemConfig = {
            id: 'default',
            name: 'Noodle Ecosystem',
            version: '1.0.0',
            description: 'Default Noodle ecosystem configuration',
            environments: [
                {
                    id: 'development',
                    name: 'Development',
                    type: 'development',
                    variables: {
                        NODE_ENV: 'development',
                        DEBUG: 'true',
                        LOG_LEVEL: 'debug'
                    },
                    features: ['debug-mode', 'hot-reload', 'dev-tools'],
                    limits: {
                        maxMemory: 2048,
                        maxCpu: 2,
                        maxConcurrentRequests: 10,
                        timeout: 30000
                    }
                },
                {
                    id: 'production',
                    name: 'Production',
                    type: 'production',
                    variables: {
                        NODE_ENV: 'production',
                        DEBUG: 'false',
                        LOG_LEVEL: 'info'
                    },
                    features: ['optimization', 'monitoring', 'security'],
                    limits: {
                        maxMemory: 8192,
                        maxCpu: 8,
                        maxConcurrentRequests: 100,
                        timeout: 5000
                    }
                }
            ],
            services: [],
            integrations: [],
            monitoring: {
                enabled: true,
                metrics: {
                    enabled: true,
                    endpoints: ['/metrics'],
                    interval: 30000,
                    retention: 86400000
                },
                alerts: {
                    enabled: true,
                    channels: ['console'],
                    rules: [
                        {
                            id: 'high-error-rate',
                            name: 'High Error Rate',
                            condition: 'error_rate > 0.1',
                            threshold: 0.1,
                            severity: 'critical',
                            enabled: true
                        }
                    ]
                },
                tracing: {
                    enabled: true,
                    sampling: 0.1,
                    exporters: ['console']
                }
            },
            security: {
                authentication: {
                    enabled: true,
                    method: 'jwt',
                    tokenExpiry: 7200
                },
                authorization: {
                    enabled: true,
                    roles: [
                        {
                            id: 'admin',
                            name: 'Administrator',
                            permissions: ['*'],
                            resources: ['*']
                        },
                        {
                            id: 'developer',
                            name: 'Developer',
                            permissions: ['read', 'write'],
                            resources: ['code', 'config']
                        }
                    ]
                },
                encryption: {
                    enabled: true,
                    algorithm: 'aes-256',
                    keyRotation: 86400
                },
                audit: {
                    enabled: true,
                    level: 'normal',
                    retention: 604800
                }
            },
            performance: {
                optimization: {
                    enabled: true,
                    caching: true,
                    compression: true,
                    minification: true
                },
                limits: {
                    maxMemory: 2048,
                    maxCpu: 4,
                    maxConcurrentRequests: 50,
                    requestTimeout: 10000
                },
                profiling: {
                    enabled: false,
                    sampling: 0.01,
                    retention: 86400000
                }
            },
            logging: {
                level: 'info',
                format: 'structured',
                outputs: [
                    {
                        type: 'console',
                        config: {}
                    }
                ],
                retention: 604800
            }
        };
        
        this.currentConfig = defaultConfig;
        await this.saveConfiguration();
        
        this.outputChannel.appendLine('Created default configuration');
    }

    /**
     * Save configuration
     */
    private async saveConfiguration(): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration to save');
            }
            
            // Create backup
            await this.createBackup();
            
            // Save configuration
            fs.writeFileSync(this.configFilePath, yaml.dump(this.currentConfig, { indent: 2 }));
            
            this.outputChannel.appendLine('Configuration saved successfully');
        } catch (error) {
            throw new Error(`Failed to save configuration: ${error.message}`);
        }
    }

    /**
     * Create configuration backup
     */
    private async createBackup(): Promise<void> {
        if (!this.currentConfig) {
            return;
        }
        
        const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
        const backupPath = path.join(
            this.context.globalStorageUri.fsPath,
            `backups/ecosystem-config-${timestamp}.yaml`
        );
        
        const backupDir = path.dirname(backupPath);
        if (!fs.existsSync(backupDir)) {
            fs.mkdirSync(backupDir, { recursive: true });
        }
        
        fs.writeFileSync(backupPath, yaml.dump(this.currentConfig, { indent: 2 }));
        
        // Keep only last 10 backups
        const backupDirFiles = fs.readdirSync(backupDir);
        const backupFiles = backupDirFiles
            .filter(file => file.startsWith('ecosystem-config-'))
            .sort()
            .reverse();
        
        if (backupFiles.length > 10) {
            for (let i = 10; i < backupFiles.length; i++) {
                fs.unlinkSync(path.join(backupDir, backupFiles[i]));
            }
        }
    }

    /**
     * Load environments
     */
    private async loadEnvironments(): Promise<void> {
        try {
            if (!this.currentConfig) {
                return;
            }
            
            for (const env of this.currentConfig.environments) {
                this.environments.set(env.id, env);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.environments.size} environments`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load environments: ${error.message}`);
        }
    }

    /**
     * Load services
     */
    private async loadServices(): Promise<void> {
        try {
            if (!this.currentConfig) {
                return;
            }
            
            for (const service of this.currentConfig.services) {
                this.services.set(service.id, service);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.services.size} services`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load services: ${error.message}`);
        }
    }

    /**
     * Load integrations
     */
    private async loadIntegrations(): Promise<void> {
        try {
            if (!this.currentConfig) {
                return;
            }
            
            for (const integration of this.currentConfig.integrations) {
                this.integrations.set(integration.id, integration);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.integrations.size} integrations`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load integrations: ${error.message}`);
        }
    }

    /**
     * Add environment
     */
    public async addEnvironment(environment: EnvironmentConfig): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            // Validate environment
            this.validateEnvironment(environment);
            
            this.environments.set(environment.id, environment);
            this.currentConfig.environments.push(environment);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Added environment: ${environment.name}`);
            this.emit('environmentAdded', environment);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add environment: ${error.message}`);
        }
    }

    /**
     * Remove environment
     */
    public async removeEnvironment(id: string): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            const environment = this.environments.get(id);
            if (!environment) {
                throw new Error(`Environment not found: ${id}`);
            }
            
            // Remove from maps
            this.environments.delete(id);
            
            // Remove from configuration
            this.currentConfig.environments = this.currentConfig.environments
                .filter(e => e.id !== id);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Removed environment: ${environment.name}`);
            this.emit('environmentRemoved', environment);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to remove environment: ${error.message}`);
        }
    }

    /**
     * Validate environment
     */
    private validateEnvironment(environment: EnvironmentConfig): void {
        if (!environment.id || !environment.name || !environment.type) {
            throw new Error('Environment must have ID, name, and type');
        }
        
        if (!['development', 'staging', 'production', 'testing'].includes(environment.type)) {
            throw new Error('Invalid environment type');
        }
        
        if (environment.limits.maxMemory <= 0 || environment.limits.maxCpu <= 0) {
            throw new Error('Memory and CPU limits must be greater than 0');
        }
    }

    /**
     * Add service
     */
    public async addService(service: ServiceConfig): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            // Validate service
            this.validateService(service);
            
            this.services.set(service.id, service);
            this.currentConfig.services.push(service);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Added service: ${service.name}`);
            this.emit('serviceAdded', service);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add service: ${error.message}`);
        }
    }

    /**
     * Remove service
     */
    public async removeService(id: string): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            const service = this.services.get(id);
            if (!service) {
                throw new Error(`Service not found: ${id}`);
            }
            
            // Remove from maps
            this.services.delete(id);
            
            // Remove from configuration
            this.currentConfig.services = this.currentConfig.services
                .filter(s => s.id !== id);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Removed service: ${service.name}`);
            this.emit('serviceRemoved', service);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to remove service: ${error.message}`);
        }
    }

    /**
     * Validate service
     */
    private validateService(service: ServiceConfig): void {
        if (!service.id || !service.name || !service.type || !service.endpoint) {
            throw new Error('Service must have ID, name, type, and endpoint');
        }
        
        if (!['api', 'database', 'cache', 'storage', 'message-queue', 'external-api'].includes(service.type)) {
            throw new Error('Invalid service type');
        }
        
        if (!['none', 'api-key', 'oauth', 'basic', 'bearer'].includes(service.authentication.type)) {
            throw new Error('Invalid authentication type');
        }
    }

    /**
     * Add integration
     */
    public async addIntegration(integration: IntegrationConfig): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            // Validate integration
            this.validateIntegration(integration);
            
            this.integrations.set(integration.id, integration);
            this.currentConfig.integrations.push(integration);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Added integration: ${integration.name}`);
            this.emit('integrationAdded', integration);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add integration: ${error.message}`);
        }
    }

    /**
     * Remove integration
     */
    public async removeIntegration(id: string): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            const integration = this.integrations.get(id);
            if (!integration) {
                throw new Error(`Integration not found: ${id}`);
            }
            
            // Remove from maps
            this.integrations.delete(id);
            
            // Remove from configuration
            this.currentConfig.integrations = this.currentConfig.integrations
                .filter(i => i.id !== id);
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Removed integration: ${integration.name}`);
            this.emit('integrationRemoved', integration);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to remove integration: ${error.message}`);
        }
    }

    /**
     * Validate integration
     */
    private validateIntegration(integration: IntegrationConfig): void {
        if (!integration.id || !integration.name || !integration.type) {
            throw new Error('Integration must have ID, name, and type');
        }
        
        const validTypes = ['git', 'github', 'gitlab', 'docker', 'kubernetes', 'aws', 'azure', 'gcp'];
        if (!validTypes.includes(integration.type)) {
            throw new Error('Invalid integration type');
        }
        
        if (!['none', 'api-key', 'oauth', 'service-account'].includes(integration.auth.type)) {
            throw new Error('Invalid authentication type');
        }
    }

    /**
     * Update configuration
     */
    public async updateConfiguration(config: Partial<EcosystemConfig>): Promise<void> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration loaded');
            }
            
            // Merge configuration
            this.currentConfig = {
                ...this.currentConfig,
                ...config,
                version: config.version || this.currentConfig.version
            };
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine('Configuration updated successfully');
            this.emit('configurationUpdated', this.currentConfig);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to update configuration: ${error.message}`);
        }
    }

    /**
     * Get current configuration
     */
    public getCurrentConfiguration(): EcosystemConfig | null {
        return this.currentConfig ? { ...this.currentConfig } : null;
    }

    /**
     * Get environment by ID
     */
    public getEnvironment(id: string): EnvironmentConfig | undefined {
        return this.environments.get(id);
    }

    /**
     * Get all environments
     */
    public getEnvironments(): EnvironmentConfig[] {
        return Array.from(this.environments.values());
    }

    /**
     * Get service by ID
     */
    public getService(id: string): ServiceConfig | undefined {
        return this.services.get(id);
    }

    /**
     * Get all services
     */
    public getServices(): ServiceConfig[] {
        return Array.from(this.services.values());
    }

    /**
     * Get integration by ID
     */
    public getIntegration(id: string): IntegrationConfig | undefined {
        return this.integrations.get(id);
    }

    /**
     * Get all integrations
     */
    public getIntegrations(): IntegrationConfig[] {
        return Array.from(this.integrations.values());
    }

    /**
     * Export configuration
     */
    public async exportConfiguration(filePath?: string): Promise<string> {
        try {
            if (!this.currentConfig) {
                throw new Error('No configuration to export');
            }
            
            const exportPath = filePath || path.join(
                this.context.globalStorageUri.fsPath,
                `exports/ecosystem-config-${new Date().toISOString().split('T')[0]}.yaml`
            );
            
            const exportDir = path.dirname(exportPath);
            if (!fs.existsSync(exportDir)) {
                fs.mkdirSync(exportDir, { recursive: true });
            }
            
            fs.writeFileSync(exportPath, yaml.dump(this.currentConfig, { indent: 2 }));
            
            this.outputChannel.appendLine(`Configuration exported to: ${exportPath}`);
            return exportPath;
        } catch (error) {
            throw new Error(`Failed to export configuration: ${error.message}`);
        }
    }

    /**
     * Import configuration
     */
    public async importConfiguration(filePath: string): Promise<void> {
        try {
            if (!fs.existsSync(filePath)) {
                throw new Error(`Configuration file not found: ${filePath}`);
            }
            
            const configData = yaml.load(fs.readFileSync(filePath, 'utf8'));
            const importedConfig = configData as EcosystemConfig;
            
            // Validate imported configuration
            this.validateConfiguration(importedConfig);
            
            // Create backup of current config
            await this.createBackup();
            
            // Update current configuration
            this.currentConfig = importedConfig;
            
            // Reload components
            await this.loadEnvironments();
            await this.loadServices();
            await this.loadIntegrations();
            
            await this.saveConfiguration();
            
            this.outputChannel.appendLine(`Configuration imported from: ${filePath}`);
            this.emit('configurationImported', this.currentConfig);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to import configuration: ${error.message}`);
        }
    }

    /**
     * Validate configuration
     */
    private validateConfiguration(config: EcosystemConfig): void {
        if (!config.id || !config.name || !config.version) {
            throw new Error('Configuration must have ID, name, and version');
        }
        
        if (!config.environments || config.environments.length === 0) {
            throw new Error('Configuration must have at least one environment');
        }
        
        for (const env of config.environments) {
            this.validateEnvironment(env);
        }
        
        for (const service of config.services || []) {
            this.validateService(service);
        }
        
        for (const integration of config.integrations || []) {
            this.validateIntegration(integration);
        }
    }

    /**
     * Start configuration monitoring
     */
    private startConfigurationMonitoring(): void {
        // Watch for configuration file changes
        const watcher = fs.watch(this.configFilePath, async (eventType) => {
            if (eventType === 'change') {
                try {
                    await this.loadConfiguration();
                    this.outputChannel.appendLine('Configuration file changed, reloaded');
                    this.emit('configurationReloaded', this.currentConfig);
                } catch (error) {
                    this.outputChannel.appendLine(`Failed to reload configuration: ${error.message}`);
                }
            }
        });
        
        // Store watcher for cleanup
        (this as any).configWatcher = watcher;
    }

    /**
     * Update status bar with configuration information
     */
    private updateStatusBar(): void {
        const totalEnvironments = this.environments.size;
        const totalServices = this.services.size;
        const totalIntegrations = this.integrations.size;
        const activeEnvironments = Array.from(this.environments.values())
            .filter(e => e.type === 'production' || e.type === 'staging').length;
        
        let text = `$(settings) Config`;
        if (totalEnvironments > 0) {
            text += ` 🌍${totalEnvironments}`;
        }
        if (totalServices > 0) {
            text += ` 🔧${totalServices}`;
        }
        if (totalIntegrations > 0) {
            text += ` 🔗${totalIntegrations}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Configuration: ${activeEnvironments} active environments, ${totalServices} services, ${totalIntegrations} integrations`;
    }

    /**
     * Show configuration status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const config = this.getCurrentConfiguration();
            if (!config) {
                throw new Error('No configuration loaded');
            }

            let output = `Ecosystem Configuration Status\n`;
            output += `============================\n\n`;

            output += `Configuration: ${config.name} v${config.version}\n`;
            output += `Description: ${config.description}\n\n`;

            output += `Environments (${config.environments.length}):\n`;
            for (const env of config.environments) {
                const typeIcon = env.type === 'production' ? '🏭' : 
                               env.type === 'staging' ? '🔬' : 
                               env.type === 'development' ? '💻' : '🧪';
                output += `  ${typeIcon} ${env.name}: ${env.type}\n`;
                output += `    Variables: ${Object.keys(env.variables).length}\n`;
                output += `    Features: ${env.features.join(', ')}\n`;
            }
            output += '\n';

            output += `Services (${config.services.length}):\n`;
            for (const service of config.services.slice(0, 5)) {
                const typeIcon = service.type === 'api' ? '🌐' : 
                               service.type === 'database' ? '🗄️' : 
                               service.type === 'cache' ? '⚡' : '📦';
                output += `  ${typeIcon} ${service.name}: ${service.type}\n`;
                output += `    Endpoint: ${service.endpoint}\n`;
                output += `    Auth: ${service.authentication.type}\n`;
            }
            if (config.services.length > 5) {
                output += `  ... and ${config.services.length - 5} more services\n`;
            }
            output += '\n';

            output += `Integrations (${config.integrations.length}):\n`;
            for (const integration of config.integrations.slice(0, 5)) {
                const typeIcon = integration.type === 'github' ? '🐙' : 
                               integration.type === 'docker' ? '🐳' : 
                               integration.type === 'kubernetes' ? '☸️' : '🔗';
                output += `  ${typeIcon} ${integration.name}: ${integration.type}\n`;
                output += `    Enabled: ${integration.enabled}\n`;
            }
            if (config.integrations.length > 5) {
                output += `  ... and ${config.integrations.length - 5} more integrations\n`;
            }
            output += '\n';

            output += `Monitoring: ${config.monitoring.enabled ? 'Enabled' : 'Disabled'}\n`;
            output += `Security: ${config.security.authentication.enabled ? 'Enabled' : 'Disabled'}\n`;
            output += `Performance: ${config.performance.optimization.enabled ? 'Enabled' : 'Disabled'}\n`;
            output += `Logging: ${config.logging.level} (${config.logging.format})\n`;

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show configuration status: ${error.message}`);
        }
    }

    /**
     * Dispose configuration management
     */
    public dispose(): void {
        if ((this as any).configWatcher) {
            (this as any).configWatcher.close();
        }
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }

    // Event emitter methods
    private emit(event: string, data: any): void {
        // Implementation would depend on the event system being used
    }
}