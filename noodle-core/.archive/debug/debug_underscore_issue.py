#!/usr/bin/env python3
"""
Noodle Core::Debug Underscore Issue - debug_underscore_issue.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Debug script to understand the underscore token handling issue.
"""

import sys
import os

# Add noodle-core directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler'))

from enhanced_parser import EnhancedParser

def debug_underscore_issue():
    """Debug underscore token handling issue"""
    
    # Simple test case with underscore pattern
    code = """
    match x {
        _ => "wildcard"
    }
    """
    
    print("Code:", code.strip())
    
    try:
        parser = EnhancedParser(code)
        
        # Print tokens for debugging
        print("\nTokens:")
        for i, token in enumerate(parser.tokens):
            print(f"  {i}: {token.type.value} = '{token.value}'")
        
        # Try to parse
        ast = parser.parse()
        
        if parser.errors:
            print("\nErrors:")
            for error in parser.errors:
                print(f"  {error}")
        else:
            print("\nâœ“ Parsed successfully")
            print("AST:", ast.to_dict())
    except Exception as e:
        print(f"âœ— Failed with exception: {e}")

if __name__ == "__main__":
    debug_underscore_issue()

