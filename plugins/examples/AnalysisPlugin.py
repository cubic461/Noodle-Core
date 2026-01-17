"""
AnalysisPlugin - Code analysis tool plugin for NIP v3.0.0

This plugin demonstrates advanced plugin features:
- Complex tool creation with schemas
- Integration with external libraries (ast, re)
- File processing capabilities
- Result caching
- Detailed error reporting
- Multiple analysis modes
"""

import ast
import re
from pathlib import Path
from typing import List, Dict, Any, Optional
from collections import Counter
from datetime import datetime

from plugins.plugin_base import (
    Plugin, 
    PluginMetadata
)


class AnalysisPlugin(Plugin):
    """
    A code analysis plugin that provides static analysis capabilities.
    
    Features:
    - Python code complexity analysis
    - Code style checking
    - Dependency detection
    - Function/class extraction
    - Import analysis
    """
    
    def __init__(self):
        # Define plugin metadata
        metadata = PluginMetadata(
            name="code_analysis",
            version="1.0.0",
            description="Advanced code analysis and static code review tools",
            author="NIP Development Team",
            plugin_type="tool",
            dependencies=[],
            min_nip_version="3.0.0",
            permissions=["read_files"],
            tags=["analysis", "code", "developer-tools", "static-analysis"],
            homepage="https://github.com/nip/analysis-plugin",
            repository="https://github.com/nip/analysis-plugin",
            license="MIT"
        )
        
        super().__init__(metadata)
        
        # Plugin state
        self.analysis_cache = {}
        self.cache_enabled = True
    
    # ========== Lifecycle Methods ==========
    
    def initialize(self):
        """Initialize the analysis plugin."""
        self.log_info("🔍 AnalysisPlugin initializing...")
        
        # Load configuration
        self.cache_enabled = self.get_config("cache_enabled", True)
        max_cache_size = self.get_config("max_cache_size", 100)
        
        self.log_info(f"Cache enabled: {self.cache_enabled}")
        self.log_info(f"Max cache size: {max_cache_size}")
        
        # Initialize statistics
        self.set_shared_state("analysis_count", 0)
        self.set_shared_state("files_analyzed", set())
        
        self.log_info("✅ AnalysisPlugin ready!")
    
    def cleanup(self):
        """Clean up resources."""
        analysis_count = self.get_shared_state("analysis_count", 0)
        files_analyzed = self.get_shared_state("files_analyzed", set())
        
        self.log_info(f"📊 Total analyses performed: {analysis_count}")
        self.log_info(f"📁 Unique files analyzed: {len(files_analyzed)}")
        
        # Clear cache
        self.analysis_cache.clear()
    
    # ========== Tool Registration ==========
    
    def register_tools(self) -> List[Dict[str, Any]]:
        """Register analysis tools."""
        return [
            {
                "name": "analyze_code",
                "description": "Analyze Python code for complexity, style, and structure",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Python code to analyze"
                        },
                        "file_path": {
                            "type": "string",
                            "description": "Optional file path (for better error reporting)"
                        },
                        "options": {
                            "type": "object",
                            "description": "Analysis options",
                            "properties": {
                                "check_complexity": {"type": "boolean"},
                                "check_style": {"type": "boolean"},
                                "extract_functions": {"type": "boolean"},
                                "extract_classes": {"type": "boolean"},
                                "analyze_imports": {"type": "boolean"}
                            }
                        }
                    },
                    "required": ["code"]
                },
                "function": self.analyze_code
            },
            {
                "name": "analyze_file",
                "description": "Analyze a Python file",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "file_path": {
                            "type": "string",
                            "description": "Path to Python file"
                        },
                        "options": {
                            "type": "object",
                            "description": "Analysis options (same as analyze_code)"
                        }
                    },
                    "required": ["file_path"]
                },
                "function": self.analyze_file
            },
            {
                "name": "find_complexity",
                "description": "Find complexity hotspots in code",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Python code to analyze"
                        },
                        "threshold": {
                            "type": "integer",
                            "description": "Complexity threshold (default: 10)"
                        }
                    },
                    "required": ["code"]
                },
                "function": self.find_complexity
            },
            {
                "name": "extract_dependencies",
                "description": "Extract all dependencies from Python code",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Python code to analyze"
                        }
                    },
                    "required": ["code"]
                },
                "function": self.extract_dependencies
            },
            {
                "name": "code_metrics",
                "description": "Calculate code metrics (lines, functions, classes, etc.)",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "code": {
                            "type": "string",
                            "description": "Python code to analyze"
                        }
                    },
                    "required": ["code"]
                },
                "function": self.code_metrics
            }
        ]
    
    # ========== Tool Implementations ==========
    
    def analyze_code(
        self, 
        code: str, 
        file_path: str = None,
        options: Dict[str, Any] = None
    ) -> Dict[str, Any]:
        """
        Perform comprehensive code analysis.
        
        Args:
            code: Python source code
            file_path: Optional file path
            options: Analysis options
            
        Returns:
            Dictionary with analysis results
        """
        try:
            # Default options
            if options is None:
                options = {}
            
            opts = {
                "check_complexity": options.get("check_complexity", True),
                "check_style": options.get("check_style", True),
                "extract_functions": options.get("extract_functions", True),
                "extract_classes": options.get("extract_classes", True),
                "analyze_imports": options.get("analyze_imports", True)
            }
            
            # Check cache
            cache_key = self._get_cache_key(code, opts)
            if self.cache_enabled and cache_key in self.analysis_cache:
                self.log_debug("Returning cached analysis result")
                return self.analysis_cache[cache_key]
            
            # Parse code
            try:
                tree = ast.parse(code)
            except SyntaxError as e:
                return {
                    "success": False,
                    "error": f"Syntax error: {str(e)}",
                    "line": e.lineno,
                    "offset": e.offset
                }
            
            # Perform analysis
            result = {
                "success": True,
                "file_path": file_path,
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "analysis": {}
            }
            
            # Complexity analysis
            if opts["check_complexity"]:
                result["analysis"]["complexity"] = self._analyze_complexity(tree)
            
            # Style checks
            if opts["check_style"]:
                result["analysis"]["style"] = self._check_style(code)
            
            # Extract functions
            if opts["extract_functions"]:
                result["analysis"]["functions"] = self._extract_functions(tree)
            
            # Extract classes
            if opts["extract_classes"]:
                result["analysis"]["classes"] = self._extract_classes(tree)
            
            # Analyze imports
            if opts["analyze_imports"]:
                result["analysis"]["imports"] = self._analyze_imports(tree)
            
            # Update statistics
            self._update_stats(file_path)
            
            # Cache result
            if self.cache_enabled:
                self.analysis_cache[cache_key] = result
            
            return result
        
        except Exception as e:
            self.log_error(f"Error in analyze_code: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "plugin": "code_analysis"
            }
    
    def analyze_file(self, file_path: str, options: Dict[str, Any] = None) -> Dict[str, Any]:
        """
        Analyze a Python file.
        
        Args:
            file_path: Path to Python file
            options: Analysis options
            
        Returns:
            Dictionary with analysis results
        """
        try:
            path = Path(file_path)
            
            if not path.exists():
                return {
                    "success": False,
                    "error": f"File not found: {file_path}"
                }
            
            if not path.suffix == ".py":
                return {
                    "success": False,
                    "error": f"Not a Python file: {file_path}"
                }
            
            # Read file
            with open(path, 'r', encoding='utf-8') as f:
                code = f.read()
            
            # Analyze
            return self.analyze_code(code, file_path, options)
        
        except Exception as e:
            self.log_error(f"Error in analyze_file: {str(e)}")
            return {
                "success": False,
                "error": str(e),
                "plugin": "code_analysis"
            }
    
    def find_complexity(self, code: str, threshold: int = 10) -> Dict[str, Any]:
        """
        Find complexity hotspots in code.
        
        Args:
            code: Python source code
            threshold: Complexity threshold
            
        Returns:
            Dictionary with complexity hotspots
        """
        try:
            tree = ast.parse(code)
            complexity_data = self._analyze_complexity(tree)
            
            hotspots = []
            for func_name, complexity in complexity_data.get("functions", {}).items():
                if complexity > threshold:
                    hotspots.append({
                        "name": func_name,
                        "complexity": complexity,
                        "severity": "high" if complexity > 20 else "medium"
                    })
            
            # Sort by complexity
            hotspots.sort(key=lambda x: x["complexity"], reverse=True)
            
            return {
                "success": True,
                "threshold": threshold,
                "hotspots": hotspots,
                "total": len(hotspots)
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def extract_dependencies(self, code: str) -> Dict[str, Any]:
        """
        Extract all dependencies from code.
        
        Args:
            code: Python source code
            
        Returns:
            Dictionary with dependencies
        """
        try:
            tree = ast.parse(code)
            imports = self._analyze_imports(tree)
            
            # Categorize dependencies
            stdlib_modules = set()
            external_modules = set()
            local_modules = set()
            
            for imp in imports.get("modules", []):
                module = imp.split(".")[0]
                if self._is_stdlib_module(module):
                    stdlib_modules.add(module)
                else:
                    external_modules.add(module)
            
            return {
                "success": True,
                "stdlib": sorted(stdlib_modules),
                "external": sorted(external_modules),
                "local": sorted(local_modules),
                "total_imports": len(imports.get("imports", []))
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    def code_metrics(self, code: str) -> Dict[str, Any]:
        """
        Calculate code metrics.
        
        Args:
            code: Python source code
            
        Returns:
            Dictionary with metrics
        """
        try:
            lines = code.splitlines()
            
            # Count different types of lines
            total_lines = len(lines)
            code_lines = 0
            comment_lines = 0
            blank_lines = 0
            docstring_lines = 0
            
            in_docstring = False
            
            for line in lines:
                stripped = line.strip()
                
                if not stripped:
                    blank_lines += 1
                elif stripped.startswith("#"):
                    comment_lines += 1
                elif '"""' in stripped or "'''" in stripped:
                    in_docstring = not in_docstring
                    if in_docstring:
                        docstring_lines += 1
                elif in_docstring:
                    docstring_lines += 1
                else:
                    code_lines += 1
            
            # Parse AST for more metrics
            tree = ast.parse(code)
            
            functions = []
            classes = []
            
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    functions.append(node.name)
                elif isinstance(node, ast.ClassDef):
                    classes.append(node.name)
            
            return {
                "success": True,
                "metrics": {
                    "total_lines": total_lines,
                    "code_lines": code_lines,
                    "comment_lines": comment_lines,
                    "blank_lines": blank_lines,
                    "docstring_lines": docstring_lines,
                    "function_count": len(functions),
                    "class_count": len(classes),
                    "functions": functions,
                    "classes": classes
                }
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }
    
    # ========== Helper Methods ==========
    
    def _analyze_complexity(self, tree: ast.AST) -> Dict[str, Any]:
        """Analyze cyclomatic complexity."""
        class ComplexityVisitor(ast.NodeVisitor):
            def __init__(self):
                self.function_complexity = {}
                self.current_complexity = 1
            
            def visit_FunctionDef(self, node):
                self.current_complexity = 1
                self.generic_visit(node)
                self.function_complexity[node.name] = self.current_complexity
            
            def visit_If(self, node):
                self.current_complexity += 1
                self.generic_visit(node)
            
            def visit_For(self, node):
                self.current_complexity += 1
                self.generic_visit(node)
            
            def visit_While(self, node):
                self.current_complexity += 1
                self.generic_visit(node)
            
            def visit_With(self, node):
                self.current_complexity += 1
                self.generic_visit(node)
            
            def visit_Try(self, node):
                self.current_complexity += len(node.handlers)
                self.generic_visit(node)
        
        visitor = ComplexityVisitor()
        visitor.visit(tree)
        
        return {
            "functions": visitor.function_complexity,
            "max_complexity": max(visitor.function_complexity.values()) if visitor.function_complexity else 0,
            "avg_complexity": sum(visitor.function_complexity.values()) / len(visitor.function_complexity) if visitor.function_complexity else 0
        }
    
    def _check_style(self, code: str) -> Dict[str, Any]:
        """Check code style issues."""
        issues = []
        
        lines = code.splitlines()
        
        for i, line in enumerate(lines, 1):
            # Check line length
            if len(line) > 100:
                issues.append({
                    "line": i,
                    "type": "line_too_long",
                    "message": f"Line exceeds 100 characters ({len(line)} chars)"
                })
            
            # Check for trailing whitespace
            if line.rstrip() != line:
                issues.append({
                    "line": i,
                    "type": "trailing_whitespace",
                    "message": "Trailing whitespace"
                })
        
        return {
            "issues": issues,
            "total_issues": len(issues)
        }
    
    def _extract_functions(self, tree: ast.AST) -> List[Dict[str, Any]]:
        """Extract function information."""
        functions = []
        
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                args = [arg.arg for arg in node.args.args]
                functions.append({
                    "name": node.name,
                    "lineno": node.lineno,
                    "args": args,
                    "docstring": ast.get_docstring(node),
                    "is_async": isinstance(node, ast.AsyncFunctionDef)
                })
        
        return functions
    
    def _extract_classes(self, tree: ast.AST) -> List[Dict[str, Any]]:
        """Extract class information."""
        classes = []
        
        for node in ast.walk(tree):
            if isinstance(node, ast.ClassDef):
                bases = [self._get_name(base) for base in node.bases]
                methods = [
                    n.name for n in node.body 
                    if isinstance(n, ast.FunctionDef)
                ]
                classes.append({
                    "name": node.name,
                    "lineno": node.lineno,
                    "bases": bases,
                    "methods": methods,
                    "docstring": ast.get_docstring(node)
                })
        
        return classes
    
    def _analyze_imports(self, tree: ast.AST) -> Dict[str, Any]:
        """Analyze imports."""
        imports = []
        modules = set()
        
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.append({
                        "type": "import",
                        "module": alias.name,
                        "alias": alias.asname
                    })
                    modules.add(alias.name.split(".")[0])
            
            elif isinstance(node, ast.ImportFrom):
                module = node.module or ""
                imports.append({
                    "type": "from_import",
                    "module": module,
                    "names": [alias.name for alias in node.names]
                })
                if module:
                    modules.add(module.split(".")[0])
        
        return {
            "imports": imports,
            "modules": sorted(modules)
        }
    
    def _get_name(self, node: ast.AST) -> str:
        """Get name from AST node."""
        if isinstance(node, ast.Name):
            return node.id
        elif isinstance(node, ast.Attribute):
            return f"{self._get_name(node.value)}.{node.attr}"
        return ""
    
    def _is_stdlib_module(self, module_name: str) -> bool:
        """Check if module is from standard library."""
        stdlib = {
            "os", "sys", "re", "json", "datetime", "collections",
            "itertools", "functools", "pathlib", "typing", "math",
            "random", "string", "time", "hashlib", "logging"
        }
        return module_name in stdlib
    
    def _get_cache_key(self, code: str, options: Dict[str, Any]) -> str:
        """Generate cache key."""
        import hashlib
        content = code + str(sorted(options.items()))
        return hashlib.md5(content.encode()).hexdigest()
    
    def _update_stats(self, file_path: Optional[str]):
        """Update analysis statistics."""
        count = self.get_shared_state("analysis_count", 0)
        self.set_shared_state("analysis_count", count + 1)
        
        if file_path:
            files = self.get_shared_state("files_analyzed", set())
            files.add(file_path)
            self.set_shared_state("files_analyzed", files)


# Plugin factory
def create_plugin() -> AnalysisPlugin:
    """Factory function to create the plugin instance."""
    return AnalysisPlugin()


# Allow direct execution for testing
if __name__ == "__main__":
    print("AnalysisPlugin - NIP v3.0.0")
    print("=" * 50)
    
    plugin = AnalysisPlugin()
    plugin.initialize()
    
    # Test code
    test_code = '''
def fibonacci(n):
    """Calculate fibonacci numbers."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

class Calculator:
    def add(self, a, b):
        return a + b
    
    def subtract(self, a, b):
        return a - b
'''
    
    print("\nTesting analyze_code:")
    result = plugin.analyze_code(test_code)
    print(f"Success: {result['success']}")
    if result['success']:
        print(f"Functions: {len(result['analysis']['functions'])}")
        print(f"Classes: {len(result['analysis']['classes'])}")
    
    print("\nTesting code_metrics:")
    metrics = plugin.code_metrics(test_code)
    print(f"Metrics: {metrics}")
    
    print("\nTesting find_complexity:")
    complexity = plugin.find_complexity(test_code, threshold=1)
    print(f"Complexity hotspots: {complexity}")
    
    plugin.cleanup()
    print("\n✅ Tests completed!")
