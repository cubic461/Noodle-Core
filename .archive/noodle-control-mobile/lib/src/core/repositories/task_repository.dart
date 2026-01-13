import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../network/http_client.dart';
import '../network/websocket_service.dart';
import '../network/exceptions.dart';
import '../../shared/models/models.dart';

/// Task management repository
class TaskRepository {
  final HttpClient _httpClient;
  final WebSocketService _webSocketService;
  final Logger _logger = App.logger;
  
  // Stream controllers for real-time updates
  final StreamController<List<Task>> _tasksController = 
      StreamController<List<Task>>.broadcast();
  final StreamController<Task> _taskUpdateController = 
      StreamController<Task>.broadcast();
  final StreamController<Map<String, dynamic>> _performanceController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // Cached data
  List<Task> _cachedTasks = [];
  List<Map<String, dynamic>> _cachedPerformanceData = [];
  Timer? _refreshTimer;
  
  TaskRepository({
    required HttpClient httpClient,
    required WebSocketService webSocketService,
  }) : _httpClient = httpClient,
       _webSocketService = webSocketService {
    _setupWebSocketListeners();
  }
  
  /// Get all tasks
  Future<List<Task>> getTasks({
    bool forceRefresh = false,
    String? nodeId,
    TaskStatus? status,
    int? limit,
    int? offset,
  }) async {
    try {
      _logger.d('Fetching tasks');
      
      if (!forceRefresh && _cachedTasks.isNotEmpty && nodeId == null && status == null) {
        return _cachedTasks;
      }
      
      final queryParameters = <String, dynamic>{};
      if (nodeId != null) queryParameters['nodeId'] = nodeId;
      if (status != null) queryParameters['status'] = status.name;
      if (limit != null) queryParameters['limit'] = limit;
      if (offset != null) queryParameters['offset'] = offset;
      
      final response = await _httpClient.get(
        '/api/v1/tasks',
        queryParameters: queryParameters,
      );
      
      final tasksData = response['tasks'] as List<dynamic>;
      
      final tasks = tasksData
          .map((taskData) => Task.fromJson(taskData as Map<String, dynamic>))
          .toList();
      
      // Update cache if this is a full fetch
      if (nodeId == null && status == null) {
        _cachedTasks = tasks;
        _tasksController.add(tasks);
      }
      
      return tasks;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch tasks: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get task by ID
  Future<Task> getTask(String taskId) async {
    try {
      _logger.d('Fetching task: $taskId');
      
      final response = await _httpClient.get('/api/v1/tasks/$taskId');
      final taskData = response['task'] as Map<String, dynamic>;
      
      return Task.fromJson(taskData);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch task: $e');
      throw ApiException.notFound(details: e.toString());
    }
  }
  
  /// Create a new task
  Future<Task> createTask(Map<String, dynamic> taskData) async {
    try {
      _logger.i('Creating new task');
      
      final response = await _httpClient.post(
        '/api/v1/tasks',
        data: taskData,
      );
      
      final newTaskData = response['task'] as Map<String, dynamic>;
      final newTask = Task.fromJson(newTaskData);
      
      // Update cache
      _cachedTasks.add(newTask);
      _tasksController.add(_cachedTasks);
      
      return newTask;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to create task: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Update task
  Future<Task> updateTask(String taskId, Map<String, dynamic> taskData) async {
    try {
      _logger.i('Updating task: $taskId');
      
      final response = await _httpClient.put(
        '/api/v1/tasks/$taskId',
        data: taskData,
      );
      
      final updatedTaskData = response['task'] as Map<String, dynamic>;
      final updatedTask = Task.fromJson(updatedTaskData);
      
      // Update cache
      final index = _cachedTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _cachedTasks[index] = updatedTask;
        _tasksController.add(_cachedTasks);
      }
      
      return updatedTask;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to update task: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Delete task
  Future<void> deleteTask(String taskId) async {
    try {
      _logger.i('Deleting task: $taskId');
      
      await _httpClient.delete('/api/v1/tasks/$taskId');
      
      // Update cache
      _cachedTasks.removeWhere((task) => task.id == taskId);
      _tasksController.add(_cachedTasks);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to delete task: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Cancel task
  Future<void> cancelTask(String taskId) async {
    try {
      _logger.i('Cancelling task: $taskId');
      
      await _httpClient.post('/api/v1/tasks/$taskId/cancel');
      
      // Update cache
      final index = _cachedTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _cachedTasks[index] = _cachedTasks[index].copyWith(
          status: TaskStatus.cancelled,
          completedAt: DateTime.now(),
        );
        _tasksController.add(_cachedTasks);
      }
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to cancel task: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Retry task
  Future<Task> retryTask(String taskId) async {
    try {
      _logger.i('Retrying task: $taskId');
      
      final response = await _httpClient.post('/api/v1/tasks/$taskId/retry');
      final retriedTaskData = response['task'] as Map<String, dynamic>;
      final retriedTask = Task.fromJson(retriedTaskData);
      
      // Update cache
      final index = _cachedTasks.indexWhere((task) => task.id == taskId);
      if (index != -1) {
        _cachedTasks[index] = retriedTask;
        _tasksController.add(_cachedTasks);
      }
      
      return retriedTask;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to retry task: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get task logs
  Future<List<String>> getTaskLogs(String taskId, {int limit = 100}) async {
    try {
      _logger.d('Fetching task logs: $taskId');
      
      final response = await _httpClient.get(
        '/api/v1/tasks/$taskId/logs',
        queryParameters: {'limit': limit},
      );
      
      final logsData = response['logs'] as List<dynamic>;
      return logsData.map((log) => log.toString()).toList();
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch task logs: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get performance data
  Future<List<Map<String, dynamic>>> getPerformanceData({
    String? nodeId,
    String? timeRange,
  }) async {
    try {
      _logger.d('Fetching performance data');
      
      final queryParameters = <String, dynamic>{};
      if (nodeId != null) queryParameters['nodeId'] = nodeId;
      if (timeRange != null) queryParameters['timeRange'] = timeRange;
      
      final response = await _httpClient.get(
        '/api/v1/performance',
        queryParameters: queryParameters,
      );
      
      final performanceData = response['data'] as List<dynamic>;
      final data = performanceData
          .map((item) => item as Map<String, dynamic>)
          .toList();
      
      // Update cache
      _cachedPerformanceData = data;
      _performanceController.add(data);
      
      return data;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch performance data: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get tasks stream
  Stream<List<Task>> get tasksStream => _tasksController.stream;
  
  /// Get task update stream
  Stream<Task> get taskUpdateStream => _taskUpdateController.stream;
  
  /// Get performance data stream
  Stream<Map<String, dynamic>> get performanceStream => _performanceController.stream;
  
  /// Start periodic refresh
  void startPeriodicRefresh({Duration interval = const Duration(seconds: 10)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      getTasks(forceRefresh: true).catchError((e) {
        _logger.e('Failed to refresh tasks: $e');
      });
      
      getPerformanceData().catchError((e) {
        _logger.e('Failed to refresh performance data: $e');
      });
    });
  }
  
  /// Stop periodic refresh
  void stopPeriodicRefresh() {
    _refreshTimer?.cancel();
  }
  
  /// Setup WebSocket listeners for real-time updates
  void _setupWebSocketListeners() {
    _webSocketService.messageStream.listen((message) {
      switch (message.type) {
        case WebSocketMessageType.taskUpdate:
          _handleTaskUpdate(message);
          break;
        case WebSocketMessageType.performanceData:
          _handlePerformanceData(message);
          break;
        default:
          break;
      }
    });
  }
  
  /// Handle task update from WebSocket
  void _handleTaskUpdate(WebSocketMessage message) {
    try {
      final taskData = message.data['task'] as Map<String, dynamic>?;
      if (taskData == null) return;
      
      final task = Task.fromJson(taskData);
      
      // Update cache
      final index = _cachedTasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _cachedTasks[index] = task;
      } else {
        _cachedTasks.add(task);
      }
      
      // Notify listeners
      _tasksController.add(_cachedTasks);
      _taskUpdateController.add(task);
      
      _logger.d('Task updated via WebSocket: ${task.id}');
      
    } catch (e) {
      _logger.e('Failed to handle task update: $e');
    }
  }
  
  /// Handle performance data from WebSocket
  void _handlePerformanceData(WebSocketMessage message) {
    try {
      final performanceData = message.data['data'] as Map<String, dynamic>?;
      if (performanceData == null) return;
      
      // Update cache
      _cachedPerformanceData.add(performanceData);
      
      // Keep only last 100 data points
      if (_cachedPerformanceData.length > 100) {
        _cachedPerformanceData = _cachedPerformanceData.sublist(
          _cachedPerformanceData.length - 100,
        );
      }
      
      // Notify listeners
      _performanceController.add(performanceData);
      
      _logger.d('Performance data updated via WebSocket');
      
    } catch (e) {
      _logger.e('Failed to handle performance data: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _tasksController.close();
    _taskUpdateController.close();
    _performanceController.close();
  }
}

// Provider for task repository
final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return TaskRepository(
    httpClient: httpClient,
    webSocketService: webSocketService,
  );
});

// Provider for tasks stream
final tasksStreamProvider = StreamProvider<List<Task>>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.tasksStream;
});

// Provider for task updates stream
final taskUpdateStreamProvider = StreamProvider<Task>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.taskUpdateStream;
});

// Provider for performance data stream
final performanceStreamProvider = StreamProvider<Map<String, dynamic>>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return taskRepository.performanceStream;
});