/**
 * NoodleCore External Tool Authentication System
 * 
 * Provides comprehensive authentication management for external tools and services
 * including OAuth2, API keys, JWT tokens, and custom authentication schemes.
 */

import * as vscode from 'vscode';
import * as crypto from 'crypto';
import * as fs from 'fs';
import * as path from 'path';

export interface AuthProvider {
    id: string;
    name: string;
    type: 'oauth2' | 'api-key' | 'jwt' | 'basic' | 'custom';
    description: string;
    icon?: string;
    scopes: string[];
    config: AuthProviderConfig;
    enabled: boolean;
}

export interface AuthProviderConfig {
    clientId?: string;
    clientSecret?: string;
    authUrl?: string;
    tokenUrl?: string;
    scopes?: string[];
    redirectUri?: string;
    apiKey?: string;
    username?: string;
    password?: string;
    headers?: { [key: string]: string };
    customAuth?: CustomAuthConfig;
}

export interface CustomAuthConfig {
    authEndpoint: string;
    tokenEndpoint?: string;
    revokeEndpoint?: string;
    headers?: { [key: string]: string };
    body?: { [key: string]: any };
    responseParser?: (response: any) => AuthToken;
}

export interface AuthToken {
    accessToken: string;
    refreshToken?: string;
    tokenType?: string;
    expiresAt?: Date;
    scope?: string;
    idToken?: string;
    customData?: { [key: string]: any };
}

export interface AuthSession {
    id: string;
    providerId: string;
    userId: string;
    token: AuthToken;
    createdAt: Date;
    lastUsed: Date;
    expiresAt?: Date;
    scopes: string[];
    metadata: { [key: string]: any };
}

export interface AuthPermission {
    id: string;
    name: string;
    description: string;
    resource: string;
    action: string;
    effect: 'allow' | 'deny';
    conditions?: { [key: string]: any };
}

export interface AuthUser {
    id: string;
    username: string;
    email?: string;
    name?: string;
    avatar?: string;
    permissions: AuthPermission[];
    metadata: { [key: string]: any };
}

export interface AuthChallenge {
    id: string;
    providerId: string;
    type: 'mfa' | '2fa' | 'sso' | 'custom';
    description: string;
    required: boolean;
    completed: boolean;
    data: { [key: string]: any };
}

export class ExternalAuthSystem {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private authProviders: Map<string, AuthProvider> = new Map();
    private authSessions: Map<string, AuthSession> = new Map();
    private authUsers: Map<string, AuthUser> = new Map();
    private authChallenges: Map<string, AuthChallenge> = new Map();
    private storagePath: string;
    private config: vscode.WorkspaceConfiguration;

    constructor(context: vscode.ExtensionContext) {
        this.outputChannel = vscode.window.createOutputChannel('Noodle Authentication');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            80
        );
        this.statusBarItem.command = 'noodle.auth.showStatus';
        
        // Initialize storage path
        this.storagePath = path.join(context.globalStorageUri.fsPath, 'auth');
        if (!fs.existsSync(this.storagePath)) {
            fs.mkdirSync(this.storagePath, { recursive: true });
        }
        
        // Load configuration
        this.config = vscode.workspace.getConfiguration('noodle.auth');
        
        this.initializeAuthSystem();
    }

    /**
     * Initialize authentication system
     */
    private async initializeAuthSystem(): Promise<void> {
        try {
            // Load auth providers from configuration
            const providersConfig = this.config.get<AuthProvider[]>('providers', []);
            
            // Initialize providers
            for (const providerConfig of providersConfig) {
                await this.addAuthProvider(providerConfig);
            }
            
            // Load saved sessions
            await this.loadSessions();
            
            // Load saved users
            await this.loadUsers();
            
            // Start session cleanup
            this.startSessionCleanup();
            
            this.outputChannel.appendLine('Authentication system initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Authentication initialization failed: ${error.message}`);
        }
    }

    /**
     * Add authentication provider
     */
    public async addAuthProvider(provider: AuthProvider): Promise<void> {
        try {
            // Validate provider configuration
            this.validateAuthProvider(provider);
            
            this.authProviders.set(provider.id, provider);
            this.outputChannel.appendLine(`Added auth provider: ${provider.name}`);
            
            // Save provider configuration
            await this.saveAuthProvider(provider);
            
            this.emit('providerAdded', provider);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add auth provider: ${error.message}`);
        }
    }

    /**
     * Remove authentication provider
     */
    public removeAuthProvider(id: string): boolean {
        const provider = this.authProviders.get(id);
        if (!provider) {
            return false;
        }

        // Remove all sessions for this provider
        const sessionsToRemove = Array.from(this.authSessions.values())
            .filter(session => session.providerId === id);
        
        for (const session of sessionsToRemove) {
            this.authSessions.delete(session.id);
        }

        this.authProviders.delete(id);
        this.outputChannel.appendLine(`Removed auth provider: ${provider.name}`);
        
        // Remove provider configuration
        this.removeAuthProviderConfig(id);
        
        this.emit('providerRemoved', provider);
        this.updateStatusBar();
        return true;
    }

    /**
     * Get all authentication providers
     */
    public getAuthProviders(): AuthProvider[] {
        return Array.from(this.authProviders.values());
    }

    /**
     * Get authentication provider by ID
     */
    public getAuthProvider(id: string): AuthProvider | undefined {
        return this.authProviders.get(id);
    }

    /**
     * Validate authentication provider configuration
     */
    private validateAuthProvider(provider: AuthProvider): void {
        if (!provider.id || !provider.name) {
            throw new Error('Provider must have an ID and name');
        }
        
        if (!provider.scopes || provider.scopes.length === 0) {
            throw new Error('Provider must have at least one scope');
        }
        
        switch (provider.type) {
            case 'oauth2':
                if (!provider.config.clientId || !provider.config.authUrl || !provider.config.tokenUrl) {
                    throw new Error('OAuth2 provider requires clientId, authUrl, and tokenUrl');
                }
                break;
                
            case 'api-key':
                if (!provider.config.apiKey) {
                    throw new Error('API key provider requires an apiKey');
                }
                break;
                
            case 'jwt':
                if (!provider.config.clientId || !provider.config.clientSecret) {
                    throw new Error('JWT provider requires clientId and clientSecret');
                }
                break;
                
            case 'basic':
                if (!provider.config.username || !provider.config.password) {
                    throw new Error('Basic auth provider requires username and password');
                }
                break;
                
            case 'custom':
                if (!provider.config.customAuth?.authEndpoint) {
                    throw new Error('Custom auth provider requires authEndpoint');
                }
                break;
        }
    }

    /**
     * Authenticate with provider
     */
    public async authenticate(providerId: string, options?: {
        scopes?: string[];
        challenge?: AuthChallenge;
        customData?: { [key: string]: any };
    }): Promise<AuthSession> {
        const provider = this.authProviders.get(providerId);
        if (!provider) {
            throw new Error(`Provider not found: ${providerId}`);
        }

        if (!provider.enabled) {
            throw new Error(`Provider is disabled: ${providerId}`);
        }

        try {
            let token: AuthToken;
            
            switch (provider.type) {
                case 'oauth2':
                    token = await this.authenticateWithOAuth2(provider, options);
                    break;
                    
                case 'api-key':
                    token = await this.authenticateWithApiKey(provider, options);
                    break;
                    
                case 'jwt':
                    token = await this.authenticateWithJWT(provider, options);
                    break;
                    
                case 'basic':
                    token = await this.authenticateWithBasic(provider, options);
                    break;
                    
                case 'custom':
                    token = await this.authenticateWithCustom(provider, options);
                    break;
                    
                default:
                    throw new Error(`Unsupported auth type: ${provider.type}`);
            }
            
            // Create session
            const session: AuthSession = {
                id: this.generateSessionId(),
                providerId,
                userId: token.customData?.userId || 'default',
                token,
                createdAt: new Date(),
                lastUsed: new Date(),
                expiresAt: token.expiresAt,
                scopes: options?.scopes || provider.scopes,
                metadata: options?.customData || {}
            };
            
            this.authSessions.set(session.id, session);
            await this.saveSession(session);
            
            this.outputChannel.appendLine(`Authentication successful for provider: ${provider.name}`);
            this.emit('sessionCreated', session);
            
            return session;
        } catch (error) {
            throw new Error(`Authentication failed: ${error.message}`);
        }
    }

    /**
     * Authenticate with OAuth2
     */
    private async authenticateWithOAuth2(
        provider: AuthProvider,
        options?: { scopes?: string[]; customData?: { [key: string]: any } }
    ): Promise<AuthToken> {
        // This is a simplified OAuth2 flow
        // In production, use proper OAuth2 library
        
        const config = provider.config;
        const scopes = options?.scopes || provider.scopes;
        
        // Generate state and code verifier for PKCE
        const state = this.generateRandomString(32);
        const codeVerifier = this.generateRandomString(128);
        const codeChallenge = this.generateCodeChallenge(codeVerifier);
        
        // Build auth URL
        const authUrl = new URL(config.authUrl!);
        authUrl.searchParams.set('client_id', config.clientId!);
        authUrl.searchParams.set('redirect_uri', config.redirectUri || 'http://localhost:3000/callback');
        authUrl.searchParams.set('response_type', 'code');
        authUrl.searchParams.set('scope', scopes.join(' '));
        authUrl.searchParams.set('state', state);
        authUrl.searchParams.set('code_challenge', codeChallenge);
        authUrl.searchParams.set('code_challenge_method', 'S256');
        
        // Open browser for authentication
        const authCode = await this.openBrowserForAuth(authUrl.toString());
        
        // Exchange code for token
        const tokenResponse = await fetch(config.tokenUrl!, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded',
                'Authorization': `Basic ${Buffer.from(`${config.clientId}:${config.clientSecret}`).toString('base64')}`
            },
            body: new URLSearchParams({
                grant_type: 'authorization_code',
                code: authCode,
                redirect_uri: config.redirectUri || 'http://localhost:3000/callback',
                code_verifier: codeVerifier
            })
        });
        
        const tokenData = await tokenResponse.json();
        
        return {
            accessToken: tokenData.access_token,
            refreshToken: tokenData.refresh_token,
            tokenType: tokenData.token_type,
            expiresAt: tokenData.expires_in ? new Date(Date.now() + tokenData.expires_in * 1000) : undefined,
            scope: tokenData.scope,
            customData: tokenData
        };
    }

    /**
     * Authenticate with API key
     */
    private async authenticateWithApiKey(
        provider: AuthProvider,
        options?: { customData?: { [key: string]: any } }
    ): Promise<AuthToken> {
        return {
            accessToken: provider.config.apiKey!,
            tokenType: 'Bearer',
            expiresAt: undefined,
            customData: options?.customData
        };
    }

    /**
     * Authenticate with JWT
     */
    private async authenticateWithJWT(
        provider: AuthProvider,
        options?: { customData?: { [key: string]: any } }
    ): Promise<AuthToken> {
        // This is a simplified JWT flow
        // In production, use proper JWT library
        
        const config = provider.config;
        
        // Build JWT payload
        const payload = {
            iss: config.clientId,
            sub: 'user',
            aud: config.tokenUrl,
            exp: Math.floor(Date.now() / 1000) + 3600,
            iat: Math.floor(Date.now() / 1000),
            scope: provider.scopes.join(' '),
            ...options?.customData
        };
        
        // Sign JWT (simplified - in production, use proper JWT signing)
        const jwt = this.signJWT(payload, config.clientSecret!);
        
        return {
            accessToken: jwt,
            tokenType: 'Bearer',
            expiresAt: new Date(Date.now() + 3600 * 1000),
            customData: payload
        };
    }

    /**
     * Authenticate with Basic Auth
     */
    private async authenticateWithBasic(
        provider: AuthProvider,
        options?: { customData?: { [key: string]: any } }
    ): Promise<AuthToken> {
        const credentials = Buffer.from(`${provider.config.username}:${provider.config.password}`).toString('base64');
        
        return {
            accessToken: credentials,
            tokenType: 'Basic',
            expiresAt: undefined,
            customData: options?.customData
        };
    }

    /**
     * Authenticate with Custom Auth
     */
    private async authenticateWithCustom(
        provider: AuthProvider,
        options?: { scopes?: string[]; customData?: { [key: string]: any } }
    ): Promise<AuthToken> {
        const config = provider.config.customAuth!;
        
        // Build request body
        const body = {
            ...config.body,
            ...options?.customData
        };
        
        // Make authentication request
        const response = await fetch(config.authEndpoint, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                ...config.headers
            },
            body: JSON.stringify(body)
        });
        
        const responseData = await response.json();
        
        // Parse response using custom parser or default
        const token = config.responseParser ? 
            config.responseParser(responseData) : 
            this.parseCustomAuthResponse(responseData);
        
        return token;
    }

    /**
     * Parse custom auth response
     */
    private parseCustomAuthResponse(response: any): AuthToken {
        return {
            accessToken: response.access_token || response.token,
            refreshToken: response.refresh_token,
            tokenType: response.token_type || 'Bearer',
            expiresAt: response.expires_in ? new Date(Date.now() + response.expires_in * 1000) : undefined,
            scope: response.scope,
            customData: response
        };
    }

    /**
     * Refresh authentication token
     */
    public async refreshToken(sessionId: string): Promise<AuthSession> {
        const session = this.authSessions.get(sessionId);
        if (!session) {
            throw new Error(`Session not found: ${sessionId}`);
        }
        
        const provider = this.authProviders.get(session.providerId);
        if (!provider) {
            throw new Error(`Provider not found: ${session.providerId}`);
        }
        
        try {
            let newToken: AuthToken;
            
            if (session.token.refreshToken && provider.type === 'oauth2') {
                // Use refresh token
                const config = provider.config;
                const response = await fetch(config.tokenUrl!, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Authorization': `Basic ${Buffer.from(`${config.clientId}:${config.clientSecret}`).toString('base64')}`
                    },
                    body: new URLSearchParams({
                        grant_type: 'refresh_token',
                        refresh_token: session.token.refreshToken
                    })
                });
                
                const tokenData = await response.json();
                newToken = {
                    accessToken: tokenData.access_token,
                    refreshToken: tokenData.refresh_token || session.token.refreshToken,
                    tokenType: tokenData.token_type,
                    expiresAt: tokenData.expires_in ? new Date(Date.now() + tokenData.expires_in * 1000) : undefined,
                    scope: tokenData.scope,
                    customData: tokenData
                };
            } else {
                // Re-authenticate
                newToken = await this.authenticate(session.providerId, {
                    scopes: session.scopes,
                    customData: session.metadata
                });
            }
            
            // Update session
            session.token = newToken;
            session.lastUsed = new Date();
            
            this.authSessions.set(sessionId, session);
            await this.saveSession(session);
            
            this.outputChannel.appendLine(`Token refreshed for session: ${sessionId}`);
            this.emit('sessionUpdated', session);
            
            return session;
        } catch (error) {
            throw new Error(`Token refresh failed: ${error.message}`);
        }
    }

    /**
     * Revoke authentication session
     */
    public async revokeSession(sessionId: string): Promise<void> {
        const session = this.authSessions.get(sessionId);
        if (!session) {
            throw new Error(`Session not found: ${sessionId}`);
        }
        
        const provider = this.authProviders.get(session.providerId);
        if (!provider) {
            throw new Error(`Provider not found: ${session.providerId}`);
        }
        
        try {
            // Try to revoke token at provider
            if (provider.type === 'oauth2' && session.token.refreshToken) {
                const config = provider.config;
                await fetch(config.tokenUrl!, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/x-www-form-urlencoded',
                        'Authorization': `Basic ${Buffer.from(`${config.clientId}:${config.clientSecret}`).toString('base64')}`
                    },
                    body: new URLSearchParams({
                        grant_type: 'refresh_token',
                        token: session.token.refreshToken
                    })
                });
            }
            
            // Remove session
            this.authSessions.delete(sessionId);
            await this.removeSession(sessionId);
            
            this.outputChannel.appendLine(`Session revoked: ${sessionId}`);
            this.emit('sessionRevoked', session);
        } catch (error) {
            // Don't throw error if revocation fails, just log it
            this.outputChannel.appendLine(`Warning: Failed to revoke token at provider: ${error.message}`);
            
            // Still remove local session
            this.authSessions.delete(sessionId);
            await this.removeSession(sessionId);
            this.emit('sessionRevoked', session);
        }
    }

    /**
     * Get all sessions
     */
    public getSessions(): AuthSession[] {
        return Array.from(this.authSessions.values());
    }

    /**
     * Get session by ID
     */
    public getSession(id: string): AuthSession | undefined {
        return this.authSessions.get(id);
    }

    /**
     * Get active sessions for provider
     */
    public getSessionsForProvider(providerId: string): AuthSession[] {
        return Array.from(this.authSessions.values())
            .filter(session => session.providerId === providerId);
    }

    /**
     * Check if session is valid
     */
    public isSessionValid(session: AuthSession): boolean {
        if (session.expiresAt && new Date() > session.expiresAt) {
            return false;
        }
        
        // Additional validation logic can be added here
        return true;
    }

    /**
     * Get authorization header for session
     */
    public getAuthHeader(sessionId: string): string {
        const session = this.authSessions.get(sessionId);
        if (!session) {
            throw new Error(`Session not found: ${sessionId}`);
        }
        
        if (!this.isSessionValid(session)) {
            throw new Error(`Session is expired or invalid: ${sessionId}`);
        }
        
        return `${session.token.tokenType} ${session.token.accessToken}`;
    }

    /**
     * Update status bar with authentication information
     */
    private updateStatusBar(): void {
        const activeSessions = Array.from(this.authSessions.values())
            .filter(session => this.isSessionValid(session)).length;
        const totalProviders = this.authProviders.size;
        const enabledProviders = Array.from(this.authProviders.values())
            .filter(provider => provider.enabled).length;
        
        let text = `$(lock) Auth`;
        if (activeSessions > 0) {
            text += ` ${activeSessions}`;
        }
        if (totalProviders > 0) {
            text += ` 🔒${enabledProviders}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Authentication: ${activeSessions} active sessions, ${enabledProviders}/${totalProviders} providers enabled`;
    }

    /**
     * Show authentication status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const providers = this.getAuthProviders();
            const sessions = this.getSessions();
            const activeSessions = sessions.filter(session => this.isSessionValid(session));

            let output = `Authentication System Status\n`;
            output += `============================\n\n`;

            output += `Providers (${providers.length}):\n`;
            for (const provider of providers) {
                output += `  ${provider.name}: ${provider.enabled ? 'Enabled' : 'Disabled'}\n`;
                output += `    Type: ${provider.type}\n`;
                output += `    Scopes: ${provider.scopes.join(', ')}\n`;
            }
            output += '\n';

            output += `Sessions (${sessions.length}):\n`;
            for (const session of activeSessions) {
                const provider = this.authProviders.get(session.providerId);
                output += `  ${provider?.name || 'Unknown'}: ${session.userId}\n`;
                output += `    Created: ${session.createdAt.toLocaleString()}\n`;
                output += `    Last Used: ${session.lastUsed.toLocaleString()}\n`;
                if (session.expiresAt) {
                    output += `    Expires: ${session.expiresAt.toLocaleString()}\n`;
                }
                output += `    Scopes: ${session.scopes.join(', ')}\n`;
            }
            
            if (sessions.length > activeSessions.length) {
                const expiredSessions = sessions.length - activeSessions.length;
                output += `  ... and ${expiredSessions} expired sessions\n`;
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show authentication status: ${error.message}`);
        }
    }

    /**
     * Save authentication provider configuration
     */
    private async saveAuthProvider(provider: AuthProvider): Promise<void> {
        const filePath = path.join(this.storagePath, `provider-${provider.id}.json`);
        const config = {
            ...provider,
            config: {
                ...provider.config,
                // Don't save sensitive data
                clientSecret: undefined,
                apiKey: undefined,
                password: undefined
            }
        };
        
        fs.writeFileSync(filePath, JSON.stringify(config, null, 2));
    }

    /**
     * Remove authentication provider configuration
     */
    private removeAuthProviderConfig(id: string): void {
        const filePath = path.join(this.storagePath, `provider-${id}.json`);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }

    /**
     * Save session
     */
    private async saveSession(session: AuthSession): Promise<void> {
        const filePath = path.join(this.storagePath, `session-${session.id}.json`);
        fs.writeFileSync(filePath, JSON.stringify(session, null, 2));
    }

    /**
     * Remove session
     */
    private async removeSession(sessionId: string): Promise<void> {
        const filePath = path.join(this.storagePath, `session-${sessionId}.json`);
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }

    /**
     * Load sessions from storage
     */
    private async loadSessions(): Promise<void> {
        try {
            const files = fs.readdirSync(this.storagePath);
            const sessionFiles = files.filter(file => file.startsWith('session-'));
            
            for (const file of sessionFiles) {
                const filePath = path.join(this.storagePath, file);
                const sessionData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                
                const session: AuthSession = {
                    ...sessionData,
                    createdAt: new Date(sessionData.createdAt),
                    lastUsed: new Date(sessionData.lastUsed),
                    expiresAt: sessionData.expiresAt ? new Date(sessionData.expiresAt) : undefined
                };
                
                this.authSessions.set(session.id, session);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.authSessions.size} sessions`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load sessions: ${error.message}`);
        }
    }

    /**
     * Load users from storage
     */
    private async loadUsers(): Promise<void> {
        try {
            const filePath = path.join(this.storagePath, 'users.json');
            if (fs.existsSync(filePath)) {
                const usersData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                
                for (const userData of usersData) {
                    const user: AuthUser = {
                        ...userData,
                        permissions: userData.permissions.map((p: any) => ({
                            ...p,
                            id: p.id || this.generateRandomString(16)
                        }))
                    };
                    
                    this.authUsers.set(user.id, user);
                }
                
                this.outputChannel.appendLine(`Loaded ${this.authUsers.size} users`);
            }
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load users: ${error.message}`);
        }
    }

    /**
     * Start session cleanup
     */
    private startSessionCleanup(): void {
        setInterval(() => {
            const now = new Date();
            const expiredSessions = Array.from(this.authSessions.values())
                .filter(session => session.expiresAt && now > session.expiresAt);
            
            for (const session of expiredSessions) {
                this.authSessions.delete(session.id);
                this.removeSession(session.id);
                this.emit('sessionExpired', session);
            }
            
            if (expiredSessions.length > 0) {
                this.outputChannel.appendLine(`Cleaned up ${expiredSessions.length} expired sessions`);
            }
        }, 3600000); // Run every hour
    }

    /**
     * Generate random string
     */
    private generateRandomString(length: number): string {
        return crypto.randomBytes(length).toString('hex').substring(0, length);
    }

    /**
     * Generate code challenge for PKCE
     */
    private generateCodeChallenge(codeVerifier: string): string {
        return crypto.createHash('sha256').update(codeVerifier).digest('base64')
            .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
    }

    /**
     * Generate session ID
     */
    private generateSessionId(): string {
        return `session_${this.generateRandomString(32)}`;
    }

    /**
     * Sign JWT (simplified)
     */
    private signJWT(payload: any, secret: string): string {
        // This is a simplified JWT signing
        // In production, use proper JWT library
        const header = {
            alg: 'HS256',
            typ: 'JWT'
        };
        
        const encodedHeader = Buffer.from(JSON.stringify(header)).toString('base64');
        const encodedPayload = Buffer.from(JSON.stringify(payload)).toString('base64');
        const signature = crypto.createHmac('sha256', secret)
            .update(`${encodedHeader}.${encodedPayload}`)
            .digest('base64')
            .replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '');
        
        return `${encodedHeader}.${encodedPayload}.${signature}`;
    }

    /**
     * Open browser for authentication
     */
    private async openBrowserForAuth(authUrl: string): Promise<string> {
        return new Promise((resolve, reject) => {
            // This is a simplified browser opening
            // In production, use proper OAuth2 flow with callback server
            vscode.env.openExternal(vscode.Uri.parse(authUrl));
            
            // For demo purposes, return a dummy code
            setTimeout(() => {
                resolve('dummy_auth_code');
            }, 2000);
        });
    }

    /**
     * Dispose authentication system
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }

    // Event emitter methods
    private emit(event: string, data: any): void {
        this.emit(event, data);
    }
}