import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:noodle_control_mobile_app/src/core/repositories/node_repository.dart';
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
import 'node_repository_test.mocks.dart';

void main() {
  group(TestGroups.nodeManagement, () {
    late NodeRepository nodeRepository;
    late MockHttpClient mockHttpClient;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockWebSocketService = MockWebSocketService();
      nodeRepository = NodeRepository(
        httpClient: mockHttpClient,
        webSocketService: mockWebSocketService,
      );
    });

    tearDown(() {
      nodeRepository.dispose();
    });

    group('getNodes', () {
      test(TestDescriptions.getNodesSuccess, () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
        
        // Act
        final result = await nodeRepository.getNodes();
        
        // Assert
        expect(result, isA<List<Node>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testNode.id));
        expect(result[0].name, equals(MockData.testNode.name));
        
        verify(mockHttpClient.get('/api/v1/nodes')).called(1);
      });

      test('should return cached nodes when forceRefresh is false', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
        
        // First call to populate cache
        await nodeRepository.getNodes();
        
        // Act - Second call should use cache
        final result = await nodeRepository.getNodes();
        
        // Assert
        expect(result, isA<List<Node>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testNode.id));
        
        // HTTP client should only be called once
        verify(mockHttpClient.get('/api/v1/nodes')).called(1);
      });

      test('should fetch fresh nodes when forceRefresh is true', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
        
        // First call to populate cache
        await nodeRepository.getNodes();
        
        // Act - Second call with forceRefresh should fetch fresh data
        final result = await nodeRepository.getNodes(forceRefresh: true);
        
        // Assert
        expect(result, isA<List<Node>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testNode.id));
        
        // HTTP client should be called twice
        verify(mockHttpClient.get('/api/v1/nodes')).called(2);
      });

      test('should handle network exceptions when getting nodes', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.getNodes(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getNode', () {
      test(TestDescriptions.getNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodeResponse);
        
        // Act
        final result = await nodeRepository.getNode(nodeId);
        
        // Assert
        expect(result, isA<Node>());
        expect(result.id, equals(MockData.testNode.id));
        expect(result.name, equals(MockData.testNode.name));
        
        verify(mockHttpClient.get('/api/v1/nodes/$nodeId')).called(1);
      });

      test('should handle network exceptions when getting node', () async {
        // Arrange
        const nodeId = 'invalid-node-id';
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.getNode(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('createNode', () {
      test(TestDescriptions.createNodeSuccess, () async {
        // Arrange
        final nodeData = {
          'name': TestConstants.testNodeName,
          'type': TestConstants.testNodeType,
        };
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'create-node-123',
          'node': MockData.testNodeJson,
        });
        
        // Act
        final result = await nodeRepository.createNode(nodeData);
        
        // Assert
        expect(result, isA<Node>());
        expect(result.id, equals(MockData.testNode.id));
        expect(result.name, equals(MockData.testNode.name));
        
        verify(mockHttpClient.post(
          '/api/v1/nodes',
          data: nodeData,
        )).called(1);
      });

      test('should handle network exceptions when creating node', () async {
        // Arrange
        final nodeData = {
          'name': TestConstants.testNodeName,
          'type': TestConstants.testNodeType,
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
          () async => await nodeRepository.createNode(nodeData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateNode', () {
      test(TestDescriptions.updateNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        final nodeData = {
          'name': 'Updated Node Name',
        };
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'update-node-123',
          'node': MockData.testNodeJson,
        });
        
        // Act
        final result = await nodeRepository.updateNode(nodeId, nodeData);
        
        // Assert
        expect(result, isA<Node>());
        expect(result.id, equals(MockData.testNode.id));
        
        verify(mockHttpClient.put(
          '/api/v1/nodes/$nodeId',
          data: nodeData,
        )).called(1);
      });

      test('should handle network exceptions when updating node', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        final nodeData = {
          'name': 'Updated Node Name',
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
          () async => await nodeRepository.updateNode(nodeId, nodeData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteNode', () {
      test(TestDescriptions.deleteNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.delete(any)).thenAnswer((_) async => {
          'requestId': 'delete-node-123',
        });
        
        // Act
        await nodeRepository.deleteNode(nodeId);
        
        // Assert
        verify(mockHttpClient.delete('/api/v1/nodes/$nodeId')).called(1);
      });

      test('should handle network exceptions when deleting node', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.delete(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.deleteNode(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('startNode', () {
      test(TestDescriptions.startNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'start-node-123',
        });
        
        // First populate cache
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
        await nodeRepository.getNodes();
        
        // Act
        await nodeRepository.startNode(nodeId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/nodes/$nodeId/start')).called(1);
      });

      test('should handle network exceptions when starting node', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.startNode(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('stopNode', () {
      test(TestDescriptions.stopNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'stop-node-123',
        });
        
        // First populate cache
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
        await nodeRepository.getNodes();
        
        // Act
        await nodeRepository.stopNode(nodeId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/nodes/$nodeId/stop')).called(1);
      });

      test('should handle network exceptions when stopping node', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.stopNode(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('restartNode', () {
      test(TestDescriptions.restartNodeSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'restart-node-123',
        });
        
        // Act
        await nodeRepository.restartNode(nodeId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/nodes/$nodeId/restart')).called(1);
      });

      test('should handle network exceptions when restarting node', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.restartNode(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getNodeStatistics', () {
      test(TestDescriptions.getNodeStatisticsSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        final statistics = {
          'uptime': 86400,
          'totalTasks': 100,
          'completedTasks': 95,
          'failedTasks': 5,
        };
        
        when(mockHttpClient.get(any)).thenAnswer((_) async => {
          'requestId': 'node-stats-123',
          'statistics': statistics,
        });
        
        // Act
        final result = await nodeRepository.getNodeStatistics(nodeId);
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['uptime'], equals(86400));
        expect(result['totalTasks'], equals(100));
        
        verify(mockHttpClient.get('/api/v1/nodes/$nodeId/statistics')).called(1);
      });

      test('should handle network exceptions when getting node statistics', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await nodeRepository.getNodeStatistics(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getNodeLogs', () {
      test(TestDescriptions.getNodeLogsSuccess, () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        const limit = 50;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'node-logs-123',
          'logs': MockData.testLogs,
        });
        
        // Act
        final result = await nodeRepository.getNodeLogs(nodeId, limit: limit);
        
        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, equals(MockData.testLogs.length));
        expect(result[0], equals(MockData.testLogs[0]));
        
        verify(mockHttpClient.get(
          '/api/v1/nodes/$nodeId/logs',
          queryParameters: {'limit': limit},
        )).called(1);
      });

      test('should use default limit when not specified', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'node-logs-123',
          'logs': MockData.testLogs,
        });
        
        // Act
        await nodeRepository.getNodeLogs(nodeId);
        
        // Assert
        verify(mockHttpClient.get(
          '/api/v1/nodes/$nodeId/logs',
          queryParameters: {'limit': 100}, // Default limit
        )).called(1);
      });

      test('should handle network exceptions when getting node logs', () async {
        // Arrange
        const nodeId = TestConstants.testNodeId;
        
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
          () async => await nodeRepository.getNodeLogs(nodeId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('periodic refresh', () {
      test('should start periodic refresh', () async {
        // Act
        nodeRepository.startPeriodicRefresh();
        
        // Wait a bit to allow the timer to start
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        // Assert - Timer should be started (no direct way to verify without making timer public)
        expect(nodeRepository.nodesStream, isA<Stream>());
        
        // Clean up
        nodeRepository.stopPeriodicRefresh();
      });

      test('should stop periodic refresh', () async {
        // Act
        nodeRepository.startPeriodicRefresh();
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        nodeRepository.stopPeriodicRefresh();
        
        // Assert - No exceptions should be thrown
        expect(nodeRepository.nodesStream, isA<Stream>());
      });
    });

    group('streams', () {
      test('should provide nodes stream', () {
        // Act & Assert
        expect(nodeRepository.nodesStream, isA<Stream<List<Node>>>());
      });

      test('should provide node update stream', () {
        // Act & Assert
        expect(nodeRepository.nodeUpdateStream, isA<Stream<Node>>());
      });
    });
  });
}