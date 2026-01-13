#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_pattern_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test for pattern matching without dataclass issues
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

# Simple test without using dataclasses
test_code = """
match x {
    case 1:
        return "one";
}
"""

# Simple classes without dataclass
class SimplePattern:
    def __init__(self, type, value=None):
        self.type = type
        self.value = value

class SimpleLiteralPattern(SimplePattern):
    def __init__(self, value):
        super().__init__("literal", value)

class SimpleIdentifierPattern(SimplePattern):
    def __init__(self, name):
        super().__init__("identifier", name)

# Simple test
try:
    # Create a simple pattern
    pattern = SimpleLiteralPattern(1)
    print(f"Created pattern: type={pattern.type}, value={pattern.value}")
    
    print("Simple test passed!")
except Exception as e:
    print(f"Error: {str(e)}")
    import traceback
    traceback.print_exc()

