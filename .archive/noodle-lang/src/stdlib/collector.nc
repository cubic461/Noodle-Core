# Converted from Python to NoodleCore
# Original file: src

# """
# Usage Event Collector for Adaptive Library Evolution (ALE)
# Collects and stores runtime metrics from Python FFI calls for analysis and optimization.
# """

import json
import logging
import os
import sqlite3
import time
import uuid
import pathlib.Path
import typing.Any

import ...error.secure_logger


class UsageCollector
    #     """
    #     Collects usage events from Python bridge calls and stores them in memory database.
    #     """

    #     def __init__(self, db_path: str = "memory_bank/ale_usage.db"):
    self.db_path = db_path
    #         # Remove error_handler reference as we're using secure_logger directly
            self._ensure_db_exists()

    #     def _ensure_db_exists(self):
    #         """Create database and tables if they don't exist."""
    os.makedirs(os.path.dirname(self.db_path), exist_ok = True)

    #         with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()

    #             # Create usage_events table
                cursor.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS usage_events (
    #                     id TEXT PRIMARY KEY,
    #                     timestamp REAL,
    #                     project TEXT,
    #                     call_signature TEXT,
    #                     args_json TEXT,
    #                     runtime_ms REAL,
    #                     node TEXT,
    #                     outcome TEXT,
    #                     stderr TEXT,
    #                     trace TEXT,
    #                     input_sample_id TEXT,
    #                     user_id TEXT
    #                 )
    #             """
    #             )

    #             # Create candidate_libs table
                cursor.execute(
    #                 """
                    CREATE TABLE IF NOT EXISTS candidate_libs (
    #                     id TEXT PRIMARY KEY,
    #                     call_signature TEXT,
    #                     source_code TEXT,
    #                     tests TEXT,
    #                     bench_results TEXT,
    #                     provenance TEXT,
    #                     status TEXT,
    #                     created_at REAL,
    #                     signature TEXT
    #                 )
    #             """
    #             )

                conn.commit()

    #     def log_usage_event(
    #         self,
    #         project: str,
    #         call_signature: str,
    #         args_meta: List[Dict[str, Any]],
    #         runtime_ms: float,
    node: str = "local",
    outcome: str = "success",
    stderr: str = "",
    trace: str = "",
    input_sample_id: Optional[str] = None,
    user_id: str = "local-user",
    #     ) -str):
    #         """
    #         Log a usage event to the memory database.

    #         Args:
    #             project: Project identifier
                call_signature: Function call signature (e.g., "numpy.dot")
    #             args_meta: List of argument metadata including shapes and dtypes
    #             runtime_ms: Execution time in milliseconds
    #             node: Node identifier
    #             outcome: "success" or "error"
    #             stderr: Error message if any
    #             trace: Stack trace if error
    #             input_sample_id: ID of input sample for training
    #             user_id: User identifier

    #         Returns:
    #             Event ID
    #         """
    event_id = str(uuid.uuid4())
    args_json = json.dumps(args_meta)

    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()
                    cursor.execute(
    #                     """
                        INSERT INTO usage_events (
    #                         id, timestamp, project, call_signature, args_json, runtime_ms,
    #                         node, outcome, stderr, trace, input_sample_id, user_id
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    #                 """,
                        (
    #                         event_id,
                            time.time(),
    #                         project,
    #                         call_signature,
    #                         args_json,
    #                         runtime_ms,
    #                         node,
    #                         outcome,
    #                         stderr,
    #                         trace,
    #                         input_sample_id,
    #                         user_id,
    #                     ),
    #                 )
                    conn.commit()

    #             return event_id

    #         except Exception as e:
                secure_logger(
    #                 f"Error logging usage event for {call_signature}: {str(e)}",
    #                 logging.ERROR,
    error_type = "UsageEventLoggingError",
    severity = "MEDIUM",
    #             )
    #             raise

    #     def get_frequent_calls(
    self, project: str, min_calls: int = 10, time_window_days: int = 7
    #     ) -List[str]):
    #         """
    #         Get frequently called function signatures for optimization candidates.

    #         Args:
    #             project: Project identifier
    #             min_calls: Minimum number of calls to consider
    #             time_window_days: Time window in days

    #         Returns:
    #             List of call signatures sorted by frequency
    #         """
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()

    #                 # Get call signatures with frequency count
                    cursor.execute(
    #                     """
                        SELECT call_signature, COUNT(*) as count
    #                     FROM usage_events
    WHERE project = ?
    #                     AND timestamp ?
    #                     GROUP BY call_signature
    HAVING count > = ?
    #                     ORDER BY count DESC
    #                 """,
                        (
    #                         project,
                            time.time() - (time_window_days * 24 * 60 * 60),
    #                         min_calls,
    #                     ),
    #                 )

    #                 return [row[0] for row in cursor.fetchall()]

    #         except Exception as e):
                secure_logger(
    #                 f"Error getting frequent calls for project {project}: {str(e)}",
    #                 logging.ERROR,
    error_type = "FrequentCallsError",
    severity = "MEDIUM",
    #             )
    #             return []

    #     def get_input_samples(
    self, call_signature: str, limit: int = 10
    #     ) -List[Dict[str, Any]]):
    #         """
    #         Get representative input samples for a given call signature.

    #         Args:
    #             call_signature: Function call signature
    #             limit: Maximum number of samples to return

    #         Returns:
    #             List of input sample metadata
    #         """
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()

                    cursor.execute(
    #                     """
    #                     SELECT args_json, id
    #                     FROM usage_events
    WHERE call_signature = ? AND outcome = 'success'
    #                     ORDER BY timestamp DESC
    #                     LIMIT ?
    #                 """,
                        (call_signature, limit),
    #                 )

    samples = []
    #                 for args_json, sample_id in cursor.fetchall():
                        samples.append(
                            {"args": json.loads(args_json), "sample_id": sample_id}
    #                     )

    #                 return samples

    #         except Exception as e:
                secure_logger(
    #                 f"Error getting input samples for {call_signature}: {str(e)}",
    #                 logging.ERROR,
    error_type = "InputSamplesError",
    severity = "MEDIUM",
    #             )
    #             return []

    #     def log_candidate_lib(
    #         self,
    #         call_signature: str,
    #         source_code: str,
    #         tests: Dict[str, Any],
    #         bench_results: Dict[str, Any],
    #         provenance: Dict[str, Any],
    status: str = "pending",
    #     ) -str):
    #         """
    #         Log a candidate library for optimization.

    #         Args:
    #             call_signature: Function call signature
    #             source_code: Generated Noodle source code
    #             tests: Test cases used for validation
    #             bench_results: Performance benchmark results
                provenance: Provenance information (LLM prompt, model, etc.)
                status: Candidate status (pending, failed, promoted, rolled_back)

    #         Returns:
    #             Candidate ID
    #         """
    candidate_id = str(uuid.uuid4())

    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()
                    cursor.execute(
    #                     """
                        INSERT INTO candidate_libs (
    #                         id, call_signature, source_code, tests, bench_results,
    #                         provenance, status, created_at, signature
                        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    #                 """,
                        (
    #                         candidate_id,
    #                         call_signature,
    #                         source_code,
                            json.dumps(tests),
                            json.dumps(bench_results),
                            json.dumps(provenance),
    #                         status,
                            time.time(),
    #                         "",
    #                     ),
    #                 )
                    conn.commit()

    #             return candidate_id

    #         except Exception as e:
                secure_logger(
    #                 f"Error logging candidate library for {call_signature}: {str(e)}",
    #                 logging.ERROR,
    error_type = "CandidateLibraryLoggingError",
    severity = "MEDIUM",
    #             )
    #             raise

    #     def get_candidate_status(self, candidate_id: str) -Optional[str]):
    #         """
    #         Get the status of a candidate library.

    #         Args:
    #             candidate_id: Candidate library ID

    #         Returns:
    #             Status string or None if not found
    #         """
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()
                    cursor.execute(
    "SELECT status FROM candidate_libs WHERE id = ?", (candidate_id,)
    #                 )
    result = cursor.fetchone()
    #                 return result[0] if result else None

    #         except Exception as e:
                secure_logger(
    #                 f"Error getting candidate status for {candidate_id}: {str(e)}",
    #                 logging.ERROR,
    error_type = "CandidateStatusError",
    severity = "MEDIUM",
    #             )
    #             return None

    #     def update_candidate_status(
    self, candidate_id: str, status: str, signature: str = ""
    #     ) -bool):
    #         """
    #         Update the status of a candidate library.

    #         Args:
    #             candidate_id: Candidate library ID
    #             status: New status
    #             signature: Cryptographic signature if promoted

    #         Returns:
    #             True if updated successfully
    #         """
    #         try:
    #             with sqlite3.connect(self.db_path) as conn:
    cursor = conn.cursor()
                    cursor.execute(
    #                     """
    #                     UPDATE candidate_libs
    SET status = ?, signature = ?
    WHERE id = ?
    #                 """,
                        (status, signature, candidate_id),
    #                 )
                    conn.commit()

    #                 return cursor.rowcount 0

    #         except Exception as e):
                secure_logger(
    #                 f"Error updating candidate status for {candidate_id}: {str(e)}",
    #                 logging.ERROR,
    error_type = "CandidateStatusUpdateError",
    severity = "MEDIUM",
    #             )
    #             return False


# Global instance
collector = UsageCollector()
