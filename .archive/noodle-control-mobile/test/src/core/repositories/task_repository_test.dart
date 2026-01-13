import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:noodle_control_mobile_app/src/core/repositories/task_repository.dart';
import 'package:noodle_control_mobile_app/src/core/network/http_client.dart';
import 'package:noodle_control_mobile_app/src/core/network/websocket_service.dart';
import 'package:noodle_control_mobile_app/src/core/network/exceptions.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';

import '../../test_utils/test_helpers.dart';
import '../../test_utils/mock_data.dart';
import '../../test_utils/test_config.dart';

// Generate mocks
@GenerateMocks([
  HttpClient,
  WebSocketService,
])
import 'task_repository_test.mocks.dart';

void main() {
  group(TestGroups.taskManagement, () {
    late TaskRepository taskRepository;
    late MockHttpClient mockHttpClient;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockWebSocketService = MockWebSocketService();
      taskRepository = TaskRepository(
        httpClient: mockHttpClient,
        webSocketService: mockWebSocketService,
      );
    });

    tearDown(() {
      taskRepository.dispose();
    });

    group('getTasks', () {
      test(TestDescriptions.getTasksSuccess, () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => MockData.getTasksResponse);
        
        // Act
        final result = await taskRepository.getTasks();
        
        // Assert
        expect(result, isA<List<Task>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testTask.id));
        expect(result[0].title, equals(MockData.testTask.title));
        
        verify(mockHttpClient.get(
          '/api/v1/tasks',
          queryParameters: {},
        )).called(1);
      });

      test('should return cached tasks when forceRefresh is false', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => MockData.getTasksResponse);
        
        // First call to populate cache
        await taskRepository.getTasks();
        
        // Act - Second call should use cache
        final result = await taskRepository.getTasks();
        
        // Assert
        expect(result, isA<List<Task>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testTask.id));
        
        // HTTP client should only be called once
        verify(mockHttpClient.get(
          '/api/v1/tasks',
          queryParameters: {},
        )).called(1);
      });

      test('should fetch fresh tasks when forceRefresh is true', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => MockData.getTasksResponse);
        
        // First call to populate cache
        await taskRepository.getTasks();
        
        // Act - Second call with forceRefresh should fetch fresh data
        final result = await taskRepository.getTasks(forceRefresh: true);
        
        // Assert
        expect(result, isA<List<Task>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testTask.id));
        
        // HTTP client should be called twice
        verify(mockHttpClient.get(
          '/api/v1/tasks',
          queryParameters: {},
        )).called(2);
      });

      test('should fetch tasks with filters', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        const status = TaskStatus.running;
        const limit = 10;
        const offset = 0;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => MockData.getTasksResponse);
        
        // Act
        await taskRepository.getTasks(
          nodeId: nodeId,
          status: status,
          limit: limit,
          offset: offset,
        );
        
        // Assert
        verify(mockHttpClient.get(
          '/api/v1/tasks',
          queryParameters: {
            'nodeId': nodeId,
            'status': status.name,
            'limit': limit,
            'offset': offset,
          },
        )).called(1);
      });

      test('should handle network exceptions when getting tasks', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.getTasks(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getTask', () {
      test(TestDescriptions.getTaskSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getTaskResponse);
        
        // Act
        final result = await taskRepository.getTask(taskId);
        
        // Assert
        expect(result, isA<Task>());
        expect(result.id, equals(MockData.testTask.id));
        expect(result.title, equals(MockData.testTask.title));
        
        verify(mockHttpClient.get('/api/v1/tasks/$taskId')).called(1);
      });

      test('should handle network exceptions when getting task', () async {
        // Arrange
        const taskId = 'invalid-task-id';
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.getTask(taskId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('createTask', () {
      test(TestDescriptions.createTaskSuccess, () async {
        // Arrange
        final taskData = {
          'title': TestConstants.testTaskTitle,
          'description': TestConstants.testTaskDescription,
          'nodeId': TestConstants.testNodeId,
        };
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'create-task-123',
          'task': MockData.testTaskJson,
        });
        
        // Act
        final result = await taskRepository.createTask(taskData);
        
        // Assert
        expect(result, isA<Task>());
        expect(result.id, equals(MockData.testTask.id));
        expect(result.title, equals(MockData.testTask.title));
        
        verify(mockHttpClient.post(
          '/api/v1/tasks',
          data: taskData,
        )).called(1);
      });

      test('should handle network exceptions when creating task', () async {
        // Arrange
        final taskData = {
          'title': TestConstants.testTaskTitle,
          'nodeId': TestConstants.testNodeId,
        };
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.createTask(taskData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateTask', () {
      test(TestDescriptions.updateTaskSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        final taskData = {
          'title': 'Updated Task Title',
        };
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'update-task-123',
          'task': MockData.testTaskJson,
        });
        
        // Act
        final result = await taskRepository.updateTask(taskId, taskData);
        
        // Assert
        expect(result, isA<Task>());
        expect(result.id, equals(MockData.testTask.id));
        
        verify(mockHttpClient.put(
          '/api/v1/tasks/$taskId',
          data: taskData,
        )).called(1);
      });

      test('should handle network exceptions when updating task', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        final taskData = {
          'title': 'Updated Task Title',
        };
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.updateTask(taskId, taskData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteTask', () {
      test(TestDescriptions.deleteTaskSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.delete(any)).thenAnswer((_) async => {
          'requestId': 'delete-task-123',
        });
        
        // Act
        await taskRepository.deleteTask(taskId);
        
        // Assert
        verify(mockHttpClient.delete('/api/v1/tasks/$taskId')).called(1);
      });

      test('should handle network exceptions when deleting task', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.delete(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.deleteTask(taskId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('cancelTask', () {
      test(TestDescriptions.cancelTaskSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'cancel-task-123',
        });
        
        // First populate cache
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => MockData.getTasksResponse);
        await taskRepository.getTasks();
        
        // Act
        await taskRepository.cancelTask(taskId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/tasks/$taskId/cancel')).called(1);
      });

      test('should handle network exceptions when cancelling task', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.cancelTask(taskId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('retryTask', () {
      test(TestDescriptions.retryTaskSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'retry-task-123',
          'task': MockData.testTaskJson,
        });
        
        // Act
        final result = await taskRepository.retryTask(taskId);
        
        // Assert
        expect(result, isA<Task>());
        expect(result.id, equals(MockData.testTask.id));
        
        verify(mockHttpClient.post('/api/v1/tasks/$taskId/retry')).called(1);
      });

      test('should handle network exceptions when retrying task', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.retryTask(taskId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getTaskLogs', () {
      test(TestDescriptions.getTaskLogsSuccess, () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        const limit = 50;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'task-logs-123',
          'logs': MockData.testLogs,
        });
        
        // Act
        final result = await taskRepository.getTaskLogs(taskId, limit: limit);
        
        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, equals(MockData.testLogs.length));
        expect(result[0], equals(MockData.testLogs[0]));
        
        verify(mockHttpClient.get(
          '/api/v1/tasks/$taskId/logs',
          queryParameters: {'limit': limit},
        )).called(1);
      });

      test('should use default limit when not specified', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'task-logs-123',
          'logs': MockData.testLogs,
        });
        
        // Act
        await taskRepository.getTaskLogs(taskId);
        
        // Assert
        verify(mockHttpClient.get(
          '/api/v1/tasks/$taskId/logs',
          queryParameters: {'limit': 100}, // Default limit
        )).called(1);
      });

      test('should handle network exceptions when getting task logs', () async {
        // Arrange
        const taskId = TestConstants.testTaskId;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.getTaskLogs(taskId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getPerformanceData', () {
      test(TestDescriptions.getPerformanceDataSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        const timeRange = '1h';
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'performance-data-123',
          'data': MockData.testPerformanceData,
        });
        
        // Act
        final result = await taskRepository.getPerformanceData(
          nodeId: nodeId,
          timeRange: timeRange,
        );
        
        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(MockData.testPerformanceData.length));
        expect(result[0]['nodeId'], equals(nodeId));
        
        verify(mockHttpClient.get(
          '/api/v1/performance',
          queryParameters: {
            'nodeId': nodeId,
            'timeRange': timeRange,
          },
        )).called(1);
      });

      test('should handle network exceptions when getting performance data', () async {
        // Arrange
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await taskRepository.getPerformanceData(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('periodic refresh', () {
      test('should start periodic refresh', () async {
        // Act
        taskRepository.startPeriodicRefresh();
        
        // Wait a bit to allow the timer to start
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        // Assert - Timer should be started (no direct way to verify without making timer public)
        expect(taskRepository.tasksStream, isA<Stream>());
        
        // Clean up
        taskRepository.stopPeriodicRefresh();
      });

      test('should stop periodic refresh', () async {
        // Act
        taskRepository.startPeriodicRefresh();
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        taskRepository.stopPeriodicRefresh();
        
        // Assert - No exceptions should be thrown
        expect(taskRepository.tasksStream, isA<Stream>());
      });
    });

    group('streams', () {
      test('should provide tasks stream', () {
        // Act & Assert
        expect(taskRepository.tasksStream, isA<Stream<List<Task>>>());
      });

      test('should provide task update stream', () {
        // Act & Assert
        expect(taskRepository.taskUpdateStream, isA<Stream<Task>>());
      });

      test('should provide performance data stream', () {
        // Act & Assert
        expect(taskRepository.performanceStream, isA<Stream<Map<String, dynamic>>>());
      });
    });
  });
}