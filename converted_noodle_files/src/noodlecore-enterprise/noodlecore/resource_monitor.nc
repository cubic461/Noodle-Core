# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Resource Monitor Module

# This module provides resource monitoring for NBC runtime,
# re-exported from noodlecore.runtime.nbc_runtime.distributed.resource_monitor for backward compatibility.
# """

try
    #     # Import from noodlecore
    #     from noodlecore.runtime.nbc_runtime.distributed.resource_monitor import ResourceMonitor

    __all__ = [
    #         "ResourceMonitor",
    #     ]

except ImportError
    #     # Fallback stub implementations
    #     import warnings
        warnings.warn("Could not import resource monitor from noodlecore, using stub implementations")

    #     import os
    #     try:
    #         import psutil
    PSUTIL_AVAILABLE = True
    #     except ImportError:
    PSUTIL_AVAILABLE = False

    #     class ResourceMonitor:
    #         """Resource monitor stub implementation."""

    #         def __init__(self):
    #             pass

    #         def get_memory_usage(self) -> float:
    #             """Get current memory usage in MB."""
    #             if PSUTIL_AVAILABLE:
    process = psutil.Process(os.getpid())
                    return process.memory_info().rss / 1024 / 1024
    #             else:
    #                 # Fallback if psutil is not available
    #                 return 100.0  # Return a dummy value

    __all__ = [
    #         "ResourceMonitor",
    #     ]