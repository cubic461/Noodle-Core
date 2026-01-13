#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_simple_ast_nodes.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test for enhanced AST nodes
"""

import sys
from pathlib import Path

# Add the noodle-core path to sys.path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

def test_basic_ast_nodes():
    """Test basic AST node creation"""
    print("Testing basic AST node creation...")
    
    try:
        # Import just the basic components we need
        from src.noodlecore.compiler.ast_nodes import (
            EnhancedProgramNode, EnhancedLetStatementNode, EnhancedBinaryExpressionNode, 
            EnhancedFunctionCallNode, EnhancedIdentifierNode, EnhancedNumberLiteralNode, 
            EnhancedStringLiteralNode, EnhancedBooleanLiteralNode, EnhancedExpressionStatementNode, 
            SourceLocation
        )
        
        # Create simple location
        location = SourceLocation("test.nc", 1, 1, 0)
        
        # Create some basic nodes
        num_node = EnhancedNumberLiteralNode(42, location)
        str_node = EnhancedStringLiteralNode("hello", location)
        bool_node = EnhancedBooleanLiteralNode(True, location)
        ident_node = EnhancedIdentifierNode("x", location)
        
        # Create binary expression
        add_expr = EnhancedBinaryExpressionNode("+", num_node, str_node, location)
        
        # Create function call
        print_call = EnhancedFunctionCallNode("print", [add_expr], location)
        
        # Create expression statement
        expr_stmt = EnhancedExpressionStatementNode(print_call, location)
        
        # Create program
        program = EnhancedProgramNode([expr_stmt], location)
        
        # Test serialization
        ast_dict = program.to_dict()
        print(f"Successfully created AST with {len(program.statements)} statements")
        print(f"AST serialization: {ast_dict}")
        
        return True
    except Exception as e:
        print(f"Error creating AST nodes: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """Run test"""
    print("Testing Enhanced AST Nodes")
    print("=" * 40)
    
    if test_basic_ast_nodes():
        print("Basic AST node test passed!")
        return 0
    else:
        print("Basic AST node test failed!")
        return 1

if __name__ == '__main__':
    sys.exit(main())

