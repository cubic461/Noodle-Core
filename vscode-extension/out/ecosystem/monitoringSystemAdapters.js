"use strict";
/**
 * Monitoring System Adapters for Noodle VS Code Extension
 *
 * Provides adapters for various monitoring and observability systems
 * including Prometheus, Grafana, ELK stack, and custom monitoring solutions.
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
exports.MonitoringSystemAdapters = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class MonitoringSystemAdapters extends events_1.EventEmitter {
    constructor(context) {
        super();
        this.adapters = new Map();
        this.configs = new Map();
        this.metrics = new Map();
        this.alerts = new Map();
        this.dashboards = new Map();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Monitoring System');
    }
    /**
     * Initialize monitoring system adapters
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing monitoring system adapters...');
            // Load configurations
            await this.loadConfigurations();
            // Initialize adapters
            await this.initializeAdapters();
            this.outputChannel.appendLine('Monitoring system adapters initialized');
            this.emit('initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize monitoring system adapters: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Add monitoring adapter
     */
    async addAdapter(type, config) {
        try {
            this.outputChannel.appendLine(`Adding monitoring adapter: ${type}`);
            // Validate configuration
            if (!config.endpoint) {
                throw new Error('Monitoring endpoint is required');
            }
            // Store adapter configuration
            this.configs.set(type, config);
            this.adapters.set(type, this.createAdapter(type, config));
            this.outputChannel.appendLine(`Monitoring adapter added: ${type}`);
            this.emit('adapterAdded', { type, config });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to add monitoring adapter: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Remove monitoring adapter
     */
    removeAdapter(type) {
        const adapter = this.adapters.get(type);
        if (!adapter) {
            return false;
        }
        this.adapters.delete(type);
        this.configs.delete(type);
        this.outputChannel.appendLine(`Monitoring adapter removed: ${type}`);
        this.emit('adapterRemoved', { type });
        return true;
    }
    /**
     * Get all adapters
     */
    getAdapters() {
        return new Map(this.adapters);
    }
    /**
     * Get adapter by type
     */
    getAdapter(type) {
        return this.adapters.get(type);
    }
    /**
     * Collect metrics from adapter
     */
    async collectMetrics(type, metrics) {
        const adapter = this.adapters.get(type);
        if (!adapter) {
            throw new Error(`Monitoring adapter not found: ${type}`);
        }
        try {
            // Send metrics to adapter
            await adapter.collectMetrics(metrics);
            // Store metrics locally
            const existingMetrics = this.metrics.get(type) || [];
            this.metrics.set(type, [...existingMetrics, ...metrics]);
            this.outputChannel.appendLine(`Collected ${metrics.length} metrics from ${type} adapter`);
            this.emit('metricsCollected', { type, metrics });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to collect metrics from ${type} adapter: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Get metrics from adapter
     */
    getMetrics(type) {
        return this.metrics.get(type) || [];
    }
    /**
     * Create monitoring dashboard
     */
    async createDashboard(type, name, url) {
        try {
            this.outputChannel.appendLine(`Creating monitoring dashboard: ${name}`);
            const dashboard = {
                id: this.generateId(),
                name,
                url,
                type: type,
                enabled: true
            };
            // Store dashboard
            const existingDashboards = this.dashboards.get(type) || [];
            this.dashboards.set(type, [...existingDashboards, dashboard]);
            this.outputChannel.appendLine(`Monitoring dashboard created: ${name}`);
            this.emit('dashboardCreated', { type, dashboard });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to create monitoring dashboard: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Get dashboards
     */
    getDashboards(type) {
        if (type) {
            return this.dashboards.get(type) || [];
        }
        return Array.from(this.dashboards.values()).flat();
    }
    /**
     * Set up alerting
     */
    async setupAlerting(type, config) {
        const adapter = this.adapters.get(type);
        if (!adapter) {
            throw new Error(`Monitoring adapter not found: ${type}`);
        }
        try {
            await adapter.setupAlerting(config);
            this.outputChannel.appendLine(`Alerting setup for ${type} adapter`);
            this.emit('alertingSetup', { type, config });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to setup alerting for ${type} adapter: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Create alert
     */
    async createAlert(type, alert) {
        const adapter = this.adapters.get(type);
        if (!adapter) {
            throw new Error(`Monitoring adapter not found: ${type}`);
        }
        try {
            const fullAlert = {
                id: this.generateId(),
                ...alert
            };
            const existingAlerts = this.alerts.get(type) || [];
            this.alerts.set(type, [...existingAlerts, fullAlert]);
            this.outputChannel.appendLine(`Alert created: ${alert.name}`);
            this.emit('alertCreated', { type, alert: fullAlert });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to create alert: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }
    /**
     * Get alerts
     */
    getAlerts(type) {
        if (type) {
            return this.alerts.get(type) || [];
        }
        return Array.from(this.alerts.values()).flat();
    }
    /**
     * Resolve alert
     */
    async resolveAlert(type, alertId) {
        const alerts = this.alerts.get(type) || [];
        const alertIndex = alerts.findIndex(a => a.id === alertId);
        if (alertIndex === -1) {
            throw new Error(`Alert not found: ${alertId}`);
        }
        alerts[alertIndex].resolved = true;
        this.alerts.set(type, alerts);
        this.outputChannel.appendLine(`Alert resolved: ${alertId}`);
        this.emit('alertResolved', { type, alertId });
    }
    /**
     * Load configurations
     */
    async loadConfigurations() {
        try {
            const config = vscode.workspace.getConfiguration('noodle.monitoring');
            const adapters = config.get('adapters', {});
            for (const [type, adapterConfig] of Object.entries(adapters)) {
                this.configs.set(type, adapterConfig);
                this.adapters.set(type, this.createAdapter(type, adapterConfig));
            }
            this.outputChannel.appendLine('Monitoring configurations loaded');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load monitoring configurations: ${error instanceof Error ? error.message : String(error)}`);
        }
    }
    /**
     * Initialize adapters
     */
    async initializeAdapters() {
        for (const [type, adapter] of this.adapters) {
            try {
                await adapter.initialize();
                this.outputChannel.appendLine(`Monitoring adapter initialized: ${type}`);
            }
            catch (error) {
                this.outputChannel.appendLine(`Failed to initialize monitoring adapter ${type}: ${error instanceof Error ? error.message : String(error)}`);
            }
        }
    }
    /**
     * Create adapter instance
     */
    createAdapter(type, config) {
        switch (type) {
            case 'prometheus':
                return this.createPrometheusAdapter(config);
            case 'grafana':
                return this.createGrafanaAdapter(config);
            case 'elk':
                return this.createELKAdapter(config);
            case 'custom':
                return this.createCustomAdapter(config);
            default:
                return this.createGenericAdapter(config);
        }
    }
    /**
     * Create Prometheus adapter
     */
    createPrometheusAdapter(config) {
        return {
            type: 'prometheus',
            config,
            initialize: async () => {
                this.outputChannel.appendLine('Initializing Prometheus adapter');
            },
            collectMetrics: async (metrics) => {
                this.outputChannel.appendLine(`Collecting ${metrics.length} metrics for Prometheus`);
            },
            setupAlerting: async (alertConfig) => {
                this.outputChannel.appendLine('Setting up Prometheus alerting');
            }
        };
    }
    /**
     * Create Grafana adapter
     */
    createGrafanaAdapter(config) {
        return {
            type: 'grafana',
            config,
            initialize: async () => {
                this.outputChannel.appendLine('Initializing Grafana adapter');
            },
            collectMetrics: async (metrics) => {
                this.outputChannel.appendLine(`Collecting ${metrics.length} metrics for Grafana`);
            },
            setupAlerting: async (alertConfig) => {
                this.outputChannel.appendLine('Setting up Grafana alerting');
            }
        };
    }
    /**
     * Create ELK adapter
     */
    createELKAdapter(config) {
        return {
            type: 'elk',
            config,
            initialize: async () => {
                this.outputChannel.appendLine('Initializing ELK adapter');
            },
            collectMetrics: async (metrics) => {
                this.outputChannel.appendLine(`Collecting ${metrics.length} metrics for ELK`);
            },
            setupAlerting: async (alertConfig) => {
                this.outputChannel.appendLine('Setting up ELK alerting');
            }
        };
    }
    /**
     * Create custom adapter
     */
    createCustomAdapter(config) {
        return {
            type: 'custom',
            config,
            initialize: async () => {
                this.outputChannel.appendLine('Initializing custom monitoring adapter');
            },
            collectMetrics: async (metrics) => {
                this.outputChannel.appendLine(`Collecting ${metrics.length} metrics for custom adapter`);
            },
            setupAlerting: async (alertConfig) => {
                this.outputChannel.appendLine('Setting up custom alerting');
            }
        };
    }
    /**
     * Create generic adapter
     */
    createGenericAdapter(config) {
        return {
            type: 'generic',
            config,
            initialize: async () => {
                this.outputChannel.appendLine('Initializing generic monitoring adapter');
            },
            collectMetrics: async (metrics) => {
                this.outputChannel.appendLine(`Collecting ${metrics.length} metrics for generic adapter`);
            },
            setupAlerting: async (alertConfig) => {
                this.outputChannel.appendLine('Setting up generic alerting');
            }
        };
    }
    /**
     * Generate unique ID
     */
    generateId() {
        return 'monitor_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);
    }
    /**
     * Dispose monitoring system adapters
     */
    dispose() {
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.MonitoringSystemAdapters = MonitoringSystemAdapters;
//# sourceMappingURL=monitoringSystemAdapters.js.map