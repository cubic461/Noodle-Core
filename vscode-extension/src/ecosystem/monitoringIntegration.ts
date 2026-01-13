/**
 * NoodleCore Monitoring Integration
 * 
 * Provides comprehensive monitoring and observability integration with
 * popular monitoring platforms like Prometheus, Grafana, DataDog, and more.
 */

import * as vscode from 'vscode';
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { v4 as uuidv4 } from 'uuid';

export interface MonitoringProvider {
    name: string;
    type: MonitoringType;
    endpoint: string;
    apiKey?: string;
    enabled: boolean;
    config: MonitoringConfig;
}

export interface MonitoringConfig {
    refreshInterval: number;
    retentionPeriod: number;
    alertThresholds: AlertThresholds;
    dashboards: DashboardConfig[];
    notifications: NotificationConfig;
}

export interface AlertThresholds {
    cpu: number;
    memory: number;
    disk: number;
    network: number;
    responseTime: number;
    errorRate: number;
}

export interface DashboardConfig {
    id: string;
    name: string;
    url: string;
    refreshInterval: number;
    widgets: WidgetConfig[];
}

export interface WidgetConfig {
    id: string;
    type: WidgetType;
    title: string;
    query: string;
    visualization: VisualizationType;
    refreshInterval: number;
}

export interface NotificationConfig {
    email: EmailNotification[];
    slack: SlackNotification[];
    webhook: WebhookNotification[];
}

export interface EmailNotification {
    enabled: boolean;
    recipients: string[];
    thresholds: string[];
}

export interface SlackNotification {
    enabled: boolean;
    webhookUrl: string;
    channel: string;
    thresholds: string[];
}

export interface WebhookNotification {
    enabled: boolean;
    url: string;
    headers: { [key: string]: string };
    thresholds: string[];
}

export interface MonitoringMetric {
    name: string;
    value: number;
    unit: string;
    timestamp: string;
    labels: { [key: string]: string };
    tags: string[];
}

export interface MonitoringAlert {
    id: string;
    name: string;
    severity: AlertSeverity;
    status: AlertStatus;
    message: string;
    source: string;
    timestamp: string;
    resolvedAt?: string;
    acknowledgedAt?: string;
    assignee?: string;
    labels: string[];
    annotations: { [key: string]: string };
}

export interface MonitoringDashboard {
    id: string;
    name: string;
    description: string;
    url: string;
    panels: MonitoringPanel[];
    variables: { [key: string]: string };
    refreshInterval: number;
    timeRange: TimeRange;
}

export interface MonitoringPanel {
    id: string;
    title: string;
    type: PanelType;
    targets: MetricTarget[];
    gridPos: GridPosition;
    options: PanelOptions;
}

export interface MetricTarget {
    expr: string;
    legendFormat?: string;
    interval?: string;
    refId?: string;
}

export interface GridPosition {
    x: number;
    y: number;
    w: number;
    h: number;
}

export interface PanelOptions {
    legend?: LegendOptions;
    tooltip?: TooltipOptions;
    yAxis?: YAxisOptions;
    xAxis?: XAxisOptions;
}

export interface LegendOptions {
    displayMode?: 'list' | 'table' | 'hidden';
    placement?: 'bottom' | 'right';
    calcs?: string[];
}

export interface TooltipOptions {
    mode?: 'single' | 'multi' | 'hidden';
    sort?: number;
    shared?: boolean;
}

export interface YAxisOptions {
    format?: string;
    label?: string;
    logBase?: number;
    max?: number;
    min?: number;
}

export interface XAxisOptions {
    mode?: 'time' | 'series';
    value?: string;
    name?: string;
}

export interface TimeRange {
    from: string;
    to: string;
    step?: string;
}

export type MonitoringType = 'prometheus' | 'grafana' | 'datadog' | 'newrelic' | 'splunk' | 'elastic' | 'custom';
export type WidgetType = 'graph' | 'stat' | 'table' | 'heatmap' | 'gauge' | 'logs' | 'alert';
export type VisualizationType = 'line' | 'bar' | 'pie' | 'table' | 'heatmap' | 'gauge';
export type AlertSeverity = 'critical' | 'warning' | 'info';
export type AlertStatus = 'firing' | 'resolved' | 'acknowledged';
export type PanelType = 'graph' | 'singlestat' | 'table' | 'heatmap' | 'dashboardlist';

export class MonitoringIntegration {
    private workspaceRoot: string;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private providers: Map<string, MonitoringProvider> = new Map();
    private apiClients: Map<string, AxiosInstance> = new Map();
    private metrics: Map<string, MonitoringMetric[]> = new Map();
    private alerts: Map<string, MonitoringAlert[]> = new Map();

    constructor(workspaceRoot: string) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Monitoring Integration');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            70
        );
        this.statusBarItem.command = 'noodle.monitoring.showStatus';
        this.statusBarItem.show();
        
        this.initializeProviders();
    }

    /**
     * Initialize monitoring providers from configuration
     */
    private async initializeProviders(): Promise<void> {
        try {
            const config = vscode.workspace.getConfiguration('noodle.monitoring');
            const providers = config.get<MonitoringProvider[]>('providers', []);
            
            for (const provider of providers) {
                if (provider.enabled) {
                    await this.addProvider(provider);
                }
            }

            this.outputChannel.appendLine(`Initialized ${this.providers.size} monitoring providers`);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to initialize monitoring providers: ${error.message}`);
        }
    }

    /**
     * Add a monitoring provider
     */
    public async addProvider(provider: MonitoringProvider): Promise<void> {
        try {
            this.providers.set(provider.name, provider);
            
            // Initialize API client
            const apiClient = await this.createApiClient(provider);
            this.apiClients.set(provider.name, apiClient);
            
            // Start monitoring
            this.startMonitoring(provider.name);
            
            this.outputChannel.appendLine(`Added monitoring provider: ${provider.name}`);
        } catch (error) {
            throw new Error(`Failed to add provider ${provider.name}: ${error.message}`);
        }
    }

    /**
     * Create API client for provider
     */
    private async createApiClient(provider: MonitoringProvider): Promise<AxiosInstance> {
        try {
            const headers: { [key: string]: string } = {
                'Content-Type': 'application/json',
                'User-Agent': 'Noodle-VSCode-Extension'
            };

            if (provider.apiKey) {
                headers['Authorization'] = `Bearer ${provider.apiKey}`;
            }

            return axios.create({
                baseURL: provider.endpoint,
                headers,
                timeout: 30000
            });
        } catch (error) {
            throw new Error(`Failed to create API client: ${error.message}`);
        }
    }

    /**
     * Start monitoring for a provider
     */
    private startMonitoring(providerName: string): void {
        const provider = this.providers.get(providerName);
        if (!provider || !provider.enabled) {
            return;
        }

        // Start periodic monitoring
        setInterval(async () => {
            try {
                await this.collectMetrics(providerName);
                await this.checkAlerts(providerName);
            } catch (error) {
                this.outputChannel.appendLine(`Monitoring error for ${providerName}: ${error.message}`);
            }
        }, provider.config.refreshInterval * 1000);
    }

    /**
     * Collect metrics from provider
     */
    private async collectMetrics(providerName: string): Promise<void> {
        const provider = this.providers.get(providerName);
        const apiClient = this.apiClients.get(providerName);
        
        if (!provider || !apiClient) {
            return;
        }

        try {
            const metrics = await this.fetchMetrics(provider, apiClient);
            this.metrics.set(providerName, metrics);
            
            // Publish metrics event
            this.publishMetricsEvent(providerName, metrics);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to collect metrics from ${providerName}: ${error.message}`);
        }
    }

    /**
     * Fetch metrics from provider based on type
     */
    private async fetchMetrics(
        provider: MonitoringProvider,
        apiClient: AxiosInstance
    ): Promise<MonitoringMetric[]> {
        switch (provider.type) {
            case 'prometheus':
                return await this.fetchPrometheusMetrics(apiClient);
            case 'grafana':
                return await this.fetchGrafanaMetrics(apiClient, provider);
            case 'datadog':
                return await this.fetchDataDogMetrics(apiClient);
            default:
                return await this.fetchCustomMetrics(apiClient, provider);
        }
    }

    /**
     * Fetch metrics from Prometheus
     */
    private async fetchPrometheusMetrics(apiClient: AxiosInstance): Promise<MonitoringMetric[]> {
        try {
            const response = await apiClient.get('/api/v1/query_range', {
                params: {
                    query: 'cpu_usage_percent',
                    start: Date.now() - 300000, // Last 5 minutes
                    end: Date.now(),
                    step: '30s'
                }
            });

            return this.parsePrometheusMetrics(response.data);
        } catch (error) {
            throw new Error(`Failed to fetch Prometheus metrics: ${error.message}`);
        }
    }

    /**
     * Fetch metrics from Grafana
     */
    private async fetchGrafanaMetrics(
        apiClient: AxiosInstance,
        provider: MonitoringProvider
    ): Promise<MonitoringMetric[]> {
        try {
            const dashboards = await this.getGrafanaDashboards(apiClient);
            const metrics: MonitoringMetric[] = [];

            for (const dashboard of provider.config.dashboards) {
                const response = await apiClient.get(
                    `/api/dashboards/uid/${dashboard.id}`
                );
                
                const dashboardData = response.data.dashboard;
                if (dashboardData && dashboardData.panels) {
                    for (const panel of dashboardData.panels) {
                        const panelMetrics = await this.fetchGrafanaPanelMetrics(
                            apiClient,
                            panel,
                            dashboard
                        );
                        metrics.push(...panelMetrics);
                    }
                }
            }

            return metrics;
        } catch (error) {
            throw new Error(`Failed to fetch Grafana metrics: ${error.message}`);
        }
    }

    /**
     * Fetch metrics from DataDog
     */
    private async fetchDataDogMetrics(apiClient: AxiosInstance): Promise<MonitoringMetric[]> {
        try {
            const response = await apiClient.get('/api/v1/query', {
                params: {
                    query: 'avg:system.cpu.total{*}',
                    from: Date.now() - 300000,
                    to: Date.now()
                }
            });

            return this.parseDataDogMetrics(response.data);
        } catch (error) {
            throw new Error(`Failed to fetch DataDog metrics: ${error.message}`);
        }
    }

    /**
     * Fetch metrics from custom provider
     */
    private async fetchCustomMetrics(
        apiClient: AxiosInstance,
        provider: MonitoringProvider
    ): Promise<MonitoringMetric[]> {
        try {
            const response = await apiClient.get('/metrics');
            return response.data.metrics || [];
        } catch (error) {
            throw new Error(`Failed to fetch custom metrics: ${error.message}`);
        }
    }

    /**
     * Get Grafana dashboards
     */
    private async getGrafanaDashboards(apiClient: AxiosInstance): Promise<any[]> {
        try {
            const response = await apiClient.get('/api/search', {
                params: {
                    type: 'dash-db'
                }
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get Grafana dashboards: ${error.message}`);
        }
    }

    /**
     * Fetch metrics from Grafana panel
     */
    private async fetchGrafanaPanelMetrics(
        apiClient: AxiosInstance,
        panel: any,
        dashboard: any
    ): Promise<MonitoringMetric[]> {
        try {
            const response = await apiClient.get('/api/datasources/proxy/api/v1/query_range', {
                params: {
                    query: panel.targets[0]?.expr || '',
                    start: Date.now() - 300000,
                    end: Date.now(),
                    step: '30s'
                }
            });

            return this.parsePrometheusMetrics(response.data);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to fetch panel metrics: ${error.message}`);
            return [];
        }
    }

    /**
     * Parse Prometheus metrics response
     */
    private parsePrometheusMetrics(data: any): MonitoringMetric[] {
        const metrics: MonitoringMetric[] = [];

        if (data.data && data.data.result) {
            for (const result of data.data.result) {
                if (result.values) {
                    for (const [timestamp, value] of result.values) {
                        metrics.push({
                            name: result.metric.__name__ || 'unknown',
                            value: parseFloat(value),
                            unit: result.metric.unit || '',
                            timestamp: new Date(timestamp * 1000).toISOString(),
                            labels: result.metric,
                            tags: Object.keys(result.metric).map(key => `${key}=${result.metric[key]}`)
                        });
                    }
                }
            }
        }

        return metrics;
    }

    /**
     * Parse DataDog metrics response
     */
    private parseDataDogMetrics(data: any): MonitoringMetric[] {
        const metrics: MonitoringMetric[] = [];

        if (data.series) {
            for (const series of data.series) {
                if (series.pointlist) {
                    for (const point of series.pointlist) {
                        metrics.push({
                            name: series.metric,
                            value: point[1],
                            unit: '',
                            timestamp: new Date(point[0] * 1000).toISOString(),
                            labels: series.tags || {},
                            tags: series.tags || []
                        });
                    }
                }
            }
        }

        return metrics;
    }

    /**
     * Check for alerts
     */
    private async checkAlerts(providerName: string): Promise<void> {
        const provider = this.providers.get(providerName);
        const apiClient = this.apiClients.get(providerName);
        
        if (!provider || !apiClient) {
            return;
        }

        try {
            const alerts = await this.fetchAlerts(provider, apiClient);
            this.alerts.set(providerName, alerts);
            
            // Check for new alerts
            await this.processNewAlerts(providerName, alerts);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to check alerts for ${providerName}: ${error.message}`);
        }
    }

    /**
     * Fetch alerts from provider
     */
    private async fetchAlerts(
        provider: MonitoringProvider,
        apiClient: AxiosInstance
    ): Promise<MonitoringAlert[]> {
        switch (provider.type) {
            case 'prometheus':
                return await this.fetchPrometheusAlerts(apiClient);
            case 'grafana':
                return await this.fetchGrafanaAlerts(apiClient);
            case 'datadog':
                return await this.fetchDataDogAlerts(apiClient);
            default:
                return await this.fetchCustomAlerts(apiClient);
        }
    }

    /**
     * Fetch alerts from Prometheus
     */
    private async fetchPrometheusAlerts(apiClient: AxiosInstance): Promise<MonitoringAlert[]> {
        try {
            const response = await apiClient.get('/api/v1/alerts');
            return this.parsePrometheusAlerts(response.data);
        } catch (error) {
            throw new Error(`Failed to fetch Prometheus alerts: ${error.message}`);
        }
    }

    /**
     * Fetch alerts from Grafana
     */
    private async fetchGrafanaAlerts(apiClient: AxiosInstance): Promise<MonitoringAlert[]> {
        try {
            const response = await apiClient.get('/api/alerts');
            return this.parseGrafanaAlerts(response.data);
        } catch (error) {
            throw new Error(`Failed to fetch Grafana alerts: ${error.message}`);
        }
    }

    /**
     * Fetch alerts from DataDog
     */
    private async fetchDataDogAlerts(apiClient: AxiosInstance): Promise<MonitoringAlert[]> {
        try {
            const response = await apiClient.get('/api/v1/monitor');
            return this.parseDataDogAlerts(response.data);
        } catch (error) {
            throw new Error(`Failed to fetch DataDog alerts: ${error.message}`);
        }
    }

    /**
     * Fetch alerts from custom provider
     */
    private async fetchCustomAlerts(apiClient: AxiosInstance): Promise<MonitoringAlert[]> {
        try {
            const response = await apiClient.get('/alerts');
            return response.data.alerts || [];
        } catch (error) {
            throw new Error(`Failed to fetch custom alerts: ${error.message}`);
        }
    }

    /**
     * Parse Prometheus alerts
     */
    private parsePrometheusAlerts(data: any): MonitoringAlert[] {
        const alerts: MonitoringAlert[] = [];

        if (data.data && data.data.alerts) {
            for (const alert of data.data.alerts) {
                alerts.push({
                    id: alert.fingerprint || uuidv4(),
                    name: alert.labels.alertname || 'Unknown',
                    severity: this.mapPrometheusSeverity(alert.state),
                    status: alert.state === 'firing' ? 'firing' : 'resolved',
                    message: alert.annotations.summary || alert.annotations.description || '',
                    source: 'prometheus',
                    timestamp: alert.startsAt,
                    resolvedAt: alert.endsAt,
                    labels: Object.values(alert.labels || {}),
                    annotations: alert.annotations || {}
                });
            }
        }

        return alerts;
    }

    /**
     * Parse Grafana alerts
     */
    private parseGrafanaAlerts(data: any): MonitoringAlert[] {
        const alerts: MonitoringAlert[] = [];

        if (data) {
            for (const alert of data) {
                alerts.push({
                    id: alert.id.toString(),
                    name: alert.name,
                    severity: this.mapGrafanaSeverity(alert.state),
                    status: alert.state === 'alerting' ? 'firing' : 'resolved',
                    message: alert.message || '',
                    source: 'grafana',
                    timestamp: alert.newStateDate,
                    resolvedAt: alert.state === 'ok' ? alert.newStateDate : undefined,
                    labels: alert.labels || [],
                    annotations: {}
                });
            }
        }

        return alerts;
    }

    /**
     * Parse DataDog alerts
     */
    private parseDataDogAlerts(data: any): MonitoringAlert[] {
        const alerts: MonitoringAlert[] = [];

        if (data) {
            for (const monitor of data) {
                alerts.push({
                    id: monitor.id.toString(),
                    name: monitor.name,
                    severity: this.mapDataDogSeverity(monitor.options.priority),
                    status: monitor.state === 'OK' ? 'resolved' : 'firing',
                    message: monitor.message || '',
                    source: 'datadog',
                    timestamp: monitor.last_triggered_ts.toString(),
                    resolvedAt: monitor.state === 'OK' ? monitor.last_triggered_ts.toString() : undefined,
                    labels: monitor.tags || [],
                    annotations: {}
                });
            }
        }

        return alerts;
    }

    /**
     * Map Prometheus severity
     */
    private mapPrometheusSeverity(state: string): AlertSeverity {
        switch (state) {
            case 'firing':
                return 'critical';
            case 'pending':
                return 'warning';
            default:
                return 'info';
        }
    }

    /**
     * Map Grafana severity
     */
    private mapGrafanaSeverity(state: string): AlertSeverity {
        switch (state) {
            case 'alerting':
                return 'critical';
            case 'pending':
                return 'warning';
            default:
                return 'info';
        }
    }

    /**
     * Map DataDog severity
     */
    private mapDataDogSeverity(priority: string): AlertSeverity {
        switch (priority) {
            case '1':
                return 'critical';
            case '2':
                return 'warning';
            default:
                return 'info';
        }
    }

    /**
     * Process new alerts and send notifications
     */
    private async processNewAlerts(
        providerName: string,
        alerts: MonitoringAlert[]
    ): Promise<void> {
        const provider = this.providers.get(providerName);
        if (!provider) {
            return;
        }

        const previousAlerts = this.alerts.get(providerName) || [];
        const newAlerts = alerts.filter(alert => 
            !previousAlerts.some(prev => prev.id === alert.id)
        );

        for (const alert of newAlerts) {
            if (alert.status === 'firing') {
                await this.sendNotifications(provider, alert);
                vscode.window.showWarningMessage(
                    `New alert from ${providerName}: ${alert.name}`,
                    'View Details',
                    'Dismiss'
                ).then(selection => {
                    if (selection === 'View Details') {
                        this.showAlertDetails(alert);
                    }
                });
            }
        }
    }

    /**
     * Send notifications for alert
     */
    private async sendNotifications(
        provider: MonitoringProvider,
        alert: MonitoringAlert
    ): Promise<void> {
        const notifications = provider.config.notifications;

        // Send email notifications
        for (const email of notifications.email) {
            if (email.enabled && email.recipients.length > 0) {
                // Implementation would depend on email service
                this.outputChannel.appendLine(`Email notification sent for alert: ${alert.name}`);
            }
        }

        // Send Slack notifications
        for (const slack of notifications.slack) {
            if (slack.enabled && slack.webhookUrl) {
                await this.sendSlackNotification(slack, alert);
            }
        }

        // Send webhook notifications
        for (const webhook of notifications.webhook) {
            if (webhook.enabled && webhook.url) {
                await this.sendWebhookNotification(webhook, alert);
            }
        }
    }

    /**
     * Send Slack notification
     */
    private async sendSlackNotification(
        slack: SlackNotification,
        alert: MonitoringAlert
    ): Promise<void> {
        try {
            const payload = {
                text: `Alert: ${alert.name}`,
                attachments: [{
                    color: alert.severity === 'critical' ? 'danger' : 'warning',
                    fields: [
                        { title: 'Severity', value: alert.severity, short: true },
                        { title: 'Status', value: alert.status, short: true },
                        { title: 'Message', value: alert.message, short: false },
                        { title: 'Source', value: alert.source, short: true }
                    ]
                }]
            };

            await axios.post(slack.webhookUrl, payload);
            this.outputChannel.appendLine(`Slack notification sent for alert: ${alert.name}`);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to send Slack notification: ${error.message}`);
        }
    }

    /**
     * Send webhook notification
     */
    private async sendWebhookNotification(
        webhook: WebhookNotification,
        alert: MonitoringAlert
    ): Promise<void> {
        try {
            const payload = {
                id: uuidv4(),
                timestamp: new Date().toISOString(),
                alert,
                source: 'noodle-monitoring'
            };

            await axios.post(webhook.url, payload, {
                headers: webhook.headers
            });

            this.outputChannel.appendLine(`Webhook notification sent for alert: ${alert.name}`);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to send webhook notification: ${error.message}`);
        }
    }

    /**
     * Publish metrics event
     */
    private publishMetricsEvent(providerName: string, metrics: MonitoringMetric[]): void {
        // This would integrate with the existing event bus
        // For now, just log to output channel
        this.outputChannel.appendLine(`Collected ${metrics.length} metrics from ${providerName}`);
    }

    /**
     * Update status bar
     */
    private updateStatusBar(): void {
        const activeProviders = Array.from(this.providers.values())
            .filter(p => p.enabled)
            .length;

        let totalAlerts = 0;
        let criticalAlerts = 0;

        for (const alerts of this.alerts.values()) {
            const firing = alerts.filter(a => a.status === 'firing');
            totalAlerts += firing.length;
            criticalAlerts += firing.filter(a => a.severity === 'critical').length;
        }

        let text = `$(pulse) ${activeProviders} providers`;
        if (totalAlerts > 0) {
            text += ` ${criticalAlerts > 0 ? '$(warning) ' : ''}${totalAlerts} alerts`;
        }

        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `
Active Providers: ${activeProviders}
Total Alerts: ${totalAlerts}
Critical Alerts: ${criticalAlerts}
        `.trim();
    }

    /**
     * Show monitoring status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            let output = `Monitoring Status\n`;
            output += `================\n\n`;

            for (const [name, provider] of this.providers) {
                output += `Provider: ${name}\n`;
                output += `Type: ${provider.type}\n`;
                output += `Status: ${provider.enabled ? 'Enabled' : 'Disabled'}\n`;
                output += `Endpoint: ${provider.endpoint}\n\n`;

                if (provider.enabled) {
                    const metrics = this.metrics.get(name) || [];
                    const alerts = this.alerts.get(name) || [];

                    output += `Metrics: ${metrics.length} collected\n`;
                    output += `Alerts: ${alerts.filter(a => a.status === 'firing').length} firing\n\n`;
                }
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show monitoring status: ${error.message}`);
        }
    }

    /**
     * Show alert details
     */
    public showAlertDetails(alert: MonitoringAlert): void {
        const message = `
Alert Details
=============
Name: ${alert.name}
Severity: ${alert.severity}
Status: ${alert.status}
Source: ${alert.source}
Message: ${alert.message}
Timestamp: ${new Date(alert.timestamp).toLocaleString()}
${alert.resolvedAt ? `Resolved: ${new Date(alert.resolvedAt).toLocaleString()}` : ''}
${alert.assignee ? `Assignee: ${alert.assignee}` : ''}

Labels: ${alert.labels.join(', ')}
        `.trim();

        vscode.window.showInformationMessage(message, 'Acknowledge', 'Resolve').then(selection => {
            if (selection === 'Acknowledge') {
                this.acknowledgeAlert(alert.id);
            } else if (selection === 'Resolve') {
                this.resolveAlert(alert.id);
            }
        });
    }

    /**
     * Acknowledge an alert
     */
    private async acknowledgeAlert(alertId: string): Promise<void> {
        // Implementation would depend on provider API
        this.outputChannel.appendLine(`Alert ${alertId} acknowledged`);
    }

    /**
     * Resolve an alert
     */
    private async resolveAlert(alertId: string): Promise<void> {
        // Implementation would depend on provider API
        this.outputChannel.appendLine(`Alert ${alertId} resolved`);
    }

    /**
     * Dispose monitoring integration
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}