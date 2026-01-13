import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/app.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  
  // Mock data for demonstration
  final List<Node> _nodes = [
    Node(
      id: 'node_1',
      name: 'Primary Node',
      type: 'compute',
      status: NodeStatus.running,
      cpuUsage: 45.2,
      memoryUsage: 62.8,
      activeTasks: 3,
      totalTasks: 8,
      ipAddress: '192.168.1.100',
      port: 8080,
      lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 2)),
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    ),
    Node(
      id: 'node_2',
      name: 'Secondary Node',
      type: 'storage',
      status: NodeStatus.idle,
      cpuUsage: 12.5,
      memoryUsage: 34.2,
      activeTasks: 0,
      totalTasks: 5,
      ipAddress: '192.168.1.101',
      port: 8080,
      lastHeartbeat: DateTime.now().subtract(const Duration(minutes: 1)),
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now(),
    ),
  ];
  
  final List<Task> _recentTasks = [
    Task(
      id: 'task_1',
      title: 'Code Analysis',
      description: 'Analyze Python code for optimization',
      nodeId: 'node_1',
      status: TaskStatus.completed,
      progress: 100,
      startedAt: DateTime.now().subtract(const Duration(hours: 2)),
      completedAt: DateTime.now().subtract(const Duration(hours: 1)),
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      updatedAt: DateTime.now(),
    ),
    Task(
      id: 'task_2',
      title: 'Model Training',
      description: 'Train ML model on dataset',
      nodeId: 'node_1',
      status: TaskStatus.running,
      progress: 65,
      startedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
      updatedAt: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual data loading
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      App.logger.e('Failed to load dashboard data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Navigate to the selected screen
    switch (index) {
      case 0:
        // Already on dashboard
        break;
      case 1:
        context.go('/ide-control');
        break;
      case 2:
        context.go('/node-management');
        break;
      case 3:
        context.go('/reasoning-monitoring');
        break;
      case 4:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoodleAppBar(
        title: 'Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh',
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'logout':
                  _handleLogout();
                  break;
                case 'about':
                  _showAboutDialog();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'about',
                child: Row(
                  children: [
                    Icon(Icons.info_outline),
                    SizedBox(width: 8),
                    Text('About'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading dashboard...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadDashboardData,
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome section
                        Text(
                          'Welcome to NoodleControl',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage your AI development environment',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Status cards
                        Row(
                          children: [
                            Expanded(
                              child: StatusCard(
                                title: 'Active Nodes',
                                value: '${_nodes.where((n) => n.status == NodeStatus.running).length}/${_nodes.length}',
                                icon: Icons.devices,
                                color: Theme.of(context).colorScheme.primary,
                                onTap: () => context.go('/node-management'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatusCard(
                                title: 'Running Tasks',
                                value: '${_recentTasks.where((t) => t.status == TaskStatus.running).length}',
                                icon: Icons.play_circle,
                                color: Theme.of(context).colorScheme.secondary,
                                onTap: () => context.go('/reasoning-monitoring'),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: StatusCard(
                                title: 'CPU Usage',
                                value: '${_nodes.isEmpty ? 0 : (_nodes.map((n) => n.cpuUsage ?? 0).reduce((a, b) => a + b) / _nodes.length).toStringAsFixed(1)}%',
                                icon: Icons.memory,
                                color: _nodes.isEmpty 
                                    ? Theme.of(context).colorScheme.outline
                                    : _nodes.map((n) => n.cpuUsage ?? 0).reduce((a, b) => a + b) / _nodes.length > 80
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: StatusCard(
                                title: 'Memory Usage',
                                value: '${_nodes.isEmpty ? 0 : (_nodes.map((n) => n.memoryUsage ?? 0).reduce((a, b) => a + b) / _nodes.length).toStringAsFixed(1)}%',
                                icon: Icons.storage,
                                color: _nodes.isEmpty 
                                    ? Theme.of(context).colorScheme.outline
                                    : _nodes.map((n) => n.memoryUsage ?? 0).reduce((a, b) => a + b) / _nodes.length > 80
                                        ? Theme.of(context).colorScheme.error
                                        : Theme.of(context).colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Quick actions
                        Text(
                          'Quick Actions',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            _QuickActionCard(
                              title: 'IDE Control',
                              icon: Icons.code,
                              color: Theme.of(context).colorScheme.primary,
                              onTap: () => context.go('/ide-control'),
                            ),
                            _QuickActionCard(
                              title: 'Node Management',
                              icon: Icons.devices,
                              color: Theme.of(context).colorScheme.secondary,
                              onTap: () => context.go('/node-management'),
                            ),
                            _QuickActionCard(
                              title: 'Monitoring',
                              icon: Icons.analytics,
                              color: Theme.of(context).colorScheme.tertiary,
                              onTap: () => context.go('/reasoning-monitoring'),
                            ),
                            _QuickActionCard(
                              title: 'Settings',
                              icon: Icons.settings,
                              color: Theme.of(context).colorScheme.outline,
                              onTap: () => context.go('/settings'),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Recent tasks
                        Text(
                          'Recent Tasks',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_recentTasks.isEmpty)
                          const EmptyState(
                            title: 'No recent tasks',
                            subtitle: 'Tasks will appear here when they are created',
                            icon: Icons.task_alt,
                          )
                        else
                          ..._recentTasks.map((task) => _TaskCard(task: task)),
                        
                        const SizedBox(height: 24),
                        
                        // Active nodes
                        Text(
                          'Active Nodes',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_nodes.isEmpty)
                          const EmptyState(
                            title: 'No nodes available',
                            subtitle: 'Nodes will appear here when they are connected',
                            icon: Icons.devices,
                          )
                        else
                          ..._nodes.map((node) => _NodeCard(node: node)),
                        
                        const SizedBox(height: 100), // Extra space for bottom navigation
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: NoodleBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await App.clearAllData();
      if (mounted) {
        context.go('/auth/login');
      }
    } catch (e) {
      App.logger.e('Logout failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: App.appName,
      applicationVersion: App.appVersion,
      applicationIcon: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.code,
          size: 24,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      ),
      children: [
        const Text('Mobile app for managing Noodle AI development environment.'),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;

  const _TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          task.status == TaskStatus.running
              ? Icons.play_circle
              : task.status == TaskStatus.completed
                  ? Icons.check_circle
                  : Icons.error,
          color: task.status == TaskStatus.running
              ? Theme.of(context).colorScheme.primary
              : task.status == TaskStatus.completed
                  ? Theme.of(context).colorScheme.tertiary
                  : Theme.of(context).colorScheme.error,
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            const SizedBox(height: 4),
            Row(
              children: [
                StatusChip(
                  label: task.status.name.toUpperCase(),
                  color: task.status == TaskStatus.running
                      ? Theme.of(context).colorScheme.primaryContainer
                      : task.status == TaskStatus.completed
                          ? Theme.of(context).colorScheme.tertiaryContainer
                          : Theme.of(context).colorScheme.errorContainer,
                ),
                const SizedBox(width: 8),
                if (task.progress != null) Text('${task.progress}%'),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          // TODO: Navigate to task details
        },
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final Node node;

  const _NodeCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          node.status == NodeStatus.running
              ? Icons.circle
              : node.status == NodeStatus.idle
                  ? Icons.pause_circle
                  : Icons.error,
          color: node.status == NodeStatus.running
              ? Colors.green
              : node.status == NodeStatus.idle
                  ? Colors.orange
                  : Colors.red,
          size: 16,
        ),
        title: Text(node.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${node.type} • ${node.ipAddress}:${node.port}'),
            const SizedBox(height: 4),
            if (node.cpuUsage != null && node.memoryUsage != null)
              Row(
                children: [
                  Text('CPU: ${node.cpuUsage}%', style: Theme.of(context).textTheme.bodySmall),
                  const SizedBox(width: 16),
                  Text('Memory: ${node.memoryUsage}%', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
          ],
        ),
        trailing: Text(
          '${node.activeTasks ?? 0}/${node.totalTasks ?? 0}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        onTap: () {
          // TODO: Navigate to node details
        },
      ),
    );
  }
}