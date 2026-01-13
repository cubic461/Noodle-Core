"use strict";
/**
 * NoodleCore Performance Monitor
 *
 * Real-time performance tracking with metrics collection,
 * profiling, and performance optimization suggestions.
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
exports.PerformanceMonitor = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class PerformanceMonitor extends events_1.EventEmitter {
    constructor() {
        super();
        this.metrics = [];
        this.profiles = new Map();
        this.thresholds = [];
        this.alerts = [];
        this.monitoringInterval = null;
        this.maxMetricsHistory = 1000;
        this.isMonitoring = false;
        this.lastMetrics = null;
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore Performance Monitor');
        this.thresholds = this.initializeThresholds();
        this.setupPerformanceHooks();
    }
    /**
     * Start performance monitoring
     */
    startMonitoring(intervalMs = 5000) {
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
    stopMonitoring() {
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
    getCurrentMetrics() {
        return this.lastMetrics;
    }
    /**
     * Get metrics history
     */
    getMetricsHistory(filter) {
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
    startProfile(name, metadata) {
        const profileId = this.generateProfileId();
        const profile = {
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
    endProfile(profileId) {
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
    getProfiles(filter) {
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
    getAlerts(filter) {
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
    setThresholds(thresholds) {
        this.thresholds = thresholds;
        this.emit('thresholdsUpdated', thresholds);
    }
    /**
     * Get performance thresholds
     */
    getThresholds() {
        return [...this.thresholds];
    }
    /**
     * Generate performance report
     */
    generateReport(timeRange) {
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
        const report = {
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
    clearMetrics() {
        this.metrics = [];
        this.alerts = [];
        this.emit('metricsCleared');
    }
    /**
     * Collect performance metrics
     */
    collectMetrics() {
        const metrics = {
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
    collectMemoryMetrics() {
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
    collectCpuMetrics() {
        const cpuUsage = process.cpuUsage();
        const loadAverage = require('os').loadavg();
        return {
            usage: (cpuUsage.user + cpuUsage.system) / 1000000,
            loadAverage: loadAverage,
            userTime: cpuUsage.user,
            systemTime: cpuUsage.system,
            idleTime: cpuUsage.idle
        };
    }
    /**
     * Collect network metrics
     */
    collectNetworkMetrics() {
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
    collectDiskMetrics() {
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
    collectProcessMetrics() {
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
    collectGcMetrics() {
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
    checkThresholds() {
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
            }
            else if (value >= threshold.warning) {
                this.createAlert('warning', threshold, value);
            }
        }
    }
    /**
     * Get metric value by path
     */
    getMetricValue(metricPath, metrics) {
        const parts = metricPath.split('.');
        let value = metrics;
        for (const part of parts) {
            value = value?.[part];
        }
        return typeof value === 'number' ? value : undefined;
    }
    /**
     * Create performance alert
     */
    createAlert(type, threshold, value) {
        const alert = {
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
    updateProfiles() {
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
    calculateSummary(metrics) {
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
    generateRecommendations(metrics, alerts) {
        const recommendations = [];
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
    initializeThresholds() {
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
    setupPerformanceHooks() {
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
    generateProfileId() {
        return `profile_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    /**
     * Generate alert ID
     */
    generateAlertId() {
        return `alert_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }
    /**
     * Dispose performance monitor
     */
    dispose() {
        this.stopMonitoring();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.PerformanceMonitor = PerformanceMonitor;
//# sourceMappingURL=PerformanceMonitor.js.map