# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Project Structure Analyzer
# -------------------------
# Analyzes project directories and generates project structure metadata
# including file types, languages, and dependencies.
# """

import hashlib
import json
import logging
import os
import re
import collections.Counter,
import dataclasses.asdict,
import datetime.datetime
import pathlib.Path
import typing.Any,

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


# @dataclass
class FileMetadata
    #     """Metadata for a single file"""

    #     path: str
    #     name: str
    #     extension: str
    #     size: int
    #     language: str
    #     modified: datetime
    is_binary: bool = False
    hash: Optional[str] = None
    dependencies: List[str] = field(default_factory=list)


# @dataclass
class DirectoryMetadata
    #     """Metadata for a directory"""

    #     path: str
    #     name: str
    is_project_root: bool = False
    is_hidden: bool = False
    file_count: int = 0
    total_size: int = 0
    languages: Dict[str, int] = field(default_factory=Counter)
    description: str = ""


# @dataclass
class ProjectStructure
    #     """Complete project structure analysis"""

    #     root_path: str
    #     name: str
    #     type: str
    version: str = ""
    created_at: datetime = field(default_factory=datetime.now)
    last_updated: datetime = field(default_factory=datetime.now)
    directories: Dict[str, DirectoryMetadata] = field(default_factory=dict)
    files: Dict[str, FileMetadata] = field(default_factory=dict)
    dependencies: Dict[str, List[str]] = field(
    default_factory = lambda: defaultdict(list)
    #     )
    config_files: List[str] = field(default_factory=list)
    package_files: List[str] = field(default_factory=list)
    total_files: int = 0
    total_size: int = 0
    languages: Dict[str, int] = field(default_factory=Counter)


class ProjectAnalyzer
    #     """
    #     Analyzes project directories and generates comprehensive project structure metadata.
    #     Supports multiple programming languages and dependency detection.
    #     """

    #     def __init__(self, root_path: Union[str, Path]):
    #         """
    #         Initialize the ProjectAnalyzer.

    #         Args:
    #             root_path: Path to the project directory to analyze
    #         """
    self.root_path = Path(root_path)
    self.supported_languages = {
    #             "python": {
    #                 "extensions": [".py", ".pyw", ".pyx", ".pyi"],
    #                 "config_files": [
    #                     "requirements.txt",
    #                     "setup.py",
    #                     "pyproject.toml",
    #                     "Pipfile",
    #                     "poetry.lock",
    #                 ],
    #                 "package_files": ["__init__.py", "setup.cfg"],
    #                 "dependencies": self._extract_python_dependencies,
    #             },
    #             "javascript": {
    #                 "extensions": [".js", ".mjs", ".cjs"],
    #                 "config_files": ["package.json", "package-lock.json", "yarn.lock"],
    #                 "package_files": ["package.json"],
    #                 "dependencies": self._extract_js_dependencies,
    #             },
    #             "typescript": {
    #                 "extensions": [".ts", ".tsx", ".d.ts"],
    #                 "config_files": ["tsconfig.json", "package.json", "tsconfig.base.json"],
    #                 "package_files": ["package.json"],
    #                 "dependencies": self._extract_ts_dependencies,
    #             },
    #             "noodle": {
    #                 "extensions": [".noodle"],
    #                 "config_files": [".noodle/config.json"],
    #                 "package_files": [".noodle/packages.json"],
    #                 "dependencies": self._extract_noodle_dependencies,
    #             },
    #             "json": {
    #                 "extensions": [".json"],
    #                 "config_files": [],
    #                 "package_files": ["package.json"],
    #                 "dependencies": self._extract_json_dependencies,
    #             },
    #             "yaml": {
    #                 "extensions": [".yml", ".yaml"],
    #                 "config_files": [],
    #                 "package_files": [],
    #                 "dependencies": self._extract_yaml_dependencies,
    #             },
    #             "xml": {
    #                 "extensions": [".xml"],
    #                 "config_files": [],
    #                 "package_files": [],
    #                 "dependencies": self._extract_xml_dependencies,
    #             },
    #             "markdown": {
    #                 "extensions": [".md", ".markdown"],
    #                 "config_files": [],
    #                 "package_files": [],
    #                 "dependencies": self._extract_markdown_dependencies,
    #             },
    #             "config": {
    #                 "extensions": [".ini", ".cfg", ".conf", ".config", ".toml"],
    #                 "config_files": [],
    #                 "package_files": [],
    #                 "dependencies": self._extract_config_dependencies,
    #             },
    #         }

    #     def scan_directory(
    #         self,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> ProjectStructure:
    #         """
    #         Scan the project directory and generate project structure metadata.

    #         Args:
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             ProjectStructure object containing all metadata
    #         """
    #         if exclude_dirs is None:
    exclude_dirs = [
    #                 ".git",
    #                 "__pycache__",
    #                 "node_modules",
    #                 "venv",
    #                 "env",
    #                 ".idea",
    #                 ".vscode",
    #             ]

    #         if exclude_files is None:
    exclude_files = ["*.pyc", "*.pyo", "*.log", "*.tmp"]

    #         # Initialize project structure
    project_name = self.root_path.name
    project_type = self._detect_project_type()

    structure = ProjectStructure(
    root_path = str(self.root_path), name=project_name, type=project_type
    #         )

    #         # Scan directories
    #         for dirpath, dirnames, filenames in os.walk(self.root_path):
    #             # Convert to Path object
    dir_path = Path(dirpath)
    relative_path = dir_path.relative_to(self.root_path)

    #             # Skip excluded directories
    #             dirnames[:] = [d for d in dirnames if d not in exclude_dirs]

    #             # Skip hidden directories
    #             dirnames[:] = [d for d in dirnames if not d.startswith(".")]

    #             # Process directory
                self._process_directory(
    #                 structure, dir_path, relative_path, exclude_dirs, exclude_files
    #             )

    #             # Process files
    #             for filename in filenames:
    file_path = math.divide(dir_path, filename)
    relative_file_path = file_path.relative_to(self.root_path)

    #                 # Skip excluded files
    #                 if self._is_file_excluded(filename, exclude_files):
    #                     continue

    #                 # Skip hidden files
    #                 if filename.startswith("."):
    #                     continue

    #                 # Process file
                    self._process_file(structure, file_path, relative_file_path)

    #         # Update statistics
            self._update_project_statistics(structure)

    #         # Detect project dependencies
            self._detect_project_dependencies(structure)

            logger.info(f"Scanned project: {project_name}")
            logger.info(
                f"Found {structure.total_files} files across {len(structure.languages)} languages"
    #         )

    #         return structure

    #     def _process_directory(
    #         self,
    #         structure: ProjectStructure,
    #         dir_path: Path,
    #         relative_path: Path,
    #         exclude_dirs: List[str],
    #         exclude_files: List[str],
    #     ):
    #         """Process a single directory"""
    dir_name = dir_path.name
    dir_metadata = DirectoryMetadata(
    path = str(relative_path),
    name = dir_name,
    is_project_root = (relative_path == Path(".")),
    is_hidden = dir_name.startswith("."),
    #         )

            # Count files in directory (without recursion)
    #         for item in dir_path.iterdir():
    #             if item.is_file() and not self._is_file_excluded(item.name, exclude_files):
    dir_metadata.file_count + = 1
    dir_metadata.total_size + = item.stat().st_size

    structure.directories[str(relative_path)] = dir_metadata

    #     def _process_file(
    #         self, structure: ProjectStructure, file_path: Path, relative_file_path: Path
    #     ):
    #         """Process a single file"""
    #         try:
    file_stat = file_path.stat()

    #             # Determine file extension and language
    extension = file_path.suffix.lower()
    language = self._detect_language(file_path)

    #             # Check if file is binary
    is_binary = self._is_binary_file(file_path)

    #             # Calculate file hash for non-binary files
    file_hash = None
    #             if not is_binary:
    file_hash = self._calculate_file_hash(file_path)

    #             # Create file metadata
    file_metadata = FileMetadata(
    path = str(relative_file_path),
    name = file_path.name,
    extension = extension,
    size = file_stat.st_size,
    language = language,
    modified = datetime.fromtimestamp(file_stat.st_mtime),
    is_binary = is_binary,
    hash = file_hash,
    #             )

    #             # Store file metadata
    structure.files[str(relative_file_path)] = file_metadata

    #             # Track language statistics
    #             if language:
    structure.languages[language] + = 1

    #         except OSError as e:
                logger.warning(f"Could not process file {file_path}: {e}")

    #     def _detect_language(self, file_path: Path) -> str:
    #         """
    #         Detect the programming language of a file based on its extension and content.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             Detected language name
    #         """
    extension = file_path.suffix.lower()

    #         # Check language by extension
    #         for lang, info in self.supported_languages.items():
    #             if extension in info["extensions"]:
    #                 # Further verification by checking file content
    #                 if lang in ["python", "javascript", "typescript", "noodle"]:
    #                     if self._verify_language_by_content(file_path, lang):
    #                         return lang
    #                 else:
    #                     return lang

    #         return "unknown"

    #     def _verify_language_by_content(self, file_path: Path, language: str) -> bool:
    #         """
    #         Verify file content matches expected language patterns.

    #         Args:
    #             file_path: Path to the file
    #             language: Expected language

    #         Returns:
    #             True if content verification passes
    #         """
    #         try:
    #             with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
    first_lines = "".join(f.readlines(10))  # Read first 10 lines
    #         except:
    #             return False

    #         # Language-specific patterns
    patterns = {
    #             "python": [
    #                 r"^\s*#!/usr/bin/env python",
    #                 r"^\s*#.*Python",
                    r"^\s*(import|from)",
    #             ],
    #             "javascript": [
    #                 r"^\s*#!/usr/bin/env node",
    #                 r"^\s*//.*JavaScript",
                    r"^\s*(var|let|const|function)",
    #             ],
    #             "typescript": [
    #                 r"^\s*///\s*<reference",
    #                 r"^\s*interface\s+\w+",
    #                 r"^\s*type\s+\w+",
    #             ],
    #             "noodle": [r"^\s*#\s*Noodle\s+file", r"^\s*@noodle", r"^\s*module\s+\w+"],
    #         }

    #         if language in patterns:
                return any(
                    re.search(pattern, first_lines, re.MULTILINE | re.IGNORECASE)
    #                 for pattern in patterns[language]
    #             )

    #         return False

    #     def _detect_project_type(self) -> str:
    #         """
    #         Detect the project type based on configuration files.

    #         Returns:
    #             Detected project type
    #         """
    #         # Check for known project configuration files
    config_indicators = {
    #             "python": ["requirements.txt", "setup.py", "pyproject.toml"],
    #             "javascript": ["package.json", "package-lock.json"],
    #             "typescript": ["tsconfig.json", "package.json"],
    #             "noodle": [".noodle/config.json"],
    #             "generic": ["README.md", "LICENSE", "Makefile", "CMakeLists.txt"],
    #         }

    #         for config_file in self.root_path.glob("**/*"):
    #             if config_file.is_file():
    config_path = config_file.relative_to(self.root_path)

    #                 for project_type, indicators in config_indicators.items():
    #                     if config_path.name in indicators:
    #                         return project_type

    #         return "unknown"

    #     def _is_file_excluded(self, filename: str, exclude_files: List[str]) -> bool:
    #         """
    #         Check if a file should be excluded based on exclusion patterns.

    #         Args:
    #             filename: Name of the file
    #             exclude_files: List of exclusion patterns

    #         Returns:
    #             True if file should be excluded
    #         """
    #         for pattern in exclude_files:
    #             if pattern.startswith("*"):
    #                 # EndsWith pattern
    #                 if filename.endswith(pattern[1:]):
    #                     return True
    #             else:
    #                 # Exact match
    #                 if filename == pattern:
    #                     return True
    #         return False

    #     def _is_binary_file(self, file_path: Path) -> bool:
    #         """
    #         Check if a file is binary or text.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             True if file appears to be binary
    #         """
    #         try:
    #             with open(file_path, "rb") as f:
    chunk = f.read(1024)
    #                 return b"\0" in chunk
    #         except:
    #             return True

    #     def _calculate_file_hash(self, file_path: Path) -> str:
    #         """
    #         Calculate SHA256 hash of a file.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             SHA256 hash string
    #         """
    sha256_hash = hashlib.sha256()
    #         try:
    #             with open(file_path, "rb") as f:
    #                 for chunk in iter(lambda: f.read(4096), b""):
                        sha256_hash.update(chunk)
                return sha256_hash.hexdigest()
    #         except:
    #             return ""

    #     def _update_project_statistics(self, structure: ProjectStructure):
    #         """Update project-level statistics"""
    structure.total_files = len(structure.files)
    #         structure.total_size = sum(f.size for f in structure.files.values())

    #         # Also update directory statistics
    #         for dir_path, dir_metadata in structure.directories.items():
    dir_meta = DirectoryMetadata(
    path = dir_metadata.path,
    name = dir_metadata.name,
    is_project_root = dir_metadata.is_project_root,
    is_hidden = dir_metadata.is_hidden,
    file_count = len(
    #                     [
    #                         f
    #                         for f in structure.files.values()
    #                         if f.path.startswith(dir_path + "/")
    #                     ]
    #                 ),
    total_size = sum(
    #                     f.size
    #                     for f in structure.files.values()
    #                     if f.path.startswith(dir_path + "/")
    #                 ),
    languages = Counter(
    #                     f.language
    #                     for f in structure.files.values()
    #                     if f.path.startswith(dir_path + "/")
    #                 ),
    #             )
    structure.directories[dir_path] = dir_meta

    #     def _detect_project_dependencies(self, structure: ProjectStructure):
    #         """Detect project dependencies by analyzing configuration files"""
    config_files = []
    package_files = []

    #         for file_path, file_metadata in structure.files.items():
    #             # Check if it's a config file
    #             for lang, info in self.supported_languages.items():
    #                 if file_metadata.name in info["config_files"]:
                        config_files.append(file_path)
    dependencies = info["dependencies"](
    #                         file_metadata.path, structure.root_path
    #                     )
    #                     if dependencies:
    structure.dependencies[file_path] = dependencies
    #                     break

    #             # Check if it's a package file
    #             for lang, info in self.supported_languages.items():
    #                 if file_metadata.name in info["package_files"]:
                        package_files.append(file_path)
    dependencies = info["dependencies"](
    #                         file_metadata.path, structure.root_path
    #                     )
    #                     if dependencies:
    structure.dependencies[file_path] = dependencies
    #                     break

    structure.config_files = config_files
    structure.package_files = package_files

    #     def _extract_python_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract Python dependencies from requirements.txt, setup.py, or pyproject.toml"""
    dependencies = []

    #         try:
    #             # Try different config file types
    #             if "requirements.txt" in file_path:
    #                 with open(
    os.path.join(root_path, file_path), "r", encoding = "utf-8"
    #                 ) as f:
    #                     for line in f:
    line = line.strip()
    #                         if line and not line.startswith("#"):
                                dependencies.append(line)

    #             elif "setup.py" in file_path:
    #                 # Simple regex-based extraction for setup.py
    #                 with open(
    os.path.join(root_path, file_path), "r", encoding = "utf-8"
    #                 ) as f:
    content = f.read()
    #                     # Extract install_requires
    install_requires_match = re.search(
    r"install_requires\s* = \s*\[(.*?)\]", content, re.DOTALL
    #                     )
    #                     if install_requires_match:
    requirements = re.findall(
                                r"'([^']+)'|\"([^\"]+)\"", install_requires_match.group(1)
    #                         )
                            dependencies.extend(
    #                             [
    #                                 req
    #                                 for req_pair in requirements
    #                                 for req in req_pair
    #                                 if req
    #                             ]
    #                         )

    #             elif "pyproject.toml" in file_path:
    #                 # Simple parsing of pyproject.toml
    #                 with open(
    os.path.join(root_path, file_path), "r", encoding = "utf-8"
    #                 ) as f:
    content = f.read()
    #                     # Extract dependencies
    in_dependencies = False
    #                     for line in content.split("\n"):
    line = line.strip()
    #                         if line == "[tool.poetry.dependencies]" or line.startswith(
    "dependencies = "
    #                         ):
    in_dependencies = True
    #                             continue
    #                         elif line.startswith("[") and "]" in line:
    in_dependencies = False
    #                             continue

    #                         if in_dependencies and line and not line.startswith("#"):
    # Extract package name from line like "package = "^1.0.0""
    package_match = re.match(r"^\s*([a-zA-Z0-9\-_.]+)", line)
    #                             if package_match:
                                    dependencies.append(package_match.group(1))

    #         except Exception as e:
                logger.debug(f"Error extracting Python dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_js_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract JavaScript dependencies from package.json"""
    dependencies = []

    #         if "package.json" in file_path:
    #             try:
    #                 import json

    #                 with open(
    os.path.join(root_path, file_path), "r", encoding = "utf-8"
    #                 ) as f:
    pkg_data = json.load(f)

    #                 # Extract dependencies
    deps_sections = ["dependencies", "devDependencies", "peerDependencies"]
    #                 for section in deps_sections:
    #                     if section in pkg_data:
                            dependencies.extend(list(pkg_data[section].keys()))

    #             except Exception as e:
                    logger.debug(f"Error extracting JS dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_ts_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract TypeScript dependencies from package.json or tsconfig.json"""
    #         # TypeScript dependencies are the same as JavaScript for now
            return self._extract_js_dependencies(file_path, root_path)

    #     def _extract_noodle_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract Noodle dependencies from .noodle config files"""
    dependencies = []

    #         try:
    #             # This is a placeholder for Noodle-specific dependency extraction
    #             # In a real implementation, this would parse Noodle's specific format
    #             with open(os.path.join(root_path, file_path), "r", encoding="utf-8") as f:
    content = f.read()
    #                 # Simple regex to find import statements
    import_matches = re.findall(r'@import\s+["\']([^"\']+)["\']', content)
                    dependencies.extend(import_matches)

    #         except Exception as e:
                logger.debug(f"Error extracting Noodle dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_json_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract JSON dependencies from JSON files"""
    dependencies = []

    #         try:
    #             # Check if it's a package.json file
    #             if file_path.endswith("package.json"):
                    return self._extract_js_dependencies(file_path, root_path)

    #             # For other JSON files, look for specific patterns
    #             with open(os.path.join(root_path, file_path), "r", encoding="utf-8") as f:
    data = json.load(f)

    #                 # Look for common dependency-like keys
    #                 for key, value in data.items():
    #                     if key in ["dependencies", "imports", "modules"]:
    #                         if isinstance(value, dict):
                                dependencies.extend(list(value.keys()))
    #                         elif isinstance(value, list):
    #                             dependencies.extend(str(v) for v in value)

    #         except Exception as e:
                logger.debug(f"Error extracting JSON dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_yaml_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract YAML dependencies from YAML files"""
    dependencies = []

    #         try:
    #             import yaml

    #             with open(os.path.join(root_path, file_path), "r", encoding="utf-8") as f:
    data = yaml.safe_load(f)

    #                 # Look for common dependency-like keys
    #                 for key, value in data.items() if isinstance(data, dict) else []:
    #                     if key in ["dependencies", "imports", "modules"]:
    #                         if isinstance(value, dict):
                                dependencies.extend(list(value.keys()))
    #                         elif isinstance(value, list):
    #                             dependencies.extend(str(v) for v in value)

    #         except Exception as e:
                logger.debug(f"Error extracting YAML dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_xml_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract XML dependencies from XML files"""
    dependencies = []

    #         try:
    #             from xml.etree import ElementTree as ET

    tree = ET.parse(os.path.join(root_path, file_path))
    root = tree.getroot()

    #             # Look for dependency-like elements
    #             for elem in root.iter():
    #                 if "dependency" in elem.tag or "import" in elem.tag:
    #                     if "name" in elem.attrib:
                            dependencies.append(elem.attrib["name"])
    #                     elif "id" in elem.attrib:
                            dependencies.append(elem.attrib["id"])
    #                     elif elem.text:
                            dependencies.append(elem.text.strip())

    #         except Exception as e:
                logger.debug(f"Error extracting XML dependencies from {file_path}: {e}")

    #         return dependencies

    #     def _extract_markdown_dependencies(
    #         self, file_path: str, root_path: str
    #     ) -> List[str]:
            """Extract dependencies from Markdown files (mostly links and references)"""
    dependencies = []

    #         try:
    #             with open(os.path.join(root_path, file_path), "r", encoding="utf-8") as f:
    content = f.read()

    #                 # Extract links
    link_matches = re.findall(r"\[([^\]]+)\]\(([^)]+)\)", content)
    #                 dependencies.extend([link for _, link in link_matches])

    #                 # Extract code block languages
    code_block_matches = re.findall(r"```(\w+)", content)
                    dependencies.extend(code_block_matches)

    #         except Exception as e:
                logger.debug(
    #                 f"Error extracting Markdown dependencies from {file_path}: {e}"
    #             )

    #         return dependencies

    #     def _extract_config_dependencies(self, file_path: str, root_path: str) -> List[str]:
    #         """Extract dependencies from configuration files"""
    dependencies = []

    #         try:
    #             with open(os.path.join(root_path, file_path), "r", encoding="utf-8") as f:
    content = f.read()

    #                 # Look for common dependency patterns
    #                 # This is a simplified approach - in practice, you'd need file-type specific parsing

    #                 # For TOML files
    #                 if file_path.endswith(".toml"):
    #                     import re

    #                     # Simple key-value extraction
    key_value_matches = re.findall(
    r'^\s*([a-zA-Z0-9_]+)\s* = \s*[\'"]([^\'"]*)[\'"]',
    #                         content,
    #                         re.MULTILINE,
    #                     )
                        dependencies.extend(
    #                         [f"{key}={value}" for key, value in key_value_matches]
    #                     )

    #                 # For INI/CFG files
    #                 elif file_path.endswith((".ini", ".cfg", ".conf")):
    #                     import re

    #                     # Extract values from sections
    section_matches = re.findall(r"\[([^\]]+)\]", content)
                        dependencies.extend(section_matches)

    #         except Exception as e:
                logger.debug(f"Error extracting config dependencies from {file_path}: {e}")

    #         return dependencies

    #     def generate_project_structure(
    #         self,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> Dict[str, Any]:
    #         """
    #         Generate a JSON-serializable project structure.

    #         Args:
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             Dictionary representation of the project structure
    #         """
    structure = self.scan_directory(exclude_dirs, exclude_files)

    #         # Convert dataclasses to dictionaries for JSON serialization
    result = asdict(structure)

    #         # Convert datetime objects to strings
    #         if "created_at" in result and isinstance(result["created_at"], datetime):
    result["created_at"] = result["created_at"].isoformat()

    #         if "last_updated" in result and isinstance(result["last_updated"], datetime):
    result["last_updated"] = result["last_updated"].isoformat()

    #         # Convert datetime objects in files
    #         for file_path, file_data in result["files"].items():
    #             if "modified" in file_data and isinstance(file_data["modified"], datetime):
    file_data["modified"] = file_data["modified"].isoformat()

    #         # Convert datetime objects in directories
    #         for dir_path, dir_data in result["directories"].items():
    #             if "modified" not in dir_data:
    #                 continue
    #             if isinstance(dir_data["modified"], datetime):
    dir_data["modified"] = dir_data["modified"].isoformat()

    #         return result

    #     def save_project_structure(
    #         self,
    #         output_path: Union[str, Path],
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> str:
    #         """
    #         Save project structure to a JSON file.

    #         Args:
    #             output_path: Path to save the project structure JSON
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             Path to the saved file
    #         """
    output_path = Path(output_path)

    #         # Create .noodle directory if it doesn't exist
    noodle_dir = output_path / ".noodle"
    noodle_dir.mkdir(parents = True, exist_ok=True)

    #         # Generate project structure
    structure = self.generate_project_structure(exclude_dirs, exclude_files)

    #         # Save to file
    output_file = noodle_dir / "project_structure.json"
    #         with open(output_file, "w", encoding="utf-8") as f:
    json.dump(structure, f, indent = 2, ensure_ascii=False)

            logger.info(f"Saved project structure to {output_file}")
            return str(output_file)

    #     def get_file_language_distribution(
    #         self,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> Dict[str, int]:
    #         """
    #         Get the distribution of programming languages in the project.

    #         Args:
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             Dictionary mapping language names to file counts
    #         """
    structure = self.scan_directory(exclude_dirs, exclude_files)
            return dict(structure.languages)

    #     def get_dependency_graph(
    #         self,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> Dict[str, List[str]]:
    #         """
    #         Get a dependency graph of the project.

    #         Args:
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             Dictionary mapping file paths to their dependencies
    #         """
    structure = self.scan_directory(exclude_dirs, exclude_files)
            return dict(structure.dependencies)

    #     def find_duplicate_files(
    #         self,
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> Dict[str, List[str]]:
    #         """
    #         Find files with identical content (duplicates).

    #         Args:
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             Dictionary mapping hash values to lists of file paths
    #         """
    structure = self.scan_directory(exclude_dirs, exclude_files)
    duplicates = defaultdict(list)

    #         for file_path, file_metadata in structure.files.items():
    #             if file_metadata.hash and not file_metadata.is_binary:
                    duplicates[file_metadata.hash].append(file_path)

    #         # Filter out non-duplicates (hash values with only one file)
    #         return {
    #             hash_val: paths for hash_val, paths in duplicates.items() if len(paths) > 1
    #         }

    #     def find_large_files(
    #         self,
    min_size: int = math.multiply(1024, 1024,  # 1MB)
    exclude_dirs: Optional[List[str]] = None,
    exclude_files: Optional[List[str]] = None,
    #     ) -> List[Dict[str, Any]]:
    #         """
    #         Find large files in the project.

    #         Args:
    #             min_size: Minimum file size in bytes to consider as "large"
    #             exclude_dirs: List of directory names to exclude
    #             exclude_files: List of file names/patterns to exclude

    #         Returns:
    #             List of dictionaries with file information
    #         """
    structure = self.scan_directory(exclude_dirs, exclude_files)
    large_files = []

    #         for file_path, file_metadata in structure.files.items():
    #             if file_metadata.size >= min_size:
                    large_files.append(
    #                     {
    #                         "path": file_metadata.path,
    #                         "name": file_metadata.name,
    #                         "size": file_metadata.size,
    #                         "language": file_metadata.language,
                            "modified": file_metadata.modified.isoformat(),
    #                     }
    #                 )

            # Sort by size (largest first)
    large_files.sort(key = lambda x: x["size"], reverse=True)
    #         return large_files
