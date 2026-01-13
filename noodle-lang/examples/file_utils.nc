# Converted from Python to NoodleCore
# Original file: src

# """
# File Utilities Module

# This module provides file utility functions for NoodleCore CLI.
# """

import os
import shutil
import pathlib.Path
import typing.Dict


class FileUtils:
    #     """File utility functions for NoodleCore CLI."""

    #     def __init__(self):
    #         """Initialize the file utilities."""
    self.name = "FileUtils"

    #     def read_file(self, file_path: str, encoding: str = 'utf-8') -Dict[str, Any]):
    #         """
    #         Read a file.

    #         Args:
    #             file_path: Path to the file
    #             encoding: File encoding

    #         Returns:
    #             Dictionary containing file content
    #         """
    #         try:
    #             with open(file_path, 'r', encoding=encoding) as f:
    content = f.read()

    #             return {
    #                 'success': True,
    #                 'content': content,
    #                 'file_path': file_path,
                    'size': os.path.getsize(file_path)
    #             }

    #         except FileNotFoundError:
    #             return {
    #                 'success': False,
    #                 'error': f"File not found: {file_path}",
    #                 'error_code': 10001
    #             }
    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error reading file: {str(e)}",
    #                 'error_code': 10002
    #             }

    #     def write_file(self, file_path: str, content: str, encoding: str = 'utf-8') -Dict[str, Any]):
    #         """
    #         Write content to a file.

    #         Args:
    #             file_path: Path to the file
    #             content: Content to write
    #             encoding: File encoding

    #         Returns:
    #             Dictionary containing write result
    #         """
    #         try:
    #             # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(file_path), exist_ok = True)

    #             with open(file_path, 'w', encoding=encoding) as f:
                    f.write(content)

    #             return {
    #                 'success': True,
    #                 'message': f"File written successfully: {file_path}",
    #                 'file_path': file_path,
                    'size': os.path.getsize(file_path)
    #             }

    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error writing file: {str(e)}",
    #                 'error_code': 10003
    #             }

    #     def append_file(self, file_path: str, content: str, encoding: str = 'utf-8') -Dict[str, Any]):
    #         """
    #         Append content to a file.

    #         Args:
    #             file_path: Path to the file
    #             content: Content to append
    #             encoding: File encoding

    #         Returns:
    #             Dictionary containing append result
    #         """
    #         try:
    #             # Create directory if it doesn't exist
    os.makedirs(os.path.dirname(file_path), exist_ok = True)

    #             with open(file_path, 'a', encoding=encoding) as f:
                    f.write(content)

    #             return {
    #                 'success': True,
    #                 'message': f"Content appended successfully: {file_path}",
    #                 'file_path': file_path,
                    'size': os.path.getsize(file_path)
    #             }

    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error appending to file: {str(e)}",
    #                 'error_code': 10004
    #             }

    #     def delete_file(self, file_path: str) -Dict[str, Any]):
    #         """
    #         Delete a file.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             Dictionary containing delete result
    #         """
    #         try:
    #             if os.path.exists(file_path):
                    os.remove(file_path)
    #                 return {
    #                     'success': True,
    #                     'message': f"File deleted successfully: {file_path}",
    #                     'file_path': file_path
    #                 }
    #             else:
    #                 return {
    #                     'success': False,
    #                     'error': f"File not found: {file_path}",
    #                     'error_code': 10005
    #                 }

    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error deleting file: {str(e)}",
    #                 'error_code': 10006
    #             }

    #     def copy_file(self, source_path: str, target_path: str) -Dict[str, Any]):
    #         """
    #         Copy a file.

    #         Args:
    #             source_path: Path to the source file
    #             target_path: Path to the target file

    #         Returns:
    #             Dictionary containing copy result
    #         """
    #         try:
    #             # Create target directory if it doesn't exist
    os.makedirs(os.path.dirname(target_path), exist_ok = True)

                shutil.copy2(source_path, target_path)

    #             return {
    #                 'success': True,
    #                 'message': f"File copied successfully: {source_path} -{target_path}",
    #                 'source_path'): source_path,
    #                 'target_path': target_path
    #             }

    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error copying file: {str(e)}",
    #                 'error_code': 10007
    #             }

    #     def move_file(self, source_path: str, target_path: str) -Dict[str, Any]):
    #         """
    #         Move a file.

    #         Args:
    #             source_path: Path to the source file
    #             target_path: Path to the target file

    #         Returns:
    #             Dictionary containing move result
    #         """
    #         try:
    #             # Create target directory if it doesn't exist
    os.makedirs(os.path.dirname(target_path), exist_ok = True)

                shutil.move(source_path, target_path)

    #             return {
    #                 'success': True,
    #                 'message': f"File moved successfully: {source_path} -{target_path}",
    #                 'source_path'): source_path,
    #                 'target_path': target_path
    #             }

    #         except IOError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error moving file: {str(e)}",
    #                 'error_code': 10008
    #             }

    #     def list_files(self, directory: str, pattern: str = '*', recursive: bool = False) -Dict[str, Any]):
    #         """
    #         List files in a directory.

    #         Args:
    #             directory: Directory to list
    #             pattern: File pattern to match
    #             recursive: Whether to list recursively

    #         Returns:
    #             Dictionary containing list of files
    #         """
    #         try:
    #             if recursive:
    files = list(Path(directory).rglob(pattern))
    #             else:
    files = list(Path(directory).glob(pattern))

    #             # Filter to only include files, not directories
    #             file_paths = [str(f) for f in files if f.is_file()]

    #             return {
    #                 'success': True,
    #                 'files': file_paths,
                    'count': len(file_paths),
    #                 'directory': directory,
    #                 'pattern': pattern,
    #                 'recursive': recursive
    #             }

    #         except OSError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error listing files: {str(e)}",
    #                 'error_code': 10009
    #             }

    #     def create_directory(self, directory: str) -Dict[str, Any]):
    #         """
    #         Create a directory.

    #         Args:
    #             directory: Directory to create

    #         Returns:
    #             Dictionary containing create result
    #         """
    #         try:
    os.makedirs(directory, exist_ok = True)

    #             return {
    #                 'success': True,
    #                 'message': f"Directory created successfully: {directory}",
    #                 'directory': directory
    #             }

    #         except OSError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error creating directory: {str(e)}",
    #                 'error_code': 10010
    #             }

    #     def delete_directory(self, directory: str, recursive: bool = False) -Dict[str, Any]):
    #         """
    #         Delete a directory.

    #         Args:
    #             directory: Directory to delete
    #             recursive: Whether to delete recursively

    #         Returns:
    #             Dictionary containing delete result
    #         """
    #         try:
    #             if recursive:
                    shutil.rmtree(directory)
    #             else:
                    os.rmdir(directory)

    #             return {
    #                 'success': True,
    #                 'message': f"Directory deleted successfully: {directory}",
    #                 'directory': directory,
    #                 'recursive': recursive
    #             }

    #         except OSError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error deleting directory: {str(e)}",
    #                 'error_code': 10011
    #             }

    #     def get_file_info(self, file_path: str) -Dict[str, Any]):
    #         """
    #         Get file information.

    #         Args:
    #             file_path: Path to the file

    #         Returns:
    #             Dictionary containing file information
    #         """
    #         try:
    stat = os.stat(file_path)

    #             return {
    #                 'success': True,
    #                 'file_path': file_path,
    #                 'size': stat.st_size,
    #                 'created': stat.st_ctime,
    #                 'modified': stat.st_mtime,
    #                 'accessed': stat.st_atime,
                    'is_file': os.path.isfile(file_path),
                    'is_directory': os.path.isdir(file_path),
                    'is_readable': os.access(file_path, os.R_OK),
                    'is_writable': os.access(file_path, os.W_OK),
                    'is_executable': os.access(file_path, os.X_OK)
    #             }

    #         except OSError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error getting file info: {str(e)}",
    #                 'error_code': 10012
    #             }

    #     def find_files(self, directory: str, name: Optional[str] = None, extension: Optional[str] = None) -Dict[str, Any]):
    #         """
    #         Find files in a directory.

    #         Args:
    #             directory: Directory to search
    #             name: File name to match
    #             extension: File extension to match

    #         Returns:
    #             Dictionary containing found files
    #         """
    #         try:
    found_files = []

    #             for root, dirs, files in os.walk(directory):
    #                 for file in files:
    file_path = os.path.join(root, file)

    #                     # Check name match
    #                     if name and name not in file:
    #                         continue

    #                     # Check extension match
    #                     if extension and not file.endswith(extension):
    #                         continue

                        found_files.append(file_path)

    #             return {
    #                 'success': True,
    #                 'files': found_files,
                    'count': len(found_files),
    #                 'directory': directory,
    #                 'name': name,
    #                 'extension': extension
    #             }

    #         except OSError as e:
    #             return {
    #                 'success': False,
                    'error': f"Error finding files: {str(e)}",
    #                 'error_code': 10013
    #             }