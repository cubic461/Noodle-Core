#!/usr/bin/env python3
"""
Noodle Lang::Nbc Generator - nbc_generator.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NBC Code Generator - AST naar NBC Bytecode

Deze module converteert de AST (van de parser) naar NBC bytecode
dat uitgevoerd kan worden door de NBC VM.

Componenten:
1. NBCGenerator - Hoofd generator class
2. SymbolTable - Variable/function tracking
3. LabelManager - Spring-adres beheer
4. ConstantPool - Constante optimalisatie

Architectuur:
parse_tree â†’ AST â†’ NBCGenerator â†’ NBCBytecode â†’ NBCVM
"""

from dataclasses import dataclass
from typing import List, Dict, Any, Optional, Union
from .nbc_vm import NBCBytecode, Opcode, Instruction


@dataclass
class Symbol:
    """Symbol in symbol table"""
    name: str
    type: str  # 'variable', 'function', 'constant'
    index: int
    scope_level: int = 0


class SymbolTable:
    """Symbol table for tracking variables and functions"""
    
    def __init__(self):
        self.symbols: Dict[str, Symbol] = {}
        self.scope_level = 0
        self.next_index = 0
    
    def enter_scope(self):
        """Enter a new scope"""
        self.scope_level += 1
    
    def exit_scope(self):
        """Exit current scope"""
        self.scope_level -= 1
        # Remove symbols from exited scope
        to_remove = [name for name, symbol in self.symbols.items()
                     if symbol.scope_level > self.scope_level]
        for name in to_remove:
            del self.symbols[name]
    
    def add_symbol(self, name: str, symbol_type: str) -> int:
        """Add symbol to table"""
        index = self.next_index
        self.next_index += 1
        symbol = Symbol(name, symbol_type, index, self.scope_level)
        self.symbols[name] = symbol
        return index
    
    def get_symbol(self, name: str) -> Optional[Symbol]:
        """Get symbol from table"""
        return self.symbols.get(name)
    
    def has_symbol(self, name: str) -> bool:
        """Check if symbol exists"""
        return name in self.symbols


class LabelManager:
    """Manages labels for control flow"""
    
    def __init__(self):
        self.label_counter = 0
        self.labels: Dict[str, int] = {}
        self.next_labels: List[str] = []
    
    def create_label(self, prefix: str = "label") -> str:
        """Create a new unique label"""
        label = f"{prefix}_{self.label_counter}"
        self.label_counter += 1
        return label
    
    def set_label_position(self, label: str, position: int):
        """Set label at current position"""
        self.labels[label] = position
    
    def get_label_position(self, label: str) -> int:
        """Get position of label"""
        return self.labels.get(label, -1)
    
    def add_next_label(self, label: str):
        """Add label to be set at next instruction"""
        self.next_labels.append(label)
    
    def process_next_labels(self, position: int):
        """Set next labels at current position"""
        for label in self.next_labels:
            self.set_label_position(label, position)
        self.next_labels.clear()


class NBCGenerator:
    """
    Generate NBC bytecode from AST (abstract syntax tree)
    
    The generator walks the AST and emits corresponding NBC instructions
    """
    
    def __init__(self):
        self.symbol_table = SymbolTable()
        self.branch_placeholder = []
        self.current_bytecode = None
    
    def generate(self, ast: dict) -> NBCBytecode:
        """
        Generate NBC bytecode from AST
        
        Args:
            ast: Abstract syntax tree from parser
            
        Returns:
            NBCBytecode ready for execution
        """
        if not ast or 'statements' not in ast:
            raise ValueError("Invalid AST: no statements found")
        
        self.current_bytecode = NBCBytecode()
        self.branch_placeholder = []
        
        # Enter global scope
        self.symbol_table.enter_scope()
        
        try:
            # Generate code for each statement
            self._generate_statements(ast['statements'])
            
            # If no explicit return, add implicit None return
            if not self._has_explicit_return(ast['statements']):
                none_index = self.current_bytecode.add_constant(None)
                self._emit(Opcode.LOAD_CONST, none_index)
                self._emit(Opcode.RETURN_VALUE)
        
        finally:
            self.symbol_table.exit_scope()
            self.current_bytecode = None
        
        return self.current_bytecode
    
    def _generate_statements(self, statements: List[dict]):
        """Generate code for a list of statements"""
        for stmt in statements:
            self._generate_statement(stmt)
    
    def _generate_statement(self, stmt: dict):
        """Generate code for a single statement"""
        stmt_type = stmt.get('type')
        
        if stmt_type == 'function_definition':
            self._generate_function_definition(stmt)
        elif stmt_type == 'variable_declaration':
            self._generate_variable_declaration(stmt)
        elif stmt_type == 'assignment':
            self._generate_assignment(stmt)
        elif stmt_type == 'expression_statement':
            self._generate_expression(stmt.get('expression', {}))
        elif stmt_type == 'return_statement':
            self._generate_return_statement(stmt)
        elif stmt_type == 'if_statement':
            self._generate_if_statement(stmt)
        elif stmt_type == 'for_statement':
            self._generate_for_statement(stmt)
        elif stmt_type == 'while_statement':
            self._generate_while_statement(stmt)
        else:
            raise NotImplementedError(f"Statement type '{stmt_type}' not implemented")
    
    def _generate_function_definition(self, stmt: dict):
        """Generate code for function definition"""
        func_name = stmt['name']
        parameters = stmt.get('parameters', [])
        body_stmts = stmt.get('body', [])
        
        # For now, generate inline code (no separate function objects yet)
        # In the future, this would create a function object and store it
        
        param_names = [p['name'] for p in parameters]
        
        # Add function to symbol table
        func_index = self.symbol_table.add_symbol(func_name, 'function')
        
        # Generate function body in new scope
        self.symbol_table.enter_scope()
        
        # Register parameters as variables in function scope
        for param_name in param_names:
            self.symbol_table.add_symbol(param_name, 'variable')
        
        # Generate body code
        self._generate_statements(body_stmts)
        
        # If no explicit return, add implicit None return
        if not self._has_explicit_return(body_stmts):
            none_index = self.current_bytecode.add_constant(None)
            self._emit(Opcode.LOAD_CONST, none_index)
            self._emit(Opcode.RETURN_VALUE)
        
        self.symbol_table.exit_scope()
    
    def _generate_variable_declaration(self, stmt: dict):
        """Generate code for variable declaration (let x = value)"""
        var_name = stmt['name']
        value_expr = stmt.get('value')
        
        if value_expr:
            self._generate_expression(value_expr)
        else:
            none_index = self.current_bytecode.add_constant(None)
            self._emit(Opcode.LOAD_CONST, none_index)
        
        # Add variable to symbol table
        var_index = self.symbol_table.add_symbol(var_name, 'variable')
        
        # Store in bytecode names table
        name_index = self.current_bytecode.add_name(var_name)
        
        # Store value in variable
        self._emit(Opcode.STORE_NAME, name_index)
    
    def _generate_assignment(self, stmt: dict):
        """Generate code for variable assignment"""
        var_name = stmt['name']
        value_expr = stmt.get('value')
        
        if not value_expr:
            raise ValueError("Assignment requires value")
        
        # Generate value expression
        self._generate_expression(value_expr)
        
        # Lookup variable index
        name_index = self.current_bytecode.add_name(var_name)
        
        # Store in variable
        self._emit(Opcode.STORE_NAME, name_index)
    
    def _generate_return_statement(self, stmt: dict):
        """Generate code for return statement"""
        if 'value' in stmt and stmt['value']:
            self._generate_expression(stmt['value'])
        else:
            none_index = self.current_bytecode.add_constant(None)
            self._emit(Opcode.LOAD_CONST, none_index)
        
        self._emit(Opcode.RETURN_VALUE)
    
    def _generate_if_statement(self, stmt: dict):
        """Generate code for if/else statement"""
        condition = stmt['condition']
        then_body = stmt.get('body', [])
        else_body = stmt.get('else_body', [])
        
        # Generate condition
        self._generate_expression(condition)
        
        # Jump to else block if condition is false
        else_label = self._create_label()
        skip_else_label = self._create_label()
        
        # If condition true, skip else block
        self._emit(Opcode.POP_JUMP_IF_FALSE, else_label)
        
        # Generate then body
        self._generate_statements(then_body)
        
        # Jump past else block
        self._emit(Opcode.JUMP_ABSOLUTE, skip_else_label)
        
        # Else block (will be filled in when label is resolved)
        self._set_label_branch(else_label, len(self.current_bytecode.instructions))
        self._generate_statements(else_body)
        
        # End of if statement
        self._set_label_branch(skip_else_label, len(self.current_bytecode.instructions))
    
    def _generate_expression(self, expr: dict):
        """Generate code for expression"""
        if not expr:
            none_index = self.current_bytecode.add_constant(None)
            self._emit(Opcode.LOAD_CONST, none_index)
            return
        
        expr_type = expr.get('type')
        
        if expr_type == 'literal':
            self._generate_literal(expr)
        elif expr_type == 'identifier':
            self._generate_identifier(expr)
        elif expr_type == 'binary_expression':
            self._generate_binary_expression(expr)
        elif expr_type == 'function_call':
            self._generate_function_call(expr)
        else:
            raise NotImplementedError(f"Expression type '{expr_type}' not implemented")
    
    def _generate_literal(self, expr: dict):
        """Generate code for literal value"""
        value = expr.get('value')
        const_index = self.current_bytecode.add_constant(value)
        self._emit(Opcode.LOAD_CONST, const_index)
    
    def _generate_identifier(self, expr: dict):
        """Generate code for identifier lookup"""
        name = expr.get('name')
        
        # Lookup symbol
        symbol = self.symbol_table.get_symbol(name)
        if not symbol:
            raise NameError(f"Variable '{name}' not defined")
        
        # Lookup in bytecode names table
        name_index = self.current_bytecode.add_name(name)
        
        self._emit(Opcode.LOAD_NAME, name_index)
    
    def _generate_binary_expression(self, expr: dict):
        """Generate code for binary expression (a + b, a * b, etc.)"""
        left = expr.get('left')
        right = expr.get('right')
        operator = expr.get('operator')
        
        # Generate left operand
        self._generate_expression(left)
        
        # Generate right operand
        self._generate_expression(right)
        
        # Emit operation
        opcode_map = {
            '+': Opcode.BINARY_ADD,
            '-': Opcode.BINARY_SUBTRACT,
            '*': Opcode.BINARY_MULTIPLY,
            '/': Opcode.BINARY_DIVIDE,
            '%': Opcode.BINARY_MODULO,
        }
        
        opcode = opcode_map.get(operator)
        if not opcode:
            raise NotImplementedError(f"Operator '{operator}' not implemented")
        
        self._emit(opcode)
    
    def _generate_function_call(self, expr: dict):
        """Generate code for function call"""
        # For now, just generate a placeholder
        # In full implementation, this would call the function
        raise NotImplementedError("Function calls not yet implemented")
    
    def _generate_for_statement(self, stmt: dict):
        """Generate code for for loop (basic implementation)"""
        raise NotImplementedError("For loops not yet implemented")
    
    def _generate_while_statement(self, stmt: dict):
        """Generate code for while loop"""
        raise NotImplementedError("While loops not yet implemented")
    
    def _emit(self, opcode: Opcode, operand=None):
        """Emit instruction to bytecode"""
        self.current_bytecode.add_instruction(opcode, operand)
    
    def _has_explicit_return(self, statements: List[dict]) -> bool:
        """Check if statements contain explicit return"""
        for stmt in statements:
            if stmt.get('type') == 'return_statement':
                return True
            if stmt.get('type') == 'if_statement':
                # Check both branches
                if self._has_explicit_return(stmt.get('body', [])):
                    if self._has_explicit_return(stmt.get('else_body', [])):
                        return True
        return False
    
    def _create_label(self) -> str:
        """Create a label for control flow"""
        return f"label_{len(self.branch_placeholder)}"
    
    def _set_label_branch(self, label: str, position: int):
        """Set label at position (placeholder)"""
        self.branch_placeholder.append((label, position))


def generate_nbc_from_ast(ast: dict) -> NBCBytecode:
    """
    Convenience function to generate NBC bytecode from AST
    
    Args:
        ast: Abstract syntax tree
        
    Returns:
        NBCBytecode ready for execution
    """
    generator = NBCGenerator()
    return generator.generate(ast)


if __name__ == "__main__":
    # Example: Generate NBC for simple program
    example_ast = {
        'statements': [
            {
                'type': 'function_definition',
                'name': 'hello',
                'parameters': [],
                'body': [
                    {
                        'type': 'variable_declaration',
                        'name': 'message',
                        'value': {'type': 'literal', 'value': "Hallo vanuit NoodleCore!"}
                    },
                    {
                        'type': 'return_statement',
                        'value': {'type': 'identifier', 'name': 'message'}
                    }
                ]
            }
        ]
    }
    
    try:
        print("=== NBC Code Generator Test ===")
        
        generator = NBCGenerator()
        bytecode = generator.generate(example_ast)
        
        print("\\nGenerated NBC Bytecode:")
        print(bytecode.disassemble())
        
        print("\\nâœ… Code generation successful!")
        
    except Exception as e:
        print(f"\\nâŒ Code generation failed: {e}")
        import traceback
        traceback.print_exc()


