"use strict";
/**
 * NoodleCore GitHub Integration
 *
 * Provides comprehensive GitHub API integration for repository management,
 * issue tracking, pull requests, and collaboration features.
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.GitHubIntegration = void 0;
const vscode = __importStar(require("vscode"));
const axios_1 = __importDefault(require("axios"));
class GitHubIntegration {
    constructor(workspaceRoot, gitIntegration) {
        this.workspaceRoot = workspaceRoot;
        this.gitIntegration = gitIntegration;
        this.outputChannel = vscode.window.createOutputChannel('Noodle GitHub Integration');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 90);
        this.statusBarItem.command = 'noodle.github.showStatus';
        this.initializeApiClient();
    }
    /**
     * Initialize GitHub API client
     */
    async initializeApiClient() {
        try {
            const token = await this.getGitHubToken();
            this.apiClient = axios_1.default.create({
                baseURL: 'https://api.github.com',
                headers: {
                    'Accept': 'application/vnd.github.v3+json',
                    'User-Agent': 'Noodle-VSCode-Extension',
                    'Authorization': `token ${token}`
                },
                timeout: 30000
            });
            // Add request interceptor for logging
            this.apiClient.interceptors.request.use((config) => {
                this.outputChannel.appendLine(`[API] ${config.method?.toUpperCase()} ${config.url}`);
                return config;
            }, (error) => {
                this.outputChannel.appendLine(`[API] Request error: ${error.message}`);
                return Promise.reject(error);
            });
            // Add response interceptor for logging
            this.apiClient.interceptors.response.use((response) => {
                this.outputChannel.appendLine(`[API] ${response.status} ${response.config.url}`);
                return response;
            }, (error) => {
                this.outputChannel.appendLine(`[API] Response error: ${error.message}`);
                return Promise.reject(error);
            });
            this.outputChannel.appendLine('GitHub API client initialized');
        }
        catch (error) {
            throw new Error(`Failed to initialize GitHub API client: ${error.message}`);
        }
    }
    /**
     * Get GitHub token from configuration or secure storage
     */
    async getGitHubToken() {
        const config = vscode.workspace.getConfiguration('noodle.github');
        let token = config.get('token');
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
            }
            else {
                throw new Error('GitHub token is required for GitHub integration');
            }
        }
        return token;
    }
    /**
     * Get repository information from current directory
     */
    async getRepositoryInfo() {
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
        }
        catch (error) {
            throw new Error(`Failed to get repository info: ${error.message}`);
        }
    }
    /**
     * Get repository details
     */
    async getRepository() {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}`);
            this.updateStatusBar(response.data);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get repository: ${error.message}`);
        }
    }
    /**
     * Get issues for repository
     */
    async getIssues(options = {}) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/issues`, {
                params: options
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get issues: ${error.message}`);
        }
    }
    /**
     * Create a new issue
     */
    async createIssue(issue) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/issues`, issue);
            vscode.window.showInformationMessage(`Issue #${response.data.number} created successfully`);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to create issue: ${error.message}`);
        }
    }
    /**
     * Update an existing issue
     */
    async updateIssue(issueNumber, updates) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.patch(`/repos/${owner}/${repo}/issues/${issueNumber}`, updates);
            vscode.window.showInformationMessage(`Issue #${issueNumber} updated successfully`);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to update issue: ${error.message}`);
        }
    }
    /**
     * Get pull requests for repository
     */
    async getPullRequests(options = {}) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/pulls`, {
                params: options
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get pull requests: ${error.message}`);
        }
    }
    /**
     * Create a new pull request
     */
    async createPullRequest(pr) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/pulls`, pr);
            vscode.window.showInformationMessage(`Pull Request #${response.data.number} created successfully`);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to create pull request: ${error.message}`);
        }
    }
    /**
     * Get workflows for repository
     */
    async getWorkflows() {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/actions/workflows`);
            return response.data.workflows;
        }
        catch (error) {
            throw new Error(`Failed to get workflows: ${error.message}`);
        }
    }
    /**
     * Get workflow runs for repository
     */
    async getWorkflowRuns(options = {}) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/actions/runs`, { params: options });
            return response.data.workflow_runs;
        }
        catch (error) {
            throw new Error(`Failed to get workflow runs: ${error.message}`);
        }
    }
    /**
     * Trigger a workflow run
     */
    async triggerWorkflow(workflowId, inputs) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/actions/workflows/${workflowId}/dispatches`, { ref: 'main', inputs });
            vscode.window.showInformationMessage('Workflow triggered successfully');
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to trigger workflow: ${error.message}`);
        }
    }
    /**
     * Get releases for repository
     */
    async getReleases(options = {}) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/releases`, { params: options });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get releases: ${error.message}`);
        }
    }
    /**
     * Create a new release
     */
    async createRelease(release) {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.post(`/repos/${owner}/${repo}/releases`, release);
            vscode.window.showInformationMessage(`Release ${release.tagName} created successfully`);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to create release: ${error.message}`);
        }
    }
    /**
     * Get repository contributors
     */
    async getContributors() {
        try {
            const { owner, repo } = await this.getRepositoryInfo();
            const response = await this.apiClient.get(`/repos/${owner}/${repo}/contributors`);
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get contributors: ${error.message}`);
        }
    }
    /**
     * Search repositories
     */
    async searchRepositories(query, options = {}) {
        try {
            const response = await this.apiClient.get('/search/repositories', {
                params: { q: query, ...options }
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to search repositories: ${error.message}`);
        }
    }
    /**
     * Update status bar with repository information
     */
    updateStatusBar(repository) {
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
    async showStatus() {
        try {
            const repository = await this.getRepository();
            const statusText = this.formatRepositoryForDisplay(repository);
            this.outputChannel.clear();
            this.outputChannel.appendLine(statusText);
            this.outputChannel.show();
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show GitHub status: ${error.message}`);
        }
    }
    /**
     * Format repository information for display
     */
    formatRepositoryForDisplay(repo) {
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
    async openInBrowser() {
        try {
            const repository = await this.getRepository();
            vscode.env.openExternal(vscode.Uri.parse(repository.htmlUrl));
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to open repository: ${error.message}`);
        }
    }
    /**
     * Dispose GitHub integration
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.GitHubIntegration = GitHubIntegration;
//# sourceMappingURL=githubIntegration.js.map