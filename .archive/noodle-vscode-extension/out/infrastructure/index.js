"use strict";
/**
 * NoodleCore Infrastructure Index
 *
 * Central entry point for all infrastructure components.
 * Exports all infrastructure modules for easy importing.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.initializeInfrastructure = exports.getInfrastructure = exports.InfrastructureFactory = exports.setContainer = exports.getContainer = exports.createContainer = exports.autoWire = exports.InjectProperty = exports.Inject = exports.Injectable = exports.ServiceLifetime = exports.DependencyInjectionContainer = exports.PerformanceTestRunner = exports.E2ETestRunner = exports.IntegrationTestRunner = exports.UnitTestRunner = exports.BaseTestRunner = exports.TestStatus = exports.TestType = exports.TestingFramework = exports.PerformanceMonitor = exports.ErrorCategory = exports.ErrorSeverity = exports.ErrorHandler = exports.SecurityConfig = exports.PerformanceConfig = exports.LSPConfig = exports.AIConfig = exports.DatabaseConfig = exports.EnvironmentConfig = exports.NoodleConfiguration = exports.ConfigurationManager = exports.ResourceManager = exports.EventFilter = exports.EventHandler = exports.TypedEvent = exports.EventBus = exports.ServiceRegistry = exports.ServiceLifecycle = exports.ServiceDescriptor = exports.ServiceManager = void 0;
var ServiceManager_1 = require("./ServiceManager");
Object.defineProperty(exports, "ServiceManager", { enumerable: true, get: function () { return ServiceManager_1.ServiceManager; } });
Object.defineProperty(exports, "ServiceDescriptor", { enumerable: true, get: function () { return ServiceManager_1.ServiceDescriptor; } });
Object.defineProperty(exports, "ServiceLifecycle", { enumerable: true, get: function () { return ServiceManager_1.ServiceLifecycle; } });
Object.defineProperty(exports, "ServiceRegistry", { enumerable: true, get: function () { return ServiceManager_1.ServiceRegistry; } });
var EventBus_1 = require("./EventBus");
Object.defineProperty(exports, "EventBus", { enumerable: true, get: function () { return EventBus_1.EventBus; } });
Object.defineProperty(exports, "TypedEvent", { enumerable: true, get: function () { return EventBus_1.TypedEvent; } });
Object.defineProperty(exports, "EventHandler", { enumerable: true, get: function () { return EventBus_1.EventHandler; } });
Object.defineProperty(exports, "EventFilter", { enumerable: true, get: function () { return EventBus_1.EventFilter; } });
var ResourceManager_1 = require("./ResourceManager");
Object.defineProperty(exports, "ResourceManager", { enumerable: true, get: function () { return ResourceManager_1.ResourceManager; } });
var ConfigurationManager_1 = require("./ConfigurationManager");
Object.defineProperty(exports, "ConfigurationManager", { enumerable: true, get: function () { return ConfigurationManager_1.ConfigurationManager; } });
Object.defineProperty(exports, "NoodleConfiguration", { enumerable: true, get: function () { return ConfigurationManager_1.NoodleConfiguration; } });
Object.defineProperty(exports, "EnvironmentConfig", { enumerable: true, get: function () { return ConfigurationManager_1.EnvironmentConfig; } });
Object.defineProperty(exports, "DatabaseConfig", { enumerable: true, get: function () { return ConfigurationManager_1.DatabaseConfig; } });
Object.defineProperty(exports, "AIConfig", { enumerable: true, get: function () { return ConfigurationManager_1.AIConfig; } });
Object.defineProperty(exports, "LSPConfig", { enumerable: true, get: function () { return ConfigurationManager_1.LSPConfig; } });
Object.defineProperty(exports, "PerformanceConfig", { enumerable: true, get: function () { return ConfigurationManager_1.PerformanceConfig; } });
Object.defineProperty(exports, "SecurityConfig", { enumerable: true, get: function () { return ConfigurationManager_1.SecurityConfig; } });
var ErrorHandler_1 = require("./ErrorHandler");
Object.defineProperty(exports, "ErrorHandler", { enumerable: true, get: function () { return ErrorHandler_1.ErrorHandler; } });
Object.defineProperty(exports, "ErrorSeverity", { enumerable: true, get: function () { return ErrorHandler_1.ErrorSeverity; } });
Object.defineProperty(exports, "ErrorCategory", { enumerable: true, get: function () { return ErrorHandler_1.ErrorCategory; } });
var PerformanceMonitor_1 = require("./PerformanceMonitor");
Object.defineProperty(exports, "PerformanceMonitor", { enumerable: true, get: function () { return PerformanceMonitor_1.PerformanceMonitor; } });
var TestingFramework_1 = require("./TestingFramework");
Object.defineProperty(exports, "TestingFramework", { enumerable: true, get: function () { return TestingFramework_1.TestingFramework; } });
Object.defineProperty(exports, "TestType", { enumerable: true, get: function () { return TestingFramework_1.TestType; } });
Object.defineProperty(exports, "TestStatus", { enumerable: true, get: function () { return TestingFramework_1.TestStatus; } });
Object.defineProperty(exports, "BaseTestRunner", { enumerable: true, get: function () { return TestingFramework_1.BaseTestRunner; } });
Object.defineProperty(exports, "UnitTestRunner", { enumerable: true, get: function () { return TestingFramework_1.UnitTestRunner; } });
Object.defineProperty(exports, "IntegrationTestRunner", { enumerable: true, get: function () { return TestingFramework_1.IntegrationTestRunner; } });
Object.defineProperty(exports, "E2ETestRunner", { enumerable: true, get: function () { return TestingFramework_1.E2ETestRunner; } });
Object.defineProperty(exports, "PerformanceTestRunner", { enumerable: true, get: function () { return TestingFramework_1.PerformanceTestRunner; } });
var DependencyInjection_1 = require("./DependencyInjection");
Object.defineProperty(exports, "DependencyInjectionContainer", { enumerable: true, get: function () { return DependencyInjection_1.DependencyInjectionContainer; } });
Object.defineProperty(exports, "ServiceLifetime", { enumerable: true, get: function () { return DependencyInjection_1.ServiceLifetime; } });
Object.defineProperty(exports, "Injectable", { enumerable: true, get: function () { return DependencyInjection_1.Injectable; } });
Object.defineProperty(exports, "Inject", { enumerable: true, get: function () { return DependencyInjection_1.Inject; } });
Object.defineProperty(exports, "InjectProperty", { enumerable: true, get: function () { return DependencyInjection_1.InjectProperty; } });
Object.defineProperty(exports, "autoWire", { enumerable: true, get: function () { return DependencyInjection_1.autoWire; } });
Object.defineProperty(exports, "createContainer", { enumerable: true, get: function () { return DependencyInjection_1.createContainer; } });
Object.defineProperty(exports, "getContainer", { enumerable: true, get: function () { return DependencyInjection_1.getContainer; } });
Object.defineProperty(exports, "setContainer", { enumerable: true, get: function () { return DependencyInjection_1.setContainer; } });
/**
 * Infrastructure Factory
 *
 * Creates and configures all infrastructure components
 * with proper dependencies and initialization.
 */
class InfrastructureFactory {
    constructor() {
        this.container = createContainer();
        this.initializeComponents();
    }
    /**
     * Get singleton instance of InfrastructureFactory
     */
    static getInstance() {
        if (!InfrastructureFactory.instance) {
            InfrastructureFactory.instance = new InfrastructureFactory();
        }
        return InfrastructureFactory.instance;
    }
    /**
     * Initialize all infrastructure components
     */
    initializeComponents() {
        // Register all infrastructure services with the container
        this.registerInfrastructureServices();
        // Initialize core components
        this.serviceManager = this.container.resolve('ServiceManager');
        this.eventBus = this.container.resolve('EventBus');
        this.resourceManager = this.container.resolve('ResourceManager');
        this.configurationManager = this.container.resolve('ConfigurationManager');
        this.errorHandler = this.container.resolve('ErrorHandler');
        this.performanceMonitor = this.container.resolve('PerformanceMonitor');
        this.testingFramework = this.container.resolve('TestingFramework');
        // Setup cross-component communication
        this.setupComponentCommunication();
    }
    /**
     * Register infrastructure services with dependency injection
     */
    registerInfrastructureServices() {
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
    setupComponentCommunication() {
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
    getServiceManager() {
        return this.serviceManager;
    }
    /**
     * Get event bus instance
     */
    getEventBus() {
        return this.eventBus;
    }
    /**
     * Get resource manager instance
     */
    getResourceManager() {
        return this.resourceManager;
    }
    /**
     * Get configuration manager instance
     */
    getConfigurationManager() {
        return this.configurationManager;
    }
    /**
     * Get error handler instance
     */
    getErrorHandler() {
        return this.errorHandler;
    }
    /**
     * Get performance monitor instance
     */
    getPerformanceMonitor() {
        return this.performanceMonitor;
    }
    /**
     * Get testing framework instance
     */
    getTestingFramework() {
        return this.testingFramework;
    }
    /**
     * Get dependency injection container
     */
    getContainer() {
        return this.container;
    }
    /**
     * Initialize all infrastructure components
     */
    async initialize(workspaceRoot) {
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
        }
        catch (error) {
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
    setupGlobalErrorHandling() {
        // Handle uncaught exceptions
        process.on('uncaughtException', (error) => {
            this.errorHandler.handleError(error, {
                component: 'Process',
                operation: 'uncaught.exception'
            });
        });
        // Handle unhandled promise rejections
        process.on('unhandledRejection', (reason, promise) => {
            this.errorHandler.handleError(reason instanceof Error ? reason : new Error(String(reason)), {
                component: 'Process',
                operation: 'unhandled.promise.rejection',
                additionalData: { promise: promise.toString() }
            });
        });
    }
    /**
     * Dispose all infrastructure components
     */
    async dispose() {
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
        }
        catch (error) {
            console.error('Error during infrastructure disposal:', error);
        }
    }
}
exports.InfrastructureFactory = InfrastructureFactory;
InfrastructureFactory.instance = null;
/**
 * Convenience function to get infrastructure factory instance
 */
function getInfrastructure() {
    return InfrastructureFactory.getInstance();
}
exports.getInfrastructure = getInfrastructure;
/**
 * Convenience function to initialize infrastructure
 */
async function initializeInfrastructure(workspaceRoot) {
    const infrastructure = getInfrastructure();
    await infrastructure.initialize(workspaceRoot);
}
exports.initializeInfrastructure = initializeInfrastructure;
//# sourceMappingURL=index.js.map