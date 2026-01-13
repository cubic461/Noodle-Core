/**
 * NoodleCore External API Connectors
 * 
 * Provides a unified interface for connecting to various external APIs
 * and services, with standardized authentication, rate limiting,
 * and error handling across different providers.
 */

import * as vscode from 'vscode';
import axios, { AxiosInstance, AxiosResponse, AxiosRequestConfig } from 'axios';
import { v4 as uuidv4 } from 'uuid';

export interface ApiConnector {
    id: string;
    name: string;
    type: ConnectorType;
    baseUrl: string;
    authentication: AuthenticationConfig;
    rateLimit: RateLimitConfig;
    retryConfig: RetryConfig;
    headers: { [key: string]: string };
    timeout: number;
    enabled: boolean;
}

export interface AuthenticationConfig {
    type: AuthenticationType;
    apiKey?: string;
    username?: string;
    password?: string;
    token?: string;
    oauth?: OAuthConfig;
    custom?: { [key: string]: string };
}

export interface OAuthConfig {
    clientId: string;
    clientSecret: string;
    redirectUri: string;
    scopes: string[];
    accessToken?: string;
    refreshToken?: string;
    expiresAt?: string;
}

export interface RateLimitConfig {
    requestsPerSecond: number;
    requestsPerMinute: number;
    requestsPerHour: number;
    requestsPerDay: number;
    burstLimit: number;
}

export interface RetryConfig {
    maxAttempts: number;
    baseDelay: number;
    maxDelay: number;
    backoffMultiplier: number;
    retryableStatusCodes: number[];
}

export interface ApiRequest {
    id: string;
    method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
    url: string;
    headers?: { [key: string]: string };
    params?: { [key: string]: any };
    data?: any;
    timeout?: number;
    retries?: number;
    metadata?: { [key: string]: any };
}

export interface ApiResponse<T = any> {
    requestId: string;
    success: boolean;
    data?: T;
    error?: ApiError;
    headers?: { [key: string]: string };
    status: number;
    statusText: string;
    timestamp: string;
    duration: number;
}

export interface ApiError {
    code: string;
    message: string;
    details?: any;
    timestamp: string;
    requestId: string;
}

export interface WebhookConfig {
    url: string;
    secret?: string;
    events: string[];
    headers?: { [key: string]: string };
    retryConfig: RetryConfig;
    enabled: boolean;
}

export interface ApiEndpoint {
    path: string;
    method: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH';
    description: string;
    parameters: ApiParameter[];
    requestBody?: ApiParameter;
    responses: ApiResponseExample[];
    rateLimit?: RateLimitConfig;
}

export interface ApiParameter {
    name: string;
    type: 'string' | 'number' | 'boolean' | 'array' | 'object';
    required: boolean;
    description: string;
    example?: any;
    validation?: ValidationRule[];
}

export interface ValidationRule {
    rule: string;
    message: string;
}

export interface ApiResponseExample {
    status: number;
    description: string;
    schema?: any;
}

export type ConnectorType = 'rest' | 'graphql' | 'websocket' | 'grpc' | 'custom';
export type AuthenticationType = 'none' | 'api-key' | 'basic' | 'bearer' | 'oauth2' | 'custom';

export class ExternalApiConnectors {
    private workspaceRoot: string;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private connectors: Map<string, ApiConnector> = new Map();
    private apiClients: Map<string, AxiosInstance> = new Map();
    private rateLimiters: Map<string, RateLimiter> = new Map();
    private webhooks: Map<string, WebhookConfig> = new Map();
    private requestQueue: Map<string, ApiRequest[]> = new Map();
    private isProcessing = false;

    constructor(workspaceRoot: string) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle API Connectors');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            50
        );
        this.statusBarItem.command = 'noodle.api.showStatus';
        this.statusBarItem.show();
        
        this.initializeConnectors();
    }

    /**
     * Initialize API connectors from configuration
     */
    private async initializeConnectors(): Promise<void> {
        try {
            const config = vscode.workspace.getConfiguration('noodle.api');
            const connectors = config.get<ApiConnector[]>('connectors', []);
            
            for (const connector of connectors) {
                if (connector.enabled) {
                    await this.addConnector(connector);
                }
            }

            this.outputChannel.appendLine(`Initialized ${this.connectors.size} API connectors`);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to initialize API connectors: ${error.message}`);
        }
    }

    /**
     * Add an API connector
     */
    public async addConnector(connector: ApiConnector): Promise<void> {
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
        } catch (error) {
            throw new Error(`Failed to add connector ${connector.id}: ${error.message}`);
        }
    }

    /**
     * Create API client for connector
     */
    private async createApiClient(connector: ApiConnector): Promise<AxiosInstance> {
        try {
            const headers = { ...connector.headers };
            
            // Add authentication headers
            this.addAuthenticationHeaders(headers, connector.authentication);
            
            const axiosConfig: AxiosRequestConfig = {
                baseURL: connector.baseUrl,
                headers,
                timeout: connector.timeout || 30000,
                validateStatus: false
            };

            // Add interceptors for logging and rate limiting
            const client = axios.create(axiosConfig);
            
            // Request interceptor
            client.interceptors.request.use(
                (config) => {
                    this.logRequest(connector.id, config);
                    return config;
                },
                (error) => {
                    this.outputChannel.appendLine(`Request error: ${error.message}`);
                    return Promise.reject(error);
                }
            );

            // Response interceptor
            client.interceptors.response.use(
                (response) => {
                    this.logResponse(connector.id, response);
                    return response;
                },
                (error) => {
                    this.logError(connector.id, error);
                    return Promise.reject(error);
                }
            );

            return client;
        } catch (error) {
            throw new Error(`Failed to create API client: ${error.message}`);
        }
    }

    /**
     * Add authentication headers
     */
    private addAuthenticationHeaders(
        headers: { [key: string]: string },
        auth: AuthenticationConfig
    ): void {
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
    public async makeRequest<T = any>(
        connectorId: string,
        request: ApiRequest
    ): Promise<ApiResponse<T>> {
        const connector = this.connectors.get(connectorId);
        const apiClient = this.apiClients.get(connectorId);
        const rateLimiter = this.rateLimiters.get(connectorId);
        
        if (!connector || !apiClient) {
            throw new Error(`Connector ${connectorId} not found`);
        }

        const requestId = request.metadata?.requestId || uuidv4();
        const startTime = Date.now();

        try {
            // Check rate limit
            await rateLimiter.acquire();

            // Add request to queue for tracking
            const queue = this.requestQueue.get(connectorId) || [];
            const queuedRequest: ApiRequest = {
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
            const requestConfig: AxiosRequestConfig = {
                method: request.method,
                url: request.url,
                headers: request.headers,
                params: request.params,
                data: request.data,
                timeout: request.timeout || connector.timeout,
                responseType: 'json'
            };

            // Execute request with retry logic
            const response = await this.executeWithRetry(
                apiClient,
                requestConfig,
                connector.retryConfig
            );

            const duration = Date.now() - startTime;

            // Process response
            const apiResponse: ApiResponse<T> = {
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
        } catch (error) {
            const duration = Date.now() - startTime;
            const apiResponse: ApiResponse<T> = {
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
    private async executeWithRetry<T = any>(
        apiClient: AxiosInstance,
        config: AxiosRequestConfig,
        retryConfig: RetryConfig
    ): Promise<AxiosResponse<T>> {
        let lastError: any;
        let attempt = 0;

        while (attempt < retryConfig.maxAttempts) {
            try {
                return await apiClient.request(config);
            } catch (error) {
                lastError = error;
                attempt++;

                if (attempt < retryConfig.maxAttempts) {
                    const isRetryable = retryConfig.retryableStatusCodes.includes(
                        error.response?.status
                    );

                    if (isRetryable) {
                        const delay = Math.min(
                            retryConfig.baseDelay * Math.pow(retryConfig.backoffMultiplier, attempt - 1),
                            retryConfig.maxDelay
                        );

                        this.outputChannel.appendLine(
                            `Request failed (attempt ${attempt}), retrying in ${delay}ms`
                        );

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
    private sleep(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }

    /**
     * Parse API error from response
     */
    private parseApiError(data: any, status: number): ApiError {
        if (typeof data === 'object' && data !== null) {
            return {
                code: data.code || 'UNKNOWN_ERROR',
                message: data.message || 'Unknown error occurred',
                details: data.details,
                timestamp: new Date().toISOString(),
                requestId: uuidv4()
            };
        }

        return {
            code: status.toString(),
            message: `HTTP ${status}: ${this.getStatusText(status)}`,
            timestamp: new Date().toISOString(),
            requestId: uuidv4()
        };
    }

    /**
     * Get status text for HTTP status code
     */
    private getStatusText(status: number): string {
        const statusTexts: { [key: number]: string } = {
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
    private logRequest(connectorId: string, config: AxiosRequestConfig): void {
        const connector = this.connectors.get(connectorId);
        if (!connector) return;

        this.outputChannel.appendLine(
            `[${connectorId}] ${config.method?.toUpperCase()} ${config.url}`
        );

        if (config.headers) {
            this.outputChannel.appendLine(
                `[${connectorId}] Headers: ${JSON.stringify(config.headers)}`
            );
        }

        if (config.params) {
            this.outputChannel.appendLine(
                `[${connectorId}] Params: ${JSON.stringify(config.params)}`
            );
        }

        if (config.data) {
            this.outputChannel.appendLine(
                `[${connectorId}] Data: ${JSON.stringify(config.data)}`
            );
        }
    }

    /**
     * Log response
     */
    private logResponse(connectorId: string, response: AxiosResponse): void {
        const connector = this.connectors.get(connectorId);
        if (!connector) return;

        this.outputChannel.appendLine(
            `[${connectorId}] Response: ${response.status} (${response.statusText})`
        );

        if (response.headers) {
            this.outputChannel.appendLine(
                `[${connectorId}] Response Headers: ${JSON.stringify(response.headers)}`
            );
        }

        const duration = response.config.metadata?.duration;
        if (duration) {
            this.outputChannel.appendLine(
                `[${connectorId}] Duration: ${duration}ms`
            );
        }
    }

    /**
     * Log success
     */
    private logSuccess(connectorId: string, apiResponse: ApiResponse<any>): void {
        const connector = this.connectors.get(connectorId);
        if (!connector) return;

        this.outputChannel.appendLine(
            `[${connectorId}] Success: ${apiResponse.requestId} (${apiResponse.duration}ms)`
        );
    }

    /**
     * Log error
     */
    private logError(connectorId: string, error: any): void {
        const connector = this.connectors.get(connectorId);
        if (!connector) return;

        this.outputChannel.appendLine(
            `[${connectorId}] Error: ${error.message}`
        );

        if (error.response) {
            this.outputChannel.appendLine(
                `[${connectorId}] Status: ${error.response.status} ${error.response.statusText}`
            );
        }
    }

    /**
     * Setup webhook for connector
     */
    public async setupWebhook(
        connectorId: string,
        webhook: WebhookConfig
    ): Promise<void> {
        try {
            this.webhooks.set(connectorId, webhook);
            
            // Create webhook endpoint handler
            const webhookHandler = new WebhookHandler(
                connectorId,
                webhook,
                this.outputChannel
            );

            await webhookHandler.start();

            vscode.window.showInformationMessage(
                `Webhook configured for ${connectorId}`
            );
        } catch (error) {
            throw new Error(`Failed to setup webhook: ${error.message}`);
        }
    }

    /**
     * Get connector status
     */
    public async getConnectorStatus(connectorId?: string): Promise<{ [id: string]: any }> {
        const statuses: { [id: string]: any } = {};

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
    public async testConnection(connectorId: string): Promise<boolean> {
        try {
            const connector = this.connectors.get(connectorId);
            if (!connector) {
                throw new Error(`Connector ${connectorId} not found`);
            }

            // Make a simple health check request
            const response = await this.makeRequest(connectorId, {
                id: uuidv4(),
                method: 'GET',
                url: '/health',
                timeout: 5000,
                metadata: { test: true }
            });

            return response.success;
        } catch (error) {
            this.outputChannel.appendLine(
                `Connection test failed for ${connectorId}: ${error.message}`
            );
            return false;
        }
    }

    /**
     * Update status bar
     */
    private updateStatusBar(): void {
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
    public async showStatus(): Promise<void> {
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
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show API status: ${error.message}`);
        }
    }

    /**
     * Dispose API connectors
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}

/**
 * Rate Limiter Class
 */
class RateLimiter {
    private config: RateLimitConfig;
    private requests: number[] = [];

    constructor(config: RateLimitConfig) {
        this.config = config;
    }

    /**
     * Acquire request slot
     */
    async acquire(): Promise<void> {
        const now = Date.now();
        
        // Clean old requests
        this.requests = this.requests.filter(
            timestamp => now - timestamp < 60000 // Keep last minute
        );

        // Check rate limits
        if (this.config.requestsPerSecond > 0) {
            const recentRequests = this.requests.filter(
                timestamp => now - timestamp < 1000
            );
            if (recentRequests.length >= this.config.requestsPerSecond) {
                throw new Error('Rate limit exceeded (per second)');
            }
        }

        if (this.config.requestsPerMinute > 0) {
            const minuteRequests = this.requests.filter(
                timestamp => now - timestamp < 60000
            );
            if (minuteRequests.length >= this.config.requestsPerMinute) {
                throw new Error('Rate limit exceeded (per minute)');
            }
        }

        if (this.config.requestsPerHour > 0) {
            const hourRequests = this.requests.filter(
                timestamp => now - timestamp < 3600000
            );
            if (hourRequests.length >= this.config.requestsPerHour) {
                throw new Error('Rate limit exceeded (per hour)');
            }
        }

        if (this.config.requestsPerDay > 0) {
            const dayRequests = this.requests.filter(
                timestamp => now - timestamp < 86400000
            );
            if (dayRequests.length >= this.config.requestsPerDay) {
                throw new Error('Rate limit exceeded (per day)');
            }
        }

        this.requests.push(now);
    }

    /**
     * Get rate limit status
     */
    public getStatus(): any {
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
    private connectorId: string;
    private config: WebhookConfig;
    private outputChannel: vscode.OutputChannel;
    private server?: any;

    constructor(
        connectorId: string,
        config: WebhookConfig,
        outputChannel: vscode.OutputChannel
    ) {
        this.connectorId = connectorId;
        this.config = config;
        this.outputChannel = outputChannel;
    }

    /**
     * Start webhook server
     */
    async start(): Promise<void> {
        // This would start a local server to handle webhooks
        // Implementation depends on the specific requirements
        this.outputChannel.appendLine(
            `Webhook started for ${this.connectorId} on ${this.config.url}`
        );
    }

    /**
     * Stop webhook server
     */
    async stop(): Promise<void> {
        if (this.server) {
            await this.server.close();
            this.server = undefined;
        }
    }

    /**
     * Handle incoming webhook
     */
    private handleWebhook(request: any, response: any): void {
        // Verify webhook secret if provided
        if (this.config.secret) {
            const signature = request.headers['x-webhook-signature'];
            if (!this.verifySignature(request.body, signature)) {
                response.status(401).send('Unauthorized');
                return;
            }
        }

        // Process webhook event
        this.outputChannel.appendLine(
            `Webhook event received: ${JSON.stringify(request.body)}`
        );

        // Send success response
        response.status(200).send('OK');
    }

    /**
     * Verify webhook signature
     */
    private verifySignature(payload: string, signature: string): boolean {
        // Implementation depends on the signature method (HMAC-SHA256, etc.)
        return true; // Placeholder
    }
}