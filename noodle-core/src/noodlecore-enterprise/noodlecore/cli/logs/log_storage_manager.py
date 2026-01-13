"""
Logs::Log Storage Manager - log_storage_manager.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Log Storage Manager Module

This module implements efficient log storage and retrieval system for the NoodleCore CLI,
including multiple storage backends, compression, archival, and high availability.
"""

import asyncio
import gzip
import json
import os
import shutil
import sqlite3
import time
from abc import ABC, abstractmethod
from dataclasses import dataclass, asdict
from datetime import datetime, timedelta
from enum import Enum
from pathlib import Path
from typing import Dict, Any, Optional, List, Union, BinaryIO, Tuple
import hashlib
import threading
from concurrent.futures import ThreadPoolExecutor

from ..cli_config import get_cli_config


# Error codes for log storage manager (5601-5700)
class LogStorageErrorCodes:
    STORAGE_INIT_FAILED = 5601
    BACKEND_ERROR = 5602
    COMPRESSION_FAILED = 5603
    ARCHIVAL_FAILED = 5604
    RETENTION_FAILED = 5605
    BACKUP_FAILED = 5606
    INDEXING_FAILED = 5607
    REPLICATION_FAILED = 5608
    ENCRYPTION_FAILED = 5609
    CLEANUP_FAILED = 5610


class StorageBackend(Enum):
    """Storage backend types."""
    FILE = "file"
    DATABASE = "database"
    CLOUD = "cloud"
    HYBRID = "hybrid"


class CompressionType(Enum):
    """Compression types."""
    NONE = "none"
    GZIP = "gzip"
    LZMA = "lzma"
    BROTLI = "brotli"


class RetentionPolicy(Enum):
    """Retention policy types."""
    TIME_BASED = "time_based"
    SIZE_BASED = "size_based"
    COUNT_BASED = "count_based"
    CUSTOM = "custom"


@dataclass
class StorageConfig:
    """Storage configuration."""
    backend: StorageBackend
    compression: CompressionType
    encryption_enabled: bool
    retention_policy: RetentionPolicy
    retention_value: Union[int, str]  # days, size in MB, count, or custom rule
    backup_enabled: bool
    replication_enabled: bool
    indexing_enabled: bool
    config: Dict[str, Any]


@dataclass
class LogEntry:
    """Log entry for storage."""
    id: str
    timestamp: datetime
    level: str
    component: str
    message: str
    details: Dict[str, Any]
    tags: Dict[str, str]
    request_id: Optional[str] = None
    source_file: Optional[str] = None
    checksum: Optional[str] = None


@dataclass
class StorageStats:
    """Storage statistics."""
    total_entries: int
    total_size_bytes: int
    compressed_size_bytes: int
    oldest_entry: Optional[datetime]
    newest_entry: Optional[datetime]
    entries_by_level: Dict[str, int]
    entries_by_component: Dict[str, int]
    storage_backend: StorageBackend


class LogStorageException(Exception):
    """Base exception for log storage errors."""
    
    def __init__(self, message: str, error_code: int):
        self.error_code = error_code
        super().__init__(message)


class StorageBackendInterface(ABC):
    """Abstract interface for storage backends."""
    
    @abstractmethod
    async def store_entry(self, entry: LogEntry, config: StorageConfig) -> bool:
        """Store a log entry."""
        pass
    
    @abstractmethod
    async def retrieve_entries(
        self,
        filters: Dict[str, Any],
        limit: int,
        offset: int
    ) -> List[LogEntry]:
        """Retrieve log entries with filters."""
        pass
    
    @abstractmethod
    async def delete_entries(self, filters: Dict[str, Any]) -> int:
        """Delete log entries matching filters."""
        pass
    
    @abstractmethod
    async def get_stats(self) -> StorageStats:
        """Get storage statistics."""
        pass
    
    @abstractmethod
    async def optimize_storage(self) -> bool:
        """Optimize storage (compact, rebuild indexes, etc.)."""
        pass


class FileStorageBackend(StorageBackendInterface):
    """File-based storage backend."""
    
    def __init__(self, storage_dir: Path):
        self.storage_dir = storage_dir
        self.storage_dir.mkdir(parents=True, exist_ok=True)
        
        # Create subdirectories
        self.logs_dir = self.storage_dir / 'logs'
        self.index_dir = self.storage_dir / 'indexes'
        self.archive_dir = self.storage_dir / 'archive'
        
        for dir_path in [self.logs_dir, self.index_dir, self.archive_dir]:
            dir_path.mkdir(exist_ok=True)
        
        # Index files
        self.index_file = self.index_dir / 'log_index.db'
        self._initialize_index()
    
    def _initialize_index(self) -> None:
        """Initialize SQLite index database."""
        try:
            with sqlite3.connect(self.index_file) as conn:
                conn.execute('''
                    CREATE TABLE IF NOT EXISTS log_entries (
                        id TEXT PRIMARY KEY,
                        timestamp TEXT,
                        level TEXT,
                        component TEXT,
                        message TEXT,
                        details TEXT,
                        tags TEXT,
                        request_id TEXT,
                        source_file TEXT,
                        checksum TEXT,
                        file_path TEXT,
                        file_offset INTEGER
                    )
                ''')
                
                conn.execute('''
                    CREATE INDEX IF NOT EXISTS idx_timestamp ON log_entries(timestamp)
                ''')
                
                conn.execute('''
                    CREATE INDEX IF NOT EXISTS idx_level ON log_entries(level)
                ''')
                
                conn.execute('''
                    CREATE INDEX IF NOT EXISTS idx_component ON log_entries(component)
                ''')
                
                conn.commit()
        except Exception as e:
            raise LogStorageException(
                f"Failed to initialize file storage index: {str(e)}",
                LogStorageErrorCodes.INDEXING_FAILED
            )
    
    async def store_entry(self, entry: LogEntry, config: StorageConfig) -> bool:
        """Store a log entry to file."""
        try:
            # Generate file path based on date
            date_str = entry.timestamp.strftime('%Y/%m/%d')
            date_dir = self.logs_dir / date_str
            date_dir.mkdir(parents=True, exist_ok=True)
            
            file_name = f"{entry.component}_{entry.timestamp.strftime('%Y%m%d')}.log"
            if config.compression != CompressionType.NONE:
                file_name += f".{config.compression.value}"
            
            file_path = date_dir / file_name
            
            # Prepare entry data
            entry_data = {
                'id': entry.id,
                'timestamp': entry.timestamp.isoformat(),
                'level': entry.level,
                'component': entry.component,
                'message': entry.message,
                'details': entry.details,
                'tags': entry.tags,
                'request_id': entry.request_id,
                'source_file': entry.source_file
            }
            
            # Calculate checksum
            entry_json = json.dumps(entry_data, sort_keys=True, separators=(',', ':'))
            entry.checksum = hashlib.sha256(entry_json.encode()).hexdigest()
            entry_data['checksum'] = entry.checksum
            
            # Write to file
            if config.compression == CompressionType.GZIP:
                with gzip.open(file_path, 'at', encoding='utf-8') as f:
                    f.write(json.dumps(entry_data) + '\n')
            elif config.compression == CompressionType.NONE:
                with open(file_path, 'a', encoding='utf-8') as f:
                    f.write(json.dumps(entry_data) + '\n')
            else:
                # For other compression types, use gzip as fallback
                with gzip.open(file_path, 'at', encoding='utf-8') as f:
                    f.write(json.dumps(entry_data) + '\n')
            
            # Update index
            await self._update_index(entry, str(file_path), config)
            
            return True
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to store entry to file: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def _update_index(self, entry: LogEntry, file_path: str, config: StorageConfig) -> None:
        """Update SQLite index."""
        try:
            with sqlite3.connect(self.index_file) as conn:
                conn.execute('''
                    INSERT OR REPLACE INTO log_entries 
                    (id, timestamp, level, component, message, details, tags, 
                     request_id, source_file, checksum, file_path, file_offset)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    entry.id,
                    entry.timestamp.isoformat(),
                    entry.level,
                    entry.component,
                    entry.message,
                    json.dumps(entry.details),
                    json.dumps(entry.tags),
                    entry.request_id,
                    entry.source_file,
                    entry.checksum,
                    file_path,
                    -1  # File offset not tracked for append-only files
                ))
                conn.commit()
        except Exception as e:
            # Don't let index failures break storage
            pass
    
    async def retrieve_entries(
        self,
        filters: Dict[str, Any],
        limit: int,
        offset: int
    ) -> List[LogEntry]:
        """Retrieve log entries from files."""
        try:
            # Build SQL query
            query = "SELECT * FROM log_entries WHERE 1=1"
            params = []
            
            if 'since' in filters:
                query += " AND timestamp >= ?"
                params.append(filters['since'].isoformat())
            
            if 'until' in filters:
                query += " AND timestamp <= ?"
                params.append(filters['until'].isoformat())
            
            if 'level' in filters:
                query += " AND level = ?"
                params.append(filters['level'])
            
            if 'component' in filters:
                query += " AND component = ?"
                params.append(filters['component'])
            
            if 'request_id' in filters:
                query += " AND request_id = ?"
                params.append(filters['request_id'])
            
            query += " ORDER BY timestamp DESC LIMIT ? OFFSET ?"
            params.extend([limit, offset])
            
            # Execute query
            with sqlite3.connect(self.index_file) as conn:
                cursor = conn.execute(query, params)
                rows = cursor.fetchall()
            
            entries = []
            for row in rows:
                entry = LogEntry(
                    id=row[0],
                    timestamp=datetime.fromisoformat(row[1]),
                    level=row[2],
                    component=row[3],
                    message=row[4],
                    details=json.loads(row[5]),
                    tags=json.loads(row[6]),
                    request_id=row[7],
                    source_file=row[8],
                    checksum=row[9]
                )
                entries.append(entry)
            
            return entries
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to retrieve entries: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def delete_entries(self, filters: Dict[str, Any]) -> int:
        """Delete log entries matching filters."""
        try:
            # Get matching entries first
            matching_entries = await self.retrieve_entries(filters, 10000, 0)
            
            if not matching_entries:
                return 0
            
            # Delete from index
            with sqlite3.connect(self.index_file) as conn:
                # Build delete query
                query = "DELETE FROM log_entries WHERE 1=1"
                params = []
                
                if 'since' in filters:
                    query += " AND timestamp >= ?"
                    params.append(filters['since'].isoformat())
                
                if 'until' in filters:
                    query += " AND timestamp <= ?"
                    params.append(filters['until'].isoformat())
                
                if 'level' in filters:
                    query += " AND level = ?"
                    params.append(filters['level'])
                
                if 'component' in filters:
                    query += " AND component = ?"
                    params.append(filters['component'])
                
                cursor = conn.execute(query, params)
                deleted_count = cursor.rowcount
                conn.commit()
            
            # Note: We don't delete from actual log files for integrity
            # Files will be cleaned up by retention policies
            
            return deleted_count
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to delete entries: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def get_stats(self) -> StorageStats:
        """Get storage statistics."""
        try:
            with sqlite3.connect(self.index_file) as conn:
                # Total entries
                cursor = conn.execute("SELECT COUNT(*) FROM log_entries")
                total_entries = cursor.fetchone()[0]
                
                # Size calculation
                total_size = 0
                for root, dirs, files in os.walk(self.logs_dir):
                    for file in files:
                        file_path = os.path.join(root, file)
                        total_size += os.path.getsize(file_path)
                
                # Date range
                cursor = conn.execute("SELECT MIN(timestamp), MAX(timestamp) FROM log_entries")
                oldest, newest = cursor.fetchone()
                
                oldest_entry = datetime.fromisoformat(oldest) if oldest else None
                newest_entry = datetime.fromisoformat(newest) if newest else None
                
                # Entries by level
                cursor = conn.execute("SELECT level, COUNT(*) FROM log_entries GROUP BY level")
                entries_by_level = dict(cursor.fetchall())
                
                # Entries by component
                cursor = conn.execute("SELECT component, COUNT(*) FROM log_entries GROUP BY component")
                entries_by_component = dict(cursor.fetchall())
            
            return StorageStats(
                total_entries=total_entries,
                total_size_bytes=total_size,
                compressed_size_bytes=total_size,  # Would need actual calculation
                oldest_entry=oldest_entry,
                newest_entry=newest_entry,
                entries_by_level=entries_by_level,
                entries_by_component=entries_by_component,
                storage_backend=StorageBackend.FILE
            )
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to get storage stats: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def optimize_storage(self) -> bool:
        """Optimize file storage."""
        try:
            # Optimize SQLite index
            with sqlite3.connect(self.index_file) as conn:
                conn.execute("VACUUM")
                conn.execute("ANALYZE")
                conn.commit()
            
            # Archive old files
            await self._archive_old_files()
            
            return True
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to optimize storage: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def _archive_old_files(self) -> None:
        """Archive old log files."""
        try:
            cutoff_date = datetime.now() - timedelta(days=30)  # Archive files older than 30 days
            
            for root, dirs, files in os.walk(self.logs_dir):
                for file in files:
                    file_path = Path(root) / file
                    
                    # Check file modification time
                    mod_time = datetime.fromtimestamp(file_path.stat().st_mtime)
                    
                    if mod_time < cutoff_date:
                        # Move to archive directory
                        archive_path = self.archive_dir / file_path.relative_to(self.logs_dir)
                        archive_path.parent.mkdir(parents=True, exist_ok=True)
                        
                        shutil.move(str(file_path), str(archive_path))
                        
                        # Compress archived file if not already compressed
                        if not file.endswith(('.gz', '.bz2', '.xz')):
                            await self._compress_file(archive_path)
                            
        except Exception:
            pass  # Don't let archival failures break optimization
    
    async def _compress_file(self, file_path: Path) -> None:
        """Compress a file."""
        try:
            with open(file_path, 'rb') as f_in:
                with gzip.open(f"{file_path}.gz", 'wb') as f_out:
                    shutil.copyfileobj(f_in, f_out)
            
            # Remove original file
            file_path.unlink()
            
        except Exception:
            pass  # If compression fails, keep original file


class DatabaseStorageBackend(StorageBackendInterface):
    """Database-based storage backend."""
    
    def __init__(self, db_path: Path):
        self.db_path = db_path
        self.db_path.parent.mkdir(parents=True, exist_ok=True)
        self._initialize_database()
    
    def _initialize_database(self) -> None:
        """Initialize database tables."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                conn.execute('''
                    CREATE TABLE IF NOT EXISTS log_entries (
                        id TEXT PRIMARY KEY,
                        timestamp TEXT NOT NULL,
                        level TEXT NOT NULL,
                        component TEXT NOT NULL,
                        message TEXT NOT NULL,
                        details TEXT,
                        tags TEXT,
                        request_id TEXT,
                        source_file TEXT,
                        checksum TEXT,
                        created_at TEXT DEFAULT CURRENT_TIMESTAMP
                    )
                ''')
                
                # Create indexes for performance
                indexes = [
                    "CREATE INDEX IF NOT EXISTS idx_log_timestamp ON log_entries(timestamp)",
                    "CREATE INDEX IF NOT EXISTS idx_log_level ON log_entries(level)",
                    "CREATE INDEX IF NOT EXISTS idx_log_component ON log_entries(component)",
                    "CREATE INDEX IF NOT EXISTS idx_log_request_id ON log_entries(request_id)",
                    "CREATE INDEX IF NOT EXISTS idx_log_created_at ON log_entries(created_at)"
                ]
                
                for index_sql in indexes:
                    conn.execute(index_sql)
                
                conn.commit()
                
        except Exception as e:
            raise LogStorageException(
                f"Failed to initialize database: {str(e)}",
                LogStorageErrorCodes.STORAGE_INIT_FAILED
            )
    
    async def store_entry(self, entry: LogEntry, config: StorageConfig) -> bool:
        """Store a log entry to database."""
        try:
            # Calculate checksum
            entry_data = {
                'id': entry.id,
                'timestamp': entry.timestamp.isoformat(),
                'level': entry.level,
                'component': entry.component,
                'message': entry.message,
                'details': entry.details,
                'tags': entry.tags,
                'request_id': entry.request_id,
                'source_file': entry.source_file
            }
            
            entry_json = json.dumps(entry_data, sort_keys=True, separators=(',', ':'))
            entry.checksum = hashlib.sha256(entry_json.encode()).hexdigest()
            
            # Insert into database
            with sqlite3.connect(self.db_path) as conn:
                conn.execute('''
                    INSERT OR REPLACE INTO log_entries 
                    (id, timestamp, level, component, message, details, tags, 
                     request_id, source_file, checksum)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                ''', (
                    entry.id,
                    entry.timestamp.isoformat(),
                    entry.level,
                    entry.component,
                    entry.message,
                    json.dumps(entry.details),
                    json.dumps(entry.tags),
                    entry.request_id,
                    entry.source_file,
                    entry.checksum
                ))
                conn.commit()
            
            return True
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to store entry to database: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def retrieve_entries(
        self,
        filters: Dict[str, Any],
        limit: int,
        offset: int
    ) -> List[LogEntry]:
        """Retrieve log entries from database."""
        try:
            # Build query
            query = "SELECT * FROM log_entries WHERE 1=1"
            params = []
            
            if 'since' in filters:
                query += " AND timestamp >= ?"
                params.append(filters['since'].isoformat())
            
            if 'until' in filters:
                query += " AND timestamp <= ?"
                params.append(filters['until'].isoformat())
            
            if 'level' in filters:
                query += " AND level = ?"
                params.append(filters['level'])
            
            if 'component' in filters:
                query += " AND component = ?"
                params.append(filters['component'])
            
            if 'request_id' in filters:
                query += " AND request_id = ?"
                params.append(filters['request_id'])
            
            if 'search' in filters:
                query += " AND message LIKE ?"
                params.append(f"%{filters['search']}%")
            
            query += " ORDER BY timestamp DESC LIMIT ? OFFSET ?"
            params.extend([limit, offset])
            
            # Execute query
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.execute(query, params)
                rows = cursor.fetchall()
            
            entries = []
            for row in rows:
                entry = LogEntry(
                    id=row[0],
                    timestamp=datetime.fromisoformat(row[1]),
                    level=row[2],
                    component=row[3],
                    message=row[4],
                    details=json.loads(row[5]) if row[5] else {},
                    tags=json.loads(row[6]) if row[6] else {},
                    request_id=row[7],
                    source_file=row[8],
                    checksum=row[9]
                )
                entries.append(entry)
            
            return entries
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to retrieve entries from database: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def delete_entries(self, filters: Dict[str, Any]) -> int:
        """Delete log entries from database."""
        try:
            # Build delete query
            query = "DELETE FROM log_entries WHERE 1=1"
            params = []
            
            if 'since' in filters:
                query += " AND timestamp >= ?"
                params.append(filters['since'].isoformat())
            
            if 'until' in filters:
                query += " AND timestamp <= ?"
                params.append(filters['until'].isoformat())
            
            if 'level' in filters:
                query += " AND level = ?"
                params.append(filters['level'])
            
            if 'component' in filters:
                query += " AND component = ?"
                params.append(filters['component'])
            
            # Execute delete
            with sqlite3.connect(self.db_path) as conn:
                cursor = conn.execute(query, params)
                deleted_count = cursor.rowcount
                conn.commit()
            
            return deleted_count
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to delete entries from database: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def get_stats(self) -> StorageStats:
        """Get database storage statistics."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                # Total entries
                cursor = conn.execute("SELECT COUNT(*) FROM log_entries")
                total_entries = cursor.fetchone()[0]
                
                # Database file size
                total_size = self.db_path.stat().st_size
                
                # Date range
                cursor = conn.execute("SELECT MIN(timestamp), MAX(timestamp) FROM log_entries")
                oldest, newest = cursor.fetchone()
                
                oldest_entry = datetime.fromisoformat(oldest) if oldest else None
                newest_entry = datetime.fromisoformat(newest) if newest else None
                
                # Entries by level
                cursor = conn.execute("SELECT level, COUNT(*) FROM log_entries GROUP BY level")
                entries_by_level = dict(cursor.fetchall())
                
                # Entries by component
                cursor = conn.execute("SELECT component, COUNT(*) FROM log_entries GROUP BY component")
                entries_by_component = dict(cursor.fetchall())
            
            return StorageStats(
                total_entries=total_entries,
                total_size_bytes=total_size,
                compressed_size_bytes=total_size,  # Database compression handled internally
                oldest_entry=oldest_entry,
                newest_entry=newest_entry,
                entries_by_level=entries_by_level,
                entries_by_component=entries_by_component,
                storage_backend=StorageBackend.DATABASE
            )
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to get database stats: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def optimize_storage(self) -> bool:
        """Optimize database storage."""
        try:
            with sqlite3.connect(self.db_path) as conn:
                # Vacuum and analyze
                conn.execute("VACUUM")
                conn.execute("ANALYZE")
                conn.commit()
            
            return True
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to optimize database: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )


class LogStorageManager:
    """Comprehensive log storage management system."""
    
    def __init__(self, config_dir: Optional[str] = None):
        """
        Initialize the log storage manager.
        
        Args:
            config_dir: Directory for storage configuration and data
        """
        self.config = get_cli_config()
        self.config_dir = Path(config_dir or '.project/.noodle/logs')
        self.config_dir.mkdir(parents=True, exist_ok=True)
        
        # Storage configuration
        self.config_file = self.config_dir / 'storage_config.json'
        self.storage_config = self._load_storage_config()
        
        # Initialize backends
        self.backends: Dict[StorageBackend, StorageBackendInterface] = {}
        self._initialize_backends()
        
        # Retention policies
        self.retention_policies: Dict[str, Dict[str, Any]] = {}
        self._initialize_retention_policies()
        
        # Backup configuration
        self.backup_config = {
            'enabled': self.config.get_bool('NOODLE_BACKUP_ENABLED', False),
            'interval_hours': self.config.get_int('NOODLE_BACKUP_INTERVAL', 24),
            'backup_dir': self.config.get('NOODLE_BACKUP_DIR', str(self.config_dir / 'backups')),
            'retention_days': self.config.get_int('NOODLE_BACKUP_RETENTION', 30)
        }
        
        # Processing state
        self._running = False
        self._maintenance_task = None
        self._executor = ThreadPoolExecutor(max_workers=4)
        
        # Statistics
        self._stats = {
            'total_stored': 0,
            'total_retrieved': 0,
            'total_deleted': 0,
            'storage_operations': 0,
            'last_maintenance': None,
            'start_time': datetime.now()
        }
    
    def _load_storage_config(self) -> StorageConfig:
        """Load storage configuration."""
        try:
            if self.config_file.exists():
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config_data = json.load(f)
                
                return StorageConfig(
                    backend=StorageBackend(config_data['backend']),
                    compression=CompressionType(config_data['compression']),
                    encryption_enabled=config_data['encryption_enabled'],
                    retention_policy=RetentionPolicy(config_data['retention_policy']),
                    retention_value=config_data['retention_value'],
                    backup_enabled=config_data['backup_enabled'],
                    replication_enabled=config_data['replication_enabled'],
                    indexing_enabled=config_data['indexing_enabled'],
                    config=config_data.get('config', {})
                )
            else:
                # Default configuration
                default_config = StorageConfig(
                    backend=StorageBackend.FILE,
                    compression=CompressionType.GZIP,
                    encryption_enabled=False,
                    retention_policy=RetentionPolicy.TIME_BASED,
                    retention_value=90,  # 90 days
                    backup_enabled=False,
                    replication_enabled=False,
                    indexing_enabled=True,
                    config={}
                )
                self._save_storage_config(default_config)
                return default_config
                
        except Exception:
            # Return default config if loading fails
            return StorageConfig(
                backend=StorageBackend.FILE,
                compression=CompressionType.GZIP,
                encryption_enabled=False,
                retention_policy=RetentionPolicy.TIME_BASED,
                retention_value=90,
                backup_enabled=False,
                replication_enabled=False,
                indexing_enabled=True,
                config={}
            )
    
    def _save_storage_config(self, config: StorageConfig) -> None:
        """Save storage configuration."""
        try:
            config_data = {
                'backend': config.backend.value,
                'compression': config.compression.value,
                'encryption_enabled': config.encryption_enabled,
                'retention_policy': config.retention_policy.value,
                'retention_value': config.retention_value,
                'backup_enabled': config.backup_enabled,
                'replication_enabled': config.replication_enabled,
                'indexing_enabled': config.indexing_enabled,
                'config': config.config
            }
            
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config_data, f, indent=2)
                
        except Exception:
            pass  # Don't let config saving failures break storage
    
    def _initialize_backends(self) -> None:
        """Initialize storage backends."""
        try:
            if self.storage_config.backend in [StorageBackend.FILE, StorageBackend.HYBRID]:
                self.backends[StorageBackend.FILE] = FileStorageBackend(self.config_dir / 'file_storage')
            
            if self.storage_config.backend in [StorageBackend.DATABASE, StorageBackend.HYBRID]:
                self.backends[StorageBackend.DATABASE] = DatabaseStorageBackend(self.config_dir / 'log_storage.db')
            
            # For hybrid backend, we'll use both with logic to route entries
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to initialize storage backends: {str(e)}",
                LogStorageErrorCodes.STORAGE_INIT_FAILED
            )
    
    def _initialize_retention_policies(self) -> None:
        """Initialize retention policies."""
        self.retention_policies = {
            'default': {
                'policy': self.storage_config.retention_policy,
                'value': self.storage_config.retention_value,
                'action': 'archive'  # archive or delete
            },
            'errors': {
                'policy': RetentionPolicy.TIME_BASED,
                'value': 180,  # Keep errors for 6 months
                'action': 'archive'
            },
            'security': {
                'policy': RetentionPolicy.TIME_BASED,
                'value': 365,  # Keep security events for 1 year
                'action': 'archive'
            }
        }
    
    async def start_maintenance(self) -> None:
        """Start storage maintenance tasks."""
        if self._running:
            return
        
        self._running = True
        self._maintenance_task = asyncio.create_task(self._maintenance_loop())
    
    async def stop_maintenance(self) -> None:
        """Stop storage maintenance tasks."""
        self._running = False
        
        if self._maintenance_task:
            self._maintenance_task.cancel()
            try:
                await self._maintenance_task
            except asyncio.CancelledError:
                pass
        
        self._executor.shutdown(wait=True)
    
    async def _maintenance_loop(self) -> None:
        """Main maintenance loop."""
        while self._running:
            try:
                # Apply retention policies
                await self._apply_retention_policies()
                
                # Optimize storage
                await self._optimize_all_backends()
                
                # Perform backup if enabled
                if self.backup_config['enabled']:
                    await self._perform_backup()
                
                # Update statistics
                await self._update_statistics()
                
                self._stats['last_maintenance'] = datetime.now()
                
                # Run maintenance every hour
                await asyncio.sleep(3600)
                
            except asyncio.CancelledError:
                break
            except Exception as e:
                # Log error but continue maintenance
                print(f"Storage maintenance error: {str(e)}")
                await asyncio.sleep(300)  # Wait 5 minutes before retrying
    
    async def store_log_entry(self, entry: LogEntry) -> bool:
        """Store a log entry."""
        try:
            success = False
            
            if self.storage_config.backend == StorageBackend.HYBRID:
                # Store in both backends for redundancy
                for backend in [StorageBackend.FILE, StorageBackend.DATABASE]:
                    if backend in self.backends:
                        backend_success = await self.backends[backend].store_entry(entry, self.storage_config)
                        success = success or backend_success
            else:
                # Store in primary backend
                backend = self.backends.get(self.storage_config.backend)
                if backend:
                    success = await backend.store_entry(entry, self.storage_config)
            
            if success:
                self._stats['total_stored'] += 1
                self._stats['storage_operations'] += 1
            
            return success
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to store log entry: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def retrieve_log_entries(
        self,
        filters: Optional[Dict[str, Any]] = None,
        limit: int = 1000,
        offset: int = 0
    ) -> List[LogEntry]:
        """Retrieve log entries with filters."""
        try:
            filters = filters or {}
            entries = []
            
            # Try primary backend first
            primary_backend = self.backends.get(self.storage_config.backend)
            if primary_backend:
                entries = await primary_backend.retrieve_entries(filters, limit, offset)
            
            # If no entries found and using hybrid, try other backends
            if not entries and self.storage_config.backend == StorageBackend.HYBRID:
                for backend_type, backend in self.backends.items():
                    if backend_type != self.storage_config.backend:
                        entries = await backend.retrieve_entries(filters, limit, offset)
                        if entries:
                            break
            
            self._stats['total_retrieved'] += len(entries)
            return entries
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to retrieve log entries: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def delete_log_entries(self, filters: Dict[str, Any]) -> int:
        """Delete log entries matching filters."""
        try:
            total_deleted = 0
            
            for backend in self.backends.values():
                deleted = await backend.delete_entries(filters)
                total_deleted += deleted
            
            self._stats['total_deleted'] += total_deleted
            return total_deleted
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to delete log entries: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    async def _apply_retention_policies(self) -> None:
        """Apply retention policies to clean up old entries."""
        try:
            for policy_name, policy_config in self.retention_policies.items():
                policy = policy_config['policy']
                value = policy_config['value']
                action = policy_config['action']
                
                if policy == RetentionPolicy.TIME_BASED:
                    cutoff_date = datetime.now() - timedelta(days=value)
                    filters = {'until': cutoff_date}
                    
                    # Apply additional filters based on policy name
                    if policy_name == 'errors':
                        filters['level'] = 'ERROR'
                    elif policy_name == 'security':
                        filters['component'] = 'security'
                    
                    if action == 'delete':
                        await self.delete_log_entries(filters)
                    elif action == 'archive':
                        await self._archive_entries(filters)
                
                elif policy == RetentionPolicy.SIZE_BASED:
                    # Check storage size and clean if needed
                    stats = await self.get_storage_stats()
                    if stats.total_size_bytes > value * 1024 * 1024:  # Convert MB to bytes
                        # Delete oldest 10% of entries
                        oldest_date = datetime.now() - timedelta(days=30)
                        await self.delete_log_entries({'until': oldest_date})
                
                elif policy == RetentionPolicy.COUNT_BASED:
                    # Keep only the most recent N entries
                    stats = await self.get_storage_stats()
                    if stats.total_entries > value:
                        # Calculate cutoff for excess entries
                        excess = stats.total_entries - value
                        cutoff_date = datetime.now() - timedelta(days=7)  # Rough estimate
                        await self.delete_log_entries({'until': cutoff_date})
                        
        except Exception:
            pass  # Don't let retention failures break maintenance
    
    async def _archive_entries(self, filters: Dict[str, Any]) -> None:
        """Archive entries matching filters."""
        try:
            # This would implement archiving logic
            # For now, we'll just move to a different location or mark as archived
            pass
        except Exception:
            pass
    
    async def _optimize_all_backends(self) -> None:
        """Optimize all storage backends."""
        try:
            for backend in self.backends.values():
                await backend.optimize_storage()
        except Exception:
            pass  # Don't let optimization failures break maintenance
    
    async def _perform_backup(self) -> None:
        """Perform backup of storage data."""
        try:
            if not self.backup_config['enabled']:
                return
            
            backup_dir = Path(self.backup_config['backup_dir'])
            backup_dir.mkdir(parents=True, exist_ok=True)
            
            # Create backup timestamp
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_name = f"noodlecore_backup_{timestamp}"
            backup_path = backup_dir / backup_name
            
            # Backup storage directory
            if self.config_dir.exists():
                backup_path.mkdir(exist_ok=True)
                shutil.copytree(self.config_dir, backup_path / 'storage', dirs_exist_ok=True)
            
            # Clean old backups
            await self._cleanup_old_backups(backup_dir)
            
        except Exception:
            pass  # Don't let backup failures break maintenance
    
    async def _cleanup_old_backups(self, backup_dir: Path) -> None:
        """Clean up old backup files."""
        try:
            retention_days = self.backup_config['retention_days']
            cutoff_date = datetime.now() - timedelta(days=retention_days)
            
            for backup_path in backup_dir.iterdir():
                if backup_path.is_dir() and backup_path.name.startswith('noodlecore_backup_'):
                    # Extract timestamp from backup name
                    timestamp_str = backup_path.name.replace('noodlecore_backup_', '')
                    try:
                        backup_date = datetime.strptime(timestamp_str, '%Y%m%d_%H%M%S')
                        
                        if backup_date < cutoff_date:
                            shutil.rmtree(backup_path)
                    except ValueError:
                        # Invalid timestamp format, skip
                        continue
                        
        except Exception:
            pass
    
    async def _update_statistics(self) -> None:
        """Update storage statistics."""
        try:
            # Statistics are already tracked in _stats
            # This could be expanded to include more detailed metrics
            pass
        except Exception:
            pass
    
    async def get_storage_stats(self) -> Dict[str, Any]:
        """Get comprehensive storage statistics."""
        try:
            stats = {}
            
            for backend_type, backend in self.backends.items():
                backend_stats = await backend.get_stats()
                stats[backend_type.value] = asdict(backend_stats)
            
            # Add overall statistics
            stats['overall'] = {
                'total_stored': self._stats['total_stored'],
                'total_retrieved': self._stats['total_retrieved'],
                'total_deleted': self._stats['total_deleted'],
                'storage_operations': self._stats['storage_operations'],
                'last_maintenance': self._stats['last_maintenance'].isoformat() if self._stats['last_maintenance'] else None,
                'start_time': self._stats['start_time'].isoformat(),
                'uptime_seconds': (datetime.now() - self._stats['start_time']).total_seconds()
            }
            
            # Add configuration
            stats['config'] = {
                'backend': self.storage_config.backend.value,
                'compression': self.storage_config.compression.value,
                'encryption_enabled': self.storage_config.encryption_enabled,
                'retention_policy': self.storage_config.retention_policy.value,
                'retention_value': self.storage_config.retention_value,
                'backup_enabled': self.storage_config.backup_enabled
            }
            
            return stats
            
        except Exception as e:
            raise LogStorageException(
                f"Failed to get storage stats: {str(e)}",
                LogStorageErrorCodes.BACKEND_ERROR
            )
    
    def update_storage_config(self, config: StorageConfig) -> None:
        """Update storage configuration."""
        self.storage_config = config
        self._save_storage_config(config)
        
        # Reinitialize backends if needed
        self._initialize_backends()
    
    def add_retention_policy(self, name: str, policy_config: Dict[str, Any]) -> None:
        """Add a custom retention policy."""
        self.retention_policies[name] = policy_config
    
    def remove_retention_policy(self, name: str) -> bool:
        """Remove a retention policy."""
        if name in self.retention_policies and name != 'default':
            del self.retention_policies[name]
            return True
        return False
    
    def get_manager_stats(self) -> Dict[str, Any]:
        """Get storage manager statistics."""
        uptime = datetime.now() - self._stats['start_time']
        
        return {
            'running': self._running,
            'total_stored': self._stats['total_stored'],
            'total_retrieved': self._stats['total_retrieved'],
            'total_deleted': self._stats['total_deleted'],
            'storage_operations': self._stats['storage_operations'],
            'last_maintenance': self._stats['last_maintenance'].isoformat() if self._stats['last_maintenance'] else None,
            'uptime_seconds': uptime.total_seconds(),
            'start_time': self._stats['start_time'].isoformat(),
            'backends': list(self.backends.keys()),
            'retention_policies': list(self.retention_policies.keys()),
            'backup_config': self.backup_config
        }

