/**
 * NoodleCore Plugin Marketplace Integration
 * 
 * Provides comprehensive integration with various plugin marketplaces
 * including VS Code Marketplace, npm, PyPI, and custom plugin repositories.
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import axios from 'axios';

export interface Plugin {
    id: string;
    name: string;
    version: string;
    description: string;
    author: string;
    publisher: string;
    repository: string;
    downloadUrl: string;
    installUrl: string;
    rating: number;
    downloads: number;
    categories: string[];
    tags: string[];
    dependencies: string[];
    platform: 'vscode' | 'npm' | 'pypi' | 'custom';
    marketplace: 'vscode' | 'npm' | 'pypi' | 'github' | 'custom';
    verified: boolean;
    lastUpdated: Date;
    size: number;
    license: string;
    homepage?: string;
    bugs?: string;
    changelog?: string;
}

export interface Marketplace {
    id: string;
    name: string;
    type: 'vscode' | 'npm' | 'pypi' | 'github' | 'custom';
    baseUrl: string;
    apiKey?: string;
    enabled: boolean;
    searchEndpoint: string;
    installEndpoint?: string;
    rateLimit: number;
    lastSync: Date;
}

export interface PluginSearchQuery {
    query: string;
    category?: string;
    tags?: string[];
    platform?: Plugin['platform'];
    marketplace?: Plugin['marketplace'];
    sortBy?: 'relevance' | 'rating' | 'downloads' | 'updated';
    sortOrder?: 'asc' | 'desc';
    limit?: number;
}

export interface PluginInstallOptions {
    plugin: Plugin;
    version?: string;
    dependencies?: boolean;
    force?: boolean;
    saveAsDevDependency?: boolean;
}

export interface PluginUpdateOptions {
    plugin: Plugin;
    targetVersion?: string;
    includeDependencies?: boolean;
}

export interface MarketplaceStats {
    totalPlugins: number;
    totalDownloads: number;
    averageRating: number;
    topCategories: { name: string; count: number }[];
    recentUpdates: Plugin[];
}

export class PluginMarketplaceIntegration {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private marketplaces: Map<string, Marketplace> = new Map();
    private installedPlugins: Map<string, Plugin> = new Map();
    private searchCache: Map<string, Plugin[]> = new Map();
    private stats: MarketplaceStats;
    private context: vscode.ExtensionContext;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Plugin Marketplace');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            90
        );
        this.statusBarItem.command = 'noodle.marketplace.showStatus';
        
        this.initializeMarketplaceIntegration();
    }

    /**
     * Initialize marketplace integration
     */
    private async initializeMarketplaceIntegration(): Promise<void> {
        try {
            // Load marketplace configurations
            await this.loadMarketplaces();
            
            // Load installed plugins
            await this.loadInstalledPlugins();
            
            // Initialize marketplace stats
            this.stats = await this.loadMarketplaceStats();
            
            // Start periodic sync
            this.startPeriodicSync();
            
            this.outputChannel.appendLine('Plugin marketplace integration initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Marketplace integration initialization failed: ${error.message}`);
        }
    }

    /**
     * Load marketplace configurations
     */
    private async loadMarketplaces(): Promise<void> {
        const config = vscode.workspace.getConfiguration('noodle.marketplace');
        const marketplacesConfig = config.get<Marketplace[]>('marketplaces', []);
        
        for (const marketplaceConfig of marketplacesConfig) {
            await this.addMarketplace(marketplaceConfig);
        }
    }

    /**
     * Add marketplace
     */
    public async addMarketplace(marketplace: Marketplace): Promise<void> {
        try {
            // Test connection
            await this.testMarketplaceConnection(marketplace);
            
            this.marketplaces.set(marketplace.id, marketplace);
            this.outputChannel.appendLine(`Added marketplace: ${marketplace.name}`);
            
            this.emit('marketplaceAdded', marketplace);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add marketplace: ${error.message}`);
        }
    }

    /**
     * Remove marketplace
     */
    public removeMarketplace(id: string): boolean {
        const marketplace = this.marketplaces.get(id);
        if (!marketplace) {
            return false;
        }

        this.marketplaces.delete(id);
        this.outputChannel.appendLine(`Removed marketplace: ${marketplace.name}`);
        
        this.emit('marketplaceRemoved', marketplace);
        this.updateStatusBar();
        return true;
    }

    /**
     * Get all marketplaces
     */
    public getMarketplaces(): Marketplace[] {
        return Array.from(this.marketplaces.values());
    }

    /**
     * Get marketplace by ID
     */
    public getMarketplace(id: string): Marketplace | undefined {
        return this.marketplaces.get(id);
    }

    /**
     * Test marketplace connection
     */
    private async testMarketplaceConnection(marketplace: Marketplace): Promise<void> {
        try {
            const response = await axios.get(marketplace.baseUrl, {
                timeout: 5000,
                headers: {
                    'User-Agent': 'NoodleVSCodeExtension/1.0.0'
                }
            });
            
            if (response.status !== 200) {
                throw new Error(`Connection test failed: HTTP ${response.status}`);
            }
        } catch (error) {
            throw new Error(`Connection test failed: ${error.message}`);
        }
    }

    /**
     * Search for plugins
     */
    public async searchPlugins(query: PluginSearchQuery): Promise<Plugin[]> {
        try {
            // Check cache first
            const cacheKey = this.generateSearchCacheKey(query);
            const cached = this.searchCache.get(cacheKey);
            if (cached) {
                return cached;
            }
            
            const results: Plugin[] = [];
            
            // Search in enabled marketplaces
            for (const marketplace of this.marketplaces.values()) {
                if (!marketplace.enabled) {
                    continue;
                }
                
                const marketplaceResults = await this.searchInMarketplace(marketplace, query);
                results.push(...marketplaceResults);
            }
            
            // Apply sorting
            const sortedResults = this.sortPlugins(results, query.sortBy, query.sortOrder);
            
            // Apply limit
            const limitedResults = query.limit ? sortedResults.slice(0, query.limit) : sortedResults;
            
            // Cache results
            this.searchCache.set(cacheKey, limitedResults);
            
            // Clean up old cache entries
            this.cleanupSearchCache();
            
            return limitedResults;
        } catch (error) {
            throw new Error(`Plugin search failed: ${error.message}`);
        }
    }

    /**
     * Search in specific marketplace
     */
    private async searchInMarketplace(marketplace: Marketplace, query: PluginSearchQuery): Promise<Plugin[]> {
        try {
            const searchUrl = `${marketplace.baseUrl}${marketplace.searchEndpoint}`;
            
            const params = {
                q: query.query,
                category: query.category,
                tags: query.tags?.join(','),
                platform: query.platform,
                sort: query.sortBy,
                order: query.sortOrder,
                limit: query.limit || 20
            };
            
            const response = await axios.get(searchUrl, {
                params,
                timeout: 10000,
                headers: {
                    'Authorization': marketplace.apiKey ? `Bearer ${marketplace.apiKey}` : undefined,
                    'User-Agent': 'NoodleVSCodeExtension/1.0.0'
                }
            });
            
            return this.parseSearchResults(response.data, marketplace);
        } catch (error) {
            this.outputChannel.appendLine(`Search failed in ${marketplace.name}: ${error.message}`);
            return [];
        }
    }

    /**
     * Parse search results
     */
    private parseSearchResults(data: any, marketplace: Marketplace): Plugin[] {
        const plugins: Plugin[] = [];
        
        if (marketplace.type === 'vscode') {
            // VS Code marketplace response format
            if (data.results) {
                for (const result of data.results) {
                    plugins.push({
                        id: result.extensions[0].extensionId,
                        name: result.extensions[0].displayName,
                        version: result.extensions[0].version,
                        description: result.extensions[0].description,
                        author: result.extensions[0].publisher.displayName,
                        publisher: result.extensions[0].publisher.publisherName,
                        repository: result.extensions[0].repository,
                        downloadUrl: result.extensions[0].files[0]?.downloadUrl || '',
                        installUrl: `vscode:extension/${result.extensions[0].extensionId}`,
                        rating: result.extensions[0].averageRating || 0,
                        downloads: result.extensions[0].downloadCount || 0,
                        categories: result.extensions[0].categories || [],
                        tags: result.extensions[0].tags || [],
                        dependencies: result.extensions[0].dependencies || [],
                        platform: 'vscode',
                        marketplace: 'vscode',
                        verified: result.extensions[0].verified,
                        lastUpdated: new Date(result.extensions[0].lastUpdated),
                        size: result.extensions[0].files[0]?.size || 0,
                        license: result.extensions[0].license || '',
                        homepage: result.extensions[0].homepage,
                        bugs: result.extensions[0].support,
                        changelog: result.extensions[0].changelogUrl
                    });
                }
            }
        } else if (marketplace.type === 'npm') {
            // npm response format
            if (data.objects) {
                for (const obj of data.objects) {
                    plugins.push({
                        id: obj.package.name,
                        name: obj.package.name,
                        version: obj.package.version,
                        description: obj.package.description || '',
                        author: obj.package.author?.name || '',
                        publisher: obj.package.publisher?.username || '',
                        repository: obj.package.links?.repository || '',
                        downloadUrl: obj.package.links?.tarball || '',
                        installUrl: `npm install ${obj.package.name}`,
                        rating: 0, // npm doesn't provide ratings
                        downloads: obj.package.downloads || 0,
                        categories: obj.package.keywords || [],
                        tags: obj.package.keywords || [],
                        dependencies: Object.keys(obj.package.dependencies || {}),
                        platform: 'npm',
                        marketplace: 'npm',
                        verified: false,
                        lastUpdated: new Date(obj.package.date),
                        size: obj.package.dist?.unpackedSize || 0,
                        license: obj.package.license || '',
                        homepage: obj.package.homepage,
                        bugs: obj.package.bugs?.url
                    });
                }
            }
        } else if (marketplace.type === 'pypi') {
            // PyPI response format
            if (data.results) {
                for (const result of data.results) {
                    plugins.push({
                        id: result.name,
                        name: result.name,
                        version: result.version,
                        description: result.summary || '',
                        author: result.author || '',
                        publisher: result.author || '',
                        repository: result.project_urls?.Repository || '',
                        downloadUrl: result.urls?.find((u: any) => u.packagetype === 'bdist_wheel')?.url || '',
                        installUrl: `pip install ${result.name}`,
                        rating: 0, // PyPI doesn't provide ratings
                        downloads: result.downloads || 0,
                        categories: result.keywords?.split(',') || [],
                        tags: result.keywords?.split(',') || [],
                        dependencies: result.requires_dist || [],
                        platform: 'pypi',
                        marketplace: 'pypi',
                        verified: false,
                        lastUpdated: new Date(result.upload_time),
                        size: result.urls?.find((u: any) => u.packagetype === 'bdist_wheel')?.size || 0,
                        license: result.license || '',
                        homepage: result.project_urls?.Homepage,
                        bugs: result.project_urls?.['Bug tracker']
                    });
                }
            }
        }
        
        return plugins;
    }

    /**
     * Install plugin
     */
    public async installPlugin(options: PluginInstallOptions): Promise<void> {
        try {
            const plugin = options.plugin;
            
            // Check if already installed
            if (this.installedPlugins.has(plugin.id) && !options.force) {
                throw new Error(`Plugin already installed: ${plugin.name}`);
            }
            
            // Install dependencies
            if (options.dependencies) {
                for (const dependency of plugin.dependencies) {
                    const depQuery: PluginSearchQuery = {
                        query: dependency,
                        limit: 1
                    };
                    
                    const depResults = await this.searchPlugins(depQuery);
                    if (depResults.length > 0) {
                        await this.installPlugin({
                            plugin: depResults[0],
                            dependencies: true,
                            force: options.force
                        });
                    }
                }
            }
            
            // Install plugin
            await this.executePluginInstall(plugin, options);
            
            // Add to installed plugins
            this.installedPlugins.set(plugin.id, plugin);
            await this.saveInstalledPlugin(plugin);
            
            this.outputChannel.appendLine(`Plugin installed: ${plugin.name} v${plugin.version}`);
            this.emit('pluginInstalled', plugin);
            
            // Update stats
            this.stats.totalPlugins++;
            this.stats.totalDownloads += plugin.downloads;
            
        } catch (error) {
            throw new Error(`Plugin installation failed: ${error.message}`);
        }
    }

    /**
     * Execute plugin installation
     */
    private async executePluginInstall(plugin: Plugin, options: PluginInstallOptions): Promise<void> {
        switch (plugin.platform) {
            case 'vscode':
                await this.installVSCodePlugin(plugin, options);
                break;
            case 'npm':
                await this.installNpmPlugin(plugin, options);
                break;
            case 'pypi':
                await this.installPypiPlugin(plugin, options);
                break;
            default:
                throw new Error(`Unsupported platform: ${plugin.platform}`);
        }
    }

    /**
     * Install VS Code plugin
     */
    private async installVSCodePlugin(plugin: Plugin, options: PluginInstallOptions): Promise<void> {
        // Use VS Code API to install extension
        await vscode.commands.executeCommand('workbench.extensions.installExtension', plugin.id);
    }

    /**
     * Install npm plugin
     */
    private async installNpmPlugin(plugin: Plugin, options: PluginInstallOptions): Promise<void> {
        const command = options.saveAsDevDependency ? 
            `npm install ${plugin.name}@${options.version || plugin.version} --save-dev` : 
            `npm install ${plugin.name}@${options.version || plugin.version}`;
        
        await this.executeCommand(command);
    }

    /**
     * Install PyPI plugin
     */
    private async installPypiPlugin(plugin: Plugin, options: PluginInstallOptions): Promise<void> {
        const command = `pip install ${plugin.name}==${options.version || plugin.version}`;
        
        await this.executeCommand(command);
    }

    /**
     * Update plugin
     */
    public async updatePlugin(options: PluginUpdateOptions): Promise<void> {
        try {
            const plugin = options.plugin;
            
            // Check if installed
            if (!this.installedPlugins.has(plugin.id)) {
                throw new Error(`Plugin not installed: ${plugin.name}`);
            }
            
            // Get current version
            const currentPlugin = this.installedPlugins.get(plugin.id)!;
            const targetVersion = options.targetVersion || plugin.version;
            
            if (currentPlugin.version === targetVersion) {
                throw new Error(`Plugin already at target version: ${targetVersion}`);
            }
            
            // Update dependencies
            if (options.includeDependencies) {
                for (const dependency of plugin.dependencies) {
                    const depQuery: PluginSearchQuery = {
                        query: dependency,
                        limit: 1
                    };
                    
                    const depResults = await this.searchPlugins(depQuery);
                    if (depResults.length > 0) {
                        await this.updatePlugin({
                            plugin: depResults[0],
                            targetVersion: depResults[0].version,
                            includeDependencies: true
                        });
                    }
                }
            }
            
            // Update plugin
            await this.executePluginUpdate(plugin, targetVersion);
            
            // Update installed plugins
            currentPlugin.version = targetVersion;
            this.installedPlugins.set(plugin.id, currentPlugin);
            await this.saveInstalledPlugin(currentPlugin);
            
            this.outputChannel.appendLine(`Plugin updated: ${plugin.name} v${targetVersion}`);
            this.emit('pluginUpdated', currentPlugin);
            
        } catch (error) {
            throw new Error(`Plugin update failed: ${error.message}`);
        }
    }

    /**
     * Execute plugin update
     */
    private async executePluginUpdate(plugin: Plugin, targetVersion: string): Promise<void> {
        switch (plugin.platform) {
            case 'vscode':
                // VS Code extensions are updated through the marketplace
                await vscode.commands.executeCommand('workbench.extensions.update', { id: plugin.id });
                break;
            case 'npm':
                await this.executeCommand(`npm update ${plugin.name}@${targetVersion}`);
                break;
            case 'pypi':
                await this.executeCommand(`pip install --upgrade ${plugin.name}==${targetVersion}`);
                break;
            default:
                throw new Error(`Unsupported platform: ${plugin.platform}`);
        }
    }

    /**
     * Uninstall plugin
     */
    public async uninstallPlugin(pluginId: string): Promise<void> {
        try {
            const plugin = this.installedPlugins.get(pluginId);
            if (!plugin) {
                throw new Error(`Plugin not installed: ${pluginId}`);
            }
            
            // Uninstall plugin
            await this.executePluginUninstall(plugin);
            
            // Remove from installed plugins
            this.installedPlugins.delete(pluginId);
            await this.removeInstalledPlugin(pluginId);
            
            this.outputChannel.appendLine(`Plugin uninstalled: ${plugin.name}`);
            this.emit('pluginUninstalled', plugin);
            
            // Update stats
            this.stats.totalPlugins--;
            
        } catch (error) {
            throw new Error(`Plugin uninstallation failed: ${error.message}`);
        }
    }

    /**
     * Execute plugin uninstallation
     */
    private async executePluginUninstall(plugin: Plugin): Promise<void> {
        switch (plugin.platform) {
            case 'vscode':
                await vscode.commands.executeCommand('workbench.extensions.uninstallExtension', plugin.id);
                break;
            case 'npm':
                await this.executeCommand(`npm uninstall ${plugin.name}`);
                break;
            case 'pypi':
                await this.executeCommand(`pip uninstall ${plugin.name}`);
                break;
            default:
                throw new Error(`Unsupported platform: ${plugin.platform}`);
        }
    }

    /**
     * Get installed plugins
     */
    public getInstalledPlugins(): Plugin[] {
        return Array.from(this.installedPlugins.values());
    }

    /**
     * Get installed plugin by ID
     */
    public getInstalledPlugin(id: string): Plugin | undefined {
        return this.installedPlugins.get(id);
    }

    /**
     * Get marketplace stats
     */
    public getMarketplaceStats(): MarketplaceStats {
        return { ...this.stats };
    }

    /**
     * Generate search cache key
     */
    private generateSearchCacheKey(query: PluginSearchQuery): string {
        const key = `${query.query}-${query.category || ''}-${query.tags?.join(',') || ''}-${query.platform || ''}-${query.marketplace || ''}-${query.sortBy || ''}-${query.sortOrder || ''}`;
        return Buffer.from(key).toString('base64').substring(0, 32);
    }

    /**
     * Clean up search cache
     */
    private cleanupSearchCache(): void {
        const maxCacheSize = 50;
        if (this.searchCache.size > maxCacheSize) {
            const keys = Array.from(this.searchCache.keys());
            const keysToRemove = keys.slice(0, keys.length - maxCacheSize);
            
            for (const key of keysToRemove) {
                this.searchCache.delete(key);
            }
        }
    }

    /**
     * Sort plugins
     */
    private sortPlugins(plugins: Plugin[], sortBy?: string, sortOrder?: string): Plugin[] {
        const sorted = [...plugins];
        
        if (sortBy === 'rating') {
            sorted.sort((a, b) => (a.rating - b.rating) * (sortOrder === 'desc' ? -1 : 1));
        } else if (sortBy === 'downloads') {
            sorted.sort((a, b) => (a.downloads - b.downloads) * (sortOrder === 'desc' ? -1 : 1));
        } else if (sortBy === 'updated') {
            sorted.sort((a, b) => (a.lastUpdated.getTime() - b.lastUpdated.getTime()) * (sortOrder === 'desc' ? -1 : 1));
        } else {
            // Default to relevance
            sorted.sort((a, b) => a.name.localeCompare(b.name));
        }
        
        return sorted;
    }

    /**
     * Execute shell command
     */
    private async executeCommand(command: string): Promise<void> {
        const { exec } = require('child_process');
        const promisify = require('util').promisify;
        const execAsync = promisify(exec);
        
        await execAsync(command);
    }

    /**
     * Load installed plugins
     */
    private async loadInstalledPlugins(): Promise<void> {
        try {
            const pluginsDir = path.join(this.context.globalStorageUri.fsPath, 'plugins');
            if (!fs.existsSync(pluginsDir)) {
                fs.mkdirSync(pluginsDir, { recursive: true });
                return;
            }
            
            const files = fs.readdirSync(pluginsDir);
            const pluginFiles = files.filter(file => file.endsWith('.json'));
            
            for (const file of pluginFiles) {
                const filePath = path.join(pluginsDir, file);
                const pluginData = JSON.parse(fs.readFileSync(filePath, 'utf8'));
                
                const plugin: Plugin = {
                    ...pluginData,
                    lastUpdated: new Date(pluginData.lastUpdated)
                };
                
                this.installedPlugins.set(plugin.id, plugin);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.installedPlugins.size} installed plugins`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load installed plugins: ${error.message}`);
        }
    }

    /**
     * Save installed plugin
     */
    private async saveInstalledPlugin(plugin: Plugin): Promise<void> {
        const pluginsDir = path.join(this.context.globalStorageUri.fsPath, 'plugins');
        if (!fs.existsSync(pluginsDir)) {
            fs.mkdirSync(pluginsDir, { recursive: true });
        }
        
        const filePath = path.join(pluginsDir, `${plugin.id}.json`);
        fs.writeFileSync(filePath, JSON.stringify(plugin, null, 2));
    }

    /**
     * Remove installed plugin
     */
    private async removeInstalledPlugin(pluginId: string): Promise<void> {
        const pluginsDir = path.join(this.context.globalStorageUri.fsPath, 'plugins');
        const filePath = path.join(pluginsDir, `${pluginId}.json`);
        
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }

    /**
     * Load marketplace stats
     */
    private async loadMarketplaceStats(): Promise<MarketplaceStats> {
        // In a real implementation, this would fetch stats from marketplaces
        return {
            totalPlugins: 0,
            totalDownloads: 0,
            averageRating: 0,
            topCategories: [],
            recentUpdates: []
        };
    }

    /**
     * Start periodic sync
     */
    private startPeriodicSync(): void {
        setInterval(async () => {
            try {
                // Sync marketplace stats
                this.stats = await this.loadMarketplaceStats();
                
                // Sync installed plugins
                await this.loadInstalledPlugins();
                
                this.outputChannel.appendLine('Marketplace sync completed');
            } catch (error) {
                this.outputChannel.appendLine(`Marketplace sync failed: ${error.message}`);
            }
        }, 3600000); // Sync every hour
    }

    /**
     * Update status bar with marketplace information
     */
    private updateStatusBar(): void {
        const enabledMarketplaces = Array.from(this.marketplaces.values())
            .filter(m => m.enabled).length;
        const totalMarketplaces = this.marketplaces.size;
        const installedPlugins = this.installedPlugins.size;
        
        let text = `$(extensions) Marketplace`;
        if (installedPlugins > 0) {
            text += ` ${installedPlugins}`;
        }
        if (totalMarketplaces > 0) {
            text += ` 🔗${enabledMarketplaces}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Marketplace: ${enabledMarketplaces}/${totalMarketplaces} enabled, ${installedPlugins} plugins installed`;
    }

    /**
     * Show marketplace status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const marketplaces = this.getMarketplaces();
            const installedPlugins = this.getInstalledPlugins();
            const stats = this.getMarketplaceStats();

            let output = `Plugin Marketplace Status\n`;
            output += `========================\n\n`;

            output += `Marketplaces (${marketplaces.length}):\n`;
            for (const marketplace of marketplaces) {
                output += `  ${marketplace.name}: ${marketplace.enabled ? 'Enabled' : 'Disabled'}\n`;
                output += `    Type: ${marketplace.type}\n`;
                output += `    Base URL: ${marketplace.baseUrl}\n`;
                output += `    Rate Limit: ${marketplace.rateLimit}\n`;
                output += `    Last Sync: ${marketplace.lastSync.toLocaleString()}\n`;
            }
            output += '\n';

            output += `Installed Plugins (${installedPlugins.length}):\n`;
            for (const plugin of installedPlugins.slice(0, 10)) {
                output += `  ${plugin.name} v${plugin.version} (${plugin.platform})\n`;
                output += `    Author: ${plugin.author}\n`;
                output += `    Downloads: ${plugin.downloads}\n`;
                output += `    Rating: ${plugin.rating}/5\n`;
            }
            if (installedPlugins.length > 10) {
                output += `  ... and ${installedPlugins.length - 10} more plugins\n`;
            }
            output += '\n';

            output += `Marketplace Statistics:\n`;
            output += `  Total Plugins: ${stats.totalPlugins}\n`;
            output += `  Total Downloads: ${stats.totalDownloads}\n`;
            output += `  Average Rating: ${stats.averageRating}/5\n`;
            output += `  Top Categories: ${stats.topCategories.map(c => c.name).join(', ')}\n`;

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show marketplace status: ${error.message}`);
        }
    }

    /**
     * Dispose marketplace integration
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }

    // Event emitter methods
    private emit(event: string, data: any): void {
        // Implementation would depend on the event system being used
    }
}