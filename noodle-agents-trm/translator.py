"""
Ai Agents::Translator - translator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
TRM Translator Component

Dit component is verantwoordelijk voor het vertalen van AST structuren
naar NoodleCore Intermediate Representation (IR).
"""

import asyncio
import logging
import time
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass, field
from enum import Enum

logger = logging.getLogger(__name__)


class IRNodeType(Enum):
    """Soorten IR nodes"""
    MODULE = "module"
    FUNCTION = "function"
    CLASS = "class"
    ASSIGNMENT = "assignment"
    EXPRESSION = "expression"
    CONTROL_FLOW = "control_flow"
    LOOP = "loop"
    IMPORT = "import"
    RETURN = "return"
    CALL = "call"
    VARIABLE = "variable"
    LITERAL = "literal"
    OPERATION = "operation"
    TYPE = "type"


@dataclass
class IRNode:
    """IR Node representatie"""
    
    node_type: IRNodeType
    name: str
    children: List['IRNode'] = field(default_factory=list)
    attributes: Dict[str, Any] = field(default_factory=dict)
    position: Optional[Dict[str, int]] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class IRFunction:
    """IR Function representatie"""
    
    name: str
    parameters: List[Dict[str, Any]]
    return_type: Optional[str]
    body: List[IRNode]
    docstring: Optional[str] = None
    decorators: List[str] = field(default_factory=list)
    position: Optional[Dict[str, int]] = None
    complexity_score: float = 0.0


@dataclass
class IRClass:
    """IR Class representatie"""
    
    name: str
    methods: List[IRFunction]
    attributes: List[Dict[str, Any]]
    base_classes: List[str] = field(default_factory=list)
    docstring: Optional[str] = None
    position: Optional[Dict[str, int]] = None


@dataclass
class IRModule:
    """IR Module representatie"""
    
    name: str
    functions: List[IRFunction]
    classes: List[IRClass]
    imports: List[Dict[str, Any]]
    globals: List[Dict[str, Any]] = field(default_factory=list)
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class TranslationResult:
    """Resultaat van een vertaling"""
    
    module_name: str
    ir_module: IRModule
    original_ast: Dict[str, Any]
    translation_time: float
    success: bool
    error_message: Optional[str] = None
    complexity_metrics: Dict[str, Any] = field(default_factory=dict)


class TRMTranslator:
    """
    TRM Translator voor het vertalen van AST naar NoodleCore-IR
    
    Dit component converteert Abstract Syntax Trees naar een gestandaardiseerde
    Intermediate Representation (IR) die geschikt is voor optimalisatie.
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialiseer de TRM Translator
        
        Args:
            config: Translator configuratie opties
        """
        self.config = config or {}
        
        # Translator instellingen
        self.enable_debug_output = self.config.get('enable_debug_output', False)
        self.enable_metadata_preservation = self.config.get('enable_metadata_preservation', True)
        self.max_function_complexity = self.config.get('max_function_complexity', 10)
        self.supported_features = self.config.get('supported_features', [
            'functions', 'classes', 'imports', 'control_flow', 
            'expressions', 'type_hints'
        ])
        
        # Cache voor snelle toegang
        self.translation_cache: Dict[str, TranslationResult] = {}
        
        # Statistics
        self.stats = {
            'total_translations': 0,
            'successful_translations': 0,
            'failed_translations': 0,
            'cache_hits': 0,
            'average_translation_time': 0.0,
            'total_nodes_processed': 0
        }
        
        logger.info(f"TRM Translator geÃ¯nitialiseerd met config: {self.config}")
    
    async def initialize(self):
        """Initialiseer de translator"""
        # Start background tasks
        self._cleanup_task = asyncio.create_task(self._cleanup_cache())
        logger.info("TRM Translator geÃ¯nitialiseerd")
    
    async def cleanup(self):
        """Clean up de translator"""
        if hasattr(self, '_cleanup_task'):
            self._cleanup_task.cancel()
        
        self.translation_cache.clear()
        logger.info("TRM Translator opgeschoond")
    
    async def translate(self,
                       ast_data: Dict[str, Any],
                       module_name: str) -> TranslationResult:
        """
        Vertaal AST naar NoodleCore-IR
        
        Args:
            ast_data: AST data dictionary
            module_name: Naam van de module
            
        Returns:
            TranslationResult met IR module
        """
        start_time = time.time()
        
        try:
            # Controleer cache eerst
            cache_key = self._generate_cache_key(ast_data, module_name)
            if cache_key in self.translation_cache:
                self.stats['cache_hits'] += 1
                logger.debug(f"Cache hit voor {module_name}")
                return self.translation_cache[cache_key]
            
            # Parse AST data naar IR
            ir_module = self._convert_ast_to_ir(ast_data, module_name)
            
            # Calculeer complexiteitsmetrieken
            complexity_metrics = self._calculate_complexity_metrics(ir_module)
            
            # Compileer resultaat
            translation_result = TranslationResult(
                module_name=module_name,
                ir_module=ir_module,
                original_ast=ast_data,
                translation_time=time.time() - start_time,
                success=True,
                complexity_metrics=complexity_metrics
            )
            
            # Update statistics
            self.stats['total_translations'] += 1
            self.stats['successful_translations'] += 1
            self.stats['total_nodes_processed'] += self._count_nodes(ir_module)
            
            translation_time = translation_result.translation_time
            self.stats['average_translation_time'] = (
                (self.stats['average_translation_time'] * (self.stats['total_translations'] - 1) + translation_time) 
                / self.stats['total_translations']
            )
            
            # Cache resultaat
            self.translation_cache[cache_key] = translation_result
            
            logger.debug(f"Succesvol vertaald: {module_name} ({translation_time:.3f}s)")
            
            if self.enable_debug_output:
                logger.debug(f"IR voor {module_name}: {len(ir_module.functions)} functies, {len(ir_module.classes)} klassen")
            
            return translation_result
            
        except Exception as e:
            self.stats['total_translations'] += 1
            self.stats['failed_translations'] += 1
            
            translation_time = time.time() - start_time
            logger.error(f"Vertaal fout in {module_name}: {e} ({translation_time:.3f}s)")
            
            # Compileer error resultaat
            error_result = TranslationResult(
                module_name=module_name,
                ir_module=IRModule(name=module_name, functions=[], classes=[], imports=[]),
                original_ast=ast_data,
                translation_time=translation_time,
                success=False,
                error_message=str(e)
            )
            
            return error_result
    
    def _convert_ast_to_ir(self, ast_data: Dict[str, Any], module_name: str) -> IRModule:
        """
        Converteer AST naar IR
        
        Args:
            ast_data: AST data dictionary
            module_name: Naam van de module
            
        Returns:
            IR Module object
        """
        # Maak basis IR module
        ir_module = IRModule(
            name=module_name,
            functions=[],
            classes=[],
            imports=[]
        )
        
        # Converteer hoofd AST nodes
        for node_name, node_data in ast_data.items():
            if node_name == 'node_type' and node_data == 'Module':
                # Verwerk module children
                if 'body' in node_data:
                    for child_node in node_data['body']:
                        child_ir = self._convert_ast_node_to_ir(child_node)
                        if child_ir:
                            if isinstance(child_ir, IRFunction):
                                ir_module.functions.append(child_ir)
                            elif isinstance(child_ir, IRClass):
                                ir_module.classes.append(child_ir)
                            elif isinstance(child_ir, tuple) and child_ir[0] == 'import':
                                ir_module.imports.append(child_ir[1])
        
        return ir_module
    
    def _convert_ast_node_to_ir(self, node_data: Dict[str, Any]) -> Optional[Union[IRFunction, IRClass, tuple]]:
        """
        Converteer een AST node naar IR
        
        Args:
            node_data: AST node data
            
        Returns:
            IR object of None
        """
        node_type = node_data.get('node_type')
        
        if node_type == 'FunctionDef':
            return self._convert_function_to_ir(node_data)
        elif node_type == 'ClassDef':
            return self._convert_class_to_ir(node_data)
        elif node_type == 'Import':
            return ('import', self._convert_import_to_ir(node_data))
        elif node_type == 'ImportFrom':
            return ('import', self._convert_import_from_to_ir(node_data))
        else:
            logger.debug(f"Ongesteunde node type: {node_type}")
            return None
    
    def _convert_function_to_ir(self, node_data: Dict[str, Any]) -> IRFunction:
        """
        Converteer een FunctionDef node naar IR
        
        Args:
            node_data: FunctionDef node data
            
        Returns:
            IR Function object
        """
        # Extract functie informatie
        name = node_data.get('name', '')
        
        # Converteer parameters
        parameters = []
        if 'args' in node_data:
            args_data = node_data['args']
            for arg in args_data.get('args', []):
                param = {
                    'name': arg.get('arg', ''),
                    'type_annotation': self._extract_type_annotation(arg),
                    'default': None
                }
                parameters.append(param)
        
        # Converteer return type
        return_type = self._extract_type_annotation(node_data, 'returns')
        
        # Converteer body
        body = []
        if 'body' in node_data:
            for child_node in node_data['body']:
                child_ir = self._convert_ast_node_to_ir(child_node)
                if child_ir:
                    body.append(child_ir)
        
        # Extract docstring
        docstring = None
        if (node_data.get('body') and 
            isinstance(node_data['body'][0], dict) and 
            node_data['body'][0].get('node_type') == 'Expr' and
            node_data['body'][0].get('value', {}).get('node_type') == 'Constant'):
            docstring = node_data['body'][0]['value'].get('value')
        
        # Extract decorators
        decorators = []
        if 'decorator_list' in node_data:
            for decorator in node_data['decorator_list']:
                if decorator.get('node_type') == 'Name':
                    decorators.append(decorator.get('id', ''))
        
        # Bereken complexiteitsscore
        complexity_score = self._calculate_function_complexity(node_data)
        
        # Maak IR functie
        ir_function = IRFunction(
            name=name,
            parameters=parameters,
            return_type=return_type,
            body=body,
            docstring=docstring,
            decorators=decorators,
            complexity_score=complexity_score
        )
        
        return ir_function
    
    def _convert_class_to_ir(self, node_data: Dict[str, Any]) -> IRClass:
        """
        Converteer een ClassDef node naar IR
        
        Args:
            node_data: ClassDef node data
            
        Returns:
            IR Class object
        """
        # Extract class informatie
        name = node_data.get('name', '')
        
        # Converteer base classes
        base_classes = []
        if 'bases' in node_data:
            for base in node_data['bases']:
                if base.get('node_type') == 'Name':
                    base_classes.append(base.get('id', ''))
        
        # Converteer methods
        methods = []
        if 'body' in node_data:
            for child_node in node_data['body']:
                if child_node.get('node_type') == 'FunctionDef':
                    method = self._convert_function_to_ir(child_node)
                    methods.append(method)
        
        # Extract class attributes
        attributes = []
        if 'body' in node_data:
            for child_node in node_data['body']:
                if child_node.get('node_type') == 'AnnAssign':
                    attr = {
                        'name': child_node.get('target', {}).get('id', ''),
                        'type': self._extract_type_annotation(child_node),
                        'init_value': None
                    }
                    attributes.append(attr)
        
        # Extract docstring
        docstring = None
        if (node_data.get('body') and 
            isinstance(node_data['body'][0], dict) and 
            node_data['body'][0].get('node_type') == 'Expr' and
            node_data['body'][0].get('value', {}).get('node_type') == 'Constant'):
            docstring = node_data['body'][0]['value'].get('value')
        
        # Maak IR class
        ir_class = IRClass(
            name=name,
            methods=methods,
            attributes=attributes,
            base_classes=base_classes,
            docstring=docstring
        )
        
        return ir_class
    
    def _convert_import_to_ir(self, node_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Converteer een Import node naar IR
        
        Args:
            node_data: Import node data
            
        Returns:
            IR Import data
        """
        imports = []
        for alias in node_data.get('names', []):
            imports.append({
                'module': alias.get('name', ''),
                'alias': alias.get('asname', '')
            })
        
        return {'type': 'import', 'imports': imports}
    
    def _convert_import_from_to_ir(self, node_data: Dict[str, Any]) -> Dict[str, Any]:
        """
        Converteer een ImportFrom node naar IR
        
        Args:
            node_data: ImportFrom node data
            
        Returns:
            IR ImportFrom data
        """
        imports = []
        for alias in node_data.get('names', []):
            imports.append({
                'name': alias.get('name', ''),
                'asname': alias.get('asname', '')
            })
        
        return {
            'type': 'from_import',
            'module': node_data.get('module', ''),
            'level': node_data.get('level', 0),
            'imports': imports
        }
    
    def _extract_type_annotation(self, node_data: Dict[str, Any], field_name: str = 'annotation') -> Optional[str]:
        """
        Extract type annotation uit een node
        
        Args:
            node_data: Node data
            field_name: Naam van het veld
            
        Returns:
            Type naam of None
        """
        annotation = node_data.get(field_name)
        if annotation:
            if annotation.get('node_type') == 'Name':
                return annotation.get('id', '')
            elif annotation.get('node_type') == 'Subscript':
                value = annotation.get('value', {})
                if value.get('node_type') == 'Name':
                    return f"{value.get('id', '')}[{annotation.get('slice', {}).get('value', '')}]"
        
        return None
    
    def _calculate_function_complexity(self, node_data: Dict[str, Any]) -> float:
        """
        Bereken complexiteitsscore voor een functie
        
        Args:
            node_data: FunctionDef node data
            
        Returns:
            Complexiteitsscore
        """
        complexity = 0.0
        
        # Simpele complexiteitsberekening
        if 'body' in node_data:
            for child_node in node_data['body']:
                node_type = child_node.get('node_type')
                
                if node_type in ['If', 'For', 'While', 'Try']:
                    complexity += 1.0
                elif node_type in ['IfExp', 'DictComp', 'ListComp', 'SetComp', 'GeneratorExp']:
                    complexity += 0.5
        
        return complexity
    
    def _calculate_complexity_metrics(self, ir_module: IRModule) -> Dict[str, Any]:
        """
        Bereken complexiteitsmetrieken voor een IR module
        
        Args:
            ir_module: IR Module object
            
        Returns:
            Complexiteitsmetrieken
        """
        metrics = {
            'total_functions': len(ir_module.functions),
            'total_classes': len(ir_module.classes),
            'total_imports': len(ir_module.imports),
            'average_function_complexity': 0.0,
            'max_function_complexity': 0.0,
            'total_lines_of_code': 0,
            'cyclomatic_complexity': 0
        }
        
        if ir_module.functions:
            complexities = [func.complexity_score for func in ir_module.functions]
            metrics['average_function_complexity'] = sum(complexities) / len(complexities)
            metrics['max_function_complexity'] = max(complexities)
        
        # Simpele cyclomatische complexiteit
        metrics['cyclomatic_complexity'] = (
            metrics['total_functions'] + 
            metrics['total_classes'] + 
            metrics['total_imports']
        )
        
        return metrics
    
    def _count_nodes(self, ir_module: IRModule) -> int:
        """
        Tel het totaal aantal IR nodes
        
        Args:
            ir_module: IR Module object
            
        Returns:
            Totaal aantal nodes
        """
        count = 0
        
        # Tel functies
        for func in ir_module.functions:
            count += 1 + len(func.parameters) + len(func.body)
        
        # Tel klassen
        for cls in ir_module.classes:
            count += 1 + len(cls.methods) + len(cls.attributes)
        
        # Tel imports
        count += len(ir_module.imports)
        
        return count
    
    def _generate_cache_key(self, ast_data: Dict[str, Any], module_name: str) -> str:
        """Genereer een cache key voor gegeven input"""
        import hashlib
        content = f"{module_name}:{str(ast_data)}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    async def _cleanup_cache(self):
        """Periodieke cleanup van de cache"""
        while True:
            try:
                await asyncio.sleep(600)  # 10 minuten
                
                # Verwijder oude cache entries
                current_time = time.time()
                old_keys = [
                    key for key, result in self.translation_cache.items()
                    if current_time - result.translation_time > 7200  # 2 uur
                ]
                
                for key in old_keys:
                    del self.translation_cache[key]
                
                if old_keys:
                    logger.info(f"Translation cache opgeschoond: {len(old_keys)} entries verwijderd")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Translation cache cleanup fout: {e}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg translator statistieken"""
        stats = self.stats.copy()
        stats.update({
            'cache_size': len(self.translation_cache),
            'supported_features': self.supported_features,
            'max_function_complexity': self.max_function_complexity
        })
        return stats
    
    def clear_cache(self):
        """Wis de translation cache"""
        self.translation_cache.clear()
        logger.info("Translation cache gewist")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"TRMTranslator(cache={len(self.translation_cache)}, successful={self.stats['successful_translations']})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return f"TRMTranslator(cache_size={len(self.translation_cache)}, stats={self.stats})"


