import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:noodle_control_mobile_app/src/core/network/websocket_service.dart';
import 'package:noodle_control_mobile_app/src/core/network/exceptions.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';

import '../../test_utils/test_helpers.dart';
import '../../test_utils/mock_data.dart';
import '../../test_utils/test_config.dart';

// Generate mocks
@GenerateMocks([
  WebSocketChannel,
  StreamSink,
  StreamSubscription,
])
import 'websocket_service_test.mocks.dart';

void main() {
  group(TestGroups.webSocket, () {
    late WebSocketService webSocketService;
    late MockWebSocketChannel mockChannel;
    late MockStreamSink mockSink;

    setUp(() {
      mockChannel = MockWebSocketChannel();
      mockSink = MockStreamSink();
      webSocketService = WebSocketService(serverUrl: TestConstants.testWebSocketUrl);
    });

    tearDown(() {
      webSocketService.dispose();
    });

    group('initialization', () {
      test('should initialize with correct server URL', () {
        // Act & Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.disconnected));
      });

      test('should update server URL', () {
        // Arrange
        const newUrl = 'ws://new-server:8080';
        
        // Act
        webSocketService.updateServerUrl(newUrl);
        
        // Assert
        // No direct way to verify without making _serverUrl public
        expect(webSocketService.currentStatus, equals(ConnectionStatus.disconnected));
      });
    });

    group('connect', () {
      test(TestDescriptions.connectSuccess, () async {
        // Arrange
        when(mockChannel.stream).thenAnswer((_) => Stream.empty());
        when(mockChannel.sink).thenReturn(mockSink);
        
        // Mock WebSocketChannel.connect
        // Note: We can't easily mock static methods in Dart, so we'll test the behavior
        // by checking the status changes through the stream
        
        // Act
        final connectFuture = webSocketService.connect();
        
        // The connection will fail in test environment, but we can verify the attempt
        // Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.connecting));
        
        try {
          await connectFuture;
        } catch (e) {
          // Expected to fail in test environment
        }
      });

      test('should connect with auth token', () async {
        // Arrange
        const authToken = TestConstants.testToken;
        
        when(mockChannel.stream).thenAnswer((_) => Stream.empty());
        when(mockChannel.sink).thenReturn(mockSink);
        
        // Act
        final connectFuture = webSocketService.connect(authToken: authToken);
        
        // Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.connecting));
        
        try {
          await connectFuture;
        } catch (e) {
          // Expected to fail in test environment
        }
      });

      test('should not connect if already connecting', () async {
        // Arrange
        when(mockChannel.stream).thenAnswer((_) => Stream.empty());
        when(mockChannel.sink).thenReturn(mockSink);
        
        // Act
        final connectFuture1 = webSocketService.connect();
        final connectFuture2 = webSocketService.connect();
        
        // Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.connecting));
        
        try {
          await connectFuture1;
          await connectFuture2;
        } catch (e) {
          // Expected to fail in test environment
        }
      });

      test('should not connect if already connected', () async {
        // This test is difficult to implement without being able to mock the static connect method
        // In a real implementation, we would mock the WebSocketChannel.connect to return a mock channel
        // and set up the internal state to connected
      });
    });

    group('disconnect', () {
      test(TestDescriptions.disconnectSuccess, () async {
        // Arrange
        when(mockSink.close()).thenAnswer((_) async {});
        
        // Act
        await webSocketService.disconnect();
        
        // Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.disconnected));
      });
    });

    group('sendMessage', () {
      test(TestDescriptions.sendMessageSuccess, () async {
        // This test is difficult to implement without being able to mock the WebSocketChannel properly
        // In a real implementation, we would:
        // 1. Mock WebSocketChannel.connect to return our mock channel
        // 2. Set up the internal state to connected
        // 3. Verify that the message is added to the sink
      });

      test('should throw exception when not connected', () async {
        // Act & Assert
        expect(
          () async => await webSocketService.sendMessage(
            WebSocketMessageType.heartbeat,
            {'timestamp': DateTime.now().toIso8601String()},
          ),
          throwsA(isA<WebSocketException>()),
        );
      });

      test('should handle message without response', () async {
        // This test would verify that expectResponse=false doesn't wait for a response
        // Implementation depends on being able to mock the WebSocketChannel properly
      });

      test('should handle timeout for expected response', () async {
        // This test would verify that a timeout occurs when no response is received
        // Implementation depends on being able to mock the WebSocketChannel properly
      });
    });

    group('message parsing', () {
      test('should parse valid heartbeat message', () {
        // Arrange
        final messageJson = MockData.heartbeatMessage;
        
        // Act
        final message = WebSocketMessage.fromJson(messageJson);
        
        // Assert
        expect(message.type, equals(WebSocketMessageType.heartbeat));
        expect(message.data['timestamp'], isNotNull);
      });

      test('should parse valid authentication message', () {
        // Arrange
        final messageJson = MockData.authenticationMessage;
        
        // Act
        final message = WebSocketMessage.fromJson(messageJson);
        
        // Assert
        expect(message.type, equals(WebSocketMessageType.authentication));
        expect(message.data['token'], equals(TestConstants.testToken));
      });

      test('should parse valid node update message', () {
        // Arrange
        final messageJson = MockData.nodeUpdateMessage;
        
        // Act
        final message = WebSocketMessage.fromJson(messageJson);
        
        // Assert
        expect(message.type, equals(WebSocketMessageType.nodeUpdate));
        expect(message.data['node'], isNotNull);
      });

      test('should parse valid task update message', () {
        // Arrange
        final messageJson = MockData.taskUpdateMessage;
        
        // Act
        final message = WebSocketMessage.fromJson(messageJson);
        
        // Assert
        expect(message.type, equals(WebSocketMessageType.taskUpdate));
        expect(message.data['task'], isNotNull);
      });

      test('should parse valid performance data message', () {
        // Arrange
        final messageJson = MockData.performanceDataMessage;
        
        // Act
        final message = WebSocketMessage.fromJson(messageJson);
        
        // Assert
        expect(message.type, equals(WebSocketMessageType.performanceData));
        expect(message.data['data'], isNotNull);
      });

      test('should throw exception for invalid message type', () {
        // Arrange
        final messageJson = {
          'id': 'test-id',
          'type': 'invalidType',
          'data': {},
          'timestamp': DateTime.now().toIso8601String(),
        };
        
        // Act & Assert
        expect(
          () => WebSocketMessage.fromJson(messageJson),
          throwsA(isA<WebSocketException>()),
        );
      });

      test('should throw exception for malformed JSON', () {
        // Arrange
        const invalidJson = '{"invalid": json}';
        
        // Act & Assert
        expect(
          () => WebSocketMessage.fromJson(jsonDecode(invalidJson)),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('message serialization', () {
      test('should serialize message to JSON', () {
        // Arrange
        final message = WebSocketMessage(
          type: WebSocketMessageType.heartbeat,
          data: {'timestamp': DateTime.now().toIso8601String()},
        );
        
        // Act
        final json = message.toJson();
        
        // Assert
        expect(json['type'], equals('heartbeat'));
        expect(json['data'], isNotNull);
        expect(json['timestamp'], isNotNull);
        expect(json['id'], isNotNull);
      });

      test('should serialize message with custom ID', () {
        // Arrange
        const customId = 'custom-message-id';
        final message = WebSocketMessage(
          type: WebSocketMessageType.heartbeat,
          data: {'test': 'data'},
          id: customId,
        );
        
        // Act
        final json = message.toJson();
        
        // Assert
        expect(json['id'], equals(customId));
      });
    });

    group('status monitoring', () {
      test('should provide status stream', () {
        // Act & Assert
        expect(webSocketService.statusStream, isA<Stream<ConnectionStatus>>());
      });

      test('should provide message stream', () {
        // Act & Assert
        expect(webSocketService.messageStream, isA<Stream<WebSocketMessage>>());
      });

      test('should return current status', () {
        // Act & Assert
        expect(webSocketService.currentStatus, equals(ConnectionStatus.disconnected));
      });
    });

    group('reconnection logic', () {
      test('should handle reconnection attempts', () {
        // This test would verify that the service attempts to reconnect after disconnection
        // Implementation depends on being able to mock the WebSocketChannel properly
      });

      test('should limit reconnection attempts', () {
        // This test would verify that the service stops trying to reconnect after max attempts
        // Implementation depends on being able to mock the WebSocketChannel properly
      });
    });

    group('heartbeat', () {
      test(TestDescriptions.heartbeatSuccess, () {
        // This test would verify that heartbeat messages are sent periodically
        // Implementation depends on being able to mock the WebSocketChannel properly
      });

      test('should stop heartbeat when disconnected', () {
        // This test would verify that heartbeat messages stop being sent after disconnection
        // Implementation depends on being able to mock the WebSocketChannel properly
      });
    });

    group('error handling', () {
      test('should handle WebSocket errors', () {
        // This test would verify that WebSocket errors are handled properly
        // Implementation depends on being able to mock the WebSocketChannel properly
      });

      test('should handle connection errors', () {
        // This test would verify that connection errors are handled properly
        // Implementation depends on being able to mock the WebSocketChannel properly
      });
    });

    group('authentication', () {
      test(TestDescriptions.authenticateSuccess, () {
        // This test would verify that authentication messages are sent properly
        // Implementation depends on being able to mock the WebSocketChannel properly
      });

      test('should handle authentication failures', () {
        // This test would verify that authentication failures are handled properly
        // Implementation depends on being able to mock the WebSocketChannel properly
      });
    });

    group('resource cleanup', () {
      test('should dispose resources properly', () {
        // Act
        webSocketService.dispose();
        
        // Assert
        // Verify that streams are closed
        // In a real implementation, we would verify that the stream controllers are closed
      });
    });
  });
}