/**
 * Logging and Monitoring System for Noodle VS Code Extension
 * 
 * Provides comprehensive logging, performance monitoring, and
 * health tracking capabilities.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';
import * as path from 'path';
import * as fs from 'fs';

export enum LogLevel {
    DEBUG = 0,
    INFO = 1,
    WARN = 2,
    ERROR = 3,
    FATAL = 4
}

export interface LogEntry {
    timestamp: number;
    level: LogLevel;
    message: string;
    category?: string;
    data?: any;
    source?: string;
    correlationId?: string;
    userId?: string;
    sessionId?: string;
}

export interface PerformanceMetric {
    name: string;
    value: number;
    unit: string;
    timestamp: number;
    tags?: Record<string, string>;
    category?: string;
}

export interface HealthCheck {
    name: string;
    status: 'healthy' | 'degraded' | 'unhealthy';
    message?: string;
    timestamp: number;
    duration?: number;
    metadata?: Record<string, any>;
}

export interface LoggerConfig {
    level?: LogLevel;
    enableConsole?: boolean;
    enableFile?: boolean;
    enableOutputChannel?: boolean;
    logFilePath?: string;
    maxFileSize?: number;
    maxFiles?: number;
    enableMetrics?: boolean;
    enableHealthChecks?: boolean;
    metricsInterval?: number;
    healthCheckInterval?: number;
}

export class Logger extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private config: LoggerConfig;
    private logs: LogEntry[] = [];
    private metrics: PerformanceMetric[] = [];
    private healthChecks: Map<string, HealthCheck> = new Map();
    private metricsInterval?: NodeJS.Timer;
    private healthCheckInterval?: NodeJS.Timer;
    private logFile?: fs.WriteStream;
    private sessionId: string;
    
    constructor(context: vscode.ExtensionContext, config?: LoggerConfig) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Logger');
        this.sessionId = this.generateSessionId();
        
        this.config = {
            level: LogLevel.INFO,
            enableConsole: true,
            enableFile: true,
            enableOutputChannel: true,
            logFilePath: path.join(context.globalStorageUri.fsPath, 'logs'),
            maxFileSize: 10 * 1024 * 1024, // 10MB
            maxFiles: 5,
            enableMetrics: true,
            enableHealthChecks: true,
            metricsInterval: 60000, // 1 minute
            healthCheckInterval: 300000, // 5 minutes
            ...config
        };
    }
    
    /**
     * Initialize logger
     */
    public async initialize(): Promise<void> {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize logger: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Log debug message
     */
    public debug(category: string, message: string, data?: any): void {
        this.log(LogLevel.DEBUG, category, message, data);
    }
    
    /**
     * Log info message
     */
    public info(category: string, message: string, data?: any): void {
        this.log(LogLevel.INFO, category, message, data);
    }
    
    /**
     * Log warning message
     */
    public warn(category: string, message: string, data?: any): void {
        this.log(LogLevel.WARN, category, message, data);
    }
    
    /**
     * Log error message
     */
    public error(category: string, message: string, data?: any): void {
        this.log(LogLevel.ERROR, category, message, data);
    }
    
    /**
     * Log fatal message
     */
    public fatal(category: string, message: string, data?: any): void {
        this.log(LogLevel.FATAL, category, message, data);
    }
    
    /**
     * Log message
     */
    public log(level: LogLevel, category: string, message: string, data?: any): void {
        try {
            // Check log level
            if (level < (this.config.level || LogLevel.INFO)) {
                return;
            }
            
            const logEntry: LogEntry = {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to log message: ${error.message}`);
        }
    }
    
    /**
     * Record performance metric
     */
    public recordMetric(name: string, value: number, unit: string, tags?: Record<string, string>, category?: string): void {
        try {
            const metric: PerformanceMetric = {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to record metric: ${error.message}`);
        }
    }
    
    /**
     * Record timing metric
     */
    public startTimer(name: string, tags?: Record<string, string>, category?: string): () => void {
        const startTime = Date.now();
        
        return () => {
            const duration = Date.now() - startTime;
            this.recordMetric(name, duration, 'ms', tags, category);
        };
    }
    
    /**
     * Record health check
     */
    public recordHealthCheck(name: string, status: HealthCheck['status'], message?: string, metadata?: Record<string, any>): void {
        try {
            const healthCheck: HealthCheck = {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to record health check: ${error.message}`);
        }
    }
    
    /**
     * Get logs
     */
    public getLogs(level?: LogLevel, category?: string, limit?: number): LogEntry[] {
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
    public getMetrics(name?: string, category?: string, limit?: number): PerformanceMetric[] {
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
    public getHealthChecks(): Map<string, HealthCheck> {
        return new Map(this.healthChecks);
    }
    
    /**
     * Get overall health status
     */
    public getOverallHealth(): 'healthy' | 'degraded' | 'unhealthy' {
        const healthChecks = Array.from(this.healthChecks.values());
        
        if (healthChecks.length === 0) {
            return 'healthy';
        }
        
        const unhealthyCount = healthChecks.filter(check => check.status === 'unhealthy').length;
        const degradedCount = healthChecks.filter(check => check.status === 'degraded').length;
        
        if (unhealthyCount > 0) {
            return 'unhealthy';
        } else if (degradedCount > 0) {
            return 'degraded';
        } else {
            return 'healthy';
        }
    }
    
    /**
     * Clear logs
     */
    public clearLogs(): void {
        this.logs = [];
        this.emit('logsCleared');
    }
    
    /**
     * Clear metrics
     */
    public clearMetrics(): void {
        this.metrics = [];
        this.emit('metricsCleared');
    }
    
    /**
     * Export logs to file
     */
    public async exportLogs(filePath: string, level?: LogLevel, category?: string): Promise<boolean> {
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
        } catch (error) {
            this.error('Logger', `Failed to export logs: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Output to console
     */
    private outputToConsole(logEntry: LogEntry): void {
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
    private outputToFile(logEntry: LogEntry): void {
        if (!this.logFile) {
            return;
        }
        
        const logLine = JSON.stringify(logEntry) + '\n';
        this.logFile.write(logLine);
    }
    
    /**
     * Output to VS Code channel
     */
    private outputToChannel(logEntry: LogEntry): void {
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
    private async ensureLogDirectory(): Promise<void> {
        try {
            const logDir = this.config.logFilePath;
            if (logDir && !fs.existsSync(logDir)) {
                fs.mkdirSync(logDir, { recursive: true });
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to create log directory: ${error.message}`);
        }
    }
    
    /**
     * Open log file
     */
    private async openLogFile(): Promise<void> {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to open log file: ${error.message}`);
        }
    }
    
    /**
     * Rotate log file if needed
     */
    private async rotateLogFileIfNeeded(filePath: string): Promise<void> {
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
                    } else {
                        fs.renameSync(oldFile, newFile);
                    }
                }
            }
            
            // Move current file
            fs.renameSync(filePath, `${filePath}.1`);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to rotate log file: ${error.message}`);
        }
    }
    
    /**
     * Start metrics collection
     */
    private startMetricsCollection(): void {
        this.metricsInterval = setInterval(() => {
            this.collectSystemMetrics();
        }, this.config.metricsInterval || 60000);
    }
    
    /**
     * Start health checks
     */
    private startHealthChecks(): void {
        this.healthCheckInterval = setInterval(() => {
            this.performHealthChecks();
        }, this.config.healthCheckInterval || 300000);
    }
    
    /**
     * Collect system metrics
     */
    private collectSystemMetrics(): void {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to collect system metrics: ${error.message}`);
        }
    }
    
    /**
     * Perform health checks
     */
    private performHealthChecks(): void {
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
            this.recordHealthCheck('memory', memoryHealthy ? 'healthy' : 'degraded', 
                `Heap usage: ${(heapUsedRatio * 100).toFixed(1)}%`);
            
            // Overall health
            const overallHealth = this.getOverallHealth();
            this.recordHealthCheck('overall', overallHealth);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to perform health checks: ${error.message}`);
        }
    }
    
    /**
     * Generate session ID
     */
    private generateSessionId(): string {
        return Math.random().toString(36).substring(2, 15) + 
               Math.random().toString(36).substring(2, 15);
    }
    
    /**
     * Dispose logger
     */
    public dispose(): void {
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
        } catch (error) {
            console.error(`Failed to dispose logger: ${error.message}`);
        }
    }
}