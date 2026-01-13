import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import '../app.dart';
import 'exceptions.dart';
import '../utils/error_handler.dart';
import '../utils/performance_monitor.dart';
import '../utils/analytics_service.dart';

/// WebSocket message types
enum WebSocketMessageType {
  heartbeat,
  authentication,
  nodeUpdate,
  taskUpdate,
  performanceData,
  error,
  response,
}

/// WebSocket message model
class WebSocketMessage {
  final String id;
  final WebSocketMessageType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  WebSocketMessage({
    required this.type,
    required this.data,
    String? id,
  }) : id = id ?? const Uuid().v4(),
       timestamp = DateTime.now();
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory WebSocketMessage.fromJson(Map<String, dynamic> json) {
    try {
      final typeString = json['type'] as String;
      final type = WebSocketMessageType.values.firstWhere(
        (e) => e.name == typeString,
        orElse: () => throw WebSocketException.messageParseError(
          details: 'Unknown message type: $typeString',
        ),
      );
      
      return WebSocketMessage(
        id: json['id'] as String? ?? const Uuid().v4(),
        type: type,
        data: json['data'] as Map<String, dynamic>? ?? {},
      );
    } catch (e) {
      throw WebSocketException.messageParseError(
        details: 'Failed to parse WebSocket message: $e',
      );
    }
  }
}

/// WebSocket service for real-time communication
class WebSocketService {
  String _serverUrl;
  WebSocketChannel? _channel;
  final StreamController<WebSocketMessage> _messageController = 
      StreamController<WebSocketMessage>.broadcast();
  final StreamController<ConnectionStatus> _statusController = 
      StreamController<ConnectionStatus>.broadcast();
  final Logger _logger = App.logger;
  final Map<String, Completer<WebSocketMessage>> _pendingRequests = {};
  Timer? _heartbeatTimer;
  Timer? _reconnectTimer;
  bool _isConnecting = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  static const Duration _heartbeatInterval = Duration(seconds: 30);
  static const Duration _reconnectDelay = Duration(seconds: 5);
  
  WebSocketService({
    required String serverUrl,
  }) : _serverUrl = serverUrl;
  
  /// Get message stream
  Stream<WebSocketMessage> get messageStream => _messageController.stream;
  
  /// Get connection status stream
  Stream<ConnectionStatus> get statusStream => _statusController.stream;
  
  /// Get current connection status
  ConnectionStatus get currentStatus {
    if (_isConnecting) return ConnectionStatus.connecting;
    if (_channel != null) return ConnectionStatus.connected;
    return ConnectionStatus.disconnected;
  }
  
  /// Update server URL
  void updateServerUrl(String url) {
    if (_serverUrl != url) {
      _serverUrl = url;
      if (currentStatus == ConnectionStatus.connected) {
        disconnect();
        connect();
      }
    }
  }
  
  /// Connect to WebSocket server
  Future<void> connect({String? authToken}) async {
    if (_isConnecting || currentStatus == ConnectionStatus.connected) {
      return;
    }
    
    final timerId = PerformanceMonitor.startTimer('websocket_connect');
    
    _isConnecting = true;
    _statusController.add(ConnectionStatus.connecting);
    
    try {
      _logger.i('Connecting to WebSocket server: $_serverUrl');
      
      // Build URL with auth token if provided
      var url = _serverUrl;
      if (authToken != null) {
        final separator = url.contains('?') ? '&' : '?';
        url = '$url${separator}token=$authToken';
      }
      
      _channel = WebSocketChannel.connect(Uri.parse(url));
      
      // Listen for messages
      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnection,
        cancelOnError: false,
      );
      
      // Send authentication if token is provided
      if (authToken != null) {
        await _authenticate(authToken);
      }
      
      // Start heartbeat timer
      _startHeartbeat();
      
      _isConnecting = false;
      _reconnectAttempts = 0;
      _statusController.add(ConnectionStatus.connected);
      
      // Track connection in analytics
      final duration = PerformanceMonitor.endTimer(timerId);
      AnalyticsService.trackEvent('websocket_connected', {
        'server_url': _serverUrl,
        'duration_ms': duration,
        'attempt': _reconnectAttempts + 1,
      });
      
      _logger.i('WebSocket connection established');
      
    } catch (e) {
      _isConnecting = false;
      _logger.e('Failed to connect to WebSocket: $e');
      _statusController.add(ConnectionStatus.error);
      
      // Track connection error in analytics
      AnalyticsService.trackEvent('websocket_connection_failed', {
        'server_url': _serverUrl,
        'error': e.toString(),
        'attempt': _reconnectAttempts + 1,
      });
      
      ErrorHandler.handleError(e, context: 'WebSocket.connect');
      
      // Schedule reconnection if needed
      if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
        _scheduleReconnect();
      }
      
      throw WebSocketException.connectionFailed(details: e.toString());
    }
  }
  
  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    
    if (_channel != null) {
      try {
        await _channel!.sink.close();
        _logger.i('WebSocket connection closed');
      } catch (e) {
        _logger.e('Error closing WebSocket connection: $e');
      }
      _channel = null;
    }
    
    _statusController.add(ConnectionStatus.disconnected);
  }
  
  /// Send message to server
  Future<WebSocketMessage> sendMessage(
    WebSocketMessageType type,
    Map<String, dynamic> data, {
    bool expectResponse = true,
    Duration? timeout,
  }) async {
    if (_channel == null || currentStatus != ConnectionStatus.connected) {
      throw WebSocketException.disconnected(
        details: 'Cannot send message when not connected',
      );
    }
    
    final timerId = PerformanceMonitor.startTimer('websocket_send_message');
    
    final message = WebSocketMessage(type: type, data: data);
    final messageJson = jsonEncode(message.toJson());
    
    _logger.d('Sending WebSocket message: ${message.type.name}');
    
    try {
      _channel!.sink.add(messageJson);
      
      // Track message sent in analytics
      AnalyticsService.trackEvent('websocket_message_sent', {
        'message_type': type.name,
        'message_id': message.id,
        'expect_response': expectResponse,
      });
      
      if (expectResponse) {
        // Wait for response
        final completer = Completer<WebSocketMessage>();
        _pendingRequests[message.id] = completer;
        
        // Set timeout
        timeout ??= const Duration(seconds: 30);
        Timer(timeout, () {
          if (!completer.isCompleted) {
            _pendingRequests.remove(message.id);
            
            // Track timeout in analytics
            AnalyticsService.trackEvent('websocket_message_timeout', {
              'message_type': type.name,
              'message_id': message.id,
              'timeout_ms': timeout?.inMilliseconds,
            });
            
            completer.completeError(
              ConnectionException.timeout(details: 'No response received for message ${message.id}'),
            );
          }
        });
        
        final result = await completer.future;
        PerformanceMonitor.endTimer(timerId);
        return result;
      }
      
      PerformanceMonitor.endTimer(timerId);
      return message;
    } catch (e) {
      PerformanceMonitor.endTimer(timerId);
      _logger.e('Failed to send WebSocket message: $e');
      
      // Track send error in analytics
      AnalyticsService.trackEvent('websocket_message_send_failed', {
        'message_type': type.name,
        'message_id': message.id,
        'error': e.toString(),
      });
      
      ErrorHandler.handleError(e, context: 'WebSocket.sendMessage');
      throw WebSocketException.connectionFailed(details: e.toString());
    }
  }
  
  /// Handle incoming message
  void _handleMessage(dynamic message) {
    try {
      final messageData = jsonDecode(message) as Map<String, dynamic>;
      final webSocketMessage = WebSocketMessage.fromJson(messageData);
      
      _logger.d('Received WebSocket message: ${webSocketMessage.type.name}');
      
      // Track message received in analytics
      AnalyticsService.trackEvent('websocket_message_received', {
        'message_type': webSocketMessage.type.name,
        'message_id': webSocketMessage.id,
      });
      
      // Check if this is a response to a pending request
      if (webSocketMessage.type == WebSocketMessageType.response &&
          webSocketMessage.data.containsKey('requestId')) {
        final requestId = webSocketMessage.data['requestId'] as String;
        final completer = _pendingRequests.remove(requestId);
        if (completer != null && !completer.isCompleted) {
          completer.complete(webSocketMessage);
          return;
        }
      }
      
      // Add to message stream
      _messageController.add(webSocketMessage);
      
    } catch (e) {
      _logger.e('Failed to handle WebSocket message: $e');
      
      // Track parse error in analytics
      AnalyticsService.trackEvent('websocket_message_parse_error', {
        'error': e.toString(),
      });
      
      ErrorHandler.handleError(e, context: 'WebSocket._handleMessage');
      _messageController.addError(
        WebSocketException.messageParseError(details: e.toString()),
      );
    }
  }
  
  /// Handle WebSocket error
  void _handleError(dynamic error) {
    _logger.e('WebSocket error: $error');
    _statusController.add(ConnectionStatus.error);
    
    // Track error in analytics
    AnalyticsService.trackEvent('websocket_error', {
      'error': error.toString(),
      'reconnect_attempts': _reconnectAttempts,
    });
    
    ErrorHandler.handleError(error, context: 'WebSocket error');
    
    // Schedule reconnection if needed
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }
  
  /// Handle WebSocket disconnection
  void _handleDisconnection() {
    _logger.i('WebSocket disconnected');
    _heartbeatTimer?.cancel();
    _channel = null;
    _statusController.add(ConnectionStatus.disconnected);
    
    // Schedule reconnection if needed
    if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
      _scheduleReconnect();
    }
  }
  
  /// Authenticate with the server
  Future<void> _authenticate(String token) async {
    try {
      await sendMessage(
        WebSocketMessageType.authentication,
        {'token': token},
        expectResponse: true,
      );
      
      // Track authentication success in analytics
      AnalyticsService.trackEvent('websocket_authentication_success');
      
      _logger.i('WebSocket authentication successful');
    } catch (e) {
      _logger.e('WebSocket authentication failed: $e');
      
      // Track authentication failure in analytics
      AnalyticsService.trackEvent('websocket_authentication_failed', {
        'error': e.toString(),
      });
      
      ErrorHandler.handleError(e, context: 'WebSocket._authenticate');
      throw AuthenticationException.unauthorized(details: e.toString());
    }
  }
  
  /// Start heartbeat timer
  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (currentStatus == ConnectionStatus.connected) {
        sendMessage(
          WebSocketMessageType.heartbeat,
          {'timestamp': DateTime.now().toIso8601String()},
          expectResponse: false,
        ).catchError((e) {
          _logger.e('Failed to send heartbeat: $e');
        });
      }
    });
  }
  
  /// Schedule reconnection attempt
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_shouldReconnect && _reconnectAttempts < _maxReconnectAttempts) {
        _reconnectAttempts++;
        _logger.i('Attempting to reconnect (${_reconnectAttempts}/$_maxReconnectAttempts)');
        connect();
      }
    });
  }
  
  /// Dispose resources
  void dispose() {
    disconnect();
    _messageController.close();
    _statusController.close();
  }
}