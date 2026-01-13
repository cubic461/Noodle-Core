"""
Ai Agents::Agent - agent.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Main TRM-Agent implementation

Dit bevat de hoofd-klasse voor de TRM-Agent die alle componenten coÃ¶rdineert.
"""

import asyncio
import logging
import time
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass, field
from enum import Enum

from parser import TRMParser
from translator import TRMTranslator
from optimizer import TRMOptimizer
from feedback import TRMFeedback

logger = logging.getLogger(__name__)


class AgentMode(Enum):
    """Agent uitvoeringsmodi"""
    TRAINING = "training"
    INFERENCE = "inference"
    HYBRID = "hybrid"


class TRMAgent:
    """
    Hoofd TRM-Agent klasse die Python-code vertaalt naar NoodleCore-IR
    en optimaliseert op basis van feedback.
    """
    
    def __init__(self, 
                 mode: AgentMode = AgentMode.HYBRID,
                 model_path: Optional[str] = None,
                 bit_precision: int = 16,
                 learning_rate: float = 0.001,
                 config: Optional[Dict[str, Any]] = None):
        """
        Initialiseer de TRM-Agent
        
        Args:
            mode: Uitvoeringsmodus (training, inference, hybrid)
            model_path: Pad naar voorgetraind model (optioneel)
            bit_precision: Bits voor kwantisatie (16, 8, 4, 1)
            learning_rate: Leer voor training
            config: Extra configuratie opties
        """
        self.mode = mode
        self.model_path = model_path
        self.bit_precision = bit_precision
        self.learning_rate = learning_rate
        self.config = config or {}
        
        # Initialiseer componenten
        self.parser = TRMParser(config=self.config.get('parser', {}))
        self.translator = TRMTranslator(config=self.config.get('translator', {}))
        self.optimizer = TRMOptimizer(config=self.config.get('optimizer', {}))
        self.feedback = TRMFeedback(config=self.config.get('feedback', {}))
        
        # Status tracking
        self.is_running = False
        self.processed_modules = 0
        self.optimized_modules = 0
        self.total_processing_time = 0.0
        
        # Model state (voor training)
        self.model_state = {
            'weights': None,
            'biases': None,
            'latent_state': None,
            'training_history': []
        }
        
        # Cache voor snelle toegang
        self.module_cache: Dict[str, Dict[str, Any]] = {}
        self.optimization_cache: Dict[str, Dict[str, Any]] = {}
        
        # Event handlers
        self.on_module_processed = None
        self.on_module_optimized = None
        self.on_agent_error = None
        
        # Statistics
        self.stats = {
            'total_modules': 0,
            'successful_parses': 0,
            'failed_parses': 0,
            'successful_translations': 0,
            'failed_translations': 0,
            'successful_optimizations': 0,
            'failed_optimizations': 0,
            'feedback_updates': 0,
            'average_processing_time': 0.0
        }
        
        logger.info(f"TRM-Agent geÃ¯nitialiseerd in {mode.value} mode met {bit_precision}-bit precisie")
    
    async def start(self):
        """Start de TRM-Agent"""
        if self.is_running:
            logger.warning("TRM-Agent is al actief")
            return
        
        self.is_running = True
        
        # Initialiseer componenten
        await self.parser.initialize()
        await self.translator.initialize()
        await self.optimizer.initialize()
        await self.feedback.initialize()
        
        logger.info("TRM-Agent gestart")
    
    async def stop(self):
        """Stop de TRM-Agent"""
        if not self.is_running:
            return
        
        self.is_running = False
        
        # Stop componenten
        await self.parser.cleanup()
        await self.translator.cleanup()
        await self.optimizer.cleanup()
        await self.feedback.cleanup()
        
        logger.info("TRM-Agent gestopt")
    
    async def parse_module(self, 
                          source_code: str, 
                          module_name: str,
                          file_path: Optional[str] = None) -> Dict[str, Any]:
        """
        Parse Python-code naar AST/parse-structuur
        
        Args:
            source_code: Python broncode
            module_name: Naam van de module
            file_path: Bestandspad (optioneel)
            
        Returns:
            Parse resultaat met AST en metadata
        """
        start_time = time.time()
        
        try:
            # Parse broncode
            parse_result = await self.parser.parse(
                source_code=source_code,
                module_name=module_name,
                file_path=file_path
            )
            
            # Update statistics
            self.stats['successful_parses'] += 1
            self.stats['total_modules'] += 1
            
            logger.debug(f"Succesvol geparsed: {module_name}")
            
            # Roep event handler aan
            if self.on_module_processed:
                await self.on_module_processed(module_name, 'parse', parse_result)
            
            return parse_result
            
        except Exception as e:
            self.stats['failed_parses'] += 1
            logger.error(f"Parse fout in {module_name}: {e}")
            
            # Roep error handler aan
            if self.on_agent_error:
                await self.on_agent_error(module_name, 'parse', str(e))
            
            raise
    
    async def translate_ast(self, 
                           ast_data: Dict[str, Any],
                           module_name: str) -> Dict[str, Any]:
        """
        Vertaal AST naar NoodleCore-IR
        
        Args:
            ast_data: AST data van parser
            module_name: Naam van de module
            
        Returns:
            NoodleCore-IR representatie
        """
        start_time = time.time()
        
        try:
            # Vertaal AST naar IR
            ir_result = await self.translator.translate(
                ast_data=ast_data,
                module_name=module_name
            )
            
            # Update statistics
            self.stats['successful_translations'] += 1
            
            logger.debug(f"Succesvol vertaald: {module_name}")
            
            return ir_result
            
        except Exception as e:
            self.stats['failed_translations'] += 1
            logger.error(f"Vertaal fout in {module_name}: {e}")
            
            raise
    
    async def optimize_ir(self, 
                         ir_data: Dict[str, Any],
                         module_name: str,
                         optimization_level: int = 1) -> Dict[str, Any]:
        """
        Optimaliseer NoodleCore-IR
        
        Args:
            ir_data: NoodleCore-IR data
            module_name: Naam van de module
            optimization_level: Optimalisatie niveau (1-3)
            
        Returns:
            Geoptimaliseerde IR
        """
        start_time = time.time()
        
        try:
            # Optimaliseer IR
            optimized_ir = await self.optimizer.optimize(
                ir_data=ir_data,
                module_name=module_name,
                optimization_level=optimization_level,
                model_state=self.model_state
            )
            
            # Update statistics
            self.stats['successful_optimizations'] += 1
            self.optimized_modules += 1
            
            logger.debug(f"Succesvol geoptimaliseerd: {module_name}")
            
            # Roep event handler aan
            if self.on_module_optimized:
                await self.on_module_optimized(module_name, 'optimize', optimized_ir)
            
            return optimized_ir
            
        except Exception as e:
            self.stats['failed_optimizations'] += 1
            logger.error(f"Optimalisatie fout in {module_name}: {e}")
            
            # Fallback naar originele IR
            return ir_data
    
    async def process_feedback(self,
                             module_name: str,
                             execution_metrics: Dict[str, Any],
                             optimization_results: Dict[str, Any]):
        """
        Verwerk feedback van uitvoering
        
        Args:
            module_name: Naam van de module
            execution_metrics: Uitvoeringsmetrieken
            optimization_results: Resultaten van optimalisatie
        """
        try:
            # Verwerk feedback
            feedback_result = await self.feedback.process(
                module_name=module_name,
                execution_metrics=execution_metrics,
                optimization_results=optimization_results,
                model_state=self.model_state,
                learning_rate=self.learning_rate
            )
            
            # Update model state
            if feedback_result.get('model_updated'):
                self.model_state = feedback_result['model_state']
                self.stats['feedback_updates'] += 1
            
            logger.debug(f"Feedback verwerkt voor {module_name}")
            
        except Exception as e:
            logger.error(f"Feedback verwerkings fout voor {module_name}: {e}")
    
    async def process_module(self,
                           source_code: str,
                           module_name: str,
                           file_path: Optional[str] = None,
                           optimization_level: int = 1) -> Dict[str, Any]:
        """
        Verwerk een complete Python module
        
        Args:
            source_code: Python broncode
            module_name: Naam van de module
            file_path: Bestandspad (optioneel)
            optimization_level: Optimalisatie niveau (1-3)
            
        Returns:
            Verwerkingsresultaat met IR en metadata
        """
        start_time = time.time()
        
        if not self.is_running:
            raise RuntimeError("TRM-Agent is niet gestart")
        
        try:
            # Controleer cache
            if module_name in self.module_cache:
                logger.debug(f"Gebruik cache voor {module_name}")
                return self.module_cache[module_name]
            
            # Stap 1: Parse
            parse_result = await self.parse_module(source_code, module_name, file_path)
            
            # Stap 2: Vertaal
            ir_result = await self.translate_ast(parse_result['ast'], module_name)
            
            # Stap 3: Optimaliseer
            optimized_ir = await self.optimize_ir(ir_result, module_name, optimization_level)
            
            # Compileer resultaat
            processing_result = {
                'module_name': module_name,
                'parse_result': parse_result,
                'ir_result': ir_result,
                'optimized_ir': optimized_ir,
                'processing_time': time.time() - start_time,
                'success': True,
                'timestamp': time.time()
            }
            
            # Update statistics
            self.processed_modules += 1
            self.total_processing_time += processing_result['processing_time']
            self.stats['average_processing_time'] = self.total_processing_time / max(1, self.processed_modules)
            
            # Cache resultaat
            self.module_cache[module_name] = processing_result
            
            logger.info(f"Module {module_name} succesvol verwerkt in {processing_result['processing_time']:.2f}s")
            
            return processing_result
            
        except Exception as e:
            logger.error(f"Module {module_name} verwerkingsfout: {e}")
            
            # Compileer error resultaat
            error_result = {
                'module_name': module_name,
                'success': False,
                'error': str(e),
                'processing_time': time.time() - start_time,
                'timestamp': time.time()
            }
            
            return error_result
    
    async def train_on_codebase(self,
                              code_samples: List[Dict[str, Any]],
                              epochs: int = 1) -> Dict[str, Any]:
        """
        Train de agent op een codebase
        
        Args:
            code_samples: Lijst met code samples
            epochs: Aantal epochs
            
        Returns:
            Training resultaten
        """
        if self.mode == AgentMode.INFERENCE:
            logger.warning("Training niet mogelijk in inference mode")
            return {'success': False, 'error': 'Training niet mogelijk in inference mode'}
        
        logger.info(f"Start training op {len(code_samples)} samples voor {epochs} epochs")
        
        training_start_time = time.time()
        epoch_results = []
        
        for epoch in range(epochs):
            epoch_start_time = time.time()
            epoch_errors = 0
            
            logger.info(f"Epoch {epoch + 1}/{epochs}")
            
            for i, sample in enumerate(code_samples):
                try:
                    module_name = sample.get('module_name', f'module_{i}')
                    source_code = sample.get('source_code', '')
                    optimization_level = sample.get('optimization_level', 1)
                    
                    # Verwerk module
                    result = await self.process_module(
                        source_code=source_code,
                        module_name=module_name,
                        optimization_level=optimization_level
                    )
                    
                    if result['success']:
                        # Genereer fake execution metrics voor training
                        execution_metrics = {
                            'execution_time': result['processing_time'] * 1000,  # ms
                            'memory_usage': 1024,  # MB
                            'cpu_usage': 50.0,  # %
                            'success': True,
                            'optimization_gains': 0.1  # 10% verbetering
                        }
                        
                        # Verwerk feedback
                        await self.process_feedback(
                            module_name=module_name,
                            execution_metrics=execution_metrics,
                            optimization_results=result
                        )
                    else:
                        epoch_errors += 1
                        
                except Exception as e:
                    logger.error(f"Training error in sample {i}: {e}")
                    epoch_errors += 1
            
            # Compileer epoch resultaat
            epoch_time = time.time() - epoch_start_time
            epoch_result = {
                'epoch': epoch + 1,
                'total_samples': len(code_samples),
                'errors': epoch_errors,
                'success_rate': (len(code_samples) - epoch_errors) / len(code_samples),
                'epoch_time': epoch_time
            }
            
            epoch_results.append(epoch_result)
            
            logger.info(f"Epoch {epoch + 1} voltooid: {epoch_result['success_rate']:.2%} succesvol")
        
        # Compileer training resultaat
        total_time = time.time() - training_start_time
        training_result = {
            'success': True,
            'total_epochs': epochs,
            'total_samples': len(code_samples),
            'total_time': total_time,
            'average_time_per_epoch': total_time / epochs,
            'epoch_results': epoch_results,
            'model_state': self.model_state,
            'final_stats': self.stats.copy()
        }
        
        logger.info(f"Training voltooid in {total_time:.2f}s")
        
        return training_result
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg statistieken van de agent"""
        stats = self.stats.copy()
        
        # Voeg extra statistieken toe
        stats.update({
            'is_running': self.is_running,
            'mode': self.mode.value,
            'bit_precision': self.bit_precision,
            'processed_modules': self.processed_modules,
            'optimized_modules': self.optimized_modules,
            'total_processing_time': self.total_processing_time,
            'cache_size': len(self.module_cache),
            'model_state_size': len(str(self.model_state)) if self.model_state else 0
        })
        
        return stats
    
    def clear_cache(self):
        """Wis de cache"""
        self.module_cache.clear()
        self.optimization_cache.clear()
        logger.info("Cache gewist")
    
    def export_model_state(self, filepath: str):
        """
        Exporteer model state naar bestand
        
        Args:
            filepath: Pad naar export bestand
        """
        import json
        
        export_data = {
            'model_state': self.model_state,
            'statistics': self.stats,
            'config': {
                'mode': self.mode.value,
                'bit_precision': self.bit_precision,
                'learning_rate': self.learning_rate
            },
            'export_timestamp': time.time()
        }
        
        with open(filepath, 'w') as f:
            json.dump(export_data, f, indent=2)
        
        logger.info(f"Model state geÃ«xporteerd naar {filepath}")
    
    def load_model_state(self, filepath: str):
        """
        Laad model state uit bestand
        
        Args:
            filepath: Pad naar import bestand
        """
        import json
        
        with open(filepath, 'r') as f:
            export_data = json.load(f)
        
        self.model_state = export_data['model_state']
        self.stats = export_data.get('statistics', self.stats)
        
        logger.info(f"Model state geladen uit {filepath}")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"TRMAgent(mode={self.mode.value}, running={self.is_running}, modules={self.processed_modules})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return (f"TRMAgent(mode={self.mode.value}, precision={self.bit_precision}, "
                f"processed={self.processed_modules}, optimized={self.optimized_modules})")


