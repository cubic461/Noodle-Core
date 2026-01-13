import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../network/http_client.dart';
import '../network/websocket_service.dart';
import '../network/exceptions.dart';
import '../../shared/models/models.dart';

/// IDE project repository
class IdeRepository {
  final HttpClient _httpClient;
  final WebSocketService _webSocketService;
  final Logger _logger = App.logger;
  
  // Stream controllers for real-time updates
  final StreamController<List<IdeProject>> _projectsController = 
      StreamController<List<IdeProject>>.broadcast();
  final StreamController<IdeProject> _projectUpdateController = 
      StreamController<IdeProject>.broadcast();
  
  // Cached data
  List<IdeProject> _cachedProjects = [];
  Timer? _refreshTimer;
  
  IdeRepository({
    required HttpClient httpClient,
    required WebSocketService webSocketService,
  }) : _httpClient = httpClient,
       _webSocketService = webSocketService {
    _setupWebSocketListeners();
  }
  
  /// Get all IDE projects
  Future<List<IdeProject>> getProjects({bool forceRefresh = false}) async {
    try {
      _logger.d('Fetching IDE projects');
      
      if (!forceRefresh && _cachedProjects.isNotEmpty) {
        return _cachedProjects;
      }
      
      final response = await _httpClient.get('/api/v1/ide/projects');
      final projectsData = response['projects'] as List<dynamic>;
      
      final projects = projectsData
          .map((projectData) => IdeProject.fromJson(projectData as Map<String, dynamic>))
          .toList();
      
      _cachedProjects = projects;
      _projectsController.add(projects);
      
      return projects;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch IDE projects: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get project by ID
  Future<IdeProject> getProject(String projectId) async {
    try {
      _logger.d('Fetching IDE project: $projectId');
      
      final response = await _httpClient.get('/api/v1/ide/projects/$projectId');
      final projectData = response['project'] as Map<String, dynamic>;
      
      return IdeProject.fromJson(projectData);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch IDE project: $e');
      throw ApiException.notFound(details: e.toString());
    }
  }
  
  /// Create a new project
  Future<IdeProject> createProject(Map<String, dynamic> projectData) async {
    try {
      _logger.i('Creating new IDE project');
      
      final response = await _httpClient.post(
        '/api/v1/ide/projects',
        data: projectData,
      );
      
      final newProjectData = response['project'] as Map<String, dynamic>;
      final newProject = IdeProject.fromJson(newProjectData);
      
      // Update cache
      _cachedProjects.add(newProject);
      _projectsController.add(_cachedProjects);
      
      return newProject;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to create IDE project: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Update project
  Future<IdeProject> updateProject(String projectId, Map<String, dynamic> projectData) async {
    try {
      _logger.i('Updating IDE project: $projectId');
      
      final response = await _httpClient.put(
        '/api/v1/ide/projects/$projectId',
        data: projectData,
      );
      
      final updatedProjectData = response['project'] as Map<String, dynamic>;
      final updatedProject = IdeProject.fromJson(updatedProjectData);
      
      // Update cache
      final index = _cachedProjects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        _cachedProjects[index] = updatedProject;
        _projectsController.add(_cachedProjects);
      }
      
      return updatedProject;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to update IDE project: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      _logger.i('Deleting IDE project: $projectId');
      
      await _httpClient.delete('/api/v1/ide/projects/$projectId');
      
      // Update cache
      _cachedProjects.removeWhere((project) => project.id == projectId);
      _projectsController.add(_cachedProjects);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to delete IDE project: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Open project in IDE
  Future<void> openProject(String projectId) async {
    try {
      _logger.i('Opening IDE project: $projectId');
      
      await _httpClient.post('/api/v1/ide/projects/$projectId/open');
      
      // Update cache
      final index = _cachedProjects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        _cachedProjects[index] = _cachedProjects[index].copyWith(
          isOpen: true,
          lastAccessed: DateTime.now(),
        );
        _projectsController.add(_cachedProjects);
      }
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to open IDE project: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Close project in IDE
  Future<void> closeProject(String projectId) async {
    try {
      _logger.i('Closing IDE project: $projectId');
      
      await _httpClient.post('/api/v1/ide/projects/$projectId/close');
      
      // Update cache
      final index = _cachedProjects.indexWhere((project) => project.id == projectId);
      if (index != -1) {
        _cachedProjects[index] = _cachedProjects[index].copyWith(
          isOpen: false,
          lastAccessed: DateTime.now(),
        );
        _projectsController.add(_cachedProjects);
      }
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to close IDE project: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get project files
  Future<List<Map<String, dynamic>>> getProjectFiles(String projectId) async {
    try {
      _logger.d('Fetching IDE project files: $projectId');
      
      final response = await _httpClient.get('/api/v1/ide/projects/$projectId/files');
      final filesData = response['files'] as List<dynamic>;
      
      return filesData
          .map((fileData) => fileData as Map<String, dynamic>)
          .toList();
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch IDE project files: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get file content
  Future<String> getFileContent(String projectId, String filePath) async {
    try {
      _logger.d('Fetching file content: $filePath');
      
      final response = await _httpClient.get(
        '/api/v1/ide/projects/$projectId/files/content',
        queryParameters: {'path': filePath},
      );
      
      return response['content'] as String;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch file content: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Update file content
  Future<void> updateFileContent(String projectId, String filePath, String content) async {
    try {
      _logger.i('Updating file content: $filePath');
      
      await _httpClient.put(
        '/api/v1/ide/projects/$projectId/files/content',
        data: {
          'path': filePath,
          'content': content,
        },
      );
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to update file content: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Run project
  Future<Map<String, dynamic>> runProject(String projectId, {Map<String, dynamic>? config}) async {
    try {
      _logger.i('Running IDE project: $projectId');
      
      final response = await _httpClient.post(
        '/api/v1/ide/projects/$projectId/run',
        data: config ?? {},
      );
      
      return response['result'] as Map<String, dynamic>;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to run IDE project: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Stop project
  Future<void> stopProject(String projectId) async {
    try {
      _logger.i('Stopping IDE project: $projectId');
      
      await _httpClient.post('/api/v1/ide/projects/$projectId/stop');
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to stop IDE project: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get project output
  Future<List<String>> getProjectOutput(String projectId, {int? lines}) async {
    try {
      _logger.d('Fetching IDE project output: $projectId');
      
      final queryParameters = <String, dynamic>{};
      if (lines != null) queryParameters['lines'] = lines;
      
      final response = await _httpClient.get(
        '/api/v1/ide/projects/$projectId/output',
        queryParameters: queryParameters,
      );
      
      final outputData = response['output'] as List<dynamic>;
      return outputData.map((line) => line.toString()).toList();
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch IDE project output: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get projects stream
  Stream<List<IdeProject>> get projectsStream => _projectsController.stream;
  
  /// Get project update stream
  Stream<IdeProject> get projectUpdateStream => _projectUpdateController.stream;
  
  /// Start periodic refresh
  void startPeriodicRefresh({Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      getProjects(forceRefresh: true).catchError((e) {
        _logger.e('Failed to refresh IDE projects: $e');
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
      // Handle IDE project updates if needed
      // This would be implemented based on WebSocket message types
    });
  }
  
  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _projectsController.close();
    _projectUpdateController.close();
  }
}

// Provider for IDE repository
final ideRepositoryProvider = Provider<IdeRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return IdeRepository(
    httpClient: httpClient,
    webSocketService: webSocketService,
  );
});

// Provider for IDE projects stream
final ideProjectsStreamProvider = StreamProvider<List<IdeProject>>((ref) {
  final ideRepository = ref.watch(ideRepositoryProvider);
  return ideRepository.projectsStream;
});

// Provider for IDE project updates stream
final ideProjectUpdateStreamProvider = StreamProvider<IdeProject>((ref) {
  final ideRepository = ref.watch(ideRepositoryProvider);
  return ideRepository.projectUpdateStream;
});