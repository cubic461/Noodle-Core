import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'test_helpers.dart';

/// Test configuration and setup
class TestConfig {
  /// Initialize test environment
  static Future<void> setUpTestEnvironment() async {
    // Set up any global test configuration here
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Configure test timeouts
    setUpAll(() {
      // Increase timeout for async operations
      TestWidgetsFlutterBinding.instance.defaultTestTimeout = const Duration(minutes: 5);
    });
  }

  /// Common test setup for repository tests
  static void setUpRepositoryTests() {
    // Common setup for repository tests
  }

  /// Common test teardown for repository tests
  static void tearDownRepositoryTests() {
    // Common teardown for repository tests
  }

  /// Common test setup for service tests
  static void setUpServiceTests() {
    // Common setup for service tests
  }

  /// Common test teardown for service tests
  static void tearDownServiceTests() {
    // Common teardown for service tests
  }

  /// Common test setup for widget tests
  static void setUpWidgetTests() {
    // Common setup for widget tests
  }

  /// Common test teardown for widget tests
  static void tearDownWidgetTests() {
    // Common teardown for widget tests
  }
}

/// Test constants
class TestConstants {
  // Timeouts
  static const Duration defaultTimeout = Duration(seconds: 30);
  static const Duration shortTimeout = Duration(seconds: 5);
  static const Duration longTimeout = Duration(minutes: 2);
  
  // Test data
  static const String testUsername = 'testuser';
  static const String testPassword = 'testpassword';
  static const String testEmail = 'test@example.com';
  static const String testDeviceName = 'Test Device';
  static const String testDeviceType = 'mobile';
  static const String testNodeName = 'Test Node';
  static const String testNodeType = 'compute';
  static const String testTaskTitle = 'Test Task';
  static const String testTaskDescription = 'A test task for testing';
  static const String testProjectName = 'Test Project';
  static const String testProjectPath = '/path/to/project';
  static const String testProjectLanguage = 'dart';
  
  // URLs
  static const String testServerUrl = 'ws://localhost:8080';
  static const String testApiUrl = 'http://localhost:8080';
  static const String testWebSocketUrl = 'ws://localhost:8080/ws';
  
  // Tokens
  static const String testToken = 'test-jwt-token';
  static const String testRefreshToken = 'test-refresh-token';
  static const String testDeviceId = 'test-device-id';
  
  // IDs
  static const String testUserId = 'user-123';
  static const String testNodeId = 'node-789';
  static const String testTaskId = 'task-101';
  static const String testProjectId = 'project-202';
  
  // Error messages
  static const String networkErrorMessage = 'Network error occurred';
  static const String authenticationErrorMessage = 'Authentication failed';
  static const String notFoundErrorMessage = 'Resource not found';
  static const String serverErrorMessage = 'Internal server error';
  
  // Status codes
  static const int successStatusCode = 200;
  static const int createdStatusCode = 201;
  static const int badRequestStatusCode = 400;
  static const int unauthorizedStatusCode = 401;
  static const int forbiddenStatusCode = 403;
  static const int notFoundStatusCode = 404;
  static const int serverErrorStatusCode = 500;
  
  // Pagination
  static const int defaultLimit = 20;
  static const int defaultOffset = 0;
  static const int maxLimit = 100;
  
  // File paths
  static const String testFilePath = '/test/file.txt';
  static const String testFileContent = 'This is test file content';
  
  // Performance metrics
  static const double testCpuUsage = 25.5;
  static const double testMemoryUsage = 60.2;
  static const int testActiveTasks = 2;
  static const int testTotalTasks = 10;
  
  // Time ranges
  static const String testTimeRange = '1h';
  static const String testStartTime = '2023-01-01T00:00:00.000Z';
  static const String testEndTime = '2023-01-01T01:00:00.000Z';
}

/// Test groups for organizing tests
class TestGroups {
  static const String authentication = 'Authentication';
  static const String nodeManagement = 'Node Management';
  static const String taskManagement = 'Task Management';
  static const String ideManagement = 'IDE Management';
  static const String networkServices = 'Network Services';
  static const String webSocket = 'WebSocket';
  static const String httpClient = 'HTTP Client';
  static const String connectionService = 'Connection Service';
  static const String widgets = 'Widgets';
  static const String dashboard = 'Dashboard';
  static const String ideControl = 'IDE Control';
  static const String nodeManagementWidget = 'Node Management Widget';
  static const String reasoningMonitoring = 'Reasoning Monitoring';
  static const String settings = 'Settings';
  static const String integration = 'Integration';
  static const String unit = 'Unit Tests';
  static const String widgetTests = 'Widget Tests';
  static const String integrationTests = 'Integration Tests';
}

/// Test descriptions
class TestDescriptions {
  // Authentication
  static const String loginSuccess = 'should login successfully with valid credentials';
  static const String loginFailure = 'should throw exception with invalid credentials';
  static const String registerDeviceSuccess = 'should register device successfully';
  static const String refreshTokenSuccess = 'should refresh token successfully';
  static const String logoutSuccess = 'should logout successfully';
  static const String getCurrentUserSuccess = 'should get current user successfully';
  static const String updateProfileSuccess = 'should update profile successfully';
  static const String changePasswordSuccess = 'should change password successfully';
  static const String isAuthenticatedTrue = 'should return true when authenticated';
  static const String isAuthenticatedFalse = 'should return false when not authenticated';
  static const String autoAuthenticateSuccess = 'should auto-authenticate successfully';
  static const String autoAuthenticateFailure = 'should fail auto-authentication with invalid token';
  
  // Node Management
  static const String getNodesSuccess = 'should get nodes successfully';
  static const String getNodeSuccess = 'should get node by ID successfully';
  static const String createNodeSuccess = 'should create node successfully';
  static const String updateNodeSuccess = 'should update node successfully';
  static const String deleteNodeSuccess = 'should delete node successfully';
  static const String startNodeSuccess = 'should start node successfully';
  static const String stopNodeSuccess = 'should stop node successfully';
  static const String restartNodeSuccess = 'should restart node successfully';
  static const String getNodeStatisticsSuccess = 'should get node statistics successfully';
  static const String getNodeLogsSuccess = 'should get node logs successfully';
  
  // Task Management
  static const String getTasksSuccess = 'should get tasks successfully';
  static const String getTaskSuccess = 'should get task by ID successfully';
  static const String createTaskSuccess = 'should create task successfully';
  static const String updateTaskSuccess = 'should update task successfully';
  static const String deleteTaskSuccess = 'should delete task successfully';
  static const String cancelTaskSuccess = 'should cancel task successfully';
  static const String retryTaskSuccess = 'should retry task successfully';
  static const String getTaskLogsSuccess = 'should get task logs successfully';
  static const String getPerformanceDataSuccess = 'should get performance data successfully';
  
  // IDE Management
  static const String getProjectsSuccess = 'should get IDE projects successfully';
  static const String getProjectSuccess = 'should get IDE project by ID successfully';
  static const String createProjectSuccess = 'should create IDE project successfully';
  static const String updateProjectSuccess = 'should update IDE project successfully';
  static const String deleteProjectSuccess = 'should delete IDE project successfully';
  static const String openProjectSuccess = 'should open IDE project successfully';
  static const String closeProjectSuccess = 'should close IDE project successfully';
  static const String getProjectFilesSuccess = 'should get IDE project files successfully';
  static const String getFileContentSuccess = 'should get file content successfully';
  static const String updateFileContentSuccess = 'should update file content successfully';
  static const String runProjectSuccess = 'should run IDE project successfully';
  static const String stopProjectSuccess = 'should stop IDE project successfully';
  static const String getProjectOutputSuccess = 'should get IDE project output successfully';
  
  // WebSocket
  static const String connectSuccess = 'should connect successfully';
  static const String disconnectSuccess = 'should disconnect successfully';
  static const String sendMessageSuccess = 'should send message successfully';
  static const String receiveMessageSuccess = 'should receive message successfully';
  static const String authenticateSuccess = 'should authenticate successfully';
  static const String heartbeatSuccess = 'should send heartbeat successfully';
  static const String reconnectSuccess = 'should reconnect successfully';
  
  // HTTP Client
  static const String getRequestSuccess = 'should make GET request successfully';
  static const String postRequestSuccess = 'should make POST request successfully';
  static const String putRequestSuccess = 'should make PUT request successfully';
  static const String deleteRequestSuccess = 'should make DELETE request successfully';
  static const String uploadFileSuccess = 'should upload file successfully';
  static const String handleResponseSuccess = 'should handle response successfully';
  static const String handleErrorSuccess = 'should handle error successfully';
  
  // Connection Service
  static const String initializeSuccess = 'should initialize successfully';
  static const String connectToServerSuccess = 'should connect to server successfully';
  static const String disconnectFromServerSuccess = 'should disconnect from server successfully';
  static const String reconnectToServerSuccess = 'should reconnect to server successfully';
  static const String healthCheckSuccess = 'should perform health check successfully';
  static const String statusUpdateSuccess = 'should update status successfully';
  
  // Widgets
  static const String widgetRenders = 'should render widget correctly';
  static const String widgetInteracts = 'should handle user interactions correctly';
  static const String widgetUpdates = 'should update when data changes';
  static const String widgetNavigates = 'should handle navigation correctly';
  
  // Integration
  static const String authenticationFlowSuccess = 'should complete authentication flow successfully';
  static const String nodeManagementFlowSuccess = 'should complete node management flow successfully';
  static const String taskManagementFlowSuccess = 'should complete task management flow successfully';
  static const String ideManagementFlowSuccess = 'should complete IDE management flow successfully';
}