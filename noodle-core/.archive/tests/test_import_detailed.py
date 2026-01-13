#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import_detailed.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Detailed import test to diagnose the ml_configuration_manager import issue
"""

import sys
import os

# Add the src directory to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

print("Python path:")
for p in sys.path[:10]:  # Show first 10 paths
    print(f"  {p}")
print("  ... (truncated)")

print("\n" + "="*50)
print("Testing basic noodlecore import...")
try:
    import noodlecore
    print("SUCCESS: Basic noodlecore import works")
    print(f"noodlecore.__file__: {noodlecore.__file__}")
except Exception as e:
    print(f"FAILED: Basic noodlecore import failed: {e}")

print("\n" + "="*50)
print("Testing noodlecore.ai_agents import...")
try:
    import noodlecore.ai_agents
    print("SUCCESS: noodlecore.ai_agents import works")
    print(f"noodlecore.ai_agents.__file__: {noodlecore.ai_agents.__file__}")
except Exception as e:
    print(f"FAILED: noodlecore.ai_agents import failed: {e}")

print("\n" + "="*50)
print("Testing noodlecore.ai_agents.ml_configuration_manager import...")
try:
    import noodlecore.ai_agents.ml_configuration_manager
    print("SUCCESS: Direct import from noodlecore.ai_agents.ml_configuration_manager works")
    print(f"noodlecore.ai_agents.ml_configuration_manager.__file__: {noodlecore.ai_agents.ml_configuration_manager.__file__}")
except Exception as e:
    print(f"FAILED: Direct import from noodlecore.ai_agents.ml_configuration_manager failed: {e}")

print("\n" + "="*50)
print("Testing MLConfigurationManager class import from noodlecore.ai_agents...")
try:
    from noodlecore.ai_agents import MLConfigurationManager
    print("SUCCESS: MLConfigurationManager class import from noodlecore.ai_agents works")
    print(f"MLConfigurationManager: {MLConfigurationManager}")
except Exception as e:
    print(f"FAILED: MLConfigurationManager class import from noodlecore.ai_agents failed: {e}")

print("\n" + "="*50)
print("Testing MLConfigurationManager class import from noodlecore...")
try:
    from noodlecore import MLConfigurationManager
    print("SUCCESS: MLConfigurationManager class import from noodlecore works")
    print(f"MLConfigurationManager: {MLConfigurationManager}")
except Exception as e:
    print(f"FAILED: MLConfigurationManager class import from noodlecore failed: {e}")

print("\n" + "="*50)
print("Testing noodlecore.ml_configuration_manager import (the failing one)...")
try:
    import noodlecore.ml_configuration_manager
    print("SUCCESS: Import noodlecore.ml_configuration_manager works")
    print(f"noodlecore.ml_configuration_manager.__file__: {noodlecore.ml_configuration_manager.__file__}")
except Exception as e:
    print(f"FAILED: Import noodlecore.ml_configuration_manager failed: {e}")

print("\n" + "="*50)
print("Checking noodlecore.__dict__ for MLConfigurationManager...")
try:
    import noodlecore
    if 'MLConfigurationManager' in noodlecore.__dict__:
        print("SUCCESS: MLConfigurationManager found in noodlecore.__dict__")
        print(f"noodlecore.MLConfigurationManager: {noodlecore.MLConfigurationManager}")
    else:
        print("FAILED: MLConfigurationManager not found in noodlecore.__dict__")
        print("Available keys in noodlecore.__dict__:")
        for key in sorted(noodlecore.__dict__.keys()):
            if not key.startswith('_'):
                print(f"  {key}")
except Exception as e:
    print(f"FAILED: Checking noodlecore.__dict__ failed: {e}")

print("\n" + "="*50)
print("Checking noodlecore.ai_agents.__dict__ for MLConfigurationManager...")
try:
    import noodlecore.ai_agents
    if 'MLConfigurationManager' in noodlecore.ai_agents.__dict__:
        print("SUCCESS: MLConfigurationManager found in noodlecore.ai_agents.__dict__")
        print(f"noodlecore.ai_agents.MLConfigurationManager: {noodlecore.ai_agents.MLConfigurationManager}")
    else:
        print("FAILED: MLConfigurationManager not found in noodlecore.ai_agents.__dict__")
        print("Available keys in noodlecore.ai_agents.__dict__:")
        for key in sorted(noodlecore.ai_agents.__dict__.keys()):
            if not key.startswith('_'):
                print(f"  {key}")
except Exception as e:
    print(f"FAILED: Checking noodlecore.ai_agents.__dict__ failed: {e}")

