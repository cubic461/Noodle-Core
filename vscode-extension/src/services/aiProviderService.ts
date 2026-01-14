import * as vscode from 'vscode';
import * as https from 'https';

export interface AIProviderConfig {
    provider: string;
    apiKey?: string;
    endpoint?: string;
    model: string;
    temperature: number;
    maxTokens: number;
    timeout: number;
}

export interface AIResponse {
    success: boolean;
    content?: string;
    usage?: {
        promptTokens: number;
        completionTokens: number;
        totalTokens: number;
    };
    error?: string;
}

/**
 * AI Provider Service
 * Handles direct communication with various AI providers
 */
export class AIProviderService {
    private config: AIProviderConfig;
    private outputChannel: vscode.OutputChannel;

    constructor() {
        this.outputChannel = vscode.window.createOutputChannel('Noodle AI');
        this.loadConfig();
        
        // Watch for config changes
        vscode.workspace.onDidChangeConfiguration(event => {
            if (event.affectsConfiguration('noodle.ai')) {
                this.loadConfig();
                this.outputChannel.appendLine('AI configuration reloaded');
            }
        });
    }

    private loadConfig(): void {
        const config = vscode.workspace.getConfiguration('noodle.ai');
        
        this.config = {
            provider: config.get('provider', 'openai'),
            apiKey: config.get('apiKey', '') || process.env.NOODLE_AI_API_KEY,
            endpoint: config.get('endpoint', ''),
            model: config.get('model', 'gpt-4'),
            temperature: config.get('temperature', 0.7),
            maxTokens: config.get('maxTokens', 2048),
            timeout: config.get('timeout', 30000)
        };

        // Warn if no API key for providers that need it
        if (this.requiresApiKey() && !this.config.apiKey) {
            this.outputChannel.appendLine(`âš ï¸  Warning: No API key configured for ${this.config.provider}`);
            this.outputChannel.appendLine('   Set noodle.ai.apiKey in settings or use NOODLE_AI_API_KEY environment variable');
        }
    }

    private requiresApiKey(): boolean {
        return !['local', 'ollama', 'lmstudio'].includes(this.config.provider);
    }

    private getEndpointForProvider(): string {
        // Custom endpoint takes precedence
        if (this.config.endpoint) {
            return this.config.endpoint;
        }

        // Default endpoints per provider
        const endpoints: { [key: string]: string } = {
            'openai': 'https://api.openai.com/v1',
            'anthropic': 'https://api.anthropic.com/v1',
            'groq': 'https://api.groq.com/openai/v1',
            'z.ai': 'https://api.z.ai/v1',
            'ollama': 'http://localhost:11434',
            'lmstudio': 'http://localhost:1234/v1'
        };

        return endpoints[this.config.provider] || this.config.endpoint || '';
    }

    /**
     * Send chat completion request to AI provider
     */
    async chatCompletion(messages: Array<{ role: string; content: string }>): Promise<AIResponse> {
        try {
            const endpoint = this.getEndpointForProvider();
            
            if (!endpoint) {
                return {
                    success: false,
                    error: `No endpoint configured for provider: ${this.config.provider}`
                };
            }

            this.outputChannel.appendLine(`ðŸ“¤ Sending request to ${this.config.provider}`);
            this.outputChannel.appendLine(`   Model: ${this.config.model}`);
            this.outputChannel.appendLine(`   Messages: ${messages.length}`);

            const response = await this.makeProviderRequest(endpoint, messages);
            
            this.outputChannel.appendLine(`âœ… Response received`);
            
            return response;

        } catch (error) {
            this.outputChannel.appendLine(`âŒ Error: ${error.message}`);
            return {
                success: false,
                error: error.message
            };
        }
    }

    private async makeProviderRequest(
        endpoint: string,
        messages: Array<{ role: string; content: string }>
    ): Promise<AIResponse> {
        return new Promise((resolve, reject) => {
            const url = new URL(endpoint + (endpoint.includes('/v1') ? '/chat/completions' : '/api/chat'));
            
            const requestBody = this.getRequestBody(messages);
            
            const options = {
                hostname: url.hostname,
                port: url.port || (url.protocol === 'https:' ? 443 : 80),
                path: url.pathname + url.search,
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${this.config.apiKey}`,
                    ...this.getProviderSpecificHeaders()
                },
                timeout: this.config.timeout
            };

            const req = https.request(options, (res) => {
                let data = '';

                res.on('data', chunk => data += chunk);
                res.on('end', () => {
                    if (res.statusCode === 200) {
                        try {
                            const json = JSON.parse(data);
                            resolve(this.parseResponse(json));
                        } catch (e) {
                            resolve({
                                success: false,
                                error: `Failed to parse response: ${e.message}`
                            });
                        }
                    } else {
                        resolve({
                            success: false,
                            error: `HTTP ${res.statusCode}: ${data}`
                        });
                    }
                });
            });

            req.on('error', reject);
            req.on('timeout', () => {
                req.destroy();
                reject(new Error('Request timeout'));
            });

            req.write(JSON.stringify(requestBody));
            req.end();
        });
    }

    private getRequestBody(messages: Array<{ role: string; content: string }>): any {
        // OpenAI-compatible format
        return {
            model: this.config.model,
            messages: messages,
            temperature: this.config.temperature,
            max_tokens: this.config.maxTokens
        };
    }

    private getProviderSpecificHeaders(): { [key: string]: string } {
        const headers: { [key: string]: string } = {};

        // Anthropic uses different headers
        if (this.config.provider === 'anthropic') {
            headers['anthropic-version'] = '2023-06-01';
            delete headers['Authorization'];
            headers['x-api-key'] = this.config.apiKey || '';
        }

        return headers;
    }

    private parseResponse(json: any): AIResponse {
        // Handle different response formats
        if (json.choices) {
            // OpenAI format
            return {
                success: true,
                content: json.choices[0]?.message?.content || '',
                usage: json.usage ? {
                    promptTokens: json.usage.prompt_tokens,
                    completionTokens: json.usage.completion_tokens,
                    totalTokens: json.usage.total_tokens
                } : undefined
            };
        } else if (json.content) {
            // Anthropic format
            return {
                success: true,
                content: json.content,
                usage: json.usage
            };
        } else {
            return {
                success: false,
                error: 'Unknown response format'
            };
        }
    }

    /**
     * Test connection to AI provider
     */
    async testConnection(): Promise<{ success: boolean; message: string }> {
        try {
            const result = await this.chatCompletion([
                { role: 'user', content: 'Hello! Can you respond with just "OK"?' }
            ]);

            if (result.success) {
                return {
                    success: true,
                    message: `âœ… Successfully connected to ${this.config.provider}`
                };
            } else {
                return {
                    success: false,
                    message: `âŒ Connection failed: ${result.error}`
                };
            }
        } catch (error) {
            return {
                success: false,
                message: `âŒ Error: ${error.message}`
            };
        }
    }

    dispose(): void {
        this.outputChannel.dispose();
    }
}
