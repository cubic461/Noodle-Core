# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# NoodleCore NBC Launcher and Performance Tester

# This script provides a dedicated launcher for executing NoodleCore (.nbc) files
# with integrated vector indexing capabilities and performance measurement.
# """

import os
import sys
import json
import time
import psutil
import argparse
import logging
import traceback
import pathlib.Path
import typing.Dict
from dataclasses import dataclass
import importlib.util

# Add the noodle-core directory to the path
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

# NoodleCore imports
import noodlecore.runtime.nbc_runtime.core.runtime.NBCRuntime
import noodlecore.runtime.nbc_runtime.instructions.InstructionHandler
import noodlecore.vector_db.indexer.FileIndexer
import noodlecore.vector_db.embedding_models.EmbeddingModelManager
import noodlecore.vector_db.storage.VectorIndex

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


dataclass
class PerformanceMetrics
    #     """Performance metrics for NBC execution and vector indexing."""

    #     # NBC Runtime metrics
    nbc_parse_time: float = 0.0
    nbc_execution_time: float = 0.0
    nbc_instructions_executed: int = 0
    nbc_memory_peak: float = 0.0

    #     # Vector indexing metrics
    vector_parse_time: float = 0.0
    vector_indexing_time: float = 0.0
    vector_embedding_time: float = 0.0
    files_processed: int = 0
    chunks_generated: int = 0
    embeddings_created: int = 0

    #     # System metrics
    cpu_usage: float = 0.0
    memory_usage: float = 0.0
    disk_io_read: int = 0
    disk_io_write: int = 0

    #     # Combined metrics
    total_time: float = 0.0
    success: bool = True
    errors: List[str] = field(default_factory=list)

    #     def to_dict(self) -Dict[str, Any]):
    #         """Convert to dictionary for serialization."""
    #         return {
    #             "nbc_runtime": {
    #                 "parse_time": self.nbc_parse_time,
    #                 "execution_time": self.nbc_execution_time,
    #                 "instructions_executed": self.nbc_instructions_executed,
    #                 "memory_peak_mb": self.nbc_memory_peak
    #             },
    #             "vector_indexing": {
    #                 "parse_time": self.vector_parse_time,
    #                 "indexing_time": self.vector_indexing_time,
    #                 "embedding_time": self.vector_embedding_time,
    #                 "files_processed": self.files_processed,
    #                 "chunks_generated": self.chunks_generated,
    #                 "embeddings_created": self.embeddings_created
    #             },
    #             "system": {
    #                 "cpu_usage_percent": self.cpu_usage,
    #                 "memory_usage_mb": self.memory_usage,
    #                 "disk_io_read_mb": self.disk_io_read,
    #                 "disk_io_write_mb": self.disk_io_write
    #             },
    #             "summary": {
    #                 "total_time": self.total_time,
    #                 "success": self.success,
    #                 "errors": self.errors
    #             }
    #         }


class NBCLauncher
    #     """Dedicated launcher for NoodleCore (.nbc) files with performance measurement."""

    #     def __init__(self, config: Optional[Dict[str, Any]] = None):""
    #         Initialize the NBC launcher.

    #         Args:
    #             config: Configuration dictionary
    #         """
    self.config = config or {}
    self.metrics = PerformanceMetrics()
    self.start_time = 0.0
    self.process = psutil.Process()

    #         # Initialize components
    self.nbc_runtime = None
    self.vector_indexer = None
    self.vector_index = None

            logger.info("NBC Launcher initialized")

    #     def _get_system_metrics(self) -Tuple[float, float, int, int]):
    #         """Get current system metrics."""
    cpu_percent = self.process.cpu_percent()
    memory_info = self.process.memory_info()
    memory_mb = memory_info.rss / (1024 * 1024)

    io_counters = self.process.io_counters()
    disk_read_mb = io_counters.read_bytes / (1024 * 1024)
    disk_write_mb = io_counters.write_bytes / (1024 * 1024)

    #         return cpu_percent, memory_mb, disk_read_mb, disk_write_mb

    #     def _parse_nbc_file(self, file_path: str) -List[Any]):
    #         """
    #         Parse a .nbc file into instructions.

    #         Args:
    #             file_path: Path to the .nbc file

    #         Returns:
    #             List of instructions
    #         """
    parse_start = time.time()

    #         try:
    #             # Read the file
    #             with open(file_path, 'r', encoding='utf-8') as f:
    content = f.read()

    #             # Simple parsing - in a real implementation, this would use the NBC parser
    #             # For now, we'll create a simple instruction set based on the content

    #             # Create an instruction handler
    handler = InstructionHandler(is_debug=True)

    #             # Create a basic program from the content
    #             # This is a simplified implementation - real NBC parsing would be more complex
    instructions = []
    lines = content.split('\n')

    #             for line_num, line in enumerate(lines):
    line = line.strip()
    #                 if not line or line.startswith('#'):
    #                     continue

    #                 # Simple instruction parsing - this is a placeholder
    #                 # In a real implementation, this would use the actual NBC parser
    #                 if 'print' in line:
    #                     # Extract the string to print
    start = line.find('"') + 1
    end = line.rfind('"')
    #                     if start 0 and end > start):
    text = line[start:end]
                            instructions.append({
    #                             'type': 'PRINT',
    #                             'operands': [text],
    #                             'line': line_num + 1
    #                         })
    #                 elif '=' in line and not line.startswith('def'):
    #                     # Variable assignment
    var, value = line.split('=', 1)
                        instructions.append({
    #                         'type': 'ASSIGN',
                            'operands': [var.strip(), value.strip()],
    #                         'line': line_num + 1
    #                     })
    #                 elif line.startswith('def '):
    #                     # Function definition
    func_name = line[4:].split('(')[0].strip()
                        instructions.append({
    #                         'type': 'FUNC_DEF',
    #                         'operands': [func_name],
    #                         'line': line_num + 1
    #                     })
    #                 elif line.startswith('return '):
    #                     # Return statement
    value = line[7:].strip()
                        instructions.append({
    #                         'type': 'RETURN',
    #                         'operands': [value],
    #                         'line': line_num + 1
    #                     })

    parse_time = time.time() - parse_start
    self.metrics.nbc_parse_time = parse_time

                logger.info(f"Parsed {len(instructions)} instructions from {file_path} in {parse_time:.4f}s")
    #             return instructions

    #         except Exception as e:
    error_msg = f"Error parsing NBC file {file_path}: {str(e)}"
                logger.error(error_msg)
                self.metrics.errors.append(error_msg)
    self.metrics.success = False
    #             return []

    #     def _execute_nbc_instructions(self, instructions: List[Any]) -bool):
    #         """
    #         Execute NBC instructions.

    #         Args:
    #             instructions: List of instructions to execute

    #         Returns:
    #             True if successful, False otherwise
    #         """
    #         if not instructions:
                logger.warning("No instructions to execute")
    #             return True

    exec_start = time.time()
    initial_memory = 0

    #         try:
    #             # Get initial memory usage
    initial_memory = self.process.memory_info().rss / (1024 * 1024)

    #             # Create NBC runtime
    runtime_config = RuntimeConfig(
    max_stack_depth = 1000,
    max_execution_time = 300.0,  # 5 minutes
    max_memory_usage = 512 * 1024 * 1024,  # 512MB
    enable_profiling = True
    #             )

    self.nbc_runtime = NBCRuntime(runtime_config)

    #             # Execute instructions
    #             # In a real implementation, this would convert our simple instructions
    #             # to proper NBC instruction objects
    #             for instruction in instructions:
    #                 if instruction['type'] == 'PRINT':
                        print(f"[NBC] {instruction['operands'][0]}")
    #                 elif instruction['type'] == 'ASSIGN':
    var, value = instruction['operands']
    print(f"[NBC] {var} = {value}")
    #                 elif instruction['type'] == 'FUNC_DEF':
                        print(f"[NBC] Function defined: {instruction['operands'][0]}")
    #                 elif instruction['type'] == 'RETURN':
                        print(f"[NBC] Return: {instruction['operands'][0]}")

    self.metrics.nbc_instructions_executed + = 1

    #                 # Check memory usage
    current_memory = self.process.memory_info().rss / (1024 * 1024)
    #                 if current_memory self.metrics.nbc_memory_peak):
    self.metrics.nbc_memory_peak = current_memory

    exec_time = time.time() - exec_start
    self.metrics.nbc_execution_time = exec_time

                logger.info(f"Executed {len(instructions)} instructions in {exec_time:.4f}s")
    #             return True

    #         except Exception as e:
    error_msg = f"Error executing NBC instructions: {str(e)}"
                logger.error(error_msg)
                self.metrics.errors.append(error_msg)
    self.metrics.success = False
    #             return False
    #         finally:
    #             # Clean up runtime
    #             if self.nbc_runtime:
    #                 try:
                        self.nbc_runtime.stop()
    #                 except AttributeError as e:
    #                     # Handle case where cleanup method doesn't exist
                        logger.warning(f"Runtime cleanup warning: {str(e)}")
    #                     # Try alternative cleanup if needed
    #                     if hasattr(self.nbc_runtime, 'resource_manager') and hasattr(self.nbc_runtime.resource_manager, 'cleanup_all_resources'):
                            self.nbc_runtime.resource_manager.cleanup_all_resources()

    #     def _index_file_with_vectors(self, file_path: str) -bool):
    #         """
    #         Index a file using vector database.

    #         Args:
    #             file_path: Path to the file to index

    #         Returns:
    #             True if successful, False otherwise
    #         """
    vector_start = time.time()
    parse_start = vector_start

    #         try:
    #             # Initialize components
    self.vector_indexer = FileIndexer()
    self.vector_index = VectorIndex(backend="sqlite")

    #             # Extract content
    parse_start = time.time()
    content = self.vector_indexer.extract_content(file_path)
    #             if not content:
                    logger.warning(f"No content extracted from {file_path}")
    #                 return True

    parse_time = time.time() - parse_start
    self.metrics.vector_parse_time = parse_time

    #             # Extract chunks
    chunks = self.vector_indexer.extract_chunks(file_path, content)
    self.metrics.chunks_generated = len(chunks)

    #             if not chunks:
                    logger.warning(f"No chunks generated from {file_path}")
    #                 return True

    #             # Generate embeddings
    embed_start = time.time()
    embeddings = self.vector_indexer.generate_embeddings(chunks)
    embed_time = time.time() - embed_start
    self.metrics.vector_embedding_time = embed_time

    #             # Add to vector index
    index_start = time.time()
    #             chunk_ids = [emb[0] for emb in embeddings]
    #             embedding_matrices = [emb[1] for emb in embeddings]

    metadata = []
    #             for chunk in chunks:
    meta = chunk.metadata.copy()
    meta["file_path"] = chunk.file_path
    meta["file_type"] = chunk.file_type
                    metadata.append(meta)

                self.vector_index.add(chunk_ids, embedding_matrices, metadata)
    index_time = time.time() - index_start
    self.metrics.vector_indexing_time = index_time

    total_time = time.time() - vector_start
    self.metrics.files_processed = 1
    self.metrics.embeddings_created = len(embeddings)

                logger.info(f"Indexed {file_path} in {total_time:.4f}s: {len(chunks)} chunks, {len(embeddings)} embeddings")
    #             return True

    #         except Exception as e:
    error_msg = f"Error indexing file {file_path}: {str(e)}"
                logger.error(error_msg)
                self.metrics.errors.append(error_msg)
    self.metrics.success = False
    #             return False

    #     def _index_noodle_project(self, project_root: str) -bool):
    #         """
    #         Index the entire Noodle project using the async file indexer.

    #         Args:
    #             project_root: Root directory of the Noodle project

    #         Returns:
    #             True if successful, False otherwise
    #         """
    vector_start = time.time()

    #         try:
    #             # Initialize async file indexer
    self.vector_indexer = AsyncFileIndexer(
    max_workers = 8,
    batch_size = 50
    #             )
    self.vector_index = VectorIndex(backend="sqlite")

    #             # Progress callback
    #             def progress_callback(batch_num, total_batches, chunks_processed, errors):
                    logger.info(
    #                     f"Progress: Batch {batch_num}/{total_batches}, "
    #                     f"{chunks_processed} chunks processed, {errors} errors"
    #                 )

    #             # Index the project
    stats = self.vector_indexer.index_noodle_project(
    project_root = project_root,
    vector_index = self.vector_index,
    progress_callback = progress_callback
    #             )

    #             # Update metrics
    self.metrics.vector_indexing_time = time.time() - vector_start
    self.metrics.files_processed = stats["total_files"]
    self.metrics.chunks_generated = stats["total_chunks"]
    self.metrics.embeddings_created = stats["total_embeddings"]

    #             # Add any errors to metrics
    #             if stats["errors"]:
                    self.metrics.errors.extend(stats["errors"][:10])  # Limit to first 10 errors
    #                 if len(stats["errors"]) 10):
                        self.metrics.errors.append(f"... and {len(stats['errors']) - 10} more errors")

                logger.info(f"Noodle project indexing completed in {self.metrics.vector_indexing_time:.2f}s")
                logger.info(f"Processed {stats['total_files']} files, {stats['total_chunks']} chunks, {stats['total_embeddings']} embeddings")

    #             return True

    #         except Exception as e:
    error_msg = f"Error indexing Noodle project: {str(e)}"
                logger.error(error_msg)
                self.metrics.errors.append(error_msg)
    self.metrics.success = False
    #             return False

    #     def run_nbc_file(self, file_path: str, run_vector_indexing: bool = False) -PerformanceMetrics):
    #         """
    #         Run a .nbc file and measure performance.

    #         Args:
    #             file_path: Path to the .nbc file
    #             run_vector_indexing: Whether to also run vector indexing

    #         Returns:
    #             Performance metrics
    #         """
    self.metrics = PerformanceMetrics()
    self.start_time = time.time()

    #         # Get initial system metrics
    initial_cpu, initial_memory, initial_read, initial_write = self._get_system_metrics()

            logger.info(f"Running NBC file: {file_path}")

    #         # Parse the NBC file
    instructions = self._parse_nbc_file(file_path)
    #         if not instructions and self.metrics.errors:
    #             # We had parsing errors
    self.metrics.total_time = time.time() - self.start_time
    #             return self.metrics

    #         # Execute NBC instructions
    #         if not self._execute_nbc_instructions(instructions):
    #             # We had execution errors
    self.metrics.total_time = time.time() - self.start_time
    #             return self.metrics

    #         # Run vector indexing if requested
    #         if run_vector_indexing:
                logger.info("Running vector indexing on the same file")
    #             if not self._index_file_with_vectors(file_path):
    #                 # We had indexing errors
    self.metrics.total_time = time.time() - self.start_time
    #                 return self.metrics

    #     def index_noodle_project(self, project_root: str) -PerformanceMetrics):
    #         """
    #         Index the entire Noodle project.

    #         Args:
    #             project_root: Root directory of the Noodle project

    #         Returns:
    #             Performance metrics
    #         """
    self.metrics = PerformanceMetrics()
    self.start_time = time.time()

    #         # Get initial system metrics
    initial_cpu, initial_memory, initial_read, initial_write = self._get_system_metrics()

            logger.info(f"Indexing Noodle project at: {project_root}")

    #         # Index the project
    #         if not self._index_noodle_project(project_root):
    #             # We had indexing errors
    self.metrics.total_time = time.time() - self.start_time
    #             return self.metrics

    #         # Get final system metrics
    final_cpu, final_memory, final_read, final_write = self._get_system_metrics()

    #         # Calculate system metrics
    self.metrics.cpu_usage = final_cpu
    self.metrics.memory_usage = final_memory
    self.metrics.disk_io_read = final_read - initial_read
    self.metrics.disk_io_write = final_write - initial_write

    #         # Calculate total time
    self.metrics.total_time = time.time() - self.start_time

            logger.info(f"Completed project indexing in {self.metrics.total_time:.4f}s")
    #         return self.metrics

    #         # Get final system metrics
    final_cpu, final_memory, final_read, final_write = self._get_system_metrics()

    #         # Calculate system metrics
    self.metrics.cpu_usage = final_cpu
    self.metrics.memory_usage = final_memory
    self.metrics.disk_io_read = final_read - initial_read
    self.metrics.disk_io_write = final_write - initial_write

    #         # Calculate total time
    self.metrics.total_time = time.time() - self.start_time

            logger.info(f"Completed execution in {self.metrics.total_time:.4f}s")
    #         return self.metrics

    #     def compare_with_other_indexers(self, file_path: str) -Dict[str, Any]):
    #         """
    #         Compare performance with other vector indexers.

    #         Args:
    #             file_path: Path to the file to index

    #         Returns:
    #             Comparison results
    #         """
    results = {
    "nbc_launcher": self.run_nbc_file(file_path, run_vector_indexing = True).to_dict(),
    #             "optimized_vector_indexer": {}
    #         }

    #         try:
    #             # Import and run the optimized vector indexer
    #             from noodlecore.cli.optimized_vector_indexer import OptimizedVectorIndexer

    #             logger.info("Running OptimizedVectorIndexer for comparison")
    start_time = time.time()

    #             # Create a temporary directory for the index
    #             import tempfile
    #             with tempfile.TemporaryDirectory() as temp_dir:
    #                 # Copy the file to the temp directory
    #                 import shutil
    temp_file = math.divide(Path(temp_dir), Path(file_path).name)
                    shutil.copy2(file_path, temp_file)

    indexer = OptimizedVectorIndexer(
    project_root = temp_dir,
    max_workers = 4,
    batch_size = 10
    #                 )

    #                 # Initialize vector index
    indexer.vector_index = VectorIndex(backend="sqlite")

    #                 # Index the file
    success = indexer.index_files(resume=False)

    #                 # Get stats
    stats = indexer.stats

                    indexer.cleanup()

    total_time = time.time() - start_time

    results["optimized_vector_indexer"] = {
    #                 "vector_indexing": {
    #                     "parse_time": 0,  # Not tracked separately
    #                     "indexing_time": total_time,
    #                     "embedding_time": 0,  # Not tracked separately
    #                     "files_processed": stats.processed_files,
    #                     "chunks_generated": stats.total_chunks,
    #                     "embeddings_created": stats.indexed_chunks
    #                 },
    #                 "summary": {
    #                     "total_time": total_time,
    #                     "success": success,
    #                     "errors": stats.errors
    #                 }
    #             }

    #         except Exception as e:
    error_msg = f"Error running OptimizedVectorIndexer: {str(e)}"
                logger.error(error_msg)
    results["optimized_vector_indexer"] = {
    #                 "summary": {
    #                     "total_time": 0,
    #                     "success": False,
    #                     "errors": [error_msg]
    #                 }
    #             }

    #         return results


function main()
    #     """Main entry point for the NBC launcher."""
    parser = argparse.ArgumentParser(
    description = "NoodleCore NBC Launcher and Performance Tester",
    formatter_class = argparse.ArgumentDefaultsHelpFormatter
    #     )

        parser.add_argument(
    #         "file",
    help = "Path to the .nbc file to execute"
    #     )

        parser.add_argument(
    #         "--vector-indexing",
    action = "store_true",
    help = "Also run vector indexing on the file"
    #     )

        parser.add_argument(
    #         "--index-project",
    action = "store_true",
    help = "Index the entire Noodle project"
    #     )

        parser.add_argument(
    #         "--project-root",
    type = str,
    default = ".",
    help = "Root directory of the Noodle project to index (default: current directory)"
    #     )

        parser.add_argument(
    #         "--compare",
    action = "store_true",
    #         help="Compare performance with other vector indexers"
    #     )

        parser.add_argument(
    #         "--output",
    #         "-o",
    #         help="Output file for performance metrics (JSON format)"
    #     )

        parser.add_argument(
    #         "--verbose",
    #         "-v",
    action = "store_true",
    help = "Enable verbose output"
    #     )

    args = parser.parse_args()

    #     # Set up logging
    #     log_level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(level = log_level)

    #     # Check if file exists
    file_path = Path(args.file)
    #     if not file_path.exists():
            logger.error(f"File not found: {args.file}")
            sys.exit(1)

    #     # Create launcher
    launcher = NBCLauncher()

    #     # Run the file
    #     if args.compare:
    #         # Run comparison
    results = launcher.compare_with_other_indexers(str(file_path))

    #         # Print results
    print("\n = == Performance Comparison Results ===\n")
    print(json.dumps(results, indent = 2))

    #         # Save results if requested
    #         if args.output:
    #             with open(args.output, 'w') as f:
    json.dump(results, f, indent = 2)
                print(f"\nResults saved to: {args.output}")

    #         # Return appropriate exit code
    success = results.get("nbc_launcher", {}).get("summary", {}).get("success", False)
    #         sys.exit(0 if success else 1)
    #     elif args.index_project:
    #         # Index the entire Noodle project
    metrics = launcher.index_noodle_project(args.project_root)

    #         # Print metrics
    print("\n = == Noodle Project Indexing Metrics ===\n")
    print(json.dumps(metrics.to_dict(), indent = 2))

    #         # Save metrics if requested
    #         if args.output:
    #             with open(args.output, 'w') as f:
    json.dump(metrics.to_dict(), f, indent = 2)
                print(f"\nMetrics saved to: {args.output}")

    #         # Return appropriate exit code
    #         sys.exit(0 if metrics.success else 1)
    #     else:
    #         # Run just the NBC file
    metrics = launcher.run_nbc_file(str(file_path), args.vector_indexing)

    #         # Print metrics
    print("\n = == Performance Metrics ===\n")
    print(json.dumps(metrics.to_dict(), indent = 2))

    #         # Save metrics if requested
    #         if args.output:
    #             with open(args.output, 'w') as f:
    json.dump(metrics.to_dict(), f, indent = 2)
                print(f"\nMetrics saved to: {args.output}")

    #         # Return appropriate exit code
    #         sys.exit(0 if metrics.success else 1)


if __name__ == "__main__"
        main()