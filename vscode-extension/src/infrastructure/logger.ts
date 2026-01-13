/**
 * Logger for Noodle VS Code Extension
 * 
 * Provides centralized logging with different levels and output channels.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';

export interface LogEntry {
    timestamp: string;
    level: 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR';
    message: string;
    data?: any;
}

export interface LoggerConfig {
    level: 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR';
    enableFileLogging: boolean;
    enableOutputChannel: boolean;
    maxLogEntries: number;
    logRetentionDays: number;
}

export class Logger extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private config: LoggerConfig;
    private logEntries: LogEntry[] = [];
    private logFile?: string;
    
    constructor(context: vscode.ExtensionContext, config?: LoggerConfig) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Extension');
        this.config = {
            level: 'INFO',
            enableFileLogging: true,
            enableOutputChannel: true,
            maxLogEntries: 1000,
            logRetentionDays: 7,
            ...config
        };
    }
    
    /**
     * Initialize logger
     */
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing logger...');
            
            // Set up log file
            if (this.config.enableFileLogging) {
                this.logFile = this.context.globalStorageUri.fsPath + '/noodle-extension.log';
            }
            
            this.outputChannel.appendLine('Logger initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize logger: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Log debug message
     */
    public debug(message: string, data?: any): void {
        this.log('DEBUG', message, data);
    }
    
    /**
     * Log info message
     */
    public info(message: string, data?: any): void {
        this.log('INFO', message, data);
    }
    
    /**
     * Log warning message
     */
    public warning(message: string, data?: any): void {
        this.log('WARNING', message, data);
    }
    
    /**
     * Log error message
     */
    public error(message: string, data?: any): void {
        this.log('ERROR', message, data);
    }
    
    /**
     * Log message with specified level
     */
    public log(level: 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR', message: string, data?: any): void {
        try {
            const entry: LogEntry = {
                timestamp: new Date().toISOString(),
                level,
                message,
                data
            };
            
            // Add to in-memory log
            this.logEntries.push(entry);
            
            // Trim log if too many entries
            if (this.logEntries.length > this.config.maxLogEntries) {
                this.logEntries = this.logEntries.slice(-this.config.maxLogEntries);
            }
            
            // Output to channel
            if (this.config.enableOutputChannel) {
                const output = `[${level}] ${message}`;
                if (data) {
                    this.outputChannel.appendLine(`${output} ${JSON.stringify(data)}`);
                } else {
                    this.outputChannel.appendLine(output);
                }
            }
            
            // Write to file
            if (this.config.enableFileLogging && this.logFile) {
                this.writeToFile(entry);
            }
            
            // Emit event
            this.emit('log', entry);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to log message: ${error.message}`);
        }
    }
    
    /**
     * Write log entry to file
     */
    private async writeToFile(entry: LogEntry): Promise<void> {
        if (!this.logFile) return;
        
        try {
            const fs = require('fs');
            const logLine = `${entry.timestamp} [${entry.level}] ${entry.message}${entry.data ? ` ${JSON.stringify(entry.data)}` : ''}\n`;
            
            await fs.promises.appendFile(this.logFile, logLine, 'utf8');
            
            // Clean up old logs
            await this.cleanupOldLogs();
        } catch (error) {
            this.outputChannel.appendLine(`Failed to write to log file: ${error.message}`);
        }
    }
    
    /**
     * Clean up old log files
     */
    private async cleanupOldLogs(): Promise<void> {
        if (!this.logFile) return;
        
        try {
            const fs = require('fs');
            const path = require('path');
            const logDir = path.dirname(this.logFile);
            
            // Get all log files
            const files = await fs.promises.readdir(logDir);
            const logFiles = files.filter(file => file.endsWith('.log'));
            
            // Sort by modification time
            const fileStats = await Promise.all(
                logFiles.map(async (file) => {
                    const filePath = path.join(logDir, file);
                    const stats = await fs.promises.stat(filePath);
                    return { file, stats };
                })
            );
            
            fileStats.sort((a, b) => b.stats.mtime - a.stats.mtime);
            
            // Remove old files beyond retention period
            const cutoffDate = new Date();
            cutoffDate.setDate(cutoffDate.getDate() - this.config.logRetentionDays);
            
            for (let i = this.config.logRetentionDays; i < fileStats.length; i++) {
                const { file, stats } = fileStats[i];
                if (stats.mtime < cutoffDate) {
                    const filePath = path.join(logDir, file);
                    await fs.promises.unlink(filePath);
                }
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to cleanup old logs: ${error.message}`);
        }
    }
    
    /**
     * Get log entries
     */
    public getLogEntries(): LogEntry[] {
        return [...this.logEntries];
    }
    
    /**
     * Get log entries by level
     */
    public getLogEntriesByLevel(level: 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR'): LogEntry[] {
        return this.logEntries.filter(entry => entry.level === level);
    }
    
    /**
     * Get log entries by date range
     */
    public getLogEntriesByDate(startDate: Date, endDate: Date): LogEntry[] {
        const start = startDate.getTime();
        const end = endDate.getTime();
        
        return this.logEntries.filter(entry => {
            const entryTime = new Date(entry.timestamp).getTime();
            return entryTime >= start && entryTime <= end;
        });
    }
    
    /**
     * Clear log entries
     */
    public clear(): void {
        this.logEntries = [];
        this.emit('logCleared');
    }
    
    /**
     * Set log level
     */
    public setLevel(level: 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR'): void {
        this.config.level = level;
        this.emit('levelChanged', level);
    }
    
    /**
     * Get current log level
     */
    public getLevel(): 'DEBUG' | 'INFO' | 'WARNING' | 'ERROR' {
        return this.config.level;
    }
    
    /**
     * Dispose logger
     */
    public dispose(): void {
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}