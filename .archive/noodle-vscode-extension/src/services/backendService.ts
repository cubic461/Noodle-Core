import * as http from 'http';
import * as https from 'https';
import * as vscode from 'vscode';

export interface NoodleResponse {
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

export class NoodleBackendService {
    private readonly baseUrl: string;
    private readonly port: number;
    private readonly useHttps: boolean;
    private serviceManager: any;
    private configManager: any;
    private eventBus: any;
    private cacheManager: any;
    private logger: any;

    constructor(
        serviceManager?: any,
        configManager?: any,
        eventBus?: any,
        cacheManager?: any,
        logger?: any
    ) {
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

    async initialize(): Promise<void> {
        if (this.logger) {
            this.logger.info('Initializing NoodleBackendService');
        }
        
        // Check if backend is available
        const isConnected = await this.isConnected();
        if (this.logger) {
            this.logger.info(`Backend connection status: ${isConnected ? 'Connected' : 'Disconnected'}`);
        }
    }

    private async makeRequest(endpoint: string, method: string = 'GET', data?: any): Promise<NoodleResponse> {
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
                        const parsedResponse: NoodleResponse = JSON.parse(responseData);
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

    async checkHealth(): Promise<NoodleResponse> {
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async getServerInfo(): Promise<NoodleResponse> {
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async executeCode(code: string, language?: string): Promise<NoodleResponse> {
        try {
            return await this.makeRequest('/api/v1/ide/code/execute', 'POST', {
                content: code,
                file_type: language || 'noodle'
            });
        } catch (error) {
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

    async analyzeCode(code: string): Promise<NoodleResponse> {
        try {
            return await this.makeRequest('/api/v1/analyze', 'POST', {
                code: code
            });
        } catch (error) {
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

    async getDatabaseStatus(): Promise<NoodleResponse> {
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }

    async makeAIChatRequest(message: string, provider: string, model: string, history: any[]): Promise<NoodleResponse> {
        try {
            return await this.makeRequest('/api/v1/ai/chat', 'POST', {
                message: message,
                provider: provider,
                model: model,
                history: history
            });
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
                requestId: this.generateRequestId(),
                timestamp: new Date().toISOString()
            };
        }
    }

    private generateRequestId(): string {
        return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
            const r = Math.random() * 16 | 0;
            const v = c === 'x' ? r : (r & 0x3 | 0x8);
            return v.toString(16);
        });
    }

    async isConnected(): Promise<boolean> {
        try {
            const health = await this.checkHealth();
            return health.success;
        } catch {
            return false;
        }
    }

    showConnectionStatus(): void {
        this.isConnected().then(connected => {
            if (connected) {
                vscode.window.showInformationMessage('✅ NoodleCore backend server is connected');
            } else {
                vscode.window.showErrorMessage('❌ NoodleCore backend server is not running. Please start the server first.');
            }
        });
    }
}