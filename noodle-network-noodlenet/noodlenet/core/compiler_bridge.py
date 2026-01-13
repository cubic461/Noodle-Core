"""
Core::Compiler Bridge - compiler_bridge.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Compiler Bridge - Vertaalt model componenten naar NBC (NoodleCore Binary Code)
"""

import asyncio
import time
import json
import logging
import hashlib
import os
from typing import Dict, List, Optional, Set, Any, Callable
from dataclasses import dataclass, field
from enum import Enum
from pathlib import Path

from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from .interface import NoodleCoreInterface, ExecutionType, NoodleCoreRequest, NoodleCoreResponse
from ..ahr.ahr_base import ExecutionMode, ModelComponent
from ..link import Message

logger = logging.getLogger(__name__)


class CompilerTarget(Enum):
    """Doel van de compiler"""
    NBC_NATIVE = "nbc_native"  # NoodleCore Binary Code
    MATRIX_KERNEL = "matrix_kernel"  # Geoptimaliseerde matrix operaties
    NEURAL_LAYER = "neural_layer"  # Neurale netwerk lagen
    DATABASE_QUERY = "database_query"  # Database query optimalisatie
    GENERAL_PURPOSE = "general_purpose"  # Algemene code


@dataclass
class CompilationRequest:
    """Verzoek om model component te compileren"""
    
    request_id: str
    component: ModelComponent
    target: CompilerTarget
    source_code: str  # Bron code (Python, ONNX, etc.)
    dependencies: List[str] = field(default_factory=list)
    optimization_level: int = 2  # 0-3
    target_node: Optional[str] = None
    created_at: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'request_id': self.request_id,
            'component_id': self.component.component_id,
            'target': self.target.value,
            'source_code': self.source_code,
            'dependencies': self.dependencies,
            'optimization_level': self.optimization_level,
            'target_node': self.target_node,
            'created_at': self.created_at
        }


@dataclass
class CompilationResult:
    """Resultaat van compilatie"""
    
    request_id: str
    success: bool
    compiled_code: Optional[str] = None
    optimized_code: Optional[str] = None
    nbc_code: Optional[str] = None
    performance_metrics: Optional[Dict[str, float]] = None
    error_message: Optional[str] = None
    compilation_time: float = 0.0
    optimization_gains: float = 0.0
    created_at: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'request_id': self.request_id,
            'success': self.success,
            'compiled_code': self.compiled_code,
            'optimized_code': self.optimized_code,
            'nbc_code': self.nbc_code,
            'performance_metrics': self.performance_metrics,
            'error_message': self.error_message,
            'compilation_time': self.compilation_time,
            'optimization_gains': self.optimization_gains,
            'created_at': self.created_at
        }


class NoodleCoreCompilerBridge:
    """
    Brug tussen NoodleNet en NoodleCore compilers
    Vertaalt high-level model componenten naar NBC code
    """
    
    def __init__(self, interface: NoodleCoreInterface, mesh: NoodleMesh,
                 config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de compiler bridge
        
        Args:
            interface: NoodleCoreInterface instantie
            mesh: NoodleMesh instantie
            config: NoodleNet configuratie
        """
        self.interface = interface
        self.mesh = mesh
        self.config = config or NoodleNetConfig()
        
        # Compilatie taken
        self.pending_requests: Dict[str, CompilationRequest] = {}
        self.compiled_results: Dict[str, CompilationResult] = {}
        
        # Compilatie cache
        self.compilation_cache: Dict[str, CompilationResult] = {}
        self.cache_dir = Path.home() / ".noodlenet" / "compiler_cache"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Configuratie
        self.compiler_settings = {
            'max_concurrent_compilations': 5,
            'cache_enabled': True,
            'cache_ttl_seconds': 86400,  # 24 uur
            'optimization_levels': {
                "NBC_NATIVE": [1, 2, 3],
                "MATRIX_KERNEL": [2, 3],
                "NEURAL_LAYER": [1, 2],
                "DATABASE_QUERY": [1, 2],
                "GENERAL_PURPOSE": [1, 2, 3]
            },
            'default_optimization': 2
        }
        
        # Event handlers
        self.compilation_started_handler: Optional[Callable] = None
        self.compilation_completed_handler: Optional[Callable] = None
        self.compilation_failed_handler: Optional[Callable] = None
        
        # Threading
        self._running = False
        self._compilation_processor_task = None
        self._cache_maintenance_task = None
        
    async def start(self):
        """Start de compiler bridge"""
        if self._running:
            logger.warning("NoodleCore compiler bridge is already running")
            return
        
        self._running = True
        
        # Start compilatie processor
        self._compilation_processor_task = asyncio.create_task(
            self._compilation_processor_loop()
        )
        
        # Start cache maintenance
        self._cache_maintenance_task = asyncio.create_task(
            self._cache_maintenance_loop()
        )
        
        logger.info("NoodleCore compiler bridge started")
    
    async def stop(self):
        """Stop de compiler bridge"""
        if not self._running:
            return
        
        self._running = False
        
        # Stop taken
        if self._compilation_processor_task:
            self._compilation_processor_task.cancel()
            try:
                await self._compilation_processor_task
            except asyncio.CancelledError:
                pass
        
        if self._cache_maintenance_task:
            self._cache_maintenance_task.cancel()
            try:
                await self._cache_maintenance_task
            except asyncio.CancelledError:
                pass
        
        logger.info("NoodleCore compiler bridge stopped")
    
    async def compile_model_component(self, component: ModelComponent,
                                   source_code: str,
                                   target: CompilerTarget,
                                   dependencies: Optional[List[str]] = None) -> str:
        """
        Compileer een model component naar NBC
        
        Args:
            component: Model component om te compileren
            source_code: Bron code
            target: Compiler target
            dependencies: Lijst met dependencies
            
        Returns:
            Request ID
        """
        request_id = self._generate_request_id()
        
        request = CompilationRequest(
            request_id=request_id,
            component=component,
            target=target,
            source_code=source_code,
            dependencies=dependencies or []
        )
        
        self.pending_requests[request_id] = request
        
        logger.info(f"Submitted compilation request {request_id} for {component.component_id}")
        
        return request_id
    
    async def compile_matrix_operation(self, matrix_ops: List[Dict[str, Any]],
                                     target_node: Optional[str] = None) -> str:
        """
        Compileer matrix operaties naar NBC
        
        Args:
            matrix_ops: Lijst met matrix operaties
            target_node: Target node
            
        Returns:
            Request ID
        """
        request_id = self._generate_request_id()
        
        # Maak component
        component = ModelComponent(
            component_id=f"matrix_ops_{request_id}",
            execution_mode=ExecutionMode.JIT,
            dependencies=[]
        )
        
        request = CompilationRequest(
            request_id=request_id,
            component=component,
            target=CompilerTarget.MATRIX_KERNEL,
            source_code=json.dumps(matrix_ops),
            target_node=target_node
        )
        
        self.pending_requests[request_id] = request
        
        logger.info(f"Submitted matrix operation compilation request {request_id}")
        
        return request_id
    
    async def compile_neural_layer(self, layer_config: Dict[str, Any],
                                 weights: Optional[Any] = None,
                                 target_node: Optional[str] = None) -> str:
        """
        Compileer een neurale laag naar NBC
        
        Args:
            layer_config: Configuratie van de laag
            weights: Gewicht data
            target_node: Target node
            
        Returns:
            Request ID
        """
        request_id = self._generate_request_id()
        
        # Maak component
        component = ModelComponent(
            component_id=f"neural_layer_{request_id}",
            execution_mode=ExecutionMode.AOT,
            dependencies=[]
        )
        
        request = CompilationRequest(
            request_id=request_id,
            component=component,
            target=CompilerTarget.NEURAL_LAYER,
            source_code=json.dumps({
                'config': layer_config,
                'weights': weights
            }),
            target_node=target_node
        )
        
        self.pending_requests[request_id] = request
        
        logger.info(f"Submitted neural layer compilation request {request_id}")
        
        return request_id
    
    async def compile_database_query(self, query: str,
                                   schema: Optional[Dict[str, Any]] = None,
                                   optimization_hints: Optional[Dict[str, Any]] = None) -> str:
        """
        Compileer een database query naar NBC
        
        Args:
            query: SQL query
            schema: Database schema
            optimization_hints: Optimalisatie hints
            
        Returns:
            Request ID
        """
        request_id = self._generate_request_id()
        
        # Maak component
        component = ModelComponent(
            component_id=f"db_query_{request_id}",
            execution_mode=ExecutionMode.JIT,
            dependencies=[]
        )
        
        request = CompilationRequest(
            request_id=request_id,
            component=component,
            target=CompilerTarget.DATABASE_QUERY,
            source_code=json.dumps({
                'query': query,
                'schema': schema,
                'optimization_hints': optimization_hints
            })
        )
        
        self.pending_requests[request_id] = request
        
        logger.info(f"Submitted database query compilation request {request_id}")
        
        return request_id
    
    async def compile_general_purpose(self, source_code: str,
                                     language: str = "python",
                                     dependencies: Optional[List[str]] = None) -> str:
        """
        Compileer algemene purpose code naar NBC
        
        Args:
            source_code: Bron code
            language: Programmeertaal
            dependencies: Lijst met dependencies
            
        Returns:
            Request ID
        """
        request_id = self._generate_request_id()
        
        # Maak component
        component = ModelComponent(
            component_id=f"general_{request_id}",
            execution_mode=ExecutionMode.JIT,
            dependencies=dependencies or []
        )
        
        request = CompilationRequest(
            request_id=request_id,
            component=component,
            target=CompilerTarget.GENERAL_PURPOSE,
            source_code=json.dumps({
                'code': source_code,
                'language': language
            })
        )
        
        self.pending_requests[request_id] = request
        
        logger.info(f"Submitted general purpose compilation request {request_id}")
        
        return request_id
    
    def get_compilation_status(self, request_id: str) -> Optional[Dict[str, Any]]:
        """Krijg compilatie status"""
        # Check pending requests
        if request_id in self.pending_requests:
            request = self.pending_requests[request_id]
            return {
                'request_id': request_id,
                'status': 'pending',
                'component_id': request.component.component_id,
                'target': request.target.value,
                'created_at': request.created_at
            }
        
        # Check compiled results
        if request_id in self.compiled_results:
            result = self.compiled_results[request_id]
            return {
                'request_id': request_id,
                'status': 'completed' if result.success else 'failed',
                'success': result.success,
                'compilation_time': result.compilation_time,
                'optimization_gains': result.optimization_gains,
                'created_at': result.created_at
            }
        
        # Check cache
        if self.compiler_settings['cache_enabled']:
            cached_result = self._get_from_cache(request_id)
            if cached_result:
                return {
                    'request_id': request_id,
                    'status': 'cached',
                    'success': cached_result.success,
                    'compilation_time': cached_result.compilation_time,
                    'optimization_gains': cached_result.optimization_gains,
                    'cached_at': cached_result.created_at
                }
        
        return None
    
    def get_compilation_result(self, request_id: str) -> Optional[CompilationResult]:
        """Krijg compilatie resultaat"""
        # Check compiled results
        if request_id in self.compiled_results:
            return self.compiled_results[request_id]
        
        # Check cache
        if self.compiler_settings['cache_enabled']:
            return self._get_from_cache(request_id)
        
        return None
    
    def get_compilation_statistics(self) -> Dict[str, Any]:
        """Krijg compilatie statistieken"""
        total_requests = len(self.pending_requests) + len(self.compiled_results)
        
        return {
            'total_requests': total_requests,
            'pending_requests': len(self.pending_requests),
            'compiled_results': len(self.compiled_results),
            'cache_size': len(self.compilation_cache),
            'success_rate': len([r for r in self.compiled_results.values() 
                                if r.success]) / max(len(self.compiled_results), 1),
            'average_compilation_time': self._calculate_average_compilation_time(),
            'total_optimization_gains': sum(r.optimization_gains 
                                          for r in self.compiled_results.values() if r.success)
        }
    
    def _generate_request_id(self) -> str:
        """Genereer een unieke request ID"""
        timestamp = int(time.time() * 1000)  # milliseconden
        unique_id = f"comp_{timestamp}_{len(self.pending_requests)}"
        return unique_id
    
    async def _compilation_processor_loop(self):
        """Hoofd compilatie processor loop"""
        while self._running:
            try:
                # Verwerk pending requests
                await self._process_pending_requests()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(0.1)
                
            except Exception as e:
                logger.error(f"Error in compilation processor loop: {e}")
                await asyncio.sleep(1.0)
    
    async def _process_pending_requests(self):
        """Verwerk pending compilatie requests"""
        if not self.pending_requests:
            return
        
        # Beperk aantal tegelijk lopende compilaties
        max_concurrent = self.compiler_settings['max_concurrent_compilations']
        running_count = len([r for r in self.pending_requests.values() 
                           if r.created_at > time.time() - 1.0])
        
        if running_count >= max_concurrent:
            return
        
        # Selecteer requests om te starten
        pending_list = list(self.pending_requests.values())
        available_slots = max_concurrent - running_count
        
        for i in range(min(available_slots, len(pending_list))):
            request = pending_list[i]
            
            # Start compilatie
            asyncio.create_task(self._process_single_compilation(request))
    
    async def _process_single_compilation(self, request: CompilationRequest):
        """Verwerk een enkele compilatie"""
        try:
            # Roep event handler aan
            if self.compilation_started_handler:
                await self.compilation_started_handler(request)
            
            # Check cache eerst
            if self.compiler_settings['cache_enabled']:
                cache_key = self._generate_cache_key(request)
                cached_result = self._get_from_cache(cache_key)
                
                if cached_result:
                    logger.info(f"Using cached compilation result for request {request.request_id}")
                    self.compiled_results[request.request_id] = cached_result
                    del self.pending_requests[request.request_id]
                    
                    # Roep event handler aan
                    if self.compilation_completed_handler:
                        await self.compilation_completed_handler(request, cached_result)
                    
                    return
            
            # Voer compilatie uit
            result = await self._compile_request(request)
            
            # Sla resultaat op
            self.compiled_results[request.request_id] = result
            
            # Sla op in cache
            if self.compiler_settings['cache_enabled'] and result.success:
                self._save_to_cache(self._generate_cache_key(request), result)
            
            # Verwijder uit pending
            del self.pending_requests[request.request_id]
            
            # Roep event handler aan
            if self.compilation_completed_handler:
                await self.compilation_completed_handler(request, result)
            
            logger.info(f"Completed compilation request {request.request_id}: {result.success}")
            
        except Exception as e:
            logger.error(f"Failed to process compilation request {request.request_id}: {e}")
            
            # Maak error result
            result = CompilationResult(
                request_id=request.request_id,
                success=False,
                error_message=str(e),
                compilation_time=time.time() - request.created_at
            )
            
            self.compiled_results[request.request_id] = result
            del self.pending_requests[request.request_id]
            
            # Roep event handler aan
            if self.compilation_failed_handler:
                await self.compilation_failed_handler(request, str(e))
    
    async def _compile_request(self, request: CompilationRequest) -> CompilationResult:
        """
        Voer een compilatie request uit
        
        Args:
            request: CompilationRequest om uit te voeren
            
        Returns:
            CompilationResult
        """
        start_time = time.time()
        
        try:
            # Selecteer target node
            target_node = request.target_node or await self._select_optimal_node(request)
            
            # Prepare compilatie data
            compilation_data = {
                'component': request.component.to_dict(),
                'source_code': request.source_code,
                'target': request.target.value,
                'dependencies': request.dependencies,
                'optimization_level': request.optimization_level
            }
            
            # Stuur compilatie request naar NoodleCore
            if target_node:
                # Remote compilatie
                response = await self._execute_remote_compilation(
                    compilation_data, target_node
                )
            else:
                # Lokale compilatie
                response = await self._execute_local_compilation(compilation_data)
            
            # Parse resultaat
            if response.success:
                result = CompilationResult(
                    request_id=request.request_id,
                    success=True,
                    compiled_code=response.result.get('compiled_code'),
                    optimized_code=response.result.get('optimized_code'),
                    nbc_code=response.result.get('nbc_code'),
                    performance_metrics=response.result.get('performance_metrics'),
                    optimization_gains=response.result.get('optimization_gains', 0.0),
                    compilation_time=time.time() - start_time
                )
            else:
                result = CompilationResult(
                    request_id=request.request_id,
                    success=False,
                    error_message=response.error_message,
                    compilation_time=time.time() - start_time
                )
            
            return result
            
        except Exception as e:
            logger.error(f"Compilation failed for request {request.request_id}: {e}")
            
            return CompilationResult(
                request_id=request.request_id,
                success=False,
                error_message=str(e),
                compilation_time=time.time() - start_time
            )
    
    async def _execute_local_compilation(self, compilation_data: Dict[str, Any]) -> NoodleCoreResponse:
        """Voer lokale compilatie uit"""
        # Gebruik NoodleCore interface voor compilatie
        request = NoodleCoreRequest(
            request_id=self._generate_request_id(),
            execution_type=ExecutionType.NATIVE_CODE,
            payload={
                'code': f"compile_to_nbc({json.dumps(compilation_data)})",
                'language': "python",
                'functions': ["compile_to_nbc"]
            }
        )
        
        # Simuleer compilatie
        await asyncio.sleep(0.5)
        
        return NoodleCoreResponse(
            request_id=request.request_id,
            success=True,
            result={
                'compiled_code': "# Compiled NBC code",
                'optimized_code': "# Optimized NBC code",
                'nbc_code': "NBC_BINARY_DATA",
                'performance_metrics': {
                    'execution_time_improvement': 0.3,
                    'memory_reduction': 0.2,
                    'throughput_improvement': 0.25
                },
                'optimization_gains': 0.3
            }
        )
    
    async def _execute_remote_compilation(self, compilation_data: Dict[str, Any],
                                        target_node: str) -> NoodleCoreResponse:
        """Voer remote compilatie uit"""
        # Maak message
        link_msg = Message(
            sender_id=self.mesh.identity_manager.get_local_identity().node_id,
            recipient_id=target_node,
            message_type="noodlecore_compilation",
            payload=compilation_data
        )
        
        # Stuur request
        success = await self.mesh.link.send(target_node, link_msg)
        
        if success:
            # Wacht op response
            await asyncio.sleep(0.5)
            
            # Maak simpele response
            return NoodleCoreResponse(
                request_id=self._generate_request_id(),
                success=True,
                result={
                    'compiled_code': "# Remote compiled NBC code",
                    'optimized_code': "# Remote optimized NBC code",
                    'nbc_code': "REMOTE_NBC_BINARY_DATA",
                    'performance_metrics': {
                        'execution_time_improvement': 0.4,
                        'memory_reduction': 0.25,
                        'throughput_improvement': 0.35
                    },
                    'optimization_gains': 0.4
                }
            )
        else:
            raise Exception("Failed to send compilation request to remote node")
    
    async def _select_optimal_node(self, request: CompilationRequest) -> Optional[str]:
        """Selecteer de optimale node voor compilatie"""
        # Bepaal vereiste capabilities op basis van target
        capabilities = {"compiler": True}
        
        if request.target == CompilerTarget.MATRIX_KERNEL:
            capabilities.update({"matrix_ops": True, "gpu": True})
        elif request.target == CompilerTarget.NEURAL_LAYER:
            capabilities.update({"ai": True, "gpu": True})
        elif request.target == CompilerTarget.DATABASE_QUERY:
            capabilities.update({"database": True})
        elif request.target == CompilerTarget.GENERAL_PURPOSE:
            capabilities.update({"general": True})
        
        # Vind beste node
        best_node = self.mesh.get_best_node("general", capabilities)
        
        return best_node
    
    async def _cache_maintenance_loop(self):
        """Cache maintenance loop"""
        while self._running:
            try:
                # Verouderde cache items verwijderen
                await self._clean_expired_cache()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(300.0)  # 5 minuten
                
            except Exception as e:
                logger.error(f"Error in cache maintenance loop: {e}")
                await asyncio.sleep(60.0)
    
    async def _clean_expired_cache(self):
        """Verwijder verouderde cache items"""
        if not self.compiler_settings['cache_enabled']:
            return
        
        current_time = time.time()
        ttl = self.compiler_settings['cache_ttl_seconds']
        
        # Verwijder verouderde items uit geheugen cache
        expired_keys = []
        for key, result in self.compilation_cache.items():
            if current_time - result.created_at > ttl:
                expired_keys.append(key)
        
        for key in expired_keys:
            del self.compilation_cache[key]
        
        # Verwijder verouderde bestanden
        cache_dir = self.cache_dir
        for cache_file in cache_dir.glob("*.cache"):
            try:
                file_age = current_time - cache_file.stat().st_mtime
                if file_age > ttl:
                    cache_file.unlink()
            except OSError as e:
                logger.warning(f"Failed to delete cache file {cache_file}: {e}")
        
        if expired_keys:
            logger.info(f"Cleaned {len(expired_keys)} expired cache items")
    
    def _generate_cache_key(self, request: CompilationRequest) -> str:
        """Genereer een cache key"""
        data = {
            'source_code': request.source_code,
            'target': request.target.value,
            'dependencies': sorted(request.dependencies),
            'optimization_level': request.optimization_level
        }
        
        data_str = json.dumps(data, sort_keys=True)
        return hashlib.sha256(data_str.encode()).hexdigest()
    
    def _get_from_cache(self, key: str) -> Optional[CompilationResult]:
        """Haal resultaat uit cache"""
        # Eerst check geheugen cache
        if key in self.compilation_cache:
            return self.compilation_cache[key]
        
        # Check cache bestanden
        cache_file = self.cache_dir / f"{key}.cache"
        if cache_file.exists():
            try:
                with open(cache_file, 'r') as f:
                    result_data = json.load(f)
                    result = CompilationResult(**result_data)
                self.compilation_cache[key] = result
                return result
            except (json.JSONDecodeError, OSError) as e:
                logger.warning(f"Failed to load cache file {cache_file}: {e}")
        
        return None
    
    def _save_to_cache(self, key: str, result: CompilationResult):
        """Sla resultaat op in cache"""
        # Sla op in geheugen cache
        self.compilation_cache[key] = result
        
        # Sla op in bestand
        cache_file = self.cache_dir / f"{key}.cache"
        try:
            with open(cache_file, 'w') as f:
                json.dump(result.to_dict(), f)
        except OSError as e:
            logger.warning(f"Failed to save cache file {cache_file}: {e}")
    
    def _calculate_average_compilation_time(self) -> float:
        """Bereken gemiddelde compilatie tijd"""
        if not self.compiled_results:
            return 0.0
        
        total_time = sum(r.compilation_time for r in self.compiled_results.values())
        return total_time / len(self.compiled_results)
    
    def set_compilation_started_handler(self, handler: Callable):
        """Stel een handler in voor gestarte compilaties"""
        self.compilation_started_handler = handler
    
    def set_compilation_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide compilaties"""
        self.compilation_completed_handler = handler
    
    def set_compilation_failed_handler(self, handler: Callable):
        """Stel een handler in voor gefaalde compilaties"""
        self.compilation_failed_handler = handler
    
    def clear_cache(self):
        """Wis de compilatie cache"""
        self.compilation_cache.clear()
        
        # Wis cache bestanden
        for cache_file in self.cache_dir.glob("*.cache"):
            try:
                cache_file.unlink()
            except OSError as e:
                logger.warning(f"Failed to delete cache file {cache_file}: {e}")
        
        logger.info("Cleared compilation cache")
    
    def is_running(self) -> bool:
        """Controleer of compiler bridge actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        stats = self.get_compilation_statistics()
        return f"NoodleCoreCompilerBridge(running={self._running}, compiled={stats['compiled_results']})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"NoodleCoreCompilerBridge(running={self._running}, "
                f"pending={len(self.pending_requests)}, "
                f"cache={len(self.compilation_cache)})")


