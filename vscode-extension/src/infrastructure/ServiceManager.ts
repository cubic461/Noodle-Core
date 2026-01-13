/**
 * Service Manager for Noodle VS Code Extension
 * 
 * Manages all services in the extension ecosystem with proper
 * lifecycle management, dependency injection, and health monitoring.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';

export interface ServiceConfig {
    id: string;
    name: string;
    version: string;
    dependencies?: string[];
    enabled: boolean;
    priority: number;
    autoStart: boolean;
    healthCheck?: {
        enabled: boolean;
        interval: number;
        timeout: number;
    };
}

export interface ServiceStatus {
    state: 'stopped' | 'starting' | 'running' | 'stopping' | 'error';
    startTime?: number;
    lastError?: string;
    healthStatus?: 'healthy' | 'degraded' | 'unhealthy';
    metrics?: Record<string, any>;
}

export interface Service {
    config: ServiceConfig;
    status: ServiceStatus;
    initialize(): Promise<void>;
    start(): Promise<void>;
    stop(): Promise<void>;
    dispose(): Promise<void>;
    healthCheck?(): Promise<boolean>;
    getMetrics?(): Record<string, any>;
}

export class ServiceManager extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private services: Map<string, Service> = new Map();
    private serviceOrder: string[] = [];
    private healthCheckInterval?: NodeJS.Timer;
    
    constructor(context: vscode.ExtensionContext) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Service Manager');
    }
    
    /**
     * Initialize service manager
     */
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing service manager...');
            
            // Start health check interval
            this.startHealthCheckInterval();
            
            this.outputChannel.appendLine('Service manager initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize service manager: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Register a service
     */
    public async registerService(service: Service): Promise<void> {
        try {
            this.outputChannel.appendLine(`Registering service: ${service.config.name}`);
            
            // Check dependencies
            if (service.config.dependencies) {
                for (const depId of service.config.dependencies) {
                    if (!this.services.has(depId)) {
                        throw new Error(`Dependency not found: ${depId}`);
                    }
                }
            }
            
            // Add service
            this.services.set(service.config.id, service);
            this.updateServiceOrder();
            
            // Auto-start if enabled
            if (service.config.autoStart) {
                await this.startService(service.config.id);
            }
            
            this.outputChannel.appendLine(`Service registered: ${service.config.name}`);
            this.emit('serviceRegistered', service);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to register service ${service.config.name}: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Start a service
     */
    public async startService(serviceId: string): Promise<void> {
        try {
            const service = this.services.get(serviceId);
            if (!service) {
                throw new Error(`Service not found: ${serviceId}`);
            }
            
            if (service.status.state === 'running') {
                this.outputChannel.appendLine(`Service already running: ${service.config.name}`);
                return;
            }
            
            this.outputChannel.appendLine(`Starting service: ${service.config.name}`);
            
            // Update status
            service.status.state = 'starting';
            this.emit('serviceStatusChanged', service);
            
            // Start dependencies first
            if (service.config.dependencies) {
                for (const depId of service.config.dependencies) {
                    await this.startService(depId);
                }
            }
            
            // Initialize if not already initialized
            if (service.status.state === 'stopped') {
                await service.initialize();
            }
            
            // Start the service
            await service.start();
            
            // Update status
            service.status.state = 'running';
            service.status.startTime = Date.now();
            this.emit('serviceStatusChanged', service);
            
            this.outputChannel.appendLine(`Service started: ${service.config.name}`);
            this.emit('serviceStarted', service);
        } catch (error) {
            const service = this.services.get(serviceId);
            if (service) {
                service.status.state = 'error';
                service.status.lastError = error.message;
                this.emit('serviceStatusChanged', service);
            }
            
            this.outputChannel.appendLine(`Failed to start service ${serviceId}: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Stop a service
     */
    public async stopService(serviceId: string): Promise<void> {
        try {
            const service = this.services.get(serviceId);
            if (!service) {
                throw new Error(`Service not found: ${serviceId}`);
            }
            
            if (service.status.state === 'stopped') {
                this.outputChannel.appendLine(`Service already stopped: ${service.config.name}`);
                return;
            }
            
            this.outputChannel.appendLine(`Stopping service: ${service.config.name}`);
            
            // Update status
            service.status.state = 'stopping';
            this.emit('serviceStatusChanged', service);
            
            // Stop dependent services first
            const dependentServices = this.getDependentServices(serviceId);
            for (const depId of dependentServices) {
                await this.stopService(depId);
            }
            
            // Stop the service
            await service.stop();
            
            // Update status
            service.status.state = 'stopped';
            this.emit('serviceStatusChanged', service);
            
            this.outputChannel.appendLine(`Service stopped: ${service.config.name}`);
            this.emit('serviceStopped', service);
        } catch (error) {
            const service = this.services.get(serviceId);
            if (service) {
                service.status.state = 'error';
                service.status.lastError = error.message;
                this.emit('serviceStatusChanged', service);
            }
            
            this.outputChannel.appendLine(`Failed to stop service ${serviceId}: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Get service
     */
    public getService(serviceId: string): Service | undefined {
        return this.services.get(serviceId);
    }
    
    /**
     * Get all services
     */
    public getServices(): Service[] {
        return Array.from(this.services.values());
    }
    
    /**
     * Get services by status
     */
    public getServicesByStatus(state: ServiceStatus['state']): Service[] {
        return Array.from(this.services.values()).filter(s => s.status.state === state);
    }
    
    /**
     * Get service status
     */
    public getServiceStatus(serviceId: string): ServiceStatus | undefined {
        const service = this.services.get(serviceId);
        return service ? service.status : undefined;
    }
    
    /**
     * Update service order based on dependencies and priority
     */
    private updateServiceOrder(): void {
        const services = Array.from(this.services.values());
        
        // Sort by priority and dependencies
        services.sort((a, b) => {
            if (a.config.priority !== b.config.priority) {
                return b.config.priority - a.config.priority;
            }
            return a.config.name.localeCompare(b.config.name);
        });
        
        this.serviceOrder = services.map(s => s.config.id);
    }
    
    /**
     * Get dependent services
     */
    private getDependentServices(serviceId: string): string[] {
        const dependentServices: string[] = [];
        
        for (const [id, service] of this.services) {
            if (service.config.dependencies && service.config.dependencies.includes(serviceId)) {
                dependentServices.push(id);
            }
        }
        
        return dependentServices;
    }
    
    /**
     * Start health check interval
     */
    private startHealthCheckInterval(): void {
        this.healthCheckInterval = setInterval(async () => {
            await this.performHealthChecks();
        }, 30000); // Check every 30 seconds
    }
    
    /**
     * Perform health checks on all services
     */
    private async performHealthChecks(): Promise<void> {
        for (const service of this.services.values()) {
            if (service.status.state === 'running' && service.config.healthCheck?.enabled) {
                try {
                    if (service.healthCheck) {
                        const isHealthy = await service.healthCheck();
                        service.status.healthStatus = isHealthy ? 'healthy' : 'unhealthy';
                    } else {
                        service.status.healthStatus = 'healthy';
                    }
                    
                    // Update metrics
                    if (service.getMetrics) {
                        service.status.metrics = service.getMetrics();
                    }
                    
                    this.emit('serviceHealthChecked', service);
                } catch (error) {
                    service.status.healthStatus = 'unhealthy';
                    service.status.lastError = error.message;
                    this.emit('serviceHealthCheckFailed', service, error);
                }
            }
        }
    }
    
    /**
     * Dispose service manager
     */
    public dispose(): void {
        // Stop health check interval
        if (this.healthCheckInterval) {
            clearInterval(this.healthCheckInterval);
        }
        
        // Stop all services
        const stopPromises: Promise<void>[] = [];
        for (const service of this.services.values()) {
            if (service.status.state === 'running') {
                stopPromises.push(this.stopService(service.config.id));
            }
        }
        
        Promise.all(stopPromises).then(() => {
            // Dispose all services
            const disposePromises: Promise<void>[] = [];
            for (const service of this.services.values()) {
                disposePromises.push(service.dispose());
            }
            
            Promise.all(disposePromises).then(() => {
                this.outputChannel.appendLine('All services disposed');
            });
        });
        
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}