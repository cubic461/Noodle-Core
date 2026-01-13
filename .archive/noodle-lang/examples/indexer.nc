# Converted from Python to NoodleCore
# Original file: src

# """Indexer for processing project files and generating embeddings.

# Handles file discovery, content extraction, chunking, and embedding generation.
# """

import asyncio
import concurrent.futures
import hashlib
import json
import logging
import mimetypes
import os
import time
import abc.ABC
from dataclasses import dataclass
import pathlib.Path
import typing.Any

import noodlecore.runtime.nbc_runtime.mathematical_objects.Matrix

import .embedding_models.EmbeddingModel
import .storage.VectorIndex

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


dataclass
class DocumentChunk
    #     """Represents a chunk of document content with metadata."""

    #     id: str
    #     content: str
    #     file_path: str
    #     file_type: str
    line_start: Optional[int] = None
    line_end: Optional[int] = None
    char_start: Optional[int] = None
    char_end: Optional[int] = None
    metadata: Optional[Dict[str, Any]] = None

    #     def __post_init__(self):
    #         if self.metadata is None:
    self.metadata = {}


class ContentExtractor(ABC)
    #     """Abstract base class for content extractors."""

    #     @abstractmethod
    #     def can_extract(self, file_path: str, file_type: str) -bool):
    #         """Check if this extractor can handle the file type."""
    #         pass

    #     @abstractmethod
    #     def extract(self, file_path: str, content: str) -List[DocumentChunk]):
    #         """Extract chunks from file content."""
    #         pass


class TextContentExtractor(ContentExtractor)
    #     """Basic text content extractor."""

    #     def can_extract(self, file_path: str, file_type: str) -bool):
    #         """Handle plain text files."""
    text_extensions = {
    #             ".txt",
    #             ".md",
    #             ".py",
    #             ".js",
    #             ".ts",
    #             ".jsx",
    #             ".tsx",
    #             ".java",
    #             ".cpp",
    #             ".c",
    #             ".h",
    #             ".hpp",
    #             ".cs",
    #             ".go",
    #             ".rs",
    #             ".php",
    #             ".rb",
    #             ".pl",
    #             ".sh",
    #             ".bat",
    #             ".sql",
    #         }
    #         return any(file_path.lower().endswith(ext) for ext in text_extensions)

    #     def extract(self, file_path: str, content: str) -List[DocumentChunk]):
    #         """Extract chunks from text files with line-based chunking."""
    chunks = []

    #         # Split by lines and create chunks
    lines = content.split("\n")
    chunk_size = 50  # lines per chunk
    overlap = 5  # lines of overlap between chunks

    #         for i in range(0, len(lines), chunk_size - overlap):
    chunk_lines = lines[i : i + chunk_size]
    chunk_content = "\n".join(chunk_lines)

    #             # Create chunk ID
    chunk_id = f"{file_path}:{i}-{i + len(chunk_lines)}"

    #             # Create chunk
    chunk = DocumentChunk(
    id = chunk_id,
    content = chunk_content,
    file_path = file_path,
    file_type = "text",
    line_start = i,
    line_end = i + len(chunk_lines,)
    metadata = {
                        "file_name": os.path.basename(file_path),
                        "total_lines": len(lines),
                        "chunk_lines": len(chunk_lines),
    #                 },
    #             )
                chunks.append(chunk)

    #         return chunks


class CodeContentExtractor(ContentExtractor)
    #     """Code-specific content extractor with syntax-aware chunking."""

    #     def can_extract(self, file_path: str, file_type: str) -bool):
    #         """Handle code files."""
    code_extensions = {
    #             ".py",
    #             ".js",
    #             ".ts",
    #             ".jsx",
    #             ".tsx",
    #             ".java",
    #             ".cpp",
    #             ".c",
    #             ".h",
    #             ".hpp",
    #             ".cs",
    #             ".go",
    #             ".rs",
    #         }
    #         return any(file_path.lower().endswith(ext) for ext in code_extensions)

    #     def extract(self, file_path: str, content: str) -List[DocumentChunk]):
    #         """Extract chunks from code files with function/class boundaries."""
    chunks = []

    #         # Simple heuristic: split by functions/classes
    lines = content.split("\n")
    i = 0
    chunk_num = 0

    #         while i < len(lines):
    #             # Look for function/class definitions
    line = lines[i].strip()

    #             # Skip empty lines and comments
    #             if (
    #                 not line
                    or line.startswith("#")
                    or line.startswith("//")
                    or line.startswith("/*")
    #             ):
    i + = 1
    #                 continue

    #             # Check for function/class definition
    #             if (
    #                 line.startswith("def ")
    #                 or line.startswith("class ")
                    or line.startswith("function ")
                    or line.startswith("const ")
                    or line.startswith("let ")
                    or line.startswith("var ")
                    or line.startswith("public ")
                    or line.startswith("private ")
                    or line.startswith("protected ")
                    or line.startswith("interface ")
    #             ):

    #                 # Found a definition, extract until next definition or end
    start_line = i
    i + = 1

    #                 # Find the end of this definition
    #                 while i < len(lines):
    next_line = lines[i].strip()

    #                     # Stop at next definition or end of file
    #                     if (
    #                         next_line.startswith("def ")
    #                         or next_line.startswith("class ")
                            or next_line.startswith("function ")
                            or next_line.startswith("const ")
                            or next_line.startswith("let ")
                            or next_line.startswith("var ")
                            or next_line.startswith("public ")
                            or next_line.startswith("private ")
                            or next_line.startswith("protected ")
                            or next_line.startswith("interface ")
    #                     ):
    #                         break

    i + = 1

    #                 # Create chunk for this definition
    chunk_lines = lines[start_line:i]
    chunk_content = "\n".join(chunk_lines)

    #                 # Create chunk ID
    chunk_id = f"{file_path}:{start_line}-{i}"

    #                 # Create chunk
    chunk = DocumentChunk(
    id = chunk_id,
    content = chunk_content,
    file_path = file_path,
    file_type = "code",
    line_start = start_line,
    line_end = i,
    metadata = {
                            "file_name": os.path.basename(file_path),
                            "definition_type": self._get_definition_type(chunk_lines[0]),
                            "chunk_lines": len(chunk_lines),
    #                         "chunk_num": chunk_num,
    #                     },
    #                 )
                    chunks.append(chunk)
    chunk_num + = 1
    #             else:
    #                 # Not a definition, add to previous chunk or create new one
    i + = 1

    #         return chunks

    #     def _get_definition_type(self, first_line: str) -str):
    #         """Extract definition type from first line."""
    first_line = first_line.strip()
    #         if first_line.startswith("def "):
    #             return "function"
    #         elif first_line.startswith("class "):
    #             return "class"
    #         elif first_line.startswith("function "):
    #             return "function"
    #         elif first_line.startswith("const "):
    #             return "constant"
    #         elif first_line.startswith("let "):
    #             return "variable"
    #         elif first_line.startswith("var "):
    #             return "variable"
    #         elif first_line.startswith("public "):
    #             return "method"
    #         elif first_line.startswith("private "):
    #             return "method"
    #         elif first_line.startswith("protected "):
    #             return "method"
    #         elif first_line.startswith("interface "):
    #             return "interface"
    #         else:
    #             return "unknown"


class MarkdownContentExtractor(ContentExtractor)
    #     """Markdown content extractor with header-based chunking."""

    #     def can_extract(self, file_path: str, file_type: str) -bool):
    #         """Handle markdown files."""
            return file_path.lower().endswith(".md")

    #     def extract(self, file_path: str, content: str) -List[DocumentChunk]):
    #         """Extract chunks from markdown files based on headers."""
    chunks = []
    lines = content.split("\n")

    #         # Find header levels
    headers = []
    #         for i, line in enumerate(lines):
    line = line.strip()
    #             if line.startswith("#"):
    level = len(line) - len(line.lstrip("#"))
                    headers.append((i, level, line.strip("#").strip()))

    #         # Create chunks for each header section
    #         if headers:
    #             # Add the content before the first header
    #             if headers[0][0] 0):
    chunk_content = "\n".join(lines[0 : headers[0][0]])
    chunk_id = f"{file_path}:0-{headers[0][0]}"
    chunk = DocumentChunk(
    id = chunk_id,
    content = chunk_content,
    file_path = file_path,
    file_type = "markdown",
    line_start = 0,
    line_end = headers[0][0],
    metadata = {
                            "file_name": os.path.basename(file_path),
    #                         "section": "preamble",
    #                     },
    #                 )
                    chunks.append(chunk)

    #             # Create chunks for each header section
    #             for i in range(len(headers)):
    start_line = headers[i][0]
    header_text = headers[i][2]
    header_level = headers[i][1]

    #                 # Find end of this section
    end_line = len(lines)
    #                 if i + 1 < len(headers):
    end_line = headers[i + 1][0]

    #                 # Extract content
    section_lines = lines[start_line:end_line]
    chunk_content = "\n".join(section_lines)

    #                 # Create chunk ID
    chunk_id = f"{file_path}:{start_line}-{end_line}"

    #                 # Create chunk
    chunk = DocumentChunk(
    id = chunk_id,
    content = chunk_content,
    file_path = file_path,
    file_type = "markdown",
    line_start = start_line,
    line_end = end_line,
    metadata = {
                            "file_name": os.path.basename(file_path),
    #                         "header": header_text,
    #                         "header_level": header_level,
    #                         "section": "header",
    #                     },
    #                 )
                    chunks.append(chunk)
    #         else:
    #             # No headers found, treat as single chunk
    chunk_id = f"{file_path}:0-{len(lines)}"
    chunk = DocumentChunk(
    id = chunk_id,
    content = content,
    file_path = file_path,
    file_type = "markdown",
    line_start = 0,
    line_end = len(lines),
    metadata = {"file_name": os.path.basename(file_path), "section": "full"},
    #             )
                chunks.append(chunk)

    #         return chunks


class FileIndexer
    #     """Indexes project files and generates embeddings."""

    #     def __init__(
    #         self,
    embedding_manager: Optional[EmbeddingModelManager] = None,
    extractors: Optional[List[ContentExtractor]] = None,
    #     ):""
    #         Initialize file indexer.

    #         Args:
    #             embedding_manager: Manager for embedding models
    #             extractors: List of content extractors
    #         """
    self.embedding_manager = embedding_manager or EmbeddingModelManager()
    self.extractors = extractors or [
                TextContentExtractor(),
                CodeContentExtractor(),
                MarkdownContentExtractor(),
    #         ]

    #     def discover_files(
    #         self,
    #         root_path: str,
    include_patterns: Optional[List[str]] = None,
    exclude_patterns: Optional[List[str]] = None,
    #     ) -List[str]):
    #         """
    #         Discover files to index in the project.

    #         Args:
    #             root_path: Root directory to search
                include_patterns: File patterns to include (glob patterns)
                exclude_patterns: File patterns to exclude (glob patterns)

    #         Returns:
    #             List of file paths to index
    #         """
    root_path = Path(root_path)
    file_paths = []

    #         # Default patterns
    #         if include_patterns is None:
    include_patterns = ["**/*"]

    #         if exclude_patterns is None:
    exclude_patterns = [
    #                 "**/*.tmp",
    #                 "**/node_modules/**",
    #                 "**/.git/**",
    #                 "**/__pycache__/**",
    #                 "**/venv/**",
    #                 "**/env/**",
    #             ]

    #         # Collect files
    #         for pattern in include_patterns:
    #             for file_path in root_path.glob(pattern):
    #                 if file_path.is_file():
    #                     # Check exclusion patterns
    excluded = False
    #                     for exclude_pattern in exclude_patterns:
    #                         if file_path.match(exclude_pattern):
    excluded = True
    #                             break

    #                     if not excluded:
                            file_paths.append(str(file_path))

    #         return file_paths

    #     def extract_content(self, file_path: str) -str):
    #         """
    #         Extract content from a file.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             File content as string
    #         """
    #         try:
    #             with open(file_path, "r", encoding="utf-8") as f:
                    return f.read()
    #         except UnicodeDecodeError:
    #             try:
    #                 with open(file_path, "r", encoding="latin-1") as f:
                        return f.read()
    #             except Exception as e:
                    logger.warning(f"Could not read file {file_path}: {e}")
    #                 return ""
    #         except Exception as e:
                logger.warning(f"Could not read file {file_path}: {e}")
    #             return ""

    #     def get_file_type(self, file_path: str) -str):
    #         """
    #         Get file type from extension.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             File type string
    #         """
    mime_type, _ = mimetypes.guess_type(file_path)
    #         if mime_type:
    #             return mime_type

    #         # Fallback to extension
    ext = Path(file_path).suffix.lower()
    #         return f"application/{ext}" if ext else "application/octet-stream"

    #     def extract_chunks(self, file_path: str, content: str) -List[DocumentChunk]):
    #         """
    #         Extract chunks from file content using appropriate extractor.

    #         Args:
    #             file_path: Path to the file
    #             content: File content

    #         Returns:
    #             List of document chunks
    #         """
    file_type = self.get_file_type(file_path)

    #         # Find appropriate extractor
    #         for extractor in self.extractors:
    #             if extractor.can_extract(file_path, file_type):
                    return extractor.extract(file_path, content)

    #         # Default to text extraction
    #         logger.warning(f"No extractor found for {file_path}, using text extractor")
            return TextContentExtractor().extract(file_path, content)

    #     def generate_embeddings(
    self, chunks: List[DocumentChunk], model_name: Optional[str] = None
    #     ) -List[Tuple[str, Matrix]]):
    #         """
    #         Generate embeddings for document chunks.

    #         Args:
    #             chunks: List of document chunks
    #             model_name: Name of embedding model to use

    #         Returns:
                List of (chunk_id, embedding) tuples
    #         """
    #         # Extract content for embedding
    #         contents = [chunk.content for chunk in chunks]

    #         # Generate embeddings
    embeddings = self.embedding_manager.embed_texts(contents, model_name)

    #         # Pair with chunk IDs
    #         return [(chunk.id, emb) for chunk, emb in zip(chunks, embeddings)]

    #     def index_project(
    #         self,
    #         root_path: str,
    #         vector_index: VectorIndex,
    include_patterns: Optional[List[str]] = None,
    exclude_patterns: Optional[List[str]] = None,
    model_name: Optional[str] = None,
    batch_size: int = 100,
    #     ) -Dict[str, Any]):
    #         """
    #         Index an entire project.

    #         Args:
    #             root_path: Root directory of the project
    #             vector_index: VectorIndex to store embeddings
    #             include_patterns: File patterns to include
    #             exclude_patterns: File patterns to exclude
    #             model_name: Name of embedding model to use
    #             batch_size: Batch size for processing

    #         Returns:
    #             Indexing statistics
    #         """
    start_time = time.time()
    stats = {
    #             "total_files": 0,
    #             "total_chunks": 0,
    #             "total_embeddings": 0,
    #             "processing_time": 0,
    #             "errors": [],
    #         }

    #         # Discover files
    file_paths = self.discover_files(root_path, include_patterns, exclude_patterns)
    stats["total_files"] = len(file_paths)

            logger.info(f"Discovered {len(file_paths)} files to index")

    #         # Process files in batches
    all_chunks = []
    all_embeddings = []

    #         for i, file_path in enumerate(file_paths):
    #             try:
                    logger.info(f"Processing file {i+1}/{len(file_paths)}: {file_path}")

    #                 # Extract content
    content = self.extract_content(file_path)
    #                 if not content:
    #                     continue

    #                 # Extract chunks
    chunks = self.extract_chunks(file_path, content)
                    all_chunks.extend(chunks)

    #                 # Generate embeddings in batches
    #                 if len(all_chunks) >= batch_size or i == len(file_paths) - 1:
    batch_embeddings = self.generate_embeddings(all_chunks, model_name)
                        all_embeddings.extend(batch_embeddings)

    #                     # Add to vector index
    #                     chunk_ids = [emb[0] for emb in batch_embeddings]
    #                     embedding_matrices = [emb[1] for emb in batch_embeddings]

    #                     # Create metadata
    metadata = []
    #                     for chunk in all_chunks:
    meta = chunk.metadata.copy()
    meta["file_path"] = chunk.file_path
    meta["file_type"] = chunk.file_type
                            metadata.append(meta)

    #                     # Add to index
                        vector_index.add(chunk_ids, embedding_matrices, metadata)

    #                     # Reset batch
    all_chunks = []

    stats["total_chunks"] = len(all_embeddings)

    #             except Exception as e:
    error_msg = f"Error processing file {file_path}: {e}"
                    logger.error(error_msg)
                    stats["errors"].append(error_msg)

    #         # Generate final embeddings for any remaining chunks
    #         if all_chunks:
    batch_embeddings = self.generate_embeddings(all_chunks, model_name)
                all_embeddings.extend(batch_embeddings)

    #             # Add to vector index
    #             chunk_ids = [emb[0] for emb in batch_embeddings]
    #             embedding_matrices = [emb[1] for emb in batch_embeddings]

    #             # Create metadata
    metadata = []
    #             for chunk in all_chunks:
    meta = chunk.metadata.copy()
    meta["file_path"] = chunk.file_path
    meta["file_type"] = chunk.file_type
                    metadata.append(meta)

    #             # Add to index
                vector_index.add(chunk_ids, embedding_matrices, metadata)

    stats["total_chunks"] = len(all_embeddings)

    stats["total_embeddings"] = len(all_embeddings)
    stats["processing_time"] = time.time() - start_time

            logger.info(f"Indexing completed in {stats['processing_time']:.2f}s")
            logger.info(
    #             f"Indexed {stats['total_files']} files, {stats['total_chunks']} chunks"
    #         )

    #         return stats

    #     def index_file(
    #         self,
    #         file_path: str,
    #         vector_index: VectorIndex,
    model_name: Optional[str] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Index a single file.

    #         Args:
    #             file_path: Path to the file
    #             vector_index: VectorIndex to store embeddings
    #             model_name: Name of embedding model to use

    #         Returns:
    #             Indexing statistics
    #         """
    start_time = time.time()
    stats = {
    #             "file_path": file_path,
    #             "total_chunks": 0,
    #             "total_embeddings": 0,
    #             "processing_time": 0,
    #             "errors": [],
    #         }

    #         try:
    #             # Extract content
    content = self.extract_content(file_path)
    #             if not content:
                    stats["errors"].append("No content extracted")
    #                 return stats

    #             # Extract chunks
    chunks = self.extract_chunks(file_path, content)
    stats["total_chunks"] = len(chunks)

    #             # Generate embeddings
    embeddings = self.generate_embeddings(chunks, model_name)
    stats["total_embeddings"] = len(embeddings)

    #             # Create metadata
    metadata = []
    #             for chunk in chunks:
    meta = chunk.metadata.copy()
    meta["file_path"] = chunk.file_path
    meta["file_type"] = chunk.file_type
                    metadata.append(meta)

    #             # Add to index
                vector_index.add(
    #                 [emb[0] for emb in embeddings], [emb[1] for emb in embeddings], metadata
    #             )

    stats["processing_time"] = time.time() - start_time

    #         except Exception as e:
    error_msg = f"Error indexing file {file_path}: {e}"
                logger.error(error_msg)
                stats["errors"].append(error_msg)

    #         return stats


class AsyncFileIndexer
    #     """Async file indexer with multithreading support for large projects."""

    #     def __init__(
    #         self,
    embedding_manager: Optional[EmbeddingModelManager] = None,
    extractors: Optional[List[ContentExtractor]] = None,
    max_workers: int = 8,
    batch_size: int = 100,
    #     ):""
    #         Initialize async file indexer.

    #         Args:
    #             embedding_manager: Manager for embedding models
    #             extractors: List of content extractors
    #             max_workers: Maximum number of worker threads
    #             batch_size: Number of files to process in each batch
    #         """
    self.embedding_manager = embedding_manager or EmbeddingModelManager()
    self.extractors = extractors or [
                TextContentExtractor(),
                CodeContentExtractor(),
                MarkdownContentExtractor(),
    #         ]
    self.max_workers = max_workers
    self.batch_size = batch_size

    #         # Create a base indexer for reuse
    self.base_indexer = FileIndexer(embedding_manager, extractors)

    #     def discover_noodle_project_files(self, project_root: str) -List[str]):
    #         """
    #         Discover all relevant files in the Noodle project.

    #         Args:
    #             project_root: Root directory of the Noodle project

    #         Returns:
    #             List of file paths to index
    #         """
    project_root = Path(project_root)

    #         # Define directories to include in Noodle project
    include_dirs = [
    #             "noodle-core",
    #             "noodle-dev",
    #             "noodle-ide",
    #             "noodlenet",
    #             "noodle_control_mobile_app",
    #             "noodlecore-deployment",
    #             "src",
    #             "docs",
    #             "scripts",
    #             "tests",
    #         ]

    #         # Define file extensions to include
    include_extensions = {
    #             ".py", ".md", ".txt", ".json", ".yaml", ".yml", ".toml", ".cfg", ".ini",
    #             ".rst", ".adoc", ".sh", ".bat", ".ps1", ".sql", ".html", ".css", ".js",
    #             ".ts", ".jsx", ".tsx", ".vue", ".dart", ".go", ".rs", ".java", ".cpp",
    #             ".c", ".h", ".hpp", ".cs", ".php", ".rb", ".swift", ".kt", ".scala", ".nbc"
    #         }

    #         # Define directories to exclude
    exclude_dirs = {
    #             ".git", "__pycache__", ".pytest_cache", "node_modules", ".venv", "venv",
    #             "dist", "build", ".coverage", "htmlcov", ".vscode", ".idea", ".DS_Store",
    #             "Thumbs.db", "*.egg-info", ".tox", ".mypy_cache", ".pytest_cache"
    #         }

    file_paths = []

    #         # Walk through the project directory
    #         for root, dirs, files in os.walk(project_root):
    #             # Check if this directory should be included
    rel_root = os.path.relpath(root, project_root)
    root_parts = Path(rel_root).parts

    #             # Skip excluded directories
    #             if any(part in exclude_dirs for part in root_parts):
    #                 continue

    #             # Include if it's in one of the include directories or is the root
    #             if rel_root == "." or any(include_dir in rel_root for include_dir in include_dirs):
    #                 for file in files:
    file_path = os.path.join(root, file)
    file_ext = Path(file_path).suffix.lower()

    #                     # Include files with matching extensions
    #                     if file_ext in include_extensions:
                            file_paths.append(file_path)

    #         return file_paths

    #     def process_file_batch(self, file_paths: List[str]) -Tuple[List[DocumentChunk], List[str]]):
    #         """
    #         Process a batch of files in parallel.

    #         Args:
    #             file_paths: List of file paths to process

    #         Returns:
                Tuple of (chunks, errors)
    #         """
    chunks = []
    errors = []

    #         with concurrent.futures.ThreadPoolExecutor(max_workers=self.max_workers) as executor:
    #             # Submit all file processing tasks
    future_to_file = {
                    executor.submit(self._process_single_file, file_path): file_path
    #                 for file_path in file_paths
    #             }

    #             # Collect results as they complete
    #             for future in concurrent.futures.as_completed(future_to_file):
    file_path = future_to_file[future]
    #                 try:
    file_chunks, file_errors = future.result()
                        chunks.extend(file_chunks)
                        errors.extend(file_errors)
    #                 except Exception as e:
    error_msg = f"Unexpected error processing {file_path}: {str(e)}"
                        logger.error(error_msg)
                        errors.append(error_msg)

    #         return chunks, errors

    #     def _process_single_file(self, file_path: str) -Tuple[List[DocumentChunk], List[str]]):
    #         """
    #         Process a single file and extract chunks.

    #         Args:
    #             file_path: Path to the file to process

    #         Returns:
                Tuple of (chunks, errors)
    #         """
    chunks = []
    errors = []

    #         try:
    #             # Extract content
    content = self.base_indexer.extract_content(file_path)
    #             if not content:
    #                 return chunks, errors

    #             # Extract chunks
    file_chunks = self.base_indexer.extract_chunks(file_path, content)
                chunks.extend(file_chunks)

    #         except Exception as e:
    error_msg = f"Error processing file {file_path}: {str(e)}"
                logger.error(error_msg)
                errors.append(error_msg)

    #         return chunks, errors

    #     async def index_noodle_project_async(
    #         self,
    #         project_root: str,
    #         vector_index: VectorIndex,
    model_name: Optional[str] = None,
    progress_callback: Optional[callable] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Asynchronously index the entire Noodle project.

    #         Args:
    #             project_root: Root directory of the Noodle project
    #             vector_index: VectorIndex to store embeddings
    #             model_name: Name of embedding model to use
    #             progress_callback: Optional callback for progress updates

    #         Returns:
    #             Indexing statistics
    #         """
    start_time = time.time()
    stats = {
    #             "total_files": 0,
    #             "total_chunks": 0,
    #             "total_embeddings": 0,
    #             "processing_time": 0,
    #             "errors": [],
    #         }

    #         try:
    #             # Discover all files in the Noodle project
    file_paths = self.discover_noodle_project_files(project_root)
    stats["total_files"] = len(file_paths)

                logger.info(f"Discovered {len(file_paths)} files to index in Noodle project")

    #             if not file_paths:
                    logger.warning("No files found to index in the Noodle project")
    #                 return stats

    #             # Process files in batches
    all_chunks = []
    total_errors = []

    #             for i in range(0, len(file_paths), self.batch_size):
    batch_files = file_paths[i:i + self.batch_size]
    batch_num = i // self.batch_size + 1
    total_batches = (len(file_paths) + self.batch_size - 1 // self.batch_size)

                    logger.info(f"Processing batch {batch_num}/{total_batches}: {len(batch_files)} files")

    #                 # Process the batch
    chunks, errors = self.process_file_batch(batch_files)
                    all_chunks.extend(chunks)
                    total_errors.extend(errors)

    #                 # Generate embeddings for this batch
    #                 if chunks:
    embeddings = self.base_indexer.generate_embeddings(chunks, model_name)

    #                     # Create metadata
    metadata = []
    #                     for chunk in chunks:
    meta = chunk.metadata.copy()
    meta["file_path"] = chunk.file_path
    meta["file_type"] = chunk.file_type
                            metadata.append(meta)

    #                     # Add to vector index
    #                     chunk_ids = [emb[0] for emb in embeddings]
    #                     embedding_matrices = [emb[1] for emb in embeddings]
                        vector_index.add(chunk_ids, embedding_matrices, metadata)

    stats["total_embeddings"] + = len(embeddings)

    #                 # Update progress
    stats["total_chunks"] = len(all_chunks)
    stats["errors"] = total_errors

    #                 if progress_callback:
                        progress_callback(batch_num, total_batches, len(all_chunks), len(total_errors))

    #                 # Small delay to allow other async operations
                    await asyncio.sleep(0.01)

    stats["processing_time"] = time.time() - start_time

                logger.info(f"Noodle project indexing completed in {stats['processing_time']:.2f}s")
                logger.info(f"Indexed {stats['total_files']} files, {stats['total_chunks']} chunks, {stats['total_embeddings']} embeddings")
                logger.info(f"Encountered {len(total_errors)} errors")

    #             return stats

    #         except Exception as e:
    error_msg = f"Error during Noodle project indexing: {str(e)}"
                logger.error(error_msg)
                stats["errors"].append(error_msg)
    stats["processing_time"] = time.time() - start_time
    #             return stats

    #     def index_noodle_project(
    #         self,
    #         project_root: str,
    #         vector_index: VectorIndex,
    model_name: Optional[str] = None,
    progress_callback: Optional[callable] = None,
    #     ) -Dict[str, Any]):
    #         """
    #         Index the entire Noodle project (synchronous wrapper for async method).

    #         Args:
    #             project_root: Root directory of the Noodle project
    #             vector_index: VectorIndex to store embeddings
    #             model_name: Name of embedding model to use
    #             progress_callback: Optional callback for progress updates

    #         Returns:
    #             Indexing statistics
    #         """
    #         # Run the async method in an event loop
    loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
    #         try:
                return loop.run_until_complete(
                    self.index_noodle_project_async(
    #                     project_root, vector_index, model_name, progress_callback
    #                 )
    #             )
    #         finally:
                loop.close()
