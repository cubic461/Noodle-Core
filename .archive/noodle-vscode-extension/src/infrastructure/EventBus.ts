/**
 * Event Bus for Noodle VS Code Extension
 * 
 * Provides a centralized event system for communication
 * between different components and services.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';

export interface EventData {
    [key: string]: any;
}

export interface EventSubscription {
    id: string;
    event: string;
    handler: (data: EventData) => void;
    once?: boolean;
    priority?: number;
}

export interface EventBusConfig {
    maxListeners?: number;
    enableLogging?: boolean;
    logLevel?: 'debug' | 'info' | 'warn' | 'error';
}

export class EventBus extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private subscriptions: Map<string, EventSubscription[]> = new Map();
    private config: EventBusConfig;
    private subscriptionCounter = 0;
    
    constructor(config?: EventBusConfig) {
        super();
        this.config = {
            maxListeners: 100,
            enableLogging: true,
            logLevel: 'info',
            ...config
        };
        
        this.outputChannel = vscode.window.createOutputChannel('Noodle Event Bus');
        
        // Set max listeners
        if (this.config.maxListeners) {
            this.setMaxListeners(this.config.maxListeners);
        }
    }
    
    /**
     * Initialize event bus
     */
    public initialize(): void {
        try {
            this.outputChannel.appendLine('Initializing event bus...');
            
            // Register error handler
            this.on('error', (error) => {
                this.outputChannel.appendLine(`Event bus error: ${error.message}`);
                if (this.config.logLevel === 'debug') {
                    this.outputChannel.appendLine(error.stack || 'No stack trace available');
                }
            });
            
            this.outputChannel.appendLine('Event bus initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize event bus: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Subscribe to an event
     */
    public subscribe(event: string, handler: (data: EventData) => void, options?: { once?: boolean; priority?: number }): string {
        try {
            const subscriptionId = `sub_${++this.subscriptionCounter}`;
            const subscription: EventSubscription = {
                id: subscriptionId,
                event,
                handler,
                once: options?.once,
                priority: options?.priority || 0
            };
            
            // Add to subscriptions
            if (!this.subscriptions.has(event)) {
                this.subscriptions.set(event, []);
            }
            
            const eventSubscriptions = this.subscriptions.get(event)!;
            eventSubscriptions.push(subscription);
            
            // Sort by priority (higher priority first)
            eventSubscriptions.sort((a, b) => (b.priority || 0) - (a.priority || 0));
            
            // Register with EventEmitter
            if (subscription.once) {
                this.once(event, handler);
            } else {
                this.on(event, handler);
            }
            
            this.logEvent('subscribe', event, { subscriptionId, priority: subscription.priority });
            
            return subscriptionId;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to subscribe to event ${event}: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Unsubscribe from an event
     */
    public unsubscribe(subscriptionId: string): boolean {
        try {
            for (const [event, subscriptions] of this.subscriptions.entries()) {
                const index = subscriptions.findIndex(sub => sub.id === subscriptionId);
                if (index !== -1) {
                    const subscription = subscriptions[index];
                    
                    // Remove from EventEmitter
                    this.removeListener(event, subscription.handler);
                    
                    // Remove from subscriptions
                    subscriptions.splice(index, 1);
                    
                    // Clean up empty event arrays
                    if (subscriptions.length === 0) {
                        this.subscriptions.delete(event);
                    }
                    
                    this.logEvent('unsubscribe', event, { subscriptionId });
                    return true;
                }
            }
            
            return false;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to unsubscribe ${subscriptionId}: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Unsubscribe all handlers for an event
     */
    public unsubscribeAll(event: string): number {
        try {
            const subscriptions = this.subscriptions.get(event);
            if (!subscriptions) {
                return 0;
            }
            
            const count = subscriptions.length;
            
            // Remove all from EventEmitter
            this.removeAllListeners(event);
            
            // Remove from subscriptions
            this.subscriptions.delete(event);
            
            this.logEvent('unsubscribeAll', event, { count });
            return count;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to unsubscribe all from event ${event}: ${error.message}`);
            return 0;
        }
    }
    
    /**
     * Publish an event
     */
    public publish(event: string, data?: EventData): void {
        try {
            this.logEvent('publish', event, data);
            
            // Emit event
            this.emit(event, data || {});
            
            // Clean up one-time subscriptions
            this.cleanupOnceSubscriptions(event);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to publish event ${event}: ${error.message}`);
        }
    }
    
    /**
     * Publish an event asynchronously
     */
    public async publishAsync(event: string, data?: EventData): Promise<void> {
        try {
            this.logEvent('publishAsync', event, data);
            
            // Get subscriptions
            const subscriptions = this.subscriptions.get(event) || [];
            
            // Execute handlers in parallel
            const promises = subscriptions.map(async (subscription) => {
                try {
                    await subscription.handler(data || {});
                } catch (error) {
                    this.outputChannel.appendLine(`Error in event handler for ${event}: ${error.message}`);
                }
            });
            
            await Promise.all(promises);
            
            // Clean up one-time subscriptions
            this.cleanupOnceSubscriptions(event);
        } catch (error) {
            this.outputChannel.appendLine(`Failed to publish event ${event} asynchronously: ${error.message}`);
        }
    }
    
    /**
     * Get subscriptions for an event
     */
    public getSubscriptions(event: string): EventSubscription[] {
        return this.subscriptions.get(event) || [];
    }
    
    /**
     * Get all subscriptions
     */
    public getAllSubscriptions(): Map<string, EventSubscription[]> {
        return new Map(this.subscriptions);
    }
    
    /**
     * Get subscription count
     */
    public getSubscriptionCount(event?: string): number {
        if (event) {
            return this.subscriptions.get(event)?.length || 0;
        } else {
            let total = 0;
            for (const subscriptions of this.subscriptions.values()) {
                total += subscriptions.length;
            }
            return total;
        }
    }
    
    /**
     * Check if event has subscribers
     */
    public hasSubscribers(event: string): boolean {
        const subscriptions = this.subscriptions.get(event);
        return subscriptions && subscriptions.length > 0;
    }
    
    /**
     * Get event names
     */
    public getEventNames(): string[] {
        return Array.from(this.subscriptions.keys());
    }
    
    /**
     * Clear all subscriptions
     */
    public clear(): void {
        try {
            // Remove all listeners
            this.removeAllListeners();
            
            // Clear subscriptions
            this.subscriptions.clear();
            
            this.logEvent('clear', 'eventBus', {});
        } catch (error) {
            this.outputChannel.appendLine(`Failed to clear event bus: ${error.message}`);
        }
    }
    
    /**
     * Create a scoped event bus
     */
    public createScope(scope: string): ScopedEventBus {
        return new ScopedEventBus(this, scope);
    }
    
    /**
     * Clean up one-time subscriptions
     */
    private cleanupOnceSubscriptions(event: string): void {
        const subscriptions = this.subscriptions.get(event);
        if (!subscriptions) {
            return;
        }
        
        const onceSubscriptions = subscriptions.filter(sub => sub.once);
        for (const subscription of onceSubscriptions) {
            this.unsubscribe(subscription.id);
        }
    }
    
    /**
     * Log event
     */
    private logEvent(action: string, event: string, data?: any): void {
        if (!this.config.enableLogging) {
            return;
        }
        
        const logMessage = `[${new Date().toISOString()}] ${action}: ${event}`;
        
        if (this.config.logLevel === 'debug' && data) {
            this.outputChannel.appendLine(`${logMessage} - ${JSON.stringify(data)}`);
        } else {
            this.outputChannel.appendLine(logMessage);
        }
    }
    
    /**
     * Dispose event bus
     */
    public dispose(): void {
        this.clear();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}

/**
 * Scoped Event Bus
 * 
 * Provides a scoped event bus that prefixes all events with a scope.
 */
export class ScopedEventBus {
    private eventBus: EventBus;
    private scope: string;
    private subscriptions: string[] = [];
    
    constructor(eventBus: EventBus, scope: string) {
        this.eventBus = eventBus;
        this.scope = scope;
    }
    
    /**
     * Subscribe to a scoped event
     */
    public subscribe(event: string, handler: (data: EventData) => void, options?: { once?: boolean; priority?: number }): string {
        const scopedEvent = `${this.scope}.${event}`;
        const subscriptionId = this.eventBus.subscribe(scopedEvent, handler, options);
        this.subscriptions.push(subscriptionId);
        return subscriptionId;
    }
    
    /**
     * Unsubscribe from a scoped event
     */
    public unsubscribe(subscriptionId: string): boolean {
        const index = this.subscriptions.indexOf(subscriptionId);
        if (index !== -1) {
            this.subscriptions.splice(index, 1);
            return this.eventBus.unsubscribe(subscriptionId);
        }
        return false;
    }
    
    /**
     * Publish a scoped event
     */
    public publish(event: string, data?: EventData): void {
        const scopedEvent = `${this.scope}.${event}`;
        this.eventBus.publish(scopedEvent, data);
    }
    
    /**
     * Publish a scoped event asynchronously
     */
    public async publishAsync(event: string, data?: EventData): Promise<void> {
        const scopedEvent = `${this.scope}.${event}`;
        await this.eventBus.publishAsync(scopedEvent, data);
    }
    
    /**
     * Get subscriptions for a scoped event
     */
    public getSubscriptions(event: string): EventSubscription[] {
        const scopedEvent = `${this.scope}.${event}`;
        return this.eventBus.getSubscriptions(scopedEvent);
    }
    
    /**
     * Check if scoped event has subscribers
     */
    public hasSubscribers(event: string): boolean {
        const scopedEvent = `${this.scope}.${event}`;
        return this.eventBus.hasSubscribers(scopedEvent);
    }
    
    /**
     * Clear all scoped subscriptions
     */
    public clear(): void {
        for (const subscriptionId of this.subscriptions) {
            this.eventBus.unsubscribe(subscriptionId);
        }
        this.subscriptions = [];
    }
    
    /**
     * Get scope
     */
    public getScope(): string {
        return this.scope;
    }
}