import 'package:json_annotation/json_annotation.dart';

part 'exceptions.g.dart';

/// Base network exception class
@JsonSerializable()
class NetworkException implements Exception {
  final int code;
  final String message;
  final String? details;
  final DateTime timestamp;
  
  const NetworkException({
    required this.code,
    required this.message,
    this.details,
    required this.timestamp,
  });
  
  factory NetworkException.fromJson(Map<String, dynamic> json) => _$NetworkExceptionFromJson(json);
  Map<String, dynamic> toJson() => _$NetworkExceptionToJson(this);
  
  @override
  String toString() => 'NetworkException($code): $message';
}

/// Connection related exceptions
class ConnectionException extends NetworkException {
  const ConnectionException({
    required super.code,
    required super.message,
    super.details,
  }) : super(timestamp: DateTime.now());
  
  factory ConnectionException.timeout({String? details}) {
    return ConnectionException(
      code: 1001,
      message: 'Connection timeout',
      details: details,
    );
  }
  
  factory ConnectionException.unreachable({String? details}) {
    return ConnectionException(
      code: 1002,
      message: 'Server unreachable',
      details: details,
    );
  }
  
  factory ConnectionException.refused({String? details}) {
    return ConnectionException(
      code: 1003,
      message: 'Connection refused',
      details: details,
    );
  }
  
  factory ConnectionException.networkError({String? details}) {
    return ConnectionException(
      code: 1004,
      message: 'Network error',
      details: details,
    );
  }
}

/// Authentication related exceptions
class AuthenticationException extends NetworkException {
  const AuthenticationException({
    required super.code,
    required super.message,
    super.details,
  }) : super(timestamp: DateTime.now());
  
  factory AuthenticationException.unauthorized({String? details}) {
    return AuthenticationException(
      code: 2001,
      message: 'Unauthorized access',
      details: details,
    );
  }
  
  factory AuthenticationException.tokenExpired({String? details}) {
    return AuthenticationException(
      code: 2002,
      message: 'Authentication token expired',
      details: details,
    );
  }
  
  factory AuthenticationException.invalidCredentials({String? details}) {
    return AuthenticationException(
      code: 2003,
      message: 'Invalid credentials',
      details: details,
    );
  }
  
  factory AuthenticationException.deviceNotRegistered({String? details}) {
    return AuthenticationException(
      code: 2004,
      message: 'Device not registered',
      details: details,
    );
  }
}

/// API related exceptions
class ApiException extends NetworkException {
  const ApiException({
    required super.code,
    required super.message,
    super.details,
  }) : super(timestamp: DateTime.now());
  
  factory ApiException.notFound({String? details}) {
    return ApiException(
      code: 3001,
      message: 'Resource not found',
      details: details,
    );
  }
  
  factory ApiException.methodNotAllowed({String? details}) {
    return ApiException(
      code: 3002,
      message: 'Method not allowed',
      details: details,
    );
  }
  
  factory ApiException.serverError({String? details}) {
    return ApiException(
      code: 3003,
      message: 'Internal server error',
      details: details,
    );
  }
  
  factory ApiException.badRequest({String? details}) {
    return ApiException(
      code: 3004,
      message: 'Bad request',
      details: details,
    );
  }
  
  factory ApiException.rateLimited({String? details}) {
    return ApiException(
      code: 3005,
      message: 'Rate limit exceeded',
      details: details,
    );
  }
}

/// WebSocket related exceptions
class WebSocketException extends NetworkException {
  const WebSocketException({
    required super.code,
    required super.message,
    super.details,
  }) : super(timestamp: DateTime.now());
  
  factory WebSocketException.connectionFailed({String? details}) {
    return WebSocketException(
      code: 4001,
      message: 'WebSocket connection failed',
      details: details,
    );
  }
  
  factory WebSocketException.disconnected({String? details}) {
    return WebSocketException(
      code: 4002,
      message: 'WebSocket disconnected',
      details: details,
    );
  }
  
  factory WebSocketException.messageParseError({String? details}) {
    return WebSocketException(
      code: 4003,
      message: 'Failed to parse WebSocket message',
      details: details,
    );
  }
}

/// Data parsing exceptions
class DataParseException extends NetworkException {
  const DataParseException({
    required super.code,
    required super.message,
    super.details,
  }) : super(timestamp: DateTime.now());
  
  factory DataParseException.jsonParseError({String? details}) {
    return DataParseException(
      code: 5001,
      message: 'Failed to parse JSON data',
      details: details,
    );
  }
  
  factory DataParseException.invalidResponse({String? details}) {
    return DataParseException(
      code: 5002,
      message: 'Invalid response format',
      details: details,
    );
  }
}

/// Utility function to create appropriate exception from HTTP status code
NetworkException createExceptionFromStatusCode(int statusCode, {String? message, String? details}) {
  switch (statusCode) {
    case 401:
      return AuthenticationException.unauthorized(details: details);
    case 403:
      return AuthenticationException.unauthorized(details: details);
    case 404:
      return ApiException.notFound(details: details);
    case 405:
      return ApiException.methodNotAllowed(details: details);
    case 429:
      return ApiException.rateLimited(details: details);
    case 500:
    case 502:
    case 503:
    case 504:
      return ApiException.serverError(details: details);
    default:
      if (statusCode >= 400 && statusCode < 500) {
        return ApiException.badRequest(
          message: message ?? 'Client error ($statusCode)',
          details: details,
        );
      } else if (statusCode >= 500) {
        return ApiException.serverError(
          message: message ?? 'Server error ($statusCode)',
          details: details,
        );
      } else {
        return NetworkException(
          code: 9999,
          message: message ?? 'Unknown error ($statusCode)',
          details: details,
          timestamp: DateTime.now(),
        );
      }
  }
}