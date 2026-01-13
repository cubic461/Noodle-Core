"use strict";
/**
 * NoodleCore Caching Strategies
 *
 * Implements various caching strategies for AI responses,
 * LSP communication, and other performance-critical operations.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.LSPCommunicationCache = exports.AIResponseCache = exports.CacheManager = exports.MultiLevelCache = exports.RedisCache = exports.MemoryLRUCache = void 0;
const events_1 = require("events");
/**
 * Memory-based LRU Cache
 */
class MemoryLRUCache extends events_1.EventEmitter {
    constructor(options = {}) {
        super();
        this.options = options;
        this.cache = new Map();
        this.accessOrder = [];
        this.currentSize = number;
        this.maxSize = options.maxSize || 1000;
        this.stats = this.initializeStats();
    }
    async get(key) {
        const entry = this.cache.get(key);
        if (!entry) {
            this.updateStats(false);
            return undefined;
        }
        // Check expiration
        if (entry.expiresAt && Date.now() > entry.expiresAt) {
            this.cache.delete(key);
            this.updateAccessOrder(key);
            this.updateStats(false);
            return undefined;
        }
        // Update access order and stats
        entry.accessCount++;
        entry.timestamp = Date.now();
        this.updateAccessOrder(key);
        this.updateStats(true);
        return entry.value;
    }
    async set(key, value, options = {}) {
        const size = this.calculateSize(value);
        const now = Date.now();
        // Check if we need to evict entries
        while (this.currentSize + size > this.maxSize && this.cache.size > 0) {
            this.evictLRU();
        }
        const entry = {
            key,
            value,
            timestamp: now,
            expiresAt: options.ttl ? now + options.ttl : undefined,
            accessCount: 1,
            size,
            metadata: options.metadata
        };
        this.cache.set(key, entry);
        this.updateAccessOrder(key);
        this.currentSize += size;
        this.stats.sets++;
        this.emit('set', { key, size: this.currentSize });
    }
    async delete(key) {
        const entry = this.cache.get(key);
        if (!entry) {
            return false;
        }
        this.currentSize -= entry.size;
        this.cache.delete(key);
        this.stats.deletes++;
        this.emit('delete', { key, size: this.currentSize });
        return true;
    }
    async clear() {
        this.cache.clear();
        this.accessOrder = [];
        this.currentSize = 0;
        this.stats = this.initializeStats();
        this.emit('clear');
    }
    async getStats() {
        return Promise.resolve({ ...this.stats });
    }
    evictLRU() {
        let lruKey = null;
        let lruTime = Date.now();
        for (const [key, entry] of this.cache.entries()) {
            if (entry.timestamp < lruTime) {
                lruTime = entry.timestamp;
                lruKey = key;
            }
        }
        if (lruKey) {
            const evictedEntry = this.cache.get(lruKey);
            this.cache.delete(lruKey);
            this.currentSize -= evictedEntry.size;
            this.stats.evictions++;
            this.emit('evict', { key: lruKey, size: evictedEntry.size });
        }
    }
    updateAccessOrder(key) {
        // Remove from current position
        const index = this.accessOrder.indexOf(key);
        if (index !== -1) {
            this.accessOrder.splice(index, 1);
        }
        // Add to end
        this.accessOrder.push(key);
    }
    updateStats(hit) {
        if (hit) {
            this.stats.hits++;
        }
        else {
            this.stats.misses++;
        }
        this.stats.hitRate = this.stats.hits / (this.stats.hits + this.stats.misses) * 100;
    }
    calculateSize(value) {
        if (value === null || value === undefined) {
            return 0;
        }
        if (typeof value === 'string') {
            return value.length * 2; // Approximate Unicode size
        }
        if (typeof value === 'object') {
            return JSON.stringify(value).length * 2;
        }
        return 8; // Basic types
    }
    initializeStats() {
        return {
            hits: 0,
            misses: 0,
            sets: 0,
            deletes: 0,
            evictions: 0,
            hitRate: 0,
            currentSize: 0,
            maxSize: this.maxSize
        };
    }
    async dispose() {
        this.cache.clear();
        this.removeAllListeners();
    }
}
exports.MemoryLRUCache = MemoryLRUCache;
/**
 * Redis-based Distributed Cache
 */
class RedisCache extends events_1.EventEmitter {
    constructor(options = {}) {
        super();
        this.options = options;
        this.keyPrefix = options.keyPrefix || 'noodle:';
        this.defaultTTL = options.ttl || 3600; // 1 hour default
        this.stats = this.initializeStats();
        this.initializeRedis();
    }
    async get(key) {
        try {
            const fullKey = this.keyPrefix + key;
            const value = await this.redis.get(fullKey);
            if (value) {
                this.updateStats(true);
                return JSON.parse(value);
            }
            else {
                this.updateStats(false);
                return undefined;
            }
        }
        catch (error) {
            this.emit('error', { operation: 'get', key, error });
            return undefined;
        }
    }
    async set(key, value, options = {}) {
        try {
            const fullKey = this.keyPrefix + key;
            const serialized = JSON.stringify(value);
            const ttl = options.ttl || this.defaultTTL;
            await this.redis.setex(fullKey, ttl, serialized);
            this.stats.sets++;
            this.emit('set', { key, ttl });
        }
        catch (error) {
            this.emit('error', { operation: 'set', key, error });
        }
    }
    async delete(key) {
        try {
            const fullKey = this.keyPrefix + key;
            const result = await this.redis.del(fullKey);
            if (result > 0) {
                this.stats.deletes++;
                this.emit('delete', { key });
                return true;
            }
            return false;
        }
        catch (error) {
            this.emit('error', { operation: 'delete', key, error });
            return false;
        }
    }
    async clear() {
        try {
            const pattern = this.keyPrefix + '*';
            const keys = await this.redis.keys(pattern);
            if (keys.length > 0) {
                await this.redis.del(...keys);
                this.stats.deletes += keys.length;
            }
            this.emit('clear', { keys: keys.length });
        }
        catch (error) {
            this.emit('error', { operation: 'clear', error });
        }
    }
    async getStats() {
        try {
            const info = await this.redis.info('memory');
            const usedMemory = parseInt(info.used_memory || '0');
            const maxMemory = parseInt(info.maxmemory || '0');
            return Promise.resolve({
                ...this.stats,
                currentSize: usedMemory,
                maxSize: maxMemory
            });
        }
        catch (error) {
            this.emit('error', { operation: 'getStats', error });
            return this.initializeStats();
        }
    }
    async initializeRedis() {
        // This would initialize Redis connection
        // For now, we'll simulate with a simple object
        this.redis = {
            get: async (key) => Promise.resolve(null),
            setex: async (key, ttl, value) => Promise.resolve('OK'),
            del: async (...keys) => Promise.resolve(keys.length),
            keys: async (pattern) => Promise.resolve([]),
            info: async (section) => Promise.resolve({
                used_memory: '1024000',
                maxmemory: '16777216'
            })
        };
    }
    initializeStats() {
        return {
            hits: 0,
            misses: 0,
            sets: 0,
            deletes: 0,
            evictions: 0,
            hitRate: 0,
            currentSize: 0,
            maxSize: 0
        };
    }
    async dispose() {
        if (this.redis && typeof this.redis.quit === 'function') {
            await this.redis.quit();
        }
        this.removeAllListeners();
    }
}
exports.RedisCache = RedisCache;
/**
 * Multi-level Cache with automatic fallback
 */
class MultiLevelCache extends events_1.EventEmitter {
    constructor(levels) {
        super();
        this.currentLevel = 0;
        this.levels = levels;
    }
    async get(key) {
        // Try each level from fastest to slowest
        for (let i = this.currentLevel; i < this.levels.length; i++) {
            const result = await this.levels[i].get(key);
            if (result !== undefined) {
                this.currentLevel = i; // Promote this level
                return result;
            }
        }
        this.updateStats(false);
        return undefined;
    }
    async set(key, value, options = {}) {
        // Set in current level
        await this.levels[this.currentLevel].set(key, value, options);
        this.updateStats(true);
    }
    async delete(key) {
        // Delete from current level
        const result = await this.levels[this.currentLevel].delete(key);
        this.updateStats(result);
        return result;
    }
    async clear() {
        // Clear all levels
        for (const level of this.levels) {
            await level.clear();
        }
        this.updateStats(false);
    }
    async getStats() {
        // Aggregate stats from all levels
        let totalStats = this.initializeStats();
        for (const level of this.levels) {
            const stats = await level.getStats();
            totalStats.hits += stats.hits;
            totalStats.misses += stats.misses;
            totalStats.sets += stats.sets;
            totalStats.deletes += stats.deletes;
            totalStats.evictions += stats.evictions;
        }
        totalStats.hitRate = totalStats.hits / (totalStats.hits + totalStats.misses) * 100;
        return Promise.resolve(totalStats);
    }
    updateStats(hit) {
        // This would update internal statistics
        // Implementation depends on specific requirements
    }
    initializeStats() {
        return {
            hits: 0,
            misses: 0,
            sets: 0,
            deletes: 0,
            evictions: 0,
            hitRate: 0,
            currentSize: 0,
            maxSize: 0
        };
    }
    async dispose() {
        for (const level of this.levels) {
            await level.dispose();
        }
        this.removeAllListeners();
    }
}
exports.MultiLevelCache = MultiLevelCache;
/**
 * Cache Manager - Factory for creating appropriate cache strategies
 */
class CacheManager extends events_1.EventEmitter {
    constructor() {
        super();
        this.strategies = new Map();
        this.defaultStrategy = 'memory-lru';
        this.registerDefaultStrategies();
    }
    /**
     * Register a cache strategy
     */
    registerStrategy(name, strategy) {
        this.strategies.set(name, strategy);
        this.emit('strategyRegistered', { name, strategy });
    }
    /**
     * Get a cache strategy by name
     */
    getStrategy(name) {
        return this.strategies.get(name);
    }
    /**
     * Create a cache instance with specified strategy
     */
    createCache(strategyName = this.defaultStrategy, options) {
        const strategy = this.strategies.get(strategyName);
        if (!strategy) {
            throw new Error(`Cache strategy '${strategyName}' not found`);
        }
        // Create instance based on strategy type
        if (strategy instanceof MemoryLRUCache) {
            return new MemoryLRUCache(options);
        }
        else if (strategy instanceof RedisCache) {
            return new RedisCache(options);
        }
        else if (strategy instanceof MultiLevelCache) {
            return new MultiLevelCache(options);
        }
        throw new Error(`Unknown cache strategy type: ${strategyName}`);
    }
    /**
     * Set default cache strategy
     */
    setDefaultStrategy(name) {
        if (!this.strategies.has(name)) {
            throw new Error(`Cache strategy '${name}' not found`);
        }
        this.defaultStrategy = name;
        this.emit('defaultStrategyChanged', { name });
    }
    /**
     * Get default cache strategy
     */
    getDefaultStrategy() {
        return this.defaultStrategy;
    }
    /**
     * Get all registered strategies
     */
    getStrategies() {
        return Array.from(this.strategies.keys());
    }
    registerDefaultStrategies() {
        // Register built-in strategies
        this.registerStrategy('memory-lru', new MemoryLRUCache());
        this.registerStrategy('redis', new RedisCache());
        this.registerStrategy('multi-level', new MultiLevelCache([
            new MemoryLRUCache({ maxSize: 100 }),
            new RedisCache({ ttl: 300 })
        ]));
    }
    /**
     * Dispose all cache strategies
     */
    async dispose() {
        const disposePromises = Array.from(this.strategies.values())
            .map(strategy => strategy.dispose());
        await Promise.all(disposePromises);
        this.strategies.clear();
        this.removeAllListeners();
    }
}
exports.CacheManager = CacheManager;
/**
 * AI Response Cache - Specialized cache for AI responses
 */
class AIResponseCache extends events_1.EventEmitter {
    constructor() {
        super();
        this.responseCache = new Map();
        this.promptCache = new Map();
        this.cache = new CacheManager();
        this.cache.setDefaultStrategy('memory-lru');
    }
    /**
     * Cache AI response
     */
    async cacheResponse(prompt, response, options = {}) {
        const key = this.generateResponseKey(prompt);
        const cacheOptions = {
            ttl: options.ttl || 300000,
            tags: options.tags,
            metadata: { prompt, timestamp: Date.now() }
        };
        await this.cache.set(key, response, cacheOptions);
        this.emit('responseCached', { prompt, key });
    }
    /**
     * Get cached AI response
     */
    async getCachedResponse(prompt) {
        const key = this.generateResponseKey(prompt);
        return await this.cache.get(key);
    }
    /**
     * Cache AI prompt (for deduplication)
     */
    async cachePrompt(prompt, options = {}) {
        const key = this.generatePromptKey(prompt);
        const cacheOptions = {
            ttl: options.ttl || 600000,
            tags: options.tags,
            metadata: { timestamp: Date.now() }
        };
        await this.cache.set(key, prompt, cacheOptions);
        this.emit('promptCached', { prompt, key });
    }
    /**
     * Get cached prompt
     */
    async getCachedPrompt(prompt) {
        const key = this.generatePromptKey(prompt);
        const entry = await this.cache.get(key);
        return entry ? entry.value : undefined;
    }
    /**
     * Invalidate cache by tags
     */
    async invalidateByTags(tags) {
        // This would require cache strategy support for tag-based invalidation
        this.emit('invalidatedByTags', { tags });
    }
    /**
     * Get cache statistics
     */
    async getStats() {
        const stats = await this.cache.getStats();
        return {
            responses: stats,
            prompts: stats,
            combined: stats
        };
    }
    /**
     * Clear all caches
     */
    async clear() {
        await this.cache.clear();
        this.responseCache.clear();
        this.promptCache.clear();
        this.emit('cleared');
    }
    generateResponseKey(prompt) {
        // Generate hash-based key for prompt
        return `response:${this.hashString(prompt)}`;
    }
    generatePromptKey(prompt) {
        // Generate hash-based key for prompt
        return `prompt:${this.hashString(prompt)}`;
    }
    hashString(str) {
        // Simple hash function for cache keys
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash).toString(36);
    }
    async dispose() {
        await this.cache.dispose();
        this.removeAllListeners();
    }
}
exports.AIResponseCache = AIResponseCache;
/**
 * LSP Communication Cache - Specialized cache for LSP operations
 */
class LSPCommunicationCache extends events_1.EventEmitter {
    constructor() {
        super();
        this.requestCache = new Map();
        this.diagnosticsCache = new Map();
        this.cache = new CacheManager();
        this.cache.setDefaultStrategy('memory-lru');
    }
    /**
     * Cache LSP request
     */
    async cacheRequest(uri, method, params, response, options = {}) {
        const key = this.generateRequestKey(uri, method);
        const cacheOptions = {
            ttl: options.ttl || 30000,
            metadata: { uri, method, timestamp: Date.now() }
        };
        await this.cache.set(key, response, cacheOptions);
        this.emit('requestCached', { uri, method, key });
    }
    /**
     * Get cached LSP request
     */
    async getCachedRequest(uri, method) {
        const key = this.generateRequestKey(uri, method);
        return await this.cache.get(key);
    }
    /**
     * Cache LSP diagnostics
     */
    async cacheDiagnostics(uri, diagnostics, options = {}) {
        const key = this.generateDiagnosticsKey(uri);
        const cacheOptions = {
            ttl: options.ttl || 10000,
            metadata: { uri, timestamp: Date.now() }
        };
        await this.cache.set(key, diagnostics, cacheOptions);
        this.emit('diagnosticsCached', { uri, count: diagnostics.length });
    }
    /**
     * Get cached diagnostics
     */
    async getCachedDiagnostics(uri) {
        const key = this.generateDiagnosticsKey(uri);
        const entry = await this.cache.get(key);
        return entry ? entry.value : undefined;
    }
    /**
     * Invalidate cache for URI
     */
    async invalidateURI(uri) {
        const keys = [];
        // Find and invalidate all entries for this URI
        for (const [key, entry] of this.requestCache.entries()) {
            if (entry.metadata && entry.metadata.uri === uri) {
                keys.push(key);
            }
        }
        for (const [key, entry] of this.diagnosticsCache.entries()) {
            if (entry.metadata && entry.metadata.uri === uri) {
                keys.push(key);
            }
        }
        if (keys.length > 0) {
            for (const key of keys) {
                await this.cache.delete(key);
            }
        }
        this.emit('uriInvalidated', { uri, keys: keys.length });
    }
    /**
     * Get cache statistics
     */
    async getStats() {
        const stats = await this.cache.getStats();
        return {
            requests: stats,
            diagnostics: stats,
            combined: stats
        };
    }
    /**
     * Clear all caches
     */
    async clear() {
        await this.cache.clear();
        this.requestCache.clear();
        this.diagnosticsCache.clear();
        this.emit('cleared');
    }
    generateRequestKey(uri, method) {
        return `lsp:request:${this.hashString(uri)}:${method}`;
    }
    generateDiagnosticsKey(uri) {
        return `lsp:diagnostics:${this.hashString(uri)}`;
    }
    hashString(str) {
        // Simple hash function for cache keys
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash).toString(36);
    }
    async dispose() {
        await this.cache.dispose();
        this.removeAllListeners();
    }
}
exports.LSPCommunicationCache = LSPCommunicationCache;
//# sourceMappingURL=CachingStrategies.js.map