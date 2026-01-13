# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Distributed OS module for the Noodle project.

# This module provides distributed operating system functionality including:
# - Node management
# - OS scheduling
# - Resource allocation
# - Task placement
# - Distributed execution
# """

import .node_manager.NodeManager
import .os_scheduler.OSScheduler
import .placement_engine.PlacementEngine
import .resource_allocator.ResourceAllocator

__all__ = ["NodeManager", "OSScheduler", "PlacementEngine", "ResourceAllocator"]
