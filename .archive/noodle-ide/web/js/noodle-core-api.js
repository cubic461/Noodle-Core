/**
 * NoodleCore API Communication Layer
 * Handles all communication between the IDE and NoodleCore backend
 * Implements language independence through pure JavaScript API calls
 */

class NoodleCoreAPI {
    constructor(baseUrl = 'http://localhost:8080', timeout = 5000) {
        this.baseUrl = baseUrl;
        this.timeout = timeout;
        this.requestId = this.generateRequestId();
        this.connectionStatus = 'disconnected';
        this.retryAttempts = 0;
        this.maxRetries = 3;
        this.retryDelay = 1000;

        // Event listeners for connection status
        this.onConnectionChange = [];
        this.onError = [];
        this.onResponse = [];

        // Performance tracking
        this.performanceMetrics = {
            totalRequests: 0,
            successfulRequests: 0,
            failedRequests: 0,
            averageResponseTime: 0,
            lastRequestTime: 0
        };

        // Initialize connection
        this.init();
    }

    /**
     * Initialize API connection
     */
    init() {
        console.log('NoodleCore API initializing...');
        this.checkConnection();

        // Set up periodic connection check
        setInterval(() => {
            this.checkConnection();
        }, 30000); // Check every 30 seconds
    }

    /**
     * Generate a UUID v4 request ID as required by NoodleCore standards
     */
    generateRequestId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    /**
     * Make HTTP request to NoodleCore API
     */
    async request(endpoint, options = {}) {
        const startTime = performance.now();
        const url = `${this.baseUrl}${endpoint}`;

        // Default options
        const requestOptions = {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'X-Request-ID': this.requestId
            },
            timeout: this.timeout,
            ...options
        };

        try {
            this.performanceMetrics.totalRequests++;
            this.performanceMetrics.lastRequestTime = Date.now();

            // Add request timestamp to payload if it's a POST/PUT
            if (['POST', 'PUT', 'PATCH'].includes(requestOptions.method)) {
                if (!requestOptions.body) {
                    requestOptions.body = JSON.stringify({});
                }

                const body = JSON.parse(requestOptions.body);
                body.timestamp = new Date().toISOString() + 'Z';
                body.requestId = this.requestId;
                requestOptions.body = JSON.stringify(body);
            }

            const response = await fetch(url, requestOptions);
            const endTime = performance.now();
            const responseTime = endTime - startTime;

            // Update performance metrics
            this.updatePerformanceMetrics(responseTime, true);

            // Parse response
            const data = await response.json();

            // Check if response has error
            if (!data.success) {
                throw new APIError(data.error?.message || 'API request failed', data.error?.code || 500);
            }

            // Notify response listeners
            this.onResponse.forEach(callback => callback(endpoint, data));

            return data;

        } catch (error) {
            const endTime = performance.now();
            const responseTime = endTime - startTime;

            // Update performance metrics for failed request
            this.updatePerformanceMetrics(responseTime, false);

            // Handle different types of errors
            if (error instanceof APIError) {
                throw error;
            } else if (error.name === 'AbortError') {
                throw new APIError('Request timeout', 408);
            } else if (error.type === 'TypeError' && error.message.includes('fetch')) {
                this.updateConnectionStatus('disconnected');
                throw new APIError('Network error - unable to connect to NoodleCore', 503);
            } else {
                throw new APIError(`Request failed: ${error.message}`, 500);
            }
        }
    }

    /**
     * Update performance metrics
     */
    updatePerformanceMetrics(responseTime, success) {
        if (success) {
            this.performanceMetrics.successfulRequests++;
        } else {
            this.performanceMetrics.failedRequests++;
        }

        // Calculate average response time
        const total = this.performanceMetrics.totalRequests;
        const currentAvg = this.performanceMetrics.averageResponseTime;
        this.performanceMetrics.averageResponseTime =
            (currentAvg * (total - 1) + responseTime) / total;
    }

    /**
     * Update connection status and notify listeners
     */
    updateConnectionStatus(status) {
        if (this.connectionStatus !== status) {
            this.connectionStatus = status;
            this.onConnectionChange.forEach(callback => callback(status));
        }
    }

    /**
     * Check connection to NoodleCore
     */
    async checkConnection() {
        try {
            const response = await this.request('/api/v1/health', { method: 'GET' });

            if (response.success) {
                this.updateConnectionStatus('connected');
                this.retryAttempts = 0;
                console.log('NoodleCore connection established');
                return true;
            }
        } catch (error) {
            this.updateConnectionStatus('disconnected');
            console.warn('NoodleCore connection failed:', error.message);
        }

        return false;
    }

    /**
     * Get API information
     */
    async getInfo() {
        return await this.request('/');
    }

    /**
     * Get system health
     */
    async getHealth() {
        return await this.request('/api/v1/health');
    }

    /**
     * Get database status
     */
    async getDatabaseStatus() {
        return await this.request('/api/v1/database/status');
    }

    /**
     * Get runtime status
     */
    async getRuntimeStatus() {
        return await this.request('/api/v1/runtime/status');
    }

    /**
     * Execute NoodleCore operation
     */
    async executeOperation(operation, params = {}) {
        const payload = {
            operation: operation,
            ...params
        };

        return await this.request('/api/v1/execute', {
            method: 'POST',
            body: JSON.stringify(payload)
        });
    }

    /**
     * IDE-specific operations
     */

    /**
     * Get IDE status
     */
    async getIDEStatus() {
        return await this.executeOperation('get_ide_status');
    }

    /**
     * Open a file
     */
    async openFile(filePath) {
        return await this.executeOperation('open_file', { file_path: filePath });
    }

    /**
     * Save a file
     */
    async saveFile(filePath, content, metadata = {}) {
        return await this.executeOperation('save_file', {
            file_path: filePath,
            content: content,
            metadata: metadata
        });
    }

    /**
     * Create a new file
     */
    async createFile(filePath, content = '', fileType = 'noodle') {
        return await this.executeOperation('create_file', {
            file_path: filePath,
            content: content,
            file_type: fileType
        });
    }

    /**
     * Delete a file
     */
    async deleteFile(filePath) {
        return await this.executeOperation('delete_file', { file_path: filePath });
    }

    /**
     * List files in directory
     */
    async listFiles(directory) {
        return await this.executeOperation('list_files', { directory: directory });
    }

    /**
     * Search for files
     */
    async searchFiles(query, directory = '') {
        return await this.executeOperation('search_files', {
            query: query,
            directory: directory
        });
    }

    /**
     * Get syntax highlighting for content
     */
    async getSyntaxHighlight(content, fileType) {
        return await this.executeOperation('get_syntax_highlight', {
            content: content,
            file_type: fileType
        });
    }

    /**
     * Get code completions
     */
    async getCodeCompletions(content, position, fileType) {
        return await this.executeOperation('get_code_completions', {
            content: content,
            position: position,
            file_type: fileType
        });
    }

    /**
     * Execute code
     */
    async executeCode(content, fileType) {
        return await this.executeOperation('execute_code', {
            content: content,
            file_type: fileType
        });
    }

    /**
     * Create a new project
     */
    async createProject(projectPath, name, description = '') {
        return await this.executeOperation('create_project', {
            project_path: projectPath,
            name: name,
            description: description
        });
    }

    /**
     * Load an existing project
     */
    async loadProject(projectPath) {
        return await this.executeOperation('load_project', {
            project_path: projectPath
        });
    }

    /**
     * Get project files
     */
    async getProjectFiles(projectPath) {
        return await this.executeOperation('get_project_files', {
            project_path: projectPath
        });
    }

    /**
     * Format code
     */
    async formatCode(content, fileType) {
        return await this.executeOperation('format_code', {
            content: content,
            file_type: fileType
        });
    }

    /**
     * Validate code
     */
    async validateCode(content, fileType) {
        return await this.executeOperation('validate_code', {
            content: content,
            file_type: fileType
        });
    }

    /**
     * Get error diagnostics
     */
    async getDiagnostics(content, fileType) {
        return await this.executeOperation('get_diagnostics', {
            content: content,
            file_type: fileType
        });
    }

    /**
     * Add event listener for connection changes
     */
    onConnectionStatusChange(callback) {
        this.onConnectionChange.push(callback);
    }

    /**
     * Add event listener for errors
     */
    onErrorOccurred(callback) {
        this.onError.push(callback);
    }

    /**
     * Add event listener for responses
     */
    onResponseReceived(callback) {
        this.onResponse.push(callback);
    }

    /**
     * Remove event listener
     */
    removeListener(type, callback) {
        const listeners = this[`on${type}`];
        if (listeners) {
            const index = listeners.indexOf(callback);
            if (index > -1) {
                listeners.splice(index, 1);
            }
        }
    }

    /**
     * Get performance metrics
     */
    getPerformanceMetrics() {
        return {
            ...this.performanceMetrics,
            connectionStatus: this.connectionStatus,
            retryAttempts: this.retryAttempts
        };
    }

    /**
     * Retry failed request with exponential backoff
     */
    async retryRequest(requestFn, maxRetries = this.maxRetries) {
        let lastError;

        for (let attempt = 0; attempt <= maxRetries; attempt++) {
            try {
                this.retryAttempts = attempt;
                return await requestFn();
            } catch (error) {
                lastError = error;

                if (attempt === maxRetries) {
                    throw error;
                }

                // Wait with exponential backoff
                const delay = this.retryDelay * Math.pow(2, attempt);
                await this.sleep(delay);
            }
        }

        throw lastError;
    }

    /**
     * Sleep utility
     */
    sleep(ms) {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Close connections and cleanup
     */
    destroy() {
        this.onConnectionChange = [];
        this.onError = [];
        this.onResponse = [];
        this.updateConnectionStatus('disconnected');
        console.log('NoodleCore API destroyed');
    }
}

/**
 * Custom API Error class
 */
class APIError extends Error {
    constructor(message, code = 500, details = {}) {
        super(message);
        this.name = 'APIError';
        this.code = code;
        this.details = details;

        if (Error.captureStackTrace) {
            Error.captureStackTrace(this, APIError);
        }
    }

    toString() {
        return `[APIError ${this.code}] ${this.message}`;
    }

    toJSON() {
        return {
            name: this.name,
            message: this.message,
            code: this.code,
            details: this.details
        };
    }
}

/**
 * IDE API Manager - Higher level API for IDE operations
 */
class IDEManager {
    constructor(api) {
        this.api = api;
        this.currentProject = null;
        this.currentFile = null;
        this.fileCache = new Map();
        this.projectCache = new Map();

        // Performance monitoring
        this.operationHistory = [];
        this.maxHistorySize = 100;
    }

    /**
     * Initialize IDE manager
     */
    async initialize() {
        try {
            // Check API connection
            const health = await this.api.getHealth();
            if (!health.success) {
                throw new Error('NoodleCore API health check failed');
            }

            console.log('IDE Manager initialized successfully');
            return true;
        } catch (error) {
            console.error('IDE Manager initialization failed:', error);
            return false;
        }
    }

    /**
     * Open and load a file
     */
    async openFile(filePath) {
        try {
            const response = await this.api.openFile(filePath);

            if (response.success) {
                const fileInfo = response.data;
                this.currentFile = fileInfo;
                this.fileCache.set(filePath, fileInfo);

                this.recordOperation('open_file', filePath, true);
                return fileInfo;
            }

            throw new Error(response.error?.message || 'Failed to open file');
        } catch (error) {
            this.recordOperation('open_file', filePath, false, error.message);
            throw error;
        }
    }

    /**
     * Save current file
     */
    async saveFile(filePath = null, content = null) {
        try {
            const targetPath = filePath || (this.currentFile ? this.currentFile.path : null);
            const targetContent = content || (this.currentFile ? this.currentFile.content : '');

            if (!targetPath) {
                throw new Error('No file path specified');
            }

            const response = await this.api.saveFile(targetPath, targetContent);

            if (response.success) {
                // Update cache
                if (this.fileCache.has(targetPath)) {
                    const cachedFile = this.fileCache.get(targetPath);
                    cachedFile.content = targetContent;
                    cachedFile.modified_at = new Date().toISOString();
                    this.fileCache.set(targetPath, cachedFile);
                }

                this.recordOperation('save_file', targetPath, true);
                return response.data;
            }

            throw new Error(response.error?.message || 'Failed to save file');
        } catch (error) {
            this.recordOperation('save_file', filePath || 'unknown', false, error.message);
            throw error;
        }
    }

    /**
     * Create a new file
     */
    async createFile(filePath, content = '', fileType = 'noodle') {
        try {
            const response = await this.api.createFile(filePath, content, fileType);

            if (response.success) {
                const fileInfo = response.data;
                this.fileCache.set(filePath, fileInfo);
                this.currentFile = fileInfo;

                this.recordOperation('create_file', filePath, true);
                return fileInfo;
            }

            throw new Error(response.error?.message || 'Failed to create file');
        } catch (error) {
            this.recordOperation('create_file', filePath, false, error.message);
            throw error;
        }
    }

    /**
     * Load or create project
     */
    async loadProject(projectPath) {
        try {
            const response = await this.api.loadProject(projectPath);

            if (response.success) {
                const project = response.data;
                this.currentProject = project;
                this.projectCache.set(projectPath, project);

                this.recordOperation('load_project', projectPath, true);
                return project;
            }

            throw new Error(response.error?.message || 'Failed to load project');
        } catch (error) {
            this.recordOperation('load_project', projectPath, false, error.message);
            throw error;
        }
    }

    /**
     * Execute code in the current file or specified content
     */
    async executeCode(content = null, fileType = 'noodle') {
        try {
            const codeContent = content || (this.currentFile ? this.currentFile.content : '');
            const type = fileType || (this.currentFile ? this.currentFile.file_type : 'noodle');

            if (!codeContent.trim()) {
                throw new Error('No code content to execute');
            }

            const response = await this.api.executeCode(codeContent, type);

            if (response.success) {
                this.recordOperation('execute_code', (this.currentFile?.path || 'untitled'), true);
                return response.data;
            }

            throw new Error(response.error?.message || 'Failed to execute code');
        } catch (error) {
            this.recordOperation('execute_code', (this.currentFile?.path || 'untitled'), false, error.message);
            throw error;
        }
    }

    /**
     * Get code completions for current position
     */
    async getCodeCompletions(content, position, fileType = 'noodle') {
        try {
            const response = await this.api.getCodeCompletions(content, position, fileType);

            if (response.success) {
                return response.data;
            }

            throw new Error(response.error?.message || 'Failed to get completions');
        } catch (error) {
            console.error('Code completion failed:', error);
            return [];
        }
    }

    /**
     * Get syntax highlighting for content
     */
    async getSyntaxHighlight(content, fileType = 'noodle') {
        try {
            const response = await this.api.getSyntaxHighlight(content, fileType);

            if (response.success) {
                return response.data;
            }

            throw new Error(response.error?.message || 'Failed to get syntax highlight');
        } catch (error) {
            console.error('Syntax highlighting failed:', error);
            return [];
        }
    }

    /**
     * Record operation for history and analytics
     */
    recordOperation(operation, target, success, error = null) {
        const record = {
            operation,
            target,
            success,
            error,
            timestamp: Date.now(),
            duration: 0 // Could be measured externally
        };

        this.operationHistory.push(record);

        // Maintain history size
        if (this.operationHistory.length > this.maxHistorySize) {
            this.operationHistory = this.operationHistory.slice(-this.maxHistorySize);
        }
    }

    /**
     * Get operation history
     */
    getOperationHistory(limit = 50) {
        return this.operationHistory.slice(-limit);
    }

    /**
     * Get IDE statistics
     */
    getStatistics() {
        const totalOperations = this.operationHistory.length;
        const successfulOperations = this.operationHistory.filter(op => op.success).length;
        const failedOperations = totalOperations - successfulOperations;

        return {
            totalOperations,
            successfulOperations,
            failedOperations,
            successRate: totalOperations > 0 ? successfulOperations / totalOperations : 0,
            filesInCache: this.fileCache.size,
            projectsInCache: this.projectCache.size,
            currentProject: this.currentProject?.name || null,
            currentFile: this.currentFile?.path || null,
            apiPerformance: this.api.getPerformanceMetrics()
        };
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = { NoodleCoreAPI, APIError, IDEManager };
} else if (typeof window !== 'undefined') {
    window.NoodleCoreAPI = NoodleCoreAPI;
    window.APIError = APIError;
    window.IDEManager = IDEManager;
}