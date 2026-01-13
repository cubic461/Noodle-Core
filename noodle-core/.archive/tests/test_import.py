#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_import.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify import issues
"""

import sys
import os

# Add src to Python path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

print("Python path:")
for p in sys.path:
    print(f"  {p}")

print("\nTesting imports...")

try:
    print("1. Testing direct import from noodlecore.ai_agents.ml_configuration_manager...")
    from noodlecore.ai_agents.ml_configuration_manager import MLConfigurationManager
    print("   SUCCESS: Direct import worked")
except ImportError as e:
    print(f"   FAILED: {e}")

try:
    print("2. Testing import via noodlecore.ai_agents...")
    import noodlecore.ai_agents
    from noodlecore.ai_agents import ml_configuration_manager
    print("   SUCCESS: Import via noodlecore.ai_agents worked")
except ImportError as e:
    print(f"   FAILED: {e}")

try:
    print("3. Testing what noodlecore.ml_configuration_manager resolves to...")
    import noodlecore.ml_configuration_manager
    print("   SUCCESS: Found noodlecore.ml_configuration_manager")
except ImportError as e:
    print(f"   FAILED: {e}")

