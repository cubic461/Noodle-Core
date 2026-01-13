"""
Integration::Ahr Integration - ahr_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleNet & AHR Integration - Complete distributed AI runtime integration
"""

import asyncio
import time
import logging
from typing import Dict, List, Optional, Set, Any, Callable
from dataclasses import dataclass, field
from enum import Enum

from ..discovery import NoodleDiscovery
from ..mesh import NoodleMesh
from ..link import NoodleLink
from ..ahr.ahr_base import AHRBase, ModelProfile, ExecutionMode
from ..core.interface import NoodleCoreInterface
from ..config import NoodleNetConfig
from ..identity import NoodleIdentityManager

logger = logging.getLogger(__name__)


class IntegrationStatus(Enum):
    """Integratiestatus"""
    INITIALIZING = "initializing"
    CONNECTING = "connecting"
    SYNCING = "syncing"
    RUNNING = "running"
    ERROR = "error"
    STOPPED = "stopped"


@dataclass
class IntegrationMetrics:
    """Integratiemetrieken"""
    start_time: float = field(default_factory=time.time)
    nodes_connected: int = 0
    models_registered: int = 0
    requests_processed: int = 0
    optimizations_triggered: int = 0
    errors_count: int = 0
    total_execution_time: float = 0.0
    average_latency: float = 0.0
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'uptime': time.time() - self.start_time,
            'nodes_connected': self.nodes_connected,
            'models_registered': self.models_registered,
            'requests_processed': self.requests_processed,
            'optimizations_triggered': self.optimizations_triggered,
            'errors_count': self.errors_count,
            'total_execution_time': self.total_execution_time,
            'average_latency': self.average_latency
        }


class NoodleNetAHRIntegration:
    """Complete integratie van NoodleNet met AHR voor distributed AI runtime"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de NoodleNet & AHR integratie
        
        Args:
            config: NoodleNet configuratie
        """
        self.config = config or NoodleNetConfig()
        self.status = IntegrationStatus.INITIALIZING
        
        # Core components
        self.identity_manager: Optional[NoodleIdentityManager] = None
        self.link: Optional[NoodleLink] = None
        self.discovery: Optional[NoodleDiscovery] = None
        self.mesh: Optional[NoodleMesh] = None
        self.ahr: Optional[AHRBase] = None
        self.core_interface: Optional[NoodleCoreInterface] = None
        
        # Integratie state
        self._running = False
        self._metrics = IntegrationMetrics()
        
        # Event handlers
        self.status_changed_handler: Optional[Callable] = None
        self.model_optimized_handler: Optional[Callable] = None
        self.node_discovered_handler: Optional[Callable] = None
        self.request_completed_handler: Optional[Callable] = None
        
        # Integratie settings
        self.integration_settings = {
            'auto_optimize': True,
            'optimization_threshold': 0.6,
            'max_concurrent_requests': 20,
            'enable_distributed_execution': True,
            'enable_local_fallback': True,
            'heartbeat_interval': 30.0,
            'sync_interval': 60.0
        }
    
    async def initialize(self):
        """Initialiseer alle componenten"""
        try:
            self.status = IntegrationStatus.INITIALIZING
            
            # Initialiseer identity manager
            self.identity_manager = NoodleIdentityManager()
            
            # Initialiseer link layer
            self.link = NoodleLink(self.config)
            
            # Initialiseer discovery
            self.discovery = NoodleDiscovery(self.link, self.identity_manager, self.config)
            
            # Initialiseer mesh
            self.mesh = NoodleMesh(self.link, self.identity_manager, self.config)
            
            # Initialiseer AHR
            self.ahr = AHRBase(self.link, self.identity_manager, self.mesh, self.config)
            
            # Initialiseer core interface
            self.core_interface = NoodleCoreInterface(self.link, self.mesh, self.config, self.identity_manager)
            
            # Registreer event handlers
            self._register_event_handlers()
            
            self.status = IntegrationStatus.STOPPED
            logger.info("NoodleNet & AHR integration initialized successfully")
            
        except Exception as e:
            self.status = IntegrationStatus.ERROR
            logger.error(f"Failed to initialize integration: {e}")
            raise
    
    async def start(self):
        """Start de integratie"""
        if self._running:
            logger.warning("Integration is already running")
            return
        
        try:
            self.status = IntegrationStatus.CONNECTING
            
            # Start alle componenten
            await self.link.start()
            await self.discovery.start()
            await self.mesh.start()
            await self.ahr.start()
            await self.core_interface.start()
            
            # Start integratie taken
            self._running = True
            asyncio.create_task(self._integration_loop())
            asyncio.create_task(self._sync_loop())
            
            self.status = IntegrationStatus.RUNNING
            self._metrics.nodes_connected = self.mesh.get_node_count()
            
            logger.info("NoodleNet & AHR integration started successfully")
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
                
        except Exception as e:
            self.status = IntegrationStatus.ERROR
            logger.error(f"Failed to start integration: {e}")
            raise
    
    async def stop(self):
        """Stop de integratie"""
        if not self._running:
            return
        
        try:
            self._running = False
            self.status = IntegrationStatus.STOPPED
            
            # Stop alle componenten
            if self.core_interface:
                await self.core_interface.stop()
            if self.ahr:
                await self.ahr.stop()
            if self.mesh:
                await self.mesh.stop()
            if self.discovery:
                await self.discovery.stop()
            if self.link:
                await self.link.stop()
            
            logger.info("NoodleNet & AHR integration stopped")
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
                
        except Exception as e:
            self.status = IntegrationStatus.ERROR
            logger.error(f"Error stopping integration: {e}")
            raise
    
    def _register_event_handlers(self):
        """Registreer event handlers tussen componenten"""
        # Discovery events
        if self.discovery:
            self.discovery.set_node_discovered_handler(self._on_node_discovered)
            self.discovery.set_node_lost_handler(self._on_node_lost)
        
        # AHR events
        if self.ahr:
            self.ahr.set_model_loaded_handler(self._on_model_loaded)
            self.ahr.set_model_optimized_handler(self._on_model_optimized)
            self.ahr.set_execution_completed_handler(self._on_execution_completed)
        
        # Core interface events
        if self.core_interface:
            self.core_interface.set_request_completed_handler(self._on_request_completed)
            self.core_interface.set_request_failed_handler(self._on_request_failed)
    
    async def _integration_loop(self):
        """Hoofd integratie loop"""
        while self._running:
            try:
                # Verwerk integratie taken
                await self._process_integration_tasks()
                
                # Update metrieken
                self._update_metrics()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(1.0)
                
            except Exception as e:
                logger.error(f"Error in integration loop: {e}")
                await asyncio.sleep(5.0)
    
    async def _sync_loop(self):
        """Synchronisatie loop voor state sync"""
        while self._running:
            try:
                # Sync state tussen nodes
                await self._sync_state()
                
                # Wacht voor volgende sync
                await asyncio.sleep(self.integration_settings['sync_interval'])
                
            except Exception as e:
                logger.error(f"Error in sync loop: {e}")
                await asyncio.sleep(10.0)
    
    async def _process_integration_tasks(self):
        """Verwerk integratie taken"""
        # Check voor optimalisatie mogelijkheden
        if self.integration_settings['auto_optimize']:
            await self._check_global_optimization()
        
        # Load balance requests
        if self.integration_settings['enable_distributed_execution']:
            await self._load_balance_requests()
    
    async def _sync_state(self):
        """Synchroniseer state tussen nodes"""
        if not self.mesh or not self.ahr:
            return
        
        # Get global state
        global_state = {
            'models': self.ahr.get_all_statistics(),
            'nodes': self.mesh.get_network_metrics(),
            'timestamp': time.time()
        }
        
        # Broadcast state naar andere nodes
        # Implementatie afhankelijk van link layer capabilities
        logger.debug("Synced global state")
    
    async def _check_global_optimization(self):
        """Controleer op globale optimalisatie mogelijkheden"""
        if not self.ahr:
            return
        
        # Get optimization candidates van alle nodes
        all_candidates = []
        
        for model_id in self.ahr.model_profiles.keys():
            candidates = self.ahr.get_optimization_candidates(model_id)
            all_candidates.extend(candidates)
        
        # Trigger optimalisatie voor beste candidates
        if all_candidates:
            # Sorteer op optimization score
            all_candidates.sort(key=lambda c: c.optimization_score, reverse=True)
            
            # Trigger optimalisatie voor top candidates
            for i in range(min(3, len(all_candidates))):  # Max 3 tegelijk
                component = all_candidates[i]
                if component.optimization_score >= self.integration_settings['optimization_threshold']:
                    await self._trigger_optimization(component.model_id, component.component_id)
    
    async def _load_balance_requests(self):
        """Load balance requests over beschikbare nodes"""
        if not self.mesh or not self.core_interface:
            return
        
        # Get current load van alle nodes
        node_loads = self.mesh.get_node_loads()
        
        # Selecteer node met minste load
        best_node = min(node_loads.items(), key=lambda x: x[1]['current_load'])[0]
        
        # Update core interface om dit node te prefereren
        # Implementatie afhankelijk van core interface capabilities
        logger.debug(f"Load balanced to node {best_node}")
    
    async def _trigger_optimization(self, model_id: str, component_id: str):
        """Trigger optimalisatie voor een component"""
        if not self.ahr:
            return
        
        # Update component execution mode
        profile = self.ahr.get_model_profile(model_id)
        if profile:
            component = profile.get_component(component_id)
            if component:
                # Upgrade naar JIT mode
                component.execution_mode = ExecutionMode.JIT
                self._metrics.optimizations_triggered += 1
                
                logger.info(f"Triggered optimization for {model_id}/{component_id}")
                
                # Roep event handler aan
                if self.model_optimized_handler:
                    await self.model_optimized_handler(model_id, component_id)
    
    # Event handlers
    async def _on_node_discovered(self, node_id: str):
        """Handler voor nieuwe nodes"""
        self._metrics.nodes_connected = self.mesh.get_node_count()
        logger.info(f"Node discovered: {node_id}")
        
        if self.node_discovered_handler:
            await self.node_discovered_handler(node_id)
    
    async def _on_node_lost(self, node_id: str):
        """Handler voor verloren nodes"""
        logger.info(f"Node lost: {node_id}")
    
    async def _on_model_loaded(self, model_id: str, model_type: str, version: str):
        """Handler voor geladen modellen"""
        self._metrics.models_registered += 1
        logger.info(f"Model loaded: {model_id} ({model_type} v{version})")
    
    async def _on_model_optimized(self, model_id: str, component_id: str):
        """Handler voor geoptimaliseerde modellen"""
        logger.info(f"Model optimized: {model_id}/{component_id}")
    
    async def _on_execution_completed(self, model_id: str, component_id: str, 
                                    metrics, success: bool):
        """Handler voor voltooide uitvoeringen"""
        self._metrics.requests_processed += 1
        self._metrics.total_execution_time += metrics.total_time
        
        if not success:
            self._metrics.errors_count += 1
        
        # Update gemiddelde latency
        if self._metrics.requests_processed > 0:
            self._metrics.average_latency = self._metrics.total_execution_time / self._metrics.requests_processed
        
        if self.request_completed_handler:
            await self.request_completed_handler(model_id, component_id, metrics, success)
    
    async def _on_request_completed(self, request, response):
        """Handler voor voltooide requests"""
        logger.debug(f"Request completed: {request.request_id}")
    
    async def _on_request_failed(self, request, response):
        """Handler voor gefaalde requests"""
        self._metrics.errors_count += 1
        logger.warning(f"Request failed: {request.request_id} - {response.error_message}")
    
    def _update_metrics(self):
        """Update integratiemetrieken"""
        # Update metrieken op basis van component state
        if self.mesh:
            self._metrics.nodes_connected = self.mesh.get_node_count()
        
        if self.ahr:
            self._metrics.models_registered = len(self.ahr.model_profiles)
    
    # Public API methods
    async def register_model(self, model_id: str, model_type: str, version: str = "1.0"):
        """Registreer een model in het distributed systeem"""
        if not self.ahr:
            raise Exception("AHR not initialized")
        
        await self.ahr.register_model(model_id, model_type, version)
    
    async def execute_distributed_task(self, task_type: str, payload: Dict[str, Any],
                                       target_nodes: Optional[List[str]] = None) -> Dict[str, Any]:
        """Voer een distributed task uit"""
        if not self.core_interface:
            raise Exception("Core interface not initialized")
        
        # Map task type naar execution type
        task_mapping = {
            'matrix': 'matrix_operation',
            'neural_network': 'neural_network',
            'database': 'database_query',
            'native': 'native_code'
        }
        
        execution_type = task_mapping.get(task_type, 'composite')
        
        # Voer task uit
        if execution_type == 'matrix_operation':
            response = await self.core_interface.execute_matrix_operation(
                payload.get('matrix_a', []),
                payload.get('matrix_b', []),
                payload.get('operation', 'multiply')
            )
        elif execution_type == 'neural_network':
            response = await self.core_interface.execute_neural_network(
                payload.get('model_path', ''),
                payload.get('input_data', {}),
                payload.get('config', {})
            )
        elif execution_type == 'database_query':
            response = await self.core_interface.execute_database_query(
                payload.get('query', ''),
                payload.get('params', {}),
                payload.get('connection_string')
            )
        elif execution_type == 'native_code':
            response = await self.core_interface.execute_native_code(
                payload.get('code', ''),
                payload.get('language', 'nbc'),
                payload.get('functions', [])
            )
        else:
            response = await self.core_interface.execute_composite(payload.get('operations', []))
        
        return response.to_dict()
    
    def get_integration_status(self) -> Dict[str, Any]:
        """Krijg integratiestatus"""
        return {
            'status': self.status.value,
            'metrics': self._metrics.to_dict(),
            'component_status': {
                'link': self.link.is_running() if self.link else False,
                'discovery': self.discovery.is_running() if self.discovery else False,
                'mesh': self.mesh.is_running() if self.mesh else False,
                'ahr': self.ahr.is_running() if self.ahr else False,
                'core_interface': self.core_interface.is_running() if self.core_interface else False
            },
            'settings': self.integration_settings
        }
    
    def get_detailed_report(self) -> Dict[str, Any]:
        """Krijg gedetailleerd rapport"""
        report = {
            'integration_status': self.get_integration_status(),
            'ahr_statistics': self.ahr.get_all_statistics() if self.ahr else {},
            'mesh_metrics': self.mesh.get_network_metrics() if self.mesh else {},
            'core_statistics': self.core_interface.get_statistics() if self.core_interface else {}
        }
        
        return report
    
    def set_status_changed_handler(self, handler: Callable):
        """Stel een handler in voor status wijzigingen"""
        self.status_changed_handler = handler
    
    def set_model_optimized_handler(self, handler: Callable):
        """Stel een handler in voor geoptimaliseerde modellen"""
        self.model_optimized_handler = handler
    
    def set_node_discovered_handler(self, handler: Callable):
        """Stel een handler in voor nieuwe nodes"""
        self.node_discovered_handler = handler
    
    def set_request_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide requests"""
        self.request_completed_handler = handler
    
    def set_integration_setting(self, setting_name: str, value: Any):
        """Stel een integratie setting in"""
        if setting_name in self.integration_settings:
            self.integration_settings[setting_name] = value
            logger.info(f"Updated integration setting {setting_name} to {value}")
        else:
            logger.warning(f"Unknown integration setting: {setting_name}")
    
    def is_running(self) -> bool:
        """Controleer of integratie actief is"""
        return self._running and self.status == IntegrationStatus.RUNNING

