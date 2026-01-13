import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:noodle_control_mobile_app/src/shared/models/models.dart';
import 'package:noodle_control_mobile_app/src/core/network/exceptions.dart';

// Generate mocks
@GenerateMocks([
  Dio,
  Response,
  ResponseType,
  HttpClient,
  WebSocketService,
  ConnectionService,
])
void main() {}

/// Test helper class for common test utilities
class TestHelpers {
  /// Creates a mock HTTP response
  static Response<Map<String, dynamic>> createMockResponse({
    int statusCode = 200,
    Map<String, dynamic>? data,
    String? statusMessage,
  }) {
    final response = MockResponse<Map<String, dynamic>>();
    when(response.statusCode).thenReturn(statusCode);
    when(response.data).thenReturn(data ?? {});
    when(response.statusMessage).thenReturn(statusMessage ?? 'OK');
    when(response.requestOptions).thenReturn(RequestOptions(path: '/test'));
    return response;
  }

  /// Creates a mock Dio error
  static DioException createMockDioError({
    DioExceptionType type = DioExceptionType.unknown,
    int? statusCode,
    String? message,
    Response? response,
  }) {
    return DioException(
      type: type,
      requestOptions: RequestOptions(path: '/test'),
      response: response,
      message: message,
    );
  }

  /// Creates a test user
  static User createTestUser({
    String id = 'test-user-id',
    String username = 'testuser',
    String email = 'test@example.com',
  }) {
    final now = DateTime.now();
    return User(
      id: id,
      username: username,
      email: email,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a test device
  static Device createTestDevice({
    String id = 'test-device-id',
    String name = 'Test Device',
    String type = 'mobile',
  }) {
    final now = DateTime.now();
    return Device(
      id: id,
      name: name,
      type: type,
      isActive: true,
      lastSeen: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a test node
  static Node createTestNode({
    String id = 'test-node-id',
    String name = 'Test Node',
    String type = 'compute',
    NodeStatus status = NodeStatus.idle,
  }) {
    final now = DateTime.now();
    return Node(
      id: id,
      name: name,
      type: type,
      status: status,
      lastHeartbeat: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a test task
  static Task createTestTask({
    String id = 'test-task-id',
    String title = 'Test Task',
    String nodeId = 'test-node-id',
    TaskStatus status = TaskStatus.pending,
  }) {
    final now = DateTime.now();
    return Task(
      id: id,
      title: title,
      nodeId: nodeId,
      status: status,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a test IDE project
  static IdeProject createTestIdeProject({
    String id = 'test-project-id',
    String name = 'Test Project',
    String path = '/test/path',
    String language = 'dart',
  }) {
    final now = DateTime.now();
    return IdeProject(
      id: id,
      name: name,
      path: path,
      language: language,
      isOpen: false,
      lastAccessed: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates test app settings
  static AppSettings createTestAppSettings({
    String serverUrl = 'ws://localhost:8080',
    bool autoConnect = true,
    bool notificationsEnabled = true,
    bool darkMode = false,
    String themeMode = 'system',
    int connectionTimeout = 30,
    int maxRetries = 3,
    bool enableLogging = true,
    String logLevel = 'INFO',
  }) {
    return AppSettings(
      serverUrl: serverUrl,
      autoConnect: autoConnect,
      notificationsEnabled: notificationsEnabled,
      darkMode: darkMode,
      themeMode: themeMode,
      connectionTimeout: connectionTimeout,
      maxRetries: maxRetries,
      enableLogging: enableLogging,
      logLevel: logLevel,
    );
  }

  /// Creates a mock file for testing
  static File createMockFile(String path, {String content = 'test content'}) {
    final file = File(path);
    return file;
  }

  /// Verifies that an exception matches the expected type and code
  static void expectException(
    Exception exception,
    Type expectedType,
    int expectedCode,
  ) {
    expect(exception, isA<expectedType>());
    if (exception is NetworkException) {
      expect(exception.code, equals(expectedCode));
    }
  }

  /// Creates a JSON string from a map
  static String createJsonString(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  /// Parses a JSON string to a map
  static Map<String, dynamic> parseJsonString(String jsonString) {
    return jsonDecode(jsonString) as Map<String, dynamic>;
  }

  /// Creates a test response with requestId
  static Map<String, dynamic> createTestResponse({
    Map<String, dynamic>? data,
    String? requestId,
  }) {
    return {
      'requestId': requestId ?? 'test-request-id',
      ...?data,
    };
  }

  /// Creates a test WebSocket message
  static Map<String, dynamic> createTestWebSocketMessage({
    String type = 'heartbeat',
    Map<String, dynamic>? data,
    String? id,
  }) {
    return {
      'id': id ?? 'test-message-id',
      'type': type,
      'data': data ?? {},
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Waits for a specified duration (useful for async tests)
  static Future<void> waitFor(Duration duration) {
    return Future.delayed(duration);
  }

  /// Creates a test stream that emits values after delays
  static Stream<T> createTestStream<T>(List<T> values, {Duration delay = const Duration(milliseconds: 100)}) {
    return Stream.fromIterable(values).asyncMap((value) async {
      await waitFor(delay);
      return value;
    });
  }

  /// Verifies that a stream emits expected values in order
  static Future<void> expectStream<T>(
    Stream<T> stream,
    List<T> expectedValues, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final receivedValues = <T>[];
    await for (final value in stream.timeout(timeout)) {
      receivedValues.add(value);
      if (receivedValues.length == expectedValues.length) {
        break;
      }
    }
    expect(receivedValues, equals(expectedValues));
  }

  /// Creates a mock error response
  static Map<String, dynamic> createErrorResponse({
    int code = 400,
    String message = 'Bad Request',
    String? error,
  }) {
    return {
      'code': code,
      'message': message,
      'error': error ?? message,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Custom matcher for NetworkException
class NetworkExceptionMatcher extends Matcher {
  final int expectedCode;
  final String? expectedMessage;

  const NetworkExceptionMatcher(this.expectedCode, {this.expectedMessage});

  @override
  Description describe(Description description) {
    description.add('NetworkException with code $expectedCode');
    if (expectedMessage != null) {
      description.add(' and message "$expectedMessage"');
    }
    return description;
  }

  @override
  bool matches(item, Map matchState) {
    if (item is! NetworkException) return false;
    if (item.code != expectedCode) return false;
    if (expectedMessage != null && item.message != expectedMessage) return false;
    return true;
  }
}

/// Convenience function for creating NetworkException matcher
Matcher isNetworkException(int code, {String? message}) {
  return NetworkExceptionMatcher(code, expectedMessage: message);
}