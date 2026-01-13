"use strict";
/**
 * NoodleCore Resource Manager
 *
 * Manages system resources including memory, CPU, file handles,
 * and other limited resources with monitoring and optimization.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ResourceManager = void 0;
const events_1 = require("events");
class ResourceManager extends events_1.EventEmitter {
    constructor() {
        super();
        this.cache = new Map();
        this.cacheStats = {
            hits: 0,
            misses: 0,
            evictions: 0
        };
        this.monitoringInterval = null;
        this.garbageCollectionInterval = null;
        this.isMonitoring = false;
        this.metrics = this.initializeMetrics();
        this.thresholds = this.initializeThresholds();
        this.quota = this.initializeQuota();
        this.setupMemoryMonitoring();
    }
    /**
     * Start resource monitoring
     */
    startMonitoring(intervalMs = 5000) {
        if (this.isMonitoring) {
            return;
        }
        this.isMonitoring = true;
        this.monitoringInterval = setInterval(() => {
            this.updateMetrics();
            this.checkThresholds();
        }, intervalMs);
        // Start garbage collection optimization
        this.garbageCollectionInterval = setInterval(() => {
            this.optimizeGarbageCollection();
        }, 30000); // Every 30 seconds
        this.emit('monitoringStarted');
    }
    /**
     * Stop resource monitoring
     */
    stopMonitoring() {
        if (!this.isMonitoring) {
            return;
        }
        this.isMonitoring = false;
        if (this.monitoringInterval) {
            clearInterval(this.monitoringInterval);
            this.monitoringInterval = null;
        }
        if (this.garbageCollectionInterval) {
            clearInterval(this.garbageCollectionInterval);
            this.garbageCollectionInterval = null;
        }
        this.emit('monitoringStopped');
    }
    /**
     * Get current resource metrics
     */
    getMetrics() {
        return { ...this.metrics };
    }
    /**
     * Get resource thresholds
     */
    getThresholds() {
        return { ...this.thresholds };
    }
    /**
     * Set resource thresholds
     */
    setThresholds(thresholds) {
        this.thresholds = { ...this.thresholds, ...thresholds };
        this.emit('thresholdsUpdated', this.thresholds);
    }
    /**
     * Get resource quota
     */
    getQuota() {
        return { ...this.quota };
    }
    /**
     * Set resource quota
     */
    setQuota(quota) {
        this.quota = { ...this.quota, ...quota };
        this.emit('quotaUpdated', this.quota);
    }
    /**
     * Store value in cache with LRU eviction
     */
    setCache(key, value, options = {}) {
        const size = this.calculateSize(value);
        // Check cache size limit
        if (this.getCurrentCacheSize() + size > this.quota.maxCacheSize) {
            this.evictCacheEntries(size);
        }
        const now = Date.now();
        const entry = {
            key,
            value,
            size,
            accessCount: 1,
            lastAccessed: now,
            expiresAt: options.ttl ? now + options.ttl : undefined,
            priority: options.priority || 0
        };
        this.cache.set(key, entry);
        this.emit('cacheSet', { key, size });
    }
    /**
     * Get value from cache
     */
    getCache(key) {
        const entry = this.cache.get(key);
        if (!entry) {
            this.cacheStats.misses++;
            this.emit('cacheMiss', { key });
            return undefined;
        }
        // Check expiration
        if (entry.expiresAt && Date.now() > entry.expiresAt) {
            this.cache.delete(key);
            this.cacheStats.misses++;
            this.emit('cacheExpired', { key });
            return undefined;
        }
        // Update access info
        entry.accessCount++;
        entry.lastAccessed = Date.now();
        this.cacheStats.hits++;
        this.emit('cacheHit', { key });
        return entry.value;
    }
    /**
     * Remove entry from cache
     */
    deleteCache(key) {
        const deleted = this.cache.delete(key);
        if (deleted) {
            this.emit('cacheDeleted', { key });
        }
        return deleted;
    }
    /**
     * Clear all cache entries
     */
    clearCache() {
        const size = this.cache.size;
        this.cache.clear();
        this.emit('cacheCleared', { size });
    }
    /**
     * Get cache statistics
     */
    getCacheStats() {
        const total = this.cacheStats.hits + this.cacheStats.misses;
        const hitRate = total > 0 ? (this.cacheStats.hits / total) * 100 : 0;
        const evictionRate = this.cacheStats.evictions / (total + this.cacheStats.evictions) * 100;
        return {
            size: this.cache.size,
            hitRate,
            evictionRate
        };
    }
    /**
     * Force garbage collection
     */
    forceGarbageCollection() {
        if (global.gc) {
            global.gc();
            this.emit('garbageCollected');
        }
    }
    /**
     * Optimize memory usage
     */
    optimizeMemory() {
        // Clear expired cache entries
        this.clearExpiredCacheEntries();
        // Evict least recently used entries if over quota
        while (this.getCurrentCacheSize() > this.quota.maxCacheSize * 0.8) {
            this.evictLRUEntry();
        }
        // Force garbage collection if memory usage is high
        if (this.metrics.memory.percentage > 80) {
            this.forceGarbageCollection();
        }
        this.emit('memoryOptimized');
    }
    /**
     * Initialize metrics
     */
    initializeMetrics() {
        return {
            memory: {
                used: 0,
                total: 0,
                percentage: 0,
                heapUsed: 0,
                heapTotal: 0
            },
            cpu: {
                usage: 0,
                loadAverage: [0, 0, 0]
            },
            handles: {
                active: 0,
                peak: 0
            },
            cache: {
                size: 0,
                hitRate: 0,
                evictionRate: 0
            }
        };
    }
    /**
     * Initialize thresholds
     */
    initializeThresholds() {
        return {
            memory: {
                warning: 75,
                critical: 90 // 90%
            },
            cpu: {
                warning: 80,
                critical: 95 // 95%
            },
            handles: {
                warning: 1000,
                critical: 1500
            }
        };
    }
    /**
     * Initialize quota
     */
    initializeQuota() {
        return {
            maxMemory: 2 * 1024 * 1024 * 1024,
            maxHandles: 1000,
            maxCacheSize: 100 * 1024 * 1024 // 100MB
        };
    }
    /**
     * Setup memory monitoring
     */
    setupMemoryMonitoring() {
        // Handle process memory warnings
        process.on('warning', (warning) => {
            if (warning.name === 'MaxListenersExceededWarning') {
                this.emit('resourceWarning', {
                    type: 'maxListeners',
                    message: warning.message
                });
            }
        });
        // Handle out of memory errors
        process.on('uncaughtException', (error) => {
            if (error.message.includes('out of memory')) {
                this.emit('resourceCritical', {
                    type: 'memory',
                    error: error.message
                });
            }
        });
    }
    /**
     * Update resource metrics
     */
    updateMetrics() {
        const memUsage = process.memoryUsage();
        const totalMemory = require('os').totalmem();
        this.metrics.memory = {
            used: memUsage.rss,
            total: totalMemory,
            percentage: (memUsage.rss / totalMemory) * 100,
            heapUsed: memUsage.heapUsed,
            heapTotal: memUsage.heapTotal
        };
        this.metrics.cpu.usage = process.cpuUsage().user / 1000000; // Convert to percentage
        // Update cache metrics
        const cacheStats = this.getCacheStats();
        this.metrics.cache = {
            size: cacheStats.size,
            hitRate: cacheStats.hitRate,
            evictionRate: cacheStats.evictionRate
        };
        this.emit('metricsUpdated', this.metrics);
    }
    /**
     * Check resource thresholds
     */
    checkThresholds() {
        // Memory thresholds
        if (this.metrics.memory.percentage >= this.thresholds.memory.critical) {
            this.emit('resourceCritical', {
                type: 'memory',
                value: this.metrics.memory.percentage,
                threshold: this.thresholds.memory.critical
            });
        }
        else if (this.metrics.memory.percentage >= this.thresholds.memory.warning) {
            this.emit('resourceWarning', {
                type: 'memory',
                value: this.metrics.memory.percentage,
                threshold: this.thresholds.memory.warning
            });
        }
        // CPU thresholds
        if (this.metrics.cpu.usage >= this.thresholds.cpu.critical) {
            this.emit('resourceCritical', {
                type: 'cpu',
                value: this.metrics.cpu.usage,
                threshold: this.thresholds.cpu.critical
            });
        }
        else if (this.metrics.cpu.usage >= this.thresholds.cpu.warning) {
            this.emit('resourceWarning', {
                type: 'cpu',
                value: this.metrics.cpu.usage,
                threshold: this.thresholds.cpu.warning
            });
        }
    }
    /**
     * Calculate approximate size of value
     */
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
    /**
     * Get current cache size in bytes
     */
    getCurrentCacheSize() {
        let size = 0;
        for (const entry of this.cache.values()) {
            size += entry.size;
        }
        return size;
    }
    /**
     * Evict cache entries to make room
     */
    evictCacheEntries(requiredSpace) {
        const entries = Array.from(this.cache.values());
        // Sort by priority (low priority first) and last accessed
        entries.sort((a, b) => {
            if (a.priority !== b.priority) {
                return a.priority - b.priority;
            }
            return a.lastAccessed - b.lastAccessed;
        });
        let freedSpace = 0;
        for (const entry of entries) {
            this.cache.delete(entry.key);
            this.cacheStats.evictions++;
            freedSpace += entry.size;
            if (freedSpace >= requiredSpace) {
                break;
            }
        }
        this.emit('cacheEvicted', { entries: entries.length, size: freedSpace });
    }
    /**
     * Evict least recently used entry
     */
    evictLRUEntry() {
        let oldestEntry = null;
        let oldestTime = Date.now();
        for (const entry of this.cache.values()) {
            if (entry.lastAccessed < oldestTime) {
                oldestTime = entry.lastAccessed;
                oldestEntry = entry;
            }
        }
        if (oldestEntry) {
            this.cache.delete(oldestEntry.key);
            this.cacheStats.evictions++;
        }
    }
    /**
     * Clear expired cache entries
     */
    clearExpiredCacheEntries() {
        const now = Date.now();
        const expiredKeys = [];
        for (const [key, entry] of this.cache.entries()) {
            if (entry.expiresAt && now > entry.expiresAt) {
                expiredKeys.push(key);
            }
        }
        for (const key of expiredKeys) {
            this.cache.delete(key);
        }
        if (expiredKeys.length > 0) {
            this.emit('cacheExpired', { keys: expiredKeys.length });
        }
    }
    /**
     * Optimize garbage collection
     */
    optimizeGarbageCollection() {
        // Clear expired entries
        this.clearExpiredCacheEntries();
        // Force GC if memory usage is high
        if (this.metrics.memory.percentage > 70) {
            this.forceGarbageCollection();
        }
    }
    /**
     * Dispose resource manager
     */
    dispose() {
        this.stopMonitoring();
        this.cache.clear();
        this.removeAllListeners();
    }
}
exports.ResourceManager = ResourceManager;
//# sourceMappingURL=ResourceManager.js.map