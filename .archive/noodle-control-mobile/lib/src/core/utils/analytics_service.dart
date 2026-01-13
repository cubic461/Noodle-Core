import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:uuid/uuid.dart';
import '../app.dart';
import 'error_handler.dart';

/// Analytics service for tracking user behavior and app performance
class AnalyticsService {
  static final Logger _logger = App.logger;
  static const Uuid _uuid = Uuid();
  static bool _initialized = false;
  static String? _userId;
  static String? _sessionId;
  
  /// Initialize the analytics service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Generate or retrieve session ID
      _sessionId = await _getOrCreateSessionId();
      
      // In a real implementation, you would initialize a service like:
      // - Firebase Analytics
      // - Amplitude
      // - Mixpanel
      // - Custom analytics backend
      
      _initialized = true;
      _logger.i('Analytics service initialized with session ID: $_sessionId');
      
      // Track app start
      trackEvent('app_start', {
        'platform': Platform.operatingSystem,
        'version': App.appVersion,
        'buildNumber': Platform.isIOS 
            ? 'iOS' 
            : Platform.isAndroid 
                ? 'Android' 
                : 'Unknown',
      });
    } catch (e) {
      _logger.e('Failed to initialize analytics service: $e');
    }
  }
  
  /// Set the current user ID for analytics
  static Future<void> setUserId(String userId) async {
    _userId = userId;
    
    // In a real implementation, you would set the user ID in your analytics service
    // For example: FirebaseAnalytics.instance.setUserId(userId);
    
    _logger.d('Analytics user ID set: $userId');
  }
  
  /// Set user properties for analytics
  static Future<void> setUserProperties(Map<String, dynamic> properties) async {
    // In a real implementation, you would set user properties in your analytics service
    // For example: 
    // for (final entry in properties.entries) {
    //   FirebaseAnalytics.instance.setUserProperty(name: entry.key, value: entry.value.toString());
    // }
    
    _logger.d('Analytics user properties set: $properties');
  }
  
  /// Track a custom event
  static Future<void> trackEvent(
    String eventName, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_initialized) {
      _logger.w('Analytics service not initialized, skipping event tracking');
      return;
    }
    
    try {
      final enrichedParameters = <String, dynamic>{
        'session_id': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        if (_userId != null) 'user_id': _userId,
        ...?parameters,
      };
      
      // In a real implementation, you would send the event to your analytics service
      // For example: FirebaseAnalytics.instance.logEvent(name: eventName, parameters: enrichedParameters);
      
      _logger.d('Analytics event tracked: $eventName with parameters: $enrichedParameters');
    } catch (e) {
      _logger.e('Failed to track analytics event: $e');
      ErrorHandler.handleError(e, context: 'Analytics.trackEvent');
    }
  }
  
  /// Track screen view
  static Future<void> trackScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    await trackEvent('screen_view', {
      'screen_name': screenName,
      'screen_class': screenClass ?? screenName,
    });
  }
  
  /// Track user interaction
  static Future<void> trackInteraction(
    String elementType,
    String action, {
    String? elementId,
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent('user_interaction', {
      'element_type': elementType,
      'action': action,
      if (elementId != null) 'element_id': elementId,
      ...?additionalParams,
    });
  }
  
  /// Track performance metrics
  static Future<void> trackPerformance(
    String operation,
    int durationMs, {
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent('performance', {
      'operation': operation,
      'duration_ms': durationMs,
      ...?additionalParams,
    });
  }
  
  /// Track error
  static Future<void> trackError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? additionalParams,
    bool fatal = false,
  }) async {
    await trackEvent('error', {
      'error_type': error.runtimeType.toString(),
      'error_message': error.toString(),
      'context': context,
      'fatal': fatal,
      ...?additionalParams,
    });
  }
  
  /// Track API call
  static Future<void> trackApiCall(
    String endpoint,
    String method,
    int statusCode,
    int durationMs, {
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent('api_call', {
      'endpoint': endpoint,
      'method': method,
      'status_code': statusCode,
      'duration_ms': durationMs,
      ...?additionalParams,
    });
  }
  
  /// Track user engagement
  static Future<void> trackEngagement(
    String feature, {
    int? durationSeconds,
    Map<String, dynamic>? additionalParams,
  }) async {
    await trackEvent('user_engagement', {
      'feature': feature,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      ...?additionalParams,
    });
  }
  
  /// Track app lifecycle events
  static Future<void> trackAppLifecycleEvent(String event) async {
    await trackEvent('app_lifecycle', {
      'event': event,
    });
  }
  
  /// Get or create a session ID
  static Future<String> _getOrCreateSessionId() async {
    // In a real implementation, you would store and retrieve the session ID
    // from persistent storage. For now, we'll generate a new one each time.
    return _uuid.v4();
  }
  
  /// Reset analytics data
  static Future<void> reset() async {
    _userId = null;
    _sessionId = await _getOrCreateSessionId();
    
    // In a real implementation, you would reset the analytics service
    // For example: FirebaseAnalytics.instance.resetAnalyticsData();
    
    _logger.d('Analytics data reset');
  }
  
  /// Enable/disable analytics collection
  static Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    // In a real implementation, you would enable/disable analytics collection
    // For example: FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(enabled);
    
    _logger.d('Analytics collection ${enabled ? 'enabled' : 'disabled'}');
  }
}

/// Crash reporting service
class CrashReportingService {
  static final Logger _logger = App.logger;
  static bool _initialized = false;
  
  /// Initialize the crash reporting service
  static Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // In a real implementation, you would initialize a service like:
      // - Firebase Crashlytics
      // - Sentry
      // - Bugsnag
      
      _initialized = true;
      _logger.i('Crash reporting service initialized');
    } catch (e) {
      _logger.e('Failed to initialize crash reporting service: $e');
    }
  }
  
  /// Report a non-fatal error
  static Future<void> reportError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) async {
    if (!_initialized) {
      _logger.w('Crash reporting service not initialized, skipping error reporting');
      return;
    }
    
    try {
      // In a real implementation, you would report the error to your crash reporting service
      // For example: 
      // FirebaseCrashlytics.instance.recordError(
      //   error,
      //   stackTrace,
      //   fatal: fatal,
      //   information: [
      //     DiagnosticsProperty('context', context),
      //     ...extra?.entries.map((e) => DiagnosticsProperty(e.key, e.value)) ?? [],
      //   ],
      // );
      
      // Also track in analytics
      await AnalyticsService.trackError(
        error,
        stackTrace: stackTrace,
        context: context,
        additionalParams: extra,
        fatal: fatal,
      );
      
      _logger.d('Error reported to crash reporting service: $error');
    } catch (e) {
      _logger.e('Failed to report error: $e');
      ErrorHandler.handleError(e, context: 'CrashReportingService.reportError');
    }
  }
  
  /// Report a message
  static Future<void> reportMessage(
    String message, {
    String? context,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) {
      _logger.w('Crash reporting service not initialized, skipping message reporting');
      return;
    }
    
    try {
      // In a real implementation, you would report the message to your crash reporting service
      // For example: FirebaseCrashlytics.instance.log('$context: $message');
      
      _logger.d('Message reported to crash reporting service: $message');
    } catch (e) {
      _logger.e('Failed to report message: $e');
      ErrorHandler.handleError(e, context: 'CrashReportingService.reportMessage');
    }
  }
  
  /// Set user identifier for crash reports
  static Future<void> setUserIdentifier(String identifier) async {
    // In a real implementation, you would set the user identifier in your crash reporting service
    // For example: FirebaseCrashlytics.instance.setUserIdentifier(identifier);
    
    _logger.d('Crash reporting user identifier set: $identifier');
  }
  
  /// Set custom keys for crash reports
  static Future<void> setCustomKey(String key, dynamic value) async {
    // In a real implementation, you would set custom keys in your crash reporting service
    // For example: FirebaseCrashlytics.instance.setCustomKey(key, value.toString());
    
    _logger.d('Crash reporting custom key set: $key = $value');
  }
  
  /// Enable/disable crash reporting
  static Future<void> setCrashReportingEnabled(bool enabled) async {
    // In a real implementation, you would enable/disable crash reporting
    // For example: FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(enabled);
    
    _logger.d('Crash reporting ${enabled ? 'enabled' : 'disabled'}');
  }
  
  /// Test crash reporting
  static Future<void> testCrash() async {
    if (kDebugMode) {
      // In a real implementation, you would test the crash reporting
      // For example: FirebaseCrashlytics.instance.crash();
      
      _logger.d('Test crash requested (debug mode only)');
    } else {
      _logger.w('Test crash is only available in debug mode');
    }
  }
}

/// Extension to add analytics tracking to widgets
extension AnalyticsWidgetExtension on Widget {
  /// Track when this widget is built
  Widget trackScreen(String screenName) {
    return Builder(
      builder: (context) {
        // Track screen view when widget is built
        WidgetsBinding.instance.addPostFrameCallback((_) {
          AnalyticsService.trackScreenView(screenName);
        });
        return this;
      },
    );
  }
}

/// Mixin to add analytics tracking to State classes
mixin AnalyticsTrackingMixin<T extends StatefulWidget> on State<T> {
  String get screenName => widget.runtimeType.toString();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AnalyticsService.trackScreenView(screenName);
    });
  }
}