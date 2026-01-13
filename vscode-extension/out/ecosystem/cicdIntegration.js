"use strict";
/**
 * NoodleCore CI/CD Integration
 *
 * Provides comprehensive CI/CD pipeline integration with popular platforms
 * like GitHub Actions, GitLab CI, Jenkins, Azure DevOps, and more.
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
exports.CICDIntegration = void 0;
const vscode = __importStar(require("vscode"));
const child_process_1 = require("child_process");
const util_1 = require("util");
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
const execAsync = (0, util_1.promisify)(child_process_1.exec);
class CICDIntegration {
    constructor(workspaceRoot, githubIntegration) {
        this.workspaceRoot = workspaceRoot;
        this.githubIntegration = githubIntegration;
        this.outputChannel = vscode.window.createOutputChannel('Noodle CI/CD Integration');
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(vscode.StatusBarAlignment.Left, 80);
        this.statusBarItem.command = 'noodle.cicd.showStatus';
        this.detectProvider();
    }
    /**
     * Detect CI/CD provider based on configuration files
     */
    detectProvider() {
        const configFiles = [
            { path: '.github/workflows', provider: 'github-actions' },
            { path: '.gitlab-ci.yml', provider: 'gitlab-ci' },
            { path: 'Jenkinsfile', provider: 'jenkins' },
            { path: 'azure-pipelines.yml', provider: 'azure-devops' },
            { path: '.circleci/config.yml', provider: 'circleci' },
            { path: '.travis.yml', provider: 'travis-ci' },
            { path: 'bitbucket-pipelines.yml', provider: 'bitbucket-pipelines' }
        ];
        for (const config of configFiles) {
            const fullPath = path.join(this.workspaceRoot, config.path);
            if (fs.existsSync(fullPath)) {
                this.provider = config.provider;
                this.configPath = fullPath;
                break;
            }
        }
        if (this.provider) {
            this.outputChannel.appendLine(`Detected CI/CD provider: ${this.provider}`);
            this.statusBarItem.text = `$(gear) ${this.getProviderIcon()}`;
            this.statusBarItem.show();
        }
        else {
            this.outputChannel.appendLine('No CI/CD provider detected');
            this.statusBarItem.hide();
        }
    }
    /**
     * Get icon for provider
     */
    getProviderIcon() {
        const icons = {
            'github-actions': 'GitHub',
            'gitlab-ci': 'GitLab',
            'jenkins': 'Jenkins',
            'azure-devops': 'Azure DevOps',
            'circleci': 'CircleCI',
            'travis-ci': 'Travis CI',
            'bitbucket-pipelines': 'Bitbucket'
        };
        return icons[this.provider] || 'CI/CD';
    }
    /**
     * Get CI/CD pipelines
     */
    async getPipelines() {
        try {
            switch (this.provider) {
                case 'github-actions':
                    return await this.getGitHubActionsPipelines();
                case 'gitlab-ci':
                    return await this.getGitLabCIPipelines();
                case 'jenkins':
                    return await this.getJenkinsPipelines();
                case 'azure-devops':
                    return await this.getAzureDevOpsPipelines();
                default:
                    return await this.getGenericPipelines();
            }
        }
        catch (error) {
            throw new Error(`Failed to get pipelines: ${error.message}`);
        }
    }
    /**
     * Get GitHub Actions pipelines
     */
    async getGitHubActionsPipelines() {
        if (!this.githubIntegration) {
            throw new Error('GitHub integration not available');
        }
        try {
            const workflows = await this.githubIntegration.getWorkflows();
            const runs = await this.githubIntegration.getWorkflowRuns();
            return workflows.map(workflow => {
                const latestRun = runs.find(run => run.workflowId === workflow.id);
                return {
                    id: workflow.id.toString(),
                    name: workflow.name,
                    provider: 'github-actions',
                    status: latestRun ? this.mapGitHubStatus(latestRun.status) : 'pending',
                    trigger: 'push',
                    lastRun: latestRun ? {
                        id: latestRun.id.toString(),
                        pipelineId: workflow.id.toString(),
                        status: this.mapGitHubStatus(latestRun.status),
                        startedAt: latestRun.createdAt,
                        completedAt: latestRun.updatedAt,
                        trigger: 'push',
                        commit: {
                            sha: latestRun.headSha,
                            message: '',
                            author: '',
                            branch: latestRun.headBranch
                        }
                    } : undefined,
                    config: {
                        path: path.join(this.configPath, `${workflow.name}.yml`),
                        content: '',
                        format: 'yaml',
                        valid: true
                    },
                    environment: {
                        name: 'GitHub Actions',
                        variables: {},
                        secrets: {}
                    }
                };
            });
        }
        catch (error) {
            throw new Error(`Failed to get GitHub Actions pipelines: ${error.message}`);
        }
    }
    /**
     * Get GitLab CI pipelines
     */
    async getGitLabCIPipelines() {
        try {
            const configPath = path.join(this.workspaceRoot, '.gitlab-ci.yml');
            const configContent = fs.readFileSync(configPath, 'utf8');
            return [{
                    id: 'gitlab-ci',
                    name: 'GitLab CI',
                    provider: 'gitlab-ci',
                    status: 'pending',
                    trigger: 'push',
                    config: {
                        path: configPath,
                        content: configContent,
                        format: 'yaml',
                        valid: this.validateYAML(configContent)
                    },
                    environment: {
                        name: 'GitLab CI',
                        variables: {},
                        secrets: {}
                    }
                }];
        }
        catch (error) {
            throw new Error(`Failed to get GitLab CI pipelines: ${error.message}`);
        }
    }
    /**
     * Get Jenkins pipelines
     */
    async getJenkinsPipelines() {
        try {
            const jenkinsfilePath = path.join(this.workspaceRoot, 'Jenkinsfile');
            const configContent = fs.existsSync(jenkinsfilePath) ?
                fs.readFileSync(jenkinsfilePath, 'utf8') : '';
            return [{
                    id: 'jenkins',
                    name: 'Jenkins Pipeline',
                    provider: 'jenkins',
                    status: 'pending',
                    trigger: 'push',
                    config: {
                        path: jenkinsfilePath,
                        content: configContent,
                        format: 'jenkinsfile',
                        valid: true
                    },
                    environment: {
                        name: 'Jenkins',
                        variables: {},
                        secrets: {}
                    }
                }];
        }
        catch (error) {
            throw new Error(`Failed to get Jenkins pipelines: ${error.message}`);
        }
    }
    /**
     * Get Azure DevOps pipelines
     */
    async getAzureDevOpsPipelines() {
        try {
            const configPath = path.join(this.workspaceRoot, 'azure-pipelines.yml');
            const configContent = fs.existsSync(configPath) ?
                fs.readFileSync(configPath, 'utf8') : '';
            return [{
                    id: 'azure-devops',
                    name: 'Azure DevOps Pipeline',
                    provider: 'azure-devops',
                    status: 'pending',
                    trigger: 'push',
                    config: {
                        path: configPath,
                        content: configContent,
                        format: 'yaml',
                        valid: this.validateYAML(configContent)
                    },
                    environment: {
                        name: 'Azure DevOps',
                        variables: {},
                        secrets: {}
                    }
                }];
        }
        catch (error) {
            throw new Error(`Failed to get Azure DevOps pipelines: ${error.message}`);
        }
    }
    /**
     * Get generic pipelines for unsupported providers
     */
    async getGenericPipelines() {
        return [{
                id: 'generic',
                name: 'Generic CI/CD',
                provider: this.provider,
                status: 'pending',
                trigger: 'push',
                config: {
                    path: this.configPath,
                    content: '',
                    format: 'yaml',
                    valid: true
                },
                environment: {
                    name: 'Generic CI/CD',
                    variables: {},
                    secrets: {}
                }
            }];
    }
    /**
     * Map GitHub status to CI/CD status
     */
    mapGitHubStatus(status) {
        const statusMap = {
            'queued': 'pending',
            'in_progress': 'running',
            'completed': 'success',
            'failure': 'failure',
            'cancelled': 'cancelled',
            'skipped': 'skipped',
            'timed_out': 'failure',
            'action_required': 'pending'
        };
        return statusMap[status] || 'pending';
    }
    /**
     * Trigger a pipeline run
     */
    async triggerPipeline(pipelineId, inputs) {
        try {
            switch (this.provider) {
                case 'github-actions':
                    if (this.githubIntegration) {
                        await this.githubIntegration.triggerWorkflow(parseInt(pipelineId), inputs);
                    }
                    break;
                case 'gitlab-ci':
                    await this.triggerGitLabCI();
                    break;
                case 'jenkins':
                    await this.triggerJenkins();
                    break;
                default:
                    throw new Error(`Pipeline triggering not supported for ${this.provider}`);
            }
            vscode.window.showInformationMessage('Pipeline triggered successfully');
        }
        catch (error) {
            throw new Error(`Failed to trigger pipeline: ${error.message}`);
        }
    }
    /**
     * Trigger GitLab CI pipeline
     */
    async triggerGitLabCI() {
        // This would require GitLab API integration
        throw new Error('GitLab CI triggering not implemented yet');
    }
    /**
     * Trigger Jenkins pipeline
     */
    async triggerJenkins() {
        // This would require Jenkins API integration
        throw new Error('Jenkins triggering not implemented yet');
    }
    /**
     * Get pipeline runs
     */
    async getPipelineRuns(pipelineId) {
        try {
            switch (this.provider) {
                case 'github-actions':
                    return await this.getGitHubActionsRuns(pipelineId);
                default:
                    return [];
            }
        }
        catch (error) {
            throw new Error(`Failed to get pipeline runs: ${error.message}`);
        }
    }
    /**
     * Get GitHub Actions runs
     */
    async getGitHubActionsRuns(pipelineId) {
        if (!this.githubIntegration) {
            throw new Error('GitHub integration not available');
        }
        try {
            const runs = await this.githubIntegration.getWorkflowRuns({
                workflow_id: parseInt(pipelineId)
            });
            return runs.map(run => ({
                id: run.id.toString(),
                pipelineId,
                status: this.mapGitHubStatus(run.status),
                startedAt: run.createdAt,
                completedAt: run.updatedAt,
                trigger: 'push',
                commit: {
                    sha: run.headSha,
                    message: '',
                    author: '',
                    branch: run.headBranch
                }
            }));
        }
        catch (error) {
            throw new Error(`Failed to get GitHub Actions runs: ${error.message}`);
        }
    }
    /**
     * Validate YAML configuration
     */
    validateYAML(content) {
        try {
            // Basic YAML validation - would use a proper YAML parser in production
            return content.trim().length > 0;
        }
        catch {
            return false;
        }
    }
    /**
     * Create CI/CD configuration
     */
    async createConfiguration(provider) {
        try {
            let configPath;
            let template;
            switch (provider) {
                case 'github-actions':
                    configPath = path.join(this.workspaceRoot, '.github', 'workflows', 'ci.yml');
                    template = this.getGitHubActionsTemplate();
                    break;
                case 'gitlab-ci':
                    configPath = path.join(this.workspaceRoot, '.gitlab-ci.yml');
                    template = this.getGitLabCITemplate();
                    break;
                case 'jenkins':
                    configPath = path.join(this.workspaceRoot, 'Jenkinsfile');
                    template = this.getJenkinsTemplate();
                    break;
                case 'azure-devops':
                    configPath = path.join(this.workspaceRoot, 'azure-pipelines.yml');
                    template = this.getAzureDevOpsTemplate();
                    break;
                default:
                    throw new Error(`Unsupported provider: ${provider}`);
            }
            // Create directory if it doesn't exist
            const dir = path.dirname(configPath);
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
            }
            // Write configuration file
            fs.writeFileSync(configPath, template, 'utf8');
            vscode.window.showInformationMessage(`${provider} configuration created at ${configPath}`);
            // Refresh provider detection
            this.detectProvider();
        }
        catch (error) {
            throw new Error(`Failed to create configuration: ${error.message}`);
        }
    }
    /**
     * Get GitHub Actions template
     */
    getGitHubActionsTemplate() {
        return `name: CI/CD Pipeline

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
        cache: 'npm'
    
    - name: Install dependencies
      run: npm ci
    
    - name: Run tests
      run: npm test
    
    - name: Build
      run: npm run build

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    steps:
    - uses: actions/checkout@v3
    
    - name: Deploy
      run: |
        echo "Deploying to production..."
        # Add your deployment commands here
`;
    }
    /**
     * Get GitLab CI template
     */
    getGitLabCITemplate() {
        return `stages:
  - test
  - build
  - deploy

variables:
  NODE_VERSION: "18"

cache:
  paths:
    - node_modules/

before_script:
  - npm ci

test:
  stage: test
  script:
    - npm test
  coverage: '/Coverage: \\d+\\.\\d+%/'
  artifacts:
    reports:
      coverage_report:
        coverage_format: cobertura
        path: coverage/cobertura-coverage.xml

build:
  stage: build
  script:
    - npm run build
  artifacts:
    paths:
      - dist/
    expire_in: 1 week

deploy:
  stage: deploy
  script:
    - echo "Deploying to production..."
    # Add your deployment commands here
  only:
    - main
  when: manual
`;
    }
    /**
     * Get Jenkins template
     */
    getJenkinsTemplate() {
        return `pipeline {
    agent any
    
    environment {
        NODE_VERSION = '18'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        
        stage('Setup') {
            steps {
                sh 'npm ci'
            }
        }
        
        stage('Test') {
            steps {
                sh 'npm test'
                publishTestResults testResultsPattern: 'test-results.xml'
                publishHTMLReport([
                    allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'coverage',
                    reportFiles: 'index.html',
                    reportName: 'Coverage Report'
                ])
            }
        }
        
        stage('Build') {
            steps {
                sh 'npm run build'
                archiveArtifacts artifacts: 'dist/**/*', fingerprint: true
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                sh 'echo "Deploying to production..."'
                // Add your deployment commands here
            }
        }
    }
}
`;
    }
    /**
     * Get Azure DevOps template
     */
    getAzureDevOpsTemplate() {
        return `trigger:
  branches:
    include:
    - main
    - develop
  paths:
    exclude:
    - docs/*
    - README.md

pr:
  branches:
    include:
    - main

variables:
  NODE_VERSION: '18'

pool:
  vmImage: 'ubuntu-latest'

stages:
- stage: Test
  displayName: 'Run tests'
  jobs:
  - job: Test
    displayName: 'Test job'
    steps:
    - task: NodeTool@0
      inputs:
        versionSpec: '$(NODE_VERSION)'
    
    - task: Npm@1
      displayName: 'Install dependencies'
      inputs:
        command: 'ci'
    
    - task: Npm@1
      displayName: 'Run tests'
      inputs:
        command: 'test'
    
    - task: PublishTestResults@2
      displayName: 'Publish test results'
      inputs:
        testResultsFiles: 'test-results.xml'
        testRunTitle: 'Unit Tests'

- stage: Build
  displayName: 'Build application'
  dependsOn: Test
  jobs:
  - job: Build
    displayName: 'Build job'
    steps:
    - task: Npm@1
      displayName: 'Build'
      inputs:
        command: 'run'
        customCommand: 'build'
    
    - task: PublishBuildArtifacts@1
      displayName: 'Publish artifacts'
      inputs:
        pathToPublish: 'dist'
        artifactName: 'dist'

- stage: Deploy
  displayName: 'Deploy to production'
  dependsOn: Build
  condition: and(succeeded(), eq(variables['Build.SourceBranch'], 'refs/heads/main'))
  jobs:
  - job: Deploy
    displayName: 'Deploy job'
    steps:
    - task: Bash@3
      displayName: 'Deploy'
      inputs:
        targetType: 'inline'
        script: |
          echo "Deploying to production..."
          # Add your deployment commands here
`;
    }
    /**
     * Show CI/CD status in output channel
     */
    async showStatus() {
        try {
            const pipelines = await this.getPipelines();
            const statusText = this.formatPipelinesForDisplay(pipelines);
            this.outputChannel.clear();
            this.outputChannel.appendLine(statusText);
            this.outputChannel.show();
        }
        catch (error) {
            vscode.window.showErrorMessage(`Failed to show CI/CD status: ${error.message}`);
        }
    }
    /**
     * Format pipelines for display
     */
    formatPipelinesForDisplay(pipelines) {
        let output = `CI/CD Pipeline Status\n`;
        output += `====================\n\n`;
        output += `Provider: ${this.getProviderIcon()}\n\n`;
        for (const pipeline of pipelines) {
            output += `Pipeline: ${pipeline.name}\n`;
            output += `Status: ${pipeline.status}\n`;
            output += `Trigger: ${pipeline.trigger}\n`;
            if (pipeline.lastRun) {
                output += `Last Run: ${new Date(pipeline.lastRun.startedAt).toLocaleString()}\n`;
                if (pipeline.lastRun.completedAt) {
                    output += `Duration: ${pipeline.lastRun.duration}ms\n`;
                }
            }
            output += `Config: ${pipeline.config.path}\n`;
            output += `Environment: ${pipeline.environment.name}\n\n`;
        }
        return output;
    }
    /**
     * Dispose CI/CD integration
     */
    dispose() {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}
exports.CICDIntegration = CICDIntegration;
//# sourceMappingURL=cicdIntegration.js.map