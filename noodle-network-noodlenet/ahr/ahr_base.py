"""
Ahr::Ahr Base - ahr_base.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Basis componenten voor Adaptive Hybrid Runtime (AHR) integratie
"""

import time
import asyncio
import logging
import threading
from typing import Dict, List, Optional, Set, Any, Callable
from dataclasses import dataclass, field
from enum import Enum
from ..config import NoodleNetConfig
from ..identity import NodeIdentity, NoodleIdentityManager
from ..mesh import NoodleMesh, NodeMetrics
from ..link import NoodleLink, Message

logger = logging.getLogger(__name__)


class ExecutionMode(Enum):
    """Uitvoeringsmodi voor AI-modellen"""
    INTERPRETER = "interpreter"  # Python/JS engines
    JIT = "jit"  # Just-In-Time compilatie naar NBC
    AOT = "aot"  # Ahead-Of-Time gecompileerd NBC


class ModelComponent:
    """Vertegenwoordigt een component van een AI-model"""
    
    def __init__(self, component_id: str, component_type: str):
        self.component_id = component_id
        self.component_type = component_type  # "dense", "conv", "activation", etc.
        self.execution_mode = ExecutionMode.INTERPRETER
        self.last_executed = 0.0
        self.execution_count = 0
        self.total_execution_time = 0.0
        self.average_latency = 0.0
        self.error_count = 0
        self.optimization_score = 0.0
        
    def update_execution_stats(self, execution_time: float, error: bool = False):
        """Update uitvoeringsstatistieken"""
        self.last_executed = time.time()
        self.execution_count += 1
        self.total_execution_time += execution_time
        self.average_latency = self.total_execution_time / self.execution_count
        
        if error:
            self.error_count += 1
        
        # Update optimization score
        self._calculate_optimization_score()
    
    def _calculate_optimization_score(self):
        """Bereken optimalisatiescore op basis van statistieken"""
        # Lagere latency = hogere score
        # Hogere frequency = hogere score
        # Lagere error rate = hogere score
        
        latency_score = max(0.0, 1.0 - (self.average_latency / 100.0))  # Normaliseer naar 100ms
        frequency_score = min(1.0, self.execution_count / 100.0)  # Normaliseer naar 100 uitvoeringen
        
        if self.execution_count > 0:
            error_rate = self.error_count / self.execution_count
            error_score = max(0.0, 1.0 - error_rate)
        else:
            error_score = 1.0
        
        self.optimization_score = (latency_score * 0.4 + 
                                 frequency_score * 0.3 + 
                                 error_score * 0.3)


@dataclass
class ModelProfile:
    """Profiel voor een AI-model"""
    
    model_id: str
    model_type: str  # "pytorch", "tensorflow", "onnx"
    version: str
    components: Dict[str, ModelComponent] = field(default_factory=dict)
    created_at: float = field(default_factory=time.time)
    last_updated: float = field(default_factory=time.time)
    
    def add_component(self, component: ModelComponent):
        """Voeg een component toe aan het model"""
        self.components[component.component_id] = component
        self.last_updated = time.time()
    
    def get_component(self, component_id: str) -> Optional[ModelComponent]:
        """Krijg een component op ID"""
        return self.components.get(component_id)
    
    def get_total_executions(self) -> int:
        """Krijg totaal aantal uitvoeringen"""
        return sum(comp.execution_count for comp in self.components.values())
    
    def get_average_latency(self) -> float:
        """Krijg gemiddelde latency over alle components"""
        if not self.components:
            return 0.0
        
        total_latency = sum(comp.average_latency for comp in self.components.values())
        return total_latency / len(self.components)
    
    def get_optimization_candidates(self) -> List[ModelComponent]:
        """Krijg componenten die geoptimaliseerd kunnen worden"""
        candidates = []
        
        for component in self.components.values():
            if (component.execution_mode == ExecutionMode.INTERPRETER and 
                component.execution_count > 10 and
                component.optimization_score > 0.5):
                candidates.append(component)
        
        return sorted(candidates, key=lambda c: c.optimization_score, reverse=True)


class ExecutionMetrics:
    """Uitvoeringsmetrieken voor monitoring"""
    
    def __init__(self):
        self.start_time = 0.0
        self.end_time = 0.0
        self.total_time = 0.0
        self.component_times: Dict[str, float] = {}
        self.memory_usage: Dict[str, float] = {}
        self.cpu_usage: float = 0.0
        self.gpu_usage: float = 0.0
        self.error_count: int = 0
        self.warning_count: int = 0
        
    def start(self):
        """Start metingen"""
        self.start_time = time.time()
        self.component_times.clear()
        self.memory_usage.clear()
        self.error_count = 0
        self.warning_count = 0
        
    def end(self):
        """Eindig metingen"""
        self.end_time = time.time()
        self.total_time = self.end_time - self.start_time
        
    def add_component_time(self, component_id: str, execution_time: float):
        """Voeg component uitvoeringstijd toe"""
        self.component_times[component_id] = execution_time
        
    def add_memory_usage(self, component_id: str, memory_mb: float):
        """Voeg geheugengebruik toe"""
        self.memory_usage[component_id] = memory_mb
        
    def add_error(self):
        """Voeg fout toe"""
        self.error_count += 1
        
    def add_warning(self):
        """Voeg waarschuwing toe"""
        self.warning_count += 1
        
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'total_time': self.total_time,
            'component_times': self.component_times,
            'memory_usage': self.memory_usage,
            'cpu_usage': self.cpu_usage,
            'gpu_usage': self.gpu_usage,
            'error_count': self.error_count,
            'warning_count': self.warning_count,
            'start_time': self.start_time,
            'end_time': self.end_time
        }


class AHRBase:
    """Basis klasse voor Adaptive Hybrid Runtime integratie"""
    
    def __init__(self, link: NoodleLink, 
                 identity_manager: NoodleIdentityManager,
                 mesh: NoodleMesh,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de AHR basis
        
        Args:
            link: NoodleLink instantie
            identity_manager: NoodleIdentityManager
            mesh: NoodleMesh instantie
            config: NoodleNet configuratie
        """
        self.link = link
        self.identity_manager = identity_manager
        self.mesh = mesh
        self.config = config or NoodleNetConfig()
        
        # Model profielen
        self.model_profiles: Dict[str, ModelProfile] = {}
        
        # Uitvoeringsstatistieken
        self.execution_history: List[Dict[str, Any]] = []
        self.max_history_size = 1000
        
        # Optimisatie triggers
        self.optimization_triggers: Dict[str, float] = {
            'execution_threshold': 10,  # Minimaal aantal uitvoeringen
            'latency_threshold': 100.0,  # ms
            'error_rate_threshold': 0.05,  # 5%
            'optimization_score_threshold': 0.6
        }
        
        # Event handlers
        self.model_loaded_handler: Optional[Callable] = None
        self.model_optimized_handler: Optional[Callable] = None
        self.execution_completed_handler: Optional[Callable] = None
        
        # Threading
        self._metrics_lock = threading.Lock()
        self._running = False
        
    def register_model(self, model_id: str, model_type: str, version: str = "1.0"):
        """
        Registreer een nieuw model
        
        Args:
            model_id: Unieke ID voor het model
            model_type: Type model (pytorch, tensorflow, onnx)
            version: Model versie
        """
        if model_id in self.model_profiles:
            logger.warning(f"Model {model_id} already registered, updating...")
        
        profile = ModelProfile(model_id, model_type, version)
        self.model_profiles[model_id] = profile
        
        # Roep event handler aan
        if self.model_loaded_handler:
            self.model_loaded_handler(model_id, model_type, version)
        
        logger.info(f"Registered model {model_id} ({model_type} v{version})")
    
    def register_model_component(self, model_id: str, component_id: str, 
                               component_type: str):
        """
        Registreer een component bij een model
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            component_type: Type component
        """
        if model_id not in self.model_profiles:
            logger.error(f"Model {model_id} not registered")
            return
        
        component = ModelComponent(component_id, component_type)
        self.model_profiles[model_id].add_component(component)
        
        logger.debug(f"Registered component {component_id} for model {model_id}")
    
    def record_execution_start(self, model_id: str, component_id: str):
        """
        Start metingen voor een component uitvoering
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            
        Returns:
            ExecutionMetrics instance
        """
        metrics = ExecutionMetrics()
        metrics.start()
        
        # Start component timing
        metrics.add_component_time(component_id, 0.0)
        
        return metrics
    
    def record_execution_end(self, model_id: str, component_id: str, 
                           metrics: ExecutionMetrics, success: bool = True):
        """
        Eindig metingen voor een component uitvoering
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            metrics: ExecutionMetrics instance
            success: Of de uitvoering succesvol was
        """
        metrics.end()
        
        # Update component statistieken
        if model_id in self.model_profiles:
            profile = self.model_profiles[model_id]
            component = profile.get_component(component_id)
            
            if component:
                execution_time = metrics.component_times.get(component_id, 0.0)
                component.update_execution_stats(execution_time, not success)
                
                # Update model laatste update tijd
                profile.last_updated = time.time()
        
        # Voeg toe aan geschiedenis
        self._add_to_execution_history(model_id, component_id, metrics, success)
        
        # Roep event handler aan
        if self.execution_completed_handler:
            self.execution_completed_handler(model_id, component_id, metrics, success)
        
        # Controleer op optimalisatie mogelijkheden
        asyncio.create_task(self._check_optimization_opportunities(model_id))
    
    def get_model_profile(self, model_id: str) -> Optional[ModelProfile]:
        """Krijg model profiel op ID"""
        return self.model_profiles.get(model_id)
    
    def get_optimization_candidates(self, model_id: str) -> List[ModelComponent]:
        """Krijg componenten die geoptimaliseerd kunnen worden"""
        if model_id not in self.model_profiles:
            return []
        
        profile = self.model_profiles[model_id]
        return profile.get_optimization_candidates()
    
    def get_model_statistics(self, model_id: str) -> Dict[str, Any]:
        """Krijg statistieken voor een model"""
        if model_id not in self.model_profiles:
            return {}
        
        profile = self.model_profiles[model_id]
        
        return {
            'model_id': model_id,
            'model_type': profile.model_type,
            'version': profile.version,
            'total_executions': profile.get_total_executions(),
            'average_latency': profile.get_average_latency(),
            'component_count': len(profile.components),
            'components': {
                comp_id: {
                    'type': comp.component_type,
                    'execution_mode': comp.execution_mode.value,
                    'execution_count': comp.execution_count,
                    'average_latency': comp.average_latency,
                    'optimization_score': comp.optimization_score,
                    'error_count': comp.error_count
                }
                for comp_id, comp in profile.components.items()
            },
            'last_updated': profile.last_updated
        }
    
    def get_all_statistics(self) -> Dict[str, Any]:
        """Krijg statistieken voor alle geregistreerde modellen"""
        return {
            'model_count': len(self.model_profiles),
            'models': {
                model_id: self.get_model_statistics(model_id)
                for model_id in self.model_profiles.keys()
            },
            'total_executions': sum(
                profile.get_total_executions() 
                for profile in self.model_profiles.values()
            )
        }
    
    def set_optimization_trigger(self, trigger_name: str, value: float):
        """
        Stel een optimalisatie trigger in
        
        Args:
            trigger_name: Naam van de trigger
            value: Nieuwe waarde
        """
        if trigger_name in self.optimization_triggers:
            self.optimization_triggers[trigger_name] = value
            logger.info(f"Updated optimization trigger {trigger_name} to {value}")
        else:
            logger.warning(f"Unknown optimization trigger: {trigger_name}")
    
    def set_model_loaded_handler(self, handler: Callable):
        """Stel een handler in voor geladen modellen"""
        self.model_loaded_handler = handler
    
    def set_model_optimized_handler(self, handler: Callable):
        """Stel een handler in voor geoptimaliseerde modellen"""
        self.model_optimized_handler = handler
    
    def set_execution_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide uitvoeringen"""
        self.execution_completed_handler = handler
    
    async def _check_optimization_opportunities(self, model_id: str):
        """
        Controleer of er optimalisatie mogelijkheden zijn voor een model
        
        Args:
            model_id: ID van het model
        """
        candidates = self.get_optimization_candidates(model_id)
        
        if candidates:
            logger.info(f"Found {len(candidates)} optimization candidates for model {model_id}")
            
            # Roep event handler aan voor elke candidate
            for component in candidates:
                if self.model_optimized_handler:
                    await self.model_optimized_handler(model_id, component.component_id)
    
    def _add_to_execution_history(self, model_id: str, component_id: str, 
                                metrics: ExecutionMetrics, success: bool):
        """Voeg uitvoering toe aan geschiedenis"""
        entry = {
            'timestamp': time.time(),
            'model_id': model_id,
            'component_id': component_id,
            'success': success,
            'metrics': metrics.to_dict()
        }
        
        with self._metrics_lock:
            self.execution_history.append(entry)
            
            # Beperk geschiedenis grootte
            if len(self.execution_history) > self.max_history_size:
                self.execution_history.pop(0)
    
    def get_execution_history(self, model_id: Optional[str] = None, 
                            component_id: Optional[str] = None,
                            limit: int = 100) -> List[Dict[str, Any]]:
        """
        Krijg uitvoeringsgeschiedenis
        
        Args:
            model_id: Filter op model ID
            component_id: Filter op component ID
            limit: Maximum aantal resultaten
            
        Returns:
            Lijst met geschiedenis entries
        """
        with self._metrics_lock:
            history = self.execution_history.copy()
        
        # Filter resultaten
        if model_id:
            history = [entry for entry in history if entry['model_id'] == model_id]
        
        if component_id:
            history = [entry for entry in history if entry['component_id'] == component_id]
        
        # Beperk aantal resultaten
        return history[-limit:]
    
    def get_performance_summary(self, model_id: Optional[str] = None) -> Dict[str, Any]:
        """
        Krijg prestatie samenvatting
        
        Args:
            model_id: Specifieke model ID, of None voor alle modellen
            
        Returns:
            Prestatie samenvatting
        """
        if model_id:
            histories = [h for h in self.execution_history if h['model_id'] == model_id]
        else:
            histories = self.execution_history
        
        if not histories:
            return {}
        
        total_executions = len(histories)
        successful_executions = sum(1 for h in histories if h['success'])
        failed_executions = total_executions - successful_executions
        
        success_rate = successful_executions / total_executions if total_executions > 0 else 0.0
        
        # Bereken gemiddelde total time
        avg_total_time = sum(h['metrics']['total_time'] for h in histories) / total_executions
        
        # Bereken gemiddelde component times
        component_times = {}
        for history in histories:
            for comp_id, comp_time in history['metrics']['component_times'].items():
                if comp_id not in component_times:
                    component_times[comp_id] = []
                component_times[comp_id].append(comp_time)
        
        avg_component_times = {
            comp_id: sum(times) / len(times)
            for comp_id, times in component_times.items()
        }
        
        return {
            'total_executions': total_executions,
            'successful_executions': successful_executions,
            'failed_executions': failed_executions,
            'success_rate': success_rate,
            'average_total_time': avg_total_time,
            'average_component_times': avg_component_times,
            'error_count': sum(h['metrics']['error_count'] for h in histories),
            'warning_count': sum(h['metrics']['warning_count'] for h in histories)
        }
    
    def clear_history(self):
        """Wis de uitvoeringsgeschiedenis"""
        with self._metrics_lock:
            self.execution_history.clear()
        
        logger.info("Cleared execution history")
    
    def export_statistics(self, filepath: str):
        """
        Exporteer statistieken naar een bestand
        
        Args:
            filepath: Pad naar export bestand
        """
        import json
        
        stats = {
            'models': self.get_all_statistics(),
            'performance_summary': self.get_performance_summary(),
            'triggers': self.optimization_triggers,
            'export_timestamp': time.time()
        }
        
        with open(filepath, 'w') as f:
            json.dump(stats, f, indent=2)
        
        logger.info(f"Exported statistics to {filepath}")
    
    def is_running(self) -> bool:
        """Controleer of AHR actief is"""
        return self._running
    
    def is_monitoring(self) -> bool:
        """Controleer of AHR monitoring actief is"""
        return self._running
    
    def start(self):
        """Start de AHR"""
        self._running = True
        logger.info("AHR Base started")
    
    def stop(self):
        """Stop de AHR"""
        self._running = False
        logger.info("AHR Base stopped")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"AHRBase(models={len(self.model_profiles)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"AHRBase(models={len(self.model_profiles)}, "
                f"total_executions={sum(p.get_total_executions() for p in self.model_profiles.values())})")


