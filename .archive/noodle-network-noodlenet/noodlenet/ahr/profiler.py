"""
Ahr::Profiler - profiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Profiler voor Adaptive Hybrid Runtime - Hotspot detectie en performance monitoring
"""

import time
import asyncio
import threading
import psutil
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from collections import defaultdict, deque
from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from .ahr_base import ExecutionMode, ModelComponent, ModelProfile

logger = logging.getLogger(__name__)


@dataclass
class ProfileSession:
    """Profielsessie voor performance monitoring"""
    
    session_id: str
    model_id: str
    component_id: str
    start_time: float
    end_time: Optional[float] = None
    samples: List[Dict[str, Any]] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def add_sample(self, timestamp: float, metrics: Dict[str, Any]):
        """Voeg een sample toe aan de sessie"""
        self.samples.append({
            'timestamp': timestamp,
            'metrics': metrics
        })
    
    def get_duration(self) -> float:
        """Krijg de duur van de sessie"""
        if self.end_time:
            return self.end_time - self.start_time
        return time.time() - self.start_time
    
    def get_average_metrics(self) -> Dict[str, float]:
        """Krijg gemiddelde metrics"""
        if not self.samples:
            return {}
        
        total_metrics = defaultdict(float)
        count = len(self.samples)
        
        for sample in self.samples:
            for key, value in sample['metrics'].items():
                if isinstance(value, (int, float)):
                    total_metrics[key] += value
        
        return {key: total / count for key, total in total_metrics.items()}
    
    def is_completed(self) -> bool:
        """Controleer of de sessie voltooid is"""
        return self.end_time is not None


class PerformanceProfiler:
    """Performance profiler voor AHR componenten"""
    
    def __init__(self, mesh: NoodleMesh, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de performance profiler
        
        Args:
            mesh: NoodleMesh instantie
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.config = config or NoodleNetConfig()
        
        # Profiel sessies
        self.active_sessions: Dict[str, ProfileSession] = {}
        self.completed_sessions: Dict[str, ProfileSession] = {}
        
        # Sessie counter
        self._session_counter = 0
        
        # Resource monitoring
        self.resource_samples: deque = deque(maxlen=1000)
        self._resource_monitoring = False
        self._resource_monitor_task = None
        
        # Hotspot detectie
        self.hotspots: Dict[str, List[Dict[str, Any]]] = defaultdict(list)
        self.hotspot_thresholds = {
            'execution_time': 100.0,  # ms
            'cpu_usage': 0.8,  # 80%
            'memory_usage': 0.9,  # 90%
            'error_rate': 0.05  # 5%
        }
        
        # Event handlers
        self.hotspot_detected_handler: Optional[Callable] = None
        self.session_completed_handler: Optional[Callable] = None
        
        # Threading
        self._lock = threading.Lock()
        
    async def start_profiling(self, model_id: str, component_id: str,
                            metadata: Optional[Dict[str, Any]] = None) -> str:
        """
        Start een nieuwe profielsessie
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            metadata: Extra metadata voor de sessie
            
        Returns:
            Sessie ID
        """
        session_id = self._generate_session_id()
        
        with self._lock:
            session = ProfileSession(
                session_id=session_id,
                model_id=model_id,
                component_id=component_id,
                start_time=time.time(),
                metadata=metadata or {}
            )
            
            self.active_sessions[session_id] = session
        
        logger.info(f"Started profiling session {session_id} for {model_id}.{component_id}")
        
        return session_id
    
    def stop_profiling(self, session_id: str) -> Optional[ProfileSession]:
        """
        Stop een profielsessie
        
        Args:
            session_id: ID van de sessie
            
        Returns:
            Voltooide ProfileSession of None als niet gevonden
        """
        with self._lock:
            if session_id not in self.active_sessions:
                logger.warning(f"Session {session_id} not found")
                return None
            
            session = self.active_sessions.pop(session_id)
            session.end_time = time.time()
            
            # Verplaats naar voltooide sessies
            self.completed_sessions[session_id] = session
            
            # Roep event handler aan
            if self.session_completed_handler:
                self.session_completed_handler(session)
            
            logger.info(f"Stopped profiling session {session_id}")
            
            return session
    
    def add_sample(self, session_id: str, timestamp: float, metrics: Dict[str, Any]):
        """
        Voeg een sample toe aan een profielsessie
        
        Args:
            session_id: ID van de sessie
            timestamp: Tijdstempel van de sample
            metrics: Metriek data
        """
        with self._lock:
            if session_id not in self.active_sessions:
                logger.warning(f"Session {session_id} not found for sample")
                return
            
            session = self.active_sessions[session_id]
            session.add_sample(timestamp, metrics)
            
            # Controleer op hotspots
            self._check_hotspots(session, metrics)
    
    def add_resource_sample(self, metrics: Dict[str, Any]):
        """
        Voeg een resource sample toe voor globale monitoring
        
        Args:
            metrics: Resource metrieken
        """
        self.resource_samples.append({
            'timestamp': time.time(),
            'metrics': metrics
        })
    
    def get_session(self, session_id: str) -> Optional[ProfileSession]:
        """Krijg een profielsessie op ID"""
        with self._lock:
            return self.active_sessions.get(session_id) or self.completed_sessions.get(session_id)
    
    def get_active_sessions(self) -> List[ProfileSession]:
        """Krijg alle actieve profielsessies"""
        with self._lock:
            return list(self.active_sessions.values())
    
    def get_completed_sessions(self, limit: int = 100) -> List[ProfileSession]:
        """Krijg recent voltooide profielsessies"""
        with self._lock:
            sessions = list(self.completed_sessions.values())
            return sorted(sessions, key=lambda s: s.end_time or 0, reverse=True)[:limit]
    
    def get_session_statistics(self, session_id: str) -> Optional[Dict[str, Any]]:
        """
        Krijg statistieken voor een profielsessie
        
        Args:
            session_id: ID van de sessie
            
        Returns:
            Statistieken dictionary of None als niet gevonden
        """
        session = self.get_session(session_id)
        if not session:
            return None
        
        return {
            'session_id': session_id,
            'model_id': session.model_id,
            'component_id': session.component_id,
            'duration': session.get_duration(),
            'sample_count': len(session.samples),
            'average_metrics': session.get_average_metrics(),
            'metadata': session.metadata,
            'start_time': session.start_time,
            'end_time': session.end_time
        }
    
    def get_hotspots(self, model_id: Optional[str] = None, 
                    component_id: Optional[str] = None,
                    limit: int = 50) -> List[Dict[str, Any]]:
        """
        Krijg gedetecteerde hotspots
        
        Args:
            model_id: Filter op model ID
            component_id: Filter op component ID
            limit: Maximum aantal resultaten
            
        Returns:
            Lijst met hotspot entries
        """
        hotspots = []
        
        for target_id, target_hotspots in self.hotspots.items():
            if model_id or component_id:
                target_model_id, target_comp_id = target_id.split('.')
                if (model_id and target_model_id != model_id) or \
                   (component_id and target_comp_id != component_id):
                    continue
            
            hotspots.extend(target_hotspots)
        
        # Sorteer op ernst (timestamp descending)
        hotspots.sort(key=lambda h: h['timestamp'], reverse=True)
        
        return hotspots[:limit]
    
    def set_hotspot_threshold(self, metric_name: str, threshold: float):
        """
        Stel een hotspot drempel in
        
        Args:
            metric_name: Naam van de metriek
            threshold: Nieuwe drempelwaarde
        """
        if metric_name in self.hotspot_thresholds:
            self.hotspot_thresholds[metric_name] = threshold
            logger.info(f"Updated hotspot threshold {metric_name} to {threshold}")
        else:
            logger.warning(f"Unknown hotspot metric: {metric_name}")
    
    def _check_hotspots(self, session: ProfileSession, metrics: Dict[str, Any]):
        """
        Controleer of de huidige metrics een hotspot vertegenwoordigen
        
        Args:
            session: Profielsessie
            metrics: Huidige metrics
        """
        target_id = f"{session.model_id}.{session.component_id}"
        
        hotspot_found = False
        hotspot_type = None
        hotspot_value = None
        
        # Controleer execution time
        if 'execution_time' in metrics:
            if metrics['execution_time'] > self.hotspot_thresholds['execution_time']:
                hotspot_found = True
                hotspot_type = 'execution_time'
                hotspot_value = metrics['execution_time']
        
        # Controleer CPU usage
        if 'cpu_usage' in metrics:
            if metrics['cpu_usage'] > self.hotspot_thresholds['cpu_usage']:
                hotspot_found = True
                hotspot_type = 'cpu_usage'
                hotspot_value = metrics['cpu_usage']
        
        # Controleer memory usage
        if 'memory_usage' in metrics:
            if metrics['memory_usage'] > self.hotspot_thresholds['memory_usage']:
                hotspot_found = True
                hotspot_type = 'memory_usage'
                hotspot_value = metrics['memory_usage']
        
        # Controleer error rate
        if 'error_rate' in metrics:
            if metrics['error_rate'] > self.hotspot_thresholds['error_rate']:
                hotspot_found = True
                hotspot_type = 'error_rate'
                hotspot_value = metrics['error_rate']
        
        if hotspot_found:
            hotspot_entry = {
                'timestamp': time.time(),
                'model_id': session.model_id,
                'component_id': session.component_id,
                'hotspot_type': hotspot_type,
                'value': hotspot_value,
                'threshold': self.hotspot_thresholds[hotspot_type],
                'session_id': session.session_id
            }
            
            with self._lock:
                self.hotspots[target_id].append(hotspot_entry)
            
            # Roep event handler aan
            if self.hotspot_detected_handler:
                self.hotspot_detected_handler(hotspot_entry)
            
            logger.warning(f"Hotspot detected in {target_id}: {hotspot_type} = {hotspot_value}")
    
    def _generate_session_id(self) -> str:
        """Genereer een unieke sessie ID"""
        self._session_counter += 1
        return f"session_{int(time.time())}_{self._session_counter}"
    
    def start_resource_monitoring(self, interval: float = 1.0):
        """
        Start resource monitoring
        
        Args:
            interval: Monitoring interval in seconden
        """
        if self._resource_monitoring:
            logger.warning("Resource monitoring is already running")
            return
        
        self._resource_monitoring = True
        self._resource_monitor_task = asyncio.create_task(
            self._resource_monitoring_loop(interval)
        )
        
        logger.info(f"Started resource monitoring with {interval}s interval")
    
    async def _resource_monitoring_loop(self, interval: float):
        """Resource monitoring loop"""
        while self._resource_monitoring:
            try:
                # Verzamel resource metrics
                metrics = self._collect_resource_metrics()
                self.add_resource_sample(metrics)
                
                await asyncio.sleep(interval)
            except Exception as e:
                logger.error(f"Error in resource monitoring loop: {e}")
                await asyncio.sleep(interval)
    
    def stop_resource_monitoring(self):
        """Stop resource monitoring"""
        if not self._resource_monitoring:
            logger.warning("Resource monitoring is not running")
            return
        
        self._resource_monitoring = False
        
        if self._resource_monitor_task:
            self._resource_monitor_task.cancel()
            try:
                asyncio.create_task(self._resource_monitor_task)
            except asyncio.CancelledError:
                pass
        
        self._resource_monitor_task = None
        
        logger.info("Stopped resource monitoring")
    
    def _collect_resource_metrics(self) -> Dict[str, Any]:
        """
        Verzamel system resource metrics
        
        Returns:
            Dictionary met resource metrics
        """
        metrics = {}
        
        try:
            # CPU metrics
            metrics['cpu_usage'] = psutil.cpu_percent()
            metrics['cpu_count'] = psutil.cpu_count()
            
            # Memory metrics
            memory = psutil.virtual_memory()
            metrics['memory_usage'] = memory.percent
            metrics['memory_total'] = memory.total
            metrics['memory_available'] = memory.available
            
            # Disk metrics
            disk = psutil.disk_usage('/')
            metrics['disk_usage'] = disk.percent
            metrics['disk_total'] = disk.total
            metrics['disk_free'] = disk.free
            
            # Network metrics
            net_io = psutil.net_io_counters()
            metrics['network_bytes_sent'] = net_io.bytes_sent
            metrics['network_bytes_recv'] = net_io.bytes_recv
            
        except Exception as e:
            logger.error(f"Error collecting resource metrics: {e}")
        
        return metrics
    
    def get_resource_summary(self, window_seconds: int = 60) -> Dict[str, Any]:
        """
        Krijg een samenvatting van resource usage
        
        Args:
            window_seconds: Tijdvenster in seconden
            
        Returns:
            Dictionary met resource samenvatting
        """
        cutoff_time = time.time() - window_seconds
        
        # Filter samples binnen het venster
        window_samples = [
            sample for sample in self.resource_samples
            if sample['timestamp'] >= cutoff_time
        ]
        
        if not window_samples:
            return {}
        
        # Bereken gemiddelden
        summary = {}
        metrics_keys = window_samples[0]['metrics'].keys()
        
        for key in metrics_keys:
            values = [sample['metrics'][key] for sample in window_samples if key in sample['metrics']]
            if values:
                summary[f'avg_{key}'] = sum(values) / len(values)
                summary[f'max_{key}'] = max(values)
                summary[f'min_{key}'] = min(values)
        
        summary['sample_count'] = len(window_samples)
        summary['window_seconds'] = window_seconds
        
        return summary
    
    def start_profiling_collection(self, interval: float = 0.1):
        """
        Start het automatisch verzamelen van performance data
        
        Args:
            interval: Interval tussen samples in seconden
        """
        # Dit zou een achtergrondtaak moeten starten
        # Voor nu, simuleren we het met een simpele timer
        logger.info(f"Started profiling collection with {interval}s interval")
    
    def stop_profiling_collection(self):
        """Stop het automatisch verzamelen van performance data"""
        logger.info("Stopped profiling collection")
    
    def get_performance_summary(self) -> Dict[str, Any]:
        """
        Krijg een algemene performance samenvatting
        
        Returns:
            Dictionary met performance data
        """
        return {
            'active_sessions': len(self.active_sessions),
            'completed_sessions': len(self.completed_sessions),
            'hotspots_count': sum(len(hs) for hs in self.hotspots.values()),
            'resource_summary': self.get_resource_summary(),
            'recent_hotspots': self.get_hotspots(limit=10)
        }
    
    def clear_completed_sessions(self, older_than_seconds: Optional[float] = None):
        """
        Verwijder voltooide sessies
        
        Args:
            older_than_seconds: Verwijder sessies ouder dan dit aantal seconden
        """
        with self._lock:
            sessions_to_remove = []
            
            for session_id, session in self.completed_sessions.items():
                if older_than_seconds is None:
                    sessions_to_remove.append(session_id)
                elif session.end_time and (time.time() - session.end_time) > older_than_seconds:
                    sessions_to_remove.append(session_id)
            
            for session_id in sessions_to_remove:
                del self.completed_sessions[session_id]
            
            if sessions_to_remove:
                logger.info(f"Cleared {len(sessions_to_remove)} completed sessions")
    
    def clear_hotspots(self, model_id: Optional[str] = None, 
                      component_id: Optional[str] = None,
                      older_than_seconds: Optional[float] = None):
        """
        Verwijder hotspot records
        
        Args:
            model_id: Filter op model ID
            component_id: Filter op component ID
            older_than_seconds: Verwijder records ouder dan dit aantal seconden
        """
        with self._lock:
            targets_to_clear = list(self.hotspots.keys())
            
            for target_id in targets_to_clear:
                target_model_id, target_comp_id = target_id.split('.')
                
                # Filter op model/component
                if model_id and target_model_id != model_id:
                    continue
                if component_id and target_comp_id != component_id:
                    continue
                
                # Verwijder oude records
                if older_than_seconds is not None:
                    cutoff_time = time.time() - older_than_seconds
                    
                    self.hotspots[target_id] = [
                        h for h in self.hotspots[target_id]
                        if h['timestamp'] >= cutoff_time
                    ]
                    
                    # Verwijder target als leeg
                    if not self.hotspots[target_id]:
                        del self.hotspots[target_id]
                else:
                    # Verwijder alle records voor deze target
                    del self.hotspots[target_id]
            
            logger.info("Cleared hotspot records")
    
    def is_monitoring(self) -> bool:
        """Controleer of resource monitoring actief is"""
        return self._resource_monitoring
    
    def set_hotspot_detected_handler(self, handler: Callable):
        """Stel een handler in voor gedetecteerde hotspots"""
        self.hotspot_detected_handler = handler
    
    def set_session_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide sessies"""
        self.session_completed_handler = handler
    
    def is_running(self) -> bool:
        """Controleer of profiler actief is"""
        return self._resource_monitoring or len(self.active_sessions) > 0


