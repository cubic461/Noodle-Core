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
exports.NoodleBackendService = void 0;
const http = __importStar(require("http"));
const https = __importStar(require("https"));
const vscode = __importStar(require("vscode"));
class NoodleBackendService {
    constructor(serviceManager, configManager, eventBus, cacheManager, logger) {
        // Store infrastructure components
        this.serviceManager = serviceManager;
        this.configManager = configManager;
        this.eventBus = eventBus;
        this.cacheManager = cacheManager;
        this.logger = logger;
        // Use default port 8080 as per NoodleCore standards
        this.port = 8080;
        this.baseUrl = '127.0.0.1';
        this.useHttps = false;
    }
    async initialize() {
        if (this.logger) {
            this.logger.info('Initializing NoodleBackendService');
        }
        // Check if backend is available
        const isConnected = await this.isConnected();
        if (this.logger) {
            this.logger.info(`Backend connection status: ${isConnected ? 'Connected' : 'Disconnected'}`);
        }
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
                requestId: this.generateRequestId(),
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async executeCode(code, language) {
        try {
            return await this.makeRequest('/api/v1/ide/code/execute', 'POST', {
                content: code,
                file_type: language || 'noodle'
            });
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5009,
                    message: `Code execution failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async analyzeCode(code) {
        try {
            return await this.makeRequest('/api/v1/analyze', 'POST', {
                code: code
            });
        }
        catch (error) {
            return {
                success: false,
                error: {
                    code: 5003,
                    message: `Code analysis failed: ${error}`,
                    details: { code: code.substring(0, 100) + '...' }
                },
                requestId: this.generateRequestId(),
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }
    async makeAIChatRequest(message, provider, model, history) {
        try {
            return await this.makeRequest('/api/v1/ai/chat', 'POST', {
                message: message,
                provider: provider,
                model: model,
                history: history
            });
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }
    generateRequestId() {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
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
    showConnectionStatus() {
        this.isConnected().then(connected => {
            if (connected) {
                vscode.window.showInformationMessage('✅ NoodleCore backend server is connected');
            }
            else {
                vscode.window.showErrorMessage('❌ NoodleCore backend server is not running. Please start the server first.');
            }
        });
    }
}
exports.NoodleBackendService = NoodleBackendService;
//# sourceMappingURL=backendService.js.map