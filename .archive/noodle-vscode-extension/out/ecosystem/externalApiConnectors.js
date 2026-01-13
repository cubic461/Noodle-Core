"use strict";
/**
 * NoodleCore External API Connectors
 *
 * Provides a unified interface for connecting to various external APIs
 * and services, with standardized authentication, rate limiting,
 * and error handling across different providers.
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
exports.ExternalApiConnectors = void 0;
const vscode = __importStar(require("vscode"));
const axios_1 = __importDefault(require("axios"));
const uuid_1 = require("uuid");
class ExternalApiConnectors {
    constructor(workspaceRoot) {
        this.connectors = new Map();
        this.apiClients = new Map();
        this.rateLimiters = new Map();
        this.webhooks = new Map();
        this.requestQueue = new Map();
        this.isProcessing = false;
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle API Connectors');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 50);
        this.statusBarItem.command = 'noodle.api.showStatus';
        this.statusBarItem.show();
        this.initializeConnectors();
    }
    /**
     * Initialize API connectors from configuration
     */
    async initializeConnectors() {
        try {
            const config = vscode.workspace.getConfiguration('noodle.api');
            const connectors = config.get('connectors', []);
            for (const connector of connectors) {
                if (connector.enabled) {
                    await this.addConnector(connector);
                }
            }
            this.outputChannel.appendLine(`Initialized ${this.connectors.size} API connectors`);
            this.updateStatusBar();
        }
        catch (error) {
            throw new Error(`Failed to initialize API connectors: ${error.message}`);
        }
    }
    /**
     * Add an API connector
     */
    async addConnector(connector) {
        try {
            this.connectors.set(connector.id, connector);
            // Initialize API client
            const apiClient = await this.createApiClient(connector);
            this.apiClients.set(connector.id, apiClient);
            // Initialize rate limiter
            const rateLimiter = new RateLimiter(connector.rateLimit);
            this.rateLimiters.set(connector.id, rateLimiter);
            // Initialize request queue
            this.requestQueue.set(connector.id, []);
            this.outputChannel.appendLine(`Added API connector: ${connector.name}`);
        }
        catch (error) {
            throw new Error(`Failed to add connector ${connector.id}: ${error.message}`);
        }
    }
    /**
     * Create API client for connector
     */
    async createApiClient(connector) {
        try {
            const headers = { ...connector.headers };
            // Add authentication headers
            this.addAuthenticationHeaders(headers, connector.authentication);
            const axiosConfig = {
                baseURL: connector.baseUrl,
                headers,
                timeout: connector.timeout || 30000,
                validateStatus: false
            };
            // Add interceptors for logging and rate limiting
            const client = axios_1.default.create(axiosConfig);
            // Request interceptor
            client.interceptors.request.use((config) => {
                this.logRequest(connector.id, config);
                return config;
            }, (error) => {
                this.outputChannel.appendLine(`Request error: ${error.message}`);
                return Promise.reject(error);
            });
            // Response interceptor
            client.interceptors.response.use((response) => {
                this.logResponse(connector.id, response);
                return response;
            }, (error) => {
                this.logError(connector.id, error);
                return Promise.reject(error);
            });
            return client;
        }
        catch (error) {
            throw new Error(`Failed to create API client: ${error.message}`);
        }
    }
    /**
     * Add authentication headers
     */
    addAuthenticationHeaders(headers, auth) {
        switch (auth.type) {
            case 'api-key':
                if (auth.apiKey) {
                    headers['Authorization'] = `Bearer ${auth.apiKey}`;
                    headers['X-API-Key'] = auth.apiKey;
                }
                break;
            case 'basic':
                if (auth.username && auth.password) {
                    const basic = Buffer.from(`${auth.username}:${auth.password}`).toString('base64');
                    headers['Authorization'] = `Basic ${basic}`;
                }
                break;
            case 'bearer':
                if (auth.token) {
                    headers['Authorization'] = `Bearer ${auth.token}`;
                }
                break;
            case 'oauth2':
                if (auth.oauth?.accessToken) {
                    headers['Authorization'] = `Bearer ${auth.oauth.accessToken}`;
                }
                break;
            case 'custom':
                if (auth.custom) {
                    Object.assign(headers, auth.custom);
                }
                break;
        }
    }
    /**
     * Make API request
     */
    async makeRequest(connectorId, request) {
        const connector = this.connectors.get(connectorId);
        const apiClient = this.apiClients.get(connectorId);
        const rateLimiter = this.rateLimiters.get(connectorId);
        if (!connector || !apiClient) {
            throw new Error(`Connector ${connectorId} not found`);
        }
        const requestId = request.metadata?.requestId || (0, uuid_1.v4)();
        const startTime = Date.now();
        try {
            // Check rate limit
            await rateLimiter.acquire();
            // Add request to queue for tracking
            const queue = this.requestQueue.get(connectorId) || [];
            const queuedRequest = {
                ...request,
                id: requestId,
                metadata: {
                    ...request.metadata,
                    queuedAt: new Date().toISOString(),
                    connectorId
                }
            };
            queue.push(queuedRequest);
            // Prepare request config
            const requestConfig = {
                method: request.method,
                url: request.url,
                headers: request.headers,
                params: request.params,
                data: request.data,
                timeout: request.timeout || connector.timeout,
                responseType: 'json'
            };
            // Execute request with retry logic
            const response = await this.executeWithRetry(apiClient, requestConfig, connector.retryConfig);
            const duration = Date.now() - startTime;
            // Process response
            const apiResponse = {
                requestId,
                success: response.status >= 200 && response.status < 300,
                data: response.data,
                headers: response.headers,
                status: response.status,
                statusText: response.statusText,
                timestamp: new Date().toISOString(),
                duration
            };
            // Handle errors
            if (!apiResponse.success) {
                apiResponse.error = this.parseApiError(response.data, response.status);
            }
            // Log successful request
            this.logSuccess(connectorId, apiResponse);
            // Remove from queue
            const index = queue.findIndex(req => req.id === requestId);
            if (index !== -1) {
                queue.splice(index, 1);
            }
            return apiResponse;
        }
        catch (error) {
            const duration = Date.now() - startTime;
            const apiResponse = {
                requestId,
                success: false,
                error: {
                    code: 'REQUEST_FAILED',
                    message: error.message,
                    timestamp: new Date().toISOString(),
                    requestId
                },
                status: 0,
                statusText: 'Request Failed',
                timestamp: new Date().toISOString(),
                duration
            };
            this.logError(connectorId, error);
            return apiResponse;
        }
    }
    /**
     * Execute request with retry logic
     */
    async executeWithRetry(apiClient, config, retryConfig) {
        let lastError;
        let attempt = 0;
        while (attempt < retryConfig.maxAttempts) {
            try {
                return await apiClient.request(config);
            }
            catch (error) {
                lastError = error;
                attempt++;
                if (attempt < retryConfig.maxAttempts) {
                    const isRetryable = retryConfig.retryableStatusCodes.includes(error.response?.status);
                    if (isRetryable) {
                        const delay = Math.min(retryConfig.baseDelay * Math.pow(retryConfig.backoffMultiplier, attempt - 1), retryConfig.maxDelay);
                        this.outputChannel.appendLine(`Request failed (attempt ${attempt}), retrying in ${delay}ms`);
                        await this.sleep(delay);
                        continue;
                    }
                }
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
     * Parse API error from response
     */
    parseApiError(data, status) {
        if (typeof data === 'object' && data !== null) {
            return {
                code: data.code || 'UNKNOWN_ERROR',
                message: data.message || 'Unknown error occurred',
                details: data.details,
                timestamp: new Date().toISOString(),
                requestId: (0, uuid_1.v4)()
            };
        }
        return {
            code: status.toString(),
            message: `HTTP ${status}: ${this.getStatusText(status)}`,
            timestamp: new Date().toISOString(),
            requestId: (0, uuid_1.v4)()
        };
    }
    /**
     * Get status text for HTTP status code
     */
    getStatusText(status) {
        const statusTexts = {
            200: 'OK',
            201: 'Created',
            202: 'Accepted',
            204: 'No Content',
            400: 'Bad Request',
            401: 'Unauthorized',
            403: 'Forbidden',
            404: 'Not Found',
            405: 'Method Not Allowed',
            409: 'Conflict',
            422: 'Unprocessable Entity',
            429: 'Too Many Requests',
            500: 'Internal Server Error',
            502: 'Bad Gateway',
            503: 'Service Unavailable',
            504: 'Gateway Timeout'
        };
        return statusTexts[status] || 'Unknown';
    }
    /**
     * Log request
     */
    logRequest(connectorId, config) {
        const connector = this.connectors.get(connectorId);
        if (!connector)
            return;
        this.outputChannel.appendLine(`[${connectorId}] ${config.method?.toUpperCase()} ${config.url}`);
        if (config.headers) {
            this.outputChannel.appendLine(`[${connectorId}] Headers: ${JSON.stringify(config.headers)}`);
        }
        if (config.params) {
            this.outputChannel.appendLine(`[${connectorId}] Params: ${JSON.stringify(config.params)}`);
        }
        if (config.data) {
            this.outputChannel.appendLine(`[${connectorId}] Data: ${JSON.stringify(config.data)}`);
        }
    }
    /**
     * Log response
     */
    logResponse(connectorId, response) {
        const connector = this.connectors.get(connectorId);
        if (!connector)
            return;
        this.outputChannel.appendLine(`[${connectorId}] Response: ${response.status} (${response.statusText})`);
        if (response.headers) {
            this.outputChannel.appendLine(`[${connectorId}] Response Headers: ${JSON.stringify(response.headers)}`);
        }
        const duration = response.config.metadata?.duration;
        if (duration) {
            this.outputChannel.appendLine(`[${connectorId}] Duration: ${duration}ms`);
        }
    }
    /**
     * Log success
     */
    logSuccess(connectorId, apiResponse) {
        const connector = this.connectors.get(connectorId);
        if (!connector)
            return;
        this.outputChannel.appendLine(`[${connectorId}] Success: ${apiResponse.requestId} (${apiResponse.duration}ms)`);
    }
    /**
     * Log error
     */
    logError(connectorId, error) {
        const connector = this.connectors.get(connectorId);
        if (!connector)
            return;
        this.outputChannel.appendLine(`[${connectorId}] Error: ${error.message}`);
        if (error.response) {
            this.outputChannel.appendLine(`[${connectorId}] Status: ${error.response.status} ${error.response.statusText}`);
        }
    }
    /**
     * Setup webhook for connector
     */
    async setupWebhook(connectorId, webhook) {
        try {
            this.webhooks.set(connectorId, webhook);
            // Create webhook endpoint handler
            const webhookHandler = new WebhookHandler(connectorId, webhook, this.outputChannel);
            await webhookHandler.start();
            vscode.window.showInformationMessage(`Webhook configured for ${connectorId}`);
        }
        catch (error) {
            throw new Error(`Failed to setup webhook: ${error.message}`);
        }
    }
    /**
     * Get connector status
     */
    async getConnectorStatus(connectorId) {
        const statuses = {};
        for (const [id, connector] of this.connectors) {
            if (!connectorId || id === connectorId) {
                const rateLimiter = this.rateLimiters.get(id);
                const queue = this.requestQueue.get(id) || [];
                statuses[id] = {
                    connector: {
                        id: connector.id,
                        name: connector.name,
                        type: connector.type,
                        baseUrl: connector.baseUrl,
                        enabled: connector.enabled
                    },
                    rateLimit: rateLimiter.getStatus(),
                    queue: {
                        length: queue.length,
                        processing: this.isProcessing
                    },
                    webhooks: this.webhooks.get(id) || null
                };
            }
        }
        return statuses;
    }
    /**
     * Test connector connection
     */
    async testConnection(connectorId) {
        try {
            const connector = this.connectors.get(connectorId);
            if (!connector) {
                throw new Error(`Connector ${connectorId} not found`);
            }
            // Make a simple health check request
            const response = await this.makeRequest(connectorId, {
                id: (0, uuid_1.v4)(),
                method: 'GET',
                url: '/health',
                timeout: 5000,
                metadata: { test: true }
            });
            return response.success;
        }
        catch (error) {
            this.outputChannel.appendLine(`Connection test failed for ${connectorId}: ${error.message}`);
            return false;
        }
    }
    /**
     * Update status bar
     */
    updateStatusBar() {
        const activeConnectors = Array.from(this.connectors.values())
            .filter(c => c.enabled)
            .length;
        let totalQueued = 0;
        for (const queue of this.requestQueue.values()) {
            totalQueued += queue.length;
        }
        this.statusBarItem.text = `$(plug) ${activeConnectors} APIs`;
        this.statusBarItem.tooltip = `
Active Connectors: ${activeConnectors}
Queued Requests: ${totalQueued}
Processing: ${this.isProcessing}
        `.trim();
    }
    /**
     * Show API status in output channel
     */
    async showStatus() {
        try {
            const statuses = await this.getConnectorStatus();
            let output = `API Connectors Status\n`;
            output += `====================\n\n`;
            for (const [id, status] of Object.entries(statuses)) {
                output += `Connector: ${status.connector.name} (${id})\n`;
                output += `Type: ${status.connector.type}\n`;
                output += `Status: ${status.connector.enabled ? 'Enabled' : 'Disabled'}\n`;
                output += `Base URL: ${status.connector.baseUrl}\n`;
                if (status.connector.enabled) {
                    output += `Rate Limit: ${JSON.stringify(status.rateLimit)}\n`;
                    output += `Queue: ${status.queue.length} requests\n`;
                    output += `Processing: ${status.queue.processing ? 'Yes' : 'No'}\n`;
                    if (status.webhooks) {
                        output += `Webhooks: ${status.webhooks.events.length} events\n`;
                    }
                }
                output += '\n';
            }
            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show API status: ${error.message}`);
        }
    }
    /**
     * Dispose API connectors
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.ExternalApiConnectors = ExternalApiConnectors;
/**
 * Rate Limiter Class
 */
class RateLimiter {
    constructor(config) {
        this.requests = [];
        this.config = config;
    }
    /**
     * Acquire request slot
     */
    async acquire() {
        const now = Date.now();
        // Clean old requests
        this.requests = this.requests.filter(timestamp => now - timestamp < 60000 // Keep last minute
        );
        // Check rate limits
        if (this.config.requestsPerSecond > 0) {
            const recentRequests = this.requests.filter(timestamp => now - timestamp < 1000);
            if (recentRequests.length >= this.config.requestsPerSecond) {
                throw new Error('Rate limit exceeded (per second)');
            }
        }
        if (this.config.requestsPerMinute > 0) {
            const minuteRequests = this.requests.filter(timestamp => now - timestamp < 60000);
            if (minuteRequests.length >= this.config.requestsPerMinute) {
                throw new Error('Rate limit exceeded (per minute)');
            }
        }
        if (this.config.requestsPerHour > 0) {
            const hourRequests = this.requests.filter(timestamp => now - timestamp < 3600000);
            if (hourRequests.length >= this.config.requestsPerHour) {
                throw new Error('Rate limit exceeded (per hour)');
            }
        }
        if (this.config.requestsPerDay > 0) {
            const dayRequests = this.requests.filter(timestamp => now - timestamp < 86400000);
            if (dayRequests.length >= this.config.requestsPerDay) {
                throw new Error('Rate limit exceeded (per day)');
            }
        }
        this.requests.push(now);
    }
    /**
     * Get rate limit status
     */
    getStatus() {
        const now = Date.now();
        const recentRequests = {
            second: this.requests.filter(t => now - t < 1000).length,
            minute: this.requests.filter(t => now - t < 60000).length,
            hour: this.requests.filter(t => now - t < 3600000).length,
            day: this.requests.filter(t => now - t < 86400000).length
        };
        return {
            current: recentRequests,
            limits: this.config,
            remaining: {
                second: Math.max(0, this.config.requestsPerSecond - recentRequests.second),
                minute: Math.max(0, this.config.requestsPerMinute - recentRequests.minute),
                hour: Math.max(0, this.config.requestsPerHour - recentRequests.hour),
                day: Math.max(0, this.config.requestsPerDay - recentRequests.day)
            }
        };
    }
}
/**
 * Webhook Handler Class
 */
class WebhookHandler {
    constructor(connectorId, config, outputChannel) {
        this.connectorId = connectorId;
        this.config = config;
        this.outputChannel = outputChannel;
    }
    /**
     * Start webhook server
     */
    async start() {
        // This would start a local server to handle webhooks
        // Implementation depends on the specific requirements
        this.outputChannel.appendLine(`Webhook started for ${this.connectorId} on ${this.config.url}`);
    }
    /**
     * Stop webhook server
     */
    async stop() {
        if (this.server) {
            await this.server.close();
            this.server = undefined;
        }
    }
    /**
     * Handle incoming webhook
     */
    handleWebhook(request, response) {
        // Verify webhook secret if provided
        if (this.config.secret) {
            const signature = request.headers['x-webhook-signature'];
            if (!this.verifySignature(request.body, signature)) {
                response.status(401).send('Unauthorized');
                return;
            }
        }
        // Process webhook event
        this.outputChannel.appendLine(`Webhook event received: ${JSON.stringify(request.body)}`);
        // Send success response
        response.status(200).send('OK');
    }
    /**
     * Verify webhook signature
     */
    verifySignature(payload, signature) {
        // Implementation depends on the signature method (HMAC-SHA256, etc.)
        return true; // Placeholder
    }
}
//# sourceMappingURL=externalApiConnectors.js.map