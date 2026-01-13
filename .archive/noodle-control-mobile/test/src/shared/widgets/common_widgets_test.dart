import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:noodle_control_mobile_app/src/shared/widgets/common_widgets.dart';

void main() {
  group('Common Widgets Tests', () {
    testWidgets('NoodleAppBar renders correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'Test App Bar';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: NoodleAppBar(title: title),
          ),
        ),
      );
      
      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
    
    testWidgets('NoodleAppBar with actions renders correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'Test App Bar';
      final actionKey = UniqueKey();
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: NoodleAppBar(
              title: title,
              actions: [
                IconButton(key: actionKey, icon: const Icon(Icons.add), onPressed: () {}),
              ],
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.byKey(actionKey), findsOneWidget);
    });
    
    testWidgets('NoodleBottomNavigationBar renders correctly', (WidgetTester tester) async {
      // Arrange
      var selectedIndex = 0;
      final onTap = (int index) {
        selectedIndex = index;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NoodleBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onTap,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(BottomNavigationBar), findsOneWidget);
      expect(find.text('Dashboard'), findsOneWidget);
      expect(find.text('IDE'), findsOneWidget);
      expect(find.text('Nodes'), findsOneWidget);
      expect(find.text('Monitor'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
    
    testWidgets('NoodleBottomNavigationBar handles tap correctly', (WidgetTester tester) async {
      // Arrange
      var selectedIndex = 0;
      final onTap = (int index) {
        selectedIndex = index;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            bottomNavigationBar: NoodleBottomNavigationBar(
              currentIndex: selectedIndex,
              onTap: onTap,
            ),
          ),
        ),
      );
      
      // Tap on the second item
      await tester.tap(find.text('IDE'));
      await tester.pump();
      
      // Assert
      expect(selectedIndex, equals(1));
    });
    
    testWidgets('StatusChip renders correctly', (WidgetTester tester) async {
      // Arrange
      const label = 'Active';
      const color = Colors.green;
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusChip(label: label, color: color),
          ),
        ),
      );
      
      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byType(Chip), findsOneWidget);
    });
    
    testWidgets('LoadingIndicator renders correctly', (WidgetTester tester) async {
      // Arrange
      const message = 'Loading...';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIndicator(message: message),
          ),
        ),
      );
      
      // Assert
      expect(find.text(message), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('ErrorDisplay renders correctly', (WidgetTester tester) async {
      // Arrange
      const message = 'Something went wrong';
      var retryCalled = false;
      final onRetry = () {
        retryCalled = true;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplay(message: message, onRetry: onRetry),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Oops! Something went wrong'), findsOneWidget);
      expect(find.text(message), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      
      // Test retry button
      await tester.tap(find.text('Retry'));
      expect(retryCalled, isTrue);
    });
    
    testWidgets('EmptyState renders correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'No Data';
      const subtitle = 'There is no data to display';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: title,
              subtitle: subtitle,
              icon: Icons.inbox,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });
    
    testWidgets('EmptyState with action renders correctly', (WidgetTester tester) async {
      // Arrange
      const title = 'No Data';
      const subtitle = 'There is no data to display';
      var actionCalled = false;
      final action = ActionButton(
        label: 'Create',
        icon: Icons.add,
        onPressed: () {
          actionCalled = true;
        },
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              title: title,
              subtitle: subtitle,
              icon: Icons.inbox,
              action: action,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(title), findsOneWidget);
      expect(find.text(subtitle), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      
      // Test action button
      await tester.tap(find.text('Create'));
      expect(actionCalled, isTrue);
    });
    
    testWidgets('ActionButton renders correctly', (WidgetTester tester) async {
      // Arrange
      const label = 'Test Button';
      var buttonPressed = false;
      final onPressed = () {
        buttonPressed = true;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              label: label,
              icon: Icons.add,
              onPressed: onPressed,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
      
      // Test button press
      await tester.tap(find.text(label));
      expect(buttonPressed, isTrue);
    });
    
    testWidgets('ActionButton with loading state renders correctly', (WidgetTester tester) async {
      // Arrange
      const label = 'Test Button';
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ActionButton(
              label: label,
              icon: Icons.add,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
    });
    
    testWidgets('SearchBar renders correctly', (WidgetTester tester) async {
      // Arrange
      const hintText = 'Search...';
      var onChangedCalled = false;
      String? searchValue;
      final onChanged = (String value) {
        onChangedCalled = true;
        searchValue = value;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              hintText: hintText,
              onChanged: onChanged,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text(hintText), findsOneWidget);
      
      // Test typing in search bar
      await tester.enterText(find.byType(TextField), 'test query');
      expect(onChangedCalled, isTrue);
      expect(searchValue, equals('test query'));
      
      // Test clear button appears
      expect(find.byIcon(Icons.clear), findsOneWidget);
      
      // Test clear button
      await tester.tap(find.byIcon(Icons.clear));
      expect(searchValue, equals(''));
    });
    
    testWidgets('FilterChip renders correctly', (WidgetTester tester) async {
      // Arrange
      const label = 'Active';
      var selected = false;
      final onSelected = (bool value) {
        selected = value;
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterChip(
              label: const Text(label),
              selected: selected,
              onSelected: onSelected,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text(label), findsOneWidget);
      expect(find.byType(FilterChip), findsOneWidget);
      
      // Test selection
      await tester.tap(find.byType(FilterChip));
      expect(selected, isTrue);
    });
    
    testWidgets('ResponsiveLayoutBuilder renders correctly', (WidgetTester tester) async {
      // Arrange
      ScreenType? detectedScreenType;
      final builder = (BuildContext context, ScreenType screenType) {
        detectedScreenType = screenType;
        return Text('Screen Type: ${screenType.name}');
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveLayoutBuilder(builder: builder),
          ),
        ),
      );
      
      // Assert
      expect(detectedScreenType, isNotNull);
      expect(find.text('Screen Type: ${detectedScreenType!.name}'), findsOneWidget);
    });
    
    testWidgets('ResponsiveValue renders correctly', (WidgetTester tester) async {
      // Arrange
      const mobileValue = 'Mobile';
      const tabletValue = 'Tablet';
      const desktopValue = 'Desktop';
      
      final builder = (BuildContext context, String value) {
        return Text('Value: $value');
      };
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ResponsiveValue<String>(
              mobile: mobileValue,
              tablet: tabletValue,
              desktop: desktopValue,
              builder: builder,
            ),
          ),
        ),
      );
      
      // Assert
      // Default test window size is small, so it should use mobile value
      expect(find.text('Value: $mobileValue'), findsOneWidget);
    });
  });
}