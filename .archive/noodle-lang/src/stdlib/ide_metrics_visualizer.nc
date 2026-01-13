# Performance Monitoring and Metrics Visualization for NoodleCore IDE
# -----------------------------------------------------------------

import .runtime.performance_monitor.PerformanceMonitor
import .runtime.resource_monitor.ResourceMonitor
import .utils.common.CommonUtils
import .runtime.error_handler.ErrorHandler

class IDEMetricsVisualizer:
    """
    Performance monitoring and metrics visualization for NoodleCore IDE.
    
    Provides real-time monitoring of IDE performance, resource usage,
    user activity, and system health with interactive visualizations
    and alerts following noodlecore performance standards.
    """
    
    def __init__(self, performance_monitor, resource_monitor, error_handler):
        """
        Initialize IDE Metrics Visualizer.
        
        Args:
            performance_monitor: Performance monitoring system
            resource_monitor: Resource monitoring system
            error_handler: Error handling system
        """
        self.performance_monitor = performance_monitor
        self.resource_monitor = resource_monitor
        self.error_handler = error_handler
        
        # Metrics configuration
        self.metrics_config = {
            'monitoring_enabled': True,
            'metrics_retention_hours': 24,
            'alert_thresholds': {
                'response_time_ms': 500,
                'memory_usage_mb': 512,
                'cpu_usage_percent': 80,
                'disk_usage_percent': 90,
                'network_latency_ms': 100,
                'concurrent_users': 100
            },
            'collection_interval': 5000,  # 5 seconds
            'chart_update_interval': 1000,  # 1 second
            'max_metrics_per_chart': 100
        }
        
        # Metric categories
        self.metric_categories = {
            'ide_performance': {
                'name': 'IDE Performance',
                'description': 'IDE-specific performance metrics',
                'color': '#0066cc',
                'metrics': [
                    'editor_response_time',
                    'file_operation_latency',
                    'search_performance',
                    'ai_analysis_time',
                    'ui_rendering_time'
                ]
            },
            'system_resources': {
                'name': 'System Resources',
                'description': 'System resource utilization',
                'color': '#28a745',
                'metrics': [
                    'cpu_usage',
                    'memory_usage',
                    'disk_usage',
                    'network_io'
                ]
            },
            'user_activity': {
                'name': 'User Activity',
                'description': 'User interaction metrics',
                'color': '#fd7e14',
                'metrics': [
                    'active_users',
                    'files_opened',
                    'collaboration_sessions',
                    'code_executions'
                ]
            },
            'ai_performance': {
                'name': 'AI Performance',
                'description': 'AI system performance metrics',
                'color': '#6f42c1',
                'metrics': [
                    'analysis_accuracy',
                    'suggestion_confidence',
                    'learning_progress',
                    'model_response_time'
                ]
            },
            'network_status': {
                'name': 'Network Status',
                'description': 'Network and connectivity metrics',
                'color': '#20c997',
                'metrics': [
                    'websocket_connections',
                    'api_response_time',
                    'error_rate',
                    'throughput'
                ]
            }
        }
        
        # Real-time metrics storage
        self.realtime_metrics = {}
        self.historical_metrics = {}
        self.alert_history = []
        
        # Dashboard configuration
        self.dashboard_config = {
            'layout': 'grid',
            'refresh_interval': 30,  # seconds
            'auto_scaling': True,
            'dark_mode': True,
            'show_alerts': True,
            'show_historical': True
        }
        
        # Initialize metrics collection
        self.setup_metrics_collection()
    
    def setup_metrics_collection(self):
        """Setup metrics collection and monitoring."""
        try:
            if not self.metrics_config['monitoring_enabled']:
                return
            
            # Initialize performance monitoring
            if self.performance_monitor:
                self.setup_performance_monitoring()
            
            # Initialize resource monitoring
            if self.resource_monitor:
                self.setup_resource_monitoring()
            
            # Start metrics collection
            self.start_metrics_collection()
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup metrics collection: {str(e)}')
    
    def setup_performance_monitoring(self):
        """Setup IDE-specific performance monitoring."""
        try:
            # Define IDE-specific performance metrics
            ide_metrics = {
                'editor_response_time': {
                    'type': 'gauge',
                    'unit': 'milliseconds',
                    'description': 'Time from user input to editor response',
                    'target': '< 100ms',
                    'alert_threshold': self.metrics_config['alert_thresholds']['response_time_ms']
                },
                'file_operation_latency': {
                    'type': 'histogram',
                    'unit': 'milliseconds',
                    'description': 'Time for file operations (open, save, close)',
                    'target': '< 500ms',
                    'alert_threshold': 1000
                },
                'search_performance': {
                    'type': 'histogram',
                    'unit': 'milliseconds',
                    'description': 'Search operation performance',
                    'target': '< 1000ms',
                    'alert_threshold': 3000
                },
                'ai_analysis_time': {
                    'type': 'gauge',
                    'unit': 'milliseconds',
                    'description': 'Time for AI code analysis',
                    'target': '< 2000ms',
                    'alert_threshold': 5000
                },
                'ui_rendering_time': {
                    'type': 'gauge',
                    'unit': 'milliseconds',
                    'description': 'UI component rendering time',
                    'target': '< 50ms',
                    'alert_threshold': 100
                }
            }
            
            # Register metrics with performance monitor
            for metric_name, metric_config in ide_metrics.items():
                self.performance_monitor.register_metric(metric_name, metric_config)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup performance monitoring: {str(e)}')
    
    def setup_resource_monitoring(self):
        """Setup system resource monitoring."""
        try:
            # Define resource monitoring thresholds
            resource_thresholds = {
                'cpu_usage': self.metrics_config['alert_thresholds']['cpu_usage_percent'],
                'memory_usage': self.metrics_config['alert_thresholds']['memory_usage_mb'],
                'disk_usage': self.metrics_config['alert_thresholds']['disk_usage_percent']
            }
            
            # Configure resource monitoring
            self.resource_monitor.configure_alerts(resource_thresholds)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to setup resource monitoring: {str(e)}')
    
    def start_metrics_collection(self):
        """Start background metrics collection."""
        try:
            import threading
            import time
            
            def collect_metrics():
                while self.metrics_config['monitoring_enabled']:
                    try:
                        self.collect_realtime_metrics()
                        time.sleep(self.metrics_config['collection_interval'] / 1000)
                    except Exception as e:
                        self.error_handler.handle_error(f'Error in metrics collection: {str(e)}')
                        time.sleep(5)
            
            # Start collection thread
            collection_thread = threading.Thread(target=collect_metrics, daemon=True)
            collection_thread.start()
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to start metrics collection: {str(e)}')
    
    def collect_realtime_metrics(self):
        """Collect real-time metrics from all sources."""
        try:
            timestamp = self._get_timestamp()
            
            # Collect IDE performance metrics
            ide_metrics = self._collect_ide_performance_metrics()
            
            # Collect system resource metrics
            system_metrics = self._collect_system_metrics()
            
            # Collect user activity metrics
            user_metrics = self._collect_user_activity_metrics()
            
            # Collect AI performance metrics
            ai_metrics = self._collect_ai_performance_metrics()
            
            # Collect network metrics
            network_metrics = self._collect_network_metrics()
            
            # Combine all metrics
            all_metrics = {
                'timestamp': timestamp,
                'ide_performance': ide_metrics,
                'system_resources': system_metrics,
                'user_activity': user_metrics,
                'ai_performance': ai_metrics,
                'network_status': network_metrics
            }
            
            # Store real-time metrics
            self.realtime_metrics = all_metrics
            
            # Store in historical data
            self._store_historical_metrics(all_metrics)
            
            # Check for alerts
            self._check_alerts(all_metrics)
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect realtime metrics: {str(e)}')
    
    def _collect_ide_performance_metrics(self):
        """Collect IDE-specific performance metrics."""
        try:
            return {
                'editor_response_time': self._get_editor_response_time(),
                'file_operation_latency': self._get_file_operation_latency(),
                'search_performance': self._get_search_performance(),
                'ai_analysis_time': self._get_ai_analysis_time(),
                'ui_rendering_time': self._get_ui_rendering_time()
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect IDE metrics: {str(e)}')
            return {}
    
    def _collect_system_metrics(self):
        """Collect system resource metrics."""
        try:
            return {
                'cpu_usage': self.resource_monitor.get_cpu_usage() if self.resource_monitor else 0,
                'memory_usage': self.resource_monitor.get_memory_usage() if self.resource_monitor else 0,
                'disk_usage': self.resource_monitor.get_disk_usage() if self.resource_monitor else 0,
                'network_io': self.resource_monitor.get_network_io() if self.resource_monitor else {'bytes_sent': 0, 'bytes_received': 0}
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect system metrics: {str(e)}')
            return {}
    
    def _collect_user_activity_metrics(self):
        """Collect user activity metrics."""
        try:
            return {
                'active_users': len(self._get_active_users()),
                'files_opened': self._get_files_opened_count(),
                'collaboration_sessions': self._get_collaboration_sessions_count(),
                'code_executions': self._get_code_executions_count()
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect user activity metrics: {str(e)}')
            return {}
    
    def _collect_ai_performance_metrics(self):
        """Collect AI performance metrics."""
        try:
            return {
                'analysis_accuracy': self._get_ai_analysis_accuracy(),
                'suggestion_confidence': self._get_ai_suggestion_confidence(),
                'learning_progress': self._get_learning_progress(),
                'model_response_time': self._get_ai_model_response_time()
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect AI metrics: {str(e)}')
            return {}
    
    def _collect_network_metrics(self):
        """Collect network status metrics."""
        try:
            return {
                'websocket_connections': self._get_websocket_connections(),
                'api_response_time': self._get_api_response_time(),
                'error_rate': self._get_api_error_rate(),
                'throughput': self._get_api_throughput()
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to collect network metrics: {str(e)}')
            return {}
    
    def get_dashboard_data(self, time_range='1h'):
        """
        Get dashboard data for visualization.
        
        Args:
            time_range: Time range for historical data
            
        Returns:
            dict: Dashboard data with charts and metrics
        """
        try:
            # Get historical data for time range
            historical_data = self._get_historical_data(time_range)
            
            # Get current real-time metrics
            current_metrics = self.realtime_metrics.copy()
            
            # Generate chart configurations
            chart_configs = self._generate_chart_configs(historical_data, current_metrics)
            
            # Get active alerts
            active_alerts = self._get_active_alerts()
            
            # Create dashboard response
            dashboard_data = {
                'success': True,
                'request_id': self._generate_request_id(),
                'data': {
                    'current_metrics': current_metrics,
                    'historical_data': historical_data,
                    'chart_configs': chart_configs,
                    'active_alerts': active_alerts,
                    'dashboard_summary': self._create_dashboard_summary(current_metrics),
                    'last_updated': self._get_timestamp()
                }
            }
            
            return dashboard_data
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to get dashboard data: {str(e)}')
            return self._error_response('Failed to get dashboard data', '9001')
    
    def _generate_chart_configs(self, historical_data, current_metrics):
        """Generate Chart.js configurations for visualization."""
        try:
            chart_configs = {}
            
            # Performance overview chart
            chart_configs['performance_overview'] = {
                'type': 'line',
                'data': {
                    'labels': self._generate_time_labels(historical_data),
                    'datasets': [
                        {
                            'label': 'Editor Response Time',
                            'data': self._extract_metric_data(historical_data, 'ide_performance', 'editor_response_time'),
                            'borderColor': self.metric_categories['ide_performance']['color'],
                            'backgroundColor': self.metric_categories['ide_performance']['color'] + '20',
                            'tension': 0.4
                        },
                        {
                            'label': 'Memory Usage (MB)',
                            'data': self._extract_metric_data(historical_data, 'system_resources', 'memory_usage'),
                            'borderColor': self.metric_categories['system_resources']['color'],
                            'backgroundColor': self.metric_categories['system_resources']['color'] + '20',
                            'tension': 0.4
                        }
                    ]
                },
                'options': {
                    'responsive': True,
                    'scales': {
                        'y': {
                            'beginAtZero': True
                        }
                    },
                    'plugins': {
                        'title': {
                            'display': True,
                            'text': 'Performance Overview'
                        }
                    }
                }
            }
            
            # System resources chart
            chart_configs['system_resources'] = {
                'type': 'doughnut',
                'data': {
                    'labels': ['CPU Usage', 'Memory Usage', 'Disk Usage'],
                    'datasets': [{
                        'data': [
                            current_metrics.get('system_resources', {}).get('cpu_usage', 0),
                            current_metrics.get('system_resources', {}).get('memory_usage', 0),
                            current_metrics.get('system_resources', {}).get('disk_usage', 0)
                        ],
                        'backgroundColor': [
                            '#FF6384',
                            '#36A2EB',
                            '#FFCE56'
                        ]
                    }]
                },
                'options': {
                    'responsive': True,
                    'plugins': {
                        'title': {
                            'display': True,
                            'text': 'System Resources'
                        }
                    }
                }
            }
            
            # User activity chart
            chart_configs['user_activity'] = {
                'type': 'bar',
                'data': {
                    'labels': ['Active Users', 'Files Opened', 'Collaborations', 'Executions'],
                    'datasets': [{
                        'label': 'Activity Count',
                        'data': [
                            current_metrics.get('user_activity', {}).get('active_users', 0),
                            current_metrics.get('user_activity', {}).get('files_opened', 0),
                            current_metrics.get('user_activity', {}).get('collaboration_sessions', 0),
                            current_metrics.get('user_activity', {}).get('code_executions', 0)
                        ],
                        'backgroundColor': self.metric_categories['user_activity']['color']
                    }]
                },
                'options': {
                    'responsive': True,
                    'plugins': {
                        'title': {
                            'display': True,
                            'text': 'User Activity'
                        }
                    }
                }
            }
            
            # AI performance chart
            chart_configs['ai_performance'] = {
                'type': 'radar',
                'data': {
                    'labels': ['Accuracy', 'Confidence', 'Learning Progress', 'Response Time'],
                    'datasets': [{
                        'label': 'AI Performance',
                        'data': [
                            current_metrics.get('ai_performance', {}).get('analysis_accuracy', 0) * 100,
                            current_metrics.get('ai_performance', {}).get('suggestion_confidence', 0) * 100,
                            current_metrics.get('ai_performance', {}).get('learning_progress', 0) * 100,
                            100 - (current_metrics.get('ai_performance', {}).get('model_response_time', 0) / 50 * 100)
                        ],
                        'borderColor': self.metric_categories['ai_performance']['color'],
                        'backgroundColor': self.metric_categories['ai_performance']['color'] + '20'
                    }]
                },
                'options': {
                    'responsive': True,
                    'plugins': {
                        'title': {
                            'display': True,
                            'text': 'AI Performance'
                        }
                    },
                    'scales': {
                        'r': {
                            'beginAtZero': True,
                            'max': 100
                        }
                    }
                }
            }
            
            return chart_configs
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to generate chart configs: {str(e)}')
            return {}
    
    def _create_dashboard_summary(self, current_metrics):
        """Create dashboard summary with key metrics."""
        try:
            return {
                'status': self._get_overall_status(current_metrics),
                'key_metrics': {
                    'active_users': current_metrics.get('user_activity', {}).get('active_users', 0),
                    'system_load': current_metrics.get('system_resources', {}).get('cpu_usage', 0),
                    'ide_performance': current_metrics.get('ide_performance', {}).get('editor_response_time', 0),
                    'ai_efficiency': current_metrics.get('ai_performance', {}).get('analysis_accuracy', 0)
                },
                'alerts_count': len(self._get_active_alerts()),
                'recommendations': self._generate_recommendations(current_metrics)
            }
        except Exception as e:
            self.error_handler.handle_error(f'Failed to create dashboard summary: {str(e)}')
            return {}
    
    def _generate_recommendations(self, current_metrics):
        """Generate performance recommendations based on metrics."""
        recommendations = []
        
        try:
            # Check CPU usage
            cpu_usage = current_metrics.get('system_resources', {}).get('cpu_usage', 0)
            if cpu_usage > 80:
                recommendations.append({
                    'type': 'warning',
                    'message': 'High CPU usage detected. Consider closing unnecessary applications.',
                    'action': 'Close unused applications'
                })
            
            # Check memory usage
            memory_usage = current_metrics.get('system_resources', {}).get('memory_usage', 0)
            if memory_usage > 512:
                recommendations.append({
                    'type': 'info',
                    'message': 'High memory usage. Monitor for potential memory leaks.',
                    'action': 'Monitor memory usage'
                })
            
            # Check IDE performance
            response_time = current_metrics.get('ide_performance', {}).get('editor_response_time', 0)
            if response_time > 100:
                recommendations.append({
                    'type': 'performance',
                    'message': 'Editor response time is high. Consider optimizing editor settings.',
                    'action': 'Optimize editor configuration'
                })
            
            # Check AI performance
            ai_accuracy = current_metrics.get('ai_performance', {}).get('analysis_accuracy', 0)
            if ai_accuracy < 0.8:
                recommendations.append({
                    'type': 'ai',
                    'message': 'AI analysis accuracy could be improved. Consider retraining models.',
                    'action': 'Trigger AI model improvement'
                })
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to generate recommendations: {str(e)}')
        
        return recommendations
    
    def _check_alerts(self, current_metrics):
        """Check metrics against thresholds and create alerts."""
        try:
            current_time = self._get_timestamp()
            
            # Check each alert threshold
            for category, metrics in current_metrics.items():
                for metric_name, value in metrics.items():
                    threshold_key = self._get_threshold_key(metric_name)
                    if threshold_key and threshold_key in self.metrics_config['alert_thresholds']:
                        threshold = self.metrics_config['alert_thresholds'][threshold_key]
                        
                        if value > threshold:
                            alert = {
                                'id': self._generate_alert_id(),
                                'type': 'threshold_exceeded',
                                'severity': 'warning' if value < threshold * 1.2 else 'critical',
                                'category': category,
                                'metric': metric_name,
                                'value': value,
                                'threshold': threshold,
                                'timestamp': current_time,
                                'message': f'{metric_name} ({value}) exceeded threshold ({threshold})'
                            }
                            
                            # Add to alert history if not already present
                            if not self._is_duplicate_alert(alert):
                                self.alert_history.append(alert)
                                
                                # Keep only recent alerts
                                self._cleanup_old_alerts()
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to check alerts: {str(e)}')
    
    def _store_historical_metrics(self, metrics):
        """Store metrics in historical data."""
        try:
            timestamp = metrics['timestamp']
            
            for category, category_metrics in metrics.items():
                if category not in self.historical_metrics:
                    self.historical_metrics[category] = {}
                
                for metric_name, value in category_metrics.items():
                    if metric_name not in self.historical_metrics[category]:
                        self.historical_metrics[category][metric_name] = []
                    
                    self.historical_metrics[category][metric_name].append({
                        'timestamp': timestamp,
                        'value': value
                    })
            
            # Cleanup old data
            self._cleanup_historical_data()
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to store historical metrics: {str(e)}')
    
    def _cleanup_historical_data(self):
        """Cleanup old historical data based on retention policy."""
        try:
            cutoff_time = self._get_timestamp() - (self.metrics_config['metrics_retention_hours'] * 3600 * 1000)
            
            for category in self.historical_metrics:
                for metric_name in self.historical_metrics[category]:
                    # Remove old data points
                    self.historical_metrics[category][metric_name] = [
                        point for point in self.historical_metrics[category][metric_name]
                        if point['timestamp'] > cutoff_time
                    ]
                    
                    # Limit data points
                    if len(self.historical_metrics[category][metric_name]) > self.metrics_config['max_metrics_per_chart']:
                        self.historical_metrics[category][metric_name] = \
                            self.historical_metrics[category][metric_name][-self.metrics_config['max_metrics_per_chart']:]
            
        except Exception as e:
            self.error_handler.handle_error(f'Failed to cleanup historical data: {str(e)}')
    
    # Placeholder methods for metric collection
    def _get_editor_response_time(self):
        """Get current editor response time (placeholder)."""
        import random
        return random.uniform(20, 80)
    
    def _get_file_operation_latency(self):
        """Get file operation latency (placeholder)."""
        import random
        return random.uniform(100, 400)
    
    def _get_search_performance(self):
        """Get search performance metrics (placeholder)."""
        import random
        return random.uniform(200, 800)
    
    def _get_ai_analysis_time(self):
        """Get AI analysis time (placeholder)."""
        import random
        return random.uniform(1000, 3000)
    
    def _get_ui_rendering_time(self):
        """Get UI rendering time (placeholder)."""
        import random
        return random.uniform(15, 40)
    
    def _get_active_users(self):
        """Get list of active users (placeholder)."""
        return ['user1', 'user2', 'user3']  # Mock active users
    
    def _get_files_opened_count(self):
        """Get files opened count (placeholder)."""
        import random
        return random.randint(10, 50)
    
    def _get_collaboration_sessions_count(self):
        """Get collaboration sessions count (placeholder)."""
        import random
        return random.randint(2, 10)
    
    def _get_code_executions_count(self):
        """Get code executions count (placeholder)."""
        import random
        return random.randint(20, 100)
    
    def _get_ai_analysis_accuracy(self):
        """Get AI analysis accuracy (placeholder)."""
        import random
        return random.uniform(0.75, 0.95)
    
    def _get_ai_suggestion_confidence(self):
        """Get AI suggestion confidence (placeholder)."""
        import random
        return random.uniform(0.8, 0.98)
    
    def _get_learning_progress(self):
        """Get learning progress (placeholder)."""
        import random
        return random.uniform(0.6, 0.9)
    
    def _get_ai_model_response_time(self):
        """Get AI model response time (placeholder)."""
        import random
        return random.uniform(500, 2000)
    
    def _get_websocket_connections(self):
        """Get WebSocket connections count (placeholder)."""
        return 5
    
    def _get_api_response_time(self):
        """Get API response time (placeholder)."""
        import random
        return random.uniform(50, 200)
    
    def _get_api_error_rate(self):
        """Get API error rate (placeholder)."""
        import random
        return random.uniform(0, 0.05)
    
    def _get_api_throughput(self):
        """Get API throughput (placeholder)."""
        import random
        return random.uniform(100, 500)
    
    # Helper methods
    def _get_historical_data(self, time_range):
        """Get historical data for time range."""
        # Return recent historical data
        return self.historical_metrics.copy()
    
    def _extract_metric_data(self, historical_data, category, metric):
        """Extract metric data for chart generation."""
        if category in historical_data and metric in historical_data[category]:
            return [point['value'] for point in historical_data[category][metric][-20:]]  # Last 20 points
        return []
    
    def _generate_time_labels(self, historical_data):
        """Generate time labels for charts."""
        import time
        base_time = int(time.time())
        labels = []
        for i in range(20):
            labels.append(f"{base_time - (19-i)*60}")  # 20 minutes ago to now
        return labels
    
    def _get_overall_status(self, current_metrics):
        """Get overall system status."""
        try:
            cpu_usage = current_metrics.get('system_resources', {}).get('cpu_usage', 0)
            memory_usage = current_metrics.get('system_resources', {}).get('memory_usage', 0)
            response_time = current_metrics.get('ide_performance', {}).get('editor_response_time', 0)
            
            if cpu_usage > 90 or memory_usage > 800 or response_time > 200:
                return 'critical'
            elif cpu_usage > 70 or memory_usage > 600 or response_time > 150:
                return 'warning'
            else:
                return 'healthy'
                
        except:
            return 'unknown'
    
    def _generate_alert_id(self):
        """Generate unique alert ID."""
        import uuid
        return str(uuid.uuid4())
    
    def _is_duplicate_alert(self, alert):
        """Check if alert is a duplicate."""
        for existing_alert in self.alert_history[-10:]:  # Check last 10 alerts
            if (existing_alert['metric'] == alert['metric'] and 
                existing_alert['severity'] == alert['severity'] and
                self._get_timestamp() - existing_alert['timestamp'] < 300000):  # 5 minutes
                return True
        return False
    
    def _cleanup_old_alerts(self):
        """Cleanup old alerts."""
        current_time = self._get_timestamp()
        # Keep alerts from last 24 hours
        cutoff_time = current_time - (24 * 3600 * 1000)
        self.alert_history = [alert for alert in self.alert_history if alert['timestamp'] > cutoff_time]
    
    def _get_active_alerts(self):
        """Get active alerts (recent alerts)."""
        return self.alert_history[-10:]  # Last 10 alerts
    
    def _get_threshold_key(self, metric_name):
        """Get threshold key for metric name."""
        threshold_mapping = {
            'editor_response_time': 'response_time_ms',
            'cpu_usage': 'cpu_usage_percent',
            'memory_usage': 'memory_usage_mb',
            'disk_usage': 'disk_usage_percent',
            'network_io': 'network_latency_ms'
        }
        return threshold_mapping.get(metric_name)
    
    def _cleanup_historical_data(self):
        """Cleanup old historical data."""
        # Implementation already provided above
    
    def _generate_request_id(self):
        """Generate unique request ID."""
        import uuid
        return str(uuid.uuid4())
    
    def _get_timestamp(self):
        """Get current timestamp."""
        import time
        return int(time.time() * 1000)
    
    def _error_response(self, message, error_code):
        """Create standardized error response."""
        return {
            'success': False,
            'request_id': self._generate_request_id(),
            'error': {
                'message': message,
                'code': error_code,
                'timestamp': self._get_timestamp()
            }
        }