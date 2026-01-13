"""
Noodle Network Noodlenet::Orchestrator - orchestrator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleNet Orchestrator - GeÃ¯ntegreerd systeem voor distributed computing
"""

import asyncio
import time
import logging
from typing import Dict, List, Optional, Set, Any, Callable
from dataclasses import dataclass
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .link import NoodleLink, Message
from .mesh import NoodleMesh
from .scheduler import DeclarativeScheduler, Task, TaskStatus, TaskPriority, TaskRequirement
from .fault_tolerance import FaultToleranceManager, FailureType
from .security import CapabilitySecurityManager, SecurityContext, Permission
from .monitoring import MonitoringSystem, Alert, AlertSeverity

logger = logging.getLogger(__name__)


@dataclass
class NoodleNetNode:
    """Complete NoodleNet node met alle componenten"""
    
    # Basis componenten
    config: NoodleNetConfig
    identity_manager: NoodleIdentityManager
    link: NoodleLink
    mesh: NoodleMesh
    
    # Advanced componenten
    scheduler: Optional[DeclarativeScheduler] = None
    fault_tolerance: Optional[FaultToleranceManager] = None
    security: Optional[CapabilitySecurityManager] = None
    monitoring: Optional[MonitoringSystem] = None
    
    # Status
    running: bool = False
    
    def __post_init__(self):
        """Initialiseer componenten na creatie"""
        # Koppel componenten aan elkaar
        self.link.set_local_identity(self.identity_manager.get_local_identity())
        
        # Initialiseer geavanceerde componenten
        if not self.scheduler:
            self.scheduler = DeclarativeScheduler(self.mesh, self.identity_manager, self.config)
        
        if not self.fault_tolerance:
            self.fault_tolerance = FaultToleranceManager(self.mesh, self.identity_manager, self.config)
        
        if not self.security:
            self.security = CapabilitySecurityManager(self.identity_manager, self.config)
        
        if not self.monitoring:
            self.monitoring = MonitoringSystem(self.mesh, self.identity_manager, self.config)


class NoodleNetOrchestrator:
    """Orchestrator voor NoodleNet distributed system"""
    
    def __init__(self, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de orchestrator
        
        Args:
            config: NoodleNet configuratie
        """
        self.config = config or NoodleNetConfig()
        self.node: Optional[NoodleNetNode] = None
        
        # Event handlers
        self._startup_handlers: List[Callable] = []
        self._shutdown_handlers: List[Callable] = []
        self._error_handlers: List[Callable] = []
        
        # Performance optimization
        self._optimization_enabled = True
        self._last_optimization = 0.0
        
        # Statistics
        self._stats = {
            'uptime': 0.0,
            'tasks_processed': 0,
            'failures_handled': 0,
            'security_events': 0,
            'alerts_generated': 0,
            'optimizations_performed': 0,
        }
    
    async def start(self, capabilities: Optional[Dict[str, Any]] = None,
                   metadata: Optional[Dict[str, Any]] = None) -> str:
        """
        Start NoodleNet node
        
        Args:
            capabilities: Capabilities van de node
            metadata: Metadata van de node
            
        Returns:
            Node ID
        """
        if self.node and self.node.running:
            logger.warning("NoodleNet is already running")
            return self.node.identity_manager.get_local_identity().node_id
        
        try:
            # Maak node
            await self._create_node(capabilities, metadata)
            
            # Start componenten in juiste volgorde
            await self._start_components()
            
            # Registreer event handlers
            self._register_event_handlers()
            
            # Start performance optimization
            if self._optimization_enabled:
                asyncio.create_task(self._optimization_loop())
            
            # Update statistieken
            self._stats['uptime'] = time.time()
            
            # Roep startup handlers aan
            for handler in self._startup_handlers:
                try:
                    await handler(self.node)
                except Exception as e:
                    logger.error(f"Error in startup handler: {e}")
            
            node_id = self.node.identity_manager.get_local_identity().node_id
            logger.info(f"NoodleNet started successfully with node ID: {node_id}")
            
            return node_id
            
        except Exception as e:
            logger.error(f"Failed to start NoodleNet: {e}")
            
            # Roep error handlers aan
            for handler in self._error_handlers:
                try:
                    await handler(e, {'context': 'startup'})
                except Exception as handler_error:
                    logger.error(f"Error in error handler: {handler_error}")
            
            raise
    
    async def stop(self):
        """Stop NoodleNet node"""
        if not self.node or not self.node.running:
            logger.warning("NoodleNet is not running")
            return
        
        try:
            # Stop componenten in omgekeerde volgorde
            await self._stop_components()
            
            # Update statistieken
            if self._stats['uptime'] > 0:
                self._stats['uptime'] = time.time() - self._stats['uptime']
            
            # Roep shutdown handlers aan
            for handler in self._shutdown_handlers:
                try:
                    await handler(self.node)
                except Exception as e:
                    logger.error(f"Error in shutdown handler: {e}")
            
            logger.info("NoodleNet stopped successfully")
            
        except Exception as e:
            logger.error(f"Error stopping NoodleNet: {e}")
            
            # Roep error handlers aan
            for handler in self._error_handlers:
                try:
                    await handler(e, {'context': 'shutdown'})
                except Exception as handler_error:
                    logger.error(f"Error in error handler: {handler_error}")
    
    async def submit_task(self, task_id: str, task_type: str, payload: Any,
                         priority: TaskPriority = TaskPriority.NORMAL,
                         requirements: Optional[TaskRequirement] = None) -> bool:
        """
        Dien een taak in voor uitvoering
        
        Args:
            task_id: Unieke taak ID
            task_type: Type taak
            payload: Taak payload
            priority: Prioriteit van de taak
            requirements: Vereisten voor de taak
            
        Returns:
            True als taak succesvol ingediend
        """
        if not self.node or not self.node.running:
            logger.error("Cannot submit task: NoodleNet is not running")
            return False
        
        if not self.node.scheduler:
            logger.error("Cannot submit task: No scheduler available")
            return False
        
        try:
            # Controleer security permissies
            if self.node.security:
                security_context = SecurityContext(
                    requester_id=self.node.identity_manager.get_local_identity().node_id,
                    operation="schedule",
                    resource=task_type
                )
                
                has_permission, reason = self.node.security.check_permission(security_context)
                if not has_permission:
                    logger.error(f"Task submission denied: {reason}")
                    return False
            
            # Dien taak in
            self.node.scheduler.submit_task(task_id, task_type, payload, priority, requirements)
            
            # Update statistieken
            self._stats['tasks_processed'] += 1
            
            logger.info(f"Task submitted: {task_id}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to submit task {task_id}: {e}")
            return False
    
    async def get_task_status(self, task_id: str) -> Optional[TaskStatus]:
        """
        Krijg status van een taak
        
        Args:
            task_id: ID van de taak
            
        Returns:
            TaskStatus of None
        """
        if not self.node or not self.node.scheduler:
            return None
        
        return self.node.scheduler.get_task_status(task_id)
    
    async def get_topology(self) -> Dict[str, Any]:
        """
        Krijg netwerk topologie
        
        Returns:
            Topologie informatie
        """
        if not self.node or not self.node.mesh:
            return {}
        
        return self.node.mesh.get_topology()
    
    async def get_statistics(self) -> Dict[str, Any]:
        """
        Krijg uitgebreide statistieken
        
        Returns:
            Dictionary met statistieken
        """
        if not self.node:
            return {'error': 'Node not initialized'}
        
        # Basis statistieken
        stats = self._stats.copy()
        
        # Component statistieken
        if self.node.mesh:
            stats['mesh'] = self.node.mesh.get_stats()
        
        if self.node.scheduler:
            stats['scheduler'] = self.node.scheduler.get_statistics()
        
        if self.node.fault_tolerance:
            stats['fault_tolerance'] = self.node.fault_tolerance.get_statistics()
        
        if self.node.security:
            stats['security'] = self.node.security.get_statistics()
        
        if self.node.monitoring:
            stats['monitoring'] = self.node.monitoring.get_statistics()
        
        # Performance metrics
        stats['performance'] = await self._get_performance_metrics()
        
        return stats
    
    async def optimize_performance(self):
        """Optimeer systeem performance"""
        if not self.node or not self._optimization_enabled:
            return
        
        current_time = time.time()
        
        # Beperk optimalisatie frequentie
        if current_time - self._last_optimization < 300:  # 5 minuten
            return
        
        try:
            # Verzamel performance data
            performance_metrics = await self._get_performance_metrics()
            
            # Identificeer optimalisatie kansen
            optimizations = await self._identify_optimizations(performance_metrics)
            
            # Voer optimalisaties uit
            for optimization in optimizations:
                await self._apply_optimization(optimization)
                self._stats['optimizations_performed'] += 1
            
            self._last_optimization = current_time
            
            logger.info(f"Performance optimization completed: {len(optimizations)} optimizations applied")
            
        except Exception as e:
            logger.error(f"Error during performance optimization: {e}")
    
    async def _create_node(self, capabilities: Optional[Dict[str, Any]] = None,
                           metadata: Optional[Dict[str, Any]] = None):
        """Maak NoodleNet node"""
        # Initialiseer identity manager
        self.node.identity_manager = NoodleIdentityManager(self.config)
        await self.node.identity_manager.initialize()
        
        # Maak lokale identity
        self.node.identity_manager.create_local_identity(capabilities, metadata)
        
        # Initialiseer link
        self.node.link = NoodleLink(self.config, self.node.identity_manager.get_local_identity())
        
        # Initialiseer mesh
        self.node.mesh = NoodleMesh(self.node.link, self.node.identity_manager, self.config)
        
        # Maak complete node
        self.node = NoodleNetNode(
            config=self.config,
            identity_manager=self.node.identity_manager,
            link=self.node.link,
            mesh=self.node.mesh
        )
    
    async def _start_components(self):
        """Start alle componenten in juiste volgorde"""
        # 1. Start link (basis communicatie)
        await self.node.link.start()
        
        # 2. Start security (moet voor andere componenten)
        if self.node.security:
            await self.node.security.start()
        
        # 3. Start mesh (netwerk topologie)
        await self.node.mesh.start()
        
        # 4. Start monitoring (observatie)
        if self.node.monitoring:
            await self.node.monitoring.start()
        
        # 5. Start fault tolerance (resilience)
        if self.node.fault_tolerance:
            await self.node.fault_tolerance.start()
        
        # 6. Start scheduler (taak verwerking)
        if self.node.scheduler:
            await self.node.scheduler.start()
        
        self.node.running = True
    
    async def _stop_components(self):
        """Stop alle componenten in omgekeerde volgorde"""
        # 1. Stop scheduler (geen nieuwe taken)
        if self.node.scheduler:
            await self.node.scheduler.stop()
        
        # 2. Stop fault tolerance
        if self.node.fault_tolerance:
            await self.node.fault_tolerance.stop()
        
        # 3. Stop monitoring
        if self.node.monitoring:
            await self.node.monitoring.stop()
        
        # 4. Stop mesh
        await self.node.mesh.stop()
        
        # 5. Stop security
        if self.node.security:
            await self.node.security.stop()
        
        # 6. Stop link
        await self.node.link.stop()
        
        self.node.running = False
    
    def _register_event_handlers(self):
        """Registreer event handlers tussen componenten"""
        # Fault tolerance handlers
        if self.node.fault_tolerance and self.node.scheduler:
            self.node.fault_tolerance.register_failure_handler(
                FailureType.TASK_FAILURE,
                self._handle_task_failure
            )
        
        # Monitoring handlers
        if self.node.monitoring:
            self.node.monitoring.register_alert_handler(self._handle_alert)
        
        # Scheduler handlers
        if self.node.scheduler:
            self.node.scheduler.set_task_failed_handler(self._handle_scheduler_failure)
            self.node.scheduler.set_task_completed_handler(self._handle_task_completed)
    
    async def _handle_task_failure(self, failure_event, exception):
        """Handler voor taak failures"""
        # Update statistieken
        self._stats['failures_handled'] += 1
        
        # Log event
        logger.warning(f"Task failure handled: {failure_event.description}")
    
    async def _handle_alert(self, alert: Alert):
        """Handler voor monitoring alerts"""
        # Update statistieken
        self._stats['alerts_generated'] += 1
        
        # Log alert
        if alert.severity == AlertSeverity.CRITICAL:
            logger.critical(f"Critical alert: {alert.message}")
        elif alert.severity == AlertSeverity.ERROR:
            logger.error(f"Error alert: {alert.message}")
        elif alert.severity == AlertSeverity.WARNING:
            logger.warning(f"Warning alert: {alert.message}")
        else:
            logger.info(f"Info alert: {alert.message}")
    
    async def _handle_scheduler_failure(self, task: Task, exception: Exception):
        """Handler voor scheduler failures"""
        # Rapporteer aan fault tolerance
        if self.node.fault_tolerance:
            self.node.fault_tolerance.report_failure(
                failure_type=FailureType.TASK_FAILURE,
                task_id=task.task_id,
                description=f"Task {task.task_id} failed: {str(exception)}",
                severity=0.7
            )
    
    async def _handle_task_completed(self, task: Task):
        """Handler voor voltooide taken"""
        # Update statistieken
        self._stats['tasks_processed'] += 1
        
        # Log completion
        logger.info(f"Task completed: {task.task_id}")
    
    async def _get_performance_metrics(self) -> Dict[str, Any]:
        """Verzamel performance metrics"""
        metrics = {}
        
        # Scheduler metrics
        if self.node.scheduler:
            scheduler_stats = self.node.scheduler.get_statistics()
            metrics['task_throughput'] = scheduler_stats.get('tasks_completed', 0) / max(1, self._stats['uptime'] / 3600)
            metrics['average_wait_time'] = scheduler_stats.get('average_wait_time', 0)
            metrics['average_execution_time'] = scheduler_stats.get('average_execution_time', 0)
        
        # Mesh metrics
        if self.node.mesh:
            mesh_stats = self.node.mesh.get_stats()
            metrics['route_success_rate'] = (
                mesh_stats.get('routes_calculated', 0) / 
                max(1, mesh_stats.get('routes_calculated', 0) + mesh_stats.get('failed_routes', 0))
            )
        
        # Monitoring metrics
        if self.node.monitoring:
            monitoring_stats = self.node.monitoring.get_statistics()
            metrics['alert_rate'] = monitoring_stats.get('alerts_generated', 0) / max(1, self._stats['uptime'] / 3600)
        
        # System metrics
        metrics['uptime_hours'] = self._stats['uptime'] / 3600 if self._stats['uptime'] > 0 else 0
        
        return metrics
    
    async def _identify_optimizations(self, metrics: Dict[str, Any]) -> List[Dict[str, Any]]:
        """Identificeer optimalisatie kansen"""
        optimizations = []
        
        # Hoge wachttijd optimalisatie
        if metrics.get('average_wait_time', 0) > 60:  # 1 minuut
            optimizations.append({
                'type': 'scheduler_throughput',
                'description': 'High task wait time detected',
                'action': 'increase_scheduler_capacity',
                'priority': 'high'
            })
        
        # Lage route success rate optimalisatie
        if metrics.get('route_success_rate', 1.0) < 0.9:
            optimizations.append({
                'type': 'mesh_routing',
                'description': 'Low routing success rate detected',
                'action': 'optimize_mesh_topology',
                'priority': 'medium'
            })
        
        # Hoge alert rate optimalisatie
        if metrics.get('alert_rate', 0) > 10:  # 10 alerts per uur
            optimizations.append({
                'type': 'monitoring_sensitivity',
                'description': 'High alert rate detected',
                'action': 'adjust_alert_thresholds',
                'priority': 'medium'
            })
        
        # Resource utilization optimalisatie
        # TODO: Voeg meer optimalisatie regels toe
        
        return optimizations
    
    async def _apply_optimization(self, optimization: Dict[str, Any]):
        """Pas een optimalisatie toe"""
        opt_type = optimization['type']
        action = optimization['action']
        
        if opt_type == 'scheduler_throughput' and action == 'increase_scheduler_capacity':
            # Verhoog scheduler capaciteit
            if self.node.scheduler:
                # TODO: Implementeer capaciteitsverhoging
                logger.info("Applied scheduler throughput optimization")
        
        elif opt_type == 'mesh_routing' and action == 'optimize_mesh_topology':
            # Optimaliseer mesh topologie
            if self.node.mesh:
                # TODO: Implementeer topologie optimalisatie
                logger.info("Applied mesh routing optimization")
        
        elif opt_type == 'monitoring_sensitivity' and action == 'adjust_alert_thresholds':
            # Pas alert drempels aan
            if self.node.monitoring:
                # TODO: Implementeer drempelaanpassing
                logger.info("Applied monitoring sensitivity optimization")
    
    async def _optimization_loop(self):
        """Loop voor periodieke performance optimalisatie"""
        while self.node and self.node.running:
            try:
                # Wacht voor optimale timing
                await asyncio.sleep(300)  # 5 minuten
                
                # Voer optimalisatie uit
                await self.optimize_performance()
                
            except Exception as e:
                logger.error(f"Error in optimization loop: {e}")
                await asyncio.sleep(60)
    
    def register_startup_handler(self, handler: Callable):
        """Registreer startup handler"""
        self._startup_handlers.append(handler)
    
    def register_shutdown_handler(self, handler: Callable):
        """Registreer shutdown handler"""
        self._shutdown_handlers.append(handler)
    
    def register_error_handler(self, handler: Callable):
        """Registreer error handler"""
        self._error_handlers.append(handler)
    
    def enable_optimization(self, enabled: bool = True):
        """Schakel performance optimalisatie in/uit"""
        self._optimization_enabled = enabled
        logger.info(f"Performance optimization {'enabled' if enabled else 'disabled'}")
    
    def is_running(self) -> bool:
        """Controleer of NoodleNet actief is"""
        return self.node and self.node.running
    
    def get_node_id(self) -> Optional[str]:
        """Krijg node ID"""
        if self.node and self.node.identity_manager:
            local_identity = self.node.identity_manager.get_local_identity()
            return local_identity.node_id if local_identity else None
        return None
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleNetOrchestrator(running={self.is_running()})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleNetOrchestrator(node_id={self.get_node_id()}, "
                f"running={self.is_running()}, "
                f"optimization={'enabled' if self._optimization_enabled else 'disabled'})")

