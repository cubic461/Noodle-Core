# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Stub module for noodle.runtime.nbc_runtime.database - redirects to noodle.database

# This module is created to resolve import errors during the naming convention standardization.
# The actual database functionality is in noodle.database.
# """

import noodlecore.database.DatabaseConfig,
import noodlecore.database.backends.sqlite.SQLiteBackend
import noodlecore.database.transaction_manager.IsolationLevel

# Redirect all imports to the correct module
__all__ = ["DatabaseModule", "DatabaseConfig", "IsolationLevel", "SQLiteBackend"]

# Add deprecation warning
import warnings

warnings.warn(
#     "noodle.runtime.nbc_runtime.database is deprecated. Use noodle.database instead.",
#     DeprecationWarning,
# )
