/**
 * Cache Manager for Noodle VS Code Extension
 * 
 * Provides a centralized caching system with TTL, eviction policies,
 * and persistent storage capabilities.
 */

import * as vscode from 'vscode';
import { EventEmitter } from 'events';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';

export interface CacheEntry<T = any> {
    key: string;
    value: T;
    createdAt: number;
    lastAccessed: number;
    expiresAt?: number;
    accessCount: number;
    size: number;
    tags?: string[];
}

export interface CacheOptions {
    ttl?: number; // Time to live in milliseconds
 maxSize?: number; // Maximum cache size in bytes
    maxEntries?: number; // Maximum number of entries
    evictionPolicy?: 'lru' | 'lfu' | 'fifo';
    persistToDisk?: boolean;
    compressionEnabled?: boolean;
    encryptionEnabled?: boolean;
    encryptionKey?: string;
}

export interface CacheStats {
    hits: number;
    misses: number;
    sets: number;
    deletes: number;
    evictions: number;
    size: number;
    entryCount: number;
    hitRate: number;
}

export class CacheManager extends EventEmitter {
    private context: vscode.ExtensionContext;
    private outputChannel: vscode.OutputChannel;
    private cache: Map<string, CacheEntry> = new Map();
    private options: CacheOptions;
    private stats: CacheStats = {
        hits: 0,
        misses: 0,
        sets: 0,
        deletes: 0,
        evictions: 0,
        size: 0,
        entryCount: 0,
        hitRate: 0
    };
    private storagePath: string;
    private cleanupInterval?: NodeJS.Timer;
    
    constructor(context: vscode.ExtensionContext, options?: CacheOptions) {
        super();
        this.context = context;
        this.outputChannel = vscode.window.createOutputChannel('Noodle Cache Manager');
        this.options = {
            ttl: 3600000, // 1 hour
            maxSize: 50 * 1024 * 1024, // 50MB
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
    public async initialize(): Promise<void> {
        try {
            this.outputChannel.appendLine('Initializing cache manager...');
            
            // Load cache from disk if persistence is enabled
            if (this.options.persistToDisk) {
                await this.loadFromDisk();
            }
            
            // Start cleanup interval
            this.startCleanupInterval();
            
            this.outputChannel.appendLine('Cache manager initialized');
        } catch (error) {
            this.outputChannel.appendLine(`Failed to initialize cache manager: ${error.message}`);
            throw error;
        }
    }
    
    /**
     * Get value from cache
     */
    public get<T = any>(key: string): T | undefined {
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
            
            return entry.value as T;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to get cache entry ${key}: ${error.message}`);
            this.stats.misses++;
            this.updateHitRate();
            return undefined;
        }
    }
    
    /**
     * Set value in cache
     */
    public set<T = any>(key: string, value: T, options?: { ttl?: number; tags?: string[] }): boolean {
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
            
            const entry: CacheEntry<T> = {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to set cache entry ${key}: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Delete entry from cache
     */
    public delete(key: string): boolean {
        try {
            const deleted = this.cache.delete(key);
            if (deleted) {
                this.stats.deletes++;
                this.updateStats();
                this.emit('cacheDelete', { key });
            }
            return deleted;
        } catch (error) {
            this.outputChannel.appendLine(`Failed to delete cache entry ${key}: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Check if key exists in cache
     */
    public has(key: string): boolean {
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
    public getKeys(pattern?: RegExp): string[] {
        const keys = Array.from(this.cache.keys());
        
        if (pattern) {
            return keys.filter(key => pattern.test(key));
        }
        
        return keys;
    }
    
    /**
     * Get all entries matching a pattern
     */
    public getEntries<T = any>(pattern?: RegExp): CacheEntry<T>[] {
        const entries = Array.from(this.cache.values());
        
        if (pattern) {
            return entries.filter(entry => pattern.test(entry.key)) as CacheEntry<T>[];
        }
        
        return entries as CacheEntry<T>[];
    }
    
    /**
     * Get entries by tags
     */
    public getEntriesByTag<T = any>(tag: string): CacheEntry<T>[] {
        const entries = Array.from(this.cache.values());
        return entries.filter(entry => 
            entry.tags && entry.tags.includes(tag)
        ) as CacheEntry<T>[];
    }
    
    /**
     * Clear cache
     */
    public clear(): void {
        const count = this.cache.size;
        this.cache.clear();
        this.stats.deletes += count;
        this.updateStats();
        this.emit('cacheClear', { count });
    }
    
    /**
     * Clear expired entries
     */
    public clearExpired(): number {
        const now = Date.now();
        const expiredKeys: string[] = [];
        
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
    public getStats(): CacheStats {
        return { ...this.stats };
    }
    
    /**
     * Reset statistics
     */
    public resetStats(): void {
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
    public async saveToDisk(): Promise<boolean> {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to save cache to disk: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Load cache from disk
     */
    public async loadFromDisk(): Promise<boolean> {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to load cache from disk: ${error.message}`);
            return false;
        }
    }
    
    /**
     * Evict entries if necessary
     */
    private evictIfNeeded(newEntrySize: number): void {
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
    private evictOne(): void {
        if (this.cache.size === 0) {
            return;
        }
        
        let keyToEvict: string | undefined;
        const entries = Array.from(this.cache.entries());
        
        switch (this.options.evictionPolicy) {
            case 'lru':
                // Least Recently Used
                keyToEvict = entries.reduce((oldest, current) => 
                    current[1].lastAccessed < oldest[1].lastAccessed ? current : oldest
                )[0];
                break;
                
            case 'lfu':
                // Least Frequently Used
                keyToEvict = entries.reduce((least, current) => 
                    current[1].accessCount < least[1].accessCount ? current : least
                )[0];
                break;
                
            case 'fifo':
                // First In First Out
                keyToEvict = entries.reduce((oldest, current) => 
                    current[1].createdAt < oldest[1].createdAt ? current : oldest
                )[0];
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
    private updateStats(): void {
        this.stats.entryCount = this.cache.size;
        this.stats.size = Array.from(this.cache.values())
            .reduce((total, entry) => total + entry.size, 0);
    }
    
    /**
     * Update hit rate
     */
    private updateHitRate(): void {
        const total = this.stats.hits + this.stats.misses;
        this.stats.hitRate = total > 0 ? this.stats.hits / total : 0;
    }
    
    /**
     * Start cleanup interval
     */
    private startCleanupInterval(): void {
        this.cleanupInterval = setInterval(() => {
            this.clearExpired();
        }, 60000); // Check every minute
    }
    
    /**
     * Ensure storage directory exists
     */
    private ensureStorageDirectory(): void {
        try {
            if (!fs.existsSync(this.storagePath)) {
                fs.mkdirSync(this.storagePath, { recursive: true });
            }
        } catch (error) {
            this.outputChannel.appendLine(`Failed to create storage directory: ${error.message}`);
        }
    }
    
    /**
     * Dispose cache manager
     */
    public async dispose(): Promise<void> {
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
        } catch (error) {
            this.outputChannel.appendLine(`Failed to dispose cache manager: ${error.message}`);
        }
    }
}