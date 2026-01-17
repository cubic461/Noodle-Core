"""
# -*- coding: utf-8 -*-
"""
TRM Parser Component
Copyright © 2025 Michael van Erp. All rights reserved.
"""

import ast
import asyncio
import logging
import time
import inspect
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass, field
from pathlib import Path

logger = logging.getLogger(__name__)


@dataclass
class ParseResult:
    """Resultaat van een parse operatie"""
    
    module_name: str
    ast: Dict[str, Any]
    syntax_tree: ast.AST
    metadata: Dict[str, Any]
    functions: List[str] = field(default_factory=list)
    classes: List[str] = field(default_factory=list)
    imports: List[str] = field(default_factory=list)
    complexity_score: float = 0.0
    lines_of_code: int = 0
    timestamp: float = field(default_factory=time.time)


class TRMParser:
    """
    TRM Parser voor het verwerken van Python broncode
    
    Dit component parseert Python-code naar AST structuren en
    extraheert relevante metadata voor verdere verwerking.
    """
    
    def __init__(self, config: Optional[Dict[str, Any]] = None):
        """
        Initialiseer de TRM Parser
        
        Args:
            config: Parser configuratie opties
        """
        self.config = config or {}
        
        # Parser instellingen
        self.max_file_size = self.config.get('max_file_size', 1024 * 1024)  # 1MB
        self.supported_versions = self.config.get('supported_versions', [3.8, 3.9, 3.10, 3.11, 3.12])
        self.enable_type_hints = self.config.get('enable_type_hints', True)
        self.enable_docstrings = self.config.get('enable_docstrings', True)
        
        # Cache voor snelle toegang
        self.parse_cache: Dict[str, ParseResult] = {}
        
        # Statistics
        self.stats = {
            'total_parses': 0,
            'successful_parses': 0,
            'failed_parses': 0,
            'cache_hits': 0,
            'average_parse_time': 0.0,
            'total_bytes_processed': 0
        }
        
        logger.info(f"TRM Parser geÃ¯nitialiseerd met config: {self.config}")
    
    async def initialize(self):
        """Initialiseer de parser"""
        # Start background tasks
        self._cleanup_task = asyncio.create_task(self._cleanup_cache())
        logger.info("TRM Parser geÃ¯nitialiseerd")
    
    async def cleanup(self):
        """Clean up de parser"""
        if hasattr(self, '_cleanup_task'):
            self._cleanup_task.cancel()
        
        self.parse_cache.clear()
        logger.info("TRM Parser opgeschoond")
    
    async def parse(self,
                   source_code: str,
                   module_name: str,
                   file_path: Optional[str] = None) -> ParseResult:
        """
        Parse Python broncode
        
        Args:
            source_code: Python broncode
            module_name: Naam van de module
            file_path: Pad naar het bronbestand (optioneel)
            
        Returns:
            ParseResult met AST en metadata
        """
        start_time = time.time()
        
        try:
            # Controleer cache eerst
            cache_key = self._generate_cache_key(source_code, module_name)
            if cache_key in self.parse_cache:
                self.stats['cache_hits'] += 1
                logger.debug(f"Cache hit voor {module_name}")
                return self.parse_cache[cache_key]
            
            # Valideer input
            self._validate_input(source_code, module_name, file_path)
            
            # Parse de broncode
            syntax_tree = self._parse_to_ast(source_code)
            
            # Extracteer metadata
            metadata = self._extract_metadata(syntax_tree, source_code, file_path)
            
            # Converteer AST naar dictionary
            ast_dict = self._convert_ast_to_dict(syntax_tree)
            
            # Parse resultaat
            parse_result = ParseResult(
                module_name=module_name,
                ast=ast_dict,
                syntax_tree=syntax_tree,
                metadata=metadata,
                functions=metadata['functions'],
                classes=metadata['classes'],
                imports=metadata['imports'],
                complexity_score=metadata['complexity_score'],
                lines_of_code=metadata['lines_of_code'],
                timestamp=time.time()
            )
            
            # Update statistics
            self.stats['total_parses'] += 1
            self.stats['successful_parses'] += 1
            self.stats['total_bytes_processed'] += len(source_code.encode('utf-8'))
            
            parse_time = time.time() - start_time
            self.stats['average_parse_time'] = (
                (self.stats['average_parse_time'] * (self.stats['total_parses'] - 1) + parse_time) 
                / self.stats['total_parses']
            )
            
            # Cache resultaat
            self.parse_cache[cache_key] = parse_result
            
            logger.debug(f"Succesvol geparsed: {module_name} ({parse_time:.3f}s)")
            
            return parse_result
            
        except Exception as e:
            self.stats['total_parses'] += 1
            self.stats['failed_parses'] += 1
            
            parse_time = time.time() - start_time
            logger.error(f"Parse fout in {module_name}: {e} ({parse_time:.3f}s)")
            
            raise
    
    def _validate_input(self,
                       source_code: str,
                       module_name: str,
                       file_path: Optional[str] = None):
        """Valideer input parameters"""
        if not source_code:
            raise ValueError("Broncode mag niet leeg zijn")
        
        if not module_name:
            raise ValueError("Modulenaam mag niet leeg zijn")
        
        if len(source_code.encode('utf-8')) > self.max_file_size:
            raise ValueError(f"Bestand te groot (max {self.max_file_size} bytes)")
        
        if file_path:
            file_path = Path(file_path)
            if not file_path.exists():
                logger.warning(f"Bestand niet gevonden: {file_path}")
    
    def _parse_to_ast(self, source_code: str) -> ast.AST:
        """
        Parse broncode naar AST
        
        Args:
            source_code: Python broncode
            
        Returns:
            AST object
        """
        try:
            # Parse met error handling
            syntax_tree = ast.parse(
                source_code,
                filename='<string>',
                mode='exec'
            )
            
            return syntax_tree
            
        except SyntaxError as e:
            logger.error(f"Syntax error in broncode: {e}")
            raise ValueError(f"Syntax error: {e}")
        except Exception as e:
            logger.error(f"Parse error: {e}")
            raise ValueError(f"Parse error: {e}")
    
    def _extract_metadata(self,
                         syntax_tree: ast.AST,
                         source_code: str,
                         file_path: Optional[str] = None) -> Dict[str, Any]:
        """
        Extraheer metadata uit AST
        
        Args:
            syntax_tree: AST object
            source_code: Originele broncode
            file_path: Pad naar bestand
            
        Returns:
            Metadata dictionary
        """
        metadata = {
            'functions': [],
            'classes': [],
            'imports': [],
            'complexity_score': 0.0,
            'lines_of_code': len(source_code.splitlines()),
            'has_type_hints': False,
            'has_docstrings': False,
            'file_path': str(file_path) if file_path else None
        }
        
        # Visitor class voor het analyseren van de AST
        class MetadataVisitor(ast.NodeVisitor):
            def __init__(self, metadata_dict):
                self.metadata = metadata_dict
                self.complexity_stack = [0]
            
            def visit_FunctionDef(self, node):
                self.metadata['functions'].append(node.name)
                self.generic_visit(node)
            
            def visit_AsyncFunctionDef(self, node):
                self.metadata['functions'].append(node.name)
                self.generic_visit(node)
            
            def visit_ClassDef(self, node):
                self.metadata['classes'].append(node.name)
                self.generic_visit(node)
            
            def visit_Import(self, node):
                for alias in node.names:
                    self.metadata['imports'].append(alias.name)
                self.generic_visit(node)
            
            def visit_ImportFrom(self, node):
                module = node.module or ''
                for alias in node.names:
                    import_name = f"{module}.{alias.name}" if module else alias.name
                    self.metadata['imports'].append(import_name)
                self.generic_visit(node)
            
            def visit_If(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
            
            def visit_For(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
            
            def visit_While(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
            
            def visit_ExceptHandler(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
            
            def visit_With(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
            
            def visit_Try(self, node):
                self.complexity_stack[-1] += 1
                self.generic_visit(node)
        
        # Analyseer de AST
        visitor = MetadataVisitor(metadata)
        visitor.visit(syntax_tree)
        
        # Bereken complexiteitsscore
        metadata['complexity_score'] = max(visitor.complexity_stack) if visitor.complexity_stack else 0
        
        # Controleer op type hints (simpele check)
        if self.enable_type_hints:
            metadata['has_type_hints'] = self._check_type_hints(syntax_tree)
        
        # Controleer op docstrings
        if self.enable_docstrings:
            metadata['has_docstrings'] = self._check_docstrings(syntax_tree)
        
        return metadata
    
    def _check_type_hints(self, syntax_tree: ast.AST) -> bool:
        """Controleer op type hints in de code"""
        has_type_hints = False
        
        class TypeHintVisitor(ast.NodeVisitor):
            def visit_FunctionDef(self, node):
                nonlocal has_type_hints
                if node.returns or any(arg.annotation for arg in node.args.args):
                    has_type_hints = True
                self.generic_visit(node)
            
            def visit_AnnAssign(self, node):
                nonlocal has_type_hints
                has_type_hints = True
                self.generic_visit(node)
        
        visitor = TypeHintVisitor()
        visitor.visit(syntax_tree)
        
        return has_type_hints
    
    def _check_docstrings(self, syntax_tree: ast.AST) -> bool:
        """Controleer op docstrings in de code"""
        has_docstrings = False
        
        class DocstringVisitor(ast.NodeVisitor):
            def visit_FunctionDef(self, node):
                nonlocal has_docstrings
                if (ast.get_docstring(node) and 
                    isinstance(node.body[0], ast.Expr) and 
                    isinstance(node.body[0].value, ast.Constant) and
                    isinstance(node.body[0].value.value, str)):
                    has_docstrings = True
                self.generic_visit(node)
            
            def visit_ClassDef(self, node):
                nonlocal has_docstrings
                if ast.get_docstring(node):
                    has_docstrings = True
                self.generic_visit(node)
        
        visitor = DocstringVisitor()
        visitor.visit(syntax_tree)
        
        return has_docstrings
    
    def _convert_ast_to_dict(self, syntax_tree: ast.AST) -> Dict[str, Any]:
        """
        Converteer AST object naar dictionary
        
        Args:
            syntax_tree: AST object
            
        Returns:
            Dictionary representatie van AST
        """
        def convert_node(node):
            if isinstance(node, ast.AST):
                result = {}
                for field, value in ast.iter_fields(node):
                    if isinstance(value, list):
                        result[field] = [convert_node(item) for item in value]
                    elif isinstance(value, ast.AST):
                        result[field] = convert_node(value)
                    else:
                        result[field] = value
                
                # Voeg node type toe
                result['node_type'] = type(node).__name__
                return result
            elif isinstance(node, list):
                return [convert_item(item) for item in node]
            else:
                return node
        
        def convert_item(item):
            if isinstance(item, ast.AST):
                return convert_node(item)
            return item
        
        return convert_node(syntax_tree)
    
    def _generate_cache_key(self, source_code: str, module_name: str) -> str:
        """Genereer een cache key voor gegeven input"""
        import hashlib
        content = f"{module_name}:{source_code}"
        return hashlib.md5(content.encode('utf-8')).hexdigest()
    
    async def _cleanup_cache(self):
        """Periodieke cleanup van de cache"""
        while True:
            try:
                await asyncio.sleep(300)  # 5 minuten
                
                # Verwijder oude cache entries
                current_time = time.time()
                old_keys = [
                    key for key, result in self.parse_cache.items()
                    if current_time - result.timestamp > 3600  # 1 uur
                ]
                
                for key in old_keys:
                    del self.parse_cache[key]
                
                if old_keys:
                    logger.info(f"Cache opgeschoond: {len(old_keys)} entries verwijderd")
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                logger.error(f"Cache cleanup fout: {e}")
    
    def get_statistics(self) -> Dict[str, Any]:
        """Krijg parser statistieken"""
        stats = self.stats.copy()
        stats.update({
            'cache_size': len(self.parse_cache),
            'max_file_size': self.max_file_size,
            'supported_versions': self.supported_versions
        })
        return stats
    
    def clear_cache(self):
        """Wis de parse cache"""
        self.parse_cache.clear()
        logger.info("Parse cache gewist")
    
    def __str__(self) -> str:
        """String representatie"""
        return f"TRMParser(cache={len(self.parse_cache)}, successful={self.stats['successful_parses']})"
    
    def __repr__(self) -> str:
        """Debug representatie"""
        return f"TRMParser(cache_size={len(self.parse_cache)}, stats={self.stats})"


