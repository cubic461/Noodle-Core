/**
 * NoodleCore Git Integration
 * 
 * Provides comprehensive Git version control integration within the VS Code extension.
 * Supports common Git operations, branch management, and repository status monitoring.
 */

import * as vscode from 'vscode';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as path from 'path';
import * as fs from 'fs';

const execAsync = promisify(exec);

export interface GitStatus {
    branch: string;
    ahead: number;
    behind: number;
    staged: number;
    modified: number;
    untracked: number;
    conflicts: number;
    clean: boolean;
}

export interface GitCommit {
    hash: string;
    author: string;
    date: string;
    message: string;
    files: string[];
}

export interface GitBranch {
    name: string;
    current: boolean;
    remote: string;
    ahead: number;
    behind: number;
}

export interface GitRemote {
    name: string;
    url: string;
    fetchUrl: string;
    pushUrl: string;
}

export class GitIntegration {
    private workspaceRoot: string;
    private gitPath: string;
    private statusBarItem: vscode.StatusBarItem;
    private outputChannel: vscode.OutputChannel;

    constructor(workspaceRoot: string) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Git Integration');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            100
        );
        this.statusBarItem.command = 'noodle.git.showStatus';
        this.statusBarItem.show();
        
        this.initializeGitPath();
    }

    /**
     * Initialize Git path and verify installation
     */
    private async initializeGitPath(): Promise<void> {
        try {
            const config = vscode.workspace.getConfiguration('git');
            this.gitPath = config.get<string>('path', 'git');
            
            // Verify Git installation
            await this.executeGitCommand('--version');
            this.outputChannel.appendLine('Git integration initialized successfully');
        } catch (error) {
            throw new Error(`Git not found or not accessible: ${error.message}`);
        }
    }

    /**
     * Execute Git command with proper error handling
     */
    private async executeGitCommand(
        command: string,
        options: { cwd?: string; silent?: boolean } = {}
    ): Promise<string> {
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
        } catch (error) {
            const errorMessage = `Git command failed: ${fullCommand}\n${error.message}`;
            this.outputChannel.appendLine(errorMessage);
            throw new Error(errorMessage);
        }
    }

    /**
     * Check if current directory is a Git repository
     */
    public async isGitRepository(): Promise<boolean> {
        try {
            await this.executeGitCommand('rev-parse --git-dir', { silent: true });
            return true;
        } catch {
            return false;
        }
    }

    /**
     * Get current Git status
     */
    public async getStatus(): Promise<GitStatus> {
        try {
            const statusOutput = await this.executeGitCommand('status --porcelain=2 --branch');
            const branchOutput = await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            
            const status = this.parseGitStatus(statusOutput);
            status.branch = branchOutput;
            
            this.updateStatusBar(status);
            return status;
        } catch (error) {
            throw new Error(`Failed to get Git status: ${error.message}`);
        }
    }

    /**
     * Parse Git status output
     */
    private parseGitStatus(statusOutput: string): GitStatus {
        const lines = statusOutput.split('\n');
        const status: GitStatus = {
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
            } else if (line.startsWith('# branch.head')) {
                status.branch = line.split(' ').pop() || '';
            } else if (line[0] === '1' || line[0] === '2') {
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
            } else if (line.startsWith('?')) {
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
    private updateStatusBar(status: GitStatus): void {
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
    private getStatusTooltip(status: GitStatus): string {
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
    public async getBranches(): Promise<GitBranch[]> {
        try {
            const branchOutput = await this.executeGitCommand('branch -vv');
            const currentBranch = await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            
            return this.parseBranches(branchOutput, currentBranch);
        } catch (error) {
            throw new Error(`Failed to get branches: ${error.message}`);
        }
    }

    /**
     * Parse branch output
     */
    private parseBranches(branchOutput: string, currentBranch: string): GitBranch[] {
        const lines = branchOutput.split('\n');
        const branches: GitBranch[] = [];

        for (const line of lines) {
            if (!line.trim()) continue;

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
                    
                    if (aheadMatch) ahead = parseInt(aheadMatch[1]);
                    if (behindMatch) behind = parseInt(behindMatch[1]);
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
    public async createBranch(branchName: string, checkout: boolean = true): Promise<void> {
        try {
            const command = checkout ? `checkout -b ${branchName}` : `branch ${branchName}`;
            await this.executeGitCommand(command);
            
            vscode.window.showInformationMessage(
                `Branch '${branchName}' created${checkout ? ' and checked out' : ''}`
            );
        } catch (error) {
            throw new Error(`Failed to create branch: ${error.message}`);
        }
    }

    /**
     * Switch to branch
     */
    public async checkoutBranch(branchName: string): Promise<void> {
        try {
            await this.executeGitCommand(`checkout ${branchName}`);
            vscode.window.showInformationMessage(`Switched to branch '${branchName}'`);
        } catch (error) {
            throw new Error(`Failed to checkout branch: ${error.message}`);
        }
    }

    /**
     * Delete branch
     */
    public async deleteBranch(branchName: string, force: boolean = false): Promise<void> {
        try {
            const command = `branch ${force ? '-D' : '-d'} ${branchName}`;
            await this.executeGitCommand(command);
            
            vscode.window.showInformationMessage(
                `Branch '${branchName}' deleted${force ? ' (forced)' : ''}`
            );
        } catch (error) {
            throw new Error(`Failed to delete branch: ${error.message}`);
        }
    }

    /**
     * Get commit history
     */
    public async getCommitHistory(limit: number = 50): Promise<GitCommit[]> {
        try {
            const format = '--pretty=format:%H|%an|%ad|%s|';
            const command = `log ${format} --name-only --max-count=${limit}`;
            const output = await this.executeGitCommand(command);
            
            return this.parseCommitHistory(output);
        } catch (error) {
            throw new Error(`Failed to get commit history: ${error.message}`);
        }
    }

    /**
     * Parse commit history
     */
    private parseCommitHistory(output: string): GitCommit[] {
        const lines = output.split('\n');
        const commits: GitCommit[] = [];
        let currentCommit: Partial<GitCommit> | null = null;

        for (const line of lines) {
            if (line.includes('|')) {
                // Save previous commit if exists
                if (currentCommit) {
                    commits.push(currentCommit as GitCommit);
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
            } else if (currentCommit && line.trim()) {
                currentCommit.files!.push(line.trim());
            }
        }

        // Add last commit
        if (currentCommit) {
            commits.push(currentCommit as GitCommit);
        }

        return commits;
    }

    /**
     * Stage files
     */
    public async stageFiles(files: string[]): Promise<void> {
        try {
            const fileList = files.join(' ');
            await this.executeGitCommand(`add ${fileList}`);
            
            vscode.window.showInformationMessage(
                `${files.length} file(s) staged`
            );
        } catch (error) {
            throw new Error(`Failed to stage files: ${error.message}`);
        }
    }

    /**
     * Unstage files
     */
    public async unstageFiles(files: string[]): Promise<void> {
        try {
            const fileList = files.join(' ');
            await this.executeGitCommand(`reset HEAD ${fileList}`);
            
            vscode.window.showInformationMessage(
                `${files.length} file(s) unstaged`
            );
        } catch (error) {
            throw new Error(`Failed to unstage files: ${error.message}`);
        }
    }

    /**
     * Commit changes
     */
    public async commit(message: string): Promise<void> {
        try {
            await this.executeGitCommand(`commit -m "${message}"`);
            vscode.window.showInformationMessage('Changes committed successfully');
        } catch (error) {
            throw new Error(`Failed to commit: ${error.message}`);
        }
    }

    /**
     * Push changes to remote
     */
    public async push(remote: string = 'origin', branch?: string): Promise<void> {
        try {
            const branchName = branch || await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            const command = `push ${remote} ${branchName}`;
            await this.executeGitCommand(command);
            
            vscode.window.showInformationMessage(
                `Pushed to ${remote}/${branchName}`
            );
        } catch (error) {
            throw new Error(`Failed to push: ${error.message}`);
        }
    }

    /**
     * Pull changes from remote
     */
    public async pull(remote: string = 'origin', branch?: string): Promise<void> {
        try {
            const branchName = branch || await this.executeGitCommand('rev-parse --abbrev-ref HEAD');
            const command = `pull ${remote} ${branchName}`;
            await this.executeGitCommand(command);
            
            vscode.window.showInformationMessage(
                `Pulled from ${remote}/${branchName}`
            );
        } catch (error) {
            throw new Error(`Failed to pull: ${error.message}`);
        }
    }

    /**
     * Get remotes
     */
    public async getRemotes(): Promise<GitRemote[]> {
        try {
            const output = await this.executeGitCommand('remote -v');
            return this.parseRemotes(output);
        } catch (error) {
            throw new Error(`Failed to get remotes: ${error.message}`);
        }
    }

    /**
     * Parse remotes output
     */
    private parseRemotes(output: string): GitRemote[] {
        const lines = output.split('\n');
        const remotes: GitRemote[] = [];
        const remoteMap = new Map<string, GitRemote>();

        for (const line of lines) {
            if (!line.trim()) continue;

            const match = line.match(/^(\S+)\s+(\S+)\s+\((\w+)\)$/);
            if (!match) continue;

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
            } else {
                const remote = remoteMap.get(name)!;
                if (type === 'fetch') {
                    remote.fetchUrl = url;
                } else if (type === 'push') {
                    remote.pushUrl = url;
                }
            }
        }

        return Array.from(remoteMap.values());
    }

    /**
     * Show Git status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const status = await this.getStatus();
            const statusText = this.formatStatusForDisplay(status);
            
            this.outputChannel.clear();
            this.outputChannel.appendLine(statusText);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show Git status: ${error.message}`);
        }
    }

    /**
     * Format status for display
     */
    private formatStatusForDisplay(status: GitStatus): string {
        let output = `Git Repository Status\n`;
        output += `====================\n\n`;
        output += `Branch: ${status.branch}\n`;
        output += `Status: ${status.clean ? 'Clean' : 'Dirty'}\n\n`;

        if (status.ahead > 0 || status.behind > 0) {
            output += `Remote Status:\n`;
            if (status.ahead > 0) output += `  Ahead: ${status.ahead} commits\n`;
            if (status.behind > 0) output += `  Behind: ${status.behind} commits\n`;
            output += '\n';
        }

        if (!status.clean) {
            output += `Changes:\n`;
            if (status.staged > 0) output += `  Staged: ${status.staged}\n`;
            if (status.modified > 0) output += `  Modified: ${status.modified}\n`;
            if (status.untracked > 0) output += `  Untracked: ${status.untracked}\n`;
            if (status.conflicts > 0) output += `  Conflicts: ${status.conflicts}\n`;
        }

        return output;
    }

    /**
     * Dispose Git integration
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}