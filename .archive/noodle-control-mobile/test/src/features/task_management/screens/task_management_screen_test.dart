import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle_control_mobile_app/src/features/task_management/screens/task_management_screen.dart';
import 'package:noodle_control_mobile_app/src/shared/models/models.dart';
import 'package:noodle_control_mobile_app/src/shared/widgets/common_widgets.dart';

import '../../../test_utils/test_helpers.dart';
import '../../../test_utils/mock_data.dart';
import 'task_management_screen_test.mocks.dart';

@GenerateMocks([GoRouter])
void main() {
  group('Task Management Screen Tests', () {
    late MockGoRouter mockGoRouter;
    
    setUp(() {
      mockGoRouter = MockGoRouter();
    });
    
    testWidgets('TaskManagementScreen renders correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Task Management'), findsOneWidget);
      expect(find.byType(LoadingIndicator), findsNothing);
      expect(find.byType(SearchBar), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Running'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('Failed'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen shows loading indicator initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Assert - Should show loading indicator initially
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading tasks...'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen displays tasks correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Check that task cards are displayed
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Model Training'), findsOneWidget);
      expect(find.text('Data Processing'), findsOneWidget);
      expect(find.text('Image Recognition'), findsOneWidget);
      
      // Check status chips
      expect(find.text('COMPLETED'), findsOneWidget);
      expect(find.text('RUNNING'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('FAILED'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen filters tasks by status', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Filter by running tasks
      await tester.tap(find.text('Running'));
      await tester.pump();
      
      // Assert - Only running tasks should be visible
      expect(find.text('Model Training'), findsOneWidget);
      expect(find.text('Code Analysis'), findsNothing);
      expect(find.text('Data Processing'), findsNothing);
      expect(find.text('Image Recognition'), findsNothing);
      
      // Filter by completed tasks
      await tester.tap(find.text('Completed'));
      await tester.pump();
      
      // Assert - Only completed tasks should be visible
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Model Training'), findsNothing);
      expect(find.text('Data Processing'), findsNothing);
      expect(find.text('Image Recognition'), findsNothing);
      
      // Filter by failed tasks
      await tester.tap(find.text('Failed'));
      await tester.pump();
      
      // Assert - Only failed tasks should be visible
      expect(find.text('Image Recognition'), findsOneWidget);
      expect(find.text('Code Analysis'), findsNothing);
      expect(find.text('Model Training'), findsNothing);
      expect(find.text('Data Processing'), findsNothing);
      
      // Filter by pending tasks
      await tester.tap(find.text('Pending'));
      await tester.pump();
      
      // Assert - Only pending tasks should be visible
      expect(find.text('Data Processing'), findsOneWidget);
      expect(find.text('Code Analysis'), findsNothing);
      expect(find.text('Model Training'), findsNothing);
      expect(find.text('Image Recognition'), findsNothing);
      
      // Reset filter
      await tester.tap(find.text('All'));
      await tester.pump();
      
      // Assert - All tasks should be visible again
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Model Training'), findsOneWidget);
      expect(find.text('Data Processing'), findsOneWidget);
      expect(find.text('Image Recognition'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen searches tasks correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Search for "Code"
      await tester.enterText(find.byType(TextField), 'Code');
      await tester.pump();
      
      // Assert - Only tasks with "Code" in title or description should be visible
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Model Training'), findsNothing);
      expect(find.text('Data Processing'), findsNothing);
      expect(find.text('Image Recognition'), findsNothing);
      
      // Clear search
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();
      
      // Assert - All tasks should be visible again
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Model Training'), findsOneWidget);
      expect(find.text('Data Processing'), findsOneWidget);
      expect(find.text('Image Recognition'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen shows empty state when no tasks match filter', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Search for non-existent task
      await tester.enterText(find.byType(TextField), 'NonExistentTask');
      await tester.pump();
      
      // Assert - Empty state should be shown
      expect(find.text('No tasks found'), findsOneWidget);
      expect(find.text('Try adjusting your search or filter'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen refreshes tasks when refresh button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap refresh button
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();
      
      // Assert - Loading indicator should appear briefly
      expect(find.byType(LoadingIndicator), findsOneWidget);
      
      // Wait for refresh to complete
      await tester.pumpAndSettle();
      
      // Assert - Tasks should be displayed again
      expect(find.text('Code Analysis'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen shows new task dialog when add button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap add button
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      
      // Assert - Dialog should be shown
      expect(find.text('New Task'), findsOneWidget);
      expect(find.text('Task creation will be implemented in a future version.'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
      
      // Close dialog
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      
      // Assert - Dialog should be closed
      expect(find.text('New Task'), findsNothing);
    });
    
    testWidgets('TaskManagementScreen shows task details when task is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on a task
      await tester.tap(find.text('Code Analysis'));
      await tester.pumpAndSettle();
      
      // Assert - Task details sheet should be shown
      expect(find.text('Code Analysis'), findsOneWidget);
      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Actions'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen cancels running task when cancel button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on a running task to show details
      await tester.tap(find.text('Model Training'));
      await tester.pumpAndSettle();
      
      // Tap cancel button
      await tester.tap(find.text('Cancel Task'));
      await tester.pump();
      
      // Assert - SnackBar should be shown
      expect(find.text('Cancelling task: Model Training'), findsOneWidget);
    });
    
    testWidgets('TaskManagementScreen retries failed task when retry button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on a failed task to show details
      await tester.tap(find.text('Image Recognition'));
      await tester.pumpAndSettle();
      
      // Tap retry button
      await tester.tap(find.text('Retry Task'));
      await tester.pump();
      
      // Assert - SnackBar should be shown
      expect(find.text('Retrying task: Image Recognition'), findsOneWidget);
    });
    
    testWidgets('TaskManagementCard displays progress bar for running tasks', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Progress bar should be visible for running tasks
      expect(find.text('Progress: 65%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
    });
    
    testWidgets('TaskManagementCard displays error message for failed tasks', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: TaskManagementScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Error message should be visible for failed tasks
      expect(find.text('GPU memory insufficient'), findsOneWidget);
    });
  });
}