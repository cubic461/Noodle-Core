# Converted from Python to NoodleCore
# Original file: src

# """
# Config Module for NBC Runtime
# --------------------------------
# This module contains config-related functionality for the NBC runtime.
# """

import datetime
import importlib
import inspect
import json
import math
import os
import random
import sys
from dataclasses import dataclass
import enum.Enum
import typing.Any

import numpy as np


dataclass
class NBCConfig
    #     """Configuration for NBC Runtime."""

    #     # Core runtime settings
    debug: bool = False
    security_enabled: bool = True
    allowed_modules: List[str] = field(
    default_factory = lambda: ["math", "random", "datetime", "json", "os"]
    #     )

        # Performance enhancements (Week 7)
    use_jit: bool = True  # Enable Numba JIT compilation
    use_gpu: bool = True  # Enable CuPy GPU offload
    use_cache: str = "distributed"  # 'local', 'distributed' (Redis), or 'off'
    profile: bool = True  # Enable PyInstrument profiling

    #     # Memory management
    memory_limit_mb: int = 1024
    enable_region_memory: bool = True  # Region - based memory arenas

    #     # Distributed settings
    max_connections: int = 10
    max_threads: int = 20

    #     def _init_python_ffi(self):
    #         """Initialize Python FFI environment with security checks"""
    self.python_modules = {}
    self.python_functions = {}
    #         # Import standard Python modules that are commonly used
    #         try:
    #             # Security check: only allow whitelisted modules
    #             if self.security_enabled:
    #                 for module_name in self.allowed_modules:
    #                     try:
    module = importlib.import_module(module_name)
    self.python_modules[module_name] = module

    #                         # Add safe functions from each module
    #                         if module_name == "math":
    self.python_functions["math.pi"] = module.pi
    self.python_functions["math.pow"] = module.pow
    self.python_functions["math.sqrt"] = module.sqrt
    self.python_functions["math.sin"] = module.sin
    self.python_functions["math.cos"] = module.cos
    self.python_functions["math.tan"] = module.tan
    #                         elif module_name == "random":
    self.python_functions["random.randint"] = module.randint
    self.python_functions["random.random"] = module.random
    self.python_functions["random.choice"] = module.choice
    #                         elif module_name == "datetime":
    self.python_functions["datetime.datetime.now"] = (
    #                                 module.datetime.now
    #                             )
    #                         elif module_name == "json":
    self.python_functions["json.dumps"] = module.dumps
    self.python_functions["json.loads"] = module.loads
    #                         elif module_name == "os":
    self.python_functions["os.path.exists"] = module.path.exists
    self.python_functions["os.path.join"] = module.path.join
    #                     except ImportError:
    #                         if self.debug:
                                print(f"Warning: Module {module_name} not available")
    #             else:
    #                 # Fallback to unrestricted imports if security is disabled
    #                 import math

    self.python_modules["math"] = math
    self.python_functions["math.pi"] = math.pi
    self.python_functions["math.pow"] = math.pow
    self.python_functions["math.sqrt"] = math.sqrt
    self.python_functions["math.sin"] = math.sin
    self.python_functions["math.cos"] = math.cos
    self.python_functions["math.tan"] = math.tan

    #                 import random

    self.python_modules["random"] = random
    self.python_functions["random.randint"] = random.randint
    self.python_functions["random.random"] = random.random
    self.python_functions["random.choice"] = random.choice

    #                 import datetime

    self.python_modules["datetime"] = datetime
    self.python_functions["datetime.datetime.now"] = datetime.datetime.now

    #                 import json

    self.python_modules["json"] = json
    self.python_functions["json.dumps"] = json.dumps
    self.python_functions["json.loads"] = json.loads

    #                 import os

    self.python_modules["os"] = os
    self.python_functions["os.path.exists"] = os.path.exists
    self.python_functions["os.path.join"] = os.path.join

    #         except ImportError as e:
    #             if self.debug:
                    print(f"Warning: Could not import some Python modules: {e}")
