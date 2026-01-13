# File Manager for Noodle IDE
# Handles all file operations through NoodleCore APIs
# Provides language-independent file management

import asyncio
import os
import json
import time
import logging
from datetime import datetime
from typing import Dict, List, Optional, Any, Union
from dataclasses import dataclass
from enum import Enum

from ..api.noodle_api_client import NoodleAPIClient, APIResponse, FileInfo

class FileOperation(Enum)
    """File operations"""
    OPEN = "open"
    SAVE = "save"
    CREATE = "create"
    DELETE = "delete"
    RENAME = "rename"
    COPY = "copy"
    MOVE = "move"

class WatchEvent(Enum)
    """File system watch events"""
    FILE_CREATED = "file_created"
    FILE_DELETED = "file_deleted"
    FILE_MODIFIED = "file_modified"
    FILE_RENAMED = "file_renamed"
    DIRECTORY_CREATED = "directory_created"
    DIRECTORY_DELETED = "directory_deleted"

@dataclass
class FileWatchEvent
    """File system watch event data"""
    event_type: WatchEvent
    file_path: str
    old_path: Optional[str] = None
    timestamp: str = None
    file_info: Optional[FileInfo] = None
    
    def __post_init__(self):
        if self.timestamp is None:
            self.timestamp = datetime.now().isoformat()

@dataclass
class FileHistoryEntry
    """File history entry"""
    operation: FileOperation
    file_path: str
    timestamp: str
    success: bool
    error: Optional[str] = None
    metadata: Dict[str, Any] = None

class FileManager
    """Noodle IDE File Manager
    
    Manages all file operations through NoodleCore APIs.
    Provides file system navigation, project management, and file watching.
    """

    def __init__(self, api_client: NoodleAPIClient):
        """Initialize the file manager
        
        Args:
            api_client: NoodleCore API client instance
        """
        self.api_client = api_client
        self.logger = logging.getLogger(__name__)
        
        # State management
        self.current_directory = ""
        self.current_files: Dict[str, FileInfo] = {}
        self.open_files: Dict[str, FileInfo] = {}
        self.recent_files: List[str] = []
        self.recent_directories: List[str] = []
        
        # File system watching
        self.watchers: Dict[str, asyncio.Task] = {}
        self.watch_event_handlers: List[callable] = []
        
        # Operation history
        self.operation_history: List[FileHistoryEntry] = []
        self.max_history = 100
        
        # Cache management
        self.file_cache: Dict[str, FileInfo] = {}
        self.cache_expiry = 300  # 5 minutes
        
        # Performance metrics
        self.operations_count = 0
        self.failed_operations = 0

    # Core File Operations
    async def open_file(self, file_path: str) -> Optional[FileInfo]:
        """Open a file and return its information"""
        try:
            # Check if file is already open
            if file_path in self.open_files:
                return self.open_files[file_path]
            
            # Load file from API
            response = await self.api_client.open_file(file_path)
            
            if response.success:
                file_info = FileInfo(
                    path=file_path,
                    name=os.path.basename(file_path),
                    size=response.data.get("size", 0),
                    modified=response.data.get("modified", ""),
                    is_directory=False,
                    content=response.data.get("content", ""),
                    language=response.data.get("language", "unknown")
                )
                
                # Add to open files
                self.open_files[file_path] = file_info
                
                # Update recent files
                if file_path not in self.recent_files:
                    self.recent_files.insert(0, file_path)
                    if len(self.recent_files) > 20:  # Keep last 20 recent files
                        self.recent_files = self.recent_files[:20]
                
                # Log operation
                await self._log_operation(FileOperation.OPEN, file_path, True)
                
                self.logger.info(f"File opened: {file_path}")
                return file_info
                
            else:
                await self._log_operation(FileOperation.OPEN, file_path, False, response.error)
                self.logger.error(f"Failed to open file {file_path}: {response.error}")
                return None
                
        except Exception as e:
            await self._log_operation(FileOperation.OPEN, file_path, False, str(e))
            self.logger.error(f"Error opening file {file_path}: {e}")
            return None

    async def save_file(self, file_path: str, content: str, language: str = "noodle") -> bool:
        """Save a file"""
        try:
            response = await self.api_client.save_file(file_path, content, language)
            
            if response.success:
                # Update cached file info
                if file_path in self.open_files:
                    self.open_files[file_path].content = content
                    self.open_files[file_path].modified = datetime.now().isoformat()
                
                # Update file cache
                if file_path in self.file_cache:
                    self.file_cache[file_path].content = content
                    self.file_cache[file_path].modified = datetime.now().isoformat()
                
                # Log operation
                await self._log_operation(FileOperation.SAVE, file_path, True)
                
                self.logger.info(f"File saved: {file_path}")
                return True
                
            else:
                await self._log_operation(FileOperation.SAVE, file_path, False, response.error)
                self.logger.error(f"Failed to save file {file_path}: {response.error}")
                return False
                
        except Exception as e:
            await self._log_operation(FileOperation.SAVE, file_path, False, str(e))
            self.logger.error(f"Error saving file {file_path}: {e}")
            return False

    async def create_file(self, file_path: str, content: str = "", language: str = "noodle") -> bool:
        """Create a new file"""
        try:
            response = await self.api_client.create_file(file_path, content, language)
            
            if response.success:
                # Add to current files list
                await self.refresh_directory()
                
                # Log operation
                await self._log_operation(FileOperation.CREATE, file_path, True)
                
                self.logger.info(f"File created: {file_path}")
                return True
                
            else:
                await self._log_operation(FileOperation.CREATE, file_path, False, response.error)
                self.logger.error(f"Failed to create file {file_path}: {response.error}")
                return False
                
        except Exception as e:
            await self._log_operation(FileOperation.CREATE, file_path, False, str(e))
            self.logger.error(f"Error creating file {file_path}: {e}")
            return False

    async def delete_file(self, file_path: str) -> bool:
        """Delete a file"""
        try:
            response = await self.api_client.delete_file(file_path)
            
            if response.success:
                # Remove from open files if open
                if file_path in self.open_files:
                    del self.open_files[file_path]
                
                # Remove from file cache
                if file_path in self.file_cache:
                    del self.file_cache[file_path]
                
                # Remove from recent files
                if file_path in self.recent_files:
                    self.recent_files.remove(file_path)
                
                # Refresh directory
                await self.refresh_directory()
                
                # Log operation
                await self._log_operation(FileOperation.DELETE, file_path, True)
                
                self.logger.info(f"File deleted: {file_path}")
                return True
                
            else:
                await self._log_operation(FileOperation.DELETE, file_path, False, response.error)
                self.logger.error(f"Failed to delete file {file_path}: {response.error}")
                return False
                
        except Exception as e:
            await self._log_operation(FileOperation.DELETE, file_path, False, str(e))
            self.logger.error(f"Error deleting file {file_path}: {e}")
            return False

    async def rename_file(self, old_path: str, new_path: str) -> bool:
        """Rename or move a file"""
        try:
            # This would need a rename/move endpoint
            # For now, we'll simulate it with delete + create
            response = await self.api_client.open_file(old_path)
            
            if not response.success:
                await self._log_operation(FileOperation.RENAME, old_path, False, response.error)
                return False
            
            old_content = response.data.get("content", "")
            old_language = response.data.get("language", "unknown")
            
            # Create new file
            create_success = await self.create_file(new_path, old_content, old_language)
            if not create_success:
                await self._log_operation(FileOperation.RENAME, old_path, False, "Failed to create new file")
                return False
            
            # Delete old file
            delete_success = await self.delete_file(old_path)
            if not delete_success:
                # Clean up new file if deletion failed
                await self.delete_file(new_path)
                await self._log_operation(FileOperation.RENAME, old_path, False, "Failed to delete old file")
                return False
            
            # Log operation
            await self._log_operation(FileOperation.RENAME, old_path, True, metadata={"new_path": new_path})
            
            self.logger.info(f"File renamed: {old_path} -> {new_path}")
            return True
            
        except Exception as e:
            await self._log_operation(FileOperation.RENAME, old_path, False, str(e))
            self.logger.error(f"Error renaming file {old_path}: {e}")
            return False

    # Directory and Project Management
    async def list_directory(self, directory: str = "") -> List[FileInfo]:
        """List files in a directory"""
        try:
            response = await self.api_client.list_files(directory)
            
            if response.success:
                files_data = response.data.get("files", [])
                files = []
                
                for file_data in files_data:
                    file_info = FileInfo(
                        path=file_data["path"],
                        name=file_data["name"],
                        size=file_data.get("size", 0),
                        modified=file_data.get("modified", ""),
                        is_directory=file_data.get("is_directory", False)
                    )
                    files.append(file_info)
                
                # Cache directory listing
                self.file_cache[f"dir:{directory}"] = FileInfo(
                    path=directory,
                    name=os.path.basename(directory) or "/",
                    size=0,
                    modified=datetime.now().isoformat(),
                    is_directory=True
                )
                
                return files
                
            else:
                self.logger.error(f"Failed to list directory {directory}: {response.error}")
                return []
                
        except Exception as e:
            self.logger.error(f"Error listing directory {directory}: {e}")
            return []

    async def refresh_directory(self):
        """Refresh current directory listing"""
        self.current_files.clear()
        files = await self.list_directory(self.current_directory)
        
        for file_info in files:
            self.current_files[file_info.path] = file_info

    async def set_current_directory(self, directory: str):
        """Set the current working directory"""
        self.current_directory = directory
        
        # Update recent directories
        if directory not in self.recent_directories:
            self.recent_directories.insert(0, directory)
            if len(self.recent_directories) > 10:
                self.recent_directories = self.recent_directories[:10]
        
        # Refresh directory listing
        await self.refresh_directory()

    def get_current_directory(self) -> str:
        """Get current working directory"""
        return self.current_directory

    def get_current_files(self) -> Dict[str, FileInfo]:
        """Get current directory files"""
        return self.current_files.copy()

    def get_open_files(self) -> Dict[str, FileInfo]:
        """Get currently open files"""
        return self.open_files.copy()

    def get_recent_files(self) -> List[str]:
        """Get recent files list"""
        return self.recent_files.copy()

    def get_recent_directories(self) -> List[str]:
        """Get recent directories list"""
        return self.recent_directories.copy()

    # File System Watching
    async def start_watching_directory(self, directory: str, recursive: bool = False):
        """Start watching a directory for changes"""
        if directory in self.watchers:
            return  # Already watching
        
        async def watch_directory():
            try:
                while directory in self.watchers:
                    # This would implement actual file system watching
                    # For now, we'll simulate periodic checks
                    await asyncio.sleep(2)
                    
                    # Check for changes (simulation)
                    files = await self.list_directory(directory)
                    # Compare with cached files and emit events
                    
            except asyncio.CancelledError:
                self.logger.info(f"Stopped watching directory: {directory}")
            except Exception as e:
                self.logger.error(f"Error watching directory {directory}: {e}")
        
        # Start watching task
        watcher_task = asyncio.create_task(watch_directory())
        self.watchers[directory] = watcher_task
        
        self.logger.info(f"Started watching directory: {directory}")

    async def stop_watching_directory(self, directory: str):
        """Stop watching a directory"""
        if directory in self.watchers:
            watcher_task = self.watchers[directory]
            watcher_task.cancel()
            del self.watchers[directory]
            
            self.logger.info(f"Stopped watching directory: {directory}")

    def add_watch_event_handler(self, handler: callable):
        """Add a file system event handler"""
        self.watch_event_handlers.append(handler)

    async def emit_watch_event(self, event: FileWatchEvent):
        """Emit a file system watch event"""
        for handler in self.watch_event_handlers:
            try:
                if asyncio.iscoroutinefunction(handler):
                    await handler(event)
                else:
                    handler(event)
            except Exception as e:
                self.logger.error(f"Error in watch event handler: {e}")

    # Utility Methods
    async def find_files(self, pattern: str, directory: str = None) -> List[FileInfo]:
        """Find files matching a pattern"""
        search_dir = directory or self.current_directory
        files = []
        
        try:
            # This would implement pattern matching
            # For now, return empty list
            pass
        except Exception as e:
            self.logger.error(f"Error searching for files: {e}")
        
        return files

    async def get_file_info(self, file_path: str) -> Optional[FileInfo]:
        """Get detailed file information"""
        try:
            # Check cache first
            if file_path in self.file_cache:
                cache_entry = self.file_cache[file_path]
                # Check if cache is still valid
                if time.time() - cache_entry.size < self.cache_expiry:
                    return cache_entry
            
            # Load from API if not in cache
            response = await self.api_client.open_file(file_path)
            
            if response.success:
                file_info = FileInfo(
                    path=file_path,
                    name=os.path.basename(file_path),
                    size=response.data.get("size", 0),
                    modified=response.data.get("modified", ""),
                    is_directory=False,
                    content=response.data.get("content", ""),
                    language=response.data.get("language", "unknown")
                )
                
                # Cache the file info
                self.file_cache[file_path] = file_info
                
                return file_info
            
            return None
            
        except Exception as e:
            self.logger.error(f"Error getting file info {file_path}: {e}")
            return None

    def clear_cache(self):
        """Clear file cache"""
        self.file_cache.clear()
        self.logger.info("File cache cleared")

    async def close_all_files(self):
        """Close all open files"""
        for file_path in list(self.open_files.keys()):
            await self.close_file(file_path)

    async def close_file(self, file_path: str) -> bool:
        """Close a file"""
        try:
            if file_path in self.open_files:
                del self.open_files[file_path]
                
                # Notify file watchers
                event = FileWatchEvent(
                    event_type=WatchEvent.FILE_MODIFIED,
                    file_path=file_path
                )
                await self.emit_watch_event(event)
                
                self.logger.info(f"File closed: {file_path}")
                return True
            
            return False
            
        except Exception as e:
            self.logger.error(f"Error closing file {file_path}: {e}")
            return False

    async def _log_operation(self, operation: FileOperation, file_path: str, success: bool, error: str = None, metadata: Dict[str, Any] = None):
        """Log a file operation"""
        self.operations_count += 1
        if not success:
            self.failed_operations += 1
        
        entry = FileHistoryEntry(
            operation=operation,
            file_path=file_path,
            timestamp=datetime.now().isoformat(),
            success=success,
            error=error,
            metadata=metadata
        )
        
        self.operation_history.append(entry)
        
        # Maintain history size limit
        if len(self.operation_history) > self.max_history:
            self.operation_history = self.operation_history[-self.max_history:]

    def get_operation_history(self, limit: int = 50) -> List[FileHistoryEntry]:
        """Get operation history"""
        return self.operation_history[-limit:]

    def get_statistics(self) -> Dict[str, Any]:
        """Get file manager statistics"""
        return {
            "total_operations": self.operations_count,
            "failed_operations": self.failed_operations,
            "success_rate": (self.operations_count - self.failed_operations) / max(1, self.operations_count),
            "open_files_count": len(self.open_files),
            "current_files_count": len(self.current_files),
            "cached_files_count": len(self.file_cache),
            "active_watchers": len(self.watchers),
            "recent_files_count": len(self.recent_files),
            "recent_directories_count": len(self.recent_directories),
            "current_directory": self.current_directory
        }

    async def cleanup(self):
        """Clean up file manager resources"""
        # Stop all file watchers
        for directory in list(self.watchers.keys()):
            await self.stop_watching_directory(directory)
        
        # Close all open files
        await self.close_all_files()
        
        # Clear cache
        self.clear_cache()
        
        self.logger.info("File manager cleaned up")

    def __str__(self):
        return f"FileManager(dir={self.current_directory}, open_files={len(self.open_files)})"

    def __repr__(self):
        return f"FileManager(operations={self.operations_count}, errors={self.failed_operations})"