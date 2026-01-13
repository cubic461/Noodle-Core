# NoodleCore API Migration Guide

## Table of Contents
1. [Overview](#overview)
2. [Migration Principles](#migration-principles)
3. [Version-Specific Migration Guides](#version-specific-migration-guides)
4. [Breaking Changes](#breaking-changes)
5. [Backward Compatibility](#backward-compatibility)
6. [Migration Tools](#migration-tools)
7. [Testing Migration](#testing-migration)
8. [Common Issues](#common-issues)

## Overview

This migration guide provides detailed instructions for updating your NoodleCore code when new versions are released. NoodleCore follows semantic versioning, and this guide will help you navigate breaking changes and ensure smooth transitions between versions.

### Version Scheme

- **Major (X.0.0)**: Breaking changes
- **Minor (X.Y.0)**: New features, backward compatible
- **Patch (X.Y.Z)**: Bug fixes, backward compatible

### Supported Versions

- **Current Stable**: 0.1.0
- **Previous**: None (initial release)
- **Next**: 0.2.0 (planned)

## Migration Principles

### 1. Progressive Migration
- Migrate components incrementally
- Test each component thoroughly
- Maintain parallel compatibility during transition

### 2. Automated Tools
- Use provided migration scripts
- Leverage static analysis tools
- Implement automated testing

### 3. Documentation
- Update code documentation
- Update inline comments
- Update external documentation

### 4. Testing
- Write comprehensive tests
- Test edge cases
- Performance regression testing

## Version-Specific Migration Guides

### From 0.1.0 to 0.2.0 (Planned)

#### Database API Changes

**Before (0.1.0):**
```python
from noodlecore.database import Database

# Old API
db = Database()
result = db.execute_query("SELECT * FROM users")
```

**After (0.2.0):**
```python
from noodlecore.database import DatabaseManager

# New API
db_manager = DatabaseManager()
result = db_manager.execute_query("SELECT * FROM users")
```

**Migration Steps:**
1. Replace `Database` with `DatabaseManager`
2. Update method calls to use manager pattern
3. Add connection management

**Migration Script:**
```python
import re

def migrate_database_imports(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Replace imports
    content = re.sub(
        r'from noodlecore\.database import Database',
        'from noodlecore.database import DatabaseManager',
        content
    )
    
    # Replace usage
    content = re.sub(
        r'db = Database\(\)',
        'db_manager = DatabaseManager()',
        content
    )
    
    # Replace method calls
    content = re.sub(
        r'db\.execute_query',
        'db_manager.execute_query',
        content
    )
    
    with open(file_path, 'w') as f:
        f.write(content)
```

#### Runtime API Changes

**Before (0.1.0):**
```python
from noodlecore.runtime import Runtime

# Old API
runtime = Runtime()
result = runtime.execute_bytecode(bytecode)
```

**After (0.2.0):**
```python
from noodlecore.runtime import RuntimeEnvironment

# New API
runtime = RuntimeEnvironment()
result = runtime.execute(bytecode)
```

**Migration Steps:**
1. Replace `Runtime` with `RuntimeEnvironment`
2. Update method names (`execute_bytecode` → `execute`)
3. Update parameter handling

**Migration Script:**
```python
def migrate_runtime_imports(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Replace imports
    content = re.sub(
        r'from noodlecore\.runtime import Runtime',
        'from noodlecore.runtime import RuntimeEnvironment',
        content
    )
    
    # Replace class usage
    content = re.sub(
        r'Runtime\(\)',
        'RuntimeEnvironment()',
        content
    )
    
    # Replace method calls
    content = re.sub(
        r'execute_bytecode',
        'execute',
        content
    )
    
    with open(file_path, 'w') as f:
        f.write(content)
```

#### Compiler API Changes

**Before (0.1.0):**
```python
from noodlecore.compiler import Compiler

# Old API
compiler = Compiler()
result = compiler.compile(source_code)
```

**After (0.2.0):**
```python
from noodlecore.compiler import NoodleCompiler

# New API
compiler = NoodleCompiler()
result = compiler.compile_source(source_code, filename)
```

**Migration Steps:**
1. Replace `Compiler` with `NoodleCompiler`
2. Update method names (`compile` → `compile_source`)
3. Add required filename parameter

**Migration Script:**
```python
def migrate_compiler_imports(file_path):
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Replace imports
    content = re.sub(
        r'from noodlecore\.compiler import Compiler',
        'from noodlecore.compiler import NoodleCompiler',
        content
    )
    
    # Replace class usage
    content = re.sub(
        r'Compiler\(\)',
        'NoodleCompiler()',
        content
    )
    
    # Replace method calls
    content = re.sub(
        r'compile\(',
        'compile_source(',
        content
    )
    
    with open(file_path, 'w') as f:
        f.write(content)
```

## Breaking Changes

### 1. Database API Changes

#### Change Summary
- `Database` class renamed to `DatabaseManager`
- Method signatures updated for better consistency
- Connection management enhanced

#### Impact Assessment
- **High Impact**: Direct database usage
- **Medium Impact**: Database configuration
- **Low Impact**: Read-only queries

#### Migration Priority
- **Critical**: Production systems
- **High**: Development environments
- **Medium**: Testing environments

### 2. Runtime API Changes

#### Change Summary
- `Runtime` class renamed to `RuntimeEnvironment`
- Method names standardized
- FFI interface enhanced

#### Impact Assessment
- **High Impact**: Direct runtime usage
- **Medium Impact**: FFI integrations
- **Low Impact**: Simple execution

#### Migration Priority
- **Critical**: Production systems
- **High**: Development environments
- **Medium**: Testing environments

### 3. Compiler API Changes

#### Change Summary
- `Compiler` class renamed to `NoodleCompiler`
- Method signatures enhanced
- Error handling improved

#### Impact Assessment
- **High Impact**: Direct compilation usage
- **Medium Impact**: Build systems
- **Low Impact**: Simple compilation

#### Migration Priority
- **Critical**: Production systems
- **High**: Development environments
- **Medium**: Testing environments

## Backward Compatibility

### Compatibility Matrix

| Component | 0.1.0 | 0.2.0 | 0.3.0 |
|-----------|-------|-------|-------|
| Compiler  | ✅    | ⚠️    | ❌    |
| Runtime   | ✅    | ⚠️    | ❌    |
| Database  | ✅    | ⚠️    | ❌    |
| Math      | ✅    | ✅    | ✅    |
| Optimization | ✅  | ✅    | ✅    |

### Compatibility Layers

#### Legacy Support Module
```python
from noodlecore.legacy import LegacyCompiler, LegacyRuntime, LegacyDatabase

# Use legacy APIs with warnings
compiler = LegacyCompiler()
result = compiler.compile(source_code)  # Shows deprecation warning

runtime = LegacyRuntime()
result = runtime.execute_bytecode(bytecode)  # Shows deprecation warning

db = LegacyDatabase()
result = db.execute_query("SELECT * FROM users")  # Shows deprecation warning
```

#### Adapter Pattern
```python
from noodlecore.database import DatabaseManager
from noodlecore.legacy import LegacyDatabase

class DatabaseAdapter:
    def __init__(self):
        self.manager = DatabaseManager()
        self.legacy = LegacyDatabase()
    
    def execute_query(self, query, params=None):
        # Use new API internally
        return self.manager.execute_query(query, params)
    
    def __getattr__(self, name):
        # Forward to legacy API for backward compatibility
        return getattr(self.legacy, name)
```

### Deprecation Strategy

#### 1. Warning Phase
- Add deprecation warnings
- Maintain full functionality
- Update documentation

#### 2. Transition Phase
- Add migration helpers
- Provide automated tools
- Enhanced error messages

#### 3. Removal Phase
- Remove deprecated APIs
- Update examples
- Clean up codebase

## Migration Tools

### Automated Migration Script

```python
#!/usr/bin/env python3
"""
NoodleCore Migration Tool
Automatically migrates code from older versions to newer versions
"""

import os
import re
import argparse
import ast
import logging
from pathlib import Path
from typing import List, Dict, Any

class NoodleCoreMigrator:
    def __init__(self, version_from: str, version_to: str):
        self.version_from = version_from
        self.version_to = version_to
        self.migration_rules = self._load_migration_rules()
        self.logger = self._setup_logger()
    
    def _load_migration_rules(self) -> Dict[str, Any]:
        """Load migration rules for specific version transitions"""
        return {
            "0.1.0_to_0.2.0": {
                "imports": {
                    "noodlecore.database.Database": "noodlecore.database.DatabaseManager",
                    "noodlecore.runtime.Runtime": "noodlecore.runtime.RuntimeEnvironment",
                    "noodlecore.compiler.Compiler": "noodlecore.compiler.NoodleCompiler",
                },
                "methods": {
                    "Database.execute_query": "DatabaseManager.execute_query",
                    "Runtime.execute_bytecode": "RuntimeEnvironment.execute",
                    "Compiler.compile": "NoodleCompiler.compile_source",
                },
                "class_names": {
                    "Database": "DatabaseManager",
                    "Runtime": "RuntimeEnvironment",
                    "Compiler": "NoodleCompiler",
                }
            }
        }
    
    def _setup_logger(self) -> logging.Logger:
        """Setup logging configuration"""
        logger = logging.getLogger("NoodleCoreMigrator")
        logger.setLevel(logging.INFO)
        
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
        
        return logger
    
    def migrate_file(self, file_path: Path) -> bool:
        """Migrate a single file"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            
            # Apply migration rules
            rules = self.migration_rules.get(f"{self.version_from}_to_{self.version_to}")
            if not rules:
                self.logger.warning(f"No migration rules found for {self.version_from} to {self.version_to}")
                return False
            
            # Apply import changes
            for old_import, new_import in rules["imports"].items():
                content = content.replace(old_import, new_import)
            
            # Apply method changes
            for old_method, new_method in rules["methods"].items():
                content = content.replace(old_method, new_method)
            
            # Apply class name changes
            for old_class, new_class in rules["class_names"].items():
                content = content.replace(old_class, new_class)
            
            # Write back if changed
            if content != original_content:
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(content)
                
                self.logger.info(f"Migrated: {file_path}")
                return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Error migrating {file_path}: {e}")
            return False
    
    def migrate_directory(self, directory: Path, file_patterns: List[str] = None) -> Dict[str, int]:
        """Migrate all files in a directory"""
        if file_patterns is None:
            file_patterns = ["*.py"]
        
        stats = {
            "total": 0,
            "migrated": 0,
            "errors": 0
        }
        
        for pattern in file_patterns:
            for file_path in directory.rglob(pattern):
                stats["total"] += 1
                try:
                    if self.migrate_file(file_path):
                        stats["migrated"] += 1
                except Exception as e:
                    stats["errors"] += 1
                    self.logger.error(f"Error migrating {file_path}: {e}")
        
        return stats
    
    def generate_migration_report(self, stats: Dict[str, int]) -> str:
        """Generate a migration report"""
        report = f"""
NoodleCore Migration Report
==========================
From: {self.version_from}
To: {self.version_to}

Files Processed: {stats['total']}
Files Migrated: {stats['migrated']}
Errors: {stats['errors']}

Success Rate: {stats['migrated'] / stats['total'] * 100:.1f}%
"""
        return report

def main():
    parser = argparse.ArgumentParser(description="NoodleCore Migration Tool")
    parser.add_argument("directory", help="Directory to migrate")
    parser.add_argument("--from", dest="version_from", default="0.1.0", help="Source version")
    parser.add_argument("--to", dest="version_to", default="0.2.0", help="Target version")
    parser.add_argument("--patterns", nargs="+", default=["*.py"], help="File patterns to migrate")
    parser.add_argument("--report", help="Generate migration report file")
    
    args = parser.parse_args()
    
    migrator = NoodleCoreMigrator(args.version_from, args.version_to)
    directory = Path(args.directory)
    
    if not directory.exists():
        print(f"Error: Directory {directory} does not exist")
        return 1
    
    stats = migrator.migrate_directory(directory, args.patterns)
    report = migrator.generate_migration_report(stats)
    
    print(report)
    
    if args.report:
        with open(args.report, 'w') as f:
            f.write(report)
        print(f"Migration report saved to: {args.report}")
    
    return 0

if __name__ == "__main__":
    exit(main())
```

### Static Analysis Tool

```python
#!/usr/bin/env python3
"""
NoodleCore Static Analysis Tool
Analyzes code for potential migration issues
"""

import ast
import os
from pathlib import Path
from typing import List, Dict, Any, Set

class MigrationAnalyzer(ast.NodeVisitor):
    def __init__(self):
        self.issues: List[Dict[str, Any]] = []
        self.imports: Set[str] = set()
        self.used_classes: Set[str] = set()
        self.used_methods: Set[str] = set()
    
    def visit_Import(self, node):
        for alias in node.names:
            self.imports.add(alias.name)
        self.generic_visit(node)
    
    def visit_ImportFrom(self, node):
        if node.module:
            self.imports.add(node.module)
        self.generic_visit(node)
    
    def visit_Attribute(self, node):
        if isinstance(node.value, ast.Name):
            self.used_methods.add(f"{node.value.id}.{node.attr}")
        self.generic_visit(node)
    
    def visit_Name(self, node):
        self.used_classes.add(node.id)
        self.generic_visit(node)
    
    def analyze_file(self, file_path: Path) -> List[Dict[str, Any]]:
        """Analyze a file for migration issues"""
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            tree = ast.parse(content)
            self.issues = []
            self.imports = set()
            self.used_classes = set()
            self.used_methods = set()
            
            self.visit(tree)
            
            # Check for deprecated imports
            deprecated_imports = {
                "noodlecore.database.Database",
                "noodlecore.runtime.Runtime",
                "noodlecore.compiler.Compiler",
            }
            
            for imp in self.imports:
                if imp in deprecated_imports:
                    self.issues.append({
                        "type": "deprecated_import",
                        "message": f"Deprecated import: {imp}",
                        "file": str(file_path),
                        "severity": "high"
                    })
            
            # Check for deprecated class usage
            deprecated_classes = {
                "Database",
                "Runtime",
                "Compiler",
            }
            
            for cls in self.used_classes:
                if cls in deprecated_classes:
                    self.issues.append({
                        "type": "deprecated_class",
                        "message": f"Deprecated class usage: {cls}",
                        "file": str(file_path),
                        "severity": "high"
                    })
            
            # Check for deprecated method usage
            deprecated_methods = {
                "Database.execute_query",
                "Runtime.execute_bytecode",
                "Compiler.compile",
            }
            
            for method in self.used_methods:
                if method in deprecated_methods:
                    self.issues.append({
                        "type": "deprecated_method",
                        "message": f"Deprecated method usage: {method}",
                        "file": str(file_path),
                        "severity": "high"
                    })
            
            return self.issues
            
        except Exception as e:
            return [{
                "type": "parse_error",
                "message": f"Error parsing file: {e}",
                "file": str(file_path),
                "severity": "critical"
            }]

def analyze_directory(directory: Path) -> Dict[str, Any]:
    """Analyze all files in a directory"""
    analyzer = MigrationAnalyzer()
    all_issues = []
    
    for file_path in directory.rglob("*.py"):
        issues = analyzer.analyze_file(file_path)
        all_issues.extend(issues)
    
    # Group by severity
    by_severity = {
        "critical": [],
        "high": [],
        "medium": [],
        "low": []
    }
    
    for issue in all_issues:
        by_severity[issue["severity"]].append(issue)
    
    return {
        "total_issues": len(all_issues),
        "by_severity": by_severity,
        "files_with_issues": len(set(issue["file"] for issue in all_issues))
    }

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="NoodleCore Static Analysis Tool")
    parser.add_argument("directory", help="Directory to analyze")
    
    args = parser.parse_args()
    
    directory = Path(args.directory)
    if not directory.exists():
        print(f"Error: Directory {directory} does not exist")
        return 1
    
    results = analyze_directory(directory)
    
    print(f"Analysis Results for {directory}")
    print("=" * 50)
    print(f"Total Issues: {results['total_issues']}")
    print(f"Files with Issues: {results['files_with_issues']}")
    
    for severity, issues in results["by_severity"].items():
        if issues:
            print(f"\n{severity.upper()} ({len(issues)} issues):")
            for issue in issues:
                print(f"  - {issue['message']} ({issue['file']})")
    
    return 0

if __name__ == "__main__":
    exit(main())
```

## Testing Migration

### Unit Testing

```python
import unittest
from noodlecore.migration import MigrationAnalyzer, NoodleCoreMigrator
from pathlib import Path

class TestMigration(unittest.TestCase):
    def setUp(self):
        self.test_dir = Path("test_migration")
        self.test_dir.mkdir(exist_ok=True)
        
        # Create test files
        (self.test_dir / "old_code.py").write_text("""
from noodlecore.database import Database
from noodlecore.runtime import Runtime
from noodlecore.compiler import Compiler

db = Database()
result = db.execute_query("SELECT * FROM users")

runtime = Runtime()
result = runtime.execute_bytecode(bytecode)

compiler = Compiler()
result = compiler.compile(source_code)
""")
    
    def tearDown(self):
        import shutil
        if self.test_dir.exists():
            shutil.rmtree(self.test_dir)
    
    def test_migration_analysis(self):
        analyzer = MigrationAnalyzer()
        issues = analyzer.analyze_file(self.test_dir / "old_code.py")
        
        self.assertEqual(len(issues), 6)  # 3 imports + 3 methods
        self.assertTrue(any(issue["type"] == "deprecated_import" for issue in issues))
        self.assertTrue(any(issue["type"] == "deprecated_class" for issue in issues))
        self.assertTrue(any(issue["type"] == "deprecated_method" for issue in issues))
    
    def test_file_migration(self):
        migrator = NoodleCoreMigrator("0.1.0", "0.2.0")
        migrated = migrator.migrate_file(self.test_dir / "old_code.py")
        
        self.assertTrue(migrated)
        
        # Check that file was migrated
        content = (self.test_dir / "old_code.py").read_text()
        self.assertIn("DatabaseManager", content)
        self.assertIn("RuntimeEnvironment", content)
        self.assertIn("NoodleCompiler", content)
    
    def test_directory_migration(self):
        migrator = NoodleCoreMigrator("0.1.0", "0.2.0")
        stats = migrator.migrate_directory(self.test_dir)
        
        self.assertEqual(stats["total"], 1)
        self.assertEqual(stats["migrated"], 1)
        self.assertEqual(stats["errors"], 0)

if __name__ == "__main__":
    unittest.main()
```

### Integration Testing

```python
import unittest
from noodlecore import compile_code, execute_code
from noodlecore.database import DatabaseManager
from noodlecore.runtime import RuntimeEnvironment
from noodlecore.compiler import NoodleCompiler

class TestMigrationIntegration(unittest.TestCase):
    def test_new_api_functionality(self):
        # Test that new APIs work correctly
        db_manager = DatabaseManager()
        runtime = RuntimeEnvironment()
        compiler = NoodleCompiler()
        
        # Test compilation
        source_code = "x = 5 + 3"
        bytecode, errors = compiler.compile_source(source_code, "test.noodle")
        self.assertIsNone(errors)
        self.assertIsNotNone(bytecode)
        
        # Test execution
        result = runtime.execute(bytecode)
        self.assertEqual(result.data, 8)
        
        # Test database operations
        db_manager.add_connection("test", "sqlite:///:memory:")
        db_manager.create_table("test_table", {
            "id": {"type": "INTEGER", "primary_key": True},
            "name": {"type": "TEXT"}
        })
        
        # Insert and query
        db_manager.insert("test_table", {"name": "test"})
        result = db_manager.select("test_table")
        self.assertEqual(len(result.rows), 1)
        self.assertEqual(result.rows[0]["name"], "test")
    
    def test_backward_compatibility(self):
        # Test that legacy compatibility layer works
        from noodlecore.legacy import LegacyCompiler, LegacyRuntime, LegacyDatabase
        
        # Test legacy compiler
        legacy_compiler = LegacyCompiler()
        result = legacy_compiler.compile("x = 5 + 3")
        self.assertIsNotNone(result)
        
        # Test legacy runtime
        legacy_runtime = LegacyRuntime()
        result = legacy_runtime.execute_bytecode(result)
        self.assertEqual(result, 8)
        
        # Test legacy database
        legacy_db = LegacyDatabase()
        result = legacy_db.execute_query("SELECT 1")
        self.assertIsNotNone(result)

if __name__ == "__main__":
    unittest.main()
```

## Common Issues

### 1. Import Path Changes

**Issue:**
```python
# Old import
from noodlecore.database import Database

# Error after migration
from noodlecore.database import DatabaseManager  # Wrong class name
```

**Solution:**
```python
# Correct import
from noodlecore.database import DatabaseManager

# Correct usage
db_manager = DatabaseManager()
```

### 2. Method Signature Changes

**Issue:**
```python
# Old method call
db.execute_query("SELECT * FROM users")

# Error after migration
db_manager.execute_query("SELECT * FROM users")  # Missing parameters
```

**Solution:**
```python
# Correct method call
db_manager.execute_query("SELECT * FROM users", params=None)
```

### 3. Class Name Changes

**Issue:**
```python
# Old class usage
runtime = Runtime()

# Error after migration
runtime = RuntimeEnvironment()  # Wrong constructor
```

**Solution:**
```python
# Correct class usage
runtime = RuntimeEnvironment()
```

### 4. Parameter Order Changes

**Issue:**
```python
# Old parameter order
compiler.compile(source_code)

# Error after migration
compiler.compile_source(source_code)  # Missing filename parameter
```

**Solution:**
```python
# Correct parameter order
compiler.compile_source(source_code, "example.noodle")
```

### 5. Return Type Changes

**Issue:**
```python
# Old return type handling
result = db.execute_query("SELECT * FROM users")
print(result.rows)  # AttributeError

# Error after migration
result = db_manager.execute_query("SELECT * FROM users")
print(result.rows)  # Still AttributeError
```

**Solution:**
```python
# Correct return type handling
result = db_manager.execute_query("SELECT * FROM users")
print(result.rows)  # Correct attribute access
```

### 6. Error Handling Changes

**Issue:**
```python
# Old error handling
try:
    result = db.execute_query("INVALID QUERY")
except DatabaseError as e:
    print(f"Database error: {e}")

# Error after migration
try:
    result = db_manager.execute_query("INVALID QUERY")
except DatabaseError as e:
    print(f"Database error: {e}")  # Different error type
```

**Solution:**
```python
# Correct error handling
try:
    result = db_manager.execute_query("INVALID QUERY")
except Exception as e:
    print(f"Error: {e}")  # Catch generic exception
```

## Best Practices

### 1. Before Migration

1. **Backup Your Code**
   ```bash
   cp -r /path/to/your/project /path/to/your/project.backup
   ```

2. **Run Tests**
   ```bash
   python -m pytest tests/
   ```

3. **Check Dependencies**
   ```bash
   pip list | grep noodlecore
   ```

4. **Review Breaking Changes**
   - Read the migration guide
   - Check the changelog
   - Understand the impact

### 2. During Migration

1. **Use Automated Tools**
   ```bash
   python migration_tool.py /path/to/your/project --from 0.1.0 --to 0.2.0
   ```

2. **Run Static Analysis**
   ```bash
   python static_analysis.py /path/to/your/project
   ```

3. **Test Incrementally**
   - Migrate one component at a time
   - Test each component thoroughly
   - Don't move to the next until all tests pass

4. **Use Version Control**
   ```bash
   git add .
   git commit -m "Start migration to 0.2.0"
   ```

### 3. After Migration

1. **Run Full Test Suite**
   ```bash
   python -m pytest tests/
   ```

2. **Check Performance**
   ```bash
   python performance_benchmark.py
   ```

3. **Update Documentation**
   - Update inline comments
   - Update external documentation
   - Update README files

4. **Monitor for Issues**
   - Set up monitoring
   - Log any errors
   - Be prepared to rollback if needed

## Conclusion

Migration to newer versions of NoodleCore should be a systematic process. By following this guide and using the provided tools, you can ensure a smooth transition with minimal disruption to your applications.

Remember to:
1. Always backup your code before migration
2. Test thoroughly after each step
3. Use the provided migration tools
4. Monitor for issues after migration
5. Keep your dependencies updated

For additional help, refer to the NoodleCore documentation or create an issue in the project repository.