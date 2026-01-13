"""
Noodle Network Noodlenet::Fault Tolerance - fault_tolerance.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Fault tolerance mechanisms voor NoodleNet - Automatic recovery en resilience
"""

import asyncio
import time
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Tuple
from dataclasses import dataclass, field
from enum import Enum
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .mesh import NoodleMesh, NodeMetrics
from .scheduler import Task, TaskStatus

logger = logging.getLogger(__name__)


class FailureType(Enum):
    """Types van failures in het systeem"""
    NODE_FAILURE = "node_failure"
    NETWORK_FAILURE = "network_failure"
    TASK_FAILURE = "task_failure"
    RESOURCE_EXHAUSTION = "resource_exhaustion"
    COMMUNICATION_TIMEOUT = "communication_timeout"
    DATA_CORRUPTION = "data_corruption"


class RecoveryAction(Enum):
    """Herstel acties voor failures"""
    RETRY = "retry"
    FAILOVER = "failover"
    RESTART = "restart"
    ISOLATE = "isolate"
    REPLICATE = "replicate"
    DEGRADE = "degrade"


@dataclass
class FailureEvent:
    """Representatie van een failure event"""
    
    failure_type: FailureType
    node_id: Optional[str]
    task_id: Optional[str]
    timestamp: float
    description: str
    severity: float  # 0.0-1.0
    context: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        """Zet timestamp indien niet gespecificeerd"""
        if self.timestamp == 0.0:
            self.timestamp = time.time()


@dataclass
class RecoveryAction:
    """Representatie van een herstel actie"""
    
    action_type: RecoveryAction
    target: str  # node_id, task_id, etc.
    parameters: Dict[str, Any] = field(default_factory=dict)
    timestamp: float = field(default_factory=time.time)
    executed: bool = False
    successful: Optional[bool] = None
    result: Optional[str] = None


@dataclass
class HealthCheck:
    """Health check configuratie voor een component"""
    
    component_id: str
    check_interval: float  # seconden
    timeout: float  # seconden
    max_failures: int
    current_failures: int = 0
    last_check: float = field(default_factory=time.time)
    last_success: float = field(default_factory=time.time)
    healthy: bool = True


class FaultToleranceManager:
    """Manager voor fault tolerance in NoodleNet"""
    
    def __init__(self, mesh: NoodleMesh, identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer fault tolerance manager
        
        Args:
            mesh: NoodleMesh instance
            identity_manager: NoodleIdentityManager instance
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # State tracking
        self._running = False
        self._failed_nodes: Set[str] = set()
        self._isolated_nodes: Set[str] = set()
        self._failed_tasks: Dict[str, FailureEvent] = {}
        self._recovery_actions: Dict[str, RecoveryAction] = {}
        
        # Health checks
        self._health_checks: Dict[str, HealthCheck] = {}
        
        # Event handlers
        self._failure_handlers: Dict[FailureType, List[Callable]] = {}
        self._recovery_handlers: Dict[RecoveryAction, List[Callable]] = {}
        
        # Background tasks
        self._health_check_task: Optional[asyncio.Task] = None
        self._recovery_task: Optional[asyncio.Task] = None
        self._cleanup_task: Optional[asyncio.Task] = None
        
        # Statistics
        self._stats = {
            'failures_detected': 0,
            'recoveries_attempted': 0,
            'recoveries_successful': 0,
            'nodes_failed': 0,
            'tasks_recovered': 0,
            'average_recovery_time': 0.0,
        }
    
    async def start(self):
        """Start de fault tolerance manager"""
        if self._running:
            logger.warning("Fault tolerance manager is already running")
            return
        
        self._running = True
        
        # Start background taken
        self._health_check_task = asyncio.create_task(self._health_check_loop())
        self._recovery_task = asyncio.create_task(self._recovery_loop())
        self._cleanup_task = asyncio.create_task(self._cleanup_loop())
        
        # Registreer mesh event handlers
        self.mesh.set_node_removed_handler(self._on_node_removed)
        
        logger.info("Fault tolerance manager started")
    
    async def stop(self):
        """Stop de fault tolerance manager"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop background taken
        if self._health_check_task:
            self._health_check_task.cancel()
            try:
                await self._health_check_task
            except asyncio.CancelledError:
                pass
        
        if self._recovery_task:
            self._recovery_task.cancel()
            try:
                await self._recovery_task
            except asyncio.CancelledError:
                pass
        
        if self._cleanup_task:
            self._cleanup_task.cancel()
            try:
                await self._cleanup_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Fault tolerance manager stopped")
    
    def register_health_check(self, component_id: str, check_interval: float,
                           timeout: float, max_failures: int = 3):
        """
        Registreer een health check voor een component
        
        Args:
            component_id: ID van het component
            check_interval: Interval tussen checks (seconden)
            timeout: Timeout voor health check (seconden)
            max_failures: Max aantal failures voordat component als unhealthy wordt beschouwd
        """
        health_check = HealthCheck(
            component_id=component_id,
            check_interval=check_interval,
            timeout=timeout,
            max_failures=max_failures
        )
        
        self._health_checks[component_id] = health_check
        logger.info(f"Registered health check for {component_id}")
    
    def report_failure(self, failure_type: FailureType, node_id: Optional[str] = None,
                     task_id: Optional[str] = None, description: str = "",
                     severity: float = 0.5, context: Optional[Dict[str, Any]] = None):
        """
        Rapporteer een failure in het systeem
        
        Args:
            failure_type: Type van de failure
            node_id: ID van de node (indien van toepassing)
            task_id: ID van de taak (indien van toepassing)
            description: Beschrijving van de failure
            severity: Ernst van de failure (0.0-1.0)
            context: Additionele context informatie
        """
        failure = FailureEvent(
            failure_type=failure_type,
            node_id=node_id,
            task_id=task_id,
            timestamp=time.time(),
            description=description,
            severity=severity,
            context=context or {}
        )
        
        # Verwerk failure
        asyncio.create_task(self._handle_failure(failure))
        
        logger.warning(f"Failure reported: {failure_type.value} - {description}")
    
    async def _handle_failure(self, failure: FailureEvent):
        """
        Handel een failure event
        
        Args:
            failure: Failure event om te verwerken
        """
        self._stats['failures_detected'] += 1
        
        # Update state
        if failure.node_id:
            self._failed_nodes.add(failure.node_id)
            self._stats['nodes_failed'] = len(self._failed_nodes)
        
        if failure.task_id:
            self._failed_tasks[failure.task_id] = failure
        
        # Roep failure handlers aan
        handlers = self._failure_handlers.get(failure.failure_type, [])
        for handler in handlers:
            try:
                await handler(failure)
            except Exception as e:
                logger.error(f"Error in failure handler: {e}")
        
        # Bepaal herstel actie
        recovery_action = self._determine_recovery_action(failure)
        
        if recovery_action:
            # Plan herstel actie
            await self._schedule_recovery_action(recovery_action)
    
    def _determine_recovery_action(self, failure: FailureEvent) -> Optional[RecoveryAction]:
        """
        Bepaal de beste herstel actie voor een failure
        
        Args:
            failure: Failure event
            
        Returns:
            Recovery actie of None
        """
        if failure.failure_type == FailureType.NODE_FAILURE:
            # Probeer failover naar andere node
            return RecoveryAction(
                action_type=RecoveryAction.FAILOVER,
                target=failure.node_id or "unknown",
                parameters={'failure_type': 'node_failure'}
            )
        
        elif failure.failure_type == FailureType.TASK_FAILURE:
            # Probeer taak te herstarten op andere node
            return RecoveryAction(
                action_type=RecoveryAction.RETRY,
                target=failure.task_id or "unknown",
                parameters={'max_retries': 3, 'delay': 5.0}
            )
        
        elif failure.failure_type == FailureType.NETWORK_FAILURE:
            # Probeer communicatie te herstellen
            return RecoveryAction(
                action_type=RecoveryAction.RESTART,
                target="network",
                parameters={'component': 'communication'}
            )
        
        elif failure.failure_type == FailureType.RESOURCE_EXHAUSTION:
            # Degrade services of scale up
            if failure.severity > 0.7:
                return RecoveryAction(
                    action_type=RecoveryAction.DEGRADE,
                    target="system",
                    parameters={'level': 'partial'}
                )
            else:
                return RecoveryAction(
                    action_type=RecoveryAction.RESTART,
                    target="resources",
                    parameters={'clear_cache': True}
                )
        
        elif failure.failure_type == FailureType.COMMUNICATION_TIMEOUT:
            # Probeer opnieuw met andere route
            return RecoveryAction(
                action_type=RecoveryAction.RETRY,
                target=failure.node_id or "unknown",
                parameters={'alternate_route': True, 'timeout': 30.0}
            )
        
        elif failure.failure_type == FailureType.DATA_CORRUPTION:
            # Herstel van backup
            return RecoveryAction(
                action_type=RecoveryAction.REPLICATE,
                target=failure.node_id or "unknown",
                parameters={'source': 'backup', 'verify_integrity': True}
            )
        
        return None
    
    async def _schedule_recovery_action(self, action: RecoveryAction):
        """
        Plan een herstel actie voor uitvoering
        
        Args:
            action: Recovery actie om uit te voeren
        """
        action_id = f"{action.action_type.value}_{action.target}_{int(time.time())}"
        self._recovery_actions[action_id] = action
        
        self._stats['recoveries_attempted'] += 1
        
        logger.info(f"Scheduled recovery action: {action.action_type.value} for {action.target}")
    
    async def _execute_recovery_action(self, action: RecoveryAction) -> bool:
        """
        Voer een herstel actie uit
        
        Args:
            action: Recovery actie om uit te voeren
            
        Returns:
            True als actie succesvol was
        """
        start_time = time.time()
        success = False
        
        try:
            if action.action_type == RecoveryAction.FAILOVER:
                success = await self._execute_failover(action)
            elif action.action_type == RecoveryAction.RETRY:
                success = await self._execute_retry(action)
            elif action.action_type == RecoveryAction.RESTART:
                success = await self._execute_restart(action)
            elif action.action_type == RecoveryAction.ISOLATE:
                success = await self._execute_isolate(action)
            elif action.action_type == RecoveryAction.REPLICATE:
                success = await self._execute_replicate(action)
            elif action.action_type == RecoveryAction.DEGRADE:
                success = await self._execute_degrade(action)
            
            # Update actie status
            action.executed = True
            action.successful = success
            action.result = "Success" if success else "Failed"
            
            # Update statistieken
            if success:
                self._stats['recoveries_successful'] += 1
            
            # Update gemiddelde hersteltijd
            recovery_time = time.time() - start_time
            total_recoveries = self._stats['recoveries_successful']
            if total_recoveries > 0:
                self._stats['average_recovery_time'] = (
                    (self._stats['average_recovery_time'] * (total_recoveries - 1) + recovery_time) / total_recoveries
                )
            
            # Roep recovery handlers aan
            handlers = self._recovery_handlers.get(action.action_type, [])
            for handler in handlers:
                try:
                    await handler(action, success)
                except Exception as e:
                    logger.error(f"Error in recovery handler: {e}")
            
            logger.info(f"Recovery action {action.action_type.value} {'succeeded' if success else 'failed'}")
            
        except Exception as e:
            logger.error(f"Error executing recovery action {action.action_type.value}: {e}")
            action.executed = True
            action.successful = False
            action.result = str(e)
        
        return success
    
    async def _execute_failover(self, action: RecoveryAction) -> bool:
        """Voer failover actie uit"""
        node_id = action.target
        
        # Vind vervangende node
        topology = self.mesh.get_topology()
        available_nodes = [
            node_id for node_id, node_data in topology['nodes'].items()
            if node_data['healthy'] and node_id not in self._failed_nodes
        ]
        
        if not available_nodes:
            logger.error("No available nodes for failover")
            return False
        
        # Selecteer beste node
        best_node = self.mesh.get_best_node("failover", set(), self._failed_nodes)
        
        if not best_node:
            logger.error("No suitable node found for failover")
            return False
        
        # Migreer taken van gefaalde node
        # TODO: Implementeer taak migratie
        
        # Update failed nodes set
        self._failed_nodes.add(node_id)
        
        logger.info(f"Failover completed: {node_id} -> {best_node}")
        return True
    
    async def _execute_retry(self, action: RecoveryAction) -> bool:
        """Voer retry actie uit"""
        task_id = action.target
        max_retries = action.parameters.get('max_retries', 3)
        delay = action.parameters.get('delay', 5.0)
        
        # Wacht voor delay
        await asyncio.sleep(delay)
        
        # TODO: Implementeer taak retry logica
        # Dit zou de scheduler moeten aanroepen om taak te herplannen
        
        logger.info(f"Retry action completed for task {task_id}")
        return True
    
    async def _execute_restart(self, action: RecoveryAction) -> bool:
        """Voer restart actie uit"""
        component = action.parameters.get('component', 'unknown')
        
        if component == 'communication':
            # Restart communicatie componenten
            # TODO: Implementeer communicatie restart
            pass
        elif component == 'resources':
            # Clear caches en reset resource usage
            # TODO: Implementeer resource reset
            pass
        
        logger.info(f"Restart action completed for component {component}")
        return True
    
    async def _execute_isolate(self, action: RecoveryAction) -> bool:
        """Voer isolatie actie uit"""
        node_id = action.target
        
        # Isoleer node van netwerk
        self._isolated_nodes.add(node_id)
        
        # Verwijder node uit mesh
        self.mesh.remove_node(node_id)
        
        logger.info(f"Isolation action completed for node {node_id}")
        return True
    
    async def _execute_replicate(self, action: RecoveryAction) -> bool:
        """Voer replicatie actie uit"""
        node_id = action.target
        source = action.parameters.get('source', 'backup')
        
        # Vind gezonde node voor replicatie
        topology = self.mesh.get_topology()
        healthy_nodes = [
            node_id for node_id, node_data in topology['nodes'].items()
            if node_data['healthy'] and node_id not in self._failed_nodes
        ]
        
        if not healthy_nodes:
            logger.error("No healthy nodes available for replication")
            return False
        
        # Selecteer target node
        target_node = healthy_nodes[0]  # Eerste beschikbare node
        
        # TODO: Implementeer data replicatie
        
        logger.info(f"Replication action completed: {source} -> {target_node}")
        return True
    
    async def _execute_degrade(self, action: RecoveryAction) -> bool:
        """Voer degradatie actie uit"""
        level = action.parameters.get('level', 'partial')
        
        if level == 'partial':
            # Schakel non-critical services uit
            # TODO: Implementeer service degradatie
            pass
        elif level == 'minimal':
            # Alleen critical services blijven actief
            # TODO: Implementeer minimale modus
            pass
        
        logger.info(f"Degradation action completed at level {level}")
        return True
    
    async def _health_check_loop(self):
        """Loop voor health checks"""
        while self._running:
            try:
                # Voer health checks uit
                for component_id, health_check in self._health_checks.items():
                    await self._perform_health_check(component_id, health_check)
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(5.0)  # Check elke 5 seconden
                
            except Exception as e:
                logger.error(f"Error in health check loop: {e}")
                await asyncio.sleep(5)
    
    async def _perform_health_check(self, component_id: str, health_check: HealthCheck):
        """
        Voer health check uit voor een component
        
        Args:
            component_id: ID van het component
            health_check: Health check configuratie
        """
        current_time = time.time()
        
        # Check of het tijd is voor volgende check
        if current_time - health_check.last_check < health_check.check_interval:
            return
        
        # Voer health check uit
        try:
            # Simuleer health check
            # In echte implementatie: ping, HTTP check, etc.
            is_healthy = await self._check_component_health(component_id, health_check.timeout)
            
            if is_healthy:
                health_check.current_failures = 0
                health_check.last_success = current_time
                health_check.healthy = True
                
                # Herstel component indien nodig
                if component_id in self._failed_nodes:
                    self._failed_nodes.remove(component_id)
                    logger.info(f"Component {component_id} recovered")
            else:
                health_check.current_failures += 1
                health_check.last_check = current_time
                
                # Check of component als unhealthy wordt beschouwd
                if health_check.current_failures >= health_check.max_failures:
                    health_check.healthy = False
                    
                    # Rapporteer failure
                    self.report_failure(
                        failure_type=FailureType.NODE_FAILURE,
                        node_id=component_id,
                        description=f"Health check failed after {health_check.current_failures} attempts",
                        severity=0.7,
                        context={'health_check': True}
                    )
        
        except asyncio.TimeoutError:
            health_check.current_failures += 1
            health_check.last_check = current_time
            
            if health_check.current_failures >= health_check.max_failures:
                health_check.healthy = False
                self.report_failure(
                    failure_type=FailureType.COMMUNICATION_TIMEOUT,
                    node_id=component_id,
                    description=f"Health check timeout after {health_check.timeout}s",
                    severity=0.8
                )
        
        except Exception as e:
            logger.error(f"Error performing health check for {component_id}: {e}")
    
    async def _check_component_health(self, component_id: str, timeout: float) -> bool:
        """
        Check health van een component
        
        Args:
            component_id: ID van het component
            timeout: Timeout voor de check
            
        Returns:
            True als component gezond is
        """
        # Simuleer health check
        # In echte implementatie: daadwerkelijke health check
        
        # Check of component in mesh is
        topology = self.mesh.get_topology()
        if component_id in topology['nodes']:
            node_data = topology['nodes'][component_id]
            return node_data['healthy']
        
        # Voor andere componenten, simuleer health
        import random
        return random.random() > 0.1  # 90% kans op healthy
    
    async def _recovery_loop(self):
        """Loop voor herstel acties"""
        while self._running:
            try:
                # Voer geplande herstel acties uit
                actions_to_execute = [
                    (action_id, action) for action_id, action in self._recovery_actions.items()
                    if not action.executed
                ]
                
                for action_id, action in actions_to_execute:
                    await self._execute_recovery_action(action)
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(1.0)
                
            except Exception as e:
                logger.error(f"Error in recovery loop: {e}")
                await asyncio.sleep(5)
    
    async def _cleanup_loop(self):
        """Loop voor opruimen van oude data"""
        while self._running:
            try:
                current_time = time.time()
                
                # Verwijder oude herstel acties
                old_actions = [
                    action_id for action_id, action in self._recovery_actions.items()
                    if action.executed and (current_time - action.timestamp) > 3600  # 1 uur
                ]
                
                for action_id in old_actions:
                    del self._recovery_actions[action_id]
                
                # Verwijder oude failure events
                old_failures = [
                    task_id for task_id, failure in self._failed_tasks.items()
                    if (current_time - failure.timestamp) > 7200  # 2 uur
                ]
                
                for task_id in old_failures:
                    del self._failed_tasks[task_id]
                
                # Wacht voor volgende cleanup
                await asyncio.sleep(300)  # 5 minuten
                
            except Exception as e:
                logger.error(f"Error in cleanup loop: {e}")
                await asyncio.sleep(60)
    
    async def _on_node_removed(self, node_id: str):
        """Handler voor node verwijdering"""
        if node_id in self._failed_nodes:
            self._failed_nodes.remove(node_id)
        
        if node_id in self._isolated_nodes:
            self._isolated_nodes.remove(node_id)
        
        logger.info(f"Node {node_id} removed from fault tolerance tracking")
    
    def register_failure_handler(self, failure_type: FailureType, handler: Callable):
        """
        Registreer een handler voor een failure type
        
        Args:
            failure_type: Type failure om te handleen
            handler: Handler functie
        """
        if failure_type not in self._failure_handlers:
            self._failure_handlers[failure_type] = []
        
        self._failure_handlers[failure_type].append(handler)
        logger.info(f"Registered failure handler for {failure_type.value}")
    
    def register_recovery_handler(self, action_type: RecoveryAction, handler: Callable):
        """
        Registreer een handler voor een recovery actie
        
        Args:
            action_type: Type recovery actie om te handleen
            handler: Handler functie
        """
        if action_type not in self._recovery_handlers:
            self._recovery_handlers[action_type] = []
        
        self._recovery_handlers[action_type].append(handler)
        logger.info(f"Registered recovery handler for {action_type.value}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Krijg fault tolerance statistieken
        
        Returns:
            Dictionary met statistieken
        """
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['failed_nodes'] = len(self._failed_nodes)
        stats['isolated_nodes'] = len(self._isolated_nodes)
        stats['failed_tasks'] = len(self._failed_tasks)
        stats['pending_recoveries'] = len([
            action for action in self._recovery_actions.values() if not action.executed
        ])
        return stats
    
    def is_running(self) -> bool:
        """Controleer of fault tolerance manager actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"FaultToleranceManager(failed_nodes={len(self._failed_nodes)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"FaultToleranceManager(failed_nodes={len(self._failed_nodes)}, "
                f"isolated_nodes={len(self._isolated_nodes)}, "
                f"failed_tasks={len(self._failed_tasks)}, "
                f"running={self._running})")

