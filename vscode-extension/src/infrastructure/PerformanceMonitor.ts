/**
 * NoodleCore Performance Monitor
 * 
 * Real-time performance tracking with metrics collection,
 * profiling, and performance optimization suggestions.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';

export interface PerformanceMetrics {
    timestamp: string;
    memory: {
        used: number;
        total: number;
        percentage: number;
        heapUsed: number;
        heapTotal: number;
        external: number;
    };
    cpu: {
        usage: number;
        loadAverage: number[];
        userTime: number;
        systemTime: number;
        idleTime: number;
    };
    network: {
        bytesReceived: number;
        bytesSent: number;
        packetsReceived: number;
        packetsSent: number;
        errors: number;
        dropped: number;
    };
    disk: {
        readBytes: number;
        writeBytes: number;
        readOps: number;
        writeOps: number;
        errors: number;
    };
    processes: {
        count: number;
        running: number;
        sleeping: number;
        zombie: number;
    };
    gc: {
        collections: number;
        duration: number;
        reclaimed: number;
        forced: number;
    };
}

export interface PerformanceProfile {
    id: string;
    name: string;
    startTime: number;
    endTime?: number;
    duration?: number;
    metadata: any;
    samples: PerformanceMetrics[];
    active: boolean;
}

export interface PerformanceThreshold {
    metric: string;
    warning: number;
    critical: number;
    enabled: boolean;
}

export interface PerformanceAlert {
    id: string;
    type: 'warning' | 'critical';
    metric: string;
    value: number;
    threshold: number;
    timestamp: string;
    message: string;
    resolved: boolean;
}

export interface PerformanceReport {
    generatedAt: string;
    timeRange: {
        start: string;
        end: string;
    };
    summary: {
        averageCpuUsage: number;
        peakMemoryUsage: number;
        averageMemoryUsage: number;
        totalGcCollections: number;
        totalNetworkErrors: number;
        totalDiskErrors: number;
    };
    profiles: PerformanceProfile[];
    alerts: PerformanceAlert[];
    recommendations: string[];
}

export class PerformanceMonitor extends EventEmitter {
    private metrics: PerformanceMetrics[] = [];
    private profiles: Map<string, PerformanceProfile> = new Map();
    private thresholds: PerformanceThreshold[] = [];
    private alerts: PerformanceAlert[] = [];
    private monitoringInterval: NodeJS.Timeout | null = null;
    private maxMetricsHistory = 1000;
    private isMonitoring = false;
    private lastMetrics: PerformanceMetrics | null = null;
    private outputChannel: vscode.OutputChannel;

    constructor() {
        super();
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore Performance Monitor');
        this.thresholds = this.initializeThresholds();
        this.setupPerformanceHooks();
    }

    /**
     * Start performance monitoring
     */
    public startMonitoring(intervalMs: number = 5000): void {
        if (this.isMonitoring) {
            return;
        }

        this.isMonitoring = true;
        
        this.monitoringInterval = setInterval(() => {
            this.collectMetrics();
            this.checkThresholds();
            this.updateProfiles();
        }, intervalMs);

        this.emit('monitoringStarted');
        this.outputChannel.appendLine('Performance monitoring started');
    }

    /**
     * Stop performance monitoring
     */
    public stopMonitoring(): void {
        if (!this.isMonitoring) {
            return;
        }

        this.isMonitoring = false;
        
        if (this.monitoringInterval) {
            clearInterval(this.monitoringInterval);
            this.monitoringInterval = null;
        }

        // End all active profiles
        for (const profile of this.profiles.values()) {
            if (profile.active) {
                this.endProfile(profile.id);
            }
        }

        this.emit('monitoringStopped');
        this.outputChannel.appendLine('Performance monitoring stopped');
    }

    /**
     * Get current performance metrics
     */
    public getCurrentMetrics(): PerformanceMetrics | null {
        return this.lastMetrics;
    }

    /**
     * Get metrics history
     */
    public getMetricsHistory(filter?: {
        since?: string;
        limit?: number;
    }): PerformanceMetrics[] {
        let history = [...this.metrics];

        if (filter) {
            if (filter.since) {
                const since = new Date(filter.since);
                history = history.filter(metric => new Date(metric.timestamp) >= since);
            }
            if (filter.limit) {
                history = history.slice(0, filter.limit);
            }
        }

        return history;
    }

    /**
     * Start a performance profile
     */
    public startProfile(name: string, metadata?: any): string {
        const profileId = this.generateProfileId();
        const profile: PerformanceProfile = {
            id: profileId,
            name,
            startTime: Date.now(),
            metadata: metadata || {},
            samples: [],
            active: true
        };

        this.profiles.set(profileId, profile);
        this.emit('profileStarted', profile);
        this.outputChannel.appendLine(`Started performance profile: ${name} (${profileId})`);

        return profileId;
    }

    /**
     * End a performance profile
     */
    public endProfile(profileId: string): PerformanceProfile | null {
        const profile = this.profiles.get(profileId);
        if (!profile || !profile.active) {
            return null;
        }

        profile.endTime = Date.now();
        profile.duration = profile.endTime - profile.startTime;
        profile.active = false;

        this.profiles.delete(profileId);
        this.emit('profileEnded', profile);
        this.outputChannel.appendLine(`Ended performance profile: ${profile.name} (${profileId}) - ${profile.duration}ms`);

        return profile;
    }

    /**
     * Get performance profiles
     */
    public getProfiles(filter?: {
        active?: boolean;
        name?: string;
        since?: string;
    }): PerformanceProfile[] {
        let profiles = Array.from(this.profiles.values());

        if (filter) {
            if (filter.active !== undefined) {
                profiles = profiles.filter(profile => profile.active === filter.active);
            }
            if (filter.name) {
                profiles = profiles.filter(profile => profile.name.includes(filter.name));
            }
            if (filter.since) {
                const since = new Date(filter.since);
                profiles = profiles.filter(profile => new Date(profile.startTime) >= since);
            }
        }

        return profiles;
    }

    /**
     * Get performance alerts
     */
    public getAlerts(filter?: {
        type?: 'warning' | 'critical';
        resolved?: boolean;
        since?: string;
    }): PerformanceAlert[] {
        let alerts = [...this.alerts];

        if (filter) {
            if (filter.type) {
                alerts = alerts.filter(alert => alert.type === filter.type);
            }
            if (filter.resolved !== undefined) {
                alerts = alerts.filter(alert => alert.resolved === filter.resolved);
            }
            if (filter.since) {
                const since = new Date(filter.since);
                alerts = alerts.filter(alert => new Date(alert.timestamp) >= since);
            }
        }

        return alerts;
    }

    /**
     * Set performance thresholds
     */
    public setThresholds(thresholds: PerformanceThreshold[]): void {
        this.thresholds = thresholds;
        this.emit('thresholdsUpdated', thresholds);
    }

    /**
     * Get performance thresholds
     */
    public getThresholds(): PerformanceThreshold[] {
        return [...this.thresholds];
    }

    /**
     * Generate performance report
     */
    public generateReport(timeRange?: {
        start: string;
        end: string;
    }): PerformanceReport {
        const now = new Date();
        const end = timeRange?.end ? new Date(timeRange.end) : now;
        const start = timeRange?.start ? new Date(timeRange.start) : new Date(now.getTime() - 24 * 60 * 60 * 1000); // Last 24 hours

        const filteredMetrics = this.metrics.filter(metric => {
            const metricTime = new Date(metric.timestamp);
            return metricTime >= start && metricTime <= end;
        });

        const profiles = this.getProfiles({ since: start.toISOString() });
        const alerts = this.getAlerts({ since: start.toISOString() });

        const summary = this.calculateSummary(filteredMetrics);
        const recommendations = this.generateRecommendations(filteredMetrics, alerts);

        const report: PerformanceReport = {
            generatedAt: now.toISOString(),
            timeRange: {
                start: start.toISOString(),
                end: end.toISOString()
            },
            summary,
            profiles,
            alerts,
            recommendations
        };

        this.emit('reportGenerated', report);
        return report;
    }

    /**
     * Clear metrics history
     */
    public clearMetrics(): void {
        this.metrics = [];
        this.alerts = [];
        this.emit('metricsCleared');
    }

    /**
     * Collect performance metrics
     */
    private collectMetrics(): void {
        const metrics: PerformanceMetrics = {
            timestamp: new Date().toISOString(),
            memory: this.collectMemoryMetrics(),
            cpu: this.collectCpuMetrics(),
            network: this.collectNetworkMetrics(),
            disk: this.collectDiskMetrics(),
            processes: this.collectProcessMetrics(),
            gc: this.collectGcMetrics()
        };

        this.metrics.unshift(metrics);
        
        // Limit history size
        if (this.metrics.length > this.maxMetricsHistory) {
            this.metrics = this.metrics.slice(0, this.maxMetricsHistory);
        }

        this.lastMetrics = metrics;
        this.emit('metricsCollected', metrics);
    }

    /**
     * Collect memory metrics
     */
    private collectMemoryMetrics(): PerformanceMetrics['memory'] {
        const memUsage = process.memoryUsage();
        const totalMemory = require('os').totalmem();

        return {
            used: memUsage.rss,
            total: totalMemory,
            percentage: (memUsage.rss / totalMemory) * 100,
            heapUsed: memUsage.heapUsed,
            heapTotal: memUsage.heapTotal,
            external: memUsage.external || 0
        };
    }

    /**
     * Collect CPU metrics
     */
    private collectCpuMetrics(): PerformanceMetrics['cpu'] {
        const cpuUsage = process.cpuUsage();
        const loadAverage = require('os').loadavg();

        return {
            usage: (cpuUsage.user + cpuUsage.system) / 1000000, // Convert to percentage
            loadAverage: loadAverage,
            userTime: cpuUsage.user,
            systemTime: cpuUsage.system,
            idleTime: cpuUsage.idle
        };
    }

    /**
     * Collect network metrics
     */
    private collectNetworkMetrics(): PerformanceMetrics['network'] {
        // In a real implementation, this would use system network APIs
        // For now, return placeholder values
        return {
            bytesReceived: 0,
            bytesSent: 0,
            packetsReceived: 0,
            packetsSent: 0,
            errors: 0,
            dropped: 0
        };
    }

    /**
     * Collect disk metrics
     */
    private collectDiskMetrics(): PerformanceMetrics['disk'] {
        // In a real implementation, this would use system disk APIs
        // For now, return placeholder values
        return {
            readBytes: 0,
            writeBytes: 0,
            readOps: 0,
            writeOps: 0,
            errors: 0
        };
    }

    /**
     * Collect process metrics
     */
    private collectProcessMetrics(): PerformanceMetrics['processes'] {
        // In a real implementation, this would use system process APIs
        // For now, return placeholder values
        return {
            count: 1,
            running: 1,
            sleeping: 0,
            zombie: 0
        };
    }

    /**
     * Collect garbage collection metrics
     */
    private collectGcMetrics(): PerformanceMetrics['gc'] {
        // In a real implementation, this would use V8 GC APIs
        // For now, return placeholder values
        return {
            collections: 0,
            duration: 0,
            reclaimed: 0,
            forced: 0
        };
    }

    /**
     * Check performance thresholds
     */
    private checkThresholds(): void {
        if (!this.lastMetrics) {
            return;
        }

        for (const threshold of this.thresholds) {
            if (!threshold.enabled) {
                continue;
            }

            const value = this.getMetricValue(threshold.metric, this.lastMetrics);
            if (value === undefined) {
                continue;
            }

            if (value >= threshold.critical) {
                this.createAlert('critical', threshold, value);
            } else if (value >= threshold.warning) {
                this.createAlert('warning', threshold, value);
            }
        }
    }

    /**
     * Get metric value by path
     */
    private getMetricValue(metricPath: string, metrics: PerformanceMetrics): number | undefined {
        const parts = metricPath.split('.');
        let value: any = metrics;

        for (const part of parts) {
            value = value?.[part];
        }

        return typeof value === 'number' ? value : undefined;
    }

    /**
     * Create performance alert
     */
    private createAlert(type: 'warning' | 'critical', threshold: PerformanceThreshold, value: number): void {
        const alert: PerformanceAlert = {
            id: this.generateAlertId(),
            type,
            metric: threshold.metric,
            value,
            threshold: type === 'critical' ? threshold.critical : threshold.warning,
            timestamp: new Date().toISOString(),
            message: `${threshold.metric} ${type} threshold exceeded: ${value} > ${type === 'critical' ? threshold.critical : threshold.warning}`,
            resolved: false
        };

        this.alerts.unshift(alert);
        
        // Limit alerts history
        if (this.alerts.length > 1000) {
            this.alerts = this.alerts.slice(0, 1000);
        }

        this.emit('alert', alert);
        this.outputChannel.appendLine(`[${type.toUpperCase()}] ${alert.message}`);
        this.outputChannel.show();
    }

    /**
     * Update active profiles with current metrics
     */
    private updateProfiles(): void {
        if (!this.lastMetrics) {
            return;
        }

        for (const profile of this.profiles.values()) {
            if (profile.active) {
                profile.samples.push({ ...this.lastMetrics });
            }
        }
    }

    /**
     * Calculate performance summary
     */
    private calculateSummary(metrics: PerformanceMetrics[]): PerformanceReport['summary'] {
        if (metrics.length === 0) {
            return {
                averageCpuUsage: 0,
                peakMemoryUsage: 0,
                averageMemoryUsage: 0,
                totalGcCollections: 0,
                totalNetworkErrors: 0,
                totalDiskErrors: 0
            };
        }

        const cpuUsages = metrics.map(m => m.cpu.usage);
        const memoryUsages = metrics.map(m => m.memory.percentage);
        const gcCollections = metrics.map(m => m.gc.collections);
        const networkErrors = metrics.map(m => m.network.errors);
        const diskErrors = metrics.map(m => m.disk.errors);

        return {
            averageCpuUsage: cpuUsages.reduce((sum, usage) => sum + usage, 0) / cpuUsages.length,
            peakMemoryUsage: Math.max(...memoryUsages),
            averageMemoryUsage: memoryUsages.reduce((sum, usage) => sum + usage, 0) / memoryUsages.length,
            totalGcCollections: gcCollections.reduce((sum, count) => sum + count, 0),
            totalNetworkErrors: networkErrors.reduce((sum, errors) => sum + errors, 0),
            totalDiskErrors: diskErrors.reduce((sum, errors) => sum + errors, 0)
        };
    }

    /**
     * Generate performance recommendations
     */
    private generateRecommendations(metrics: PerformanceMetrics[], alerts: PerformanceAlert[]): string[] {
        const recommendations: string[] = [];

        if (metrics.length === 0) {
            return recommendations;
        }

        const avgMemory = metrics.reduce((sum, m) => sum + m.memory.percentage, 0) / metrics.length;
        const avgCpu = metrics.reduce((sum, m) => sum + m.cpu.usage, 0) / metrics.length;
        const criticalAlerts = alerts.filter(a => a.type === 'critical');

        // Memory recommendations
        if (avgMemory > 80) {
            recommendations.push('High memory usage detected. Consider optimizing memory usage or increasing available memory.');
        }

        // CPU recommendations
        if (avgCpu > 80) {
            recommendations.push('High CPU usage detected. Consider optimizing algorithms or increasing CPU resources.');
        }

        // GC recommendations
        const totalGc = metrics.reduce((sum, m) => sum + m.gc.collections, 0);
        if (totalGc > metrics.length * 10) {
            recommendations.push('Frequent garbage collection detected. Consider reducing object allocation or increasing heap size.');
        }

        // Alert-based recommendations
        if (criticalAlerts.length > 5) {
            recommendations.push('Multiple critical alerts detected. Review system performance and resource allocation.');
        }

        return recommendations;
    }

    /**
     * Initialize performance thresholds
     */
    private initializeThresholds(): PerformanceThreshold[] {
        return [
            {
                metric: 'memory.percentage',
                warning: 75,
                critical: 90,
                enabled: true
            },
            {
                metric: 'cpu.usage',
                warning: 80,
                critical: 95,
                enabled: true
            },
            {
                metric: 'network.errors',
                warning: 10,
                critical: 50,
                enabled: true
            },
            {
                metric: 'disk.errors',
                warning: 5,
                critical: 20,
                enabled: true
            },
            {
                metric: 'gc.collections',
                warning: 20,
                critical: 50,
                enabled: true
            }
        ];
    }

    /**
     * Setup performance hooks
     */
    private setupPerformanceHooks(): void {
        // Monitor VS Code performance
        const disposables = [
            vscode.window.onDidChangeActiveTextEditor(() => {
                this.collectMetrics();
            }),
            vscode.workspace.onDidChangeTextDocument(() => {
                this.collectMetrics();
            })
        ];

        // Cleanup on disposal
        this.on('dispose', () => {
            disposables.forEach(d => d.dispose());
        });
    }

    /**
     * Generate profile ID
     */
    private generateProfileId(): string {
        return `profile_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Generate alert ID
     */
    private generateAlertId(): string {
        return `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Dispose performance monitor
     */
    public dispose(): void {
        this.stopMonitoring();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}