# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Noodle Vector Automation Script

# This script integrates the NoodleCore vector indexer into the existing automation system
# that runs the linter and indexer regularly. It provides a unified interface for
# running linting, testing, and vector indexing operations.

# Updated to specifically handle .nc files with the new NoodleCore linter and validator.
# """

import os
import sys
import logging
import subprocess
import argparse
import time
import json
import uuid
import pathlib.Path
import typing.List,

# NoodleCore imports
try
    #     from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer
    HAS_NOODLECORE = True
except ImportError
    HAS_NOODLECORE = False
        print("Warning: NoodleCore not found. Vector indexing will use fallback implementation.")

# NoodleCore linter import
try
    #     from noodlecore.cli.noodle_linter import NoodleLinter
    HAS_NOODLECORE_LINTER = True
except ImportError
    HAS_NOODLECORE_LINTER = False
        print("Warning: NoodleCore linter not found. Linting will use fallback implementation.")

# NoodleCore validator imports
try
        from noodlecore.validator import (
    #         NoodleCoreValidator,
    #         ValidatorConfig,
    #         ValidationMode,
    #         get_validator,
    #         validate_file,
    #         ForeignSyntaxDetector
    #     )
    HAS_NOODLECORE_VALIDATOR = True
except ImportError
    HAS_NOODLECORE_VALIDATOR = False
        print("Warning: NoodleCore validator not found. Validation will use fallback implementation.")

# NoodleCore compiler frontend import
try
        from noodlecore.compiler.frontend import (
    #         CompilerFrontend,
    #         FrontendConfig,
    #         parse_file,
    #         ParseResult
    #     )
    HAS_NOODLECORE_FRONTEND = True
except ImportError
    HAS_NOODLECORE_FRONTEND = False
        print("Warning: NoodleCore compiler frontend not found. Parsing will use fallback implementation.")

# Configure logging with environment variable support
function setup_logging()
    #     """Setup logging with environment variable support."""
    log_level = os.environ.get('NOODLE_LOG_LEVEL', 'INFO').upper()
    log_file = os.environ.get('NOODLE_LOG_FILE', 'noodle_vector_automation.log')

        logging.basicConfig(
    level = getattr(logging, log_level, logging.INFO),
    format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers = [
                logging.FileHandler(log_file),
                logging.StreamHandler()
    #         ]
    #     )
        return logging.getLogger(__name__)

logger = setup_logging()


class NoodleAutomationError(Exception)
    #     """Exception raised by the Noodle automation script with 4-digit error codes."""

    #     def __init__(self, message: str, code: int = 1001, details: Optional[Dict[str, Any]] = None):
    self.message = message
    self.code = code
    self.details = details or {}
            super().__init__(self.message)

    #     def __str__(self):
    #         return f"NoodleAutomationError[{self.code}]: {self.message}"

class NoodleVectorAutomation
    #     """Handles automation tasks for Noodle project including linting and vector indexing.

    #     Updated to specifically handle .nc files with the new NoodleCore linter and validator.
    #     """

    #     def __init__(self, project_root: Path):
    self.project_root = project_root
    self.config_file = project_root / ".noodle_automation_config.json"

    #         # Initialize NoodleCore components
    self.validator = None
    self.frontend = None
    self.foreign_syntax_detector = None

    #         # Load configuration
            self.load_config()

    #         # Initialize NoodleCore components if available
            self._init_noodlecore_components()

    #     def _init_noodlecore_components(self):
    #         """Initialize NoodleCore components if available."""
    #         try:
    #             # Initialize validator
    #             if HAS_NOODLECORE_VALIDATOR:
    validator_config = ValidatorConfig(
    mode = ValidationMode.STRICT,
    enable_foreign_syntax_detection = True,
    enable_auto_correction = False,
    enable_ast_verification = True
    #                 )
    self.validator = get_validator(validator_config)
                    logger.info("NoodleCore validator initialized")

    #             # Initialize compiler frontend
    #             if HAS_NOODLECORE_FRONTEND:
    frontend_config = FrontendConfig(
    parsing_mode = "full",
    cache_strategy = "memory",
    enable_error_recovery = True,
    enable_incremental_parsing = True
    #                 )
    self.frontend = CompilerFrontend(frontend_config)
                    logger.info("NoodleCore compiler frontend initialized")

    #             # Initialize foreign syntax detector
    #             if HAS_NOODLECORE_VALIDATOR:
    self.foreign_syntax_detector = ForeignSyntaxDetector()
                    logger.info("NoodleCore foreign syntax detector initialized")

    #         except Exception as e:
                logger.error(f"Failed to initialize NoodleCore components: {str(e)}")
                raise NoodleAutomationError(
                    f"Failed to initialize NoodleCore components: {str(e)}",
    code = 1001,
    details = {"component": "noodlecore_init"}
    #             )

    #     def load_config(self):
    #         """Load configuration from file or create default with environment variable support."""
    #         # Get configuration from environment variables
    env_config = {
    #             "vector_indexing": {
    "enabled": os.environ.get('NOODLE_VECTOR_INDEXING_ENABLED', 'true').lower() = = 'true',
    "use_noodlecore": os.environ.get('NOODLE_USE_NOODLECORE', 'true').lower() = = 'true',
                    "max_workers": int(os.environ.get('NOODLE_MAX_WORKERS', '8')),
                    "batch_size": int(os.environ.get('NOODLE_BATCH_SIZE', '100')),
                    "chunk_size": int(os.environ.get('NOODLE_CHUNK_SIZE', '50')),
    "auto_resume": os.environ.get('NOODLE_AUTO_RESUME', 'true').lower() = = 'true'
    #             },
    #             "linting": {
    "enabled": os.environ.get('NOODLE_LINTING_ENABLED', 'true').lower() = = 'true',
    "fix": os.environ.get('NOODLE_LINTING_FIX', 'false').lower() = = 'true',
                    "tools": os.environ.get('NOODLE_LINTING_TOOLS', 'black,isort,flake8,mypy,bandit').split(',')
    #             },
    #             "noodlecore": {
    "enabled": os.environ.get('NOODLECORE_ENABLED', 'true').lower() = = 'true',
    "strict_validation": os.environ.get('NOODLECORE_STRICT_VALIDATION', 'true').lower() = = 'true',
    "skip_foreign_syntax": os.environ.get('NOODLECORE_SKIP_FOREIGN_SYNTAX', 'false').lower() = = 'true',
                    "file_extensions": os.environ.get('NOODLECORE_FILE_EXTENSIONS', '.nc').split(',')
    #             },
    #             "testing": {
    "enabled": os.environ.get('NOODLE_TESTING_ENABLED', 'false').lower() = = 'true',
    "coverage": os.environ.get('NOODLE_TESTING_COVERAGE', 'false').lower() = = 'true',
                    "test_path": os.environ.get('NOODLE_TEST_PATH')
    #             },
    #             "schedule": {
                    "vector_indexing_interval": int(os.environ.get('NOODLE_VECTOR_INDEXING_INTERVAL', '3600')),
                    "linting_interval": int(os.environ.get('NOODLE_LINTING_INTERVAL', '1800')),
    "run_on_startup": os.environ.get('NOODLE_RUN_ON_STARTUP', 'true').lower() = = 'true'
    #             }
    #         }

    default_config = {
    #             "vector_indexing": {
    #                 "enabled": True,
    #                 "use_noodlecore": HAS_NOODLECORE,
    #                 "max_workers": 8,
    #                 "batch_size": 100,
    #                 "chunk_size": 50,
    #                 "auto_resume": True
    #             },
    #             "linting": {
    #                 "enabled": True,
    #                 "fix": False,
    #                 "tools": ["black", "isort", "flake8", "mypy", "bandit"]
    #             },
    #             "noodlecore": {
    #                 "enabled": True,
    #                 "strict_validation": True,
    #                 "skip_foreign_syntax": False,
    #                 "file_extensions": [".nc"]
    #             },
    #             "testing": {
    #                 "enabled": False,
    #                 "coverage": False,
    #                 "test_path": None
    #             },
    #             "schedule": {
    #                 "vector_indexing_interval": 3600,  # 1 hour in seconds
    #                 "linting_interval": 1800,  # 30 minutes in seconds
    #                 "run_on_startup": True
    #             }
    #         }

    #         # Merge environment config with defaults
    #         for section in env_config:
    #             if section in default_config:
                    default_config[section].update(env_config[section])
    #             else:
    default_config[section] = env_config[section]

    #         if self.config_file.exists():
    #             try:
    #                 with open(self.config_file, 'r') as f:
    self.config = json.load(f)
                    logger.info(f"Loaded configuration from {self.config_file}")
    #             except Exception as e:
                    logger.warning(f"Failed to load config file: {e}. Using defaults.")
    self.config = default_config
    #         else:
    self.config = default_config
                self.save_config()
                logger.info("Created default configuration file")

    #     def save_config(self):
    #         """Save current configuration to file."""
    #         try:
    #             with open(self.config_file, 'w') as f:
    json.dump(self.config, f, indent = 2)
    #         except Exception as e:
                logger.error(f"Failed to save config file: {e}")

    #     def run_command(self, cmd: List[str], description: str = None) -> bool:
    #         """Run a command and return success status."""
    #         if description:
                logger.info(f"Running: {description}")
    #         else:
                logger.info(f"Running command: {' '.join(cmd)}")

    #         try:
    result = subprocess.run(
    #                 cmd,
    cwd = self.project_root,
    capture_output = True,
    text = True,
    timeout = 1800  # 30 minute timeout
    #             )

    #             if result.stdout:
                    logger.info(result.stdout)

    #             if result.stderr:
                    logger.warning(result.stderr)

    #             if result.returncode == 0:
                    logger.info("Command completed successfully")
    #                 return True
    #             else:
    #                 logger.error(f"Command failed with exit code {result.returncode}")
    #                 return False

    #         except subprocess.TimeoutExpired:
                logger.error("Command timed out")
    #             return False
    #         except Exception as e:
                logger.error(f"Error running command: {str(e)}")
    #             return False

    #     def lint(self) -> bool:
    #         """Run linting tools on the codebase, using appropriate linters for different file types."""
    #         if not self.config["linting"]["enabled"]:
                logger.info("Linting is disabled in configuration")
    #             return True

            logger.info("Running linting on codebase...")

    lint_config = self.config["linting"]
    fix = lint_config["fix"]

    #         # Track overall success
    overall_success = True

    #         # Lint Python files with existing linter
    #         if self._has_python_files():
    #             logger.info("Linting Python files with standard linters...")
    python_success = self._lint_with_python_tools(fix)
    overall_success = overall_success and python_success

    #         # Lint NoodleCore files with NoodleCore linter
    #         if self._has_nc_files() and self.config["noodlecore"]["enabled"]:
    #             logger.info("Linting NoodleCore (.nc) files with NoodleCore linter...")
    nc_success = self._lint_nc_files(fix)
    overall_success = overall_success and nc_success

    #         if overall_success:
                logger.info("Linting completed successfully")
    #         else:
                logger.error("Linting found errors")

    #         return overall_success

    #     def _has_python_files(self) -> bool:
    #         """Check if the project has Python files."""
            return any(self.project_root.rglob("*.py"))

    #     def _has_nc_files(self) -> bool:
    #         """Check if the project has NoodleCore (.nc) files."""
            return any(self.project_root.rglob("*.nc"))

    #     def _lint_nc_files(self, fix: bool) -> bool:
    #         """Lint NoodleCore (.nc) files with NoodleCore linter."""
    #         try:
    #             if not HAS_NOODLECORE_VALIDATOR or not HAS_NOODLECORE_FRONTEND:
                    logger.warning("NoodleCore components not available, skipping .nc file linting")
    #                 return True

    #             # Find all .nc files
    nc_files = list(self.project_root.rglob("*.nc"))
    #             if not nc_files:
                    logger.info("No .nc files found")
    #                 return True

                logger.info(f"Found {len(nc_files)} .nc files to process")

    total_issues = 0
    error_count = 0
    warning_count = 0
    info_count = 0
    processed_files = 0

    #             for nc_file in nc_files:
    #                 try:
    #                     # Validate the file with NoodleCore validator
    #                     if self.validator:
    validation_result = self.validator.validate_file(str(nc_file))

    #                         # Count issues by severity
    #                         for issue in validation_result.issues:
    total_issues + = 1
    #                             if issue.severity.value == "error":
    error_count + = 1
    #                             elif issue.severity.value == "warning":
    warning_count + = 1
    #                             else:
    info_count + = 1

    #                         # Log issues
    #                         for issue in validation_result.issues:
    severity_symbol = {
    #                                 "error": "ERROR",
    #                                 "warning": "WARNING",
    #                                 "info": "INFO"
                                }.get(issue.severity.value, "?")

                                logger.info(f"{severity_symbol}: {nc_file}:{issue.line}:{issue.column} - {issue.message}")

    processed_files + = 1

    #                     # Parse the file with NoodleCore frontend to generate AST
    #                     if self.frontend:
    parse_result = self.frontend.parse_file(str(nc_file))
    #                         if not parse_result.success:
                                logger.error(f"Failed to parse {nc_file}: {parse_result.errors}")
    error_count + = len(parse_result.errors)
    total_issues + = len(parse_result.errors)

    #                         # Store AST information for vector database
                            self._store_ast_for_vector_db(nc_file, parse_result)

    #                 except Exception as e:
                        logger.error(f"Error processing {nc_file}: {str(e)}")
    error_count + = 1
    total_issues + = 1

    #             # Log summary
                logger.info(f"Processed {processed_files} .nc files")
                logger.info(f"Found {total_issues} issues:")
                logger.info(f"  Errors: {error_count}")
                logger.info(f"  Warnings: {warning_count}")
                logger.info(f"  Info: {info_count}")

    #             # Return success if no errors
    return error_count = = 0

    #         except Exception as e:
                logger.error(f"Error during NoodleCore linting: {str(e)}")
                raise NoodleAutomationError(
                    f"Error during NoodleCore linting: {str(e)}",
    code = 1002,
    details = {"component": "noodlecore_linter"}
    #             )

    #     def _store_ast_for_vector_db(self, file_path: Path, parse_result: Any):
    #         """Store AST information from parsed file for vector database indexing."""
    #         try:
    #             if not parse_result.success or not parse_result.ast:
    #                 return

    #             # Create a metadata file for the AST that can be indexed by the vector database
    ast_metadata = {
                    "file_path": str(file_path.relative_to(self.project_root)),
    #                 "file_type": "noodlecore",
                    "parsed_at": time.time(),
                    "request_id": str(uuid.uuid4()),
                    "ast_summary": self._generate_ast_summary(parse_result.ast),
    #                 "parse_errors": [str(error) for error in parse_result.errors],
    #                 "parse_warnings": parse_result.warnings
    #             }

    #             # Create a directory for AST metadata if it doesn't exist
    ast_metadata_dir = self.project_root / ".noodle_ast_metadata"
    ast_metadata_dir.mkdir(exist_ok = True)

    #             # Save the AST metadata to a JSON file
    metadata_file = ast_metadata_dir / f"{file_path.stem}_ast_metadata.json"
    #             with open(metadata_file, 'w') as f:
    json.dump(ast_metadata, f, indent = 2)

    #             logger.debug(f"Stored AST metadata for {file_path} to {metadata_file}")

    #         except Exception as e:
    #             logger.error(f"Error storing AST metadata for {file_path}: {str(e)}")

    #     def _generate_ast_summary(self, ast: Any) -> Dict[str, Any]:
    #         """Generate a summary of the AST for vector database indexing."""
    #         try:
    #             # This is a simplified implementation
    #             # In a full implementation, this would extract more detailed information
    summary = {
    #                 "node_count": 0,
    #                 "function_count": 0,
    #                 "class_count": 0,
    #                 "import_count": 0,
    #                 "complexity_score": 0
    #             }

                # Count nodes (simplified)
    #             if hasattr(ast, 'children'):
    summary["node_count"] = len(ast.children)

    #             return summary

    #         except Exception as e:
                logger.error(f"Error generating AST summary: {str(e)}")
    #             return {}

    #     def _lint_with_python_tools(self, fix: bool) -> bool:
    #         """Run linting using Python tools as a fallback."""
            logger.info("Running Python linting tools...")

    #         # Format code with black
    #         cmd = ["black", "."] if fix else ["black", "--check", "."]
    #         if not self.run_command(cmd, f"{'Formatting' if fix else 'Checking'} code with black"):
    #             return False

    #         # Sort imports with isort
    #         cmd = ["isort", "."] if fix else ["isort", "--check-only", "."]
    #         if not self.run_command(cmd, f"{'Sorting' if fix else 'Checking'} imports with isort"):
    #             return False

    #         # Run flake8
    #         if not self.run_command(["flake8", "."], "Running flake8"):
    #             return False

    #         # Run mypy
    #         if not self.run_command(["mypy", "."], "Running mypy type checking"):
    #             return False

    #         # Run bandit security check
    #         if not self.run_command(["bandit", "-r", ".", "-c", ".bandit"], "Running bandit security check"):
    #             return False

    #         # Run pre-commit on all files
    #         if not self.run_command(["pre-commit", "run", "--all-files"], "Running pre-commit hooks"):
    #             return False

            logger.info("Python linting completed successfully")
    #         return True

    #     def test(self) -> bool:
    #         """Run tests with optional coverage."""
    #         if not self.config["testing"]["enabled"]:
                logger.info("Testing is disabled in configuration")
    #             return True

            logger.info("Running tests...")

    test_config = self.config["testing"]
    cmd = ["pytest", "-v"]

    #         if test_config["coverage"]:
    cmd.extend(["--cov = .", "--cov-report=html", "--cov-report=term"])

    #         if test_config["test_path"]:
                cmd.append(test_config["test_path"])

    #         if not self.run_command(cmd, f"Running tests with coverage={test_config['coverage']}"):
    #             return False

            logger.info("Tests completed successfully")
    #         return True

    #     def vector_index_with_noodlecore(self) -> bool:
    #         """Use NoodleCore optimized vector indexer with support for .nc files."""
    #         if not HAS_NOODLECORE:
                logger.error("NoodleCore is not available. Cannot use optimized vector indexer.")
    #             return False

            logger.info("Using NoodleCore optimized vector indexer...")

    vector_config = self.config["vector_indexing"]

    #         try:
    #             # Initialize the indexer
    indexer = OptimizedVectorIndexer(
    project_root = self.project_root,
    max_workers = vector_config["max_workers"],
    batch_size = vector_config["batch_size"],
    chunk_size = vector_config["chunk_size"]
    #             )

    #             # Run indexing
    success = indexer.index_files(resume=vector_config["auto_resume"])

    #             # Index .nc file AST metadata if available
    #             if self.config["noodlecore"]["enabled"]:
                    self._index_nc_ast_metadata()

    #             # Clean up
                indexer.cleanup()

    #             if success:
                    logger.info("NoodleCore vector indexing completed successfully")
    #             else:
                    logger.error("NoodleCore vector indexing failed")

    #             return success

    #         except Exception as e:
                logger.error(f"Error during NoodleCore vector indexing: {str(e)}")
                raise NoodleAutomationError(
                    f"Error during NoodleCore vector indexing: {str(e)}",
    code = 1003,
    details = {"component": "noodlecore_vector_indexer"}
    #             )

    #     def _index_nc_ast_metadata(self):
    #         """Index AST metadata for .nc files."""
    #         try:
    ast_metadata_dir = self.project_root / ".noodle_ast_metadata"
    #             if not ast_metadata_dir.exists():
                    logger.info("No AST metadata directory found, skipping .nc AST indexing")
    #                 return

    #             # Find all AST metadata files
    metadata_files = list(ast_metadata_dir.glob("*_ast_metadata.json"))
    #             if not metadata_files:
                    logger.info("No AST metadata files found")
    #                 return

    #             logger.info(f"Indexing {len(metadata_files)} AST metadata files for .nc files")

    #             # This is a simplified implementation
    #             # In a full implementation, this would use the vector database to index the metadata
    #             for metadata_file in metadata_files:
    #                 try:
    #                     with open(metadata_file, 'r') as f:
    metadata = json.load(f)

    #                     logger.debug(f"Indexed AST metadata for {metadata['file_path']}")

    #                 except Exception as e:
                        logger.error(f"Error indexing AST metadata file {metadata_file}: {str(e)}")

                logger.info("AST metadata indexing completed")

    #         except Exception as e:
                logger.error(f"Error indexing .nc AST metadata: {str(e)}")
                raise NoodleAutomationError(
                    f"Error indexing .nc AST metadata: {str(e)}",
    code = 1004,
    details = {"component": "nc_ast_metadata_indexer"}
    #             )

    #     def vector_index_fallback(self) -> bool:
    #         """Fallback vector indexing implementation."""
            logger.info("Using fallback vector indexing implementation...")

    #         # Run the original setup_vector_db.py script
    cmd = ["python", "scripts/setup_vector_db.py", "--project-root", str(self.project_root)]

    #         if not self.run_command(cmd, "Running fallback vector indexing"):
    #             return False

            logger.info("Fallback vector indexing completed successfully")
    #         return True

    #     def vector_index(self) -> bool:
    #         """Index files in the vector database."""
    #         if not self.config["vector_indexing"]["enabled"]:
                logger.info("Vector indexing is disabled in configuration")
    #             return True

            logger.info("Starting vector indexing...")

    vector_config = self.config["vector_indexing"]

    #         # Choose indexing method based on configuration and availability
    #         if vector_config["use_noodlecore"] and HAS_NOODLECORE:
                return self.vector_index_with_noodlecore()
    #         else:
                return self.vector_index_fallback()

    #     def run_full_automation(self) -> bool:
    #         """Run the complete automation workflow."""
            logger.info("Starting full automation workflow...")

    #         # Run linting
    #         if not self.lint():
                logger.error("Linting failed")
    #             return False

    #         # Run testing
    #         if not self.test():
                logger.error("Testing failed")
    #             return False

    #         # Run vector indexing
    #         if not self.vector_index():
                logger.error("Vector indexing failed")
    #             return False

            logger.info("Full automation workflow completed successfully")
    #         return True

    #     def run_scheduled_automation(self) -> None:
    #         """Run automation on a schedule."""
            logger.info("Starting scheduled automation...")

    #         # Track last run times
    last_vector_index = 0
    last_linting = 0

    #         # Run on startup if configured
    #         if self.config["schedule"]["run_on_startup"]:
                logger.info("Running automation on startup")
                self.run_full_automation()
    last_vector_index = time.time()
    last_linting = time.time()

    #         # Main scheduling loop
    #         try:
    #             while True:
    current_time = time.time()

    #                 # Check if it's time to run vector indexing
    vector_interval = self.config["schedule"]["vector_indexing_interval"]
    #                 if current_time - last_vector_index >= vector_interval:
                        logger.info("Running scheduled vector indexing")
    #                     if self.vector_index():
    last_vector_index = current_time
    #                     else:
                            logger.error("Scheduled vector indexing failed")

    #                 # Check if it's time to run linting
    linting_interval = self.config["schedule"]["linting_interval"]
    #                 if current_time - last_linting >= linting_interval:
                        logger.info("Running scheduled linting")
    #                     if self.lint():
    last_linting = current_time
    #                     else:
                            logger.error("Scheduled linting failed")

    #                 # Sleep for a short interval before checking again
                    time.sleep(60)  # Check every minute

    #         except KeyboardInterrupt:
                logger.info("Scheduled automation interrupted by user")
    #         except Exception as e:
                logger.error(f"Error in scheduled automation: {str(e)}")


function main()
    #     """Main entry point for the automation script."""
    parser = argparse.ArgumentParser(description="Noodle Vector Automation Tool")
        parser.add_argument(
    #         "--project-root",
    type = str,
    default = ".",
    help = "Path to the project root directory (default: current directory)"
    #     )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    #     # Lint command
    lint_parser = subparsers.add_parser("lint", help="Run linting tools")
    lint_parser.add_argument("--fix", action = "store_true", help="Automatically fix linting issues")
    lint_parser.add_argument("--files", type = str, help="Comma-separated list of files to lint")
    lint_parser.add_argument("--type", choices = ["python", "noodlecore", "all"], default="all",
    help = "Type of files to lint (default: all)")

    #     # Test command
    test_parser = subparsers.add_parser("test", help="Run tests")
    test_parser.add_argument("--coverage", action = "store_true", help="Generate coverage report")
    test_parser.add_argument("--path", type = str, help="Path to specific test file or directory")

    #     # NoodleCore validation command
    nc_parser = subparsers.add_parser("validate-nc", help="Validate NoodleCore (.nc) files")
    nc_parser.add_argument("--files", type = str, help="Comma-separated list of .nc files to validate")
    nc_parser.add_argument("--strict", action = "store_true", help="Enable strict validation")
    nc_parser.add_argument("--skip-foreign-syntax", action = "store_true", help="Skip foreign syntax detection")

    #     # Vector index command
    vector_parser = subparsers.add_parser("vector-index", help="Index files in vector database")
    vector_parser.add_argument("--use-fallback", action = "store_true", help="Use fallback implementation")
    #     vector_parser.add_argument("--include-ast", action="store_true", help="Include AST metadata for .nc files")

    #     # Full automation command
    auto_parser = subparsers.add_parser("auto", help="Run full automation workflow")

    #     # Schedule command
    schedule_parser = subparsers.add_parser("schedule", help="Run automation on a schedule")

    #     # Config command
    config_parser = subparsers.add_parser("config", help="Show or update configuration")
    config_parser.add_argument("--show", action = "store_true", help="Show current configuration")
    config_parser.add_argument("--set", type = str, help="Set configuration value (key=value)")

    args = parser.parse_args()

    #     if not args.command:
            parser.print_help()
            sys.exit(1)

    project_root = Path(args.project_root).resolve()

    #     if not project_root.exists():
            logger.error(f"Project root does not exist: {project_root}")
            sys.exit(1)

    #     # Create and run the automation
    automation = NoodleVectorAutomation(project_root)

    success = False

    #     if args.command == "lint":
    #         # Update config if flags are set
    #         if args.fix:
    automation.config["linting"]["fix"] = True
    #         if hasattr(args, 'type') and args.type != "all":
    automation.config["linting"]["file_type"] = args.type
    #         if hasattr(args, 'files') and args.files:
    automation.config["linting"]["files"] = args.files.split(',')
            automation.save_config()
    success = automation.lint()
    #     elif args.command == "test":
    #         # Update config if flags are set
    #         if args.coverage:
    automation.config["testing"]["coverage"] = True
    #         if args.path:
    automation.config["testing"]["test_path"] = args.path
            automation.save_config()
    success = automation.test()
    #     elif args.command == "validate-nc":
    #         # Update config if flags are set
    #         if args.strict:
    automation.config["noodlecore"]["strict_validation"] = True
    #         if args.skip_foreign_syntax:
    automation.config["noodlecore"]["skip_foreign_syntax"] = True
    #         if args.files:
    automation.config["noodlecore"]["files"] = args.files.split(',')

    #         # Validate .nc files
    success = automation._lint_nc_files(fix=False)
    #     elif args.command == "vector-index":
    #         # Update config if flags are set
    #         if args.use_fallback:
    automation.config["vector_indexing"]["use_noodlecore"] = False
    #         if args.include_ast:
    automation.config["vector_indexing"]["include_ast"] = True
            automation.save_config()
    success = automation.vector_index()
    #     elif args.command == "auto":
    success = automation.run_full_automation()
    #     elif args.command == "schedule":
            automation.run_scheduled_automation()
    success = True  # This runs indefinitely until interrupted
    #     elif args.command == "config":
    #         if args.show:
    print(json.dumps(automation.config, indent = 2))
    success = True
    #         elif args.set:
    #             try:
    key, value = args.set.split("=", 1)
    #                 # Navigate through the nested config
    keys = key.split(".")
    config = automation.config
    #                 for k in keys[:-1]:
    config = config[k]

    #                 # Try to parse as JSON, otherwise keep as string
    #                 try:
    config[keys[-1]] = json.loads(value)
    #                 except json.JSONDecodeError:
    config[keys[-1]] = value

                    automation.save_config()
    print(f"Configuration updated: {key} = {value}")
    success = True
    #             except Exception as e:
                    logger.error(f"Failed to set configuration: {e}")
    success = False
    #         else:
    print("Please specify either --show or --set key = value")
    success = False

    #     if success:
            logger.info(f"Command '{args.command}' completed successfully")
            sys.exit(0)
    #     else:
            logger.error(f"Command '{args.command}' failed")
            sys.exit(1)


if __name__ == "__main__"
        main()