import * as http from 'http';
import * as https from 'https';
import * as vscode from 'vscode';
import { v4 as uuidv4 } from 'uuid';

export interface EnhancedNoodleResponse {
    success: boolean;
    data?: any;
    error?: {
        code: number;
        message: string;
        details?: any;
    };
    requestId: string;
    timestamp: string;
}

export interface AIRequestContext {
    activeFile?: string;
    selectedCode?: string;
    workspacePath?: string;
    language?: string;
}

export interface AIChatRequest {
    message: string;
    provider: string;
    model: string;
    history: any[];
    context?: AIRequestContext;
}

export interface AIProviderConfig {
    id: string;
    name: string;
    endpoint: string;
    apiKey?: string;
    models: string[];
    capabilities: string[];
}

export class EnhancedBackendService {
    private readonly baseUrl: string;
    private readonly port: number;
    private readonly useHttps: boolean;
    private readonly providers: Map<string, AIProviderConfig>;

    constructor() {
        // Use default port 8080 as per NoodleCore standards
        this.port = 8080;
        this.baseUrl = '127.0.0.1';
        this.useHttps = false;
        
        // Initialize AI provider configurations
        this.providers = new Map<string, AIProviderConfig>();
        this._initializeProviders();
    }

    private _initializeProviders() {
        // OpenAI configuration
        this.providers.set('openai', {
            id: 'openai',
            name: 'OpenAI',
            endpoint: '/api/v1/ai/openai/chat',
            models: ['gpt-3.5-turbo', 'gpt-4', 'gpt-4-turbo'],
            capabilities: ['code-generation', 'analysis', 'explanation', 'debugging']
        });

        // Anthropic configuration
        this.providers.set('anthropic', {
            id: 'anthropic',
            name: 'Anthropic',
            endpoint: '/api/v1/ai/anthropic/chat',
            models: ['claude-3-sonnet', 'claude-3-opus'],
            capabilities: ['code-analysis', 'reasoning', 'explanation', 'refactoring']
        });

        // Local NoodleCore configuration
        this.providers.set('local', {
            id: 'local',
            name: 'Local NoodleCore',
            endpoint: '/api/v1/ai/local/chat',
            models: ['noodle-ai', 'syntax-fixer', 'code-optimizer'],
            capabilities: ['syntax-fixing', 'noodle-specific', 'optimization', 'compilation']
        });
    }

    private async makeRequest(endpoint: string, method: string = 'GET', data?: any): Promise<EnhancedNoodleResponse> {
        return new Promise((resolve, reject) => {
            const url = `http://${this.baseUrl}:${this.port}${endpoint}`;
            const isGet = method === 'GET';
            const postData = data ? JSON.stringify(data) : undefined;

            const options = {
                hostname: this.baseUrl,
                port: this.port,
                path: endpoint,
                method: method,
                headers: {
                    'Content-Type': 'application/json',
                    'X-Request-ID': uuidv4(),
                    ...(postData && { 'Content-Length': Buffer.byteLength(postData) })
                }
            };

            const client = this.useHttps ? https : http;

            const req = client.request(options, (res) => {
                let responseData = '';

                res.on('data', (chunk) => {
                    responseData += chunk;
                });

                res.on('end', () => {
                    try {
                        const parsedResponse: EnhancedNoodleResponse = JSON.parse(responseData);
                        resolve(parsedResponse);
                    } catch (error) {
                        reject(new Error(`Failed to parse response: ${error}`));
                    }
                });
            });

            req.on('error', (error) => {
                reject(new Error(`Request failed: ${error.message}`));
            });

            if (postData) {
                req.write(postData);
            }

            req.end();
        });
    }

    async checkHealth(): Promise<EnhancedNoodleResponse> {
        try {
            return await this.makeRequest('/api/v1/health');
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5001,
                    message: `Backend connection failed: ${error}`,
                    details: { endpoint: '/api/v1/health' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async getServerInfo(): Promise<EnhancedNoodleResponse> {
        try {
            return await this.makeRequest('/');
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5001,
                    message: `Backend connection failed: ${error}`,
                    details: { endpoint: '/' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async executeCode(code: string, options?: {
        language?: string;
        context?: AIRequestContext;
        optimize?: boolean;
    }): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                code: code,
                language: options?.language || 'noodle'
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.optimize) {
                requestData.optimize = true;
            }

            return await this.makeRequest('/api/v1/execute', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5002,
                    message: `Code execution failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async analyzeCode(code: string, options?: {
        context?: AIRequestContext;
        analysisType?: 'syntax' | 'semantics' | 'performance' | 'security';
    }): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                code: code
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.analysisType) {
                requestData.analysisType = options.analysisType;
            }

            return await this.makeRequest('/api/v1/analyze', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5003,
                    message: `Code analysis failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async getDatabaseStatus(): Promise<EnhancedNoodleResponse> {
        try {
            return await this.makeRequest('/api/v1/database/status');
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5004,
                    message: `Database status check failed: ${error}`,
                    details: { endpoint: '/api/v1/database/status' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async makeAIChatRequest(
        message: string,
        provider: string,
        model: string,
        history: any[],
        context?: AIRequestContext
    ): Promise<EnhancedNoodleResponse> {
        try {
            const providerConfig = this.providers.get(provider);
            if (!providerConfig) {
                throw new Error(`Unknown AI provider: ${provider}`);
            }

            const requestData: AIChatRequest = {
                message,
                provider,
                model,
                history,
                context
            };

            return await this.makeRequest(providerConfig.endpoint, 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5005,
                    message: `AI chat request failed: ${error}`,
                    details: {
                        message: message.substring(0, 100) + '...',
                        provider: provider,
                        model: model
                    }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async generateCode(
        prompt: string,
        options?: {
            language?: string;
            context?: AIRequestContext;
            provider?: string;
            model?: string;
        }
    ): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                prompt: prompt,
                language: options?.language || 'noodle'
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.provider) {
                requestData.provider = options.provider;
            }

            if (options?.model) {
                requestData.model = options.model;
            }

            return await this.makeRequest('/api/v1/ai/generate', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5006,
                    message: `Code generation failed: ${error}`,
                    details: { prompt: prompt.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async fixCode(
        code: string,
        options?: {
            context?: AIRequestContext;
            fixType?: 'syntax' | 'logic' | 'runtime';
        }
    ): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                code: code
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.fixType) {
                requestData.fixType = options.fixType;
            }

            return await this.makeRequest('/api/v1/ai/fix', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5007,
                    message: `Code fixing failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async optimizeCode(
        code: string,
        options?: {
            context?: AIRequestContext;
            optimizationType?: 'performance' | 'memory' | 'readability';
        }
    ): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                code: code
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.optimizationType) {
                requestData.optimizationType = options.optimizationType;
            }

            return await this.makeRequest('/api/v1/ai/optimize', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5008,
                    message: `Code optimization failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async explainCode(
        code: string,
        options?: {
            context?: AIRequestContext;
            explanationType?: 'overview' | 'detailed' | 'step-by-step';
        }
    ): Promise<EnhancedNoodleResponse> {
        try {
            const requestData: any = {
                code: code
            };

            if (options?.context) {
                requestData.context = options.context;
            }

            if (options?.explanationType) {
                requestData.explanationType = options.explanationType;
            }

            return await this.makeRequest('/api/v1/ai/explain', 'POST', requestData);
        } catch (error) {
            return {
                success: false,
                error: {
                    code: 5009,
                    message: `Code explanation failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: uuidv4(),
                timestamp: new Date().toISOString()
            };
        }
    }

    getAvailableProviders(): AIProviderConfig[] {
        return Array.from(this.providers.values());
    }

    getProviderConfig(providerId: string): AIProviderConfig | undefined {
        return this.providers.get(providerId);
    }

    async isConnected(): Promise<boolean> {
        try {
            const health = await this.checkHealth();
            return health.success;
        } catch {
            return false;
        }
    }

    async showConnectionStatus(): Promise<void> {
        const connected = await this.isConnected();
        if (connected) {
            vscode.window.showInformationMessage('✅ NoodleCore backend server is connected');
        } else {
            vscode.window.showErrorMessage('❌ NoodleCore backend server is not running. Please start the server first.');
        }
    }

    async testProvider(providerId: string): Promise<boolean> {
        try {
            const providerConfig = this.providers.get(providerId);
            if (!providerConfig) {
                return false;
            }

            const testResponse = await this.makeRequest(providerConfig.endpoint, 'POST', {
                message: 'Hello, this is a test message.',
                provider: providerId,
                model: providerConfig.models[0],
                history: []
            });

            return testResponse.success;
        } catch {
            return false;
        }
    }
}