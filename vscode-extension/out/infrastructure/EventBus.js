"use strict";
/**
 * Event Bus for Noodle VS Code Extension
 *
 * Provides a centralized event system for communication
 * between different components and services.
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
exports.ScopedEventBus = exports.EventBus = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
class EventBus extends events_1.EventEmitter {
    constructor(config) {
        super();
        this.subscriptions = new Map();
        this.subscriptionCounter = 0;
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
    initialize() {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize event bus: ${error.message}`);
            throw error;
        }
    }
    /**
     * Subscribe to an event
     */
    subscribe(event, handler, options) {
        try {
            const subscriptionId = `sub_${++this.subscriptionCounter}`;
            const subscription = {
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
            const eventSubscriptions = this.subscriptions.get(event);
            eventSubscriptions.push(subscription);
            // Sort by priority (higher priority first)
            eventSubscriptions.sort((a, b) => (b.priority || 0) - (a.priority || 0));
            // Register with EventEmitter
            if (subscription.once) {
                this.once(event, handler);
            }
            else {
                this.on(event, handler);
            }
            this.logEvent('subscribe', event, { subscriptionId, priority: subscription.priority });
            return subscriptionId;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to subscribe to event ${event}: ${error.message}`);
            throw error;
        }
    }
    /**
     * Unsubscribe from an event
     */
    unsubscribe(subscriptionId) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to unsubscribe ${subscriptionId}: ${error.message}`);
            return false;
        }
    }
    /**
     * Unsubscribe all handlers for an event
     */
    unsubscribeAll(event) {
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
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to unsubscribe all from event ${event}: ${error.message}`);
            return 0;
        }
    }
    /**
     * Publish an event
     */
    publish(event, data) {
        try {
            this.logEvent('publish', event, data);
            // Emit event
            this.emit(event, data || {});
            // Clean up one-time subscriptions
            this.cleanupOnceSubscriptions(event);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to publish event ${event}: ${error.message}`);
        }
    }
    /**
     * Publish an event asynchronously
     */
    async publishAsync(event, data) {
        try {
            this.logEvent('publishAsync', event, data);
            // Get subscriptions
            const subscriptions = this.subscriptions.get(event) || [];
            // Execute handlers in parallel
            const promises = subscriptions.map(async (subscription) => {
                try {
                    await subscription.handler(data || {});
                }
                catch (error) {
                    this.outputChannel.appendLine(`Error in event handler for ${event}: ${error.message}`);
                }
            });
            await Promise.all(promises);
            // Clean up one-time subscriptions
            this.cleanupOnceSubscriptions(event);
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to publish event ${event} asynchronously: ${error.message}`);
        }
    }
    /**
     * Get subscriptions for an event
     */
    getSubscriptions(event) {
        return this.subscriptions.get(event) || [];
    }
    /**
     * Get all subscriptions
     */
    getAllSubscriptions() {
        return new Map(this.subscriptions);
    }
    /**
     * Get subscription count
     */
    getSubscriptionCount(event) {
        if (event) {
            return this.subscriptions.get(event)?.length || 0;
        }
        else {
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
    hasSubscribers(event) {
        const subscriptions = this.subscriptions.get(event);
        return subscriptions && subscriptions.length > 0;
    }
    /**
     * Get event names
     */
    getEventNames() {
        return Array.from(this.subscriptions.keys());
    }
    /**
     * Clear all subscriptions
     */
    clear() {
        try {
            // Remove all listeners
            this.removeAllListeners();
            // Clear subscriptions
            this.subscriptions.clear();
            this.logEvent('clear', 'eventBus', {});
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to clear event bus: ${error.message}`);
        }
    }
    /**
     * Create a scoped event bus
     */
    createScope(scope) {
        return new ScopedEventBus(this, scope);
    }
    /**
     * Clean up one-time subscriptions
     */
    cleanupOnceSubscriptions(event) {
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
    logEvent(action, event, data) {
        if (!this.config.enableLogging) {
            return;
        }
        const logMessage = `[${new Date().toISOString()}] ${action}: ${event}`;
        if (this.config.logLevel === 'debug' && data) {
            this.outputChannel.appendLine(`${logMessage} - ${JSON.stringify(data)}`);
        }
        else {
            this.outputChannel.appendLine(logMessage);
        }
    }
    /**
     * Dispose event bus
     */
    dispose() {
        this.clear();
        this.outputChannel.dispose();
        this.removeAllListeners();
    }
}
exports.EventBus = EventBus;
/**
 * Scoped Event Bus
 *
 * Provides a scoped event bus that prefixes all events with a scope.
 */
class ScopedEventBus {
    constructor(eventBus, scope) {
        this.subscriptions = [];
        this.eventBus = eventBus;
        this.scope = scope;
    }
    /**
     * Subscribe to a scoped event
     */
    subscribe(event, handler, options) {
        const scopedEvent = `${this.scope}.${event}`;
        const subscriptionId = this.eventBus.subscribe(scopedEvent, handler, options);
        this.subscriptions.push(subscriptionId);
        return subscriptionId;
    }
    /**
     * Unsubscribe from a scoped event
     */
    unsubscribe(subscriptionId) {
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
    publish(event, data) {
        const scopedEvent = `${this.scope}.${event}`;
        this.eventBus.publish(scopedEvent, data);
    }
    /**
     * Publish a scoped event asynchronously
     */
    async publishAsync(event, data) {
        const scopedEvent = `${this.scope}.${event}`;
        await this.eventBus.publishAsync(scopedEvent, data);
    }
    /**
     * Get subscriptions for a scoped event
     */
    getSubscriptions(event) {
        const scopedEvent = `${this.scope}.${event}`;
        return this.eventBus.getSubscriptions(scopedEvent);
    }
    /**
     * Check if scoped event has subscribers
     */
    hasSubscribers(event) {
        const scopedEvent = `${this.scope}.${event}`;
        return this.eventBus.hasSubscribers(scopedEvent);
    }
    /**
     * Clear all scoped subscriptions
     */
    clear() {
        for (const subscriptionId of this.subscriptions) {
            this.eventBus.unsubscribe(subscriptionId);
        }
        this.subscriptions = [];
    }
    /**
     * Get scope
     */
    getScope() {
        return this.scope;
    }
}
exports.ScopedEventBus = ScopedEventBus;
//# sourceMappingURL=EventBus.js.map