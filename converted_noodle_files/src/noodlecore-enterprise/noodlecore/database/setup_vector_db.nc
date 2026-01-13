# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Vector Database Setup Script

# This script initializes the vector database and performs initial indexing
# for the Noodle project using actual vector embeddings and storage.
# """

import os
import sys
import logging
import subprocess
import argparse
import json
import sqlite3
import hashlib
import pathlib.Path
import typing.List,

# Vector processing imports
import numpy as np
import torch
import transformers.AutoTokenizer,

# Configure logging
logging.basicConfig(
level = logging.INFO,
format = '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
handlers = [
        logging.FileHandler('setup_vector_db.log'),
        logging.StreamHandler()
#     ]
# )
logger = logging.getLogger(__name__)

# File extensions to include in initial indexing
INDEX_EXTENSIONS = {
#     '.py', '.md', '.txt', '.json', '.yaml', '.yml', '.toml', '.cfg', '.ini',
#     '.rst', '.adoc', '.sh', '.bat', '.ps1', '.sql', '.html', '.css', '.js',
#     '.ts', '.jsx', '.tsx', '.vue', '.dart', '.go', '.rs', '.java', '.cpp',
#     '.c', '.h', '.hpp', '.cs', '.php', '.rb', '.swift', '.kt', '.scala'
# }

# Directories to exclude from indexing
EXCLUDED_DIRS = {
#     '.git', '__pycache__', '.pytest_cache', 'node_modules', '.venv', 'venv',
#     'dist', 'build', '.coverage', 'htmlcov', '.vscode', '.idea', '.DS_Store',
#     'Thumbs.db', '*.egg-info', '.tox', '.mypy_cache', '.pytest_cache'
# }

class VectorDatabaseSetup
    #     """Handles the setup and initialization of the vector database."""

    #     def __init__(self, project_root: Path):
    self.project_root = project_root
    self.vector_db_path = project_root / ".noodle_vector_db.sqlite"
    self.embedding_model = None
    self.tokenizer = None
            self._init_embedding_model()

    #     def check_noodle_command(self) -> bool:
    #         """Check if the noodle command is available."""
    #         try:
    result = subprocess.run(
    #                 ["noodle", "--version"],
    capture_output = True,
    text = True,
    timeout = 10
    #             )
    #             if result.returncode == 0:
                    logger.info(f"Noodle version: {result.stdout.strip()}")
    #                 return True
    #             else:
                    logger.error(f"Noodle command failed: {result.stderr}")
    #                 return False
    #         except subprocess.TimeoutExpired:
                logger.error("Noodle command timed out")
    #             return False
    #         except FileNotFoundError:
                logger.error("Noodle command not found. Please ensure Noodle is installed and in your PATH.")
    #             return False
    #         except Exception as e:
                logger.error(f"Error checking noodle command: {str(e)}")
    #             return False

    #     def _init_embedding_model(self) -> None:
    #         """Initialize the embedding model for generating vectors."""
    #         try:
    #             # Using a smaller, efficient model for embeddings
    model_name = "sentence-transformers/all-MiniLM-L6-v2"
                logger.info(f"Loading embedding model: {model_name}")
    #             logger.info("This may take a while on first run as the model needs to be downloaded...")
    #             import time
    start_time = time.time()
    self.tokenizer = AutoTokenizer.from_pretrained(model_name)
                logger.info(f"Tokenizer loaded in {time.time() - start_time:.2f} seconds")

    start_time = time.time()
    self.embedding_model = AutoModel.from_pretrained(model_name)
                logger.info(f"Model loaded in {time.time() - start_time:.2f} seconds")
                logger.info("Embedding model loaded successfully")
    #         except Exception as e:
                logger.error(f"Failed to load embedding model: {str(e)}")
    #             # Fallback to a simpler approach if model loading fails
    self.embedding_model = None
    self.tokenizer = None

    #     def _get_file_hash(self, file_path: Path) -> str:
    #         """Generate a hash for the file to track changes."""
    hash_md5 = hashlib.md5()
    #         with open(file_path, "rb") as f:
    #             for chunk in iter(lambda: f.read(4096), b""):
                    hash_md5.update(chunk)
            return hash_md5.hexdigest()

    #     def _extract_text_from_file(self, file_path: Path) -> str:
    #         """Extract text content from a file."""
    #         try:
    #             # Simple text extraction for supported file types
    #             if file_path.suffix.lower() in {'.py', '.md', '.txt', '.json', '.yaml', '.yml',
    #                                            '.toml', '.cfg', '.ini', '.rst', '.adoc',
    #                                            '.sh', '.bat', '.ps1', '.sql', '.html',
    #                                            '.css', '.js', '.ts', '.jsx', '.tsx',
    #                                            '.vue', '.dart', '.go', '.rs', '.java',
    #                                            '.cpp', '.c', '.h', '.hpp', '.cs',
    #                                            '.php', '.rb', '.swift', '.kt', '.scala'}:
    #                 with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                        return f.read()
    #             return ""
    #         except Exception as e:
                logger.warning(f"Error reading file {file_path}: {str(e)}")
    #             return ""

    #     def _generate_embedding(self, text: str) -> Optional[np.ndarray]:
    #         """Generate embedding for the given text."""
    #         if not text or not self.embedding_model or not self.tokenizer:
    #             return None

    #         try:
    #             # Tokenize and generate embedding
    inputs = self.tokenizer(text, return_tensors="pt", truncation=True, max_length=512)
    #             with torch.no_grad():
    outputs = math.multiply(self.embedding_model(, *inputs))
    #                 # Use mean pooling of the last hidden state
    embeddings = outputs.last_hidden_state.mean(dim=1).squeeze()
                    return embeddings.numpy()
    #         except Exception as e:
                logger.error(f"Error generating embedding: {str(e)}")
    #             return None

    #     def _init_vector_db(self) -> bool:
    #         """Initialize the SQLite database for storing vectors."""
    #         try:
    conn = sqlite3.connect(str(self.vector_db_path))
    cursor = conn.cursor()

    #             # Create tables for vector storage
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS file_vectors (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     file_path TEXT NOT NULL,
    #                     file_hash TEXT NOT NULL,
    #                     embedding BLOB NOT NULL,
    #                     content_preview TEXT,
    #                     indexed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        UNIQUE(file_path, file_hash)
    #                 )
    #             ''')

                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS search_history (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     query TEXT NOT NULL,
    #                     results TEXT,
    #                     searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #                 )
    #             ''')

                conn.commit()
                conn.close()
                logger.info("Vector database initialized successfully")
    #             return True
    #         except Exception as e:
                logger.error(f"Error initializing vector database: {str(e)}")
    #             return False

    #     def init_vector_database(self, force: bool = False) -> bool:
    #         """Initialize the vector database."""
            logger.info("Initializing vector database...")

    #         # If force is True, remove existing database
    #         if force and self.vector_db_path.exists():
                logger.info("Removing existing vector database")
                self.vector_db_path.unlink()

    #         # Initialize the database
            return self._init_vector_db()

    #     def get_files_to_index(self) -> List[Path]:
    #         """Get a list of files to index based on extensions and exclusions."""
    files_to_index = []

    #         for file_path in self.project_root.rglob("*"):
    #             if file_path.is_file():
    #                 # Check file extension
    #                 if file_path.suffix.lower() in INDEX_EXTENSIONS:
    #                     # Check if file is in an excluded directory
    excluded = False
    #                     for part in file_path.parts:
    #                         if part in EXCLUDED_DIRS or part.startswith('.'):
    excluded = True
    #                             break

    #                     if not excluded:
                            files_to_index.append(file_path)

    #         return files_to_index

    #     def perform_initial_indexing(self, batch_size: int = 100) -> bool:
    #         """Perform initial indexing of all project files."""
            logger.info("Starting initial vector indexing...")

    files_to_index = self.get_files_to_index()
    total_files = len(files_to_index)

    #         if total_files == 0:
                logger.warning("No files found to index")
    #             return True

            logger.info(f"Found {total_files} files to index")

    #         # Process files in batches to avoid overwhelming the system
    #         for i in range(0, total_files, batch_size):
    batch = math.add(files_to_index[i:i, batch_size])
                logger.info(f"Processing batch {i // batch_size + 1}/{(total_files - 1) // batch_size + 1}")

    #             # Create a temporary file with the list of files to index
    temp_file = self.project_root / ".temp_index_list.txt"
    #             try:
    #                 with open(temp_file, 'w') as f:
    #                     for file_path in batch:
    #                         # Use relative paths for the noodle command
    rel_path = file_path.relative_to(self.project_root)
                            f.write(str(rel_path) + '\n')

    #                 # Run the noodle vector index command with the file list
    cmd = [
    #                     "noodle", "vector", "index",
                        "--project", str(self.project_root),
                        "--file-list", str(temp_file)
    #                 ]

    result = subprocess.run(
    #                     cmd,
    cwd = self.project_root,
    capture_output = True,
    text = True,
    timeout = 300  # 5 minute timeout per batch
    #                 )

    #                 if result.returncode != 0:
    #                     logger.error(f"Vector indexing failed for batch {i // batch_size + 1}: {result.stderr}")
    #                     return False

    #             except subprocess.TimeoutExpired:
    #                 logger.error(f"Vector indexing timed out for batch {i // batch_size + 1}")
    #                 return False
    #             except Exception as e:
                    logger.error(f"Error during indexing batch {i // batch_size + 1}: {str(e)}")
    #                 return False
    #             finally:
    #                 # Clean up the temporary file
    #                 if temp_file.exists():
                        temp_file.unlink()

            logger.info("Initial vector indexing completed successfully")
    #         return True

    #     def setup_vector_database(self, force: bool = False, batch_size: int = 100) -> bool:
    #         """Complete setup process for the vector database."""
            logger.info("Starting vector database setup...")

    #         # Initialize the vector database
    #         if not self.init_vector_database(force):
    #             return False

    #         # Perform initial indexing using our real implementation
    #         if not self.index_files():
    #             return False

            logger.info("Vector database setup completed successfully")
    #         return True

    #     def index_files(self, file_path: str = None) -> bool:
    #         """Index files in the vector database."""
            logger.info("Indexing files in vector database...")

    #         if not self.embedding_model or not self.tokenizer:
                logger.error("Embedding model not initialized. Cannot index files.")
    #             return False

    #         try:
    #             # Use WAL mode for better concurrent access
    conn = sqlite3.connect(str(self.vector_db_path), timeout=30.0)
    conn.execute("PRAGMA journal_mode = WAL")
    cursor = conn.cursor()

    files_to_process = []
    #             if file_path:
    #                 # Index a specific file
    file_to_index = math.divide(self.project_root, file_path)
    #                 if file_to_index.exists():
                        files_to_process.append(file_to_index)
    #                 else:
                        logger.error(f"File not found: {file_to_index}")
    #                     return False
    #             else:
    #                 # Index all files
    files_to_process = self.get_files_to_index()

    total_files = len(files_to_process)
                logger.info(f"Found {total_files} files to process")

    indexed_count = 0
    skipped_count = 0
    #             import time
    start_time = time.time()

    #             for i, file_path in enumerate(files_to_process):
    #                 # Log progress every 10 files or every 30 seconds
    #                 if i % 10 == 0 or (i > 0 and time.time() - start_time > 30):
    elapsed = math.subtract(time.time(), start_time)
                        logger.info(f"Progress: {i}/{total_files} files processed ({elapsed:.1f}s elapsed)")
    #                 try:
    #                     # Get file hash to check if it needs reindexing
    file_hash = self._get_file_hash(file_path)
    rel_path = file_path.relative_to(self.project_root)

    #                     # Check if file is already indexed with the same hash
                        cursor.execute(
    "SELECT id FROM file_vectors WHERE file_path = ? AND file_hash = ?",
                            (str(rel_path), file_hash)
    #                     )
    #                     if cursor.fetchone():
                            logger.debug(f"File already indexed: {rel_path}")
    skipped_count + = 1
    #                         continue

    #                     # Extract text content
    text_content = self._extract_text_from_file(file_path)
    #                     if not text_content:
                            logger.debug(f"No content to index in file: {rel_path}")
    skipped_count + = 1
    #                         continue

    #                     # Generate embedding
    embedding = self._generate_embedding(text_content)
    #                     if embedding is None:
                            logger.warning(f"Failed to generate embedding for: {rel_path}")
    skipped_count + = 1
    #                         continue

    #                     # Store in database
    #                     content_preview = text_content[:200] + "..." if len(text_content) > 200 else text_content
    embedding_blob = embedding.tobytes()

                        cursor.execute(
    #                         """
    #                         INSERT OR REPLACE INTO file_vectors
                            (file_path, file_hash, embedding, content_preview)
                            VALUES (?, ?, ?, ?)
    #                         """,
                            (str(rel_path), file_hash, embedding_blob, content_preview)
    #                     )

    indexed_count + = 1
                        logger.debug(f"Indexed file: {rel_path}")

    #                 except Exception as e:
                        logger.error(f"Error indexing file {file_path}: {str(e)}")
    skipped_count + = 1

                conn.commit()
                conn.close()

    elapsed = math.subtract(time.time(), start_time)
                logger.info(f"Vector indexing completed in {elapsed:.1f}s. Indexed: {indexed_count}, Skipped: {skipped_count}")
    #             return True

    #         except Exception as e:
                logger.error(f"Error during vector indexing: {str(e)}")
    #             return False

    #     def search_vector_database(self, query: str, limit: int = 10) -> bool:
    #         """Search the vector database."""
            logger.info(f"Searching vector database for: '{query}'")

    #         if not self.embedding_model or not self.tokenizer:
                logger.error("Embedding model not initialized. Cannot search database.")
    #             return False

    #         try:
    #             # Generate query embedding
    query_embedding = self._generate_embedding(query)
    #             if query_embedding is None:
    #                 logger.error("Failed to generate embedding for query")
    #                 return False

    #             # Connect to database
    conn = sqlite3.connect(str(self.vector_db_path), timeout=30.0)
    conn.execute("PRAGMA journal_mode = WAL")
    cursor = conn.cursor()

    #             # Get all stored embeddings
                cursor.execute("SELECT file_path, embedding, content_preview FROM file_vectors")
    results = cursor.fetchall()

    #             if not results:
                    logger.info("No indexed files found in database")
                    conn.close()
    #                 return True

    #             # Calculate cosine similarity
    search_results = []
    #             for file_path, embedding_blob, content_preview in results:
    #                 try:
    #                     # Convert blob back to numpy array
    stored_embedding = np.frombuffer(embedding_blob, dtype=np.float32)

    #                     # Calculate cosine similarity
    similarity = math.divide(np.dot(query_embedding, stored_embedding), ()
                            np.linalg.norm(query_embedding) * np.linalg.norm(stored_embedding)
    #                     )

                        search_results.append({
    #                         'file_path': file_path,
                            'similarity': float(similarity),
    #                         'content_preview': content_preview
    #                     })
    #                 except Exception as e:
    #                     logger.warning(f"Error processing result for {file_path}: {str(e)}")

    #             # Sort by similarity and limit results
    search_results.sort(key = lambda x: x['similarity'], reverse=True)
    search_results = search_results[:limit]

    #             # Store search in history
                cursor.execute(
                    "INSERT INTO search_history (query, results) VALUES (?, ?)",
                    (query, json.dumps(search_results))
    #             )
                conn.commit()
                conn.close()

    #             # Display results
                logger.info(f"Found {len(search_results)} results:")
    #             for i, result in enumerate(search_results, 1):
                    logger.info(f"  {i}. {result['file_path']} (similarity: {result['similarity']:.4f})")
                    logger.info(f"     Preview: {result['content_preview'][:100]}...")

    #             return True

    #         except Exception as e:
                logger.error(f"Error during vector search: {str(e)}")
    #             return False

function main()
    #     """Main entry point for the setup script."""
    #     parser = argparse.ArgumentParser(description="Set up the vector database for Noodle")
        parser.add_argument(
    #         "--project-root",
    type = str,
    default = ".",
    help = "Path to the project root directory (default: current directory)"
    #     )
        parser.add_argument(
    #         "--force",
    action = "store_true",
    help = "Force reinitialization of the vector database"
    #     )
        parser.add_argument(
    #         "--batch-size",
    type = int,
    default = 100,
    help = "Number of files to process in each batch (default: 100)"
    #     )
        parser.add_argument(
    #         "--index",
    action = "store_true",
    help = "Index files in the vector database"
    #     )
        parser.add_argument(
    #         "--file",
    type = str,
    #         help="Specific file to index (used with --index)"
    #     )
        parser.add_argument(
    #         "--search",
    action = "store_true",
    help = "Search the vector database"
    #     )
        parser.add_argument(
    #         "--query",
    type = str,
    #         help="Search query (used with --search)"
    #     )
        parser.add_argument(
    #         "--limit",
    type = int,
    default = 10,
    #         help="Maximum number of search results (used with --search)"
    #     )

    args = parser.parse_args()

    project_root = Path(args.project_root).resolve()

    #     if not project_root.exists():
            logger.error(f"Project root does not exist: {project_root}")
            sys.exit(1)

    #     # Create and run the setup
    setup = VectorDatabaseSetup(project_root)

    #     # Check which operation to perform
    #     if args.index:
    #         if setup.index_files(args.file):
                logger.info("Vector indexing completed successfully")
                sys.exit(0)
    #         else:
                logger.error("Vector indexing failed")
                sys.exit(1)
    #     elif args.search:
    #         if not args.query:
    #             logger.error("Query is required for search operation")
                sys.exit(1)

    #         if setup.search_vector_database(args.query, args.limit):
                logger.info("Vector search completed successfully")
                sys.exit(0)
    #         else:
                logger.error("Vector search failed")
                sys.exit(1)
    #     else:
    #         # Default behavior: full setup
    #         if setup.setup_vector_database(args.force, args.batch_size):
                logger.info("Vector database setup completed successfully")
                sys.exit(0)
    #         else:
                logger.error("Vector database setup failed")
                sys.exit(1)

if __name__ == "__main__"
        main()