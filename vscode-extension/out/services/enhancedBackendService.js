"use strict";
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
exports.EnhancedBackendService = void 0;
const http = __importStar(require("http"));
const https = __importStar(require("https"));
const vscode = __importStar(require("vscode"));
const uuid_1 = require("uuid");
class EnhancedBackendService {
    constructor() {
        // Use default port 8080 as per NoodleCore standards
        this.port = 8080;
        this.baseUrl = '127.0.0.1';
        this.useHttps = false;
        // Initialize AI provider configurations
        this.providers = new Map();
        this._initializeProviders();
    }
    _initializeProviders() {
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
    async makeRequest(endpoint, method = 'GET', data) {
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
                    'X-Request-ID': (0, uuid_1.v4)(),
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
                        const parsedResponse = JSON.parse(responseData);
                        resolve(parsedResponse);
                    }
                    catch (error) {
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
    async checkHealth() {
        try {
            return await this.makeRequest('/api/v1/health');
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5001,
                    message: `Backend connection failed: ${error}`,
                    details: { endpoint: '/api/v1/health' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async getServerInfo() {
        try {
            return await this.makeRequest('/');
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5001,
                    message: `Backend connection failed: ${error}`,
                    details: { endpoint: '/' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async executeCode(code, options) {
        try {
            const requestData = {
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
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5002,
                    message: `Code execution failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async analyzeCode(code, options) {
        try {
            const requestData = {
                code: code
            };
            if (options?.context) {
                requestData.context = options.context;
            }
            if (options?.analysisType) {
                requestData.analysisType = options.analysisType;
            }
            return await this.makeRequest('/api/v1/analyze', 'POST', requestData);
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5003,
                    message: `Code analysis failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async getDatabaseStatus() {
        try {
            return await this.makeRequest('/api/v1/database/status');
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5004,
                    message: `Database status check failed: ${error}`,
                    details: { endpoint: '/api/v1/database/status' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async makeAIChatRequest(message, provider, model, history, context) {
        try {
            const providerConfig = this.providers.get(provider);
            if (!providerConfig) {
                throw new Error(`Unknown AI provider: ${provider}`);
            }
            const requestData = {
                message,
                provider,
                model,
                history,
                context
            };
            return await this.makeRequest(providerConfig.endpoint, 'POST', requestData);
        }
        catch (error) {
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
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async generateCode(prompt, options) {
        try {
            const requestData = {
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
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5006,
                    message: `Code generation failed: ${error}`,
                    details: { prompt: prompt.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async fixCode(code, options) {
        try {
            const requestData = {
                code: code
            };
            if (options?.context) {
                requestData.context = options.context;
            }
            if (options?.fixType) {
                requestData.fixType = options.fixType;
            }
            return await this.makeRequest('/api/v1/ai/fix', 'POST', requestData);
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5007,
                    message: `Code fixing failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async optimizeCode(code, options) {
        try {
            const requestData = {
                code: code
            };
            if (options?.context) {
                requestData.context = options.context;
            }
            if (options?.optimizationType) {
                requestData.optimizationType = options.optimizationType;
            }
            return await this.makeRequest('/api/v1/ai/optimize', 'POST', requestData);
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5008,
                    message: `Code optimization failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async explainCode(code, options) {
        try {
            const requestData = {
                code: code
            };
            if (options?.context) {
                requestData.context = options.context;
            }
            if (options?.explanationType) {
                requestData.explanationType = options.explanationType;
            }
            return await this.makeRequest('/api/v1/ai/explain', 'POST', requestData);
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5009,
                    message: `Code explanation failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: (0, uuid_1.v4)(),
                timestamp: new Date().toISOString()
            };
        }
    }
    getAvailableProviders() {
        return Array.from(this.providers.values());
    }
    getProviderConfig(providerId) {
        return this.providers.get(providerId);
    }
    async isConnected() {
        try {
            const health = await this.checkHealth();
            return health.success;
        }
        catch {
            return false;
        }
    }
    async showConnectionStatus() {
        const connected = await this.isConnected();
        if (connected) {
            vscode.window.showInformationMessage('✅ NoodleCore backend server is connected');
        }
        else {
            vscode.window.showErrorMessage('❌ NoodleCore backend server is not running. Please start the server first.');
        }
    }
    async testProvider(providerId) {
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
        }
        catch {
            return false;
        }
    }
}
exports.EnhancedBackendService = EnhancedBackendService;
//# sourceMappingURL=enhancedBackendService.js.map