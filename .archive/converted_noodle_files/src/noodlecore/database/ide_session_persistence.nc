# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# IDE Session Persistence Manager

# This module provides comprehensive session persistence for the NoodleCore IDE,
# allowing users to continue exactly where they left off by storing all IDE state
# in the vector database.

# Features:
# - Window positions and geometry
# - Open files and tabs
# - Panel states and visibility
# - Current project and working directory
# - File content at save points
# - Editor preferences and settings
# - Search history and recent files
# - Panel sizes and layout
# - AI chat history
# - Git state and repository info
# """

import sqlite3
import json
import hashlib
import os
import sys
import time
import threading
import datetime.datetime
import pathlib.Path
import typing.Dict,
import logging

# Configure logging
logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)

class IDESessionPersistence
    #     """
    #     Manages IDE session persistence using vector database storage.
    #     """

    #     def __init__(self, project_root: Path = None):
    #         """Initialize the session persistence manager."""
    self.project_root = project_root or Path.cwd()
    self.db_path = self.project_root / ".noodle_ide_sessions.sqlite"
    self.session_id = None
    self.is_dirty = False
    self._lock = threading.Lock()
            self._init_database()

    #     def _init_database(self):
    #         """Initialize the SQLite database for IDE sessions."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    conn.execute("PRAGMA journal_mode = WAL")
    cursor = conn.cursor()

    #             # Create sessions table
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS ide_sessions (
    #                     id TEXT PRIMARY KEY,
    #                     name TEXT,
    #                     project_path TEXT NOT NULL,
    #                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    #                     last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    #                     session_data TEXT NOT NULL,
                        UNIQUE(id, project_path)
    #                 )
    #             ''')

    #             # Create session files table for file content snapshots
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS session_files (
    #                     id TEXT PRIMARY KEY,
    #                     session_id TEXT NOT NULL,
    #                     file_path TEXT NOT NULL,
    #                     file_hash TEXT NOT NULL,
    #                     file_content TEXT NOT NULL,
    #                     cursor_position TEXT,
    #                     tab_order INTEGER,
    #                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (session_id) REFERENCES ide_sessions (id) ON DELETE CASCADE,
                        UNIQUE(session_id, file_path)
    #                 )
    #             ''')

    #             # Create workspace snapshots table
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS workspace_snapshots (
    #                     id TEXT PRIMARY KEY,
    #                     session_id TEXT NOT NULL,
    #                     snapshot_type TEXT NOT NULL,
    #                     snapshot_data TEXT NOT NULL,
    #                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                        FOREIGN KEY (session_id) REFERENCES ide_sessions (id) ON DELETE CASCADE
    #                 )
    #             ''')

    #             # Create search history table
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS search_history (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     session_id TEXT,
    #                     query TEXT NOT NULL,
    #                     file_pattern TEXT,
    #                     results_summary TEXT,
    #                     searched_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #                 )
    #             ''')

    #             # Create AI chat history table
                cursor.execute('''
                    CREATE TABLE IF NOT EXISTS ai_chat_history (
    #                     id INTEGER PRIMARY KEY AUTOINCREMENT,
    #                     session_id TEXT,
    #                     chat_messages TEXT NOT NULL,
    #                     provider TEXT,
    #                     model TEXT,
    #                     created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    #                 )
    #             ''')

                conn.commit()
                conn.close()
                logger.info("IDE session database initialized successfully")

    #         except Exception as e:
                logger.error(f"Error initializing session database: {str(e)}")
    #             raise

    #     def _generate_id(self, prefix: str = "") -> str:
    #         """Generate a unique ID for database entries."""
    timestamp = math.multiply(int(time.time(), 1000))
    random_part = os.urandom(8).hex()
    #         return f"{prefix}{timestamp}_{random_part}"

    #     def create_session(self, name: str = "Default Session") -> str:
    #         """Create a new IDE session."""
    #         with self._lock:
    self.session_id = self._generate_id("session_")

    #             # Load existing session data if it exists
    existing_data = self._load_existing_session()

    session_data = {
    #                 "name": name,
    #                 "window_geometry": "1200x800+100+100",
    #                 "window_state": "normal",
    #                 "current_file": None,
    #                 "active_tab": 0,
    #                 "panel_states": {
    #                     "file_explorer": True,
    #                     "code_editor": True,
    #                     "terminal": True,
    #                     "ai_chat": True,
    #                     "properties": False
    #                 },
    #                 "panel_sizes": {
    #                     "file_explorer_width": 300,
    #                     "terminal_height": 200,
    #                     "ai_chat_width": 350
    #                 },
                    "current_project_path": str(self.project_root),
    #                 "recent_files": [],
    #                 "search_history": [],
    #                 "git_state": {},
    #                 "editor_settings": {
    #                     "font_size": 12,
    #                     "theme": "dark",
    #                     "word_wrap": True,
    #                     "line_numbers": True
    #                 },
                    "last_save": datetime.now().isoformat(),
    #                 "version": "1.0"
    #             }

    #             # Merge with existing data if available
    #             if existing_data:
    session_data = self._merge_session_data(session_data, existing_data)

                self._save_session_data(session_data)
    self.is_dirty = False

                logger.info(f"Created new IDE session: {self.session_id}")
    #             return self.session_id

    #     def _load_existing_session(self) -> Optional[Dict]:
    #         """Load the most recent session for this project."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

    #             # Get the most recent session for this project
                cursor.execute('''
    #                 SELECT session_data FROM ide_sessions
    WHERE project_path = ?
    #                 ORDER BY last_modified DESC
    #                 LIMIT 1
                ''', (str(self.project_root),))

    result = cursor.fetchone()
                conn.close()

    #             if result:
                    return json.loads(result[0])

    #             return None

    #         except Exception as e:
                logger.error(f"Error loading existing session: {str(e)}")
    #             return None

    #     def _merge_session_data(self, new_data: Dict, existing_data: Dict) -> Dict:
    #         """Merge new session data with existing data, preserving valuable state."""
    #         try:
    #             # Preserve recent files and search history
    #             if "recent_files" in existing_data:
    new_data["recent_files"] = existing_data["recent_files"][:50]  # Keep last 50

    #             if "search_history" in existing_data:
    new_data["search_history"] = existing_data["search_history"][:100]  # Keep last 100

    #             # Preserve editor settings
    #             if "editor_settings" in existing_data:
                    new_data["editor_settings"].update(existing_data["editor_settings"])

    #             # Preserve git state
    #             if "git_state" in existing_data:
    new_data["git_state"] = existing_data["git_state"]

    #             # Update last save time
    new_data["last_save"] = datetime.now().isoformat()

    #             logger.info("Successfully merged session data with existing state")
    #             return new_data

    #         except Exception as e:
                logger.error(f"Error merging session data: {str(e)}")
    #             return new_data

    #     def _save_session_data(self, session_data: Dict):
    #         """Save session data to the database."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

    #             # Update or insert session
                cursor.execute('''
    #                 INSERT OR REPLACE INTO ide_sessions
                    (id, name, project_path, last_modified, session_data)
                    VALUES (?, ?, ?, ?, ?)
                ''', (
    #                 self.session_id,
                    session_data.get("name", "Default Session"),
                    str(self.project_root),
                    datetime.now().isoformat(),
    json.dumps(session_data, indent = 2)
    #             ))

                conn.commit()
                conn.close()
                logger.debug(f"Saved session data: {self.session_id}")

    #         except Exception as e:
                logger.error(f"Error saving session data: {str(e)}")
    #             raise

    #     def save_window_state(self, window_geometry: str, window_state: str, panel_states: Dict, panel_sizes: Dict):
    #         """Save current window state."""
    #         if not self.session_id:
    #             return

    #         with self._lock:
    #             try:
    session_data = self._load_session_data()
    #                 if session_data:
    session_data["window_geometry"] = window_geometry
    session_data["window_state"] = window_state
    session_data["panel_states"] = panel_states
    session_data["panel_sizes"] = panel_sizes
    session_data["last_save"] = datetime.now().isoformat()

                        self._save_session_data(session_data)
    self.is_dirty = False

    #             except Exception as e:
                    logger.error(f"Error saving window state: {str(e)}")

    #     def save_open_files(self, open_files: Dict, active_tab: int, current_file: str = None):
    #         """Save information about currently open files."""
    #         if not self.session_id:
    #             return

    #         with self._lock:
    #             try:
    #                 # Save file content snapshots
    #                 for file_path, text_widget in open_files.items():
                        self._save_file_snapshot(file_path, text_widget, active_tab)

    #                 # Update session data
    session_data = self._load_session_data()
    #                 if session_data:
    session_data["active_tab"] = active_tab
    session_data["current_file"] = current_file
    session_data["last_save"] = datetime.now().isoformat()

    #                     # Update recent files list
    #                     if current_file:
    recent_files = session_data.get("recent_files", [])
    #                         if current_file not in recent_files:
                                recent_files.insert(0, current_file)
    session_data["recent_files"] = recent_files[:20]  # Keep last 20

                        self._save_session_data(session_data)
    self.is_dirty = False

    #             except Exception as e:
                    logger.error(f"Error saving open files: {str(e)}")

    #     def _save_file_snapshot(self, file_path: str, text_widget, tab_order: int):
    #         """Save a snapshot of file content and cursor position."""
    #         try:
    #             if not hasattr(text_widget, 'get'):
    #                 return  # Not a text widget, skip

    #             # Get file content
    content = text_widget.get('1.0', 'end-1c')  # Get all text except final newline

    #             # Get cursor position
    #             try:
    cursor_index = text_widget.index('insert')
    #             except:
    cursor_index = "1.0"

    #             # Calculate file hash for change detection
    file_hash = hashlib.md5(content.encode('utf-8')).hexdigest()

    #             # Check if content has changed
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT file_hash FROM session_files
    WHERE session_id = ? AND file_path = ?
                ''', (self.session_id, file_path))

    existing = cursor.fetchone()
                conn.close()

    #             # Only save if content has changed
    #             if not existing or existing[0] != file_hash:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                    cursor.execute('''
    #                     INSERT OR REPLACE INTO session_files
                        (id, session_id, file_path, file_hash, file_content, cursor_position, tab_order)
                        VALUES (?, ?, ?, ?, ?, ?, ?)
                    ''', (
                        self._generate_id("file_"),
    #                     self.session_id,
    #                     file_path,
    #                     file_hash,
    #                     content,
    #                     cursor_index,
    #                     tab_order
    #                 ))

                    conn.commit()
                    conn.close()
                    logger.debug(f"Saved file snapshot: {file_path}")

    #         except Exception as e:
                logger.error(f"Error saving file snapshot {file_path}: {str(e)}")

    #     def save_search_history(self, query: str, file_pattern: str = None, results_summary: str = None):
    #         """Save search history entry."""
    #         if not self.session_id:
    #             return

    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 INSERT INTO search_history
                    (session_id, query, file_pattern, results_summary)
                    VALUES (?, ?, ?, ?)
                ''', (self.session_id, query, file_pattern, results_summary))

                conn.commit()
                conn.close()

    #             # Also update session data
    session_data = self._load_session_data()
    #             if session_data:
    search_history = session_data.get("search_history", [])
    search_entry = {
    #                     "query": query,
    #                     "file_pattern": file_pattern,
                        "timestamp": datetime.now().isoformat()
    #                 }
                    search_history.insert(0, search_entry)
    session_data["search_history"] = search_history[:50]  # Keep last 50
                    self._save_session_data(session_data)

    #         except Exception as e:
                logger.error(f"Error saving search history: {str(e)}")

    #     def save_ai_chat_history(self, messages: List[Dict], provider: str = None, model: str = None):
    #         """Save AI chat history."""
    #         if not self.session_id:
    #             return

    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 INSERT INTO ai_chat_history
                    (session_id, chat_messages, provider, model)
                    VALUES (?, ?, ?, ?)
                ''', (
    #                 self.session_id,
    json.dumps(messages, indent = 2),
    #                 provider,
    #                 model
    #             ))

                conn.commit()
                conn.close()
                logger.debug(f"Saved AI chat history: {len(messages)} messages")

    #         except Exception as e:
                logger.error(f"Error saving AI chat history: {str(e)}")

    #     def save_git_state(self, git_state: Dict):
    #         """Save current Git repository state."""
    #         if not self.session_id:
    #             return

    #         try:
    session_data = self._load_session_data()
    #             if session_data:
    session_data["git_state"] = git_state
    session_data["last_save"] = datetime.now().isoformat()
                    self._save_session_data(session_data)
                    logger.debug("Saved Git state")

    #         except Exception as e:
                logger.error(f"Error saving Git state: {str(e)}")

    #     def _load_session_data(self) -> Optional[Dict]:
    #         """Load current session data from database."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT session_data FROM ide_sessions
    WHERE id = ?
                ''', (self.session_id,))

    result = cursor.fetchone()
                conn.close()

    #             if result:
                    return json.loads(result[0])

    #             return None

    #         except Exception as e:
                logger.error(f"Error loading session data: {str(e)}")
    #             return None

    #     def load_session_state(self) -> Dict:
    #         """Load the complete IDE session state."""
    #         if not self.session_id:
                self.create_session()

    #         try:
    #             # Load basic session data
    session_data = self._load_session_data() or {}

    #             # Load file snapshots
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT file_path, file_content, cursor_position, tab_order
    #                 FROM session_files
    WHERE session_id = ?
    #                 ORDER BY tab_order
                ''', (self.session_id,))

    file_snapshots = cursor.fetchall()
                conn.close()

    #             # Load search history
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT query, file_pattern, results_summary, searched_at
    #                 FROM search_history
    WHERE session_id = ? OR session_id IS NULL
    #                 ORDER BY searched_at DESC
    #                 LIMIT 50
                ''', (self.session_id,))

    search_history = cursor.fetchall()
                conn.close()

    #             # Load AI chat history
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT chat_messages, provider, model, created_at
    #                 FROM ai_chat_history
    WHERE session_id = ?
    #                 ORDER BY created_at DESC
    #                 LIMIT 1
                ''', (self.session_id,))

    chat_result = cursor.fetchone()
                conn.close()

    ai_chat_history = []
    #             if chat_result:
    #                 try:
    ai_chat_history = json.loads(chat_result[0])
    #                 except:
    #                     pass

    #             # Combine all data
    complete_state = {
    #                 "session_data": session_data,
    #                 "file_snapshots": [
    #                     {
    #                         "file_path": row[0],
    #                         "content": row[1],
    #                         "cursor_position": row[2],
    #                         "tab_order": row[3]
    #                     }
    #                     for row in file_snapshots
    #                 ],
    #                 "search_history": [
    #                     {
    #                         "query": row[0],
    #                         "file_pattern": row[1],
    #                         "results_summary": row[2],
    #                         "timestamp": row[3]
    #                     }
    #                     for row in search_history
    #                 ],
    #                 "ai_chat_history": ai_chat_history
    #             }

    #             logger.info(f"Loaded session state with {len(file_snapshots)} file snapshots")
    #             return complete_state

    #         except Exception as e:
                logger.error(f"Error loading session state: {str(e)}")
    #             return {}

    #     def get_recent_sessions(self, limit: int = 10) -> List[Dict]:
    #         """Get list of recent sessions for this project."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

                cursor.execute('''
    #                 SELECT id, name, created_at, last_modified
    #                 FROM ide_sessions
    WHERE project_path = ?
    #                 ORDER BY last_modified DESC
    #                 LIMIT ?
                ''', (str(self.project_root), limit))

    sessions = cursor.fetchall()
                conn.close()

    #             return [
    #                 {
    #                     "id": row[0],
    #                     "name": row[1],
    #                     "created_at": row[2],
    #                     "last_modified": row[3]
    #                 }
    #                 for row in sessions
    #             ]

    #         except Exception as e:
                logger.error(f"Error getting recent sessions: {str(e)}")
    #             return []

    #     def switch_session(self, session_id: str):
    #         """Switch to a different session."""
    #         with self._lock:
    self.session_id = session_id
    self.is_dirty = False
                logger.info(f"Switched to session: {session_id}")

    #     def cleanup_old_sessions(self, keep_count: int = 20):
    #         """Clean up old sessions, keeping only the most recent ones."""
    #         try:
    conn = sqlite3.connect(str(self.db_path), timeout=30.0)
    cursor = conn.cursor()

    #             # Get sessions to delete
                cursor.execute('''
    #                 SELECT id FROM ide_sessions
    WHERE project_path = ?
    #                 ORDER BY last_modified DESC
    #                 OFFSET ?
                ''', (str(self.project_root), keep_count))

    #             sessions_to_delete = [row[0] for row in cursor.fetchall()]

    #             # Delete old sessions
    #             for session_id in sessions_to_delete:
    cursor.execute('DELETE FROM ide_sessions WHERE id = ?', (session_id,))
    cursor.execute('DELETE FROM session_files WHERE session_id = ?', (session_id,))
    cursor.execute('DELETE FROM workspace_snapshots WHERE session_id = ?', (session_id,))
    cursor.execute('DELETE FROM search_history WHERE session_id = ?', (session_id,))
    cursor.execute('DELETE FROM ai_chat_history WHERE session_id = ?', (session_id,))

                conn.commit()
                conn.close()

    #             if sessions_to_delete:
                    logger.info(f"Cleaned up {len(sessions_to_delete)} old sessions")

    #         except Exception as e:
                logger.error(f"Error cleaning up old sessions: {str(e)}")

    #     def export_session(self, export_path: str):
    #         """Export current session to a JSON file."""
    #         try:
    state = self.load_session_state()

    #             with open(export_path, 'w', encoding='utf-8') as f:
    json.dump(state, f, indent = 2, ensure_ascii=False)

                logger.info(f"Session exported to: {export_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Error exporting session: {str(e)}")
    #             return False

    #     def import_session(self, import_path: str, session_name: str = "Imported Session"):
    #         """Import session from a JSON file."""
    #         try:
    #             with open(import_path, 'r', encoding='utf-8') as f:
    state = json.load(f)

    #             # Create new session
                self.create_session(session_name)

                # Restore state (implementation would depend on IDE integration)
                logger.info(f"Session imported from: {import_path}")
    #             return True

    #         except Exception as e:
                logger.error(f"Error importing session: {str(e)}")
    #             return False

# Global instance for IDE integration
_session_manager = None

def get_session_manager(project_root: Path = None) -> IDESessionPersistence:
#     """Get the global session manager instance."""
#     global _session_manager
#     if _session_manager is None:
_session_manager = IDESessionPersistence(project_root)
#     return _session_manager

if __name__ == "__main__"
    #     # Test the session persistence system
    session_mgr = IDESessionPersistence()
        session_mgr.create_session("Test Session")

    #     # Test saving state
        session_mgr.save_window_state("1200x800", "normal",
    #                                   {"file_explorer": True, "terminal": True},
    #                                   {"file_explorer_width": 300})

    #     # Test loading state
    state = session_mgr.load_session_state()
        print("Session state loaded successfully")
        print(f"Session data keys: {list(state.keys())}")