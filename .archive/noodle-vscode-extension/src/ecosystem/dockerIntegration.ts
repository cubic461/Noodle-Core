/**
 * NoodleCore Docker Integration
 * 
 * Provides comprehensive Docker containerization integration for
 * building, running, and managing Docker containers and images.
 */

import * as vscode from 'vscode';
import { exec } from 'child_process';
import { promisify } from 'util';
import * as path from 'path';
import * as fs from 'fs';
import axios from 'axios';

const execAsync = promisify(exec);

export interface DockerContainer {
    id: string;
    name: string;
    image: string;
    status: ContainerStatus;
    ports: ContainerPort[];
    volumes: ContainerVolume[];
    environment: { [key: string]: string };
    networks: string[];
    createdAt: string;
    startedAt?: string;
    labels: { [key: string]: string };
}

export interface ContainerPort {
    containerPort: number;
    hostPort?: number;
    protocol: 'tcp' | 'udp';
    hostIp?: string;
}

export interface ContainerVolume {
    containerPath: string;
    hostPath: string;
    mode: 'ro' | 'rw' | 'z' | 'Z';
}

export interface DockerImage {
    id: string;
    repository: string;
    tag: string;
    size: number;
    created: string;
    architecture: string;
    os: string;
    layers: DockerLayer[];
}

export interface DockerLayer {
    id: string;
    digest: string;
    size: number;
    instruction: string;
    created: string;
}

export interface DockerNetwork {
    id: string;
    name: string;
    driver: string;
    scope: 'local' | 'swarm' | 'global';
    internal: boolean;
    containers: string[];
    created: string;
    labels: { [key: string]: string };
}

export interface DockerVolume {
    name: string;
    driver: string;
    mountpoint: string;
    created: string;
    size: number;
    containers: string[];
    labels: { [key: string]: string };
}

export interface DockerComposeService {
    name: string;
    image: string;
    build?: DockerComposeBuild;
    ports?: DockerComposePort[];
    volumes?: DockerComposeVolume[];
    environment?: { [key: string]: string };
    depends_on?: string[];
    networks?: string[];
    command?: string[];
    working_dir?: string;
    user?: string;
    restart?: DockerComposeRestart;
}

export interface DockerComposeBuild {
    context: string;
    dockerfile: string;
    args?: { [key: string]: string };
    target?: string;
    cache_from?: string[];
    labels?: { [key: string]: string };
}

export interface DockerComposePort {
    target: number;
    published?: number;
    protocol?: 'tcp' | 'udp';
    mode?: string;
}

export interface DockerComposeVolume {
    source: string;
    target: string;
    type?: string;
    read_only?: boolean;
    bind?: {
        propagation: string;
    };
    volume?: {
        nocopy?: boolean;
    };
}

export type ContainerStatus = 'running' | 'paused' | 'exited' | 'restarting' | 'removing' | 'dead' | 'created' | 'not-found';
export type DockerComposeRestart = 'no' | 'always' | 'on-failure' | 'unless-stopped';

export class DockerIntegration {
    private workspaceRoot: string;
    private outputChannel: vscode.OutputChannel;
    private statusBarItem: vscode.StatusBarItem;
    private dockerApiUrl: string;
    private dockerVersion: string;

    constructor(workspaceRoot: string) {
        this.workspaceRoot = workspaceRoot;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Docker Integration');
        
        // Create status bar item
        this.statusBarItem = vscode.window.createStatusBarItem(
            vscode.StatusBarAlignment.Left,
            60
        );
        this.statusBarItem.command = 'noodle.docker.showStatus';
        this.statusBarItem.show();
        
        this.initializeDocker();
    }

    /**
     * Initialize Docker connection and verify installation
     */
    private async initializeDocker(): Promise<void> {
        try {
            // Check Docker installation
            const { stdout } = await execAsync('docker --version');
            this.dockerVersion = stdout.trim();
            
            // Check Docker daemon
            await execAsync('docker info');
            
            // Setup Docker API URL
            this.dockerApiUrl = process.env.DOCKER_HOST || 'unix:///var/run/docker.sock';
            
            this.outputChannel.appendLine(`Docker integration initialized (${this.dockerVersion})`);
            this.updateStatusBar();
        } catch (error) {
            throw new Error(`Docker not available: ${error.message}`);
        }
    }

    /**
     * Execute Docker command with proper error handling
     */
    private async executeDockerCommand(
        command: string,
        options: { cwd?: string; silent?: boolean } = {}
    ): Promise<string> {
        const cwd = options.cwd || this.workspaceRoot;
        const fullCommand = `docker ${command}`;
        
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
            const errorMessage = `Docker command failed: ${fullCommand}\n${error.message}`;
            this.outputChannel.appendLine(errorMessage);
            throw new Error(errorMessage);
        }
    }

    /**
     * Get all containers
     */
    public async getContainers(all: boolean = false): Promise<DockerContainer[]> {
        try {
            const command = all ? 'ps -a --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.CreatedAt}}"' : 
                                   'ps --format "{{.ID}}\t{{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}\t{{.CreatedAt}}"';
            const output = await this.executeDockerCommand(command);
            return this.parseContainerList(output);
        } catch (error) {
            throw new Error(`Failed to get containers: ${error.message}`);
        }
    }

    /**
     * Parse container list output
     */
    private parseContainerList(output: string): DockerContainer[] {
        const lines = output.split('\n').filter(line => line.trim());
        const containers: DockerContainer[] = [];

        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length >= 5) {
                const container: DockerContainer = {
                    id: parts[0],
                    name: parts[1],
                    image: parts[2],
                    status: this.parseContainerStatus(parts[3]),
                    ports: this.parseContainerPorts(parts[4]),
                    volumes: [],
                    environment: {},
                    networks: [],
                    createdAt: parts[5],
                    labels: {}
                };

                // Get additional container details
                try {
                    const inspectOutput = await this.executeDockerCommand(
                        `inspect ${container.id}`,
                        { silent: true }
                    );
                    const inspectData = JSON.parse(inspectOutput);
                    
                    if (inspectData && inspectData.length > 0) {
                        const details = inspectData[0];
                        container.volumes = this.parseContainerVolumes(details.Mounts || []);
                        container.environment = this.parseContainerEnvironment(details.Config?.Env || []);
                        container.networks = this.parseContainerNetworks(details.NetworkSettings?.Networks || {});
                        container.labels = details.Config?.Labels || {};
                        container.startedAt = details.State?.StartedAt;
                    }
                } catch (error) {
                    this.outputChannel.appendLine(`Failed to inspect container ${container.id}: ${error.message}`);
                }

                containers.push(container);
            }
        }

        return containers;
    }

    /**
     * Parse container status
     */
    private parseContainerStatus(status: string): ContainerStatus {
        if (status.includes('Up')) return 'running';
        if (status.includes('Paused')) return 'paused';
        if (status.includes('Exited')) return 'exited';
        if (status.includes('Restarting')) return 'restarting';
        if (status.includes('Removing')) return 'removing';
        if (status.includes('Dead')) return 'dead';
        if (status.includes('Created')) return 'created';
        return 'not-found';
    }

    /**
     * Parse container ports
     */
    private parseContainerPorts(ports: string): ContainerPort[] {
        if (!ports || ports === '<no value>') {
            return [];
        }

        const portList = ports.split(', ');
        const containerPorts: ContainerPort[] = [];

        for (const port of portList) {
            const match = port.match(/(\d+)\/(tcp|udp)(?:->(\d+))?/);
            if (match) {
                containerPorts.push({
                    containerPort: parseInt(match[1]),
                    protocol: match[2] as 'tcp' | 'udp',
                    hostPort: match[3] ? parseInt(match[3]) : undefined
                });
            }
        }

        return containerPorts;
    }

    /**
     * Parse container volumes
     */
    private parseContainerVolumes(mounts: any[]): ContainerVolume[] {
        return mounts.map(mount => ({
            containerPath: mount.Destination || '',
            hostPath: mount.Source || '',
            mode: mount.RW ? 'rw' : 'ro'
        }));
    }

    /**
     * Parse container environment
     */
    private parseContainerEnvironment(env: string[]): { [key: string]: string } {
        const environment: { [key: string]: string } = {};
        
        for (const envVar of env) {
            if (typeof envVar === 'string') {
                const equalIndex = envVar.indexOf('=');
                if (equalIndex > 0) {
                    const key = envVar.substring(0, equalIndex);
                    const value = envVar.substring(equalIndex + 1);
                    environment[key] = value;
                }
            }
        }

        return environment;
    }

    /**
     * Parse container networks
     */
    private parseContainerNetworks(networks: { [key: string]: any }): string[] {
        return Object.keys(networks);
    }

    /**
     * Get all images
     */
    public async getImages(): Promise<DockerImage[]> {
        try {
            const output = await this.executeDockerCommand(
                'images --format "{{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.CreatedAt}}\t{{.Size}}"'
            );
            return this.parseImageList(output);
        } catch (error) {
            throw new Error(`Failed to get images: ${error.message}`);
        }
    }

    /**
     * Parse image list output
     */
    private parseImageList(output: string): DockerImage[] {
        const lines = output.split('\n').filter(line => line.trim());
        const images: DockerImage[] = [];

        for (const line of lines) {
            const parts = line.split('\t');
            if (parts.length >= 5) {
                const image: DockerImage = {
                    id: parts[0],
                    repository: parts[1] || '<none>',
                    tag: parts[2] || '<none>',
                    created: parts[3],
                    size: this.parseImageSize(parts[4]),
                    architecture: '',
                    os: '',
                    layers: []
                };

                // Get detailed image information
                try {
                    const inspectOutput = await this.executeDockerCommand(
                        `inspect ${image.id}`,
                        { silent: true }
                    );
                    const inspectData = JSON.parse(inspectOutput);
                    
                    if (inspectData && inspectData.length > 0) {
                        const details = inspectData[0];
                        image.architecture = details.Architecture || '';
                        image.os = details.Os || '';
                        image.layers = this.parseImageLayers(details.RootFS?.Layers || []);
                    }
                } catch (error) {
                    this.outputChannel.appendLine(`Failed to inspect image ${image.id}: ${error.message}`);
                }

                images.push(image);
            }
        }

        return images;
    }

    /**
     * Parse image size
     */
    private parseImageSize(size: string): number {
        if (!size) return 0;
        
        const match = size.match(/(\d+(?:\.\d+)?)([KMG]?)B/);
        if (!match) return 0;
        
        const value = parseFloat(match[1]);
        const unit = match[2];
        
        switch (unit) {
            case 'K': return value * 1024;
            case 'M': return value;
            case 'G': return value / 1024;
            default: return value;
        }
    }

    /**
     * Parse image layers
     */
    private parseImageLayers(layers: any[]): DockerLayer[] {
        return layers.map(layer => ({
            id: layer.id || '',
            digest: layer.digest || '',
            size: layer.size || 0,
            instruction: layer.created_by || '',
            created: layer.created || ''
        }));
    }

    /**
     * Build Docker image
     */
    public async buildImage(
        dockerfilePath: string,
        tag: string,
        buildContext?: string
    ): Promise<string> {
        try {
            const contextPath = buildContext || path.dirname(dockerfilePath);
            const relativeDockerfile = path.relative(contextPath, dockerfilePath);
            
            const command = `build -t ${tag} -f ${relativeDockerfile} ${contextPath}`;
            const output = await this.executeDockerCommand(command);
            
            // Extract image ID from output
            const imageIdMatch = output.match(/Successfully built ([a-f0-9]+)/);
            const imageId = imageIdMatch ? imageIdMatch[1] : '';
            
            vscode.window.showInformationMessage(
                `Docker image built successfully: ${imageId}`
            );
            
            return imageId;
        } catch (error) {
            throw new Error(`Failed to build image: ${error.message}`);
        }
    }

    /**
     * Run container
     */
    public async runContainer(options: {
        image: string;
        name?: string;
        ports?: ContainerPort[];
        volumes?: ContainerVolume[];
        environment?: { [key: string]: string };
        detach?: boolean;
        command?: string[];
    }): Promise<string> {
        try {
            let command = `run -d ${options.image}`;
            
            if (options.name) {
                command += ` --name ${options.name}`;
            }
            
            if (options.ports) {
                for (const port of options.ports) {
                    if (port.hostPort) {
                        command += ` -p ${port.hostPort}:${port.containerPort}/${port.protocol}`;
                    } else {
                        command += ` -p ${port.containerPort}/${port.protocol}`;
                    }
                }
            }
            
            if (options.volumes) {
                for (const volume of options.volumes) {
                    command += ` -v ${volume.hostPath}:${volume.containerPath}:${volume.mode}`;
                }
            }
            
            if (options.environment) {
                for (const [key, value] of Object.entries(options.environment)) {
                    command += ` -e ${key}="${value}"`;
                }
            }
            
            if (options.command) {
                command += ` ${options.command.join(' ')}`;
            }
            
            const output = await this.executeDockerCommand(command);
            
            // Extract container ID from output
            const containerId = output.trim();
            
            vscode.window.showInformationMessage(
                `Container started: ${containerId}`
            );
            
            return containerId;
        } catch (error) {
            throw new Error(`Failed to run container: ${error.message}`);
        }
    }

    /**
     * Stop container
     */
    public async stopContainer(containerId: string): Promise<void> {
        try {
            await this.executeDockerCommand(`stop ${containerId}`);
            
            vscode.window.showInformationMessage(
                `Container stopped: ${containerId}`
            );
        } catch (error) {
            throw new Error(`Failed to stop container: ${error.message}`);
        }
    }

    /**
     * Start container
     */
    public async startContainer(containerId: string): Promise<void> {
        try {
            await this.executeDockerCommand(`start ${containerId}`);
            
            vscode.window.showInformationMessage(
                `Container started: ${containerId}`
            );
        } catch (error) {
            throw new Error(`Failed to start container: ${error.message}`);
        }
    }

    /**
     * Restart container
     */
    public async restartContainer(containerId: string): Promise<void> {
        try {
            await this.executeDockerCommand(`restart ${containerId}`);
            
            vscode.window.showInformationMessage(
                `Container restarted: ${containerId}`
            );
        } catch (error) {
            throw new Error(`Failed to restart container: ${error.message}`);
        }
    }

    /**
     * Remove container
     */
    public async removeContainer(containerId: string, force: boolean = false): Promise<void> {
        try {
            const command = force ? `rm -f ${containerId}` : `rm ${containerId}`;
            await this.executeDockerCommand(command);
            
            vscode.window.showInformationMessage(
                `Container removed: ${containerId}`
            );
        } catch (error) {
            throw new Error(`Failed to remove container: ${error.message}`);
        }
    }

    /**
     * Remove image
     */
    public async removeImage(imageId: string, force: boolean = false): Promise<void> {
        try {
            const command = force ? `rmi -f ${imageId}` : `rmi ${imageId}`;
            await this.executeDockerCommand(command);
            
            vscode.window.showInformationMessage(
                `Image removed: ${imageId}`
            );
        } catch (error) {
            throw new Error(`Failed to remove image: ${error.message}`);
        }
    }

    /**
     * Get Docker Compose services
     */
    public async getComposeServices(composeFile?: string): Promise<DockerComposeService[]> {
        try {
            const composePath = composeFile || this.findDockerComposeFile();
            if (!composePath) {
                throw new Error('Docker Compose file not found');
            }

            const output = await this.executeDockerCommand(
                `compose -f ${composePath} config`,
                { silent: true }
            );
            const composeConfig = JSON.parse(output);
            
            return this.parseComposeServices(composeConfig);
        } catch (error) {
            throw new Error(`Failed to get Compose services: ${error.message}`);
        }
    }

    /**
     * Find Docker Compose file
     */
    private findDockerComposeFile(): string | null {
        const possibleFiles = [
            'docker-compose.yml',
            'docker-compose.yaml',
            'compose.yml',
            'compose.yaml'
        ];

        for (const file of possibleFiles) {
            const filePath = path.join(this.workspaceRoot, file);
            if (fs.existsSync(filePath)) {
                return filePath;
            }
        }

        return null;
    }

    /**
     * Parse Docker Compose services
     */
    private parseComposeServices(config: any): DockerComposeService[] {
        const services: DockerComposeService[] = [];
        
        if (config.services) {
            for (const [name, service] of Object.entries(config.services)) {
                services.push({
                    name,
                    image: service.image || '',
                    build: service.build,
                    ports: service.ports,
                    volumes: service.volumes,
                    environment: service.environment,
                    depends_on: service.depends_on,
                    networks: service.networks,
                    command: service.command,
                    working_dir: service.working_dir,
                    user: service.user,
                    restart: service.restart
                });
            }
        }

        return services;
    }

    /**
     * Start Docker Compose
     */
    public async startCompose(composeFile?: string): Promise<void> {
        try {
            const composePath = composeFile || this.findDockerComposeFile();
            if (!composePath) {
                throw new Error('Docker Compose file not found');
            }

            await this.executeDockerCommand(`compose -f ${composePath} up -d`);
            
            vscode.window.showInformationMessage(
                'Docker Compose started'
            );
        } catch (error) {
            throw new Error(`Failed to start Compose: ${error.message}`);
        }
    }

    /**
     * Stop Docker Compose
     */
    public async stopCompose(composeFile?: string): Promise<void> {
        try {
            const composePath = composeFile || this.findDockerComposeFile();
            if (!composePath) {
                throw new Error('Docker Compose file not found');
            }

            await this.executeDockerCommand(`compose -f ${composePath} down`);
            
            vscode.window.showInformationMessage(
                'Docker Compose stopped'
            );
        } catch (error) {
            throw new Error(`Failed to stop Compose: ${error.message}`);
        }
    }

    /**
     * Get container logs
     */
    public async getContainerLogs(
        containerId: string,
        options: {
            follow?: boolean;
            tail?: number;
            since?: string;
            until?: string;
        } = {}
    ): Promise<string> {
        try {
            let command = `logs ${containerId}`;
            
            if (options.follow) command += ' -f';
            if (options.tail) command += ` --tail ${options.tail}`;
            if (options.since) command += ` --since "${options.since}"`;
            if (options.until) command += ` --until "${options.until}"`;
            
            return await this.executeDockerCommand(command);
        } catch (error) {
            throw new Error(`Failed to get container logs: ${error.message}`);
        }
    }

    /**
     * Update status bar
     */
    private updateStatusBar(): void {
        this.statusBarItem.text = `$(docker) Docker ${this.dockerVersion}`;
        this.statusBarItem.tooltip = `Docker Integration\nVersion: ${this.dockerVersion}`;
    }

    /**
     * Show Docker status in output channel
     */
    public async showStatus(): Promise<void> {
        try {
            const containers = await this.getContainers(true);
            const images = await this.getImages();
            
            let output = `Docker Status\n`;
            output += `============\n\n`;
            output += `Version: ${this.dockerVersion}\n\n`;

            output += `Containers (${containers.length}):\n`;
            for (const container of containers) {
                output += `  ${container.name} (${container.id})\n`;
                output += `    Status: ${container.status}\n`;
                output += `    Image: ${container.image}\n`;
                output += `    Created: ${container.createdAt}\n`;
                if (container.ports.length > 0) {
                    output += `    Ports: ${container.ports.map(p => `${p.containerPort}${p.hostPort ? `->${p.hostPort}` : ''}`).join(', ')}\n`;
                }
                output += '\n';
            }

            output += `Images (${images.length}):\n`;
            for (const image of images.slice(0, 10)) { // Show first 10 images
                output += `  ${image.repository}:${image.tag} (${image.id})\n`;
                output += `    Size: ${image.size} bytes\n`;
                output += `    Created: ${image.created}\n`;
                output += `    Architecture: ${image.architecture}\n`;
                output += `    OS: ${image.os}\n\n`;
            }

            if (images.length > 10) {
                output += `... and ${images.length - 10} more images\n`;
            }

            this.outputChannel.clear();
            this.outputChannel.appendLine(output);
            this.outputChannel.show();
        } catch (error) {
            vscode.window.showErrorMessage(`Failed to show Docker status: ${error.message}`);
        }
    }

    /**
     * Create Dockerfile template
     */
    public async createDockerfile(options: {
        baseImage?: string;
        workdir?: string;
        copyFiles?: string[];
        runCommands?: string[];
        exposePorts?: number[];
        cmd?: string[];
        environment?: { [key: string]: string };
    }): Promise<void> {
        try {
            let dockerfile = `# Generated by Noodle VS Code Extension\n`;
            
            if (options.baseImage) {
                dockerfile += `FROM ${options.baseImage}\n`;
            }
            
            if (options.workdir) {
                dockerfile += `WORKDIR ${options.workdir}\n`;
            }
            
            if (options.copyFiles) {
                for (const file of options.copyFiles) {
                    dockerfile += `COPY ${file} .\n`;
                }
            }
            
            if (options.runCommands) {
                for (const command of options.runCommands) {
                    dockerfile += `RUN ${command}\n`;
                }
            }
            
            if (options.exposePorts) {
                for (const port of options.exposePorts) {
                    dockerfile += `EXPOSE ${port}\n`;
                }
            }
            
            if (options.environment) {
                for (const [key, value] of Object.entries(options.environment)) {
                    dockerfile += `ENV ${key}="${value}"\n`;
                }
            }
            
            if (options.cmd) {
                dockerfile += `CMD [${options.cmd.map(c => `"${c}"`).join(', ')}]\n`;
            }

            const dockerfilePath = path.join(this.workspaceRoot, 'Dockerfile');
            fs.writeFileSync(dockerfilePath, dockerfile, 'utf8');
            
            vscode.window.showInformationMessage(
                `Dockerfile created at ${dockerfilePath}`
            );
        } catch (error) {
            throw new Error(`Failed to create Dockerfile: ${error.message}`);
        }
    }

    /**
     * Create docker-compose.yml template
     */
    public async createDockerComposeFile(services: DockerComposeService[]): Promise<void> {
        try {
            const composeConfig = {
                version: '3.8',
                services: {}
            };

            for (const service of services) {
                const serviceConfig: any = {
                    image: service.image
                };

                if (service.build) serviceConfig.build = service.build;
                if (service.ports) serviceConfig.ports = service.ports;
                if (service.volumes) serviceConfig.volumes = service.volumes;
                if (service.environment) serviceConfig.environment = service.environment;
                if (service.depends_on) serviceConfig.depends_on = service.depends_on;
                if (service.networks) serviceConfig.networks = service.networks;
                if (service.command) serviceConfig.command = service.command;
                if (service.working_dir) serviceConfig.working_dir = service.working_dir;
                if (service.user) serviceConfig.user = service.user;
                if (service.restart) serviceConfig.restart = service.restart;

                composeConfig.services[service.name] = serviceConfig;
            }

            const composePath = path.join(this.workspaceRoot, 'docker-compose.yml');
            const yamlContent = this.convertToYAML(composeConfig);
            fs.writeFileSync(composePath, yamlContent, 'utf8');
            
            vscode.window.showInformationMessage(
                `docker-compose.yml created at ${composePath}`
            );
        } catch (error) {
            throw new Error(`Failed to create docker-compose.yml: ${error.message}`);
        }
    }

    /**
     * Convert object to YAML (basic implementation)
     */
    private convertToYAML(obj: any): string {
        // This is a basic YAML converter - in production, use a proper YAML library
        const yaml = require('js-yaml') || null;
        if (yaml) {
            return yaml.dump(obj);
        }
        
        // Fallback to simple YAML-like format
        return JSON.stringify(obj, null, 2)
            .replace(/"/g, '"')
            .replace(/"/g, '"');
    }

    /**
     * Dispose Docker integration
     */
    public dispose(): void {
        this.statusBarItem.dispose();
        this.outputChannel.dispose();
    }
}