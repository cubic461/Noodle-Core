import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';
import '../app.dart';

/// Cache entry with expiration time
class CacheEntry<T> {
  final T data;
  final DateTime createdAt;
  final Duration? expiration;
  
  CacheEntry({
    required this.data,
    required this.createdAt,
    this.expiration,
  });
  
  /// Check if the cache entry is expired
  bool get isExpired {
    if (expiration == null) return false;
    return DateTime.now().isAfter(createdAt.add(expiration!));
  }
  
  /// Create a cache entry from JSON
  factory CacheEntry.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJson,
  ) {
    return CacheEntry<T>(
      data: fromJson(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      expiration: json['expiration'] != null 
          ? Duration(milliseconds: json['expiration']) 
          : null,
    );
  }
  
  /// Convert cache entry to JSON
  Map<String, dynamic> toJson(dynamic Function(T) toJson) {
    return {
      'data': toJson(data),
      'createdAt': createdAt.toIso8601String(),
      'expiration': expiration?.inMilliseconds,
    };
  }
}

/// Cache manager for handling app-wide caching
class CacheManager {
  static final Logger _logger = App.logger;
  static CacheManager? _instance;
  static const String _cacheBoxName = 'noodle_cache';
  static const String _memoryCacheBoxName = 'noodle_memory_cache';
  
  late Box _cacheBox;
  late Box _memoryCacheBox;
  bool _initialized = false;
  
  /// Get singleton instance
  static CacheManager get instance {
    _instance ??= CacheManager._();
    return _instance!;
  }
  
  CacheManager._();
  
  /// Initialize the cache manager
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
      
      // Open persistent cache box
      _cacheBox = await Hive.openBox(_cacheBoxName);
      
      // Open memory cache box (will be cleared when app closes)
      _memoryCacheBox = await Hive.openBox(_memoryCacheBoxName);
      
      _initialized = true;
      _logger.i('Cache manager initialized');
    } catch (e) {
      _logger.e('Failed to initialize cache manager: $e');
      rethrow;
    }
  }
  
  /// Store data in cache
  Future<void> set<T>(
    String key,
    T data, {
    Duration? expiration,
    bool persistent = true,
  }) async {
    if (!_initialized) await initialize();
    
    try {
      final entry = CacheEntry<T>(
        data: data,
        createdAt: DateTime.now(),
        expiration: expiration,
      );
      
      final box = persistent ? _cacheBox : _memoryCacheBox;
      
      if (T == String || data is String) {
        await box.put(key, data as String);
      } else if (T == int || data is int) {
        await box.put(key, data as int);
      } else if (T == double || data is double) {
        await box.put(key, data as double);
      } else if (T == bool || data is bool) {
        await box.put(key, data as bool);
      } else {
        // For complex objects, serialize to JSON
        final json = jsonEncode(entry.toJson((d) => d));
        await box.put(key, json);
      }
      
      _logger.d('Cached data for key: $key (persistent: $persistent)');
    } catch (e) {
      _logger.e('Failed to cache data for key $key: $e');
      rethrow;
    }
  }
  
  /// Retrieve data from cache
  T? get<T>(
    String key, {
    T Function(dynamic)? fromJson,
    bool persistent = true,
  }) {
    if (!_initialized) {
      _logger.w('Cache manager not initialized');
      return null;
    }
    
    try {
      final box = persistent ? _cacheBox : _memoryCacheBox;
      final value = box.get(key);
      
      if (value == null) {
        _logger.d('Cache miss for key: $key');
        return null;
      }
      
      // Handle simple types
      if (T == String || value is String) {
        return value as T;
      } else if (T == int || value is int) {
        return value as T;
      } else if (T == double || value is double) {
        return value as T;
      } else if (T == bool || value is bool) {
        return value as T;
      }
      
      // Handle complex objects
      if (fromJson != null && value is String) {
        final json = jsonDecode(value) as Map<String, dynamic>;
        final entry = CacheEntry<T>.fromJson(json, fromJson);
        
        if (entry.isExpired) {
          _logger.d('Cache entry expired for key: $key');
          remove(key, persistent: persistent);
          return null;
        }
        
        _logger.d('Cache hit for key: $key');
        return entry.data;
      }
      
      _logger.w('Unsupported cache type for key: $key');
      return null;
    } catch (e) {
      _logger.e('Failed to retrieve cached data for key $key: $e');
      return null;
    }
  }
  
  /// Check if key exists in cache
  bool contains(String key, {bool persistent = true}) {
    if (!_initialized) return false;
    
    final box = persistent ? _cacheBox : _memoryCacheBox;
    return box.containsKey(key);
  }
  
  /// Remove data from cache
  Future<void> remove(String key, {bool persistent = true}) async {
    if (!_initialized) return;
    
    try {
      final box = persistent ? _cacheBox : _memoryCacheBox;
      await box.delete(key);
      _logger.d('Removed cache entry for key: $key');
    } catch (e) {
      _logger.e('Failed to remove cache entry for key $key: $e');
    }
  }
  
  /// Clear all cache data
  Future<void> clear({bool persistent = true}) async {
    if (!_initialized) return;
    
    try {
      final box = persistent ? _cacheBox : _memoryCacheBox;
      await box.clear();
      _logger.i('Cleared ${persistent ? 'persistent' : 'memory'} cache');
    } catch (e) {
      _logger.e('Failed to clear cache: $e');
    }
  }
  
  /// Clear expired cache entries
  Future<void> clearExpired({bool persistent = true}) async {
    if (!_initialized) return;
    
    try {
      final box = persistent ? _cacheBox : _memoryCacheBox;
      final keysToRemove = <String>[];
      
      for (final key in box.keys) {
        final value = box.get(key);
        
        // Skip simple types
        if (value is String || value is int || value is double || value is bool) {
          continue;
        }
        
        // Check complex objects
        if (value is String) {
          try {
            final json = jsonDecode(value) as Map<String, dynamic>;
            final entry = CacheEntry.fromJson(json, (d) => d);
            if (entry.isExpired) {
              keysToRemove.add(key);
            }
          } catch (e) {
            // Invalid entry, remove it
            keysToRemove.add(key);
          }
        }
      }
      
      for (final key in keysToRemove) {
        await box.delete(key);
      }
      
      _logger.i('Cleared ${keysToRemove.length} expired cache entries');
    } catch (e) {
      _logger.e('Failed to clear expired cache entries: $e');
    }
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStats({bool persistent = true}) {
    if (!_initialized) return {};
    
    final box = persistent ? _cacheBox : _memoryCacheBox;
    final keys = box.keys.toList();
    
    return {
      'type': persistent ? 'persistent' : 'memory',
      'totalEntries': keys.length,
      'keys': keys,
    };
  }
  
  /// Close the cache manager
  Future<void> close() async {
    if (!_initialized) return;
    
    try {
      await _cacheBox.close();
      await _memoryCacheBox.close();
      _initialized = false;
      _logger.i('Cache manager closed');
    } catch (e) {
      _logger.e('Failed to close cache manager: $e');
    }
  }
}

/// Network cache manager for API responses
class NetworkCacheManager {
  static final CacheManager _cacheManager = CacheManager.instance;
  static const Duration _defaultExpiration = Duration(minutes: 5);
  static const Duration _longExpiration = Duration(hours: 1);
  
  /// Cache API response
  static Future<void> cacheResponse(
    String url,
    Map<String, dynamic> response, {
    Duration? expiration,
  }) async {
    await _cacheManager.set<Map<String, dynamic>>(
      'api_response_$url',
      response,
      expiration: expiration ?? _defaultExpiration,
      persistent: true,
    );
  }
  
  /// Get cached API response
  static Map<String, dynamic>? getCachedResponse(String url) {
    return _cacheManager.get<Map<String, dynamic>>(
      'api_response_$url',
      fromJson: (data) => data as Map<String, dynamic>,
      persistent: true,
    );
  }
  
  /// Cache image data
  static Future<void> cacheImage(
    String url,
    Uint8List imageData, {
    Duration? expiration,
  }) async {
    await _cacheManager.set<Uint8List>(
      'image_$url',
      imageData,
      expiration: expiration ?? _longExpiration,
      persistent: true,
    );
  }
  
  /// Get cached image data
  static Uint8List? getCachedImage(String url) {
    return _cacheManager.get<Uint8List>(
      'image_$url',
      persistent: true,
    );
  }
  
  /// Clear all network cache
  static Future<void> clearNetworkCache() async {
    // In a real implementation, you would iterate through keys
    // and remove only network-related entries
    await _cacheManager.clear(persistent: true);
  }
}

/// Image cache manager for optimized image loading
class ImageCacheManager {
  static final CacheManager _cacheManager = CacheManager.instance;
  static const Duration _defaultExpiration = Duration(days: 7);
  static const int _maxCacheSize = 100 * 1024 * 1024; // 100MB
  
  /// Cache image with metadata
  static Future<void> cacheImage(
    String url,
    Uint8List imageData, {
    String? etag,
    DateTime? lastModified,
  }) async {
    final metadata = {
      'url': url,
      'size': imageData.length,
      'etag': etag,
      'lastModified': lastModified?.toIso8601String(),
      'cachedAt': DateTime.now().toIso8601String(),
    };
    
    await _cacheManager.set<Uint8List>(
      'image_data_$url',
      imageData,
      expiration: _defaultExpiration,
      persistent: true,
    );
    
    await _cacheManager.set<Map<String, dynamic>>(
      'image_meta_$url',
      metadata,
      expiration: _defaultExpiration,
      persistent: true,
    );
  }
  
  /// Get cached image
  static Uint8List? getCachedImage(String url) {
    return _cacheManager.get<Uint8List>(
      'image_data_$url',
      persistent: true,
    );
  }
  
  /// Get image metadata
  static Map<String, dynamic>? getImageMetadata(String url) {
    return _cacheManager.get<Map<String, dynamic>>(
      'image_meta_$url',
      fromJson: (data) => data as Map<String, dynamic>,
      persistent: true,
    );
  }
  
  /// Check if image is cached and valid
  static bool isImageCached(String url, {String? etag}) {
    final metadata = getImageMetadata(url);
    if (metadata == null) return false;
    
    // Check ETag if provided
    if (etag != null && metadata['etag'] != null) {
      return metadata['etag'] == etag;
    }
    
    return true;
  }
  
  /// Clear image cache
  static Future<void> clearImageCache() async {
    // In a real implementation, you would iterate through keys
    // and remove only image-related entries
    await _cacheManager.clear(persistent: true);
  }
  
  /// Get cache size
  static Future<int> getCacheSize() async {
    // In a real implementation, you would calculate the actual size
    // of all cached images
    return 0;
  }
  
  /// Clear cache if it exceeds max size
  static Future<void> maintainCacheSize() async {
    final currentSize = await getCacheSize();
    if (currentSize > _maxCacheSize) {
      // In a real implementation, you would implement LRU eviction
      // to remove oldest images until cache size is acceptable
      _logger.w('Image cache size exceeds limit, implementing cleanup');
    }
  }
}