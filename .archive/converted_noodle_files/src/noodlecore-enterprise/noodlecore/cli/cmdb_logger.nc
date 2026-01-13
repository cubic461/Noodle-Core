# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# CMDB Logger Module
# ------------------

# This module provides logging functionality for the NoodleCore CLI to write
all logs to the central CMDB (Configuration Management Database).

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 19-10-2025
# Location: Hellevoetsluis, Nederland
# """

import asyncio
import json
import logging
import time
import datetime.datetime
import typing.Any,

import noodlecore.database.DatabaseModule


class CMDBLogger
    #     """Logger for writing CLI operations to the CMDB."""

    #     def __init__(self, database: DatabaseModule):
    #         """Initialize the CMDB logger."""
    self.database = database
    self.logger = logging.getLogger(__name__)

    #         # Initialize CMDB tables if they don't exist
            self._init_tables()

    #     def _init_tables(self) -> None:
    #         """Initialize CMDB tables."""
    #         # Create command_logs table
            self.database.create_table("command_logs", {
    #             "id": "SERIAL PRIMARY KEY",
                "request_id": "VARCHAR(36) NOT NULL",
                "command": "VARCHAR(50) NOT NULL",
    #             "args": "JSONB",
    #             "start_time": "TIMESTAMP",
    #             "end_time": "TIMESTAMP",
    #             "duration": "FLOAT",
                "status": "VARCHAR(20)",
    #             "result": "JSONB",
    #             "created_at": "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    #         })

    #         # Create error_logs table
            self.database.create_table("error_logs", {
    #             "id": "SERIAL PRIMARY KEY",
                "request_id": "VARCHAR(36) NOT NULL",
    #             "error_code": "INTEGER NOT NULL",
    #             "message": "TEXT NOT NULL",
    #             "details": "JSONB",
    #             "stack_trace": "TEXT",
    #             "created_at": "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    #         })

    #         # Create validation_logs table
            self.database.create_table("validation_logs", {
    #             "id": "SERIAL PRIMARY KEY",
                "request_id": "VARCHAR(36) NOT NULL",
                "file_path": "VARCHAR(255) NOT NULL",
                "validation_type": "VARCHAR(50) NOT NULL",
    #             "result": "JSONB",
    #             "created_at": "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    #         })

    #         # Create ai_guard_logs table
            self.database.create_table("ai_guard_logs", {
    #             "id": "SERIAL PRIMARY KEY",
                "request_id": "VARCHAR(36) NOT NULL",
                "file_path": "VARCHAR(255) NOT NULL",
                "source": "VARCHAR(100)",
    #             "result": "JSONB",
    #             "created_at": "TIMESTAMP DEFAULT CURRENT_TIMESTAMP"
    #         })

    #     async def log_command_start(self, command: str, request_id: str,
    #                                args: Dict[str, Any]) -> None:
    #         """Log the start of a command execution."""
    log_entry = {
    #             "request_id": request_id,
    #             "command": command,
    #             "args": args,
                "start_time": datetime.now(),
    #             "status": "started"
    #         }

    #         try:
                self.database.insert_into_database("command_logs", log_entry)
                self.logger.debug(f"Logged command start: {command} (request_id: {request_id})")
    #         except Exception as e:
                self.logger.error(f"Failed to log command start: {e}")

    #     async def log_command_complete(self, command: str, request_id: str,
    #                                   result: Dict[str, Any], duration: float) -> None:
    #         """Log the completion of a command execution."""
    log_entry = {
    #             "request_id": request_id,
    #             "command": command,
                "end_time": datetime.now(),
    #             "duration": duration,
    #             "status": "completed",
    #             "result": result
    #         }

    #         try:
                self.database.insert_into_database("command_logs", log_entry)
                self.logger.debug(f"Logged command complete: {command} (request_id: {request_id})")
    #         except Exception as e:
                self.logger.error(f"Failed to log command complete: {e}")

    #     async def log_command_error(self, command: str, request_id: str,
    #                                error: Dict[str, Any], duration: float) -> None:
    #         """Log an error during command execution."""
    log_entry = {
    #             "request_id": request_id,
    #             "command": command,
                "end_time": datetime.now(),
    #             "duration": duration,
    #             "status": "error",
    #             "result": error
    #         }

    #         try:
                self.database.insert_into_database("command_logs", log_entry)
                self.logger.debug(f"Logged command error: {command} (request_id: {request_id})")
    #         except Exception as e:
                self.logger.error(f"Failed to log command error: {e}")

    #     async def log_error(self, error_code: int, message: str, request_id: str,
    details: Optional[Dict[str, Any]] = math.subtract(None), > None:)
    #         """Log an error to the CMDB."""
    log_entry = {
    #             "request_id": request_id,
    #             "error_code": error_code,
    #             "message": message,
    #             "details": details or {}
    #         }

    #         try:
                self.database.insert_into_database("error_logs", log_entry)
                self.logger.debug(f"Logged error: {error_code} (request_id: {request_id})")
    #         except Exception as e:
                self.logger.error(f"Failed to log error: {e}")

    #     async def log_validation_result(self, request_id: str, file_path: str,
    #                                    validation_type: str, result: Dict[str, Any]) -> None:
    #         """Log a validation result to the CMDB."""
    log_entry = {
    #             "request_id": request_id,
    #             "file_path": file_path,
    #             "validation_type": validation_type,
    #             "result": result
    #         }

    #         try:
                self.database.insert_into_database("validation_logs", log_entry)
    #             self.logger.debug(f"Logged validation result: {validation_type} for {file_path}")
    #         except Exception as e:
                self.logger.error(f"Failed to log validation result: {e}")

    #     async def log_ai_guard_result(self, request_id: str, file_path: str,
    #                                  source: Optional[str], result: Dict[str, Any]) -> None:
    #         """Log an AI guard result to the CMDB."""
    log_entry = {
    #             "request_id": request_id,
    #             "file_path": file_path,
    #             "source": source,
    #             "result": result
    #         }

    #         try:
                self.database.insert_into_database("ai_guard_logs", log_entry)
    #             self.logger.debug(f"Logged AI guard result for {file_path}")
    #         except Exception as e:
                self.logger.error(f"Failed to log AI guard result: {e}")

    #     async def get_command_history(self, limit: int = 100,
    request_id: Optional[str] = math.subtract(None), > List[Dict[str, Any]]:)
    #         """Get command history from the CMDB."""
    #         try:
    query = "SELECT * FROM command_logs"
    params = {}

    #             if request_id:
    query + = " WHERE request_id = %(request_id)s"
    params["request_id"] = request_id

    query + = " ORDER BY created_at DESC LIMIT %(limit)s"
    params["limit"] = limit

                return self.database.execute_query(query, params)
    #         except Exception as e:
                self.logger.error(f"Failed to get command history: {e}")
    #             return []

    #     async def get_error_history(self, limit: int = 100,
    request_id: Optional[str] = math.subtract(None), > List[Dict[str, Any]]:)
    #         """Get error history from the CMDB."""
    #         try:
    query = "SELECT * FROM error_logs"
    params = {}

    #             if request_id:
    query + = " WHERE request_id = %(request_id)s"
    params["request_id"] = request_id

    query + = " ORDER BY created_at DESC LIMIT %(limit)s"
    params["limit"] = limit

                return self.database.execute_query(query, params)
    #         except Exception as e:
                self.logger.error(f"Failed to get error history: {e}")
    #             return []

    #     async def get_validation_history(self, limit: int = 100,
    file_path: Optional[str] = math.subtract(None), > List[Dict[str, Any]]:)
    #         """Get validation history from the CMDB."""
    #         try:
    query = "SELECT * FROM validation_logs"
    params = {}

    #             if file_path:
    query + = " WHERE file_path = %(file_path)s"
    params["file_path"] = file_path

    query + = " ORDER BY created_at DESC LIMIT %(limit)s"
    params["limit"] = limit

                return self.database.execute_query(query, params)
    #         except Exception as e:
                self.logger.error(f"Failed to get validation history: {e}")
    #             return []

    #     async def get_ai_guard_history(self, limit: int = 100,
    source: Optional[str] = math.subtract(None), > List[Dict[str, Any]]:)
    #         """Get AI guard history from the CMDB."""
    #         try:
    query = "SELECT * FROM ai_guard_logs"
    params = {}

    #             if source:
    query + = " WHERE source = %(source)s"
    params["source"] = source

    query + = " ORDER BY created_at DESC LIMIT %(limit)s"
    params["limit"] = limit

                return self.database.execute_query(query, params)
    #         except Exception as e:
                self.logger.error(f"Failed to get AI guard history: {e}")
    #             return []

    #     async def get_statistics(self) -> Dict[str, Any]:
    #         """Get usage statistics from the CMDB."""
    #         try:
    #             # Get command counts
    command_counts = self.database.execute_query("""
                    SELECT command, COUNT(*) as count
    #                 FROM command_logs
    #                 GROUP BY command
    #             """)

    #             # Get error counts
    error_counts = self.database.execute_query("""
                    SELECT error_code, COUNT(*) as count
    #                 FROM error_logs
    #                 GROUP BY error_code
    #             """)

    #             # Get validation success rates
    validation_stats = self.database.execute_query("""
    #                 SELECT
    #                     validation_type,
                        COUNT(*) as total,
    SUM(CASE WHEN result->>'valid' = 'true' THEN 1 ELSE 0 END) as valid_count
    #                 FROM validation_logs
    #                 GROUP BY validation_type
    #             """)

    #             # Get AI guard stats
    ai_guard_stats = self.database.execute_query("""
    #                 SELECT
    #                     source,
                        COUNT(*) as total,
    SUM(CASE WHEN result->>'action' = 'ALLOW' THEN 1 ELSE 0 END) as allowed_count
    #                 FROM ai_guard_logs
    #                 GROUP BY source
    #             """)

    #             return {
    #                 "command_counts": command_counts,
    #                 "error_counts": error_counts,
    #                 "validation_stats": validation_stats,
    #                 "ai_guard_stats": ai_guard_stats
    #             }
    #         except Exception as e:
                self.logger.error(f"Failed to get statistics: {e}")
    #             return {}

    #     async def close(self) -> None:
    #         """Close the CMDB logger."""
    #         try:
                self.database.close()
                self.logger.debug("CMDB logger closed")
    #         except Exception as e:
                self.logger.error(f"Failed to close CMDB logger: {e}")