/**
 * External Tool Authentication for Noodle VS Code Extension
 * 
 * Provides authentication mechanisms for external tools and services
 * including OAuth, API keys, certificates, and custom authentication methods.
 */

import * as crypto from 'crypto';
import { EventEmitter } from 'events';
import * as vscode from 'vscode';

export interface AuthConfig {
    type: 'oauth' | 'apikey' | 'certificate' | 'basic' | 'custom';
    name: string;
    enabled?: boolean;
    config?: Record<string, any>;
}

export interface AuthToken {
    type: string;
    token: string;
    expires?: Date;
    refresh?: string;
    scopes?: string[];
}

export interface AuthCredential {
    id: string;
    name: string;
    type: string;
    username?: string;
    token?: string;
    apiKey?: string;
    certificate?: string;
    privateKey?: string;
    expires?: Date;
    created: Date;
    lastUsed?: Date;
}

export interface AuthProvider {
    type: string;
    name: string;
    initialize: () => Promise<void>;
    authenticate: (config: AuthConfig) => Promise<AuthToken>;
    refreshToken: (token: AuthToken) => Promise<AuthToken>;
    validateToken: (token: AuthToken) => Promise<boolean>;
    revokeToken: (token: AuthToken) => Promise<void>;
}

export class ExternalToolAuthentication extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private providers: Map<string, AuthProvider> = new Map();
    private credentials: Map<string, AuthCredential> = new Map();
    private tokens: Map<string, AuthToken> = new Map();
    private secrets: vscode.SecretStorage;

    constructor(context: vscode.ExtensionContext) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Authentication');
        this.secrets = context.secrets;
    }

    /**
     * Initialize external tool authentication
     */
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing external tool authentication...');

            // Load credentials from secure storage
            await this.loadCredentials();

            // Initialize authentication providers
            await this.initializeProviders();

            this.outputChannel.appendLine('External tool authentication initialized');
            this.emit('initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize external tool authentication: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Add authentication provider
     */
    public async addProvider(provider: AuthProvider): Promise<void> {
        try {
            this.outputChannel.appendLine(`Adding authentication provider: ${provider.name}`);

            // Initialize provider
            await provider.initialize();

            // Store provider
            this.providers.set(provider.type, provider);

            this.outputChannel.appendLine(`Authentication provider added: ${provider.name}`);
            this.emit('providerAdded', { provider });
        } catch (error) {
            this.outputChannel.appendLine(`Failed to add authentication provider: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Remove authentication provider
     */
    public removeProvider(type: string): boolean {
        const provider = this.providers.get(type);
        if (!provider) {
            return false;
        }

        this.providers.delete(type);

        this.outputChannel.appendLine(`Authentication provider removed: ${type}`);
        this.emit('providerRemoved', { type });
        return true;
    }

    /**
     * Get all providers
     */
    public getProviders(): Map<string, AuthProvider> {
        return new Map(this.providers);
    }

    /**
     * Get provider by type
     */
    public getProvider(type: string): AuthProvider | undefined {
        return this.providers.get(type);
    }

    /**
     * Authenticate with external tool
     */
    public async authenticate(config: AuthConfig): Promise<AuthToken> {
        const provider = this.providers.get(config.type);
        if (!provider) {
            throw new Error(`Authentication provider not found: ${config.type}`);
        }

        try {
            this.outputChannel.appendLine(`Authenticating with ${config.name} using ${config.type}`);

            // Authenticate with provider
            const token = await provider.authenticate(config);

            // Store token
            this.tokens.set(config.name, token);

            // Store credential
            const credential: AuthCredential = {
                id: this.generateId(),
                name: config.name,
                type: config.type,
                token: token.token,
                expires: token.expires,
                created: new Date(),
                lastUsed: new Date()
            };

            this.credentials.set(config.name, credential);
            await this.saveCredential(credential);

            this.outputChannel.appendLine(`Authentication successful for ${config.name}`);
            this.emit('authenticated', { config, token });

            return token;
        } catch (error) {
            this.outputChannel.appendLine(`Authentication failed for ${config.name}: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Refresh authentication token
     */
    public async refreshToken(name: string): Promise<AuthToken> {
        const token = this.tokens.get(name);
        if (!token) {
            throw new Error(`Token not found: ${name}`);
        }

        const provider = this.providers.get(token.type);
        if (!provider) {
            throw new Error(`Authentication provider not found: ${token.type}`);
        }

        try {
            this.outputChannel.appendLine(`Refreshing token for ${name}`);

            // Refresh token
            const newToken = await provider.refreshToken(token);

            // Update stored token
            this.tokens.set(name, newToken);

            // Update credential
            const credential = this.credentials.get(name);
            if (credential) {
                credential.token = newToken.token;
                credential.expires = newToken.expires;
                credential.lastUsed = new Date();
                await this.saveCredential(credential);
            }

            this.outputChannel.appendLine(`Token refreshed for ${name}`);
            this.emit('tokenRefreshed', { name, token: newToken });

            return newToken;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to refresh token for ${name}: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Validate authentication token
     */
    public async validateToken(name: string): Promise<boolean> {
        const token = this.tokens.get(name);
        if (!token) {
            return false;
        }

        const provider = this.providers.get(token.type);
        if (!provider) {
            return false;
        }

        try {
            return await provider.validateToken(token);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to validate token for ${name}: ${error instanceof Error ? error.message : String(error)}`);
            return false;
        }
    }

    /**
     * Revoke authentication token
     */
    public async revokeToken(name: string): Promise<void> {
        const token = this.tokens.get(name);
        if (!token) {
            throw new Error(`Token not found: ${name}`);
        }

        const provider = this.providers.get(token.type);
        if (!provider) {
            throw new Error(`Authentication provider not found: ${token.type}`);
        }

        try {
            this.outputChannel.appendLine(`Revoking token for ${name}`);

            // Revoke token
            await provider.revokeToken(token);

            // Remove stored token
            this.tokens.delete(name);

            // Remove credential
            this.credentials.delete(name);
            await this.deleteCredential(name);

            this.outputChannel.appendLine(`Token revoked for ${name}`);
            this.emit('tokenRevoked', { name });
        } catch (error) {
            this.outputChannel.appendLine(`Failed to revoke token for ${name}: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Get all credentials
     */
    public getCredentials(): AuthCredential[] {
        return Array.from(this.credentials.values());
    }

    /**
     * Get credential by name
     */
    public getCredential(name: string): AuthCredential | undefined {
        return this.credentials.get(name);
    }

    /**
     * Get token by name
     */
    public getToken(name: string): AuthToken | undefined {
        return this.tokens.get(name);
    }

    /**
     * Check if token is expired
     */
    public isTokenExpired(name: string): boolean {
        const token = this.tokens.get(name);
        if (!token || !token.expires) {
            return false;
        }

        return new Date() >= token.expires;
    }

    /**
     * Load credentials from secure storage
     */
    private async loadCredentials(): Promise<void> {
        try {
            // Load credential names
            const credentialNames = this.context.globalState.get<string[]>('authCredentials', []);

            for (const name of credentialNames) {
                const credentialData = await this.secrets.get(`authCredential_${name}`);
                if (credentialData) {
                    const credential = JSON.parse(credentialData) as AuthCredential;
                    credential.created = new Date(credential.created);
                    if (credential.expires) {
                        credential.expires = new Date(credential.expires);
                    }
                    if (credential.lastUsed) {
                        credential.lastUsed = new Date(credential.lastUsed);
                    }

                    this.credentials.set(name, credential);
                }
            }

            this.outputChannel.appendLine(`Loaded ${this.credentials.size} credentials`);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to load credentials: ${error instanceof Error ? error.message : String(error)}`);
        }
    }

    /**
     * Save credential to secure storage
     */
    private async saveCredential(credential: AuthCredential): Promise<void> {
        try {
            // Save credential to secure storage
            await this.secrets.store(`authCredential_${credential.name}`, JSON.stringify(credential));

            // Update credential names list
            const credentialNames = this.context.globalState.get<string[]>('authCredentials', []);
            if (!credentialNames.includes(credential.name)) {
                credentialNames.push(credential.name);
                await this.context.globalState.update('authCredentials', credentialNames);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to save credential: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Delete credential from secure storage
     */
    private async deleteCredential(name: string): Promise<void> {
        try {
            // Delete credential from secure storage
            await this.secrets.delete(`authCredential_${name}`);

            // Update credential names list
            const credentialNames = this.context.globalState.get<string[]>('authCredentials', []);
            const index = credentialNames.indexOf(name);
            if (index !== -1) {
                credentialNames.splice(index, 1);
                await this.context.globalState.update('authCredentials', credentialNames);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to delete credential: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Initialize authentication providers
     */
    private async initializeProviders(): Promise<void> {
        try {
            // Add OAuth provider
            await this.addProvider(this.createOAuthProvider());

            // Add API Key provider
            await this.addProvider(this.createAPIKeyProvider());

            // Add Certificate provider
            await this.addProvider(this.createCertificateProvider());

            // Add Basic Auth provider
            await this.addProvider(this.createBasicAuthProvider());

            // Add Custom provider
            await this.addProvider(this.createCustomProvider());

            this.outputChannel.appendLine('Authentication providers initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize authentication providers: ${error instanceof Error ? error.message : String(error)}`);
            throw error;
        }
    }

    /**
     * Create OAuth provider
     */
    private createOAuthProvider(): AuthProvider {
        return {
            type: 'oauth',
            name: 'OAuth',
            initialize: async () => {
                this.outputChannel.appendLine('Initializing OAuth provider');
            },
            authenticate: async (config: AuthConfig) => {
                this.outputChannel.appendLine('Authenticating with OAuth');

                // Mock OAuth authentication
                return {
                    type: 'oauth',
                    token: 'oauth_token_' + this.generateId(),
                    expires: new Date(Date.now() + 3600 * 1000),
                    refresh: 'refresh_token_' + this.generateId(),
                    scopes: config.config?.scopes || []
                };
            },
            refreshToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Refreshing OAuth token');

                // Mock token refresh
                return {
                    ...token,
                    token: 'oauth_token_' + this.generateId(),
                    expires: new Date(Date.now() + 3600 * 1000)
                };
            },
            validateToken: async (token: AuthToken) => {
                // Mock token validation
                return !token.expires || new Date() < token.expires;
            },
            revokeToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Revoking OAuth token');
                // Mock token revocation
            }
        };
    }

    /**
     * Create API Key provider
     */
    private createAPIKeyProvider(): AuthProvider {
        return {
            type: 'apikey',
            name: 'API Key',
            initialize: async () => {
                this.outputChannel.appendLine('Initializing API Key provider');
            },
            authenticate: async (config: AuthConfig) => {
                this.outputChannel.appendLine('Authenticating with API Key');

                // Mock API Key authentication
                return {
                    type: 'apikey',
                    token: config.config?.apiKey || 'api_key_' + this.generateId()
                };
            },
            refreshToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Refreshing API Key');
                // API keys typically don't expire or refresh
                return token;
            },
            validateToken: async (token: AuthToken) => {
                // Mock token validation
                return !!token.token;
            },
            revokeToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Revoking API Key');
                // Mock token revocation
            }
        };
    }

    /**
     * Create Certificate provider
     */
    private createCertificateProvider(): AuthProvider {
        return {
            type: 'certificate',
            name: 'Certificate',
            initialize: async () => {
                this.outputChannel.appendLine('Initializing Certificate provider');
            },
            authenticate: async (config: AuthConfig) => {
                this.outputChannel.appendLine('Authenticating with Certificate');

                // Mock Certificate authentication
                return {
                    type: 'certificate',
                    token: 'certificate_token_' + this.generateId(),
                    expires: config.config?.expires ? new Date(config.config.expires) : undefined
                };
            },
            refreshToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Refreshing Certificate');
                // Certificates typically don't refresh
                return token;
            },
            validateToken: async (token: AuthToken) => {
                // Mock token validation
                return !token.expires || new Date() < token.expires;
            },
            revokeToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Revoking Certificate');
                // Mock token revocation
            }
        };
    }

    /**
     * Create Basic Auth provider
     */
    private createBasicAuthProvider(): AuthProvider {
        return {
            type: 'basic',
            name: 'Basic Auth',
            initialize: async () => {
                this.outputChannel.appendLine('Initializing Basic Auth provider');
            },
            authenticate: async (config: AuthConfig) => {
                this.outputChannel.appendLine('Authenticating with Basic Auth');

                // Mock Basic Auth authentication
                const credentials = Buffer.from(`${config.config?.username}:${config.config?.password}`).toString('base64');
                return {
                    type: 'basic',
                    token: 'Basic ' + credentials
                };
            },
            refreshToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Refreshing Basic Auth');
                // Basic auth doesn't typically refresh
                return token;
            },
            validateToken: async (token: AuthToken) => {
                // Mock token validation
                return !!token.token;
            },
            revokeToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Revoking Basic Auth');
                // Mock token revocation
            }
        };
    }

    /**
     * Create Custom provider
     */
    private createCustomProvider(): AuthProvider {
        return {
            type: 'custom',
            name: 'Custom',
            initialize: async () => {
                this.outputChannel.appendLine('Initializing Custom provider');
            },
            authenticate: async (config: AuthConfig) => {
                this.outputChannel.appendLine('Authenticating with Custom method');

                // Mock Custom authentication
                return {
                    type: 'custom',
                    token: 'custom_token_' + this.generateId(),
                    expires: config.config?.expires ? new Date(config.config.expires) : undefined
                };
            },
            refreshToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Refreshing Custom token');

                // Mock token refresh
                return {
                    ...token,
                    token: 'custom_token_' + this.generateId(),
                    expires: new Date(Date.now() + 3600 * 1000)
                };
            },
            validateToken: async (token: AuthToken) => {
                // Mock token validation
                return !token.expires || new Date() < token.expires;
            },
            revokeToken: async (token: AuthToken) => {
                this.outputChannel.appendLine('Revoking Custom token');
                // Mock token revocation
            }
        };
    }

    /**
     * Generate unique ID
     */
    private generateId(): string {
        return crypto.randomBytes(16).toString('hex');
    }

    /**
     * Dispose external tool authentication
     */
    public dispose(): void {
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}