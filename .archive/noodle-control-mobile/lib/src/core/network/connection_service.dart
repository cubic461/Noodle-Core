import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import 'websocket_service.dart';
import 'http_client.dart';
import 'exceptions.dart';

/// Connection status monitoring service
class ConnectionService {
  final WebSocketService _webSocketService;
  HttpClient? _httpClient;
  final Logger _logger = App.logger;
  
  // Stream controllers
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final StreamController<String> _messageController = 
      StreamController<String>.broadcast();
  
  // Connection state
  ConnectionStatus _status = ConnectionStatus.disconnected;
  String _lastError = '';
  DateTime? _lastConnectedTime;
  Timer? _healthCheckTimer;
  
  ConnectionService({
    required WebSocketService webSocketService,
  }) : _webSocketService = webSocketService {
    _setupWebSocketListeners();
  }
  
  /// Get current connection status
  ConnectionStatus get status => _status;
  
  /// Get last error message
  String get lastError => _lastError;
  
  /// Get last connected time
  DateTime? get lastConnectedTime => _lastConnectedTime;
  
  /// Get connection status stream
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  
  /// Get message stream
  Stream<String> get messageStream => _messageController.stream;
  
  /// Set HTTP client
  void setHttpClient(HttpClient client) {
    _httpClient = client;
  }
  
  /// Initialize connection monitoring
  Future<void> initialize() async {
    _logger.i('Initializing connection monitoring service');
    
    // Start health check timer
    _startHealthCheck();
    
    // Check initial connection status
    await _checkConnectionHealth();
  }
  
  /// Connect to server
  Future<void> connect({String? serverUrl, String? authToken}) async {
    try {
      _updateStatus(ConnectionStatus.connecting);
      _addMessage('Connecting to server...');
      
      // Update WebSocket server URL if provided
      if (serverUrl != null) {
        _webSocketService.updateServerUrl(serverUrl);
      }
      
      // Connect WebSocket
      await _webSocketService.connect(authToken: authToken);
      
      // Test HTTP connection if client is available
      if (_httpClient != null) {
        await _testHttpConnection();
      }
      
      _updateStatus(ConnectionStatus.connected);
      _lastConnectedTime = DateTime.now();
      _addMessage('Connected to server successfully');
      
    } catch (e) {
      _logger.e('Failed to connect: $e');
      _updateStatus(ConnectionStatus.error);
      _lastError = e.toString();
      _addMessage('Connection failed: ${e.toString()}');
      rethrow;
    }
  }
  
  /// Disconnect from server
  Future<void> disconnect() async {
    try {
      _addMessage('Disconnecting from server...');
      await _webSocketService.disconnect();
      _updateStatus(ConnectionStatus.disconnected);
      _addMessage('Disconnected from server');
    } catch (e) {
      _logger.e('Error during disconnection: $e');
      _lastError = e.toString();
    }
  }
  
  /// Reconnect to server
  Future<void> reconnect() async {
    _addMessage('Attempting to reconnect...');
    await disconnect();
    await connect();
  }
  
  /// Setup WebSocket listeners
  void _setupWebSocketListeners() {
    // Listen to WebSocket status changes
    _webSocketService.statusStream.listen((status) {
      if (status != _status) {
        _updateStatus(status);
        
        switch (status) {
          case ConnectionStatus.connected:
            _lastConnectedTime = DateTime.now();
            _addMessage('WebSocket connected');
            break;
          case ConnectionStatus.disconnected:
            _addMessage('WebSocket disconnected');
            break;
          case ConnectionStatus.connecting:
            _addMessage('WebSocket connecting...');
            break;
          case ConnectionStatus.reconnecting:
            _addMessage('WebSocket reconnecting...');
            break;
          case ConnectionStatus.error:
            _addMessage('WebSocket connection error');
            break;
        }
      }
    });
  }
  
  /// Start health check timer
  void _startHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = Timer.periodic(const Duration(seconds: 60), (_) {
      _checkConnectionHealth();
    });
  }
  
  /// Check connection health
  Future<void> _checkConnectionHealth() async {
    try {
      if (_status == ConnectionStatus.connected) {
        // Send heartbeat via WebSocket
        await _webSocketService.sendMessage(
          WebSocketMessageType.heartbeat,
          {'timestamp': DateTime.now().toIso8601String()},
          expectResponse: true,
          timeout: const Duration(seconds: 10),
        );
        
        // Test HTTP connection if available
        if (_httpClient != null) {
          await _testHttpConnection();
        }
      }
    } catch (e) {
      _logger.e('Health check failed: $e');
      if (_status == ConnectionStatus.connected) {
        _updateStatus(ConnectionStatus.error);
        _lastError = 'Health check failed: ${e.toString()}';
        _addMessage('Connection health check failed');
      }
    }
  }
  
  /// Test HTTP connection
  Future<void> _testHttpConnection() async {
    if (_httpClient == null) return;
    
    try {
      await _httpClient!.get('/api/v1/health');
    } catch (e) {
      throw ConnectionException.networkError(details: e.toString());
    }
  }
  
  /// Update connection status
  void _updateStatus(ConnectionStatus newStatus) {
    if (_status != newStatus) {
      final oldStatus = _status;
      _status = newStatus;
      _logger.i('Connection status changed: $oldStatus -> $newStatus');
      _statusController.add(newStatus);
    }
  }
  
  /// Add message to message stream
  void _addMessage(String message) {
    final timestamp = DateTime.now().toIso8601String();
    _messageController.add('[$timestamp] $message');
    _logger.d('Connection message: $message');
  }
  
  /// Dispose resources
  void dispose() {
    _healthCheckTimer?.cancel();
    _statusController.close();
    _messageController.close();
  }
}

/// Provider for connection service
final connectionServiceProvider = Provider<ConnectionService>((ref) {
  throw UnimplementedError('ConnectionService provider not implemented');
});

/// Provider for connection status
final connectionStatusProvider = StreamProvider<ConnectionStatus>((ref) {
  final connectionService = ref.watch(connectionServiceProvider);
  return connectionService.statusStream;
});

/// Provider for connection messages
final connectionMessagesProvider = StreamProvider<String>((ref) {
  final connectionService = ref.watch(connectionServiceProvider);
  return connectionService.messageStream;
});