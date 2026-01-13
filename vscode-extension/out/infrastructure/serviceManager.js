"use strict";
/**
 * Service Manager for Noodle VS Code Extension
 *
 * Manages all services in the extension ecosystem with proper
 * lifecycle management, dependency injection, and health monitoring.
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
exports.ServiceManager = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class ServiceManager extends events_1.EventEmitter {
    constructor(context) {
        super();
        this.services = new Map();
        this.serviceOrder = [];
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Service Manager');
    }
    /**
     * Initialize service manager
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing service manager...');
            // Start health check interval
            this.startHealthCheckInterval();
            this.outputChannel.appendLine('Service manager initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize service manager: ${error.message}`);
            throw error;
        }
    }
    /**
     * Register a service
     */
    async registerService(service) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to register service ${service.config.name}: ${error.message}`);
            throw error;
        }
    }
    /**
     * Start a service
     */
    async startService(serviceId) {
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
        }
        catch (error) {
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
    async stopService(serviceId) {
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
        }
        catch (error) {
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
    getService(serviceId) {
        return this.services.get(serviceId);
    }
    /**
     * Get all services
     */
    getServices() {
        return Array.from(this.services.values());
    }
    /**
     * Get services by status
     */
    getServicesByStatus(state) {
        return Array.from(this.services.values()).filter(s => s.status.state === state);
    }
    /**
     * Get service status
     */
    getServiceStatus(serviceId) {
        const service = this.services.get(serviceId);
        return service ? service.status : undefined;
    }
    /**
     * Update service order based on dependencies and priority
     */
    updateServiceOrder() {
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
    getDependentServices(serviceId) {
        const dependentServices = [];
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
    startHealthCheckInterval() {
        this.healthCheckInterval = setInterval(async () => {
            await this.performHealthChecks();
        }, 30000); // Check every 30 seconds
    }
    /**
     * Perform health checks on all services
     */
    async performHealthChecks() {
        for (const service of this.services.values()) {
            if (service.status.state === 'running' && service.config.healthCheck?.enabled) {
                try {
                    if (service.healthCheck) {
                        const isHealthy = await service.healthCheck();
                        service.status.healthStatus = isHealthy ? 'healthy' : 'unhealthy';
                    }
                    else {
                        service.status.healthStatus = 'healthy';
                    }
                    // Update metrics
                    if (service.getMetrics) {
                        service.status.metrics = service.getMetrics();
                    }
                    this.emit('serviceHealthChecked', service);
                }
                catch (error) {
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
    dispose() {
        // Stop health check interval
        if (this.healthCheckInterval) {
            clearInterval(this.healthCheckInterval);
        }
        // Stop all services
        const stopPromises = [];
        for (const service of this.services.values()) {
            if (service.status.state === 'running') {
                stopPromises.push(this.stopService(service.config.id));
            }
        }
        Promise.all(stopPromises).then(() => {
            // Dispose all services
            const disposePromises = [];
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
exports.ServiceManager = ServiceManager;
//# sourceMappingURL=serviceManager.js.map