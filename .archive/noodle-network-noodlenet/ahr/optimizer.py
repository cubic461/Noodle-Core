"""
Ahr::Optimizer - optimizer.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Optimizer voor Adaptive Hybrid Runtime - Beslis engine voor JIT/AOT optimalisatie
"""

import time
import asyncio
import logging
import math
from typing import Dict, List, Optional, Set, Any, Callable, Tuple
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict

from ..config import NoodleNetConfig
from ..mesh import NoodleMesh, NodeMetrics
from .ahr_base import ExecutionMode, ModelComponent, ModelProfile
from .profiler import PerformanceProfiler, ProfileSession
from .compiler import ModelCompiler, CompilationTask

logger = logging.getLogger(__name__)


class OptimizationDecisionType(Enum):
    """Optimalisatie beslissingen"""
    KEEP_INTERPRETER = "keep_interpreter"
    JIT_COMPILATION = "jit_compilation"
    AOT_COMPILATION = "aot_compilation"
    MIGRATE_TO_NODE = "migrate_to_node"


class OptimizationReason(Enum):
    """Redenen voor optimalisatie"""
    HIGH_LATENCY = "high_latency"
    HIGH_FREQUENCY = "high_frequency"
    LOW_ERROR_RATE = "low_error_rate"
    RESOURCE_CONSTRAINED = "resource_constrained"
    PERFORMANCE_CRITICAL = "performance_critical"
    COST_OPTIMIZATION = "cost_optimization"


@dataclass
class OptimizationDecision:
    """Optimalisatie beslissing"""
    
    component_id: str
    decision: OptimizationDecisionType
    reason: OptimizationReason
    confidence: float  # 0.0-1.0
    expected_improvement: float  # 0.0-1.0
    execution_mode: ExecutionMode
    target_node: Optional[str] = None
    priority: int = 1  # 1-5, 5 = hoogste prioriteit
    created_at: float = field(default_factory=time.time)
    
    def to_dict(self) -> Dict[str, Any]:
        """Converteer naar dictionary"""
        return {
            'component_id': self.component_id,
            'decision': self.decision.value,
            'reason': self.reason.value,
            'confidence': self.confidence,
            'expected_improvement': self.expected_improvement,
            'execution_mode': self.execution_mode.value,
            'target_node': self.target_node,
            'priority': self.priority,
            'created_at': self.created_at
        }


@dataclass
class OptimizationMetric:
    """Optimalisatie metriek"""
    
    name: str
    value: float
    threshold: float
    weight: float = 1.0
    
    def is_above_threshold(self) -> bool:
        """Controleer of waarde boven drempel is"""
        return self.value > self.threshold
    
    def get_score(self) -> float:
        """Bereken score voor deze metriek"""
        if self.is_above_threshold():
            return self.weight
        else:
            # Score gebaseerd op hoe ver boven/beneden drempel
            ratio = self.value / self.threshold
            if ratio > 1:
                return self.weight * min(ratio, 2.0)  # Max 2x weight
            else:
                return self.weight * ratio


class OptimizationRule:
    """Regel voor optimalisatie beslissingen"""
    
    def __init__(self, name: str, priority: int = 1):
        self.name = name
        self.priority = priority
        self.conditions: List[OptimizationMetric] = []
        self.decision = OptimizationDecisionType.KEEP_INTERPRETER
        self.reason = OptimizationReason.PERFORMANCE_CRITICAL
        self.confidence_threshold = 0.7
        self.expected_improvement = 0.3
    
    def add_condition(self, name: str, value: float, threshold: float, weight: float = 1.0):
        """Voeg een voorwaarde toe aan de regel"""
        metric = OptimizationMetric(name, value, threshold, weight)
        self.conditions.append(metric)
    
    def evaluate(self, component: ModelComponent, 
                 session: Optional[ProfileSession] = None) -> Optional[OptimizationDecision]:
        """
        Evalueer de regel voor een component
        
        Args:
            component: Model component om te evalueren
            session: Optionele profielsessie
            
        Returns:
            OptimizationDecision of None als niet van toepassing
        """
        # Bereken totale score
        total_score = 0.0
        conditions_met = 0
        
        for condition in self.conditions:
            score = condition.get_score()
            total_score += score
            conditions_met += 1
        
        # Bereken gemiddelde score
        if conditions_met == 0:
            return None
        
        average_score = total_score / conditions_met
        
        # Controleer confidence drempel
        if average_score < self.confidence_threshold:
            return None
        
        # Maak beslissing
        return OptimizationDecision(
            component_id=component.component_id,
            decision=self.decision,
            reason=self.reason,
            confidence=average_score,
            expected_improvement=self.expected_improvement,
            execution_mode=ExecutionMode.INTERPRETER, # Changed from self.decision.value
            priority=self.priority
        )


class AHRDecisionOptimizer:
    """Beslis engine voor AHR optimalisatie"""
    
    def __init__(self, mesh: NoodleMesh, profiler: PerformanceProfiler,
                 compiler: ModelCompiler, config: Optional[NoodleNetConfig] = None):
        """
        Initialiseer de AHR beslis optimizer
        
        Args:
            mesh: NoodleMesh instantie
            profiler: PerformanceProfiler instantie
            compiler: ModelCompiler instantie
            config: NoodleNet configuratie
        """
        self.mesh = mesh
        self.profiler = profiler
        self.compiler = compiler
        self.config = config or NoodleNetConfig()
        
        # Optimalisatie regels
        self.rules: List[OptimizationRule] = []
        self._initialize_rules()
        
        # Beslissingen
        self.pending_decisions: List[OptimizationDecision] = []
        self.executed_decisions: List[OptimizationDecision] = []
        self.rejected_decisions: List[OptimizationDecision] = []
        
        # Statistieken
        self.decision_stats = {
            'total_decisions': 0,
            'jit_decisions': 0,
            'aot_decisions': 0,
            'keep_interpreter': 0,
            'migrate_decisions': 0,
            'successful_executions': 0,
            'failed_executions': 0
        }
        
        # Event handlers
        self.decision_made_handler: Optional[Callable] = None
        self.decision_executed_handler: Optional[Callable] = None
        self.decision_failed_handler: Optional[Callable] = None
        
        # Configuratie
        self.optimization_settings = {
            'decision_interval': 5.0,  # seconden
            'min_execution_threshold': 10,  # minimaal aantal uitvoeringen
            'min_confidence_threshold': 0.7,
            'max_pending_decisions': 10,
            'enable_migration': True,
            'cost_aware_optimization': True
        }
        
    def _initialize_rules(self):
        """Initialiseer standaard optimalisatie regels"""
        # Regel 1: High Latency JIT
        rule1 = OptimizationRule("high_latency_jit", priority=5)
        rule1.add_condition("latency", 100.0, 50.0, 1.0)  # latency > 50ms
        rule1.add_condition("execution_count", 10, 5, 0.5)  # min 5 uitvoeringen
        rule1.decision = OptimizationDecisionType.JIT_COMPILATION
        rule1.reason = OptimizationReason.HIGH_LATENCY
        rule1.confidence_threshold = 0.8
        rule1.expected_improvement = 0.6
        
        # Regel 2: High Frequency JIT
        rule2 = OptimizationRule("high_frequency_jit", priority=4)
        rule2.add_condition("execution_count", 50, 20, 1.0)  # > 20 uitvoeringen
        rule2.add_condition("frequency", 0.5, 0.3, 0.8)  # hoge frequentie
        rule2.decision = OptimizationDecisionType.JIT_COMPILATION
        rule2.reason = OptimizationReason.HIGH_FREQUENCY
        rule2.confidence_threshold = 0.7
        rule2.expected_improvement = 0.4
        
        # Regel 3: Low Error Rate AOT
        rule3 = OptimizationRule("low_error_rate_aot", priority=3)
        rule3.add_condition("error_rate", 0.01, 0.05, 1.0)  # error_rate < 5%
        rule3.add_condition("execution_count", 100, 50, 0.8)  # > 50 uitvoeringen
        rule3.decision = OptimizationDecisionType.AOT_COMPILATION
        rule3.reason = OptimizationReason.LOW_ERROR_RATE
        rule3.confidence_threshold = 0.8
        rule3.expected_improvement = 0.8
        
        # Regel 4: Resource Constrained JIT
        rule4 = OptimizationRule("resource_constrained_jit", priority=4)
        rule4.add_condition("cpu_usage", 0.8, 0.6, 1.0)  # hoge CPU usage
        rule4.add_condition("memory_usage", 0.9, 0.7, 0.8)  # hoge memory usage
        rule4.decision = OptimizationDecisionType.JIT_COMPILATION
        rule4.reason = OptimizationReason.RESOURCE_CONSTRAINED
        rule4.confidence_threshold = 0.7
        rule4.expected_improvement = 0.5
        
        # Regel 5: Performance Critical AOT
        rule5 = OptimizationRule("performance_critical_aot", priority=5)
        rule5.add_condition("latency", 200.0, 100.0, 1.0)  # zeer hoge latency
        rule5.add_condition("execution_count", 5, 3, 0.6)  # min 3 uitvoeringen
        rule5.decision = OptimizationDecisionType.AOT_COMPILATION
        rule5.reason = OptimizationReason.PERFORMANCE_CRITICAL
        rule5.confidence_threshold = 0.9
        rule5.expected_improvement = 0.9
        
        # Regel 6: Cost Optimization Migration
        rule6 = OptimizationRule("cost_optimization_migration", priority=2)
        rule6.add_condition("execution_count", 100, 80, 1.0)  # > 80 uitvoeringen
        rule6.add_condition("latency", 150.0, 100.0, 0.8)  # hoge latency
        rule6.decision = OptimizationDecisionType.MIGRATE_TO_NODE
        rule6.reason = OptimizationReason.COST_OPTIMIZATION
        rule6.confidence_threshold = 0.6
        rule6.expected_improvement = 0.3
        
        # Voeg regels toe
        self.rules = [rule1, rule2, rule3, rule4, rule5, rule6]
    
    async def evaluate_optimization_opportunities(self, model_id: str) -> List[OptimizationDecision]:
        """
        Evalueer optimalisatie mogelijkheden voor een model
        
        Args:
            model_id: ID van het model
            
        Returns:
            Lijst met optimization decisions
        """
        decisions = []
        
        # Haal model profiel op
        profile = self.profiler.mesh.model_profiles.get(model_id)
        if not profile:
            logger.warning(f"Model {model_id} not found in profiler")
            return decisions
        
        # Evalueer elk component
        for component_id, component in profile.components.items():
            # Controleer minimum drempel
            if component.execution_count < self.optimization_settings['min_execution_threshold']:
                continue
            
            # Evalueer regels
            for rule in self.rules:
                decision = rule.evaluate(component)
                if decision:
                    decisions.append(decision)
        
        # Sorteer op prioriteit
        decisions.sort(key=lambda d: d.priority, reverse=True)
        
        logger.info(f"Generated {len(decisions)} optimization decisions for model {model_id}")
        
        return decisions
    
    async def make_optimization_decision(self, model_id: str, component_id: str) -> Optional[OptimizationDecision]:
        """
        Maak een optimizatie beslissing voor een specifiek component
        
        Args:
            model_id: ID van het model
            component_id: ID van het component
            
        Returns:
            OptimizationDecision of None als geen beslissing genomen
        """
        # Haal model profiel op
        profile = self.profiler.mesh.model_profiles.get(model_id)
        if not profile:
            logger.warning(f"Model {model_id} not found in profiler")
            return None
        
        # Haal component op
        component = profile.get_component(component_id)
        if not component:
            logger.warning(f"Component {component_id} not found in model {model_id}")
            return None
        
        # Controleer minimum drempel
        if component.execution_count < self.optimization_settings['min_execution_threshold']:
            return None
        
        # Evalueer regels
        best_decision = None
        best_score = 0.0
        
        for rule in self.rules:
            decision = rule.evaluate(component)
            if decision and decision.confidence > best_score:
                best_decision = decision
                best_score = decision.confidence
        
        if best_decision:
            # Controleer confidence drempel
            if best_score < self.optimization_settings['min_confidence_threshold']:
                return None
            
            # Update target node voor migration beslissingen
            if best_decision.decision == OptimizationDecisionType.MIGRATE_TO_NODE:
                best_decision.target_node = await self._select_optimal_node(model_id, component_id)
            
            logger.info(f"Made optimization decision for {model_id}.{component_id}: {best_decision.decision.value}")
            
            # Voeg toe aan pending decisions
            self.pending_decisions.append(best_decision)
            
            # Roep event handler aan
            if self.decision_made_handler:
                await self.decision_made_handler(best_decision)
            
            return best_decision
        
        return None
    
    async def execute_optimization_decision(self, decision: OptimizationDecision) -> bool:
        """
        Voer een optimalisatie beslissing uit
        
        Args:
            decision: OptimizationDecision om uit te voeren
            
        Returns:
            True als succesvol uitgevoerd
        """
        try:
            # Markeer als uitgevoerd
            decision.created_at = time.time()
            
            # Voer beslissing uit
            if decision.decision == OptimizationDecisionType.JIT_COMPILATION:
                success = await self._execute_jit_compilation(decision)
            elif decision.decision == OptimizationDecisionType.AOT_COMPILATION:
                success = await self._execute_aot_compilation(decision)
            elif decision.decision == OptimizationDecisionType.MIGRATE_TO_NODE:
                success = await self._execute_node_migration(decision)
            else:
                # Keep interpreter - geen actie nodig
                success = True
            
            # Update statistieken
            self.decision_stats['total_decisions'] += 1
            if decision.decision == OptimizationDecisionType.JIT_COMPILATION:
                self.decision_stats['jit_decisions'] += 1
            elif decision.decision == OptimizationDecisionType.AOT_COMPILATION:
                self.decision_stats['aot_decisions'] += 1
            elif decision.decision == OptimizationDecisionType.MIGRATE_TO_NODE:
                self.decision_stats['migrate_decisions'] += 1
            else:
                self.decision_stats['keep_interpreter'] += 1
            
            if success:
                self.decision_stats['successful_executions'] += 1
                self.executed_decisions.append(decision)
            else:
                self.decision_stats['failed_executions'] += 1
                self.rejected_decisions.append(decision)
            
            # Verwijder uit pending
            if decision in self.pending_decisions:
                self.pending_decisions.remove(decision)
            
            # Roep event handler aan
            if self.decision_executed_handler:
                await self.decision_executed_handler(decision, success)
            
            logger.info(f"Executed optimization decision {decision.decision.value}: {'success' if success else 'failed'}")
            
            return success
            
        except Exception as e:
            logger.error(f"Failed to execute optimization decision {decision.decision.value}: {e}")
            
            # Markeer als gefaald
            self.rejected_decisions.append(decision)
            if decision in self.pending_decisions:
                self.pending_decisions.remove(decision)
            
            # Roep event handler aan
            if self.decision_failed_handler:
                await self.decision_failed_handler(decision, str(e))
            
            return False
    
    async def _execute_jit_compilation(self, decision: OptimizationDecision) -> bool:
        """Voer JIT compilatie uit"""
        # Simuleer JIT compilatie
        await asyncio.sleep(0.5)
        
        # Update component execution mode
        component = self.profiler.mesh.model_profiles[decision.component_id.split('.')[0]].components[decision.component_id]
        component.execution_mode = ExecutionMode.JIT
        
        logger.info(f"Executed JIT compilation for {decision.component_id}")
        return True
    
    async def _execute_aot_compilation(self, decision: OptimizationDecision) -> bool:
        """Voer AOT compilatie uit"""
        # Dien compilatie taak in
        task_id = self.compiler.submit_compilation_task(
            model_id=decision.component_id.split('.')[0],
            component_id=decision.component_id,
            source_code=f"# AOT compilation for {decision.component_id}",
            target_mode=ExecutionMode.AOT
        )
        
        # Wacht op compilatie resultaat
        # In een echte implementatie: wacht op voltooiing
        await asyncio.sleep(1.0)
        
        # Update component execution mode
        component = self.profiler.mesh.model_profiles[decision.component_id.split('.')[0]].components[decision.component_id]
        component.execution_mode = ExecutionMode.AOT
        
        logger.info(f"Executed AOT compilation for {decision.component_id}")
        return True
    
    async def _execute_node_migration(self, decision: OptimizationDecision) -> bool:
        """Voer node migratie uit"""
        if not decision.target_node:
            logger.error(f"No target node specified for migration of {decision.component_id}")
            return False
        
        # Simuleer migratie
        await asyncio.sleep(0.3)
        
        # Update component execution mode
        component = self.profiler.mesh.model_profiles[decision.component_id.split('.')[0]].components[decision.component_id]
        component.execution_mode = ExecutionMode.JIT  # Na migratie: JIT op nieuwe node
        
        logger.info(f"Executed node migration for {decision.component_id} to {decision.target_node}")
        return True
    
    async def _select_optimal_node(self, model_id: str, component_id: str) -> Optional[str]:
        """Selecteer de optimale node voor migratie"""
        if not self.optimization_settings['enable_migration']:
            return None
        
        # Vind beste node op basis van component type
        component_type = component_id.split('_')[0]  # Simpele extractie
        
        capabilities = {component_type}
        best_node = self.mesh.get_best_node("general", capabilities)
        
        return best_node
    
    def get_optimization_decisions(self, status: Optional[str] = None) -> List[OptimizationDecision]:
        """
        Krijg optimalisatie beslissingen
        
        Args:
            status: Filter op status (pending, executed, rejected)
            
        Returns:
            Lijst met optimization decisions
        """
        if status == "pending":
            return self.pending_decisions.copy()
        elif status == "executed":
            return self.executed_decisions.copy()
        elif status == "rejected":
            return self.rejected_decisions.copy()
        else:
            return (self.pending_decisions + self.executed_decisions + 
                   self.rejected_decisions)
    
    def get_decision_statistics(self) -> Dict[str, Any]:
        """Krijg beslissing statistieken"""
        return self.decision_stats.copy()
    
    def get_optimization_summary(self) -> Dict[str, Any]:
        """Krijg optimalisatie samenvatting"""
        total_decisions = self.decision_stats['total_decisions']
        
        return {
            'total_decisions': total_decisions,
            'pending_decisions': len(self.pending_decisions),
            'executed_decisions': len(self.executed_decisions),
            'rejected_decisions': len(self.rejected_decisions),
            'success_rate': (self.decision_stats['successful_executions'] / 
                           total_decisions if total_decisions > 0 else 0.0),
            'decision_breakdown': {
                'jit': self.decision_stats['jit_decisions'],
                'aot': self.decision_stats['aot_decisions'],
                'keep_interpreter': self.decision_stats['keep_interpreter'],
                'migrate': self.decision_stats['migrate_decisions']
            }
        }
    
    def add_optimization_rule(self, rule: OptimizationRule):
        """Voeg een custom optimalisatie regel toe"""
        self.rules.append(rule)
        logger.info(f"Added optimization rule: {rule.name}")
    
    def remove_optimization_rule(self, rule_name: str) -> bool:
        """Verwijder een optimalisatie regel"""
        for i, rule in enumerate(self.rules):
            if rule.name == rule_name:
                self.rules.pop(i)
                logger.info(f"Removed optimization rule: {rule_name}")
                return True
        return False
    
    def set_optimization_setting(self, setting_name: str, value: Any):
        """
        Stel een optimalisatie setting in
        
        Args:
            setting_name: Naam van de setting
            value: Nieuwe waarde
        """
        if setting_name in self.optimization_settings:
            self.optimization_settings[setting_name] = value
            logger.info(f"Updated optimization setting {setting_name} to {value}")
        else:
            logger.warning(f"Unknown optimization setting: {setting_name}")
    
    def set_decision_made_handler(self, handler: Callable):
        """Stel een handler in voor genomen beslissingen"""
        self.decision_made_handler = handler
    
    def set_decision_executed_handler(self, handler: Callable):
        """Stel een handler in voor uitgevoerde beslissingen"""
        self.decision_executed_handler = handler
    
    def set_decision_failed_handler(self, handler: Callable):
        """Stel een handler in voor gefaalde beslissingen"""
        self.decision_failed_handler = handler
    
    def clear_decisions(self, status: Optional[str] = None):
        """Wis beslissingen"""
        if status == "pending":
            self.pending_decisions.clear()
        elif status == "executed":
            self.executed_decisions.clear()
        elif status == "rejected":
            self.rejected_decisions.clear()
        else:
            self.pending_decisions.clear()
            self.executed_decisions.clear()
            self.rejected_decisions.clear()
        
        logger.info(f"Cleared optimization decisions")
    
    def is_optimization_active(self) -> bool:
        """Controleer of optimalisatie actief is"""
        return len(self.pending_decisions) > 0 or len(self.rules) > 0
    
    def start(self):
        """Start de optimizer"""
        logger.info("AHR Decision Optimizer started")
    
    def stop(self):
        """Stop de optimizer"""
        logger.info("AHR Decision Optimizer stopped")
    
    def is_running(self) -> bool:
        """Controleer of optimizer actief is"""
        return True  # Altijd actief als er regels zijn
    
    def __str__(self) -> str:
        """String representatie"""
        summary = self.get_optimization_summary()
        return f"AHRDecisionOptimizer(rules={len(self.rules)}, pending={len(self.pending_decisions)})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"AHRDecisionOptimizer(rules={len(self.rules)}, "
                f"decisions={self.decision_stats['total_decisions']})")


