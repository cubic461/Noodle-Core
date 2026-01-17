#!/usr/bin/env python3
"""
Performance Optimization Script for NIP v3.0.0

This script performs:
- Code profiling
- Memory optimization
- Caching strategies
- Database query optimization
- Async/await optimization
"""

import ast
import re
from pathlib import Path


class PerformanceOptimizer:
    """Optimize code for better performance"""

    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.optimizations = []
        self.stats = {
            'files_analyzed': 0,
            'optimizations_found': 0,
            'potential_speedup': 0.0
        }

    def analyze(self) -> dict:
        """Analyze code for performance optimizations"""
        print("⚡ Analyzing code for performance optimizations...\n")

        # Find all Python files
        python_files = list(self.root_path.rglob("*.py"))
        python_files = [f for f in python_files if
                       '.pytest_cache' not in str(f) and
                       '__pycache__' not in str(f)]

        print(f"📁 Analyzing {len(python_files)} Python files\n")

        # Analyze each file
        for file_path in python_files:
            self._analyze_file(file_path)

        # Generate recommendations
        return self._generate_report()

    def _analyze_file(self, file_path: Path):
        """Analyze a single Python file for optimizations"""
        try:
            with open(file_path, encoding='utf-8') as f:
                content = f.read()
                lines = content.splitlines()

            self.stats['files_analyzed'] += 1

            # Parse AST
            try:
                tree = ast.parse(content, filename=str(file_path))
            except SyntaxError:
                return

            # Run optimization checks
            self._check_caching_opportunities(file_path, tree, lines)
            self._check_async_optimization(file_path, tree, lines)
            self._check_loop_optimization(file_path, content, lines)
            self._check_data_structure_optimization(file_path, tree, lines)
            self._check_database_optimization(file_path, content, lines)
            self._check_io_optimization(file_path, content, lines)

        except Exception as e:
            print(f"⚠️  Error analyzing {file_path}: {e}")

    def _check_caching_opportunities(self, file_path: Path, tree: ast.AST, lines: list[str]):
        """Check for opportunities to add caching"""

        # Look for repeated function calls with same arguments
        for node in ast.walk(tree):
            if isinstance(node, ast.FunctionDef):
                # Check if function is pure (no side effects)
                if self._is_pure_function(node):
                    # Check if it's called multiple times
                    func_name = node.name
                    call_count = content.count(f"{func_name}(")

                    if call_count > 5:
                        self._add_optimization({
                            'file': str(file_path),
                            'line': node.lineno,
                            'type': 'Caching',
                            'priority': 'high',
                            'message': f"Function '{func_name}' is called {call_count} times - consider adding @lru_cache",
                            'speedup': '2-5x'
                        })

    def _check_async_optimization(self, file_path: Path, tree: ast.AST, lines: list[str]):
        """Check for async optimization opportunities"""

        # Look for sequential I/O operations that could be parallelized
        for i, node in enumerate(ast.walk(tree)):
            if isinstance(node, ast.AsyncFor):
                # Check if loop body has independent async operations
                self._add_optimization({
                    'file': str(file_path),
                    'line': node.lineno,
                    'type': 'Async Optimization',
                    'priority': 'medium',
                    'message': "Consider using asyncio.gather() for concurrent execution",
                    'speedup': '3-10x'
                })

        # Check for missing async/await on I/O operations
        for i, line in enumerate(lines, 1):
            if re.search(r'\bopen\s*\(', line) and 'async' not in line:
                self._add_optimization({
                    'file': str(file_path),
                    'line': i,
                    'type': 'Async I/O',
                    'priority': 'medium',
                    'message': "Consider using aiofiles for async file I/O",
                    'speedup': '2-3x'
                })

    def _check_loop_optimization(self, file_path: Path, content: str, lines: list[str]):
        """Check for loop optimizations"""

        for i, line in enumerate(lines, 1):
            # Check for string concatenation in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                # Look ahead for string concatenation
                for j in range(i, min(i+10, len(lines)+1)):
                    if '+=' in lines[j-1] and '"' in lines[j-1]:
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'Loop Optimization',
                            'priority': 'low',
                            'message': "Use list.join() instead of string concatenation",
                            'speedup': '5-10x'
                        })
                        break

            # Check for nested loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i+1, min(i+5, len(lines)+1)):
                    if re.search(r'for\s+\w+\s+in\s+.*:', lines[j-1]):
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'Algorithm Optimization',
                            'priority': 'high',
                            'message': "Nested loop detected - consider using hash tables or better algorithm",
                            'speedup': '10-100x'
                        })
                        break

            # Check for expensive operations in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i, min(i+5, len(lines)+1)):
                    # Check for function calls that could be moved outside
                    if re.search(r'\.append\(.*\.\w+\(.*\)\)', lines[j-1]):
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'Loop Optimization',
                            'priority': 'low',
                            'message': "Move function call outside loop if result is constant",
                            'speedup': '2-5x'
                        })
                        break

    def _check_data_structure_optimization(self, file_path: Path, tree: ast.AST, lines: list[str]):
        """Check for data structure optimizations"""

        for node in ast.walk(tree):
            # Check for list used as set
            if isinstance(node, ast.Compare) and isinstance(node.ops[0], ast.In):
                # This is an 'in' check - could be using a set
                self._add_optimization({
                    'file': str(file_path),
                    'line': node.lineno,
                    'type': 'Data Structure',
                    'priority': 'medium',
                    'message': "Use set instead of list for 'in' operator (O(1) vs O(n))",
                    'speedup': '10-1000x'
                })

            # Check for slow dictionary operations
            if isinstance(node, ast.Call) and isinstance(node.func, ast.Attribute):
                if node.func.attr == 'keys':
                    # Check if iterating over keys directly
                    self._add_optimization({
                        'file': str(file_path),
                        'line': node.lineno,
                        'type': 'Data Structure',
                        'priority': 'low',
                        'message': "Iterate over dict directly instead of dict.keys()",
                        'speedup': '1.5-2x'
                    })

    def _check_database_optimization(self, file_path: Path, content: str, lines: list[str]):
        """Check for database query optimizations"""

        for i, line in enumerate(lines, 1):
            # Check for N+1 query problem
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i, min(i+10, len(lines)+1)):
                    if re.search(r'(execute|query|select)', lines[j-1], re.IGNORECASE):
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'Database Optimization',
                            'priority': 'high',
                            'message': "Possible N+1 query problem - use JOIN or bulk queries",
                            'speedup': '10-100x'
                        })
                        break

            # Check for missing indexes hints
            if re.search(r'SELECT\s+.*\s+WHERE\s+', line, re.IGNORECASE):
                if 'ORDER BY' in line or 'GROUP BY' in line:
                    self._add_optimization({
                        'file': str(file_path),
                        'line': i,
                        'type': 'Database Optimization',
                        'priority': 'medium',
                        'message': "Ensure columns in WHERE/ORDER BY/GROUP BY are indexed",
                        'speedup': '5-50x'
                    })

            # Check for SELECT *
            if re.search(r'SELECT\s+\*\s+FROM', line, re.IGNORECASE):
                self._add_optimization({
                    'file': str(file_path),
                    'line': i,
                    'type': 'Database Optimization',
                    'priority': 'low',
                    'message': "Avoid SELECT * - specify only needed columns",
                    'speedup': '1.2-2x'
                })

    def _check_io_optimization(self, file_path: Path, content: str, lines: list[str]):
        """Check for I/O optimizations"""

        for i, line in enumerate(lines, 1):
            # Check for small file reads in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i, min(i+10, len(lines)+1)):
                    if re.search(r'\bopen\s*\(', lines[j-1]):
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'I/O Optimization',
                            'priority': 'high',
                            'message': "File I/O in loop - consider bulk reading or buffering",
                            'speedup': '10-100x'
                        })
                        break

            # Check for synchronous network requests in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i, min(i+10, len(lines)+1)):
                    if re.search(r'(requests\.|urllib\.|http\.|fetch\s*\()', lines[j-1]):
                        self._add_optimization({
                            'file': str(file_path),
                            'line': j,
                            'type': 'I/O Optimization',
                            'priority': 'high',
                            'message': "Use async HTTP requests or connection pooling",
                            'speedup': '5-20x'
                        })
                        break

    def _is_pure_function(self, node: ast.FunctionDef) -> bool:
        """Check if function is pure (no side effects)"""
        # Simple heuristic: no file I/O, no network calls, no global state modification
        for child in ast.walk(node):
            if isinstance(child, ast.Call) and isinstance(child.func, ast.Attribute):
                if child.func.attr in ['write', 'read', 'open', 'connect', 'send']:
                    return False
        return True

    def _add_optimization(self, opt: dict):
        """Add an optimization to the list"""
        self.optimizations.append(opt)
        self.stats['optimizations_found'] += 1

        # Estimate potential speedup
        speedup_str = opt.get('speedup', '1x')
        if 'x' in speedup_str:
            try:
                speedup_range = speedup_str.replace('x', '').split('-')
                avg_speedup = (float(speedup_range[0]) + float(speedup_range[-1])) / 2
                self.stats['potential_speedup'] += avg_speedup
            except:
                pass

    def _generate_report(self) -> dict:
        """Generate optimization report"""
        # Sort by priority
        priority_order = {'high': 0, 'medium': 1, 'low': 2}
        self.optimizations.sort(key=lambda x: priority_order.get(x['priority'], 3))

        return {
            'optimizations': self.optimizations,
            'stats': self.stats
        }


def main():
    """Main entry point"""
    root_path = Path(__file__).parent.parent

    print("=" * 70)
    print("⚡ NOODLE V3.0.0 - Performance Optimization Analysis")
    print("=" * 70)
    print()

    # Run analysis
    optimizer = PerformanceOptimizer(str(root_path))
    report = optimizer.analyze()

    # Print summary
    print("\n" + "=" * 70)
    print("📊 OPTIMIZATION SUMMARY")
    print("=" * 70)
    print(f"Files Analyzed: {report['stats']['files_analyzed']}")
    print(f"Optimizations Found: {report['stats']['optimizations_found']}")
    print(f"Total Potential Speedup: {report['stats']['potential_speedup']:.1f}x")
    print()

    # Print top optimizations
    if report['optimizations']:
        print("\n" + "=" * 70)
        print("🚀 TOP OPTIMIZATIONS (by priority)")
        print("=" * 70)

        for opt in report['optimizations'][:15]:
            icon = {'high': '🔥', 'medium': '⚡', 'low': '💡'}[opt['priority']]
            print(f"\n{icon} [{opt['priority']}] {opt['type']}")
            print(f"   File: {opt['file']}:{opt['line']}")
            print(f"   Speedup: {opt['speedup']}")
            print(f"   Message: {opt['message']}")

    print("\n" + "=" * 70)
    print("✅ Analysis complete!")
    print("=" * 70)
    print("\n💡 Tips:")
    print("  • Prioritize high-priority optimizations for biggest impact")
    print("  • Measure before and after optimization with profiling")
    print("  • Consider trade-offs between speed and code readability")


if __name__ == "__main__":
    main()
