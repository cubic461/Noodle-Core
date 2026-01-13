/**
 * NoodleCore Dependency Injection System
 * 
 * Provides IoC container for managing dependencies,
 * service lifetime, and automatic resolution.
 */

import { EventEmitter } from 'events';

export enum ServiceLifetime {
    Transient = 'transient',
    Singleton = 'singleton',
    Scoped = 'scoped'
}

export interface ServiceDescriptor {
    token: string;
    factory: () => any;
    lifetime: ServiceLifetime;
    dependencies?: string[];
}

export interface ServiceRegistration {
    descriptor: ServiceDescriptor;
    instance: any;
    resolved: boolean;
}

export interface InjectionContext {
    requestScope: Map<string, any>;
    parent?: InjectionContext;
}

export class DependencyInjectionContainer extends EventEmitter {
    private services = new Map<string, ServiceRegistration>();
    private contexts: InjectionContext[] = [];
    private currentContext: InjectionContext;
    private disposables: (() => void)[] = [];

    constructor() {
        super();
        this.currentContext = this.createContext();
    }

    /**
     * Register a service with the container
     */
    public register(token: string, factory: () => any, lifetime: ServiceLifetime = ServiceLifetime.Transient, dependencies?: string[]): void {
        if (this.services.has(token)) {
            throw new Error(`Service ${token} is already registered`);
        }

        const descriptor: ServiceDescriptor = {
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
    public registerSingleton(token: string, factory: () => any, dependencies?: string[]): void {
        this.register(token, factory, ServiceLifetime.Singleton, dependencies);
    }

    /**
     * Register a scoped service
     */
    public registerScoped(token: string, factory: () => any, dependencies?: string[]): void {
        this.register(token, factory, ServiceLifetime.Scoped, dependencies);
    }

    /**
     * Resolve a service by token
     */
    public resolve<T = any>(token: string): T {
        const registration = this.services.get(token);
        if (!registration) {
            throw new Error(`Service ${token} is not registered`);
        }

        return this.resolveService<T>(registration);
    }

    /**
     * Try to resolve a service (returns null if not found)
     */
    public tryResolve<T = any>(token: string): T | null {
        try {
            return this.resolve<T>(token);
        } catch {
            return null;
        }
    }

    /**
     * Check if a service is registered
     */
    public isRegistered(token: string): boolean {
        return this.services.has(token);
    }

    /**
     * Get all registered service tokens
     */
    public getRegisteredTokens(): string[] {
        return Array.from(this.services.keys());
    }

    /**
     * Create a new injection context
     */
    public createContext(parent?: InjectionContext): InjectionContext {
        const context: InjectionContext = {
            requestScope: new Map(),
            parent
        };

        this.contexts.push(context);
        return context;
    }

    /**
     * Set the current injection context
     */
    public setContext(context: InjectionContext): void {
        this.currentContext = context;
    }

    /**
     * Get the current injection context
     */
    public getContext(): InjectionContext {
        return this.currentContext;
    }

    /**
     * Add a scoped service to the current context
     */
    public addToContext<T = any>(token: string, instance: T): void {
        this.currentContext.requestScope.set(token, instance);
    }

    /**
     * Get a scoped service from the current context
     */
    public getFromContext<T = any>(token: string): T | null {
        return this.currentContext.requestScope.get(token) || null;
    }

    /**
     * Create a child container
     */
    public createChild(): DependencyInjectionContainer {
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
    public injectable(token: string, lifetime: ServiceLifetime = ServiceLifetime.Transient) {
        return (target: any, propertyKey: string | symbol) => {
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
    public inject(...tokens: string[]) {
        return (target: any, propertyKey: string | symbol, parameterIndex: number) => {
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
    private resolveService<T>(registration: ServiceRegistration): T {
        // Check for circular dependencies
        this.checkForCircularDependencies(registration.descriptor);

        switch (registration.descriptor.lifetime) {
            case ServiceLifetime.Singleton:
                return this.resolveSingleton<T>(registration);
            case ServiceLifetime.Scoped:
                return this.resolveScoped<T>(registration);
            case ServiceLifetime.Transient:
            default:
                return this.resolveTransient<T>(registration);
        }
    }

    /**
     * Resolve singleton service
     */
    private resolveSingleton<T>(registration: ServiceRegistration): T {
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
    private resolveScoped<T>(registration: ServiceRegistration): T {
        // Check if already in current context
        const scopedInstance = this.getFromContext<T>(registration.descriptor.token);
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
    private resolveTransient<T>(registration: ServiceRegistration): T {
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
    private resolveDependencies(dependencies?: string[]): any[] {
        if (!dependencies || dependencies.length === 0) {
            return [];
        }

        return dependencies.map(dep => this.resolve(dep));
    }

    /**
     * Create service instance with dependencies
     */
    private createInstance(factory: () => any, dependencies: any[]): any {
        if (dependencies.length === 0) {
            return factory();
        }

        // Use apply to pass dependencies as arguments
        return factory.apply(null, dependencies);
    }

    /**
     * Check for circular dependencies
     */
    private checkForCircularDependencies(descriptor: ServiceDescriptor): void {
        if (!descriptor.dependencies || descriptor.dependencies.length === 0) {
            return;
        }

        const visited = new Set<string>();
        const visiting = new Set<string>();

        const visit = (token: string) => {
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
    public dispose(): void {
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
    public addCleanup(cleanup: () => void): void {
        this.disposables.push(cleanup);
    }

    /**
     * Remove cleanup function
     */
    public removeCleanup(cleanup: () => void): boolean {
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
    public getStatistics(): {
        registeredServices: number;
        resolvedServices: number;
        activeContexts: number;
        scopedServices: number;
    } {
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
    private createContext(parent?: InjectionContext): InjectionContext {
        return {
            requestScope: new Map(),
            parent
        };
    }
}

// Global container instance
let globalContainer: DependencyInjectionContainer | null = null;

/**
 * Get the global dependency injection container
 */
export function getContainer(): DependencyInjectionContainer {
    if (!globalContainer) {
        globalContainer = new DependencyInjectionContainer();
    }
    return globalContainer;
}

/**
 * Set the global dependency injection container
 */
export function setContainer(container: DependencyInjectionContainer): void {
    globalContainer = container;
}

/**
 * Decorator for marking classes as injectable
 */
export function Injectable(token: string, lifetime: ServiceLifetime = ServiceLifetime.Transient) {
    return function (target: any) {
        target._injectableToken = token;
        target._injectableLifetime = lifetime;
        return target;
    };
}

/**
 * Decorator for constructor parameter injection
 */
export function Inject(token: string) {
    return function (target: any, propertyKey: string | symbol, parameterIndex: number) {
        // This will be processed by the container during instance creation
        return target;
    };
}

/**
 * Decorator for property injection
 */
export function InjectProperty(token: string) {
    return function (target: any, propertyKey: string | symbol) {
        // This will be processed by the container during instance creation
        return target;
    };
}

/**
 * Utility function to create and configure a container with common services
 */
export function createContainer(): DependencyInjectionContainer {
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

/**
 * Utility function to auto-wire a class with dependency injection
 */
export function autoWire<T>(constructor: new (...args: any[]) => T, container: DependencyInjectionContainer = getContainer()): T {
    const paramTypes = Reflect.getMetadata('design:paramtypes', constructor) || [];
    const injectedParams = constructor._injectedParameters || [];

    const args: any[] = [];
    
    for (let i = 0; i < paramTypes.length; i++) {
        const injectedParam = injectedParams.find(p => p.parameterIndex === i);
        
        if (injectedParam) {
            // Resolve dependency from container
            const dependency = container.resolve(injectedParam.tokens[0]);
            args.push(dependency);
        } else {
            // Use default parameter type
            args.push(null); // Will be replaced by actual arguments
        }
    }

    return new constructor(...args);
}