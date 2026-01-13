"""
Core::Interface - interface.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore interface - Directe integratie met NoodleCore native uitvoering
"""

import asyncio
import time
import json
import logging
import subprocess
import tempfile
import os
from typing import Dict, List, Optional, Set, Any, Callable, Union
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from ..link import NoodleLink, Message
from ..ahr.ahr_base import ExecutionMode, ModelComponent

logger = logging.getLogger(__name__)


class ExecutionType(Enum):
    """Soorten NoodleCore uitvoering"""
    MATRIX_OPERATION = "matrix_operation"
    NEURAL_NETWORK = "neural_network"
    DATABASE_QUERY = "database_query"
    NATIVE_CODE = "native_code"
    COMPOSITE = "composite"


@dataclass
class NoodleCoreRequest:
    """Request voor NoodleCore uitvoering"""
    
    request_id: str
    execution_type: ExecutionType
    payload: Dict[str, Any]
    target_node: Optional[str] = None
    priority: int = 1  # 1-5, 5 = hoogste prioriteit
    timeout: float = 30.0  # seconden
    created_at: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'request_id': self.request_id,
            'execution_type': self.execution_type.value,
            'payload': self.payload,
            'target_node': self.target_node,
            'priority': self.priority,
            'timeout': self.timeout,
            'created_at': self.created_at
        }


@dataclass
class NoodleCoreResponse:
    """Response van NoodleCore uitvoering"""
    
    request_id: str
    success: bool
    execution_type: Optional[ExecutionType] = None
    result: Optional[Any] = None
    error_message: Optional[str] = None
    execution_time: float = 0.0
    memory_used: float = 0.0  # MB
    cpu_used: float = 0.0  # percentage
    created_at: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'request_id': self.request_id,
            'success': self.success,
            'execution_type': self.execution_type.value if self.execution_type else None,
            'result': self.result,
            'error_message': self.error_message,
            'execution_time': self.execution_time,
            'memory_used': self.memory_used,
            'cpu_used': self.cpu_used,
            'created_at': self.created_at
        }


class NoodleCoreInterface:
    """Directe interface met NoodleCore voor native uitvoering"""
    
    def __init__(self, link: NoodleLink, mesh: NoodleMesh,
                 config: Optional[NoodleNetConfig] = None, 
                 identity_manager=None):
        """
        Initialiseer de NoodleCore interface
        
        Args:
            link: NoodleLink instantie
            mesh: NoodleMesh instantie
            config: NoodleNet configuratie
            identity_manager: NoodleIdentityManager optioneel
        """
        self.link = link
        self.mesh = mesh
        self.config = config or NoodleNetConfig()
        self.identity_manager = identity_manager
        
        # NoodleCore process management
        self.noodlecore_processes: Dict[str, subprocess.Popen] = {}
        self.temp_dir = Path(tempfile.gettempdir()) / "noodlenet_core"
        self.temp_dir.mkdir(exist_ok=True)
        
        # Request tracking
        self.pending_requests: Dict[str, NoodleCoreRequest] = {}
        self.completed_requests: Dict[str, NoodleCoreResponse] = {}
        
        # Configuration
        self.core_settings = {
            'max_concurrent_requests': 10,
            'request_timeout': 30.0,
            'memory_limit_mb': 2048,
            'cpu_limit_percent': 80,
            'enable_profiling': False,
            'log_level': 'INFO'
        }
        
        # Event handlers
        self.request_completed_handler: Optional[Callable] = None
        self.request_failed_handler: Optional[Callable] = None
        self.core_available_handler: Optional[Callable] = None
        self.core_unavailable_handler: Optional[Callable] = None
        
        # Threading
        self._running = False
        self._request_processor_task = None
        self._monitoring_task = None
        
    async def start(self):
        """Start de NoodleCore interface"""
        if self._running:
            logger.warning("NoodleCore interface is already running")
            return
        
        self._running = True
        
        # Start request processor
        self._request_processor_task = asyncio.create_task(
            self._request_processor_loop()
        )
        
        # Start monitoring
        self._monitoring_task = asyncio.create_task(
            self._monitoring_loop()
        )
        
        logger.info("NoodleCore interface started")
    
    async def stop(self):
        """Stop de NoodleCore interface"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop taken
        if self._request_processor_task:
            self._request_processor_task.cancel()
            try:
                await self._request_processor_task
            except asyncio.CancelledError:
                pass
        
        if self._monitoring_task:
            self._monitoring_task.cancel()
            try:
                await self._monitoring_task
            except asyncio.CancelledError:
                pass
        
        # Stop NoodleCore processes
        for process in self.noodlecore_processes.values():
            try:
                process.terminate()
                process.wait(timeout=5.0)
            except subprocess.TimeoutExpired:
                process.kill()
        
        self.noodlecore_processes.clear()
        
        logger.info("NoodleCore interface stopped")
    
    async def execute_matrix_operation(self, matrix_a: List[List[float]], 
                                    matrix_b: List[List[float]],
                                    operation: str = "multiply") -> NoodleCoreResponse:
        """
        Voer een matrix operatie uit met NoodleCore
        
        Args:
            matrix_a: Eerste matrix
            matrix_b: Tweede matrix
            operation: Te verrichten operatie
            
        Returns:
            NoodleCoreResponse met resultaat
        """
        request_id = self._generate_request_id()
        
        request = NoodleCoreRequest(
            request_id=request_id,
            execution_type=ExecutionType.MATRIX_OPERATION,
            payload={
                'matrix_a': matrix_a,
                'matrix_b': matrix_b,
                'operation': operation
            }
        )
        
        return await self._execute_request(request)
    
    async def execute_neural_network(self, model_path: str, input_data: Any,
                                   config: Optional[Dict[str, Any]] = None) -> NoodleCoreResponse:
        """
        Voer een neuraal netwerk uit met NoodleCore
        
        Args:
            model_path: Pad naar het model
            input_data: Input data
            config: Configuratie opties
            
        Returns:
            NoodleCoreResponse met resultaat
        """
        request_id = self._generate_request_id()
        
        request = NoodleCoreRequest(
            request_id=request_id,
            execution_type=ExecutionType.NEURAL_NETWORK,
            payload={
                'model_path': model_path,
                'input_data': input_data,
                'config': config or {}
            }
        )
        
        return await self._execute_request(request)
    
    async def execute_database_query(self, query: str, params: Optional[Dict[str, Any]] = None,
                                   connection_string: Optional[str] = None) -> NoodleCoreResponse:
        """
        Voer een database query uit met NoodleCore
        
        Args:
            query: SQL query
            params: Query parameters
            connection_string: Database connectie string
            
        Returns:
            NoodleCoreResponse met resultaat
        """
        request_id = self._generate_request_id()
        
        request = NoodleCoreRequest(
            request_id=request_id,
            execution_type=ExecutionType.DATABASE_QUERY,
            payload={
                'query': query,
                'params': params or {},
                'connection_string': connection_string
            }
        )
        
        return await self._execute_request(request)
    
    async def execute_native_code(self, code: str, language: str = "nbc",
                                functions: Optional[List[str]] = None) -> NoodleCoreResponse:
        """
        Voer native code uit met NoodleCore
        
        Args:
            code: Code om uit te voeren
            language: Programmeertaal
            functions: Functies om aan te roepen
            
        Returns:
            NoodleCoreResponse met resultaat
        """
        request_id = self._generate_request_id()
        
        request = NoodleCoreRequest(
            request_id=request_id,
            execution_type=ExecutionType.NATIVE_CODE,
            payload={
                'code': code,
                'language': language,
                'functions': functions or []
            }
        )
        
        return await self._execute_request(request)
    
    async def execute_composite(self, operations: List[Dict[str, Any]]) -> NoodleCoreResponse:
        """
        Voer een composite operatie uit meerdere stappen
        
        Args:
            operations: Lijst met operaties
            
        Returns:
            NoodleCoreResponse met resultaat
        """
        request_id = self._generate_request_id()
        
        request = NoodleCoreRequest(
            request_id=request_id,
            execution_type=ExecutionType.COMPOSITE,
            payload={
                'operations': operations
            }
        )
        
        return await self._execute_request(request)
    
    async def _execute_request(self, request: NoodleCoreRequest) -> NoodleCoreResponse:
        """
        Voer een request uit
        
        Args:
            request: NoodleCoreRequest om uit te voeren
            
        Returns:
            NoodleCoreResponse
        """
        # Voeg toe aan pending requests
        self.pending_requests[request.request_id] = request
        
        # Selecteer target node
        if not request.target_node:
            request.target_node = await self._select_optimal_node(request)
        
        if not request.target_node:
            # Voer lokaal uit
            return await self._execute_local_request(request)
        else:
            # Stuur naar remote node
            return await self._execute_remote_request(request)
    
    async def _execute_local_request(self, request: NoodleCoreRequest) -> NoodleCoreResponse:
        """Voer een request lokaal uit"""
        start_time = time.time()
        
        try:
            # Start NoodleCore process
            process = await self._start_noodlecore_process()
            
            # Prepare request data
            request_data = request.to_dict()
            
            # Stuur request naar NoodleCore
            stdout, stderr = await self._communicate_with_process(
                process, json.dumps(request_data)
            )
            
            # Parse response
            response_data = json.loads(stdout)
            response = NoodleCoreResponse(**response_data)
            
            # Bereken statistieken
            response.execution_time = time.time() - start_time
            
            logger.info(f"Executed local request {request.request_id}: {response.success}")
            
            return response
            
        except Exception as e:
            logger.error(f"Failed to execute local request {request.request_id}: {e}")
            
            # Maak error response
            return NoodleCoreResponse(
                request_id=request.request_id,
                success=False,
                error_message=str(e),
                execution_time=time.time() - start_time
            )
    
    async def _execute_remote_request(self, request: NoodleCoreRequest) -> NoodleCoreResponse:
        """Voer een request uit op een remote node"""
        try:
            # Maak message
            link_msg = Message(
                sender_id=self.identity_manager.get_local_identity().node_id,
                recipient_id=request.target_node,
                message_type="noodlecore_request",
                payload=request.to_dict()
            )
            
            # Stuur request
            success = await self.link.send(request.target_node, link_msg)
            
            if success:
                # Wacht op response (simulatie)
                await asyncio.sleep(0.1)  # In echte implementatie: wacht op response
                
                # Maak simpele response
                return NoodleCoreResponse(
                    request_id=request.request_id,
                    success=True,
                    result={"status": "remote_execution_started"},
                    execution_time=0.1
                )
            else:
                raise Exception("Failed to send request to remote node")
                
        except Exception as e:
            logger.error(f"Failed to execute remote request {request.request_id}: {e}")
            
            # Fallback naar lokale uitvoering
            return await self._execute_local_request(request)
    
    async def _start_noodlecore_process(self) -> subprocess.Popen:
        """Start een NoodleCore process"""
        # Simuleer NoodleCore process start
        # In een echte implementatie: start het daadwerkelijke NoodleCore proces
        
        # Maak dummy process
        process = subprocess.Popen(
            ["echo", "NoodleCore process started"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        
        self.noodlecore_processes[str(id(process))] = process
        
        logger.info("Started NoodleCore process")
        return process
    
    async def _communicate_with_process(self, process: subprocess.Popen, 
                                     input_data: str) -> tuple:
        """Communicatie met NoodleCore process"""
        # Simuleer communicatie
        await asyncio.sleep(0.1)
        
        # Maak dummy response
        response_data = {
            "request_id": "dummy_request",
            "success": True,
            "result": {"output": "dummy_result"},
            "execution_time": 0.1,
            "memory_used": 100.0,
            "cpu_used": 10.0
        }
        
        return json.dumps(response_data), ""
    
    async def _select_optimal_node(self, request: NoodleCoreRequest) -> Optional[str]:
        """Selecteer de optimale node voor een request"""
        # Bepaal vereiste capabilities op basis van execution type
        if request.execution_type == ExecutionType.MATRIX_OPERATION:
            capabilities = {"matrix_ops": True}
        elif request.execution_type == ExecutionType.NEURAL_NETWORK:
            capabilities = {"ai": True, "gpu": True}
        elif request.execution_type == ExecutionType.DATABASE_QUERY:
            capabilities = {"database": True}
        elif request.execution_type == ExecutionType.NATIVE_CODE:
            capabilities = {"native": True}
        else:
            capabilities = {"general": True}
        
        # Vind beste node
        best_node = self.mesh.get_best_node("general", capabilities)
        
        return best_node
    
    def _generate_request_id(self) -> str:
        """Genereer een unieke request ID"""
        timestamp = int(time.time() * 1000)  # milliseconden
        unique_id = f"req_{timestamp}_{len(self.pending_requests)}"
        return unique_id
    
    async def _request_processor_loop(self):
        """Hoofd request processor loop"""
        while self._running:
            try:
                # Verwerk pending requests
                await self._process_pending_requests()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Error in request processor loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _process_pending_requests(self):
        """Verwerk pending requests"""
        if not self.pending_requests:
            return
        
        # Beperk aantal tegelijk lopende requests
        max_concurrent = self.core_settings['max_concurrent_requests']
        running_count = len([r for r in self.pending_requests.values() 
                           if r.created_at > time.time() - 1.0])
        
        if running_count >= max_concurrent:
            return
        
        # Selecteer requests om te starten
        pending_list = list(self.pending_requests.values())
        available_slots = max_concurrent - running_count
        
        for i in range(min(available_slots, len(pending_list))):
            request = pending_list[i]
            
            # Start request
            asyncio.create_task(self._process_single_request(request))
    
    async def _process_single_request(self, request: NoodleCoreRequest):
        """Verwerk een enkele request"""
        try:
            # Voer request uit
            response = await self._execute_request(request)
            
            # Verwerk response
            await self._handle_response(request, response)
            
        except Exception as e:
            logger.error(f"Error processing request {request.request_id}: {e}")
            
            # Maak error response
            response = NoodleCoreResponse(
                request_id=request.request_id,
                success=False,
                error_message=str(e)
            )
            
            await self._handle_response(request, response)
    
    async def _handle_response(self, request: NoodleCoreRequest, 
                             response: NoodleCoreResponse):
        """Verwerk een response"""
        # Verplaats van pending naar completed
        if request.request_id in self.pending_requests:
            del self.pending_requests[request.request_id]
        
        self.completed_requests[request.request_id] = response
        
        # Roep event handler aan
        if response.success:
            if self.request_completed_handler:
                await self.request_completed_handler(request, response)
        else:
            if self.request_failed_handler:
                await self.request_failed_handler(request, response)
        
        logger.info(f"Processed request {request.request_id}: {response.success}")
    
    async def _monitoring_loop(self):
        """Monitoring loop voor NoodleCore processes"""
        while self._running:
            try:
                # Monitor processen
                await self._monitor_processes()
                
                # Monitor resources
                await self._monitor_resources()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(5.0)
                
            except Exception as e:
                logger.error(f"Error in monitoring loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _monitor_processes(self):
        """Monitor NoodleCore processes"""
        # Verwijder beÃ«indigde processen
        terminated_processes = []
        
        for process_id, process in self.noodlecore_processes.items():
            if process.poll() is not None:  # Proces is beÃ«indigd
                terminated_processes.append(process_id)
        
        for process_id in terminated_processes:
            del self.noodlecore_processes[process_id]
            logger.info(f"NoodleCore process {process_id} terminated")
    
    async def _monitor_resources(self):
        """Monitor systeem resources"""
        # Simuleer resource monitoring
        # In een echte implementatie: gebruik psutil of vergelijkbare
        
        # Check CPU usage
        cpu_usage = 0.0  # Simuleert lage CPU usage
        
        if cpu_usage > self.core_settings['cpu_limit_percent']:
            logger.warning(f"CPU usage ({cpu_usage}%) exceeds limit")
            # Implementeer throttling of andere maatregelen
        
        # Check memory usage
        memory_usage = 0.0  # Simuleert laag geheugengebruik
        
        if memory_usage > self.core_settings['memory_limit_mb']:
            logger.warning(f"Memory usage ({memory_usage}MB) exceeds limit")
            # Implementeer garbage collection of andere maatregelen
    
    def get_request_status(self, request_id: str) -> Optional[Dict[str, Any]]:
        """Krijg status van een request"""
        # Check pending requests
        if request_id in self.pending_requests:
            request = self.pending_requests[request_id]
            return {
                'request_id': request_id,
                'status': 'pending',
                'execution_type': request.execution_type.value,
                'created_at': request.created_at,
                'target_node': request.target_node
            }
        
        # Check completed requests
        if request_id in self.completed_requests:
            response = self.completed_requests[request_id]
            return {
                'request_id': request_id,
                'status': 'completed',
                'success': response.success,
                'execution_time': response.execution_time,
                'created_at': response.created_at,
                'completed_at': response.created_at
            }
        
        return None
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg statistieken voor de interface"""
        return {
            'running': self._running,
            'active_processes': len(self.noodlecore_processes),
            'pending_requests': len(self.pending_requests),
            'completed_requests': len(self.completed_requests),
            'success_rate': self._calculate_success_rate(),
            'average_execution_time': self._calculate_average_execution_time()
        }
    
    def _calculate_success_rate(self) -> float:
        """Bereken success rate"""
        if not self.completed_requests:
            return 0.0
        
        successful = sum(1 for r in self.completed_requests.values() if r.success)
        return successful / len(self.completed_requests)
    
    def _calculate_average_execution_time(self) -> float:
        """Bereken gemiddelde uitvoeringstijd"""
        if not self.completed_requests:
            return 0.0
        
        total_time = sum(r.execution_time for r in self.completed_requests.values())
        return total_time / len(self.completed_requests)
    
    def set_request_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide requests"""
        self.request_completed_handler = handler
    
    def set_request_failed_handler(self, handler: Callable):
        """Stel een handler in voor gefaalde requests"""
        self.request_failed_handler = handler
    
    def set_core_available_handler(self, handler: Callable):
        """Stel een handler in voor beschikbare core"""
        self.core_available_handler = handler
    
    def set_core_unavailable_handler(self, handler: Callable):
        """Stel een handler in voor onbeschikbare core"""
        self.core_unavailable_handler = handler
    
    def set_core_setting(self, setting_name: str, value: Any):
        """
        Stel een core setting in
        
        Args:
            setting_name: Naam van de setting
            value: Nieuwe waarde
        """
        if setting_name in self.core_settings:
            self.core_settings[setting_name] = value
            logger.info(f"Updated core setting {setting_name} to {value}")
        else:
            logger.warning(f"Unknown core setting: {setting_name}")
    
    def clear_completed_requests(self, older_than: float = 3600.0):
        """
        Wis completed requests ouder dan opgegeven tijd
        
        Args:
            older_than: Tijd in seconden
        """
        current_time = time.time()
        old_requests = [
            req_id for req_id, response in self.completed_requests.items()
            if current_time - response.created_at > older_than
        ]
        
        for req_id in old_requests:
            del self.completed_requests[req_id]
        
        if old_requests:
            logger.info(f"Cleared {len(old_requests)} old completed requests")
    
    def is_running(self) -> bool:
        """Controleer of interface actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        return f"NoodleCoreInterface(running={self._running}, pending={len(self.pending_requests)})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleCoreInterface(running={self._running}, "
                f"processes={len(self.noodlecore_processes)}, "
                f"completed={len(self.completed_requests)})")


