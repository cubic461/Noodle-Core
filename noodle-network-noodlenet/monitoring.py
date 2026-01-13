"""
Noodle Network Noodlenet::Monitoring - monitoring.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Comprehensive monitoring system voor NoodleNet - Real-time metrics en alerting
"""

import asyncio
import time
import json
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Tuple
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict, deque
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .mesh import NoodleMesh, NodeMetrics
from .scheduler import Task, TaskStatus

logger = logging.getLogger(__name__)


class MetricType(Enum):
    """Types van metrics"""
    COUNTER = "counter"
    GAUGE = "gauge"
    HISTOGRAM = "histogram"
    TIMER = "timer"


class AlertSeverity(Enum):
    """Ernst niveaus voor alerts"""
    INFO = "info"
    WARNING = "warning"
    ERROR = "error"
    CRITICAL = "critical"


class AlertStatus(Enum):
    """Status van alerts"""
    ACTIVE = "active"
    RESOLVED = "resolved"
    SUPPRESSED = "suppressed"


@dataclass
class Metric:
    """Representatie van een metric"""
    
    name: str
    value: float
    metric_type: MetricType
    timestamp: float = field(default_factory=time.time)
    labels: Dict[str, str] = field(default_factory=dict)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'name': self.name,
            'value': self.value,
            'type': self.metric_type.value,
            'timestamp': self.timestamp,
            'labels': self.labels
        }


@dataclass
class MetricFamily:
    """Familie van gerelateerde metrics"""
    
    name: str
    help_text: str
    metric_type: MetricType
    metrics: List[Metric] = field(default_factory=list)
    
    def add_metric(self, value: float, labels: Optional[Dict[str, str]] = None):
        """Voeg een metric toe aan de familie"""
        metric = Metric(
            name=self.name,
            value=value,
            metric_type=self.metric_type,
            labels=labels or {}
        )
        self.metrics.append(metric)
    
    def get_latest(self, labels: Optional[Dict[str, str]] = None) -> Optional[Metric]:
        """Krijg laatste metric met gegeven labels"""
        matching_metrics = self.metrics
        
        if labels:
            for key, value in labels.items():
                matching_metrics = [
                    m for m in matching_metrics
                    if m.labels.get(key) == value
                ]
        
        return matching_metrics[-1] if matching_metrics else None


@dataclass
class AlertRule:
    """Regel voor alert generatie"""
    
    name: str
    description: str
    metric_name: str
    condition: str  # bv. "> 0.9", "!= 0"
    severity: AlertSeverity
    duration: float = 60.0  # seconden
    labels: Dict[str, str] = field(default_factory=dict)
    enabled: bool = True
    
    def evaluate(self, metrics: Dict[str, MetricFamily]) -> bool:
        """
        Evalueer alert regel
        
        Args:
            metrics: Beschikbare metrics
            
        Returns:
            True als alert geactiveerd moet worden
        """
        if self.metric_name not in metrics:
            return False
        
        metric_family = metrics[self.metric_name]
        latest_metric = metric_family.get_latest(self.labels)
        
        if not latest_metric:
            return False
        
        # Parse en evalueer condition
        try:
            # Simple evaluatie voor nu
            # In echte implementatie: meer geavanceerde expression parser
            if self.condition.startswith(">"):
                threshold = float(self.condition[2:].strip())
                return latest_metric.value > threshold
            elif self.condition.startswith("<"):
                threshold = float(self.condition[2:].strip())
                return latest_metric.value < threshold
            elif self.condition.startswith("=="):
                threshold = float(self.condition[2:].strip())
                return abs(latest_metric.value - threshold) < 0.001
            elif self.condition.startswith("!="):
                threshold = float(self.condition[3:].strip())
                return abs(latest_metric.value - threshold) >= 0.001
            elif self.condition == "absent":
                return False  # Metric is aanwezig
            
        except (ValueError, IndexError):
            logger.error(f"Invalid alert condition: {self.condition}")
        
        return False


@dataclass
class Alert:
    """Representatie van een alert"""
    
    alert_id: str
    rule_name: str
    severity: AlertSeverity
    status: AlertStatus
    message: str
    timestamp: float = field(default_factory=time.time)
    resolved_at: Optional[float] = None
    labels: Dict[str, str] = field(default_factory=dict)
    annotations: Dict[str, str] = field(default_factory=dict)
    
    def resolve(self):
        """Los alert op"""
        self.status = AlertStatus.RESOLVED
        self.resolved_at = time.time()
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'alert_id': self.alert_id,
            'rule_name': self.rule_name,
            'severity': self.severity.value,
            'status': self.status.value,
            'message': self.message,
            'timestamp': self.timestamp,
            'resolved_at': self.resolved_at,
            'labels': self.labels,
            'annotations': self.annotations
        }


class MetricsCollector:
    """Collector voor systeem metrics"""
    
    def __init__(self):
        """Initialiseer metrics collector"""
        self._metrics: Dict[str, MetricFamily] = {}
        self._counters: Dict[str, float] = defaultdict(float)
        self._gauges: Dict[str, float] = defaultdict(float)
        self._histograms: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
        self._timers: Dict[str, deque] = defaultdict(lambda: deque(maxlen=1000))
    
    def counter(self, name: str, value: float = 1.0, labels: Optional[Dict[str, str]] = None):
        """
        Verhoog een counter metric
        
        Args:
            name: Naam van de metric
            value: Waarde om toe te voegen
            labels: Labels voor de metric
        """
        key = self._make_key(name, labels)
        self._counters[key] += value
        
        # Update metric family
        self._ensure_metric_family(name, MetricType.COUNTER)
        self._metrics[name].add_metric(self._counters[key], labels)
    
    def gauge(self, name: str, value: float, labels: Optional[Dict[str, str]] = None):
        """
        Stel een gauge metric in
        
        Args:
            name: Naam van de metric
            value: Waarde om in te stellen
            labels: Labels voor de metric
        """
        key = self._make_key(name, labels)
        self._gauges[key] = value
        
        # Update metric family
        self._ensure_metric_family(name, MetricType.GAUGE)
        self._metrics[name].add_metric(value, labels)
    
    def histogram(self, name: str, value: float, labels: Optional[Dict[str, str]] = None):
        """
        Voeg waarde toe aan histogram
        
        Args:
            name: Naam van de metric
            value: Waarde om toe te voegen
            labels: Labels voor de metric
        """
        key = self._make_key(name, labels)
        self._histograms[key].append(value)
        
        # Update metric family met gemiddelde
        if len(self._histograms[key]) > 0:
            avg_value = sum(self._histograms[key]) / len(self._histograms[key])
            self._ensure_metric_family(name, MetricType.HISTOGRAM)
            self._metrics[name].add_metric(avg_value, labels)
    
    def timer(self, name: str, duration: float, labels: Optional[Dict[str, str]] = None):
        """
        Voeg duratie toe aan timer
        
        Args:
            name: Naam van de metric
            duration: Duratie in seconden
            labels: Labels voor de metric
        """
        key = self._make_key(name, labels)
        self._timers[key].append(duration)
        
        # Update metric family met gemiddelde
        if len(self._timers[key]) > 0:
            avg_duration = sum(self._timers[key]) / len(self._timers[key])
            self._ensure_metric_family(name, MetricType.TIMER)
            self._metrics[name].add_metric(avg_duration, labels)
    
    def get_metrics(self) -> Dict[str, MetricFamily]:
        """Krijg alle metrics"""
        return self._metrics.copy()
    
    def get_metric(self, name: str, labels: Optional[Dict[str, str]] = None) -> Optional[Metric]:
        """Krijg specifieke metric"""
        if name not in self._metrics:
            return None
        
        return self._metrics[name].get_latest(labels)
    
    def _make_key(self, name: str, labels: Optional[Dict[str, str]] = None) -> str:
        """Maak unieke key voor metric met labels"""
        if not labels:
            return name
        
        label_str = ",".join(f"{k}={v}" for k, v in sorted(labels.items()))
        return f"{name}[{label_str}]"
    
    def _ensure_metric_family(self, name: str, metric_type: MetricType):
        """Zorg dat metric family bestaat"""
        if name not in self._metrics:
            self._metrics[name] = MetricFamily(
                name=name,
                help_text=f"Metric {name}",
                metric_type=metric_type
            )


class MonitoringSystem:
    """Comprehensive monitoring systeem voor NoodleNet"""
    
    def __init__(self, mesh: NoodleMesh, identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer monitoring systeem
        
        Args:
            mesh: NoodleMesh instance
            identity_manager: NoodleIdentityManager instance
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # Monitoring state
        self._running = False
        self._metrics_collector = MetricsCollector()
        self._alert_rules: Dict[str, AlertRule] = {}
        self._active_alerts: Dict[str, Alert] = {}
        
        # Event handlers
        self._alert_handlers: List[Callable] = []
        
        # Background tasks
        self._collection_task: Optional[asyncio.Task] = None
        self._evaluation_task: Optional[asyncio.Task] = None
        self._cleanup_task: Optional[asyncio.Task] = None
        
        # Statistics
        self._stats = {
            'metrics_collected': 0,
            'alerts_generated': 0,
            'alerts_resolved': 0,
            'collection_errors': 0,
            'evaluation_errors': 0,
        }
    
    async def start(self):
        """Start het monitoring systeem"""
        if self._running:
            logger.warning("Monitoring system is already running")
            return
        
        self._running = True
        
        # Laad standaard alert regels
        self._load_default_alert_rules()
        
        # Start background taken
        self._collection_task = asyncio.create_task(self._collection_loop())
        self._evaluation_task = asyncio.create_task(self._evaluation_loop())
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        logger.info("Monitoring system started")
    
    async def stop(self):
        """Stop het monitoring systeem"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop background taken
        if self._collection_task:
            self._collection_task.cancel()
            try:
                await self._collection_task
            except asyncio.CancelledError:
                pass
        
        if self._evaluation_task:
            self._evaluation_task.cancel()
            try:
                await self._evaluation_task
            except asyncio.CancelledError:
                pass
        
        if self._cleanup_task:
            self._cleanup_task.cancel()
            try:
                await self._cleanup_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Monitoring system stopped")
    
    def add_alert_rule(self, rule: AlertRule):
        """
        Voeg een alert regel toe
        
        Args:
            rule: Alert regel om toe te voegen
        """
        self._alert_rules[rule.name] = rule
        logger.info(f"Alert rule added: {rule.name}")
    
    def remove_alert_rule(self, rule_name: str):
        """
        Verwijder een alert regel
        
        Args:
            rule_name: Naam van de regel
        """
        if rule_name in self._alert_rules:
            del self._alert_rules[rule_name]
            logger.info(f"Alert rule removed: {rule_name}")
    
    def get_metrics(self) -> Dict[str, Any]:
        """
        Krijg alle metrics in Prometheus formaat
        
        Returns:
            Dictionary met metrics
        """
        metrics_data = {}
        
        for name, metric_family in self._metrics_collector.get_metrics().items():
            metrics_data[name] = {
                'help': metric_family.help_text,
                'type': metric_family.metric_type.value,
                'metrics': [metric.to_dict() for metric in metric_family.metrics]
            }
        
        return metrics_data
    
    def get_alerts(self, status: Optional[AlertStatus] = None) -> List[Alert]:
        """
        Krijg alerts
        
        Args:
            status: Filter op status (optioneel)
            
        Returns:
            Lijst met alerts
        """
        alerts = list(self._active_alerts.values())
        
        if status:
            alerts = [alert for alert in alerts if alert.status == status]
        
        return alerts
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Krijg monitoring statistieken
        
        Returns:
            Dictionary met statistieken
        """
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['alert_rules'] = len(self._alert_rules)
        stats['active_alerts'] = len([
            alert for alert in self._active_alerts.values()
            if alert.status == AlertStatus.ACTIVE
        ])
        stats['metrics_families'] = len(self._metrics_collector.get_metrics())
        return stats
    
    async def _collection_loop(self):
        """Loop voor het verzamelen van metrics"""
        while self._running:
            try:
                # Verzamel node metrics
                await self._collect_node_metrics()
                
                # Verzamel mesh metrics
                await self._collect_mesh_metrics()
                
                # Verzamel system metrics
                await self._collect_system_metrics()
                
                # Update statistieken
                self._stats['metrics_collected'] += 1
                
                # Wacht voor volgende collectie
                await asyncio.sleep(self.config.monitoring_interval)
                
            except Exception as e:
                self._stats['collection_errors'] += 1
                logger.error(f"Error in metrics collection: {e}")
                await asyncio.sleep(5)
    
    async def _collect_node_metrics(self):
        """Verzamel metrics van alle nodes"""
        topology = self.mesh.get_topology()
        
        for node_id, node_data in topology['nodes'].items():
            # Basis metrics
            self._metrics_collector.gauge(
                "node_cpu_usage",
                node_data['cpu_usage'],
                labels={'node_id': node_id}
            )
            
            self._metrics_collector.gauge(
                "node_memory_usage",
                node_data['memory_usage'],
                labels={'node_id': node_id}
            )
            
            self._metrics_collector.gauge(
                "node_gpu_usage",
                node_data['gpu_usage'],
                labels={'node_id': node_id}
            )
            
            self._metrics_collector.gauge(
                "node_latency",
                node_data['latency'],
                labels={'node_id': node_id}
            )
            
            self._metrics_collector.gauge(
                "node_bandwidth_down",
                node_data.get('bandwidth_down', 0.0),
                labels={'node_id': node_id}
            )
            
            self._metrics_collector.gauge(
                "node_uptime",
                node_data['uptime'],
                labels={'node_id': node_id}
            )
            
            # Quality score
            self._metrics_collector.gauge(
                "node_quality_score",
                node_data['quality_score'],
                labels={'node_id': node_id}
            )
            
            # Health status
            self._metrics_collector.gauge(
                "node_healthy",
                1.0 if node_data['healthy'] else 0.0,
                labels={'node_id': node_id}
            )
    
    async def _collect_mesh_metrics(self):
        """Verzamel mesh topologie metrics"""
        topology = self.mesh.get_topology()
        
        # Topologie metrics
        self._metrics_collector.gauge(
            "mesh_node_count",
            topology['node_count']
        )
        
        self._metrics_collector.gauge(
            "mesh_edge_count",
            topology['edge_count']
        )
        
        # Mesh statistieken
        mesh_stats = self.mesh.get_stats()
        
        self._metrics_collector.counter(
            "mesh_routes_calculated",
            mesh_stats.get('routes_calculated', 0)
        )
        
        self._metrics_collector.counter(
            "mesh_best_node_selections",
            mesh_stats.get('best_node_selections', 0)
        )
        
        self._metrics_collector.counter(
            "mesh_failed_routes",
            mesh_stats.get('failed_routes', 0)
        )
    
    async def _collect_system_metrics(self):
        """Verzamel systeem metrics"""
        import psutil
        import os
        
        # CPU metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        self._metrics_collector.gauge("system_cpu_usage", cpu_percent)
        
        # Memory metrics
        memory = psutil.virtual_memory()
        self._metrics_collector.gauge("system_memory_usage", memory.percent)
        self._metrics_collector.gauge(
            "system_memory_available",
            memory.available / (1024**3)  # GB
        )
        
        # Disk metrics
        disk = psutil.disk_usage('/')
        self._metrics_collector.gauge(
            "system_disk_usage",
            disk.used / disk.total * 100
        )
        
        # Network metrics
        network = psutil.net_io_counters()
        self._metrics_collector.counter(
            "system_network_bytes_sent",
            network.bytes_sent
        )
        
        self._metrics_collector.counter(
            "system_network_bytes_recv",
            network.bytes_recv
        )
        
        # Process metrics
        process = psutil.Process(os.getpid())
        self._metrics_collector.gauge(
            "process_memory_usage",
            process.memory_info().rss / (1024**2)  # MB
        )
        
        self._metrics_collector.gauge(
            "process_cpu_usage",
            process.cpu_percent()
        )
        
        # Custom NoodleNet metrics
        self._metrics_collector.gauge(
            "noodlenet_connected_nodes",
            len(self.identity_manager.get_all_nodes())
        )
        
        self._metrics_collector.gauge(
            "noodlenet_capabilities_count",
            len(self.identity_manager.get_capabilities_summary())
        )
    
    async def _evaluation_loop(self):
        """Loop voor het evalueren van alert regels"""
        while self._running:
            try:
                # Haal metrics op
                metrics = self._metrics_collector.get_metrics()
                
                # Evalueer elke alert regel
                for rule_name, rule in self._alert_rules.items():
                    if not rule.enabled:
                        continue
                    
                    try:
                        should_alert = rule.evaluate(metrics)
                        alert_key = f"{rule_name}_{hash(tuple(sorted(rule.labels.items())))}"
                        
                        if should_alert:
                            # Check of alert al actief is
                            if alert_key not in self._active_alerts:
                                # Maak nieuwe alert
                                alert = Alert(
                                    alert_id=self._generate_alert_id(),
                                    rule_name=rule_name,
                                    severity=rule.severity,
                                    status=AlertStatus.ACTIVE,
                                    message=f"Alert: {rule.description}",
                                    labels=rule.labels.copy()
                                )
                                
                                self._active_alerts[alert_key] = alert
                                self._stats['alerts_generated'] += 1
                                
                                # Roep handlers aan
                                await self._notify_alert(alert)
                                
                                logger.warning(f"Alert activated: {rule_name}")
                        
                        else:
                            # Controleer of alert opgelost moet worden
                            if alert_key in self._active_alerts:
                                alert = self._active_alerts[alert_key]
                                if alert.status == AlertStatus.ACTIVE:
                                    alert.resolve()
                                    self._stats['alerts_resolved'] += 1
                                    
                                    # Roep handlers aan
                                    await self._notify_alert_resolved(alert)
                                    
                                    logger.info(f"Alert resolved: {rule_name}")
                    
                    except Exception as e:
                        self._stats['evaluation_errors'] += 1
                        logger.error(f"Error evaluating alert rule {rule_name}: {e}")
                
                # Wacht voor volgende evaluatie
                await asyncio.sleep(30)  # Check elke 30 seconden
                
            except Exception as e:
                self._stats['evaluation_errors'] += 1
                logger.error(f"Error in alert evaluation loop: {e}")
                await asyncio.sleep(5)
    
    async def _cleanup_loop(self):
        """Loop voor opruimen van oude data"""
        while self._running:
            try:
                current_time = time.time()
                
                # Verwijder opgeloste alerts ouder dan 24 uur
                resolved_alerts = [
                    key for key, alert in self._active_alerts.items()
                    if alert.status == AlertStatus.RESOLVED and
                       alert.resolved_at and (current_time - alert.resolved_at) > 86400
                ]
                
                for key in resolved_alerts:
                    del self._active_alerts[key]
                
                if resolved_alerts:
                    logger.info(f"Cleaned {len(resolved_alerts)} resolved alerts")
                
                # Wacht voor volgende cleanup
                await asyncio.sleep(3600)  # Elke uur
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(60)
    
    async def _notify_alert(self, alert: Alert):
        """
        Notificeer handlers over nieuwe alert
        
        Args:
            alert: Alert om te notificeren
        """
        for handler in self._alert_handlers:
            try:
                await handler(alert)
            except Exception as e:
                logger.error(f"Error in alert handler: {e}")
    
    async def _notify_alert_resolved(self, alert: Alert):
        """
        Notificeer handlers over opgeloste alert
        
        Args:
            alert: Opgeloste alert
        """
        for handler in self._alert_handlers:
            try:
                await handler(alert)  # Dezelfde handler voor beide events
            except Exception as e:
                logger.error(f"Error in alert resolved handler: {e}")
    
    def _generate_alert_id(self) -> str:
        """Genereer unieke alert ID"""
        import uuid
        return str(uuid.uuid4())
    
    def _load_default_alert_rules(self):
        """Laad standaard alert regels"""
        # High CPU usage alert
        self.add_alert_rule(AlertRule(
            name="high_cpu_usage",
            description="CPU usage is above 90%",
            metric_name="node_cpu_usage",
            condition="> 0.9",
            severity=AlertSeverity.WARNING,
            duration=300  # 5 minuten
        ))
        
        # High memory usage alert
        self.add_alert_rule(AlertRule(
            name="high_memory_usage",
            description="Memory usage is above 90%",
            metric_name="node_memory_usage",
            condition="> 0.9",
            severity=AlertSeverity.WARNING,
            duration=300
        ))
        
        # Node down alert
        self.add_alert_rule(AlertRule(
            name="node_down",
            description="Node is unhealthy",
            metric_name="node_healthy",
            condition="!= 1",
            severity=AlertSeverity.CRITICAL,
            duration=60
        ))
        
        # High latency alert
        self.add_alert_rule(AlertRule(
            name="high_latency",
            description="Node latency is above 100ms",
            metric_name="node_latency",
            condition="> 100",
            severity=AlertSeverity.WARNING,
            duration=300
        ))
        
        # Low quality score alert
        self.add_alert_rule(AlertRule(
            name="low_quality_score",
            description="Node quality score is below 0.5",
            metric_name="node_quality_score",
            condition="< 0.5",
            severity=AlertSeverity.WARNING,
            duration=300
        ))
        
        # System disk usage alert
        self.add_alert_rule(AlertRule(
            name="high_disk_usage",
            description="System disk usage is above 90%",
            metric_name="system_disk_usage",
            condition="> 90",
            severity=AlertSeverity.ERROR,
            duration=600
        ))
    
    def register_alert_handler(self, handler: Callable):
        """
        Registreer een alert handler
        
        Args:
            handler: Handler functie die Alert accepteert
        """
        self._alert_handlers.append(handler)
        logger.info("Alert handler registered")
    
    def is_running(self) -> bool:
        """Controleer of monitoring systeem actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"MonitoringSystem(alerts={len(self._active_alerts)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"MonitoringSystem(rules={len(self._alert_rules)}, "
                f"alerts={len(self._active_alerts)}, "
                f"metrics={len(self._metrics_collector.get_metrics())}, "
                f"running={self._running})")

