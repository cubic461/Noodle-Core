#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_unicode_fixes.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify Unicode encoding fixes in self_improvement_integration.py
"""

import sys
import os
from pathlib import Path

# Add the noodle-core directory to path for imports
noodle_core_path = Path(__file__).parent
if str(noodle_core_path) not in sys.path:
    sys.path.insert(0, str(noodle_core_path))

# Import the safe functions from the self-improvement integration
from src.noodlecore.desktop.ide.self_improvement_integration import safe_print, safe_log
import logging

def test_unicode_fixes():
    """Test the Unicode-safe print and log functions."""
    safe_print("Testing Unicode encoding fixes...")
    
    # Test cases with various Unicode characters
    test_messages = [
        "âœ… Test passed - checkmark",
        "ðŸ” Searching for improvements - magnifying glass", 
        "ðŸš€ Performance optimization - rocket",
        "ðŸ’¡ AI suggestion - light bulb",
        "ðŸ”§ Conversion complete - wrench",
        "ðŸŒŸ New feature detected - star",
        "âš¡ Speed improvement - lightning",
        "ðŸŽ¯ Target achieved - target",
        "ðŸ“ Code analysis - memo",
        "ðŸ“Š Performance metrics - bar chart",
        "Normal ASCII text without emojis",
        "Mixed text with some special chars: cafÃ© naÃ¯ve rÃ©sumÃ©"
    ]
    
    safe_print("\n=== Testing safe_print function ===")
    for i, message in enumerate(test_messages, 1):
        safe_print(f"\nTest {i}: {message}")
        try:
            safe_print(f"safe_print: {message}")
            safe_print("âœ“ safe_print succeeded")
        except Exception as e:
            safe_print(f"âœ— safe_print failed: {e}")
    
    safe_print("\n=== Testing safe_log function ===")
    for i, message in enumerate(test_messages, 1):
        safe_print(f"\nTest {i}: {message}")
        try:
            safe_log(f"safe_log: {message}")
            safe_print("âœ“ safe_log succeeded")
        except Exception as e:
            safe_print(f"âœ— safe_log failed: {e}")
    
    safe_print("\n=== Testing with problematic Unicode characters ===")
    problematic_chars = [
        "\u2705",  # White heavy check mark (âœ…)
        "\u1F50D",  # Magnifying glass tilted left (ðŸ”)
        "\u1F680",  # Rocket (ðŸš€)
        "\u1F4A1",  # Light bulb (ðŸ’¡)
        "\u1F527",  # Wrench (ðŸ”§)
        "\u1F31F",  # Glowing star (ðŸŒŸ)
        "\u26A1",   # High voltage sign (âš¡)
        "\u1F3AF",  # Direct hit (ðŸŽ¯)
        "\u1F4DD",  # Memo (ðŸ“)
        "\u1F4CA",  # Bar chart (ðŸ“Š)
    ]
    
    for char in problematic_chars:
        test_msg = f"Testing character: {char}"
        safe_print(f"\nTesting: {test_msg}")
        try:
            safe_print(test_msg)
            safe_log(test_msg)
            safe_print("âœ“ Both functions handled the character successfully")
        except Exception as e:
            safe_print(f"âœ— Error handling character: {e}")
    
    safe_print("\n=== Test Summary ===")
    safe_print("All Unicode encoding tests completed!")
    safe_print("The self-improvement integration should now handle Unicode characters properly on Windows systems.")

if __name__ == "__main__":
    test_unicode_fixes()

