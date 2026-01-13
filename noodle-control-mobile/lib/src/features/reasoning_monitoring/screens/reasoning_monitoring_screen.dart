import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../shared/widgets/common_widgets.dart';
import '../../../shared/models/models.dart';
import '../../../core/app.dart';

class ReasoningMonitoringScreen extends ConsumerStatefulWidget {
  const ReasoningMonitoringScreen({super.key});

  @override
  ConsumerState<ReasoningMonitoringScreen> createState() => _ReasoningMonitoringScreenState();
}

class _ReasoningMonitoringScreenState extends ConsumerState<ReasoningMonitoringScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Task> _runningTasks = [];
  List<Map<String, dynamic>> _performanceData = [];
  String _selectedTimeRange = '1h';
  String _selectedNodeFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadMonitoringData();
  }

  Future<void> _loadMonitoringData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Implement actual data loading
      // For now, simulate loading with mock data
      await Future.delayed(const Duration(seconds: 1));
      
      // Mock running tasks data
      _runningTasks = [
        Task(
          id: 'task_1',
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
          id: 'task_2',
          title: 'Data Processing',
          description: 'Process and clean dataset',
          nodeId: 'node_2',
          status: TaskStatus.running,
          progress: 40,
          startedAt: DateTime.now().subtract(const Duration(minutes: 15)),
          createdAt: DateTime.now().subtract(const Duration(minutes: 20)),
          updatedAt: DateTime.now(),
        ),
      ];
      
      // Mock performance data
      final now = DateTime.now();
      _performanceData = List.generate(60, (index) {
        final time = now.subtract(Duration(minutes: 60 - index));
        return {
          'time': time,
          'cpu': 45.0 + (index % 20) * 2.0,
          'memory': 60.0 + (index % 15) * 1.5,
          'network': 20.0 + (index % 10) * 3.0,
          'tasks': 3 + (index % 5),
        };
      });
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      App.logger.e('Failed to load monitoring data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
    }
  }

  List<Map<String, dynamic>> get _filteredPerformanceData {
    var filtered = _performanceData;
    
    // Apply time range filter
    final now = DateTime.now();
    switch (_selectedTimeRange) {
      case '15m':
        filtered = filtered.where((data) => 
          now.difference(data['time'] as DateTime).inMinutes <= 15
        ).toList();
        break;
      case '1h':
        filtered = filtered.where((data) => 
          now.difference(data['time'] as DateTime).inMinutes <= 60
        ).toList();
        break;
      case '6h':
        filtered = filtered.where((data) => 
          now.difference(data['time'] as DateTime).inHours <= 6
        ).toList();
        break;
      case '24h':
        filtered = filtered.where((data) => 
          now.difference(data['time'] as DateTime).inHours <= 24
        ).toList();
        break;
    }
    
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: NoodleAppBar(
        title: 'Performance Monitor',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadMonitoringData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading monitoring data...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadMonitoringData,
                )
              : RefreshIndicator(
                  onRefresh: _loadMonitoringData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time range selector
                        Row(
                          children: [
                            Text(
                              'Time Range:',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: [
                                    FilterChip(
                                      label: const Text('15m'),
                                      selected: _selectedTimeRange == '15m',
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTimeRange = '15m';
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterChip(
                                      label: const Text('1h'),
                                      selected: _selectedTimeRange == '1h',
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTimeRange = '1h';
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterChip(
                                      label: const Text('6h'),
                                      selected: _selectedTimeRange == '6h',
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTimeRange = '6h';
                                        });
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    FilterChip(
                                      label: const Text('24h'),
                                      selected: _selectedTimeRange == '24h',
                                      onSelected: (selected) {
                                        setState(() {
                                          _selectedTimeRange = '24h';
                                        });
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Performance metrics cards
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'CPU Usage',
                                value: '${(_performanceData.isNotEmpty ? _performanceData.last['cpu'] : 0).toStringAsFixed(1)}%',
                                icon: Icons.memory,
                                color: _getMetricColor(_performanceData.isNotEmpty ? _performanceData.last['cpu'] : 0),
                                trend: _getTrend(_performanceData.map((d) => d['cpu']).toList()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Memory Usage',
                                value: '${(_performanceData.isNotEmpty ? _performanceData.last['memory'] : 0).toStringAsFixed(1)}%',
                                icon: Icons.storage,
                                color: _getMetricColor(_performanceData.isNotEmpty ? _performanceData.last['memory'] : 0),
                                trend: _getTrend(_performanceData.map((d) => d['memory']).toList()),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                title: 'Network I/O',
                                value: '${(_performanceData.isNotEmpty ? _performanceData.last['network'] : 0).toStringAsFixed(1)}%',
                                icon: Icons.network_check,
                                color: Colors.blue,
                                trend: _getTrend(_performanceData.map((d) => d['network']).toList()),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _MetricCard(
                                title: 'Active Tasks',
                                value: '${_runningTasks.length}',
                                icon: Icons.task,
                                color: Theme.of(context).colorScheme.primary,
                                trend: _getTrend(_performanceData.map((d) => d['tasks']).toList()),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Performance charts
                        Text(
                          'Performance Metrics',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // CPU Usage Chart
                        _ChartCard(
                          title: 'CPU Usage',
                          child: _LineChart(
                            data: _filteredPerformanceData.map((d) => {
                              'x': d['time'] as DateTime,
                              'y': d['cpu'] as double,
                            }).toList(),
                            color: Colors.blue,
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Memory Usage Chart
                        _ChartCard(
                          title: 'Memory Usage',
                          child: _LineChart(
                            data: _filteredPerformanceData.map((d) => {
                              'x': d['time'] as DateTime,
                              'y': d['memory'] as double,
                            }).toList(),
                            color: Colors.green,
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Running tasks
                        Text(
                          'Running Tasks',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_runningTasks.isEmpty)
                          const EmptyState(
                            title: 'No running tasks',
                            subtitle: 'Tasks will appear here when they are running',
                            icon: Icons.task_alt,
                          )
                        else
                          ..._runningTasks.map((task) => _TaskCard(task: task)),
                        
                        const SizedBox(height: 100), // Extra space for bottom navigation
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: NoodleBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
          if (index != 3) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/ide-control');
                break;
              case 2:
                context.go('/node-management');
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

  Color _getMetricColor(double value) {
    if (value > 80) {
      return Colors.red;
    } else if (value > 60) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  String _getTrend(List<double> values) {
    if (values.length < 2) return '→';
    
    final recent = values.sublist(values.length > 10 ? values.length - 10 : 0);
    final avg = recent.reduce((a, b) => a + b) / recent.length;
    final last = values.last;
    
    if (last > avg * 1.05) return '↑';
    if (last < avg * 0.95) return '↓';
    return '→';
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final String trend;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  trend,
                  style: TextStyle(
                    color: trend == '↑' 
                        ? Colors.green 
                        : trend == '↓' 
                            ? Colors.red 
                            : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _ChartCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

class _LineChart extends StatelessWidget {
  final List<Map<String, dynamic>> data;
  final Color color;

  const _LineChart({
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: 20,
          verticalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.surfaceVariant,
              strokeWidth: 1,
            );
          },
          getDrawingVerticalLine: (value) {
            return FlLine(
              color: Theme.of(context).colorScheme.surfaceVariant,
              strokeWidth: 0.5,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              interval: 1,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= data.length) {
                  return const SizedBox();
                }
                
                final time = data[index]['x'] as DateTime;
                final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    formattedTime,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: 20,
              getTitlesWidget: (value, meta) {
                return SideTitleWidget(
                  axisSide: meta.axisSide,
                  child: Text(
                    '${value.toInt()}%',
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Theme.of(context).colorScheme.surfaceVariant),
        ),
        minX: 0,
        maxX: (data.length - 1).toDouble(),
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: data.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value['y'] as double);
            }).toList(),
            isCurved: true,
            gradient: LinearGradient(
              colors: [
                color.withOpacity(0.8),
                color,
              ],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: false,
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.1),
                  color.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Theme.of(context).colorScheme.inverseSurface,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final index = spot.x.toInt();
                if (index < 0 || index >= data.length) {
                  return null;
                }
                
                final time = data[index]['x'] as DateTime;
                final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:${time.second.toString().padLeft(2, '0')}';
                final value = '${spot.y.toStringAsFixed(1)}%';
                
                return LineTooltipItem(
                  '$formattedTime\n$value',
                  TextStyle(
                    color: Theme.of(context).colorScheme.onInverseSurface,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
          touchCallback: (FlTouchEvent event, lineTouchResponse) {},
          handleBuiltInTouches: true,
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
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          Icons.play_circle,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description != null) Text(task.description!),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Node: ${task.nodeId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(width: 16),
                Text(
                  'Started: ${_formatDuration(DateTime.now().difference(task.startedAt!))} ago',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (task.progress ?? 0) / 100,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress: ${task.progress ?? 0}%',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    // TODO: Implement task cancellation
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task cancellation not implemented yet'),
                      ),
                    );
                  },
                  iconSize: 20,
                  tooltip: 'Cancel Task',
                ),
              ],
            ),
          ],
        ),
      ),
    );
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