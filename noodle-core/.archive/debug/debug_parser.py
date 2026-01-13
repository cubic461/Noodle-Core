#!/usr/bin/env python3
"""
Noodle Core::Debug Parser - debug_parser.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to trace the parser execution
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

# Import directly from the modules
from enhanced_parser import EnhancedParser

def debug_parser():
    """Debug the parser for the test input"""
    source = """
def identity<T: Comparable>(value: T): T {
    return value;
}
"""
    
    parser = EnhancedParser(source, "test")
    
    # Override the error method to print more info
    original_error = parser.error
    def debug_error(message, location=None):
        if location is None:
            token = parser._current_token()
            location = token.location
        print(f"Current token: {parser._current_token().type.value}('{parser._current_token().value}') at {parser._current_token().location}")
        print(f"Position: {parser.position}")
        print(f"Tokens before: {[t.type.value for t in parser.tokens[:parser.position]]}")
        print(f"Tokens after: {[t.type.value for t in parser.tokens[parser.position:parser.position+5]]}")
        return original_error(message, location)
    
    parser.error = debug_error
    
    try:
        ast = parser.parse()
        print("Parsing successful!")
        print(f"Errors: {len(parser.errors)}")
        if parser.errors:
            for error in parser.errors:
                print(f"  - {error.message}")
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    debug_parser()

