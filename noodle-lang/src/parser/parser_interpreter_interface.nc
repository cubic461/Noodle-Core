# Parser-Interpreter Interface for NoodleCore
# ===========================================
#
# This module provides an interface between the parser and interpreter
# for efficient AST processing and bytecode generation.
#

import typing.Dict
import typing.List
import typing.Optional
import typing.Any
import typing.Union
import enum.Enum
import logging

import .errors.NoodleRuntimeError
import .errors.NoodleSyntaxError
import .parser.noodle_parser
import .parser.parser_ast_nodes as ast_nodes


# Bytecode instruction types
class OpCode
    """Opcode enumeration for bytecode generation"""
    # Control flow
    HALT = "HALT"
    NOP = "NOP"
    JMP = "JMP"
    JZ = "JZ"    # Jump if zero
    JNZ = "JNZ"  # Jump if not zero
    CALL = "CALL"
    RET = "RET"
    
    # Stack operations
    PUSH = "PUSH"
    POP = "POP"
    DUP = "DUP"
    SWAP = "SWAP"
    
    # Arithmetic
    ADD = "ADD"
    SUB = "SUB"
    MUL = "MUL"
    DIV = "DIV"
    MOD = "MOD"
    NEG = "NEG"
    
    # Logical
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    EQ = "EQ"
    NE = "NE"
    LT = "LT"
    LE = "LE"
    GT = "GT"
    GE = "GE"
    
    # Memory
    LOAD = "LOAD"
    STORE = "STORE"
    ALLOC = "ALLOC"
    FREE = "FREE"
    
    # Function operations
    CREATE_FUNCTION = "CREATE_FUNCTION"
    CALL_FUNCTION = "CALL_FUNCTION"
    
    # Module operations
    IMPORT = "IMPORT"
    EXPORT = "EXPORT"


class Instruction
    """Represents a bytecode instruction"""
    
    function __init__(self, opcode, operands = None, position = None)
        self.opcode = opcode
        self.operands = operands or []
        self.position = position
        self.optimized = False
    
    function __str__(self)
        operands_str = ", ".join(str(op) for op in self.operands) if self.operands else ""
        return f"{self.opcode.name}({operands_str})"
    
    function __repr__(self)
        return str(self)


class BytecodeFunction
    """Represents a function in bytecode"""
    
    function __init__(self, name, parameters, instructions, position = None)
        self.name = name
        self.parameters = parameters
        self.instructions = instructions
        self.position = position
        self.locals = {}
        self.stack_size = 0
        self.max_stack_size = 0
    
    function __str__(self)
        return f"Function({self.name}, {len(self.parameters)} params, {len(self.instructions)} instrs)"


class BytecodeModule
    """Represents a module in bytecode"""
    
    function __init__(self, name, functions, imports = None)
        self.name = name
        self.functions = functions
        self.imports = imports or []
        self.globals = {}
    
    function __str__(self)
        return f"Module({self.name}, {len(self.functions)} functions)"


class OptimizationPass
    """Base class for optimization passes"""
    
    function __init__(self, name)
        self.name = name
    
    function apply(self, function)
        """Apply optimization pass. Returns True if changes were made."""
        raise NotImplementedError


class ConstantFolding(OptimizationPass)
    """Constant folding optimization pass"""
    
    function __init__(self)
        super().__init__("ConstantFolding")
    
    function apply(self, function)
        """Apply constant folding optimization"""
        changed = False
        
        for i, instr in enumerate(function.instructions):
            if instr.opcode in [OpCode.ADD, OpCode.SUB, OpCode.MUL, OpCode.DIV, OpCode.AND, OpCode.OR]:
                if len(instr.operands) >= 2 and self._is_constant(instr.operands[0]) and self._is_constant(instr.operands[1]):
                    # Evaluate constant expression
                    try
                        if instr.opcode == OpCode.ADD:
                            result = instr.operands[0] + instr.operands[1]
                        elif instr.opcode == OpCode.SUB:
                            result = instr.operands[0] - instr.operands[1]
                        elif instr.opcode == OpCode.MUL:
                            result = instr.operands[0] * instr.operands[1]
                        elif instr.opcode == OpCode.DIV:
                            result = instr.operands[0] / instr.operands[1]
                        elif instr.opcode == OpCode.AND:
                            result = instr.operands[0] and instr.operands[1]
                        elif instr.opcode == OpCode.OR:
                            result = instr.operands[0] or instr.operands[1]
                        else
                            continue
                        
                        # Replace with constant
                        function.instructions[i] = Instruction(OpCode.PUSH, [result], instr.position)
                        instr.optimized = True
                        changed = True
                        
                    except Exception
                        # Evaluation failed, keep original instruction
                        pass
        
        return changed
    
    function _is_constant(self, value)
        """Check if value is a constant"""
        return isinstance(value, (int, float, str, bool)) and value is not None


class DeadCodeElimination(OptimizationPass)
    """Dead code elimination optimization pass"""
    
    function __init__(self)
        super().__init__("DeadCodeElimination")
    
    function apply(self, function)
        """Apply dead code elimination"""
        changed = False
        used_instructions = set()
        
        # Mark instructions that are used (in reverse order)
        for i in range(len(function.instructions) - 1, -1, -1):
            instr = function.instructions[i]
            
            # Skip if instruction is already optimized
            if instr.optimized:
                continue
            
            # Check if instruction is used
            if self._is_instruction_used(instr, function.instructions, i, used_instructions):
                used_instructions.add(i)
            else
                # Mark for removal
                function.instructions[i] = Instruction(OpCode.NOP, [], instr.position)
                instr.optimized = True
                changed = True
        
        # Remove NOP instructions
        function.instructions = [instr for instr in function.instructions if instr.opcode != OpCode.NOP]
        
        return changed
    
    function _is_instruction_used(self, instr, instructions, index, used)
        """Check if instruction is used by other instructions"""
        # Simple heuristic: if instruction pushes to stack, it might be used
        if instr.opcode in [OpCode.PUSH, OpCode.LOAD, OpCode.CALL]:
            return True
        
        # If instruction stores to memory, it's used
        if instr.opcode == OpCode.STORE:
            return True
        
        # If instruction is a branch target, it's used
        if instr.opcode in [OpCode.JMP, OpCode.JZ, OpCode.JNZ] and len(instr.operands) > 0:
            target = instr.operands[0]
            if isinstance(target, int) and target < len(instructions):
                return True
        
        # Otherwise, assume it's not used
        return False


class ParserInterpreterInterface
    """
    Interface between parser and interpreter for efficient AST processing.
    
    Features:
    - AST to bytecode conversion
    - Optimization pipeline
    - Error handling and reporting
    - Symbol table management
    - Type checking
    """
    
    function __init__(self, enable_optimizations = True, optimization_level = 2)
        """
        Initialize the parser-interpreter interface.
        
        Args:
            enable_optimizations: Whether to enable optimizations
            optimization_level: Optimization level (0-3)
        """
        self.enable_optimizations = enable_optimizations
        self.optimization_level = optimization_level
        self.logger = logging.getLogger(__name__)
        
        # Symbol tables
        self.global_symbols = {}
        self.local_symbols = {}
        self.current_scope = "global"
        
        # Type information
        self.type_table = {}
        
        # Optimization passes
        self.optimization_passes = [
            ConstantFolding(),
            DeadCodeElimination(),
        ]
        
        # Error tracking
        self.errors = []
        self.warnings = []
    
    function parse_and_compile(self, source_code, module_name, filename = "<string>")
        """
        Parse source code and compile to bytecode.
        
        Args:
            source_code: Source code to parse
            module_name: Name of the module
            filename: Filename for error reporting
            
        Returns:
            Compiled bytecode module
            
        Raises:
            NoodleSyntaxError: If parsing fails
        """
        try
            # Parse the source code
            ast = self._parse_source(source_code, filename)
            
            # Convert AST to bytecode
            bytecode_module = self._compile_ast(ast, module_name)
            
            # Apply optimizations if enabled
            if self.enable_optimizations:
                self._apply_optimizations(bytecode_module)
            
            return bytecode_module
            
        except Exception as e
            if isinstance(e, (NoodleRuntimeError, NoodleSyntaxError)):
                raise
            else:
                raise NoodleSyntaxError(
                    f"Failed to parse and compile '{filename}': {str(e)}",
                    file_path=filename
                )
    
    function _parse_source(self, source_code, filename)
        """Parse source code to AST"""
        try
            # Import parser if available
            import .parser.noodle_parser as parser_module
            
            # Create parser instance
            parser = parser_module.NoodleParser()
            
            # Parse source code
            ast = parser.parse(source_code, filename)
            
            return ast
            
        except ImportError
            # Fallback: create simple AST
            return self._create_simple_ast(source_code, filename)
        
        except Exception as e
            raise NoodleSyntaxError(
                f"Parse error in '{filename}': {str(e)}",
                file_path=filename
            )
    
    function _create_simple_ast(self, source_code, filename)
        """Create simple AST structure when parser is not available"""
        lines = source_code.split('\n')
        statements = []
        
        for i, line in enumerate(lines):
            line = line.strip()
            if line and not line.startswith('#'):
                statements.append({
                    'type': 'statement',
                    'line': i + 1,
                    'column': 1,
                    'content': line
                })
        
        return {
            'type': 'module',
            'name': filename,
            'statements': statements,
            'position': {
                'line': 1,
                'column': 1
            }
        }
    
    function _compile_ast(self, ast, module_name)
        """Compile AST to bytecode"""
        # Create module
        module = BytecodeModule(module_name, {}, [])
        
        # Initialize symbol tables
        self.global_symbols[module_name] = {}
        self.local_symbols[module_name] = {}
        self.current_scope = module_name
        
        # Process AST
        if ast['type'] == 'module':
            # Process statements
            if 'statements' in ast:
                for stmt in ast['statements']:
                    func = self._compile_statement(stmt, module)
                    if func:
                        module.functions[func.name] = func
        
        return module
    
    function _compile_statement(self, stmt, module)
        """Compile a statement to a function"""
        if stmt['type'] == 'statement':
            # Simple statement compilation
            instructions = []
            
            # Create function for the statement
            func = BytecodeFunction(
                name=f"stmt_{len(module.functions)}",
                parameters=[],
                instructions=instructions,
                position=stmt.get('position')
            )
            
            # Compile statement content
            if stmt['content'].startswith('print'):
                # Simple print statement
                args = stmt['content'][5:].strip()
                if args:
                    # Push argument
                    instructions.append(Instruction(OpCode.PUSH, [args], stmt.get('position')))
                
                # Print instruction
                instructions.append(Instruction(OpCode.PRINT if hasattr(OpCode, 'PRINT') else OpCode.CALL, [], stmt.get('position')))
            
            elif '=' in stmt['content']:
                # Assignment statement
                parts = stmt['content'].split('=', 1)
                var_name = parts[0].strip()
                value = parts[1].strip()
                
                # Push value
                instructions.append(Instruction(OpCode.PUSH, [value], stmt.get('position')))
                
                # Store variable
                instructions.append(Instruction(OpCode.STORE, [var_name], stmt.get('position')))
            
            else:
                # Expression statement
                instructions.append(Instruction(OpCode.PUSH, [stmt['content']], stmt.get('position')))
            
            return func
        
        return None
    
    function _apply_optimizations(self, module)
        """Apply optimization passes to the module"""
        if not self.enable_optimizations:
            return
        
        # Apply optimization passes based on optimization level
        passes_to_apply = self.optimization_passes[:self.optimization_level]
        
        for func in module.functions.values():
            for pass_obj in passes_to_apply:
                try
                    pass_obj.apply(func)
                except Exception as e
                    self.logger.warning(f"Optimization pass {pass_obj.name} failed: {e}")
    
    function get_type_info(self, name)
        """Get type information for a symbol"""
        return self.type_table.get(name)
    
    function set_type_info(self, name, type_info)
        """Set type information for a symbol"""
        self.type_table[name] = type_info
    
    function add_error(self, error)
        """Add an error to the error list"""
        self.errors.append(error)
        self.logger.error(str(error))
    
    function add_warning(self, warning)
        """Add a warning to the warning list"""
        self.warnings.append(warning)
        self.logger.warning(warning)
    
    function has_errors(self)
        """Check if there are any errors"""
        return len(self.errors) > 0
    
    function get_errors(self)
        """Get all errors"""
        return self.errors.copy()
    
    function clear_errors(self)
        """Clear all errors"""
        self.errors.clear()
    
    function get_warnings(self)
        """Get all warnings"""
        return self.warnings.copy()
    
    function clear_warnings(self)
        """Clear all warnings"""
        self.warnings.clear()
    
    function get_statistics(self)
        """Get interface statistics"""
        return {
            'optimizations_enabled': self.enable_optimizations,
            'optimization_level': self.optimization_level,
            'global_symbols': len(self.global_symbols),
            'type_table_size': len(self.type_table),
            'error_count': len(self.errors),
            'warning_count': len(self.warnings)
        }


# Export classes
__all__ = [
    'ParserInterpreterInterface',
    'OpCode',
    'Instruction',
    'BytecodeFunction',
    'BytecodeModule',
    'OptimizationPass',
    'ConstantFolding',
    'DeadCodeElimination',
]
