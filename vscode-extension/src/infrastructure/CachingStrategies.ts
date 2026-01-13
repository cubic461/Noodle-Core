/**
 * NoodleCore Caching Strategies
 * 
 * Implements various caching strategies for AI responses,
 * LSP communication, and other performance-critical operations.
 */

import { EventEmitter } from 'events';

export interface CacheEntry<T = any> {
    key: string;
    value: T;
    timestamp: number;
    expiresAt: number;
    accessCount: number;
    size: number;
    metadata?: any;
}

export interface CacheStats {
    hits: number;
    misses: number;
    sets: number;
    deletes: number;
    evictions: number;
    hitRate: number;
    currentSize: number;
    maxSize: number;
}

export interface CacheStrategy {
    name: string;
    get<T = any>(key: string): Promise<T | undefined>;
    set<T = any>(key: string, value: T, options?: CacheSetOptions): Promise<void>;
    delete(key: string): Promise<boolean>;
    clear(): Promise<void>;
    getStats(): Promise<CacheStats>;
    dispose(): Promise<void>;
}

export interface CacheSetOptions {
    ttl?: number;           // Time to live in milliseconds
    priority?: number;     // Higher priority = less likely to evict
    tags?: string[];       // For cache invalidation
    metadata?: any;        // Additional metadata
}

export interface LRUCacheOptions extends CacheSetOptions {
    maxSize: number;        // Maximum cache size in bytes
    maxAge: number;         // Maximum age in milliseconds
}

export interface DistributedCacheOptions extends CacheSetOptions {
    nodeName: string;        // Redis node name
    keyPrefix: string;       // Key prefix for namespacing
    ttl?: number;            // Time to live in seconds
    clusterNodes?: string[];  // Redis cluster nodes
}

/**
 * Memory-based LRU Cache
 */
export class MemoryLRUCache<T = any> extends EventEmitter implements CacheStrategy {
    private cache = new Map<string, CacheEntry<T>>();
    private accessOrder: string[] = [];
    private maxSize: number;
    private currentSize = number;
    private stats: CacheStats;

    constructor(private options: LRUCacheOptions = {}) {
        super();
        this.maxSize = options.maxSize || 1000;
        this.stats = this.initializeStats();
    }

    async get(key: string): Promise<T | undefined> {
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

    async set(key: string, value: T, options: CacheSetOptions = {}): Promise<void> {
        const size = this.calculateSize(value);
        const now = Date.now();
        
        // Check if we need to evict entries
        while (this.currentSize + size > this.maxSize && this.cache.size > 0) {
            this.evictLRU();
        }

        const entry: CacheEntry<T> = {
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

    async delete(key: string): Promise<boolean> {
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

    async clear(): Promise<void> {
        this.cache.clear();
        this.accessOrder = [];
        this.currentSize = 0;
        this.stats = this.initializeStats();
        this.emit('clear');
    }

    async getStats(): Promise<CacheStats> {
        return Promise.resolve({ ...this.stats });
    }

    private evictLRU(): void {
        let lruKey: string | null = null;
        let lruTime = Date.now();

        for (const [key, entry] of this.cache.entries()) {
            if (entry.timestamp < lruTime) {
                lruTime = entry.timestamp;
                lruKey = key;
            }
        }

        if (lruKey) {
            const evictedEntry = this.cache.get(lruKey)!;
            this.cache.delete(lruKey);
            this.currentSize -= evictedEntry.size;
            this.stats.evictions++;
            this.emit('evict', { key: lruKey, size: evictedEntry.size });
        }
    }

    private updateAccessOrder(key: string): void {
        // Remove from current position
        const index = this.accessOrder.indexOf(key);
        if (index !== -1) {
            this.accessOrder.splice(index, 1);
        }
        // Add to end
        this.accessOrder.push(key);
    }

    private updateStats(hit: boolean): void {
        if (hit) {
            this.stats.hits++;
        } else {
            this.stats.misses++;
        }

        this.stats.hitRate = this.stats.hits / (this.stats.hits + this.stats.misses) * 100;
    }

    private calculateSize(value: T): number {
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

    private initializeStats(): CacheStats {
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

    async dispose(): Promise<void> {
        this.cache.clear();
        this.removeAllListeners();
    }
}

/**
 * Redis-based Distributed Cache
 */
export class RedisCache<T = any> extends EventEmitter implements CacheStrategy {
    private redis: any; // Redis client
    private keyPrefix: string;
    private defaultTTL: number;
    private stats: CacheStats;

    constructor(private options: DistributedCacheOptions = {}) {
        super();
        this.keyPrefix = options.keyPrefix || 'noodle:';
        this.defaultTTL = options.ttl || 3600; // 1 hour default
        this.stats = this.initializeStats();
        this.initializeRedis();
    }

    async get(key: string): Promise<T | undefined> {
        try {
            const fullKey = this.keyPrefix + key;
            const value = await this.redis.get(fullKey);
            
            if (value) {
                this.updateStats(true);
                return JSON.parse(value);
            } else {
                this.updateStats(false);
                return undefined;
            }
        } catch (error) {
            this.emit('error', { operation: 'get', key, error });
            return undefined;
        }
    }

    async set(key: string, value: T, options: CacheSetOptions = {}): Promise<void> {
        try {
            const fullKey = this.keyPrefix + key;
            const serialized = JSON.stringify(value);
            const ttl = options.ttl || this.defaultTTL;
            
            await this.redis.setex(fullKey, ttl, serialized);
            this.stats.sets++;
            this.emit('set', { key, ttl });
        } catch (error) {
            this.emit('error', { operation: 'set', key, error });
        }
    }

    async delete(key: string): Promise<boolean> {
        try {
            const fullKey = this.keyPrefix + key;
            const result = await this.redis.del(fullKey);
            
            if (result > 0) {
                this.stats.deletes++;
                this.emit('delete', { key });
                return true;
            }
            
            return false;
        } catch (error) {
            this.emit('error', { operation: 'delete', key, error });
            return false;
        }
    }

    async clear(): Promise<void> {
        try {
            const pattern = this.keyPrefix + '*';
            const keys = await this.redis.keys(pattern);
            if (keys.length > 0) {
                await this.redis.del(...keys);
                this.stats.deletes += keys.length;
            }
            this.emit('clear', { keys: keys.length });
        } catch (error) {
            this.emit('error', { operation: 'clear', error });
        }
    }

    async getStats(): Promise<CacheStats> {
        try {
            const info = await this.redis.info('memory');
            const usedMemory = parseInt(info.used_memory || '0');
            const maxMemory = parseInt(info.maxmemory || '0');
            
            return Promise.resolve({
                ...this.stats,
                currentSize: usedMemory,
                maxSize: maxMemory
            });
        } catch (error) {
            this.emit('error', { operation: 'getStats', error });
            return this.initializeStats();
        }
    }

    private async initializeRedis(): Promise<void> {
        // This would initialize Redis connection
        // For now, we'll simulate with a simple object
        this.redis = {
            get: async (key: string) => Promise.resolve(null),
            setex: async (key: string, ttl: number, value: string) => Promise.resolve('OK'),
            del: async (...keys: string[]) => Promise.resolve(keys.length),
            keys: async (pattern: string) => Promise.resolve([]),
            info: async (section: string) => Promise.resolve({
                used_memory: '1024000',
                maxmemory: '16777216'
            })
        };
    }

    private initializeStats(): CacheStats {
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

    async dispose(): Promise<void> {
        if (this.redis && typeof this.redis.quit === 'function') {
            await this.redis.quit();
        }
        this.removeAllListeners();
    }
}

/**
 * Multi-level Cache with automatic fallback
 */
export class MultiLevelCache<T = any> extends EventEmitter implements CacheStrategy {
    private levels: CacheStrategy[];
    private currentLevel: number = 0;

    constructor(levels: CacheStrategy[]) {
        super();
        this.levels = levels;
    }

    async get(key: string): Promise<T | undefined> {
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

    async set(key: string, value: T, options: CacheSetOptions = {}): Promise<void> {
        // Set in current level
        await this.levels[this.currentLevel].set(key, value, options);
        this.updateStats(true);
    }

    async delete(key: string): Promise<boolean> {
        // Delete from current level
        const result = await this.levels[this.currentLevel].delete(key);
        this.updateStats(result);
        return result;
    }

    async clear(): Promise<void> {
        // Clear all levels
        for (const level of this.levels) {
            await level.clear();
        }
        this.updateStats(false);
    }

    async getStats(): Promise<CacheStats> {
        // Aggregate stats from all levels
        let totalStats: CacheStats = this.initializeStats();
        
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

    private updateStats(hit: boolean): void {
        // This would update internal statistics
        // Implementation depends on specific requirements
    }

    private initializeStats(): CacheStats {
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

    async dispose(): Promise<void> {
        for (const level of this.levels) {
            await level.dispose();
        }
        this.removeAllListeners();
    }
}

/**
 * Cache Manager - Factory for creating appropriate cache strategies
 */
export class CacheManager extends EventEmitter {
    private strategies = new Map<string, CacheStrategy>();
    private defaultStrategy: string = 'memory-lru';

    constructor() {
        super();
        this.registerDefaultStrategies();
    }

    /**
     * Register a cache strategy
     */
    public registerStrategy(name: string, strategy: CacheStrategy): void {
        this.strategies.set(name, strategy);
        this.emit('strategyRegistered', { name, strategy });
    }

    /**
     * Get a cache strategy by name
     */
    public getStrategy(name: string): CacheStrategy | undefined {
        return this.strategies.get(name);
    }

    /**
     * Create a cache instance with specified strategy
     */
    public createCache<T = any>(
        strategyName: string = this.defaultStrategy,
        options?: any
    ): CacheStrategy<T> {
        const strategy = this.strategies.get(strategyName);
        if (!strategy) {
            throw new Error(`Cache strategy '${strategyName}' not found`);
        }

        // Create instance based on strategy type
        if (strategy instanceof MemoryLRUCache) {
            return new MemoryLRUCache<T>(options);
        } else if (strategy instanceof RedisCache) {
            return new RedisCache<T>(options);
        } else if (strategy instanceof MultiLevelCache) {
            return new MultiLevelCache<T>(options);
        }

        throw new Error(`Unknown cache strategy type: ${strategyName}`);
    }

    /**
     * Set default cache strategy
     */
    public setDefaultStrategy(name: string): void {
        if (!this.strategies.has(name)) {
            throw new Error(`Cache strategy '${name}' not found`);
        }
        this.defaultStrategy = name;
        this.emit('defaultStrategyChanged', { name });
    }

    /**
     * Get default cache strategy
     */
    public getDefaultStrategy(): string {
        return this.defaultStrategy;
    }

    /**
     * Get all registered strategies
     */
    public getStrategies(): string[] {
        return Array.from(this.strategies.keys());
    }

    private registerDefaultStrategies(): void {
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
    public async dispose(): Promise<void> {
        const disposePromises = Array.from(this.strategies.values())
            .map(strategy => strategy.dispose());

        await Promise.all(disposePromises);
        this.strategies.clear();
        this.removeAllListeners();
    }
}

/**
 * AI Response Cache - Specialized cache for AI responses
 */
export class AIResponseCache extends EventEmitter {
    private cache: CacheManager;
    private responseCache: Map<string, CacheEntry<any>> = new Map();
    private promptCache: Map<string, CacheEntry<string>> = new Map();

    constructor() {
        super();
        this.cache = new CacheManager();
        this.cache.setDefaultStrategy('memory-lru');
    }

    /**
     * Cache AI response
     */
    public async cacheResponse(
        prompt: string,
        response: any,
        options: {
            ttl?: number;
            tags?: string[];
        } = {}
    ): Promise<void> {
        const key = this.generateResponseKey(prompt);
        const cacheOptions = {
            ttl: options.ttl || 300000, // 5 minutes default
            tags: options.tags,
            metadata: { prompt, timestamp: Date.now() }
        };

        await this.cache.set(key, response, cacheOptions);
        this.emit('responseCached', { prompt, key });
    }

    /**
     * Get cached AI response
     */
    public async getCachedResponse(prompt: string): Promise<any | undefined> {
        const key = this.generateResponseKey(prompt);
        return await this.cache.get(key);
    }

    /**
     * Cache AI prompt (for deduplication)
     */
    public async cachePrompt(
        prompt: string,
        options: {
            ttl?: number;
            tags?: string[];
        } = {}
    ): Promise<void> {
        const key = this.generatePromptKey(prompt);
        const cacheOptions = {
            ttl: options.ttl || 600000, // 10 minutes default
            tags: options.tags,
            metadata: { timestamp: Date.now() }
        };

        await this.cache.set(key, prompt, cacheOptions);
        this.emit('promptCached', { prompt, key });
    }

    /**
     * Get cached prompt
     */
    public async getCachedPrompt(prompt: string): Promise<string | undefined> {
        const key = this.generatePromptKey(prompt);
        const entry = await this.cache.get(key);
        return entry ? entry.value : undefined;
    }

    /**
     * Invalidate cache by tags
     */
    public async invalidateByTags(tags: string[]): Promise<void> {
        // This would require cache strategy support for tag-based invalidation
        this.emit('invalidatedByTags', { tags });
    }

    /**
     * Get cache statistics
     */
    public async getStats(): Promise<{
        responses: CacheStats;
        prompts: CacheStats;
        combined: CacheStats;
    }> {
        const stats = await this.cache.getStats();
        
        return {
            responses: stats,
            prompts: stats, // Same stats for now
            combined: stats
        };
    }

    /**
     * Clear all caches
     */
    public async clear(): Promise<void> {
        await this.cache.clear();
        this.responseCache.clear();
        this.promptCache.clear();
        this.emit('cleared');
    }

    private generateResponseKey(prompt: string): string {
        // Generate hash-based key for prompt
        return `response:${this.hashString(prompt)}`;
    }

    private generatePromptKey(prompt: string): string {
        // Generate hash-based key for prompt
        return `prompt:${this.hashString(prompt)}`;
    }

    private hashString(str: string): string {
        // Simple hash function for cache keys
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash).toString(36);
    }

    async dispose(): Promise<void> {
        await this.cache.dispose();
        this.removeAllListeners();
    }
}

/**
 * LSP Communication Cache - Specialized cache for LSP operations
 */
export class LSPCommunicationCache extends EventEmitter {
    private cache: CacheManager;
    private requestCache: Map<string, CacheEntry<any>> = new Map();
    private diagnosticsCache: Map<string, CacheEntry<any[]>> = new Map();

    constructor() {
        super();
        this.cache = new CacheManager();
        this.cache.setDefaultStrategy('memory-lru');
    }

    /**
     * Cache LSP request
     */
    public async cacheRequest(
        uri: string,
        method: string,
        params: any,
        response: any,
        options: {
            ttl?: number;
        } = {}
    ): Promise<void> {
        const key = this.generateRequestKey(uri, method);
        const cacheOptions = {
            ttl: options.ttl || 30000, // 30 seconds default
            metadata: { uri, method, timestamp: Date.now() }
        };

        await this.cache.set(key, response, cacheOptions);
        this.emit('requestCached', { uri, method, key });
    }

    /**
     * Get cached LSP request
     */
    public async getCachedRequest(
        uri: string,
        method: string
    ): Promise<any | undefined> {
        const key = this.generateRequestKey(uri, method);
        return await this.cache.get(key);
    }

    /**
     * Cache LSP diagnostics
     */
    public async cacheDiagnostics(
        uri: string,
        diagnostics: any[],
        options: {
            ttl?: number;
        } = {}
    ): Promise<void> {
        const key = this.generateDiagnosticsKey(uri);
        const cacheOptions = {
            ttl: options.ttl || 10000, // 10 seconds default
            metadata: { uri, timestamp: Date.now() }
        };

        await this.cache.set(key, diagnostics, cacheOptions);
        this.emit('diagnosticsCached', { uri, count: diagnostics.length });
    }

    /**
     * Get cached diagnostics
     */
    public async getCachedDiagnostics(uri: string): Promise<any[] | undefined> {
        const key = this.generateDiagnosticsKey(uri);
        const entry = await this.cache.get(key);
        return entry ? entry.value : undefined;
    }

    /**
     * Invalidate cache for URI
     */
    public async invalidateURI(uri: string): Promise<void> {
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
    public async getStats(): Promise<{
        requests: CacheStats;
        diagnostics: CacheStats;
        combined: CacheStats;
    }> {
        const stats = await this.cache.getStats();
        
        return {
            requests: stats,
            diagnostics: stats, // Same stats for now
            combined: stats
        };
    }

    /**
     * Clear all caches
     */
    public async clear(): Promise<void> {
        await this.cache.clear();
        this.requestCache.clear();
        this.diagnosticsCache.clear();
        this.emit('cleared');
    }

    private generateRequestKey(uri: string, method: string): string {
        return `lsp:request:${this.hashString(uri)}:${method}`;
    }

    private generateDiagnosticsKey(uri: string): string {
        return `lsp:diagnostics:${this.hashString(uri)}`;
    }

    private hashString(str: string): string {
        // Simple hash function for cache keys
        let hash = 0;
        for (let i = 0; i < str.length; i++) {
            const char = str.charCodeAt(i);
            hash = ((hash << 5) - hash) + char;
            hash = hash & hash; // Convert to 32-bit integer
        }
        return Math.abs(hash).toString(36);
    }

    async dispose(): Promise<void> {
        await this.cache.dispose();
        this.removeAllListeners();
    }
}

// Export cache classes for easy importing
export {
    MemoryLRUCache,
    RedisCache,
    MultiLevelCache,
    CacheManager,
    AIResponseCache,
    LSPCommunicationCache
};