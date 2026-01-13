import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:noodle_control_mobile_app/src/core/repositories/auth_repository.dart';
import 'package:noodle_control_mobile_app/src/core/network/http_client.dart';
import 'package:noodle_control_mobile_app/src/core/network/websocket_service.dart';
import 'package:noodle_control_mobile_app/src/core/network/exceptions.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';
import 'package:noodle_control_mobile_app/src/core/app.dart';

import '../../test_utils/test_helpers.dart';
import '../../test_utils/mock_data.dart';
import '../../test_utils/test_config.dart';

// Generate mocks
@GenerateMocks([
  HttpClient,
  WebSocketService,
])
import 'auth_repository_test.mocks.dart';

void main() {
  group(TestGroups.authentication, () {
    late AuthRepository authRepository;
    late MockHttpClient mockHttpClient;
    late MockWebSocketService mockWebSocketService;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockWebSocketService = MockWebSocketService();
      authRepository = AuthRepository(
        httpClient: mockHttpClient,
        webSocketService: mockWebSocketService,
      );
    });

    group('login', () {
      test(TestDescriptions.loginSuccess, () async {
        // Arrange
        const username = TestConstants.testUsername;
        const password = TestConstants.testPassword;
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => MockData.loginResponse);
        
        when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
        when(mockWebSocketService.connect(authToken: anyNamed('authToken')))
            .thenAnswer((_) async {});
        
        // Act
        final result = await authRepository.login(username, password);
        
        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(MockData.testUser.id));
        expect(result.username, equals(MockData.testUser.username));
        expect(result.email, equals(MockData.testUser.email));
        
        verify(mockHttpClient.post(
          '/api/v1/auth/login',
          data: argThat(
            containsPair('username', username),
          ),
        )).called(1);
        verify(mockHttpClient.updateAuthToken(MockData.testToken)).called(1);
        verify(mockWebSocketService.connect(authToken: MockData.testToken))
            .called(1);
      });

      test(TestDescriptions.loginFailure, () async {
        // Arrange
        const username = 'invaliduser';
        const password = 'invalidpassword';
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(AuthenticationException.invalidCredentials());
        
        // Act & Assert
        expect(
          () async => await authRepository.login(username, password),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should handle network exceptions during login', () async {
        // Arrange
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
          () async => await authRepository.login('user', 'pass'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle server errors during login', () async {
        // Arrange
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(ApiException(
          code: 3003,
          message: 'Internal server error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await authRepository.login('user', 'pass'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('registerDevice', () {
      test(TestDescriptions.registerDeviceSuccess, () async {
        // Arrange
        const name = TestConstants.testDeviceName;
        const type = TestConstants.testDeviceType;
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => MockData.registerDeviceResponse);
        
        // Act
        final result = await authRepository.registerDevice(name, type);
        
        // Assert
        expect(result, isA<Device>());
        expect(result.id, equals(MockData.testDevice.id));
        expect(result.name, equals(MockData.testDevice.name));
        expect(result.type, equals(MockData.testDevice.type));
        
        verify(mockHttpClient.post(
          '/api/v1/devices/register',
          data: argThat(
            allOf([
              containsPair('name', name),
              containsPair('type', type),
            ]),
          ),
        )).called(1);
      });

      test('should handle network exceptions during device registration', () async {
        // Arrange
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
          () async => await authRepository.registerDevice('device', 'mobile'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle server errors during device registration', () async {
        // Arrange
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(ApiException(
          code: 3003,
          message: 'Internal server error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await authRepository.registerDevice('device', 'mobile'),
          throwsA(isA<ApiException>()),
        );
      });
    });

    group('refreshToken', () {
      test(TestDescriptions.refreshTokenSuccess, () async {
        // Arrange
        const newToken = 'new-jwt-token';
        const newRefreshToken = 'new-refresh-token';
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'token': newToken,
          'refreshToken': newRefreshToken,
        });
        
        when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
        
        // Act
        final result = await authRepository.refreshToken();
        
        // Assert
        expect(result, equals(newToken));
        verify(mockHttpClient.post(
          '/api/v1/auth/refresh',
          data: argThat(
            containsPair('refreshToken', any),
          ),
        )).called(1);
        verify(mockHttpClient.updateAuthToken(newToken)).called(1);
      });

      test('should throw exception when no refresh token is available', () async {
        // Act & Assert
        expect(
          () async => await authRepository.refreshToken(),
          throwsA(isA<AuthenticationException>()),
        );
      });

      test('should handle network exceptions during token refresh', () async {
        // Arrange
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
          () async => await authRepository.refreshToken(),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('logout', () {
      test(TestDescriptions.logoutSuccess, () async {
        // Arrange
        when(mockHttpClient.post(any)).thenAnswer((_) async => {});
        when(mockWebSocketService.disconnect()).thenAnswer((_) async {});
        
        // Act
        await authRepository.logout();
        
        // Assert
        verify(mockHttpClient.post('/api/v1/auth/logout')).called(1);
        verify(mockWebSocketService.disconnect()).called(1);
        verify(mockHttpClient.updateAuthToken(null)).called(1);
      });

      test('should handle exceptions during logout API call', () async {
        // Arrange
        when(mockHttpClient.post(any)).thenThrow(Exception('API error'));
        when(mockWebSocketService.disconnect()).thenAnswer((_) async {});
        
        // Act & Assert - Should not throw exception
        await authRepository.logout();
        
        verify(mockWebSocketService.disconnect()).called(1);
        verify(mockHttpClient.updateAuthToken(null)).called(1);
      });

      test('should handle exceptions during WebSocket disconnect', () async {
        // Arrange
        when(mockHttpClient.post(any)).thenAnswer((_) async => {});
        when(mockWebSocketService.disconnect()).thenThrow(Exception('WebSocket error'));
        
        // Act & Assert - Should not throw exception
        await authRepository.logout();
        
        verify(mockHttpClient.post('/api/v1/auth/logout')).called(1);
        verify(mockHttpClient.updateAuthToken(null)).called(1);
      });
    });

    group('getCurrentUser', () {
      test(TestDescriptions.getCurrentUserSuccess, () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => {
          'user': MockData.testUserJson,
        });
        
        // Act
        final result = await authRepository.getCurrentUser();
        
        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(MockData.testUser.id));
        expect(result.username, equals(MockData.testUser.username));
        expect(result.email, equals(MockData.testUser.email));
        
        verify(mockHttpClient.get('/api/v1/auth/me')).called(1);
      });

      test('should handle network exceptions when getting current user', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await authRepository.getCurrentUser(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle authentication exceptions when getting current user', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(AuthenticationException.invalidToken());
        
        // Act & Assert
        expect(
          () async => await authRepository.getCurrentUser(),
          throwsA(isA<AuthenticationException>()),
        );
      });
    });

    group('updateProfile', () {
      test(TestDescriptions.updateProfileSuccess, () async {
        // Arrange
        final profileData = {'username': 'newusername'};
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {
          'user': MockData.testUserJson,
        });
        
        // Act
        final result = await authRepository.updateProfile(profileData);
        
        // Assert
        expect(result, isA<User>());
        expect(result.id, equals(MockData.testUser.id));
        
        verify(mockHttpClient.put(
          '/api/v1/auth/profile',
          data: profileData,
        )).called(1);
      });

      test('should handle network exceptions during profile update', () async {
        // Arrange
        final profileData = {'username': 'newusername'};
        
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
          () async => await authRepository.updateProfile(profileData),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle validation exceptions during profile update', () async {
        // Arrange
        final profileData = {'username': ''}; // Invalid username
        
        when(mockHttpClient.put(
          any,
          data: anyNamed('data'),
        )).thenThrow(ValidationException(
          code: 2002,
          message: 'Invalid username',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await authRepository.updateProfile(profileData),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('changePassword', () {
      test(TestDescriptions.changePasswordSuccess, () async {
        // Arrange
        const currentPassword = 'oldpassword';
        const newPassword = 'newpassword';
        
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenAnswer((_) async => {});
        
        // Act
        await authRepository.changePassword(currentPassword, newPassword);
        
        // Assert
        verify(mockHttpClient.post(
          '/api/v1/auth/change-password',
          data: argThat(
            allOf([
              containsPair('currentPassword', currentPassword),
              containsPair('newPassword', newPassword),
            ]),
          ),
        )).called(1);
      });

      test('should handle network exceptions during password change', () async {
        // Arrange
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
          () async => await authRepository.changePassword('old', 'new'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle validation exceptions during password change', () async {
        // Arrange
        when(mockHttpClient.post(
          any,
          data: anyNamed('data'),
        )).thenThrow(ValidationException(
          code: 2002,
          message: 'Password too weak',
          timestamp: DateTime.now(),
        ));
        
        // Act & Assert
        expect(
          () async => await authRepository.changePassword('old', 'weak'),
          throwsA(isA<ValidationException>()),
        );
      });
    });

    group('isAuthenticated', () {
      test(TestDescriptions.isAuthenticatedTrue, () async {
        // Arrange
        when(mockHttpClient.get(any)).thenAnswer((_) async => {
          'user': MockData.testUserJson,
        });
        
        // Act
        final result = await authRepository.isAuthenticated();
        
        // Assert
        expect(result, isTrue);
      });

      test(TestDescriptions.isAuthenticatedFalse, () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act
        final result = await authRepository.isAuthenticated();
        
        // Assert
        expect(result, isFalse);
      });

      test('should return false when authentication exception occurs', () async {
        // Arrange
        when(mockHttpClient.get(any)).thenThrow(AuthenticationException.invalidToken());
        
        // Act
        final result = await authRepository.isAuthenticated();
        
        // Assert
        expect(result, isFalse);
      });
    });

    group('autoAuthenticate', () {
      test(TestDescriptions.autoAuthenticateSuccess, () async {
        // Arrange
        when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
        when(mockWebSocketService.connect(authToken: anyNamed('authToken')))
            .thenAnswer((_) async {});
        when(mockHttpClient.get(any)).thenAnswer((_) async => {
          'user': MockData.testUserJson,
        });
        
        // Act
        final result = await authRepository.autoAuthenticate();
        
        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(MockData.testUser.id));
        
        verify(mockHttpClient.updateAuthToken(any)).called(1);
        verify(mockWebSocketService.connect(authToken: anyNamed('authToken')))
            .called(1);
        verify(mockHttpClient.get('/api/v1/auth/me')).called(1);
      });

      test(TestDescriptions.autoAuthenticateFailure, () async {
        // Arrange
        when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
        when(mockWebSocketService.connect(authToken: anyNamed('authToken')))
            .thenAnswer((_) async {});
        when(mockHttpClient.get(any)).thenThrow(NetworkException(
          code: 1001,
          message: 'Network error',
          timestamp: DateTime.now(),
        ));
        
        // Act
        final result = await authRepository.autoAuthenticate();
        
        // Assert
        expect(result, isNull);
        
        verify(mockHttpClient.updateAuthToken(null)).called(1);
      });

      test('should handle exceptions during WebSocket connection', () async {
        // Arrange
        when(mockHttpClient.updateAuthToken(any)).thenReturn(null);
        when(mockWebSocketService.connect(authToken: anyNamed('authToken')))
            .thenThrow(Exception('WebSocket error'));
        
        // Act
        final result = await authRepository.autoAuthenticate();
        
        // Assert
        expect(result, isNull);
        
        verify(mockHttpClient.updateAuthToken(null)).called(1);
      });
    });
  });
}