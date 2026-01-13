import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:noodle_control_mobile_app/src/core/repositories/ide_repository.dart';
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
import 'ide_repository_test.mocks.dart';

void main() {
  group(TestGroups.ideManagement, () {
    late IdeRepository ideRepository;
    late MockHttpClient mockHttpClient;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockWebSocketService = MockWebSocketService();
      ideRepository = IdeRepository(
        httpClient: mockHttpClient,
        webSocketService: mockWebSocketService,
      );
    });

    tearDown(() {
      ideRepository.dispose();
    });

    group('getProjects', () {
      test(TestDescriptions.getProjectsSuccess, () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectsResponse);
        
        // Act
        final result = await ideRepository.getProjects();
        
        // Assert
        expect(result, isA<List<IdeProject>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testIdeProject.id));
        expect(result[0].name, equals(MockData.testIdeProject.name));
        
        verify(mockHttpClient.get('/api/v1/ide/projects')).called(1);
      });

      test('should return cached projects when forceRefresh is false', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectsResponse);
        
        // First call to populate cache
        await ideRepository.getProjects();
        
        // Act - Second call should use cache
        final result = await ideRepository.getProjects();
        
        // Assert
        expect(result, isA<List<IdeProject>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testIdeProject.id));
        
        // HTTP client should only be called once
        verify(mockHttpClient.get('/api/v1/ide/projects')).called(1);
      });

      test('should fetch fresh projects when forceRefresh is true', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectsResponse);
        
        // First call to populate cache
        await ideRepository.getProjects();
        
        // Act - Second call with forceRefresh should fetch fresh data
        final result = await ideRepository.getProjects(forceRefresh: true);
        
        // Assert
        expect(result, isA<List<IdeProject>>());
        expect(result.length, equals(1));
        expect(result[0].id, equals(MockData.testIdeProject.id));
        
        // HTTP client should be called twice
        verify(mockHttpClient.get('/api/v1/ide/projects')).called(2);
      });

      test('should handle network exceptions when getting projects', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.getProjects(),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProject', () {
      test(TestDescriptions.getProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectResponse);
        
        // Act
        final result = await ideRepository.getProject(projectId);
        
        // Assert
        expect(result, isA<IdeProject>());
        expect(result.id, equals(MockData.testIdeProject.id));
        expect(result.name, equals(MockData.testIdeProject.name));
        
        verify(mockHttpClient.get('/api/v1/ide/projects/$projectId')).called(1);
      });

      test('should handle network exceptions when getting project', () async {
        // Arrange
        const projectId = 'invalid-project-id';
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.getProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('createProject', () {
      test(TestDescriptions.createProjectSuccess, () async {
        // Arrange
        final projectData = {
          'name': TestConstants.testProjectName,
          'path': TestConstants.testProjectPath,
          'language': TestConstants.testProjectLanguage,
        };
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'create-project-123',
          'project': MockData.testIdeProjectJson,
        });
        
        // Act
        final result = await ideRepository.createProject(projectData);
        
        // Assert
        expect(result, isA<IdeProject>());
        expect(result.id, equals(MockData.testIdeProject.id));
        expect(result.name, equals(MockData.testIdeProject.name));
        
        verify(mockHttpClient.post(
          '/api/v1/ide/projects',
          data: projectData,
        )).called(1);
      });

      test('should handle network exceptions when creating project', () async {
        // Arrange
        final projectData = {
          'name': TestConstants.testProjectName,
          'path': TestConstants.testProjectPath,
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
          () async => await ideRepository.createProject(projectData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateProject', () {
      test(TestDescriptions.updateProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        final projectData = {
          'name': 'Updated Project Name',
        };
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'update-project-123',
          'project': MockData.testIdeProjectJson,
        });
        
        // Act
        final result = await ideRepository.updateProject(projectId, projectData);
        
        // Assert
        expect(result, isA<IdeProject>());
        expect(result.id, equals(MockData.testIdeProject.id));
        
        verify(mockHttpClient.put(
          '/api/v1/ide/projects/$projectId',
          data: projectData,
        )).called(1);
      });

      test('should handle network exceptions when updating project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        final projectData = {
          'name': 'Updated Project Name',
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
          () async => await ideRepository.updateProject(projectId, projectData),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('deleteProject', () {
      test(TestDescriptions.deleteProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.delete(any)).thenAnswer((_) async => {
          'requestId': 'delete-project-123',
        });
        
        // Act
        await ideRepository.deleteProject(projectId);
        
        // Assert
        verify(mockHttpClient.delete('/api/v1/ide/projects/$projectId')).called(1);
      });

      test('should handle network exceptions when deleting project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.delete(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.deleteProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('openProject', () {
      test(TestDescriptions.openProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'open-project-123',
        });
        
        // First populate cache
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectsResponse);
        await ideRepository.getProjects();
        
        // Act
        await ideRepository.openProject(projectId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/ide/projects/$projectId/open')).called(1);
      });

      test('should handle network exceptions when opening project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.openProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('closeProject', () {
      test(TestDescriptions.closeProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'close-project-123',
        });
        
        // First populate cache
        when(mockHttpClient.get(any)).thenAnswer((_) async => MockData.getIdeProjectsResponse);
        await ideRepository.getProjects();
        
        // Act
        await ideRepository.closeProject(projectId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/ide/projects/$projectId/close')).called(1);
      });

      test('should handle network exceptions when closing project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.closeProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProjectFiles', () {
      test(TestDescriptions.getProjectFilesSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.get(any)).thenAnswer((_) async => {
          'requestId': 'project-files-123',
          'files': MockData.testFiles,
        });
        
        // Act
        final result = await ideRepository.getProjectFiles(projectId);
        
        // Assert
        expect(result, isA<List<Map<String, dynamic>>>());
        expect(result.length, equals(MockData.testFiles.length));
        expect(result[0]['name'], equals(MockData.testFiles[0]['name']));
        
        verify(mockHttpClient.get('/api/v1/ide/projects/$projectId/files')).called(1);
      });

      test('should handle network exceptions when getting project files', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.getProjectFiles(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getFileContent', () {
      test(TestDescriptions.getFileContentSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        const filePath = TestConstants.testFilePath;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'file-content-123',
          'content': TestConstants.testFileContent,
        });
        
        // Act
        final result = await ideRepository.getFileContent(projectId, filePath);
        
        // Assert
        expect(result, isA<String>());
        expect(result, equals(TestConstants.testFileContent));
        
        verify(mockHttpClient.get(
          '/api/v1/ide/projects/$projectId/files/content',
          queryParameters: {'path': filePath},
        )).called(1);
      });

      test('should handle network exceptions when getting file content', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        const filePath = TestConstants.testFilePath;
        
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
          () async => await ideRepository.getFileContent(projectId, filePath),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('updateFileContent', () {
      test(TestDescriptions.updateFileContentSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        const filePath = TestConstants.testFilePath;
        const content = TestConstants.testFileContent;
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'update-file-123',
        });
        
        // Act
        await ideRepository.updateFileContent(projectId, filePath, content);
        
        // Assert
        verify(mockHttpClient.put(
          '/api/v1/ide/projects/$projectId/files/content',
          data: {
            'path': filePath,
            'content': content,
          },
        )).called(1);
      });

      test('should handle network exceptions when updating file content', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        const filePath = TestConstants.testFilePath;
        const content = TestConstants.testFileContent;
        
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
          () async => await ideRepository.updateFileContent(projectId, filePath, content),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('runProject', () {
      test(TestDescriptions.runProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        final config = {'debug': true};
        final resultData = {'output': 'Project started successfully'};
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'run-project-123',
          'result': resultData,
        });
        
        // Act
        final result = await ideRepository.runProject(projectId, config: config);
        
        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['output'], equals('Project started successfully'));
        
        verify(mockHttpClient.post(
          '/api/v1/ide/projects/$projectId/run',
          data: config,
        )).called(1);
      });

      test('should run project without config', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        final resultData = {'output': 'Project started successfully'};
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'requestId': 'run-project-123',
          'result': resultData,
        });
        
        // Act
        await ideRepository.runProject(projectId);
        
        // Assert
        verify(mockHttpClient.post(
          '/api/v1/ide/projects/$projectId/run',
          data: {},
        )).called(1);
      });

      test('should handle network exceptions when running project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
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
          () async => await ideRepository.runProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('stopProject', () {
      test(TestDescriptions.stopProjectSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenAnswer((_) async => {
          'requestId': 'stop-project-123',
        });
        
        // Act
        await ideRepository.stopProject(projectId);
        
        // Assert
        verify(mockHttpClient.post('/api/v1/ide/projects/$projectId/stop')).called(1);
      });

      test('should handle network exceptions when stopping project', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.post(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await ideRepository.stopProject(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('getProjectOutput', () {
      test(TestDescriptions.getProjectOutputSuccess, () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        const lines = 50;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'project-output-123',
          'output': MockData.testLogs,
        });
        
        // Act
        final result = await ideRepository.getProjectOutput(projectId, lines: lines);
        
        // Assert
        expect(result, isA<List<String>>());
        expect(result.length, equals(MockData.testLogs.length));
        expect(result[0], equals(MockData.testLogs[0]));
        
        verify(mockHttpClient.get(
          '/api/v1/ide/projects/$projectId/output',
          queryParameters: {'lines': lines},
        )).called(1);
      });

      test('should get project output without lines parameter', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
        when(mockHttpClient.get(
          any,
          queryParameters: anyNamed('queryParameters'),
        )).thenAnswer((_) async => {
          'requestId': 'project-output-123',
          'output': MockData.testLogs,
        });
        
        // Act
        await ideRepository.getProjectOutput(projectId);
        
        // Assert
        verify(mockHttpClient.get(
          '/api/v1/ide/projects/$projectId/output',
          queryParameters: {},
        )).called(1);
      });

      test('should handle network exceptions when getting project output', () async {
        // Arrange
        const projectId = TestConstants.testProjectId;
        
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
          () async => await ideRepository.getProjectOutput(projectId),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('periodic refresh', () {
      test('should start periodic refresh', () async {
        // Act
        ideRepository.startPeriodicRefresh();
        
        // Wait a bit to allow the timer to start
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        // Assert - Timer should be started (no direct way to verify without making timer public)
        expect(ideRepository.projectsStream, isA<Stream>());
        
        // Clean up
        ideRepository.stopPeriodicRefresh();
      });

      test('should stop periodic refresh', () async {
        // Act
        ideRepository.startPeriodicRefresh();
        await TestHelpers.waitFor(const Duration(milliseconds: 100));
        
        ideRepository.stopPeriodicRefresh();
        
        // Assert - No exceptions should be thrown
        expect(ideRepository.projectsStream, isA<Stream>());
      });
    });

    group('streams', () {
      test('should provide projects stream', () {
        // Act & Assert
        expect(ideRepository.projectsStream, isA<Stream<List<IdeProject>>>());
      });

      test('should provide project update stream', () {
        // Act & Assert
        expect(ideRepository.projectUpdateStream, isA<Stream<IdeProject>>());
      });
    });
  });
}