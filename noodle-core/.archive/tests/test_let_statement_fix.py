#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_let_statement_fix.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script to verify the LetStatementNode fix.
This script tests that the LetStatementNode can be imported and used correctly.
"""

import sys
import os

# Add the noodle-core src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_let_statement_import():
    """Test that LetStatementNode can be imported successfully"""
    try:
        from noodlecore.compiler.ast_nodes import (
            LetStatementNode, EnhancedLetStatementNode, 
            NodeType, SourceLocation
        )
        print("âœ“ Successfully imported LetStatementNode and EnhancedLetStatementNode")
        return True
    except ImportError as e:
        print(f"âœ— Import failed: {e}")
        return False

def test_let_statement_creation():
    """Test that LetStatementNode can be created with the expected interface"""
    try:
        from noodlecore.compiler.ast_nodes import (
            LetStatementNode, EnhancedLetStatementNode, 
            NodeType, SourceLocation
        )
        
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
        assert basic_node.generic_parameters == []
        print("âœ“ Basic LetStatementNode created successfully")
        
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
        assert enhanced_node.generic_parameters == ["T", "U"]
        assert enhanced_node.is_typed() == True
        assert enhanced_node.is_initialized() == False
        assert enhanced_node.has_generics() == True
        print("âœ“ EnhancedLetStatementNode created successfully")
        
        return True
    except Exception as e:
        print(f"âœ— Creation failed: {e}")
        return False

def test_parser_compatibility():
    """Test that the nodes work with the parser"""
    try:
        from noodlecore.compiler.ast_nodes import (
            LetStatementNode, EnhancedLetStatementNode, 
            NodeType, SourceLocation
        )
        
        # Test that the parser can access the generic_parameters attribute
        location = SourceLocation("test", 1, 1, 0)
        node = EnhancedLetStatementNode(
            name="test",
            type_annotation=None,
            initializer=None,
            location=location,
            generic_parameters=["T"]
        )
        
        # This should not raise an AttributeError
        generics = node.generic_parameters
        assert generics == ["T"]
        print("âœ“ Parser compatibility test passed")
        
        return True
    except Exception as e:
        print(f"âœ— Parser compatibility test failed: {e}")
        return False

def main():
    """Run all tests"""
    print("Testing LetStatementNode fix...")
    print("=" * 50)
    
    tests = [
        test_let_statement_import,
        test_let_statement_creation,
        test_parser_compatibility
    ]
    
    passed = 0
    total = len(tests)
    
    for test in tests:
        if test():
            passed += 1
        print()
    
    print("=" * 50)
    print(f"Results: {passed}/{total} tests passed")
    
    if passed == total:
        print("ðŸŽ‰ All tests passed! The LetStatementNode fix is working correctly.")
        return 0
    else:
        print("âŒ Some tests failed. The fix may need additional work.")
        return 1

if __name__ == "__main__":
    sys.exit(main())

