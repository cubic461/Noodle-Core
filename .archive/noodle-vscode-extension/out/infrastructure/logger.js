"use strict";
/**
 * Logger for Noodle VS Code Extension
 *
 * Provides centralized logging with different levels and output channels.
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
exports.Logger = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class Logger extends events_1.EventEmitter {
    constructor(context, config) {
        super();
        this.logEntries = [];
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
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing logger...');
            // Set up log file
            if (this.config.enableFileLogging) {
                this.logFile = this.context.globalStorageUri.fsPath + '/noodle-extension.log';
            }
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
    debug(message, data) {
        this.log('DEBUG', message, data);
    }
    /**
     * Log info message
     */
    info(message, data) {
        this.log('INFO', message, data);
    }
    /**
     * Log warning message
     */
    warning(message, data) {
        this.log('WARNING', message, data);
    }
    /**
     * Log error message
     */
    error(message, data) {
        this.log('ERROR', message, data);
    }
    /**
     * Log message with specified level
     */
    log(level, message, data) {
        try {
            const entry = {
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
                }
                else {
                    this.outputChannel.appendLine(output);
                }
            }
            // Write to file
            if (this.config.enableFileLogging && this.logFile) {
                this.writeToFile(entry);
            }
            // Emit event
            this.emit('log', entry);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to log message: ${error.message}`);
        }
    }
    /**
     * Write log entry to file
     */
    async writeToFile(entry) {
        if (!this.logFile)
            return;
        try {
            const fs = require('fs');
            const logLine = `${entry.timestamp} [${entry.level}] ${entry.message}${entry.data ? ` ${JSON.stringify(entry.data)}` : ''}\n`;
            await fs.promises.appendFile(this.logFile, logLine, 'utf8');
            // Clean up old logs
            await this.cleanupOldLogs();
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to write to log file: ${error.message}`);
        }
    }
    /**
     * Clean up old log files
     */
    async cleanupOldLogs() {
        if (!this.logFile)
            return;
        try {
            const fs = require('fs');
            const path = require('path');
            const logDir = path.dirname(this.logFile);
            // Get all log files
            const files = await fs.promises.readdir(logDir);
            const logFiles = files.filter(file => file.endsWith('.log'));
            // Sort by modification time
            const fileStats = await Promise.all(logFiles.map(async (file) => {
                const filePath = path.join(logDir, file);
                const stats = await fs.promises.stat(filePath);
                return { file, stats };
            }));
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to cleanup old logs: ${error.message}`);
        }
    }
    /**
     * Get log entries
     */
    getLogEntries() {
        return [...this.logEntries];
    }
    /**
     * Get log entries by level
     */
    getLogEntriesByLevel(level) {
        return this.logEntries.filter(entry => entry.level === level);
    }
    /**
     * Get log entries by date range
     */
    getLogEntriesByDate(startDate, endDate) {
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
    clear() {
        this.logEntries = [];
        this.emit('logCleared');
    }
    /**
     * Set log level
     */
    setLevel(level) {
        this.config.level = level;
        this.emit('levelChanged', level);
    }
    /**
     * Get current log level
     */
    getLevel() {
        return this.config.level;
    }
    /**
     * Dispose logger
     */
    dispose() {
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.Logger = Logger;
//# sourceMappingURL=logger.js.map