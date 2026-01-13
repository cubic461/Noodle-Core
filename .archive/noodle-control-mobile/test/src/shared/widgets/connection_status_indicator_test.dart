import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:noodle_control_mobile_app/src/shared/widgets/connection_status_indicator.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';
import 'package:noodle_control_mobile_app/src/core/services/service_provider.dart';

import '../../test_utils/test_helpers.dart';
import 'connection_status_indicator_test.mocks.dart';

@GenerateMocks([ConnectionService])
void main() {
  group('Connection Status Indicator Tests', () {
    late MockConnectionService mockConnectionService;
    
    setUp(() {
      mockConnectionService = MockConnectionService();
    });
    
    testWidgets('ConnectionStatusIndicator renders correctly when connected', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusIndicator renders correctly when connecting', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connecting);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connecting'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_find), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusIndicator renders correctly when disconnected', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.disconnected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Disconnected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusIndicator renders correctly when in error state', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.error);
      when(mockConnectionService.lastError).thenReturn('Connection failed');
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusIndicator without label renders correctly', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(showLabel: false),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connected'), findsNothing);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusIndicator with custom size renders correctly', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(size: 24.0),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      
      // Verify the icon size
      final icon = tester.widget<Icon>(find.byIcon(Icons.wifi));
      expect(icon.size, equals(24.0));
    });
    
    testWidgets('ConnectionStatusIndicator handles tap correctly', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      var onTapCalled = false;
      final onTap = () {
        onTapCalled = true;
      };
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ConnectionStatusIndicator(onTap: onTap),
            ),
          ),
        ),
      );
      
      // Tap on the indicator
      await tester.tap(find.byIcon(Icons.wifi));
      
      // Assert
      expect(onTapCalled, isTrue);
    });
    
    testWidgets('AnimatedConnectionStatusIndicator animates when connecting', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connecting);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connecting'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_find), findsOneWidget);
      
      // Let the animation run for a frame
      await tester.pump();
      
      // Verify the animation is running
      expect(find.byType(Transform), findsOneWidget);
    });
    
    testWidgets('AnimatedConnectionStatusIndicator does not animate when connected', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: AnimatedConnectionStatusIndicator(),
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      
      // Verify there is no animation
      expect(find.byType(Transform), findsNothing);
    });
    
    testWidgets('ConnectionStatusDialog renders correctly when connected', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.connected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(DateTime.now().subtract(const Duration(minutes: 5)));
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => ConnectionStatusDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      
      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Connection Status'), findsOneWidget);
      expect(find.text('Connected'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
    
    testWidgets('ConnectionStatusDialog shows reconnect button when not connected', (WidgetTester tester) async {
      // Arrange
      when(mockConnectionService.status).thenReturn(ConnectionStatus.disconnected);
      when(mockConnectionService.lastError).thenReturn('');
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      when(mockConnectionService.reconnect()).thenAnswer((_) async {});
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => ConnectionStatusDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      
      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Reconnect'), findsOneWidget);
      
      // Test reconnect button
      await tester.tap(find.text('Reconnect'));
      await tester.pump();
      
      // Verify reconnect was called
      verify(mockConnectionService.reconnect()).called(1);
    });
    
    testWidgets('ConnectionStatusDialog shows error when in error state', (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'Connection failed: Timeout';
      when(mockConnectionService.status).thenReturn(ConnectionStatus.error);
      when(mockConnectionService.lastError).thenReturn(errorMessage);
      when(mockConnectionService.lastConnectedTime).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            connectionServiceProvider.overrideWithValue(mockConnectionService),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: tester.element(find.byType(ElevatedButton)),
                    builder: (context) => ConnectionStatusDialog(),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
      
      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Connection Status'), findsOneWidget);
      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Last Error:'), findsOneWidget);
      expect(find.text(errorMessage), findsOneWidget);
    });
  });
}