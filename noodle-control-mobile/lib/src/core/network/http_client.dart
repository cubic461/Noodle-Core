import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import 'exceptions.dart';
import '../utils/error_handler.dart';
import '../utils/performance_monitor.dart';
import '../utils/analytics_service.dart';
import '../utils/cache_manager.dart';

/// HTTP client service for REST API operations
class HttpClient {
  final Dio _dio;
  final Logger _logger = App.logger;
  
  HttpClient({
    required String baseUrl,
    Duration? timeout,
    String? authToken,
  }) : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: timeout ?? App.defaultTimeout,
    receiveTimeout: timeout ?? App.defaultTimeout,
    sendTimeout: timeout ?? App.defaultTimeout,
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
      'User-Agent': 'NoodleControl/${App.appVersion}',
    },
  )) {
    _setupInterceptors();
  }
  
  /// Setup request and response interceptors
  void _setupInterceptors() {
    // Request interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add request ID for tracking
          final requestId = const Uuid().v4();
          options.headers['X-Request-ID'] = requestId;
          
          // Start performance monitoring
          final timerId = PerformanceMonitor.startTimer('api_request_${options.method}_${options.path}');
          options.extra['timerId'] = timerId;
          options.extra['requestId'] = requestId;
          
          _logger.d('API Request: ${options.method} ${options.path} (ID: $requestId)');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // End performance monitoring
          final timerId = response.requestOptions.extra['timerId'] as String?;
          final requestId = response.requestOptions.extra['requestId'] as String?;
          
          if (timerId != null) {
            final duration = PerformanceMonitor.endTimer(timerId);
            
            // Track API call in analytics
            AnalyticsService.trackApiCall(
              response.requestOptions.path,
              response.requestOptions.method,
              response.statusCode ?? 0,
              duration,
              additionalParams: {
                'request_id': requestId,
                'response_size': response.data?.toString().length ?? 0,
              },
            );
          }
          
          _logger.d('API Response: ${response.statusCode} ${response.requestOptions.path}');
          handler.next(response);
        },
        onError: (error, handler) {
          // End performance monitoring
          final timerId = error.requestOptions.extra['timerId'] as String?;
          final requestId = error.requestOptions.extra['requestId'] as String?;
          
          if (timerId != null) {
            final duration = PerformanceMonitor.endTimer(timerId);
            
            // Track API error in analytics
            AnalyticsService.trackApiCall(
              error.requestOptions.path,
              error.requestOptions.method,
              error.response?.statusCode ?? 0,
              duration,
              additionalParams: {
                'request_id': requestId,
                'error': error.message,
              },
            );
          }
          
          // Handle error
          final networkException = _handleDioError(error);
          ErrorHandler.handleNetworkError(networkException, context: 'HTTP Request');
          
          _logger.e('API Error: ${error.requestOptions.path} - ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
  
  /// Update authentication token
  void updateAuthToken(String? token) {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }
  
  /// Update base URL
  void updateBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }
  
  /// Make GET request
  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool useCache = true,
  }) async {
    // Check cache first
    if (useCache) {
      final cacheKey = 'get_${path}_${queryParameters?.toString() ?? ''}';
      final cachedResponse = NetworkCacheManager.getCachedResponse(cacheKey);
      if (cachedResponse != null) {
        _logger.d('Using cached response for GET: $path');
        return cachedResponse;
      }
    }
    
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      
      final handledResponse = _handleResponse(response);
      
      // Cache response if successful
      if (useCache && (response.statusCode ?? 0) >= 200 && (response.statusCode ?? 0) < 300) {
        final cacheKey = 'get_${path}_${queryParameters?.toString() ?? ''}';
        await NetworkCacheManager.cacheResponse(cacheKey, handledResponse);
      }
      
      return handledResponse;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in GET request: $e');
      ErrorHandler.handleError(e, context: 'HTTP GET Request');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Make POST request
  Future<Map<String, dynamic>> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in POST request: $e');
      ErrorHandler.handleError(e, context: 'HTTP POST Request');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Make PUT request
  Future<Map<String, dynamic>> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in PUT request: $e');
      ErrorHandler.handleError(e, context: 'HTTP PUT Request');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Make PATCH request
  Future<Map<String, dynamic>> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in PATCH request: $e');
      ErrorHandler.handleError(e, context: 'HTTP PATCH Request');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Make DELETE request
  Future<Map<String, dynamic>> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in DELETE request: $e');
      ErrorHandler.handleError(e, context: 'HTTP DELETE Request');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Upload file
  Future<Map<String, dynamic>> uploadFile(
    String path,
    File file, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
        ...?data,
      });
      
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      _logger.e('Unexpected error in file upload: $e');
      ErrorHandler.handleError(e, context: 'HTTP File Upload');
      throw NetworkException(
        code: 9999,
        message: 'Unexpected error',
        details: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }
  
  /// Handle successful response
  Map<String, dynamic> _handleResponse(Response<Map<String, dynamic>> response) {
    final data = response.data;
    
    if (data == null) {
      throw DataParseException.invalidResponse(
        details: 'Response data is null',
      );
    }
    
    // Check if response contains requestId as per API requirements
    if (!data.containsKey('requestId')) {
      _logger.w('Response missing requestId field');
    }
    
    return data;
  }
  
  /// Handle Dio errors and convert to appropriate exceptions
  NetworkException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ConnectionException.timeout(
          details: error.message,
        );
      
      case DioExceptionType.connectionError:
        return ConnectionException.unreachable(
          details: error.message,
        );
      
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode ?? 0;
        final message = error.response?.statusMessage;
        final responseData = error.response?.data;
        
        String? details;
        if (responseData is Map<String, dynamic>) {
          details = responseData['error']?.toString() ?? responseData['message']?.toString();
        }
        
        return createExceptionFromStatusCode(
          statusCode,
          message: message,
          details: details,
        );
      
      case DioExceptionType.cancel:
        return NetworkException(
          code: 9998,
          message: 'Request cancelled',
          details: error.message,
          timestamp: DateTime.now(),
        );
      
      case DioExceptionType.unknown:
      default:
        return NetworkException(
          code: 9999,
          message: 'Unknown network error',
          details: error.message,
          timestamp: DateTime.now(),
        );
    }
  }
}