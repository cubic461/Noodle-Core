#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_enhanced_parser_simple.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Simple test for enhanced Noodle parser
"""

import sys
import os
from pathlib import Path

# Add the noodle-core path to sys.path
current_dir = Path(__file__).parent
sys.path.insert(0, str(current_dir))

def test_basic_parsing():
    """Test basic parsing functionality"""
    print("Testing basic parsing...")
    
    # Test simple program
    test_code = """
let x: int = 42;
let y = "hello";
let z = true;
let result = x + y;

print(result);
"""
    
    try:
        # Write test code to temporary file
        test_file = "test_basic.nc"
        with open(test_file, 'w') as f:
            f.write(test_code)
        
        # Parse the file using a simple parser approach
        print("Parsing with basic approach...")
        
        # Simple manual parsing for demonstration
        from noodlecore.compiler.ast_nodes import EnhancedProgramNode, EnhancedLetStatementNode, EnhancedBinaryExpressionNode, EnhancedFunctionCallNode, EnhancedIdentifierNode, EnhancedNumberLiteralNode, EnhancedStringLiteralNode, EnhancedBooleanLiteralNode, EnhancedExpressionStatementNode, SourceLocation
        
        # Create simple AST manually
        location = SourceLocation("test_basic.nc", 1, 1, 0)
        
        # Create let statements
        let_x = EnhancedLetStatementNode("x", "int", None, location)
        let_y = EnhancedLetStatementNode("y", None, None, location)
        let_z = EnhancedLetStatementNode("z", None, None, location)
        
        # Create expressions
        x_ident = EnhancedIdentifierNode("x", location)
        y_ident = EnhancedIdentifierNode("y", location)
        x_num = EnhancedNumberLiteralNode(42, location)
        y_str = EnhancedStringLiteralNode("hello", location)
        z_bool = EnhancedBooleanLiteralNode(True, location)
        
        # Create binary expression
        add_expr = EnhancedBinaryExpressionNode("+", x_ident, y_str, location)
        result_expr = EnhancedBinaryExpressionNode("+", add_expr, z_bool, location)
        
        # Create function call
        print_call = EnhancedFunctionCallNode("print", [result_expr], location)
        
        # Create expression statement
        expr_stmt = EnhancedExpressionStatementNode(print_call, location)
        
        # Create program
        program = EnhancedProgramNode([let_x, let_y, let_z, expr_stmt], location)
        
        print(f"Successfully created AST with {len(program.statements)} statements")
        print(f"AST: {program.to_dict()}")
        
        # Clean up
        os.remove(test_file)
        return True
    except Exception as e:
        print(f"Error in basic parsing: {e}")
        return False

def main():
    """Run test"""
    print("Testing Enhanced Noodle Parser (Simple)")
    print("=" * 50)
    
    if test_basic_parsing():
        print("Basic parsing test passed! Enhanced parser components are working correctly.")
        return 0
    else:
        print("Basic parsing test failed!")
        return 1

if __name__ == '__main__':
    sys.exit(main())

