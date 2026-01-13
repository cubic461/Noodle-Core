# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Metrics Collector Module for NoodleCore
# Implements metrics collection from various sources
# """

import logging
import time
import threading
import typing
import typing.Any,
import dataclasses.dataclass,
import enum
import json
import math
import statistics
import collections.deque

logger = logging.getLogger(__name__)


class MetricsCollector
    #     """Metrics collector for distributed execution"""

    #     def __init__(self, collection_interval: float = 30.0, retention: int = 10000):
    #         """Initialize metrics collector

    #         Args:
    #             collection_interval: Interval for collecting metrics in seconds
    #             retention: Number of metrics to retain per metric name
    #         """
    self.collection_interval = collection_interval
    self.retention = retention

    #         # Metrics storage
    self.metrics: Dict[str, deque] = {}
    self.metric_locks: Dict[str, threading.Lock] = {}

    #         # Collection sources
    self.collection_sources: List[Callable] = []
    self.source_threads: Dict[str, threading.Thread] = {}

    #         # Threading
    self._collecting = False
    self._lock = threading.RLock()

    #         # Statistics
    self.statistics = {
    #             'total_metrics': 0,
    #             'collection_sources': 0,
    #             'collection_rate': 0.0,
    #             'last_collection_time': 0.0
    #         }

    #     def start(self):
    #         """Start metrics collection"""
    #         with self._lock:
    #             if self._collecting:
    #                 return

    self._collecting = True

    #             # Start collection threads for each source
    #             for i, source in enumerate(self.collection_sources):
    thread = threading.Thread(
    target = self._collection_worker,
    args = (i, source),
    daemon = True
    #                 )
    self.source_threads[i] = thread
                    thread.start()

                logger.info(f"Started metrics collection from {len(self.collection_sources)} sources")

    #     def stop(self):
    #         """Stop metrics collection"""
    #         with self._lock:
    #             if not self._collecting:
    #                 return

    self._collecting = False

    #             # Wait for threads to stop
    #             for thread in self.source_threads.values():
    #                 if thread and thread.is_alive():
    thread.join(timeout = 5.0)

                logger.info("Stopped metrics collection")

    #     def add_collection_source(self, source: Callable, name: Optional[str] = None):
    #         """
    #         Add a metrics collection source

    #         Args:
    #             source: Function that returns metrics
    #             name: Optional name for the source
    #         """
    #         with self._lock:
    #             if self._collecting:
    #                 return

    source_name = name or f"source_{len(self.collection_sources)}"
                self.collection_sources.append(source)

    #             # Start thread for this source if collection is active
    #             if self._collecting:
    thread = threading.Thread(
    target = self._collection_worker,
    args = math.subtract((len(self.collection_sources), 1, source),)
    daemon = True
    #                 )
    self.source_threads[source_name] = thread
                    thread.start()

    self.statistics['collection_sources'] = len(self.collection_sources)
                logger.info(f"Added metrics collection source: {source_name}")

    #     def remove_collection_source(self, name: Optional[str] = None):
    #         """
    #         Remove a metrics collection source

    #         Args:
    #             name: Name of the source to remove (None for last)
    #         """
    #         with self._lock:
    #             if self._collecting:
    #                 return

    #             if name is None:
    #                 # Remove last source
    #                 if self.collection_sources:
    source_name = f"source_{len(self.collection_sources) - 1}"
    #                     if source_name in self.source_threads:
    thread = self.source_threads[source_name]
    #                         if thread and thread.is_alive():
    thread.join(timeout = 5.0)

    #                         del self.source_threads[source_name]

    #                     if self.collection_sources:
                            self.collection_sources.pop()

    self.statistics['collection_sources'] = len(self.collection_sources)
                    logger.info(f"Removed metrics collection source: {source_name}")
    #             else:
    #                 # Remove specific source
    #                 if name in self.source_threads:
    thread = self.source_threads[name]
    #                     if thread and thread.is_alive():
    thread.join(timeout = 5.0)

    #                     del self.source_threads[name]

    #                 # Find and remove from collection sources
    #                 for i, source in enumerate(self.collection_sources):
    source_name = name or f"source_{i}"
    #                     if source_name == name:
                            self.collection_sources.pop(i)
    #                         break

    self.statistics['collection_sources'] = len(self.collection_sources)
                    logger.info(f"Removed metrics collection source: {name}")

    #     def get_current_metrics(self) -> Dict[str, Any]:
    #         """
    #         Get current metrics from all sources

    #         Returns:
    #             Dictionary of current metrics
    #         """
    current_metrics = {}

    #         # Collect from each source
    #         for source in self.collection_sources:
    #             try:
    source_metrics = source()
    #                 if isinstance(source_metrics, dict):
                        current_metrics.update(source_metrics)
    #             except Exception as e:
                    logger.error(f"Error collecting metrics from source: {e}")

    #         return current_metrics

    #     def get_metrics(self, name: str, since: Optional[float] = None, limit: Optional[int] = None) -> List[Any]:
    #         """
    #         Get metrics for a specific name

    #         Args:
    #             name: Metric name
    #             since: Get metrics since this timestamp
    #             limit: Maximum number of metrics to return

    #         Returns:
    #             List of metrics
    #         """
    #         if name not in self.metrics:
    #             return []

    #         with self.metric_locks[name]:
    metrics = list(self.metrics[name])

    #             # Filter by timestamp
    #             if since is not None:
    #                 metrics = [m for m in metrics if m.timestamp >= since]

    #             # Limit results
    #             if limit is not None:
    metrics = math.subtract(metrics[, limit:])

    #             return metrics

    #     def record_metric(self, name: str, value: Any, tags: Optional[Dict[str, str]] = None):
    #         """
    #         Record a metric

    #         Args:
    #             name: Metric name
    #             value: Metric value
    #             tags: Additional tags
    #         """
    #         # This method is provided for compatibility but doesn't store metrics directly
    #         # Metrics are stored by collection sources
    #         logger.debug(f"Metric {name} recorded with value {value}")

    #     def get_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get collector statistics

    #         Returns:
    #             Statistics dictionary
    #         """
    stats = self.statistics.copy()

    #         # Add metrics count
    #         stats['metrics_count'] = sum(len(self.metrics[name]) for name in self.metrics)

    #         return stats

    #     def _collection_worker(self, source_index: int, source: Callable):
    #         """Background worker for collecting metrics from a source"""
    #         logger.info(f"Started collection worker for source {source_index}")

    #         while self._collecting:
    #             try:
    #                 # Collect metrics from source
    metrics = source()

    #                 if isinstance(metrics, dict):
    #                     # Process each metric
    #                     for metric_name, metric_value in metrics.items():
    #                         # Get or create metric lock
    #                         if metric_name not in self.metric_locks:
    self.metric_locks[metric_name] = threading.Lock()

    #                         # Add metric to storage
    #                         with self.metric_locks[metric_name]:
    #                             if metric_name not in self.metrics:
    self.metrics[metric_name] = deque(maxlen=self.retention)

                                self.metrics[metric_name].append(metric_value)

    #                             # Update statistics
    self.statistics['total_metrics'] + = 1
    self.statistics['last_collection_time'] = time.time()

    #                 # Sleep until next collection
                    time.sleep(self.collection_interval)

    #             except Exception as e:
                    logger.error(f"Error in collection worker {source_index}: {e}")
                    time.sleep(5.0)