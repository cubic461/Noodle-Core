import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../app.dart';

/// Security utilities for input validation and secure storage
class SecurityUtils {
  static final Logger _logger = App.logger;
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  /// Validate email format
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    
    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    return emailRegex.hasMatch(email);
  }
  
  /// Validate password strength
  static PasswordValidationResult validatePassword(String password) {
    if (password.isEmpty) {
      return const PasswordValidationResult(
        isValid: false,
        score: 0,
        feedback: 'Password is required',
      );
    }
    
    int score = 0;
    final List<String> feedback = [];
    
    // Length check
    if (password.length >= 8) {
      score += 1;
    } else {
      feedback.add('Password should be at least 8 characters');
    }
    
    // Contains lowercase letter
    if (password.contains(RegExp(r'[a-z]'))) {
      score += 1;
    } else {
      feedback.add('Password should contain lowercase letters');
    }
    
    // Contains uppercase letter
    if (password.contains(RegExp(r'[A-Z]'))) {
      score += 1;
    } else {
      feedback.add('Password should contain uppercase letters');
    }
    
    // Contains number
    if (password.contains(RegExp(r'[0-9]'))) {
      score += 1;
    } else {
      feedback.add('Password should contain numbers');
    }
    
    // Contains special character
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      score += 1;
    } else {
      feedback.add('Password should contain special characters');
    }
    
    return PasswordValidationResult(
      isValid: score >= 4,
      score: score,
      feedback: feedback.join('\n'),
    );
  }
  
  /// Sanitize user input to prevent XSS
  static String sanitizeInput(String input) {
    if (input.isEmpty) return input;
    
    // HTML escape special characters
    return input
        .replaceAll('&', '&')
        .replaceAll('<', '<')
        .replaceAll('>', '>')
        .replaceAll('"', '"')
        .replaceAll("'", '&#x27;')
        .replaceAll('/', '&#x2F;');
  }
  
  /// Validate URL format
  static bool isValidUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
  
  /// Generate a secure random token
  static String generateSecureToken({int length = 32}) {
    final bytes = Uint8List(length);
    for (int i = 0; i < length; i++) {
      bytes[i] = (DateTime.now().millisecondsSinceEpoch + i) % 256;
    }
    return base64Url.encode(bytes);
  }
  
  /// Hash a password using SHA-256
  static String hashPassword(String password, {String? salt}) {
    salt ??= 'noodle_control_salt';
    final bytes = utf8.encode(password + salt);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
  
  /// Verify a password against its hash
  static bool verifyPassword(String password, String hash, {String? salt}) {
    final computedHash = hashPassword(password, salt: salt);
    return computedHash == hash;
  }
  
  /// Store data securely
  static Future<void> storeSecurely(String key, String value) async {
    try {
      await _secureStorage.write(key: key, value: value);
      _logger.d('Securely stored data for key: $key');
    } catch (e) {
      _logger.e('Failed to store secure data: $e');
      rethrow;
    }
  }
  
  /// Retrieve data securely
  static Future<String?> retrieveSecurely(String key) async {
    try {
      final value = await _secureStorage.read(key: key);
      _logger.d('Retrieved secure data for key: $key');
      return value;
    } catch (e) {
      _logger.e('Failed to retrieve secure data: $e');
      return null;
    }
  }
  
  /// Delete secure data
  static Future<void> deleteSecurely(String key) async {
    try {
      await _secureStorage.delete(key: key);
      _logger.d('Deleted secure data for key: $key');
    } catch (e) {
      _logger.e('Failed to delete secure data: $e');
      rethrow;
    }
  }
  
  /// Clear all secure data
  static Future<void> clearAllSecureData() async {
    try {
      await _secureStorage.deleteAll();
      _logger.i('Cleared all secure data');
    } catch (e) {
      _logger.e('Failed to clear secure data: $e');
      rethrow;
    }
  }
  
  /// Check if secure storage is available
  static Future<bool> isSecureStorageAvailable() async {
    try {
      // Try to write and read a test value
      const testKey = 'secure_storage_test';
      const testValue = 'test_value';
      
      await _secureStorage.write(key: testKey, value: testValue);
      final retrievedValue = await _secureStorage.read(key: testKey);
      await _secureStorage.delete(key: testKey);
      
      return retrievedValue == testValue;
    } catch (e) {
      _logger.e('Secure storage not available: $e');
      return false;
    }
  }
  
  /// Encrypt sensitive data (basic implementation)
  static String encryptData(String data, String key) {
    try {
      // This is a simple XOR encryption for demonstration
      // In production, use proper encryption libraries
      final keyBytes = utf8.encode(key);
      final dataBytes = utf8.encode(data);
      
      final encryptedBytes = <int>[];
      for (int i = 0; i < dataBytes.length; i++) {
        encryptedBytes.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return base64.encode(encryptedBytes);
    } catch (e) {
      _logger.e('Failed to encrypt data: $e');
      rethrow;
    }
  }
  
  /// Decrypt sensitive data (basic implementation)
  static String decryptData(String encryptedData, String key) {
    try {
      // This is a simple XOR decryption for demonstration
      // In production, use proper encryption libraries
      final keyBytes = utf8.encode(key);
      final encryptedBytes = base64.decode(encryptedData);
      
      final decryptedBytes = <int>[];
      for (int i = 0; i < encryptedBytes.length; i++) {
        decryptedBytes.add(encryptedBytes[i] ^ keyBytes[i % keyBytes.length]);
      }
      
      return utf8.decode(decryptedBytes);
    } catch (e) {
      _logger.e('Failed to decrypt data: $e');
      rethrow;
    }
  }
  
  /// Validate device ID format
  static bool isValidDeviceId(String deviceId) {
    if (deviceId.isEmpty) return false;
    
    // Device ID should be alphanumeric and between 8 and 64 characters
    final deviceIdRegex = RegExp(r'^[a-zA-Z0-9]{8,64}$');
    return deviceIdRegex.hasMatch(deviceId);
  }
  
  /// Validate server URL with security checks
  static bool isValidServerUrl(String url) {
    if (!isValidUrl(url)) return false;
    
    final uri = Uri.parse(url);
    
    // Only allow HTTP and HTTPS schemes
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    
    // Check for localhost in debug mode only
    if (kDebugMode && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return true;
    }
    
    // In production, don't allow localhost
    if (!kDebugMode && (uri.host == 'localhost' || uri.host == '127.0.0.1')) {
      return false;
    }
    
    return true;
  }
}

/// Result of password validation
class PasswordValidationResult {
  final bool isValid;
  final int score;
  final String feedback;
  
  const PasswordValidationResult({
    required this.isValid,
    required this.score,
    required this.feedback,
  });
  
  @override
  String toString() => 'PasswordValidationResult(isValid: $isValid, score: $score)';
}

/// Security configuration
class SecurityConfig {
  static const int maxLoginAttempts = 5;
  static const Duration lockoutDuration = Duration(minutes: 15);
  static const Duration sessionTimeout = Duration(hours: 2);
  static const int passwordMinLength = 8;
  static const int passwordMaxLength = 128;
  static const int tokenLength = 32;
}

/// Input validation rules
class ValidationRules {
  static const String usernamePattern = r'^[a-zA-Z0-9_]{3,20}$';
  static const String deviceIdPattern = r'^[a-zA-Z0-9]{8,64}$';
  static const String projectNamePattern = r'^[a-zA-Z0-9_\-\s]{1,50}$';
  static const String nodeIdPattern = r'^[a-zA-Z0-9\-_]{8,32}$';
  static const String taskIdPattern = r'^[a-zA-Z0-9\-_]{8,32}$';
  
  /// Validate input against a pattern
  static bool validatePattern(String input, String pattern) {
    if (input.isEmpty) return false;
    return RegExp(pattern).hasMatch(input);
  }
  
  /// Validate username
  static bool isValidUsername(String username) {
    return validatePattern(username, usernamePattern);
  }
  
  /// Validate device ID
  static bool isValidDeviceId(String deviceId) {
    return validatePattern(deviceId, deviceIdPattern);
  }
  
  /// Validate project name
  static bool isValidProjectName(String projectName) {
    return validatePattern(projectName, projectNamePattern);
  }
  
  /// Validate node ID
  static bool isValidNodeId(String nodeId) {
    return validatePattern(nodeId, nodeIdPattern);
  }
  
  /// Validate task ID
  static bool isValidTaskId(String taskId) {
    return validatePattern(taskId, taskIdPattern);
  }
}