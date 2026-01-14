"use strict";
/**
 * Cache Manager for Noodle VS Code Extension
 *
 * Provides a centralized caching system with TTL, eviction policies,
 * and persistent storage capabilities.
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
exports.CacheManager = void 0;
const vscode = __importStar(require("vscode"));
const events_1 = require("events");
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
class CacheManager extends events_1.EventEmitter {
    constructor(context, options) {
        super();
        this.cache = new Map();
        this.stats = {
            hits: 0,
            misses: 0,
            sets: 0,
            deletes: 0,
            evictions: 0,
            size: 0,
            entryCount: 0,
            hitRate: 0
        };
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Cache Manager');
        this.options = {
            ttl: 3600000,
            maxSize: 50 * 1024 * 1024,
            maxEntries: 1000,
            evictionPolicy: 'lru',
            persistToDisk: true,
            compressionEnabled: false,
            encryptionEnabled: false,
            ...options
        };
        // Set storage path
        this.storagePath = path.join(context.globalStorageUri.fsPath, 'cache');
        this.ensureStorageDirectory();
    }
    /**
     * Initialize cache manager
     */
    async initialize() {
        try {
            this.outputChannel.appendLine('Initializing cache manager...');
            // Load cache from disk if persistence is enabled
            if (this.options.persistToDisk) {
                await this.loadFromDisk();
            }
            // Start cleanup interval
            this.startCleanupInterval();
            this.outputChannel.appendLine('Cache manager initialized');
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to initialize cache manager: ${error.message}`);
            throw error;
        }
    }
    /**
     * Get value from cache
     */
    get(key) {
        try {
            const entry = this.cache.get(key);
            if (!entry) {
                this.stats.misses++;
                this.updateHitRate();
                this.emit('cacheMiss', { key });
                return undefined;
            }
            // Check if expired
            if (entry.expiresAt && Date.now() > entry.expiresAt) {
                this.cache.delete(key);
                this.stats.misses++;
                this.updateStats();
                this.updateHitRate();
                this.emit('cacheExpired', { key, entry });
                return undefined;
            }
            // Update access information
            entry.lastAccessed = Date.now();
            entry.accessCount++;
            this.stats.hits++;
            this.updateHitRate();
            this.emit('cacheHit', { key, entry });
            return entry.value;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to get cache entry ${key}: ${error.message}`);
            this.stats.misses++;
            this.updateHitRate();
            return undefined;
        }
    }
    /**
     * Set value in cache
     */
    set(key, value, options) {
        try {
            const now = Date.now();
            const ttl = options?.ttl || this.options.ttl;
            const expiresAt = ttl ? now + ttl : undefined;
            const serializedValue = JSON.stringify(value);
            const size = Buffer.byteLength(serializedValue, 'utf8');
            // Check if entry is too large
            if (size > (this.options.maxSize || 0)) {
                this.outputChannel.appendLine(`Cache entry ${key} too large: ${size} bytes`);
                return false;
            }
            // Evict entries if necessary
            this.evictIfNeeded(size);
            const entry = {
                key,
                value,
                createdAt: now,
                lastAccessed: now,
                expiresAt,
                accessCount: 1,
                size,
                tags: options?.tags
            };
            this.cache.set(key, entry);
            this.stats.sets++;
            this.updateStats();
            this.emit('cacheSet', { key, entry });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to set cache entry ${key}: ${error.message}`);
            return false;
        }
    }
    /**
     * Delete entry from cache
     */
    delete(key) {
        try {
            const deleted = this.cache.delete(key);
            if (deleted) {
                this.stats.deletes++;
                this.updateStats();
                this.emit('cacheDelete', { key });
            }
            return deleted;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to delete cache entry ${key}: ${error.message}`);
            return false;
        }
    }
    /**
     * Check if key exists in cache
     */
    has(key) {
        const entry = this.cache.get(key);
        if (!entry) {
            return false;
        }
        // Check if expired
        if (entry.expiresAt && Date.now() > entry.expiresAt) {
            this.cache.delete(key);
            this.updateStats();
            return false;
        }
        return true;
    }
    /**
     * Get all keys matching a pattern
     */
    getKeys(pattern) {
        const keys = Array.from(this.cache.keys());
        if (pattern) {
            return keys.filter(key => pattern.test(key));
        }
        return keys;
    }
    /**
     * Get all entries matching a pattern
     */
    getEntries(pattern) {
        const entries = Array.from(this.cache.values());
        if (pattern) {
            return entries.filter(entry => pattern.test(entry.key));
        }
        return entries;
    }
    /**
     * Get entries by tags
     */
    getEntriesByTag(tag) {
        const entries = Array.from(this.cache.values());
        return entries.filter(entry => entry.tags && entry.tags.includes(tag));
    }
    /**
     * Clear cache
     */
    clear() {
        const count = this.cache.size;
        this.cache.clear();
        this.stats.deletes += count;
        this.updateStats();
        this.emit('cacheClear', { count });
    }
    /**
     * Clear expired entries
     */
    clearExpired() {
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
        this.stats.deletes += expiredKeys.length;
        this.updateStats();
        this.emit('cacheClearExpired', { count: expiredKeys.length });
        return expiredKeys.length;
    }
    /**
     * Get cache statistics
     */
    getStats() {
        return { ...this.stats };
    }
    /**
     * Reset statistics
     */
    resetStats() {
        this.stats = {
            hits: 0,
            misses: 0,
            sets: 0,
            deletes: 0,
            evictions: 0,
            size: 0,
            entryCount: 0,
            hitRate: 0
        };
        this.emit('statsReset');
    }
    /**
     * Save cache to disk
     */
    async saveToDisk() {
        try {
            if (!this.options.persistToDisk) {
                return false;
            }
            const cacheData = {
                version: '1.0.0',
                timestamp: Date.now(),
                entries: Array.from(this.cache.entries())
            };
            const serializedData = JSON.stringify(cacheData);
            const filePath = path.join(this.storagePath, 'cache.json');
            await fs.promises.writeFile(filePath, serializedData, 'utf8');
            this.outputChannel.appendLine(`Cache saved to disk: ${this.cache.size} entries`);
            this.emit('cacheSaved', { filePath, entryCount: this.cache.size });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to save cache to disk: ${error.message}`);
            return false;
        }
    }
    /**
     * Load cache from disk
     */
    async loadFromDisk() {
        try {
            if (!this.options.persistToDisk) {
                return false;
            }
            const filePath = path.join(this.storagePath, 'cache.json');
            if (!fs.existsSync(filePath)) {
                return false;
            }
            const fileContent = await fs.promises.readFile(filePath, 'utf8');
            const cacheData = JSON.parse(fileContent);
            if (cacheData.version !== '1.0.0') {
                this.outputChannel.appendLine('Cache version mismatch, skipping load');
                return false;
            }
            // Load entries
            for (const [key, entry] of cacheData.entries) {
                // Check if expired
                if (entry.expiresAt && Date.now() > entry.expiresAt) {
                    continue;
                }
                this.cache.set(key, entry);
            }
            this.updateStats();
            this.outputChannel.appendLine(`Cache loaded from disk: ${this.cache.size} entries`);
            this.emit('cacheLoaded', { filePath, entryCount: this.cache.size });
            return true;
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to load cache from disk: ${error.message}`);
            return false;
        }
    }
    /**
     * Evict entries if necessary
     */
    evictIfNeeded(newEntrySize) {
        const maxSize = this.options.maxSize || 0;
        const maxEntries = this.options.maxEntries || 0;
        // Check size limit
        while ((this.stats.size + newEntrySize > maxSize) ||
            (maxEntries > 0 && this.cache.size >= maxEntries)) {
            this.evictOne();
        }
    }
    /**
     * Evict one entry based on policy
     */
    evictOne() {
        if (this.cache.size === 0) {
            return;
        }
        let keyToEvict;
        const entries = Array.from(this.cache.entries());
        switch (this.options.evictionPolicy) {
            case 'lru':
                // Least Recently Used
                keyToEvict = entries.reduce((oldest, current) => current[1].lastAccessed < oldest[1].lastAccessed ? current : oldest)[0];
                break;
            case 'lfu':
                // Least Frequently Used
                keyToEvict = entries.reduce((least, current) => current[1].accessCount < least[1].accessCount ? current : least)[0];
                break;
            case 'fifo':
                // First In First Out
                keyToEvict = entries.reduce((oldest, current) => current[1].createdAt < oldest[1].createdAt ? current : oldest)[0];
                break;
        }
        if (keyToEvict) {
            const entry = this.cache.get(keyToEvict);
            this.cache.delete(keyToEvict);
            this.stats.evictions++;
            this.updateStats();
            this.emit('cacheEvict', { key: keyToEvict, entry });
        }
    }
    /**
     * Update statistics
     */
    updateStats() {
        this.stats.entryCount = this.cache.size;
        this.stats.size = Array.from(this.cache.values())
            .reduce((total, entry) => total + entry.size, 0);
    }
    /**
     * Update hit rate
     */
    updateHitRate() {
        const total = this.stats.hits + this.stats.misses;
        this.stats.hitRate = total > 0 ? this.stats.hits / total : 0;
    }
    /**
     * Start cleanup interval
     */
    startCleanupInterval() {
        this.cleanupInterval = setInterval(() => {
            this.clearExpired();
        }, 60000); // Check every minute
    }
    /**
     * Ensure storage directory exists
     */
    ensureStorageDirectory() {
        try {
            if (!fs.existsSync(this.storagePath)) {
                fs.mkdirSync(this.storagePath, { recursive: true });
            }
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to create storage directory: ${error.message}`);
        }
    }
    /**
     * Dispose cache manager
     */
    async dispose() {
        try {
            // Stop cleanup interval
            if (this.cleanupInterval) {
                clearInterval(this.cleanupInterval);
            }
            // Save to disk
            if (this.options.persistToDisk) {
                await this.saveToDisk();
            }
            // Clear cache
            this.cache.clear();
            this.outputChannel.dispose();
            this.removeAllListeners();
        }
        catch (error) {
            this.outputChannel.appendLine(`Failed to dispose cache manager: ${error.message}`);
        }
    }
}
exports.CacheManager = CacheManager;
//# sourceMappingURL=cacheManager.js.map