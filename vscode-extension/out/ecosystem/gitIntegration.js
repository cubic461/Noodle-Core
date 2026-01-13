"use strict";
/**
 * NoodleCore Git Integration
 *
 * Provides comprehensive Git version control integration within the VS Code extension.
 * Supports common Git operations, branch management, and repository status monitoring.
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
exports.GitIntegration = void 0;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
const util_1 = require("util");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
class GitIntegration {
    constructor(workspaceRoot) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Git Integration');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 100);
        this.statusBarItem.command = 'noodle.git.showStatus';
        this.statusBarItem.show();
        this.initializeGitPath();
    }
    /**
     * Initialize Git path and verify installation
     */
    async initializeGitPath() {
        try {
            const config = vscode.workspace.getConfiguration('git');
            this.gitPath = config.get('path', 'git');
            // Verify Git installation
            await this.executeGitCommand('--version');
            this.outputChannel.appendLine('Git integration initialized successfully');
        }
        catch (error) {
            throw new Error(`Git not found or not accessible: ${error.message}`);
        }
    }
    /**
     * Execute Git command with proper error handling
     */
    async executeGitCommand(command, options = {}) {
        const cwd = options.cwd || this.workspaceRoot;
        const fullCommand = `${this.gitPath} ${command}`;
        if (!options.silent) {
            this.outputChannel.appendLine(`> ${fullCommand}`);
        }
        try {
            const { stdout, stderr } = await execAsync(fullCommand, { cwd });
            if (stderr && !options.silent) {
                this.outputChannel.appendLine(`Warning: ${stderr}`);
            }
            return stdout.trim();
        }
        catch (error) {
            const errorMessage = `Git command failed: ${fullCommand}\n${error.message}`;
            this.outputChannel.appendLine(errorMessage);
            throw new Error(errorMessage);
        }
    }
    /**
     * Check if current directory is a Git repository
     */
    async isGitRepository() {
        try {
            await this.executeGitCommand('rev-parse --git-dir', { silent: true });
            return true;
        }
        catch {
            return false;
        }
    }
    /**
     * Get current Git status
     */
    async getStatus() {
        try {
            const statusOutput = await this.executeGitCommand('status --porcelain=2 --branch');
            const branchOutput = await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            const status = this.parseGitStatus(statusOutput);
            status.branch = branchOutput;
            this.updateStatusBar(status);
            return status;
        }
        catch (error) {
            throw new Error(`Failed to get Git status: ${error.message}`);
        }
    }
    /**
     * Parse Git status output
     */
    parseGitStatus(statusOutput) {
        const lines = statusOutput.split('\n');
        const status = {
            branch: '',
            ahead: 0,
            behind: 0,
            staged: 0,
            modified: 0,
            untracked: 0,
            conflicts: 0,
            clean: true
        };
        for (const line of lines) {
            if (line.startsWith('# branch.ab')) {
                const match = line.match(/a(\d+)\s+b(\d+)/);
                if (match) {
                    status.ahead = parseInt(match[1]);
                    status.behind = parseInt(match[2]);
                }
            }
            else if (line.startsWith('# branch.head')) {
                status.branch = line.split(' ').pop() || '';
            }
            else if (line[0] === '1' || line[0] === '2') {
                const indexStatus = line[14];
                const worktreeStatus = line[15];
                if (indexStatus !== '.') {
                    status.staged++;
                }
                if (worktreeStatus !== '.') {
                    status.modified++;
                }
                if (worktreeStatus === 'U' || indexStatus === 'U') {
                    status.conflicts++;
                }
            }
            else if (line.startsWith('?')) {
                status.untracked++;
            }
        }
        status.clean = status.staged === 0 &&
            status.modified === 0 &&
            status.untracked === 0 &&
            status.conflicts === 0;
        return status;
    }
    /**
     * Update status bar with Git information
     */
    updateStatusBar(status) {
        let text = `$(git-branch) ${status.branch}`;
        if (status.ahead > 0) {
            text += ` ↑${status.ahead}`;
        }
        if (status.behind > 0) {
            text += ` ↓${status.behind}`;
        }
        if (!status.clean) {
            const changes = status.staged + status.modified + status.untracked + status.conflicts;
            text += ` •${changes}`;
        }
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = this.getStatusTooltip(status);
    }
    /**
     * Generate tooltip for status bar
     */
    getStatusTooltip(status) {
        let tooltip = `Branch: ${status.branch}\n`;
        if (status.ahead > 0) {
            tooltip += `Ahead: ${status.ahead} commits\n`;
        }
        if (status.behind > 0) {
            tooltip += `Behind: ${status.behind} commits\n`;
        }
        tooltip += `Staged: ${status.staged}\n`;
        tooltip += `Modified: ${status.modified}\n`;
        tooltip += `Untracked: ${status.untracked}\n`;
        tooltip += `Conflicts: ${status.conflicts}\n`;
        tooltip += `Status: ${status.clean ? 'Clean' : 'Dirty'}`;
        return tooltip;
    }
    /**
     * Get all branches
     */
    async getBranches() {
        try {
            const branchOutput = await this.executeGitCommand('branch -vv');
            const currentBranch = await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            return this.parseBranches(branchOutput, currentBranch);
        }
        catch (error) {
            throw new Error(`Failed to get branches: ${error.message}`);
        }
    }
    /**
     * Parse branch output
     */
    parseBranches(branchOutput, currentBranch) {
        const lines = branchOutput.split('\n');
        const branches = [];
        for (const line of lines) {
            if (!line.trim())
                continue;
            const isCurrent = line.startsWith('*');
            const name = line.replace(/^\*\s*/, '').split(/\s+/)[0];
            // Extract remote and ahead/behind info
            const remoteMatch = line.match(/\[([^\]]+)\]/);
            let remote = '';
            let ahead = 0;
            let behind = 0;
            if (remoteMatch) {
                const remoteInfo = remoteMatch[1];
                const parts = remoteInfo.split(':');
                remote = parts[0];
                if (parts.length > 1) {
                    const aheadBehind = parts[1];
                    const aheadMatch = aheadBehind.match(/ahead (\d+)/);
                    const behindMatch = aheadBehind.match(/behind (\d+)/);
                    if (aheadMatch)
                        ahead = parseInt(aheadMatch[1]);
                    if (behindMatch)
                        behind = parseInt(behindMatch[1]);
                }
            }
            branches.push({
                name,
                current: isCurrent,
                remote,
                ahead,
                behind
            });
        }
        return branches;
    }
    /**
     * Create new branch
     */
    async createBranch(branchName, checkout = true) {
        try {
            const command = checkout ? `checkout -b ${branchName}` : `branch ${branchName}`;
            await this.executeGitCommand(command);
            vscode.window.showInformationMessage(`Branch '${branchName}' created${checkout ? ' and checked out' : ''}`);
        }
        catch (error) {
            throw new Error(`Failed to create branch: ${error.message}`);
        }
    }
    /**
     * Switch to branch
     */
    async checkoutBranch(branchName) {
        try {
            await this.executeGitCommand(`checkout ${branchName}`);
            vscode.window.showInformationMessage(`Switched to branch '${branchName}'`);
        }
        catch (error) {
            throw new Error(`Failed to checkout branch: ${error.message}`);
        }
    }
    /**
     * Delete branch
     */
    async deleteBranch(branchName, force = false) {
        try {
            const command = `branch ${force ? '-D' : '-d'} ${branchName}`;
            await this.executeGitCommand(command);
            vscode.window.showInformationMessage(`Branch '${branchName}' deleted${force ? ' (forced)' : ''}`);
        }
        catch (error) {
            throw new Error(`Failed to delete branch: ${error.message}`);
        }
    }
    /**
     * Get commit history
     */
    async getCommitHistory(limit = 50) {
        try {
            const format = '--pretty=format:%H|%an|%ad|%s|';
            const command = `log ${format} --name-only --max-count=${limit}`;
            const output = await this.executeGitCommand(command);
            return this.parseCommitHistory(output);
        }
        catch (error) {
            throw new Error(`Failed to get commit history: ${error.message}`);
        }
    }
    /**
     * Parse commit history
     */
    parseCommitHistory(output) {
        const lines = output.split('\n');
        const commits = [];
        let currentCommit = null;
        for (const line of lines) {
            if (line.includes('|')) {
                // Save previous commit if exists
                if (currentCommit) {
                    commits.push(currentCommit);
                }
                // Parse new commit
                const parts = line.split('|');
                currentCommit = {
                    hash: parts[0] || '',
                    author: parts[1] || '',
                    date: parts[2] || '',
                    message: parts[3] || '',
                    files: []
                };
            }
            else if (currentCommit && line.trim()) {
                currentCommit.files.push(line.trim());
            }
        }
        // Add last commit
        if (currentCommit) {
            commits.push(currentCommit);
        }
        return commits;
    }
    /**
     * Stage files
     */
    async stageFiles(files) {
        try {
            const fileList = files.join(' ');
            await this.executeGitCommand(`add ${fileList}`);
            vscode.window.showInformationMessage(`${files.length} file(s) staged`);
        }
        catch (error) {
            throw new Error(`Failed to stage files: ${error.message}`);
        }
    }
    /**
     * Unstage files
     */
    async unstageFiles(files) {
        try {
            const fileList = files.join(' ');
            await this.executeGitCommand(`reset HEAD ${fileList}`);
            vscode.window.showInformationMessage(`${files.length} file(s) unstaged`);
        }
        catch (error) {
            throw new Error(`Failed to unstage files: ${error.message}`);
        }
    }
    /**
     * Commit changes
     */
    async commit(message) {
        try {
            await this.executeGitCommand(`commit -m "${message}"`);
            vscode.window.showInformationMessage('Changes committed successfully');
        }
        catch (error) {
            throw new Error(`Failed to commit: ${error.message}`);
        }
    }
    /**
     * Push changes to remote
     */
    async push(remote = 'origin', branch) {
        try {
            const branchName = branch || await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            const command = `push ${remote} ${branchName}`;
            await this.executeGitCommand(command);
            vscode.window.showInformationMessage(`Pushed to ${remote}/${branchName}`);
        }
        catch (error) {
            throw new Error(`Failed to push: ${error.message}`);
        }
    }
    /**
     * Pull changes from remote
     */
    async pull(remote = 'origin', branch) {
        try {
            const branchName = branch || await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            const command = `pull ${remote} ${branchName}`;
            await this.executeGitCommand(command);
            vscode.window.showInformationMessage(`Pulled from ${remote}/${branchName}`);
        }
        catch (error) {
            throw new Error(`Failed to pull: ${error.message}`);
        }
    }
    /**
     * Get remotes
     */
    async getRemotes() {
        try {
            const output = await this.executeGitCommand('remote -v');
            return this.parseRemotes(output);
        }
        catch (error) {
            throw new Error(`Failed to get remotes: ${error.message}`);
        }
    }
    /**
     * Parse remotes output
     */
    parseRemotes(output) {
        const lines = output.split('\n');
        const remotes = [];
        const remoteMap = new Map();
        for (const line of lines) {
            if (!line.trim())
                continue;
            const match = line.match(/^(\S+)\s+(\S+)\s+\((\w+)\)$/);
            if (!match)
                continue;
            const name = match[1];
            const url = match[2];
            const type = match[3]; // fetch or push
            if (!remoteMap.has(name)) {
                remoteMap.set(name, {
                    name,
                    url,
                    fetchUrl: type === 'fetch' ? url : '',
                    pushUrl: type === 'push' ? url : ''
                });
            }
            else {
                const remote = remoteMap.get(name);
                if (type === 'fetch') {
                    remote.fetchUrl = url;
                }
                else if (type === 'push') {
                    remote.pushUrl = url;
                }
            }
        }
        return Array.from(remoteMap.values());
    }
    /**
     * Show Git status in output channel
     */
    async showStatus() {
        try {
            const status = await this.getStatus();
            const statusText = this.formatStatusForDisplay(status);
            this.outputChannel.clear();
            this.outputChannel.appendLine(statusText);
            this.outputChannel.show();
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show Git status: ${error.message}`);
        }
    }
    /**
     * Format status for display
     */
    formatStatusForDisplay(status) {
        let output = `Git Repository Status\n`;
        output += `====================\n\n`;
        output += `Branch: ${status.branch}\n`;
        output += `Status: ${status.clean ? 'Clean' : 'Dirty'}\n\n`;
        if (status.ahead > 0 || status.behind > 0) {
            output += `Remote Status:\n`;
            if (status.ahead > 0)
                output += `  Ahead: ${status.ahead} commits\n`;
            if (status.behind > 0)
                output += `  Behind: ${status.behind} commits\n`;
            output += '\n';
        }
        if (!status.clean) {
            output += `Changes:\n`;
            if (status.staged > 0)
                output += `  Staged: ${status.staged}\n`;
            if (status.modified > 0)
                output += `  Modified: ${status.modified}\n`;
            if (status.untracked > 0)
                output += `  Untracked: ${status.untracked}\n`;
            if (status.conflicts > 0)
                output += `  Conflicts: ${status.conflicts}\n`;
        }
        return output;
    }
    /**
     * Dispose Git integration
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.GitIntegration = GitIntegration;
//# sourceMappingURL=gitIntegration.js.map