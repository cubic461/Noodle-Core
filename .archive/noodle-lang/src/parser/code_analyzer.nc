#!/usr/bin/env python3
"""
Code Analyzer Module
====================

This module provides real-time code analysis during execution, including
syntax checking, semantic analysis, and execution state monitoring.

Author: NoodleCore Development Team
Version: 1.0.0
"""

import ast
import re
import time
import uuid
import logging
from typing import Dict, List, Optional, Any, Tuple, Set
from dataclasses import dataclass, asdict
from datetime import datetime
from pathlib import Path
import keyword

# Configure logging
logger = logging.getLogger(__name__)


@dataclass
class CodeAnalysisResult:
    """Result of code analysis."""
    script_id: str
    is_valid: bool
    syntax_errors: List[str] = None
    semantic_warnings: List[str] = None
    security_issues: List[str] = None
    performance_hints: List[str] = None
    code_quality_score: float = 0.0
    complexity_metrics: Dict[str, float] = None
    variable_analysis: Dict[str, Any] = None
    function_analysis: Dict[str, Any] = None
    import_analysis: Dict[str, Any] = None
    execution_readiness: bool = True
    
    def __post_init__(self):
        if self.syntax_errors is None:
            self.syntax_errors = []
        if self.semantic_warnings is None:
            self.semantic_warnings = []
        if self.security_issues is None:
            self.security_issues = []
        if self.performance_hints is None:
            self.performance_hints = []
        if self.complexity_metrics is None:
            self.complexity_metrics = {}
        if self.variable_analysis is None:
            self.variable_analysis = {}
        if self.function_analysis is None:
            self.function_analysis = {}
        if self.import_analysis is None:
            self.import_analysis = {}


@dataclass
class AnalysisContext:
    """Context for code analysis."""
    analysis_id: str
    script_id: str
    code: str
    language: str = "python"
    analysis_depth: str = "full"  # "basic", "full", "deep"
    include_security: bool = True
    include_performance: bool = True
    include_quality: bool = True
    
    def __post_init__(self):
        if not self.analysis_id:
            self.analysis_id = str(uuid.uuid4())


@dataclass
class ExecutionState:
    """Current execution state during analysis."""
    script_id: str
    line_number: int
    active_functions: List[str] = None
    active_variables: List[str] = None
    execution_context: Dict[str, Any] = None
    error_state: Optional[str] = None
    
    def __post_init__(self):
        if self.active_functions is None:
            self.active_functions = []
        if self.active_variables is None:
            self.active_variables = []
        if self.execution_context is None:
            self.execution_context = {}


class SyntaxAnalyzer:
    """Analyzes Python code syntax."""
    
    def __init__(self):
        self.python_keywords = set(keyword.kwlist)
        self.builtin_functions = set(dir(__builtins__))
    
    def analyze_syntax(self, code: str) -> Tuple[bool, List[str]]:
        """Analyze Python code syntax."""
        
        errors = []
        
        try:
            # Parse the code
            tree = ast.parse(code)
            
            # Perform additional syntax checks
            errors.extend(self._check_import_statements(code))
            errors.extend(self._check_function_definitions(code))
            errors.extend(self._check_class_definitions(code))
            
            return len(errors) == 0, errors
            
        except SyntaxError as e:
            return False, [f"Syntax Error: {e.msg} at line {e.lineno}"]
        except Exception as e:
            return False, [f"Parse Error: {str(e)}"]
    
    def _check_import_statements(self, code: str) -> List[str]:
        """Check import statements for issues."""
        
        errors = []
        import_patterns = [
            r'^import\s+(\w+)',
            r'^from\s+(\w+)\s+import'
        ]
        
        lines = code.split('\n')
        for i, line in enumerate(lines, 1):
            line = line.strip()
            if line.startswith('import ') or line.startswith('from '):
                # Check for suspicious imports
                for pattern in import_patterns:
                    match = re.search(pattern, line)
                    if match:
                        module = match.group(1)
                        if self._is_suspicious_module(module):
                            errors.append(f"Line {i}: Suspicious import '{module}'")
        
        return errors
    
    def _check_function_definitions(self, code: str) -> List[str]:
        """Check function definitions for issues."""
        
        errors = []
        
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    # Check for function name conflicts
                    if node.name in self.python_keywords:
                        errors.append(f"Line {node.lineno}: Function name '{node.name}' conflicts with Python keyword")
                    
                    # Check for too many parameters
                    if len(node.args.args) > 10:
                        errors.append(f"Line {node.lineno}: Function '{node.name}' has too many parameters ({len(node.args.args)})")
                    
                    # Check for missing docstring
                    if not ast.get_docstring(node):
                        errors.append(f"Line {node.lineno}: Function '{node.name}' missing docstring")
        
        except Exception as e:
            errors.append(f"Error analyzing function definitions: {str(e)}")
        
        return errors
    
    def _check_class_definitions(self, code: str) -> List[str]:
        """Check class definitions for issues."""
        
        errors = []
        
        try:
            tree = ast.parse(code)
            for node in ast.walk(tree):
                if isinstance(node, ast.ClassDef):
                    # Check class naming
                    if not re.match(r'^[A-Z][a-zA-Z0-9]*$', node.name):
                        errors.append(f"Line {node.lineno}: Class name '{node.name}' should follow PascalCase convention")
                    
                    # Check for missing docstring
                    if not ast.get_docstring(node):
                        errors.append(f"Line {node.lineno}: Class '{node.name}' missing docstring")
        
        except Exception as e:
            errors.append(f"Error analyzing class definitions: {str(e)}")
        
        return errors
    
    def _is_suspicious_module(self, module: str) -> bool:
        """Check if module might be suspicious."""
        
        suspicious_modules = {
            'os', 'sys', 'subprocess', 'eval', 'exec', 'compile',
            '__import__', 'open', 'file', 'input', 'raw_input'
        }
        
        return module in suspicious_modules


class SecurityAnalyzer:
    """Analyzes code for security vulnerabilities."""
    
    def __init__(self):
        self.dangerous_functions = {
            'eval', 'exec', 'compile', 'os.system', 'os.popen',
            'subprocess.call', 'subprocess.run', 'subprocess.Popen',
            'pickle.load', 'pickle.loads', 'marshal.load'
        }
        
        self.sql_injection_patterns = [
            r'execute\s*\(\s*["\'].*%.*["\'].*\)',
            r'cursor\.execute\s*\(\s*["\'].*%.*["\'].*\)',
            r'Query\s*\(\s*["\'].*%.*["\'].*\)'
        ]
        
        self.xss_patterns = [
            r'render_template_string\s*\(',
            r'print\s*\([^)]*request\.',
            r'HttpResponse\s*\([^)]*request\.'
        ]
    
    def analyze_security(self, code: str) -> List[str]:
        """Analyze code for security issues."""
        
        issues = []
        
        # Check for dangerous function calls
        issues.extend(self._check_dangerous_functions(code))
        
        # Check for SQL injection patterns
        issues.extend(self._check_sql_injection(code))
        
        # Check for XSS vulnerabilities
        issues.extend(self._check_xss_vulnerabilities(code))
        
        # Check for hardcoded secrets
        issues.extend(self._check_hardcoded_secrets(code))
        
        # Check for path traversal vulnerabilities
        issues.extend(self._check_path_traversal(code))
        
        return issues
    
    def _check_dangerous_functions(self, code: str) -> List[str]:
        """Check for dangerous function calls."""
        
        issues = []
        lines = code.split('\n')
        
        for i, line in enumerate(lines, 1):
            for dangerous_func in self.dangerous_functions:
                if dangerous_func in line and not line.strip().startswith('#'):
                    issues.append(f"Line {i}: Dangerous function '{dangerous_func}' detected")
        
        return issues
    
    def _check_sql_injection(self, code: str) -> List[str]:
        """Check for SQL injection vulnerabilities."""
        
        issues = []
        
        for pattern in self.sql_injection_patterns:
            matches = re.finditer(pattern, code, re.IGNORECASE)
            for match in matches:
                line_num = code[:match.start()].count('\n') + 1
                issues.append(f"Line {line_num}: Potential SQL injection vulnerability")
        
        return issues
    
    def _check_xss_vulnerabilities(self, code: str) -> List[str]:
        """Check for XSS vulnerabilities."""
        
        issues = []
        
        for pattern in self.xss_patterns:
            matches = re.finditer(pattern, code, re.IGNORECASE)
            for match in matches:
                line_num = code[:match.start()].count('\n') + 1
                issues.append(f"Line {line_num}: Potential XSS vulnerability")
        
        return issues
    
    def _check_hardcoded_secrets(self, code: str) -> List[str]:
        """Check for hardcoded secrets."""
        
        issues = []
        lines = code.split('\n')
        
        secret_patterns = [
            r'password\s*=\s*["\'][^"\']+["\']',
            r'api_key\s*=\s*["\'][^"\']+["\']',
            r'secret\s*=\s*["\'][^"\']+["\']',
            r'token\s*=\s*["\'][^"\']+["\']'
        ]
        
        for i, line in enumerate(lines, 1):
            for pattern in secret_patterns:
                if re.search(pattern, line, re.IGNORECASE):
                    issues.append(f"Line {i}: Potential hardcoded secret detected")
        
        return issues
    
    def _check_path_traversal(self, code: str) -> List[str]:
        """Check for path traversal vulnerabilities."""
        
        issues = []
        lines = code.split('\n')
        
        traversal_patterns = [
            r'open\s*\([^)]*\.\.\/',
            r'file\s*\([^)]*\.\.\/',
            r'os\.path\.join\s*\([^)]*\.\.\/'
        ]
        
        for i, line in enumerate(lines, 1):
            for pattern in traversal_patterns:
                if re.search(pattern, line):
                    issues.append(f"Line {i}: Potential path traversal vulnerability")
        
        return issues


class ComplexityAnalyzer:
    """Analyzes code complexity and metrics."""
    
    def __init__(self):
        pass
    
    def analyze_complexity(self, code: str) -> Dict[str, float]:
        """Analyze code complexity and return metrics."""
        
        try:
            tree = ast.parse(code)
            metrics = {}
            
            # Calculate cyclomatic complexity
            metrics['cyclomatic_complexity'] = self._calculate_cyclomatic_complexity(tree)
            
            # Calculate nesting depth
            metrics['max_nesting_depth'] = self._calculate_nesting_depth(tree)
            
            # Calculate lines of code
            lines = [line for line in code.split('\n') if line.strip()]
            metrics['lines_of_code'] = len(lines)
            
            # Calculate comment ratio
            comment_lines = [line for line in code.split('\n') if line.strip().startswith('#')]
            metrics['comment_ratio'] = len(comment_lines) / len(lines) if lines else 0
            
            # Calculate function count
            metrics['function_count'] = len([node for node in ast.walk(tree) if isinstance(node, ast.FunctionDef)])
            
            # Calculate class count
            metrics['class_count'] = len([node for node in ast.walk(tree) if isinstance(node, ast.ClassDef)])
            
            # Calculate average function length
            function_lengths = []
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    func_lines = node.end_lineno - node.lineno + 1 if node.end_lineno else 0
                    function_lengths.append(func_lines)
            
            metrics['average_function_length'] = sum(function_lengths) / len(function_lengths) if function_lengths else 0
            
            return metrics
            
        except Exception as e:
            logger.error(f"Complexity analysis failed: {e}")
            return {'error': str(e)}
    
    def _calculate_cyclomatic_complexity(self, tree: ast.AST) -> float:
        """Calculate cyclomatic complexity."""
        
        complexity = 1  # Base complexity
        
        for node in ast.walk(tree):
            if isinstance(node, (ast.If, ast.While, ast.For, ast.With, ast.Try, ast.ExceptHandler)):
                complexity += 1
            elif isinstance(node, ast.BoolOp):
                complexity += len(node.values) - 1
        
        return complexity
    
    def _calculate_nesting_depth(self, tree: ast.AST) -> float:
        """Calculate maximum nesting depth."""
        
        max_depth = 0
        current_depth = 0
        
        def traverse(node, depth):
            nonlocal max_depth, current_depth
            max_depth = max(max_depth, depth)
            
            for child in ast.iter_child_nodes(node):
                traverse(child, depth + 1)
        
        traverse(tree, 0)
        return max_depth


class PerformanceAnalyzer:
    """Analyzes code for performance issues."""
    
    def __init__(self):
        self.performance_patterns = {
            'inefficient_loop': r'for\s+\w+\s+in\s+range\(len\(',
            'string_concatenation_loop': r'\w+\s*\+=\s*["\']',
            'inefficient_search': r'\w+\.index\(',
            'repeated_calculation': r'math\.\w+\(',
            'list_comprehension_missing': r'\[.*for.*in.*\]'
        }
    
    def analyze_performance(self, code: str) -> List[str]:
        """Analyze code for performance issues."""
        
        hints = []
        
        # Check for inefficient patterns
        hints.extend(self._check_inefficient_patterns(code))
        
        # Check for missing optimizations
        hints.extend(self._check_missing_optimizations(code))
        
        # Check for memory issues
        hints.extend(self._check_memory_issues(code))
        
        return hints
    
    def _check_inefficient_patterns(self, code: str) -> List[str]:
        """Check for inefficient coding patterns."""
        
        hints = []
        lines = code.split('\n')
        
        for i, line in enumerate(lines, 1):
            line = line.strip()
            
            # Check for range(len()) pattern
            if re.search(r'for\s+\w+\s+in\s+range\(len\(', line):
                hints.append(f"Line {i}: Use enumerate() instead of range(len())")
            
            # Check for string concatenation in loop
            if re.search(r'\w+\s*\+=\s*["\']', line):
                hints.append(f"Line {i}: Consider using list.append() and ''.join() for string concatenation")
            
            # Check for repeated calculations
            if 'math.' in line and 'sin' in line or 'cos' in line:
                hints.append(f"Line {i}: Cache expensive calculations outside loops")
        
        return hints
    
    def _check_missing_optimizations(self, code: str) -> List[str]:
        """Check for missing optimizations."""
        
        hints = []
        
        # Check if loops could use list comprehensions
        if re.search(r'for\s+\w+\s+in\s+\w+:', code) and 'if' in code:
            hints.append("Consider using list comprehension for better performance")
        
        return hints
    
    def _check_memory_issues(self, code: str) -> List[str]:
        """Check for potential memory issues."""
        
        hints = []
        lines = code.split('\n')
        
        for i, line in enumerate(lines, 1):
            # Check for large data structures
            if 'list(' in line and 'range(' in line:
                hints.append(f"Line {i}: Consider using generator expression instead of list(range())")
        
        return hints


class CodeAnalyzer:
    """Main code analyzer that orchestrates all analysis components."""
    
    def __init__(self):
        self.syntax_analyzer = SyntaxAnalyzer()
        self.security_analyzer = SecurityAnalyzer()
        self.complexity_analyzer = ComplexityAnalyzer()
        self.performance_analyzer = PerformanceAnalyzer()
        
    def analyze_code(self, context: AnalysisContext) -> CodeAnalysisResult:
        """Perform comprehensive code analysis."""
        
        logger.info(f"Starting analysis for script {context.script_id}")
        
        try:
            # Initialize result
            result = CodeAnalysisResult(script_id=context.script_id)
            
            # Syntax analysis
            if context.analysis_depth in ['basic', 'full', 'deep']:
                is_valid, syntax_errors = self.syntax_analyzer.analyze_syntax(context.code)
                result.is_valid = is_valid
                result.syntax_errors = syntax_errors
                result.execution_readiness = is_valid and len(syntax_errors) == 0
            
            # Security analysis
            if context.include_security and result.is_valid:
                result.security_issues = self.security_analyzer.analyze_security(context.code)
            
            # Complexity analysis
            if context.analysis_depth in ['full', 'deep']:
                result.complexity_metrics = self.complexity_analyzer.analyze_complexity(context.code)
                result.code_quality_score = self._calculate_quality_score(result)
            
            # Performance analysis
            if context.include_performance and result.is_valid:
                result.performance_hints = self.performance_analyzer.analyze_performance(context.code)
            
            # Variable and function analysis
            if context.analysis_depth in ['full', 'deep']:
                result.variable_analysis = self._analyze_variables(context.code)
                result.function_analysis = self._analyze_functions(context.code)
                result.import_analysis = self._analyze_imports(context.code)
            
            # Semantic warnings
            result.semantic_warnings = self._generate_semantic_warnings(context.code)
            
            logger.info(f"Analysis completed for script {context.script_id}, quality score: {result.code_quality_score}")
            
            return result
            
        except Exception as e:
            logger.error(f"Code analysis failed: {e}")
            return CodeAnalysisResult(
                script_id=context.script_id,
                is_valid=False,
                syntax_errors=[f"Analysis failed: {str(e)}"],
                execution_readiness=False
            )
    
    def analyze_execution_state(self, script_id: str, code: str, 
                               current_line: int, execution_context: Dict[str, Any]) -> ExecutionState:
        """Analyze current execution state."""
        
        try:
            # Parse code to get current context
            tree = ast.parse(code)
            
            # Find active functions and variables at current line
            active_functions = []
            active_variables = []
            
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    if node.lineno <= current_line <= (node.end_lineno or node.lineno + 20):
                        active_functions.append(node.name)
            
            return ExecutionState(
                script_id=script_id,
                line_number=current_line,
                active_functions=active_functions,
                active_variables=active_variables,
                execution_context=execution_context
            )
            
        except Exception as e:
            logger.error(f"Execution state analysis failed: {e}")
            return ExecutionState(
                script_id=script_id,
                line_number=current_line,
                error_state=str(e)
            )
    
    def _analyze_variables(self, code: str) -> Dict[str, Any]:
        """Analyze variable usage in code."""
        
        try:
            tree = ast.parse(code)
            variables = {}
            
            for node in ast.walk(tree):
                if isinstance(node, ast.Assign):
                    for target in node.targets:
                        if isinstance(target, ast.Name):
                            var_name = target.id
                            if var_name not in variables:
                                variables[var_name] = {
                                    'defined_line': node.lineno,
                                    'usage_count': 0,
                                    'is_global': False,
                                    'assignments': []
                                }
                            variables[var_name]['assignments'].append({
                                'line': node.lineno,
                                'value_type': type(node.value).__name__
                            })
            
            # Count usages
            for node in ast.walk(tree):
                if isinstance(node, ast.Name) and isinstance(node.ctx, ast.Load):
                    var_name = node.id
                    if var_name in variables:
                        variables[var_name]['usage_count'] += 1
            
            return variables
            
        except Exception as e:
            return {'error': str(e)}
    
    def _analyze_functions(self, code: str) -> Dict[str, Any]:
        """Analyze function definitions and calls."""
        
        try:
            tree = ast.parse(code)
            functions = {}
            
            for node in ast.walk(tree):
                if isinstance(node, ast.FunctionDef):
                    functions[node.name] = {
                        'line': node.lineno,
                        'parameters': [arg.arg for arg in node.args.args],
                        'calls_count': 0,
                        'is_recursive': False,
                        'docstring': ast.get_docstring(node)
                    }
            
            # Count function calls and detect recursion
            for node in ast.walk(tree):
                if isinstance(node, ast.Call) and isinstance(node.func, ast.Name):
                    func_name = node.func.id
                    if func_name in functions:
                        functions[func_name]['calls_count'] += 1
                        if func_name in [f.name for f in ast.walk(tree) if isinstance(f, ast.FunctionDef)]:
                            functions[func_name]['is_recursive'] = True
            
            return functions
            
        except Exception as e:
            return {'error': str(e)}
    
    def _analyze_imports(self, code: str) -> Dict[str, Any]:
        """Analyze import statements."""
        
        imports = {
            'standard_imports': [],
            'third_party_imports': [],
            'local_imports': [],
            'unused_imports': [],
            'circular_imports': []
        }
        
        try:
            tree = ast.parse(code)
            import_nodes = []
            
            for node in ast.walk(tree):
                if isinstance(node, (ast.Import, ast.ImportFrom)):
                    import_nodes.append(node)
            
            for node in import_nodes:
                if isinstance(node, ast.Import):
                    for alias in node.names:
                        imports['standard_imports'].append(alias.name)
                elif isinstance(node, ast.ImportFrom):
                    module = node.module or ''
                    imports['standard_imports'].append(module)
            
            return imports
            
        except Exception as e:
            return {'error': str(e)}
    
    def _generate_semantic_warnings(self, code: str) -> List[str]:
        """Generate semantic warnings."""
        
        warnings = []
        lines = code.split('\n')
        
        for i, line in enumerate(lines, 1):
            line = line.strip()
            
            # Check for undefined variables (basic check)
            if re.search(r'\bprint\([^)]*\w+[^)]*\)', line) and 'Hello' not in line:
                warnings.append(f"Line {i}: Consider adding error handling for print statements")
            
            # Check for missing exception handling
            if 'open(' in line and 'with' not in line:
                warnings.append(f"Line {i}: Consider using 'with' statement for file operations")
            
            # Check for missing type hints in functions
            if line.startswith('def ') and ':' in line and '->' not in line:
                warnings.append(f"Line {i}: Consider adding type hints for better code clarity")
        
        return warnings
    
    def _calculate_quality_score(self, result: CodeAnalysisResult) -> float:
        """Calculate overall code quality score."""
        
        if not result.complexity_metrics:
            return 0.0
        
        score = 100.0
        
        # Deduct for syntax errors
        score -= len(result.syntax_errors) * 20
        
        # Deduct for security issues
        score -= len(result.security_issues) * 15
        
        # Deduct for complexity issues
        cyclomatic = result.complexity_metrics.get('cyclomatic_complexity', 0)
        if cyclomatic > 10:
            score -= (cyclomatic - 10) * 2
        
        # Deduct for performance issues
        score -= len(result.performance_hints) * 5
        
        # Deduct for semantic warnings
        score -= len(result.semantic_warnings) * 3
        
        return max(0.0, score)
    
    def get_analysis_statistics(self) -> Dict[str, Any]:
        """Get analysis engine statistics."""
        
        return {
            "analysis_components": [
                "Syntax Analysis", "Security Analysis", "Complexity Analysis", 
                "Performance Analysis", "Variable Analysis", "Function Analysis"
            ],
            "supported_languages": ["python"],
            "security_checks": len(self.security_analyzer.dangerous_functions),
            "performance_patterns": len(self.performance_analyzer.performance_patterns),
            "max_complexity_threshold": 20,
            "quality_score_range": [0, 100]
        }


# Factory function
def create_code_analyzer() -> CodeAnalyzer:
    """Create a new CodeAnalyzer instance."""
    return CodeAnalyzer()


# Global instance
_code_analyzer = None

def get_code_analyzer() -> CodeAnalyzer:
    """Get the global code analyzer instance."""
    global _code_analyzer
    if _code_analyzer is None:
        _code_analyzer = create_code_analyzer()
    return _code_analyzer