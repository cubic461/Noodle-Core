import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../app.dart';
import '../network/http_client.dart';
import '../network/websocket_service.dart';
import '../network/exceptions.dart';
import '../../shared/models/models.dart';

/// Authentication repository
class AuthRepository {
  final HttpClient _httpClient;
  final WebSocketService _webSocketService;
  final Logger _logger = App.logger;
  
  AuthRepository({
    required HttpClient httpClient,
    required WebSocketService webSocketService,
  }) : _httpClient = httpClient,
       _webSocketService = webSocketService;
  
  /// Login with credentials
  Future<User> login(String username, String password) async {
    try {
      _logger.i('Attempting login for user: $username');
      
      final response = await _httpClient.post(
        '/api/v1/auth/login',
        data: {
          'username': username,
          'password': password,
          'deviceInfo': await _getDeviceInfo(),
        },
      );
      
      final userData = response['user'] as Map<String, dynamic>;
      final token = response['token'] as String;
      final refreshToken = response['refreshToken'] as String?;
      
      // Parse user data
      final user = User.fromJson(userData);
      
      // Save tokens
      await App.saveToken(token);
      if (refreshToken != null) {
        await App.saveRefreshToken(refreshToken);
      }
      
      // Update HTTP client with token
      _httpClient.updateAuthToken(token);
      
      // Connect WebSocket with token
      await _webSocketService.connect(authToken: token);
      
      _logger.i('Login successful for user: $username');
      return user;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Login failed: $e');
      throw AuthenticationException.invalidCredentials(details: e.toString());
    }
  }
  
  /// Register a new device
  Future<Device> registerDevice(String name, String type) async {
    try {
      _logger.i('Registering device: $name');
      
      final response = await _httpClient.post(
        '/api/v1/devices/register',
        data: {
          'name': name,
          'type': type,
          'deviceInfo': await _getDeviceInfo(),
        },
      );
      
      final deviceData = response['device'] as Map<String, dynamic>;
      final device = Device.fromJson(deviceData);
      
      // Save device ID
      await App.saveDeviceId(device.id);
      
      _logger.i('Device registered successfully: ${device.id}');
      return device;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Device registration failed: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Refresh authentication token
  Future<String> refreshToken() async {
    try {
      final refreshToken = await App.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        throw AuthenticationException.tokenExpired();
      }
      
      _logger.d('Refreshing authentication token');
      
      final response = await _httpClient.post(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      final newToken = response['token'] as String;
      final newRefreshToken = response['refreshToken'] as String?;
      
      // Save new tokens
      await App.saveToken(newToken);
      if (newRefreshToken != null) {
        await App.saveRefreshToken(newRefreshToken);
      }
      
      // Update HTTP client with new token
      _httpClient.updateAuthToken(newToken);
      
      _logger.d('Token refreshed successfully');
      return newToken;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Token refresh failed: $e');
      throw AuthenticationException.tokenExpired(details: e.toString());
    }
  }
  
  /// Logout user
  Future<void> logout() async {
    try {
      _logger.i('Logging out user');
      
      // Call logout endpoint
      await _httpClient.post('/api/v1/auth/logout');
      
    } catch (e) {
      _logger.e('Error during logout API call: $e');
      // Continue with local logout even if API call fails
    } finally {
      // Disconnect WebSocket
      await _webSocketService.disconnect();
      
      // Clear stored tokens
      await _clearTokens();
      
      // Update HTTP client
      _httpClient.updateAuthToken(null);
      
      _logger.i('Logout completed');
    }
  }
  
  /// Get current user
  Future<User> getCurrentUser() async {
    try {
      _logger.d('Fetching current user');
      
      final response = await _httpClient.get('/api/v1/auth/me');
      final userData = response['user'] as Map<String, dynamic>;
      
      return User.fromJson(userData);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to get current user: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Update user profile
  Future<User> updateProfile(Map<String, dynamic> profileData) async {
    try {
      _logger.i('Updating user profile');
      
      final response = await _httpClient.put(
        '/api/v1/auth/profile',
        data: profileData,
      );
      
      final userData = response['user'] as Map<String, dynamic>;
      return User.fromJson(userData);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to update profile: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Change password
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      _logger.i('Changing password');
      
      await _httpClient.post(
        '/api/v1/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
      
      _logger.i('Password changed successfully');
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to change password: $e');
      throw AuthenticationException.invalidCredentials(details: e.toString());
    }
  }
  
  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await App.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Try to get current user to validate token
      await getCurrentUser();
      return true;
      
    } catch (e) {
      _logger.e('Authentication check failed: $e');
      return false;
    }
  }
  
  /// Auto-authenticate with stored token
  Future<User?> autoAuthenticate() async {
    try {
      final token = await App.getToken();
      if (token == null || token.isEmpty) {
        return null;
      }
      
      _logger.d('Attempting auto-authentication');
      
      // Update HTTP client with token
      _httpClient.updateAuthToken(token);
      
      // Connect WebSocket with token
      await _webSocketService.connect(authToken: token);
      
      // Get current user
      final user = await getCurrentUser();
      
      _logger.i('Auto-authentication successful');
      return user;
      
    } catch (e) {
      _logger.e('Auto-authentication failed: $e');
      
      // Clear invalid tokens
      await _clearTokens();
      
      // Update HTTP client
      _httpClient.updateAuthToken(null);
      
      return null;
    }
  }
  
  /// Get device information
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      final packageInfo = await PackageInfo.fromPlatform();
      
      Map<String, dynamic> deviceData = {
        'appName': App.appName,
        'appVersion': packageInfo.version,
        'buildNumber': packageInfo.buildNumber,
      };
      
      if (App.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'iOS',
          'model': iosInfo.model,
          'systemVersion': iosInfo.systemVersion,
          'name': iosInfo.name,
          'identifierForVendor': iosInfo.identifierForVendor,
        });
      } else if (App.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'Android',
          'model': androidInfo.model,
          'systemVersion': androidInfo.version.release,
          'manufacturer': androidInfo.manufacturer,
          'id': androidInfo.id,
        });
      } else {
        deviceData['platform'] = 'Unknown';
      }
      
      return deviceData;
    } catch (e) {
      _logger.e('Failed to get device info: $e');
      return {
        'platform': 'Unknown',
        'appName': App.appName,
        'appVersion': App.appVersion,
      };
    }
  }
  
  /// Clear stored tokens
  Future<void> _clearTokens() async {
    await App.saveToken('');
    await App.saveRefreshToken('');
    await App.saveDeviceId('');
  }
}

// Provider for authentication repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return AuthRepository(
    httpClient: httpClient,
    webSocketService: webSocketService,
  );
});