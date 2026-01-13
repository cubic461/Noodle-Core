"""
Ai Agents::Feedback - feedback.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
TRM Feedback Component

Dit component is verantwoordelijk voor het verwerken van runtime feedback
en het bijwerken van het TRM model state voor continue verbetering.
"""

import asyncio
import logging
import time
import numpy as np
from typing import Dict, List, Optional, Any, Union, Tuple
from dataclasses import dataclass, field
from enum import Enum

logger = logging.getLogger(__name__)


class FeedbackType(Enum):
    """Soorten feedback"""
    PERFORMANCE = "performance"
    MEMORY = "memory"
    ERROR_RATE = "error_rate"
    OPTIMIZATION_EFFECTIVENESS = "optimization_effectiveness"
    CODE_QUALITY = "code_quality"


class LearningStrategy(Enum):
    """LeerstrategieÃ«n"""
    ONLINE = "online"
    BATCH = "batch"
    HYBRID = "hybrid"


@dataclass
class ExecutionMetrics:
    """Uitvoeringsmetrieken"""
    
    execution_time: float
    memory_usage: float
    cpu_usage: float
    error_rate: float = 0.0
    success: bool = True
    timestamp: float = field(default_factory=time.time)
    optimization_gains: float = 0.0
    code_size_reduction: float = 0.0
    energy_efficiency: float = 0.0


@dataclass
class FeedbackResult:
    """Resultaat van feedback verwerking"""
    
    module_name: str
    feedback_processed: bool
    model_updated: bool
    learning_gains: float = 0.0
    improvement_suggestions: List[str] = field(default_factory=list)
    new_patterns_learned: int = 0
    processing_time: float = 0.0
    success: bool = True
    error_message: Optional[str] = None


class TRMFeedback:
    """
    TRM Feedback voor continue verbetering
    
    Dit component verwerkt runtime feedback en gebruikt deze om
    het TRM model state bij te werken voor zelfoptimalisatie.
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialiseer de TRM Feedback
        
        Args:
            config: Feedback configuratie opties
        """
        self.config = config or {}
        
        # Feedback instellingen
        self.learning_strategy = self.config.get('learning_strategy', LearningStrategy.HYBRID)
        self.learning_rate = self.config.get('learning_rate', 0.001)
        self.batch_size = self.config.get('batch_size', 32)
        self.enable_online_learning = self.config.get('enable_online_learning', True)
        self.enable_pattern_recognition = self.config.get('enable_pattern_recognition', True)
        self.feedback_window_size = self.config.get('feedback_window_size', 1000)
        
        # Model state voor feedback learning
        self.model_state = {
            'weights': None,
            'biases': None,
            'latent_state': None,
            'feedback_patterns': {},
            'performance_history': [],
            'error_patterns': {},
            'optimization_insights': {},
            'learning_rate_schedule': {},
            'convergence_metrics': {}
        }
        
        # Feedback buffer
        self.feedback_buffer: List[Dict[str, Any]] = []
        self.performance_history: List[ExecutionMetrics] = []
        
        # Learning state
        self.learning_state = {
            'epoch': 0,
            'batch_count': 0,
            'total_feedback_processed': 0,
            'convergence_achieved': False,
            'last_update_time': time.time()
        }
        
        # Cache voor snelle toegang
        self.feedback_cache: Dict[str, FeedbackResult] = {}
        
        # Statistics
        self.stats = {
            'total_feedback_processed': 0,
            'successful_feedback_processing': 0,
            'failed_feedback_processing': 0,
            'cache_hits': 0,
            'average_processing_time': 0.0,
            'patterns_learned': 0,
            'model_updates': 0,
            'learning_efficiency': 0.0
        }
        
        logger.info(f"TRM Feedback geÃ¯nitialiseerd met config: {self.config}")
    
    async def initialize(self):
        """Initialiseer de feedback component"""
        # Initialiseer model state
        await self._initialize_model_state()
        
        # Start background tasks
        self._learning_task = asyncio.create_task(self._continuous_learning())
        self._cleanup_task = asyncio.create_task(self._cleanup_cache())
        self._analysis_task = asyncio.create_task(self._periodic_analysis())
        
        logger.info("TRM Feedback geÃ¯nitialiseerd")
    
    async def cleanup(self):
        """Clean up de feedback component"""
        if hasattr(self, '_learning_task'):
            self._learning_task.cancel()
        
        if hasattr(self, '_cleanup_task'):
            self._cleanup_task.cancel()
        
        if hasattr(self, '_analysis_task'):
            self._analysis_task.cancel()
        
        self.feedback_buffer.clear()
        self.performance_history.clear()
        self.feedback_cache.clear()
        
        logger.info("TRM Feedback opgeschoond")
    
    async def process(self,
                     module_name: str,
                     execution_metrics: Dict[str, Any],
                     optimization_results: Dict[str, Any],
                     model_state: Optional[Dict[str, Any]] = None,
                     learning_rate: float = 0.001) -> FeedbackResult:
        """
        Verwerk feedback van uitvoering
        
        Args:
            module_name: Naam van de module
            execution_metrics: Uitvoeringsmetrieken
            optimization_results: Resultaten van optimalisatie
            model_state: Optionele model state
            learning_rate: Leer rate
            
        Returns:
            FeedbackResult met verwerkingsresultaten
        """
        start_time = time.time()
        
        try:
            # Update model state
            if model_state:
                self.model_state.update(model_state)
            
            # Update learning rate
            self.learning_rate = learning_rate
            
            # Parse execution metrics
            metrics = self._parse_execution_metrics(execution_metrics)
            
            # Parse optimization results
            optimization_insights = self._parse_optimization_results(optimization_results)
            
            # Voeg toe aan performance history
            self.performance_history.append(metrics)
            self._maintain_performance_window()
            
            # Verwerk feedback
            feedback_processed = await self._process_feedback_data(
                module_name, 
                metrics, 
                optimization_insights
            )
            
            # Update model state indien nodig
            model_updated = False
            if feedback_processed:
                model_updated = await self._update_model_state(module_name)
            
            # Leer van patronen
            learning_gains = 0.0
            new_patterns_learned = 0
            improvement_suggestions = []
            
            if self.enable_pattern_recognition:
                learning_gains, new_patterns, suggestions = await self._learn_from_patterns(module_name)
                new_patterns_learned = new_patterns
                improvement_suggestions = suggestions
            
            # Compileer resultaat
            feedback_result = FeedbackResult(
                module_name=module_name,
                feedback_processed=feedback_processed,
                model_updated=model_updated,
                learning_gains=learning_gains,
                new_patterns_learned=new_patterns_learned,
                improvement_suggestions=improvement_suggestions,
                processing_time=time.time() - start_time,
                success=True
            )
            
            # Update statistics
            self.stats['total_feedback_processed'] += 1
            self.stats['successful_feedback_processing'] += 1
            self.stats['patterns_learned'] += new_patterns_learned
            if model_updated:
                self.stats['model_updates'] += 1
            
            proc_time = feedback_result.processing_time
            self.stats['average_processing_time'] = (
                (self.stats['average_processing_time'] * (self.stats['total_feedback_processed'] - 1) + proc_time) 
                / self.stats['total_feedback_processed']
            )
            
            # Cache resultaat
            cache_key = f"{module_name}_{metrics.timestamp}"
            self.feedback_cache[cache_key] = feedback_result
            
            logger.debug(f"Feedback verwerkt voor {module_name} ({proc_time:.3f}s)")
            
            if feedback_result.improvement_suggestions:
                logger.info(f"Verbeterings suggesties voor {module_name}: {', '.join(feedback_result.improvement_suggestions)}")
            
            return feedback_result
            
        except Exception as e:
            self.stats['total_feedback_processed'] += 1
            self.stats['failed_feedback_processing'] += 1
            
            proc_time = time.time() - start_time
            logger.error(f"Feedback verwerkings fout voor {module_name}: {e} ({proc_time:.3f}s)")
            
            # Compileer error resultaat
            error_result = FeedbackResult(
                module_name=module_name,
                feedback_processed=False,
                model_updated=False,
                processing_time=proc_time,
                success=False,
                error_message=str(e)
            )
            
            return error_result
    
    def _parse_execution_metrics(self, execution_metrics: Dict[str, Any]) -> ExecutionMetrics:
        """
        Parse execution metrics naar gestructureerd formaat
        
        Args:
            execution_metrics: Raw execution metrics
            
        Returns:
            ExecutionMetrics object
        """
        return ExecutionMetrics(
            execution_time=execution_metrics.get('execution_time', 0.0),
            memory_usage=execution_metrics.get('memory_usage', 0.0),
            cpu_usage=execution_metrics.get('cpu_usage', 0.0),
            error_rate=execution_metrics.get('error_rate', 0.0),
            success=execution_metrics.get('success', True),
            timestamp=time.time(),
            optimization_gains=execution_metrics.get('optimization_gains', 0.0),
            code_size_reduction=execution_metrics.get('code_size_reduction', 0.0),
            energy_efficiency=execution_metrics.get('energy_efficiency', 0.0)
        )
    
    def _parse_optimization_results(self, optimization_results: Dict[str, Any]) -> Dict[str, Any]:
        """
        Parse optimization results
        
        Args:
            optimization_results: Raw optimization results
            
        Returns:
            Gestructureerde optimization insights
        """
        insights = {
            'optimizations_applied': optimization_results.get('optimizations_applied', []),
            'performance_improvement': optimization_results.get('performance_improvement', 0.0),
            'memory_improvement': optimization_results.get('memory_improvement', 0.0),
            'code_reduction': optimization_results.get('code_reduction', 0.0),
            'optimization_time': optimization_results.get('optimization_time', 0.0),
            'success': optimization_results.get('success', True)
        }
        
        return insights
    
    def _maintain_performance_window(self):
        """Onderhoud performance window voor recente metrieken"""
        current_time = time.time()
        cutoff_time = current_time - (self.feedback_window_size * 3600)  # Convert hours to seconds
        
        # Filter out old metrics
        self.performance_history = [
            metrics for metrics in self.performance_history
            if metrics.timestamp > cutoff_time
        ]
    
    async def _process_feedback_data(self,
                                   module_name: str,
                                   metrics: ExecutionMetrics,
                                   optimization_insights: Dict[str, Any]) -> bool:
        """
        Verwerk feedback data
        
        Args:
            module_name: Naam van de module
            metrics: Execution metrics
            optimization_insights: Optimization insights
            
        Returns:
            True als feedback succesvol is verwerkt
        """
        try:
            # Bouw feedback record
            feedback_record = {
                'module_name': module_name,
                'timestamp': metrics.timestamp,
                'metrics': {
                    'execution_time': metrics.execution_time,
                    'memory_usage': metrics.memory_usage,
                    'cpu_usage': metrics.cpu_usage,
                    'error_rate': metrics.error_rate,
                    'success': metrics.success,
                    'optimization_gains': metrics.optimization_gains
                },
                'optimization': optimization_insights,
                'performance_score': self._calculate_performance_score(metrics),
                'efficiency_score': self._calculate_efficiency_score(metrics)
            }
            
            # Voeg toe aan feedback buffer
            self.feedback_buffer.append(feedback_record)
            
            # Verwerk buffer indien volgens strategie
            if self.learning_strategy == LearningStrategy.ONLINE:
                await self._process_feedback_buffer()
            elif len(self.feedback_buffer) >= self.batch_size:
                await self._process_feedback_buffer()
            
            return True
            
        except Exception as e:
            logger.error(f"Feedback data verwerking mislukt: {e}")
            return False
    
    def _calculate_performance_score(self, metrics: ExecutionMetrics) -> float:
        """Bereken performance score"""
        # Normaliseer metrieken (lagere is beter)
        normalized_time = min(metrics.execution_time / 1000.0, 1.0)  # Normaliseer naar 0-1
        normalized_memory = min(metrics.memory_usage / 1024.0, 1.0)  # Normaliseer naar 0-1
        normalized_cpu = min(metrics.cpu_usage / 100.0, 1.0)  # Normaliseer naar 0-1
        
        # Bereken gewogen score (lagere is beter)
        performance_score = (
            0.4 * normalized_time +
            0.3 * normalized_memory +
            0.3 * normalized_cpu
        )
        
        return 1.0 - performance_score  # Hogere is beter
    
    def _calculate_efficiency_score(self, metrics: ExecutionMetrics) -> float:
        """Bereken efficiency score"""
        # Efficiency = Performance / Resource Usage
        if metrics.memory_usage > 0 and metrics.cpu_usage > 0:
            efficiency = (1.0 / metrics.execution_time) / (metrics.memory_usage * metrics.cpu_usage)
            return min(efficiency, 1.0)
        
        return 0.0
    
    async def _process_feedback_buffer(self):
        """
        Verwerk feedback buffer
        """
        if not self.feedback_buffer:
            return
        
        try:
            # Groeer feedback per module
            module_feedback = {}
            for record in self.feedback_buffer:
                module_name = record['module_name']
                if module_name not in module_feedback:
                    module_feedback[module_name] = []
                module_feedback[module_name].append(record)
            
            # Verwerk feedback per module
            for module_name, records in module_feedback.items():
                await self._aggregate_module_feedback(module_name, records)
            
            # Wis buffer
            self.feedback_buffer.clear()
            
            # Update learning state
            self.learning_state['batch_count'] += 1
            
        except Exception as e:
            logger.error(f"Feedback buffer verwerking mislukt: {e}")
    
    async def _aggregate_module_feedback(self,
                                       module_name: str,
                                       records: List[Dict[str, Any]]):
        """
        Aggregeer feedback voor een specifieke module
        
        Args:
            module_name: Naam van de module
            records: Feedback records voor de module
        """
        try:
            # Bereken gemiddelden
            avg_performance = sum(r['performance_score'] for r in records) / len(records)
            avg_efficiency = sum(r['efficiency_score'] for r in records) / len(records)
            avg_execution_time = sum(r['metrics']['execution_time'] for r in records) / len(records)
            
            # Identificeer patronen
            patterns = self._identify_feedback_patterns(records)
            
            # Update feedback patterns
            if module_name not in self.model_state['feedback_patterns']:
                self.model_state['feedback_patterns'][module_name] = {
                    'performance_trend': [],
                    'efficiency_trend': [],
                    'pattern_frequency': {},
                    'optimization_effectiveness': {}
                }
            
            patterns_data = self.model_state['feedback_patterns'][module_name]
            
            # Update trends
            patterns_data['performance_trend'].append(avg_performance)
            patterns_data['efficiency_trend'].append(avg_efficiency)
            
            # Beperk trend lengte
            max_trend_length = 50
            if len(patterns_data['performance_trend']) > max_trend_length:
                patterns_data['performance_trend'] = patterns_data['performance_trend'][-max_trend_length:]
                patterns_data['efficiency_trend'] = patterns_data['efficiency_trend'][-max_trend_length:]
            
            # Update pattern frequency
            for pattern_name, pattern_count in patterns.items():
                if pattern_name not in patterns_data['pattern_frequency']:
                    patterns_data['pattern_frequency'][pattern_name] = 0
                patterns_data['pattern_frequency'][pattern_name] += pattern_count
            
            logger.debug(f"Feedback geaggregeerd voor {module_name}: avg_performance={avg_performance:.3f}")
            
        except Exception as e:
            logger.error(f"Module feedback aggregatie mislukt voor {module_name}: {e}")
    
    def _identify_feedback_patterns(self, records: List[Dict[str, Any]]) -> Dict[str, int]:
        """
        Identificeer patronen in feedback data
        
        Args:
            records: Feedback records
            
        Returns:
            Dictionary met patroon namen en frequenties
        """
        patterns = {}
        
        try:
            # Performance patronen
            performance_scores = [r['performance_score'] for r in records]
            if max(performance_scores) - min(performance_scores) > 0.3:
                patterns['high_performance_variance'] = len(records)
            
            # Efficiency patronen
            efficiency_scores = [r['efficiency_score'] for r in records]
            if sum(efficiency_scores) / len(efficiency_scores) > 0.7:
                patterns['high_efficiency'] = len(records)
            
            # Error patronen
            error_rates = [r['metrics']['error_rate'] for r in records]
            if any(rate > 0.1 for rate in error_rates):  # > 10% error rate
                patterns['high_error_rate'] = len([r for r in records if r['metrics']['error_rate'] > 0.1])
            
            # Optimalisatie patronen
            optimizations_applied = set()
            for record in records:
                for opt in record['optimization']['optimizations_applied']:
                    optimizations_applied.add(opt)
            
            if optimizations_applied:
                patterns['optimizations_active'] = len(optimizations_applied)
            
        except Exception as e:
            logger.warning(f"Patroon identificatie mislukt: {e}")
        
        return patterns
    
    async def _update_model_state(self, module_name: str) -> bool:
        """
        Update model state op basis van feedback
        
        Args:
            module_name: Naam van de module
            
        Returns:
            True als model state is bijgewerkt
        """
        try:
            # Haal feedback patterns op
            if module_name not in self.model_state['feedback_patterns']:
                return False
            
            patterns_data = self.model_state['feedback_patterns'][module_name]
            
            # Bereken learning delta
            performance_trend = patterns_data['performance_trend']
            if len(performance_trend) < 2:
                return False
            
            # Calculate trend direction
            recent_performance = performance_trend[-5:] if len(performance_trend) >= 5 else performance_trend
            if len(recent_performance) < 2:
                return False
            
            performance_delta = recent_performance[-1] - recent_performance[0]
            
            # Update weights indien significant verandering
            if abs(performance_delta) > 0.05:  # 5% significant change
                await self._apply_learning_delta(module_name, performance_delta)
                return True
            
            return False
            
        except Exception as e:
            logger.error(f"Model state update mislukt voor {module_name}: {e}")
            return False
    
    async def _apply_learning_delta(self, module_name: str, performance_delta: float):
        """
        Pas learning delta toe op model state
        
        Args:
            module_name: Naam van de module
            performance_delta: Performance verandering
        """
        try:
            # Simuleer weight update
            if self.model_state['weights'] is not None:
                # Apply learning rate and delta
                learning_factor = self.learning_rate * performance_delta
                
                # Update weights (simulatie)
                self.model_state['weights'] += learning_factor * np.random.random(self.model_state['weights'].shape) * 0.1
                
                # Update biases (simulatie)
                if self.model_state['biases'] is not None:
                    self.model_state['biases'] += learning_factor * np.random.random(self.model_state['biases'].shape) * 0.1
                
                # Update convergence metrics
                self.model_state['convergence_metrics'][module_name] = {
                    'last_update': time.time(),
                    'performance_delta': performance_delta,
                    'learning_applied': learning_factor
                }
                
                logger.debug(f"Learning toegepast voor {module_name}: delta={performance_delta:.3f}")
            
        except Exception as e:
            logger.error(f"Learning delta toepassen mislukt: {e}")
    
    async def _learn_from_patterns(self, module_name: str) -> Tuple[float, int, List[str]]:
        """
        Leer van geÃ¯dentificeerde patronen
        
        Args:
            module_name: Naam van de module
            
        Returns:
            Tuple van learning gains, nieuwe patronen, en suggesties
        """
        try:
            learning_gains = 0.0
            new_patterns = 0
            suggestions = []
            
            # Haal module feedback patterns op
            if module_name in self.model_state['feedback_patterns']:
                patterns = self.model_state['feedback_patterns'][module_name]
                
                # Analyseer performance trend
                performance_trend = patterns['performance_trend']
                if len(performance_trend) >= 10:
                    # Bereken trend
                    trend_slope = (performance_trend[-1] - performance_trend[0]) / len(performance_trend)
                    learning_gains = abs(trend_slope) * 0.1  # Scale learning gains
                    
                    # Genereer suggesties
                    if trend_slope > 0:  # Verbetering
                        suggestions.append("Performance verbetering wordt waargenomen")
                        new_patterns += 1
                    elif trend_slope < -0.1:  # Verslechtering
                        suggestions.append("Performance verslechtering gedetecteerd - optimalisatie aanbevolen")
                        new_patterns += 1
                
                # Analyseer efficiency
                if 'efficiency_trend' in patterns:
                    efficiency_trend = patterns['efficiency_trend']
                    if len(efficiency_trend) >= 5:
                        avg_efficiency = sum(efficiency_trend) / len(efficiency_trend)
                        if avg_efficiency > 0.8:
                            suggestions.append("Hoge efficiency waargenomen - huidige strategie effectief")
                        elif avg_efficiency < 0.3:
                            suggestions.append("Lage efficiency waargenomen - strategie heroverwegen")
                
                # Update optimization insights
                if 'optimizations_applied' in patterns:
                    for opt in patterns['optimizations_applied']:
                        if opt not in self.model_state['optimization_insights']:
                            self.model_state['optimization_insights'][opt] = {
                                'usage_count': 0,
                                'success_rate': 0.0
                            }
                        self.model_state['optimization_insights'][opt]['usage_count'] += 1
            
            return learning_gains, new_patterns, suggestions
            
        except Exception as e:
            logger.error(f"Patroon leren mislukt voor {module_name}: {e}")
            return 0.0, 0, []
    
    async def _continuous_learning(self):
        """Continue leerproces"""
        while True:
            try:
                await asyncio.sleep(600)  # 10 minuten
                
                # Verwerk feedback buffer
                if self.feedback_buffer:
                    await self._process_feedback_buffer()
                
                # Update learning state
                self.learning_state['epoch'] += 1
                current_time = time.time()
                
                # Check convergence
                if self.learning_state['epoch'] % 10 == 0:  # Elke 10 epochs
                    convergence_achieved = await self._check_convergence()
                    self.learning_state['convergence_achieved'] = convergence_achieved
                
                # Update learning rate schedule
                await self._update_learning_rate_schedule()
                
                logger.debug(f"Continue leerproces epoch {self.learning_state['epoch']}")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Continue leerproces fout: {e}")
    
    async def _check_convergence(self) -> bool:
        """Check of model convergence heeft bereikt"""
        try:
            # Simuleer convergence check
            if len(self.performance_history) < 50:
                return False
            
            # Bereken recente performance stabiliteit
            recent_metrics = self.performance_history[-50:]
            performance_scores = [self._calculate_performance_score(m) for m in recent_metrics]
            
            # Check stabiliteit (lage variantatie)
            if len(performance_scores) >= 10:
                recent_scores = performance_scores[-10:]
                variance = np.var(recent_scores)
                
                if variance < 0.01:  # Lage variantatie = stabiliteit
                    return True
            
            return False
            
        except Exception as e:
            logger.error(f"Convergence check mislukt: {e}")
            return False
    
    async def _update_learning_rate_schedule(self):
        """Update learning rate schedule"""
        try:
            # Simuleer learning rate schedule update
            if self.learning_state['convergence_achieved']:
                # Reduce learning rate bij convergence
                self.learning_rate *= 0.95
                self.model_state['learning_rate_schedule']['current'] = self.learning_rate
            
            # Sla laatste update op
            self.learning_state['last_update_time'] = time.time()
            
        except Exception as e:
            logger.error(f"Learning rate schedule update mislukt: {e}")
    
    async def _periodic_analysis(self):
        """Periodieke analyse van feedback data"""
        while True:
            try:
                await asyncio.sleep(1800)  # 30 minuten
                
                # Voer periodieke analyse uit
                await self._analyze_feedback_trends()
                await self._generate_insights()
                
                logger.debug("Periodieke feedback analyse voltooid")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Periodieke analyse fout: {e}")
    
    async def _analyze_feedback_trends(self):
        """Analyseer feedback trends"""
        try:
            if len(self.performance_history) < 10:
                return
            
            # Bereken trends
            recent_metrics = self.performance_history[-100:] if len(self.performance_history) >= 100 else self.performance_history
            
            # Performance trend
            performance_scores = [self._calculate_performance_score(m) for m in recent_metrics]
            avg_performance = sum(performance_scores) / len(performance_scores)
            
            # Memory usage trend
            memory_usage = [m.memory_usage for m in recent_metrics]
            avg_memory = sum(memory_usage) / len(memory_usage)
            
            # Update global performance metrics
            self.model_state['performance_metrics']['average_performance'] = avg_performance
            self.model_state['performance_metrics']['average_memory'] = avg_memory
            
            logger.debug(f"Feedback trends geanalyseerd: avg_performance={avg_performance:.3f}, avg_memory={avg_memory:.1f}MB")
            
        except Exception as e:
            logger.error(f"Feedback trend analyse mislukt: {e}")
    
    async def _generate_insights(self):
        """Genereer inzichten uit feedback data"""
        try:
            insights = []
            
            # Analyseer performance trends
            if 'average_performance' in self.model_state['performance_metrics']:
                avg_perf = self.model_state['performance_metrics']['average_performance']
                if avg_perf > 0.8:
                    insights.append("Algemene performance is uitstekend")
                elif avg_perf < 0.4:
                    insights.append("Performance verbetering nodig")
            
            # Analyseer error patterns
            error_patterns = self.model_state['error_patterns']
            if error_patterns:
                insights.append(f"{len(error_patterns)} fout patronen gedetecteerd")
            
            # Update model state met inzichten
            if insights:
                self.model_state['insights'] = insights
                logger.info(f"Feedback inzichten gegenereerd: {', '.join(insights)}")
            
        except Exception as e:
            logger.error(f"Inzichten genereren mislukt: {e}")
    
    async def _initialize_model_state(self):
        """Initialiseer model state"""
        # Simuleer model state initialisatie
        self.model_state['weights'] = np.random.random((64, 32)) * 0.1
        self.model_state['biases'] = np.random.random((32,)) * 0.1
        self.model_state['latent_state'] = np.random.random((16,)) * 0.1
    
    async def _cleanup_cache(self):
        """Periodieke cleanup van de cache"""
        while True:
            try:
                await asyncio.sleep(3600)  # 1 uur
                
                # Verwijder oude cache entries
                current_time = time.time()
                old_keys = [
                    key for key, result in self.feedback_cache.items()
                    if current_time - result.processing_time > 7200  # 2 uur
                ]
                
                for key in old_keys:
                    del self.feedback_cache[key]
                
                if old_keys:
                    logger.info(f"Feedback cache opgeschoond: {len(old_keys)} entries verwijderd")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Feedback cache cleanup fout: {e}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg feedback statistieken"""
        stats = self.stats.copy()
        stats.update({
            'cache_size': len(self.feedback_cache),
            'feedback_buffer_size': len(self.feedback_buffer),
            'performance_history_size': len(self.performance_history),
            'learning_strategy': self.learning_strategy.value,
            'learning_rate': self.learning_rate,
            'learning_state': self.learning_state.copy(),
            'total_modules': len(self.model_state['feedback_patterns'])
        })
        return stats
    
    def clear_cache(self):
        """Wis de feedback cache"""
        self.feedback_cache.clear()
        logger.info("Feedback cache gewist")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"TRMFeedback(cache={len(self.feedback_cache)}, processed={self.stats['total_feedback_processed']})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return f"TRMFeedback(cache_size={len(self.feedback_cache)}, stats={self.stats})"


