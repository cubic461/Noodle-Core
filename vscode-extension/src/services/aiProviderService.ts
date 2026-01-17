import * as vscode from 'vscode';
import fetch, { RequestInit } from 'node-fetch';

export interface AIMessage {
    role: 'system' | 'user' | 'assistant';
    content: string;
}

export interface AIResponse {
    content: string;
    usage?: {
        promptTokens: number;
        completionTokens: number;
        totalTokens: number;
    };
}

export interface AIProviderConfig {
    provider: string;
    apiKey: string;
    endpoint: string;
    model: string;
    apiStyle: 'openai' | 'anthropic';
    temperature?: number;
    maxTokens?: number;
    timeout?: number;
}

export class AIProviderService {
    private config: AIProviderConfig;
    private outputChannel: vscode.OutputChannel;

    constructor(config: AIProviderConfig, outputChannel: vscode.OutputChannel) {
        this.config = config;
        this.outputChannel = outputChannel;
    }

    public async sendMessage(messages: AIMessage[]): Promise<AIResponse> {
        try {
            await this.logRequest(messages);
            
            const response = await this.makeProviderRequest(messages);
            
            return this.parseResponse(response);
        } catch (error) {
            this.handleError(error);
            throw error;
        }
    }

    private async makeProviderRequest(messages: AIMessage[]): Promise<any> {
        const { provider, apiKey, endpoint, model, apiStyle, temperature, maxTokens, timeout } = this.config;
        
        // Construct full URL based on API style
        let url = endpoint;
        if (apiStyle === 'openai' && !url.includes('/chat/completions')) {
            url = url.endsWith('/') ? `${url}chat/completions` : `${url}/chat/completions`;
        } else if (apiStyle === 'anthropic' && !url.includes('/messages')) {
            url = url.endsWith('/') ? `${url}messages` : `${url}/messages`;
        }

        this.outputChannel.appendLine(`Full URL: ${url}`);

        // Build request body based on API style
        let body: any;

        if (apiStyle === 'anthropic') {
            body = {
                model: model,
                max_tokens: maxTokens || 2048,
                messages: messages,
                anthropic_version: '2023-06-01'
            };
            if (temperature !== undefined) {
                body.temperature = temperature;
            }
        } else {
            // OpenAI style (default)
            body = {
                model: model,
                messages: messages,
                temperature: temperature || 0.7,
                max_tokens: maxTokens || 2048
            };
        }

        // Build headers based on provider
        const headers: Record<string, string> = {
            'Content-Type': 'application/json',
            'User-Agent': 'Noodle-VSCode-Extension/1.0.0'
        };

        if (provider === 'anthropic' || apiStyle === 'anthropic') {
            headers['x-api-key'] = apiKey;
            headers['anthropic-version'] = '2023-06-01';
        } else {
            headers['Authorization'] = `Bearer ${apiKey}`;
        }

        this.outputChannel.appendLine('Sending request...');
        this.outputChannel.appendLine(`Model: ${model}`);
        this.outputChannel.appendLine(`Headers: ${JSON.stringify({ ...headers, 'Authorization': '***REDACTED***' })}`);
        
        // Make request using node-fetch (better SSL/TLS handling)
        const controller = new AbortController();
        const timeoutId = setTimeout(() => controller.abort(), timeout || 30000);

        try {
            const response = await fetch(url, {
                method: 'POST',
                headers: headers,
                body: JSON.stringify(body),
                signal: controller.signal
            });

            clearTimeout(timeoutId);

            this.outputChannel.appendLine(`Response status: ${response.status} ${response.statusText}`);

            if (!response.ok) {
                const errorText = await response.text();
                throw new Error(`HTTP ${response.status}: ${response.statusText}\nResponse: ${errorText}`);
            }

            const data = await response.json();
            this.outputChannel.appendLine('Response received successfully');
            return data;

        } catch (error: any) {
            clearTimeout(timeoutId);
            
            if (error.name === 'AbortError') {
                throw new Error(`Request timeout after ${timeout || 30000}ms`);
            }
            
            // Enhance error messages for common issues
            if (error.code === 'ECONNREFUSED') {
                throw new Error(`Connection refused to ${url}. Check if the endpoint is correct and the server is running.`);
            } else if (error.code === 'ENOTFOUND') {
                throw new Error(`Cannot resolve hostname: ${url}. Check your network connection and the endpoint URL.`);
            } else if (error.type === 'request-timeout') {
                throw new Error(`Request timeout: The server took too long to respond. Try increasing the timeout setting.`);
            } else if (error.message.includes('Client network socket')) {
                throw new Error(`Network SSL/TLS Error: ${error.message}\n\nTroubleshooting:\n1. Check your internet connection\n2. Try disabling VPN or proxy\n3. Check firewall settings\n4. Verify the endpoint URL is correct`);
            }
            
            throw error;
        }
    }

    private parseResponse(data: any): AIResponse {
        const { apiStyle } = this.config;

        let content = '';
        let usage;

        if (apiStyle === 'anthropic') {
            content = data.content[0]?.text || '';
            usage = {
                promptTokens: data.usage?.input_tokens || 0,
                completionTokens: data.usage?.output_tokens || 0,
                totalTokens: (data.usage?.input_tokens || 0) + (data.usage?.output_tokens || 0)
            };
        } else {
            // OpenAI style
            content = data.choices?.[0]?.message?.content || '';
            usage = {
                promptTokens: data.usage?.prompt_tokens || 0,
                completionTokens: data.usage?.completion_tokens || 0,
                totalTokens: data.usage?.total_tokens || 0
            };
        }

        if (!content) {
            throw new Error('Empty response received from AI provider');
        }

        return { content, usage };
    }

    private async logRequest(messages: AIMessage[]): Promise<void> {
        this.outputChannel.appendLine('=== AI Provider Request ===');
        this.outputChannel.appendLine(`Provider: ${this.config.provider}`);
        this.outputChannel.appendLine(`Endpoint: ${this.config.endpoint}`);
        this.outputChannel.appendLine(`Model: ${this.config.model}`);
        this.outputChannel.appendLine(`API Style: ${this.config.apiStyle}`);
        this.outputChannel.appendLine(`Messages: ${JSON.stringify(messages)}`);
    }

    private handleError(error: any): void {
        this.outputChannel.appendLine('=== AI Provider Error ===');
        this.outputChannel.appendLine(`Error: ${error.message}`);
        
        vscode.window.showErrorMessage(`AI Error: ${error.message}`);
    }

    public updateConfig(config: Partial<AIProviderConfig>): void {
        this.config = { ...this.config, ...config };
    }
}

