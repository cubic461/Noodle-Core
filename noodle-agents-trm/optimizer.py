import asyncio
import logging
import time
import numpy as np
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass
from enum import Enum
# -*- coding: utf-8 -*-
"""
TRM Optimizer Component
Copyright © 2025 Michael van Erp. All rights reserved.
"""

logger = logging.getLogger(__name__)


class OptimizationType(Enum):
    """Soorten optimalisatie"""
    CONSTANT_FOLDING = "constant_folding"
    DEAD_CODE_ELIMINATION = "dead_code_elimination"
    LOOP_OPTIMIZATION = "loop_optimization"
    INLINE_FUNCTIONS = "inline_functions"
    VECTORIZATION = "vectorization"
    MEMORY_OPTIMIZATION = "memory_optimization"
    CONTROL_FLOW_OPTIMIZATION = "control_flow_optimization"


class OptimizationLevel(Enum):
    """Optimalisatie niveaus"""
    BASIC = 1  # Simpele optimalisaties
    STANDARD = 2  # Standaard optimalisaties
    AGGRESSIVE = 3  # Aggressieve optimalisaties


@dataclass
class OptimizationRule:
    """Optimalisatie regel"""
    
    name: str
    optimization_type: OptimizationType
    condition: callable
    transformation: callable
    priority: int = 1
    enabled: bool = True
    description: str = ""


@dataclass
class OptimizationResult:
    """Resultaat van optimalisatie"""
    
    original_ir: Dict[str, Any]
    optimized_ir: Dict[str, Any]
    optimizations_applied: List[str]
    performance_improvement: float = 0.0
    memory_improvement: float = 0.0
    code_reduction: float = 0.0
    optimization_time: float = 0.0
    success: bool = True
    error_message: Optional[str] = None


class TRMOptimizer:
    """
    TRM Optimizer voor het optimaliseren van NoodleCore-IR
    
    Dit component gebruikt Tiny Recursive Model technieken om
    Intermediate Representation te optimaliseren op basis van
    patronen en heuristieken.
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialiseer de TRM Optimizer
        
        Args:
            config: Optimizer configuratie opties
        """
        self.config = config or {}
        
        # Optimizer instellingen
        self.optimization_level = self.config.get('optimization_level', OptimizationLevel.STANDARD)
        self.enable_trm_reasoning = self.config.get('enable_trm_reasoning', True)
        self.max_optimization_time = self.config.get('max_optimization_time', 30.0)
        self.enable_parallel_optimization = self.config.get('enable_parallel_optimization', True)
        self.enable_memory_profiling = self.config.get('enable_memory_profiling', True)
        
        # Model state (voor TRM)
        self.model_state = {
            'weights': None,
            'biases': None,
            'latent_state': None,
            'optimization_patterns': {},
            'performance_metrics': {},
            'learning_rate': self.config.get('learning_rate', 0.001)
        }
        
        # Optimalisatie regels
        self.optimization_rules: List[OptimizationRule] = self._initialize_rules()
        
        # Cache voor snelle toegang
        self.optimization_cache: Dict[str, OptimizationResult] = {}
        
        # Statistics
        self.stats = {
            'total_optimizations': 0,
            'successful_optimizations': 0,
            'failed_optimizations': 0,
            'cache_hits': 0,
            'average_optimization_time': 0.0,
            'total_improvement': 0.0,
            'rules_applied': {},
            'optimization_types': {}
        }
        
        logger.info(f"TRM Optimizer geïnitialiseerd met config: {self.config}")
    
    async def initialize(self):
        """Initialiseer de optimizer"""
        # Initialiseer model state
        await self._initialize_model_state()
        
        # Start background tasks
        self._cleanup_task = asyncio.create_task(self._cleanup_cache())
        self._learning_task = asyncio.create_task(self._continuous_learning())
        
        logger.info("TRM Optimizer geïnitialiseerd")
    
    async def cleanup(self):
        """Clean up de optimizer"""
        if hasattr(self, '_cleanup_task'):
            self._cleanup_task.cancel()
        
        if hasattr(self, '_learning_task'):
            self._learning_task.cancel()
        
        self.optimization_cache.clear()
        logger.info("TRM Optimizer opgeschoond")
    
    async def optimize(self,
                      ir_data: Dict[str, Any],
                      module_name: str,
                      optimization_level: int = 2,
                      model_state: Optional[Dict[str, Any]] = None) -> OptimizationResult:
        """
        Optimaliseer NoodleCore-IR
        
        Args:
            ir_data: NoodleCore-IR data
            module_name: Naam van de module
            optimization_level: Optimalisatie niveau (1-3)
            model_state: Optionele model state voor TRM
            
        Returns:
            OptimizationResult met geoptimaliseerde IR
        """
        start_time = time.time()
        
        try:
            # Update model state
            if model_state:
                self.model_state.update(model_state)
            
            # Bepaal optimalisatie niveau
            opt_level = OptimizationLevel(optimization_level)
            
            # Controleer cache eerst
            cache_key = self._generate_cache_key(ir_data, module_name, opt_level)
            if cache_key in self.optimization_cache:
                self.stats['cache_hits'] += 1
                logger.debug(f"Cache hit voor {module_name}")
                return self.optimization_cache[cache_key]
            
            # Maak kopie van originele IR
            original_ir = self._deep_copy_ir(ir_data)
            
            # Pas optimalisaties toe
            optimized_ir, optimizations_applied = await self._apply_optimizations(
                original_ir, 
                opt_level
            )
            
            # Bereken verbeteringen
            improvements = self._calculate_improvements(original_ir, optimized_ir)
            
            # Compileer resultaat
            optimization_result = OptimizationResult(
                original_ir=original_ir,
                optimized_ir=optimized_ir,
                optimizations_applied=optimizations_applied,
                performance_improvement=improvements['performance'],
                memory_improvement=improvements['memory'],
                code_reduction=improvements['code_reduction'],
                optimization_time=time.time() - start_time,
                success=True
            )
            
            # Update statistics
            self.stats['total_optimizations'] += 1
            self.stats['successful_optimizations'] += 1
            
            opt_time = optimization_result.optimization_time
            self.stats['average_optimization_time'] = (
                (self.stats['average_optimization_time'] * (self.stats['total_optimizations'] - 1) + opt_time) 
                / self.stats['total_optimizations']
            )
            
            self.stats['total_improvement'] += improvements['performance']
            
            # Update regels statistieken
            for rule_name in optimizations_applied:
                if rule_name not in self.stats['rules_applied']:
                    self.stats['rules_applied'][rule_name] = 0
                self.stats['rules_applied'][rule_name] += 1
            
            # Update optimalisatie type statistieken
            for rule_name in optimizations_applied:
                rule = self._find_rule_by_name(rule_name)
                if rule:
                    opt_type = rule.optimization_type.value
                    if opt_type not in self.stats['optimization_types']:
                        self.stats['optimization_types'][opt_type] = 0
                    self.stats['optimization_types'][opt_type] += 1
            
            # Cache resultaat
            self.optimization_cache[cache_key] = optimization_result
            
            logger.debug(f"Succesvol geoptimaliseerd: {module_name} ({opt_time:.3f}s)")
            logger.info(f"Toepas optimalisaties: {', '.join(optimizations_applied)}")
            
            return optimization_result
            
        except Exception as e:
            self.stats['total_optimizations'] += 1
            self.stats['failed_optimizations'] += 1
            
            opt_time = time.time() - start_time
            logger.error(f"Optimalisatie fout in {module_name}: {e} ({opt_time:.3f}s)")
            
            # Compileer error resultaat
            error_result = OptimizationResult(
                original_ir=ir_data,
                optimized_ir=ir_data,
                optimizations_applied=[],
                optimization_time=opt_time,
                success=False,
                error_message=str(e)
            )
            
            return error_result
    
    async def _apply_optimizations(self,
                                  ir_data: Dict[str, Any],
                                  optimization_level: OptimizationLevel) -> Tuple[Dict[str, Any], List[str]]:
        """
        Pas optimalisaties toe op IR
        
        Args:
            ir_data: IR data
            optimization_level: Optimalisatie niveau
            
        Returns:
            Tuple van geoptimaliseerde IR en toegepaste optimalisaties
        """
        optimized_ir = self._deep_copy_ir(ir_data)
        optimizations_applied = []
        
        # Filter regels op basis van niveau
        applicable_rules = [
            rule for rule in self.optimization_rules
            if rule.enabled and rule.priority <= optimization_level.value
        ]
        
        # Sorteer regels op prioriteit
        applicable_rules.sort(key=lambda r: r.priority)
        
        # Pas regels toe
        for rule in applicable_rules:
            try:
                if await self._should_apply_rule(optimized_ir, rule):
                    optimized_ir = await rule.transformation(optimized_ir)
                    optimizations_applied.append(rule.name)
                    
                    logger.debug(f"Optimalisatie toegepast: {rule.name}")
                    
            except Exception as e:
                logger.warning(f"Optimalisatie {rule.name} mislukt: {e}")
                continue
        
        # Pas TRM reden toe indien ingeschakeld
        if self.enable_trm_reasoning:
            optimized_ir, trm_optimizations = await self._apply_trm_reasoning(
                optimized_ir, 
                optimization_level
            )
            optimizations_applied.extend(trm_optimizations)
        
        return optimized_ir, optimizations_applied
    
    async def _should_apply_rule(self, ir_data: Dict[str, Any], rule: OptimizationRule) -> bool:
        """
        Bepaal of een regel moet worden toegepast
        
        Args:
            ir_data: IR data
            rule: Optimalisatie regel
            
        Returns:
            True als regel moet worden toegepast
        """
        try:
            # Controleer TRM model state indien beschikbaar
            if self.model_state.get('optimization_patterns'):
                pattern_score = self._evaluate_optimization_pattern(ir_data, rule)
                if pattern_score < 0.3:  # Laag patroon match
                    return False
            
            # Voer condition check uit
            return await rule.condition(ir_data)
            
        except Exception as e:
            logger.warning(f"Condition check voor {rule.name} mislukt: {e}")
            return False
    
    def _evaluate_optimization_pattern(self, ir_data: Dict[str, Any], rule: OptimizationRule) -> float:
        """
        Evalueer optimalisatie patroon met TRM
        
        Args:
            ir_data: IR data
            rule: Optimalisatie regel
            
        Returns:
            Patroon match score (0.0-1.0)
        """
        # Simpele patroon evaluatie
        pattern_key = f"{rule.optimization_type.value}_{rule.name}"
        
        if pattern_key in self.model_state['optimization_patterns']:
            saved_pattern = self.model_state['optimization_patterns'][pattern_key]
            current_pattern = self._extract_pattern(ir_data, rule)
            
            # Bereken match score
            match_score = self._calculate_pattern_similarity(saved_pattern, current_pattern)
            return match_score
        
        return 0.5  # Neutrale score
    
    def _extract_pattern(self, ir_data: Dict[str, Any], rule: OptimizationRule) -> Dict[str, Any]:
        """Extraheer patroon uit IR data"""
        # Simpele patroon extractie
        pattern = {
            'node_count': len(ir_data.get('functions', [])) + len(ir_data.get('classes', [])),
            'complexity_score': sum(func.get('complexity_score', 0) for func in ir_data.get('functions', [])),
            'has_loops': any('loop' in str(func) for func in ir_data.get('functions', [])),
            'has_conditionals': any('if' in str(func) for func in ir_data.get('functions', []))
        }
        
        return pattern
    
    def _calculate_pattern_similarity(self, pattern1: Dict[str, Any], pattern2: Dict[str, Any]) -> float:
        """Bereken patroon similariteit"""
        similarity = 0.0
        total_weight = 0.0
        
        for key in pattern1:
            if key in pattern2:
                weight = 1.0  # Gelijke gewichten voor nu
                similarity += weight * (1.0 - abs(pattern1[key] - pattern2[key]) / max(pattern1[key], 1))
                total_weight += weight
        
        return similarity / max(total_weight, 1.0)
    
    async def _apply_trm_reasoning(self,
                                 ir_data: Dict[str, Any],
                                 optimization_level: OptimizationLevel) -> Tuple[Dict[str, Any], List[str]]:
        """
        Pas TRM reden toe op IR
        
        Args:
            ir_data: IR data
            optimization_level: Optimalisatie niveau
            
        Returns:
            Tuple van geoptimaliseerde IR en toegepaste TRM optimalisaties
        """
        optimized_ir = self._deep_copy_ir(ir_data)
        trm_optimizations = []
        
        # Simuleer TRM reden (hier zou een echt TRM model worden gebruikt)
        latent_state = self.model_state.get('latent_state')
        if latent_state is not None:
            # Gebruik latent state om patronen te identificeren
            patterns = self._identify_trm_patterns(optimized_ir, latent_state)
            
            # Pas patroon-gebaseerde optimalisaties toe
            for pattern_name, pattern_data in patterns.items():
                if pattern_data['confidence'] > 0.7:
                    optimization = await self._apply_trm_optimization(
                        optimized_ir, 
                        pattern_name, 
                        pattern_data
                    )
                    if optimization:
                        optimized_ir = optimization
                        trm_optimizations.append(f"trm_{pattern_name}")
        
        return optimized_ir, trm_optimizations
    
    def _identify_trm_patterns(self, ir_data: Dict[str, Any], latent_state: Dict[str, Any]) -> Dict[str, Any]:
        """Identificeer TRM patronen in IR data"""
        patterns = {}
        
        # Simpele patroon identificatie
        functions = ir_data.get('functions', [])
        
        # Herhalende patronen
        if len(functions) > 3:
            patterns['redundant_functions'] = {
                'confidence': 0.8,
                'description': 'Meerdere functies met vergelijkbare logica'
            }
        
        # Complexe patronen
        avg_complexity = sum(f.get('complexity_score', 0) for f in functions) / max(len(functions), 1)
        if avg_complexity > 5.0:
            patterns['high_complexity'] = {
                'confidence': 0.9,
                'description': 'Hoge gemiddelde complexiteit'
            }
        
        return patterns
    
    async def _apply_trm_optimization(self,
                                   ir_data: Dict[str, Any],
                                   pattern_name: str,
                                   pattern_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Pas TRM-gebaseerde optimalisatie toe
        
        Args:
            ir_data: IR data
            pattern_name: Naam van het patroon
            pattern_data: Patroon data
            
        Returns:
            Geoptimaliseerde IR of None
        """
        try:
            # Simuleer TRM-gebaseerde optimalisatie
            if pattern_name == 'redundant_functions':
                # Functie deduplicatie
                optimized_ir = self._deduplicate_functions(ir_data)
                return optimized_ir
            
            elif pattern_name == 'high_complexity':
                # Complexiteitsreductie
                optimized_ir = self._reduce_complexity(ir_data)
                return optimized_ir
            
        except Exception as e:
            logger.warning(f"TRM optimalisatie {pattern_name} mislukt: {e}")
        
        return None
    
    def _deduplicate_functions(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Deduplicatie van functies"""
        functions = ir_data.get('functions', [])
        
        # Simpele deduplicatie op basis van naam
        unique_functions = []
        seen_names = set()
        
        for func in functions:
            func_name = func.get('name', '')
            if func_name not in seen_names:
                unique_functions.append(func)
                seen_names.add(func_name)
        
        # Update IR
        optimized_ir = ir_data.copy()
        optimized_ir['functions'] = unique_functions
        
        return optimized_ir
    
    def _reduce_complexity(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Complexiteitsreductie"""
        functions = ir_data.get('functions', [])
        
        # Simpele complexiteitsreductie
        optimized_functions = []
        for func in functions:
            complexity = func.get('complexity_score', 0)
            
            if complexity > 10.0:
                # Splits complexe functies (simulatie)
                optimized_func = func.copy()
                optimized_func['complexity_score'] = complexity / 2
                optimized_functions.append(optimized_func)
            else:
                optimized_functions.append(func)
        
        # Update IR
        optimized_ir = ir_data.copy()
        optimized_ir['functions'] = optimized_functions
        
        return optimized_ir
    
    def _initialize_rules(self) -> List[OptimizationRule]:
        """Initialiseer optimalisatie regels"""
        rules = []
        
        # Constant folding
        rules.append(OptimizationRule(
            name="constant_folding",
            optimization_type=OptimizationType.CONSTANT_FOLDING,
            condition=self._condition_constant_folding,
            transformation=self._transformation_constant_folding,
            priority=1,
            enabled=True,
            description="Vereenvoudiging van constante expressies"
        ))
        
        # Dead code elimination
        rules.append(OptimizationRule(
            name="dead_code_elimination",
            optimization_type=OptimizationType.DEAD_CODE_ELIMINATION,
            condition=self._condition_dead_code,
            transformation=self._transformation_dead_code,
            priority=2,
            enabled=True,
            description="Verwijderen van onbereikbare code"
        ))
        
        # Loop optimization
        rules.append(OptimizationRule(
            name="loop_optimization",
            optimization_type=OptimizationType.LOOP_OPTIMIZATION,
            condition=self._condition_loops,
            transformation=self._transformation_loops,
            priority=3,
            enabled=True,
            description="Optimalisatie van lussen"
        ))
        
        # Function inlining
        rules.append(OptimizationRule(
            name="function_inlining",
            optimization_type=OptimizationType.INLINE_FUNCTIONS,
            condition=self._condition_inline_functions,
            transformation=self._transformation_inline_functions,
            priority=2,
            enabled=False,  # Uitgeschakeld voor veiligheid
            description="Inlinen van kleine functies"
        ))
        
        return rules
    
    async def _condition_constant_folding(self, ir_data: Dict[str, Any]) -> bool:
        """Check voor constant folding mogelijkheden"""
        functions = ir_data.get('functions', [])
        return len(functions) > 0  # Simpele check
    
    async def _transformation_constant_folding(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Pas constant folding toe"""
        # Simuleer constant folding
        optimized_ir = ir_data.copy()
        functions = optimized_ir.get('functions', [])
        
        for func in functions:
            # Simpele constant folding simulatie
            if func.get('body'):
                # Replace constant expressions
                func['body'] = self._replace_constants(func['body'])
        
        return optimized_ir
    
    async def _condition_dead_code(self, ir_data: Dict[str, Any]) -> bool:
        """Check voor dead code mogelijkheden"""
        functions = ir_data.get('functions', [])
        return len(functions) > 1  # Meerdere functies mogelijk
    
    async def _transformation_dead_code(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Pas dead code elimination toe"""
        # Simuleer dead code elimination
        optimized_ir = ir_data.copy()
        
        # Verwijder ongebruikte functies (simulatie)
        functions = optimized_ir.get('functions', [])
        if len(functions) > 1:
            # Keep first function, remove others (simulatie)
            optimized_ir['functions'] = [functions[0]]
        
        return optimized_ir
    
    async def _condition_loops(self, ir_data: Dict[str, Any]) -> bool:
        """Check voor loop optimalisatie mogelijkheden"""
        functions = ir_data.get('functions', [])
        return any('loop' in str(func) for func in functions)
    
    async def _transformation_loops(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Pas loop optimalisatie toe"""
        # Simuleer loop optimalisatie
        optimized_ir = ir_data.copy()
        functions = optimized_ir.get('functions', [])
        
        for func in functions:
            # Simuleer loop unrolling
            if func.get('body'):
                func['body'] = self._optimize_loops(func['body'])
        
        return optimized_ir
    
    async def _condition_inline_functions(self, ir_data: Dict[str, Any]) -> bool:
        """Check voor function inlining mogelijkheden"""
        functions = ir_data.get('functions', [])
        return len(functions) > 1  # Meerdere functies
    
    async def _transformation_inline_functions(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Pas function inlining toe"""
        # Simuleer function inlining
        optimized_ir = ir_data.copy()
        functions = optimized_ir.get('functions', [])
        
        if len(functions) > 1:
            # Inline kleine functies (simulatie)
            main_func = functions[0].copy()
            main_func['body'] = main_func['body'] + functions[1]['body']
            optimized_ir['functions'] = [main_func]
        
        return optimized_ir
    
    def _replace_constants(self, body: List[Any]) -> List[Any]:
        """Vervang constante expressies"""
        # Simpele constante vervanging
        result = []
        for item in body:
            if isinstance(item, dict) and item.get('type') == 'constant':
                # Replace with optimized constant
                item['optimized'] = True
            result.append(item)
        return result
    
    def _optimize_loops(self, body: List[Any]) -> List[Any]:
        """Optimaliseer lussen"""
        # Simpele loop optimalisatie
        result = []
        for item in body:
            if isinstance(item, dict) and item.get('type') == 'loop':
                # Optimize loop (simulatie)
                item['optimized'] = True
            result.append(item)
        return result
    
    def _calculate_improvements(self, original_ir: Dict[str, Any], optimized_ir: Dict[str, Any]) -> Dict[str, float]:
        """Bereken verbeteringen"""
        original_size = len(str(original_ir))
        optimized_size = len(str(optimized_ir))
        
        improvements = {
            'performance': 0.1,  # 10% performance verbetering (simulatie)
            'memory': 0.05,     # 5% geheugen besparing (simulatie)
            'code_reduction': (original_size - optimized_size) / original_size if original_size > 0 else 0
        }
        
        return improvements
    
    def _deep_copy_ir(self, ir_data: Dict[str, Any]) -> Dict[str, Any]:
        """Maak een diepe kopie van IR data"""
        import copy
        return copy.deepcopy(ir_data)
    
    def _find_rule_by_name(self, name: str) -> Optional[OptimizationRule]:
        """Vind een regel op naam"""
        for rule in self.optimization_rules:
            if rule.name == name:
                return rule
        return None
    
    async def _initialize_model_state(self):
        """Initialiseer model state"""
        # Simuleer model state initialisatie
        self.model_state['weights'] = np.random.random((100, 50)) * 0.1
        self.model_state['biases'] = np.random.random((50,)) * 0.1
        self.model_state['latent_state'] = np.random.random((32,)) * 0.1
    
    async def _continuous_learning(self):
        """Continue leerproces"""
        while True:
            try:
                await asyncio.sleep(300)  # 5 minuten
                
                # Update model state op basis van recente optimalisaties
                await self._update_model_patterns()
                
                logger.debug("Model state bijgewerkt door continue leerproces")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Continue leerproces fout: {e}")
    
    async def _update_model_patterns(self):
        """Update model patronen op basis van recente optimalisaties"""
        # Update optimalisatie patronen
        recent_patterns = {}
        
        # Simuleer patroon update
        for rule_name, count in self.stats['rules_applied'].items():
            if count > 5:  # Regel wordt vaak toegepast
                recent_patterns[rule_name] = {
                    'frequency': count,
                    'effectiveness': 0.8  # Simuleerde effectiviteit
                }
        
        self.model_state['optimization_patterns'].update(recent_patterns)
    
    async def _cleanup_cache(self):
        """Periodieke cleanup van de cache"""
        while True:
            try:
                await asyncio.sleep(600)  # 10 minuten
                
                # Verwijder oude cache entries
                current_time = time.time()
                old_keys = [
                    key for key, result in self.optimization_cache.items()
                    if current_time - result.optimization_time > 7200  # 2 uur
                ]
                
                for key in old_keys:
                    del self.optimization_cache[key]
                
                if old_keys:
                    logger.info(f"Optimization cache opgeschoond: {len(old_keys)} entries verwijderd")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Optimization cache cleanup fout: {e}")
    
    def _generate_cache_key(self, ir_data: Dict[str, Any], module_name: str, level: OptimizationLevel) -> str:
        """Genereer een cache key voor gegeven input"""
        import hashlib
        content = f"{module_name}:{level.value}:{str(ir_data)}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg optimizer statistieken"""
        stats = self.stats.copy()
        stats.update({
            'cache_size': len(self.optimization_cache),
            'optimization_level': self.optimization_level.value,
            'enable_trm_reasoning': self.enable_trm_reasoning,
            'total_rules': len(self.optimization_rules),
            'enabled_rules': sum(1 for rule in self.optimization_rules if rule.enabled)
        })
        return stats
    
    def clear_cache(self):
        """Wis de optimization cache"""
        self.optimization_cache.clear()
        logger.info("Optimization cache gewist")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"TRMOptimizer(cache={len(self.optimization_cache)}, successful={self.stats['successful_optimizations']})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return f"TRMOptimizer(cache_size={len(self.optimization_cache)}, stats={self.stats})"

