"""
Noodle Network Noodlenet::Scheduler - scheduler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Declaratieve scheduler voor NoodleNet - Resource-aware taak distributie
"""

import asyncio
import time
import math
import logging
from typing import Dict, List, Optional, Set, Any, Callable, Tuple
from dataclasses import dataclass, field
from enum import Enum
from .config import NoodleNetConfig
from .identity import NodeIdentity, NoodleIdentityManager
from .mesh import NoodleMesh, NodeMetrics

logger = logging.getLogger(__name__)


class TaskStatus(Enum):
    """Status van een taak in de scheduler"""
    PENDING = "pending"
    SCHEDULED = "scheduled"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"


class TaskPriority(Enum):
    """Prioriteit van taken"""
    LOW = 1
    NORMAL = 2
    HIGH = 3
    CRITICAL = 4


class HardwareType(Enum):
    """Hardware types voor taak uitvoering"""
    CPU = "cpu"
    GPU = "gpu"
    NPU = "npu"
    MIXED = "mixed"


@dataclass
class TaskRequirement:
    """Vereisten voor een taak"""
    
    # Basis vereisten
    cpu_cores: int = 1
    memory_mb: int = 512
    storage_mb: int = 1024
    
    # Hardware vereisten
    preferred_hardware: HardwareType = HardwareType.CPU
    gpu_memory_mb: int = 0
    npu_units: int = 0
    
    # Netwerk vereisten
    bandwidth_mbps: float = 10.0
    latency_ms: float = 100.0
    
    # Performance vereisten
    max_execution_time: float = 3600.0  # seconden
    reliability_threshold: float = 0.95
    
    def get_hardware_score(self, node_metrics: NodeMetrics) -> float:
        """
        Bereken score voor hardware match
        
        Args:
            node_metrics: Metrieken van de node
            
        Returns:
            Hardware match score (0.0-1.0)
        """
        score = 1.0
        
        # CPU cores check
        if node_metrics.cpu_usage > (1.0 - (self.cpu_cores / 8.0)):
            score *= 0.5
        
        # Memory check
        if node_metrics.memory_usage > (1.0 - (self.memory_mb / 8192.0)):
            score *= 0.5
        
        # Hardware preference
        if self.preferred_hardware == HardwareType.GPU:
            if node_metrics.gpu_usage > 0.8:
                score *= 0.3
        elif self.preferred_hardware == HardwareType.NPU:
            # NPU availability check (simulated)
            if not hasattr(node_metrics, 'npu_usage') or node_metrics.npu_usage > 0.8:
                score *= 0.3
        
        # Network requirements
        if node_metrics.bandwidth_down < self.bandwidth_mbps:
            score *= 0.7
        if node_metrics.latency > self.latency_ms:
            score *= 0.8
        
        # Reliability check
        if node_metrics.uptime < self.reliability_threshold:
            score *= 0.5
        
        return max(0.0, min(1.0, score))


@dataclass
class Task:
    """Taak definitie voor de scheduler"""
    
    # Basis informatie
    task_id: str
    task_type: str
    payload: Any
    priority: TaskPriority = TaskPriority.NORMAL
    
    # Vereisten
    requirements: TaskRequirement = field(default_factory=TaskRequirement)
    
    # Status tracking
    status: TaskStatus = TaskStatus.PENDING
    created_at: float = field(default_factory=time.time)
    scheduled_at: Optional[float] = None
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    
    # Uitvoering
    assigned_node: Optional[str] = None
    execution_time: Optional[float] = None
    result: Optional[Any] = None
    error: Optional[str] = None
    
    # Cost tracking
    estimated_cost: float = 0.0
    actual_cost: float = 0.0
    
    def get_wait_time(self) -> float:
        """Krijg wachttijd van taak"""
        if self.scheduled_at:
            return self.scheduled_at - self.created_at
        return time.time() - self.created_at
    
    def get_execution_time(self) -> Optional[float]:
        """Krijg uitvoeringstijd"""
        if self.started_at and self.completed_at:
            return self.completed_at - self.started_at
        return None
    
    def get_total_time(self) -> Optional[float]:
        """Krijg totale tijd van creatie tot voltooiing"""
        if self.completed_at:
            return self.completed_at - self.created_at
        return None


@dataclass
class CostModel:
    """Cost model voor taak uitvoering"""
    
    # Cost factors
    cpu_cost_per_hour: float = 0.1
    memory_cost_per_gb_hour: float = 0.05
    gpu_cost_per_hour: float = 0.5
    npu_cost_per_hour: float = 0.3
    storage_cost_per_gb_hour: float = 0.01
    network_cost_per_gb: float = 0.1
    
    # Multipliers
    priority_multiplier: Dict[TaskPriority, float] = field(default_factory=lambda: {
        TaskPriority.LOW: 0.8,
        TaskPriority.NORMAL: 1.0,
        TaskPriority.HIGH: 1.5,
        TaskPriority.CRITICAL: 2.0
    })
    
    def calculate_cost(self, task: Task, execution_time: float, 
                     node_metrics: NodeMetrics) -> float:
        """
        Bereken kost voor taak uitvoering
        
        Args:
            task: Taak om kost te berekenen
            execution_time: Uitvoeringstijd in uren
            node_metrics: Metrieken van uitvoerende node
            
        Returns:
            Berekende kost
        """
        # Basis hardware kosten
        cpu_cost = task.requirements.cpu_cores * self.cpu_cost_per_hour * execution_time
        memory_cost = (task.requirements.memory_mb / 1024.0) * self.memory_cost_per_gb_hour * execution_time
        storage_cost = (task.requirements.storage_mb / 1024.0) * self.storage_cost_per_gb_hour * execution_time
        
        # Hardware specifieke kosten
        gpu_cost = 0.0
        if task.requirements.preferred_hardware == HardwareType.GPU:
            gpu_cost = self.gpu_cost_per_hour * execution_time
        
        npu_cost = 0.0
        if task.requirements.preferred_hardware == HardwareType.NPU:
            npu_cost = self.npu_cost_per_hour * execution_time
        
        # Network kosten (geschat)
        network_cost = 0.0  # TODO: Implementeer network usage tracking
        
        # Basis kost
        base_cost = cpu_cost + memory_cost + storage_cost + gpu_cost + npu_cost + network_cost
        
        # Priority multiplier
        priority_mult = self.priority_multiplier.get(task.priority, 1.0)
        
        # Node performance factor (betere nodes zijn duurder)
        performance_factor = 1.0 + (1.0 - node_metrics.get_quality_score()) * 0.5
        
        return base_cost * priority_mult * performance_factor


class DeclarativeScheduler:
    """Declaratieve scheduler voor NoodleNet"""
    
    def __init__(self, mesh: NoodleMesh, identity_manager: NoodleIdentityManager,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de scheduler
        
        Args:
            mesh: NoodleMesh instance voor topologie
            identity_manager: NoodleIdentityManager voor node info
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.identity_manager = identity_manager
        self.config = config or NoodleNetConfig()
        
        # Scheduler state
        self._running = False
        self._tasks: Dict[str, Task] = {}
        self._task_queue: List[Task] = []
        self._running_tasks: Dict[str, Task] = {}
        
        # Cost model
        self.cost_model = CostModel()
        
        # Event handlers
        self._task_scheduled_handler: Optional[Callable] = None
        self._task_completed_handler: Optional[Callable] = None
        self._task_failed_handler: Optional[Callable] = None
        
        # Scheduling loop
        self._scheduling_task: Optional[asyncio.Task] = None
        
        # Statistics
        self._stats = {
            'tasks_submitted': 0,
            'tasks_scheduled': 0,
            'tasks_completed': 0,
            'tasks_failed': 0,
            'total_cost': 0.0,
            'average_wait_time': 0.0,
            'average_execution_time': 0.0,
        }
    
    async def start(self):
        """Start de scheduler"""
        if self._running:
            logger.warning("Scheduler is already running")
            return
        
        self._running = True
        
        # Start scheduling loop
        self._scheduling_task = asyncio.create_task(self._scheduling_loop())
        
        logger.info("Declarative scheduler started")
    
    async def stop(self):
        """Stop de scheduler"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop scheduling loop
        if self._scheduling_task:
            self._scheduling_task.cancel()
            try:
                await self._scheduling_task
            except asyncio.CancelledError:
                pass
        
        # Cancel all pending tasks
        for task in self._task_queue:
            task.status = TaskStatus.CANCELLED
        
        logger.info("Declarative scheduler stopped")
    
    def submit_task(self, task_id: str, task_type: str, payload: Any,
                   priority: TaskPriority = TaskPriority.NORMAL,
                   requirements: Optional[TaskRequirement] = None) -> str:
        """
        Dien een taak in voor uitvoering
        
        Args:
            task_id: Unieke taak ID
            task_type: Type taak
            payload: Taak payload
            priority: Prioriteit van de taak
            requirements: Vereisten voor de taak
            
        Returns:
            Taak ID
        """
        if task_id in self._tasks:
            raise ValueError(f"Task {task_id} already exists")
        
        # Maak taak
        task = Task(
            task_id=task_id,
            task_type=task_type,
            payload=payload,
            priority=priority,
            requirements=requirements or TaskRequirement()
        )
        
        # Schat kost
        task.estimated_cost = self._estimate_task_cost(task)
        
        # Voeg toe aan systemen
        self._tasks[task_id] = task
        self._task_queue.append(task)
        
        # Sorteer queue op prioriteit
        self._task_queue.sort(key=lambda t: t.priority.value, reverse=True)
        
        self._stats['tasks_submitted'] += 1
        
        logger.info(f"Task submitted: {task_id} (priority: {priority.name})")
        return task_id
    
    def cancel_task(self, task_id: str) -> bool:
        """
        Annuleer een taak
        
        Args:
            task_id: ID van de taak om te annuleren
            
        Returns:
            True als taak geannuleerd is
        """
        if task_id not in self._tasks:
            return False
        
        task = self._tasks[task_id]
        
        # Kan alleen pending taken annuleren
        if task.status != TaskStatus.PENDING:
            return False
        
        # Verwijder uit queue
        if task in self._task_queue:
            self._task_queue.remove(task)
        
        # Update status
        task.status = TaskStatus.CANCELLED
        task.completed_at = time.time()
        
        logger.info(f"Task cancelled: {task_id}")
        return True
    
    def get_task_status(self, task_id: str) -> Optional[TaskStatus]:
        """
        Krijg status van een taak
        
        Args:
            task_id: ID van de taak
            
        Returns:
            TaskStatus of None als taak niet gevonden
        """
        task = self._tasks.get(task_id)
        return task.status if task else None
    
    def get_task(self, task_id: str) -> Optional[Task]:
        """
        Krijg taak informatie
        
        Args:
            task_id: ID van de taak
            
        Returns:
            Task object of None als niet gevonden
        """
        return self._tasks.get(task_id)
    
    def get_tasks_by_status(self, status: TaskStatus) -> List[Task]:
        """
        Krijg taken op basis van status
        
        Args:
            status: Status om te filteren
            
        Returns:
            Lijst met taken met gegeven status
        """
        return [task for task in self._tasks.values() if task.status == status]
    
    def _estimate_task_cost(self, task: Task) -> float:
        """Schat kost van taak op basis van vereisten"""
        # Gebruik gemiddelde node metrics voor schatting
        avg_metrics = self._get_average_node_metrics()
        if not avg_metrics:
            return 0.0
        
        # Schat uitvoeringstijd (simulated)
        estimated_time = 1.0  # uur
        
        # Bereken kost
        return self.cost_model.calculate_cost(task, estimated_time, avg_metrics)
    
    def _get_average_node_metrics(self) -> Optional[NodeMetrics]:
        """Krijg gemiddelde node metrics van alle nodes"""
        topology = self.mesh.get_topology()
        
        if not topology['nodes']:
            return None
        
        # Bereken gemiddelden
        total_nodes = len(topology['nodes'])
        avg_cpu = sum(node['cpu_usage'] for node in topology['nodes'].values()) / total_nodes
        avg_memory = sum(node['memory_usage'] for node in topology['nodes'].values()) / total_nodes
        avg_gpu = sum(node['gpu_usage'] for node in topology['nodes'].values()) / total_nodes
        avg_latency = sum(node['latency'] for node in topology['nodes'].values()) / total_nodes
        avg_bandwidth = sum(node.get('bandwidth_down', 100.0) for node in topology['nodes'].values()) / total_nodes
        avg_uptime = sum(node['uptime'] for node in topology['nodes'].values()) / total_nodes
        
        # Maak gemiddelde metrics
        return NodeMetrics(
            node_id="average",
            hostname="average",
            cpu_usage=avg_cpu,
            memory_usage=avg_memory,
            gpu_usage=avg_gpu,
            latency=avg_latency,
            bandwidth_down=avg_bandwidth,
            uptime=avg_uptime
        )
    
    async def _scheduling_loop(self):
        """Hoofd scheduling loop"""
        while self._running:
            try:
                # Verwerk pending taken
                await self._schedule_pending_tasks()
                
                # Monitor lopende taken
                await self._monitor_running_tasks()
                
                # Update statistieken
                self._update_statistics()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(self.config.scheduler_interval)
                
            except Exception as e:
                logger.error(f"Error in scheduling loop: {e}")
                await asyncio.sleep(5)
    
    async def _schedule_pending_tasks(self):
        """Plan pending taken in"""
        if not self._task_queue:
            return
        
        # Verwerk taken in prioriteit volgorde
        tasks_to_schedule = self._task_queue.copy()
        
        for task in tasks_to_schedule:
            if task.status != TaskStatus.PENDING:
                continue
            
            # Vind beste node voor taak
            best_node = await self._find_best_node_for_task(task)
            
            if best_node:
                # Plan taak in
                await self._schedule_task(task, best_node)
            else:
                # Geen geschikte node gevonden, wacht
                logger.debug(f"No suitable node found for task {task.task_id}")
    
    async def _find_best_node_for_task(self, task: Task) -> Optional[str]:
        """
        Vind de beste node voor een taak
        
        Args:
            task: Taak om in te plannen
            
        Returns:
            Beste node ID of None
        """
        # Haal capabilities op
        required_capabilities = set()
        if task.requirements.preferred_hardware == HardwareType.GPU:
            required_capabilities.add("gpu")
        elif task.requirements.preferred_hardware == HardwareType.NPU:
            required_capabilities.add("npu")
        
        # Vind beste node via mesh
        best_node = self.mesh.get_best_node(
            task_type=task.task_type,
            capabilities=required_capabilities,
            exclude_nodes=set(self._running_tasks.keys())
        )
        
        return best_node
    
    async def _schedule_task(self, task: Task, node_id: str):
        """
        Plan een taak in op een specifieke node
        
        Args:
            task: Taak om in te plannen
            node_id: Node ID voor uitvoering
        """
        # Update taak status
        task.status = TaskStatus.SCHEDULED
        task.scheduled_at = time.time()
        task.assigned_node = node_id
        
        # Verwijder uit queue
        if task in self._task_queue:
            self._task_queue.remove(task)
        
        # Voeg toe aan lopende taken
        self._running_tasks[task.task_id] = task
        
        # Start taak op node (simulated)
        asyncio.create_task(self._execute_task(task, node_id))
        
        self._stats['tasks_scheduled'] += 1
        
        # Roep handler aan
        if self._task_scheduled_handler:
            self._task_scheduled_handler(task, node_id)
        
        logger.info(f"Task {task.task_id} scheduled on node {node_id}")
    
    async def _execute_task(self, task: Task, node_id: str):
        """
        Voer taak uit op node
        
        Args:
            task: Taak om uit te voeren
            node_id: Node ID voor uitvoering
        """
        try:
            # Update status
            task.status = TaskStatus.RUNNING
            task.started_at = time.time()
            
            # Simuleer taak uitvoering
            execution_time = self._simulate_task_execution(task)
            await asyncio.sleep(execution_time)
            
            # Update status
            task.status = TaskStatus.COMPLETED
            task.completed_at = time.time()
            task.execution_time = task.completed_at - task.started_at
            
            # Bereken werkelijke kost
            node_metrics = self._get_node_metrics(node_id)
            if node_metrics:
                task.actual_cost = self.cost_model.calculate_cost(
                    task, task.execution_time / 3600.0, node_metrics
                )
                self._stats['total_cost'] += task.actual_cost
            
            # Verwijder uit lopende taken
            if task.task_id in self._running_tasks:
                del self._running_tasks[task.task_id]
            
            self._stats['tasks_completed'] += 1
            
            # Roep handler aan
            if self._task_completed_handler:
                self._task_completed_handler(task)
            
            logger.info(f"Task {task.task_id} completed on node {node_id}")
            
        except Exception as e:
            # Update status
            task.status = TaskStatus.FAILED
            task.completed_at = time.time()
            task.error = str(e)
            
            # Verwijder uit lopende taken
            if task.task_id in self._running_tasks:
                del self._running_tasks[task.task_id]
            
            self._stats['tasks_failed'] += 1
            
            # Roep handler aan
            if self._task_failed_handler:
                self._task_failed_handler(task, e)
            
            logger.error(f"Task {task.task_id} failed on node {node_id}: {e}")
    
    def _simulate_task_execution(self, task: Task) -> float:
        """
        Simuleer taak uitvoeringstijd
        
        Args:
            task: Taak om te simuleren
            
        Returns:
            Gesimuleerde uitvoeringstijd in seconden
        """
        # Basis tijd op basis van taak type
        base_times = {
            'ai_inference': 5.0,
            'data_processing': 10.0,
            'storage': 2.0,
            'network': 3.0,
            'compute': 15.0,
        }
        
        base_time = base_times.get(task.task_type, 10.0)
        
        # Pas aan op basis van vereisten
        cpu_factor = task.requirements.cpu_cores / 4.0
        memory_factor = max(0.5, task.requirements.memory_mb / 2048.0)
        
        # Hardware aanpassingen
        hardware_factor = 1.0
        if task.requirements.preferred_hardware == HardwareType.GPU:
            hardware_factor = 0.3  # GPU is sneller
        elif task.requirements.preferred_hardware == HardwareType.NPU:
            hardware_factor = 0.2  # NPU is nog sneller
        
        # Bereken gesimuleerde tijd
        simulated_time = base_time / (cpu_factor * memory_factor * hardware_factor)
        
        # Voeg wat random variatie toe
        import random
        variation = random.uniform(0.8, 1.2)
        
        return simulated_time * variation
    
    def _get_node_metrics(self, node_id: str) -> Optional[NodeMetrics]:
        """Krijg metrics voor een specifieke node"""
        topology = self.mesh.get_topology()
        node_data = topology['nodes'].get(node_id)
        
        if not node_data:
            return None
        
        return NodeMetrics(
            node_id=node_id,
            hostname=node_data['hostname'],
            cpu_usage=node_data['cpu_usage'],
            memory_usage=node_data['memory_usage'],
            gpu_usage=node_data['gpu_usage'],
            latency=node_data['latency'],
            bandwidth_down=node_data.get('bandwidth_down', 100.0),
            uptime=node_data['uptime']
        )
    
    async def _monitor_running_tasks(self):
        """Monitor lopende taken voor timeouts en failures"""
        current_time = time.time()
        
        for task_id, task in list(self._running_tasks.items()):
            # Check timeout
            if (current_time - task.started_at) > task.requirements.max_execution_time:
                logger.warning(f"Task {task_id} timed out")
                
                # Update status
                task.status = TaskStatus.FAILED
                task.completed_at = current_time
                task.error = "Execution timeout"
                
                # Verwijder uit lopende taken
                del self._running_tasks[task_id]
                
                self._stats['tasks_failed'] += 1
                
                # Roep handler aan
                if self._task_failed_handler:
                    self._task_failed_handler(task, TimeoutError("Task execution timeout"))
    
    def _update_statistics(self):
        """Update scheduler statistieken"""
        completed_tasks = self.get_tasks_by_status(TaskStatus.COMPLETED)
        
        if completed_tasks:
            # Bereken gemiddelde wachttijd
            wait_times = [task.get_wait_time() for task in completed_tasks]
            self._stats['average_wait_time'] = sum(wait_times) / len(wait_times)
            
            # Bereken gemiddelde uitvoeringstijd
            exec_times = [task.get_execution_time() for task in completed_tasks if task.get_execution_time()]
            if exec_times:
                self._stats['average_execution_time'] = sum(exec_times) / len(exec_times)
    
    def get_statistics(self) -> Dict[str, Any]:
        """
        Krijg scheduler statistieken
        
        Returns:
            Dictionary met statistieken
        """
        stats = self._stats.copy()
        stats['running'] = self._running
        stats['pending_tasks'] = len(self.get_tasks_by_status(TaskStatus.PENDING))
        stats['running_tasks'] = len(self._running_tasks)
        stats['completed_tasks'] = len(self.get_tasks_by_status(TaskStatus.COMPLETED))
        stats['failed_tasks'] = len(self.get_tasks_by_status(TaskStatus.FAILED))
        return stats
    
    def set_task_scheduled_handler(self, handler: Callable[[Task, str], None]):
        """Stel handler in voor geplande taken"""
        self._task_scheduled_handler = handler
    
    def set_task_completed_handler(self, handler: Callable[[Task], None]):
        """Stel handler in voor voltooide taken"""
        self._task_completed_handler = handler
    
    def set_task_failed_handler(self, handler: Callable[[Task, Exception], None]):
        """Stel handler in voor gefaalde taken"""
        self._task_failed_handler = handler
    
    def is_running(self) -> bool:
        """Controleer of scheduler actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"DeclarativeScheduler(tasks={len(self._tasks)}, running={self._running})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"DeclarativeScheduler(pending={len(self._task_queue)}, "
                f"running={len(self._running_tasks)}, "
                f"completed={len(self.get_tasks_by_status(TaskStatus.COMPLETED))})")

