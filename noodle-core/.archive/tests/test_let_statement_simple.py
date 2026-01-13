#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_let_statement_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test script to verify the LetStatementNode fix.
This script tests only the AST nodes directly.
"""

import sys
import os

# Add the noodle-core src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_let_statement_direct():
    """Test LetStatementNode directly without full module imports"""
    try:
        # Import only the AST nodes module directly
        from noodlecore.compiler.ast_nodes import (
            LetStatementNode, EnhancedLetStatementNode, 
            NodeType, SourceLocation
        )
        print("âœ“ Successfully imported LetStatementNode and EnhancedLetStatementNode")
        
        # Test basic LetStatementNode
        location = SourceLocation("test", 1, 1, 0)
        basic_node = LetStatementNode(
            name="x",
            type_annotation="int",
            initializer=None,
            generic_parameters=[]
        )
        
        assert basic_node.name == "x"
        assert basic_node.type_annotation == "int"
        assert basic_node.initializer is None
        assert hasattr(basic_node, 'generic_parameters')
        assert basic_node.generic_parameters == []
        print("âœ“ Basic LetStatementNode created successfully with generic_parameters")
        
        # Test EnhancedLetStatementNode
        enhanced_node = EnhancedLetStatementNode(
            name="y",
            type_annotation="string",
            initializer=None,
            location=location,
            generic_parameters=["T", "U"]
        )
        
        assert enhanced_node.name == "y"
        assert enhanced_node.type_annotation == "string"
        assert enhanced_node.initializer is None
        assert hasattr(enhanced_node, 'generic_parameters')
        assert enhanced_node.generic_parameters == ["T", "U"]
        assert enhanced_node.is_typed() == True
        assert enhanced_node.is_initialized() == False
        assert enhanced_node.has_generics() == True
        print("âœ“ EnhancedLetStatementNode created successfully with generic_parameters")
        
        return True
    except Exception as e:
        print(f"âœ— Test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run the test"""
    print("Testing LetStatementNode fix (direct import)...")
    print("=" * 50)
    
    if test_let_statement_direct():
        print("=" * 50)
        print("ðŸŽ‰ Test passed! The LetStatementNode fix is working correctly.")
        return 0
    else:
        print("=" * 50)
        print("âŒ Test failed. The fix may need additional work.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

