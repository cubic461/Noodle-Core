#!/usr/bin/env python3
"""
Scripts::Dependency Analyzer Advanced - dependency_analyzer_advanced.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Advanced Dependency Analysis Module

This module provides comprehensive dependency analysis capabilities for the NoodleCore
reorganization project, including AST-based import analysis, dependency graph construction,
and circular dependency detection.

Author: NoodleCore Reorganization Team
Version: 1.0.0
Date: 2025-10-23
"""

import ast
import logging
import os
import re
from pathlib import Path
from typing import Optional, Any
from dataclasses import dataclass, field
from enum import Enum
from collections import defaultdict
import networkx as nx

# Configure logging
logger = logging.getLogger(__name__)


class DependencyType(Enum):
    """Enumeration of dependency types"""
    INTERNAL = "internal"
    EXTERNAL = "external"
    STANDARD = "standard"
    RELATIVE = "relative"
    DYNAMIC = "dynamic"


class DependencyStrength(Enum):
    """Enumeration of dependency strength levels"""
    WEAK = 1      # Optional imports, type hints only
    MEDIUM = 2    # Runtime imports with try/except
    STRONG = 3    # Required imports at module level


@dataclass
class Dependency:
    """Data class representing a dependency relationship"""
    source_file: str
    target_module: str
    dependency_type: DependencyType
    strength: DependencyStrength
    line_number: Optional[int] = None
    import_type: Optional[str] = None  # "import", "from", "try/except", etc.
    is_conditional: bool = False
    alias: Optional[str] = None


@dataclass
class DependencyAnalysisResult:
    """Data class containing dependency analysis results"""
    file_path: str
    dependencies: list[Dependency] = field(default_factory=list)
    dependents: list[str] = field(default_factory=list)  # Files that depend on this file
    circular_dependencies: list[list[str]] = field(default_factory=list)
    dependency_level: int = 0  # Level in dependency hierarchy
    complexity_score: float = 0.0
    risk_score: float = 0.0


class PythonDependencyAnalyzer:
    """Analyzer for Python file dependencies"""

    def __init__(self, project_root: Path):
        """
        Initialize the Python dependency analyzer

        Args:
            project_root: Root path of the project
        """
        self.project_root = project_root
        self.standard_library_modules = self._load_standard_library_modules()
        self.internal_module_prefixes = ["noodlecore", "noodle"]

        # Patterns for different import types
        self.import_patterns = {
            "standard_import": re.compile(r'^import\s+([\w\.]+)'),
            "from_import": re.compile(r'^from\s+([\w\.]+)\s+import'),
            "try_import": re.compile(r'try:\s*\n\s*import\s+([\w\.]+)'),
            "conditional_import": re.compile(r'if\s+.*:\s*\n\s*import\s+([\w\.]+)'),
            "dynamic_import": re.compile(r'__import__\s*\(\s*[\'"]([^\'"]+)[\'"]'),
            "importlib_import": re.compile(r'importlib\.import_module\(\s*[\'"]([^\'"]+)[\'"]')
        }

    def _load_standard_library_modules(self) -> set[str]:
        """Load a set of standard library module names"""
        # This is a simplified list - in practice, you'd use a more comprehensive approach
        return {
            "abc", "aifc", "argparse", "array", "ast", "asynchat", "asyncio",
            "asyncore", "atexit", "audioop", "base64", "bdb", "binascii",
            "bisect", "builtins", "bz2", "cProfile", "calendar", "cgi",
            "cgitb", "chunk", "cmath", "cmd", "code", "codecs", "codeop",
            "collections", "colorsys", "compileall", "concurrent", "configparser",
            "contextlib", "contextvars", "copy", "copyreg", "crypt", "csv",
            "ctypes", "curses", "dataclasses", "datetime", "dbm", "decimal",
            "difflib", "dis", "distutils", "doctest", "email", "encodings",
            "enum", "errno", "faulthandler", "fcntl", "filecmp", "fileinput",
            "fnmatch", "formatter", "fractions", "ftplib", "functools",
            "gc", "getopt", "getpass", "gettext", "glob", "grp", "gzip",
            "hashlib", "heapq", "hmac", "html", "http", "imaplib", "imghdr",
            "imp", "importlib", "inspect", "io", "ipaddress", "itertools",
            "json", "keyword", "linecache", "locale", "logging", "lzma",
            "mailbox", "mailcap", "marshal", "math", "mimetypes", "mmap",
            "modulefinder", "multiprocessing", "netrc", "nntplib", "numbers",
            "operator", "os", "ossaudiodev", "pathlib", "pdb", "pickle",
            "pickletools", "pipes", "pkgutil", "platform", "plistlib",
            "poplib", "posix", "pprint", "profile", "pstats", "pty",
            "pwd", "py_compile", "pyclbr", "pydoc", "pyexpat", "queue",
            "quopri", "random", "re", "readline", "reprlib", "resource",
            "rlcompleter", "runpy", "sched", "secrets", "select", "selectors",
            "shelve", "shlex", "shutil", "signal", "site", "smtpd", "smtplib",
            "sndhdr", "socket", "socketserver", "sqlite3", "sre", "sre_compile",
            "sre_constants", "sre_parse", "ssl", "stat", "statistics",
            "string", "stringprep", "struct", "subprocess", "sunau", "symbol",
            "symtable", "sys", "sysconfig", "syslog", "tabnanny", "tarfile",
            "telnetlib", "tempfile", "termios", "textwrap", "threading",
            "time", "timeit", "tkinter", "token", "tokenize", "trace",
            "traceback", "tracemalloc", "tty", "turtle", "types", "typing",
            "unicodedata", "unittest", "urllib", "uu", "uuid", "venv",
            "warnings", "wave", "weakref", "webbrowser", "winreg", "winsound",
            "wsgiref", "xdrlib", "xml", "xmlrpc", "zipapp", "zipfile",
            "zipimport", "zlib"
        }

    def analyze_file(self, file_path: Path) -> DependencyAnalysisResult:
        """
        Analyze dependencies of a Python file

        Args:
            file_path: Path to the Python file to analyze

        Returns:
            DependencyAnalysisResult with detailed dependency information
        """
        try:
            with open(file_path, encoding='utf-8') as f:
                content = f.read()

            # Parse AST
            tree = ast.parse(content)

            # Extract dependencies
            dependencies = self._extract_dependencies(tree, content, file_path)

            # Calculate metrics
            complexity_score = self._calculate_complexity_score(dependencies)
            risk_score = self._calculate_risk_score(dependencies, file_path)

            return DependencyAnalysisResult(
                file_path=str(file_path),
                dependencies=dependencies,
                complexity_score=complexity_score,
                risk_score=risk_score
            )

        except Exception as e:
            logger.error(f"Error analyzing dependencies for {file_path}: {e}")
            return DependencyAnalysisResult(file_path=str(file_path))

    def _extract_dependencies(
        self,
        tree: ast.AST,
        content: str,
        file_path: Path
    ) -> list[Dependency]:
        """Extract dependencies from AST and content"""
        dependencies = []
        lines = content.split('\n')

        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    dep = self._create_dependency(
                        source_file=str(file_path),
                        target_module=alias.name,
                        line_number=node.lineno,
                        import_type="import",
                        alias=alias.asname
                    )
                    dependencies.append(dep)

            elif isinstance(node, ast.ImportFrom):
                module = node.module or ""
                for alias in node.names:
                    full_module = f"{module}.{alias.name}" if module else alias.name
                    dep = self._create_dependency(
                        source_file=str(file_path),
                        target_module=full_module,
                        line_number=node.lineno,
                        import_type="from",
                        alias=alias.asname
                    )
                    dependencies.append(dep)

            elif isinstance(node, ast.Call):
                # Check for dynamic imports
                if (isinstance(node.func, ast.Name) and
                    node.func.id in ["__import__", "import_module"]):
                    if node.args and isinstance(node.args[0], ast.Constant):
                        module_name = node.args[0].value
                        dep = self._create_dependency(
                            source_file=str(file_path),
                            target_module=module_name,
                            line_number=node.lineno,
                            import_type="dynamic",
                            is_conditional=False
                        )
                        dependencies.append(dep)

        # Check for conditional imports using regex
        for line_num, line in enumerate(lines, 1):
            for pattern_name, pattern in self.import_patterns.items():
                match = pattern.search(line)
                if match:
                    module_name = match.group(1)
                    is_conditional = pattern_name in ["try_import", "conditional_import"]
                    import_type = pattern_name.replace("_import", "")

                    dep = self._create_dependency(
                        source_file=str(file_path),
                        target_module=module_name,
                        line_number=line_num,
                        import_type=import_type,
                        is_conditional=is_conditional
                    )
                    dependencies.append(dep)

        return dependencies

    def _create_dependency(
        self,
        source_file: str,
        target_module: str,
        line_number: int,
        import_type: str,
        alias: Optional[str] = None,
        is_conditional: bool = False
    ) -> Dependency:
        """Create a Dependency object with appropriate classification"""
        # Determine dependency type
        dependency_type = self._classify_dependency_type(target_module)

        # Determine strength
        strength = self._determine_dependency_strength(import_type, is_conditional)

        return Dependency(
            source_file=source_file,
            target_module=target_module,
            dependency_type=dependency_type,
            strength=strength,
            line_number=line_number,
            import_type=import_type,
            is_conditional=is_conditional,
            alias=alias
        )

    def _classify_dependency_type(self, module_name: str) -> DependencyType:
        """Classify a dependency as internal, external, standard, or dynamic"""
        # Check for relative imports
        if module_name.startswith('.'):
            return DependencyType.RELATIVE

        # Check for standard library
        base_module = module_name.split('.')[0]
        if base_module in self.standard_library_modules:
            return DependencyType.STANDARD

        # Check for internal modules
        if any(module_name.startswith(prefix) for prefix in self.internal_module_prefixes):
            return DependencyType.INTERNAL

        # Default to external
        return DependencyType.EXTERNAL

    def _determine_dependency_strength(
        self,
        import_type: str,
        is_conditional: bool
    ) -> DependencyStrength:
        """Determine the strength of a dependency"""
        if is_conditional:
            return DependencyStrength.WEAK
        elif import_type in ["try", "conditional"]:
            return DependencyStrength.MEDIUM
        else:
            return DependencyStrength.STRONG

    def _calculate_complexity_score(self, dependencies: list[Dependency]) -> float:
        """Calculate a complexity score based on dependencies"""
        if not dependencies:
            return 0.0

        # Base score from number of dependencies
        base_score = len(dependencies) * 0.1

        # Weight by dependency type
        type_weights = {
            DependencyType.INTERNAL: 1.0,
            DependencyType.EXTERNAL: 0.5,
            DependencyType.STANDARD: 0.2,
            DependencyType.RELATIVE: 0.8,
            DependencyType.DYNAMIC: 1.5
        }

        # Weight by strength
        strength_weights = {
            DependencyStrength.WEAK: 0.5,
            DependencyStrength.MEDIUM: 0.75,
            DependencyStrength.STRONG: 1.0
        }

        weighted_score = 0.0
        for dep in dependencies:
            type_weight = type_weights.get(dep.dependency_type, 1.0)
            strength_weight = strength_weights.get(dep.strength, 1.0)
            weighted_score += type_weight * strength_weight

        return base_score + (weighted_score * 0.1)

    def _calculate_risk_score(
        self,
        dependencies: list[Dependency],
        file_path: Path
    ) -> float:
        """Calculate a risk score for migrating this file"""
        if not dependencies:
            return 0.0

        risk_score = 0.0

        # High number of strong dependencies increases risk
        strong_deps = sum(1 for d in dependencies if d.strength == DependencyStrength.STRONG)
        risk_score += strong_deps * 0.2

        # Dynamic imports increase risk
        dynamic_deps = sum(1 for d in dependencies if d.dependency_type == DependencyType.DYNAMIC)
        risk_score += dynamic_deps * 0.5

        # Internal dependencies increase risk
        internal_deps = sum(1 for d in dependencies if d.dependency_type == DependencyType.INTERNAL)
        risk_score += internal_deps * 0.1

        # Normalize to 0-1 range
        return min(risk_score, 1.0)


class DependencyGraphBuilder:
    """Builder for creating and analyzing dependency graphs"""

    def __init__(self, project_root: Path):
        """
        Initialize the dependency graph builder

        Args:
            project_root: Root path of the project
        """
        self.project_root = project_root
        self.graph = nx.DiGraph()
        self.file_analysis_results: dict[str, DependencyAnalysisResult] = {}

    def build_graph(self, analysis_results: dict[str, DependencyAnalysisResult]) -> nx.DiGraph:
        """
        Build a dependency graph from analysis results

        Args:
            analysis_results: Dictionary of file paths to analysis results

        Returns:
            NetworkX directed graph representing dependencies
        """
        self.file_analysis_results = analysis_results
        self.graph = nx.DiGraph()

        # Add nodes for each file
        for file_path, result in analysis_results.items():
            self.graph.add_node(
                file_path,
                complexity_score=result.complexity_score,
                risk_score=result.risk_score,
                dependency_count=len(result.dependencies)
            )

        # Add edges for dependencies
        for file_path, result in analysis_results.items():
            for dep in result.dependencies:
                # Only add edges for internal dependencies
                if dep.dependency_type == DependencyType.INTERNAL:
                    # Find the target file (simplified approach)
                    target_file = self._find_target_file(dep.target_module)
                    if target_file and target_file in analysis_results:
                        self.graph.add_edge(
                            file_path,
                            target_file,
                            weight=dep.strength.value,
                            dependency_type=dep.dependency_type.value
                        )

        return self.graph

    def _find_target_file(self, module_name: str) -> Optional[str]:
        """
        Find the file path for a given module name

        Args:
            module_name: Name of the module to find

        Returns:
            File path if found, None otherwise
        """
        # This is a simplified implementation
        # In practice, you'd search the project structure more thoroughly

        # Convert module name to potential file paths
        module_parts = module_name.split('.')
        possible_paths = []

        # Try different combinations
        for i in range(len(module_parts)):
            path_part = os.path.join(*module_parts[i:])
            possible_paths.append(f"{path_part}.py")
            possible_paths.append(os.path.join(path_part, "__init__.py"))

        # Check if any of these paths exist in the project
        for path_str in possible_paths:
            path = self.project_root / path_str
            if path.exists():
                return str(path.relative_to(self.project_root))

        return None

    def detect_circular_dependencies(self) -> list[list[str]]:
        """
        Detect circular dependencies in the graph

        Returns:
            List of cycles, where each cycle is a list of file paths
        """
        try:
            cycles = list(nx.simple_cycles(self.graph))
            return cycles
        except Exception as e:
            logger.error(f"Error detecting circular dependencies: {e}")
            return []

    def calculate_dependency_levels(self) -> dict[str, int]:
        """
        Calculate dependency levels for all files (topological ordering)

        Returns:
            Dictionary mapping file paths to their dependency levels
        """
        try:
            # Get topological ordering
            topo_order = list(nx.topological_sort(self.graph))

            # Calculate levels
            levels = {}
            for node in topo_order:
                predecessors = list(self.graph.predecessors(node))
                if not predecessors:
                    levels[node] = 0
                else:
                    max_pred_level = max(levels[pred] for pred in predecessors)
                    levels[node] = max_pred_level + 1

            return levels
        except nx.NetworkXError:
            # Graph has cycles, return empty dict
            logger.warning("Cannot calculate dependency levels due to circular dependencies")
            return {}

    def find_highly_depended_files(self, threshold: int = 5) -> list[tuple[str, int]]:
        """
        Find files that are depended upon by many other files

        Args:
            threshold: Minimum number of dependents to be considered highly depended

        Returns:
            List of (file_path, dependent_count) tuples
        """
        dependent_counts = []
        for node in self.graph.nodes():
            dependents = list(self.graph.predecessors(node))
            count = len(dependents)
            if count >= threshold:
                dependent_counts.append((node, count))

        # Sort by count (descending)
        dependent_counts.sort(key=lambda x: x[1], reverse=True)
        return dependent_counts

    def analyze_impact_of_change(self, file_path: str) -> dict[str, Any]:
        """
        Analyze the impact of changing a specific file

        Args:
            file_path: Path to the file to analyze

        Returns:
            Dictionary containing impact analysis
        """
        if file_path not in self.graph:
            return {"error": "File not found in dependency graph"}

        # Find all files that depend on this file (directly or indirectly)
        descendants = nx.descendants(self.graph, file_path)

        # Calculate impact metrics
        impact = {
            "file_path": file_path,
            "direct_dependents": list(self.graph.predecessors(file_path)),
            "indirect_dependents": list(descendants),
            "total_affected": len(descendants),
            "risk_level": "low"
        }

        # Determine risk level
        if len(descendants) > 20:
            impact["risk_level"] = "high"
        elif len(descendants) > 5:
            impact["risk_level"] = "medium"

        # Find critical paths
        critical_paths = []
        for dependent in descendants:
            try:
                paths = list(nx.all_simple_paths(self.graph, dependent, file_path))
                if paths:
                    critical_paths.append(min(paths, key=len))
            except nx.NetworkXNoPath:
                pass

        impact["critical_paths"] = critical_paths[:5]  # Limit to 5 paths

        return impact


class AdvancedDependencyAnalyzer:
    """Main class for advanced dependency analysis"""

    def __init__(self, project_root: Path):
        """
        Initialize the advanced dependency analyzer

        Args:
            project_root: Root path of the project
        """
        self.project_root = project_root
        self.python_analyzer = PythonDependencyAnalyzer(project_root)
        self.graph_builder = DependencyGraphBuilder(project_root)
        self.analysis_results: dict[str, DependencyAnalysisResult] = {}
        self.dependency_graph: Optional[nx.DiGraph] = None

    def analyze_project(self, file_paths: list[str]) -> dict[str, DependencyAnalysisResult]:
        """
        Analyze dependencies for all files in the project

        Args:
            file_paths: List of file paths to analyze

        Returns:
            Dictionary mapping file paths to analysis results
        """
        logger.info(f"Analyzing dependencies for {len(file_paths)} files")

        for file_path in file_paths:
            path = self.project_root / file_path
            if path.exists() and path.suffix == '.py':
                result = self.python_analyzer.analyze_file(path)
                self.analysis_results[file_path] = result

        # Build dependency graph
        self.dependency_graph = self.graph_builder.build_graph(self.analysis_results)

        # Update analysis results with graph information
        self._update_analysis_with_graph_info()

        logger.info(f"Completed dependency analysis for {len(self.analysis_results)} files")
        return self.analysis_results

    def _update_analysis_with_graph_info(self):
        """Update analysis results with information from the dependency graph"""
        if not self.dependency_graph:
            return

        # Calculate dependency levels
        dependency_levels = self.graph_builder.calculate_dependency_levels()

        # Detect circular dependencies
        circular_deps = self.graph_builder.detect_circular_dependencies()

        # Update each file's analysis result
        for file_path, result in self.analysis_results.items():
            result.dependency_level = dependency_levels.get(file_path, 0)

            # Check if this file is part of any circular dependency
            result.circular_dependencies = [
                cycle for cycle in circular_deps if file_path in cycle
            ]

            # Find dependents
            result.dependents = list(self.dependency_graph.predecessors(file_path))

    def get_migration_priority(self) -> list[tuple[str, int]]:
        """
        Get files ordered by migration priority (based on dependency levels)

        Returns:
            List of (file_path, dependency_level) tuples sorted by level
        """
        if not self.analysis_results:
            return []

        files_with_levels = [
            (file_path, result.dependency_level)
            for file_path, result in self.analysis_results.items()
        ]

        # Sort by dependency level (ascending)
        files_with_levels.sort(key=lambda x: x[1])
        return files_with_levels

    def get_high_risk_files(self, threshold: float = 0.7) -> list[tuple[str, float]]:
        """
        Get files with high risk scores

        Args:
            threshold: Risk score threshold

        Returns:
            List of (file_path, risk_score) tuples
        """
        high_risk_files = [
            (file_path, result.risk_score)
            for file_path, result in self.analysis_results.items()
            if result.risk_score >= threshold
        ]

        # Sort by risk score (descending)
        high_risk_files.sort(key=lambda x: x[1], reverse=True)
        return high_risk_files

    def generate_dependency_report(self) -> dict[str, Any]:
        """
        Generate a comprehensive dependency analysis report

        Returns:
            Dictionary containing the dependency report
        """
        if not self.analysis_results:
            return {"error": "No analysis results available"}

        # Calculate statistics
        total_files = len(self.analysis_results)
        total_dependencies = sum(len(result.dependencies) for result in self.analysis_results.values())
        circular_deps = self.graph_builder.detect_circular_dependencies()
        highly_depended = self.graph_builder.find_highly_depended_files()

        # Categorize dependencies
        dep_type_counts = defaultdict(int)
        for result in self.analysis_results.values():
            for dep in result.dependencies:
                dep_type_counts[dep.dependency_type.value] += 1

        report = {
            "summary": {
                "total_files_analyzed": total_files,
                "total_dependencies": total_dependencies,
                "average_dependencies_per_file": total_dependencies / total_files if total_files > 0 else 0,
                "circular_dependencies_count": len(circular_deps),
                "highly_depended_files_count": len(highly_depended)
            },
            "dependency_types": dict(dep_type_counts),
            "circular_dependencies": circular_deps,
            "highly_depended_files": highly_depended[:10],  # Top 10
            "high_risk_files": self.get_high_risk_files()[:10],  # Top 10
            "migration_priority": self.get_migration_priority()[:20]  # Top 20
        }

        return report

