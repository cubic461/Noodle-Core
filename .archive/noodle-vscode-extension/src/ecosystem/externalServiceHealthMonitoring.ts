/**
 * NoodleCore External Service Health Monitoring
 * 
 * Provides comprehensive health monitoring for external services and APIs
 * with real-time alerts, metrics collection, and automated recovery.
 */

import * as vscode from 'vscode';
import * as axios from 'axios';
import * as fs from 'fs';
import * as path from 'path';

export interface ServiceHealth {
    id: string;
    name: string;
    type: 'api' | 'database' | 'cache' | 'storage' | 'message-queue' | 'external-api';
    url: string;
    method: 'GET' | 'POST' | 'PUT' | 'DELETE';
    headers: { [key: string]: string };
    timeout: number;
    interval: number;
    expectedStatus: number[];
    expectedResponse?: {
        field?: string;
        value?: any;
        type?: 'string' | 'number' | 'boolean' | 'object' | 'array';
    };
    enabled: boolean;
    lastCheck: Date;
    status: 'healthy' | 'degraded' | 'unhealthy' | 'unknown';
    responseTime: number;
    errorCount: number;
    consecutiveFailures: number;
    uptime: number;
    downtime: number;
    lastError?: string;
    metadata: { [key: string]: any };
}

export interface HealthAlert {
    id: string;
    serviceId: string;
    type: 'critical' | 'warning' | 'info';
    message: string;
    timestamp: Date;
    resolved: boolean;
    resolvedAt?: Date;
    metadata: { [key: string]: any };
}

export interface HealthMetric {
    id: string;
    serviceId: string;
    metric: string;
    value: number;
    timestamp: Date;
    tags: { [key: string]: string };
}

export interface HealthThreshold {
    id: string;
    serviceId: string;
    metric: string;
    operator: 'gt' | 'lt' | 'eq' | 'gte' | 'lte';
    value: number;
    severity: 'critical' | 'warning' | 'info';
    enabled: boolean;
}

export interface HealthReport {
    timestamp: Date;
    totalServices: number;
    healthyServices: number;
    degradedServices: number;
    unhealthyServices: number;
    alerts: HealthAlert[];
    metrics: HealthMetric[];
    uptime: number;
    responseTime: {
        average: number;
        min: number;
        max: number;
        p95: number;
        p99: number;
    };
}

export class ExternalServiceHealthMonitoring {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private services: Map<string, ServiceHealth> = new Map();
    private alerts: Map<string, HealthAlert> = new Map();
    private metrics: Map<string, HealthMetric[]> = new Map();
    private thresholds: Map<string, HealthThreshold[]> = new Map();
    private monitoringInterval: NodeJS.Timeout | null = null;
    private context: vscode.ExtensionContext;
    private alertHistory: HealthAlert[] = [];

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Service Health');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            100
        );
        this.statusBarItem.command = 'noodle.health.showStatus';
        
        this.initializeHealthMonitoring();
    }

    /**
     * Initialize health monitoring
     */
    private async initializeHealthMonitoring(): Promise<void> {
        try {
            // Load service configurations
            await this.loadServices();
            
            // Load health thresholds
            await this.loadThresholds();
            
            // Start monitoring
            this.startMonitoring();
            
            this.outputChannel.appendLine('External service health monitoring initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Health monitoring initialization failed: ${error.message}`);
        }
    }

    /**
     * Load service configurations
     */
    private async loadServices(): Promise<void> {
        try {
            const servicesDir = path.join(this.context.globalStorageUri.fsPath, 'services');
            if (!fs.existsSync(servicesDir)) {
                fs.mkdirSync(servicesDir, { recursive: true });
                return;
            }
            
            const files = fs.readdirSync(servicesDir);
            const serviceFiles = files.filter(file => file.endsWith('.json'));
            
            for (const file of serviceFiles) {
                const filePath = path.join(servicesDir, file);
                const serviceData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                
                const service: ServiceHealth = {
                    ...serviceData,
                    lastCheck: new Date(serviceData.lastCheck || Date.now()),
                    status: serviceData.status || 'unknown',
                    responseTime: serviceData.responseTime || 0,
                    errorCount: serviceData.errorCount || 0,
                    consecutiveFailures: serviceData.consecutiveFailures || 0,
                    uptime: serviceData.uptime || 0,
                    downtime: serviceData.downtime || 0,
                    metadata: serviceData.metadata || {}
                };
                
                this.services.set(service.id, service);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.services.size} services for monitoring`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load services: ${error.message}`);
        }
    }

    /**
     * Load health thresholds
     */
    private async loadThresholds(): Promise<void> {
        try {
            const thresholdsDir = path.join(this.context.globalStorageUri.fsPath, 'thresholds');
            if (!fs.existsSync(thresholdsDir)) {
                fs.mkdirSync(thresholdsDir, { recursive: true });
                return;
            }
            
            const files = fs.readdirSync(thresholdsDir);
            const thresholdFiles = files.filter(file => file.endsWith('.json'));
            
            for (const file of thresholdFiles) {
                const filePath = path.join(thresholdsDir, file);
                const thresholdData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                
                const threshold: HealthThreshold = {
                    ...thresholdData
                };
                
                if (!this.thresholds.has(threshold.serviceId)) {
                    this.thresholds.set(threshold.serviceId, []);
                }
                this.thresholds.get(threshold.serviceId)!.push(threshold);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.thresholds.size} threshold configurations`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load thresholds: ${error.message}`);
        }
    }

    /**
     * Add service for monitoring
     */
    public async addService(service: ServiceHealth): Promise<void> {
        try {
            // Validate service
            this.validateService(service);
            
            this.services.set(service.id, service);
            await this.saveService(service);
            
            this.outputChannel.appendLine(`Added service for monitoring: ${service.name}`);
            this.emit('serviceAdded', service);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add service: ${error.message}`);
        }
    }

    /**
     * Remove service from monitoring
     */
    public removeService(id: string): boolean {
        const service = this.services.get(id);
        if (!service) {
            return false;
        }

        this.services.delete(id);
        this.removeServiceFile(id);
        
        // Remove related alerts
        const serviceAlerts = Array.from(this.alerts.values())
            .filter(a => a.serviceId === id);
        for (const alert of serviceAlerts) {
            this.alerts.delete(alert.id);
        }
        
        // Remove related metrics
        this.metrics.delete(id);
        
        this.outputChannel.appendLine(`Removed service from monitoring: ${service.name}`);
        this.emit('serviceRemoved', service);
        this.updateStatusBar();
        return true;
    }

    /**
     * Validate service configuration
     */
    private validateService(service: ServiceHealth): void {
        if (!service.id || !service.name || !service.url) {
            throw new Error('Service must have an ID, name, and URL');
        }
        
        if (!['GET', 'POST', 'PUT', 'DELETE'].includes(service.method)) {
            throw new Error('Invalid HTTP method');
        }
        
        if (service.timeout <= 0) {
            throw new Error('Timeout must be greater than 0');
        }
        
        if (service.interval <= 0) {
            throw new Error('Interval must be greater than 0');
        }
    }

    /**
     * Save service configuration
     */
    private async saveService(service: ServiceHealth): Promise<void> {
        const servicesDir = path.join(this.context.globalStorageUri.fsPath, 'services');
        if (!fs.existsSync(servicesDir)) {
            fs.mkdirSync(servicesDir, { recursive: true });
        }
        
        const filePath = path.join(servicesDir, `${service.id}.json`);
        fs.writeFileSync(filePath, JSON.stringify(service, null, 2));
    }

    /**
     * Remove service file
     */
    private removeServiceFile(id: string): void {
        const servicesDir = path.join(this.context.globalStorageUri.fsPath, 'services');
        const filePath = path.join(servicesDir, `${id}.json`);
        
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }

    /**
     * Start monitoring services
     */
    private startMonitoring(): void {
        // Check monitoring interval from configuration
        const config = vscode.workspace.getConfiguration('noodle.health');
        const interval = config.get<number>('monitoringInterval', 30000); // 30 seconds default
        
        this.monitoringInterval = setInterval(async () => {
            await this.checkAllServices();
        }, interval);
        
        // Initial check
        this.checkAllServices();
    }

    /**
     * Check all services
     */
    private async checkAllServices(): Promise<void> {
        const enabledServices = Array.from(this.services.values())
            .filter(s => s.enabled);
        
        for (const service of enabledServices) {
            await this.checkService(service.id);
        }
        
        // Generate health report
        await this.generateHealthReport();
    }

    /**
     * Check individual service
     */
    private async checkService(serviceId: string): Promise<void> {
        const service = this.services.get(serviceId);
        if (!service || !service.enabled) {
            return;
        }
        
        const startTime = Date.now();
        let status: ServiceHealth['status'] = 'unknown';
        let responseTime = 0;
        let error = '';
        let success = false;
        
        try {
            const response = await axios({
                method: service.method,
                url: service.url,
                headers: service.headers,
                timeout: service.timeout,
                validateStatus: (status) => service.expectedStatus.includes(status)
            });
            
            responseTime = Date.now() - startTime;
            success = true;
            
            // Check expected response
            if (service.expectedResponse) {
                const expected = service.expectedResponse;
                const actual = expected.field ? response.data[expected.field] : response.data;
                
                if (expected.type === 'string' && typeof actual !== 'string') {
                    throw new Error(`Expected string but got ${typeof actual}`);
                } else if (expected.type === 'number' && typeof actual !== 'number') {
                    throw new Error(`Expected number but got ${typeof actual}`);
                } else if (expected.type === 'boolean' && typeof actual !== 'boolean') {
                    throw new Error(`Expected boolean but got ${typeof actual}`);
                } else if (expected.type === 'object' && typeof actual !== 'object') {
                    throw new Error(`Expected object but got ${typeof actual}`);
                } else if (expected.type === 'array' && !Array.isArray(actual)) {
                    throw new Error(`Expected array but got ${typeof actual}`);
                } else if (expected.value !== undefined && actual !== expected.value) {
                    throw new Error(`Expected value ${expected.value} but got ${actual}`);
                }
            }
            
            // Determine status based on response time
            if (responseTime < 1000) {
                status = 'healthy';
            } else if (responseTime < 5000) {
                status = 'degraded';
            } else {
                status = 'unhealthy';
            }
            
        } catch (err) {
            responseTime = Date.now() - startTime;
            error = err.message;
            status = 'unhealthy';
            success = false;
        }
        
        // Update service status
        service.lastCheck = new Date();
        service.status = status;
        service.responseTime = responseTime;
        service.lastError = error;
        
        if (success) {
            service.consecutiveFailures = 0;
            service.uptime += responseTime;
        } else {
            service.consecutiveFailures++;
            service.errorCount++;
            service.downtime += responseTime;
        }
        
        // Save updated service
        await this.saveService(service);
        
        // Record metric
        this.recordMetric(serviceId, 'response_time', responseTime);
        this.recordMetric(serviceId, 'status', status === 'healthy' ? 1 : 0);
        
        // Check thresholds
        await this.checkThresholds(serviceId);
        
        // Generate alerts if needed
        if (!success || status === 'unhealthy') {
            await this.generateAlert(serviceId, status, error);
        }
        
        this.emit('serviceChecked', service);
    }

    /**
     * Check health thresholds
     */
    private async checkThresholds(serviceId: string): Promise<void> {
        const serviceThresholds = this.thresholds.get(serviceId) || [];
        const service = this.services.get(serviceId);
        
        for (const threshold of serviceThresholds) {
            if (!threshold.enabled) {
                continue;
            }
            
            let currentValue: number;
            
            switch (threshold.metric) {
                case 'response_time':
                    currentValue = service?.responseTime || 0;
                    break;
                case 'error_count':
                    currentValue = service?.errorCount || 0;
                    break;
                case 'consecutive_failures':
                    currentValue = service?.consecutiveFailures || 0;
                    break;
                case 'uptime':
                    currentValue = service?.uptime || 0;
                    break;
                case 'downtime':
                    currentValue = service?.downtime || 0;
                    break;
                default:
                    continue;
            }
            
            let triggered = false;
            
            switch (threshold.operator) {
                case 'gt':
                    triggered = currentValue > threshold.value;
                    break;
                case 'lt':
                    triggered = currentValue < threshold.value;
                    break;
                case 'eq':
                    triggered = currentValue === threshold.value;
                    break;
                case 'gte':
                    triggered = currentValue >= threshold.value;
                    break;
                case 'lte':
                    triggered = currentValue <= threshold.value;
                    break;
            }
            
            if (triggered) {
                await this.generateAlert(serviceId, threshold.severity, 
                    `Threshold exceeded: ${threshold.metric} ${threshold.operator} ${threshold.value} (current: ${currentValue})`,
                    threshold);
            }
        }
    }

    /**
     * Generate health alert
     */
    private async generateAlert(serviceId: string, type: ServiceHealth['status'] | HealthThreshold['severity'], message: string, threshold?: HealthThreshold): Promise<void> {
        const service = this.services.get(serviceId);
        if (!service) {
            return;
        }
        
        const alert: HealthAlert = {
            id: `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            serviceId,
            type: type === 'critical' ? 'critical' : type === 'warning' ? 'warning' : 'info',
            message,
            timestamp: new Date(),
            resolved: false,
            metadata: {
                service: service.name,
                threshold: threshold?.id,
                responseTime: service.responseTime,
                errorCount: service.errorCount
            }
        };
        
        this.alerts.set(alert.id, alert);
        this.alertHistory.push(alert);
        
        // Keep only last 1000 alerts
        if (this.alertHistory.length > 1000) {
            this.alertHistory = this.alertHistory.slice(-1000);
        }
        
        this.outputChannel.appendLine(`[${alert.type.toUpperCase()}] ${service.name}: ${message}`);
        this.emit('alertGenerated', alert);
        
        // Send notification if configured
        await this.sendAlertNotification(alert);
    }

    /**
     * Send alert notification
     */
    private async sendAlertNotification(alert: HealthAlert): Promise<void> {
        const config = vscode.workspace.getConfiguration('noodle.health.notifications');
        const enabled = config.get<boolean>('enabled', true);
        
        if (!enabled) {
            return;
        }
        
        const channels = config.get<string[]>('channels', ['console']);
        
        for (const channel of channels) {
            if (channel === 'console') {
                this.outputChannel.appendLine(`ALERT: ${alert.message}`);
            } else if (channel === 'vscode') {
                vscode.window.showWarningMessage(`Service Health Alert: ${alert.message}`);
            }
            // Add other notification channels (email, Slack, etc.) as needed
        }
    }

    /**
     * Record health metric
     */
    private recordMetric(serviceId: string, metric: string, value: number): void {
        const healthMetric: HealthMetric = {
            id: `metric_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`,
            serviceId,
            metric,
            value,
            timestamp: new Date(),
            tags: {
                service: this.services.get(serviceId)?.name || 'unknown'
            }
        };
        
        if (!this.metrics.has(serviceId)) {
            this.metrics.set(serviceId, []);
        }
        
        const serviceMetrics = this.metrics.get(serviceId)!;
        serviceMetrics.push(healthMetric);
        
        // Keep only last 1000 metrics per service
        if (serviceMetrics.length > 1000) {
            this.metrics.set(serviceId, serviceMetrics.slice(-1000));
        }
    }

    /**
     * Generate health report
     */
    private async generateHealthReport(): Promise<HealthReport> {
        const totalServices = this.services.size;
        const enabledServices = Array.from(this.services.values()).filter(s => s.enabled);
        const healthyServices = enabledServices.filter(s => s.status === 'healthy').length;
        const degradedServices = enabledServices.filter(s => s.status === 'degraded').length;
        const unhealthyServices = enabledServices.filter(s => s.status === 'unhealthy').length;
        
        // Calculate response time statistics
        const allResponseTimes = Array.from(this.services.values())
            .map(s => s.responseTime)
            .filter(t => t > 0);
        
        const responseTimeStats = {
            average: allResponseTimes.length > 0 ? 
                allResponseTimes.reduce((a, b) => a + b, 0) / allResponseTimes.length : 0,
            min: allResponseTimes.length > 0 ? Math.min(...allResponseTimes) : 0,
            max: allResponseTimes.length > 0 ? Math.max(...allResponseTimes) : 0,
            p95: this.calculatePercentile(allResponseTimes, 95),
            p99: this.calculatePercentile(allResponseTimes, 99)
        };
        
        // Get active alerts
        const activeAlerts = Array.from(this.alerts.values())
            .filter(a => !a.resolved);
        
        const report: HealthReport = {
            timestamp: new Date(),
            totalServices,
            healthyServices,
            degradedServices,
            unhealthyServices,
            alerts: activeAlerts,
            metrics: Array.from(this.metrics.values()).flat(),
            uptime: healthyServices / totalServices * 100,
            responseTime: responseTimeStats
        };
        
        this.emit('healthReportGenerated', report);
        return report;
    }

    /**
     * Calculate percentile
     */
    private calculatePercentile(values: number[], percentile: number): number {
        if (values.length === 0) return 0;
        
        const sorted = [...values].sort((a, b) => a - b);
        const index = Math.ceil((percentile / 100) * sorted.length) - 1;
        return sorted[index] || 0;
    }

    /**
     * Get all services
     */
    public getServices(): ServiceHealth[] {
        return Array.from(this.services.values());
    }

    /**
     * Get service by ID
     */
    public getService(id: string): ServiceHealth | undefined {
        return this.services.get(id);
    }

    /**
     * Get all alerts
     */
    public getAlerts(): HealthAlert[] {
        return Array.from(this.alerts.values());
    }

    /**
     * Get active alerts
     */
    public getActiveAlerts(): HealthAlert[] {
        return Array.from(this.alerts.values())
            .filter(a => !a.resolved);
    }

    /**
     * Resolve alert
     */
    public async resolveAlert(alertId: string): Promise<void> {
        const alert = this.alerts.get(alertId);
        if (!alert) {
            throw new Error(`Alert not found: ${alertId}`);
        }
        
        alert.resolved = true;
        alert.resolvedAt = new Date();
        
        this.outputChannel.appendLine(`Alert resolved: ${alert.message}`);
        this.emit('alertResolved', alert);
    }

    /**
     * Get health metrics for service
     */
    public getMetrics(serviceId: string): HealthMetric[] {
        return this.metrics.get(serviceId) || [];
    }

    /**
     * Get health thresholds for service
     */
    public getThresholds(serviceId: string): HealthThreshold[] {
        return this.thresholds.get(serviceId) || [];
    }

    /**
     * Add health threshold
     */
    public async addThreshold(threshold: HealthThreshold): Promise<void> {
        if (!this.thresholds.has(threshold.serviceId)) {
            this.thresholds.set(threshold.serviceId, []);
        }
        
        this.thresholds.get(threshold.serviceId)!.push(threshold);
        await this.saveThreshold(threshold);
        
        this.emit('thresholdAdded', threshold);
    }

    /**
     * Save threshold configuration
     */
    private async saveThreshold(threshold: HealthThreshold): Promise<void> {
        const thresholdsDir = path.join(this.context.globalStorageUri.fsPath, 'thresholds');
        if (!fs.existsSync(thresholdsDir)) {
            fs.mkdirSync(thresholdsDir, { recursive: true });
        }
        
        const filePath = path.join(thresholdsDir, `${threshold.serviceId}_${threshold.id}.json`);
        fs.writeFileSync(filePath, JSON.stringify(threshold, null, 2));
    }

    /**
     * Update status bar with health information
     */
    private updateStatusBar(): void {
        const totalServices = this.services.size;
        const enabledServices = Array.from(this.services.values())
            .filter(s => s.enabled).length;
        const healthyServices = Array.from(this.services.values())
            .filter(s => s.enabled && s.status === 'healthy').length;
        const activeAlerts = this.getActiveAlerts().length;
        
        let text = `$(heart) Health`;
        if (activeAlerts > 0) {
            text += ` ⚠️${activeAlerts}`;
        }
        if (totalServices > 0) {
            text += ` 🟢${healthyServices}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Health: ${healthyServices}/${enabledServices} services healthy, ${activeAlerts} active alerts`;
    }

    /**
     * Show health status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const services = this.getServices();
            const activeAlerts = this.getActiveAlerts();
            const report = await this.generateHealthReport();

            let output = `External Service Health Status\n`;
            output += `==============================\n\n`;

            output += `Services (${services.length}):\n`;
            for (const service of services) {
                const statusIcon = service.status === 'healthy' ? '🟢' : 
                                 service.status === 'degraded' ? '🟡' : '🔴';
                output += `  ${statusIcon} ${service.name}: ${service.status}\n`;
                output += `    URL: ${service.url}\n`;
                output += `    Response Time: ${service.responseTime}ms\n`;
                output += `    Last Check: ${service.lastCheck.toLocaleString()}\n`;
                if (service.lastError) {
                    output += `    Last Error: ${service.lastError}\n`;
                }
            }
            output += '\n';

            output += `Active Alerts (${activeAlerts.length}):\n`;
            for (const alert of activeAlerts.slice(0, 10)) {
                const typeIcon = alert.type === 'critical' ? '🔴' : 
                               alert.type === 'warning' ? '🟡' : '🔵';
                output += `  ${typeIcon} ${alert.message}\n`;
                output += `    Service: ${services.find(s => s.id === alert.serviceId)?.name || 'Unknown'}\n`;
                output += `    Timestamp: ${alert.timestamp.toLocaleString()}\n`;
            }
            if (activeAlerts.length > 10) {
                output += `  ... and ${activeAlerts.length - 10} more alerts\n`;
            }
            output += '\n';

            output += `Health Summary:\n`;
            output += `  Total Services: ${report.totalServices}\n`;
            output += `  Healthy Services: ${report.healthyServices}\n`;
            output += `  Degraded Services: ${report.degradedServices}\n`;
            output += `  Unhealthy Services: ${report.unhealthyServices}\n`;
            output += `  Uptime: ${report.uptime.toFixed(2)}%\n`;
            output += `  Average Response Time: ${report.responseTime.average.toFixed(2)}ms\n`;
            output += `  P95 Response Time: ${report.responseTime.p95.toFixed(2)}ms\n`;
            output += `  P99 Response Time: ${report.responseTime.p99.toFixed(2)}ms\n`;

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show health status: ${error.message}`);
        }
    }

    /**
     * Dispose health monitoring
     */
    public dispose(): void {
        if (this.monitoringInterval) {
            clearInterval(this.monitoringInterval);
        }
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }

    // Event emitter methods
    private emit(event: string, data: any): void {
        // Implementation would depend on the event system being used
    }
}