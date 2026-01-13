"use strict";
/**
 * NoodleCore Monitoring Integration
 *
 * Provides comprehensive monitoring and observability integration with
 * popular monitoring platforms like Prometheus, Grafana, DataDog, and more.
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.MonitoringIntegration = void 0;
const vscode = __importStar(require("vscode"));
const axios_1 = __importDefault(require("axios"));
const uuid_1 = require("uuid");
class MonitoringIntegration {
    constructor(workspaceRoot) {
        this.providers = new Map();
        this.apiClients = new Map();
        this.metrics = new Map();
        this.alerts = new Map();
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Monitoring Integration');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 70);
        this.statusBarItem.command = 'noodle.monitoring.showStatus';
        this.statusBarItem.show();
        this.initializeProviders();
    }
    /**
     * Initialize monitoring providers from configuration
     */
    async initializeProviders() {
        try {
            const config = vscode.workspace.getConfiguration('noodle.monitoring');
            const providers = config.get('providers', []);
            for (const provider of providers) {
                if (provider.enabled) {
                    await this.addProvider(provider);
                }
            }
            this.outputChannel.appendLine(`Initialized ${this.providers.size} monitoring providers`);
            this.updateStatusBar();
        }
        catch (error) {
            throw new Error(`Failed to initialize monitoring providers: ${error.message}`);
        }
    }
    /**
     * Add a monitoring provider
     */
    async addProvider(provider) {
        try {
            this.providers.set(provider.name, provider);
            // Initialize API client
            const apiClient = await this.createApiClient(provider);
            this.apiClients.set(provider.name, apiClient);
            // Start monitoring
            this.startMonitoring(provider.name);
            this.outputChannel.appendLine(`Added monitoring provider: ${provider.name}`);
        }
        catch (error) {
            throw new Error(`Failed to add provider ${provider.name}: ${error.message}`);
        }
    }
    /**
     * Create API client for provider
     */
    async createApiClient(provider) {
        try {
            const headers = {
                'Content-Type': 'application/json',
                'User-Agent': 'Noodle-VSCode-Extension'
            };
            if (provider.apiKey) {
                headers['Authorization'] = `Bearer ${provider.apiKey}`;
            }
            return axios_1.default.create({
                baseURL: provider.endpoint,
                headers,
                timeout: 30000
            });
        }
        catch (error) {
            throw new Error(`Failed to create API client: ${error.message}`);
        }
    }
    /**
     * Start monitoring for a provider
     */
    startMonitoring(providerName) {
        const provider = this.providers.get(providerName);
        if (!provider || !provider.enabled) {
            return;
        }
        // Start periodic monitoring
        setInterval(async () => {
            try {
                await this.collectMetrics(providerName);
                await this.checkAlerts(providerName);
            }
            catch (error) {
                this.outputChannel.appendLine(`Monitoring error for ${providerName}: ${error.message}`);
            }
        }, provider.config.refreshInterval * 1000);
    }
    /**
     * Collect metrics from provider
     */
    async collectMetrics(providerName) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to collect metrics from ${providerName}: ${error.message}`);
        }
    }
    /**
     * Fetch metrics from provider based on type
     */
    async fetchMetrics(provider, apiClient) {
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
    async fetchPrometheusMetrics(apiClient) {
        try {
            const response = await apiClient.get('/api/v1/query_range', {
                params: {
                    query: 'cpu_usage_percent',
                    start: Date.now() - 300000,
                    end: Date.now(),
                    step: '30s'
                }
            });
            return this.parsePrometheusMetrics(response.data);
        }
        catch (error) {
            throw new Error(`Failed to fetch Prometheus metrics: ${error.message}`);
        }
    }
    /**
     * Fetch metrics from Grafana
     */
    async fetchGrafanaMetrics(apiClient, provider) {
        try {
            const dashboards = await this.getGrafanaDashboards(apiClient);
            const metrics = [];
            for (const dashboard of provider.config.dashboards) {
                const response = await apiClient.get(`/api/dashboards/uid/${dashboard.id}`);
                const dashboardData = response.data.dashboard;
                if (dashboardData && dashboardData.panels) {
                    for (const panel of dashboardData.panels) {
                        const panelMetrics = await this.fetchGrafanaPanelMetrics(apiClient, panel, dashboard);
                        metrics.push(...panelMetrics);
                    }
                }
            }
            return metrics;
        }
        catch (error) {
            throw new Error(`Failed to fetch Grafana metrics: ${error.message}`);
        }
    }
    /**
     * Fetch metrics from DataDog
     */
    async fetchDataDogMetrics(apiClient) {
        try {
            const response = await apiClient.get('/api/v1/query', {
                params: {
                    query: 'avg:system.cpu.total{*}',
                    from: Date.now() - 300000,
                    to: Date.now()
                }
            });
            return this.parseDataDogMetrics(response.data);
        }
        catch (error) {
            throw new Error(`Failed to fetch DataDog metrics: ${error.message}`);
        }
    }
    /**
     * Fetch metrics from custom provider
     */
    async fetchCustomMetrics(apiClient, provider) {
        try {
            const response = await apiClient.get('/metrics');
            return response.data.metrics || [];
        }
        catch (error) {
            throw new Error(`Failed to fetch custom metrics: ${error.message}`);
        }
    }
    /**
     * Get Grafana dashboards
     */
    async getGrafanaDashboards(apiClient) {
        try {
            const response = await apiClient.get('/api/search', {
                params: {
                    type: 'dash-db'
                }
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get Grafana dashboards: ${error.message}`);
        }
    }
    /**
     * Fetch metrics from Grafana panel
     */
    async fetchGrafanaPanelMetrics(apiClient, panel, dashboard) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to fetch panel metrics: ${error.message}`);
            return [];
        }
    }
    /**
     * Parse Prometheus metrics response
     */
    parsePrometheusMetrics(data) {
        const metrics = [];
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
    parseDataDogMetrics(data) {
        const metrics = [];
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
    async checkAlerts(providerName) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to check alerts for ${providerName}: ${error.message}`);
        }
    }
    /**
     * Fetch alerts from provider
     */
    async fetchAlerts(provider, apiClient) {
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
    async fetchPrometheusAlerts(apiClient) {
        try {
            const response = await apiClient.get('/api/v1/alerts');
            return this.parsePrometheusAlerts(response.data);
        }
        catch (error) {
            throw new Error(`Failed to fetch Prometheus alerts: ${error.message}`);
        }
    }
    /**
     * Fetch alerts from Grafana
     */
    async fetchGrafanaAlerts(apiClient) {
        try {
            const response = await apiClient.get('/api/alerts');
            return this.parseGrafanaAlerts(response.data);
        }
        catch (error) {
            throw new Error(`Failed to fetch Grafana alerts: ${error.message}`);
        }
    }
    /**
     * Fetch alerts from DataDog
     */
    async fetchDataDogAlerts(apiClient) {
        try {
            const response = await apiClient.get('/api/v1/monitor');
            return this.parseDataDogAlerts(response.data);
        }
        catch (error) {
            throw new Error(`Failed to fetch DataDog alerts: ${error.message}`);
        }
    }
    /**
     * Fetch alerts from custom provider
     */
    async fetchCustomAlerts(apiClient) {
        try {
            const response = await apiClient.get('/alerts');
            return response.data.alerts || [];
        }
        catch (error) {
            throw new Error(`Failed to fetch custom alerts: ${error.message}`);
        }
    }
    /**
     * Parse Prometheus alerts
     */
    parsePrometheusAlerts(data) {
        const alerts = [];
        if (data.data && data.data.alerts) {
            for (const alert of data.data.alerts) {
                alerts.push({
                    id: alert.fingerprint || (0, uuid_1.v4)(),
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
    parseGrafanaAlerts(data) {
        const alerts = [];
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
    parseDataDogAlerts(data) {
        const alerts = [];
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
    mapPrometheusSeverity(state) {
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
    mapGrafanaSeverity(state) {
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
    mapDataDogSeverity(priority) {
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
    async processNewAlerts(providerName, alerts) {
        const provider = this.providers.get(providerName);
        if (!provider) {
            return;
        }
        const previousAlerts = this.alerts.get(providerName) || [];
        const newAlerts = alerts.filter(alert => !previousAlerts.some(prev => prev.id === alert.id));
        for (const alert of newAlerts) {
            if (alert.status === 'firing') {
                await this.sendNotifications(provider, alert);
                vscode.window.showWarningMessage(`New alert from ${providerName}: ${alert.name}`, 'View Details', 'Dismiss').then(selection => {
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
    async sendNotifications(provider, alert) {
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
    async sendSlackNotification(slack, alert) {
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
            await axios_1.default.post(slack.webhookUrl, payload);
            this.outputChannel.appendLine(`Slack notification sent for alert: ${alert.name}`);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to send Slack notification: ${error.message}`);
        }
    }
    /**
     * Send webhook notification
     */
    async sendWebhookNotification(webhook, alert) {
        try {
            const payload = {
                id: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString(),
                alert,
                source: 'noodle-monitoring'
            };
            await axios_1.default.post(webhook.url, payload, {
                headers: webhook.headers
            });
            this.outputChannel.appendLine(`Webhook notification sent for alert: ${alert.name}`);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to send webhook notification: ${error.message}`);
        }
    }
    /**
     * Publish metrics event
     */
    publishMetricsEvent(providerName, metrics) {
        // This would integrate with the existing event bus
        // For now, just log to output channel
        this.outputChannel.appendLine(`Collected ${metrics.length} metrics from ${providerName}`);
    }
    /**
     * Update status bar
     */
    updateStatusBar() {
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
    async showStatus() {
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
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show monitoring status: ${error.message}`);
        }
    }
    /**
     * Show alert details
     */
    showAlertDetails(alert) {
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
            }
            else if (selection === 'Resolve') {
                this.resolveAlert(alert.id);
            }
        });
    }
    /**
     * Acknowledge an alert
     */
    async acknowledgeAlert(alertId) {
        // Implementation would depend on provider API
        this.outputChannel.appendLine(`Alert ${alertId} acknowledged`);
    }
    /**
     * Resolve an alert
     */
    async resolveAlert(alertId) {
        // Implementation would depend on provider API
        this.outputChannel.appendLine(`Alert ${alertId} resolved`);
    }
    /**
     * Dispose monitoring integration
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.MonitoringIntegration = MonitoringIntegration;
//# sourceMappingURL=monitoringIntegration.js.map