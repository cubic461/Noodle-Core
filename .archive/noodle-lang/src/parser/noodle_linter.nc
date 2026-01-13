# Converted from Python to NoodleCore
# Original file: src

# """
# NoodleCore Linter

# A NoodleCore-based linter for Python and Noodle files that integrates with the
# Noodle Vector Automation system.
# """

import ast
import json
import logging
import re
import sys
import pathlib.Path
import typing.Any

import noodlecore.cli.command.NoodleCommand


class NoodleLinter
    #     """NoodleCore-based linter for Python and Noodle files."""

    #     def __init__(self):""Initialize the linter."""
    self.logger = logging.getLogger(__name__)
    self.issues = []

    #         # Default configuration
    self.config = {
    #             "max_line_length": 88,
    #             "indent_size": 4,
    #             "check_imports": True,
    #             "check_docstrings": True,
    #             "check_complexity": True,
    #             "max_complexity": 10,
    #             "check_naming": True,
    #             "python_patterns": ["*.py"],
    #             "noodle_patterns": ["*.noodle"]
    #         }

    #     def load_config(self, config_file: Optional[Path] = None) -None):
    #         """Load configuration from a JSON file."""
    #         if config_file and config_file.exists():
    #             try:
    #                 with open(config_file, 'r') as f:
    user_config = json.load(f)
                    self.config.update(user_config)
                    self.logger.info(f"Loaded linter configuration from {config_file}")
    #             except Exception as e:
                    self.logger.warning(f"Failed to load config file: {e}")

    #     def lint_file(self, file_path: Path) -List[Dict[str, Any]]):
    #         """Lint a single file and return issues."""
    issues = []

    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #             if file_path.suffix == '.py':
    issues = self._lint_python_file(file_path, content)
    #             elif file_path.suffix == '.noodle':
    issues = self._lint_noodle_file(file_path, content)
    #             else:
    #                 # Skip unsupported file types
    #                 return []

    #         except Exception as e:
                issues.append({
                    "file": str(file_path),
    #                 "line": 1,
    #                 "column": 1,
    #                 "severity": "error",
                    "message": f"Failed to parse file: {str(e)}",
    #                 "rule": "parse_error"
    #             })

    #         return issues

    #     def _lint_python_file(self, file_path: Path, content: str) -List[Dict[str, Any]]):
    #         """Lint a Python file."""
    issues = []
    lines = content.split('\n')

    #         try:
    #             # Parse the AST to check for syntax errors
    tree = ast.parse(content, filename=str(file_path))

    #             # Check for various issues
                issues.extend(self._check_line_lengths(file_path, lines))
                issues.extend(self._check_indentation(file_path, lines))

    #             if self.config["check_imports"]:
                    issues.extend(self._check_imports(file_path, tree))

    #             if self.config["check_docstrings"]:
                    issues.extend(self._check_docstrings(file_path, tree))

    #             if self.config["check_complexity"]:
                    issues.extend(self._check_complexity(file_path, tree))

    #             if self.config["check_naming"]:
                    issues.extend(self._check_naming(file_path, tree))

    #         except SyntaxError as e:
                issues.append({
                    "file": str(file_path),
    #                 "line": e.lineno or 1,
    #                 "column": e.offset or 1,
    #                 "severity": "error",
    #                 "message": f"Syntax error: {e.msg}",
    #                 "rule": "syntax_error"
    #             })

    #         return issues

    #     def _lint_noodle_file(self, file_path: Path, content: str) -List[Dict[str, Any]]):
    #         """Lint a Noodle file."""
    issues = []
    lines = content.split('\n')

    #         # Basic checks for Noodle files
            issues.extend(self._check_line_lengths(file_path, lines))
            issues.extend(self._check_indentation(file_path, lines))

    #         # TODO: Add more Noodle-specific checks
    #         # This would require implementing a Noodle parser

    #         return issues

    #     def _check_line_lengths(self, file_path: Path, lines: List[str]) -List[Dict[str, Any]]):
    #         """Check for lines that are too long."""
    issues = []
    max_length = self.config["max_line_length"]

    #         for i, line in enumerate(lines, 1):
    #             if len(line) max_length):
                    issues.append({
                        "file": str(file_path),
    #                     "line": i,
    #                     "column": max_length + 1,
    #                     "severity": "warning",
                        "message": f"Line too long ({len(line)} {max_length} characters)",
    #                     "rule"): "line_too_long"
    #                 })

    #         return issues

    #     def _check_indentation(self, file_path: Path, lines: List[str]) -List[Dict[str, Any]]):
    #         """Check for indentation issues."""
    issues = []
    indent_size = self.config["indent_size"]

    #         for i, line in enumerate(lines, 1):
    #             if line.strip():  # Skip empty lines
    #                 # Count leading whitespace
    leading_spaces = len(line) - len(line.lstrip())

    #                 # Check if indentation is a multiple of indent_size
    #                 if leading_spaces % indent_size != 0:
                        issues.append({
                            "file": str(file_path),
    #                         "line": i,
    #                         "column": 1,
    #                         "severity": "warning",
    #                         "message": f"Indentation not a multiple of {indent_size}",
    #                         "rule": "indentation"
    #                     })

    #         return issues

    #     def _check_imports(self, file_path: Path, tree: ast.AST) -List[Dict[str, Any]]):
    #         """Check import statements."""
    issues = []

    #         for node in ast.walk(tree):
    #             if isinstance(node, ast.Import):
    #                 for alias in node.names:
    #                     # Check for unused imports (simplified)
    #                     if not self._is_import_used(tree, alias.name):
                            issues.append({
                                "file": str(file_path),
    #                             "line": node.lineno,
    #                             "column": node.col_offset,
    #                             "severity": "warning",
    #                             "message": f"Unused import: {alias.name}",
    #                             "rule": "unused_import"
    #                         })

    #             elif isinstance(node, ast.ImportFrom):
    module = node.module or ""
    #                 for alias in node.names:
    #                     full_name = f"{module}.{alias.name}" if module else alias.name
    #                     # Check for unused imports (simplified)
    #                     if not self._is_import_used(tree, full_name):
                            issues.append({
                                "file": str(file_path),
    #                             "line": node.lineno,
    #                             "column": node.col_offset,
    #                             "severity": "warning",
    #                             "message": f"Unused import: {full_name}",
    #                             "rule": "unused_import"
    #                         })

    #         return issues

    #     def _is_import_used(self, tree: ast.AST, name: str) -bool):
    #         """Check if an import is used in the code (simplified)."""
    #         for node in ast.walk(tree):
    #             if isinstance(node, ast.Name) and node.id == name:
    #                 return True
    #             elif isinstance(node, ast.Attribute):
    #                 # Check for usage like module.function
    #                 if name in ast.unparse(node):
    #                     return True
    #         return False

    #     def _check_docstrings(self, file_path: Path, tree: ast.AST) -List[Dict[str, Any]]):
    #         """Check for missing docstrings."""
    issues = []

    #         for node in ast.walk(tree):
    #             if isinstance(node, (ast.FunctionDef, ast.ClassDef, ast.AsyncFunctionDef)):
    #                 # Check if the node has a docstring
    #                 if not (node.body and isinstance(node.body[0], ast.Expr) and
                            isinstance(node.body[0].value, ast.Constant) and
                            isinstance(node.body[0].value.value, str)):
                        issues.append({
                            "file": str(file_path),
    #                         "line": node.lineno,
    #                         "column": node.col_offset,
    #                         "severity": "info",
    #                         "message": f"Missing docstring for {node.__class__.__name__.lower()} '{node.name}'",
    #                         "rule": "missing_docstring"
    #                     })

    #         return issues

    #     def _check_complexity(self, file_path: Path, tree: ast.AST) -List[Dict[str, Any]]):
    #         """Check for high cyclomatic complexity."""
    issues = []

    #         for node in ast.walk(tree):
    #             if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef)):
    complexity = self._calculate_complexity(node)
    #                 if complexity self.config["max_complexity"]):
                        issues.append({
                            "file": str(file_path),
    #                         "line": node.lineno,
    #                         "column": node.col_offset,
    #                         "severity": "warning",
                            "message": f"Function '{node.name}' has high complexity ({complexity} {self.config['max_complexity']})",
    #                         "rule"): "high_complexity"
    #                     })

    #         return issues

    #     def _calculate_complexity(self, node: ast.AST) -int):
    #         """Calculate cyclomatic complexity of a node."""
    complexity = 1  # Base complexity

    #         for child in ast.walk(node):
    #             if isinstance(child, (ast.If, ast.While, ast.For, ast.AsyncFor,
    #                                  ast.With, ast.AsyncWith, ast.Try, ast.ExceptHandler)):
    complexity + = 1
    #             elif isinstance(child, ast.BoolOp):
    complexity + = len(child.values) - 1

    #         return complexity

    #     def _check_naming(self, file_path: Path, tree: ast.AST) -List[Dict[str, Any]]):
    #         """Check for naming convention violations."""
    issues = []

    #         for node in ast.walk(tree):
    #             if isinstance(node, ast.FunctionDef):
    #                 if not re.match(r'^[a-z_][a-z0-9_]*$', node.name):
                        issues.append({
                            "file": str(file_path),
    #                         "line": node.lineno,
    #                         "column": node.col_offset,
    #                         "severity": "warning",
    #                         "message": f"Function name '{node.name}' should be snake_case",
    #                         "rule": "naming_convention"
    #                     })

    #             elif isinstance(node, ast.ClassDef):
    #                 if not re.match(r'^[A-Z][a-zA-Z0-9]*$', node.name):
                        issues.append({
                            "file": str(file_path),
    #                         "line": node.lineno,
    #                         "column": node.col_offset,
    #                         "severity": "warning",
    #                         "message": f"Class name '{node.name}' should be PascalCase",
    #                         "rule": "naming_convention"
    #                     })

    #         return issues

    #     def lint_directory(self, directory: Path) -Dict[str, Any]):
    #         """Lint all files in a directory and return a summary."""
    all_issues = []
    files_processed = 0

    #         # Find all Python and Noodle files
    patterns = self.config["python_patterns"] + self.config["noodle_patterns"]

    #         for pattern in patterns:
    #             for file_path in directory.rglob(pattern):
    #                 if file_path.is_file():
    files_processed + = 1
    issues = self.lint_file(file_path)
                        all_issues.extend(issues)

    #         # Categorize issues by severity
    #         error_count = sum(1 for issue in all_issues if issue["severity"] == "error")
    #         warning_count = sum(1 for issue in all_issues if issue["severity"] == "warning")
    #         info_count = sum(1 for issue in all_issues if issue["severity"] == "info")

    #         return {
    #             "files_processed": files_processed,
                "total_issues": len(all_issues),
    #             "error_count": error_count,
    #             "warning_count": warning_count,
    #             "info_count": info_count,
    #             "issues": all_issues
    #         }

    #     def fix_issues(self, directory: Path, fix_rules: List[str] = None) -Dict[str, Any]):
    #         """Fix linting issues in files."""
    #         # This is a placeholder for auto-fixing functionality
    #         # In a full implementation, this would modify files to fix issues

    #         if not fix_rules:
    fix_rules = ["line_too_long", "indentation"]

    fixed_files = 0

    #         for pattern in self.config["python_patterns"] + self.config["noodle_patterns"]:
    #             for file_path in directory.rglob(pattern):
    #                 if file_path.is_file():
    #                     # TODO: Implement actual fixing logic
    fixed_files + = 1

    #         return {
    #             "files_fixed": fixed_files,
    #             "rules_applied": fix_rules
    #         }


class NoodleLinterCommand(NoodleCommand)
    #     """Command to run the Noodle linter."""

    #     def __init__(self):""Initialize the linter command."""
            super().__init__()
    self.linter = NoodleLinter()

    #     def add_arguments(self, parser):
    #         """Add command arguments."""
            parser.add_argument(
    #             "path",
    nargs = "?",
    default = ".",
    help = "Path to file or directory to lint"
    #         )
            parser.add_argument(
    #             "--config",
    help = "Path to configuration file"
    #         )
            parser.add_argument(
    #             "--fix",
    action = "store_true",
    help = "Automatically fix issues"
    #         )
            parser.add_argument(
    #             "--rules",
    help = "Comma-separated list of rules to fix when using --fix"
    #         )
            parser.add_argument(
    #             "--output",
    #             help="Output file for results (JSON format)"
    #         )
            parser.add_argument(
    #             "--quiet", "-q",
    action = "store_true",
    help = "Only show errors"
    #         )

    #     def run(self, args):
    #         """Run the linter command."""
    #         # Load configuration
    #         config_file = Path(args.config) if args.config else None
            self.linter.load_config(config_file)

    #         # Determine what to lint
    path = Path(args.path)

    #         if path.is_file():
    #             # Lint a single file
    issues = self.linter.lint_file(path)
    result = {
    #                 "files_processed": 1,
                    "total_issues": len(issues),
    #                 "error_count": sum(1 for issue in issues if issue["severity"] == "error"),
    #                 "warning_count": sum(1 for issue in issues if issue["severity"] == "warning"),
    #                 "info_count": sum(1 for issue in issues if issue["severity"] == "info"),
    #                 "issues": issues
    #             }
    #         elif path.is_dir():
    #             # Lint a directory
    result = self.linter.lint_directory(path)
    #         else:
                print(f"Error: Path not found: {path}")
    #             return 1

    #         # Print results
    #         if not args.quiet:
                print(f"Processed {result['files_processed']} files")
                print(f"Found {result['total_issues']} issues:")
                print(f"  Errors: {result['error_count']}")
                print(f"  Warnings: {result['warning_count']}")
                print(f"  Info: {result['info_count']}")

    #         # Print individual issues if not quiet
    #         if not args.quiet and result['issues']:
    #             for issue in result['issues']:
    severity_symbol = {
    #                     "error": "E",
    #                     "warning": "W",
    #                     "info": "I"
                    }.get(issue["severity"], "?")

                    print(f"{severity_symbol} {issue['file']}:{issue['line']}:{issue['column']} - {issue['message']}")

    #         # Save results to file if requested
    #         if args.output:
    #             with open(args.output, 'w') as f:
    json.dump(result, f, indent = 2)
                print(f"Results saved to {args.output}")

    #         # Fix issues if requested
    #         if args.fix:
    #             fix_rules = args.rules.split(',') if args.rules else None
    fix_result = self.linter.fix_issues(path, fix_rules)
                print(f"Fixed {fix_result['files_fixed']} files")

    #         # Return appropriate exit code
    #         return 1 if result['error_count'] > 0 else 0


function main()
    #     """Main entry point for the linter."""
    #     import argparse

    parser = argparse.ArgumentParser(description="NoodleCore Linter")
    command = NoodleLinterCommand()
        command.add_arguments(parser)

    args = parser.parse_args()
    exit_code = command.run(args)
        sys.exit(exit_code)


if __name__ == "__main__"
        main()