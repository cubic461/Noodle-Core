import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/service_provider.dart';
import '../../shared/models/models.dart';

/// Connection status indicator widget
class ConnectionStatusIndicator extends ConsumerWidget {
  final bool showLabel;
  final double? size;
  final VoidCallback? onTap;

  const ConnectionStatusIndicator({
    super.key,
    this.showLabel = true,
    this.size,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionStatus = ref.watch(
      connectionServiceProvider.select((service) => service.status),
    );

    final lastError = ref.watch(
      connectionServiceProvider.select((service) => service.lastError),
    );

    final lastConnectedTime = ref.watch(
      connectionServiceProvider.select((service) => service.lastConnectedTime),
    );

    final color = _getStatusColor(connectionStatus);
    final icon = _getStatusIcon(connectionStatus);
    final label = _getStatusLabel(connectionStatus);

    Widget indicator = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: color,
          size: size ?? 16,
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: size != null ? size! * 0.75 : 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      indicator = InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: indicator,
      );
    }

    return Tooltip(
      message: _getTooltipMessage(connectionStatus, lastError, lastConnectedTime),
      child: indicator,
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Icons.wifi_find;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.error:
        return Icons.error_outline;
    }
  }

  String _getStatusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  String _getTooltipMessage(
    ConnectionStatus status,
    String lastError,
    DateTime? lastConnectedTime,
  ) {
    switch (status) {
      case ConnectionStatus.connected:
        if (lastConnectedTime != null) {
          final timeDiff = DateTime.now().difference(lastConnectedTime);
          return 'Connected for ${_formatDuration(timeDiff)}';
        }
        return 'Connected to server';
      case ConnectionStatus.connecting:
        return 'Connecting to server...';
      case ConnectionStatus.reconnecting:
        return 'Attempting to reconnect...';
      case ConnectionStatus.disconnected:
        return 'Disconnected from server';
      case ConnectionStatus.error:
        return lastError.isNotEmpty ? lastError : 'Connection error';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}

/// Connection status indicator with animation
class AnimatedConnectionStatusIndicator extends ConsumerStatefulWidget {
  final bool showLabel;
  final double? size;
  final VoidCallback? onTap;

  const AnimatedConnectionStatusIndicator({
    super.key,
    this.showLabel = true,
    this.size,
    this.onTap,
  });

  @override
  ConsumerState<AnimatedConnectionStatusIndicator> createState() =>
      _AnimatedConnectionStatusIndicatorState();
}

class _AnimatedConnectionStatusIndicatorState
    extends ConsumerState<AnimatedConnectionStatusIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final connectionStatus = ref.watch(
      connectionServiceProvider.select((service) => service.status),
    );

    final shouldAnimate = connectionStatus == ConnectionStatus.connecting ||
        connectionStatus == ConnectionStatus.reconnecting;

    Widget child = ConnectionStatusIndicator(
      showLabel: widget.showLabel,
      size: widget.size,
      onTap: widget.onTap,
    );

    if (shouldAnimate) {
      child = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: child,
          );
        },
        child: child,
      );
    }

    return child;
  }
}

/// Connection status dialog
class ConnectionStatusDialog extends ConsumerWidget {
  const ConnectionStatusDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionService = ref.watch(connectionServiceProvider);
    final connectionStatus = connectionService.status;
    final lastError = connectionService.lastError;
    final lastConnectedTime = connectionService.lastConnectedTime;

    return AlertDialog(
      title: const Text('Connection Status'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(connectionStatus),
                color: _getStatusColor(connectionStatus),
              ),
              const SizedBox(width: 12),
              Text(
                _getStatusLabel(connectionStatus),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(connectionStatus),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (connectionStatus == ConnectionStatus.connected &&
              lastConnectedTime != null) ...[
            Text(
              'Connected for: ${_formatDuration(DateTime.now().difference(lastConnectedTime))}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (lastError.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Last Error:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                lastError,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          const SizedBox(height: 16),
          if (connectionStatus != ConnectionStatus.connected) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await connectionService.reconnect();
                  } catch (e) {
                    // Error will be handled by connection status stream
                  }
                },
                child: const Text('Reconnect'),
              ),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Color _getStatusColor(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Colors.green;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Colors.orange;
      case ConnectionStatus.disconnected:
        return Colors.grey;
      case ConnectionStatus.error:
        return Colors.red;
    }
  }

  IconData _getStatusIcon(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return Icons.wifi;
      case ConnectionStatus.connecting:
      case ConnectionStatus.reconnecting:
        return Icons.wifi_find;
      case ConnectionStatus.disconnected:
        return Icons.wifi_off;
      case ConnectionStatus.error:
        return Icons.error_outline;
    }
  }

  String _getStatusLabel(ConnectionStatus status) {
    switch (status) {
      case ConnectionStatus.connected:
        return 'Connected';
      case ConnectionStatus.connecting:
        return 'Connecting';
      case ConnectionStatus.reconnecting:
        return 'Reconnecting';
      case ConnectionStatus.disconnected:
        return 'Disconnected';
      case ConnectionStatus.error:
        return 'Error';
    }
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes}m ${duration.inSeconds % 60}s';
    } else {
      return '${duration.inSeconds}s';
    }
  }
}