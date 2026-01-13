# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Python AST to NoodleCore IR Translator

# This module provides translation of Python AST structures to NoodleCore IR,
# enabling direct conversion of Python code to the intermediate representation
# used by NoodleCore's compiler pipeline.
# """

import ast
import inspect
import logging
import sys
import typing.Dict,

# Import TRM-Agent components
try
    #     from ..trm_agent_base import TRMAgentBase, TRMAgentException, Logger
except ImportError
    #     # Fallback for when TRM-Agent components are not available
    #     class TRMAgentBase:
    #         def __init__(self, config=None):
    self.config = config
    self.logger = Logger("python_ast_translator")

    #     class TRMAgentException(Exception):
    #         def __init__(self, message, error_code=5060):
                super().__init__(message)
    self.error_code = error_code

    #     class Logger:
    #         def __init__(self, name):
    self.name = name

    #         def debug(self, msg):
                print(f"DEBUG: {msg}")

    #         def info(self, msg):
                print(f"INFO: {msg}")

    #         def warning(self, msg):
                print(f"WARNING: {msg}")

    #         def error(self, msg):
                print(f"ERROR: {msg}")

# Import NoodleCore IR components
try
        from ..compiler.nir.ir import (
    #         Module, Block, Value, Operation, Function, ConstantOp,
    #         AddOp, SubOp, MulOp, DivOp, ModOp, PowOp,
    #         CompareOp, CallOp, ReturnOp, BranchOp,
    #         Dialect, Location, Type, BasicType, FunctionType
    #     )
    IR_AVAILABLE = True
except ImportError
    IR_AVAILABLE = False
    #     # Create fallback classes
    #     class Module:
    #         def __init__(self, name):
    self.name = name
    self.blocks = []
    self.functions = []

    #     class Block:
    #         def __init__(self, name):
    self.name = name
    self.operations = []

    #     class Value:
    #         def __init__(self, name, type=None):
    self.name = name
    self.type = type

    #     class Operation:
    #         def __init__(self, name, dialect, operands=None, location=None):
    self.name = name
    self.dialect = dialect
    self.operands = operands or []
    self.location = location
    self.results = [Value(f"{name}_result")]

    #     class ConstantOp:
    #         def __init__(self, value, dtype, location=None):
    self.value = value
    self.dtype = dtype
    self.location = location
    self.results = [Value(f"const_{value}", dtype)]

    #     class AddOp:
    #         def __init__(self, lhs, rhs, location=None):
    self.lhs = lhs
    self.rhs = rhs
    self.location = location
    self.results = [Value("add_result")]

    #     class SubOp:
    #         def __init__(self, lhs, rhs, location=None):
    self.lhs = lhs
    self.rhs = rhs
    self.location = location
    self.results = [Value("sub_result")]

    #     class MulOp:
    #         def __init__(self, lhs, rhs, location=None):
    self.lhs = lhs
    self.rhs = rhs
    self.location = location
    self.results = [Value("mul_result")]

    #     class DivOp:
    #         def __init__(self, lhs, rhs, location=None):
    self.lhs = lhs
    self.rhs = rhs
    self.location = location
    self.results = [Value("div_result")]

    #     class CompareOp:
    #         def __init__(self, lhs, rhs, op_type, location=None):
    self.lhs = lhs
    self.rhs = rhs
    self.op_type = op_type
    self.location = location
    self.results = [Value("compare_result")]

    #     class CallOp:
    #         def __init__(self, callee, args, location=None):
    self.callee = callee
    self.args = args
    self.location = location
    self.results = [Value("call_result")]

    #     class ReturnOp:
    #         def __init__(self, value=None, location=None):
    self.value = value
    self.location = location
    self.results = []

    #     class BranchOp:
    #         def __init__(self, condition, true_block, false_block, location=None):
    self.condition = condition
    self.true_block = true_block
    self.false_block = false_block
    self.location = location
    self.results = []

    #     class Dialect:
    STD = "std"

    #     class Location:
    #         def __init__(self, file=None, line=None, col=None):
    self.file = file
    self.line = line
    self.col = col

    #     class Type:
    #         def __init__(self, name):
    self.name = name

    #     class BasicType(Type):
    INTEGER = "integer"
    FLOAT = "float"
    STRING = "string"
    BOOLEAN = "boolean"

    #     class FunctionType(Type):
    #         def __init__(self, inputs, output):
    self.inputs = inputs
    self.output = output


class PythonASTTranslatorError(TRMAgentException)
    #     """Exception raised during Python AST translation."""
    #     def __init__(self, message: str):
    super().__init__(message, error_code = 5061)


class PythonASTTranslator(TRMAgentBase)
    #     """
    #     Translator for converting Python AST to NoodleCore IR.

    #     This class handles the conversion of Python AST nodes to NoodleCore IR
    #     operations, enabling direct compilation of Python code to the NoodleCore
    #     intermediate representation.
    #     """

    #     def __init__(self, config=None):
    #         """
    #         Initialize the Python AST translator.

    #         Args:
    #             config: TRM-Agent configuration. If None, default configuration is used.
    #         """
            super().__init__(config)
    self.logger = Logger("python_ast_translator")

    #         # Translation context
    self.current_module: Optional[Module] = None
    self.current_block: Optional[Block] = None
    self.current_function: Optional[Function] = None
    self.symbol_table: Dict[str, Value] = {}
    self.filename: str = "<string>"

    #         # Statistics
    self.translation_statistics = {
    #             'total_translations': 0,
    #             'successful_translations': 0,
    #             'failed_translations': 0,
    #             'nodes_translated': 0,
    #             'unsupported_nodes': 0,
    #             'translation_errors': 0
    #         }

    #         # Mapping of Python AST node types to translation methods
    self.node_translators = {
    #             ast.Module: self._translate_module,
    #             ast.FunctionDef: self._translate_function_def,
    #             ast.Return: self._translate_return,
    #             ast.Assign: self._translate_assign,
    #             ast.AnnAssign: self._translate_ann_assign,
    #             ast.AugAssign: self._translate_aug_assign,
    #             ast.For: self._translate_for,
    #             ast.While: self._translate_while,
    #             ast.If: self._translate_if,
    #             ast.Expr: self._translate_expr,
    #             ast.BinOp: self._translate_bin_op,
    #             ast.UnaryOp: self._translate_unary_op,
    #             ast.Compare: self._translate_compare,
    #             ast.Call: self._translate_call,
    #             ast.Name: self._translate_name,
    #             ast.Constant: self._translate_constant,
    #             ast.Num: self._translate_constant,  # Python 3.7 and earlier
    #             ast.Str: self._translate_constant,  # Python 3.7 and earlier
    #             ast.NameConstant: self._translate_constant,  # Python 3.7 and earlier
    #             ast.Attribute: self._translate_attribute,
    #             ast.Subscript: self._translate_subscript,
    #             ast.List: self._translate_list,
    #             ast.Tuple: self._translate_tuple,
    #             ast.Dict: self._translate_dict,
    #             ast.Pass: self._translate_pass,
    #             ast.Break: self._translate_break,
    #             ast.Continue: self._translate_continue
    #         }

    #     def translate_python_to_ir(self, source_code: str, filename: str = "<string>") -> Module:
    #         """
    #         Translate Python source code to NoodleCore IR.

    #         Args:
    #             source_code: Python source code to translate.
    #             filename: Name of the source file.

    #         Returns:
    #             Module: NoodleCore IR module.

    #         Raises:
    #             PythonASTTranslatorError: If translation fails.
    #         """
    self.translation_statistics['total_translations'] + = 1
    self.filename = filename

    #         try:
    #             # Parse Python source to AST
    tree = ast.parse(source_code, filename=filename)

    #             # Create module
    self.current_module = Module(filename)

    #             # Create entry block
    entry_block = Block("entry")
                self.current_module.blocks.append(entry_block)
    self.current_block = entry_block

    #             # Reset symbol table
    self.symbol_table = {}

    #             # Translate AST
                self._translate_node(tree)

    #             # Update statistics
    self.translation_statistics['successful_translations'] + = 1

    #             return self.current_module

    #         except SyntaxError as e:
    self.translation_statistics['translation_errors'] + = 1
    self.translation_statistics['failed_translations'] + = 1
    error_msg = f"Python syntax error in {filename}:{e.lineno}:{e.offset}: {e.msg}"
                self.logger.error(error_msg)
                raise PythonASTTranslatorError(error_msg)

    #         except Exception as e:
    self.translation_statistics['translation_errors'] + = 1
    self.translation_statistics['failed_translations'] + = 1
    error_msg = f"Python AST translation failed: {str(e)}"
                self.logger.error(error_msg)
                raise PythonASTTranslatorError(error_msg)

    #     def _translate_node(self, node: ast.AST) -> Optional[Value]:
    #         """
    #         Translate a Python AST node to NoodleCore IR.

    #         Args:
    #             node: Python AST node to translate.

    #         Returns:
    #             Optional[Value]: Result value if applicable.

    #         Raises:
    #             PythonASTTranslatorError: If translation fails.
    #         """
    node_type = type(node)
    self.translation_statistics['nodes_translated'] + = 1

    #         # Get translator method for this node type
    translator = self.node_translators.get(node_type)

    #         if translator is None:
    self.translation_statistics['unsupported_nodes'] + = 1
                self.logger.warning(f"Unsupported AST node type: {node_type.__name__}")
    #             return None

    #         try:
                return translator(node)
    #         except Exception as e:
                self.logger.error(f"Error translating {node_type.__name__}: {str(e)}")
                raise PythonASTTranslatorError(f"Error translating {node_type.__name__}: {str(e)}")

    #     def _translate_module(self, node: ast.Module) -> Optional[Value]:
    #         """Translate a module node."""
    #         for stmt in node.body:
                self._translate_node(stmt)
    #         return None

    #     def _translate_function_def(self, node: ast.FunctionDef) -> Optional[Value]:
    #         """Translate a function definition node."""
    #         # Create function
    input_types = math.multiply([BasicType.FLOAT], len(node.args.args)  # Simplified type inference)
    output_type = BasicType.FLOAT  # Simplified type inference
    function_type = FunctionType(input_types, output_type)

    function = Function(node.name, function_type)
            self.current_module.functions.append(function)

    #         # Create entry block for function
    entry_block = Block(f"{node.name}_entry")
            function.blocks.append(entry_block)

    #         # Save current context
    saved_module = self.current_module
    saved_block = self.current_block
    saved_function = self.current_function
    saved_symbol_table = self.symbol_table.copy()

    #         # Update context
    self.current_module = None  # Not used within function
    self.current_block = entry_block
    self.current_function = function
    self.symbol_table = {}

    #         # Add parameters to symbol table
    #         for i, arg in enumerate(node.args.args):
    param_value = Value(arg.arg, input_types[i])
    self.symbol_table[arg.arg] = param_value

    #         # Translate function body
    #         for stmt in node.body:
                self._translate_node(stmt)

    #         # Restore context
    self.current_module = saved_module
    self.current_block = saved_block
    self.current_function = saved_function
    self.symbol_table = saved_symbol_table

    #         return None

    #     def _translate_return(self, node: ast.Return) -> Optional[Value]:
    #         """Translate a return node."""
    #         if node.value:
    value = self._translate_node(node.value)
    ret_op = ReturnOp(value, self._get_location(node))
    #         else:
    ret_op = ReturnOp(location=self._get_location(node))

            self.current_block.operations.append(ret_op)
    #         return None

    #     def _translate_assign(self, node: ast.Assign) -> Optional[Value]:
    #         """Translate an assignment node."""
    #         # Translate the value
    value = self._translate_node(node.value)
    #         if value is None:
    #             return None

    #         # Assign to each target
    #         for target in node.targets:
    #             if isinstance(target, ast.Name):
    #                 # Simple variable assignment
    self.symbol_table[target.id] = value
    #             elif isinstance(target, ast.Attribute):
    # Attribute assignment (obj.attr = value)
    obj = self._translate_node(target.value)
    #                 if obj:
    #                     # Create a set attribute operation
    op = Operation(
    #                         "set_attribute",
    #                         Dialect.STD,
    operands = [obj, value],
    location = self._get_location(node)
    #                     )
                        self.current_block.operations.append(op)
    #             elif isinstance(target, ast.Subscript):
    # Subscript assignment (obj[index] = value)
    obj = self._translate_node(target.value)
    index = self._translate_node(target.slice)
    #                 if obj and index:
    #                     # Create a set subscript operation
    op = Operation(
    #                         "set_subscript",
    #                         Dialect.STD,
    operands = [obj, index, value],
    location = self._get_location(node)
    #                     )
                        self.current_block.operations.append(op)

    #         return value

    #     def _translate_ann_assign(self, node: ast.AnnAssign) -> Optional[Value]:
    #         """Translate an annotated assignment node."""
    #         # Translate the value if present
    value = None
    #         if node.value:
    value = self._translate_node(node.value)

    #         # For simplicity, we ignore the annotation for now
    #         if isinstance(node.target, ast.Name) and value:
    self.symbol_table[node.target.id] = value

    #         return value

    #     def _translate_aug_assign(self, node: ast.AugAssign) -> Optional[Value]:
    #         """Translate an augmented assignment node."""
    #         # Get the current value
    #         if isinstance(node.target, ast.Name):
    current_value = self.symbol_table.get(node.target.id)
    #             if current_value is None:
    #                 # Create a default value
    current_value = Value(node.target.id, BasicType.FLOAT)
    self.symbol_table[node.target.id] = current_value
    #         else:
    current_value = self._translate_node(node.target)

    #         if current_value is None:
    #             return None

    #         # Translate the right-hand side
    rhs = self._translate_node(node.value)
    #         if rhs is None:
    #             return None

    #         # Create the appropriate operation
    result = None
    #         if isinstance(node.op, ast.Add):
    op = AddOp(current_value, rhs, self._get_location(node))
                self.current_block.operations.append(op)
    result = op.results[0]
    #         elif isinstance(node.op, ast.Sub):
    op = SubOp(current_value, rhs, self._get_location(node))
                self.current_block.operations.append(op)
    result = op.results[0]
    #         elif isinstance(node.op, ast.Mult):
    op = MulOp(current_value, rhs, self._get_location(node))
                self.current_block.operations.append(op)
    result = op.results[0]
    #         elif isinstance(node.op, ast.Div):
    op = DivOp(current_value, rhs, self._get_location(node))
                self.current_block.operations.append(op)
    result = op.results[0]
    #         else:
    #             # Create a generic binary operation
    op = Operation(
                    f"aug_{type(node.op).__name__}",
    #                 Dialect.STD,
    operands = [current_value, rhs],
    location = self._get_location(node)
    #             )
                self.current_block.operations.append(op)
    result = op.results[0]

    #         # Update the target
    #         if isinstance(node.target, ast.Name):
    self.symbol_table[node.target.id] = result

    #         return result

    #     def _translate_for(self, node: ast.For) -> Optional[Value]:
    #         """Translate a for loop node."""
    #         # Create loop blocks
    loop_header = Block(f"for_header_{id(node)}")
    loop_body = Block(f"for_body_{id(node)}")
    loop_exit = Block(f"for_exit_{id(node)}")

    #         # Add blocks to current function or module
    #         if self.current_function:
                self.current_function.blocks.extend([loop_header, loop_body, loop_exit])
    #         else:
                self.current_module.blocks.extend([loop_header, loop_body, loop_exit])

    #         # Translate the iterator
    iter_value = self._translate_node(node.iter)
    #         if iter_value is None:
    #             return None

    #         # Create loop header
    #         # Get iterator
    get_iter_op = Operation(
    #             "get_iter",
    #             Dialect.STD,
    operands = [iter_value],
    location = self._get_location(node)
    #         )
            loop_header.operations.append(get_iter_op)
    iterator = get_iter_op.results[0]

    #         # Check if iterator has next
    has_next_op = Operation(
    #             "iter_has_next",
    #             Dialect.STD,
    operands = [iterator],
    location = self._get_location(node)
    #         )
            loop_header.operations.append(has_next_op)
    condition = has_next_op.results[0]

    #         # Create branch to loop body or exit
    branch_op = BranchOp(condition, loop_body, loop_exit, self._get_location(node))
            loop_header.operations.append(branch_op)

    #         # Create loop body
    #         # Get next item from iterator
    next_op = Operation(
    #             "iter_next",
    #             Dialect.STD,
    operands = [iterator],
    location = self._get_location(node)
    #         )
            loop_body.operations.append(next_op)
    next_item = next_op.results[0]

    #         # Save current context
    saved_block = self.current_block
    saved_symbol_table = self.symbol_table.copy()

    #         # Update context
    self.current_block = loop_body

    #         # Assign loop variable
    #         if isinstance(node.target, ast.Name):
    self.symbol_table[node.target.id] = next_item

    #         # Translate loop body
    #         for stmt in node.body:
                self._translate_node(stmt)

    #         # Branch back to header
    back_branch_op = BranchOp(
                Value("true", BasicType.BOOLEAN),
    #             loop_header,
    #             loop_exit,
                self._get_location(node)
    #         )
            loop_body.operations.append(back_branch_op)

    #         # Restore context
    self.current_block = saved_block
    self.symbol_table = saved_symbol_table

    #         return None

    #     def _translate_while(self, node: ast.While) -> Optional[Value]:
    #         """Translate a while loop node."""
    #         # Create loop blocks
    loop_header = Block(f"while_header_{id(node)}")
    loop_body = Block(f"while_body_{id(node)}")
    loop_exit = Block(f"while_exit_{id(node)}")

    #         # Add blocks to current function or module
    #         if self.current_function:
                self.current_function.blocks.extend([loop_header, loop_body, loop_exit])
    #         else:
                self.current_module.blocks.extend([loop_header, loop_body, loop_exit])

    #         # Create loop header
    #         # Translate condition
    condition = self._translate_node(node.test)
    #         if condition is None:
    condition = Value("true", BasicType.BOOLEAN)

    #         # Create branch to loop body or exit
    branch_op = BranchOp(condition, loop_body, loop_exit, self._get_location(node))
            loop_header.operations.append(branch_op)

    #         # Create loop body
    #         # Save current context
    saved_block = self.current_block

    #         # Update context
    self.current_block = loop_body

    #         # Translate loop body
    #         for stmt in node.body:
                self._translate_node(stmt)

    #         # Branch back to header
    back_branch_op = BranchOp(
                Value("true", BasicType.BOOLEAN),
    #             loop_header,
    #             loop_exit,
                self._get_location(node)
    #         )
            loop_body.operations.append(back_branch_op)

    #         # Restore context
    self.current_block = saved_block

    #         return None

    #     def _translate_if(self, node: ast.If) -> Optional[Value]:
    #         """Translate an if statement node."""
    #         # Translate condition
    condition = self._translate_node(node.test)
    #         if condition is None:
    condition = Value("true", BasicType.BOOLEAN)

    #         # Create blocks
    true_block = Block(f"if_true_{id(node)}")
    false_block = Block(f"if_false_{id(node)}")
    exit_block = Block(f"if_exit_{id(node)}")

    #         # Add blocks to current function or module
    #         if self.current_function:
                self.current_function.blocks.extend([true_block, false_block, exit_block])
    #         else:
                self.current_module.blocks.extend([true_block, false_block, exit_block])

    #         # Create branch
    branch_op = BranchOp(condition, true_block, false_block, self._get_location(node))
            self.current_block.operations.append(branch_op)

    #         # Save current context
    saved_block = self.current_block

    #         # Translate true block
    self.current_block = true_block
    #         for stmt in node.body:
                self._translate_node(stmt)
    #         # Branch to exit
    true_exit_op = BranchOp(
                Value("true", BasicType.BOOLEAN),
    #             exit_block,
    #             exit_block,
                self._get_location(node)
    #         )
            true_block.operations.append(true_exit_op)

    #         # Translate false block if it has statements
    #         if node.orelse:
    self.current_block = false_block
    #             for stmt in node.orelse:
                    self._translate_node(stmt)
    #             # Branch to exit
    false_exit_op = BranchOp(
                    Value("true", BasicType.BOOLEAN),
    #                 exit_block,
    #                 exit_block,
                    self._get_location(node)
    #             )
                false_block.operations.append(false_exit_op)
    #         else:
    #             # Directly branch to exit
    false_exit_op = BranchOp(
                    Value("true", BasicType.BOOLEAN),
    #                 exit_block,
    #                 exit_block,
                    self._get_location(node)
    #             )
                false_block.operations.append(false_exit_op)

    #         # Restore context
    self.current_block = saved_block

    #         return None

    #     def _translate_expr(self, node: ast.Expr) -> Optional[Value]:
    #         """Translate an expression statement node."""
            return self._translate_node(node.value)

    #     def _translate_bin_op(self, node: ast.BinOp) -> Optional[Value]:
    #         """Translate a binary operation node."""
    #         # Translate operands
    left = self._translate_node(node.left)
    right = self._translate_node(node.right)

    #         if left is None or right is None:
    #             return None

    #         # Create appropriate operation
    op = None
    #         if isinstance(node.op, ast.Add):
    op = AddOp(left, right, self._get_location(node))
    #         elif isinstance(node.op, ast.Sub):
    op = SubOp(left, right, self._get_location(node))
    #         elif isinstance(node.op, ast.Mult):
    op = MulOp(left, right, self._get_location(node))
    #         elif isinstance(node.op, ast.Div):
    op = DivOp(left, right, self._get_location(node))
    #         elif isinstance(node.op, ast.Mod):
    op = Operation(
    #                 "mod",
    #                 Dialect.STD,
    operands = [left, right],
    location = self._get_location(node)
    #             )
    #         elif isinstance(node.op, ast.Pow):
    op = Operation(
    #                 "pow",
    #                 Dialect.STD,
    operands = [left, right],
    location = self._get_location(node)
    #             )
    #         else:
    #             # Create a generic binary operation
    op = Operation(
                    f"bin_{type(node.op).__name__}",
    #                 Dialect.STD,
    operands = [left, right],
    location = self._get_location(node)
    #             )

            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_unary_op(self, node: ast.UnaryOp) -> Optional[Value]:
    #         """Translate a unary operation node."""
    #         # Translate operand
    operand = self._translate_node(node.operand)
    #         if operand is None:
    #             return None

    #         # Create appropriate operation
    op = Operation(
                f"unary_{type(node.op).__name__}",
    #             Dialect.STD,
    operands = [operand],
    location = self._get_location(node)
    #         )

            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_compare(self, node: ast.Compare) -> Optional[Value]:
    #         """Translate a comparison node."""
    #         # Translate left operand
    left = self._translate_node(node.left)
    #         if left is None:
    #             return None

    #         # For simplicity, only handle single comparison
    #         if len(node.ops) != 1 or len(node.comparators) != 1:
                self.logger.warning("Only single comparisons are supported")
    #             return None

    #         # Translate right operand
    right = self._translate_node(node.comparators[0])
    #         if right is None:
    #             return None

    #         # Determine comparison type
    op_type = type(node.ops[0]).__name__

    #         # Create comparison operation
    op = CompareOp(left, right, op_type, self._get_location(node))
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_call(self, node: ast.Call) -> Optional[Value]:
    #         """Translate a function call node."""
    #         # Translate function
    func = self._translate_node(node.func)
    #         if func is None:
    #             return None

    #         # Translate arguments
    args = []
    #         for arg in node.args:
    arg_value = self._translate_node(arg)
    #             if arg_value is not None:
                    args.append(arg_value)

    #         # Create call operation
    op = CallOp(func, args, self._get_location(node))
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_name(self, node: ast.Name) -> Optional[Value]:
    #         """Translate a name node."""
    #         # Look up in symbol table
    #         if node.id in self.symbol_table:
    #             return self.symbol_table[node.id]

    #         # Check if it's a built-in function
    #         if node.id in {"print", "len", "range", "enumerate", "zip", "map", "filter"}:
                return Value(node.id, Type("function"))

    #         # Create a new variable
    value = Value(node.id, BasicType.FLOAT)
    self.symbol_table[node.id] = value
    #         return value

    #     def _translate_constant(self, node: Union[ast.Constant, ast.Num, ast.Str, ast.NameConstant]) -> Optional[Value]:
    #         """Translate a constant node."""
    #         # Handle different Python versions
    #         if isinstance(node, ast.Constant):
    value = node.value
    #         elif isinstance(node, ast.Num):
    value = node.n
    #         elif isinstance(node, ast.Str):
    value = node.s
    #         elif isinstance(node, ast.NameConstant):
    value = node.value
    #         else:
    #             return None

    #         # Determine type
    #         if isinstance(value, bool):
    dtype = BasicType.BOOLEAN
    #         elif isinstance(value, int):
    dtype = BasicType.INTEGER
    #         elif isinstance(value, float):
    dtype = BasicType.FLOAT
    #         elif isinstance(value, str):
    dtype = BasicType.STRING
    #         else:
    dtype = BasicType.FLOAT  # Default

    #         # Create constant operation
    op = ConstantOp(value, dtype, self._get_location(node))
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_attribute(self, node: ast.Attribute) -> Optional[Value]:
    #         """Translate an attribute access node."""
    #         # Translate object
    obj = self._translate_node(node.value)
    #         if obj is None:
    #             return None

    #         # Create attribute access operation
    op = Operation(
    #             "get_attribute",
    #             Dialect.STD,
    operands = [obj],
    location = self._get_location(node)
    #         )
    op.attributes = {"attr": node.attr}
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_subscript(self, node: ast.Subscript) -> Optional[Value]:
    #         """Translate a subscript node."""
    #         # Translate object and index
    obj = self._translate_node(node.value)
    index = self._translate_node(node.slice)

    #         if obj is None or index is None:
    #             return None

    #         # Create subscript operation
    op = Operation(
    #             "get_subscript",
    #             Dialect.STD,
    operands = [obj, index],
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_list(self, node: ast.List) -> Optional[Value]:
    #         """Translate a list node."""
    #         # Translate elements
    elements = []
    #         for elt in node.elts:
    elt_value = self._translate_node(elt)
    #             if elt_value is not None:
                    elements.append(elt_value)

    #         # Create list operation
    op = Operation(
    #             "create_list",
    #             Dialect.STD,
    operands = elements,
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_tuple(self, node: ast.Tuple) -> Optional[Value]:
    #         """Translate a tuple node."""
    #         # Translate elements
    elements = []
    #         for elt in node.elts:
    elt_value = self._translate_node(elt)
    #             if elt_value is not None:
                    elements.append(elt_value)

    #         # Create tuple operation
    op = Operation(
    #             "create_tuple",
    #             Dialect.STD,
    operands = elements,
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_dict(self, node: ast.Dict) -> Optional[Value]:
    #         """Translate a dictionary node."""
    #         # Translate keys and values
    keys = []
    values = []
    #         for key, value in zip(node.keys, node.values):
    #             if key is not None:
    key_value = self._translate_node(key)
    #                 if key_value is not None:
                        keys.append(key_value)

    #             if value is not None:
    value_value = self._translate_node(value)
    #                 if value_value is not None:
                        values.append(value_value)

    #         # Create dict operation
    op = Operation(
    #             "create_dict",
    #             Dialect.STD,
    operands = math.add(keys, values,)
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return op.results[0]

    #     def _translate_pass(self, node: ast.Pass) -> Optional[Value]:
    #         """Translate a pass node."""
    #         # No operation needed
    #         return None

    #     def _translate_break(self, node: ast.Break) -> Optional[Value]:
    #         """Translate a break node."""
    #         # Create break operation
    op = Operation(
    #             "break",
    #             Dialect.STD,
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return None

    #     def _translate_continue(self, node: ast.Continue) -> Optional[Value]:
    #         """Translate a continue node."""
    #         # Create continue operation
    op = Operation(
    #             "continue",
    #             Dialect.STD,
    location = self._get_location(node)
    #         )
            self.current_block.operations.append(op)
    #         return None

    #     def _get_location(self, node: ast.AST) -> Location:
    #         """Get location information from an AST node."""
    #         if hasattr(node, 'lineno') and hasattr(node, 'col_offset'):
                return Location(self.filename, node.lineno, node.col_offset)
            return Location(self.filename)

    #     def get_translation_statistics(self) -> Dict[str, Any]:
    #         """
    #         Get statistics about the translation process.

    #         Returns:
    #             Dict[str, Any]: Statistics dictionary.
    #         """
            return self.translation_statistics.copy()

    #     def reset_translation_statistics(self):
    #         """Reset all translation statistics."""
    self.translation_statistics = {
    #             'total_translations': 0,
    #             'successful_translations': 0,
    #             'failed_translations': 0,
    #             'nodes_translated': 0,
    #             'unsupported_nodes': 0,
    #             'translation_errors': 0
    #         }
            self.logger.info("Translation statistics reset")


# Global translator instance
_python_ast_translator = None


def get_python_ast_translator(config=None) -> PythonASTTranslator:
#     """
#     Get the global Python AST translator instance.

#     Args:
#         config: TRM-Agent configuration.

#     Returns:
#         PythonASTTranslator: Global Python AST translator.
#     """
#     global _python_ast_translator
#     if _python_ast_translator is None:
_python_ast_translator = PythonASTTranslator(config)
#     return _python_ast_translator


def translate_python_to_ir(source_code: str, filename: str = "<string>", config=None) -> Module:
#     """
#     Translate Python to IR using the global translator.

#     Args:
#         source_code: Python source code to translate.
#         filename: Name of the source file.
#         config: TRM-Agent configuration.

#     Returns:
#         Module: NoodleCore IR module.
#     """
translator = get_python_ast_translator(config)
    return translator.translate_python_to_ir(source_code, filename)