"use strict";
/**
 * NoodleCore GitHub API Connectors
 *
 * Provides comprehensive GitHub API integration for repository management,
 * issue tracking, pull requests, and GitHub Actions workflow management.
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
exports.GitHubIntegration = void 0;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
const util_1 = require("util");
const execAsync = (0, util_1.promisify)(child_process_1.exec);
class GitHubIntegration {
    constructor(workspaceRoot) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle GitHub Integration');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 90);
        this.statusBarItem.command = 'noodle.github.showStatus';
        this.initializeGitHub();
    }
    /**
     * Initialize GitHub integration and verify authentication
     */
    async initializeGitHub() {
        try {
            // Get GitHub token from configuration
            const config = vscode.workspace.getConfiguration('noodle.github');
            this.githubToken = config.get('token', '');
            if (!this.githubToken) {
                throw new Error('GitHub token not configured. Please set noodle.github.token in settings.');
            }
            // Initialize Octokit (GitHub API client)
            const { Octokit } = await Promise.resolve().then(() => __importStar(require('@octokit/rest')));
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
        }
        catch (error) {
            throw new Error(`GitHub initialization failed: ${error.message}`);
        }
    }
    /**
     * Detect current GitHub repository
     */
    async detectRepository() {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Could not detect GitHub repository: ${error.message}`);
        }
    }
    /**
     * Set repository context
     */
    async setRepository(owner, repo) {
        try {
            const response = await this.octokit.repos.get({
                owner,
                repo
            });
            this.repository = response.data;
            this.outputChannel.appendLine(`Set repository context: ${this.repository.fullName}`);
            this.updateStatusBar();
        }
        catch (error) {
            throw new Error(`Failed to set repository: ${error.message}`);
        }
    }
    /**
     * Execute Git command with proper error handling
     */
    async executeGitCommand(command, options = {}) {
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
        }
        catch (error) {
            const errorMessage = `Git command failed: ${fullCommand}\n${error.message}`;
            this.outputChannel.appendLine(errorMessage);
            throw new Error(errorMessage);
        }
    }
    /**
     * Update status bar with GitHub information
     */
    updateStatusBar() {
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
    getRepository() {
        return this.repository;
    }
    /**
     * Get repositories for authenticated user
     */
    async getRepositories() {
        try {
            const response = await this.octokit.repos.listForAuthenticatedUser();
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get repositories: ${error.message}`);
        }
    }
    /**
     * Get repository issues
     */
    async getIssues(state = 'open') {
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
        }
        catch (error) {
            throw new Error(`Failed to get issues: ${error.message}`);
        }
    }
    /**
     * Create a new issue
     */
    async createIssue(title, body, labels) {
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
        }
        catch (error) {
            throw new Error(`Failed to create issue: ${error.message}`);
        }
    }
    /**
     * Update an issue
     */
    async updateIssue(issueNumber, updates) {
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
        }
        catch (error) {
            throw new Error(`Failed to update issue: ${error.message}`);
        }
    }
    /**
     * Get pull requests
     */
    async getPullRequests(state = 'open') {
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
        }
        catch (error) {
            throw new Error(`Failed to get pull requests: ${error.message}`);
        }
    }
    /**
     * Create a new pull request
     */
    async createPullRequest(title, head, base, body) {
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
        }
        catch (error) {
            throw new Error(`Failed to create pull request: ${error.message}`);
        }
    }
    /**
     * Update a pull request
     */
    async updatePullRequest(pullNumber, updates) {
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
        }
        catch (error) {
            throw new Error(`Failed to update pull request: ${error.message}`);
        }
    }
    /**
     * Get workflows
     */
    async getWorkflows() {
        if (!this.repository) {
            throw new Error('No repository context set');
        }
        try {
            const response = await this.octokit.actions.listRepoWorkflows({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data.workflows;
        }
        catch (error) {
            throw new Error(`Failed to get workflows: ${error.message}`);
        }
    }
    /**
     * Get workflow runs
     */
    async getWorkflowRuns(options) {
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
        }
        catch (error) {
            throw new Error(`Failed to get workflow runs: ${error.message}`);
        }
    }
    /**
     * Trigger a workflow run
     */
    async triggerWorkflow(workflowId, inputs) {
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
        }
        catch (error) {
            throw new Error(`Failed to trigger workflow: ${error.message}`);
        }
    }
    /**
     * Get releases
     */
    async getReleases() {
        if (!this.repository) {
            throw new Error('No repository context set');
        }
        try {
            const response = await this.octokit.repos.listReleases({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get releases: ${error.message}`);
        }
    }
    /**
     * Create a new release
     */
    async createRelease(tag_name, name, body, draft = false, prerelease = false) {
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
        }
        catch (error) {
            throw new Error(`Failed to create release: ${error.message}`);
        }
    }
    /**
     * Get branches
     */
    async getBranches() {
        if (!this.repository) {
            throw new Error('No repository context set');
        }
        try {
            const response = await this.octokit.repos.listBranches({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get branches: ${error.message}`);
        }
    }
    /**
     * Get collaborators
     */
    async getCollaborators() {
        if (!this.repository) {
            throw new Error('No repository context set');
        }
        try {
            const response = await this.octokit.repos.listCollaborators({
                owner: this.repository.owner.login,
                repo: this.repository.name
            });
            return response.data;
        }
        catch (error) {
            throw new Error(`Failed to get collaborators: ${error.message}`);
        }
    }
    /**
     * Add collaborator to repository
     */
    async addCollaborator(username, permission = 'pull') {
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
        }
        catch (error) {
            throw new Error(`Failed to add collaborator: ${error.message}`);
        }
    }
    /**
     * Remove collaborator from repository
     */
    async removeCollaborator(username) {
        if (!this.repository) {
            throw new Error('No repository context set');
        }
        try {
            await this.octokit.repos.removeCollaborator({
                owner: this.repository.owner.login,
                repo: this.repository.name,
                username
            });
        }
        catch (error) {
            throw new Error(`Failed to remove collaborator: ${error.message}`);
        }
    }
    /**
     * Get repository statistics
     */
    async getRepositoryStats() {
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
        }
        catch (error) {
            throw new Error(`Failed to get repository stats: ${error.message}`);
        }
    }
    /**
     * Show GitHub status in output channel
     */
    async showStatus() {
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
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show GitHub status: ${error.message}`);
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
//# sourceMappingURL=githubApiConnectors.js.map