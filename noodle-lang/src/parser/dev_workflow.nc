# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Noodle Development Workflow Script

# This script provides commands for common development tasks including linting,
# testing, and vector database operations.
# """

import os
import sys
import logging
import subprocess
import argparse
import pathlib.Path
import typing.List

# Configure logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('dev_workflow.log'),
        logging.StreamHandler()
#     ]
# )
logger = logging.getLogger(__name__)

class DevWorkflow
    #     """Handles common development workflow tasks."""

    #     def __init__(self, project_root: Path):
    self.project_root = project_root

    #     def run_command(self, cmd: List[str], description: str = None) -bool):
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

    #             if result.returncode = 0:
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

    #     def lint(self, fix: bool = False) -bool):
    #         """Run linting tools on the codebase."""
            logger.info("Running linting tools...")

    #         # Format code with black
    #         if fix:
    #             if not self.run_command(["black", "."], "Formatting code with black"):
    #                 return False

    #         # Sort imports with isort
    #         if fix:
    #             if not self.run_command(["isort", "."], "Sorting imports with isort"):
    #                 return False

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

            logger.info("Linting completed successfully")
    #         return True

    #     def test(self, coverage: bool = False, test_path: str = None) -bool):
    #         """Run tests with optional coverage."""
            logger.info("Running tests...")

    cmd = ["pytest", "-v"]

    #         if coverage:
    cmd.extend(["--cov = .", "--cov-report=html", "--cov-report=term"])

    #         if test_path:
                cmd.append(test_path)

    #         if not self.run_command(cmd, f"Running tests with coverage={coverage}"):
    #             return False

            logger.info("Tests completed successfully")
    #         return True

    #     def vector_init(self, force: bool = False) -bool):
    #         """Initialize the vector database using NoodleCore optimized vector indexer."""
            logger.info("Initializing vector database...")

    #         # Try to use NoodleCore optimized vector indexer first
    #         try:
    #             from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

    #             # Initialize the indexer
    indexer = OptimizedVectorIndexer(
    project_root = self.project_root,
    max_workers = 8,
    batch_size = 100,
    chunk_size = 50
    #             )

    #             # Just initialize the vector index without indexing files
    #             if hasattr(indexer, '_init_vector_index'):
                    indexer._init_vector_index()
    #                 logger.info("Vector database initialized successfully with NoodleCore")
    #                 return True
    #             else:
                    logger.warning("NoodleCore vector indexer doesn't support initialization only")
    #         except ImportError:
                logger.info("NoodleCore not available, falling back to original implementation")
    #         except Exception as e:
    #             logger.warning(f"Failed to initialize with NoodleCore: {e}")

    #         # Fallback to original implementation
    cmd = ["python", "scripts/setup_vector_db.py", "--project-root", str(self.project_root)]

    #         if force:
                cmd.append("--force")

    #         if not self.run_command(cmd, "Initializing vector database"):
    #             return False

            logger.info("Vector database initialized successfully")
    #         return True

    #     def vector_index(self, file_path: str = None) -bool):
    #         """Index files in the vector database using NoodleCore optimized vector indexer."""
            logger.info("Indexing files in vector database...")

    #         # Try to use NoodleCore optimized vector indexer first
    #         try:
    #             from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

    #             # Initialize the indexer
    indexer = OptimizedVectorIndexer(
    project_root = self.project_root,
    max_workers = 8,
    batch_size = 100,
    chunk_size = 50
    #             )

    #             if file_path:
    #                 # Index a specific file
    #                 # NoodleCore doesn't directly support single file indexing in the current API
    #                 # So we'll fall back to the original implementation for single files
                    logger.info("Single file indexing requested, using original implementation")
                    raise ImportError("Single file indexing not supported by NoodleCore yet")
    #             else:
    #                 # Index all files
    success = indexer.index_files(resume=True)
                    indexer.cleanup()

    #                 if success:
    #                     logger.info("Vector indexing completed successfully with NoodleCore")
    #                     return True
    #                 else:
                        logger.warning("NoodleCore vector indexing failed, falling back to original implementation")
                        raise ImportError("NoodleCore vector indexing failed")

    #         except ImportError:
                logger.info("Using original vector indexing implementation")
    #         except Exception as e:
    #             logger.warning(f"Failed to index with NoodleCore: {e}")
                logger.info("Falling back to original implementation")

    #         # Fallback to original implementation
    cmd = ["python", "scripts/setup_vector_db.py", "--project-root", str(self.project_root), "--index"]

    #         if file_path:
                cmd.extend(["--file", file_path])

    #         if not self.run_command(cmd, f"Indexing files ({file_path or 'all'})"):
    #             return False

            logger.info("Vector indexing completed successfully")
    #         return True

    #     def vector_search(self, query: str, limit: int = 10) -bool):
    #         """Search the vector database."""
            logger.info(f"Searching vector database for: '{query}'")

    #         # Try to use NoodleCore vector index for searching
    #         try:
    #             from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

    #             # Initialize the indexer
    indexer = OptimizedVectorIndexer(
    project_root = self.project_root,
    max_workers = 8,
    batch_size = 100,
    chunk_size = 50
    #             )

    #             # NoodleCore doesn't directly support searching in the current API
    #             # So we'll fall back to the original implementation for searching
                logger.info("Searching using original implementation")
                raise ImportError("Search not directly supported by NoodleCore yet")

    #         except ImportError:
                logger.info("Using original vector search implementation")
    #         except Exception as e:
    #             logger.warning(f"Failed to search with NoodleCore: {e}")
                logger.info("Falling back to original implementation")

    #         # Fallback to original implementation
    cmd = [
    #             "python", "scripts/setup_vector_db.py",
                "--project-root", str(self.project_root),
    #             "--search",
    #             "--query", query,
                "--limit", str(limit)
    #         ]

    #         if not self.run_command(cmd, f"Searching for '{query}'"):
    #             return False

            logger.info("Vector search completed successfully")
    #         return True

    #     def serve(self, port: int = 8080) -bool):
    #         """Start the development server."""
            logger.info(f"Starting development server on port {port}...")

    #         # Check if there's a specific server script
    server_scripts = [
    #             "noodle-core/src/noodlecore/cli/serve.py",
    #             "scripts/core-http-server.py",
    #             "main.py"
    #         ]

    #         for script in server_scripts:
    script_path = math.divide(self.project_root, script)
    #             if script_path.exists():
    cmd = ["python3", script, "--port", str(port)]
    #                 if not self.run_command(cmd, f"Starting server with {script}"):
    #                     return False
    #                 return True

    #         # Fallback to a simple HTTP server
            logger.warning("No specific server script found, using Python's built-in HTTP server")
    cmd = ["python3", "-m", "http.server", str(port)]

    #         if not self.run_command(cmd, f"Starting HTTP server on port {port}"):
    #             return False

            logger.info(f"Development server started on http://localhost:{port}")
    #         return True

    #     def clean(self) -bool):
    #         """Clean up generated files and caches."""
            logger.info("Cleaning up generated files and caches...")

    #         # Clean Python cache
    #         if not self.run_command(["find", ".", "-type", "d", "-name", "__pycache__", "-exec", "rm", "-rf", "{}", "+"], "Cleaning Python cache"):
    #             # Try alternative approach if find command fails
                logger.warning("Find command failed, trying alternative cleanup")
    #             for cache_dir in self.project_root.rglob("__pycache__"):
    #                 try:
    #                     import shutil
                        shutil.rmtree(cache_dir)
    #                 except Exception as e:
                        logger.warning(f"Failed to remove {cache_dir}: {e}")

    #         # Clean other cache directories
    cache_dirs = [
    #             ".pytest_cache",
    #             ".mypy_cache",
    #             ".coverage",
    #             "htmlcov",
    #             ".tox",
    #             "build",
    #             "dist",
    #             "*.egg-info"
    #         ]

    #         for cache_dir in cache_dirs:
    #             for path in self.project_root.glob(cache_dir):
    #                 try:
    #                     if path.is_dir():
    #                         import shutil
                            shutil.rmtree(path)
                            logger.info(f"Removed directory: {path}")
    #                     elif path.is_file():
                            path.unlink()
                            logger.info(f"Removed file: {path}")
    #                 except Exception as e:
                        logger.warning(f"Failed to remove {path}: {e}")

            logger.info("Cleanup completed successfully")
    #         return True

    #     def install_deps(self) -bool):
    #         """Install project dependencies."""
            logger.info("Installing project dependencies...")

    #         # Check if requirements.txt exists
    requirements_file = self.project_root / "requirements.txt"
    #         if requirements_file.exists():
    #             if not self.run_command(
    #                 ["python3", "-m", "pip", "install", "-r", "requirements.txt"],
    #                 "Installing dependencies from requirements.txt"
    #             ):
    #                 return False
    #         else:
                logger.warning("No requirements.txt found, installing basic dependencies")
    basic_deps = [
    "psycopg2-binary = 2.9.0",
    "redis-py = 4.5.0",
    "pytest = 7.4.0",
    "black = 23.7.0",
    "isort = 5.12.0",
    "flake8 = 6.0.0",
    "mypy = 1.5.1",
    "bandit = 1.7.5"
    #             ]

    #             for dep in basic_deps:
    #                 if not self.run_command(
    #                     ["python3", "-m", "pip", "install", dep],
    #                     f"Installing {dep}"
    #                 ):
    #                     return False

            logger.info("Dependencies installed successfully")
    #         return True

    #     def status(self) -bool):
    #         """Show project status information."""
            logger.info("Project Status:")

    #         # Python version
    result = subprocess.run(
    #             ["python3", "--version"],
    capture_output = True,
    text = True
    #         )
            logger.info(f"Python version: {result.stdout.strip()}")

    #         # Check if key files exist
    key_files = [
    #             "requirements.txt",
    #             ".env",
    #             "pyproject.toml",
    #             "setup.cfg",
    #             "mypy.ini",
    #             ".bandit",
    #             ".pre-commit-config.yaml"
    #         ]

            logger.info("Configuration files:")
    #         for file in key_files:
    #             exists = "✅" if (self.project_root / file).exists() else "❌"
                logger.info(f"  {exists} {file}")

    #         # Check if vector database exists
    vector_db_path = self.project_root / "vector_db"
    #         if vector_db_path.exists():
                logger.info("✅ Vector database exists")
    #         else:
                logger.info("❌ Vector database not found")

    #         return True

function main()
    #     """Main entry point for the development workflow script."""
    parser = argparse.ArgumentParser(description="Noodle Development Workflow Tool")
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

    #     # Test command
    test_parser = subparsers.add_parser("test", help="Run tests")
    test_parser.add_argument("--coverage", action = "store_true", help="Generate coverage report")
    test_parser.add_argument("--path", type = str, help="Path to specific test file or directory")

    #     # Vector commands
    vector_init_parser = subparsers.add_parser("vector-init", help="Initialize vector database")
    vector_init_parser.add_argument("--force", action = "store_true", help="Force reinitialization")

    vector_index_parser = subparsers.add_parser("vector-index", help="Index files in vector database")
    vector_index_parser.add_argument("--file", type = str, help="Specific file to index")

    vector_search_parser = subparsers.add_parser("vector-search", help="Search vector database")
    vector_search_parser.add_argument("query", type = str, help="Search query")
    vector_search_parser.add_argument("--limit", type = int, default=10, help="Maximum number of results")

    #     # Serve command
    serve_parser = subparsers.add_parser("serve", help="Start development server")
    serve_parser.add_argument("--port", type = int, default=8080, help="Port to run server on")

    #     # Clean command
    subparsers.add_parser("clean", help = "Clean up generated files and caches")

    #     # Install command
    subparsers.add_parser("install", help = "Install project dependencies")

    #     # Status command
    subparsers.add_parser("status", help = "Show project status")

    args = parser.parse_args()

    #     if not args.command:
            parser.print_help()
            sys.exit(1)

    project_root = Path(args.project_root).resolve()

    #     if not project_root.exists():
            logger.error(f"Project root does not exist: {project_root}")
            sys.exit(1)

    #     # Create and run the workflow
    workflow = DevWorkflow(project_root)

    success = False

    #     if args.command == "lint":
    success = workflow.lint(fix=args.fix)
    #     elif args.command == "test":
    success = workflow.test(coverage=args.coverage, test_path=args.path)
    #     elif args.command == "vector-init":
    success = workflow.vector_init(force=args.force)
    #     elif args.command == "vector-index":
    success = workflow.vector_index(file_path=args.file)
    #     elif args.command == "vector-search":
    success = workflow.vector_search(query=args.query, limit=args.limit)
    #     elif args.command == "serve":
    success = workflow.serve(port=args.port)
    #     elif args.command == "clean":
    success = workflow.clean()
    #     elif args.command == "install":
    success = workflow.install_deps()
    #     elif args.command == "status":
    success = workflow.status()

    #     if success:
            logger.info(f"Command '{args.command}' completed successfully")
            sys.exit(0)
    #     else:
            logger.error(f"Command '{args.command}' failed")
            sys.exit(1)

if __name__ == "__main__"
        main()