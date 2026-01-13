# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Instruction Encoding for Noodle Programming Language
# ----------------------------------------------------
# This module implements instruction encoding for the Noodle code generator.
# It serializes bytecode instructions to executable bytes.

# Created and designed by Michael van Erp, the inventor of the Noodle language and Noodle-ide.
# Date: 25-09-2025
# Location: Hellevoetsluis, Nederland
# """

import struct
import typing.List,
import .code_generator_opcodes.OpCode,


class InstructionEncoder
    #     """Encodes bytecode instructions to executable bytes"""

    #     def __init__(self):
    self.bytecode: List[BytecodeInstruction] = []
    self.constants: List[Any] = []

    #     def encode_bytecode(self, bytecode: List[BytecodeInstruction], constants: List[Any] = None) -> bytes:
    #         """
    #         Encode bytecode instructions to executable bytes.

    #         Args:
    #             bytecode: List of BytecodeInstructions
    #             constants: Optional constants pool

    #         Returns:
    #             bytes: Encoded bytecode
    #         """
    self.bytecode = bytecode
    self.constants = constants or []

    #         # Encode all instructions
    bc_bytes = b""
    #         for instr in self.bytecode:
    bc_bytes + = instr.encode()

    #         # Add constants pool
    const_data = self._encode_constants()

    #         return bc_bytes + const_data

    #     def _encode_constants(self) -> bytes:
    #         """Encode the constants pool"""
    const_header = struct.pack("<H", len(self.constants))
    const_data = b""

    #         for const in self.constants:
    #             if isinstance(const, (int, float)):
    const_data + = struct.pack(
    #                     "d" if isinstance(const, float) else "q", const
    #                 )
    #             elif isinstance(const, str):
    b = const.encode("utf-8")
    const_data + = len(b).to_bytes(2, "little") + b
    #             elif const is None:
    const_data + = b"\xff"  # Nil marker
    #             elif isinstance(const, bool):
    #                 const_data += bytes([1 if const else 0])
    #             else:
                    raise TypeError(f"Unsupported constant type: {type(const)}")

    #         return const_header + const_data

    #     def get_bytecode_bytes(self) -> bytes:
    #         """Get raw bytecode bytes without constants"""
    bc_bytes = b""
    #         for instr in self.bytecode:
    bc_bytes + = instr.encode()
    #         return bc_bytes

    #     def get_constants_bytes(self) -> bytes:
    #         """Get constants bytes"""
            return self._encode_constants()

    #     def encode_single_instruction(self, instr: BytecodeInstruction) -> bytes:
    #         """Encode a single instruction"""
            return instr.encode()

    #     def decode_instruction(self, data: bytes, offset: int = 0) -> tuple:
    #         """
    #         Decode a single instruction from bytes.

    #         Args:
    #             data: Byte data
    #             offset: Starting offset

    #         Returns:
                tuple: (instruction, new_offset)
    #         """
    #         if offset >= len(data):
                raise ValueError("Offset out of bounds")

            # Read opcode (1 byte)
    opcode_value = data[offset]
    offset + = 1

            # Read operand count (1 byte)
    operand_count = data[offset]
    offset + = 1

    #         # Read operands
    operands = []
    #         for i in range(operand_count):
    #             if offset >= len(data):
                    raise ValueError("Unexpected end of data")

    #             # Determine operand type based on opcode
    opcode = OpCode(opcode_value)
    operand = self._decode_operand(data, offset, opcode)
                operands.append(operand)
    offset + = self._get_operand_size(operand)

    #         # Create instruction
    instr = BytecodeInstruction(opcode, operands)
    #         return instr, offset

    #     def _decode_operand(self, data: bytes, offset: int, opcode: OpCode) -> Any:
    #         """Decode a single operand based on its type"""
            # For now, assume all operands are integers (4 bytes)
    #         # This should be extended based on operand types
    #         if offset + 4 > len(data):
    #             raise ValueError("Insufficient data for operand")

    value = int.from_bytes(data[offset:offset+4], "little", signed=True)
    #         return value

    #     def _get_operand_size(self, operand: Any) -> int:
    #         """Get the size of an operand in bytes"""
    #         if isinstance(operand, int):
    #             return 4
    #         elif isinstance(operand, float):
    #             return 8
    #         elif isinstance(operand, str):
    #             # 2 bytes for length + string bytes
                return 2 + len(operand.encode("utf-8"))
    #         elif isinstance(operand, bool):
    #             return 1
    #         else:
    #             return 4  # Default size

    #     def serialize_to_file(self, filename: str, bytecode: List[BytecodeInstruction], constants: List[Any] = None):
    #         """
    #         Serialize bytecode to a file.

    #         Args:
    #             filename: Output filename
    #             bytecode: List of BytecodeInstructions
    #             constants: Optional constants pool
    #         """
    data = self.encode_bytecode(bytecode, constants)
    #         with open(filename, "wb") as f:
                f.write(data)

    #     @staticmethod
    #     def deserialize_from_file(filename: str) -> tuple:
    #         """
    #         Deserialize bytecode from a file.

    #         Args:
    #             filename: Input filename

    #         Returns:
                tuple: (bytecode, constants)
    #         """
    #         with open(filename, "rb") as f:
    data = f.read()

            return InstructionEncoder.deserialize_from_bytes(data)

    #     @staticmethod
    #     def deserialize_from_bytes(data: bytes) -> tuple:
    #         """
    #         Deserialize bytecode from bytes.

    #         Args:
    #             data: Byte data

    #         Returns:
                tuple: (bytecode, constants)
    #         """
    # Extract constants pool (last 2 bytes = count, then constants)
    const_count = int.from_bytes(data[-2:], "little")
    const_data = math.multiply(data[-2-const_count, 8:]  # Simplified - should match encoding)

            # Extract bytecode (everything before constants)
    bytecode_data = math.multiply(data[:-2-const_count, 8])

    #         # This is a simplified deserialization
    #         # Real implementation would need to parse instructions properly
    bytecode = []
    offset = 0
    encoder = InstructionEncoder()

    #         while offset < len(bytecode_data):
    #             try:
    instr, new_offset = encoder.decode_instruction(bytecode_data, offset)
                    bytecode.append(instr)
    offset = new_offset
    #             except ValueError:
    #                 break

    #         return bytecode, []