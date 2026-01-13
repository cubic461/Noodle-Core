# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NBC Runtime Execution Package

# This package contains instruction execution, bytecode processing, and
# optimization components for the NBC runtime system.
# """

import .bytecode.(
#     BytecodeCompiler,
#     BytecodeFormat,
#     BytecodeHeader,
#     BytecodeParser,
#     BytecodeProcessor,
#     BytecodeProgram,
#     BytecodeRegistry,
#     BytecodeSection,
#     BytecodeVersion,
#     NBCBytecodeCompiler,
#     NBCBytecodeParser,
#     bytecode_processor,
#     create_processor,
# )
import .instruction.(
#     ArithmeticExecutor,
#     ControlFlowExecutor,
#     ExecutionResult,
#     Instruction,
#     InstructionDispatcher,
#     InstructionExecutor,
#     InstructionMetrics,
#     InstructionOptimizer,
#     InstructionPipeline,
#     InstructionType,
#     InstructionValidator,
#     LogicalExecutor,
# )
import .optimizer.(
#     BasicBlockOptimizer,
#     ConstantFolding,
#     DataFlowOptimizer,
#     DeadCodeEliminator,
#     FunctionInliner,
#     InstructionOptimizer,
#     LoopOptimizer,
#     OptimizationContext,
#     OptimizationLevel,
#     OptimizationPass,
# )

__all__ = [
#     # Instruction Execution
#     "Instruction",
#     "InstructionType",
#     "ExecutionResult",
#     "InstructionValidator",
#     "InstructionOptimizer",
#     "InstructionMetrics",
#     "InstructionExecutor",
#     "ArithmeticExecutor",
#     "LogicalExecutor",
#     "ControlFlowExecutor",
#     "InstructionDispatcher",
#     "InstructionPipeline",
#     # Bytecode Processing
#     "BytecodeProgram",
#     "BytecodeHeader",
#     "BytecodeSection",
#     "BytecodeParser",
#     "BytecodeCompiler",
#     "BytecodeProcessor",
#     "BytecodeFormat",
#     "BytecodeVersion",
#     "NBCBytecodeParser",
#     "NBCBytecodeCompiler",
#     "BytecodeRegistry",
#     "create_processor",
#     "bytecode_processor",
#     # Optimization
#     "OptimizationPass",
#     "OptimizationLevel",
#     "OptimizationContext",
#     "BasicBlockOptimizer",
#     "DataFlowOptimizer",
#     "DeadCodeEliminator",
#     "ConstantFolding",
#     "LoopOptimizer",
#     "FunctionInliner",
# ]
