import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import '../network/http_client.dart';
import '../network/websocket_service.dart';
import '../network/exceptions.dart';
import '../../shared/models/models.dart';

/// Node management repository
class NodeRepository {
  final HttpClient _httpClient;
  final WebSocketService _webSocketService;
  final Logger _logger = App.logger;
  
  // Stream controllers for real-time updates
  final StreamController<List<Node>> _nodesController = 
      StreamController<List<Node>>.broadcast();
  final StreamController<Node> _nodeUpdateController = 
      StreamController<Node>.broadcast();
  
  // Cached data
  List<Node> _cachedNodes = [];
  Timer? _refreshTimer;
  
  NodeRepository({
    required HttpClient httpClient,
    required WebSocketService webSocketService,
  }) : _httpClient = httpClient,
       _webSocketService = webSocketService {
    _setupWebSocketListeners();
  }
  
  /// Get all nodes
  Future<List<Node>> getNodes({bool forceRefresh = false}) async {
    try {
      _logger.d('Fetching nodes');
      
      if (!forceRefresh && _cachedNodes.isNotEmpty) {
        return _cachedNodes;
      }
      
      final response = await _httpClient.get('/api/v1/nodes');
      final nodesData = response['nodes'] as List<dynamic>;
      
      final nodes = nodesData
          .map((nodeData) => Node.fromJson(nodeData as Map<String, dynamic>))
          .toList();
      
      _cachedNodes = nodes;
      _nodesController.add(nodes);
      
      return nodes;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch nodes: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get node by ID
  Future<Node> getNode(String nodeId) async {
    try {
      _logger.d('Fetching node: $nodeId');
      
      final response = await _httpClient.get('/api/v1/nodes/$nodeId');
      final nodeData = response['node'] as Map<String, dynamic>;
      
      return Node.fromJson(nodeData);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch node: $e');
      throw ApiException.notFound(details: e.toString());
    }
  }
  
  /// Create a new node
  Future<Node> createNode(Map<String, dynamic> nodeData) async {
    try {
      _logger.i('Creating new node');
      
      final response = await _httpClient.post(
        '/api/v1/nodes',
        data: nodeData,
      );
      
      final newNodeData = response['node'] as Map<String, dynamic>;
      final newNode = Node.fromJson(newNodeData);
      
      // Update cache
      _cachedNodes.add(newNode);
      _nodesController.add(_cachedNodes);
      
      return newNode;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to create node: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Update node
  Future<Node> updateNode(String nodeId, Map<String, dynamic> nodeData) async {
    try {
      _logger.i('Updating node: $nodeId');
      
      final response = await _httpClient.put(
        '/api/v1/nodes/$nodeId',
        data: nodeData,
      );
      
      final updatedNodeData = response['node'] as Map<String, dynamic>;
      final updatedNode = Node.fromJson(updatedNodeData);
      
      // Update cache
      final index = _cachedNodes.indexWhere((node) => node.id == nodeId);
      if (index != -1) {
        _cachedNodes[index] = updatedNode;
        _nodesController.add(_cachedNodes);
      }
      
      return updatedNode;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to update node: $e');
      throw ApiException.badRequest(details: e.toString());
    }
  }
  
  /// Delete node
  Future<void> deleteNode(String nodeId) async {
    try {
      _logger.i('Deleting node: $nodeId');
      
      await _httpClient.delete('/api/v1/nodes/$nodeId');
      
      // Update cache
      _cachedNodes.removeWhere((node) => node.id == nodeId);
      _nodesController.add(_cachedNodes);
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to delete node: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Start node
  Future<void> startNode(String nodeId) async {
    try {
      _logger.i('Starting node: $nodeId');
      
      await _httpClient.post('/api/v1/nodes/$nodeId/start');
      
      // Update cache
      final index = _cachedNodes.indexWhere((node) => node.id == nodeId);
      if (index != -1) {
        _cachedNodes[index] = _cachedNodes[index].copyWith(status: NodeStatus.running);
        _nodesController.add(_cachedNodes);
      }
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to start node: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Stop node
  Future<void> stopNode(String nodeId) async {
    try {
      _logger.i('Stopping node: $nodeId');
      
      await _httpClient.post('/api/v1/nodes/$nodeId/stop');
      
      // Update cache
      final index = _cachedNodes.indexWhere((node) => node.id == nodeId);
      if (index != -1) {
        _cachedNodes[index] = _cachedNodes[index].copyWith(status: NodeStatus.stopped);
        _nodesController.add(_cachedNodes);
      }
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to stop node: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Restart node
  Future<void> restartNode(String nodeId) async {
    try {
      _logger.i('Restarting node: $nodeId');
      
      await _httpClient.post('/api/v1/nodes/$nodeId/restart');
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to restart node: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get node statistics
  Future<Map<String, dynamic>> getNodeStatistics(String nodeId) async {
    try {
      _logger.d('Fetching node statistics: $nodeId');
      
      final response = await _httpClient.get('/api/v1/nodes/$nodeId/statistics');
      return response['statistics'] as Map<String, dynamic>;
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch node statistics: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get node logs
  Future<List<String>> getNodeLogs(String nodeId, {int limit = 100}) async {
    try {
      _logger.d('Fetching node logs: $nodeId');
      
      final response = await _httpClient.get(
        '/api/v1/nodes/$nodeId/logs',
        queryParameters: {'limit': limit},
      );
      
      final logsData = response['logs'] as List<dynamic>;
      return logsData.map((log) => log.toString()).toList();
      
    } on NetworkException {
      rethrow;
    } catch (e) {
      _logger.e('Failed to fetch node logs: $e');
      throw ApiException.serverError(details: e.toString());
    }
  }
  
  /// Get nodes stream
  Stream<List<Node>> get nodesStream => _nodesController.stream;
  
  /// Get node update stream
  Stream<Node> get nodeUpdateStream => _nodeUpdateController.stream;
  
  /// Start periodic refresh
  void startPeriodicRefresh({Duration interval = const Duration(seconds: 30)}) {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(interval, (_) {
      getNodes(forceRefresh: true).catchError((e) {
        _logger.e('Failed to refresh nodes: $e');
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
        case WebSocketMessageType.nodeUpdate:
          _handleNodeUpdate(message);
          break;
        default:
          break;
      }
    });
  }
  
  /// Handle node update from WebSocket
  void _handleNodeUpdate(WebSocketMessage message) {
    try {
      final nodeData = message.data['node'] as Map<String, dynamic>?;
      if (nodeData == null) return;
      
      final node = Node.fromJson(nodeData);
      
      // Update cache
      final index = _cachedNodes.indexWhere((n) => n.id == node.id);
      if (index != -1) {
        _cachedNodes[index] = node;
      } else {
        _cachedNodes.add(node);
      }
      
      // Notify listeners
      _nodesController.add(_cachedNodes);
      _nodeUpdateController.add(node);
      
      _logger.d('Node updated via WebSocket: ${node.id}');
      
    } catch (e) {
      _logger.e('Failed to handle node update: $e');
    }
  }
  
  /// Dispose resources
  void dispose() {
    _refreshTimer?.cancel();
    _nodesController.close();
    _nodeUpdateController.close();
  }
}

// Provider for node repository
final nodeRepositoryProvider = Provider<NodeRepository>((ref) {
  final httpClient = ref.watch(httpClientProvider);
  final webSocketService = ref.watch(webSocketServiceProvider);
  return NodeRepository(
    httpClient: httpClient,
    webSocketService: webSocketService,
  );
});

// Provider for nodes stream
final nodesStreamProvider = StreamProvider<List<Node>>((ref) {
  final nodeRepository = ref.watch(nodeRepositoryProvider);
  return nodeRepository.nodesStream;
});

// Provider for node updates stream
final nodeUpdateStreamProvider = StreamProvider<Node>((ref) {
  final nodeRepository = ref.watch(nodeRepositoryProvider);
  return nodeRepository.nodeUpdateStream;
});