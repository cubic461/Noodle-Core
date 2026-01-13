import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/app.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    _animationController.forward();
    
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Initialize app services
      await App.initialize();
      
      // Wait for animation to complete
      await Future.delayed(const Duration(milliseconds: 2000));
      
      if (mounted) {
        // Check authentication status and navigate accordingly
        final isAuthenticated = await App.isAuthenticated();
        
        if (isAuthenticated) {
          context.go('/dashboard');
        } else {
          context.go('/auth/login');
        }
      }
    } catch (e) {
      App.logger.e('Failed to initialize app: $e');
      if (mounted) {
        // Show error screen or retry logic
        _showErrorDialog();
      }
    }
  }
  
  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initialization Error'),
        content: const Text(
          'Failed to initialize the app. Please try again.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initializeApp();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App logo/icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.code,
                        size: 60,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // App name
                    Text(
                      App.appName,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // App version
                    Text(
                      'Version ${App.appVersion}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Loading indicator
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}