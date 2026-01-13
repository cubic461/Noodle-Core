import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;

import 'app_router.dart';
import '../shared/theme/app_theme.dart';
import '../shared/widgets/connection_status_indicator.dart';
import '../core/services/service_provider.dart';
import '../shared/models/models.dart';
import 'utils/error_handler.dart';
import 'utils/performance_monitor.dart';
import 'utils/security_utils.dart';
import 'utils/analytics_service.dart';
import 'utils/cache_manager.dart';

/// Main application class
class App extends ConsumerWidget {
  static const String appName = 'NoodleControl';
  static const String appVersion = '1.0.0';
  static const Duration defaultTimeout = Duration(seconds: 30);
  
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );
  
  static Logger get logger => _logger;
  
  static bool get isIOS => !kIsWeb && defaultTargetPlatform == TargetPlatform.iOS;
  static bool get isAndroid => !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(appRouterProvider);
    
    return MaterialApp.router(
      title: appName,
      debugShowCheckedModeBanner: kDebugMode,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            // Connection status indicator in the top right corner
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              right: 8,
              child: AnimatedConnectionStatusIndicator(
                showLabel: false,
                size: 16,
                onTap: () {
                  // Show connection status dialog
                  showDialog(
                    context: context,
                    builder: (context) => const ConnectionStatusDialog(),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
  
  /// Initialize app services
  static Future<void> initialize() async {
    logger.i('Initializing $appName v$appVersion');
    
    try {
      // Initialize shared preferences
      final prefs = await SharedPreferences.getInstance();
      logger.d('SharedPreferences initialized');
      
      // Initialize error handling
      ErrorHandler.initialize();
      logger.d('Error handler initialized');
      
      // Initialize analytics
      await AnalyticsService.initialize();
      logger.d('Analytics service initialized');
      
      // Initialize crash reporting
      await CrashReportingService.initialize();
      logger.d('Crash reporting service initialized');
      
      // Initialize cache manager
      await CacheManager.instance.initialize();
      logger.d('Cache manager initialized');
      
      // Check secure storage availability
      final secureStorageAvailable = await SecurityUtils.isSecureStorageAvailable();
      logger.d('Secure storage available: $secureStorageAvailable');
      
      // Log app start
      await AnalyticsService.trackEvent('app_initialized', {
        'version': appVersion,
        'platform': defaultTargetPlatform.toString(),
        'secure_storage_available': secureStorageAvailable,
      });
      
      logger.i('App initialization completed');
    } catch (e) {
      logger.e('Failed to initialize app: $e');
      ErrorHandler.handleError(e, context: 'App.initialize', fatal: true);
      rethrow;
    }
  }
  
  /// Check if user is authenticated
  static Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      logger.e('Failed to check authentication status: $e');
      return false;
    }
  }
  
  /// Save authentication token
  static Future<void> saveToken(String token) async {
    try {
      await SecurityUtils.storeSecurely('auth_token', token);
      logger.d('Authentication token saved securely');
    } catch (e) {
      logger.e('Failed to save authentication token: $e');
      ErrorHandler.handleError(e, context: 'App.saveToken');
      rethrow;
    }
  }
  
  /// Get authentication token
  static Future<String?> getToken() async {
    try {
      return await SecurityUtils.retrieveSecurely('auth_token');
    } catch (e) {
      logger.e('Failed to get authentication token: $e');
      ErrorHandler.handleError(e, context: 'App.getToken');
      return null;
    }
  }
  
  /// Save refresh token
  static Future<void> saveRefreshToken(String refreshToken) async {
    try {
      await SecurityUtils.storeSecurely('refresh_token', refreshToken);
      logger.d('Refresh token saved securely');
    } catch (e) {
      logger.e('Failed to save refresh token: $e');
      ErrorHandler.handleError(e, context: 'App.saveRefreshToken');
      rethrow;
    }
  }
  
  /// Get refresh token
  static Future<String?> getRefreshToken() async {
    try {
      return await SecurityUtils.retrieveSecurely('refresh_token');
    } catch (e) {
      logger.e('Failed to get refresh token: $e');
      ErrorHandler.handleError(e, context: 'App.getRefreshToken');
      return null;
    }
  }
  
  /// Save device ID
  static Future<void> saveDeviceId(String deviceId) async {
    try {
      await SecurityUtils.storeSecurely('device_id', deviceId);
      logger.d('Device ID saved securely: $deviceId');
    } catch (e) {
      logger.e('Failed to save device ID: $e');
      ErrorHandler.handleError(e, context: 'App.saveDeviceId');
      rethrow;
    }
  }
  
  /// Get device ID
  static Future<String?> getDeviceId() async {
    try {
      return await SecurityUtils.retrieveSecurely('device_id');
    } catch (e) {
      logger.e('Failed to get device ID: $e');
      ErrorHandler.handleError(e, context: 'App.getDeviceId');
      return null;
    }
  }
  
  /// Save server URL
  static Future<void> saveServerUrl(String serverUrl) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_url', serverUrl);
      logger.d('Server URL saved: $serverUrl');
    } catch (e) {
      logger.e('Failed to save server URL: $e');
      rethrow;
    }
  }
  
  /// Get server URL
  static Future<String> getServerUrl() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('server_url') ?? 'ws://localhost:8080';
    } catch (e) {
      logger.e('Failed to get server URL: $e');
      return 'ws://localhost:8080';
    }
  }
  
  /// Clear all stored data
  static Future<void> clearAllData() async {
    try {
      // Clear secure storage
      await SecurityUtils.clearAllSecureData();
      
      // Clear cache
      await CacheManager.instance.clear();
      
      // Clear shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Reset analytics
      await AnalyticsService.reset();
      
      logger.i('All stored data cleared');
    } catch (e) {
      logger.e('Failed to clear stored data: $e');
      ErrorHandler.handleError(e, context: 'App.clearAllData');
      rethrow;
    }
  }
}