#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_let_statement_direct.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Direct test script to verify the LetStatementNode fix.
This script tests only the AST nodes module directly without importing the full package.
"""

import sys
import os

# Add the noodle-core src directory to the path
sys.path.insert(0, os.path.join(os.path.dirname(__file__), 'src'))

def test_let_statement_direct():
    """Test LetStatementNode directly by importing only the ast_nodes module"""
    try:
        # Import only the AST nodes module directly, avoiding the full package
        import importlib.util
        spec = importlib.util.spec_from_file_location(
            "ast_nodes", 
            os.path.join(os.path.dirname(__file__), 'src', 'noodlecore', 'compiler', 'ast_nodes.py')
        )
        ast_nodes = importlib.util.module_from_spec(spec)
        
        # Execute the module
        spec.loader.exec_module(ast_nodes)
        
        print("âœ“ Successfully loaded ast_nodes module directly")
        
        # Test basic LetStatementNode
        location = ast_nodes.SourceLocation("test", 1, 1, 0)
        basic_node = ast_nodes.LetStatementNode(
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
        enhanced_node = ast_nodes.EnhancedLetStatementNode(
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
        
        # Test that the node can be used in serialization
        node_dict = enhanced_node.to_dict()
        assert 'generic_parameters' in node_dict
        assert node_dict['generic_parameters'] == ["T", "U"]
        print("âœ“ EnhancedLetStatementNode serialization includes generic_parameters")
        
        return True
    except Exception as e:
        print(f"âœ— Test failed: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run the test"""
    print("Testing LetStatementNode fix (direct module load)...")
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

