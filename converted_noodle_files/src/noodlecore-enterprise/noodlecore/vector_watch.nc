# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Vector Database Watch Script

# This script watches for file changes in the Noodle project and automatically
# updates the vector database using the noodle vector index command.
# """

import os
import sys
import time
import logging
import subprocess
import pathlib.Path
import typing.Set,
import argparse

try
    #     from watchdog.observers import Observer
    #     from watchdog.events import FileSystemEventHandler
except ImportError
        print("Error: watchdog package is required. Install with: pip install watchdog")
        sys.exit(1)

# Configure logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('vector_watch.log'),
        logging.StreamHandler()
#     ]
# )
logger = logging.getLogger(__name__)

# File extensions to monitor for changes
MONITORED_EXTENSIONS = {
#     '.py', '.md', '.txt', '.json', '.yaml', '.yml', '.toml', '.cfg', '.ini'
# }

# Directories to exclude from monitoring
EXCLUDED_DIRS = {
#     '.git', '__pycache__', '.pytest_cache', 'node_modules', '.venv', 'venv',
#     'dist', 'build', '.coverage', 'htmlcov'
# }

class VectorIndexHandler(FileSystemEventHandler)
    #     """Handles file system events and triggers vector indexing."""

    #     def __init__(self, project_root: Path, debounce_time: float = 5.0):
            super().__init__()
    self.project_root = project_root
    self.debounce_time = debounce_time
    self.pending_files: Dict[str, float] = {}
    self.last_index_time = 0

    #     def on_modified(self, event):
    #         """Called when a file is modified."""
    #         if event.is_directory:
    #             return

    file_path = Path(event.src_path)
    #         if self._should_monitor_file(file_path):
                self._schedule_indexing(file_path)

    #     def on_created(self, event):
    #         """Called when a file is created."""
    #         if event.is_directory:
    #             return

    file_path = Path(event.src_path)
    #         if self._should_monitor_file(file_path):
                self._schedule_indexing(file_path)

    #     def _should_monitor_file(self, file_path: Path) -> bool:
    #         """Check if the file should be monitored based on extension and path."""
    #         # Check file extension
    #         if file_path.suffix.lower() not in MONITORED_EXTENSIONS:
    #             return False

    #         # Check if file is in an excluded directory
    #         for part in file_path.parts:
    #             if part in EXCLUDED_DIRS:
    #                 return False

    #         return True

    #     def _schedule_indexing(self, file_path: Path):
    #         """Schedule a file for indexing with debouncing."""
    file_str = str(file_path)
    current_time = time.time()
    self.pending_files[file_str] = current_time

    #         logger.info(f"Scheduled file for indexing: {file_path}")

    #         # Check if we should trigger indexing now
    #         if len(self.pending_files) >= 5 or (current_time - self.last_index_time) > self.debounce_time:
                self._trigger_indexing()

    #     def _trigger_indexing(self):
    #         """Trigger the vector indexing process using NoodleCore optimized vector indexer."""
    #         if not self.pending_files:
    #             return

    current_time = time.time()

            # Filter files that are old enough (debouncing)
    files_to_index = [
    #             file_path for file_path, timestamp in self.pending_files.items()
    #             if current_time - timestamp >= self.debounce_time
    #         ]

    #         if not files_to_index:
    #             return

    #         # Clear the pending files that we're processing
    #         for file_path in files_to_index:
                self.pending_files.pop(file_path, None)

    self.last_index_time = current_time

    #         logger.info(f"Triggering vector indexing for {len(files_to_index)} files")

    #         try:
    #             # Try to use NoodleCore optimized vector indexer first
    #             try:
    #                 from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

    #                 # Initialize the indexer
    indexer = OptimizedVectorIndexer(
    project_root = self.project_root,
    max_workers = 8,
    batch_size = 100,
    chunk_size = 50
    #                 )

    #                 # Run indexing
    success = indexer.index_files(resume=True)
                    indexer.cleanup()

    #                 if success:
    #                     logger.info("Vector indexing completed successfully with NoodleCore")
    #                     return
    #                 else:
                        logger.warning("NoodleCore vector indexing failed, falling back to original implementation")
    #             except ImportError:
                    logger.info("NoodleCore not available, using original implementation")
    #             except Exception as e:
    #                 logger.warning(f"Failed to index with NoodleCore: {e}")
                    logger.info("Falling back to original implementation")

    #             # Fallback to original implementation
    cmd = ["noodle", "vector", "index", "--project", str(self.project_root)]
    result = subprocess.run(
    #                 cmd,
    cwd = self.project_root,
    capture_output = True,
    text = True,
    timeout = 300  # 5 minute timeout
    #             )

    #             if result.returncode == 0:
                    logger.info("Vector indexing completed successfully")
    #             else:
                    logger.error(f"Vector indexing failed: {result.stderr}")

    #         except subprocess.TimeoutExpired:
                logger.error("Vector indexing timed out after 5 minutes")
    #         except Exception as e:
                logger.error(f"Error during vector indexing: {str(e)}")

def setup_vector_db(project_root: Path) -> bool:
#     """Initialize the vector database if it doesn't exist using NoodleCore."""
#     try:
#         # Try to use NoodleCore optimized vector indexer first
#         try:
#             from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

#             # Initialize the indexer
indexer = OptimizedVectorIndexer(
project_root = project_root,
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
            logger.info("NoodleCore not available, using original implementation")
#         except Exception as e:
#             logger.warning(f"Failed to initialize with NoodleCore: {e}")
            logger.info("Falling back to original implementation")

#         # Fallback to original implementation
cmd = ["noodle", "vector", "init", "--project", str(project_root)]
result = subprocess.run(
#             cmd,
cwd = project_root,
capture_output = True,
text = True,
timeout = 60  # 1 minute timeout
#         )

#         if result.returncode == 0:
            logger.info("Vector database initialized successfully")
#             return True
#         else:
            logger.error(f"Vector database initialization failed: {result.stderr}")
#             return False

#     except subprocess.TimeoutExpired:
        logger.error("Vector database initialization timed out")
#         return False
#     except Exception as e:
        logger.error(f"Error initializing vector database: {str(e)}")
#         return False

function main()
    #     """Main entry point for the vector watch script."""
    #     parser = argparse.ArgumentParser(description="Watch for file changes and update vector database")
        parser.add_argument(
    #         "--project-root",
    type = str,
    default = ".",
    help = "Path to the project root directory (default: current directory)"
    #     )
        parser.add_argument(
    #         "--debounce-time",
    type = float,
    default = 5.0,
    help = "Time in seconds to wait before triggering indexing (default: 5.0)"
    #     )
        parser.add_argument(
    #         "--init-db",
    action = "store_true",
    help = "Initialize the vector database before starting to watch"
    #     )

    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()

    #     if not project_root.exists():
            logger.error(f"Project root does not exist: {project_root}")
            sys.exit(1)

    #     logger.info(f"Starting vector watch for project: {project_root}")

    #     # Initialize vector database if requested
    #     if args.init_db:
    #         if not setup_vector_db(project_root):
                logger.error("Failed to initialize vector database")
                sys.exit(1)

    #     # Set up the file system observer
    event_handler = VectorIndexHandler(project_root, args.debounce_time)
    observer = Observer()
    observer.schedule(event_handler, str(project_root), recursive = True)

    #     try:
            observer.start()
            logger.info("File watcher started. Press Ctrl+C to stop.")

    #         # Keep the script running
    #         while True:
                time.sleep(1)

    #     except KeyboardInterrupt:
            logger.info("Stopping file watcher...")
            observer.stop()

        observer.join()
        logger.info("File watcher stopped")

if __name__ == "__main__"
        main()