# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Migration Progress Tracking Tool

# This tool tracks which Python files have been migrated to NoodleCore, generates migration
# progress reports with statistics, identifies dependencies between files, and creates visual
# representations of migration progress.
# """

import argparse
import ast
import csv
import json
import logging
import os
import sys
import datetime.datetime
import pathlib.Path
import typing.Dict,

# Set up logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('migration_tracker.log'),
        logging.StreamHandler(sys.stdout)
#     ]
# )
logger = logging.getLogger(__name__)


class MigrationTracker
    #     """Main class for tracking migration progress from Python to NoodleCore."""

    #     def __init__(self, config_file: Optional[str] = None):
    #         """
    #         Initialize the migration tracker.

    #         Args:
    #             config_file: Path to configuration file
    #         """
    self.config = self._load_config(config_file)
    self.project_root = Path.cwd()
    self.migration_data = {
    #             "files": {},
    #             "statistics": {},
    #             "dependencies": {},
                "generated_at": datetime.now().isoformat()
    #         }

    #         # Migration status indicators
    self.migration_indicators = self.config.get("migration_indicators", {
    #             "migrated": ["from noodlecore", "import noodlecore"],
    #             "partial": ["# PARTIALLY MIGRATED", "# TODO: Complete migration"],
    #             "pending": ["# TODO: Migrate to NoodleCore", "# LEGACY:"],
    #             "not_applicable": ["# NO MIGRATION NEEDED"]
    #         })

    #     def _load_config(self, config_file: Optional[str]) -> Dict:
    #         """Load configuration from file or use defaults."""
    default_config = {
    #             "migration_indicators": {
    #                 "migrated": ["from noodlecore", "import noodlecore"],
    #                 "partial": ["# PARTIALLY MIGRATED", "# TODO: Complete migration"],
    #                 "pending": ["# TODO: Migrate to NoodleCore", "# LEGACY:"],
    #                 "not_applicable": ["# NO MIGRATION NEEDED"]
    #             },
    #             "file_patterns": {
    #                 "python": "*.py",
    #                 "noodlecore": "*.noodle",
    #                 "exclude": [".git", "__pycache__", ".venv", "node_modules"]
    #             },
    #             "directory_mappings": {
    #                 "python_core": "noodle-core/src/noodlecore",
    #                 "cli_tools": "noodle-core/src/noodlecore/cli",
    #                 "database": "noodle-core/src/noodlecore/database",
    #                 "utils": "noodle-core/src/noodlecore/utils",
    #                 "tests": "tests"
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

    #     def scan_project_files(self) -> Dict[str, Dict]:
    #         """
    #         Scan the project directory to identify all Python files and their migration status.

    #         Returns:
    #             Dictionary mapping file paths to file information
    #         """
            logger.info("Scanning project files...")
    files_info = {}

    #         # Get all Python files
    #         for py_file in self.project_root.rglob("*.py"):
    #             # Skip certain directories
    #             if any(part in str(py_file) for part in self.config["file_patterns"]["exclude"]):
    #                 continue

    file_info = self._analyze_file(py_file)
    files_info[str(py_file.relative_to(self.project_root))] = file_info

            logger.info(f"Found {len(files_info)} Python files")
    self.migration_data["files"] = files_info
    #         return files_info

    #     def _analyze_file(self, file_path: Path) -> Dict:
    #         """
    #         Analyze a file to determine its migration status and extract information.

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
    #             return {
                    "path": str(file_path),
    #                 "migration_status": "error",
                    "error": str(e),
    #                 "imports": [],
    #                 "dependencies": [],
    #                 "size_bytes": 0,
    #                 "last_modified": 0
    #             }

    #         # Determine migration status
    migration_status = self._determine_migration_status(content)

    #         # Extract imports
    imports = self._extract_imports(content)

    #         # Get file metadata
    stat = file_path.stat()

    #         return {
                "path": str(file_path),
                "relative_path": str(file_path.relative_to(self.project_root)),
    #             "migration_status": migration_status,
    #             "imports": imports,
    #             "dependencies": [],  # Will be filled later
    #             "size_bytes": stat.st_size,
    #             "last_modified": stat.st_mtime
    #         }

    #     def _determine_migration_status(self, content: str) -> str:
    #         """Determine the migration status of a file based on its content."""
    #         # Check for migration indicators in order of priority
    #         for status, indicators in self.migration_indicators.items():
    #             for indicator in indicators:
    #                 if indicator in content:
    #                     return status

    #         # Default to unknown
    #         return "unknown"

    #     def _extract_imports(self, content: str) -> List[str]:
    #         """Extract import statements from Python code."""
    #         try:
    tree = ast.parse(content)
    imports = []

    #             for node in ast.walk(tree):
    #                 if isinstance(node, ast.Import):
    #                     for alias in node.names:
                            imports.append(alias.name)
    #                 elif isinstance(node, ast.ImportFrom):
    module = node.module or ""
    #                     for alias in node.names:
                            imports.append(f"{module}.{alias.name}")

    #             return imports
    #         except Exception as e:
                logger.debug(f"Error parsing imports: {e}")
    #             return []

    #     def analyze_dependencies(self) -> Dict[str, List[str]]:
    #         """
    #         Analyze dependencies between Python files.

    #         Returns:
    #             Dictionary mapping file paths to their dependencies
    #         """
            logger.info("Analyzing file dependencies...")
    dependencies = {}

    #         # Create a mapping of module names to file paths
    module_to_file = {}
    #         for file_path, file_info in self.migration_data["files"].items():
    #             # Convert file path to module name
    module_name = file_path.replace("/", ".").replace("\\", ".").replace(".py", "")
    module_to_file[module_name] = file_path

    #             # Also add parent modules
    parts = module_name.split(".")
    #             for i in range(1, len(parts)):
    parent_module = ".".join(parts[:i])
    #                 if parent_module not in module_to_file:
    module_to_file[parent_module] = file_path

    #         # Analyze dependencies for each file
    #         for file_path, file_info in self.migration_data["files"].items():
    file_deps = []
    #             for imp in file_info["imports"]:
    #                 # Check if the import matches any of our files
    #                 if imp in module_to_file and module_to_file[imp] != file_path:
                        file_deps.append(module_to_file[imp])
    #                 else:
    #                     # Check for partial matches
    #                     for module, module_file in module_to_file.items():
    #                         if imp.startswith(f"{module}.") and module_file != file_path:
                                file_deps.append(module_file)
    #                             break

    dependencies[file_path] = file_deps
    file_info["dependencies"] = file_deps

    self.migration_data["dependencies"] = dependencies
            logger.info("Dependency analysis completed")
    #         return dependencies

    #     def calculate_statistics(self) -> Dict:
    #         """
    #         Calculate migration progress statistics.

    #         Returns:
    #             Dictionary containing migration statistics
    #         """
            logger.info("Calculating migration statistics...")
    files = self.migration_data["files"]

    stats = {
                "total_files": len(files),
    #             "by_status": {},
    #             "by_directory": {},
    #             "by_size": {"migrated": 0, "partial": 0, "pending": 0, "unknown": 0, "not_applicable": 0},
    #             "progress_percentage": 0
    #         }

    #         # Count by status
    #         for file_info in files.values():
    status = file_info["migration_status"]
    stats["by_status"][status] = stats["by_status"].get(status, 0) + 1

    #             # Count by size
    #             if status in stats["by_size"]:
    stats["by_size"][status] + = file_info["size_bytes"]

    #             # Count by directory
    dir_name = os.path.dirname(file_info["relative_path"])
    #             if dir_name not in stats["by_directory"]:
    stats["by_directory"][dir_name] = {"total": 0, "by_status": {}}
    stats["by_directory"][dir_name]["total"] + = 1
    stats["by_directory"][dir_name]["by_status"][status] = \
                    stats["by_directory"][dir_name]["by_status"].get(status, 0) + 1

            # Calculate progress percentage (considering migrated files as complete)
    #         if stats["total_files"] > 0:
    migrated_count = stats["by_status"].get("migrated", 0)
    partial_count = stats["by_status"].get("partial", 0)
    stats["progress_percentage"] = round(
                    (migrated_count + 0.5 * partial_count) / stats["total_files"] * 100, 2
    #             )

    self.migration_data["statistics"] = stats
            logger.info(f"Migration progress: {stats['progress_percentage']}%")
    #         return stats

    #     def generate_visual_report(self, output_file: str) -> None:
    #         """
    #         Generate an HTML visual report of migration progress.

    #         Args:
    #             output_file: Path to save the HTML report
    #         """
            logger.info(f"Generating visual report to {output_file}")

    html_content = self._create_html_report()
    #         try:
    #             with open(output_file, 'w') as f:
                    f.write(html_content)
                logger.info(f"Visual report saved to {output_file}")
    #         except Exception as e:
                logger.error(f"Error saving visual report: {e}")

    #     def _create_html_report(self) -> str:
    #         """Create the HTML content for the visual report."""
    stats = self.migration_data["statistics"]
    files = self.migration_data["files"]

    #         # Create status color mapping
    status_colors = {
    #             "migrated": "#28a745",
    #             "partial": "#ffc107",
    #             "pending": "#dc3545",
    #             "unknown": "#6c757d",
    #             "not_applicable": "#17a2b8",
    #             "error": "#343a40"
    #         }

    #         # Create HTML content
    html = f"""
# <!DOCTYPE html>
# <html>
# <head>
#     <title>Migration Progress Report</title>
<script src = "https://cdn.jsdelivr.net/npm/chart.js"></script>
#     <style>
#         body {{ font-family: Arial, sans-serif; margin: 20px; }}
#         .container {{ max-width: 1200px; margin: 0 auto; }}
#         .header {{ text-align: center; margin-bottom: 30px; }}
        .stats-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }}
        .stat-card {{ background: #f8f9fa; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }}
#         .chart-container {{ margin-bottom: 30px; }}
#         .file-table {{ width: 100%; border-collapse: collapse; margin-top: 20px; }}
#         .file-table th, .file-table td {{ border: 1px solid #ddd; padding: 8px; text-align: left; }}
#         .file-table th {{ background-color: #f2f2f2; }}
#         .status-badge {{ padding: 4px 8px; border-radius: 4px; color: white; font-size: 12px; }}
#         .progress-bar {{ width: 100%; background-color: #f0f0f0; border-radius: 4px; margin: 10px 0; }}
#         .progress-fill {{ height: 20px; border-radius: 4px; background-color: #28a745; }}
#     </style>
# </head>
# <body>
<div class = "container">
<div class = "header">
#             <h1>Migration Progress Report</h1>
#             <p>Generated on: {self.migration_data['generated_at']}</p>
#         </div>

<div class = "stats-grid">
<div class = "stat-card">
#                 <h3>Overall Progress</h3>
<div class = "progress-bar">
<div class = "progress-fill" style="width: {stats['progress_percentage']}%"></div>
#                 </div>
#                 <p>{stats['progress_percentage']}% Complete</p>
                <p>{stats['by_status'].get('migrated', 0)} of {stats['total_files']} files migrated</p>
#             </div>

<div class = "stat-card">
#                 <h3>File Status Breakdown</h3>
#                 <ul>
# """

#         for status, count in stats["by_status"].items():
color = status_colors.get(status, "#6c757d")
html + = f'                    <li><span class="status-badge" style="background-color: {color}">{status}</span>: {count} files</li>\n'

html + = """
#                 </ul>
#             </div>

<div class = "stat-card">
#                 <h3>Directory Breakdown</h3>
#                 <ul>
# """

#         for dir_name, dir_stats in stats["by_directory"].items():
html + = f'                    <li>{dir_name}: {dir_stats["total"]} files</li>\n'

html + = """
#                 </ul>
#             </div>
#         </div>

<div class = "chart-container">
#             <h2>Migration Status Chart</h2>
<canvas id = "statusChart" width="400" height="200"></canvas>
#         </div>

<div class = "chart-container">
#             <h2>Directory Progress</h2>
<canvas id = "directoryChart" width="400" height="200"></canvas>
#         </div>

#         <h2>File Details</h2>
<table class = "file-table">
#             <thead>
#                 <tr>
#                     <th>File</th>
#                     <th>Status</th>
                    <th>Size (KB)</th>
#                     <th>Last Modified</th>
#                     <th>Dependencies</th>
#                 </tr>
#             </thead>
#             <tbody>
# """

#         for file_path, file_info in files.items():
status = file_info["migration_status"]
color = status_colors.get(status, "#6c757d")
size_kb = round(file_info["size_bytes"] / 1024, 2)
last_modified = datetime.fromtimestamp(file_info["last_modified"]).strftime("%Y-%m-%d %H:%M:%S")
deps_count = len(file_info["dependencies"])

html + = f"""
#                 <tr>
#                     <td>{file_path}</td>
<td><span class = "status-badge" style="background-color: {color}">{status}</span></td>
#                     <td>{size_kb}</td>
#                     <td>{last_modified}</td>
#                     <td>{deps_count}</td>
#                 </tr>
# """

html + = """
#             </tbody>
#         </table>
#     </div>

#     <script>
#         // Status Chart
const statusCtx = document.getElementById('statusChart').getContext('2d');
const statusChart = new Chart(statusCtx, {
#             type: 'doughnut',
#             data: {
                labels: """ + json.dumps(list(stats["by_status"].keys())) + """,
#                 datasets: [{
                    data: """ + json.dumps(list(stats["by_status"].values())) + """,
#                     backgroundColor: """ + json.dumps([status_colors.get(status, "#6c757d") for status in stats["by_status"].keys()]) + """
#                 }]
#             },
#             options: {
#                 responsive: true,
#                 plugins: {
#                     title: {
#                         display: true,
#                         text: 'Files by Migration Status'
#                     }
#                 }
#             }
#         });

#         // Directory Chart
const directoryCtx = document.getElementById('directoryChart').getContext('2d');
const directoryLabels = """ + json.dumps(list(stats["by_directory"].keys())) + """;
#         const migratedData = """ + json.dumps([dir_stats["by_status"].get("migrated", 0) for dir_stats in stats["by_directory"].values()]) + """;
#         const pendingData = """ + json.dumps([dir_stats["by_status"].get("pending", 0) for dir_stats in stats["by_directory"].values()]) + """;

const directoryChart = new Chart(directoryCtx, {
#             type: 'bar',
#             data: {
#                 labels: directoryLabels,
#                 datasets: [
#                     {
#                         label: 'Migrated',
#                         data: migratedData,
#                         backgroundColor: '#28a745'
#                     },
#                     {
#                         label: 'Pending',
#                         data: pendingData,
#                         backgroundColor: '#dc3545'
#                     }
#                 ]
#             },
#             options: {
#                 responsive: true,
#                 scales: {
#                     x: { stacked: true },
#                     y: { stacked: true }
#                 },
#                 plugins: {
#                     title: {
#                         display: true,
#                         text: 'Migration Status by Directory'
#                     }
#                 }
#             }
#         });
#     </script>
# </body>
# </html>
# """
#         return html

#     def export_json(self, output_file: str) -> None:
#         """Export migration data to JSON format."""
#         try:
#             with open(output_file, 'w') as f:
json.dump(self.migration_data, f, indent = 2)
            logger.info(f"Migration data exported to {output_file}")
#         except Exception as e:
            logger.error(f"Error exporting to JSON: {e}")

#     def export_csv(self, output_file: str) -> None:
#         """Export migration data to CSV format."""
#         try:
#             with open(output_file, 'w', newline='') as f:
writer = csv.writer(f)
                writer.writerow([
                    "File Path", "Migration Status", "Size (Bytes)", "Last Modified",
#                     "Dependencies Count", "Imports"
#                 ])

#                 for file_path, file_info in self.migration_data["files"].items():
                    writer.writerow([
#                         file_path,
#                         file_info["migration_status"],
#                         file_info["size_bytes"],
                        datetime.fromtimestamp(file_info["last_modified"]).isoformat(),
                        len(file_info["dependencies"]),
                        ", ".join(file_info["imports"])
#                     ])
            logger.info(f"Migration data exported to {output_file}")
#         except Exception as e:
            logger.error(f"Error exporting to CSV: {e}")

#     def run_tracking(self, output_dir: str = "migration_reports") -> Dict:
#         """
#         Run the complete migration tracking process.

#         Args:
#             output_dir: Directory to save reports

#         Returns:
#             Dictionary containing the migration data
#         """
        logger.info("Starting migration tracking...")

#         # Create output directory if it doesn't exist
os.makedirs(output_dir, exist_ok = True)

#         # Scan project files
        self.scan_project_files()

#         # Analyze dependencies
        self.analyze_dependencies()

#         # Calculate statistics
        self.calculate_statistics()

#         # Generate reports
timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        self.export_json(f"{output_dir}/migration_data_{timestamp}.json")
        self.export_csv(f"{output_dir}/migration_data_{timestamp}.csv")
        self.generate_visual_report(f"{output_dir}/migration_report_{timestamp}.html")

        logger.info("Migration tracking completed")
#         return self.migration_data


function main()
    #     """Main entry point for the script."""
    parser = argparse.ArgumentParser(
    description = "Track migration progress from Python to NoodleCore"
    #     )
        parser.add_argument(
    #         "--config",
    type = str,
    help = "Path to configuration file"
    #     )
        parser.add_argument(
    #         "--output-dir",
    type = str,
    default = "migration_reports",
    help = "Directory to save reports"
    #     )
        parser.add_argument(
    #         "--verbose",
    action = "store_true",
    help = "Enable verbose logging"
    #     )

    args = parser.parse_args()

    #     if args.verbose:
            logging.getLogger().setLevel(logging.DEBUG)

    #     # Create and run the tracker
    tracker = MigrationTracker(config_file=args.config)
    migration_data = tracker.run_tracking(args.output_dir)

    #     # Print summary
    stats = migration_data["statistics"]
        print("\nMigration Summary:")
        print(f"Total files: {stats['total_files']}")
        print(f"Progress: {stats['progress_percentage']}%")
        print(f"Migrated: {stats['by_status'].get('migrated', 0)}")
        print(f"Partially migrated: {stats['by_status'].get('partial', 0)}")
        print(f"Pending: {stats['by_status'].get('pending', 0)}")
        print(f"Reports saved to: {args.output_dir}")


if __name__ == "__main__"
        main()