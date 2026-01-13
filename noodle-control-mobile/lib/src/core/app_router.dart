import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/screens/auth_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/device_registration_screen.dart';
import '../features/dashboard/screens/dashboard_screen.dart';
import '../features/ide_control/screens/ide_control_screen.dart';
import '../features/node_management/screens/node_management_screen.dart';
import '../features/task_management/screens/task_management_screen.dart';
import '../features/reasoning_monitoring/screens/reasoning_monitoring_screen.dart';
import '../features/settings/screens/settings_screen.dart';
import '../shared/widgets/splash_screen.dart';

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash screen
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // Authentication routes
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => const LoginScreen(),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => const DeviceRegistrationScreen(),
          ),
        ],
      ),
      
      // Main app routes (authenticated)
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      
      GoRoute(
        path: '/ide-control',
        builder: (context, state) => const IdeControlScreen(),
      ),
      
      GoRoute(
        path: '/node-management',
        builder: (context, state) => const NodeManagementScreen(),
      ),
      
      GoRoute(
        path: '/task-management',
        builder: (context, state) => const TaskManagementScreen(),
      ),
      
      GoRoute(
        path: '/reasoning-monitoring',
        builder: (context, state) => const ReasoningMonitoringScreen(),
      ),
      
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? 'Unknown error',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});