/**
 * NoodleCore GitHub API Connectors
 * 
 * Provides comprehensive GitHub API integration for repository management,
 * issue tracking, pull requests, and GitHub Actions workflow management.
 */

import * as vscode from 'vscode';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as path from 'path';
import * as fs from 'fs';
import axios from 'axios';

const execAsync = promisify(exec);

export interface GitHubRepository {
    id: number;
    name: string;
    fullName: string;
    description: string;
    htmlUrl: string;
    cloneUrl: string;
    sshUrl: string;
    defaultBranch: string;
    language: string;
    size: number;
    stargazersCount: number;
    watchersCount: number;
    forksCount: number;
    archived: boolean;
    private: boolean;
    owner: {
        login: string;
        avatarUrl: string;
        url: string;
    };
}

export interface GitHubIssue {
    id: number;
    number: number;
    title: string;
    body: string;
    state: 'open' | 'closed';
    stateReason?: 'completed' | 'not_planned';
    labels: GitHubLabel[];
    assignee?: {
        login: string;
        avatarUrl: string;
        url: string;
    };
    assignees: GitHubUser[];
    milestone?: {
        title: string;
        description: string;
        dueOn: string;
    };
    comments: number;
    createdAt: string;
    updatedAt: string;
    closedAt?: string;
    url: string;
    htmlUrl: string;
}

export interface GitHubPullRequest {
    id: number;
    number: number;
    title: string;
    body: string;
    state: 'open' | 'closed' | 'merged';
    draft: boolean;
    labels: GitHubLabel[];
    assignee?: {
        login: string;
        avatarUrl: string;
        url: string;
    };
    assignees: GitHubUser[];
    milestone?: {
        title: string;
        description: string;
        dueOn: string;
    };
    requestedReviewers: GitHubUser[];
    requestedTeams: any[];
    head: {
        ref: string;
        sha: string;
        repo: GitHubRepository;
    };
    base: {
        ref: string;
        sha: string;
        repo: GitHubRepository;
    };
    comments: number;
    reviewComments: number;
    commits: number;
    additions: number;
    deletions: number;
    changedFiles: number;
    createdAt: string;
    updatedAt: string;
    closedAt?: string;
    mergedAt?: string;
    url: string;
    htmlUrl: string;
}

export interface GitHubWorkflow {
    id: number;
    name: string;
    path: string;
    state: 'enabled' | 'disabled' | 'disabled_inactivity';
    created_at: string;
    updated_at: string;
    url: string;
    html_url: string;
    badge_url: string;
}

export interface GitHubWorkflowRun {
    id: number;
    name: string;
    head_branch: string;
    head_sha: string;
    status: 'queued' | 'in_progress' | 'completed' | 'failure' | 'cancelled' | 'skipped' | 'timed_out';
    conclusion?: 'success' | 'failure' | 'cancelled' | 'skipped' | 'neutral' | 'timed_out' | 'startup_failure';
    url: string;
    html_url: string;
    created_at: string;
    updated_at: string;
    run_number: number;
    event: string;
    workflow_id: number;
}

export interface GitHubUser {
    login: string;
    id: number;
    avatarUrl: string;
    url: string;
    type: 'User' | 'Bot' | 'Organization';
}

export interface GitHubLabel {
    id: number;
    name: string;
    color: string;
    description: string;
    url: string;
}

export interface GitHubRelease {
    id: number;
    tag_name: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    created_at: string;
    published_at: string;
    author: GitHubUser;
    assets: GitHubReleaseAsset[];
}

export interface GitHubReleaseAsset {
    id: number;
    name: string;
    size: number;
    download_count: number;
    created_at: string;
    updated_at: string;
    browser_download_url: string;
    content_type: string;
}

export interface GitHubBranch {
    name: string;
    commit: {
        sha: string;
        url: string;
    };
    protected: boolean;
}

export interface GitHubCollaborator {
    login: string;
    id: number;
    avatarUrl: string;
    url: string;
    permissions: {
        admin: boolean;
        push: boolean;
        pull: boolean;
    };
}

export class GitHubIntegration {
    private workspaceRoot: string;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private githubToken: string;
    private apiBaseUrl: string;
    private repository?: GitHubRepository;
    private octokit?: any;

    constructor(workspaceRoot: string) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle GitHub Integration');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            90
        );
        this.statusBarItem.command = 'noodle.github.showStatus';
        
        this.initializeGitHub();
    }

    /**
     * Initialize GitHub integration and verify authentication
     */
    private async initializeGitHub(): Promise<void> {
        try {
            // Get GitHub token from configuration
            const config = vscode.workspace.getConfiguration('noodle.github');
            this.githubToken = config.get<string>('token', '');
            
            if (!this.githubToken) {
                throw new Error('GitHub token not configured. Please set noodle.github.token in settings.');
            }

            // Initialize Octokit (GitHub API client)
            const { Octokit } = await import('@octokit/rest');
            this.octokit = new Octokit({
                auth: this.githubToken
            });

            // Verify token validity
            await this.octokit.users.getAuthenticated();
            
            this.apiBaseUrl = 'https://api.github.com';
            this.outputChannel.appendLine('GitHub integration initialized successfully');
            
            // Detect repository
            await this.detectRepository();
            
            this.statusBarItem.text = '$(github) GitHub';
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`GitHub initialization failed: ${error.message}`);
        }
    }

    /**
     * Detect current GitHub repository
     */
    private async detectRepository(): Promise<void> {
        try {
            // Check if current directory is a Git repository
            const gitDir = await this.executeGitCommand('rev-parse --git-dir', { silent: true });
            
            // Get remote URL
            const remoteUrl = await this.executeGitCommand('remote get-url origin', { silent: true });
            
            if (remoteUrl) {
                // Extract owner and repo from URL
                const match = remoteUrl.match(/github\.com[\/:](.+?\/.+?)(\.git)?$/);
                if (match) {
                    const [owner, repo] = match[1].split('/');
                    await this.setRepository(owner, repo);
                }
            }
        } catch (error) {
            this.outputChannel.appendLine(`Could not detect GitHub repository: ${error.message}`);
        }
    }

    /**
     * Set repository context
     */
    public async setRepository(owner: string, repo: string): Promise<void> {
        try {
            const response = await this.octokit.repos.get({
                owner,
                repo
            });
            
            this.repository = response.data;
            this.outputChannel.appendLine(`Set repository context: ${this.repository.fullName}`);
            
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to set repository: ${error.message}`);
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
        const fullCommand = `git ${command}`;
        
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
     * Update status bar with GitHub information
     */
    private updateStatusBar(): void {
        if (!this.repository) {
            this.statusBarItem.text = '$(github) GitHub';
            this.statusBarItem.tooltip = 'GitHub Integration';
            return;
        }

        let text = `$(github) ${this.repository.name}`;
        
        if (this.repository.stargazersCount > 0) {
            text += ` ⭐${this.repository.stargazersCount}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `${this.repository.fullName}\nStars: ${this.repository.stargazersCount}\nLanguage: ${this.repository.language}`;
    }

    /**
     * Get current repository
     */
    public getRepository(): GitHubRepository | undefined {
        return this.repository;
    }

    /**
     * Get repositories for authenticated user
     */
    public async getRepositories(): Promise<GitHubRepository[]> {
        try {
            const response = await this.octokit.repos.listForAuthenticatedUser();
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get repositories: ${error.message}`);
        }
    }

    /**
     * Get repository issues
     */
    public async getIssues(state: 'open' | 'closed' | 'all' = 'open'): Promise<GitHubIssue[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.issues.listForRepo({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                state
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get issues: ${error.message}`);
        }
    }

    /**
     * Create a new issue
     */
    public async createIssue(title: string, body: string, labels?: string[]): Promise<GitHubIssue> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.issues.create({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                title,
                body,
                labels
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create issue: ${error.message}`);
        }
    }

    /**
     * Update an issue
     */
    public async updateIssue(
        issueNumber: number,
        updates: {
            title?: string;
            body?: string;
            state?: 'open' | 'closed';
            labels?: string[];
            assignees?: string[];
        }
    ): Promise<GitHubIssue> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.issues.update({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                issue_number: issueNumber,
                ...updates
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to update issue: ${error.message}`);
        }
    }

    /**
     * Get pull requests
     */
    public async getPullRequests(state: 'open' | 'closed' | 'all' = 'open'): Promise<GitHubPullRequest[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.pulls.list({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                state
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get pull requests: ${error.message}`);
        }
    }

    /**
     * Create a new pull request
     */
    public async createPullRequest(
        title: string,
        head: string,
        base: string,
        body?: string
    ): Promise<GitHubPullRequest> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.pulls.create({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                title,
                head,
                base,
                body
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create pull request: ${error.message}`);
        }
    }

    /**
     * Update a pull request
     */
    public async updatePullRequest(
        pullNumber: number,
        updates: {
            title?: string;
            body?: string;
            state?: 'open' | 'closed' | 'merged';
            base?: string;
        }
    ): Promise<GitHubPullRequest> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.pulls.update({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                pull_number: pullNumber,
                ...updates
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to update pull request: ${error.message}`);
        }
    }

    /**
     * Get workflows
     */
    public async getWorkflows(): Promise<GitHubWorkflow[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.actions.listRepoWorkflows({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data.workflows;
        } catch (error) {
            throw new Error(`Failed to get workflows: ${error.message}`);
        }
    }

    /**
     * Get workflow runs
     */
    public async getWorkflowRuns(options?: {
        workflow_id?: number;
        status?: 'queued' | 'in_progress' | 'completed' | 'failure' | 'cancelled' | 'skipped' | 'timed_out';
        branch?: string;
    }): Promise<GitHubWorkflowRun[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.actions.listWorkflowRuns({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                ...options
            });
            return response.data.workflow_runs;
        } catch (error) {
            throw new Error(`Failed to get workflow runs: ${error.message}`);
        }
    }

    /**
     * Trigger a workflow run
     */
    public async triggerWorkflow(workflowId: number, inputs?: { [key: string]: any }): Promise<void> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            await this.octokit.actions.createWorkflowDispatch({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                workflow_id: workflowId,
                inputs
            });
        } catch (error) {
            throw new Error(`Failed to trigger workflow: ${error.message}`);
        }
    }

    /**
     * Get releases
     */
    public async getReleases(): Promise<GitHubRelease[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.repos.listReleases({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get releases: ${error.message}`);
        }
    }

    /**
     * Create a new release
     */
    public async createRelease(
        tag_name: string,
        name: string,
        body: string,
        draft: boolean = false,
        prerelease: boolean = false
    ): Promise<GitHubRelease> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.repos.createRelease({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                tag_name,
                name,
                body,
                draft,
                prerelease
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create release: ${error.message}`);
        }
    }

    /**
     * Get branches
     */
    public async getBranches(): Promise<GitHubBranch[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.repos.listBranches({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get branches: ${error.message}`);
        }
    }

    /**
     * Get collaborators
     */
    public async getCollaborators(): Promise<GitHubCollaborator[]> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const response = await this.octokit.repos.listCollaborators({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get collaborators: ${error.message}`);
        }
    }

    /**
     * Add collaborator to repository
     */
    public async addCollaborator(username: string, permission: 'pull' | 'push' | 'admin' = 'pull'): Promise<void> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            await this.octokit.repos.addCollaborator({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                username,
                permission
            });
        } catch (error) {
            throw new Error(`Failed to add collaborator: ${error.message}`);
        }
    }

    /**
     * Remove collaborator from repository
     */
    public async removeCollaborator(username: string): Promise<void> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            await this.octokit.repos.removeCollaborator({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                username
            });
        } catch (error) {
            throw new Error(`Failed to remove collaborator: ${error.message}`);
        }
    }

    /**
     * Get repository statistics
     */
    public async getRepositoryStats(): Promise<{
        stars: number;
        forks: number;
        issues: number;
        pullRequests: number;
        contributors: number;
        releases: number;
    }> {
        if (!this.repository) {
            throw new Error('No repository context set');
        }

        try {
            const [issues, pullRequests, releases, collaborators] = await Promise.all([
                this.getIssues('all'),
                this.getPullRequests('all'),
                this.getReleases(),
                this.getCollaborators()
            ]);

            return {
                stars: this.repository.stargazersCount,
                forks: this.repository.forksCount,
                issues: issues.length,
                pullRequests: pullRequests.length,
                contributors: collaborators.length,
                releases: releases.length
            };
        } catch (error) {
            throw new Error(`Failed to get repository stats: ${error.message}`);
        }
    }

    /**
     * Show GitHub status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            if (!this.repository) {
                this.outputChannel.appendLine('No GitHub repository context set');
                this.outputChannel.show();
                return;
            }

            const stats = await this.getRepositoryStats();
            const issues = await this.getIssues('open');
            const pullRequests = await this.getPullRequests('open');
            const workflows = await this.getWorkflows();

            let output = `GitHub Repository Status\n`;
            output += `========================\n\n`;
            output += `Repository: ${this.repository.fullName}\n`;
            output += `Description: ${this.repository.description}\n`;
            output += `Language: ${this.repository.language}\n`;
            output += `Default Branch: ${this.repository.defaultBranch}\n\n`;

            output += `Statistics:\n`;
            output += `  Stars: ${stats.stars}\n`;
            output += `  Forks: ${stats.forks}\n`;
            output += `  Open Issues: ${stats.issues}\n`;
            output += `  Open PRs: ${stats.pullRequests}\n`;
            output += `  Contributors: ${stats.contributors}\n`;
            output += `  Releases: ${stats.releases}\n\n`;

            output += `Open Issues (${issues.length}):\n`;
            for (const issue of issues.slice(0, 5)) {
                output += `  #${issue.number}: ${issue.title} (${issue.state})\n`;
            }
            if (issues.length > 5) {
                output += `  ... and ${issues.length - 5} more\n`;
            }
            output += '\n';

            output += `Open Pull Requests (${pullRequests.length}):\n`;
            for (const pr of pullRequests.slice(0, 5)) {
                output += `  #${pr.number}: ${pr.title} (${pr.state})\n`;
            }
            if (pullRequests.length > 5) {
                output += `  ... and ${pullRequests.length - 5} more\n`;
            }
            output += '\n';

            output += `Workflows (${workflows.length}):\n`;
            for (const workflow of workflows) {
                output += `  ${workflow.name}: ${workflow.state}\n`;
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show GitHub status: ${error.message}`);
        }
    }

    /**
     * Dispose GitHub integration
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}