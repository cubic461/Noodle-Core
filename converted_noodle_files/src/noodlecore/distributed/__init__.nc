# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NoodleCore Distributed AI Task Management System

# This module provides distributed AI coordination capabilities using NoodleCore's
# native architecture including NBC runtime, actor model, and matrix operations.

# Key Components:
# - Central Controller: Master coordination using NBC runtime
# - Hierarchical Task System: Matrix-based task breakdown and distribution
# - Distributed Communication: Actor model for AI coordination
# - Role Flagging System: Real-time activity tracking
# - Task Database: Persistent task management
# """

import .controller.central_controller.CentralController
import .tasks.hierarchical_task_system.HierarchicalTaskSystem
import .communication.actor_model.DistributedAICommunication
import .coordination.flag_system.RoleFlagSystem

__version__ = "1.0.0"
__all__ = [
#     "CentralController",
#     "HierarchicalTaskSystem",
#     "DistributedAICommunication",
#     "RoleFlagSystem"
# ]

# System configuration
NOODLE_DISTRIBUTED_ENABLED = True
COORDINATION_CYCLE_SECONDS = 60
STATUS_REPORT_INTERVAL_SECONDS = 300
MAX_CONCURRENT_AGENTS = 100
TASK_BREAKDOWN_TIMEOUT_MS = 100