"use strict";
/**
 * Logging and Monitoring System for Noodle VS Code Extension
 *
 * Provides comprehensive logging, performance monitoring, and
 * health tracking capabilities.
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
exports.Logger = exports.LogLevel = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
var LogLevel;
(function (LogLevel) {
    LogLevel[LogLevel["DEBUG"] = 0] = "DEBUG";
    LogLevel[LogLevel["INFO"] = 1] = "INFO";
    LogLevel[LogLevel["WARN"] = 2] = "WARN";
    LogLevel[LogLevel["ERROR"] = 3] = "ERROR";
    LogLevel[LogLevel["FATAL"] = 4] = "FATAL";
})(LogLevel = exports.LogLevel || (exports.LogLevel = {}));
class Logger extends events_1.EventEmitter {
    constructor(context, config) {
        super();
        this.logs = [];
        this.metrics = [];
        this.healthChecks = new Map();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Logger');
        this.sessionId = this.generateSessionId();
        this.config = {
            level: LogLevel.INFO,
            enableConsole: true,
            enableFile: true,
            enableOutputChannel: true,
            logFilePath: path.join(context.globalStorageUri.fsPath, 'logs'),
            maxFileSize: 10 * 1024 * 1024,
            maxFiles: 5,
            enableMetrics: true,
            enableHealthChecks: true,
            metricsInterval: 60000,
            healthCheckInterval: 300000,
            ...config
        };
    }
    /**
     * Initialize logger
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing logger...');
            // Ensure log directory exists
            await this.ensureLogDirectory();
            // Open log file
            if (this.config.enableFile) {
                await this.openLogFile();
            }
            // Start metrics collection
            if (this.config.enableMetrics) {
                this.startMetricsCollection();
            }
            // Start health checks
            if (this.config.enableHealthChecks) {
                this.startHealthChecks();
            }
            this.info('Logger', 'Logger initialized', { sessionId: this.sessionId });
            this.outputChannel.appendLine('Logger initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize logger: ${error.message}`);
            throw error;
        }
    }
    /**
     * Log debug message
     */
    debug(category, message, data) {
        this.log(LogLevel.DEBUG, category, message, data);
    }
    /**
     * Log info message
     */
    info(category, message, data) {
        this.log(LogLevel.INFO, category, message, data);
    }
    /**
     * Log warning message
     */
    warn(category, message, data) {
        this.log(LogLevel.WARN, category, message, data);
    }
    /**
     * Log error message
     */
    error(category, message, data) {
        this.log(LogLevel.ERROR, category, message, data);
    }
    /**
     * Log fatal message
     */
    fatal(category, message, data) {
        this.log(LogLevel.FATAL, category, message, data);
    }
    /**
     * Log message
     */
    log(level, category, message, data) {
        try {
            // Check log level
            if (level < (this.config.level || LogLevel.INFO)) {
                return;
            }
            const logEntry = {
                timestamp: Date.now(),
                level,
                message,
                category,
                data,
                source: 'noodle-extension',
                sessionId: this.sessionId
            };
            // Add to logs
            this.logs.push(logEntry);
            // Keep logs in memory limited
            if (this.logs.length > 10000) {
                this.logs = this.logs.slice(-5000);
            }
            // Output to console
            if (this.config.enableConsole) {
                this.outputToConsole(logEntry);
            }
            // Output to file
            if (this.config.enableFile && this.logFile) {
                this.outputToFile(logEntry);
            }
            // Output to VS Code channel
            if (this.config.enableOutputChannel) {
                this.outputToChannel(logEntry);
            }
            // Emit event
            this.emit('log', logEntry);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to log message: ${error.message}`);
        }
    }
    /**
     * Record performance metric
     */
    recordMetric(name, value, unit, tags, category) {
        try {
            const metric = {
                name,
                value,
                unit,
                timestamp: Date.now(),
                tags,
                category
            };
            this.metrics.push(metric);
            // Keep metrics in memory limited
            if (this.metrics.length > 10000) {
                this.metrics = this.metrics.slice(-5000);
            }
            this.emit('metric', metric);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to record metric: ${error.message}`);
        }
    }
    /**
     * Record timing metric
     */
    startTimer(name, tags, category) {
        const startTime = Date.now();
        return () => {
            const duration = Date.now() - startTime;
            this.recordMetric(name, duration, 'ms', tags, category);
        };
    }
    /**
     * Record health check
     */
    recordHealthCheck(name, status, message, metadata) {
        try {
            const healthCheck = {
                name,
                status,
                message,
                timestamp: Date.now(),
                metadata
            };
            this.healthChecks.set(name, healthCheck);
            this.emit('healthCheck', healthCheck);
            // Log health check
            const level = status === 'healthy' ? LogLevel.INFO :
                status === 'degraded' ? LogLevel.WARN : LogLevel.ERROR;
            this.log(level, 'HealthCheck', `${name}: ${status}`, { message, metadata });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to record health check: ${error.message}`);
        }
    }
    /**
     * Get logs
     */
    getLogs(level, category, limit) {
        let filteredLogs = this.logs;
        if (level !== undefined) {
            filteredLogs = filteredLogs.filter(log => log.level >= level);
        }
        if (category) {
            filteredLogs = filteredLogs.filter(log => log.category === category);
        }
        if (limit) {
            filteredLogs = filteredLogs.slice(-limit);
        }
        return filteredLogs;
    }
    /**
     * Get metrics
     */
    getMetrics(name, category, limit) {
        let filteredMetrics = this.metrics;
        if (name) {
            filteredMetrics = filteredMetrics.filter(metric => metric.name === name);
        }
        if (category) {
            filteredMetrics = filteredMetrics.filter(metric => metric.category === category);
        }
        if (limit) {
            filteredMetrics = filteredMetrics.slice(-limit);
        }
        return filteredMetrics;
    }
    /**
     * Get health checks
     */
    getHealthChecks() {
        return new Map(this.healthChecks);
    }
    /**
     * Get overall health status
     */
    getOverallHealth() {
        const healthChecks = Array.from(this.healthChecks.values());
        if (healthChecks.length === 0) {
            return 'healthy';
        }
        const unhealthyCount = healthChecks.filter(check => check.status === 'unhealthy').length;
        const degradedCount = healthChecks.filter(check => check.status === 'degraded').length;
        if (unhealthyCount > 0) {
            return 'unhealthy';
        }
        else if (degradedCount > 0) {
            return 'degraded';
        }
        else {
            return 'healthy';
        }
    }
    /**
     * Clear logs
     */
    clearLogs() {
        this.logs = [];
        this.emit('logsCleared');
    }
    /**
     * Clear metrics
     */
    clearMetrics() {
        this.metrics = [];
        this.emit('metricsCleared');
    }
    /**
     * Export logs to file
     */
    async exportLogs(filePath, level, category) {
        try {
            const logs = this.getLogs(level, category);
            const exportData = {
                version: '1.0.0',
                timestamp: new Date().toISOString(),
                sessionId: this.sessionId,
                logs
            };
            const fileContent = JSON.stringify(exportData, null, 2);
            await fs.promises.writeFile(filePath, fileContent, 'utf8');
            this.info('Logger', `Logs exported to: ${filePath}`);
            return true;
        }
        catch (error) {
            this.error('Logger', `Failed to export logs: ${error.message}`);
            return false;
        }
    }
    /**
     * Output to console
     */
    outputToConsole(logEntry) {
        const timestamp = new Date(logEntry.timestamp).toISOString();
        const levelName = LogLevel[logEntry.level];
        const message = `[${timestamp}] [${levelName}] [${logEntry.category}] ${logEntry.message}`;
        switch (logEntry.level) {
            case LogLevel.DEBUG:
                console.debug(message, logEntry.data);
                break;
            case LogLevel.INFO:
                console.info(message, logEntry.data);
                break;
            case LogLevel.WARN:
                console.warn(message, logEntry.data);
                break;
            case LogLevel.ERROR:
            case LogLevel.FATAL:
                console.error(message, logEntry.data);
                break;
        }
    }
    /**
     * Output to file
     */
    outputToFile(logEntry) {
        if (!this.logFile) {
            return;
        }
        const logLine = JSON.stringify(logEntry) + '\n';
        this.logFile.write(logLine);
    }
    /**
     * Output to VS Code channel
     */
    outputToChannel(logEntry) {
        const timestamp = new Date(logEntry.timestamp).toISOString();
        const levelName = LogLevel[logEntry.level];
        const message = `[${timestamp}] [${levelName}] [${logEntry.category}] ${logEntry.message}`;
        this.outputChannel.appendLine(message);
        if (logEntry.data) {
            this.outputChannel.appendLine(`  Data: ${JSON.stringify(logEntry.data)}`);
        }
    }
    /**
     * Ensure log directory exists
     */
    async ensureLogDirectory() {
        try {
            const logDir = this.config.logFilePath;
            if (logDir && !fs.existsSync(logDir)) {
                fs.mkdirSync(logDir, { recursive: true });
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to create log directory: ${error.message}`);
        }
    }
    /**
     * Open log file
     */
    async openLogFile() {
        try {
            const logDir = this.config.logFilePath;
            if (!logDir) {
                return;
            }
            const today = new Date().toISOString().split('T')[0];
            const logFileName = `noodle-${today}.log`;
            const logFilePath = path.join(logDir, logFileName);
            // Check file size and rotate if needed
            await this.rotateLogFileIfNeeded(logFilePath);
            this.logFile = fs.createWriteStream(logFilePath, { flags: 'a' });
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to open log file: ${error.message}`);
        }
    }
    /**
     * Rotate log file if needed
     */
    async rotateLogFileIfNeeded(filePath) {
        try {
            if (!fs.existsSync(filePath)) {
                return;
            }
            const stats = await fs.promises.stat(filePath);
            const maxSize = this.config.maxFileSize || 10 * 1024 * 1024;
            if (stats.size < maxSize) {
                return;
            }
            // Rotate files
            const maxFiles = this.config.maxFiles || 5;
            for (let i = maxFiles - 1; i > 0; i--) {
                const oldFile = `${filePath}.${i}`;
                const newFile = `${filePath}.${i + 1}`;
                if (fs.existsSync(oldFile)) {
                    if (i === maxFiles - 1) {
                        fs.unlinkSync(oldFile);
                    }
                    else {
                        fs.renameSync(oldFile, newFile);
                    }
                }
            }
            // Move current file
            fs.renameSync(filePath, `${filePath}.1`);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to rotate log file: ${error.message}`);
        }
    }
    /**
     * Start metrics collection
     */
    startMetricsCollection() {
        this.metricsInterval = setInterval(() => {
            this.collectSystemMetrics();
        }, this.config.metricsInterval || 60000);
    }
    /**
     * Start health checks
     */
    startHealthChecks() {
        this.healthCheckInterval = setInterval(() => {
            this.performHealthChecks();
        }, this.config.healthCheckInterval || 300000);
    }
    /**
     * Collect system metrics
     */
    collectSystemMetrics() {
        try {
            // Memory usage
            if (process.memoryUsage) {
                const memUsage = process.memoryUsage();
                this.recordMetric('memory.rss', memUsage.rss, 'bytes', undefined, 'system');
                this.recordMetric('memory.heapUsed', memUsage.heapUsed, 'bytes', undefined, 'system');
                this.recordMetric('memory.heapTotal', memUsage.heapTotal, 'bytes', undefined, 'system');
            }
            // Log count
            this.recordMetric('logs.count', this.logs.length, 'count', undefined, 'system');
            // Metrics count
            this.recordMetric('metrics.count', this.metrics.length, 'count', undefined, 'system');
            // Health check count
            this.recordMetric('healthChecks.count', this.healthChecks.size, 'count', undefined, 'system');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to collect system metrics: ${error.message}`);
        }
    }
    /**
     * Perform health checks
     */
    performHealthChecks() {
        try {
            // Log file health
            if (this.config.enableFile) {
                const logFileHealthy = !!this.logFile && !this.logFile.destroyed;
                this.recordHealthCheck('logFile', logFileHealthy ? 'healthy' : 'unhealthy');
            }
            // Memory health
            const memUsage = process.memoryUsage();
            const heapUsedRatio = memUsage.heapUsed / memUsage.heapTotal;
            const memoryHealthy = heapUsedRatio < 0.9;
            this.recordHealthCheck('memory', memoryHealthy ? 'healthy' : 'degraded', `Heap usage: ${(heapUsedRatio * 100).toFixed(1)}%`);
            // Overall health
            const overallHealth = this.getOverallHealth();
            this.recordHealthCheck('overall', overallHealth);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to perform health checks: ${error.message}`);
        }
    }
    /**
     * Generate session ID
     */
    generateSessionId() {
        return Math.random().toString(36).substring(2, 15) +
            Math.random().toString(36).substring(2, 15);
    }
    /**
     * Dispose logger
     */
    dispose() {
        try {
            // Stop intervals
            if (this.metricsInterval) {
                clearInterval(this.metricsInterval);
            }
            if (this.healthCheckInterval) {
                clearInterval(this.healthCheckInterval);
            }
            // Close log file
            if (this.logFile) {
                this.logFile.end();
            }
            this.outputChannel.dispose();
            this.removeAllListeners();
        }
        catch (error) {
            console.error(`Failed to dispose logger: ${error.message}`);
        }
    }
}
exports.Logger = Logger;
//# sourceMappingURL=LoggingMonitoring.js.map