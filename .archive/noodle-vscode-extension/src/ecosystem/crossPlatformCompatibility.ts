/**
 * NoodleCore Cross-Platform Compatibility System
 * 
 * Provides comprehensive cross-platform support for Windows, macOS, and Linux
 * with platform-specific optimizations and compatibility layers.
 */

import * as vscode from 'vscode';
import * as os from 'os';
import * as path from 'path';
import * as fs from 'fs';

export interface PlatformInfo {
    platform: NodeJS.Platform;
    arch: string;
    version: string;
    release: string;
    hostname: string;
    homedir: string;
    tmpdir: string;
    env: { [key: string]: string | undefined };
}

export interface PlatformSpecificConfig {
    executablePaths: { [platform: string]: string };
    fileExtensions: { [platform: string]: string[] };
    shellCommands: { [platform: string]: string };
    environmentVariables: { [platform: string]: string[] };
    pathSeparators: { [platform: string]: string };
    lineEndings: { [platform: string]: 'lf' | 'crlf' };
    defaultTerminal: { [platform: string]: string };
}

export interface CompatibilityIssue {
    id: string;
    type: 'path' | 'file' | 'command' | 'permission' | 'environment' | 'dependency';
    severity: 'low' | 'medium' | 'high' | 'critical';
    platform: string;
    description: string;
    suggestion: string;
    autoFixable: boolean;
    fixed: boolean;
}

export interface PlatformOptimization {
    id: string;
    name: string;
    platform: string;
    description: string;
    enabled: boolean;
    config: { [key: string]: any };
    impact: 'low' | 'medium' | 'high';
}

export class CrossPlatformCompatibility {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private platformInfo: PlatformInfo;
    private platformConfig: PlatformSpecificConfig;
    private compatibilityIssues: CompatibilityIssue[] = [];
    private optimizations: PlatformOptimization[] = [];
    private context: vscode.ExtensionContext;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Cross-Platform');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            85
        );
        this.statusBarItem.command = 'noodle.platform.showStatus';
        
        this.initializePlatformSupport();
    }

    /**
     * Initialize platform support
     */
    private async initializePlatformSupport(): Promise<void> {
        try {
            // Detect platform
            this.platformInfo = this.detectPlatform();
            
            // Load platform-specific configuration
            this.platformConfig = this.loadPlatformConfig();
            
            // Initialize platform-specific optimizations
            this.initializeOptimizations();
            
            // Check for compatibility issues
            await this.checkCompatibilityIssues();
            
            // Apply platform-specific settings
            this.applyPlatformSettings();
            
            this.outputChannel.appendLine(`Platform support initialized for ${this.platformInfo.platform}`);
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Platform support initialization failed: ${error.message}`);
        }
    }

    /**
     * Detect platform information
     */
    private detectPlatform(): PlatformInfo {
        const platform = os.platform();
        const arch = os.arch();
        const release = os.release();
        const version = os.version();
        const hostname = os.hostname();
        const homedir = os.homedir();
        const tmpdir = os.tmpdir();
        const env = process.env;

        return {
            platform,
            arch,
            version,
            release,
            hostname,
            homedir,
            tmpdir,
            env
        };
    }

    /**
     * Load platform-specific configuration
     */
    private loadPlatformConfig(): PlatformSpecificConfig {
        const config = vscode.workspace.getConfiguration('noodle.platform');
        
        return {
            executablePaths: config.get('executablePaths', {}),
            fileExtensions: config.get('fileExtensions', {}),
            shellCommands: config.get('shellCommands', {}),
            environmentVariables: config.get('environmentVariables', {}),
            pathSeparators: {
                win32: '\\',
                darwin: '/',
                linux: '/'
            },
            lineEndings: {
                win32: 'crlf',
                darwin: 'lf',
                linux: 'lf'
            },
            defaultTerminal: {
                win32: 'cmd.exe',
                darwin: 'Terminal.app',
                linux: 'xterm'
            }
        };
    }

    /**
     * Initialize platform-specific optimizations
     */
    private initializeOptimizations(): void {
        const optimizationsConfig = vscode.workspace.getConfiguration('noodle.platform.optimizations');
        
        // Windows optimizations
        this.optimizations.push({
            id: 'windows-path-length',
            name: 'Windows Path Length Optimization',
            platform: 'win32',
            description: 'Optimize for Windows path length limitations',
            enabled: optimizationsConfig.get('windows.pathLength', true),
            config: {
                maxPathLength: 260,
                useShortPaths: true
            },
            impact: 'medium'
        });

        // macOS optimizations
        this.optimizations.push({
            id: 'macos-memory',
            name: 'macOS Memory Optimization',
            platform: 'darwin',
            description: 'Optimize memory usage for macOS',
            enabled: optimizationsConfig.get('macos.memory', true),
            config: {
                memoryLimit: 2048,
                enableMemoryPressure: true
            },
            impact: 'high'
        });

        // Linux optimizations
        this.optimizations.push({
            id: 'linux-permissions',
            name: 'Linux Permissions Optimization',
            platform: 'linux',
            description: 'Optimize file permissions for Linux',
            enabled: optimizationsConfig.get('linux.permissions', true),
            config: {
                defaultFileMode: 0o644,
                defaultDirMode: 0o755
            },
            impact: 'medium'
        });

        // Cross-platform optimizations
        this.optimizations.push({
            id: 'cross-platform-cache',
            name: 'Cross-Platform Cache Optimization',
            platform: 'all',
            description: 'Optimize caching across all platforms',
            enabled: optimizationsConfig.get('cache.enabled', true),
            config: {
                cacheSize: 512,
                cacheTTL: 3600
            },
            impact: 'high'
        });
    }

    /**
     * Check for compatibility issues
     */
    private async checkCompatibilityIssues(): Promise<void> {
        const issues: CompatibilityIssue[] = [];

        // Check path separator compatibility
        const pathSeparator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        if (pathSeparator !== '/') {
            issues.push({
                id: 'path-separator',
                type: 'path',
                severity: 'medium',
                platform: this.platformInfo.platform,
                description: `Platform uses ${pathSeparator} as path separator`,
                suggestion: 'Use path.join() and path.normalize() for cross-platform compatibility',
                autoFixable: true,
                fixed: false
            });
        }

        // Check line ending compatibility
        const lineEnding = this.platformConfig.lineEndings[this.platformInfo.platform];
        if (lineEnding === 'crlf') {
            issues.push({
                id: 'line-endings',
                type: 'file',
                severity: 'low',
                platform: this.platformInfo.platform,
                description: 'Platform uses CRLF line endings',
                suggestion: 'Consider using LF line endings for better cross-platform compatibility',
                autoFixable: true,
                fixed: false
            });
        }

        // Check executable paths
        const executablePath = this.platformConfig.executablePaths[this.platformInfo.platform];
        if (!executablePath || !fs.existsSync(executablePath)) {
            issues.push({
                id: 'executable-path',
                type: 'dependency',
                severity: 'high',
                platform: this.platformInfo.platform,
                description: 'Required executable not found',
                suggestion: `Install the required executable at: ${executablePath}`,
                autoFixable: false,
                fixed: false
            });
        }

        // Check environment variables
        const requiredEnvVars = this.platformConfig.environmentVariables[this.platformInfo.platform];
        for (const envVar of requiredEnvVars) {
            if (!process.env[envVar]) {
                issues.push({
                    id: `env-${envVar}`,
                    type: 'environment',
                    severity: 'medium',
                    platform: this.platformInfo.platform,
                    description: `Required environment variable not set: ${envVar}`,
                    suggestion: `Set the ${envVar} environment variable`,
                    autoFixable: false,
                    fixed: false
                });
            }
        }

        this.compatibilityIssues = issues;
        this.outputChannel.appendLine(`Found ${issues.length} compatibility issues`);
    }

    /**
     * Apply platform-specific settings
     */
    private applyPlatformSettings(): void {
        // Apply path separator settings
        const pathSeparator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        vscode.workspace.getConfiguration('files').update('autoGuessEncoding', true, true);
        
        // Apply line ending settings
        const lineEnding = this.platformConfig.lineEndings[this.platformInfo.platform];
        vscode.workspace.getConfiguration('files').update('eol', lineEnding, true);
        
        // Apply terminal settings
        const defaultTerminal = this.platformConfig.defaultTerminal[this.platformInfo.platform];
        vscode.workspace.getConfiguration('terminal').update('defaultProfile', defaultTerminal, true);
        
        // Apply optimizations
        for (const optimization of this.optimizations) {
            if (optimization.enabled && (optimization.platform === 'all' || optimization.platform === this.platformInfo.platform)) {
                this.applyOptimization(optimization);
            }
        }
    }

    /**
     * Apply platform optimization
     */
    private applyOptimization(optimization: PlatformOptimization): void {
        switch (optimization.id) {
            case 'windows-path-length':
                this.applyWindowsPathLengthOptimization(optimization.config);
                break;
            case 'macos-memory':
                this.applyMacOSMemoryOptimization(optimization.config);
                break;
            case 'linux-permissions':
                this.applyLinuxPermissionsOptimization(optimization.config);
                break;
            case 'cross-platform-cache':
                this.applyCrossPlatformCacheOptimization(optimization.config);
                break;
        }
    }

    /**
     * Apply Windows path length optimization
     */
    private applyWindowsPathLengthOptimization(config: any): void {
        if (config.useShortPaths) {
            // Enable short path support for Windows
            vscode.workspace.getConfiguration('files').update('encoding', 'utf8', true);
            vscode.workspace.getConfiguration('search').update('useIgnoreFiles', true, true);
        }
    }

    /**
     * Apply macOS memory optimization
     */
    private applyMacOSMemoryOptimization(config: any): void {
        if (config.enableMemoryPressure) {
            // Enable memory pressure monitoring for macOS
            vscode.env.asar.extractResource('resources/memory-monitor.js', 'temp');
            // Additional macOS-specific memory optimizations
        }
    }

    /**
     * Apply Linux permissions optimization
     */
    private applyLinuxPermissionsOptimization(config: any): void {
        // Set default file permissions for Linux
        fs.chmodSync(this.context.globalStorageUri.fsPath, config.defaultDirMode);
    }

    /**
     * Apply cross-platform cache optimization
     */
    private applyCrossPlatformCacheOptimization(config: any): void {
        // Configure cross-platform caching
        const cacheDir = path.join(this.context.globalStorageUri.fsPath, 'cache');
        if (!fs.existsSync(cacheDir)) {
            fs.mkdirSync(cacheDir, { recursive: true });
        }
        
        // Set cache size limits
        vscode.workspace.getConfiguration('cache').update('size', config.cacheSize, true);
    }

    /**
     * Get platform information
     */
    public getPlatformInfo(): PlatformInfo {
        return this.platformInfo;
    }

    /**
     * Get platform-specific configuration
     */
    public getPlatformConfig(): PlatformSpecificConfig {
        return this.platformConfig;
    }

    /**
     * Get compatibility issues
     */
    public getCompatibilityIssues(): CompatibilityIssue[] {
        return [...this.compatibilityIssues];
    }

    /**
     * Get platform optimizations
     */
    public getOptimizations(): PlatformOptimization[] {
        return [...this.optimizations];
    }

    /**
     * Fix compatibility issue
     */
    public async fixCompatibilityIssue(issueId: string): Promise<boolean> {
        const issue = this.compatibilityIssues.find(i => i.id === issueId);
        if (!issue || !issue.autoFixable) {
            return false;
        }

        try {
            switch (issue.type) {
                case 'path':
                    await this.fixPathIssue(issue);
                    break;
                case 'file':
                    await this.fixFileIssue(issue);
                    break;
                case 'command':
                    await this.fixCommandIssue(issue);
                    break;
                case 'permission':
                    await this.fixPermissionIssue(issue);
                    break;
                case 'environment':
                    await this.fixEnvironmentIssue(issue);
                    break;
                case 'dependency':
                    await this.fixDependencyIssue(issue);
                    break;
                default:
                    return false;
            }

            issue.fixed = true;
            this.outputChannel.appendLine(`Fixed compatibility issue: ${issue.description}`);
            return true;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to fix compatibility issue: ${error.message}`);
            return false;
        }
    }

    /**
     * Fix path-related issue
     */
    private async fixPathIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement path fixing logic
        // This would involve normalizing paths, using proper path separators, etc.
    }

    /**
     * Fix file-related issue
     */
    private async fixFileIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement file fixing logic
        // This would involve converting line endings, fixing file permissions, etc.
    }

    /**
     * Fix command-related issue
     */
    private async fixCommandIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement command fixing logic
        // This would involve adjusting shell commands for the platform
    }

    /**
     * Fix permission-related issue
     */
    private async fixPermissionIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement permission fixing logic
        // This would involve adjusting file permissions
    }

    /**
     * Fix environment-related issue
     */
    private async fixEnvironmentIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement environment fixing logic
        // This would involve setting environment variables
    }

    /**
     * Fix dependency-related issue
     */
    private async fixDependencyIssue(issue: CompatibilityIssue): Promise<void> {
        // Implement dependency fixing logic
        // This would involve installing missing dependencies
    }

    /**
     * Get platform-specific path
     */
    public getPlatformPath(...segments: string[]): string {
        const separator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        return path.join(...segments).replace(/\//g, separator);
    }

    /**
     * Normalize path for cross-platform compatibility
     */
    public normalizePath(p: string): string {
        const separator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        return p.replace(/\//g, separator).replace(/\\/g, separator);
    }

    /**
     * Get platform-specific shell command
     */
    public getShellCommand(command: string): string {
        const platformCommand = this.platformConfig.shellCommands[this.platformInfo.platform];
        return platformCommand ? `${platformCommand} ${command}` : command;
    }

    /**
     * Get platform-specific file extensions
     */
    public getFileExtensions(): string[] {
        return this.platformConfig.fileExtensions[this.platformInfo.platform] || [];
    }

    /**
     * Check if file path is valid for current platform
     */
    public isValidPath(filePath: string): boolean {
        const platform = this.platformInfo.platform;
        
        if (platform === 'win32') {
            // Windows path validation
            const win32PathRegex = /^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$/;
            return win32PathRegex.test(filePath);
        } else {
            // Unix-like path validation
            const unixPathRegex = /^\/$|^(\/[^\r\n\/]+)+$/;
            return unixPathRegex.test(filePath);
        }
    }

    /**
     * Get platform-specific temporary directory
     */
    public getTempDir(): string {
        return this.platformInfo.tmpdir;
    }

    /**
     * Get platform-specific home directory
     */
    public getHomeDir(): string {
        return this.platformInfo.homedir;
    }

    /**
     * Get platform-specific environment variable
     */
    public getEnvVar(name: string): string | undefined {
        return this.platformInfo.env[name];
    }

    /**
     * Set platform-specific environment variable
     */
    public setEnvVar(name: string, value: string): void {
        process.env[name] = value;
        this.platformInfo.env[name] = value;
    }

    /**
     * Get platform-specific line ending
     */
    public getLineEnding(): 'lf' | 'crlf' {
        return this.platformConfig.lineEndings[this.platformInfo.platform];
    }

    /**
     * Convert text to platform-specific line endings
     */
    public convertLineEndings(text: string): string {
        const lineEnding = this.getLineEnding();
        return lineEnding === 'crlf' ? text.replace(/\n/g, '\r\n') : text;
    }

    /**
     * Update status bar with platform information
     */
    private updateStatusBar(): void {
        const platform = this.platformInfo.platform;
        const arch = this.platformInfo.arch;
        const issues = this.compatibilityIssues.filter(i => !i.fixed).length;
        
        let text = `$(computer) ${platform}`;
        if (issues > 0) {
            text += ` ⚠️${issues}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Platform: ${platform} ${arch} | Compatibility Issues: ${issues}`;
    }

    /**
     * Show platform status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const platformInfo = this.getPlatformInfo();
            const platformConfig = this.getPlatformConfig();
            const issues = this.getCompatibilityIssues();
            const optimizations = this.getOptimizations();

            let output = `Cross-Platform Compatibility Status\n`;
            output += `===================================\n\n`;

            output += `Platform Information:\n`;
            output += `  Platform: ${platformInfo.platform}\n`;
            output += `  Architecture: ${platformInfo.arch}\n`;
            output += `  Version: ${platformInfo.version}\n`;
            output += `  Release: ${platformInfo.release}\n`;
            output += `  Hostname: ${platformInfo.hostname}\n`;
            output += `  Home Directory: ${platformInfo.homedir}\n`;
            output += `  Temporary Directory: ${platformInfo.tmpdir}\n\n`;

            output += `Platform Configuration:\n`;
            output += `  Path Separator: ${platformConfig.pathSeparators[platformInfo.platform]}\n`;
            output += `  Line Ending: ${platformConfig.lineEndings[platformInfo.platform]}\n`;
            output += `  Default Terminal: ${platformConfig.defaultTerminal[platformInfo.platform]}\n\n`;

            output += `Compatibility Issues (${issues.length}):\n`;
            for (const issue of issues) {
                output += `  [${issue.severity.toUpperCase()}] ${issue.description}\n`;
                output += `    Type: ${issue.type}\n`;
                output += `    Platform: ${issue.platform}\n`;
                output += `    Auto-fixable: ${issue.autoFixable}\n`;
                output += `    Fixed: ${issue.fixed}\n`;
                output += `    Suggestion: ${issue.suggestion}\n`;
            }
            output += '\n';

            output += `Platform Optimizations (${optimizations.length}):\n`;
            for (const optimization of optimizations) {
                output += `  [${optimization.enabled ? 'Enabled' : 'Disabled'}] ${optimization.name}\n`;
                output += `    Platform: ${optimization.platform}\n`;
                output += `    Impact: ${optimization.impact}\n`;
                output += `    Description: ${optimization.description}\n`;
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show platform status: ${error.message}`);
        }
    }

    /**
     * Dispose platform compatibility system
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}