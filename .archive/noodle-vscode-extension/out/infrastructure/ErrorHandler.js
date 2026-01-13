"use strict";
/**
 * NoodleCore Error Handler
 *
 * Centralized error handling with recovery mechanisms,
 * error categorization, and comprehensive logging.
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
exports.ErrorHandler = exports.ErrorCategory = exports.ErrorSeverity = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
const uuid_1 = require("uuid");
var ErrorSeverity;
(function (ErrorSeverity) {
    ErrorSeverity["LOW"] = "low";
    ErrorSeverity["MEDIUM"] = "medium";
    ErrorSeverity["HIGH"] = "high";
    ErrorSeverity["CRITICAL"] = "critical";
})(ErrorSeverity = exports.ErrorSeverity || (exports.ErrorSeverity = {}));
var ErrorCategory;
(function (ErrorCategory) {
    ErrorCategory["SYSTEM"] = "system";
    ErrorCategory["NETWORK"] = "network";
    ErrorCategory["DATABASE"] = "database";
    ErrorCategory["AI_SERVICE"] = "ai_service";
    ErrorCategory["LSP"] = "lsp";
    ErrorCategory["VALIDATION"] = "validation";
    ErrorCategory["USER_INPUT"] = "user_input";
    ErrorCategory["CONFIGURATION"] = "configuration";
    ErrorCategory["RESOURCE"] = "resource";
    ErrorCategory["SECURITY"] = "security";
})(ErrorCategory = exports.ErrorCategory || (exports.ErrorCategory = {}));
class ErrorHandler extends events_1.EventEmitter {
    constructor() {
        super();
        this.errors = [];
        this.patterns = [];
        this.maxErrorHistory = 1000;
        this.retryAttempts = new Map();
        this.outputChannel = vscode.window.createOutputChannel('NoodleCore Error Handler');
        this.statistics = this.initializeStatistics();
        this.patterns = this.initializeErrorPatterns();
        this.setupGlobalErrorHandlers();
    }
    /**
     * Handle an error with context and recovery
     */
    async handleError(error, context, recovery) {
        const noodleError = this.createNoodleError(error, context, recovery);
        // Add to error history
        this.addError(noodleError);
        // Update statistics
        this.updateStatistics(noodleError);
        // Log error
        this.logError(noodleError);
        // Attempt recovery
        await this.attemptRecovery(noodleError);
        // Emit error event
        this.emit('error', noodleError);
        return noodleError;
    }
    /**
     * Handle error with automatic categorization
     */
    async handleErrorAuto(error, component, operation, additionalData) {
        const context = {
            component,
            operation,
            requestId: additionalData?.requestId,
            workspace: vscode.workspace.workspaceFolders?.[0]?.name,
            additionalData
        };
        return this.handleError(error, context);
    }
    /**
     * Get error by ID
     */
    getError(errorId) {
        return this.errors.find(error => error.id === errorId);
    }
    /**
     * Get all errors
     */
    getErrors(filter) {
        let filtered = [...this.errors];
        if (filter) {
            if (filter.category) {
                filtered = filtered.filter(error => error.category === filter.category);
            }
            if (filter.severity) {
                filtered = filtered.filter(error => error.severity === filter.severity);
            }
            if (filter.resolved !== undefined) {
                filtered = filtered.filter(error => error.resolved === filter.resolved);
            }
            if (filter.since) {
                const since = new Date(filter.since);
                filtered = filtered.filter(error => new Date(error.timestamp) >= since);
            }
            if (filter.limit) {
                filtered = filtered.slice(0, filter.limit);
            }
        }
        return filtered;
    }
    /**
     * Get error statistics
     */
    getStatistics() {
        return { ...this.statistics };
    }
    /**
     * Mark error as resolved
     */
    resolveError(errorId, resolution) {
        const error = this.getError(errorId);
        if (!error) {
            return false;
        }
        error.resolved = true;
        this.statistics.resolved++;
        this.statistics.unresolved--;
        // Calculate resolution time
        const resolutionTime = Date.now() - new Date(error.timestamp).getTime();
        this.updateAverageResolutionTime(resolutionTime);
        this.emit('errorResolved', { error, resolution });
        this.logResolution(error, resolution);
        return true;
    }
    /**
     * Add custom error pattern
     */
    addPattern(pattern) {
        this.patterns.push(pattern);
        this.emit('patternAdded', pattern);
    }
    /**
     * Remove error pattern
     */
    removePattern(code) {
        const index = this.patterns.findIndex(pattern => pattern.code === code);
        if (index !== -1) {
            this.patterns.splice(index, 1);
            this.emit('patternRemoved', code);
            return true;
        }
        return false;
    }
    /**
     * Get error patterns
     */
    getPatterns() {
        return [...this.patterns];
    }
    /**
     * Clear error history
     */
    clearHistory() {
        this.errors = [];
        this.statistics = this.initializeStatistics();
        this.retryAttempts.clear();
        this.emit('historyCleared');
    }
    /**
     * Export error report
     */
    exportReport(filter) {
        const errors = this.getErrors(filter);
        const report = {
            generatedAt: new Date().toISOString(),
            totalErrors: errors.length,
            statistics: this.statistics,
            errors: errors.map(error => ({
                id: error.id,
                code: error.code,
                message: error.message,
                severity: error.severity,
                category: error.category,
                component: error.context.component,
                operation: error.context.operation,
                timestamp: error.timestamp,
                resolved: error.resolved
            }))
        };
        return JSON.stringify(report, null, 2);
    }
    /**
     * Create NoodleError from generic error
     */
    createNoodleError(error, context, recovery) {
        const errorObj = typeof error === 'string' ? new Error(error) : error;
        // Find matching pattern
        const pattern = this.findMatchingPattern(errorObj);
        const noodleError = {
            id: (0, uuid_1.v4)(),
            code: pattern?.code || 'UNKNOWN_ERROR',
            message: errorObj.message,
            severity: pattern?.severity || ErrorSeverity.MEDIUM,
            category: pattern?.category || ErrorCategory.SYSTEM,
            context: {
                ...context,
                requestId: context.requestId || (0, uuid_1.v4)()
            },
            timestamp: new Date().toISOString(),
            stack: errorObj.stack,
            cause: errorObj.cause,
            recovery: { ...pattern?.recovery, ...recovery },
            resolved: false
        };
        return noodleError;
    }
    /**
     * Find matching error pattern
     */
    findMatchingPattern(error) {
        return this.patterns.find(pattern => {
            if (pattern.code && error.message.includes(pattern.code)) {
                return true;
            }
            if (pattern.message && pattern.message.test(error.message)) {
                return true;
            }
            return false;
        });
    }
    /**
     * Add error to history
     */
    addError(error) {
        this.errors.unshift(error);
        // Limit history size
        if (this.errors.length > this.maxErrorHistory) {
            this.errors = this.errors.slice(0, this.maxErrorHistory);
        }
        this.statistics.total++;
        this.statistics.unresolved++;
    }
    /**
     * Update error statistics
     */
    updateStatistics(error) {
        this.statistics.byCategory[error.category]++;
        this.statistics.bySeverity[error.severity]++;
    }
    /**
     * Attempt error recovery
     */
    async attemptRecovery(error) {
        if (!error.recovery?.canRecover) {
            return;
        }
        const retryKey = `${error.code}-${error.context.operation}`;
        const currentRetries = this.retryAttempts.get(retryKey) || 0;
        const maxRetries = error.recovery.retryCount || 3;
        if (currentRetries >= maxRetries) {
            await this.executeFallback(error);
            return;
        }
        this.retryAttempts.set(retryKey, currentRetries + 1);
        // Wait before retry
        const delay = error.recovery.retryDelay || 1000;
        await new Promise(resolve => setTimeout(resolve, delay));
        this.emit('retryAttempt', { error, attempt: currentRetries + 1 });
    }
    /**
     * Execute fallback action
     */
    async executeFallback(error) {
        if (error.recovery?.fallbackAction) {
            try {
                await error.recovery.fallbackAction();
                this.emit('fallbackExecuted', { error });
            }
            catch (fallbackError) {
                this.emit('fallbackFailed', { error, fallbackError });
            }
        }
    }
    /**
     * Log error to output channel
     */
    logError(error) {
        const logLevel = error.recovery?.logLevel || 'error';
        this.outputChannel.appendLine(`[${logLevel.toUpperCase()}] ${error.timestamp} - ${error.category}/${error.severity}`);
        this.outputChannel.appendLine(`Code: ${error.code}`);
        this.outputChannel.appendLine(`Message: ${error.message}`);
        this.outputChannel.appendLine(`Component: ${error.context.component}`);
        this.outputChannel.appendLine(`Operation: ${error.context.operation}`);
        if (error.context.additionalData) {
            this.outputChannel.appendLine(`Additional Data: ${JSON.stringify(error.context.additionalData)}`);
        }
        if (error.stack) {
            this.outputChannel.appendLine(`Stack: ${error.stack}`);
        }
        this.outputChannel.appendLine('---');
        this.outputChannel.show();
    }
    /**
     * Log error resolution
     */
    logResolution(error, resolution) {
        this.outputChannel.appendLine(`[INFO] ${new Date().toISOString()} - Error Resolved`);
        this.outputChannel.appendLine(`Error ID: ${error.id}`);
        this.outputChannel.appendLine(`Code: ${error.code}`);
        if (resolution) {
            this.outputChannel.appendLine(`Resolution: ${resolution}`);
        }
        this.outputChannel.appendLine('---');
    }
    /**
     * Update average resolution time
     */
    updateAverageResolutionTime(resolutionTime) {
        const total = this.statistics.averageResolutionTime * (this.statistics.resolved - 1) + resolutionTime;
        this.statistics.averageResolutionTime = total / this.statistics.resolved;
    }
    /**
     * Initialize statistics
     */
    initializeStatistics() {
        return {
            total: 0,
            byCategory: {
                [ErrorCategory.SYSTEM]: 0,
                [ErrorCategory.NETWORK]: 0,
                [ErrorCategory.DATABASE]: 0,
                [ErrorCategory.AI_SERVICE]: 0,
                [ErrorCategory.LSP]: 0,
                [ErrorCategory.VALIDATION]: 0,
                [ErrorCategory.USER_INPUT]: 0,
                [ErrorCategory.CONFIGURATION]: 0,
                [ErrorCategory.RESOURCE]: 0,
                [ErrorCategory.SECURITY]: 0
            },
            bySeverity: {
                [ErrorSeverity.LOW]: 0,
                [ErrorSeverity.MEDIUM]: 0,
                [ErrorSeverity.HIGH]: 0,
                [ErrorSeverity.CRITICAL]: 0
            },
            resolved: 0,
            unresolved: 0,
            averageResolutionTime: 0
        };
    }
    /**
     * Initialize error patterns
     */
    initializeErrorPatterns() {
        return [
            // Network errors
            {
                code: 'NETWORK_TIMEOUT',
                message: /timeout|timed out/i,
                category: ErrorCategory.NETWORK,
                severity: ErrorSeverity.MEDIUM,
                recovery: {
                    canRecover: true,
                    retryCount: 3,
                    retryDelay: 2000,
                    userMessage: 'Network timeout occurred. Retrying...',
                    logLevel: 'warning'
                }
            },
            {
                code: 'NETWORK_CONNECTION_REFUSED',
                message: /connection refused|ECONNREFUSED/i,
                category: ErrorCategory.NETWORK,
                severity: ErrorSeverity.HIGH,
                recovery: {
                    canRecover: true,
                    retryCount: 5,
                    retryDelay: 5000,
                    userMessage: 'Connection refused. Please check if the service is running.',
                    logLevel: 'error'
                }
            },
            // Database errors
            {
                code: 'DATABASE_CONNECTION_FAILED',
                message: /database.*connection|connection.*database/i,
                category: ErrorCategory.DATABASE,
                severity: ErrorSeverity.HIGH,
                recovery: {
                    canRecover: true,
                    retryCount: 3,
                    retryDelay: 3000,
                    userMessage: 'Database connection failed. Attempting to reconnect...',
                    logLevel: 'error'
                }
            },
            // AI Service errors
            {
                code: 'AI_SERVICE_UNAVAILABLE',
                message: /ai.*service.*unavailable|service.*ai.*down/i,
                category: ErrorCategory.AI_SERVICE,
                severity: ErrorSeverity.HIGH,
                recovery: {
                    canRecover: true,
                    retryCount: 2,
                    retryDelay: 5000,
                    fallbackAction: async () => {
                        vscode.window.showWarningMessage('AI service is temporarily unavailable. Some features may be limited.', 'OK');
                    },
                    userMessage: 'AI service is unavailable. Switching to limited mode...',
                    logLevel: 'error'
                }
            },
            // LSP errors
            {
                code: 'LSP_STARTUP_FAILED',
                message: /lsp.*startup.*failed|language.*server.*failed/i,
                category: ErrorCategory.LSP,
                severity: ErrorSeverity.MEDIUM,
                recovery: {
                    canRecover: true,
                    retryCount: 2,
                    retryDelay: 1000,
                    userMessage: 'Language server failed to start. Retrying...',
                    logLevel: 'warning'
                }
            },
            // Resource errors
            {
                code: 'OUT_OF_MEMORY',
                message: /out of memory|memory.*exceeded/i,
                category: ErrorCategory.RESOURCE,
                severity: ErrorSeverity.CRITICAL,
                recovery: {
                    canRecover: true,
                    fallbackAction: async () => {
                        vscode.window.showErrorMessage('Out of memory. Please save your work and restart VS Code.', 'Restart Now').then(selection => {
                            if (selection === 'Restart Now') {
                                vscode.commands.executeCommand('workbench.action.reloadWindow');
                            }
                        });
                    },
                    userMessage: 'Memory usage is critically high. Please restart the extension.',
                    logLevel: 'error'
                }
            },
            // Validation errors
            {
                code: 'VALIDATION_FAILED',
                message: /validation.*failed|invalid.*input/i,
                category: ErrorCategory.VALIDATION,
                severity: ErrorSeverity.LOW,
                recovery: {
                    canRecover: false,
                    userMessage: 'Input validation failed. Please check your input.',
                    logLevel: 'info'
                }
            }
        ];
    }
    /**
     * Setup global error handlers
     */
    setupGlobalErrorHandlers() {
        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.handleErrorAuto(error, 'Process', 'Uncaught Exception');
        });
        // Handle unhandled promise rejections
        process.on('unhandledRejection', (reason, promise) => {
            this.handleErrorAuto(reason instanceof Error ? reason : new Error(String(reason)), 'Process', 'Unhandled Promise Rejection', { promise: promise.toString() });
        });
        // Handle VS Code extension errors
        const disposables = [
            vscode.window.onDidChangeActiveTextEditor(() => {
                // Clear retry attempts when switching editors
                this.retryAttempts.clear();
            })
        ];
        // Cleanup on disposal
        this.on('dispose', () => {
            disposables.forEach(d => d.dispose());
        });
    }
    /**
     * Dispose error handler
     */
    dispose() {
        this.clearHistory();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.ErrorHandler = ErrorHandler;
//# sourceMappingURL=ErrorHandler.js.map