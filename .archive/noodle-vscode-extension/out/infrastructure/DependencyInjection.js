"use strict";
/**
 * NoodleCore Dependency Injection System
 *
 * Provides IoC container for managing dependencies,
 * service lifetime, and automatic resolution.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.autoWire = exports.createContainer = exports.InjectProperty = exports.Inject = exports.Injectable = exports.setContainer = exports.getContainer = exports.DependencyInjectionContainer = exports.ServiceLifetime = void 0;
const events_1 = require("events");
var ServiceLifetime;
(function (ServiceLifetime) {
    ServiceLifetime["Transient"] = "transient";
    ServiceLifetime["Singleton"] = "singleton";
    ServiceLifetime["Scoped"] = "scoped";
})(ServiceLifetime = exports.ServiceLifetime || (exports.ServiceLifetime = {}));
class DependencyInjectionContainer extends events_1.EventEmitter {
    constructor() {
        super();
        this.services = new Map();
        this.contexts = [];
        this.disposables = [];
        this.currentContext = this.createContext();
    }
    /**
     * Register a service with the container
     */
    register(token, factory, lifetime = ServiceLifetime.Transient, dependencies) {
        if (this.services.has(token)) {
            throw new Error(`Service ${token} is already registered`);
        }
        const descriptor = {
            token,
            factory,
            lifetime,
            dependencies
        };
        this.services.set(token, {
            descriptor,
            instance: null,
            resolved: false
        });
        this.emit('serviceRegistered', { token, descriptor });
    }
    /**
     * Register a singleton service
     */
    registerSingleton(token, factory, dependencies) {
        this.register(token, factory, ServiceLifetime.Singleton, dependencies);
    }
    /**
     * Register a scoped service
     */
    registerScoped(token, factory, dependencies) {
        this.register(token, factory, ServiceLifetime.Scoped, dependencies);
    }
    /**
     * Resolve a service by token
     */
    resolve(token) {
        const registration = this.services.get(token);
        if (!registration) {
            throw new Error(`Service ${token} is not registered`);
        }
        return this.resolveService(registration);
    }
    /**
     * Try to resolve a service (returns null if not found)
     */
    tryResolve(token) {
        try {
            return this.resolve(token);
        }
        catch {
            return null;
        }
    }
    /**
     * Check if a service is registered
     */
    isRegistered(token) {
        return this.services.has(token);
    }
    /**
     * Get all registered service tokens
     */
    getRegisteredTokens() {
        return Array.from(this.services.keys());
    }
    /**
     * Create a new injection context
     */
    createContext(parent) {
        const context = {
            requestScope: new Map(),
            parent
        };
        this.contexts.push(context);
        return context;
    }
    /**
     * Set the current injection context
     */
    setContext(context) {
        this.currentContext = context;
    }
    /**
     * Get the current injection context
     */
    getContext() {
        return this.currentContext;
    }
    /**
     * Add a scoped service to the current context
     */
    addToContext(token, instance) {
        this.currentContext.requestScope.set(token, instance);
    }
    /**
     * Get a scoped service from the current context
     */
    getFromContext(token) {
        return this.currentContext.requestScope.get(token) || null;
    }
    /**
     * Create a child container
     */
    createChild() {
        const child = new DependencyInjectionContainer();
        child.services = new Map(this.services); // Copy service registrations
        // Copy context stack
        child.contexts = [...this.contexts];
        child.currentContext = this.createContext(this.currentContext);
        return child;
    }
    /**
     * Register a decorator for property injection
     */
    injectable(token, lifetime = ServiceLifetime.Transient) {
        return (target, propertyKey) => {
            const constructor = target.constructor;
            // Store metadata for later resolution
            if (!constructor._injectedProperties) {
                constructor._injectedProperties = [];
            }
            constructor._injectedProperties.push({
                token,
                propertyKey,
                lifetime
            });
        };
    }
    /**
     * Create a decorator for constructor injection
     */
    inject(...tokens) {
        return (target, propertyKey, parameterIndex) => {
            const constructor = target.constructor;
            // Store metadata for later resolution
            if (!constructor._injectedParameters) {
                constructor._injectedParameters = [];
            }
            constructor._injectedParameters.push({
                tokens,
                parameterIndex
            });
        };
    }
    /**
     * Resolve a service instance
     */
    resolveService(registration) {
        // Check for circular dependencies
        this.checkForCircularDependencies(registration.descriptor);
        switch (registration.descriptor.lifetime) {
            case ServiceLifetime.Singleton:
                return this.resolveSingleton(registration);
            case ServiceLifetime.Scoped:
                return this.resolveScoped(registration);
            case ServiceLifetime.Transient:
            default:
                return this.resolveTransient(registration);
        }
    }
    /**
     * Resolve singleton service
     */
    resolveSingleton(registration) {
        if (registration.instance) {
            return registration.instance;
        }
        // Resolve dependencies first
        const dependencies = this.resolveDependencies(registration.descriptor.dependencies);
        // Create instance with dependencies
        const instance = this.createInstance(registration.descriptor.factory, dependencies);
        registration.instance = instance;
        registration.resolved = true;
        this.emit('serviceResolved', { token: registration.descriptor.token, instance, lifetime: ServiceLifetime.Singleton });
        return instance;
    }
    /**
     * Resolve scoped service
     */
    resolveScoped(registration) {
        // Check if already in current context
        const scopedInstance = this.getFromContext(registration.descriptor.token);
        if (scopedInstance) {
            return scopedInstance;
        }
        // Resolve dependencies
        const dependencies = this.resolveDependencies(registration.descriptor.dependencies);
        // Create instance with dependencies
        const instance = this.createInstance(registration.descriptor.factory, dependencies);
        // Add to current context
        this.addToContext(registration.descriptor.token, instance);
        this.emit('serviceResolved', { token: registration.descriptor.token, instance, lifetime: ServiceLifetime.Scoped });
        return instance;
    }
    /**
     * Resolve transient service
     */
    resolveTransient(registration) {
        // Resolve dependencies
        const dependencies = this.resolveDependencies(registration.descriptor.dependencies);
        // Create new instance every time
        const instance = this.createInstance(registration.descriptor.factory, dependencies);
        this.emit('serviceResolved', { token: registration.descriptor.token, instance, lifetime: ServiceLifetime.Transient });
        return instance;
    }
    /**
     * Resolve service dependencies
     */
    resolveDependencies(dependencies) {
        if (!dependencies || dependencies.length === 0) {
            return [];
        }
        return dependencies.map(dep => this.resolve(dep));
    }
    /**
     * Create service instance with dependencies
     */
    createInstance(factory, dependencies) {
        if (dependencies.length === 0) {
            return factory();
        }
        // Use apply to pass dependencies as arguments
        return factory.apply(null, dependencies);
    }
    /**
     * Check for circular dependencies
     */
    checkForCircularDependencies(descriptor) {
        if (!descriptor.dependencies || descriptor.dependencies.length === 0) {
            return;
        }
        const visited = new Set();
        const visiting = new Set();
        const visit = (token) => {
            if (visited.has(token)) {
                return; // Already processed
            }
            if (visiting.has(token)) {
                throw new Error(`Circular dependency detected: ${Array.from(visiting).join(' -> ')} -> ${token}`);
            }
            visiting.add(token);
            const registration = this.services.get(token);
            if (registration?.descriptor.dependencies) {
                for (const dep of registration.descriptor.dependencies) {
                    visit(dep);
                }
            }
            visiting.delete(token);
            visited.add(token);
        };
        for (const dep of descriptor.dependencies) {
            visit(dep);
        }
    }
    /**
     * Dispose container and cleanup resources
     */
    dispose() {
        // Call all disposables
        this.disposables.forEach(dispose => dispose());
        this.disposables = [];
        // Clear all contexts
        this.contexts = [];
        this.currentContext = this.createContext();
        // Clear service instances
        for (const registration of this.services.values()) {
            if (registration.instance && typeof registration.instance.dispose === 'function') {
                registration.instance.dispose();
            }
        }
        this.services.clear();
        this.removeAllListeners();
    }
    /**
     * Add cleanup function to be called on disposal
     */
    addCleanup(cleanup) {
        this.disposables.push(cleanup);
    }
    /**
     * Remove cleanup function
     */
    removeCleanup(cleanup) {
        const index = this.disposables.indexOf(cleanup);
        if (index !== -1) {
            this.disposables.splice(index, 1);
            return true;
        }
        return false;
    }
    /**
     * Get container statistics
     */
    getStatistics() {
        const resolvedCount = Array.from(this.services.values())
            .filter(reg => reg.resolved).length;
        const scopedCount = this.currentContext.requestScope.size;
        return {
            registeredServices: this.services.size,
            resolvedServices: resolvedCount,
            activeContexts: this.contexts.length,
            scopedServices: scopedCount
        };
    }
    /**
     * Create initial context
     */
    createContext(parent) {
        return {
            requestScope: new Map(),
            parent
        };
    }
}
exports.DependencyInjectionContainer = DependencyInjectionContainer;
// Global container instance
let globalContainer = null;
/**
 * Get the global dependency injection container
 */
function getContainer() {
    if (!globalContainer) {
        globalContainer = new DependencyInjectionContainer();
    }
    return globalContainer;
}
exports.getContainer = getContainer;
/**
 * Set the global dependency injection container
 */
function setContainer(container) {
    globalContainer = container;
}
exports.setContainer = setContainer;
/**
 * Decorator for marking classes as injectable
 */
function Injectable(token, lifetime = ServiceLifetime.Transient) {
    return function (target) {
        target._injectableToken = token;
        target._injectableLifetime = lifetime;
        return target;
    };
}
exports.Injectable = Injectable;
/**
 * Decorator for constructor parameter injection
 */
function Inject(token) {
    return function (target, propertyKey, parameterIndex) {
        // This will be processed by the container during instance creation
        return target;
    };
}
exports.Inject = Inject;
/**
 * Decorator for property injection
 */
function InjectProperty(token) {
    return function (target, propertyKey) {
        // This will be processed by the container during instance creation
        return target;
    };
}
exports.InjectProperty = InjectProperty;
/**
 * Utility function to create and configure a container with common services
 */
function createContainer() {
    const container = new DependencyInjectionContainer();
    // Register common infrastructure services
    container.registerSingleton('ServiceManager', () => {
        const { ServiceManager } = require('./ServiceManager');
        return new ServiceManager(null); // Will be properly initialized later
    });
    container.registerSingleton('EventBus', () => {
        const { EventBus } = require('./EventBus');
        return new EventBus();
    });
    container.registerSingleton('ResourceManager', () => {
        const { ResourceManager } = require('./ResourceManager');
        return new ResourceManager();
    });
    container.registerSingleton('ConfigurationManager', () => {
        const { ConfigurationManager } = require('./ConfigurationManager');
        return new ConfigurationManager('', 'development'); // Will be properly initialized later
    });
    container.registerSingleton('ErrorHandler', () => {
        const { ErrorHandler } = require('./ErrorHandler');
        return new ErrorHandler();
    });
    container.registerSingleton('PerformanceMonitor', () => {
        const { PerformanceMonitor } = require('./PerformanceMonitor');
        return new PerformanceMonitor();
    });
    return container;
}
exports.createContainer = createContainer;
/**
 * Utility function to auto-wire a class with dependency injection
 */
function autoWire(constructor, container = getContainer()) {
    const paramTypes = Reflect.getMetadata('design:paramtypes', constructor) || [];
    const injectedParams = constructor._injectedParameters || [];
    const args = [];
    for (let i = 0; i < paramTypes.length; i++) {
        const injectedParam = injectedParams.find(p => p.parameterIndex === i);
        if (injectedParam) {
            // Resolve dependency from container
            const dependency = container.resolve(injectedParam.tokens[0]);
            args.push(dependency);
        }
        else {
            // Use default parameter type
            args.push(null); // Will be replaced by actual arguments
        }
    }
    return new constructor(...args);
}
exports.autoWire = autoWire;
//# sourceMappingURL=DependencyInjection.js.map