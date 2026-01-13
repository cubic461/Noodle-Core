import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../network/http_client.dart';
import '../network/websocket_service.dart';
import '../repositories/auth_repository.dart';
import '../repositories/node_repository.dart';
import '../repositories/task_repository.dart';
import '../repositories/ide_repository.dart';
import '../../shared/models/models.dart';

// Logger provider
final loggerProvider = Provider<Logger>((ref) {
  return App.logger;
});

// HTTP Client provider
final httpClientProvider = Provider<HttpClient>((ref) {
  final logger = ref.watch(loggerProvider);
  return HttpClient(logger: logger);
});

// WebSocket Service provider
final webSocketServiceProvider = Provider<WebSocketService>((ref) {
  final logger = ref.watch(loggerProvider);
  return WebSocketService(
    serverUrl: 'ws://localhost:8080', // Default URL, will be updated when connecting
    logger: logger,
  );
});

// Connection Status Service provider
final connectionServiceProvider = Provider<ConnectionStatusService>((ref) {
  final webSocketService = ref.watch(webSocketServiceProvider);
  return ConnectionStatusService(webSocketService: webSocketService);
});

// Authentication Service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthService(authRepository: authRepository);
});

// Node Service provider
final nodeServiceProvider = Provider<NodeService>((ref) {
  final nodeRepository = ref.watch(nodeRepositoryProvider);
  return NodeService(nodeRepository: nodeRepository);
});

// Task Service provider
final taskServiceProvider = Provider<TaskService>((ref) {
  final taskRepository = ref.watch(taskRepositoryProvider);
  return TaskService(taskRepository: taskRepository);
});

// IDE Service provider
final ideServiceProvider = Provider<IdeService>((ref) {
  final ideRepository = ref.watch(ideRepositoryProvider);
  return IdeService(ideRepository: ideRepository);
});

// App Settings provider
final appSettingsProvider = FutureProvider<AppSettings>((ref) async {
  // TODO: Load settings from persistent storage
  return const AppSettings(
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
});

// Current User provider
final currentUserProvider = FutureProvider<User?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getCurrentUser();
});

// Connection Status Service
class ConnectionStatusService {
  final WebSocketService _webSocketService;
  
  ConnectionStatusService({
    required WebSocketService webSocketService,
  }) : _webSocketService = webSocketService;
  
  ConnectionStatus get status => _webSocketService.currentStatus;
  
  Stream<ConnectionStatus> get statusStream => _webSocketService.statusStream;
  
  String get lastError => _webSocketService.lastError;
  
  DateTime? get lastConnectedTime => _webSocketService.lastConnectedTime;
  
  Future<void> connect({String? authToken}) async {
    await _webSocketService.connect(authToken: authToken);
  }
  
  Future<void> disconnect() async {
    await _webSocketService.disconnect();
  }
  
  Future<void> reconnect() async {
    await _webSocketService.disconnect();
    await _webSocketService.connect();
  }
}

// Authentication Service
class AuthService {
  final AuthRepository _authRepository;
  
  AuthService({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;
  
  Future<User?> getCurrentUser() async {
    try {
      return await _authRepository.getCurrentUser();
    } catch (e) {
      return null;
    }
  }
  
  Future<User> login(String username, String password) async {
    return await _authRepository.login(username, password);
  }
  
  Future<Device> registerDevice(String name, String type) async {
    return await _authRepository.registerDevice(name, type);
  }
  
  Future<void> logout() async {
    await _authRepository.logout();
  }
  
  Future<bool> isAuthenticated() async {
    return await _authRepository.isAuthenticated();
  }
  
  Future<User?> autoAuthenticate() async {
    return await _authRepository.autoAuthenticate();
  }
}

// Node Service
class NodeService {
  final NodeRepository _nodeRepository;
  
  NodeService({
    required NodeRepository nodeRepository,
  }) : _nodeRepository = nodeRepository;
  
  Future<List<Node>> getNodes({bool forceRefresh = false}) async {
    return await _nodeRepository.getNodes(forceRefresh: forceRefresh);
  }
  
  Future<Node> getNode(String nodeId) async {
    return await _nodeRepository.getNode(nodeId);
  }
  
  Future<Node> createNode(Map<String, dynamic> nodeData) async {
    return await _nodeRepository.createNode(nodeData);
  }
  
  Future<Node> updateNode(String nodeId, Map<String, dynamic> nodeData) async {
    return await _nodeRepository.updateNode(nodeId, nodeData);
  }
  
  Future<void> deleteNode(String nodeId) async {
    await _nodeRepository.deleteNode(nodeId);
  }
  
  Future<void> startNode(String nodeId) async {
    await _nodeRepository.startNode(nodeId);
  }
  
  Future<void> stopNode(String nodeId) async {
    await _nodeRepository.stopNode(nodeId);
  }
  
  Future<void> restartNode(String nodeId) async {
    await _nodeRepository.restartNode(nodeId);
  }
  
  Stream<List<Node>> get nodesStream => _nodeRepository.nodesStream;
  
  Stream<Node> get nodeUpdateStream => _nodeRepository.nodeUpdateStream;
}

// Task Service
class TaskService {
  final TaskRepository _taskRepository;
  
  TaskService({
    required TaskRepository taskRepository,
  }) : _taskRepository = taskRepository;
  
  Future<List<Task>> getTasks({
    bool forceRefresh = false,
    String? nodeId,
    TaskStatus? status,
    int? limit,
    int? offset,
  }) async {
    return await _taskRepository.getTasks(
      forceRefresh: forceRefresh,
      nodeId: nodeId,
      status: status,
      limit: limit,
      offset: offset,
    );
  }
  
  Future<Task> getTask(String taskId) async {
    return await _taskRepository.getTask(taskId);
  }
  
  Future<Task> createTask(Map<String, dynamic> taskData) async {
    return await _taskRepository.createTask(taskData);
  }
  
  Future<Task> updateTask(String taskId, Map<String, dynamic> taskData) async {
    return await _taskRepository.updateTask(taskId, taskData);
  }
  
  Future<void> deleteTask(String taskId) async {
    await _taskRepository.deleteTask(taskId);
  }
  
  Future<void> cancelTask(String taskId) async {
    await _taskRepository.cancelTask(taskId);
  }
  
  Future<Task> retryTask(String taskId) async {
    return await _taskRepository.retryTask(taskId);
  }
  
  Stream<List<Task>> get tasksStream => _taskRepository.tasksStream;
  
  Stream<Task> get taskUpdateStream => _taskRepository.taskUpdateStream;
  
  Stream<Map<String, dynamic>> get performanceStream => _taskRepository.performanceStream;
}

// IDE Service
class IdeService {
  final IdeRepository _ideRepository;
  
  IdeService({
    required IdeRepository ideRepository,
  }) : _ideRepository = ideRepository;
  
  Future<List<IdeProject>> getProjects({bool forceRefresh = false}) async {
    return await _ideRepository.getProjects(forceRefresh: forceRefresh);
  }
  
  Future<IdeProject> getProject(String projectId) async {
    return await _ideRepository.getProject(projectId);
  }
  
  Future<IdeProject> createProject(Map<String, dynamic> projectData) async {
    return await _ideRepository.createProject(projectData);
  }
  
  Future<IdeProject> updateProject(String projectId, Map<String, dynamic> projectData) async {
    return await _ideRepository.updateProject(projectId, projectData);
  }
  
  Future<void> deleteProject(String projectId) async {
    await _ideRepository.deleteProject(projectId);
  }
  
  Future<void> openProject(String projectId) async {
    await _ideRepository.openProject(projectId);
  }
  
  Future<void> closeProject(String projectId) async {
    await _ideRepository.closeProject(projectId);
  }
  
  Future<List<Map<String, dynamic>>> getProjectFiles(String projectId) async {
    return await _ideRepository.getProjectFiles(projectId);
  }
  
  Future<String> getFileContent(String projectId, String filePath) async {
    return await _ideRepository.getFileContent(projectId, filePath);
  }
  
  Future<void> updateFileContent(String projectId, String filePath, String content) async {
    await _ideRepository.updateFileContent(projectId, filePath, content);
  }
  
  Future<Map<String, dynamic>> runProject(String projectId, {Map<String, dynamic>? config}) async {
    return await _ideRepository.runProject(projectId, config: config);
  }
  
  Future<void> stopProject(String projectId) async {
    await _ideRepository.stopProject(projectId);
  }
  
  Stream<List<IdeProject>> get projectsStream => _ideRepository.projectsStream;
  
  Stream<IdeProject> get projectUpdateStream => _ideRepository.projectUpdateStream;
}