# Converted from Python to NoodleCore
# Original file: src

# """
# Symbol Table for Noodle Programming Language
# --------------------------------------------
# This module implements the symbol table for the Noodle semantic analyzer.
# It tracks variables, functions, types, and their scopes.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import typing.Dict
import .parser_ast_nodes.Type


class SymbolTable
    #     """Symbol table for tracking variables, functions, and types"""

    #     def __init__(self, parent: Optional['SymbolTable'] = None):
    self.parent = parent
    self.symbols: Dict[str, Any] = {}
    self.scopes: List[Dict[str, Any]] = [{}]
    self.current_scope = 0

    #     def enter_scope(self):
    #         """Enter a new scope"""
            self.scopes.append({})
    self.current_scope + = 1

    #     def exit_scope(self):
    #         """Exit the current scope"""
    #         if self.current_scope 0):
                self.scopes.pop()
    self.current_scope - = 1

    #     def define(self, name: str, symbol: Any):
    #         """Define a symbol in the current scope"""
    #         if self.current_scope < len(self.scopes):
    self.scopes[self.current_scope][name] = symbol
    #         else:
    self.symbols[name] = symbol

    #     def lookup(self, name: str) -Optional[Any]):
    #         """Look up a symbol in the current scope or parent scopes"""
    #         # Check current scope
    #         if self.current_scope < len(self.scopes):
    #             if name in self.scopes[self.current_scope]:
    #                 return self.scopes[self.current_scope][name]

    #         # Check global scope
    #         if name in self.symbols:
    #             return self.symbols[name]

    #         # Check parent scopes
    #         if self.parent:
                return self.parent.lookup(name)

    #         return None

    #     def lookup_local(self, name: str) -Optional[Any]):
    #         """Look up a symbol only in the current scope"""
    #         if self.current_scope < len(self.scopes):
                return self.scopes[self.current_scope].get(name)
    #         return None

    #     def update(self, name: str, symbol: Any):
    #         """Update an existing symbol in the current scope"""
    #         if self.current_scope < len(self.scopes):
    #             if name in self.scopes[self.current_scope]:
    self.scopes[self.current_scope][name] = symbol
    #                 return
    #         if name in self.symbols:
    self.symbols[name] = symbol
    #             return
    #         if self.parent:
                self.parent.update(name, symbol)

    #     def delete(self, name: str):
    #         """Delete a symbol from the current scope"""
    #         if self.current_scope < len(self.scopes):
    #             if name in self.scopes[self.current_scope]:
    #                 del self.scopes[self.current_scope][name]
    #                 return
    #         if name in self.symbols:
    #             del self.symbols[name]
    #             return
    #         if self.parent:
                self.parent.delete(name)

    #     def get_all_symbols(self) -Dict[str, Any]):
    #         """Get all symbols in the current scope and parent scopes"""
    all_symbols = {}

    #         # Add parent symbols
    #         if self.parent:
                all_symbols.update(self.parent.get_all_symbols())

    #         # Add current scope symbols
    #         if self.current_scope < len(self.scopes):
                all_symbols.update(self.scopes[self.current_scope])

    #         # Add global symbols
            all_symbols.update(self.symbols)

    #         return all_symbols

    #     def get_scope_symbols(self) -Dict[str, Any]):
    #         """Get symbols only in the current scope"""
    #         if self.current_scope < len(self.scopes):
                return self.scopes[self.current_scope].copy()
    #         return {}

    #     def __str__(self) -str):
    #         """String representation of the symbol table"""
    result = f"SymbolTable(current_scope={self.current_scope}, symbols={len(self.symbols)})"
    #         if self.parent:
    result + = f" -> {self.parent}"
    #         return result