# Converted from Python to NoodleCore
# Original file: noodle-core

# """
NoodleCore (.nc) File Optimization Engine

# This module provides intelligent optimization suggestions for .nc files,
# using both rule-based and neural network approaches to identify optimization opportunities
# and generate actionable recommendations.
# """

import os
import re
import json
import logging
import time
import uuid
import hashlib
import difflib
import typing.Any,
import dataclasses.dataclass,
import enum.Enum
import pathlib.Path

# Import existing components
import .nc_file_analyzer.(
#     get_nc_file_analyzer, NCPatternType, NCPatternMatch,
#     NCOptimizationSuggestion, NCFileMetrics, NCFileType
# )
import .nc_pattern_recognizer.get_pattern_recognizer,
import .trm_neural_networks.get_neural_network_manager,

# Configure logging
logger = logging.getLogger(__name__)

# Environment variables
NOODLE_DEBUG = os.environ.get("NOODLE_DEBUG", "0") == "1"
NOODLE_OPTIMIZATION_ENABLED = os.environ.get("NOODLE_OPTIMIZATION_ENABLED", "1") == "1"
NOODLE_OPTIMIZATION_CACHE_DIR = os.environ.get("NOODLE_OPTIMIZATION_CACHE_DIR", "nc_optimization_cache")


class NCOptimizationType(Enum)
    #     """Types of optimizations for .nc files."""
    PERFORMANCE = "performance"  # Performance-related optimizations
    MAINTAINABILITY = "maintainability"  # Code maintainability improvements
    SECURITY = "security"  # Security enhancements
    MEMORY = "memory"  # Memory usage optimizations
    CONCURRENCY = "concurrency"  # Concurrency improvements
    CODE_STRUCTURE = "code_structure"  # Code structure improvements
    ALGORITHMIC = "algorithmic"  # Algorithmic improvements


class NCOptimizationPriority(Enum)
    #     """Priority levels for optimizations."""
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


# @dataclass
class NCOptimizationResult
    #     """Result of applying an optimization to a .nc file."""
    #     optimization_id: str
    #     file_path: str
    #     optimization_type: NCOptimizationType
    #     original_code: str
    #     optimized_code: str
    #     changes_made: List[str]
    #     performance_improvement: float  # Percentage improvement
    #     maintainability_improvement: float  # Percentage improvement
    #     security_improvement: float  # Percentage improvement
    #     success: bool
    error_message: Optional[str] = None
    #     applied_timestamp: float


class NCOptimizationEngine
    #     """
    #     Optimization engine for .nc files.

    #     This class provides intelligent optimization suggestions for .nc files,
    #     using both rule-based and neural network approaches to identify optimization opportunities
    #     and generate actionable recommendations.
    #     """

    #     def __init__(self):
    #         """Initialize the optimization engine."""
    #         if NOODLE_DEBUG:
                logger.setLevel(logging.DEBUG)

    #         # Optimization cache
    self.optimization_cache = {}

    #         # Neural network manager
    self.neural_network_manager = get_neural_network_manager()

    #         # Load optimization models
            self._load_optimization_models()

            logger.info("NC Optimization Engine initialized")

    #     def _load_optimization_models(self):
    #         """Load or create optimization models."""
    #         try:
    #             # Try to load existing optimization models
    optimization_models = self.neural_network_manager.list_models()

    #             # Check if we have optimization models
    performance_model = None
    maintainability_model = None
    security_model = None

    #             for model in optimization_models:
    model_type = model.get('model_type')

    #                 if model_type == ModelType.OPTIMIZATION_SUGGESTION.value:
    #                     if not performance_model:
    performance_model = model
                            logger.info("Found existing performance optimization model")

    #                 elif model_type == ModelType.CODE_ANALYSIS.value:
    #                     # Code analysis model can be used for maintainability
    #                     if not maintainability_model:
    maintainability_model = model
                            logger.info("Found existing maintainability optimization model")

    #                 # Check for security model (using code analysis model)
    #                 elif not security_model and model_type == ModelType.CODE_ANALYSIS.value:
    security_model = model
    #                     logger.info("Using code analysis model for security optimization")

    #             # Create models if they don't exist
    #             if not performance_model:
    model_id = self.neural_network_manager.create_model(ModelType.OPTIMIZATION_SUGGESTION)
                    logger.info(f"Created new performance optimization model: {model_id}")

    #             if not maintainability_model:
    model_id = self.neural_network_manager.create_model(ModelType.CODE_ANALYSIS)
                    logger.info(f"Created new maintainability optimization model: {model_id}")

    #             if not security_model:
    model_id = self.neural_network_manager.create_model(ModelType.CODE_ANALYSIS)
                    logger.info(f"Created new security optimization model: {model_id}")

    #         except Exception as e:
                logger.error(f"Error loading optimization models: {str(e)}")

    #     def generate_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """
    #         Generate optimization suggestions based on file analysis metrics.

    #         Args:
    #             metrics: Analysis metrics for the .nc file

    #         Returns:
    #             List[NCOptimizationSuggestion]: Optimization suggestions
    #         """
    #         try:
    #             # Check cache first
    cache_key = self._get_metrics_cache_key(metrics)
    #             if cache_key in self.optimization_cache:
    #                 logger.debug(f"Using cached optimizations for {metrics.file_path}")
    #                 return self.optimization_cache[cache_key]

    suggestions = []

    #             # Generate performance optimizations
    performance_suggestions = self._generate_performance_optimizations(metrics)
                suggestions.extend(performance_suggestions)

    #             # Generate maintainability optimizations
    maintainability_suggestions = self._generate_maintainability_optimizations(metrics)
                suggestions.extend(maintainability_suggestions)

    #             # Generate security optimizations
    security_suggestions = self._generate_security_optimizations(metrics)
                suggestions.extend(security_suggestions)

    #             # Generate code structure optimizations
    structure_suggestions = self._generate_code_structure_optimizations(metrics)
                suggestions.extend(structure_suggestions)

    #             # Generate algorithmic optimizations
    algorithmic_suggestions = self._generate_algorithmic_optimizations(metrics)
                suggestions.extend(algorithmic_suggestions)

    #             # Cache the results
    self.optimization_cache[cache_key] = suggestions

    #             logger.info(f"Generated {len(suggestions)} optimizations for {metrics.file_path}")
    #             return suggestions

    #         except Exception as e:
                logger.error(f"Error generating optimizations: {str(e)}")
    #             return []

    #     def _generate_performance_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """Generate performance-related optimization suggestions."""
    suggestions = []

    #         # Low performance score optimizations
    #         if metrics.performance_score < 30:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.PERFORMANCE,
    priority = NCOptimizationPriority.HIGH,
    title = "Improve Low Performance",
    description = f"Performance score is {metrics.performance_score}/100, indicating significant performance issues",
    current_code = "",
    suggested_code = "# Consider performance profiling and optimization\n# Add performance monitoring and caching",
    expected_improvement = 25.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["performance", "optimization"]
    #             ))

    #         # High complexity optimizations
    #         if metrics.complexity_level in [NCComplexityLevel.COMPLEX, NCComplexityLevel.VERY_COMPLEX]:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.PERFORMANCE,
    priority = NCOptimizationPriority.HIGH,
    title = "Reduce Code Complexity",
    #                 description=f"File has {metrics.complexity_level.value} complexity with cyclomatic complexity of {metrics.cyclomatic_complexity}",
    current_code = "",
    #                 suggested_code="# Consider breaking down complex functions\n# Use memoization for expensive computations",
    expected_improvement = 20.0,
    confidence = 0.9,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["performance", "complexity", "refactoring"]
    #             ))

    #         # Anti-pattern optimizations
    #         for anti_pattern in metrics.anti_patterns_found:
    #             if anti_pattern.pattern_type == NCPatternType.ANTI_PATTERN:
                    suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = anti_pattern.line_number,
    optimization_type = NCOptimizationType.MAINTAINABILITY,
    priority = NCOptimizationPriority.HIGH,
    title = "Fix Anti-Pattern",
    description = f"Anti-pattern detected: {anti_pattern.content}",
    current_code = anti_pattern.content,
    suggested_code = anti_pattern.suggestion or "# Refactor to eliminate anti-pattern",
    expected_improvement = 15.0,
    confidence = anti_pattern.confidence,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["maintainability", "anti_pattern", "refactoring"]
    #                 ))

    #         # Performance pattern optimizations
    #         performance_patterns = [p for p in metrics.patterns_found if p.pattern_type == NCPatternType.PERFORMANCE_PATTERN]
    #         if performance_patterns:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.PERFORMANCE,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Optimize Performance Patterns",
    description = "Performance-related patterns detected that could be optimized",
    current_code = "",
    suggested_code = "# Implement proper performance optimization patterns\n# Consider caching and lazy loading",
    expected_improvement = 10.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["performance", "optimization", "pattern"]
    #             ))

    #         return suggestions

    #     def _generate_maintainability_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """Generate maintainability-related optimization suggestions."""
    suggestions = []

    #         # Low maintainability index optimizations
    #         if metrics.maintainability_index < 30:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.MAINTAINABILITY,
    priority = NCOptimizationPriority.HIGH,
    title = "Improve Maintainability",
    description = f"Maintainability index is {metrics.maintainability_index}/100, indicating poor code quality",
    current_code = "",
    suggested_code = "# Improve code structure and documentation\n# Add type hints and docstrings",
    expected_improvement = 20.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["maintainability", "documentation", "quality"]
    #             ))

    #         # High technical debt optimizations
    #         if metrics.technical_debt_ratio > 0.5:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.MAINTAINABILITY,
    priority = NCOptimizationPriority.HIGH,
    title = "Reduce Technical Debt",
    description = f"Technical debt ratio is {metrics.technical_debt_ratio:.2f}, indicating code quality issues",
    current_code = "",
    suggested_code = "# Refactor to reduce technical debt\n# Improve code structure and add tests",
    expected_improvement = 25.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["maintainability", "refactoring", "technical_debt"]
    #             ))

    #         # Long function optimizations
    function_count = metrics.function_count
    #         if function_count > 0:
    #             avg_function_size = metrics.line_count / function_count if function_count > 0 else 0

    #             # Check for very long functions
    #             with open(metrics.file_path, 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.splitlines()

    #                 for line_num, line in enumerate(lines, 1):
    line_stripped = line.strip()

    #                     # Skip empty lines and comments
    #                     if not line_stripped or line_stripped.startswith('#'):
    #                         continue

    #                     # Check for long function definitions
    #                     if (line_stripped.startswith('def ') or line_stripped.startswith('function ')) and len(line_stripped) > avg_function_size * 2:
                            suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = line_num,
    optimization_type = NCOptimizationType.MAINTAINABILITY,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Break Down Long Functions",
    description = f"Function at line {line_num} is unusually long",
    current_code = line_stripped,
    suggested_code = "# Consider breaking down into smaller functions",
    expected_improvement = 10.0,
    confidence = 0.9,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["maintainability", "refactoring"]
    #                         ))

    #         return suggestions

    #     def _generate_security_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """Generate security-related optimization suggestions."""
    suggestions = []

    #         # Security anti-patterns
    #         security_patterns = [p for p in metrics.anti_patterns_found if p.pattern_type in [
    #             NCPatternType.SECURITY_INJECTION, NCPatternType.SECURITY_HARDCODED
    #         ])

    #         if security_patterns:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.SECURITY,
    priority = NCOptimizationPriority.CRITICAL,
    title = "Fix Security Vulnerabilities",
    description = "Security vulnerabilities detected that should be addressed",
    current_code = "",
    suggested_code = "# Review and fix security issues\n# Use parameterized queries and input validation",
    expected_improvement = 30.0,
    confidence = 0.9,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["security", "vulnerability"]
    #             ))

    #         # File type-specific security optimizations
    #         if metrics.file_type == NCFileType.RUNTIME:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.SECURITY,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Secure Runtime Execution",
    description = "Runtime files should include proper security checks",
    current_code = "",
    suggested_code = "# Add input validation and sandboxing\n# Implement proper error handling",
    expected_improvement = 15.0,
    confidence = 0.7,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["security", "runtime"]
    #             ))

    #         return suggestions

    #     def _generate_code_structure_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """Generate code structure-related optimization suggestions."""
    suggestions = []

    #         # Import organization optimizations
    #         if metrics.import_count > 10:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.CODE_STRUCTURE,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Organize Imports",
    description = f"File has {metrics.import_count} import statements, consider organizing",
    current_code = "",
    suggested_code = "# Group related imports\n# Remove unused imports",
    expected_improvement = 5.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["code_structure", "imports"]
    #             ))

    #         # Class structure optimizations
    #         if metrics.class_count > 5:
                suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = math.subtract(0,  # File, level suggestion)
    optimization_type = NCOptimizationType.CODE_STRUCTURE,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Simplify Class Structure",
    description = f"File has {metrics.class_count} classes, consider simplifying hierarchy",
    current_code = "",
    suggested_code = "# Use composition over inheritance\n# Extract common functionality to base classes",
    expected_improvement = 10.0,
    confidence = 0.7,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["code_structure", "classes"]
    #             ))

    #         return suggestions

    #     def _generate_algorithmic_optimizations(self, metrics: NCFileMetrics) -> List[NCOptimizationSuggestion]:
    #         """Generate algorithmic optimization suggestions."""
    suggestions = []

    #         # Read file content to analyze algorithms
    #         try:
    #             with open(metrics.file_path, 'r', encoding='utf-8') as f:
    content = f.read()
    lines = content.splitlines()

    #                 # Check for inefficient loops
    #                 for line_num, line in enumerate(lines, 1):
    line_stripped = line.strip()

    #                     # Skip empty lines and comments
    #                     if not line_stripped or line_stripped.startswith('#'):
    #                         continue

    #                     # Check for inefficient loop patterns
    #                     if 'for ' in line_stripped and 'range(' in line_stripped:
                            suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = line_num,
    optimization_type = NCOptimizationType.ALGORITHMIC,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Optimize Loop",
    #                             description="Inefficient for loop detected",
    current_code = line_stripped,
    suggested_code = "# Consider using list comprehensions or iterators",
    expected_improvement = 15.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["algorithm", "loop", "optimization"]
    #                         ))

    #                     # Check for inefficient data structures
    #                     if 'list(' in line_stripped and ('append(' in line_stripped or '+' in line_stripped):
                            suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = line_num,
    optimization_type = NCOptimizationType.ALGORITHMIC,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Optimize Data Structure",
    description = "Inefficient list operations detected",
    current_code = line_stripped,
    suggested_code = "# Consider using more efficient data structures",
    expected_improvement = 10.0,
    confidence = 0.8,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["algorithm", "data_structure", "optimization"]
    #                         ))

    #                     # Check for recursive function calls
    #                     if re.search(r'\b(\w+)\s*\(\s*\1\s*\)', line_stripped):
                            suggestions.append(NCOptimizationSuggestion(
    suggestion_id = str(uuid.uuid4()),
    file_path = metrics.file_path,
    line_number = line_num,
    optimization_type = NCOptimizationType.ALGORITHMIC,
    priority = NCOptimizationPriority.MEDIUM,
    title = "Add Memoization",
    description = "Potential recursive function call detected",
    current_code = line_stripped,
    #                             suggested_code="# Consider adding memoization for expensive functions",
    expected_improvement = 20.0,
    confidence = 0.7,
    auto_applicable = False,
    manual_review_required = True,
    tags = ["algorithm", "memoization", "optimization"]
    #                         ))

    #         except Exception as e:
                logger.error(f"Error analyzing algorithms: {str(e)}")

    #         return suggestions

    #     def apply_optimization(self, file_path: str, optimization_id: str,
    #                      optimized_code: str) -> NCOptimizationResult:
    #         """
    #         Apply an optimization to a .nc file.

    #         Args:
    #             file_path: Path to the .nc file to optimize
    #             optimization_id: ID of the optimization to apply
    #             optimized_code: The optimized code to apply

    #         Returns:
    #             NCOptimizationResult: Result of the optimization application
    #         """
    #         try:
    #             # Read original file
    #             with open(file_path, 'r', encoding='utf-8') as f:
    original_code = f.read()

    #             # Create backup
    backup_path = f"{file_path}.backup"
    #             with open(backup_path, 'w', encoding='utf-8') as f:
                    f.write(original_code)

    #             # Apply optimization
    #             with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(optimized_code)

                # Calculate improvements (simplified)
    changes_made = ["Applied optimization", "Created backup"]
    performance_improvement = 10.0  # Placeholder
    maintainability_improvement = 10.0  # Placeholder
    security_improvement = 5.0  # Placeholder

    result = NCOptimizationResult(
    optimization_id = optimization_id,
    file_path = file_path,
    optimization_type = NCOptimizationType.PERFORMANCE,  # Default
    original_code = original_code,
    optimized_code = optimized_code,
    changes_made = changes_made,
    performance_improvement = performance_improvement,
    maintainability_improvement = maintainability_improvement,
    security_improvement = security_improvement,
    success = True,
    applied_timestamp = time.time()
    #             )

                logger.info(f"Applied optimization {optimization_id} to {file_path}")
    #             return result

    #         except Exception as e:
                logger.error(f"Error applying optimization: {str(e)}")
                return NCOptimizationResult(
    optimization_id = optimization_id,
    file_path = file_path,
    optimization_type = NCOptimizationType.PERFORMANCE,
    original_code = "",
    optimized_code = "",
    changes_made = [],
    performance_improvement = 0.0,
    maintainability_improvement = 0.0,
    security_improvement = 0.0,
    success = False,
    error_message = str(e),
    applied_timestamp = time.time()
    #             )

    #     def _get_metrics_cache_key(self, metrics: NCFileMetrics) -> str:
    #         """Generate cache key for file metrics."""
    #         try:
    #             # Get file modification time and size for cache key
    mtime = os.path.getmtime(metrics.file_path)
    size = os.path.getsize(metrics.file_path)

    #             # Create hash from file metadata
    cache_data = f"{metrics.file_path}:{mtime}:{size}:{metrics.line_count}:{metrics.function_count}"
                return hashlib.md5(cache_data.encode()).hexdigest()

    #         except Exception:
    #             # Fallback to simple path hash
                return hashlib.md5(metrics.file_path.encode()).hexdigest()

    #     def clear_cache(self):
    #         """Clear the optimization cache."""
            self.optimization_cache.clear()
            logger.info("Optimization cache cleared")

    #     def get_optimization_summary(self, optimization_results: List[NCOptimizationResult]) -> Dict[str, Any]:
    #         """
    #         Generate a summary of optimization results.

    #         Args:
    #             optimization_results: List of optimization results

    #         Returns:
    #             Dict[str, Any]: Summary statistics
    #         """
    #         if not optimization_results:
    #             return {'error': 'No optimizations applied'}

    #         successful_optimizations = sum(1 for r in optimization_results if r.success)
    failed_optimizations = math.subtract(len(optimization_results), successful_optimizations)

    #         # Calculate average improvements
    #         performance_improvements = [r.performance_improvement for r in optimization_results if r.success]
    #         avg_performance_improvement = sum(performance_improvements) / len(performance_improvements) if performance_improvements else 0

    #         maintainability_improvements = [r.maintainability_improvement for r in optimization_results if r.success]
    #         avg_maintainability_improvement = sum(maintainability_improvements) / len(maintainability_improvements) if maintainability_improvements else 0

    #         # Optimization type distribution
    optimization_types = {}
    #         for result in optimization_results:
    #             if result.success:
    opt_type = result.optimization_type.value
    #                 if opt_type not in optimization_types:
    optimization_types[opt_type] = 0
    optimization_types[opt_type] + = 1

    #         return {
                'total_optimizations': len(optimization_results),
    #             'successful_optimizations': successful_optimizations,
    #             'failed_optimizations': failed_optimizations,
    #             'average_performance_improvement': avg_performance_improvement,
    #             'average_maintainability_improvement': avg_maintainability_improvement,
    #             'optimization_types': optimization_types
    #         }


# Global instance for convenience
_global_optimization_engine_instance = None


def get_optimization_engine() -> NCOptimizationEngine:
#     """
#     Get a global optimization engine instance.

#     Returns:
#         NCOptimizationEngine: An optimization engine instance.
#     """
#     global _global_optimization_engine_instance

#     if _global_optimization_engine_instance is None:
_global_optimization_engine_instance = NCOptimizationEngine()

#     return _global_optimization_engine_instance