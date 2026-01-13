#!/usr/bin/env python3
"""
Improvement Engine Module
=========================

This module provides AI-powered code improvement and optimization suggestions
based on code analysis, performance metrics, and execution patterns.

Author: NoodleCore Development Team
Version: 1.0.0
"""

import uuid
import time
import logging
from typing import Dict, List, Optional, Any, Tuple
from dataclasses import dataclass, asdict
from datetime import datetime
import json
import re
from pathlib import Path

# Configure logging
logger = logging.getLogger(__name__)


@dataclass
class ImprovementSuggestion:
    """Code improvement suggestion."""
    suggestion_id: str
    category: str  # "performance", "security", "readability", "maintainability", "optimization"
    priority: str  # "low", "medium", "high", "critical"
    title: str
    description: str
    original_code: str = ""
    improved_code: str = ""
    confidence: float = 0.0  # 0.0 to 1.0
    estimated_improvement: str = ""
    rationale: str = ""
    code_complexity_before: float = 0.0
    code_complexity_after: float = 0.0
    performance_impact: str = ""
    security_impact: str = ""
    
    def __post_init__(self):
        if not self.suggestion_id:
            self.suggestion_id = str(uuid.uuid4())


@dataclass
class OptimizationResult:
    """Result of code optimization."""
    optimization_id: str
    original_code: str
    optimized_code: str
    optimization_type: str
    improvements: List[ImprovementSuggestion]
    overall_improvement_score: float = 0.0
    performance_gain_percent: float = 0.0
    readability_score_before: float = 0.0
    readability_score_after: float = 0.0
    execution_time_estimate: float = 0.0
    
    def __post_init__(self):
        if not self.optimization_id:
            self.optimization_id = str(uuid.uuid4())


@dataclass
class CodePattern:
    """Code pattern for analysis."""
    pattern_id: str
    name: str
    pattern_type: str  # "anti-pattern", "optimization", "security", "readability"
    regex_pattern: str
    replacement: str = ""
    description: str = ""
    confidence_threshold: float = 0.7
    
    def __post_init__(self):
        if not self.pattern_id:
            self.pattern_id = str(uuid.uuid4())


class ImprovementEngine:
    """AI-powered code improvement and optimization engine."""
    
    def __init__(self):
        self.patterns = self._initialize_patterns()
        self.improvement_rules = self._initialize_improvement_rules()
        self.performance_patterns = self._initialize_performance_patterns()
        self.security_patterns = self._initialize_security_patterns()
    
    def _initialize_patterns(self) -> List[CodePattern]:
        """Initialize code patterns for analysis and improvement."""
        
        return [
            # Performance optimization patterns
            CodePattern(
                pattern_id="loop_optimization",
                name="Loop Efficiency",
                pattern_type="performance",
                regex_pattern=r"for\s+(\w+)\s+in\s+range\(len\((\w+)\)\):",
                replacement=r"for \1, item in enumerate(\2):",
                description="Replace range(len()) with enumerate() for better performance",
                confidence_threshold=0.9
            ),
            CodePattern(
                pattern_id="string_concat",
                name="String Concatenation",
                pattern_type="performance",
                regex_pattern=r'(\w+)\s*\+=\s*["\']([^"\']*)["\']',
                replacement=r'strings = []\nstrings.append("\2")\nresult = "".join(strings)',
                description="Optimize string concatenation in loops",
                confidence_threshold=0.8
            ),
            CodePattern(
                pattern_id="list_comprehension",
                name="List Comprehension",
                pattern_type="performance",
                regex_pattern=r'\[(\w+)\s+for\s+(\w+)\s+in\s+([^\]]+)\s+if\s+([^\]]+)\]',
                replacement=r'[\1 for \2 in \3 if \4]',
                description="Use list comprehensions for better performance",
                confidence_threshold=0.8
            ),
            
            # Readability improvements
            CodePattern(
                pattern_id="variable_naming",
                name="Variable Naming",
                pattern_type="readability",
                regex_pattern=r'\b([a-z]{1,2})\s*=\s*',
                replacement=r'',
                description="Use descriptive variable names",
                confidence_threshold=0.6
            ),
            CodePattern(
                pattern_id="function_length",
                name="Function Length",
                pattern_type="readability",
                regex_pattern=r'def\s+\w+\([^)]*\):(.*?)(\n\s*\n|$)',
                replacement=r'def \w+(\1):\n    # Consider breaking this function into smaller parts',
                description="Break down long functions",
                confidence_threshold=0.7
            ),
            
            # Security patterns
            CodePattern(
                pattern_id="eval_usage",
                name="Eval Usage",
                pattern_type="security",
                regex_pattern=r'\beval\s*\(',
                replacement=r'ast.literal_eval(',
                description="Replace eval() with safer ast.literal_eval()",
                confidence_threshold=0.95
            ),
            CodePattern(
                pattern_id="sql_injection",
                name="SQL Injection Risk",
                pattern_type="security",
                regex_pattern=r'execute\s*\(\s*["\'].*%.*["\'].*\)',
                replacement=r'Use parameterized queries to prevent SQL injection',
                description="Use parameterized queries instead of string formatting",
                confidence_threshold=0.9
            )
        ]
    
    def _initialize_improvement_rules(self) -> List[Dict[str, Any]]:
        """Initialize improvement rules for different code patterns."""
        
        return [
            {
                "rule_id": "memory_optimization",
                "name": "Memory Usage Optimization",
                "conditions": [
                    {"type": "pattern", "value": r"list\(.*range\(.*\)"},
                    {"type": "pattern", "value": r"\[.*for.*in.*\]"}
                ],
                "improvements": [
                    "Use generators instead of lists when possible",
                    "Implement memory pooling for frequently used objects",
                    "Clear large data structures when no longer needed"
                ]
            },
            {
                "rule_id": "cpu_optimization",
                "name": "CPU Usage Optimization",
                "conditions": [
                    {"type": "pattern", "value": r"for.*range\(len\(.*\)"},
                    {"type": "pattern", "value": r"while.*and.*"}
                ],
                "improvements": [
                    "Use enumerate() instead of range(len())",
                    "Optimize nested loops with early exit conditions",
                    "Cache frequently accessed data"
                ]
            },
            {
                "rule_id": "io_optimization",
                "name": "I/O Operations Optimization",
                "conditions": [
                    {"type": "pattern", "value": r"open\("},
                    {"type": "pattern", "value": r"requests\."}
                ],
                "improvements": [
                    "Use context managers for file operations",
                    "Implement connection pooling for HTTP requests",
                    "Batch I/O operations when possible"
                ]
            }
        ]
    
    def _initialize_performance_patterns(self) -> List[Dict[str, Any]]:
        """Initialize performance-specific improvement patterns."""
        
        return [
            {
                "pattern": r"\bfor\s+\w+\s+in\s+range\(len\((\w+)\)\):",
                "suggestion": "Use enumerate() instead of range(len())",
                "improvement": "Faster iteration and cleaner code",
                "complexity_reduction": 0.2
            },
            {
                "pattern": r"\b(\w+)\s*\+=\s*\[([^\]]*)\]",
                "suggestion": "Use list.extend() or list comprehensions",
                "improvement": "Better memory and time efficiency",
                "complexity_reduction": 0.15
            },
            {
                "pattern": r"if\s+.*:\s+return\s+.*\s+else:\s+return\s+(.+)",
                "suggestion": "Simplify conditional returns",
                "improvement": "More readable and maintainable code",
                "complexity_reduction": 0.1
            }
        ]
    
    def _initialize_security_patterns(self) -> List[Dict[str, Any]]:
        """Initialize security-specific improvement patterns."""
        
        return [
            {
                "pattern": r"\beval\s*\(",
                "severity": "critical",
                "suggestion": "Replace eval() with ast.literal_eval() or safe parsing",
                "improvement": "Prevents code injection attacks",
                "security_level": "high"
            },
            {
                "pattern": r"\bexec\s*\(",
                "severity": "critical",
                "suggestion": "Avoid exec() or use restricted execution environment",
                "improvement": "Prevents arbitrary code execution",
                "security_level": "high"
            },
            {
                "pattern": r"\binput\s*\(",
                "severity": "medium",
                "suggestion": "Validate and sanitize user input",
                "improvement": "Prevents injection attacks",
                "security_level": "medium"
            }
        ]
    
    def analyze_and_improve(self, code: str, language: str = "python", 
                          analysis_result: Any = None, performance_data: Any = None) -> OptimizationResult:
        """Analyze code and generate improvement suggestions."""
        
        logger.info(f"Generating improvements for {language} code")
        
        optimization_id = str(uuid.uuid4())
        improvements = []
        
        try:
            # Generate pattern-based improvements
            pattern_improvements = self._analyze_patterns(code)
            improvements.extend(pattern_improvements)
            
            # Generate performance-based improvements
            if performance_data:
                perf_improvements = self._analyze_performance_patterns(code, performance_data)
                improvements.extend(perf_improvements)
            
            # Generate security improvements
            security_improvements = self._analyze_security_patterns(code)
            improvements.extend(security_improvements)
            
            # Generate readability improvements
            readability_improvements = self._analyze_readability_patterns(code)
            improvements.extend(readability_improvements)
            
            # Apply improvements to create optimized code
            optimized_code = self._apply_improvements(code, improvements)
            
            # Calculate overall improvement score
            overall_score = self._calculate_improvement_score(improvements)
            
            # Calculate readability scores
            readability_before = self._calculate_readability_score(code)
            readability_after = self._calculate_readability_score(optimized_code)
            
            # Calculate estimated performance gain
            performance_gain = self._estimate_performance_gain(code, optimized_code)
            
            result = OptimizationResult(
                optimization_id=optimization_id,
                original_code=code,
                optimized_code=optimized_code,
                optimization_type="comprehensive",
                improvements=improvements,
                overall_improvement_score=overall_score,
                performance_gain_percent=performance_gain,
                readability_score_before=readability_before,
                readability_score_after=readability_after
            )
            
            logger.info(f"Generated {len(improvements)} improvement suggestions with score {overall_score}")
            
            return result
            
        except Exception as e:
            logger.error(f"Improvement analysis failed: {e}")
            return OptimizationResult(
                optimization_id=optimization_id,
                original_code=code,
                optimized_code=code,
                optimization_type="error",
                improvements=[],
                overall_improvement_score=0.0
            )
    
    def _analyze_patterns(self, code: str) -> List[ImprovementSuggestion]:
        """Analyze code against predefined patterns."""
        
        improvements = []
        
        for pattern in self.patterns:
            matches = re.finditer(pattern.regex_pattern, code, re.MULTILINE | re.DOTALL)
            
            for match in matches:
                improvement = ImprovementSuggestion(
                    category=pattern.pattern_type,
                    priority=self._determine_priority(pattern.pattern_type),
                    title=f"Improve {pattern.name}",
                    description=pattern.description,
                    original_code=match.group(0),
                    improved_code=self._generate_improved_code(match, pattern),
                    confidence=self._calculate_pattern_confidence(match, pattern),
                    estimated_improvement=self._estimate_pattern_improvement(pattern),
                    rationale=f"Pattern '{pattern.name}' detected with high confidence"
                )
                improvements.append(improvement)
        
        return improvements
    
    def _analyze_performance_patterns(self, code: str, performance_data: Any) -> List[ImprovementSuggestion]:
        """Analyze performance-specific patterns."""
        
        improvements = []
        
        for perf_pattern in self.performance_patterns:
            if re.search(perf_pattern["pattern"], code):
                improvement = ImprovementSuggestion(
                    category="performance",
                    priority="high",
                    title=f"Performance Optimization: {perf_pattern['pattern']}",
                    description=perf_pattern["suggestion"],
                    confidence=0.8,
                    estimated_improvement=perf_pattern["improvement"],
                    rationale="Performance analysis indicates potential optimization",
                    code_complexity_before=1.0,
                    code_complexity_after=1.0 - perf_pattern.get("complexity_reduction", 0.0)
                )
                improvements.append(improvement)
        
        return improvements
    
    def _analyze_security_patterns(self, code: str) -> List[ImprovementSuggestion]:
        """Analyze security-related patterns."""
        
        improvements = []
        
        for sec_pattern in self.security_patterns:
            if re.search(sec_pattern["pattern"], code):
                improvement = ImprovementSuggestion(
                    category="security",
                    priority=sec_pattern["severity"],
                    title=f"Security Issue: {sec_pattern['pattern']}",
                    description=sec_pattern["suggestion"],
                    confidence=0.9,
                    estimated_improvement=sec_pattern["improvement"],
                    rationale=f"Security analysis detected {sec_pattern['pattern']} pattern",
                    security_impact=sec_pattern["security_level"]
                )
                improvements.append(improvement)
        
        return improvements
    
    def _analyze_readability_patterns(self, code: str) -> List[ImprovementSuggestion]:
        """Analyze code readability patterns."""
        
        improvements = []
        
        lines = code.split('\n')
        
        # Check for long lines
        for i, line in enumerate(lines, 1):
            if len(line) > 120:
                improvement = ImprovementSuggestion(
                    category="readability",
                    priority="medium",
                    title="Line too long",
                    description=f"Line {i} exceeds 120 characters",
                    original_code=line,
                    improved_code=self._suggest_line_split(line),
                    confidence=0.7,
                    estimated_improvement="Improved code readability"
                )
                improvements.append(improvement)
        
        # Check for complex nested structures
        if self._calculate_nesting_depth(code) > 4:
            improvement = ImprovementSuggestion(
                category="readability",
                priority="medium", 
                title="Deep nesting detected",
                description="Code structure is deeply nested, consider refactoring",
                confidence=0.8,
                estimated_improvement="Better code structure and maintainability"
            )
            improvements.append(improvement)
        
        return improvements
    
    def _apply_improvements(self, code: str, improvements: List[ImprovementSuggestion]) -> str:
        """Apply selected improvements to create optimized code."""
        
        optimized_code = code
        
        # Sort improvements by priority and confidence
        sorted_improvements = sorted(
            improvements, 
            key=lambda x: (x.priority == "critical", x.confidence), 
            reverse=True
        )
        
        for improvement in sorted_improvements:
            if improvement.confidence > 0.8 and improvement.improved_code:
                try:
                    # Apply the improvement
                    optimized_code = optimized_code.replace(
                        improvement.original_code,
                        improvement.improved_code
                    )
                except Exception as e:
                    logger.warning(f"Failed to apply improvement {improvement.suggestion_id}: {e}")
        
        return optimized_code
    
    def _calculate_improvement_score(self, improvements: List[ImprovementSuggestion]) -> float:
        """Calculate overall improvement score."""
        
        if not improvements:
            return 0.0
        
        total_score = 0.0
        total_weight = 0.0
        
        for improvement in improvements:
            # Weight by priority and confidence
            priority_weight = {"critical": 4, "high": 3, "medium": 2, "low": 1}.get(improvement.priority, 1)
            weight = priority_weight * improvement.confidence
            
            total_score += weight
            total_weight += weight
        
        return min(100.0, (total_score / total_weight) * 25) if total_weight > 0 else 0.0
    
    def _calculate_readability_score(self, code: str) -> float:
        """Calculate code readability score."""
        
        score = 100.0
        
        lines = code.split('\n')
        
        # Deduct for long lines
        long_lines = sum(1 for line in lines if len(line) > 120)
        score -= long_lines * 2
        
        # Deduct for complex nesting
        nesting_depth = self._calculate_nesting_depth(code)
        if nesting_depth > 4:
            score -= (nesting_depth - 4) * 5
        
        # Deduct for missing comments
        total_lines = len([line for line in lines if line.strip() and not line.strip().startswith('#')])
        comment_lines = len([line for line in lines if line.strip().startswith('#')])
        comment_ratio = comment_lines / total_lines if total_lines > 0 else 0
        if comment_ratio < 0.1:
            score -= 10
        
        return max(0.0, score)
    
    def _calculate_nesting_depth(self, code: str) -> int:
        """Calculate maximum nesting depth."""
        
        max_depth = 0
        current_depth = 0
        
        for char in code:
            if char in '{[(':
                current_depth += 1
                max_depth = max(max_depth, current_depth)
            elif char in '}])':
                current_depth = max(0, current_depth - 1)
        
        return max_depth
    
    def _estimate_performance_gain(self, original_code: str, optimized_code: str) -> float:
        """Estimate performance improvement percentage."""
        
        # Simple heuristic: count operations in both versions
        original_ops = len(re.findall(r'\b(for|while|if|def|class)\b', original_code))
        optimized_ops = len(re.findall(r'\b(for|while|if|def|class)\b', optimized_code))
        
        if original_ops > optimized_ops:
            return min(30.0, (original_ops - optimized_ops) * 5)
        
        return 0.0
    
    def _determine_priority(self, pattern_type: str) -> str:
        """Determine priority based on pattern type."""
        
        priorities = {
            "security": "critical",
            "performance": "high",
            "readability": "medium",
            "optimization": "medium"
        }
        
        return priorities.get(pattern_type, "low")
    
    def _generate_improved_code(self, match, pattern: CodePattern) -> str:
        """Generate improved code for a pattern match."""
        
        if pattern.replacement:
            # Use predefined replacement
            try:
                return match.expand(pattern.replacement)
            except:
                return pattern.replacement
        else:
            # Generate generic improvement
            return f"# Improved: {match.group(0)}"
    
    def _calculate_pattern_confidence(self, match, pattern: CodePattern) -> float:
        """Calculate confidence score for a pattern match."""
        
        # Base confidence on pattern threshold and match context
        confidence = pattern.confidence_threshold
        
        # Adjust based on context
        if len(match.group(0)) > 10:  # Longer matches are more confident
            confidence += 0.1
        
        if match.start() > 0:  # Not at the beginning might indicate proper structure
            confidence += 0.05
        
        return min(1.0, confidence)
    
    def _estimate_pattern_improvement(self, pattern: CodePattern) -> str:
        """Estimate improvement from pattern."""
        
        improvements = {
            "loop_optimization": "10-15% performance improvement",
            "string_concat": "20-30% memory usage reduction",
            "list_comprehension": "15-25% execution speed improvement",
            "eval_usage": "Critical security improvement",
            "variable_naming": "Improved code readability"
        }
        
        return improvements.get(pattern.pattern_id, "Improved code quality")
    
    def _suggest_line_split(self, line: str) -> str:
        """Suggest how to split a long line."""
        
        # Simple heuristic: split at operators
        operators = ['+', '-', '*', '/', '=', '==', '!=', '<=', '>=']
        
        for op in operators:
            if op in line and len(line) > 80:
                parts = line.split(op, 1)
                if len(parts) == 2:
                    return parts[0] + op + " \\\n    " + parts[1]
        
        return line  # Fallback
    
    def get_improvement_statistics(self) -> Dict[str, Any]:
        """Get improvement engine statistics."""
        
        return {
            "total_patterns": len(self.patterns),
            "improvement_rules": len(self.improvement_rules),
            "performance_patterns": len(self.performance_patterns),
            "security_patterns": len(self.security_patterns),
            "pattern_categories": list(set(p.pattern_type for p in self.patterns)),
            "supported_languages": ["python", "noodle", "noodlecore"]
        }


# Factory function
def create_improvement_engine() -> ImprovementEngine:
    """Create a new ImprovementEngine instance."""
    return ImprovementEngine()


# Global instance
_improvement_engine = None

def get_improvement_engine() -> ImprovementEngine:
    """Get the global improvement engine instance."""
    global _improvement_engine
    if _improvement_engine is None:
        _improvement_engine = create_improvement_engine()
    return _improvement_engine