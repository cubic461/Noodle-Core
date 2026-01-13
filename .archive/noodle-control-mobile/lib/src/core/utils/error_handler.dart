import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../app.dart';
import '../network/exceptions.dart';

/// Global error handler for the application
class ErrorHandler {
  static final Logger _logger = App.logger;
  static bool _initialized = false;

  /// Initialize the global error handler
  static void initialize() {
    if (_initialized) return;
    
    // Set up error handlers for different platforms
    if (!kIsWeb) {
      // Flutter error handling
      FlutterError.onError = (FlutterErrorDetails details) {
        _logFlutterError(details);
        _reportError(details.exception, details.stack);
      };
      
      // Platform-specific error handling
      PlatformDispatcher.instance.onError = (error, stack) {
        _logPlatformError(error, stack);
        _reportError(error, stack);
        return true;
      };
    }
    
    _initialized = true;
    _logger.i('Error handler initialized');
  }

  /// Handle and log application errors
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extra,
    bool fatal = false,
  }) {
    // Log the error
    _logError(error, stackTrace, context, extra);
    
    // Report the error if needed
    _reportError(error, stackTrace, context: context, extra: extra);
    
    // Handle fatal errors
    if (fatal) {
      _logger.e('Fatal error occurred, app will terminate');
      // In a real app, you might want to show a dialog or restart the app
    }
  }

  /// Handle network errors with specific context
  static void handleNetworkError(
    NetworkException error, {
    String? context,
    Map<String, dynamic>? extra,
  }) {
    final enrichedExtra = <String, dynamic>{
      'errorCode': error.code,
      'errorType': error.runtimeType.toString(),
      ...?extra,
    };
    
    handleError(
      error,
      context: context ?? 'Network operation',
      extra: enrichedExtra,
    );
  }

  /// Handle and log async errors
  static Future<T> handleAsyncError<T>(
    Future<T> Function() operation, {
    String? context,
    Map<String, dynamic>? extra,
    T? defaultValue,
  }) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      handleError(
        error,
        stackTrace: stackTrace,
        context: context,
        extra: extra,
      );
      return defaultValue as T;
    }
  }

  /// Create a user-friendly error message
  static String getUserFriendlyMessage(dynamic error) {
    if (error is NetworkException) {
      switch (error.code) {
        case 1001:
          return 'Connection timeout. Please check your internet connection and try again.';
        case 1002:
          return 'Server is unreachable. Please check your connection and try again.';
        case 1003:
          return 'Connection was refused. Please try again later.';
        case 1004:
          return 'Network error occurred. Please check your internet connection.';
        case 2001:
        case 2002:
          return 'Authentication failed. Please log in again.';
        case 2003:
          return 'Invalid credentials. Please check your username and password.';
        case 2004:
          return 'Device not registered. Please register your device first.';
        case 3001:
          return 'The requested resource was not found.';
        case 3002:
          return 'This operation is not allowed.';
        case 3003:
          return 'Server error occurred. Please try again later.';
        case 3004:
          return 'Invalid request. Please check your input and try again.';
        case 3005:
          return 'Too many requests. Please wait a moment and try again.';
        case 5001:
        case 5002:
          return 'Data processing error. Please try again.';
        default:
          return error.message.isNotEmpty 
              ? error.message 
              : 'An unknown error occurred. Please try again.';
      }
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  /// Log Flutter-specific errors
  static void _logFlutterError(FlutterErrorDetails details) {
    final error = details.exception;
    final stack = details.stack;
    final context = details.context?.toString();
    
    _logger.e(
      'Flutter Error: ${error.runtimeType}',
      error: error,
      stackTrace: stack,
    );
    
    if (context != null) {
      _logger.d('Error context: $context');
    }
  }

  /// Log platform-specific errors
  static void _logPlatformError(dynamic error, StackTrace stack) {
    _logger.e(
      'Platform Error: ${error.runtimeType}',
      error: error,
      stackTrace: stack,
    );
  }

  /// Log general errors with context
  static void _logError(
    dynamic error,
    StackTrace? stackTrace,
    String? context,
    Map<String, dynamic>? extra,
  ) {
    final message = context != null 
        ? 'Error in $context: ${error.toString()}'
        : 'Error: ${error.toString()}';
    
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );
    
    if (extra != null && extra.isNotEmpty) {
      _logger.d('Error details: $extra');
    }
  }

  /// Report errors to analytics/crash reporting service
  static void _reportError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, dynamic>? extra,
  }) {
    // In a production app, you would send this to a service like:
    // - Firebase Crashlytics
    // - Sentry
    // - Custom error tracking service
    
    if (kDebugMode) {
      // In debug mode, just log the error
      _logger.d('Error reporting (debug mode): $error');
      return;
    }
    
    // In production, you would send the error to your reporting service
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
  }
}

/// Extension to add error handling to Future
extension FutureErrorHandling<T> on Future<T> {
  /// Handle errors for this future
  Future<T?> handleError({
    String? context,
    Map<String, dynamic>? extra,
    T? defaultValue,
  }) {
    return ErrorHandler.handleAsyncError(
      () => this,
      context: context,
      extra: extra,
      defaultValue: defaultValue,
    );
  }
}

/// Extension to add error handling to Stream
extension StreamErrorHandling<T> on Stream<T> {
  /// Handle errors for this stream
  Stream<T> handleError({
    String? context,
    Map<String, dynamic>? extra,
  }) {
    return this.handleError((error, stackTrace) {
      ErrorHandler.handleError(
        error,
        stackTrace: stackTrace,
        context: context,
        extra: extra,
      );
    });
  }
}