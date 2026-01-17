#!/usr/bin/env python3
"""
Code Quality Analysis and Bug Detection Script for NIP v3.0.0

This script performs comprehensive code quality checks:
- Syntax errors
- Unused imports
- Code complexity
- Security vulnerabilities
- Performance issues
- Best practices violations
"""

import ast
import os
import re
from pathlib import Path
from typing import List, Dict, Set, Tuple
import subprocess


class CodeAnalyzer:
    """Analyze Python code for quality issues"""
    
    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.issues = []
        self.stats = {
            'files_analyzed': 0,
            'total_lines': 0,
            'total_issues': 0,
            'by_severity': {'critical': 0, 'high': 0, 'medium': 0, 'low': 0}
        }
    
    def analyze(self) -> Dict:
        """Run all analysis checks"""
        print("🔍 Starting Code Quality Analysis...\n")
        
        # Find all Python files
        python_files = list(self.root_path.rglob("*.py"))
        python_files = [f for f in python_files if 
                       '.pytest_cache' not in str(f) and 
                       '__pycache__' not in str(f) and
                       '.venv' not in str(f) and
                       'node_modules' not in str(f)]
        
        print(f"📁 Found {len(python_files)} Python files\n")
        
        # Analyze each file
        for file_path in python_files:
            self._analyze_file(file_path)
        
        # Generate report
        return self._generate_report()
    
    def _analyze_file(self, file_path: Path):
        """Analyze a single Python file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.splitlines()
            
            self.stats['files_analyzed'] += 1
            self.stats['total_lines'] += len(lines)
            
            # Parse AST
            try:
                tree = ast.parse(content, filename=str(file_path))
            except SyntaxError as e:
                self._add_issue({
                    'file': str(file_path),
                    'line': e.lineno,
                    'severity': 'critical',
                    'type': 'Syntax Error',
                    'message': str(e)
                })
                return
            
            # Run checks
            self._check_unused_imports(file_path, tree, lines)
            self._check_code_complexity(file_path, tree, lines)
            self._check_security_issues(file_path, content, lines)
            self._check_performance_issues(file_path, content, lines)
            self._check_best_practices(file_path, content, lines)
            
        except Exception as e:
            print(f"⚠️  Error analyzing {file_path}: {e}")
    
    def _check_unused_imports(self, file_path: Path, tree: ast.AST, lines: List[str]):
        """Check for unused imports"""
        # Get all imports
        imports = set()
        for node in ast.walk(tree):
            if isinstance(node, ast.Import):
                for alias in node.names:
                    imports.add(alias.name.split('.')[0])
            elif isinstance(node, ast.ImportFrom):
                if node.module:
                    imports.add(node.module.split('.')[0])
        
        # Check if imports are used
        content = '\n'.join(lines)
        for imp in imports:
            # Simple check: does import name appear in code?
            pattern = r'\b' + re.escape(imp) + r'\b'
            if not re.search(pattern, content):
                # Might be used in comments or strings, check more carefully
                self._add_issue({
                    'file': str(file_path),
                    'line': 1,
                    'severity': 'low',
                    'type': 'Unused Import',
                    'message': f"Import '{imp}' may be unused"
                })
    
    def _check_code_complexity(self, file_path: Path, tree: ast.AST, lines: List[str]):
        """Check for code complexity issues"""
        for node in ast.walk(tree):
            # Check function length
            if isinstance(node, ast.FunctionDef):
                func_lines = node.end_lineno - node.lineno if hasattr(node, 'end_lineno') else 0
                if func_lines > 50:
                    self._add_issue({
                        'file': str(file_path),
                        'line': node.lineno,
                        'severity': 'medium',
                        'type': 'Long Function',
                        'message': f"Function '{node.name}' is {func_lines} lines (recommended: < 50)"
                    })
                
                # Check parameter count
                if len(node.args.args) > 7:
                    self._add_issue({
                        'file': str(file_path),
                        'line': node.lineno,
                        'severity': 'medium',
                        'type': 'Too Many Parameters',
                        'message': f"Function '{node.name}' has {len(node.args.args)} parameters (recommended: < 7)"
                    })
            
            # Check class complexity
            elif isinstance(node, ast.ClassDef):
                methods = [n for n in ast.walk(node) if isinstance(n, ast.FunctionDef)]
                if len(methods) > 20:
                    self._add_issue({
                        'file': str(file_path),
                        'line': node.lineno,
                        'severity': 'medium',
                        'type': 'Complex Class',
                        'message': f"Class '{node.name}' has {len(methods)} methods (recommended: < 20)"
                    })
    
    def _check_security_issues(self, file_path: Path, content: str, lines: List[str]):
        """Check for security vulnerabilities"""
        for i, line in enumerate(lines, 1):
            # Check for hardcoded passwords
            if re.search(r'password\s*=\s*["\'][^"\']+["\']', line, re.IGNORECASE):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'high',
                    'type': 'Security Issue',
                    'message': 'Hardcoded password detected'
                })
            
            # Check for SQL injection patterns
            if re.search(rf'execute\(["\'].*\+.*["\']', line):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'critical',
                    'type': 'SQL Injection Risk',
                    'message': 'Possible SQL injection vulnerability - use parameterized queries'
                })
            
            # Check for shell injection
            if re.search(r'system\(["\'].*\+.*["\']', line) or re.search(r'popen\(["\'].*\+.*["\']', line):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'critical',
                    'type': 'Shell Injection Risk',
                    'message': 'Possible shell injection vulnerability - use subprocess.run with list args'
                })
            
            # Check for weak cryptography
            if 'md5' in line.lower() or 'sha1' in line.lower():
                if not line.strip().startswith('#'):
                    self._add_issue({
                        'file': str(file_path),
                        'line': i,
                        'severity': 'medium',
                        'type': 'Weak Cryptography',
                        'message': 'MD5 and SHA1 are considered weak - use SHA256 or stronger'
                    })
            
            # Check for eval usage
            if re.search(r'\beval\s*\(', line):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'high',
                    'type': 'Dangerous Function',
                    'message': 'Use of eval() is dangerous - consider alternatives'
                })
    
    def _check_performance_issues(self, file_path: Path, content: str, lines: List[str]):
        """Check for performance issues"""
        for i, line in enumerate(lines, 1):
            # Check for string concatenation in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                # Look ahead a few lines
                for j in range(i, min(i+10, len(lines)+1)):
                    if '+=' in lines[j-1] and '"' in lines[j-1]:
                        self._add_issue({
                            'file': str(file_path),
                            'line': j,
                            'severity': 'low',
                            'type': 'Performance Issue',
                            'message': 'String concatenation in loop - use list join instead'
                        })
                        break
            
            # Check for expensive operations in loops
            if re.search(r'for\s+\w+\s+in\s+.*:', line):
                for j in range(i, min(i+5, len(lines)+1)):
                    if re.search(r'\.append\(.*\.\w+\(.*\)\)', lines[j-1]):
                        self._add_issue({
                            'file': str(file_path),
                            'line': j,
                            'severity': 'low',
                            'type': 'Performance Issue',
                            'message': 'Function call in loop - consider moving outside if constant'
                        })
                        break
    
    def _check_best_practices(self, file_path: Path, content: str, lines: List[str]):
        """Check for best practices violations"""
        has_docstring = False
        
        for i, line in enumerate(lines, 1):
            # Check for docstrings
            if i == 1 and '"""' in line:
                has_docstring = True
            
            # Check for print statements (should use logging)
            if re.search(r'^\s*print\s*\(', line) and not line.strip().startswith('#'):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'low',
                    'type': 'Best Practice',
                    'message': 'Consider using logging instead of print'
                })
            
            # Check for bare except
            if re.search(r'except\s*:', line):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'medium',
                    'type': 'Bad Exception Handling',
                    'message': 'Bare except: catches all exceptions including SystemExit - specify exception type'
                })
            
            # Check for TODO/FIXME comments
            if re.search(r'#\s*(TODO|FIXME|XXX|HACK)', line, re.IGNORECASE):
                self._add_issue({
                    'file': str(file_path),
                    'line': i,
                    'severity': 'low',
                    'type': 'Code Comment',
                    'message': f'Issue comment found: {line.strip()}'
                })
        
        # Check for module docstring
        if not has_docstring and any('def ' in l for l in lines):
            self._add_issue({
                'file': str(file_path),
                'line': 1,
                'severity': 'low',
                'type': 'Missing Docstring',
                'message': 'Module should have a docstring'
            })
    
    def _add_issue(self, issue: Dict):
        """Add an issue to the list"""
        self.issues.append(issue)
        self.stats['total_issues'] += 1
        severity = issue['severity']
        if severity in self.stats['by_severity']:
            self.stats['by_severity'][severity] += 1
    
    def _generate_report(self) -> Dict:
        """Generate analysis report"""
        # Sort issues by severity
        severity_order = {'critical': 0, 'high': 1, 'medium': 2, 'low': 3}
        self.issues.sort(key=lambda x: severity_order.get(x['severity'], 4))
        
        return {
            'issues': self.issues,
            'stats': self.stats
        }


class BugFixer:
    """Automatically fix common issues"""
    
    def __init__(self, root_path: str):
        self.root_path = Path(root_path)
        self.fixes_applied = 0
    
    def fix_all(self):
        """Apply all automatic fixes"""
        print("🔧 Applying automatic fixes...\n")
        
        python_files = list(self.root_path.rglob("*.py"))
        python_files = [f for f in python_files if 
                       '.pytest_cache' not in str(f) and 
                       '__pycache__' not in str(f)]
        
        for file_path in python_files:
            self._fix_file(file_path)
        
        print(f"\n✅ Applied {self.fixes_applied} fixes")
    
    def _fix_file(self, file_path: Path):
        """Fix issues in a single file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
                lines = content.splitlines(keepends=True)
            
            modified = False
            new_lines = []
            
            for line in lines:
                original_line = line
                
                # Fix: Add encoding declaration if missing
                if not any(l.startswith('# -*- coding:') for l in lines[:5]):
                    if line.startswith('#!'):
                        new_lines.append(line)
                        new_lines.append('# -*- coding: utf-8 -*-\n')
                        modified = True
                        continue
                
                # Fix: Replace print with logging (basic pattern)
                if re.search(r'^\s*print\s*\(', line) and not 'import logging' in '\n'.join(lines):
                    indent = len(line) - len(line.lstrip())
                    line = (' ' * indent) + 'logger.info(' + line[line.find('(')+1:]
                    modified = True
                
                # Fix: Remove trailing whitespace
                if line.rstrip() != line.rstrip('\n'):
                    line = line.rstrip() + '\n'
                    modified = True
                
                # Fix: Ensure blank line at EOF
                if line == lines[-1] and line != '\n':
                    line = line + '\n'
                    modified = True
                
                new_lines.append(line)
                
                if line != original_line:
                    self.fixes_applied += 1
            
            if modified:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(new_lines)
                print(f"  ✓ Fixed {file_path.relative_to(self.root_path)}")
        
        except Exception as e:
            print(f"  ⚠️  Could not fix {file_path}: {e}")


def main():
    """Main entry point"""
    root_path = Path(__file__).parent.parent
    
    print("=" * 70)
    print("🔍 NOODLE V3.0.0 - Code Quality Analysis & Bug Detection")
    print("=" * 70)
    print()
    
    # Run analysis
    analyzer = CodeAnalyzer(str(root_path))
    report = analyzer.analyze()
    
    # Print summary
    print("\n" + "=" * 70)
    print("📊 ANALYSIS SUMMARY")
    print("=" * 70)
    print(f"Files Analyzed: {report['stats']['files_analyzed']}")
    print(f"Total Lines: {report['stats']['total_lines']:,}")
    print(f"Total Issues: {report['stats']['total_issues']}")
    print()
    print("Issues by Severity:")
    for severity, count in report['stats']['by_severity'].items():
        if count > 0:
            icon = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🟢'}[severity]
            print(f"  {icon} {severity.capitalize()}: {count}")
    
    # Print top issues
    if report['issues']:
        print("\n" + "=" * 70)
        print("🔝 TOP ISSUES (by severity)")
        print("=" * 70)
        
        for issue in report['issues'][:20]:  # Show top 20
            icon = {'critical': '🔴', 'high': '🟠', 'medium': '🟡', 'low': '🟢'}[issue['severity']]
            print(f"\n{icon} [{issue['severity']}] {issue['type']}")
            print(f"   File: {issue['file']}:{issue['line']}")
            print(f"   Message: {issue['message']}")
    
    # Ask about automatic fixes
    if report['stats']['total_issues'] > 0:
        print("\n" + "=" * 70)
        print("🔧 AUTOMATIC FIXES")
        print("=" * 70)
        
        response = input("\nWould you like to apply automatic fixes? (y/n): ")
        if response.lower() == 'y':
            fixer = BugFixer(str(root_path))
            fixer.fix_all()
    
    print("\n" + "=" * 70)
    print("✅ Analysis complete!")
    print("=" * 70)


if __name__ == "__main__":
    main()
