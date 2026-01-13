# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# TRM (Tiny Recursive Model) Module for NoodleCore
 = ==============================================

# This module provides native TRM implementation within NoodleCore,
# avoiding the Python async/sync issues that plagued our previous attempts.

# The implementation includes:
# - Type system for TRM networks
# - Core TRM execution engine
# - Integration with NoodleCore IR
# - Training and inference capabilities
# - Compiler integration for seamless Python support
# """

import .trm_types.(
#     TRMNetwork,
#     TRMLayer,
#     TRMRecursiveFunction,
#     TRMParameter,
#     TRMLatentState,
#     TRMNode,
#     TRMActivationFunction,
#     TRMNodeType,
#     TRMTrainingConfig,
#     TRMInferenceConfig,
#     TRMIRBuilder,
#     convert_noodle_type_to_trm,
#     convert_trm_type_to_noodle,
#     create_trm_parameter_from_ir
# )

import .trm_core.TRMCore

import .trm_transpiler.TRMTranspiler,

import .trm_compiler_integration.(
#     TRMCompilerIntegration,
#     create_trm_integrated_compiler,
#     compile_with_trm,
#     validate_trm_code,
#     get_trm_compilation_stats
# )

import .trm_training.(
#     TRMTrainer,
#     TRMTrainingManager,
#     TrainingMetrics,
#     TrainingHistory,
#     train_trm_model,
#     train_trm_model_async
# )

__all__ = [
#     # Types
#     "TRMNetwork",
#     "TRMLayer",
#     "TRMRecursiveFunction",
#     "TRMParameter",
#     "TRMLatentState",
#     "TRMNode",
#     "TRMActivationFunction",
#     "TRMNodeType",
#     "TRMTrainingConfig",
#     "TRMInferenceConfig",
#     "TRMIRBuilder",

#     # Utilities
#     "convert_noodle_type_to_trm",
#     "convert_trm_type_to_noodle",
#     "create_trm_parameter_from_ir",

#     # Core
#     "TRMCore",

#     # Transpiler
#     "TRMTranspiler",
#     "transpile_python_to_trm",
#     "transpile_python_to_ir",
#     "validate_trm_transpilation",

#     # Compiler Integration
#     "TRMCompilerIntegration",
#     "create_trm_integrated_compiler",
#     "compile_with_trm",
#     "validate_trm_code",
#     "get_trm_compilation_stats",

#     # Training
#     "TRMTrainer",
#     "TRMTrainingManager",
#     "TrainingMetrics",
#     "TrainingHistory",
#     "train_trm_model",
#     "train_trm_model_async"
# ]
