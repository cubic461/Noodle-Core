/**
 * NoodleCore GitHub Integration
 * 
 * Provides comprehensive GitHub API integration for repository management,
 * issue tracking, pull requests, and collaboration features.
 */

import * as vscode from 'vscode';
import axios, { AxiosInstance, AxiosResponse } from 'axios';
import { GitIntegration } from './gitIntegration';

export interface GitHubRepository {
    id: number;
    name: string;
    fullName: string;
    description: string;
    private: boolean;
    htmlUrl: string;
    cloneUrl: string;
    sshUrl: string;
    defaultBranch: string;
    language: string;
    stars: number;
    forks: number;
    openIssues: number;
    createdAt: string;
    updatedAt: string;
    pushedAt: string;
}

export interface GitHubIssue {
    id: number;
    number: number;
    title: string;
    body: string;
    state: 'open' | 'closed';
    locked: boolean;
    user: GitHubUser;
    assignees: GitHubUser[];
    labels: GitHubLabel[];
    milestone: GitHubMilestone | null;
    comments: number;
    createdAt: string;
    updatedAt: string;
    closedAt: string | null;
    pullRequest: GitHubPullRequestRef | null;
}

export interface GitHubPullRequest {
    id: number;
    number: number;
    title: string;
    body: string;
    state: 'open' | 'closed' | 'merged';
    locked: boolean;
    user: GitHubUser;
    assignees: GitHubUser[];
    requestedReviewers: GitHubUser[];
    labels: GitHubLabel[];
    milestone: GitHubMilestone | null;
    head: GitHubPullRequestBranch;
    base: GitHubPullRequestBranch;
    merged: boolean;
    mergeable: boolean | null;
    mergedAt: string | null;
    comments: number;
    reviewComments: number;
    commits: number;
    additions: number;
    deletions: number;
    changedFiles: number;
    createdAt: string;
    updatedAt: string;
}

export interface GitHubUser {
    id: number;
    login: string;
    name: string | null;
    email: string | null;
    avatarUrl: string;
    url: string;
    type: 'User' | 'Bot';
}

export interface GitHubLabel {
    id: number;
    name: string;
    color: string;
    description: string | null;
    default: boolean;
}

export interface GitHubMilestone {
    id: number;
    number: number;
    title: string;
    description: string;
    state: 'open' | 'closed';
    openIssues: number;
    closedIssues: number;
    createdAt: string;
    updatedAt: string;
    dueOn: string | null;
    closedAt: string | null;
}

export interface GitHubPullRequestBranch {
    label: string;
    ref: string;
    sha: string;
    user: GitHubUser;
    repo: GitHubRepository;
}

export interface GitHubPullRequestRef {
    url: string;
    htmlUrl: string;
    diffUrl: string;
    patchUrl: string;
}

export interface GitHubWorkflow {
    id: number;
    name: string;
    path: string;
    state: 'active' | 'deleted';
    createdAt: string;
    updatedAt: string;
}

export interface GitHubWorkflowRun {
    id: number;
    name: string;
    headBranch: string;
    headSha: string;
    status: 'queued' | 'in_progress' | 'completed';
    conclusion: 'success' | 'failure' | 'neutral' | 'cancelled' | 'skipped' | 'timed_out' | 'action_required' | null;
    workflowId: number;
    url: string;
    htmlUrl: string;
    createdAt: string;
    updatedAt: string;
    runNumber: number;
    event: string;
}

export interface GitHubRelease {
    id: number;
    tagName: string;
    targetCommitish: string;
    name: string;
    body: string;
    draft: boolean;
    prerelease: boolean;
    createdAt: string;
    publishedAt: string;
    author: GitHubUser;
    assets: GitHubReleaseAsset[];
    tarballUrl: string;
    zipballUrl: string;
    htmlUrl: string;
}

export interface GitHubReleaseAsset {
    id: number;
    name: string;
    label: string | null;
    contentType: string;
    size: number;
    downloadCount: number;
    createdAt: string;
    updatedAt: string;
    browserDownloadUrl: string;
}

export class GitHubIntegration {
    private apiClient: AxiosInstance;
    private workspaceRoot: string;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private gitIntegration: GitIntegration;

    constructor(workspaceRoot: string, gitIntegration: GitIntegration) {
        this.workspaceRoot = workspaceRoot;
        this.gitIntegration = gitIntegration;
        this.outputChannel = vscode.window.createOutputChannel('Noodle GitHub Integration');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            90
        );
        this.statusBarItem.command = 'noodle.github.showStatus';
        
        this.initializeApiClient();
    }

    /**
     * Initialize GitHub API client
     */
    private async initializeApiClient(): Promise<void> {
        try {
            const token = await this.getGitHubToken();
            
            this.apiClient = axios.create({
                baseURL: 'https://api.github.com',
                headers: {
                    'Accept': 'application/vnd.github.v3+json',
                    'User-Agent': 'Noodle-VSCode-Extension',
                    'Authorization': `token ${token}`
                },
                timeout: 30000
            });

            // Add request interceptor for logging
            this.apiClient.interceptors.request.use(
                (config) => {
                    this.outputChannel.appendLine(`[API] ${config.method?.toUpperCase()} ${config.url}`);
                    return config;
                },
                (error) => {
                    this.outputChannel.appendLine(`[API] Request error: ${error.message}`);
                    return Promise.reject(error);
                }
            );

            // Add response interceptor for logging
            this.apiClient.interceptors.response.use(
                (response) => {
                    this.outputChannel.appendLine(`[API] ${response.status} ${response.config.url}`);
                    return response;
                },
                (error) => {
                    this.outputChannel.appendLine(`[API] Response error: ${error.message}`);
                    return Promise.reject(error);
                }
            );

            this.outputChannel.appendLine('GitHub API client initialized');
        } catch (error) {
            throw new Error(`Failed to initialize GitHub API client: ${error.message}`);
        }
    }

    /**
     * Get GitHub token from configuration or secure storage
     */
    private async getGitHubToken(): Promise<string> {
        const config = vscode.workspace.getConfiguration('noodle.github');
        let token = config.get<string>('token');

        if (!token) {
            // Prompt for token if not configured
            token = await vscode.window.showInputBox({
                prompt: 'Enter your GitHub Personal Access Token',
                password: true,
                validateInput: (value) => {
                    if (!value || value.trim().length === 0) {
                        return 'GitHub token is required';
                    }
                    return null;
                }
            });

            if (token) {
                // Store token in configuration
                await config.update('token', token, vscode.ConfigurationTarget.Global);
            } else {
                throw new Error('GitHub token is required for GitHub integration');
            }
        }

        return token;
    }

    /**
     * Get repository information from current directory
     */
    private async getRepositoryInfo(): Promise<{ owner: string; repo: string }> {
        try {
            const remotes = await this.gitIntegration.getRemotes();
            const origin = remotes.find(r => r.name === 'origin');
            
            if (!origin) {
                throw new Error('No origin remote found');
            }

            // Parse GitHub URL
            const match = origin.url.match(/github\.com[\/:]([^\/]+)\/(.+?)(\.git)?$/);
            if (!match) {
                throw new Error('Not a GitHub repository');
            }

            return {
                owner: match[1],
                repo: match[2].replace('.git', '')
            };
        } catch (error) {
            throw new Error(`Failed to get repository info: ${error.message}`);
        }
    }

    /**
     * Get repository details
     */
    public async getRepository(): Promise<GitHubRepository> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}`);
            
            this.updateStatusBar(response.data);
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get repository: ${error.message}`);
        }
    }

    /**
     * Get issues for repository
     */
    public async getIssues(options: {
        state?: 'open' | 'closed' | 'all';
        labels?: string[];
        assignee?: string;
        creator?: string;
        mentioned?: string;
        milestone?: string | number;
        sort?: 'created' | 'updated' | 'comments';
        direction?: 'asc' | 'desc';
        per_page?: number;
        page?: number;
    } = {}): Promise<GitHubIssue[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/issues`, {
                params: options
            });
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get issues: ${error.message}`);
        }
    }

    /**
     * Create a new issue
     */
    public async createIssue(issue: {
        title: string;
        body?: string;
        assignees?: string[];
        labels?: string[];
        milestone?: number;
    }): Promise<GitHubIssue> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/issues`, issue);
            
            vscode.window.showInformationMessage(
                `Issue #${response.data.number} created successfully`
            );
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create issue: ${error.message}`);
        }
    }

    /**
     * Update an existing issue
     */
    public async updateIssue(
        issueNumber: number,
        updates: {
            title?: string;
            body?: string;
            state?: 'open' | 'closed';
            assignees?: string[];
            labels?: string[];
            milestone?: number | null;
        }
    ): Promise<GitHubIssue> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.patch(
                `/repos/${owner}/${repo}/issues/${issueNumber}`,
                updates
            );
            
            vscode.window.showInformationMessage(
                `Issue #${issueNumber} updated successfully`
            );
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to update issue: ${error.message}`);
        }
    }

    /**
     * Get pull requests for repository
     */
    public async getPullRequests(options: {
        state?: 'open' | 'closed' | 'all';
        head?: string;
        base?: string;
        sort?: 'created' | 'updated' | 'popularity';
        direction?: 'asc' | 'desc';
        per_page?: number;
        page?: number;
    } = {}): Promise<GitHubPullRequest[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/pulls`, {
                params: options
            });
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get pull requests: ${error.message}`);
        }
    }

    /**
     * Create a new pull request
     */
    public async createPullRequest(pr: {
        title: string;
        body?: string;
        head: string;
        base: string;
        draft?: boolean;
        maintainer_can_modify?: boolean;
    }): Promise<GitHubPullRequest> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/pulls`, pr);
            
            vscode.window.showInformationMessage(
                `Pull Request #${response.data.number} created successfully`
            );
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create pull request: ${error.message}`);
        }
    }

    /**
     * Get workflows for repository
     */
    public async getWorkflows(): Promise<GitHubWorkflow[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/actions/workflows`);
            
            return response.data.workflows;
        } catch (error) {
            throw new Error(`Failed to get workflows: ${error.message}`);
        }
    }

    /**
     * Get workflow runs for repository
     */
    public async getWorkflowRuns(options: {
        workflow_id?: number;
        branch?: string;
        status?: 'queued' | 'in_progress' | 'completed';
        event?: string;
        per_page?: number;
        page?: number;
    } = {}): Promise<GitHubWorkflowRun[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(
                `/repos/${owner}/${repo}/actions/runs`,
                { params: options }
            );
            
            return response.data.workflow_runs;
        } catch (error) {
            throw new Error(`Failed to get workflow runs: ${error.message}`);
        }
    }

    /**
     * Trigger a workflow run
     */
    public async triggerWorkflow(
        workflowId: number,
        inputs?: { [key: string]: any }
    ): Promise<GitHubWorkflowRun> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(
                `/repos/${owner}/${repo}/actions/workflows/${workflowId}/dispatches`,
                { ref: 'main', inputs }
            );
            
            vscode.window.showInformationMessage('Workflow triggered successfully');
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to trigger workflow: ${error.message}`);
        }
    }

    /**
     * Get releases for repository
     */
    public async getReleases(options: {
        per_page?: number;
        page?: number;
    } = {}): Promise<GitHubRelease[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(
                `/repos/${owner}/${repo}/releases`,
                { params: options }
            );
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get releases: ${error.message}`);
        }
    }

    /**
     * Create a new release
     */
    public async createRelease(release: {
        tagName: string;
        targetCommitish?: string;
        name?: string;
        body?: string;
        draft?: boolean;
        prerelease?: boolean;
    }): Promise<GitHubRelease> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(
                `/repos/${owner}/${repo}/releases`,
                release
            );
            
            vscode.window.showInformationMessage(
                `Release ${release.tagName} created successfully`
            );
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to create release: ${error.message}`);
        }
    }

    /**
     * Get repository contributors
     */
    public async getContributors(): Promise<GitHubUser[]> {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/contributors`);
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to get contributors: ${error.message}`);
        }
    }

    /**
     * Search repositories
     */
    public async searchRepositories(query: string, options: {
        sort?: 'stars' | 'forks' | 'updated';
        order?: 'asc' | 'desc';
        per_page?: number;
        page?: number;
    } = {}): Promise<{ items: GitHubRepository[]; total_count: number }> {
        try {
            const response = await this.apiClient.get('/search/repositories', {
                params: { q: query, ...options }
            });
            
            return response.data;
        } catch (error) {
            throw new Error(`Failed to search repositories: ${error.message}`);
        }
    }

    /**
     * Update status bar with repository information
     */
    private updateStatusBar(repository: GitHubRepository): void {
        const stars = repository.stars >= 1000 ? 
            `${(repository.stars / 1000).toFixed(1)}k` : 
            repository.stars.toString();
        
        this.statusBarItem.text = `$(github-inverted) ${repository.fullName} ⭐${stars}`;
        this.statusBarItem.tooltip = `
Repository: ${repository.fullName}
Description: ${repository.description || 'No description'}
Language: ${repository.language || 'Unknown'}
Stars: ${repository.stars}
Forks: ${repository.forks}
Open Issues: ${repository.openIssues}
Default Branch: ${repository.defaultBranch}
        `.trim();
    }

    /**
     * Show GitHub status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const repository = await this.getRepository();
            const statusText = this.formatRepositoryForDisplay(repository);
            
            this.outputChannel.clear();
            this.outputChannel.appendLine(statusText);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show GitHub status: ${error.message}`);
        }
    }

    /**
     * Format repository information for display
     */
    private formatRepositoryForDisplay(repo: GitHubRepository): string {
        let output = `GitHub Repository Information\n`;
        output += `===========================\n\n`;
        output += `Name: ${repo.fullName}\n`;
        output += `Description: ${repo.description || 'No description'}\n`;
        output += `Language: ${repo.language || 'Unknown'}\n`;
        output += `Private: ${repo.private ? 'Yes' : 'No'}\n`;
        output += `Default Branch: ${repo.defaultBranch}\n\n`;

        output += `Statistics:\n`;
        output += `  Stars: ${repo.stars}\n`;
        output += `  Forks: ${repo.forks}\n`;
        output += `  Open Issues: ${repo.openIssues}\n\n`;

        output += `Dates:\n`;
        output += `  Created: ${new Date(repo.createdAt).toLocaleString()}\n`;
        output += `  Updated: ${new Date(repo.updatedAt).toLocaleString()}\n`;
        output += `  Pushed: ${new Date(repo.pushedAt).toLocaleString()}\n\n`;

        output += `URLs:\n`;
        output += `  HTML: ${repo.htmlUrl}\n`;
        output += `  Clone: ${repo.cloneUrl}\n`;
        output += `  SSH: ${repo.sshUrl}\n`;

        return output;
    }

    /**
     * Open repository in browser
     */
    public async openInBrowser(): Promise<void> {
        try {
            const repository = await this.getRepository();
            vscode.env.openExternal(vscode.Uri.parse(repository.htmlUrl));
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to open repository: ${error.message}`);
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