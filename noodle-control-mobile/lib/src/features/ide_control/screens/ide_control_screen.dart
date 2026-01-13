import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/app.dart';

class IdeControlScreen extends ConsumerStatefulWidget {
  const IdeControlScreen({super.key});

  @override
  ConsumerState<IdeControlScreen> createState() => _IdeControlScreenState();
}

class _IdeControlScreenState extends ConsumerState<IdeControlScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<IdeProject> _projects = [];
  String _searchQuery = '';
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual data loading
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock projects data
      _projects = [
        IdeProject(
          id: 'project_1',
          name: 'Noodle AI Core',
          description: 'Core AI processing engine',
          path: '/home/user/projects/noodle-ai-core',
          language: 'Python',
          isOpen: true,
          lastAccessed: DateTime.now().subtract(const Duration(hours: 2)),
          createdAt: DateTime.now().subtract(const Duration(days: 30)),
          updatedAt: DateTime.now(),
        ),
        IdeProject(
          id: 'project_2',
          name: 'Mobile App',
          description: 'Flutter mobile application',
          path: '/home/user/projects/noodle-mobile',
          language: 'Dart',
          isOpen: false,
          lastAccessed: DateTime.now().subtract(const Duration(days: 1)),
          createdAt: DateTime.now().subtract(const Duration(days: 60)),
          updatedAt: DateTime.now(),
        ),
        IdeProject(
          id: 'project_3',
          name: 'Web Dashboard',
          description: 'React web dashboard',
          path: '/home/user/projects/noodle-web',
          language: 'JavaScript',
          isOpen: true,
          lastAccessed: DateTime.now().subtract(const Duration(minutes: 30)),
          createdAt: DateTime.now().subtract(const Duration(days: 45)),
          updatedAt: DateTime.now(),
        ),
      ];
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      App.logger.e('Failed to load projects: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<IdeProject> get _filteredProjects {
    var filtered = _projects;
    
    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((project) =>
          project.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (project.description?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          project.language.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }
    
    // Apply status filter
    switch (_selectedFilter) {
      case 'open':
        filtered = filtered.where((project) => project.isOpen).toList();
        break;
      case 'closed':
        filtered = filtered.where((project) => !project.isOpen).toList();
        break;
    }
    
    // Sort by last accessed (most recent first)
    filtered.sort((a, b) => b.lastAccessed.compareTo(a.lastAccessed));
    
    return filtered;
  }

  void _openProject(IdeProject project) {
    // TODO: Implement actual project opening
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening project: ${project.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _closeProject(IdeProject project) {
    // TODO: Implement actual project closing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Closing project: ${project.name}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showNewProjectDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Project'),
        content: const Text('New project creation will be implemented in a future version.'),
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
        title: 'IDE Control',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProjects,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showNewProjectDialog,
            tooltip: 'New Project',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading projects...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadProjects,
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
                            hintText: 'Search projects...',
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
                          Row(
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
                                label: const Text('Open'),
                                selected: _selectedFilter == 'open',
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = 'open';
                                  });
                                },
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Closed'),
                                selected: _selectedFilter == 'closed',
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedFilter = 'closed';
                                  });
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Projects list
                    Expanded(
                      child: _filteredProjects.isEmpty
                          ? EmptyState(
                              title: 'No projects found',
                              subtitle: _searchQuery.isNotEmpty || _selectedFilter != 'all'
                                  ? 'Try adjusting your search or filter'
                                  : 'No projects available. Create a new project to get started.',
                              icon: Icons.folder_open,
                              action: _searchQuery.isEmpty && _selectedFilter == 'all'
                                  ? ActionButton(
                                      label: 'New Project',
                                      icon: Icons.add,
                                      onPressed: _showNewProjectDialog,
                                    )
                                  : null,
                            )
                          : RefreshIndicator(
                              onRefresh: _loadProjects,
                              child: ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                itemCount: _filteredProjects.length,
                                itemBuilder: (context, index) {
                                  final project = _filteredProjects[index];
                                  return _ProjectCard(
                                    project: project,
                                    onOpen: () => _openProject(project),
                                    onClose: () => _closeProject(project),
                                  );
                                },
                              ),
                            ),
                    ),
                  ],
                ),
      bottomNavigationBar: NoodleBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) {
          if (index != 1) {
            switch (index) {
              case 0:
                context.go('/dashboard');
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
        },
      ),
    );
  }
}

class _ProjectCard extends StatelessWidget {
  final IdeProject project;
  final VoidCallback onOpen;
  final VoidCallback onClose;

  const _ProjectCard({
    required this.project,
    required this.onOpen,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: project.isOpen ? null : onOpen,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Language icon
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _getLanguageColor(project.language).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getLanguageIcon(project.language),
                      color: _getLanguageColor(project.language),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Project info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                project.name,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            StatusChip(
                              label: project.isOpen ? 'OPEN' : 'CLOSED',
                              color: project.isOpen
                                  ? Theme.of(context).colorScheme.primaryContainer
                                  : Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ],
                        ),
                        
                        if (project.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            project.description!,
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
                              Icons.code,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              project.language,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                            
                            const SizedBox(width: 16),
                            
                            Icon(
                              Icons.access_time,
                              size: 16,
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatLastAccessed(project.lastAccessed),
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
              
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (project.isOpen) ...[
                    OutlinedButton(
                      onPressed: onClose,
                      child: const Text('Close'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        // TODO: Navigate to project details
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Opening project details: ${project.name}'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      child: const Text('Open in IDE'),
                    ),
                  ] else ...[
                    FilledButton(
                      onPressed: onOpen,
                      child: const Text('Open'),
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

  IconData _getLanguageIcon(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Icons.code;
      case 'dart':
        return Icons.flutter_dash;
      case 'javascript':
      case 'typescript':
        return Icons.javascript;
      case 'java':
        return Icons.coffee;
      case 'c++':
      case 'c':
        return Icons.memory;
      default:
        return Icons.code;
    }
  }

  Color _getLanguageColor(String language) {
    switch (language.toLowerCase()) {
      case 'python':
        return Colors.blue;
      case 'dart':
        return Colors.blue;
      case 'javascript':
      case 'typescript':
        return Colors.yellow;
      case 'java':
        return Colors.orange;
      case 'c++':
      case 'c':
        return Colors.blueGrey;
      default:
        return Theme.of(context).colorScheme.primary;
    }
  }

  String _formatLastAccessed(DateTime lastAccessed) {
    final now = DateTime.now();
    final difference = now.difference(lastAccessed);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${lastAccessed.day}/${lastAccessed.month}/${lastAccessed.year}';
    }
  }
}