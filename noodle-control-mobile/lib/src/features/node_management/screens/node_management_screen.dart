import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/app.dart';

class NodeManagementScreen extends ConsumerStatefulWidget {
  const NodeManagementScreen({super.key});

  @override
  ConsumerState<NodeManagementScreen> createState() => _NodeManagementScreenState();
}

class _NodeManagementScreenState extends ConsumerState<NodeManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Node> _nodes = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadNodes();
  }

  Future<void> _loadNodes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual data loading
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock nodes data
      _nodes = [
        Node(
          id: 'node_1',
          name: 'Primary Compute Node',
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
          name: 'Secondary Storage Node',
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
        Node(
          id: 'node_3',
          name: 'GPU Processing Node',
          type: 'gpu',
          status: NodeStatus.running,
          cpuUsage: 78.9,
          memoryUsage: 85.3,
          activeTasks: 2,
          totalTasks: 12,
          ipAddress: '192.168.1.102',
          port: 8080,
          lastHeartbeat: DateTime.now().subtract(const Duration(seconds: 30)),
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
          updatedAt: DateTime.now(),
        ),
        Node(
          id: 'node_4',
          name: 'Development Node',
          type: 'development',
          status: NodeStatus.error,
          cpuUsage: 0.0,
          memoryUsage: 0.0,
          activeTasks: 0,
          totalTasks: 3,
          ipAddress: '192.168.1.103',
          port: 8080,
          lastHeartbeat: DateTime.now().subtract(const Duration(hours: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
          updatedAt: DateTime.now(),
        ),
      ];
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      App.logger.e('Failed to load nodes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<Node> get _filteredNodes {
    var filtered = _nodes;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((node) =>
          node.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          node.type.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          node.ipAddress.contains(_searchQuery)
      ).toList();
    }
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'running':
        filtered = filtered.where((node) => node.status == NodeStatus.running).toList();
        break;
      case 'idle':
        filtered = filtered.where((node) => node.status == NodeStatus.idle).toList();
        break;
      case 'error':
        filtered = filtered.where((node) => node.status == NodeStatus.error).toList();
        break;
    }
    
    // Sort by name
    filtered.sort((a, b) => a.name.compareTo(b.name));
    
    return filtered;
  }

  void _startNode(Node node) async {
    try {
      // TODO: Implement actual node start
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Starting node: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      await _loadNodes(); // Refresh the list
    } catch (e) {
      App.logger.e('Failed to start node: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start node: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _stopNode(Node node) async {
    try {
      // TODO: Implement actual node stop
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stopping node: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      await _loadNodes(); // Refresh the list
    } catch (e) {
      App.logger.e('Failed to stop node: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to stop node: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _restartNode(Node node) async {
    try {
      // TODO: Implement actual node restart
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Restarting node: ${node.name}'),
          duration: const Duration(seconds: 2),
        ),
      );
      await _loadNodes(); // Refresh the list
    } catch (e) {
      App.logger.e('Failed to restart node: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restart node: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showAddNodeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Node'),
        content: const Text('Node addition will be implemented in a future version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNodeDetails(Node node) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _NodeDetailsSheet(
          node: node,
          scrollController: scrollController,
          onStart: () => _startNode(node),
          onStop: () => _stopNode(node),
          onRestart: () => _restartNode(node),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoodleAppBar(
        title: 'Node Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNodes,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddNodeDialog,
            tooltip: 'Add Node',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading nodes...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadNodes,
                )
              : Column(
                  children: [
                    // Search and filter bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          // Search bar
                          SearchBar(
                            hintText: 'Search nodes...',
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value;
                              });
                            },
                            onClear: () {
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Filter chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedFilter == 'all',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'all';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Running'),
                                  selected: _selectedFilter == 'running',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'running';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Idle'),
                                  selected: _selectedFilter == 'idle',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'idle';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Error'),
                                  selected: _selectedFilter == 'error',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'error';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Nodes list
                    Expanded(
                      child: _filteredNodes.isEmpty
                          ? EmptyState(
                              title: 'No nodes found',
                              subtitle: _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                  ? 'Try adjusting your search or filter'
                                  : 'No nodes available. Add a new node to get started.',
                              icon: Icons.devices,
                              action: _searchQuery.isEmpty && _selectedFilter == 'all'
                                  ? ActionButton(
                                      label: 'Add Node',
                                      icon: Icons.add,
                                      onPressed: _showAddNodeDialog,
                                    )
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadNodes,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _filteredNodes.length,
                                itemBuilder: (context, index) {
                                  final node = _filteredNodes[index];
                                  return _NodeCard(
                                    node: node,
                                    onTap: () => _showNodeDetails(node),
                                    onStart: () => _startNode(node),
                                    onStop: () => _stopNode(node),
                                    onRestart: () => _restartNode(node),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: NoodleBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/ide-control');
                break;
              case 3:
                context.go('/reasoning-monitoring');
                break;
              case 4:
                context.go('/settings');
                break;
            }
          }
        },
      ),
    );
  }
}

class _NodeCard extends StatelessWidget {
  final Node node;
  final VoidCallback onTap;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;

  const _NodeCard({
    required this.node,
    required this.onTap,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Status indicator
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(node.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Node info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                node.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusChip(
                              label: node.status.name.toUpperCase(),
                              color: _getStatusColor(node.status).withOpacity(0.2),
                              textColor: _getStatusColor(node.status),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        Row(
                          children: [
                            Icon(
                              _getTypeIcon(node.type),
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              node.type.toUpperCase(),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${node.ipAddress}:${node.port}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Resource usage
              if (node.status == NodeStatus.running) ...[
                Row(
                  children: [
                    Expanded(
                      child: _ResourceBar(
                        label: 'CPU',
                        value: node.cpuUsage ?? 0,
                        color: _getResourceColor(node.cpuUsage ?? 0),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ResourceBar(
                        label: 'Memory',
                        value: node.memoryUsage ?? 0,
                        color: _getResourceColor(node.memoryUsage ?? 0),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Tasks info
              Row(
                children: [
                  Icon(
                    Icons.task,
                    size: 16,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${node.activeTasks ?? 0}/${node.totalTasks ?? 0} tasks',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Action buttons
                  if (node.status == NodeStatus.running) ...[
                    IconButton(
                      icon: const Icon(Icons.restart_alt),
                      onPressed: onRestart,
                      tooltip: 'Restart',
                    ),
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: onStop,
                      tooltip: 'Stop',
                    ),
                  ] else if (node.status == NodeStatus.idle || node.status == NodeStatus.error) ...[
                    IconButton(
                      icon: const Icon(Icons.play_arrow),
                      onPressed: onStart,
                      tooltip: 'Start',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(NodeStatus status) {
    switch (status) {
      case NodeStatus.running:
        return Colors.green;
      case NodeStatus.idle:
        return Colors.orange;
      case NodeStatus.stopped:
        return Colors.grey;
      case NodeStatus.error:
        return Colors.red;
      case NodeStatus.maintenance:
        return Colors.purple;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'compute':
        return Icons.memory;
      case 'storage':
        return Icons.storage;
      case 'gpu':
        return Icons.gpu;
      case 'development':
        return Icons.code;
      default:
        return Icons.device_hub;
    }
  }

  Color _getResourceColor(double value) {
    if (value > 80) {
      return Colors.red;
    } else if (value > 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}

class _ResourceBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;

  const _ResourceBar({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${value.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: value / 100,
          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      ],
    );
  }
}

class _NodeDetailsSheet extends StatelessWidget {
  final Node node;
  final ScrollController scrollController;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onRestart;

  const _NodeDetailsSheet({
    required this.node,
    required this.scrollController,
    required this.onStart,
    required this.onStop,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Header
          Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _NodeCard(null, onTap: () {}, onStart: () {}, onStop: () {}, onRestart: () {})._getStatusColor(node.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  node.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Details
          Expanded(
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status section
                  _DetailSection(
                    title: 'Status',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailItem(
                          label: 'Status',
                          value: node.status.name.toUpperCase(),
                          valueColor: _NodeCard(null, onTap: () {}, onStart: () {}, onStop: () {}, onRestart: () {})._getStatusColor(node.status),
                        ),
                        _DetailItem(
                          label: 'Last Heartbeat',
                          value: _formatDateTime(node.lastHeartbeat),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Information section
                  _DetailSection(
                    title: 'Information',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _DetailItem(
                          label: 'Type',
                          value: node.type.toUpperCase(),
                        ),
                        _DetailItem(
                          label: 'IP Address',
                          value: '${node.ipAddress}:${node.port}',
                        ),
                        _DetailItem(
                          label: 'Created',
                          value: _formatDateTime(node.createdAt),
                        ),
                        _DetailItem(
                          label: 'Updated',
                          value: _formatDateTime(node.updatedAt),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Performance section
                  if (node.status == NodeStatus.running)
                    _DetailSection(
                      title: 'Performance',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _DetailItem(
                            label: 'CPU Usage',
                            value: '${node.cpuUsage?.toStringAsFixed(1) ?? '0.0'}%',
                          ),
                          _DetailItem(
                            label: 'Memory Usage',
                            value: '${node.memoryUsage?.toStringAsFixed(1) ?? '0.0'}%',
                          ),
                          _DetailItem(
                            label: 'Active Tasks',
                            value: '${node.activeTasks ?? 0}/${node.totalTasks ?? 0}',
                          ),
                        ],
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions section
                  _DetailSection(
                    title: 'Actions',
                    child: Column(
                      children: [
                        if (node.status == NodeStatus.running) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onRestart,
                              child: const Text('Restart Node'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onStop,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                                side: BorderSide(color: Theme.of(context).colorScheme.error),
                              ),
                              child: const Text('Stop Node'),
                            ),
                          ),
                        ] else if (node.status == NodeStatus.idle || node.status == NodeStatus.error) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: onStart,
                              child: const Text('Start Node'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailSection({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}