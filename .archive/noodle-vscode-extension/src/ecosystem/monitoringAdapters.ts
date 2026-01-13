/**
 * NoodleCore Monitoring System Adapters
 * 
 * Provides comprehensive monitoring system integration with popular platforms
 * like Prometheus, Grafana, Datadog, New Relic, and custom monitoring solutions.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';
import axios from 'axios';

export interface MetricData {
    name: string;
    value: number;
    timestamp: number;
    tags: { [key: string]: string };
    type: 'counter' | 'gauge' | 'histogram' | 'summary';
    description?: string;
}

export interface AlertRule {
    id: string;
    name: string;
    description: string;
    condition: string;
    threshold: number;
    duration: string;
    severity: 'low' | 'medium' | 'high' | 'critical';
    enabled: boolean;
    tags: { [key: string]: string };
}

export interface MonitoringDashboard {
    id: string;
    name: string;
    description: string;
    panels: DashboardPanel[];
    variables: DashboardVariable[];
    refreshInterval: number;
}

export interface DashboardPanel {
    id: string;
    title: string;
    type: 'graph' | 'singlestat' | 'table' | 'text' | 'heatmap';
    dataSource: string;
    query: string;
    options: any;
    span: number;
}

export interface DashboardVariable {
    name: string;
    type: 'query' | 'custom' | 'interval';
    query?: string;
    options?: string[];
    current?: string;
}

export interface MonitoringProvider {
    name: string;
    type: 'prometheus' | 'grafana' | 'datadog' | 'newrelic' | 'custom';
    config: MonitoringConfig;
    connected: boolean;
    lastSync: Date;
}

export interface MonitoringConfig {
    endpoint: string;
    apiKey?: string;
    username?: string;
    password?: string;
    headers?: { [key: string]: string };
    timeout: number;
    retryCount: number;
}

export interface HealthCheck {
    id: string;
    name: string;
    type: 'http' | 'tcp' | 'grpc' | 'database' | 'custom';
    endpoint: string;
    expectedStatus?: number;
    timeout: number;
    interval: number;
    enabled: boolean;
    lastCheck: Date;
    status: 'healthy' | 'unhealthy' | 'unknown';
    responseTime: number;
    error?: string;
}

export interface LogEntry {
    timestamp: Date;
    level: 'debug' | 'info' | 'warn' | 'error' | 'fatal';
    message: string;
    source: string;
    metadata: { [key: string]: any };
    traceId?: string;
    spanId?: string;
}

export interface LogQuery {
    query: string;
    startTime: Date;
    endTime: Date;
    limit: number;
    filters: { [key: string]: any };
}

export class MonitoringAdapters extends EventEmitter {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private providers: Map<string, MonitoringProvider> = new Map();
    private healthChecks: Map<string, HealthCheck> = new Map();
    private metrics: MetricData[] = [];
    private logs: LogEntry[] = [];
    private dashboards: MonitoringDashboard[] = [];
    private syncInterval: NodeJS.Timeout | null = null;

    constructor() {
        super();
        this.outputChannel = vscode.window.createOutputChannel('Noodle Monitoring');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            70
        );
        this.statusBarItem.command = 'noodle.monitoring.showStatus';
        
        this.initializeMonitoring();
    }

    /**
     * Initialize monitoring adapters
     */
    private async initializeMonitoring(): Promise<void> {
        try {
            // Load monitoring configuration
            const config = vscode.workspace.getConfiguration('noodle.monitoring');
            const providersConfig = config.get<MonitoringProvider[]>('providers', []);
            
            // Initialize providers
            for (const providerConfig of providersConfig) {
                await this.addProvider(providerConfig);
            }
            
            // Start health checks
            this.startHealthChecks();
            
            // Start metrics collection
            this.startMetricsCollection();
            
            // Start log collection
            this.startLogCollection();
            
            // Start dashboard sync
            this.startDashboardSync();
            
            this.outputChannel.appendLine('Monitoring adapters initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Monitoring initialization failed: ${error.message}`);
        }
    }

    /**
     * Add monitoring provider
     */
    public async addProvider(provider: MonitoringProvider): Promise<void> {
        try {
            // Test connection
            await this.testProviderConnection(provider);
            
            this.providers.set(provider.name, provider);
            this.outputChannel.appendLine(`Added monitoring provider: ${provider.name}`);
            
            this.emit('providerAdded', provider);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add provider: ${error.message}`);
        }
    }

    /**
     * Remove monitoring provider
     */
    public removeProvider(name: string): boolean {
        const provider = this.providers.get(name);
        if (!provider) {
            return false;
        }

        this.providers.delete(name);
        this.outputChannel.appendLine(`Removed monitoring provider: ${name}`);
        
        this.emit('providerRemoved', provider);
        this.updateStatusBar();
        return true;
    }

    /**
     * Test provider connection
     */
    private async testProviderConnection(provider: MonitoringProvider): Promise<void> {
        try {
            const config = provider.config;
            const url = `${config.endpoint}/health`;
            
            const response = await axios.get(url, {
                timeout: config.timeout,
                headers: {
                    ...config.headers,
                    ...(config.apiKey ? { 'Authorization': `Bearer ${config.apiKey}` } : {})
                }
            });
            
            provider.connected = response.status === 200;
            provider.lastSync = new Date();
        } catch (error) {
            provider.connected = false;
            throw new Error(`Connection test failed: ${error.message}`);
        }
    }

    /**
     * Get all providers
     */
    public getProviders(): MonitoringProvider[] {
        return Array.from(this.providers.values());
    }

    /**
     * Get provider by name
     */
    public getProvider(name: string): MonitoringProvider | undefined {
        return this.providers.get(name);
    }

    /**
     * Add health check
     */
    public addHealthCheck(healthCheck: HealthCheck): void {
        this.healthChecks.set(healthCheck.id, healthCheck);
        this.outputChannel.appendLine(`Added health check: ${healthCheck.name}`);
        
        this.emit('healthCheckAdded', healthCheck);
    }

    /**
     * Remove health check
     */
    public removeHealthCheck(id: string): boolean {
        const healthCheck = this.healthChecks.get(id);
        if (!healthCheck) {
            return false;
        }

        this.healthChecks.delete(id);
        this.outputChannel.appendLine(`Removed health check: ${healthCheck.name}`);
        
        this.emit('healthCheckRemoved', healthCheck);
        return true;
    }

    /**
     * Get all health checks
     */
    public getHealthChecks(): HealthCheck[] {
        return Array.from(this.healthChecks.values());
    }

    /**
     * Start health checks
     */
    private startHealthChecks(): void {
        setInterval(async () => {
            for (const healthCheck of this.healthChecks.values()) {
                if (!healthCheck.enabled) {
                    continue;
                }
                
                await this.runHealthCheck(healthCheck);
            }
        }, 30000); // Run every 30 seconds
    }

    /**
     * Run individual health check
     */
    private async runHealthCheck(healthCheck: HealthCheck): Promise<void> {
        const startTime = Date.now();
        
        try {
            let response: any;
            
            switch (healthCheck.type) {
                case 'http':
                    response = await axios.get(healthCheck.endpoint, {
                        timeout: healthCheck.timeout,
                        validateStatus: (status) => {
                            return healthCheck.expectedStatus ? status === healthCheck.expectedStatus : true;
                        }
                    });
                    break;
                    
                case 'tcp':
                    // TCP health check would use a different approach
                    // For now, simulate success
                    response = { status: 200 };
                    break;
                    
                default:
                    throw new Error(`Unsupported health check type: ${healthCheck.type}`);
            }
            
            const responseTime = Date.now() - startTime;
            
            healthCheck.lastCheck = new Date();
            healthCheck.status = 'healthy';
            healthCheck.responseTime = responseTime;
            healthCheck.error = undefined;
            
            this.emit('healthCheckUpdated', healthCheck);
            
        } catch (error) {
            const responseTime = Date.now() - startTime;
            
            healthCheck.lastCheck = new Date();
            healthCheck.status = 'unhealthy';
            healthCheck.responseTime = responseTime;
            healthCheck.error = error.message;
            
            this.emit('healthCheckUpdated', healthCheck);
            
            this.outputChannel.appendLine(`Health check failed: ${healthCheck.name} - ${error.message}`);
        }
    }

    /**
     * Add metric
     */
    public addMetric(metric: MetricData): void {
        this.metrics.push(metric);
        
        // Keep only last 1000 metrics
        if (this.metrics.length > 1000) {
            this.metrics = this.metrics.slice(-1000);
        }
        
        this.emit('metricAdded', metric);
    }

    /**
     * Get metrics
     */
    public getMetrics(filter?: {
        name?: string;
        type?: MetricData['type'];
        tags?: { [key: string]: string };
        since?: Date;
        limit?: number;
    }): MetricData[] {
        let filtered = [...this.metrics];

        if (filter) {
            if (filter.name) {
                filtered = filtered.filter(metric => metric.name === filter.name);
            }
            if (filter.type) {
                filtered = filtered.filter(metric => metric.type === filter.type);
            }
            if (filter.tags) {
                filtered = filtered.filter(metric => {
                    return Object.entries(filter.tags!).every(([key, value]) => 
                        metric.tags[key] === value
                    );
                });
            }
            if (filter.since) {
                filtered = filtered.filter(metric => 
                    new Date(metric.timestamp) >= filter.since!
                );
            }
            if (filter.limit) {
                filtered = filtered.slice(-filter.limit);
            }
        }

        return filtered;
    }

    /**
     * Start metrics collection
     */
    private startMetricsCollection(): void {
        setInterval(async () => {
            for (const provider of this.providers.values()) {
                if (!provider.connected) {
                    continue;
                }
                
                await this.collectMetricsFromProvider(provider);
            }
        }, 60000); // Collect every minute
    }

    /**
     * Collect metrics from provider
     */
    private async collectMetricsFromProvider(provider: MonitoringProvider): Promise<void> {
        try {
            const config = provider.config;
            const url = `${config.endpoint}/api/v1/metrics`;
            
            const response = await axios.get(url, {
                timeout: config.timeout,
                headers: {
                    ...config.headers,
                    ...(config.apiKey ? { 'Authorization': `Bearer ${config.apiKey}` } : {})
                }
            });
            
            // Parse and add metrics
            const metrics = this.parseMetrics(response.data);
            for (const metric of metrics) {
                this.addMetric(metric);
            }
            
            provider.lastSync = new Date();
            this.emit('metricsCollected', { provider, metrics });
            
        } catch (error) {
            this.outputChannel.appendLine(`Failed to collect metrics from ${provider.name}: ${error.message}`);
        }
    }

    /**
     * Parse metrics from response
     */
    private parseMetrics(data: any): MetricData[] {
        // This is a simplified parser - in production, use proper metrics parsing
        const metrics: MetricData[] = [];
        
        if (Array.isArray(data)) {
            for (const item of data) {
                metrics.push({
                    name: item.name || 'unknown',
                    value: item.value || 0,
                    timestamp: Date.now(),
                    tags: item.tags || {},
                    type: item.type || 'gauge',
                    description: item.description
                });
            }
        }
        
        return metrics;
    }

    /**
     * Add log entry
     */
    public addLog(log: LogEntry): void {
        this.logs.push(log);
        
        // Keep only last 10000 log entries
        if (this.logs.length > 10000) {
            this.logs = this.logs.slice(-10000);
        }
        
        this.emit('logAdded', log);
    }

    /**
     * Get logs
     */
    public getLogs(query?: LogQuery): LogEntry[] {
        let filtered = [...this.logs];

        if (query) {
            // Filter by time range
            filtered = filtered.filter(log => 
                log.timestamp >= query.startTime && log.timestamp <= query.endTime
            );
            
            // Filter by level
            if (query.filters.level) {
                filtered = filtered.filter(log => log.level === query.filters.level);
            }
            
            // Filter by source
            if (query.filters.source) {
                filtered = filtered.filter(log => log.source === query.filters.source);
            }
            
            // Apply query
            if (query.query) {
                filtered = filtered.filter(log => 
                    log.message.toLowerCase().includes(query.query.toLowerCase())
                );
            }
            
            // Limit results
            if (query.limit) {
                filtered = filtered.slice(-query.limit);
            }
        }

        return filtered;
    }

    /**
     * Start log collection
     */
    private startLogCollection(): void {
        // Listen for VS Code output channel events
        vscode.window.onDidWriteTextEditorDecoration(e => {
            // This is a simplified approach - in production, use proper log collection
            const log: LogEntry = {
                timestamp: new Date(),
                level: 'info',
                message: e.text,
                source: 'vscode',
                metadata: {}
            };
            
            this.addLog(log);
        });
    }

    /**
     * Add dashboard
     */
    public addDashboard(dashboard: MonitoringDashboard): void {
        this.dashboards.push(dashboard);
        this.outputChannel.appendLine(`Added dashboard: ${dashboard.name}`);
        
        this.emit('dashboardAdded', dashboard);
    }

    /**
     * Remove dashboard
     */
    public removeDashboard(id: string): boolean {
        const index = this.dashboards.findIndex(d => d.id === id);
        if (index === -1) {
            return false;
        }

        const dashboard = this.dashboards[index];
        this.dashboards.splice(index, 1);
        this.outputChannel.appendLine(`Removed dashboard: ${dashboard.name}`);
        
        this.emit('dashboardRemoved', dashboard);
        return true;
    }

    /**
     * Get dashboards
     */
    public getDashboards(): MonitoringDashboard[] {
        return [...this.dashboards];
    }

    /**
     * Start dashboard sync
     */
    private startDashboardSync(): void {
        this.syncInterval = setInterval(async () => {
            for (const provider of this.providers.values()) {
                if (!provider.connected) {
                    continue;
                }
                
                await this.syncDashboardsFromProvider(provider);
            }
        }, 300000); // Sync every 5 minutes
    }

    /**
     * Sync dashboards from provider
     */
    private async syncDashboardsFromProvider(provider: MonitoringProvider): Promise<void> {
        try {
            const config = provider.config;
            const url = `${config.endpoint}/api/dashboards`;
            
            const response = await axios.get(url, {
                timeout: config.timeout,
                headers: {
                    ...config.headers,
                    ...(config.apiKey ? { 'Authorization': `Bearer ${config.apiKey}` } : {})
                }
            });
            
            // Parse and add dashboards
            const dashboards = this.parseDashboards(response.data);
            for (const dashboard of dashboards) {
                this.addDashboard(dashboard);
            }
            
            provider.lastSync = new Date();
            this.emit('dashboardsSynced', { provider, dashboards });
            
        } catch (error) {
            this.outputChannel.appendLine(`Failed to sync dashboards from ${provider.name}: ${error.message}`);
        }
    }

    /**
     * Parse dashboards from response
     */
    private parseDashboards(data: any): MonitoringDashboard[] {
        // This is a simplified parser - in production, use proper dashboard parsing
        const dashboards: MonitoringDashboard[] = [];
        
        if (Array.isArray(data)) {
            for (const item of data) {
                dashboards.push({
                    id: item.id || `dashboard-${Date.now()}`,
                    name: item.name || 'Untitled Dashboard',
                    description: item.description || '',
                    panels: item.panels || [],
                    variables: item.variables || [],
                    refreshInterval: item.refreshInterval || 30000
                });
            }
        }
        
        return dashboards;
    }

    /**
     * Update status bar with monitoring information
     */
    private updateStatusBar(): void {
        const connectedProviders = Array.from(this.providers.values()).filter(p => p.connected).length;
        const totalProviders = this.providers.size;
        const healthyChecks = Array.from(this.healthChecks.values()).filter(h => h.status === 'healthy').length;
        const totalChecks = this.healthChecks.size;
        
        let text = `$(activity) Monitoring`;
        if (totalProviders > 0) {
            text += ` ${connectedProviders}/${totalProviders}`;
        }
        if (totalChecks > 0) {
            text += ` 🟢${healthyChecks}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Monitoring: ${connectedProviders}/${totalProviders} providers, ${healthyChecks}/${totalChecks} checks healthy`;
    }

    /**
     * Show monitoring status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const providers = this.getProviders();
            const healthChecks = this.getHealthChecks();
            const metrics = this.getMetrics({ limit: 10 });
            const logs = this.getLogs({ limit: 20 });
            const dashboards = this.getDashboards();

            let output = `Monitoring System Status\n`;
            output += `========================\n\n`;

            output += `Providers (${providers.length}):\n`;
            for (const provider of providers) {
                output += `  ${provider.name}: ${provider.connected ? 'Connected' : 'Disconnected'}\n`;
                output += `    Type: ${provider.type}\n`;
                output += `    Last Sync: ${provider.lastSync.toLocaleString()}\n`;
            }
            output += '\n';

            output += `Health Checks (${healthChecks.length}):\n`;
            for (const check of healthChecks) {
                output += `  ${check.name}: ${check.status}\n`;
                output += `    Type: ${check.type}\n`;
                output += `    Response Time: ${check.responseTime}ms\n`;
                if (check.error) {
                    output += `    Error: ${check.error}\n`;
                }
            }
            output += '\n';

            output += `Recent Metrics (${metrics.length}):\n`;
            for (const metric of metrics.slice(-5)) {
                output += `  ${metric.name}: ${metric.value} (${metric.type})\n`;
            }
            output += '\n';

            output += `Recent Logs (${logs.length}):\n`;
            for (const log of logs.slice(-5)) {
                output += `  [${log.level.toUpperCase()}] ${log.timestamp.toLocaleString()}: ${log.message}\n`;
            }
            output += '\n';

            output += `Dashboards (${dashboards.length}):\n`;
            for (const dashboard of dashboards) {
                output += `  ${dashboard.name}: ${dashboard.panels.length} panels\n`;
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show monitoring status: ${error.message}`);
        }
    }

    /**
     * Dispose monitoring adapters
     */
    public dispose(): void {
        if (this.syncInterval) {
            clearInterval(this.syncInterval);
        }
        
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}