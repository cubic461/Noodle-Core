# Converted from Python to NoodleCore
# Original file: src

# """
# Logging System Module

# This module contains comprehensive logging and monitoring components for the NoodleCore CLI:
# - Core Logger with async support and multiple outputs
# - Audit Trail with cryptographic signatures
# - Performance Monitor with constraint checking
# - Metrics Collector with comprehensive system monitoring
# - Log Analyzer with pattern detection and anomaly identification
# - Alert Manager with multi-channel notifications
# - Log Storage Manager with multiple backends and retention policies
# """

import .logger.Logger
import .audit_trail.(
#     AuditTrail,
#     AuditEventType,
#     AuditLevel,
#     CryptographicSigner,
#     AuditException
# )
import .performance_monitor.(
#     PerformanceMonitor,
#     PerformanceLevel,
#     MetricType,
#     PerformanceThreshold,
#     PerformanceMetric,
#     PerformanceAlert,
#     PerformanceException
# )
import .metrics_collector.(
#     MetricsCollector,
#     MetricCategory,
#     MetricType as MetricsMetricType,
#     MetricDefinition,
#     MetricValue,
#     AggregatedMetric,
#     MetricsException
# )
import .log_analyzer.(
#     LogAnalyzer,
#     LogLevel as AnalyzerLogLevel,
#     LogFormat as AnalyzerLogFormat,
#     LogPattern,
#     LogAnomaly,
#     AnomalyType,
#     LogCorrelation,
#     LogAnalyzerException
# )
import .alert_manager.(
#     AlertManager,
#     AlertSeverity,
#     AlertStatus,
#     AlertType,
#     NotificationChannel,
#     Alert,
#     AlertRule,
#     NotificationConfig,
#     AlertException
# )
import .log_storage_manager.(
#     LogStorageManager,
#     StorageBackend,
#     CompressionType,
#     RetentionPolicy,
#     StorageConfig,
#     LogEntry as StorageLogEntry,
#     StorageStats,
#     LogStorageException
# )

# Version information
__version__ = "1.0.0"
__author__ = "NoodleCore Team"

# Export all main classes and functions
__all__ = [
#     # Core Logger
#     "Logger",
#     "LogLevel",
#     "LogFormat",
#     "LogOutput",
#     "LoggingException",
#     "get_logger",
#     "reset_logger",

#     # Audit Trail
#     "AuditTrail",
#     "AuditEventType",
#     "AuditLevel",
#     "CryptographicSigner",
#     "AuditException",

#     # Performance Monitor
#     "PerformanceMonitor",
#     "PerformanceLevel",
#     "MetricType",
#     "PerformanceThreshold",
#     "PerformanceMetric",
#     "PerformanceAlert",
#     "PerformanceException",

#     # Metrics Collector
#     "MetricsCollector",
#     "MetricCategory",
#     "MetricsMetricType",
#     "MetricDefinition",
#     "MetricValue",
#     "AggregatedMetric",
#     "MetricsException",

#     # Log Analyzer
#     "LogAnalyzer",
#     "AnalyzerLogLevel",
#     "AnalyzerLogFormat",
#     "LogPattern",
#     "LogAnomaly",
#     "AnomalyType",
#     "LogCorrelation",
#     "LogAnalyzerException",

#     # Alert Manager
#     "AlertManager",
#     "AlertSeverity",
#     "AlertStatus",
#     "AlertType",
#     "NotificationChannel",
#     "Alert",
#     "AlertRule",
#     "NotificationConfig",
#     "AlertException",

#     # Log Storage Manager
#     "LogStorageManager",
#     "StorageBackend",
#     "CompressionType",
#     "RetentionPolicy",
#     "StorageConfig",
#     "StorageLogEntry",
#     "StorageStats",
#     "LogStorageException"
# ]

# Convenience functions for quick access
# async def initialize_logging_system(
log_level: str = "INFO",
enable_performance_monitoring: bool = True,
enable_metrics_collection: bool = True,
enable_alert_management: bool = True,
enable_log_storage: bool = True,
config_dir: Optional[str] = None
# ) -Dict[str, Any]):
#     """
#     Initialize the complete logging system.

#     Args:
#         log_level: Default log level
#         enable_performance_monitoring: Enable performance monitoring
#         enable_metrics_collection: Enable metrics collection
#         enable_alert_management: Enable alert management
#         enable_log_storage: Enable log storage management
#         config_dir: Configuration directory

#     Returns:
#         Dictionary containing initialized components
#     """
components = {}

#     try:
#         # Initialize Core Logger
logger = await get_logger()
        await logger.initialize(
level = log_level,
outputs = [LogOutput.CONSOLE, LogOutput.FILE],
format_type = LogFormat.JSON,
enable_async = True
#         )
components['logger'] = logger

#         # Initialize Audit Trail
audit_trail = AuditTrail(config_dir)
components['audit_trail'] = audit_trail

#         # Initialize Performance Monitor
#         if enable_performance_monitoring:
perf_monitor = PerformanceMonitor(config_dir)
            await perf_monitor.start_monitoring()
components['performance_monitor'] = perf_monitor

#         # Initialize Metrics Collector
#         if enable_metrics_collection:
metrics_collector = MetricsCollector(config_dir)
            await metrics_collector.start_collection()
components['metrics_collector'] = metrics_collector

#         # Initialize Alert Manager
#         if enable_alert_management:
alert_manager = AlertManager(config_dir)
            await alert_manager.start_processing()
components['alert_manager'] = alert_manager

#         # Initialize Log Storage Manager
#         if enable_log_storage:
storage_manager = LogStorageManager(config_dir)
            await storage_manager.start_maintenance()
components['storage_manager'] = storage_manager

        await logger.info(
#             "Logging system initialized successfully",
extra = {
                'components': list(components.keys()),
#                 'log_level': log_level,
#                 'config_dir': config_dir
#             }
#         )

#         return {
#             'success': True,
#             'components': components,
#             'message': 'Logging system initialized successfully'
#         }

#     except Exception as e:
#         if 'logger' in components:
            await components['logger'].error(
                f"Failed to initialize logging system: {str(e)}",
error_code = 5001
#             )

#         return {
#             'success': False,
            'error': str(e),
#             'components': components
#         }


# async def shutdown_logging_system(components: Dict[str, Any]) -None):
#     """
#     Shutdown the logging system gracefully.

#     Args:
#         components: Dictionary of initialized components
#     """
#     try:
#         # Shutdown in reverse order
shutdown_order = [
#             'storage_manager',
#             'alert_manager',
#             'metrics_collector',
#             'performance_monitor',
#             'audit_trail',
#             'logger'
#         ]

#         for component_name in shutdown_order:
#             if component_name in components:
component = components[component_name]

#                 if component_name == 'logger':
                    await component.shutdown()
#                 elif component_name == 'performance_monitor':
                    await component.stop_monitoring()
#                 elif component_name == 'metrics_collector':
                    await component.stop_collection()
#                 elif component_name == 'alert_manager':
                    await component.stop_processing()
#                 elif component_name == 'storage_manager':
                    await component.stop_maintenance()
#                 elif component_name == 'audit_trail':
#                     # Audit trail doesn't have explicit shutdown
#                     pass

        print("Logging system shutdown completed")

#     except Exception as e:
        print(f"Error during logging system shutdown: {str(e)}")


def get_system_health(components: Dict[str, Any]) -Dict[str, Any]):
#     """
#     Get overall system health from all components.

#     Args:
#         components: Dictionary of initialized components

#     Returns:
#         Dictionary containing system health information
#     """
health = {
#         'overall_status': 'healthy',
#         'components': {},
        'timestamp': datetime.now().isoformat(),
#         'issues': []
#     }

#     try:
#         # Check Logger
#         if 'logger' in components:
logger_stats = components['logger'].get_performance_stats()
health['components']['logger'] = {
#                 'status': 'healthy' if logger_stats['total_logs'] 0 else 'inactive',
#                 'stats'): logger_stats
#             }

#         # Check Performance Monitor
#         if 'performance_monitor' in components:
perf_stats = components['performance_monitor'].get_performance_stats()
health['components']['performance_monitor'] = {
#                 'status': 'healthy' if perf_stats['monitoring_active'] else 'inactive',
#                 'stats': perf_stats
#             }

#             # Check for performance issues
#             if perf_stats['active_alerts_count'] 0):
                health['issues'].append(f"Performance alerts: {perf_stats['active_alerts_count']}")
health['overall_status'] = 'warning'

#         # Check Metrics Collector
#         if 'metrics_collector' in components:
metrics_stats = components['metrics_collector'].get_metrics_stats()
health['components']['metrics_collector'] = {
#                 'status': 'healthy' if metrics_stats['collecting'] else 'inactive',
#                 'stats': metrics_stats
#             }

#         # Check Alert Manager
#         if 'alert_manager' in components:
alert_stats = components['alert_manager'].get_statistics()
health['components']['alert_manager'] = {
#                 'status': 'healthy' if alert_stats['running'] else 'inactive',
#                 'stats': alert_stats
#             }

#             # Check for active alerts
#             if alert_stats['active_alerts'] 0):
                health['issues'].append(f"Active alerts: {alert_stats['active_alerts']}")
#                 if any(alert['severity'] == 'critical' for alert in components['alert_manager'].get_active_alerts()):
health['overall_status'] = 'critical'

#         # Check Storage Manager
#         if 'storage_manager' in components:
storage_stats = components['storage_manager'].get_manager_stats()
health['components']['storage_manager'] = {
#                 'status': 'healthy' if storage_stats['running'] else 'inactive',
#                 'stats': storage_stats
#             }

#         # Determine overall status
#         if health['issues']:
#             if any('critical' in issue.lower() for issue in health['issues']):
health['overall_status'] = 'critical'
#             elif any('error' in issue.lower() for issue in health['issues']):
health['overall_status'] = 'error'
#             else:
health['overall_status'] = 'warning'

#         return health

#     except Exception as e:
#         return {
#             'overall_status': 'error',
            'error': str(e),
#             'components': health['components'],
            'timestamp': datetime.now().isoformat()
#         }


# Import datetime for health check
import datetime.datetime
import typing.Optional