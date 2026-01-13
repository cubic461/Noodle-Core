# Converted from Python to NoodleCore
# Original file: src

# """
# Metrics Collector Module

# This module implements comprehensive metrics collection for the NoodleCore CLI,
# including system metrics, application metrics, AI provider metrics, and custom metrics.
# """

import asyncio
import json
import os
import psutil
import time
import threading
import collections.defaultdict
from dataclasses import dataclass
import datetime.datetime
import enum.Enum
import pathlib.Path
import typing.Dict
import statistics
import socket
import platform

import ..cli_config.get_cli_config


# Error codes for metrics collector (5301-5400)
class MetricsErrorCodes
    COLLECTOR_INIT_FAILED = 5301
    METRIC_COLLECTION_FAILED = 5302
    AGGREGATION_FAILED = 5303
    EXPORT_FAILED = 5304
    CUSTOM_METRIC_FAILED = 5305
    SYSTEM_METRIC_FAILED = 5306
    AI_METRIC_FAILED = 5307
    SANDBOX_METRIC_FAILED = 5308
    ROLLUP_FAILED = 5309
    STORAGE_ERROR = 5310


class MetricCategory(Enum)
    #     """Categories of metrics."""
    SYSTEM = "system"
    APPLICATION = "application"
    AI_PROVIDER = "ai_provider"
    SANDBOX = "sandbox"
    CUSTOM = "custom"


class MetricType(Enum)
    #     """Types of metrics with their aggregation methods."""
    COUNTER = "counter"          # Sum over time period
    GAUGE = "gauge"              # Latest value
    HISTOGRAM = "histogram"      # Distribution of values
    TIMER = "timer"              # Timing measurements
    RATE = "rate"                # Rate per time unit


dataclass
class MetricDefinition
    #     """Definition of a metric."""
    #     name: str
    #     category: MetricCategory
    #     metric_type: MetricType
    #     description: str
    #     unit: str
    #     tags: Dict[str, str]
    enabled: bool = True


dataclass
class MetricValue
    #     """Single metric value with timestamp."""
    #     timestamp: datetime
    #     value: Union[float, int, Dict[str, float]]
    #     tags: Dict[str, str]


dataclass
class AggregatedMetric
    #     """Aggregated metric over a time period."""
    #     metric_name: str
    #     category: MetricCategory
    #     metric_type: MetricType
    #     time_window: int  # seconds
    #     aggregation: Dict[str, float]  # e.g., {"sum": 100, "avg": 10, "count": 10}
    #     tags: Dict[str, str]
    #     timestamp: datetime


class MetricsException(Exception)
    #     """Base exception for metrics collection errors."""

    #     def __init__(self, message: str, error_code: int):
    self.error_code = error_code
            super().__init__(message)


class MetricsCollector
    #     """Comprehensive metrics collection system."""

    #     def __init__(self, config_dir: Optional[str] = None):""
    #         Initialize the metrics collector.

    #         Args:
    #             config_dir: Directory for metrics storage
    #         """
    self.config = get_cli_config()
    self.config_dir = Path(config_dir or '.project/.noodle/logs/metrics')
    self.config_dir.mkdir(parents = True, exist_ok=True)

    #         # Metrics storage
    self.metrics_file = self.config_dir / 'metrics.log'
    self.aggregated_file = self.config_dir / 'aggregated_metrics.json'
    self.custom_metrics_file = self.config_dir / 'custom_metrics.json'

    #         # In-memory metrics storage
    self.metrics_buffer: Dict[str, deque] = defaultdict(lambda: deque(maxlen=10000))
    self.metric_definitions: Dict[str, MetricDefinition] = {}

    #         # Custom metrics registry
    self.custom_metrics: Dict[str, Callable[[], Union[float, int]]] = {}

    #         # Collection state
    self._collecting = False
    self._collection_task = None
    self._aggregation_task = None
    self._lock = threading.Lock()

            # Collection intervals (seconds)
    self.system_interval = 30
    self.application_interval = 10
    self.aggregation_interval = 60

    #         # Statistics
    self._stats = {
    #             'total_metrics': 0,
    #             'total_collections': 0,
                'start_time': datetime.now(),
                'last_collection': datetime.now()
    #         }

    #         # Initialize built-in metric definitions
            self._initialize_metric_definitions()

    #         # Initialize files
            self._initialize_files()

    #     def _initialize_metric_definitions(self) -None):
    #         """Initialize built-in metric definitions."""
    #         # System metrics
    system_metrics = [
                MetricDefinition(
    #                 "cpu_usage_percent",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 "CPU usage percentage",
    #                 "percent",
    #                 {"component": "system"}
    #             ),
                MetricDefinition(
    #                 "memory_usage_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 "Memory usage in bytes",
    #                 "bytes",
    #                 {"component": "system"}
    #             ),
                MetricDefinition(
    #                 "memory_available_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 "Available memory in bytes",
    #                 "bytes",
    #                 {"component": "system"}
    #             ),
                MetricDefinition(
    #                 "disk_usage_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 "Disk usage in bytes",
    #                 "bytes",
    #                 {"component": "system", "path": "/"}
    #             ),
                MetricDefinition(
    #                 "network_bytes_sent",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.COUNTER,
    #                 "Network bytes sent",
    #                 "bytes",
    #                 {"component": "system"}
    #             ),
                MetricDefinition(
    #                 "network_bytes_received",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.COUNTER,
    #                 "Network bytes received",
    #                 "bytes",
    #                 {"component": "system"}
    #             ),
                MetricDefinition(
    #                 "process_count",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 "Number of running processes",
    #                 "count",
    #                 {"component": "system"}
    #             )
    #         ]

    #         # Application metrics
    application_metrics = [
                MetricDefinition(
    #                 "api_requests_total",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 "Total API requests",
    #                 "requests",
    #                 {"component": "api"}
    #             ),
                MetricDefinition(
    #                 "api_response_time_seconds",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.TIMER,
    #                 "API response time",
    #                 "seconds",
    #                 {"component": "api"}
    #             ),
                MetricDefinition(
    #                 "database_queries_total",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 "Total database queries",
    #                 "queries",
    #                 {"component": "database"}
    #             ),
                MetricDefinition(
    #                 "database_query_time_seconds",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.TIMER,
    #                 "Database query time",
    #                 "seconds",
    #                 {"component": "database"}
    #             ),
                MetricDefinition(
    #                 "error_count",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 "Total error count",
    #                 "errors",
    #                 {"component": "application"}
    #             ),
                MetricDefinition(
    #                 "active_connections",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.GAUGE,
    #                 "Active connections",
    #                 "connections",
    #                 {"component": "connection_manager"}
    #             )
    #         ]

    #         # AI provider metrics
    ai_metrics = [
                MetricDefinition(
    #                 "ai_requests_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 "Total AI requests",
    #                 "requests",
    #                 {"component": "ai_adapter"}
    #             ),
                MetricDefinition(
    #                 "ai_tokens_used_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 "Total AI tokens used",
    #                 "tokens",
    #                 {"component": "ai_adapter"}
    #             ),
                MetricDefinition(
    #                 "ai_response_time_seconds",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.TIMER,
    #                 "AI response time",
    #                 "seconds",
    #                 {"component": "ai_adapter"}
    #             ),
                MetricDefinition(
    #                 "ai_cost_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 "Total AI cost",
    #                 "dollars",
    #                 {"component": "ai_adapter"}
    #             ),
                MetricDefinition(
    #                 "ai_error_rate",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.RATE,
    #                 "AI error rate",
    #                 "rate",
    #                 {"component": "ai_adapter"}
    #             )
    #         ]

    #         # Sandbox metrics
    sandbox_metrics = [
                MetricDefinition(
    #                 "sandbox_executions_total",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.COUNTER,
    #                 "Total sandbox executions",
    #                 "executions",
    #                 {"component": "sandbox"}
    #             ),
                MetricDefinition(
    #                 "sandbox_execution_time_seconds",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.TIMER,
    #                 "Sandbox execution time",
    #                 "seconds",
    #                 {"component": "sandbox"}
    #             ),
                MetricDefinition(
    #                 "sandbox_memory_usage_bytes",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.GAUGE,
    #                 "Sandbox memory usage",
    #                 "bytes",
    #                 {"component": "sandbox"}
    #             ),
                MetricDefinition(
    #                 "sandbox_file_operations_total",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.COUNTER,
    #                 "Total sandbox file operations",
    #                 "operations",
    #                 {"component": "sandbox"}
    #             )
    #         ]

    #         # Register all metrics
    all_metrics = system_metrics + application_metrics + ai_metrics + sandbox_metrics
    #         for metric in all_metrics:
    self.metric_definitions[metric.name] = metric

    #     def _initialize_files(self) -None):
    #         """Initialize metrics collection files."""
    #         try:
    #             # Initialize metrics file
    #             if not self.metrics_file.exists():
    #                 with open(self.metrics_file, 'w', encoding='utf-8') as f:
                        f.write("# NoodleCore Metrics Collection\n")
                        f.write(f"# Started: {datetime.now().isoformat()}\n\n")

    #             # Initialize aggregated metrics file
    #             if not self.aggregated_file.exists():
    #                 with open(self.aggregated_file, 'w', encoding='utf-8') as f:
    json.dump({"generated_at": datetime.now().isoformat(), "metrics": {}}, f, indent = 2)

    #             # Initialize custom metrics file
    #             if not self.custom_metrics_file.exists():
    #                 with open(self.custom_metrics_file, 'w', encoding='utf-8') as f:
    json.dump({"custom_metrics": {}}, f, indent = 2)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to initialize metrics files: {str(e)}",
    #                 MetricsErrorCodes.COLLECTOR_INIT_FAILED
    #             )

    #     async def start_collection(self) -None):
    #         """Start metrics collection."""
    #         if self._collecting:
    #             return

    #         try:
    self._collecting = True

    #             # Start collection tasks
    self._collection_task = asyncio.create_task(self._collection_loop())
    self._aggregation_task = asyncio.create_task(self._aggregation_loop())

    self._stats['start_time'] = datetime.now()

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to start metrics collection: {str(e)}",
    #                 MetricsErrorCodes.COLLECTOR_INIT_FAILED
    #             )

    #     async def stop_collection(self) -None):
    #         """Stop metrics collection."""
    self._collecting = False

    #         if self._collection_task:
                self._collection_task.cancel()
    #             try:
    #                 await self._collection_task
    #             except asyncio.CancelledError:
    #                 pass

    #         if self._aggregation_task:
                self._aggregation_task.cancel()
    #             try:
    #                 await self._aggregation_task
    #             except asyncio.CancelledError:
    #                 pass

    #         # Save final aggregated metrics
            await self._save_aggregated_metrics()

    #     async def _collection_loop(self) -None):
    #         """Main collection loop."""
    #         while self._collecting:
    #             try:
    #                 # Collect system metrics
                    await self._collect_system_metrics()

    #                 # Collect application metrics
                    await self._collect_application_metrics()

    #                 # Collect custom metrics
                    await self._collect_custom_metrics()

    self._stats['total_collections'] + = 1
    self._stats['last_collection'] = datetime.now()

                    # Calculate next collection time (minimum interval)
    next_interval = min(self.system_interval, self.application_interval)
                    await asyncio.sleep(next_interval)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
    #                 # Log error but continue collection
    #                 try:
                        await self._record_metric(
    #                         "metric_collection_errors",
    #                         MetricCategory.APPLICATION,
    #                         MetricType.COUNTER,
    #                         1,
                            {"error": str(e)}
    #                     )
    #                 except:
    #                     pass
                    await asyncio.sleep(10)  # Wait before retrying

    #     async def _aggregation_loop(self) -None):
    #         """Periodic aggregation loop."""
    #         while self._collecting:
    #             try:
                    await self._aggregate_metrics()
                    await self._save_aggregated_metrics()
                    await asyncio.sleep(self.aggregation_interval)

    #             except asyncio.CancelledError:
    #                 break
    #             except Exception as e:
    #                 # Log error but continue
    #                 try:
                        await self._record_metric(
    #                         "metric_aggregation_errors",
    #                         MetricCategory.APPLICATION,
    #                         MetricType.COUNTER,
    #                         1,
                            {"error": str(e)}
    #                     )
    #                 except:
    #                     pass
                    await asyncio.sleep(30)

    #     async def _collect_system_metrics(self) -None):
    #         """Collect system-level metrics."""
    #         try:
    #             # CPU metrics
    cpu_percent = psutil.cpu_percent(interval=1)
                await self._record_metric(
    #                 "cpu_usage_percent",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 cpu_percent,
    #                 {"component": "system"}
    #             )

    #             # Memory metrics
    memory = psutil.virtual_memory()
                await self._record_metric(
    #                 "memory_usage_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 memory.used,
    #                 {"component": "system"}
    #             )
                await self._record_metric(
    #                 "memory_available_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 memory.available,
    #                 {"component": "system"}
    #             )

    #             # Disk metrics
    disk = psutil.disk_usage('/')
                await self._record_metric(
    #                 "disk_usage_bytes",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 disk.used,
    #                 {"component": "system", "path": "/"}
    #             )

    #             # Network metrics
    network = psutil.net_io_counters()
                await self._record_metric(
    #                 "network_bytes_sent",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.COUNTER,
    #                 network.bytes_sent,
    #                 {"component": "system"}
    #             )
                await self._record_metric(
    #                 "network_bytes_received",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.COUNTER,
    #                 network.bytes_recv,
    #                 {"component": "system"}
    #             )

    #             # Process count
    process_count = len(psutil.pids())
                await self._record_metric(
    #                 "process_count",
    #                 MetricCategory.SYSTEM,
    #                 MetricType.GAUGE,
    #                 process_count,
    #                 {"component": "system"}
    #             )

                # System info (static, collected once)
    #             if not hasattr(self, '_system_info_collected'):
                    await self._record_metric(
    #                     "system_info",
    #                     MetricCategory.SYSTEM,
    #                     MetricType.GAUGE,
    #                     1,
    #                     {
                            "hostname": socket.gethostname(),
                            "platform": platform.platform(),
                            "python_version": platform.python_version(),
                            "cpu_count": psutil.cpu_count()
    #                     }
    #                 )
    self._system_info_collected = True

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to collect system metrics: {str(e)}",
    #                 MetricsErrorCodes.SYSTEM_METRIC_FAILED
    #             )

    #     async def _collect_application_metrics(self) -None):
    #         """Collect application-level metrics."""
    #         try:
    #             # These would typically be updated by other components
    #             # Here we just ensure the metrics exist and are up-to-date

    #             # Update uptime
    uptime = (datetime.now() - self._stats['start_time']).total_seconds()
                await self._record_metric(
    #                 "application_uptime_seconds",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.GAUGE,
    #                 uptime,
    #                 {"component": "application"}
    #             )

    #             # Update total metrics collected
                await self._record_metric(
    #                 "metrics_collected_total",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 self._stats['total_metrics'],
    #                 {"component": "metrics_collector"}
    #             )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to collect application metrics: {str(e)}",
    #                 MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def _collect_custom_metrics(self) -None):
    #         """Collect custom metrics."""
    #         try:
    #             for metric_name, metric_func in self.custom_metrics.items():
    #                 try:
    value = metric_func()
    #                     if isinstance(value, (int, float)):
                            await self._record_metric(
    #                             metric_name,
    #                             MetricCategory.CUSTOM,
    #                             MetricType.GAUGE,
    #                             value,
    #                             {"component": "custom"}
    #                         )
    #                 except Exception as e:
    #                     # Log error for individual metric but continue
                        await self._record_metric(
    #                         "custom_metric_errors",
    #                         MetricCategory.APPLICATION,
    #                         MetricType.COUNTER,
    #                         1,
                            {"metric": metric_name, "error": str(e)}
    #                     )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to collect custom metrics: {str(e)}",
    #                 MetricsErrorCodes.CUSTOM_METRIC_FAILED
    #             )

    #     async def _record_metric(
    #         self,
    #         name: str,
    #         category: MetricCategory,
    #         metric_type: MetricType,
    #         value: Union[float, int, Dict[str, float]],
    #         tags: Dict[str, str]
    #     ) -None):
    #         """Record a metric value."""
    #         try:
    metric_value = MetricValue(
    timestamp = datetime.now(),
    value = value,
    tags = tags
    #             )

    #             # Add to buffer
    #             with self._lock:
                    self.metrics_buffer[name].append(metric_value)
    self._stats['total_metrics'] + = 1

    #             # Save to file
                await self._save_metric(name, category, metric_type, metric_value)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to record metric {name}: {str(e)}",
    #                 MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def _save_metric(
    #         self,
    #         name: str,
    #         category: MetricCategory,
    #         metric_type: MetricType,
    #         metric_value: MetricValue
    #     ) -None):
    #         """Save metric to file."""
    #         try:
    metric_data = {
                    'timestamp': metric_value.timestamp.isoformat(),
    #                 'name': name,
    #                 'category': category.value,
    #                 'type': metric_type.value,
    #                 'value': metric_value.value,
    #                 'tags': metric_value.tags
    #             }

    #             with open(self.metrics_file, 'a', encoding='utf-8') as f:
    f.write(json.dumps(metric_data, default = str) + '\n')

    #         except IOError as e:
                raise MetricsException(
                    f"Failed to save metric: {str(e)}",
    #                 MetricsErrorCodes.STORAGE_ERROR
    #             )

    #     async def record_api_request(
    #         self,
    #         endpoint: str,
    #         response_time: float,
    status_code: int = 200,
    method: str = "GET"
    #     ) -None):
    #         """
    #         Record an API request metric.

    #         Args:
    #             endpoint: API endpoint
    #             response_time: Response time in seconds
    #             status_code: HTTP status code
    #             method: HTTP method
    #         """
    #         try:
    #             # Increment total requests
                await self._record_metric(
    #                 "api_requests_total",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 1,
                    {"endpoint": endpoint, "method": method, "status": str(status_code)}
    #             )

    #             # Record response time
                await self._record_metric(
    #                 "api_response_time_seconds",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.TIMER,
    #                 response_time,
                    {"endpoint": endpoint, "method": method, "status": str(status_code)}
    #             )

    #             # Record error if status indicates error
    #             if status_code >= 400:
                    await self._record_metric(
    #                     "api_errors_total",
    #                     MetricCategory.APPLICATION,
    #                     MetricType.COUNTER,
    #                     1,
                        {"endpoint": endpoint, "method": method, "status": str(status_code)}
    #                 )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to record API request metric: {str(e)}",
    #                 MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     async def record_ai_request(
    #         self,
    #         model: str,
    #         tokens_used: int,
    #         response_time: float,
    #         cost: float,
    success: bool = True
    #     ) -None):
    #         """
    #         Record an AI request metric.

    #         Args:
    #             model: AI model name
    #             tokens_used: Number of tokens used
    #             response_time: Response time in seconds
    #             cost: Cost in dollars
    #             success: Whether the request was successful
    #         """
    #         try:
    #             # Increment total requests
                await self._record_metric(
    #                 "ai_requests_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 1,
                    {"model": model, "success": str(success)}
    #             )

    #             # Record tokens used
                await self._record_metric(
    #                 "ai_tokens_used_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 tokens_used,
    #                 {"model": model}
    #             )

    #             # Record response time
                await self._record_metric(
    #                 "ai_response_time_seconds",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.TIMER,
    #                 response_time,
    #                 {"model": model}
    #             )

    #             # Record cost
                await self._record_metric(
    #                 "ai_cost_total",
    #                 MetricCategory.AI_PROVIDER,
    #                 MetricType.COUNTER,
    #                 cost,
    #                 {"model": model}
    #             )

    #             # Record error if not successful
    #             if not success:
                    await self._record_metric(
    #                     "ai_errors_total",
    #                     MetricCategory.AI_PROVIDER,
    #                     MetricType.COUNTER,
    #                     1,
    #                     {"model": model}
    #                 )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to record AI request metric: {str(e)}",
    #                 MetricsErrorCodes.AI_METRIC_FAILED
    #             )

    #     async def record_sandbox_execution(
    #         self,
    #         operation: str,
    #         execution_time: float,
    memory_used: Optional[int] = None,
    success: bool = True
    #     ) -None):
    #         """
    #         Record a sandbox execution metric.

    #         Args:
    #             operation: Type of operation
    #             execution_time: Execution time in seconds
    #             memory_used: Memory used in bytes
    #             success: Whether the execution was successful
    #         """
    #         try:
    #             # Increment total executions
                await self._record_metric(
    #                 "sandbox_executions_total",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.COUNTER,
    #                 1,
                    {"operation": operation, "success": str(success)}
    #             )

    #             # Record execution time
                await self._record_metric(
    #                 "sandbox_execution_time_seconds",
    #                 MetricCategory.SANDBOX,
    #                 MetricType.TIMER,
    #                 execution_time,
    #                 {"operation": operation}
    #             )

    #             # Record memory usage if provided
    #             if memory_used is not None:
                    await self._record_metric(
    #                     "sandbox_memory_usage_bytes",
    #                     MetricCategory.SANDBOX,
    #                     MetricType.GAUGE,
    #                     memory_used,
    #                     {"operation": operation}
    #                 )

    #             # Record error if not successful
    #             if not success:
                    await self._record_metric(
    #                     "sandbox_errors_total",
    #                     MetricCategory.SANDBOX,
    #                     MetricType.COUNTER,
    #                     1,
    #                     {"operation": operation}
    #                 )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to record sandbox execution metric: {str(e)}",
    #                 MetricsErrorCodes.SANDBOX_METRIC_FAILED
    #             )

    #     async def record_database_query(
    #         self,
    #         query_type: str,
    #         execution_time: float,
    success: bool = True,
    table: Optional[str] = None
    #     ) -None):
    #         """
    #         Record a database query metric.

    #         Args:
                query_type: Type of query (SELECT, INSERT, UPDATE, DELETE)
    #             execution_time: Execution time in seconds
    #             success: Whether the query was successful
    #             table: Table name
    #         """
    #         try:
    #             # Increment total queries
                await self._record_metric(
    #                 "database_queries_total",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 1,
                    {"query_type": query_type, "success": str(success), "table": table or "unknown"}
    #             )

    #             # Record query time
                await self._record_metric(
    #                 "database_query_time_seconds",
    #                 MetricCategory.APPLICATION,
    #                 MetricType.TIMER,
    #                 execution_time,
    #                 {"query_type": query_type, "table": table or "unknown"}
    #             )

    #             # Record error if not successful
    #             if not success:
                    await self._record_metric(
    #                     "database_errors_total",
    #                     MetricCategory.APPLICATION,
    #                     MetricType.COUNTER,
    #                     1,
    #                     {"query_type": query_type, "table": table or "unknown"}
    #                 )

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to record database query metric: {str(e)}",
    #                 MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             )

    #     def register_custom_metric(
    #         self,
    #         name: str,
    #         metric_func: Callable[[], Union[float, int]],
    description: str = "",
    unit: str = ""
    #     ) -None):
    #         """
    #         Register a custom metric.

    #         Args:
    #             name: Metric name
    #             metric_func: Function that returns the metric value
    #             description: Metric description
    #             unit: Metric unit
    #         """
    #         try:
    self.custom_metrics[name] = metric_func

    #             # Create metric definition
    #             metric_def = MetricDefinition(
    name = name,
    category = MetricCategory.CUSTOM,
    metric_type = MetricType.GAUGE,
    description = description,
    unit = unit,
    tags = {"component": "custom"}
    #             )
    self.metric_definitions[name] = metric_def

    #             # Save custom metric definition
                self._save_custom_metric_definition(metric_def)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to register custom metric {name}: {str(e)}",
    #                 MetricsErrorCodes.CUSTOM_METRIC_FAILED
    #             )

    #     def _save_custom_metric_definition(self, metric_def: MetricDefinition) -None):
    #         """Save custom metric definition to file."""
    #         try:
    #             # Load existing custom metrics
    #             if self.custom_metrics_file.exists():
    #                 with open(self.custom_metrics_file, 'r', encoding='utf-8') as f:
    data = json.load(f)
    #             else:
    data = {"custom_metrics": {}}

    #             # Add new metric definition
    metric_dict = asdict(metric_def)
    metric_dict['category'] = metric_def.category.value
    metric_dict['metric_type'] = metric_def.metric_type.value
    data["custom_metrics"][metric_def.name] = metric_dict

    #             # Save back to file
    #             with open(self.custom_metrics_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent = 2)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to save custom metric definition: {str(e)}",
    #                 MetricsErrorCodes.STORAGE_ERROR
    #             )

    #     async def _aggregate_metrics(self) -None):
    #         """Aggregate metrics over time windows."""
    #         try:
    time_windows = [60, 300, 900, 3600]  # 1min, 5min, 15min, 1hour

    #             for window in time_windows:
                    await self._aggregate_metrics_for_window(window)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to aggregate metrics: {str(e)}",
    #                 MetricsErrorCodes.AGGREGATION_FAILED
    #             )

    #     async def _aggregate_metrics_for_window(self, time_window: int) -None):
    #         """Aggregate metrics for a specific time window."""
    #         try:
    cutoff_time = datetime.now() - timedelta(seconds=time_window)
    aggregated = {}

    #             for metric_name, metric_values in self.metrics_buffer.items():
    #                 # Filter values by time window
    recent_values = [
    #                     mv for mv in metric_values
    #                     if mv.timestamp >= cutoff_time
    #                 ]

    #                 if not recent_values:
    #                     continue

    #                 # Get metric definition
    #                 metric_def = self.metric_definitions.get(metric_name)
    #                 if not metric_def:
    #                     continue

    #                 # Extract numeric values
    numeric_values = []
    #                 for mv in recent_values:
    #                     if isinstance(mv.value, (int, float)):
                            numeric_values.append(mv.value)
    #                     elif isinstance(mv.value, dict):
    #                         # For histogram metrics, extract sum
                            numeric_values.append(mv.value.get('sum', 0))

    #                 if not numeric_values:
    #                     continue

    #                 # Calculate aggregations based on metric type
    aggregation = {}

    #                 if metric_def.metric_type == MetricType.COUNTER:
    aggregation['sum'] = sum(numeric_values)
    aggregation['rate'] = aggregation['sum'] / time_window
    #                 elif metric_def.metric_type == MetricType.GAUGE:
    aggregation['latest'] = numeric_values[ - 1]
    aggregation['avg'] = statistics.mean(numeric_values)
    aggregation['min'] = min(numeric_values)
    aggregation['max'] = max(numeric_values)
    #                 elif metric_def.metric_type == MetricType.TIMER:
    aggregation['count'] = len(numeric_values)
    aggregation['sum'] = sum(numeric_values)
    aggregation['avg'] = statistics.mean(numeric_values)
    aggregation['min'] = min(numeric_values)
    aggregation['max'] = max(numeric_values)
    #                     if len(numeric_values) 1):
    aggregation['std_dev'] = statistics.stdev(numeric_values)
    #                     # Calculate percentiles
    sorted_values = sorted(numeric_values)
    n = len(sorted_values)
    aggregation['p50'] = sorted_values[int(n * 0.5])
    aggregation['p95'] = sorted_values[int(n * 0.95])
    aggregation['p99'] = sorted_values[int(n * 0.99])
    #                 elif metric_def.metric_type == MetricType.RATE:
    aggregation['avg_rate'] = statistics.mean(numeric_values)
    aggregation['max_rate'] = max(numeric_values)

    #                 # Create aggregated metric
    aggregated_metric = AggregatedMetric(
    metric_name = metric_name,
    category = metric_def.category,
    metric_type = metric_def.metric_type,
    time_window = time_window,
    aggregation = aggregation,
    tags = metric_def.tags,
    timestamp = datetime.now()
    #                 )

    aggregated[f"{metric_name}_{time_window}s"] = asdict(aggregated_metric)

    #             # Save aggregated metrics for this window
                await self._save_aggregated_metrics_window(time_window, aggregated)

    #         except Exception as e:
                raise MetricsException(
    #                 f"Failed to aggregate metrics for window {time_window}: {str(e)}",
    #                 MetricsErrorCodes.AGGREGATION_FAILED
    #             )

    #     async def _save_aggregated_metrics_window(
    #         self,
    #         time_window: int,
    #         aggregated: Dict[str, Any]
    #     ) -None):
    #         """Save aggregated metrics for a time window."""
    #         try:
    #             # Load existing aggregated metrics
    #             if self.aggregated_file.exists():
    #                 with open(self.aggregated_file, 'r', encoding='utf-8') as f:
    data = json.load(f)
    #             else:
    data = {"generated_at": datetime.now().isoformat(), "metrics": {}}

    #             # Update metrics for this window
    window_key = f"{time_window}s"
    #             if window_key not in data["metrics"]:
    data["metrics"][window_key] = {}

                data["metrics"][window_key].update(aggregated)
    data["generated_at"] = datetime.now().isoformat()

    #             # Save back to file
    #             with open(self.aggregated_file, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent = 2, default=str)

    #         except Exception as e:
                raise MetricsException(
                    f"Failed to save aggregated metrics: {str(e)}",
    #                 MetricsErrorCodes.STORAGE_ERROR
    #             )

    #     async def _save_aggregated_metrics(self) -None):
    #         """Save all aggregated metrics."""
    #         try:
    #             # This is called periodically to ensure all metrics are saved
                await self._aggregate_metrics()

    #         except Exception as e:
    #             # Don't raise exception for aggregation failures
    #             pass

    #     async def get_metrics(
    #         self,
    metric_names: Optional[List[str]] = None,
    category: Optional[MetricCategory] = None,
    since: Optional[datetime] = None,
    until: Optional[datetime] = None,
    limit: int = 1000
    #     ) -Dict[str, Any]):
    #         """
    #         Get metrics with filtering.

    #         Args:
    #             metric_names: Filter by metric names
    #             category: Filter by category
    #             since: Filter by start time
    #             until: Filter by end time
    #             limit: Maximum number of metrics

    #         Returns:
    #             Dictionary containing metrics
    #         """
    #         try:
    metrics = []

    #             for metric_name, metric_values in self.metrics_buffer.items():
    #                 if metric_names and metric_name not in metric_names:
    #                     continue

    #                 metric_def = self.metric_definitions.get(metric_name)
    #                 if not metric_def:
    #                     continue

    #                 if category and metric_def.category != category:
    #                     continue

    #                 for metric_value in metric_values:
    #                     if since and metric_value.timestamp < since:
    #                         continue
    #                     if until and metric_value.timestamp until):
    #                         continue

    metric_data = {
    #                         'name': metric_name,
    #                         'category': metric_def.category.value,
    #                         'type': metric_def.metric_type.value,
                            'timestamp': metric_value.timestamp.isoformat(),
    #                         'value': metric_value.value,
    #                         'tags': metric_value.tags
    #                     }
                        metrics.append(metric_data)

                # Sort by timestamp (newest first) and apply limit
    metrics.sort(key = lambda x: x['timestamp'], reverse=True)
    metrics = metrics[:limit]

    #             return {
    #                 'success': True,
    #                 'metrics': metrics,
                    'count': len(metrics),
    #                 'filters': {
    #                     'metric_names': metric_names,
    #                     'category': category.value if category else None,
    #                     'since': since.isoformat() if since else None,
    #                     'until': until.isoformat() if until else None,
    #                     'limit': limit
    #                 }
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             }

    #     async def get_aggregated_metrics(
    #         self,
    time_window: Optional[int] = None,
    metric_names: Optional[List[str]] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Get aggregated metrics.

    #         Args:
    #             time_window: Time window in seconds
    #             metric_names: Filter by metric names

    #         Returns:
    #             Dictionary containing aggregated metrics
    #         """
    #         try:
    #             if not self.aggregated_file.exists():
    #                 return {
    #                     'success': False,
    #                     'error': 'No aggregated metrics available',
    #                     'error_code': MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #                 }

    #             with open(self.aggregated_file, 'r', encoding='utf-8') as f:
    data = json.load(f)

    result = {
    #                 'success': True,
    #                 'generated_at': data['generated_at'],
    #                 'metrics': {}
    #             }

    #             # Filter by time window
    #             if time_window:
    window_key = f"{time_window}s"
    #                 if window_key in data['metrics']:
    window_metrics = data['metrics'][window_key]

    #                     # Filter by metric names
    #                     if metric_names:
    window_metrics = {
    #                             k: v for k, v in window_metrics.items()
    #                             if any(name in k for name in metric_names)
    #                         }

    result['metrics'][window_key] = window_metrics
    #             else:
    #                 # Return all time windows
    #                 for window_key, window_metrics in data['metrics'].items():
    #                     if window_key == 'generated_at':
    #                         continue

    #                     # Filter by metric names
    #                     if metric_names:
    window_metrics = {
    #                             k: v for k, v in window_metrics.items()
    #                             if any(name in k for name in metric_names)
    #                         }

    result['metrics'][window_key] = window_metrics

    #             return result

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': str(e),
    #                 'error_code': MetricsErrorCodes.METRIC_COLLECTION_FAILED
    #             }

    #     async def export_metrics(
    #         self,
    #         file_path: str,
    format_type: str = 'json',
    include_aggregated: bool = True,
    filters: Optional[Dict[str, Any]] = None
    #     ) -Dict[str, Any]):
    #         """
    #         Export metrics to a file.

    #         Args:
    #             file_path: Path to export file
                format_type: Export format ('json', 'csv', 'prometheus')
    #             include_aggregated: Include aggregated metrics
    #             filters: Filters to apply

    #         Returns:
    #             Dictionary containing export result
    #         """
    #         try:
    #             # Get metrics with filters
    filter_params = filters or {}
    metrics_result = await self.get_metrics( * *filter_params, limit=50000)

    #             if not metrics_result['success']:
    #                 return metrics_result

    metrics = metrics_result['metrics']

    #             # Get aggregated metrics if requested
    aggregated_data = None
    #             if include_aggregated:
    agg_result = await self.get_aggregated_metrics()
    #                 if agg_result['success']:
    aggregated_data = agg_result

    #             # Export based on format
    #             if format_type == 'json':
    export_data = {
    #                     'export_info': {
                            'timestamp': datetime.now().isoformat(),
                            'total_metrics': len(metrics),
    #                         'filters': filter_params,
    #                         'include_aggregated': include_aggregated
    #                     },
    #                     'metrics': metrics,
    #                     'aggregated_metrics': aggregated_data
    #                 }

    #                 with open(file_path, 'w', encoding='utf-8') as f:
    json.dump(export_data, f, indent = 2, default=str)

    #             elif format_type == 'csv':
    #                 import csv

    #                 if metrics:
    #                     # Flatten metrics for CSV
    fieldnames = ['timestamp', 'name', 'category', 'type', 'value', 'tags']

    #                     with open(file_path, 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=fieldnames)
                            writer.writeheader()

    #                         for metric in metrics:
    row = {
    #                                 'timestamp': metric['timestamp'],
    #                                 'name': metric['name'],
    #                                 'category': metric['category'],
    #                                 'type': metric['type'],
    #                                 'value': metric['value'],
                                    'tags': json.dumps(metric['tags'])
    #                             }
                                writer.writerow(row)

    #             elif format_type == 'prometheus':
    #                 # Export in Prometheus format
    #                 with open(file_path, 'w', encoding='utf-8') as f:
    #                     for metric in metrics:
    #                         # Convert metric name to Prometheus format
    prometheus_name = metric['name'].replace('.', '_').replace('-', '_')

    #                         # Add tags as labels
    #                         labels = ','.join(f'{k}="{v}"' for k, v in metric['tags'].items())
    #                         if labels:
    prometheus_name = f'{prometheus_name}{{{labels}}}'

                            f.write(f'{prometheus_name} {metric["value"]}\n')
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': f"Unsupported format: {format_type}",
    #                     'error_code': MetricsErrorCodes.EXPORT_FAILED
    #                 }

    #             return {
    #                 'success': True,
    #                 'message': f"Metrics exported to {file_path}",
    #                 'format': format_type,
                    'count': len(metrics),
    #                 'file_path': file_path
    #             }

    #         except Exception as e:
    #             return {
    #                 'success': False,
                    'error': f"Error exporting metrics: {str(e)}",
    #                 'error_code': MetricsErrorCodes.EXPORT_FAILED
    #             }

    #     def get_metrics_stats(self) -Dict[str, Any]):
    #         """Get metrics collection statistics."""
    uptime = datetime.now() - self._stats['start_time']

    #         return {
    #             'collecting': self._collecting,
    #             'total_metrics': self._stats['total_metrics'],
    #             'total_collections': self._stats['total_collections'],
                'uptime_seconds': uptime.total_seconds(),
                'start_time': self._stats['start_time'].isoformat(),
                'last_collection': self._stats['last_collection'].isoformat(),
    #             'metrics_buffer_sizes': {
    #                 name: len(values) for name, values in self.metrics_buffer.items()
    #             },
                'registered_metrics': len(self.metric_definitions),
                'custom_metrics': len(self.custom_metrics),
    #             'collection_intervals': {
    #                 'system': self.system_interval,
    #                 'application': self.application_interval,
    #                 'aggregation': self.aggregation_interval
    #             }
    #         }

    #     def increment_counter(self, name: str, value: int = 1, tags: Optional[Dict[str, str]] = None) -None):
    #         """
    #         Increment a counter metric (synchronous for convenience).

    #         Args:
    #             name: Metric name
    #             value: Value to increment by
    #             tags: Additional tags
    #         """
    #         try:
    #             # Create async task to avoid blocking
                asyncio.create_task(self._record_metric(
    #                 name,
    #                 MetricCategory.APPLICATION,
    #                 MetricType.COUNTER,
    #                 value,
    #                 tags or {}
    #             ))
    #         except:
    #             pass  # Don't let metric failures break application

    #     def set_gauge(self, name: str, value: float, tags: Optional[Dict[str, str]] = None) -None):
    #         """
    #         Set a gauge metric value (synchronous for convenience).

    #         Args:
    #             name: Metric name
    #             value: Value to set
    #             tags: Additional tags
    #         """
    #         try:
    #             # Create async task to avoid blocking
                asyncio.create_task(self._record_metric(
    #                 name,
    #                 MetricCategory.APPLICATION,
    #                 MetricType.GAUGE,
    #                 value,
    #                 tags or {}
    #             ))
    #         except:
    #             pass  # Don't let metric failures break application

    #     def record_timer(self, name: str, value: float, tags: Optional[Dict[str, str]] = None) -None):
    #         """
    #         Record a timer metric value (synchronous for convenience).

    #         Args:
    #             name: Metric name
    #             value: Time value in seconds
    #             tags: Additional tags
    #         """
    #         try:
    #             # Create async task to avoid blocking
                asyncio.create_task(self._record_metric(
    #                 name,
    #                 MetricCategory.APPLICATION,
    #                 MetricType.TIMER,
    #                 value,
    #                 tags or {}
    #             ))
    #         except:
    #             pass  # Don't let metric failures break application