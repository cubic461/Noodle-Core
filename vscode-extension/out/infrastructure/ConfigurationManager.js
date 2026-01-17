"use strict";
/**
 * Configuration Manager for Noodle VS Code Extension
 *
 * Manages configuration settings with proper validation,
 * environment-specific settings, and change notifications.
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
exports.ConfigurationManager = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
const fs = __importStar(require("fs"));
class ConfigurationManager extends events_1.EventEmitter {
    constructor(context) {
        super();
        this.schema = {};
        this.watchers = [];
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Configuration Manager');
        this.configuration = vscode.workspace.getConfiguration('noodle');
    }
    /**
     * Initialize configuration manager
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing configuration manager...');
            // Register configuration change listener
            vscode.workspace.onDidChangeConfiguration(async (event) => {
                if (event.affectsConfiguration('noodle')) {
                    await this.handleConfigurationChange(event);
                }
            });
            // Load configuration schema
            await this.loadConfigurationSchema();
            // Validate current configuration
            await this.validateConfiguration();
            this.outputChannel.appendLine('Configuration manager initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize configuration manager: ${error.message}`);
            throw error;
        }
    }
    /**
     * Get configuration value
     */
    get(key, scope) {
        try {
            const value = this.configuration.get(key, undefined, scope);
            this.outputChannel.appendLine(`Configuration get: ${key} = ${JSON.stringify(value)}`);
            return value;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to get configuration ${key}: ${error.message}`);
            return undefined;
        }
    }
    /**
     * Set configuration value
     */
    async set(key, value, target) {
        try {
            // Validate value
            const validationResult = this.validateValue(key, value);
            if (validationResult !== true) {
                throw new Error(`Validation failed: ${validationResult}`);
            }
            // Set value
            const success = await this.configuration.update(key, value, target || vscode.ConfigurationTarget.Global);
            if (success) {
                this.outputChannel.appendLine(`Configuration set: ${key} = ${JSON.stringify(value)}`);
                this.emit('configurationChanged', { key, value });
            }
            else {
                this.outputChannel.appendLine(`Failed to set configuration: ${key}`);
            }
            return success;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to set configuration ${key}: ${error.message}`);
            return false;
        }
    }
    /**
     * Get configuration section
     */
    getSection(section) {
        try {
            const value = this.configuration.get(section);
            this.outputChannel.appendLine(`Configuration section: ${section} = ${JSON.stringify(value)}`);
            return value;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to get configuration section ${section}: ${error.message}`);
            return undefined;
        }
    }
    /**
     * Check if configuration key exists
     */
    has(key) {
        try {
            const value = this.configuration.get(key);
            return value !== undefined;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to check configuration ${key}: ${error.message}`);
            return false;
        }
    }
    /**
     * Get all configuration keys
     */
    getKeys() {
        try {
            const keys = Object.keys(this.configuration);
            this.outputChannel.appendLine(`Configuration keys: ${keys.join(', ')}`);
            return keys;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to get configuration keys: ${error.message}`);
            return [];
        }
    }
    /**
     * Reset configuration to default
     */
    async reset(key) {
        try {
            if (key) {
                const success = await this.configuration.update(key, undefined, vscode.ConfigurationTarget.Global);
                if (success) {
                    this.outputChannel.appendLine(`Configuration reset: ${key}`);
                    this.emit('configurationReset', { key });
                }
                return success;
            }
            else {
                // Reset all configuration
                const keys = this.getKeys();
                let success = true;
                for (const k of keys) {
                    const result = await this.configuration.update(k, undefined, vscode.ConfigurationTarget.Global);
                    success = success && result;
                }
                if (success) {
                    this.outputChannel.appendLine('All configuration reset');
                    this.emit('configurationReset', { key: 'all' });
                }
                return success;
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to reset configuration: ${error.message}`);
            return false;
        }
    }
    /**
     * Export configuration to file
     */
    async exportConfiguration(filePath) {
        try {
            const config = this.configuration;
            const exportData = {
                version: '1.0.0',
                timestamp: new Date().toISOString(),
                configuration: config
            };
            const fileContent = JSON.stringify(exportData, null, 2);
            await fs.promises.writeFile(filePath, fileContent, 'utf8');
            this.outputChannel.appendLine(`Configuration exported to: ${filePath}`);
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to export configuration: ${error.message}`);
            return false;
        }
    }
    /**
     * Import configuration from file
     */
    async importConfiguration(filePath) {
        try {
            const fileContent = await fs.promises.readFile(filePath, 'utf8');
            const importData = JSON.parse(fileContent);
            if (!importData.configuration) {
                throw new Error('Invalid configuration file format');
            }
            // Import configuration values
            for (const [key, value] of Object.entries(importData.configuration)) {
                await this.set(key, value);
            }
            this.outputChannel.appendLine(`Configuration imported from: ${filePath}`);
            this.emit('configurationImported', { filePath });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to import configuration: ${error.message}`);
            return false;
        }
    }
    /**
     * Watch configuration file for changes
     */
    watchConfigurationFile(filePath) {
        try {
            const watcher = vscode.workspace.createFileSystemWatcher(filePath);
            watcher.onDidChange(async () => {
                this.outputChannel.appendLine(`Configuration file changed: ${filePath}`);
                await this.importConfiguration(filePath);
            });
            this.watchers.push(watcher);
            this.outputChannel.appendLine(`Watching configuration file: ${filePath}`);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to watch configuration file: ${error.message}`);
        }
    }
    /**
     * Load configuration schema
     */
    async loadConfigurationSchema() {
        try {
            // Default schema
            this.schema = {
                ecosystem: {
                    type: 'object',
                    description: 'Ecosystem integration settings',
                    properties: {
                        git: {
                            type: 'object',
                            description: 'Git integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                autoCommit: { type: 'boolean', default: false },
                                autoPush: { type: 'boolean', default: false }
                            }
                        },
                        github: {
                            type: 'object',
                            description: 'GitHub integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                token: { type: 'string', description: 'GitHub personal access token' },
                                apiEndpoint: { type: 'string', default: 'https://api.github.com' }
                            }
                        },
                        cicd: {
                            type: 'object',
                            description: 'CI/CD integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                platform: { type: 'string', enum: ['github', 'gitlab', 'jenkins', 'azure'] },
                                autoTrigger: { type: 'boolean', default: false }
                            }
                        },
                        monitoring: {
                            type: 'object',
                            description: 'Monitoring integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                platform: { type: 'string', enum: ['prometheus', 'grafana', 'datadog'] },
                                metricsEndpoint: { type: 'string' }
                            }
                        },
                        docker: {
                            type: 'object',
                            description: 'Docker integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                dockerPath: { type: 'string', default: 'docker' },
                                autoBuild: { type: 'boolean', default: false }
                            }
                        },
                        kubernetes: {
                            type: 'object',
                            description: 'Kubernetes integration settings',
                            properties: {
                                enabled: { type: 'boolean', default: true },
                                kubeconfig: { type: 'string' },
                                namespace: { type: 'string', default: 'default' }
                            }
                        }
                    }
                }
            };
            this.outputChannel.appendLine('Configuration schema loaded');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load configuration schema: ${error.message}`);
        }
    }
    /**
     * Validate configuration
     */
    async validateConfiguration() {
        try {
            const config = this.configuration;
            const errors = [];
            this.validateSchema(this.schema, config, '', errors);
            if (errors.length > 0) {
                this.outputChannel.appendLine('Configuration validation errors:');
                errors.forEach(error => this.outputChannel.appendLine(`  - ${error}`));
            }
            else {
                this.outputChannel.appendLine('Configuration validation passed');
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to validate configuration: ${error.message}`);
        }
    }
    /**
     * Validate schema
     */
    validateSchema(schema, config, path, errors) {
        for (const [key, schemaValue] of Object.entries(schema)) {
            const currentPath = path ? `${path}.${key}` : key;
            const value = config[key];
            if (typeof schemaValue === 'object' && schemaValue.type) {
                // Validate property
                const propertySchema = schemaValue;
                if (propertySchema.required && value === undefined) {
                    errors.push(`Required property missing: ${currentPath}`);
                    continue;
                }
                if (value !== undefined) {
                    const validationResult = this.validateValue(currentPath, value);
                    if (validationResult !== true) {
                        errors.push(`${currentPath}: ${validationResult}`);
                    }
                }
            }
            else if (typeof schemaValue === 'object') {
                // Validate nested object
                if (value !== undefined) {
                    this.validateSchema(schemaValue, value, currentPath, errors);
                }
            }
        }
    }
    /**
     * Validate value
     */
    validateValue(key, value) {
        try {
            // Get schema for key
            const schema = this.getSchemaForKey(key);
            if (!schema) {
                return true; // No schema, no validation
            }
            // Type validation
            if (schema.type && typeof value !== schema.type) {
                return `Expected type ${schema.type}, got ${typeof value}`;
            }
            // Enum validation
            if (schema.enum && !schema.enum.includes(value)) {
                return `Value must be one of: ${schema.enum.join(', ')}`;
            }
            // Number validation
            if (schema.type === 'number') {
                if (schema.minimum !== undefined && value < schema.minimum) {
                    return `Value must be at least ${schema.minimum}`;
                }
                if (schema.maximum !== undefined && value > schema.maximum) {
                    return `Value must be at most ${schema.maximum}`;
                }
            }
            // String validation
            if (schema.type === 'string' && schema.pattern) {
                const regex = new RegExp(schema.pattern);
                if (!regex.test(value)) {
                    return `Value does not match pattern: ${schema.pattern}`;
                }
            }
            // Custom validation
            if (schema.validation) {
                const result = schema.validation(value);
                if (result !== true) {
                    return result;
                }
            }
            return true;
        }
        catch (error) {
            return `Validation error: ${error.message}`;
        }
    }
    /**
     * Get schema for key
     */
    getSchemaForKey(key) {
        try {
            const parts = key.split('.');
            let current = this.schema;
            for (const part of parts) {
                if (current[part] && typeof current[part] === 'object') {
                    current = current[part];
                }
                else {
                    return undefined;
                }
            }
            return current;
        }
        catch (error) {
            return undefined;
        }
    }
    /**
     * Handle configuration change
     */
    async handleConfigurationChange(event) {
        try {
            this.outputChannel.appendLine('Configuration changed');
            // Re-validate configuration
            await this.validateConfiguration();
            // Emit change event
            this.emit('configurationChanged', { event });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to handle configuration change: ${error.message}`);
        }
    }
    /**
     * Dispose configuration manager
     */
    dispose() {
        // Dispose file watchers
        this.watchers.forEach(watcher => watcher.dispose());
        this.watchers = [];
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.ConfigurationManager = ConfigurationManager;
//# sourceMappingURL=ConfigurationManager.js.map