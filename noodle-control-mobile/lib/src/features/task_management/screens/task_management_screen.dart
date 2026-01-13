import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/app.dart';

class TaskManagementScreen extends ConsumerStatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  ConsumerState<TaskManagementScreen> createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends ConsumerState<TaskManagementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _tasks = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedNodeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual data loading
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock tasks data
      _tasks = [
        Task(
          id: 'task_1',
          title: 'Code Analysis',
          description: 'Analyze Python code for optimization opportunities',
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
        Task(
          id: 'task_3',
          title: 'Data Processing',
          description: 'Process and clean dataset',
          nodeId: 'node_2',
          status: TaskStatus.pending,
          progress: 0,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          updatedAt: DateTime.now(),
        ),
        Task(
          id: 'task_4',
          title: 'Image Recognition',
          description: 'Run image recognition model',
          nodeId: 'node_3',
          status: TaskStatus.failed,
          progress: 25,
          startedAt: DateTime.now().subtract(const Duration(hours: 1)),
          errorMessage: 'GPU memory insufficient',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          updatedAt: DateTime.now(),
        ),
      ];
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      App.logger.e('Failed to load tasks: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<Task> get _filteredTasks {
    var filtered = _tasks;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((task) =>
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (task.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false)
      ).toList();
    }
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'running':
        filtered = filtered.where((task) => task.status == TaskStatus.running).toList();
        break;
      case 'completed':
        filtered = filtered.where((task) => task.status == TaskStatus.completed).toList();
        break;
      case 'failed':
        filtered = filtered.where((task) => task.status == TaskStatus.failed).toList();
        break;
      case 'pending':
        filtered = filtered.where((task) => task.status == TaskStatus.pending).toList();
        break;
    }
    
    // Apply node filter
    if (_selectedNodeFilter != 'all') {
      filtered = filtered.where((task) => task.nodeId == _selectedNodeFilter).toList();
    }
    
    // Sort by creation date (newest first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return filtered;
  }

  void _cancelTask(Task task) async {
    try {
      // TODO: Implement actual task cancellation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cancelling task: ${task.title}'),
          duration: const Duration(seconds: 2),
        ),
      );
      await _loadTasks(); // Refresh the list
    } catch (e) {
      App.logger.e('Failed to cancel task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel task: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _retryTask(Task task) async {
    try {
      // TODO: Implement actual task retry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Retrying task: ${task.title}'),
          duration: const Duration(seconds: 2),
        ),
      );
      await _loadTasks(); // Refresh the list
    } catch (e) {
      App.logger.e('Failed to retry task: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry task: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showTaskDetails(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => _TaskDetailsSheet(
          task: task,
          scrollController: scrollController,
          onCancel: () => _cancelTask(task),
          onRetry: () => _retryTask(task),
        ),
      ),
    );
  }

  void _showNewTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Task'),
        content: const Text('Task creation will be implemented in a future version.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoodleAppBar(
        title: 'Task Management',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadTasks,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showNewTaskDialog,
            tooltip: 'New Task',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading tasks...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadTasks,
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
                            hintText: 'Search tasks...',
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
                          
                          // Status filter chips
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
                                  label: const Text('Completed'),
                                  selected: _selectedFilter == 'completed',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'completed';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Failed'),
                                  selected: _selectedFilter == 'failed',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'failed';
                                    });
                                  },
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Pending'),
                                  selected: _selectedFilter == 'pending',
                                  onSelected: (selected) {
                                    setState(() {
                                      _selectedFilter = 'pending';
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Tasks list
                    Expanded(
                      child: _filteredTasks.isEmpty
                          ? EmptyState(
                              title: 'No tasks found',
                              subtitle: _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                  ? 'Try adjusting your search or filter'
                                  : 'No tasks available. Create a new task to get started.',
                              icon: Icons.task_alt,
                              action: _searchQuery.isEmpty && _selectedFilter == 'all'
                                  ? ActionButton(
                                      label: 'New Task',
                                      icon: Icons.add,
                                      onPressed: _showNewTaskDialog,
                                    )
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadTasks,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _filteredTasks.length,
                                itemBuilder: (context, index) {
                                  final task = _filteredTasks[index];
                                  return _TaskCard(
                                    task: task,
                                    onTap: () => _showTaskDetails(task),
                                    onCancel: () => _cancelTask(task),
                                    onRetry: () => _retryTask(task),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const _TaskCard({
    required this.task,
    required this.onTap,
    required this.onCancel,
    required this.onRetry,
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
                  // Status icon
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(task.status),
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                task.title,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusChip(
                              label: task.status.name.toUpperCase(),
                              color: _getStatusColor(task.status).withOpacity(0.2),
                              textColor: _getStatusColor(task.status),
                            ),
                          ],
                        ),
                        
                        if (task.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        
                        const SizedBox(height: 8),
                        
                        Row(
                          children: [
                            Icon(
                              Icons.device_hub,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Node: ${task.nodeId}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Icon(
                              Icons.schedule,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDateTime(task.createdAt),
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
              
              // Progress bar
              if (task.status == TaskStatus.running && task.progress != null) ...[
                Row(
                  children: [
                    Text(
                      'Progress: ${task.progress}%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: (task.progress ?? 0) / 100,
                        backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Error message
              if (task.status == TaskStatus.failed && task.errorMessage != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          task.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (task.status == TaskStatus.running) ...[
                    OutlinedButton(
                      onPressed: onCancel,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                        side: BorderSide(color: Theme.of(context).colorScheme.error),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ] else if (task.status == TaskStatus.failed) ...[
                    OutlinedButton(
                      onPressed: onRetry,
                      child: const Text('Retry'),
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

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.running:
        return Colors.blue;
      case TaskStatus.completed:
        return Colors.green;
      case TaskStatus.failed:
        return Colors.red;
      case TaskStatus.cancelled:
        return Colors.orange;
      case TaskStatus.pending:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

class _TaskDetailsSheet extends StatelessWidget {
  final Task task;
  final ScrollController scrollController;
  final VoidCallback onCancel;
  final VoidCallback onRetry;

  const _TaskDetailsSheet({
    required this.task,
    required this.scrollController,
    required this.onCancel,
    required this.onRetry,
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
                  color: _TaskCard(
                    task: task,
                    onTap: () {},
                    onCancel: () {},
                    onRetry: () {},
                  )._getStatusColor(task.status),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.title,
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
                          value: task.status.name.toUpperCase(),
                          valueColor: _TaskCard(
                            task: task,
                            onTap: () {},
                            onCancel: () {},
                            onRetry: () {},
                          )._getStatusColor(task.status),
                        ),
                        if (task.progress != null)
                          _DetailItem(
                            label: 'Progress',
                            value: '${task.progress}%',
                          ),
                        _DetailItem(
                          label: 'Created',
                          value: _formatDateTime(task.createdAt),
                        ),
                        if (task.startedAt != null)
                          _DetailItem(
                            label: 'Started',
                            value: _formatDateTime(task.startedAt!),
                          ),
                        if (task.completedAt != null)
                          _DetailItem(
                            label: 'Completed',
                            value: _formatDateTime(task.completedAt!),
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
                          label: 'Node ID',
                          value: task.nodeId,
                        ),
                        if (task.description != null)
                          _DetailItem(
                            label: 'Description',
                            value: task.description!,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Error section
                  if (task.status == TaskStatus.failed && task.errorMessage != null)
                    _DetailSection(
                      title: 'Error',
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          task.errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Actions section
                  _DetailSection(
                    title: 'Actions',
                    child: Column(
                      children: [
                        if (task.status == TaskStatus.running) ...[
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: onCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Theme.of(context).colorScheme.error,
                                side: BorderSide(color: Theme.of(context).colorScheme.error),
                              ),
                              child: const Text('Cancel Task'),
                            ),
                          ),
                        ] else if (task.status == TaskStatus.failed) ...[
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: onRetry,
                              child: const Text('Retry Task'),
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