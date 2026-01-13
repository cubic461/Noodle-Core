import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../app.dart';

/// Performance monitoring utility for tracking app performance
class PerformanceMonitor {
  static final Logger _logger = App.logger;
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<int>> _metrics = {};
  static const int _maxMetricEntries = 100;
  
  /// Start timing an operation
  static String startTimer(String operation) {
    final id = '${operation}_${DateTime.now().millisecondsSinceEpoch}';
    _timers[id] = Stopwatch()..start();
    _logger.d('Started timer for: $operation (ID: $id)');
    return id;
  }
  
  /// End timing an operation and log the duration
  static int endTimer(String timerId, {String? operation, int? warningThresholdMs}) {
    final stopwatch = _timers.remove(timerId);
    if (stopwatch == null) {
      _logger.w('Timer not found: $timerId');
      return -1;
    }
    
    stopwatch.stop();
    final durationMs = stopwatch.elapsedMilliseconds;
    final opName = operation ?? timerId.split('_').sublist(0, timerId.split('_').length - 1).join('_');
    
    // Record metric
    _recordMetric(opName, durationMs);
    
    // Log with warning if threshold is exceeded
    if (warningThresholdMs != null && durationMs > warningThresholdMs) {
      _logger.w('Performance warning: $opName took ${durationMs}ms (threshold: ${warningThresholdMs}ms)');
    } else {
      _logger.d('$opName completed in ${durationMs}ms');
    }
    
    return durationMs;
  }
  
  /// Measure and log memory usage
  static void logMemoryUsage({String? context}) {
    if (!kIsWeb) {
      // In a real implementation, you would use platform-specific APIs
      // to get actual memory usage. For now, we'll just log a placeholder.
      _logger.d('Memory usage check${context != null ? ' for $context' : ''}');
      
      // In a production app, you might use:
      // - Android: Debug.getNativeHeapAllocatedSize()
      // - iOS: mach_task_basic_info
      // - Web: performance.memory
    }
  }
  
  /// Get performance metrics for an operation
  static Map<String, dynamic> getMetrics(String operation) {
    final values = _metrics[operation] ?? [];
    if (values.isEmpty) {
      return {};
    }
    
    values.sort();
    final count = values.length;
    final sum = values.reduce((a, b) => a + b);
    final avg = sum / count;
    final median = count % 2 == 0 
        ? (values[count ~/ 2 - 1] + values[count ~/ 2]) / 2 
        : values[count ~/ 2].toDouble();
    
    return {
      'operation': operation,
      'count': count,
      'averageMs': avg.toStringAsFixed(2),
      'medianMs': median.toStringAsFixed(2),
      'minMs': values.first,
      'maxMs': values.last,
      'totalMs': sum,
    };
  }
  
  /// Get all performance metrics
  static Map<String, Map<String, dynamic>> getAllMetrics() {
    final result = <String, Map<String, dynamic>>{};
    for (final operation in _metrics.keys) {
      result[operation] = getMetrics(operation);
    }
    return result;
  }
  
  /// Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _logger.d('Performance metrics cleared');
  }
  
  /// Record a metric value
  static void _recordMetric(String operation, int value) {
    if (!_metrics.containsKey(operation)) {
      _metrics[operation] = [];
    }
    
    _metrics[operation]!.add(value);
    
    // Keep only the most recent entries
    if (_metrics[operation]!.length > _maxMetricEntries) {
      _metrics[operation]!.removeRange(0, _metrics[operation]!.length - _maxMetricEntries);
    }
  }
}

/// Utility class to measure performance of functions
class PerformanceMeasure {
  final String operation;
  final int? warningThresholdMs;
  final String? context;
  
  const PerformanceMeasure(
    this.operation, {
    this.warningThresholdMs,
    this.context,
  });
  
  /// Measure the execution time of a function
  T measure<T>(T Function() function) {
    final timerId = PerformanceMonitor.startTimer(operation);
    try {
      final result = function();
      PerformanceMonitor.endTimer(
        timerId,
        operation: context != null ? '$context: $operation' : operation,
        warningThresholdMs: warningThresholdMs,
      );
      return result;
    } catch (e) {
      PerformanceMonitor.endTimer(timerId);
      rethrow;
    }
  }
  
  /// Measure the execution time of an async function
  Future<T> measureAsync<T>(Future<T> Function() function) async {
    final timerId = PerformanceMonitor.startTimer(operation);
    try {
      final result = await function();
      PerformanceMonitor.endTimer(
        timerId,
        operation: context != null ? '$context: $operation' : operation,
        warningThresholdMs: warningThresholdMs,
      );
      return result;
    } catch (e) {
      PerformanceMonitor.endTimer(timerId);
      rethrow;
    }
  }
}

/// Extension to add performance measurement to functions
extension PerformanceFunctionExtension<T> on T Function() {
  /// Measure execution time of this function
  T measureWithPerformance(
    String operation, {
    int? warningThresholdMs,
    String? context,
  }) {
    return PerformanceMeasure(
      operation,
      warningThresholdMs: warningThresholdMs,
      context: context,
    ).measure(this);
  }
}

/// Extension to add performance measurement to async functions
extension AsyncPerformanceFunctionExtension<T> on Future<T> Function() {
  /// Measure execution time of this async function
  Future<T> measureWithPerformance(
    String operation, {
    int? warningThresholdMs,
    String? context,
  }) {
    return PerformanceMeasure(
      operation,
      warningThresholdMs: warningThresholdMs,
      context: context,
    ).measureAsync(this);
  }
}

/// Widget for performance monitoring in debug mode
class PerformanceOverlay extends StatefulWidget {
  final Widget child;
  final bool enabled;
  
  const PerformanceOverlay({
    super.key,
    required this.child,
    this.enabled = kDebugMode,
  });

  @override
  State<PerformanceOverlay> createState() => _PerformanceOverlayState();
}

class _PerformanceOverlayState extends State<PerformanceOverlay> 
    with WidgetsBindingObserver {
  int _frameCount = 0;
  Stopwatch _fpsTimer = Stopwatch()..start();
  double _currentFps = 0.0;
  bool _isVisible = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      WidgetsBinding.instance.addObserver(this);
    }
  }
  
  @override
  void dispose() {
    if (widget.enabled) {
      WidgetsBinding.instance.removeObserver(this);
    }
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Reset metrics when app becomes visible again
    if (state == AppLifecycleState.resumed) {
      _frameCount = 0;
      _fpsTimer.reset();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || !_isVisible) {
      return widget.child;
    }
    
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 50,
          left: 10,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'FPS: ${_currentFps.toStringAsFixed(1)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ),
        Positioned(
          top: 80,
          left: 10,
          child: GestureDetector(
            onTap: () => setState(() => _isVisible = !_isVisible),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Hide',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  @override
  void performReassemble() {
    super.performReassemble();
    _updateFps();
  }
  
  void _updateFps() {
    _frameCount++;
    
    if (_fpsTimer.elapsedMilliseconds >= 1000) {
      setState(() {
        _currentFps = _frameCount * 1000.0 / _fpsTimer.elapsedMilliseconds;
        _frameCount = 0;
        _fpsTimer.reset();
      });
    }
    
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _updateFps());
    }
  }
}