# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Repository Organization Tool

# This tool helps maintain the project structure during the migration from Python to NoodleCore.
# It automatically scans the project directory, identifies Python files and their migration status,
# and moves files to appropriate directories based on file type and migration status.
# """

import argparse
import json
import logging
import os
import shutil
import sys
import pathlib.Path
import typing.Dict

# Set up logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('organize_repo.log'),
        logging.StreamHandler(sys.stdout)
#     ]
# )
logger = logging.getLogger(__name__)


class RepoOrganizer
    #     """Main class for organizing the repository during migration."""

    #     def __init__(self, config_file: Optional[str] = None, dry_run: bool = False):""
    #         Initialize the repository organizer.

    #         Args:
    #             config_file: Path to configuration file
    #             dry_run: If True, only preview changes without executing them
    #         """
    self.dry_run = dry_run
    self.config = self._load_config(config_file)
    self.project_root = Path.cwd()
    self.report = {
    #             "files_moved": [],
    #             "files_skipped": [],
    #             "errors": [],
    #             "summary": {}
    #         }

    #         # Set up directory mappings based on configuration
    self.dir_mappings = self.config.get("directory_mappings", {
    #             "python_core": "noodle-core/src/noodlecore",
    #             "cli_tools": "noodle-core/src/noodlecore/cli",
    #             "database": "noodle-core/src/noodlecore/database",
    #             "utils": "noodle-core/src/noodlecore/utils",
    #             "tests": "tests",
    #             "docs": "docs",
    #             "config": "config",
    #             "scripts": "scripts"
    #         })

    #         # File type patterns
    self.file_patterns = self.config.get("file_patterns", {
    #             "python": "*.py",
    #             "noodlecore": "*.noodle",
    #             "documentation": "*.md",
    #             "config": ["*.json", "*.yaml", "*.yml", "*.toml", "*.ini", ".env*"],
    #             "test": "test_*.py"
    #         })

    #     def _load_config(self, config_file: Optional[str]) -Dict):
    #         """Load configuration from file or use defaults."""
    default_config = {
    #             "directory_mappings": {
    #                 "python_core": "noodle-core/src/noodlecore",
    #                 "cli_tools": "noodle-core/src/noodlecore/cli",
    #                 "database": "noodle-core/src/noodlecore/database",
    #                 "utils": "noodle-core/src/noodlecore/utils",
    #                 "tests": "tests",
    #                 "docs": "docs",
    #                 "config": "config",
    #                 "scripts": "scripts"
    #             },
    #             "file_patterns": {
    #                 "python": "*.py",
    #                 "noodlecore": "*.noodle",
    #                 "documentation": "*.md",
    #                 "config": ["*.json", "*.yaml", "*.yml", "*.toml", "*.ini", ".env*"],
    #                 "test": "test_*.py"
    #             },
    #             "migration_indicators": {
    #                 "noodlecore_imports": ["from noodlecore", "import noodlecore"],
    #                 "python_standard_lib": ["import os", "import sys", "import json"],
    #                 "legacy_indicators": ["# TODO: Migrate to NoodleCore", "# LEGACY:"]
    #             }
    #         }

    #         if config_file and os.path.exists(config_file):
    #             try:
    #                 with open(config_file, 'r') as f:
    user_config = json.load(f)
    #                 # Merge with defaults
    #                 for key, value in user_config.items():
    #                     if key in default_config and isinstance(default_config[key], dict):
                            default_config[key].update(value)
    #                     else:
    default_config[key] = value
                    logger.info(f"Loaded configuration from {config_file}")
    #             except Exception as e:
                    logger.error(f"Error loading config file {config_file}: {e}")
                    logger.info("Using default configuration")

    #         return default_config

    #     def scan_project(self) -List[Dict]):
    #         """
    #         Scan the project directory to identify files and their migration status.

    #         Returns:
    #             List of dictionaries containing file information
    #         """
            logger.info("Scanning project directory...")
    files_info = []

    #         # Get all Python files
    #         for py_file in self.project_root.rglob("*.py"):
    #             # Skip certain directories
    #             if any(part in str(py_file) for part in ['.git', '__pycache__', '.venv', 'node_modules']):
    #                 continue

    file_info = self._analyze_file(py_file)
                files_info.append(file_info)

            logger.info(f"Found {len(files_info)} Python files")
    #         return files_info

    #     def _analyze_file(self, file_path: Path) -Dict):
    #         """
    #         Analyze a file to determine its type and migration status.

    #         Args:
    #             file_path: Path to the file to analyze

    #         Returns:
    #             Dictionary with file information
    #         """
    #         try:
    #             with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()
    #         except Exception as e:
                logger.error(f"Error reading file {file_path}: {e}")
    #             # Use parent directory as fallback for suggested_target
    target_dir = str(file_path.parent)
    #             return {
                    "path": str(file_path),
                    "relative_path": str(file_path.relative_to(self.project_root)),
    #                 "type": "unknown",
    #                 "migration_status": "error",
    #                 "suggested_target": target_dir,
                    "error": str(e),
    #                 "size_bytes": file_path.stat().st_size if file_path.exists() else 0,
    #                 "last_modified": file_path.stat().st_mtime if file_path.exists() else 0
    #             }

    #         # Determine file type
    file_type = self._classify_file_type(file_path, content)

    #         # Determine migration status
    migration_status = self._determine_migration_status(content)

    #         # Suggest target directory
    target_dir = self._suggest_target_directory(file_path, file_type, migration_status)

    #         return {
                "path": str(file_path),
                "relative_path": str(file_path.relative_to(self.project_root)),
    #             "type": file_type,
    #             "migration_status": migration_status,
    #             "suggested_target": target_dir,
                "size_bytes": file_path.stat().st_size,
                "last_modified": file_path.stat().st_mtime
    #         }

    #     def _classify_file_type(self, file_path: Path, content: str) -str):
    #         """Classify the file type based on path and content."""
    #         # Check for test files
    #         if file_path.name.startswith("test_") or "tests" in file_path.parts:
    #             return "test"

    #         # Check for CLI tools
    #         if "cli" in file_path.parts or file_path.name.endswith("_cli.py"):
    #             return "cli"

    #         # Check for database related files
    #         if any(keyword in file_path.name.lower() for keyword in ["db", "database", "model", "schema"]):
    #             return "database"

    #         # Check for utility files
    #         if any(keyword in file_path.name.lower() for keyword in ["util", "helper", "common"]):
    #             return "utils"

    #         # Check for documentation
    #         if file_path.suffix == ".md":
    #             return "documentation"

    #         # Check for configuration files
    #         if file_path.suffix in [".json", ".yaml", ".yml", ".toml", ".ini"] or file_path.name.startswith(".env"):
    #             return "config"

    #         # Default to Python code
    #         return "python"

    #     def _determine_migration_status(self, content: str) -str):
    #         """Determine the migration status of a file based on its content."""
    indicators = self.config.get("migration_indicators", {})

    #         # Check for NoodleCore imports
    noodlecore_imports = indicators.get("noodlecore_imports", [])
    #         if any(imp in content for imp in noodlecore_imports):
    #             return "migrated"

    #         # Check for legacy indicators
    legacy_indicators = indicators.get("legacy_indicators", [])
    #         if any(ind in content for ind in legacy_indicators):
    #             return "pending"

    #         # Default to unknown
    #         return "unknown"

    #     def _suggest_target_directory(self, file_path: Path, file_type: str, migration_status: str) -str):
    #         """Suggest the appropriate target directory for a file."""
    #         # Already in correct location
    #         if migration_status == "migrated":
    #             if file_type == "cli" and "cli" in file_path.parts:
                    return str(file_path.parent)
    #             elif file_type == "database" and "database" in file_path.parts:
                    return str(file_path.parent)
    #             elif file_type == "utils" and "utils" in file_path.parts:
                    return str(file_path.parent)
    #             elif "noodlecore" in file_path.parts:
                    return str(file_path.parent)

    #         # Suggest new location based on type
    #         if file_type == "cli":
    #             return self.dir_mappings["cli_tools"]
    #         elif file_type == "database":
    #             return self.dir_mappings["database"]
    #         elif file_type == "utils":
    #             return self.dir_mappings["utils"]
    #         elif file_type == "test":
    #             return self.dir_mappings["tests"]
    #         elif file_type == "documentation":
    #             return self.dir_mappings["docs"]
    #         elif file_type == "config":
    #             return self.dir_mappings["config"]
    #         elif migration_status == "migrated":
    #             return self.dir_mappings["python_core"]
    #         else:
    #             # Keep in current location for unknown files
                return str(file_path.parent)

    #     def organize_files(self, files_info: List[Dict]) -None):
    #         """
    #         Organize files based on the analysis.

    #         Args:
    #             files_info: List of file information dictionaries
    #         """
            logger.info("Organizing files...")

    #         for file_info in files_info:
    current_path = Path(file_info["path"])
    target_dir = Path(file_info["suggested_target"])

    #             # Skip if already in the right place
    #             if current_path.parent == target_dir:
                    self.report["files_skipped"].append({
                        "path": str(current_path),
    #                     "reason": "Already in correct location"
    #                 })
    #                 continue

    #             # Create target directory if it doesn't exist
    #             if not target_dir.exists():
    #                 if self.dry_run:
                        logger.info(f"[DRY RUN] Would create directory: {target_dir}")
    #                 else:
    #                     try:
    target_dir.mkdir(parents = True, exist_ok=True)
                            logger.info(f"Created directory: {target_dir}")
    #                     except Exception as e:
    error_msg = f"Failed to create directory {target_dir}: {e}"
                            logger.error(error_msg)
                            self.report["errors"].append(error_msg)
    #                         continue

    #             # Move the file
    target_path = math.divide(target_dir, current_path.name)
    #             if self.dry_run:
                    logger.info(f"[DRY RUN] Would move: {current_path} -{target_path}")
                    self.report["files_moved"].append({
                        "from"): str(current_path),
                        "to": str(target_path),
    #                     "status": "dry_run"
    #                 })
    #             else:
    #                 try:
                        shutil.move(str(current_path), str(target_path))
                        logger.info(f"Moved: {current_path} -{target_path}")
                        self.report["files_moved"].append({
                            "from"): str(current_path),
                            "to": str(target_path),
    #                         "status": "moved"
    #                     })
    #                 except Exception as e:
    error_msg = f"Failed to move {current_path} to {target_path}: {e}"
                        logger.error(error_msg)
                        self.report["errors"].append(error_msg)

    #     def generate_report(self, output_file: Optional[str] = None) -Dict):
    #         """
    #         Generate a report of the organization process.

    #         Args:
    #             output_file: Optional file to save the report to

    #         Returns:
    #             Dictionary containing the report
    #         """
    self.report["summary"] = {
                "files_scanned": len(self.report["files_moved"]) + len(self.report["files_skipped"]) + len(self.report["errors"]),
                "files_moved": len(self.report["files_moved"]),
                "files_skipped": len(self.report["files_skipped"]),
                "errors": len(self.report["errors"]),
    #             "dry_run": self.dry_run
    #         }

    #         if output_file:
    #             try:
    #                 with open(output_file, 'w') as f:
    json.dump(self.report, f, indent = 2)
                    logger.info(f"Report saved to {output_file}")
    #             except Exception as e:
                    logger.error(f"Failed to save report to {output_file}: {e}")

    #         return self.report

    #     def run_organization(self, output_file: Optional[str] = None) -Dict):
    #         """
    #         Run the complete organization process.

    #         Args:
    #             output_file: Optional file to save the report to

    #         Returns:
    #             Dictionary containing the report
    #         """
            logger.info("Starting repository organization...")
    #         if self.dry_run:
                logger.info("Running in DRY RUN mode - no changes will be made")

    #         # Scan the project
    files_info = self.scan_project()

    #         # Organize files
            self.organize_files(files_info)

    #         # Generate report
    report = self.generate_report(output_file)

            logger.info("Repository organization completed")
    #         return report


function main()
    #     """Main entry point for the script."""
    parser = argparse.ArgumentParser(
    description = "Organize repository structure during Python to NoodleCore migration"
    #     )
        parser.add_argument(
    #         "--config",
    type = str,
    help = "Path to configuration file"
    #     )
        parser.add_argument(
    #         "--dry-run",
    action = "store_true",
    help = "Preview changes without executing them"
    #     )
        parser.add_argument(
    #         "--output",
    type = str,
    default = "organization_report.json",
    #         help="Output file for the organization report"
    #     )
        parser.add_argument(
    #         "--verbose",
    action = "store_true",
    help = "Enable verbose logging"
    #     )

    args = parser.parse_args()

    #     if args.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    #     # Create and run the organizer
    organizer = RepoOrganizer(
    config_file = args.config,
    dry_run = args.dry_run
    #     )

    report = organizer.run_organization(args.output)

    #     # Print summary
        print("\nOrganization Summary:")
        print(f"Files scanned: {report['summary']['files_scanned']}")
        print(f"Files moved: {report['summary']['files_moved']}")
        print(f"Files skipped: {report['summary']['files_skipped']}")
        print(f"Errors: {report['summary']['errors']}")
        print(f"Dry run: {report['summary']['dry_run']}")


if __name__ == "__main__"
        main()