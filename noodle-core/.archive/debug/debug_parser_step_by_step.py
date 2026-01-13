#!/usr/bin/env python3
"""
Noodle Core::Debug Parser Step By Step - debug_parser_step_by_step.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to step through the parser and see what's happening.
"""

import sys
import os

# Add noodle-core directory to path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def debug_parser_step_by_step():
    """Debug parser step by step"""
    code = """
    match x {
        _ => "wildcard",
        1 => "one"
    }
    """
    
    parser = EnhancedParser(code, "<test>")
    
    print("Starting parse...")
    print(f"Tokens: {[(t.type.value, t.value) for t in parser.tokens]}")
    
    # Try to parse the match expression
    try:
        ast = parser.parse()
        print(f"Parse completed with {len(parser.errors)} errors")
        if parser.errors:
            for error in parser.errors:
                print(f"  Error: {error}")
    except Exception as e:
        print(f"Exception during parsing: {e}")

if __name__ == "__main__":
    debug_parser_step_by_step()

