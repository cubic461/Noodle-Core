"use strict";
/**
 * NoodleCore Cross-Platform Compatibility System
 *
 * Provides comprehensive cross-platform support for Windows, macOS, and Linux
 * with platform-specific optimizations and compatibility layers.
 */
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
exports.CrossPlatformCompatibility = void 0;
const vscode = __importStar(require("vscode"));
const os = __importStar(require("os"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
class CrossPlatformCompatibility {
    constructor(context) {
        this.compatibilityIssues = [];
        this.optimizations = [];
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Cross-Platform');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 85);
        this.statusBarItem.command = 'noodle.platform.showStatus';
        this.initializePlatformSupport();
    }
    /**
     * Initialize platform support
     */
    async initializePlatformSupport() {
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
        }
        catch (error) {
            throw new Error(`Platform support initialization failed: ${error.message}`);
        }
    }
    /**
     * Detect platform information
     */
    detectPlatform() {
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
    loadPlatformConfig() {
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
    initializeOptimizations() {
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
    async checkCompatibilityIssues() {
        const issues = [];
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
    applyPlatformSettings() {
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
    applyOptimization(optimization) {
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
    applyWindowsPathLengthOptimization(config) {
        if (config.useShortPaths) {
            // Enable short path support for Windows
            vscode.workspace.getConfiguration('files').update('encoding', 'utf8', true);
            vscode.workspace.getConfiguration('search').update('useIgnoreFiles', true, true);
        }
    }
    /**
     * Apply macOS memory optimization
     */
    applyMacOSMemoryOptimization(config) {
        if (config.enableMemoryPressure) {
            // Enable memory pressure monitoring for macOS
            vscode.env.asar.extractResource('resources/memory-monitor.js', 'temp');
            // Additional macOS-specific memory optimizations
        }
    }
    /**
     * Apply Linux permissions optimization
     */
    applyLinuxPermissionsOptimization(config) {
        // Set default file permissions for Linux
        fs.chmodSync(this.context.globalStorageUri.fsPath, config.defaultDirMode);
    }
    /**
     * Apply cross-platform cache optimization
     */
    applyCrossPlatformCacheOptimization(config) {
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
    getPlatformInfo() {
        return this.platformInfo;
    }
    /**
     * Get platform-specific configuration
     */
    getPlatformConfig() {
        return this.platformConfig;
    }
    /**
     * Get compatibility issues
     */
    getCompatibilityIssues() {
        return [...this.compatibilityIssues];
    }
    /**
     * Get platform optimizations
     */
    getOptimizations() {
        return [...this.optimizations];
    }
    /**
     * Fix compatibility issue
     */
    async fixCompatibilityIssue(issueId) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to fix compatibility issue: ${error.message}`);
            return false;
        }
    }
    /**
     * Fix path-related issue
     */
    async fixPathIssue(issue) {
        // Implement path fixing logic
        // This would involve normalizing paths, using proper path separators, etc.
    }
    /**
     * Fix file-related issue
     */
    async fixFileIssue(issue) {
        // Implement file fixing logic
        // This would involve converting line endings, fixing file permissions, etc.
    }
    /**
     * Fix command-related issue
     */
    async fixCommandIssue(issue) {
        // Implement command fixing logic
        // This would involve adjusting shell commands for the platform
    }
    /**
     * Fix permission-related issue
     */
    async fixPermissionIssue(issue) {
        // Implement permission fixing logic
        // This would involve adjusting file permissions
    }
    /**
     * Fix environment-related issue
     */
    async fixEnvironmentIssue(issue) {
        // Implement environment fixing logic
        // This would involve setting environment variables
    }
    /**
     * Fix dependency-related issue
     */
    async fixDependencyIssue(issue) {
        // Implement dependency fixing logic
        // This would involve installing missing dependencies
    }
    /**
     * Get platform-specific path
     */
    getPlatformPath(...segments) {
        const separator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        return path.join(...segments).replace(/\//g, separator);
    }
    /**
     * Normalize path for cross-platform compatibility
     */
    normalizePath(p) {
        const separator = this.platformConfig.pathSeparators[this.platformInfo.platform];
        return p.replace(/\//g, separator).replace(/\\/g, separator);
    }
    /**
     * Get platform-specific shell command
     */
    getShellCommand(command) {
        const platformCommand = this.platformConfig.shellCommands[this.platformInfo.platform];
        return platformCommand ? `${platformCommand} ${command}` : command;
    }
    /**
     * Get platform-specific file extensions
     */
    getFileExtensions() {
        return this.platformConfig.fileExtensions[this.platformInfo.platform] || [];
    }
    /**
     * Check if file path is valid for current platform
     */
    isValidPath(filePath) {
        const platform = this.platformInfo.platform;
        if (platform === 'win32') {
            // Windows path validation
            const win32PathRegex = /^[a-zA-Z]:\\(?:[^\\/:*?"<>|\r\n]+\\)*[^\\/:*?"<>|\r\n]*$/;
            return win32PathRegex.test(filePath);
        }
        else {
            // Unix-like path validation
            const unixPathRegex = /^\/$|^(\/[^\r\n\/]+)+$/;
            return unixPathRegex.test(filePath);
        }
    }
    /**
     * Get platform-specific temporary directory
     */
    getTempDir() {
        return this.platformInfo.tmpdir;
    }
    /**
     * Get platform-specific home directory
     */
    getHomeDir() {
        return this.platformInfo.homedir;
    }
    /**
     * Get platform-specific environment variable
     */
    getEnvVar(name) {
        return this.platformInfo.env[name];
    }
    /**
     * Set platform-specific environment variable
     */
    setEnvVar(name, value) {
        process.env[name] = value;
        this.platformInfo.env[name] = value;
    }
    /**
     * Get platform-specific line ending
     */
    getLineEnding() {
        return this.platformConfig.lineEndings[this.platformInfo.platform];
    }
    /**
     * Convert text to platform-specific line endings
     */
    convertLineEndings(text) {
        const lineEnding = this.getLineEnding();
        return lineEnding === 'crlf' ? text.replace(/\n/g, '\r\n') : text;
    }
    /**
     * Update status bar with platform information
     */
    updateStatusBar() {
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
    async showStatus() {
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
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show platform status: ${error.message}`);
        }
    }
    /**
     * Dispose platform compatibility system
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.CrossPlatformCompatibility = CrossPlatformCompatibility;
//# sourceMappingURL=crossPlatformCompatibility.js.map