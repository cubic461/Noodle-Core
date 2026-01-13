import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:noodle_control_mobile_app/src/features/auth/screens/auth_screen.dart';
import 'package:noodle_control_mobile_app/src/features/auth/screens/login_screen.dart';
import 'package:noodle_control_mobile_app/src/features/auth/screens/device_registration_screen.dart';
import 'package:noodle_control_mobile_app/src/features/dashboard/screens/dashboard_screen.dart';
import 'package:noodle_control_mobile_app/src/core/repositories/auth_repository.dart';
import 'package:noodle_control_mobile_app/src/core/network/websocket_service.dart';
import 'package:noodle_control_mobile_app/src/core/network/http_client.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';

import '../src/test_utils/test_helpers.dart';
import '../src/test_utils/mock_data.dart';
import 'authentication_flow_test.mocks.dart';

@GenerateMocks([
  AuthRepository,
  WebSocketService,
  HttpClient,
  GoRouter,
  SharedPreferences
])
void main() {
  group('Authentication Flow Integration Tests', () {
    late MockAuthRepository mockAuthRepository;
    late MockWebSocketService mockWebSocketService;
    late MockHttpClient mockHttpClient;
    late MockGoRouter mockGoRouter;
    late MockSharedPreferences mockSharedPreferences;
    
    setUp(() {
      mockAuthRepository = MockAuthRepository();
      mockWebSocketService = MockWebSocketService();
      mockHttpClient = MockHttpClient();
      mockGoRouter = MockGoRouter();
      mockSharedPreferences = MockSharedPreferences();
      
      // Setup default mock behavior
      when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
      when(mockAuthRepository.getCurrentUser()).thenThrow(Exception('Not authenticated'));
      when(mockAuthRepository.login(any, any)).thenAnswer((_) async => MockData.testUser);
      when(mockAuthRepository.registerDevice(any, any)).thenAnswer((_) async => MockData.testDevice);
      when(mockWebSocketService.connect(authToken: anyNamed('authToken'))).thenAnswer((_) async {});
      when(mockWebSocketService.disconnect()).thenAnswer((_) async {});
      when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
      when(mockSharedPreferences.getString(any)).thenReturn(null);
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
    });
    
    testWidgets('Complete authentication flow: login to dashboard', (WidgetTester tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => AuthScreen(),
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
              GoRoute(
                path: '/register',
                builder: (context, state) => DeviceRegistrationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            webSocketServiceProvider.overrideWithValue(mockWebSocketService),
            httpClientProvider.overrideWithValue(mockHttpClient),
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Wait for initial screen to load
      await tester.pumpAndSettle();
      
      // Assert - Should be on auth screen initially
      expect(find.text('NoodleControl'), findsOneWidget);
      
      // Navigate to login screen
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      
      // Assert - Should be on login screen
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      
      // Enter credentials
      await tester.enterText(find.byKey(const Key('username_field')), 'testuser');
      await tester.enterText(find.byKey(const Key('password_field')), 'testpassword');
      await tester.pump();
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Wait for authentication to complete
      await tester.pumpAndSettle();
      
      // Assert - Should be on dashboard screen after successful login
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Verify authentication methods were called
      verify(mockAuthRepository.login('testuser', 'testpassword')).called(1);
      verify(mockHttpClient.updateAuthToken(MockData.testToken)).called(1);
      verify(mockWebSocketService.connect(authToken: MockData.testToken)).called(1);
    });
    
    testWidgets('Authentication flow with device registration', (WidgetTester tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/auth',
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => AuthScreen(),
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
              GoRoute(
                path: '/register',
                builder: (context, state) => DeviceRegistrationScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            webSocketServiceProvider.overrideWithValue(mockWebSocketService),
            httpClientProvider.overrideWithValue(mockHttpClient),
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Wait for initial screen to load
      await tester.pumpAndSettle();
      
      // Navigate to device registration screen
      await tester.tap(find.text('Register Device'));
      await tester.pumpAndSettle();
      
      // Assert - Should be on device registration screen
      expect(find.text('Register Device'), findsOneWidget);
      expect(find.byType(TextField), findsWidgets);
      
      // Enter device details
      await tester.enterText(find.byKey(const Key('device_name_field')), 'Test Device');
      await tester.pump();
      
      // Select device type
      await tester.tap(find.text('Select Type'));
      await tester.pump();
      await tester.tap(find.text('Mobile').last);
      await tester.pump();
      
      // Tap register button
      await tester.tap(find.text('Register'));
      await tester.pump();
      
      // Wait for registration to complete
      await tester.pumpAndSettle();
      
      // Assert - Should be on login screen after successful registration
      expect(find.text('Login'), findsOneWidget);
      
      // Verify registration method was called
      verify(mockAuthRepository.registerDevice('Test Device', 'mobile')).called(1);
    });
    
    testWidgets('Authentication flow handles login failure', (WidgetTester tester) async {
      // Arrange
      when(mockAuthRepository.login(any, any)).thenThrow(Exception('Invalid credentials'));
      
      final router = GoRouter(
        initialLocation: '/auth/login',
        routes: [
          GoRoute(
            path: '/auth',
            builder: (context, state) => AuthScreen(),
            routes: [
              GoRoute(
                path: '/login',
                builder: (context, state) => LoginScreen(),
              ),
            ],
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            webSocketServiceProvider.overrideWithValue(mockWebSocketService),
            httpClientProvider.overrideWithValue(mockHttpClient),
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Wait for login screen to load
      await tester.pumpAndSettle();
      
      // Enter credentials
      await tester.enterText(find.byKey(const Key('username_field')), 'invaliduser');
      await tester.enterText(find.byKey(const Key('password_field')), 'invalidpassword');
      await tester.pump();
      
      // Tap login button
      await tester.tap(find.text('Login'));
      await tester.pump();
      
      // Wait for authentication to complete
      await tester.pumpAndSettle();
      
      // Assert - Should still be on login screen after failed login
      expect(find.text('Login'), findsOneWidget);
      
      // Verify authentication method was called
      verify(mockAuthRepository.login('invaliduser', 'invalidpassword')).called(1);
      
      // Verify error message is shown
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
    
    testWidgets('Authentication flow handles auto-authentication', (WidgetTester tester) async {
      // Arrange
      when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => MockData.testUser);
      when(mockAuthRepository.autoAuthenticate()).thenAnswer((_) async => MockData.testUser);
      
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => '/dashboard',
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => DashboardScreen(),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            webSocketServiceProvider.overrideWithValue(mockWebSocketService),
            httpClientProvider.overrideWithValue(mockHttpClient),
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Wait for auto-authentication to complete
      await tester.pumpAndSettle();
      
      // Assert - Should be on dashboard screen after auto-authentication
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Verify auto-authentication method was called
      verify(mockAuthRepository.autoAuthenticate()).called(1);
    });
    
    testWidgets('Authentication flow handles logout', (WidgetTester tester) async {
      // Arrange
      when(mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => MockData.testUser);
      when(mockAuthRepository.autoAuthenticate()).thenAnswer((_) async => MockData.testUser);
      when(mockAuthRepository.logout()).thenAnswer((_) async {});
      
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            redirect: (context, state) => '/dashboard',
          ),
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => Scaffold(
              appBar: AppBar(
                title: const Text('Dashboard'),
                actions: [
                  IconButton(
                    key: const Key('logout_button'),
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await mockAuthRepository.logout();
                      router.go('/auth/login');
                    },
                  ),
                ],
              ),
              body: const Center(child: Text('Dashboard')),
            ),
          ),
          GoRoute(
            path: '/auth/login',
            builder: (context, state) => LoginScreen(),
          ),
        ],
      );
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(mockAuthRepository),
            webSocketServiceProvider.overrideWithValue(mockWebSocketService),
            httpClientProvider.overrideWithValue(mockHttpClient),
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      
      // Wait for auto-authentication to complete
      await tester.pumpAndSettle();
      
      // Assert - Should be on dashboard screen after auto-authentication
      expect(find.text('Dashboard'), findsOneWidget);
      
      // Tap logout button
      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pump();
      
      // Wait for logout to complete
      await tester.pumpAndSettle();
      
      // Assert - Should be on login screen after logout
      expect(find.text('Login'), findsOneWidget);
      
      // Verify logout method was called
      verify(mockAuthRepository.logout()).called(1);
    });
  });
}