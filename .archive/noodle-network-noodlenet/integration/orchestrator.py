"""
Integration::Orchestrator - orchestrator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleNet Orchestrator - HoofdcoÃ¶rdinator voor alle componenten
Integreert NoodleNet, AHR en NoodleCore tot Ã©Ã©n samenhangend systeem
"""

import asyncio
import time
import json
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

from ..config import NoodleNetConfig
from ..link import NoodleLink
from ..discovery import NoodleDiscovery
from ..identity import NoodleIdentityManager
from ..mesh import NoodleMesh
from ..ahr import AHRBase, PerformanceProfiler, ModelCompiler, AHRDecisionOptimizer
from ..core import NoodleCoreInterface, NoodleCoreCompilerBridge

logger = logging.getLogger(__name__)


class SystemStatus(Enum):
    """Systeem statussen"""
    INITIALIZING = "initializing"
    STARTING = "starting"
    RUNNING = "running"
    STOPPING = "stopping"
    STOPPED = "stopped"
    ERROR = "error"


@dataclass
class SystemMetrics:
    """Globale systeem metrieken"""
    
    total_nodes: int = 0
    active_nodes: int = 0
    total_models: int = 0
    active_models: int = 0
    pending_requests: int = 0
    completed_requests: int = 0
    failed_requests: int = 0
    total_compilations: int = 0
    successful_compilations: int = 0
    failed_compilations: int = 0
    system_uptime: float = 0.0
    average_response_time: float = 0.0
    throughput: float = 0.0  # requests per second
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'total_nodes': self.total_nodes,
            'active_nodes': self.active_nodes,
            'total_models': self.total_models,
            'active_models': self.active_models,
            'pending_requests': self.pending_requests,
            'completed_requests': self.completed_requests,
            'failed_requests': self.failed_requests,
            'total_compilations': self.total_compilations,
            'successful_compilations': self.successful_compilations,
            'failed_compilations': self.failed_compilations,
            'system_uptime': self.system_uptime,
            'average_response_time': self.average_response_time,
            'throughput': self.throughput
        }


@dataclass
class OptimizationReport:
    """Rapport over optimalisatie activiteiten"""
    
    timestamp: float
    total_decisions: int
    jit_decisions: int
    aot_decisions: int
    migration_decisions: int
    successful_executions: int
    failed_executions: int
    average_improvement: float
    top_improvements: List[str] = field(default_factory=list)
    active_models: List[str] = field(default_factory=list)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'timestamp': self.timestamp,
            'total_decisions': self.total_decisions,
            'jit_decisions': self.jit_decisions,
            'aot_decisions': self.aot_decisions,
            'migration_decisions': self.migration_decisions,
            'successful_executions': self.successful_executions,
            'failed_executions': self.failed_executions,
            'average_improvement': self.average_improvement,
            'top_improvements': self.top_improvements,
            'active_models': self.active_models
        }


class NoodleNetOrchestrator:
    """
    HoofdcoÃ¶rdinator voor NoodleNet ecosysteem
    Beheert alle componenten en coÃ¶rdineert hun interacties
    """
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de orchestrator
        
        Args:
            config: NoodleNet configuratie
        """
        self.config = config or NoodleNetConfig()
        
        # Kern componenten
        self.link: Optional[NoodleLink] = None
        self.discovery: Optional[NoodleDiscovery] = None
        self.identity_manager: Optional[NoodleIdentityManager] = None
        self.mesh: Optional[NoodleMesh] = None
        
        # AHR componenten
        self.ahr: Optional[AHRBase] = None
        self.profiler: Optional[PerformanceProfiler] = None
        self.compiler: Optional[ModelCompiler] = None
        self.optimizer: Optional[AHRDecisionOptimizer] = None
        
        # NoodleCore componenten
        self.core_interface: Optional[NoodleCoreInterface] = None
        self.compiler_bridge: Optional[NoodleCoreCompilerBridge] = None
        
        # Systeem status
        self.status: SystemStatus = SystemStatus.STOPPED
        self.start_time: Optional[float] = None
        self.metrics = SystemMetrics()
        
        # Configuratie
        self.orchestrator_settings = {
            'optimization_interval': 30.0,  # seconden
            'metrics_collection_interval': 10.0,  # seconden
            'reporting_interval': 300.0,  # 5 minuten
            'max_concurrent_operations': 20,
            'enable_auto_scaling': True,
            'enable_load_balancing': True,
            'enable_performance_monitoring': True
        }
        
        # Event handlers
        self.status_changed_handler: Optional[Callable] = None
        self.metrics_updated_handler: Optional[Callable] = None
        self.optimization_report_handler: Optional[Callable] = None
        self.error_handler: Optional[Callable] = None
        
        # Taken
        self._monitoring_task: Optional[asyncio.Task] = None
        self._metrics_task: Optional[asyncio.Task] = None
        self._optimization_task: Optional[asyncio.Task] = None
        self._reporting_task: Optional[asyncio.Task] = None
        
        # Logging
        self._setup_logging()
        
    def _setup_logging(self):
        """Setup logging configuratie"""
        log_level = getattr(logging, self.config.log_level.upper())
        logging.basicConfig(
            level=log_level,
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            handlers=[
                logging.StreamHandler(),
                logging.FileHandler('noodlenet_orchestrator.log')
            ]
        )
        
        logger.info("NoodleNet Orchestrator initialized")
    
    async def start(self):
        """Start het volledige NoodleNet ecosysteem"""
        if self.status != SystemStatus.STOPPED:
            logger.warning(f"System is already in {self.status} state")
            return
        
        try:
            self.status = SystemStatus.STARTING
            self.start_time = time.time()
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
            
            logger.info("Starting NoodleNet ecosystem...")
            
            # Initialiseer kern componenten
            await self._initialize_core_components()
            
            # Initialiseer AHR componenten
            await self._initialize_ahr_components()
            
            # Initialiseer NoodleCore componenten
            await self._initialize_noodlecore_components()
            
            # Start alle componenten
            await self._start_all_components()
            
            # Start monitoring taken
            self._start_monitoring_tasks()
            
            self.status = SystemStatus.RUNNING
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
            
            logger.info("NoodleNet ecosystem started successfully")
            
        except Exception as e:
            logger.error(f"Failed to start NoodleNet ecosystem: {e}")
            self.status = SystemStatus.ERROR
            
            # Roep event handler aan
            if self.error_handler:
                await self.error_handler(e)
            
            raise
    
    async def stop(self):
        """Stop het volledige NoodleNet ecosysteem"""
        if self.status == SystemStatus.STOPPED:
            return
        
        try:
            self.status = SystemStatus.STOPPING
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
            
            logger.info("Stopping NoodleNet ecosystem...")
            
            # Stop monitoring taken
            self._stop_monitoring_tasks()
            
            # Stop alle componenten
            await self._stop_all_components()
            
            self.status = SystemStatus.STOPPED
            
            # Roep event handler aan
            if self.status_changed_handler:
                await self.status_changed_handler(self.status)
            
            logger.info("NoodleNet ecosystem stopped successfully")
            
        except Exception as e:
            logger.error(f"Error while stopping NoodleNet ecosystem: {e}")
            self.status = SystemStatus.ERROR
            
            # Roep event handler aan
            if self.error_handler:
                await self.error_handler(e)
            
            raise
    
    async def _initialize_core_components(self):
        """Initialiseer kern NoodleNet componenten"""
        logger.info("Initializing core NoodleNet components...")
        
        # Initialiseer identity manager
        self.identity_manager = NoodleIdentityManager()
        await self.identity_manager.initialize()
        
        # Initialiseer link
        self.link = NoodleLink(self.config)
        
        # Initialiseer discovery
        self.discovery = NoodleDiscovery(self.link, self.identity_manager, self.config)
        
        # Initialiseer mesh
        self.mesh = NoodleMesh(self.link, self.identity_manager, self.config)
        
        logger.info("Core NoodleNet components initialized")
    
    async def _initialize_ahr_components(self):
        """Initialiseer AHR componenten"""
        logger.info("Initializing AHR components...")
        
        # Initialiseer AHR base
        self.ahr = AHRBase(self.link, self.identity_manager, self.mesh, self.config)
        
        # Initialiseer profiler
        self.profiler = PerformanceProfiler(self.mesh, self.config)
        
        # Initialiseer compiler
        self.compiler = ModelCompiler(self.mesh, self.config)
        
        # Initialiseer optimizer
        self.optimizer = AHRDecisionOptimizer(self.mesh, self.profiler, self.compiler, self.config)
        
        logger.info("AHR components initialized")
    
    async def _initialize_noodlecore_components(self):
        """Initialiseer NoodleCore componenten"""
        logger.info("Initializing NoodleCore components...")
        
        # Initialiseer core interface
        self.core_interface = NoodleCoreInterface(self.link, self.mesh, self.config)
        
        # Initialiseer compiler bridge
        self.compiler_bridge = NoodleCoreCompilerBridge(self.core_interface, self.mesh, self.config)
        
        logger.info("NoodleCore components initialized")
    
    async def _start_all_components(self):
        """Start alle componenten"""
        logger.info("Starting all components...")
        
        # Start kern componenten
        if self.link:
            await self.link.start()
        if self.discovery:
            await self.discovery.start()
        if self.mesh:
            await self.mesh.start()
        
        # Start AHR componenten
        if self.ahr and hasattr(self.ahr, 'start'):
            await self.ahr.start()
        if self.profiler:
            # Start resource monitoring
            if hasattr(self.profiler, 'start_resource_monitoring'):
                await self.profiler.start_resource_monitoring()
            # Start profiling collection
            if hasattr(self.profiler, 'start_profiling_collection'):
                await self.profiler.start_profiling_collection()
        if self.compiler and hasattr(self.compiler, 'start'):
            await self.compiler.start()
        if self.optimizer and self.optimizer.is_running():
            if hasattr(self.optimizer, 'start'):
                await self.optimizer.start()
        
        # Start NoodleCore componenten
        if self.core_interface:
            await self.core_interface.start()
        if self.compiler_bridge:
            await self.compiler_bridge.start()
        
        logger.info("All components started")
    
    async def _stop_all_components(self):
        """Stop alle componenten"""
        logger.info("Stopping all components...")
        
        # Stop NoodleCore componenten
        if self.compiler_bridge:
            await self.compiler_bridge.stop()
        if self.core_interface:
            await self.core_interface.stop()
        
        # Stop AHR componenten
        if self.optimizer:
            if hasattr(self.optimizer, 'stop'):
                await self.optimizer.stop()
        if self.compiler:
            await self.compiler.stop()
        if self.profiler:
            if hasattr(self.profiler, 'stop_resource_monitoring'):
                await self.profiler.stop_resource_monitoring()
            if hasattr(self.profiler, 'stop_profiling_collection'):
                await self.profiler.stop_profiling_collection()
        if self.ahr:
            await self.ahr.stop()
        
        # Stop kern componenten
        if self.mesh:
            await self.mesh.stop()
        if self.discovery:
            await self.discovery.stop()
        if self.link:
            await self.link.stop()
        
        logger.info("All components stopped")
    
    def _start_monitoring_tasks(self):
        """Start monitoring taken"""
        logger.info("Starting monitoring tasks...")
        
        # Start monitoring task
        self._monitoring_task = asyncio.create_task(self._monitoring_loop())
        
        # Start metrics collection task
        self._metrics_task = asyncio.create_task(self._metrics_collection_loop())
        
        # Start optimization task
        self._optimization_task = asyncio.create_task(self._optimization_loop())
        
        # Start reporting task
        self._reporting_task = asyncio.create_task(self._reporting_loop())
    
    def _stop_monitoring_tasks(self):
        """Stop monitoring taken"""
        logger.info("Stopping monitoring tasks...")
        
        # Stop taken
        tasks = [
            self._monitoring_task,
            self._metrics_task,
            self._optimization_task,
            self._reporting_task
        ]
        
        for task in tasks:
            if task:
                task.cancel()
                try:
                    asyncio.create_task(task)
                except asyncio.CancelledError:
                    pass
        
        # Reset taken
        self._monitoring_task = None
        self._metrics_task = None
        self._optimization_task = None
        self._reporting_task = None
    
    async def _monitoring_loop(self):
        """Hoofd monitoring loop"""
        while self.status == SystemStatus.RUNNING:
            try:
                # Monitor systeem status
                await self._monitor_system_health()
                
                # Monitor componenten
                await self._monitor_components()
                
                # Monitor prestaties
                await self._monitor_performance()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(5.0)
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _metrics_collection_loop(self):
        """Metrics collection loop"""
        while self.status == SystemStatus.RUNNING:
            try:
                # Verzamel metrics
                await self._collect_metrics()
                
                # Update globale metrics
                await self._update_global_metrics()
                
                # Roep event handler aan
                if self.metrics_updated_handler:
                    await self.metrics_updated_handler(self.metrics)
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(self.orchestrator_settings['metrics_collection_interval'])
                
            except Exception as e:
                logger.error(f"Error in metrics collection loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _optimization_loop(self):
        """Optimization loop"""
        while self.status == SystemStatus.RUNNING:
            try:
                # Evalueer optimalisatie mogelijkheden
                await self._evaluate_optimization_opportunities()
                
                # Pas optimalisaties toe
                await self._apply_optimizations()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(self.orchestrator_settings['optimization_interval'])
                
            except Exception as e:
                logger.error(f"Error in optimization loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _reporting_loop(self):
        """Reporting loop"""
        while self.status == SystemStatus.RUNNING:
            try:
                # Genereer rapport
                report = await self._generate_optimization_report()
                
                # Roep event handler aan
                if self.optimization_report_handler:
                    await self.optimization_report_handler(report)
                
                # Sla rapport op
                await self._save_report(report)
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(self.orchestrator_settings['reporting_interval'])
                
            except Exception as e:
                logger.error(f"Error in reporting loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _monitor_system_health(self):
        """Monitor systeem gezondheid"""
        # Check component status
        components_status = {
            'link': self.link.is_running() if self.link else False,
            'discovery': self.discovery.is_running() if self.discovery else False,
            'mesh': self.mesh.is_running() if self.mesh else False,
            'ahr': self.ahr.is_running() if self.ahr else False,
            'profiler': self.profiler.is_monitoring() if self.profiler else False,
            'compiler': self.compiler.is_running() if self.compiler else False,
            'optimizer': self.optimizer.is_optimization_active() if self.optimizer else False,
            'core_interface': self.core_interface.is_running() if self.core_interface else False,
            'compiler_bridge': self.compiler_bridge.is_running() if self.compiler_bridge else False
        }
        
        # Check alle componenten
        all_healthy = all(components_status.values())
        
        if not all_healthy:
            logger.warning(f"System health check failed: {components_status}")
            
            # Implementeer herstel acties
            await self._handle_system_issues(components_status)
    
    async def _monitor_components(self):
        """Monitor individuele componenten"""
        # Monitor mesh
        if self.mesh:
            node_count = len(self.mesh.nodes)
            if node_count != self.metrics.total_nodes:
                self.metrics.total_nodes = node_count
                self.metrics.active_nodes = len([n for n in self.mesh.nodes.values() if n.is_active])
        
        # Monitor AHR
        if self.ahr:
            model_count = len(self.ahr.model_profiles)
            if model_count != self.metrics.total_models:
                self.metrics.total_models = model_count
                self.metrics.active_models = len([m for m in self.ahr.model_profiles.values() if True])  # Placeholder
        
        # Monitor compiler
        if self.compiler:
            compiler_stats = self.compiler.get_compilation_statistics()
            self.metrics.total_compilations = compiler_stats['total_tasks']
            self.metrics.successful_compilations = compiler_stats['completed_tasks']
            self.metrics.failed_compilations = compiler_stats['failed_tasks']
        
        # Monitor core interface
        if self.core_interface:
            interface_stats = self.core_interface.get_statistics()
            self.metrics.pending_requests = interface_stats['pending_requests']
            self.metrics.completed_requests = interface_stats['completed_requests']
    
    async def _monitor_performance(self):
        """Monitor systeem prestaties"""
        # Monitor throughput
        if self.start_time:
            uptime = time.time() - self.start_time
            total_requests = self.metrics.completed_requests + self.metrics.failed_requests
            self.metrics.throughput = total_requests / uptime if uptime > 0 else 0
        
        # Monitor response time
        if self.core_interface and self.metrics.completed_requests > 0:
            # Dit zou meer gedetailleerd gemeten moeten worden
            self.metrics.average_response_time = 0.1  # Placeholder
    
    async def _collect_metrics(self):
        """Verzamel metrics van alle componenten"""
        metrics = {}
        
        # Mesh metrics
        if self.mesh:
            metrics['mesh'] = self.mesh.get_network_metrics()
        
        # AHR metrics
        if self.profiler:
            metrics['profiler'] = self.profiler.get_performance_summary()
        if self.optimizer:
            metrics['optimizer'] = self.optimizer.get_optimization_summary()
        
        # NoodleCore metrics
        if self.core_interface:
            metrics['core_interface'] = self.core_interface.get_statistics()
        if self.compiler_bridge:
            metrics['compiler_bridge'] = self.compiler_bridge.get_compilation_statistics()
        
        return metrics
    
    async def _update_global_metrics(self):
        """Update globale systeem metrics"""
        # Update uptime
        if self.start_time:
            self.metrics.system_uptime = time.time() - self.start_time
    
    async def _evaluate_optimization_opportunities(self):
        """Evalueer optimalisatie mogelijkheden"""
        if not self.optimizer:
            return
        
        # Evalueer voor alle actieve modellen
        optimization_decisions = []
        
        if self.ahr:
            for model_id in self.ahr.model_profiles:
                decisions = await self.optimizer.evaluate_optimization_opportunities(model_id)
                optimization_decisions.extend(decisions)
        
        # Sorteer op prioriteit
        optimization_decisions.sort(key=lambda d: d.priority, reverse=True)
        
        return optimization_decisions
    
    async def _apply_optimizations(self):
        """Pas optimalisaties toe"""
        if not self.optimizer:
            return
        
        # Haal pending decisions op
        pending_decisions = self.optimizer.get_optimization_decisions("pending")
        
        # Beperk aantal tegelijk
        max_concurrent = self.orchestrator_settings['max_concurrent_operations']
        decisions_to_execute = pending_decisions[:max_concurrent]
        
        # Voer beslissingen uit
        for decision in decisions_to_execute:
            await self.optimizer.execute_optimization_decision(decision)
    
    async def _generate_optimization_report(self) -> OptimizationReport:
        """Genereer optimization report"""
        if not self.optimizer:
            return OptimizationReport(timestamp=time.time())
        
        stats = self.optimizer.get_decision_statistics()
        summary = self.optimizer.get_optimization_summary()
        
        # Bereken gemiddelde verbetering
        executed_decisions = self.optimizer.get_optimization_decisions("executed")
        avg_improvement = 0.0
        if executed_decisions:
            total_improvement = sum(d.expected_improvement for d in executed_decisions)
            avg_improvement = total_improvement / len(executed_decisions)
        
        # Haal top verbeteringen
        top_improvements = []
        if executed_decisions:
            sorted_decisions = sorted(executed_decisions, key=lambda d: d.expected_improvement, reverse=True)
            top_improvements = [f"{d.component_id}: {d.expected_improvement:.2f}"
                               for d in sorted_decisions[:5]]
        
        # Haal actieve modellen
        active_models = []
        if self.ahr:
            active_models = [m_id for m_id, m in self.ahr.models.items() if m.is_active]
        
        return OptimizationReport(
            timestamp=time.time(),
            total_decisions=stats['total_decisions'],
            jit_decisions=stats['jit_decisions'],
            aot_decisions=stats['aot_decisions'],
            migration_decisions=stats['migrate_decisions'],
            successful_executions=stats['successful_executions'],
            failed_executions=stats['failed_executions'],
            average_improvement=avg_improvement,
            top_improvements=top_improvements,
            active_models=active_models
        )
    
    async def _save_report(self, report: OptimizationReport):
        """Sla rapport op"""
        reports_dir = Path("reports")
        reports_dir.mkdir(exist_ok=True)
        
        timestamp = time.strftime("%Y%m%d_%H%M%S")
        report_file = reports_dir / f"optimization_report_{timestamp}.json"
        
        try:
            with open(report_file, 'w') as f:
                json.dump(report.to_dict(), f, indent=2)
            
            logger.info(f"Saved optimization report to {report_file}")
            
        except Exception as e:
            logger.error(f"Failed to save report: {e}")
    
    async def _handle_system_issues(self, components_status: Dict[str, bool]):
        """Behandel systeem issues"""
        # Implementeer herstel logica
        # Dit zou kunnen bestaan uit:
        # - Herstarten van gefaalde componenten
        # - Load balancing activeren
        # - Scaling activeren
        # - Notificaties sturen
        
        logger.info("Handling system issues...")
        
        # Placeholder voor herstel acties
        for component, is_healthy in components_status.items():
            if not is_healthy:
                logger.warning(f"Component {component} is not healthy")
    
    def get_system_status(self) -> Dict[str, Any]:
        """Krijg systeem status"""
        return {
            'status': self.status.value,
            'uptime': self.metrics.system_uptime,
            'metrics': self.metrics.to_dict(),
            'components_status': {
                'link': self.link.is_running() if self.link else False,
                'discovery': self.discovery.is_running() if self.discovery else False,
                'mesh': self.mesh.is_running() if self.mesh else False,
                'ahr': self.ahr.is_running() if self.ahr else False,
                'profiler': self.profiler.is_monitoring() if self.profiler else False,
                'compiler': self.compiler.is_running() if self.compiler else False,
                'optimizer': self.optimizer.is_optimization_active() if self.optimizer else False,
                'core_interface': self.core_interface.is_running() if self.core_interface else False,
                'compiler_bridge': self.compiler_bridge.is_running() if self.compiler_bridge else False
            }
        }
    
    def get_detailed_report(self) -> Dict[str, Any]:
        """Krijg gedetailleerd systeem rapport"""
        return {
            'system_status': self.get_system_status(),
            'mesh_metrics': self.mesh.get_network_metrics() if self.mesh else {},
            'ahr_metrics': {
                'profiler': self.profiler.get_performance_summary() if self.profiler else {},
                'optimizer': self.optimizer.get_optimization_summary() if self.optimizer else {},
                'compiler': self.compiler.get_compilation_statistics() if self.compiler else {}
            },
            'core_metrics': {
                'interface': self.core_interface.get_statistics() if self.core_interface else {},
                'compiler_bridge': self.compiler_bridge.get_compilation_statistics() if self.compiler_bridge else {}
            }
        }
    
    def set_status_changed_handler(self, handler: Callable):
        """Stel een handler in voor status wijzigingen"""
        self.status_changed_handler = handler
    
    def set_metrics_updated_handler(self, handler: Callable):
        """Stel een handler in voor bijgewerkte metrics"""
        self.metrics_updated_handler = handler
    
    def set_optimization_report_handler(self, handler: Callable):
        """Stel een handler in voor optimization reports"""
        self.optimization_report_handler = handler
    
    def set_error_handler(self, handler: Callable):
        """Stel een handler in voor errors"""
        self.error_handler = handler
    
    def set_orchestrator_setting(self, setting_name: str, value: Any):
        """
        Stel een orchestrator setting in
        
        Args:
            setting_name: Naam van de setting
            value: Nieuwe waarde
        """
        if setting_name in self.orchestrator_settings:
            self.orchestrator_settings[setting_name] = value
            logger.info(f"Updated orchestrator setting {setting_name} to {value}")
        else:
            logger.warning(f"Unknown orchestrator setting: {setting_name}")
    
    def is_running(self) -> bool:
        """Controleer of systeem actief is"""
        return self.status == SystemStatus.RUNNING
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleNetOrchestrator(status={self.status.value}, uptime={self.metrics.system_uptime:.1f}s)"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        component_count = len([c for c in [self.link, self.discovery, self.mesh, 
                                          self.ahr, self.profiler, self.compiler, 
                                          self.optimizer, self.core_interface, 
                                          self.compiler_bridge] if c is not None])
        return (f"NoodleNetOrchestrator(status={self.status.value}, "
                f"components={component_count})")


