import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noodle_control_mobile_app/src/core/repositories/auth_repository.dart';
import 'package:noodle_control_mobile_app/src/core/repositories/node_repository.dart';
import 'package:noodle_control_mobile_app/src/core/repositories/task_repository.dart';
import 'package:noodle_control_mobile_app/src/core/repositories/ide_repository.dart';
import 'package:noodle_control_mobile_app/src/core/network/http_client.dart';
import 'package:noodle_control_mobile_app/src/core/network/websocket_service.dart';
import 'package:noodle_control_mobile_app/src/core/network/connection_service.dart';
import 'package:noodle_control_mobile_app/src/shared/theme/app_theme.dart';

import 'mock_data.dart';
import 'test_helpers.dart';

// Mock repositories
final mockAuthRepositoryProvider = Provider<AuthRepository>((ref) => MockAuthRepository());
final mockNodeRepositoryProvider = Provider<NodeRepository>((ref) => MockNodeRepository());
final mockTaskRepositoryProvider = Provider<TaskRepository>((ref) => MockTaskRepository());
final mockIdeRepositoryProvider = Provider<IdeRepository>((ref) => MockIdeRepository());

// Mock network services
final mockHttpClientProvider = Provider<HttpClient>((ref) => MockHttpClient());
final mockWebSocketServiceProvider = Provider<WebSocketService>((ref) => MockWebSocketService());
final mockConnectionServiceProvider = Provider<ConnectionService>((ref) => MockConnectionService());

// Mock shared preferences
final mockSharedPreferencesProvider = Provider<SharedPreferences>((ref) => MockSharedPreferences());

// Mock theme mode notifier
final mockThemeModeNotifierProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return MockThemeModeNotifier();
});

/// Test provider overrides for use in tests
class TestProviderOverrides {
  static List<Override> get all => [
    authRepositoryProvider.overrideWithProvider(mockAuthRepositoryProvider),
    nodeRepositoryProvider.overrideWithProvider(mockNodeRepositoryProvider),
    taskRepositoryProvider.overrideWithProvider(mockTaskRepositoryProvider),
    ideRepositoryProvider.overrideWithProvider(mockIdeRepositoryProvider),
    httpClientProvider.overrideWithProvider(mockHttpClientProvider),
    webSocketServiceProvider.overrideWithProvider(mockWebSocketServiceProvider),
    connectionServiceProvider.overrideWithProvider(mockConnectionServiceProvider),
    sharedPreferencesProvider.overrideWithProvider(mockSharedPreferencesProvider),
    themeModeProvider.overrideWithProvider(mockThemeModeNotifierProvider),
  ];
  
  static Override authRepository(MockAuthRepository mock) {
    return authRepositoryProvider.overrideWithValue(mock);
  }
  
  static Override nodeRepository(MockNodeRepository mock) {
    return nodeRepositoryProvider.overrideWithValue(mock);
  }
  
  static Override taskRepository(MockTaskRepository mock) {
    return taskRepositoryProvider.overrideWithValue(mock);
  }
  
  static Override ideRepository(MockIdeRepository mock) {
    return ideRepositoryProvider.overrideWithValue(mock);
  }
  
  static Override httpClient(MockHttpClient mock) {
    return httpClientProvider.overrideWithValue(mock);
  }
  
  static Override webSocketService(MockWebSocketService mock) {
    return webSocketServiceProvider.overrideWithValue(mock);
  }
  
  static Override connectionService(MockConnectionService mock) {
    return connectionServiceProvider.overrideWithValue(mock);
  }
  
  static Override sharedPreferences(MockSharedPreferences mock) {
    return sharedPreferencesProvider.overrideWithValue(mock);
  }
  
  static Override themeModeNotifier(MockThemeModeNotifier mock) {
    return themeModeProvider.overrideWithValue(mock);
  }
}

/// Helper methods to set up common mock behaviors
class MockSetupHelpers {
  static void setupAuthRepository(MockAuthRepository mock) {
    when(mock.login(any, any)).thenAnswer((_) async => MockData.testUser);
    when(mock.logout()).thenAnswer((_) async {});
    when(mock.getCurrentUser()).thenAnswer((_) async => MockData.testUser);
    when(mock.isAuthenticated()).thenAnswer((_) async => true);
    when(mock.autoAuthenticate()).thenAnswer((_) async => MockData.testUser);
    when(mock.refreshToken()).thenAnswer((_) async => MockData.testToken);
    when(mock.updateProfile(any)).thenAnswer((_) async => MockData.testUser);
    when(mock.changePassword(any, any)).thenAnswer((_) async {});
    when(mock.registerDevice(any, any)).thenAnswer((_) async => MockData.testDevice);
  }
  
  static void setupNodeRepository(MockNodeRepository mock) {
    when(mock.getNodes()).thenAnswer((_) async => MockData.testNodes);
    when(mock.getNode(any)).thenAnswer((_) async => MockData.testNode);
    when(mock.createNode(any)).thenAnswer((_) async => MockData.testNode);
    when(mock.updateNode(any, any)).thenAnswer((_) async => MockData.testNode);
    when(mock.deleteNode(any)).thenAnswer((_) async {});
    when(mock.startNode(any)).thenAnswer((_) async {});
    when(mock.stopNode(any)).thenAnswer((_) async {});
    when(mock.restartNode(any)).thenAnswer((_) async {});
    when(mock.getNodeStatistics(any)).thenAnswer((_) async => MockData.testNodeStatistics);
    when(mock.getNodeLogs(any)).thenAnswer((_) async => MockData.testLogs);
  }
  
  static void setupTaskRepository(MockTaskRepository mock) {
    when(mock.getTasks()).thenAnswer((_) async => MockData.testTasks);
    when(mock.getTask(any)).thenAnswer((_) async => MockData.testTask);
    when(mock.createTask(any)).thenAnswer((_) async => MockData.testTask);
    when(mock.updateTask(any, any)).thenAnswer((_) async => MockData.testTask);
    when(mock.deleteTask(any)).thenAnswer((_) async {});
    when(mock.cancelTask(any)).thenAnswer((_) async {});
    when(mock.retryTask(any)).thenAnswer((_) async {});
    when(mock.getTaskLogs(any)).thenAnswer((_) async => MockData.testLogs);
    when(mock.getPerformanceData(any, any, any)).thenAnswer((_) async => MockData.testPerformanceData);
  }
  
  static void setupIdeRepository(MockIdeRepository mock) {
    when(mock.getProjects()).thenAnswer((_) async => MockData.testIdeProjects);
    when(mock.getProject(any)).thenAnswer((_) async => MockData.testIdeProject);
    when(mock.createProject(any)).thenAnswer((_) async => MockData.testIdeProject);
    when(mock.updateProject(any, any)).thenAnswer((_) async => MockData.testIdeProject);
    when(mock.deleteProject(any)).thenAnswer((_) async {});
    when(mock.openProject(any)).thenAnswer((_) async {});
    when(mock.closeProject(any)).thenAnswer((_) async {});
    when(mock.getProjectFiles(any)).thenAnswer((_) async => MockData.testFiles);
    when(mock.getFileContent(any, any)).thenAnswer((_) async => MockData.testFileContent);
    when(mock.updateFileContent(any, any, any)).thenAnswer((_) async {});
    when(mock.runProject(any)).thenAnswer((_) async {});
    when(mock.stopProject(any)).thenAnswer((_) async {});
    when(mock.getProjectOutput(any)).thenAnswer((_) async => '');
  }
  
  static void setupHttpClient(MockHttpClient mock) {
    when(mock.get(any)).thenAnswer((_) async => MockData.getNodesResponse);
    when(mock.post(any, data: anyNamed('data'))).thenAnswer((_) async => MockData.loginResponse);
    when(mock.put(any, data: anyNamed('data'))).thenAnswer((_) async => MockData.getNodeResponse);
    when(mock.delete(any)).thenAnswer((_) async => {});
    when(mock.updateAuthToken(any)).thenReturn(null);
    when(mock.updateBaseUrl(any)).thenReturn(null);
  }
  
  static void setupWebSocketService(MockWebSocketService mock) {
    when(mock.connect(authToken: anyNamed('authToken'))).thenAnswer((_) async {});
    when(mock.disconnect()).thenAnswer((_) async {});
    when(mock.sendMessage(any)).thenAnswer((_) async {});
    when(mock.reconnect()).thenAnswer((_) async {});
    when(mock.isAuthenticated()).thenReturn(true);
  }
  
  static void setupConnectionService(MockConnectionService mock) {
    when(mock.connect()).thenAnswer((_) async {});
    when(mock.disconnect()).thenAnswer((_) async {});
    when(mock.reconnect()).thenAnswer((_) async {});
    when(mock.healthCheck()).thenAnswer((_) async => true);
    when(mock.status).thenReturn(ConnectionStatus.connected);
    when(mock.lastError).thenReturn('');
    when(mock.lastConnectedTime).thenReturn(DateTime.now());
  }
  
  static void setupSharedPreferences(MockSharedPreferences mock) {
    when(mock.getString(any)).thenReturn('');
    when(mock.getBool(any)).thenReturn(false);
    when(mock.getInt(any)).thenReturn(0);
    when(mock.setString(any, any)).thenAnswer((_) async => true);
    when(mock.setBool(any, any)).thenAnswer((_) async => true);
    when(mock.setInt(any, any)).thenAnswer((_) async => true);
    when(mock.remove(any)).thenAnswer((_) async => true);
    when(mock.clear()).thenAnswer((_) async => true);
  }
}