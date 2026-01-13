"""
Ahr::Compiler - compiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
JIT/AOT compiler voor Adaptive Hybrid Runtime - Model optimalisatie naar NBC
"""

import time
import asyncio
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
from .ahr_base import ExecutionMode, ModelComponent, ModelProfile

logger = logging.getLogger(__name__)


class CompilationStage(Enum):
    """Compilatie stadia"""
    ANALYSIS = "analysis"
    OPTIMIZATION = "optimization"
    GENERATION = "generation"
    VERIFICATION = "verification"
    DEPLOYMENT = "deployment"


class CompilerTarget(Enum):
    """Compilatie targets"""
    NBC_NATIVE = "nbc_native"  # NoodleCore Binary Code
    NBC_JIT = "nbc_jit"  # Just-In-Time compilatie
    NBC_AOT = "nbc_aot"  # Ahead-Of-Time compilatie
    INTERPRETED = "interpreted"  # Blijf in interpret mode


@dataclass
class CompilationTask:
    """Compilatie taak voor een model component"""
    
    task_id: str
    model_id: str
    component_id: str
    source_code: str  # Bron code (Python, etc.)
    target_mode: ExecutionMode
    compilation_stage: CompilationStage = CompilationStage.ANALYSIS
    created_at: float = field(default_factory=time.time)
    started_at: Optional[float] = None
    completed_at: Optional[float] = None
    status: str = "pending"  # pending, running, completed, failed
    error_message: Optional[str] = None
    compiled_code: Optional[str] = None
    optimizations_applied: List[str] = field(default_factory=list)
    performance_improvement: Optional[float] = None
    
    def mark_started(self):
        """Markeer de taak als gestart"""
        self.status = "running"
        self.started_at = time.time()
    
    def mark_completed(self, compiled_code: str, optimizations: List[str], 
                      improvement: float):
        """Markeer de taak als voltooid"""
        self.status = "completed"
        self.completed_at = time.time()
        self.compiled_code = compiled_code
        self.optimizations_applied = optimizations
        self.performance_improvement = improvement
    
    def mark_failed(self, error_message: str):
        """Markeer de taak als gefaald"""
        self.status = "failed"
        self.completed_at = time.time()
        self.error_message = error_message
    
    def get_duration(self) -> float:
        """Krijg de duur van de taak"""
        if self.started_at and self.completed_at:
            return self.completed_at - self.started_at
        elif self.started_at:
            return time.time() - self.started_at
        return 0.0


class ModelCompiler:
    """Model compiler voor AHR optimalisatie"""
    
    def __init__(self, mesh: NoodleMesh, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de model compiler
        
        Args:
            mesh: NoodleMesh instantie
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.config = config or NoodleNetConfig()
        
        # Compilatie taken
        self.pending_tasks: List[CompilationTask] = []
        self.running_tasks: Dict[str, CompilationTask] = {}
        self.completed_tasks: Dict[str, CompilationTask] = {}
        self.failed_tasks: Dict[str, CompilationTask] = {}
        
        # Compilatie cache
        self.compilation_cache: Dict[str, str] = {}  # hash -> compiled_code
        self.cache_dir = Path.home() / ".noodlenet" / "cache"
        self.cache_dir.mkdir(parents=True, exist_ok=True)
        
        # Compiler settings
        self.compiler_settings = {
            'optimization_level': 2,  # 0-3
            'debug_mode': False,
            'parallel_compilation': True,
            'max_parallel_tasks': 4
        }
        
        # Event handlers
        self.compilation_started_handler: Optional[Callable] = None
        self.compilation_completed_handler: Optional[Callable] = None
        self.compilation_failed_handler: Optional[Callable] = None
        
        # Taken management
        self._compilation_task = None
        self._running = False
        
    def submit_compilation_task(self, model_id: str, component_id: str,
                              source_code: str, target_mode: ExecutionMode) -> str:
        """
        Dien een compilatie taak in
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            source_code: Bron code om te compileren
            target_mode: Doel uitvoeringsmodus
            
        Returns:
            Taak ID
        """
        # Genereer unieke taak ID
        task_id = self._generate_task_id(model_id, component_id)
        
        # Maak compilatie taak
        task = CompilationTask(
            task_id=task_id,
            model_id=model_id,
            component_id=component_id,
            source_code=source_code,
            target_mode=target_mode
        )
        
        # Voeg toe aan pending taken
        self.pending_tasks.append(task)
        
        logger.info(f"Submitted compilation task {task_id} for {model_id}.{component_id}")
        
        return task_id
    
    def get_compilation_task(self, task_id: str) -> Optional[CompilationTask]:
        """Krijg een compilatie taak op ID"""
        # Zoek in alle taken lijsten
        for task_list in [self.pending_tasks, self.running_tasks, 
                         self.completed_tasks, self.failed_tasks]:
            if task_id in task_list:
                return task_list[task_id]
        return None
    
    def cancel_compilation_task(self, task_id: str) -> bool:
        """
        Annuleer een compilatie taak
        
        Args:
            task_id: ID van de taak
            
        Returns:
            True als succesvol geannuleerd
        """
        # Zoek in pending taken
        for i, task in enumerate(self.pending_tasks):
            if task.task_id == task_id:
                self.pending_tasks.pop(i)
                logger.info(f"Cancelled pending compilation task {task_id}")
                return True
        
        # Zoek in running taken
        if task_id in self.running_tasks:
            task = self.running_tasks[task_id]
            task.mark_failed("Cancelled by user")
            self.failed_tasks[task_id] = task
            del self.running_tasks[task_id]
            logger.info(f"Cancelled running compilation task {task_id}")
            return True
        
        return False
    
    def get_compilation_status(self, task_id: str) -> Optional[Dict[str, Any]]:
        """
        Krijg compilatie status voor een taak
        
        Args:
            task_id: ID van de taak
            
        Returns:
            Status dictionary of None als niet gevonden
        """
        task = self.get_compilation_task(task_id)
        if not task:
            return None
        
        return {
            'task_id': task_id,
            'model_id': task.model_id,
            'component_id': task.component_id,
            'status': task.status,
            'compilation_stage': task.compilation_stage.value,
            'created_at': task.created_at,
            'started_at': task.started_at,
            'completed_at': task.completed_at,
            'duration': task.get_duration(),
            'error_message': task.error_message,
            'optimizations_applied': task.optimizations_applied,
            'performance_improvement': task.performance_improvement
        }
    
    def get_compilation_statistics(self) -> Dict[str, Any]:
        """Krijg compilatie statistieken"""
        total_tasks = len(self.pending_tasks) + len(self.running_tasks) + \
                     len(self.completed_tasks) + len(self.failed_tasks)
        
        return {
            'total_tasks': total_tasks,
            'pending_tasks': len(self.pending_tasks),
            'running_tasks': len(self.running_tasks),
            'completed_tasks': len(self.completed_tasks),
            'failed_tasks': len(self.failed_tasks),
            'cache_size': len(self.compilation_cache),
            'success_rate': len(self.completed_tasks) / total_tasks if total_tasks > 0 else 0.0,
            'average_compilation_time': self._get_average_compilation_time()
        }
    
    def set_compiler_setting(self, setting_name: str, value: Any):
        """
        Stel een compiler setting in
        
        Args:
            setting_name: Naam van de setting
            value: Nieuwe waarde
        """
        if setting_name in self.compiler_settings:
            self.compiler_settings[setting_name] = value
            logger.info(f"Updated compiler setting {setting_name} to {value}")
        else:
            logger.warning(f"Unknown compiler setting: {setting_name}")
    
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
    
    def start(self):
        """Start de compiler"""
        if self._running:
            logger.warning("Compiler is already running")
            return
        
        self._running = True
        self._compilation_task = asyncio.create_task(self._compilation_loop())
        
        logger.info("Model compiler started")
    
    async def stop(self):
        """Stop de compiler"""
        if not self._running:
            return
        
        self._running = False
        
        if self._compilation_task:
            self._compilation_task.cancel()
            try:
                await self._compilation_task
            except asyncio.CancelledError:
                pass
        
        logger.info("Model compiler stopped")
    
    async def _compilation_loop(self):
        """Hoofd compilatie loop"""
        while self._running:
            try:
                # Verwerk pending taken
                await self._process_pending_tasks()
                
                # Wacht voor volgende iteratie
                await asyncio.sleep(1.0)
                
            except Exception as e:
                logger.error(f"Error in compilation loop: {e}")
                await asyncio.sleep(5.0)
    
    async def _process_pending_tasks(self):
        """Verwerk pending compilatie taken"""
        if not self.pending_tasks:
            return
        
        # Beperk aantal parallelle taken
        max_parallel = self.compiler_settings['max_parallel_tasks']
        available_slots = max_parallel - len(self.running_tasks)
        
        if available_slots <= 0:
            return
        
        # Selecteer taken om te starten
        tasks_to_start = self.pending_tasks[:available_slots]
        
        for task in tasks_to_start:
            # Verwijder uit pending
            self.pending_tasks.remove(task)
            
            # Start compilatie
            asyncio.create_task(self._compile_task(task))
    
    async def _compile_task(self, task: CompilationTask):
        """Compileer een enkele taak"""
        # Markeer als gestart
        task.mark_started()
        self.running_tasks[task.task_id] = task
        
        # Roep event handler aan
        if self.compilation_started_handler:
            await self.compilation_started_handler(task)
        
        try:
            # Check cache eerst
            code_hash = self._generate_code_hash(task.source_code)
            cached_result = self._get_from_cache(code_hash)
            
            if cached_result:
                logger.info(f"Using cached compilation result for task {task.task_id}")
                task.mark_completed(
                    cached_result['code'],
                    cached_result['optimizations'],
                    cached_result['improvement']
                )
            else:
                # Voer volledige compilatie uit
                await self._perform_compilation(task)
                
                # Sla resultaat op in cache
                self._save_to_cache(
                    code_hash,
                    task.compiled_code,
                    task.optimizations_applied,
                    task.performance_improvement
                )
            
            # Verplaats naar completed taken
            del self.running_tasks[task.task_id]
            self.completed_tasks[task.task_id] = task
            
            # Roep event handler aan
            if self.compilation_completed_handler:
                await self.compilation_completed_handler(task)
            
            logger.info(f"Completed compilation task {task.task_id}")
            
        except Exception as e:
            # Markeer als gefaald
            task.mark_failed(str(e))
            
            # Verplaats naar failed taken
            del self.running_tasks[task.task_id]
            self.failed_tasks[task.task_id] = task
            
            # Roep event handler aan
            if self.compilation_failed_handler:
                await self.compilation_failed_handler(task)
            
            logger.error(f"Failed compilation task {task.task_id}: {e}")
    
    async def _perform_compilation(self, task: CompilationTask):
        """
        Voer de daadwerkelijke compilatie uit
        
        Args:
            task: CompilationTask om te compileren
        """
        # Simuleer compilatie process
        # In een echte implementatie: roep NBC compiler aan
        
        # Analyse fase
        task.compilation_stage = CompilationStage.ANALYSIS
        analysis_result = await self._analyze_code(task.source_code)
        
        # Optimalisatie fase
        task.compilation_stage = CompilationStage.OPTIMIZATION
        optimizations = await self._optimize_code(task.source_code, analysis_result)
        
        # Generatie fase
        task.compilation_stage = CompilationStage.GENERATION
        compiled_code = await self._generate_nbc_code(task.source_code, optimizations)
        
        # Verificatie fase
        task.compilation_stage = CompilationStage.VERIFICATION
        verification_result = await self._verify_compilation(compiled_code)
        
        if not verification_result['valid']:
            raise Exception(f"Compilation verification failed: {verification_result['error']}")
        
        # Bereken performance verbetering
        improvement = await self._estimate_performance_improvement(
            task.source_code, compiled_code, optimizations
        )
        
        # Markeer als voltooid
        task.mark_completed(compiled_code, optimizations, improvement)
    
    async def _analyze_code(self, source_code: str) -> Dict[str, Any]:
        """
        Analyseer bron code voor optimalisatie mogelijkheden
        
        Args:
            source_code: Bron code om te analyseren
            
        Returns:
            Analyse resultaten
        """
        # Simuleer code analyse
        await asyncio.sleep(0.1)
        
        # Identificeer code patterns
        patterns = []
        
        # Detecteer loops
        if "for " in source_code or "while " in source_code:
            patterns.append("loop_detection")
        
        # Detecteer matrix operaties
        if "numpy" in source_code or "torch" in source_code:
            patterns.append("matrix_operations")
        
        # Detecteer herhaalde berekeningen
        if source_code.count(".") > 10:  # Veel method calls
            patterns.append("repeated_calculations")
        
        return {
            'patterns': patterns,
            'complexity': 'medium',
            'optimization_potential': len(patterns) * 0.2
        }
    
    async def _optimize_code(self, source_code: str, analysis: Dict[str, Any]) -> List[str]:
        """
        Optimaliseer bron code
        
        Args:
            source_code: Bron code
            analysis: Analyse resultaten
            
        Returns:
            Lijst met toegepaste optimalisaties
        """
        # Simuleer optimalisatie
        await asyncio.sleep(0.2)
        
        optimizations = []
        
        # Pas optimalisaties toe op basis van analyse
        if 'loop_detection' in analysis['patterns']:
            optimizations.append("loop_unrolling")
            optimizations.append("vectorization")
        
        if 'matrix_operations' in analysis['patterns']:
            optimizations.append("matrix_optimization")
            optimizations.append("memory_layout_optimization")
        
        if 'repeated_calculations' in analysis['patterns']:
            optimizations.append("memoization")
            optimizations.append("constant_propagation")
        
        # Voeg algemene optimalisaties toe
        optimizations.append("dead_code_elimination")
        optimizations.append("inline_functions")
        
        return optimizations
    
    async def _generate_nbc_code(self, source_code: str, optimizations: List[str]) -> str:
        """
        Genereer NBC code
        
        Args:
            source_code: Bron code
            optimizations: Toegepaste optimalisaties
            
        Returns:
            Gecompileerde NBC code
        """
        # Simuleer NBC code generatie
        await asyncio.sleep(0.3)
        
        # Genereer simpele NBC code
        nbc_code = f"# NBC Generated Code\n"
        nbc_code += f"# Optimizations: {', '.join(optimizations)}\n\n"
        nbc_code += f"function main() {{\n"
        nbc_code += f"    // Input: {len(source_code)} bytes\n"
        nbc_code += f"    // Optimizations applied: {len(optimizations)}\n"
        
        # Simuleer matrix operaties
        nbc_code += f"    matrix_data = load_matrix()\n"
        nbc_code += f"    result = matrix_multiply(matrix_data, matrix_data)\n"
        nbc_code += f"    return result\n"
        nbc_code += f"}}\n"
        
        return nbc_code
    
    async def _verify_compilation(self, compiled_code: str) -> Dict[str, Any]:
        """
        Verifieer gecompileerde code
        
        Args:
            compiled_code: Gecompileerde NBC code
            
        Returns:
            Verificatie resultaten
        """
        # Simuleer verificatie
        await asyncio.sleep(0.1)
        
        # Simpele syntaxis check
        if not compiled_code.strip():
            return {'valid': False, 'error': 'Empty compiled code'}
        
        if "function main()" not in compiled_code:
            return {'valid': False, 'error': 'Missing main function'}
        
        return {'valid': True}
    
    async def _estimate_performance_improvement(self, source_code: str,
                                              compiled_code: str,
                                              optimizations: List[str]) -> float:
        """
        Schat performance verbetering
        
        Args:
            source_code: Originele bron code
            compiled_code: Gecompileerde code
            optimizations: Toegepaste optimalisaties
            
        Returns:
            Geschatte performance verbetering (0.0-1.0)
        """
        # Simuleer performance schatting
        await asyncio.sleep(0.05)
        
        # Basis verbetering op basis van aantal optimalisaties
        base_improvement = len(optimizations) * 0.1
        
        # Extra verbetering voor complexe code
        complexity_factor = min(len(source_code) / 1000.0, 1.0) * 0.2
        
        improvement = min(base_improvement + complexity_factor, 1.0)
        
        return round(improvement, 2)
    
    def _generate_task_id(self, model_id: str, component_id: str) -> str:
        """Genereer een unieke taak ID"""
        timestamp = int(time.time())
        unique_id = f"{model_id}_{component_id}_{timestamp}"
        return hashlib.md5(unique_id.encode()).hexdigest()[:16]
    
    def _generate_code_hash(self, source_code: str) -> str:
        """Genereer een hash voor bron code"""
        return hashlib.sha256(source_code.encode()).hexdigest()
    
    def _get_from_cache(self, code_hash: str) -> Optional[Dict[str, Any]]:
        """Haal resultaat uit cache"""
        # Eerst check geheugen cache
        if code_hash in self.compilation_cache:
            return json.loads(self.compilation_cache[code_hash])
        
        # Check cache bestanden
        cache_file = self.cache_dir / f"{code_hash}.cache"
        if cache_file.exists():
            try:
                with open(cache_file, 'r') as f:
                    result = json.load(f)
                self.compilation_cache[code_hash] = json.dumps(result)
                return result
            except (json.JSONDecodeError, OSError) as e:
                logger.warning(f"Failed to load cache file {cache_file}: {e}")
        
        return None
    
    def _save_to_cache(self, code_hash: str, compiled_code: str,
                      optimizations: List[str], improvement: float):
        """
        Sla resultaat op in cache
        
        Args:
            code_hash: Code hash
            compiled_code: Gecompileerde code
            optimizations: Toegepaste optimalisaties
            improvement: Performance verbetering
        """
        result = {
            'code': compiled_code,
            'optimizations': optimizations,
            'improvement': improvement,
            'timestamp': time.time()
        }
        
        # Sla op in geheugen cache
        self.compilation_cache[code_hash] = json.dumps(result)
        
        # Sla op in bestand
        cache_file = self.cache_dir / f"{code_hash}.cache"
        try:
            with open(cache_file, 'w') as f:
                json.dump(result, f)
        except OSError as e:
            logger.warning(f"Failed to save cache file {cache_file}: {e}")
    
    def _get_average_compilation_time(self) -> float:
        """Bereken gemiddelde compilatie tijd"""
        completed_tasks = [t for t in self.completed_tasks.values() 
                          if t.started_at and t.completed_at]
        
        if not completed_tasks:
            return 0.0
        
        total_time = sum(t.get_duration() for t in completed_tasks)
        return total_time / len(completed_tasks)
    
    def set_compilation_started_handler(self, handler: Callable):
        """Stel een handler in voor gestarte compilaties"""
        self.compilation_started_handler = handler
    
    def set_compilation_completed_handler(self, handler: Callable):
        """Stel een handler in voor voltooide compilaties"""
        self.compilation_completed_handler = handler
    
    def set_compilation_failed_handler(self, handler: Callable):
        """Stel een handler in voor gefaalde compilaties"""
        self.compilation_failed_handler = handler
    
    def is_running(self) -> bool:
        """Controleer of compiler actief is"""
        return self._running
    
    def is_monitoring(self) -> bool:
        """Controleer of compiler monitoring actief is"""
        return self._running
    
    def __str__(self) -> str:
        """String representatie"""
        stats = self.get_compilation_statistics()
        return f"ModelCompiler(running={self._running}, {stats['completed_tasks']}/{stats['total_tasks']} completed)"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"ModelCompiler(running={self._running}, "
                f"pending={len(self.pending_tasks)}, "
                f"running={len(self.running_tasks)})")


