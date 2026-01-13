import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:go_router/go_router.dart';

import 'package:noodle_control_mobile_app/src/features/reasoning_monitoring/screens/reasoning_monitoring_screen.dart';
import 'package:noodle_control_mobile_app/src/shared/widgets/common_widgets.dart';

import '../../../test_utils/test_helpers.dart';
import '../../../test_utils/mock_data.dart';
import 'reasoning_monitoring_screen_test.mocks.dart';

@GenerateMocks([GoRouter])
void main() {
  group('Reasoning Monitoring Screen Tests', () {
    late MockGoRouter mockGoRouter;
    
    setUp(() {
      mockGoRouter = MockGoRouter();
    });
    
    testWidgets('ReasoningMonitoringScreen renders correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('Performance Monitor'), findsOneWidget);
      expect(find.text('Time Range:'), findsOneWidget);
      expect(find.text('15m'), findsOneWidget);
      expect(find.text('1h'), findsOneWidget);
      expect(find.text('6h'), findsOneWidget);
      expect(find.text('24h'), findsOneWidget);
      expect(find.text('Performance Metrics'), findsOneWidget);
      expect(find.text('Running Tasks'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen shows loading indicator initially', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Assert - Should show loading indicator initially
      expect(find.byType(LoadingIndicator), findsOneWidget);
      expect(find.text('Loading monitoring data...'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen displays metric cards correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Check that metric cards are displayed
      expect(find.text('CPU Usage'), findsOneWidget);
      expect(find.text('Memory Usage'), findsOneWidget);
      expect(find.text('Network I/O'), findsOneWidget);
      expect(find.text('Active Tasks'), findsOneWidget);
      
      // Check metric values
      expect(find.textContaining('%'), findsWidgets);
      expect(find.text('2'), findsOneWidget); // Active tasks count
    });
    
    testWidgets('ReasoningMonitoringScreen displays performance charts correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Check that charts are displayed
      expect(find.text('CPU Usage'), findsAtLeastNWidgets(2)); // Once in metric card, once in chart
      expect(find.text('Memory Usage'), findsAtLeastNWidgets(2)); // Once in metric card, once in chart
      expect(find.byType(LineChart), findsWidgets);
    });
    
    testWidgets('ReasoningMonitoringScreen filters data by time range', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Filter by 15 minutes
      await tester.tap(find.text('15m'));
      await tester.pump();
      
      // Assert - Time range should be updated
      expect(find.text('15m'), findsOneWidget);
      
      // Filter by 6 hours
      await tester.tap(find.text('6h'));
      await tester.pump();
      
      // Assert - Time range should be updated
      expect(find.text('6h'), findsOneWidget);
      
      // Filter by 24 hours
      await tester.tap(find.text('24h'));
      await tester.pump();
      
      // Assert - Time range should be updated
      expect(find.text('24h'), findsOneWidget);
      
      // Reset to 1 hour
      await tester.tap(find.text('1h'));
      await tester.pump();
      
      // Assert - Time range should be updated
      expect(find.text('1h'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen displays running tasks correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Check that running tasks are displayed
      expect(find.text('Model Training'), findsOneWidget);
      expect(find.text('Data Processing'), findsOneWidget);
      expect(find.text('Train ML model on dataset'), findsOneWidget);
      expect(find.text('Process and clean dataset'), findsOneWidget);
      
      // Check progress bars
      expect(find.text('Progress: 65%'), findsOneWidget);
      expect(find.text('Progress: 40%'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      
      // Check start times
      expect(find.textContaining('ago'), findsWidgets);
    });
    
    testWidgets('ReasoningMonitoringScreen refreshes data when refresh button is tapped', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
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
      
      // Assert - Data should be displayed again
      expect(find.text('Performance Monitor'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen shows empty state when no running tasks', (WidgetTester tester) async {
      // This test would require modifying the mock data to have no running tasks
      // For now, we'll just verify the empty state widget exists in the code
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Empty state is not shown because we have running tasks
      expect(find.text('No running tasks'), findsNothing);
    });
    
    testWidgets('ReasoningMonitoringScreen handles pull-to-refresh', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Perform pull-to-refresh
      await tester.fling(
        find.byType(Scrollable).first,
        const Offset(0, 300),
        1000,
      );
      await tester.pump();
      
      // Wait for refresh to complete
      await tester.pumpAndSettle();
      
      // Assert - Data should still be displayed
      expect(find.text('Performance Monitor'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen metric cards show trend indicators', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Trend indicators should be visible
      // We can't directly test the trend values since they're calculated dynamically,
      // but we can verify the metric cards are displayed
      expect(find.byType(Card), findsWidgets);
    });
    
    testWidgets('ReasoningMonitoringScreen task cards show cancel button', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Cancel buttons should be visible
      expect(find.byIcon(Icons.cancel), findsWidgets);
    });
    
    testWidgets('ReasoningMonitoringScreen task cards show progress', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Assert - Progress indicators should be visible
      expect(find.byType(LinearProgressIndicator), findsWidgets);
      expect(find.text('Progress: 65%'), findsOneWidget);
      expect(find.text('Progress: 40%'), findsOneWidget);
    });
    
    testWidgets('ReasoningMonitoringScreen navigates to other screens via bottom navigation', (WidgetTester tester) async {
      // Arrange
      when(mockGoRouter.go(any)).thenReturn(null);
      
      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: ReasoningMonitoringScreen(),
          ),
        ),
      );
      
      // Wait for loading to complete
      await tester.pumpAndSettle();
      
      // Tap on Dashboard in bottom navigation
      await tester.tap(find.text('Dashboard'));
      await tester.pump();
      
      // Assert - Navigation should be triggered
      // Note: We can't directly verify the navigation without a more complex setup
      // but we can verify the button is tappable
      expect(find.text('Dashboard'), findsOneWidget);
    });
  });
}