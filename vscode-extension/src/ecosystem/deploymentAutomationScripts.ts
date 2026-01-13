/**
 * NoodleCore Deployment Automation Scripts
 * 
 * Provides comprehensive deployment automation for various environments
 * including development, staging, production, and containerized deployments.
 */

import * as vscode from 'vscode';
import * as fs from 'fs';
import * as path from 'path';
import * as yaml from 'js-yaml';
import * as child_process from 'child_process';

export interface DeploymentEnvironment {
    id: string;
    name: string;
    type: 'development' | 'staging' | 'production' | 'container';
    description: string;
    config: DeploymentConfig;
    variables: { [key: string]: string };
    enabled: boolean;
}

export interface DeploymentConfig {
    buildCommand: string;
    deployCommand: string;
    testCommand: string;
    cleanupCommand: string;
    preDeployHooks: string[];
    postDeployHooks: string[];
    healthCheck: {
        enabled: boolean;
        endpoint: string;
        interval: number;
        timeout: number;
        retries: number;
    };
    rollback: {
        enabled: boolean;
        autoRollback: boolean;
        rollbackCommand: string;
    };
    notifications: {
        enabled: boolean;
        channels: string[];
        webhook?: string;
    };
}

export interface DeploymentStep {
    id: string;
    name: string;
    type: 'build' | 'test' | 'deploy' | 'health-check' | 'cleanup' | 'hook';
    command: string;
    timeout: number;
    retryCount: number;
    dependencies: string[];
    environment: { [key: string]: string };
    continueOnError: boolean;
}

export interface DeploymentResult {
    id: string;
    environmentId: string;
    status: 'pending' | 'running' | 'success' | 'failed' | 'rolled-back';
    startTime: Date;
    endTime?: Date;
    duration?: number;
    steps: DeploymentStep[];
    logs: string[];
    errors: string[];
    artifacts: string[];
    rollbackInfo?: {
        triggeredAt: Date;
        reason: string;
        steps: DeploymentStep[];
    };
}

export interface DeploymentTemplate {
    id: string;
    name: string;
    description: string;
    type: 'web' | 'api' | 'mobile' | 'desktop' | 'microservice';
    environments: string[];
    steps: DeploymentStep[];
    variables: { [key: string]: any };
    config: DeploymentConfig;
}

export class DeploymentAutomationScripts {
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private environments: Map<string, DeploymentEnvironment> = new Map();
    private deployments: Map<string, DeploymentResult> = new Map();
    private templates: Map<string, DeploymentTemplate> = new Map();
    private context: vscode.ExtensionContext;
    private kubernetesIntegration: any;

    constructor(context: vscode.ExtensionContext) {
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Deployment Automation');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            95
        );
        this.statusBarItem.command = 'noodle.deployment.showStatus';
        
        this.initializeDeploymentAutomation();
    }

    /**
     * Set Kubernetes integration reference
     */
    public setKubernetesIntegration(kubernetesIntegration: any): void {
        this.kubernetesIntegration = kubernetesIntegration;
    }

    /**
     * Initialize deployment automation
     */
    private async initializeDeploymentAutomation(): Promise<void> {
        try {
            // Load deployment environments
            await this.loadEnvironments();
            
            // Load deployment templates
            await this.loadTemplates();
            
            // Start deployment monitoring
            this.startDeploymentMonitoring();
            
            this.outputChannel.appendLine('Deployment automation initialized successfully');
            this.updateStatusBar();
            
            this.statusBarItem.show();
        } catch (error) {
            throw new Error(`Deployment automation initialization failed: ${error.message}`);
        }
    }

    /**
     * Load deployment environments
     */
    private async loadEnvironments(): Promise<void> {
        try {
            const environmentsDir = path.join(this.context.globalStorageUri.fsPath, 'environments');
            if (!fs.existsSync(environmentsDir)) {
                fs.mkdirSync(environmentsDir, { recursive: true });
                return;
            }
            
            const files = fs.readdirSync(environmentsDir);
            const envFiles = files.filter(file => file.endsWith('.yaml') || file.endsWith('.yml'));
            
            for (const file of envFiles) {
                const filePath = path.join(environmentsDir, file);
                const envData = yaml.load(fs.readFileSync(filePath, 'utf8'));
                
                const environment: DeploymentEnvironment = {
                    ...envData,
                    config: {
                        ...envData.config,
                        healthCheck: {
                            enabled: false,
                            endpoint: '/',
                            interval: 30000,
                            timeout: 5000,
                            retries: 3,
                            ...envData.config?.healthCheck
                        },
                        rollback: {
                            enabled: true,
                            autoRollback: true,
                            rollbackCommand: 'echo "Rollback"',
                            ...envData.config?.rollback
                        },
                        notifications: {
                            enabled: true,
                            channels: ['console'],
                            ...envData.config?.notifications
                        }
                    }
                };
                
                this.environments.set(environment.id, environment);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.environments.size} deployment environments`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load environments: ${error.message}`);
        }
    }

    /**
     * Load deployment templates
     */
    private async loadTemplates(): Promise<void> {
        try {
            const templatesDir = path.join(this.context.globalStorageUri.fsPath, 'templates');
            if (!fs.existsSync(templatesDir)) {
                fs.mkdirSync(templatesDir, { recursive: true });
                return;
            }
            
            const files = fs.readdirSync(templatesDir);
            const templateFiles = files.filter(file => file.endsWith('.yaml') || file.endsWith('.yml'));
            
            for (const file of templateFiles) {
                const filePath = path.join(templatesDir, file);
                const templateData = yaml.load(fs.readFileSync(filePath, 'utf8'));
                
                const template: DeploymentTemplate = {
                    ...templateData,
                    config: {
                        ...templateData.config,
                        healthCheck: {
                            enabled: false,
                            endpoint: '/',
                            interval: 30000,
                            timeout: 5000,
                            retries: 3,
                            ...templateData.config?.healthCheck
                        },
                        rollback: {
                            enabled: true,
                            autoRollback: true,
                            rollbackCommand: 'echo "Rollback"',
                            ...templateData.config?.rollback
                        },
                        notifications: {
                            enabled: true,
                            channels: ['console'],
                            ...templateData.config?.notifications
                        }
                    }
                };
                
                this.templates.set(template.id, template);
            }
            
            this.outputChannel.appendLine(`Loaded ${this.templates.size} deployment templates`);
        } catch (error) {
            this.outputChannel.appendLine(`Warning: Failed to load templates: ${error.message}`);
        }
    }

    /**
     * Add deployment environment
     */
    public async addEnvironment(environment: DeploymentEnvironment): Promise<void> {
        try {
            // Validate environment
            this.validateEnvironment(environment);
            
            this.environments.set(environment.id, environment);
            await this.saveEnvironment(environment);
            
            this.outputChannel.appendLine(`Added deployment environment: ${environment.name}`);
            this.emit('environmentAdded', environment);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Failed to add environment: ${error.message}`);
        }
    }

    /**
     * Remove deployment environment
     */
    public removeEnvironment(id: string): boolean {
        const environment = this.environments.get(id);
        if (!environment) {
            return false;
        }

        // Cancel any running deployments for this environment
        const runningDeployments = Array.from(this.deployments.values())
            .filter(d => d.environmentId === id && d.status === 'running');
        
        for (const deployment of runningDeployments) {
            this.cancelDeployment(deployment.id);
        }

        this.environments.delete(id);
        this.removeEnvironmentFile(id);
        
        this.outputChannel.appendLine(`Removed deployment environment: ${environment.name}`);
        this.emit('environmentRemoved', environment);
        this.updateStatusBar();
        return true;
    }

    /**
     * Get all environments
     */
    public getEnvironments(): DeploymentEnvironment[] {
        return Array.from(this.environments.values());
    }

    /**
     * Get environment by ID
     */
    public getEnvironment(id: string): DeploymentEnvironment | undefined {
        return this.environments.get(id);
    }

    /**
     * Validate deployment environment
     */
    private validateEnvironment(environment: DeploymentEnvironment): void {
        if (!environment.id || !environment.name) {
            throw new Error('Environment must have an ID and name');
        }
        
        if (!environment.config.buildCommand || !environment.config.deployCommand) {
            throw new Error('Environment must have build and deploy commands');
        }
        
        if (environment.type === 'container' && !environment.config.deployCommand.includes('docker')) {
            throw new Error('Container environment must include Docker commands');
        }
    }

    /**
     * Save environment configuration
     */
    private async saveEnvironment(environment: DeploymentEnvironment): Promise<void> {
        const environmentsDir = path.join(this.context.globalStorageUri.fsPath, 'environments');
        if (!fs.existsSync(environmentsDir)) {
            fs.mkdirSync(environmentsDir, { recursive: true });
        }
        
        const filePath = path.join(environmentsDir, `${environment.id}.yaml`);
        fs.writeFileSync(filePath, yaml.dump(environment, { indent: 2 }));
    }

    /**
     * Remove environment file
     */
    private removeEnvironmentFile(id: string): void {
        const environmentsDir = path.join(this.context.globalStorageUri.fsPath, 'environments');
        const filePath = path.join(environmentsDir, `${id}.yaml`);
        
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    }

    /**
     * Create deployment from template
     */
    public async createDeployment(
        environmentId: string,
        templateId?: string,
        customSteps?: DeploymentStep[],
        variables?: { [key: string]: string }
    ): Promise<string> {
        try {
            const environment = this.environments.get(environmentId);
            if (!environment) {
                throw new Error(`Environment not found: ${environmentId}`);
            }
            
            let template: DeploymentTemplate | undefined;
            if (templateId) {
                template = this.templates.get(templateId);
                if (!template) {
                    throw new Error(`Template not found: ${templateId}`);
                }
            }
            
            // Generate deployment ID
            const deploymentId = this.generateDeploymentId();
            
            // Create deployment result
            const deployment: DeploymentResult = {
                id: deploymentId,
                environmentId,
                status: 'pending',
                startTime: new Date(),
                steps: [],
                logs: [],
                errors: [],
                artifacts: []
            };
            
            // Build deployment steps
            const steps = this.buildDeploymentSteps(environment, template, customSteps, variables);
            deployment.steps = steps;
            
            // Store deployment
            this.deployments.set(deploymentId, deployment);
            
            // Start deployment
            await this.startDeployment(deploymentId);
            
            this.outputChannel.appendLine(`Created deployment: ${deploymentId} for environment: ${environment.name}`);
            this.emit('deploymentCreated', deployment);
            
            return deploymentId;
        } catch (error) {
            throw new Error(`Failed to create deployment: ${error.message}`);
        }
    }

    /**
     * Build deployment steps
     */
    private buildDeploymentSteps(
        environment: DeploymentEnvironment,
        template?: DeploymentTemplate,
        customSteps?: DeploymentStep[],
        variables?: { [key: string]: string }
    ): DeploymentStep[] {
        const steps: DeploymentStep[] = [];
        
        // Add pre-deploy hooks
        if (environment.config.preDeployHooks) {
            for (const hook of environment.config.preDeployHooks) {
                steps.push({
                    id: `pre-hook-${steps.length}`,
                    name: `Pre-deploy hook: ${hook}`,
                    type: 'hook',
                    command: hook,
                    timeout: 30000,
                    retryCount: 1,
                    dependencies: [],
                    environment: { ...environment.variables, ...variables },
                    continueOnError: false
                });
            }
        }
        
        // Add build step
        steps.push({
            id: 'build',
            name: 'Build application',
            type: 'build',
            command: environment.config.buildCommand,
            timeout: 300000,
            retryCount: 2,
            dependencies: [],
            environment: { ...environment.variables, ...variables },
            continueOnError: false
        });
        
        // Add test step
        if (environment.config.testCommand) {
            steps.push({
                id: 'test',
                name: 'Run tests',
                type: 'test',
                command: environment.config.testCommand,
                timeout: 300000,
                retryCount: 2,
                dependencies: ['build'],
                environment: { ...environment.variables, ...variables },
                continueOnError: false
            });
        }
        
        // Add custom steps
        if (customSteps) {
            for (const step of customSteps) {
                steps.push({
                    ...step,
                    environment: { ...environment.variables, ...variables, ...step.environment }
                });
            }
        }
        
        // Add deploy step
        steps.push({
            id: 'deploy',
            name: 'Deploy application',
            type: 'deploy',
            command: environment.config.deployCommand,
            timeout: 600000,
            retryCount: 3,
            dependencies: template?.steps?.find(s => s.id === 'test') ? ['test'] : ['build'],
            environment: { ...environment.variables, ...variables },
            continueOnError: false
        });
        
        // Add health check step
        if (environment.config.healthCheck.enabled) {
            steps.push({
                id: 'health-check',
                name: 'Health check',
                type: 'health-check',
                command: `curl -f ${environment.config.healthCheck.endpoint}`,
                timeout: environment.config.healthCheck.timeout,
                retryCount: environment.config.healthCheck.retries,
                dependencies: ['deploy'],
                environment: { ...environment.variables, ...variables },
                continueOnError: true
            });
        }
        
        // Add post-deploy hooks
        if (environment.config.postDeployHooks) {
            for (const hook of environment.config.postDeployHooks) {
                steps.push({
                    id: `post-hook-${steps.length}`,
                    name: `Post-deploy hook: ${hook}`,
                    type: 'hook',
                    command: hook,
                    timeout: 30000,
                    retryCount: 1,
                    dependencies: ['health-check'],
                    environment: { ...environment.variables, ...variables },
                    continueOnError: false
                });
            }
        }
        
        // Add cleanup step
        if (environment.config.cleanupCommand) {
            steps.push({
                id: 'cleanup',
                name: 'Cleanup',
                type: 'cleanup',
                command: environment.config.cleanupCommand,
                timeout: 60000,
                retryCount: 1,
                dependencies: ['health-check'],
                environment: { ...environment.variables, ...variables },
                continueOnError: true
            });
        }
        
        return steps;
    }

    /**
     * Start deployment
     */
    private async startDeployment(deploymentId: string): Promise<void> {
        const deployment = this.deployments.get(deploymentId);
        if (!deployment) {
            throw new Error(`Deployment not found: ${deploymentId}`);
        }
        
        deployment.status = 'running';
        deployment.startTime = new Date();
        
        this.outputChannel.appendLine(`Starting deployment: ${deploymentId}`);
        
        // Execute steps in order
        for (const step of deployment.steps) {
            if (deployment.status === 'failed') {
                break;
            }
            
            await this.executeDeploymentStep(deploymentId, step);
        }
        
        // Check if deployment succeeded
        if (deployment.status === 'running') {
            deployment.status = 'success';
            deployment.endTime = new Date();
            deployment.duration = deployment.endTime.getTime() - deployment.startTime.getTime();
            
            this.outputChannel.appendLine(`Deployment completed successfully: ${deploymentId}`);
            this.emit('deploymentCompleted', deployment);
            
            // Send notifications
            await this.sendDeploymentNotification(deployment, 'success');
        }
        
        // Check for auto-rollback
        if (deployment.status === 'failed' && 
            this.environments.get(deployment.environmentId)?.config.rollback.autoRollback) {
            await this.rollbackDeployment(deploymentId);
        }
    }

    /**
     * Execute deployment step
     */
    private async executeDeploymentStep(deploymentId: string, step: DeploymentStep): Promise<void> {
        const deployment = this.deployments.get(deploymentId);
        if (!deployment) {
            throw new Error(`Deployment not found: ${deploymentId}`);
        }
        
        // Check dependencies
        for (const depId of step.dependencies) {
            const depStep = deployment.steps.find(s => s.id === depId);
            if (!depStep || depStep.status !== 'success') {
                deployment.status = 'failed';
                deployment.errors.push(`Dependency ${depId} not satisfied`);
                return;
            }
        }
        
        this.outputChannel.appendLine(`Executing step: ${step.name}`);
        
        let retryCount = 0;
        let stepSuccess = false;
        
        while (retryCount <= step.retryCount && !stepSuccess) {
            try {
                const result = await this.executeCommand(step.command, step.timeout, step.environment);
                
                if (result.success) {
                    stepSuccess = true;
                    deployment.logs.push(`Step ${step.name} completed successfully`);
                } else {
                    retryCount++;
                    if (retryCount <= step.retryCount) {
                        deployment.logs.push(`Step ${step.name} failed (attempt ${retryCount}/${step.retryCount + 1})`);
                        await new Promise(resolve => setTimeout(resolve, 5000)); // Wait before retry
                    } else {
                        deployment.errors.push(`Step ${step.name} failed after ${step.retryCount + 1} attempts`);
                        if (!step.continueOnError) {
                            deployment.status = 'failed';
                        }
                    }
                }
            } catch (error) {
                retryCount++;
                if (retryCount <= step.retryCount) {
                    deployment.logs.push(`Step ${step.name} failed with error: ${error.message} (attempt ${retryCount}/${step.retryCount + 1})`);
                    await new Promise(resolve => setTimeout(resolve, 5000)); // Wait before retry
                } else {
                    deployment.errors.push(`Step ${step.name} failed with error: ${error.message}`);
                    if (!step.continueOnError) {
                        deployment.status = 'failed';
                    }
                }
            }
        }
    }

    /**
     * Execute command
     */
    private async executeCommand(command: string, timeout: number, environment: { [key: string]: string }): Promise<{ success: boolean; output: string }> {
        return new Promise((resolve) => {
            const process = child_process.exec(command, {
                timeout,
                env: { ...process.env, ...environment }
            });
            
            let output = '';
            let error = '';
            
            process.stdout?.on('data', (data) => {
                output += data.toString();
            });
            
            process.stderr?.on('data', (data) => {
                error += data.toString();
            });
            
            process.on('close', (code) => {
                resolve({
                    success: code === 0,
                    output: output + error
                });
            });
            
            process.on('error', (err) => {
                resolve({
                    success: false,
                    output: err.message
                });
            });
        });
    }

    /**
     * Cancel deployment
     */
    public async cancelDeployment(deploymentId: string): Promise<void> {
        const deployment = this.deployments.get(deploymentId);
        if (!deployment) {
            throw new Error(`Deployment not found: ${deploymentId}`);
        }
        
        deployment.status = 'failed';
        deployment.endTime = new Date();
        deployment.duration = deployment.endTime.getTime() - deployment.startTime.getTime();
        deployment.errors.push('Deployment cancelled by user');
        
        this.outputChannel.appendLine(`Deployment cancelled: ${deploymentId}`);
        this.emit('deploymentCancelled', deployment);
        
        await this.sendDeploymentNotification(deployment, 'cancelled');
    }

    /**
     * Rollback deployment
     */
    public async rollbackDeployment(deploymentId: string): Promise<void> {
        const deployment = this.deployments.get(deploymentId);
        if (!deployment) {
            throw new Error(`Deployment not found: ${deploymentId}`);
        }
        
        const environment = this.environments.get(deployment.environmentId);
        if (!environment || !environment.config.rollback.enabled) {
            throw new Error('Rollback is not enabled for this environment');
        }
        
        this.outputChannel.appendLine(`Starting rollback for deployment: ${deploymentId}`);
        
        const rollbackDeployment: DeploymentResult = {
            id: this.generateDeploymentId(),
            environmentId: deployment.environmentId,
            status: 'running',
            startTime: new Date(),
            steps: [],
            logs: [],
            errors: [],
            artifacts: [],
            rollbackInfo: {
                triggeredAt: new Date(),
                reason: 'Auto-rollback triggered due to deployment failure',
                steps: []
            }
        };
        
        // Execute rollback command
        try {
            const result = await this.executeCommand(
                environment.config.rollback.rollbackCommand,
                300000,
                environment.variables
            );
            
            if (result.success) {
                rollbackDeployment.status = 'success';
                rollbackDeployment.endTime = new Date();
                rollbackDeployment.duration = rollbackDeployment.endTime.getTime() - rollbackDeployment.startTime.getTime();
                rollbackDeployment.logs.push('Rollback completed successfully');
                
                this.outputChannel.appendLine(`Rollback completed successfully: ${rollbackDeployment.id}`);
                this.emit('deploymentRolledBack', rollbackDeployment);
                
                await this.sendDeploymentNotification(rollbackDeployment, 'rollback');
            } else {
                rollbackDeployment.status = 'failed';
                rollbackDeployment.errors.push('Rollback failed');
                this.outputChannel.appendLine(`Rollback failed: ${rollbackDeployment.id}`);
            }
        } catch (error) {
            rollbackDeployment.status = 'failed';
            rollbackDeployment.errors.push(`Rollback failed: ${error.message}`);
            this.outputChannel.appendLine(`Rollback failed: ${rollbackDeployment.id}`);
        }
        
        this.deployments.set(rollbackDeployment.id, rollbackDeployment);
    }

    /**
     * Get deployment by ID
     */
    public getDeployment(id: string): DeploymentResult | undefined {
        return this.deployments.get(id);
    }

    /**
     * Get all deployments
     */
    public getDeployments(): DeploymentResult[] {
        return Array.from(this.deployments.values());
    }

    /**
     * Get deployments for environment
     */
    public getDeploymentsForEnvironment(environmentId: string): DeploymentResult[] {
        return Array.from(this.deployments.values())
            .filter(d => d.environmentId === environmentId);
    }

    /**
     * Generate deployment ID
     */
    private generateDeploymentId(): string {
        return `deploy_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
    }

    /**
     * Start deployment monitoring
     */
    private startDeploymentMonitoring(): void {
        setInterval(() => {
            // Check running deployments
            const runningDeployments = Array.from(this.deployments.values())
                .filter(d => d.status === 'running');
            
            for (const deployment of runningDeployments) {
                // Check if deployment is taking too long
                const elapsed = Date.now() - deployment.startTime.getTime();
                if (elapsed > 3600000) { // 1 hour
                    this.cancelDeployment(deployment.id);
                }
            }
        }, 60000); // Check every minute
    }

    /**
     * Send deployment notification
     */
    private async sendDeploymentNotification(deployment: DeploymentResult, status: string): Promise<void> {
        const environment = this.environments.get(deployment.environmentId);
        if (!environment || !environment.config.notifications.enabled) {
            return;
        }
        
        const message = {
            deploymentId: deployment.id,
            environment: environment.name,
            status,
            startTime: deployment.startTime.toISOString(),
            endTime: deployment.endTime?.toISOString(),
            duration: deployment.duration,
            errors: deployment.errors,
            steps: deployment.steps.length
        };
        
        // Send to configured channels
        for (const channel of environment.config.notifications.channels) {
            if (channel === 'console') {
                this.outputChannel.appendLine(`Deployment ${status}: ${deployment.id}`);
            } else if (channel === 'webhook' && environment.config.notifications.webhook) {
                try {
                    await fetch(environment.config.notifications.webhook, {
                        method: 'POST',
                        headers: { 'Content-Type': 'application/json' },
                        body: JSON.stringify(message)
                    });
                } catch (error) {
                    this.outputChannel.appendLine(`Failed to send webhook notification: ${error.message}`);
                }
            }
        }
    }

    /**
     * Update status bar with deployment information
     */
    private updateStatusBar(): void {
        const totalEnvironments = this.environments.size;
        const enabledEnvironments = Array.from(this.environments.values())
            .filter(e => e.enabled).length;
        const runningDeployments = Array.from(this.deployments.values())
            .filter(d => d.status === 'running').length;
        const totalDeployments = this.deployments.size;
        
        let text = `$(rocket) Deploy`;
        if (runningDeployments > 0) {
            text += ` ${runningDeployments}`;
        }
        if (totalEnvironments > 0) {
            text += ` 🔗${enabledEnvironments}`;
        }
        
        this.statusBarItem.text = text;
        this.statusBarItem.tooltip = `Deployment: ${runningDeployments} running, ${enabledEnvironments}/${totalEnvironments} environments, ${totalDeployments} total deployments`;
    }

    /**
     * Show deployment status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const environments = this.getEnvironments();
            const deployments = this.getDeployments();
            const runningDeployments = deployments.filter(d => d.status === 'running');

            let output = `Deployment Automation Status\n`;
            output += `===========================\n\n`;

            output += `Environments (${environments.length}):\n`;
            for (const environment of environments) {
                output += `  ${environment.name}: ${environment.enabled ? 'Enabled' : 'Disabled'}\n`;
                output += `    Type: ${environment.type}\n`;
                output += `    Description: ${environment.description}\n`;
                output += `    Build Command: ${environment.config.buildCommand}\n`;
                output += `    Deploy Command: ${environment.config.deployCommand}\n`;
            }
            output += '\n';

            output += `Deployments (${deployments.length}):\n`;
            for (const deployment of deployments.slice(0, 10)) {
                output += `  ${deployment.id}: ${deployment.status}\n`;
                output += `    Environment: ${this.environments.get(deployment.environmentId)?.name || 'Unknown'}\n`;
                output += `    Started: ${deployment.startTime.toLocaleString()}\n`;
                output += `    Steps: ${deployment.steps.length} completed\n`;
                if (deployment.errors.length > 0) {
                    output += `    Errors: ${deployment.errors.length}\n`;
                }
            }
            if (deployments.length > 10) {
                output += `  ... and ${deployments.length - 10} more deployments\n`;
            }
            output += '\n';

            if (runningDeployments.length > 0) {
                output += `Running Deployments (${runningDeployments.length}):\n`;
                for (const deployment of runningDeployments) {
                    output += `  ${deployment.id}: ${deployment.steps.filter(s => s.status === 'success').length}/${deployment.steps.length} steps completed\n`;
                }
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show deployment status: ${error.message}`);
        }
    }

    /**
     * Dispose deployment automation
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }

    // Event emitter methods
    private emit(event: string, data: any): void {
        // Implementation would depend on the event system being used
    }

    /**
     * Deploy to Kubernetes
     */
    public async deployToKubernetes(
        manifestPath: string,
        namespace?: string,
        environmentId?: string
    ): Promise<string> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Deploying to Kubernetes: ${manifestPath}`);
            
            // Create deployment record if environment ID is provided
            let deploymentId: string | undefined;
            if (environmentId) {
                deploymentId = await this.createDeployment(
                    environmentId,
                    undefined,
                    [{
                        id: 'kubernetes-deploy',
                        name: 'Deploy to Kubernetes',
                        type: 'deploy',
                        command: `kubectl apply -f ${manifestPath}`,
                        timeout: 300000,
                        retryCount: 3,
                        dependencies: [],
                        environment: {},
                        continueOnError: false
                    }]
                );
            }

            // Deploy using Kubernetes integration
            const success = await this.kubernetesIntegration.deploy(manifestPath);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes deployment successful: ${manifestPath}`);
                if (deploymentId) {
                    this.emit('kubernetesDeploymentCompleted', { deploymentId, manifestPath });
                }
                return deploymentId || `k8s-deploy-${Date.now()}`;
            } else {
                throw new Error('Kubernetes deployment failed');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to deploy to Kubernetes: ${error.message}`);
            throw error;
        }
    }

    /**
     * Scale Kubernetes deployment
     */
    public async scaleKubernetesDeployment(
        deploymentName: string,
        replicas: number,
        environmentId?: string
    ): Promise<boolean> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Scaling Kubernetes deployment: ${deploymentName} to ${replicas} replicas`);
            
            // Scale using Kubernetes integration
            const success = await this.kubernetesIntegration.scale(deploymentName, replicas);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes deployment scaled successfully: ${deploymentName}`);
                if (environmentId) {
                    this.emit('kubernetesDeploymentScaled', { deploymentName, replicas, environmentId });
                }
                return true;
            } else {
                throw new Error('Failed to scale Kubernetes deployment');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to scale Kubernetes deployment: ${error.message}`);
            return false;
        }
    }

    /**
     * Get Kubernetes pod logs
     */
    public async getKubernetesPodLogs(
        podName: string,
        follow?: boolean,
        tail?: number
    ): Promise<boolean> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Getting logs for Kubernetes pod: ${podName}`);
            
            // Get logs using Kubernetes integration
            const success = await this.kubernetesIntegration.getLogs(podName, follow, tail);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes pod logs retrieved: ${podName}`);
                this.emit('kubernetesPodLogsRetrieved', { podName, follow, tail });
                return true;
            } else {
                throw new Error('Failed to get Kubernetes pod logs');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to get Kubernetes pod logs: ${error.message}`);
            return false;
        }
    }

    /**
     * Delete Kubernetes resource
     */
    public async deleteKubernetesResource(
        resourceType: string,
        resourceName: string,
        environmentId?: string
    ): Promise<boolean> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Deleting Kubernetes resource: ${resourceType}/${resourceName}`);
            
            // Delete resource using Kubernetes integration
            const success = await this.kubernetesIntegration.deleteResource(resourceType, resourceName);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes resource deleted successfully: ${resourceType}/${resourceName}`);
                if (environmentId) {
                    this.emit('kubernetesResourceDeleted', { resourceType, resourceName, environmentId });
                }
                return true;
            } else {
                throw new Error('Failed to delete Kubernetes resource');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to delete Kubernetes resource: ${error.message}`);
            return false;
        }
    }

    /**
     * Setup Kubernetes port forwarding
     */
    public async setupKubernetesPortForward(
        podName: string,
        localPort: number,
        remotePort: number,
        environmentId?: string
    ): Promise<boolean> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Setting up Kubernetes port forwarding: ${podName} ${localPort}:${remotePort}`);
            
            // Setup port forwarding using Kubernetes integration
            const success = await this.kubernetesIntegration.portForward(podName, localPort, remotePort);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes port forwarding setup successful: ${podName} ${localPort}:${remotePort}`);
                if (environmentId) {
                    this.emit('kubernetesPortForwardSetup', { podName, localPort, remotePort, environmentId });
                }
                return true;
            } else {
                throw new Error('Failed to setup Kubernetes port forwarding');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to setup Kubernetes port forwarding: ${error.message}`);
            return false;
        }
    }

    /**
     * Create Kubernetes manifest
     */
    public async createKubernetesManifest(
        resourceType: string,
        environmentId?: string
    ): Promise<boolean> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            this.outputChannel.appendLine(`Creating Kubernetes manifest: ${resourceType}`);
            
            // Create manifest using Kubernetes integration
            const success = await this.kubernetesIntegration.createManifest(resourceType);
            
            if (success) {
                this.outputChannel.appendLine(`Kubernetes manifest created successfully: ${resourceType}`);
                if (environmentId) {
                    this.emit('kubernetesManifestCreated', { resourceType, environmentId });
                }
                return true;
            } else {
                throw new Error('Failed to create Kubernetes manifest');
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to create Kubernetes manifest: ${error.message}`);
            return false;
        }
    }

    /**
     * Show Kubernetes status
     */
    public async showKubernetesStatus(): Promise<void> {
        try {
            if (!this.kubernetesIntegration) {
                throw new Error('Kubernetes integration not available');
            }

            await this.kubernetesIntegration.showStatus();
        } catch (error) {
            this.outputChannel.appendLine(`Failed to show Kubernetes status: ${error.message}`);
            vscode.window.showErrorMessage(`Failed to show Kubernetes status: ${error.message}`);
        }
    }

    /**
     * Create Kubernetes deployment environment
     */
    public async createKubernetesEnvironment(
        name: string,
        namespace: string,
        kubeconfig?: string
    ): Promise<void> {
        try {
            const environment: DeploymentEnvironment = {
                id: `k8s-${name.toLowerCase().replace(/\s+/g, '-')}`,
                name,
                type: 'container',
                description: `Kubernetes deployment environment for ${name}`,
                config: {
                    buildCommand: 'docker build -t my-app:latest .',
                    deployCommand: `kubectl apply -f k8s/ -n ${namespace}`,
                    testCommand: 'kubectl get pods -n ' + namespace,
                    cleanupCommand: `kubectl delete -f k8s/ -n ${namespace}`,
                    preDeployHooks: [
                        'kubectl config use-context ' + (kubeconfig || 'default'),
                        'kubectl create namespace ' + namespace + ' --dry-run=client -o yaml | kubectl apply -f -'
                    ],
                    postDeployHooks: [
                        'kubectl rollout status deployment/my-app -n ' + namespace
                    ],
                    healthCheck: {
                        enabled: true,
                        endpoint: '/health',
                        interval: 30000,
                        timeout: 5000,
                        retries: 3
                    },
                    rollback: {
                        enabled: true,
                        autoRollback: true,
                        rollbackCommand: `kubectl rollout undo deployment/my-app -n ${namespace}`
                    },
                    notifications: {
                        enabled: true,
                        channels: ['console']
                    }
                },
                variables: {
                    KUBERNETES_NAMESPACE: namespace,
                    KUBERNETES_CONFIG: kubeconfig || ''
                },
                enabled: true
            };

            await this.addEnvironment(environment);
            this.outputChannel.appendLine(`Kubernetes environment created: ${name}`);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to create Kubernetes environment: ${error.message}`);
            throw error;
        }
    }

    /**
     * Get Kubernetes environments
     */
    public getKubernetesEnvironments(): DeploymentEnvironment[] {
        return this.getEnvironments().filter(env => env.type === 'container');
    }

    /**
     * Check if Kubernetes integration is available
     */
    public isKubernetesIntegrationAvailable(): boolean {
        return this.kubernetesIntegration !== undefined;
    }
}