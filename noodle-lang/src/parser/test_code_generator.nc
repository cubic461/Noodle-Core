# Converted from Python to NoodleCore
# Original file: src

# """
# Tests for Noodle Code Generator
# ------------------------------

# This module contains tests for the Noodle code generator that converts AST nodes
# to bytecode instructions for the NBC runtime.
# """

import os
import pytest
import tempfile

import noodlecore.compiler.code_generator.(
#     CodeGenerator,
#     CodeGenerationError,
#     OpCode,
#     generate_bytecode,
# )
import noodlecore.compiler.ast_nodes.(
#     ProgramNode,
#     AssignmentNode,
#     VariableNode,
#     LiteralNode,
#     BinaryOpNode,
#     CallNode,
#     FunctionDefNode,
#     ParameterNode,
#     ReturnNode,
#     IfNode,
#     WhileNode,
#     ForNode,
#     ListNode,
#     MatrixNode,
# )
import noodlecore.compiler.parser_ast_nodes.(
#     ProgramNode as ParserProgramNode,
#     AssignStmtNode,
#     IdentifierExprNode,
#     LiteralExprNode,
#     BinaryExprNode,
#     CallExprNode,
#     FuncDefNode,
#     ReturnStmtNode,
#     IfStmtNode,
#     WhileStmtNode,
#     ForStmtNode,
#     ListExprNode,
# )
import noodlecore.compiler.semantic_analyzer_symbol_table.SymbolTable
import noodlecore.runtime.nbc_runtime.execution.instruction.(
#     Instruction,
#     InstructionType,
# )
import noodlecore.runtime.nbc_runtime.execution.bytecode.(
#     BytecodeProcessor,
#     BytecodeFormat,
# )


class TestCodeGenerator
    #     """Test cases for the Noodle Code Generator"""

    #     def setup_method(self):""Set up test fixtures"""
    self.generator = CodeGenerator()
    self.symbol_table = SymbolTable()
    self.bytecode_processor = BytecodeProcessor()

    #     def test_generate_literal(self):
    #         """Test generating bytecode for literal values"""
    #         # Integer literal
    int_literal = LiteralNode(value=42, literal_type="int")
    instructions = self.generator.generate(int_literal, self.symbol_table)

    assert len(instructions) = = 2  # PUSH constant, HALT
    assert instructions[0].opcode = = "PUSH"
    assert instructions[0].operands[0] = = 0  # Index in constants table
    assert instructions[1].opcode = = "HALT"

    #         # String literal
    str_literal = LiteralNode(value="hello", literal_type="str")
    instructions = self.generator.generate(str_literal, self.symbol_table)

    assert len(instructions) = = 2
    assert instructions[0].opcode = = "PUSH"
    assert instructions[0].operands[0] = = 0  # Index in constants table
    assert instructions[1].opcode = = "HALT"

    #     def test_generate_variable_assignment(self):
    #         """Test generating bytecode for variable assignment"""
    # x = 42
    assignment = AssignmentNode(
    target = VariableNode(name="x"),
    value = LiteralNode(value=42, literal_type="int")
    #         )
    program = ProgramNode(statements=[assignment])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have: PUSH 42, STORE x, HALT
    assert len(instructions) = 3
    assert instructions[0].opcode = = "PUSH"
    assert instructions[1].opcode = = "STORE"
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_binary_operation(self)):
    #         """Test generating bytecode for binary operations"""
    #         # x + y
    binary_op = BinaryOpNode(
    operator = "+",
    left = VariableNode(name="x"),
    right = VariableNode(name="y")
    #         )
    instructions = self.generator.generate(binary_op, self.symbol_table)

    #         # Should have: LOAD x, LOAD y, ADD, HALT
    assert len(instructions) = 4
    assert instructions[0].opcode = = "LOAD"
    assert instructions[1].opcode = = "LOAD"
    assert instructions[2].opcode = = "ADD"
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_function_call(self)):
    #         """Test generating bytecode for function calls"""
            # print("hello")
    call = CallNode(
    function = VariableNode(name="print"),
    arguments = [LiteralNode(value="hello", literal_type="str")]
    #         )
    instructions = self.generator.generate(call, self.symbol_table)

    #         # Should have: PUSH "hello", CALL print, HALT
    assert len(instructions) = 3
    assert instructions[0].opcode = = "PUSH"
    assert instructions[1].opcode = = "CALL"
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_function_definition(self)):
    #         """Test generating bytecode for function definitions"""
    #         # def add(a, b): return a + b
    #         func_def = FunctionDefNode(
    name = "add",
    parameters = [
    ParameterNode(name = "a"),
    ParameterNode(name = "b")
    #             ],
    return_type = None,
    body = [
                    ReturnNode(
    value = BinaryOpNode(
    operator = "+",
    left = VariableNode(name="a"),
    right = VariableNode(name="b")
    #                     )
    #                 )
    #             ]
    #         )
    program = ProgramNode(statements=[func_def])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have function definition with ENTER_FRAME, body, RET, HALT
    #         assert any(instr.opcode == "ENTER_FRAME" for instr in instructions)
    #         assert any(instr.opcode == "RET" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_if_statement(self):
    #         """Test generating bytecode for if statements"""
    #         # if x 0): print("positive")
    if_stmt = IfNode(
    condition = BinaryOpNode(
    operator = ">",
    left = VariableNode(name="x"),
    right = LiteralNode(value=0, literal_type="int")
    #             ),
    then_body = [
                    CallNode(
    function = VariableNode(name="print"),
    arguments = [LiteralNode(value="positive", literal_type="str")]
    #                 )
    #             ],
    else_body = None
    #         )
    program = ProgramNode(statements=[if_stmt])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have condition evaluation, JZ, then body, JMP, HALT
    #         assert any(instr.opcode == "JZ" for instr in instructions)
    #         assert any(instr.opcode == "JMP" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_while_loop(self):
    #         """Test generating bytecode for while loops"""
    #         # while x < 10: x = x + 1
    while_stmt = WhileNode(
    condition = BinaryOpNode(
    operator = "<",
    left = VariableNode(name="x"),
    right = LiteralNode(value=10, literal_type="int")
    #             ),
    body = [
                    AssignmentNode(
    target = VariableNode(name="x"),
    value = BinaryOpNode(
    operator = "+",
    left = VariableNode(name="x"),
    right = LiteralNode(value=1, literal_type="int")
    #                     )
    #                 )
    #             ]
    #         )
    program = ProgramNode(statements=[while_stmt])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have condition evaluation, JZ, body, JMP, HALT
    #         assert any(instr.opcode == "JZ" for instr in instructions)
    #         assert any(instr.opcode == "JMP" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_for_loop(self):
    #         """Test generating bytecode for for loops"""
    #         # for item in items: print(item)
    for_stmt = ForNode(
    variable = VariableNode(name="item"),
    iterable = VariableNode(name="items"),
    body = [
                    CallNode(
    function = VariableNode(name="print"),
    arguments = [VariableNode(name="item")]
    #                 )
    #             ]
    #         )
    program = ProgramNode(statements=[for_stmt])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have iterable setup, loop condition, body, JMP, HALT
    #         assert any(instr.opcode == "JZ" for instr in instructions)
    #         assert any(instr.opcode == "JMP" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_list(self):
    #         """Test generating bytecode for list literals"""
    #         # [1, 2, 3]
    list_node = ListNode(elements=[
    LiteralNode(value = 1, literal_type="int"),
    LiteralNode(value = 2, literal_type="int"),
    LiteralNode(value = 3, literal_type="int")
    #         ])
    instructions = self.generator.generate(list_node, self.symbol_table)

    #         # Should have: CREATE_LIST 3, PUSH elements, APPEND_LIST, HALT
    #         assert any(instr.opcode == "CREATE_LIST" for instr in instructions)
    #         assert any(instr.opcode == "APPEND_LIST" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_generate_matrix(self):
    #         """Test generating bytecode for matrix literals"""
    #         # [[1, 2], [3, 4]]
    matrix_node = MatrixNode(rows=[
    [LiteralNode(value = 1, literal_type="int"), LiteralNode(value=2, literal_type="int")],
    [LiteralNode(value = 3, literal_type="int"), LiteralNode(value=4, literal_type="int")]
    #         ])
    instructions = self.generator.generate(matrix_node, self.symbol_table)

    #         # Should have: MATRIX_ZEROS, element assignments, HALT
    #         assert any(instr.opcode == "MATRIX_ZEROS" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #     def test_parser_ast_compatibility(self):
    #         """Test that the code generator works with parser AST nodes"""
    # x = 42
    assignment = AssignStmtNode(
    target = IdentifierExprNode(name="x"),
    value = LiteralExprNode(value=42, "int")
    #         )
    program = ParserProgramNode()
            program.add_child(assignment)
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Should have: PUSH 42, STORE x, HALT
    assert len(instructions) = 3
    assert instructions[0].opcode = = "PUSH"
    assert instructions[1].opcode = = "STORE"
    assert instructions[-1].opcode = = "HALT"

    #     def test_compile_to_bytecode(self)):
    #         """Test compiling instructions to bytecode"""
    # Simple program: x = 42
    assignment = AssignmentNode(
    target = VariableNode(name="x"),
    value = LiteralNode(value=42, literal_type="int")
    #         )
    program = ProgramNode(statements=[assignment])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Compile to bytecode
    bytecode = self.generator.compile_to_bytecode(instructions)

    #         # Verify bytecode is not empty
            assert len(bytecode) 0

    #         # Verify bytecode can be parsed back
    parsed_program = self.bytecode_processor.parse(bytecode)
    #         assert parsed_program.instructions is not None
            assert len(parsed_program.instructions) > 0

    #     def test_save_bytecode(self)):
    #         """Test saving bytecode to file"""
    # Simple program: x = 42
    assignment = AssignmentNode(
    target = VariableNode(name="x"),
    value = LiteralNode(value=42, literal_type="int")
    #         )
    program = ProgramNode(statements=[assignment])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Save to temporary file
    #         with tempfile.NamedTemporaryFile(delete=False) as tmp:
    tmp_path = tmp.name

    #         try:
                self.generator.save_bytecode(tmp_path, instructions)

    #             # Verify file exists and is not empty
                assert os.path.exists(tmp_path)
                assert os.path.getsize(tmp_path) 0

    #             # Verify bytecode can be read back
    #             with open(tmp_path, "rb") as f):
    bytecode = f.read()

    parsed_program = self.bytecode_processor.parse(bytecode)
    #             assert parsed_program.instructions is not None
                assert len(parsed_program.instructions) 0
    #         finally):
    #             # Clean up
    #             if os.path.exists(tmp_path):
                    os.remove(tmp_path)

    #     def test_generate_bytecode_function(self):
    #         """Test the convenience function generate_bytecode"""
    # Simple program: x = 42
    assignment = AssignmentNode(
    target = VariableNode(name="x"),
    value = LiteralNode(value=42, literal_type="int")
    #         )
    program = ProgramNode(statements=[assignment])
    instructions = generate_bytecode(program, self.symbol_table)

    #         # Verify instructions were generated
    assert len(instructions) = 3
    assert instructions[0].opcode = = "PUSH"
    assert instructions[1].opcode = = "STORE"
    assert instructions[-1].opcode = = "HALT"

    #     def test_error_handling(self)):
    #         """Test error handling in code generation"""
    #         # Test with invalid AST node
    #         with pytest.raises(Exception):
                self.generator.generate(None, self.symbol_table)

    #     def test_reset(self):
    #         """Test resetting the code generator state"""
    #         # Generate some code
    assignment = AssignmentNode(
    target = VariableNode(name="x"),
    value = LiteralNode(value=42, literal_type="int")
    #         )
            self.generator.generate(assignment, self.symbol_table)

    #         # Verify state is not empty
            assert len(self.generator.bytecode) 0
    assert len(self.generator.constants) > = 1
    assert len(self.generator.local_vars) > = 1

    #         # Reset
            self.generator.reset()

    #         # Verify state is empty
    assert len(self.generator.bytecode) = = 0
    assert len(self.generator.constants) = = 0
    assert len(self.generator.local_vars) = = 0
    assert len(self.generator.labels) = = 0
    assert len(self.generator.label_refs) = = 0
    assert self.generator.next_offset = 0
    assert self.generator.current_scope_depth = 0
    assert len(self.generator.function_stack) = = 0
    assert len(self.generator.loop_stack) = = 0

    #     def test_complex_program(self)):
    #         """Test generating bytecode for a more complex program"""
    #         # def fibonacci(n):
    #         #     if n <= 1:
    #         #         return n
    #         #     else:
            #         return fibonacci(n-1) + fibonacci(n-2)
    #         #
    # result = fibonacci(10)
    fibonacci_func = FunctionDefNode(
    name = "fibonacci",
    parameters = [ParameterNode(name="n")],
    return_type = None,
    body = [
                    IfNode(
    condition = BinaryOpNode(
    operator = "<=",
    left = VariableNode(name="n"),
    right = LiteralNode(value=1, literal_type="int")
    #                     ),
    then_body = [ReturnNode(value=VariableNode(name="n"))],
    else_body = [
                            ReturnNode(
    value = BinaryOpNode(
    operator = "+",
    left = CallNode(
    function = VariableNode(name="fibonacci"),
    arguments = [
                                            BinaryOpNode(
    operator = "-",
    left = VariableNode(name="n"),
    right = LiteralNode(value=1, literal_type="int")
    #                                         )
    #                                     ]
    #                                 ),
    right = CallNode(
    function = VariableNode(name="fibonacci"),
    arguments = [
                                            BinaryOpNode(
    operator = "-",
    left = VariableNode(name="n"),
    right = LiteralNode(value=2, literal_type="int")
    #                                         )
    #                                     ]
    #                                 )
    #                             )
    #                         )
    #                     ]
    #                 )
    #             ]
    #         )

    result_assignment = AssignmentNode(
    target = VariableNode(name="result"),
    value = CallNode(
    function = VariableNode(name="fibonacci"),
    arguments = [LiteralNode(value=10, literal_type="int")]
    #             )
    #         )

    program = ProgramNode(statements=[fibonacci_func, result_assignment])
    instructions = self.generator.generate(program, self.symbol_table)

    #         # Verify key instructions are present
    #         assert any(instr.opcode == "ENTER_FRAME" for instr in instructions)
    #         assert any(instr.opcode == "RET" for instr in instructions)
    #         assert any(instr.opcode == "JZ" for instr in instructions)
    #         assert any(instr.opcode == "JMP" for instr in instructions)
    #         assert any(instr.opcode == "CALL" for instr in instructions)
    assert instructions[-1].opcode = = "HALT"

    #         # Compile to bytecode and verify it can be parsed
    bytecode = self.generator.compile_to_bytecode(instructions)
    parsed_program = self.bytecode_processor.parse(bytecode)
    #         assert parsed_program.instructions is not None
            assert len(parsed_program.instructions) > 0