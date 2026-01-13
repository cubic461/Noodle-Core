import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle_control_mobile_app/src/features/settings/screens/settings_screen.dart';
import 'package:noodle_control_mobile_app/src/shared/widgets/common_widgets.dart';
import 'package:noodle_control_mobile_app/src/shared/theme/app_theme.dart';

import '../../../test_utils/test_helpers.dart';
import '../../../test_utils/mock_data.dart';
import 'settings_screen_test.mocks.dart';

@GenerateMocks([GoRouter, SharedPreferences])
void main() {
  group('Settings Screen Tests', () {
    late MockGoRouter mockGoRouter;
    late MockSharedPreferences mockSharedPreferences;
    
    setUp(() {
      mockGoRouter = MockGoRouter();
      mockSharedPreferences = MockSharedPreferences();
      
      // Setup default mock behavior
      when(mockSharedPreferences.getString(any)).thenReturn('ws://localhost:8080');
      when(mockSharedPreferences.getBool(any)).thenReturn(true);
      when(mockSharedPreferences.getInt(any)).thenReturn(30);
      when(mockSharedPreferences.setString(any, any)).thenAnswer((_) async => true);
      when(mockSharedPreferences.setBool(any, any)).thenAnswer((_) async => true);
      when(mockSharedPreferences.setInt(any, any)).thenAnswer((_) async => true);
    });
    
    testWidgets('SettingsScreen renders correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Connection'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Logging'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Danger Zone'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen shows loading indicator initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Assert - Should show loading indicator initially
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading settings...'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays connection settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.text('ws://localhost:8080'), findsOneWidget);
      expect(find.text('Auto Connect'), findsOneWidget);
      expect(find.text('Connection Timeout'), findsOneWidget);
      expect(find.text('Max Retries'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays appearance settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('SYSTEM'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays notification settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Enable Notifications'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays logging settings', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Enable Logging'), findsOneWidget);
      expect(find.text('Log Level'), findsOneWidget);
      expect(find.text('INFO'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays about section', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('App Version'), findsOneWidget);
      expect(find.text('Build Number'), findsOneWidget);
      expect(find.text('About NoodleControl'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen displays danger zone', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen opens server URL dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on server URL
      await tester.tap(find.text('Server URL'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Server URL'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen opens connection timeout dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on connection timeout
      await tester.tap(find.text('Connection Timeout'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Connection Timeout'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen opens max retries dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on max retries
      await tester.tap(find.text('Max Retries'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Max Retries'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen opens theme mode dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on theme mode
      await tester.tap(find.text('Theme Mode'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Theme Mode'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen opens log level dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on log level
      await tester.tap(find.text('Log Level'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Log Level'), findsOneWidget);
      expect(find.text('DEBUG'), findsOneWidget);
      expect(find.text('INFO'), findsOneWidget);
      expect(find.text('WARNING'), findsOneWidget);
      expect(find.text('ERROR'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen toggles auto connect switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Find the auto connect switch
      final autoConnectSwitch = tester.widget<SwitchListTile>(find.byType(SwitchListTile).first);
      expect(autoConnectSwitch.value, isTrue);
      
      // Toggle the switch
      await tester.tap(find.byType(SwitchListTile).first);
      await tester.pump();
      
      // Assert - The switch should be toggled
      final updatedSwitch = tester.widget<SwitchListTile>(find.byType(SwitchListTile).first);
      expect(updatedSwitch.value, isFalse);
    });
    
    testWidgets('SettingsScreen toggles dark mode switch', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Find the dark mode switch
      final darkModeSwitches = find.byType(SwitchListTile);
      expect(darkModeSwitches.evaluate().length, greaterThan(1));
      
      // Toggle the dark mode switch (second switch)
      await tester.tap(darkModeSwitches.at(1));
      await tester.pump();
      
      // Assert - The switch should be toggled
      final updatedSwitch = tester.widget<SwitchListTile>(darkModeSwitches.at(1));
      expect(updatedSwitch.value, isFalse);
    });
    
    testWidgets('SettingsScreen shows reset settings confirmation dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on reset settings
      await tester.tap(find.text('Reset Settings'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Reset Settings'), findsOneWidget);
      expect(find.text('Are you sure you want to reset all settings to their default values? This action cannot be undone.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Reset'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen shows logout confirmation dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on logout
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Logout'), findsOneWidget);
      expect(find.text('Are you sure you want to logout? You will need to sign in again to access your account.'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen shows about dialog', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on about
      await tester.tap(find.text('About NoodleControl'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('About NoodleControl'), findsOneWidget);
      expect(find.text('Mobile app for managing Noodle AI development environment.'), findsOneWidget);
      expect(find.text('© 2023 NoodleControl. All rights reserved.'), findsOneWidget);
    });
    
    testWidgets('SettingsScreen saves settings when save button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(mockSharedPreferences),
          ],
          child: MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap save button
      await tester.tap(find.byIcon(Icons.save));
      await tester.pump();
      
      // Assert - SnackBar should be shown
      expect(find.text('Settings saved successfully'), findsOneWidget);
      
      // Verify settings were saved
      verify(mockSharedPreferences.setString('server_url', 'ws://localhost:8080')).called(1);
      verify(mockSharedPreferences.setBool('auto_connect', true)).called(1);
      verify(mockSharedPreferences.setBool('notifications_enabled', true)).called(1);
      verify(mockSharedPreferences.setBool('dark_mode', false)).called(1);
      verify(mockSharedPreferences.setString('theme_mode', 'system')).called(1);
      verify(mockSharedPreferences.setInt('connection_timeout', 30)).called(1);
      verify(mockSharedPreferences.setInt('max_retries', 3)).called(1);
      verify(mockSharedPreferences.setBool('enable_logging', true)).called(1);
      verify(mockSharedPreferences.setString('log_level', 'INFO')).called(1);
    });
  });
}