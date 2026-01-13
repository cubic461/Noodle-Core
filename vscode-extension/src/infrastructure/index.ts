/**
 * NoodleCore Infrastructure Index
 * 
 * Central entry point for all infrastructure components.
 * Exports all infrastructure modules for easy importing.
 */

export { ServiceManager, ServiceDescriptor, ServiceLifecycle, ServiceRegistry } from './ServiceManager';
export { EventBus, TypedEvent, EventHandler, EventSubscription, EventFilter, EventData } from './EventBus';
export { ResourceManager, ResourceMetrics, ResourceThresholds, ResourceQuota, CacheEntry } from './ResourceManager';
export { ConfigurationManager, NoodleConfiguration, EnvironmentConfig, DatabaseConfig, AIConfig, LSPConfig, PerformanceConfig, SecurityConfig } from './ConfigurationManager';
export { ErrorHandler, NoodleError, ErrorSeverity, ErrorCategory, ErrorContext, ErrorRecoveryStrategy, ErrorPattern, ErrorStatistics } from './ErrorHandler';
export { PerformanceMonitor, PerformanceMetrics, PerformanceProfile, PerformanceAlert, PerformanceReport, PerformanceThreshold } from './PerformanceMonitor';
export { TestingFramework, TestResult, TestSuite, TestRunner, TestType, TestStatus, AssertionResult, CoverageData, PerformanceData, TestRunnerConfig, BaseTestRunner, UnitTestRunner, IntegrationTestRunner, E2ETestRunner, PerformanceTestRunner } from './TestingFramework';
export { DependencyInjectionContainer, ServiceLifetime, ServiceRegistration, InjectionContext, Injectable, Inject, InjectProperty, autoWire, createContainer, getContainer, setContainer } from './DependencyInjection';

/**
 * Infrastructure Factory
 * 
 * Creates and configures all infrastructure components
 * with proper dependencies and initialization.
 */
export class InfrastructureFactory {
    private static instance: InfrastructureFactory | null = null;
    private container: DependencyInjectionContainer;
    private serviceManager: ServiceManager;
    private eventBus: EventBus;
    private resourceManager: ResourceManager;
    private configurationManager: ConfigurationManager;
    private errorHandler: ErrorHandler;
    private performanceMonitor: PerformanceMonitor;
    private testingFramework: TestingFramework;

    private constructor() {
        this.container = createContainer();
        this.initializeComponents();
    }

    /**
     * Get singleton instance of InfrastructureFactory
     */
    public static getInstance(): InfrastructureFactory {
        if (!InfrastructureFactory.instance) {
            InfrastructureFactory.instance = new InfrastructureFactory();
        }
        return InfrastructureFactory.instance;
    }

    /**
     * Initialize all infrastructure components
     */
    private initializeComponents(): void {
        // Register all infrastructure services with the container
        this.registerInfrastructureServices();

        // Initialize core components
        this.serviceManager = this.container.resolve<ServiceManager>('ServiceManager');
        this.eventBus = this.container.resolve<EventBus>('EventBus');
        this.resourceManager = this.container.resolve<ResourceManager>('ResourceManager');
        this.configurationManager = this.container.resolve<ConfigurationManager>('ConfigurationManager');
        this.errorHandler = this.container.resolve<ErrorHandler>('ErrorHandler');
        this.performanceMonitor = this.container.resolve<PerformanceMonitor>('PerformanceMonitor');
        this.testingFramework = this.container.resolve<TestingFramework>('TestingFramework');

        // Setup cross-component communication
        this.setupComponentCommunication();
    }

    /**
     * Register infrastructure services with dependency injection
     */
    private registerInfrastructureServices(): void {
        // Service Manager
        this.container.registerSingleton('ServiceManager', () => {
            const { ServiceManager } = require('./ServiceManager');
            return new ServiceManager(null); // Context will be set later
        }, ['EventBus', 'ResourceManager', 'ConfigurationManager', 'ErrorHandler', 'PerformanceMonitor', 'TestingFramework']);

        // Event Bus
        this.container.registerSingleton('EventBus', () => {
            const { EventBus } = require('./EventBus');
            return new EventBus();
        });

        // Resource Manager
        this.container.registerSingleton('ResourceManager', () => {
            const { ResourceManager } = require('./ResourceManager');
            return new ResourceManager();
        });

        // Configuration Manager
        this.container.registerSingleton('ConfigurationManager', () => {
            const { ConfigurationManager } = require('./ConfigurationManager');
            return new ConfigurationManager('', 'development'); // Will be properly initialized later
        });

        // Error Handler
        this.container.registerSingleton('ErrorHandler', () => {
            const { ErrorHandler } = require('./ErrorHandler');
            return new ErrorHandler();
        });

        // Performance Monitor
        this.container.registerSingleton('PerformanceMonitor', () => {
            const { PerformanceMonitor } = require('./PerformanceMonitor');
            return new PerformanceMonitor();
        });

        // Testing Framework
        this.container.registerSingleton('TestingFramework', () => {
            const { TestingFramework } = require('./TestingFramework');
            return new TestingFramework();
        });
    }

    /**
     * Setup communication between components
     */
    private setupComponentCommunication(): void {
        // Service Manager events
        this.serviceManager.on('error', (error) => {
            this.errorHandler.handleError(error.error, error.context || { component: 'ServiceManager', operation: 'unknown' });
        });

        this.serviceManager.on('serviceInitialized', (serviceDescriptor) => {
            this.eventBus.publish('service.initialized', {
                service: ServiceDescriptor.name,
                timestamp: new Date().toISOString()
            });
        });

        // Event Bus events
        this.eventBus.on('error', (event) => {
            this.errorHandler.handleError(event.data.error, {
                component: 'EventBus',
                operation: 'event.processing'
            });
        });

        // Resource Manager events
        this.resourceManager.on('resourceCritical', (event) => {
            this.errorHandler.handleError(new Error(event.data.message), {
                component: 'ResourceManager',
                operation: 'resource.management'
            });
        });

        this.resourceManager.on('resourceWarning', (event) => {
            this.eventBus.publish('resource.warning', event.data);
        });

        // Configuration Manager events
        this.configurationManager.on('configError', (event) => {
            this.errorHandler.handleError(event.data.error, {
                component: 'ConfigurationManager',
                operation: 'configuration.management'
            });
        });

        this.configurationManager.on('configChanged', (event) => {
            this.eventBus.publish('configuration.changed', event.data);
        });

        // Performance Monitor events
        this.performanceMonitor.on('alert', (event) => {
            if (event.data.type === 'critical') {
                this.errorHandler.handleError(new Error(event.data.message), {
                    component: 'PerformanceMonitor',
                    operation: 'performance.monitoring'
                });
            }
        });

        // Error Handler events
        this.errorHandler.on('error', (event) => {
            this.eventBus.publish('system.error', event.data);
        });

        this.errorHandler.on('errorResolved', (event) => {
            this.eventBus.publish('error.resolved', event.data);
        });
    }

    /**
     * Get service manager instance
     */
    public getServiceManager(): ServiceManager {
        return this.serviceManager;
    }

    /**
     * Get event bus instance
     */
    public getEventBus(): EventBus {
        return this.eventBus;
    }

    /**
     * Get resource manager instance
     */
    public getResourceManager(): ResourceManager {
        return this.resourceManager;
    }

    /**
     * Get configuration manager instance
     */
    public getConfigurationManager(): ConfigurationManager {
        return this.configurationManager;
    }

    /**
     * Get error handler instance
     */
    public getErrorHandler(): ErrorHandler {
        return this.errorHandler;
    }

    /**
     * Get performance monitor instance
     */
    public getPerformanceMonitor(): PerformanceMonitor {
        return this.performanceMonitor;
    }

    /**
     * Get testing framework instance
     */
    public getTestingFramework(): TestingFramework {
        return this.testingFramework;
    }

    /**
     * Get dependency injection container
     */
    public getContainer(): DependencyInjectionContainer {
        return this.container;
    }

    /**
     * Initialize all infrastructure components
     */
    public async initialize(workspaceRoot: string): Promise<void> {
        try {
            // Initialize configuration manager first
            await this.configurationManager.load();
            
            // Start resource monitoring
            this.resourceManager.startMonitoring();
            
            // Start performance monitoring
            this.performanceMonitor.startMonitoring();
            
            // Initialize service manager
            await this.serviceManager.initialize();
            
            // Setup error handling
            this.setupGlobalErrorHandling();
            
            this.eventBus.publish('infrastructure.initialized', {
                timestamp: new Date().toISOString(),
                components: [
                    'ServiceManager',
                    'EventBus',
                    'ResourceManager',
                    'ConfigurationManager',
                    'ErrorHandler',
                    'PerformanceMonitor',
                    'TestingFramework'
                ]
            });

        } catch (error) {
            this.errorHandler.handleError(error, {
                component: 'InfrastructureFactory',
                operation: 'initialization'
            });
            throw error;
        }
    }

    /**
     * Setup global error handling
     */
    private setupGlobalErrorHandling(): void {
        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.errorHandler.handleError(error, {
                component: 'Process',
                operation: 'uncaught.exception'
            });
        });

        // Handle unhandled promise rejections
        process.on('unhandledRejection', (reason, promise) => {
            this.errorHandler.handleError(
                reason instanceof Error ? reason : new Error(String(reason)),
                {
                    component: 'Process',
                    operation: 'unhandled.promise.rejection',
                    additionalData: { promise: promise.toString() }
                }
            );
        });
    }

    /**
     * Dispose all infrastructure components
     */
    public async dispose(): Promise<void> {
        try {
            // Stop monitoring
            this.resourceManager.stopMonitoring();
            this.performanceMonitor.stopMonitoring();
            
            // Dispose all components
            this.serviceManager.dispose();
            this.eventBus.dispose();
            this.resourceManager.dispose();
            this.configurationManager.dispose();
            this.errorHandler.dispose();
            this.performanceMonitor.dispose();
            this.testingFramework.dispose();
            this.container.dispose();
            
        } catch (error) {
            console.error('Error during infrastructure disposal:', error);
        }
    }
}

/**
 * Convenience function to get infrastructure factory instance
 */
export function getInfrastructure(): InfrastructureFactory {
    return InfrastructureFactory.getInstance();
}

/**
 * Convenience function to initialize infrastructure
 */
export async function initializeInfrastructure(workspaceRoot: string): Promise<void> {
    const infrastructure = getInfrastructure();
    await infrastructure.initialize(workspaceRoot);
}