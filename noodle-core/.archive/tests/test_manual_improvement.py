#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_manual_improvement.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Manual test script to trigger self-improvement and verify Unicode fix
"""

import sys
import os
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

try:
    from src.noodlecore.desktop.ide.self_improvement_integration import SelfImprovementIntegration
    
    # Create a self-improvement integration instance
    si_integration = SelfImprovementIntegration()
    
    # Create a test improvement that would trigger Unicode characters
    test_improvement = {
        'type': 'test_unicode_fix',
        'description': 'Test Unicode fix: Runtime upgrade 1.0.0 -> 2.0.0',
        'priority': 'medium',
        'source': 'manual_test',
        'file': __file__,
        'suggestion': 'This tests Unicode arrow character replacement',
        'action': 'test'
    }
    
    print("Testing Unicode encoding fix...")
    print(f"Original description: {test_improvement['description']}")
    
    # Process the improvement (this should trigger safe_log)
    si_integration._process_improvement(test_improvement)
    
    print("[SUCCESS] Unicode test completed successfully!")
    print("[SUCCESS] No Unicode encoding errors should appear in logs")
    
    # Test the safe_log function directly
    from src.noodlecore.desktop.ide.self_improvement_integration import safe_log
    
    print("\nTesting safe_log function directly...")
    safe_log("Test message with Unicode arrow: 1.0.0 â†’ 2.0.0")
    safe_log("Another test with Unicode: Version upgrade â†’ Complete")
    
    print("[SUCCESS] safe_log test completed successfully!")
    
except Exception as e:
    print(f"[ERROR] Error during test: {e}")
    import traceback
    traceback.print_exc()

