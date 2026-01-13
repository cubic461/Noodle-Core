import 'dart:convert';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';

/// Mock data provider for testing
class MockData {
  // User data
  static const Map<String, dynamic> testUserJson = {
    'id': 'user-123',
    'username': 'testuser',
    'email': 'test@example.com',
    'avatar': null,
    'createdAt': '2023-01-01T00:00:00.000Z',
    'updatedAt': '2023-01-01T00:00:00.000Z',
  };

  static const User testUser = User(
    id: 'user-123',
    username: 'testuser',
    email: 'test@example.com',
    avatar: null,
    createdAt: _testDateTime,
    updatedAt: _testDateTime,
  );

  // Device data
  static const Map<String, dynamic> testDeviceJson = {
    'id': 'device-456',
    'name': 'Test Device',
    'type': 'mobile',
    'model': 'Test Model',
    'osVersion': '1.0.0',
    'appVersion': '1.0.0',
    'isActive': true,
    'lastSeen': '2023-01-01T00:00:00.000Z',
    'createdAt': '2023-01-01T00:00:00.000Z',
    'updatedAt': '2023-01-01T00:00:00.000Z',
  };

  static const Device testDevice = Device(
    id: 'device-456',
    name: 'Test Device',
    type: 'mobile',
    model: 'Test Model',
    osVersion: '1.0.0',
    appVersion: '1.0.0',
    isActive: true,
    lastSeen: _testDateTime,
    createdAt: _testDateTime,
    updatedAt: _testDateTime,
  );

  // Node data
  static const Map<String, dynamic> testNodeJson = {
    'id': 'node-789',
    'name': 'Test Node',
    'type': 'compute',
    'status': 'idle',
    'cpuUsage': 25.5,
    'memoryUsage': 60.2,
    'activeTasks': 2,
    'totalTasks': 10,
    'ipAddress': '192.168.1.100',
    'port': 8080,
    'lastHeartbeat': '2023-01-01T00:00:00.000Z',
    'createdAt': '2023-01-01T00:00:00.000Z',
    'updatedAt': '2023-01-01T00:00:00.000Z',
  };

  static const Node testNode = Node(
    id: 'node-789',
    name: 'Test Node',
    type: 'compute',
    status: NodeStatus.idle,
    cpuUsage: 25.5,
    memoryUsage: 60.2,
    activeTasks: 2,
    totalTasks: 10,
    ipAddress: '192.168.1.100',
    port: 8080,
    lastHeartbeat: _testDateTime,
    createdAt: _testDateTime,
    updatedAt: _testDateTime,
  );

  // Task data
  static const Map<String, dynamic> testTaskJson = {
    'id': 'task-101',
    'title': 'Test Task',
    'description': 'A test task for testing',
    'nodeId': 'node-789',
    'status': 'pending',
    'progress': 0,
    'startedAt': null,
    'completedAt': null,
    'errorMessage': null,
    'metadata': {'priority': 'high'},
    'createdAt': '2023-01-01T00:00:00.000Z',
    'updatedAt': '2023-01-01T00:00:00.000Z',
  };

  static const Task testTask = Task(
    id: 'task-101',
    title: 'Test Task',
    description: 'A test task for testing',
    nodeId: 'node-789',
    status: TaskStatus.pending,
    progress: 0,
    startedAt: null,
    completedAt: null,
    errorMessage: null,
    metadata: {'priority': 'high'},
    createdAt: _testDateTime,
    updatedAt: _testDateTime,
  );

  // IDE Project data
  static const Map<String, dynamic> testIdeProjectJson = {
    'id': 'project-202',
    'name': 'Test Project',
    'description': 'A test IDE project',
    'path': '/path/to/project',
    'language': 'dart',
    'isOpen': false,
    'lastAccessed': '2023-01-01T00:00:00.000Z',
    'createdAt': '2023-01-01T00:00:00.000Z',
    'updatedAt': '2023-01-01T00:00:00.000Z',
  };

  static const IdeProject testIdeProject = IdeProject(
    id: 'project-202',
    name: 'Test Project',
    description: 'A test IDE project',
    path: '/path/to/project',
    language: 'dart',
    isOpen: false,
    lastAccessed: _testDateTime,
    createdAt: _testDateTime,
    updatedAt: _testDateTime,
  );

  // App Settings data
  static const Map<String, dynamic> testAppSettingsJson = {
    'serverUrl': 'ws://localhost:8080',
    'autoConnect': true,
    'notificationsEnabled': true,
    'darkMode': false,
    'themeMode': 'system',
    'connectionTimeout': 30,
    'maxRetries': 3,
    'enableLogging': true,
    'logLevel': 'INFO',
  };

  static const AppSettings testAppSettings = AppSettings(
    serverUrl: 'ws://localhost:8080',
    autoConnect: true,
    notificationsEnabled: true,
    darkMode: false,
    themeMode: 'system',
    connectionTimeout: 30,
    maxRetries: 3,
    enableLogging: true,
    logLevel: 'INFO',
  );

  // Device info for registration
  static const Map<String, dynamic> deviceInfo = {
    'appName': 'NoodleControl',
    'appVersion': '1.0.0',
    'buildNumber': '1',
    'platform': 'Android',
    'model': 'Test Device',
    'systemVersion': '11',
    'manufacturer': 'Test Manufacturer',
    'id': 'test-device-id',
  };

  // Login response
  static const Map<String, dynamic> loginResponse = {
    'requestId': 'login-request-123',
    'user': testUserJson,
    'token': 'test-jwt-token',
    'refreshToken': 'test-refresh-token',
  };

  // Register device response
  static const Map<String, dynamic> registerDeviceResponse = {
    'requestId': 'register-device-123',
    'device': testDeviceJson,
  };

  // Get nodes response
  static const Map<String, dynamic> getNodesResponse = {
    'requestId': 'get-nodes-123',
    'nodes': [testNodeJson],
  };

  // Get node response
  static const Map<String, dynamic> getNodeResponse = {
    'requestId': 'get-node-123',
    'node': testNodeJson,
  };

  // Get tasks response
  static const Map<String, dynamic> getTasksResponse = {
    'requestId': 'get-tasks-123',
    'tasks': [testTaskJson],
  };

  // Get task response
  static const Map<String, dynamic> getTaskResponse = {
    'requestId': 'get-task-123',
    'task': testTaskJson,
  };

  // Get IDE projects response
  static const Map<String, dynamic> getIdeProjectsResponse = {
    'requestId': 'get-ide-projects-123',
    'projects': [testIdeProjectJson],
  };

  // Get IDE project response
  static const Map<String, dynamic> getIdeProjectResponse = {
    'requestId': 'get-ide-project-123',
    'project': testIdeProjectJson,
  };

  // WebSocket messages
  static const Map<String, dynamic> heartbeatMessage = {
    'id': 'heartbeat-123',
    'type': 'heartbeat',
    'data': {'timestamp': '2023-01-01T00:00:00.000Z'},
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> authenticationMessage = {
    'id': 'auth-123',
    'type': 'authentication',
    'data': {'token': 'test-jwt-token'},
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> nodeUpdateMessage = {
    'id': 'node-update-123',
    'type': 'nodeUpdate',
    'data': {
      'node': testNodeJson,
    },
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> taskUpdateMessage = {
    'id': 'task-update-123',
    'type': 'taskUpdate',
    'data': {
      'task': testTaskJson,
    },
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> performanceDataMessage = {
    'id': 'performance-123',
    'type': 'performanceData',
    'data': {
      'data': {
        'nodeId': 'node-789',
        'cpuUsage': 75.5,
        'memoryUsage': 80.2,
        'timestamp': '2023-01-01T00:00:00.000Z',
      },
    },
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  // Error responses
  static const Map<String, dynamic> unauthorizedError = {
    'code': 2001,
    'message': 'Unauthorized access',
    'error': 'Invalid or expired token',
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> notFoundError = {
    'code': 3001,
    'message': 'Resource not found',
    'error': 'The requested resource was not found',
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  static const Map<String, dynamic> serverError = {
    'code': 3003,
    'message': 'Internal server error',
    'error': 'An unexpected error occurred',
    'timestamp': '2023-01-01T00:00:00.000Z',
  };

  // Collection of multiple items
  static const List<Map<String, dynamic>> testNodesJson = [testNodeJson];
  static const List<Map<String, dynamic>> testTasksJson = [testTaskJson];
  static const List<Map<String, dynamic>> testIdeProjectsJson = [testIdeProjectJson];

  static const List<Node> testNodes = [testNode];
  static const List<Task> testTasks = [testTask];
  static const List<IdeProject> testIdeProjects = [testIdeProject];

  // Performance data
  static const List<Map<String, dynamic>> testPerformanceData = [
    {
      'nodeId': 'node-789',
      'cpuUsage': 25.5,
      'memoryUsage': 60.2,
      'timestamp': '2023-01-01T00:00:00.000Z',
    },
    {
      'nodeId': 'node-789',
      'cpuUsage': 30.0,
      'memoryUsage': 65.0,
      'timestamp': '2023-01-01T00:01:00.000Z',
    },
  ];

  // Log data
  static const List<String> testLogs = [
    '[2023-01-01 00:00:00] Starting node...',
    '[2023-01-01 00:00:01] Node initialized',
    '[2023-01-01 00:00:02] Ready to accept tasks',
  ];

  // File data
  static const List<Map<String, dynamic>> testFiles = [
    {
      'name': 'main.dart',
      'path': '/lib/main.dart',
      'type': 'file',
      'size': 1024,
      'modifiedAt': '2023-01-01T00:00:00.000Z',
    },
    {
      'name': 'lib',
      'path': '/lib',
      'type': 'directory',
      'size': 2048,
      'modifiedAt': '2023-01-01T00:00:00.000Z',
    },
  ];

  // Statistics data
  static const Map<String, dynamic> testNodeStatistics = {
    'uptime': 86400,
    'totalTasks': 100,
    'completedTasks': 95,
    'failedTasks': 5,
    'averageTaskDuration': 30.5,
    'currentCpuUsage': 25.5,
    'currentMemoryUsage': 60.2,
  };

  // Test constants
  static const String testToken = 'test-jwt-token';
  static const String testRefreshToken = 'test-refresh-token';
  static const String testDeviceId = 'test-device-id';
  static const String testNodeId = 'node-789';
  static const String testTaskId = 'task-101';
  static const String testProjectId = 'project-202';
  static const String testServerUrl = 'ws://localhost:8080';
  static const String testApiUrl = 'http://localhost:8080';

  // Helper to convert to JSON string
  static String toJsonString(Map<String, dynamic> data) {
    return jsonEncode(data);
  }

  // Helper to convert list to JSON string
  static String listToJsonString(List<Map<String, dynamic>> data) {
    return jsonEncode(data);
  }

  // Test date time
  static const DateTime _testDateTime = DateTime.parse('2023-01-01T00:00:00.000Z');
}