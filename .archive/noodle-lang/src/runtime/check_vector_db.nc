# Converted from Python to NoodleCore
# Original file: src

#!/usr/bin/env python3
# """
# Script to check the status of the vector database indexing process.
# """

import sqlite3
import os
import pathlib.Path

function check_vector_db_status()
    #     """Check the status of the vector database."""
    db_path = Path(".noodle_vector_db.sqlite")

    #     if not db_path.exists():
            print("Vector database does not exist.")
    #         return

    #     try:
    conn = sqlite3.connect(str(db_path))
    cursor = conn.cursor()

    #         # Get total number of files
            cursor.execute("SELECT COUNT(*) FROM file_vectors")
    total_indexed = cursor.fetchone()[0]
            print(f"Total files indexed: {total_indexed}")

    #         # Get the last indexed file
            cursor.execute("SELECT file_path, indexed_at FROM file_vectors ORDER BY indexed_at DESC LIMIT 1")
    last_file = cursor.fetchone()
    #         if last_file:
                print(f"Last indexed file: {last_file[0]} at {last_file[1]}")

    #         # Check if there's a progress indicator in the log
    log_path = Path("setup_vector_db.log")
    #         if log_path.exists():
    #             with open(log_path, 'r') as f:
    lines = f.readlines()
    #                 if lines:
    last_line = lines[ - 1].strip()
                        print(f"Last log entry: {last_line}")

            conn.close()

    #     except Exception as e:
            print(f"Error checking database: {str(e)}")

if __name__ == "__main__"
        check_vector_db_status()