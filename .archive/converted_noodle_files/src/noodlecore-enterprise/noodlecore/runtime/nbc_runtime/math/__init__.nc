# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# NBC Runtime Mathematical Objects Package

# This package contains mathematical objects, matrix operations, and
# category theory implementations for the NBC runtime system.
# """

import ..core.runtime.NBCRuntimeError,
import ..execution.BytecodeProgram,
import ..mathematical_objects.create_mathematical_object
import .category_theory.(
#     Applicative,
#     Category,
#     CategoryTheoryRegistry,
#     ComposedFunctor,
#     Composition,
#     FunctionCategory,
#     Functor,
#     Identity,
#     ListFunctor,
#     MaybeFunctor,
#     Morphism,
#     NaturalTransformation,
#     SetCategory,
#     StateMonad,
# )
import .matrix_ops.(
#     MatrixBackend,
#     MatrixBackendInterface,
#     MatrixOperation,
#     MatrixOperationResult,
#     MatrixOperationsManager,
#     NumPyBackend,
#     create_matrix_manager,
#     matrix_add,
#     matrix_determinant,
#     matrix_inverse,
#     matrix_multiply,
#     matrix_norm,
#     matrix_subtract,
#     matrix_transpose,
# )
import .objects.(
#     Actor,
#     Function,
#     MathematicalObject,
#     MathematicalObjectMapper,
#     MathematicalProperties,
#     MathematicalProperty,
#     Matrix,
#     ObjectType,
#     Scalar,
#     Table,
#     Tensor,
#     Vector,
# )

__all__ = [
#     # Mathematical Objects
#     "MathematicalObject",
#     "Scalar",
#     "Vector",
#     "Matrix",
#     "Tensor",
#     "Table",
#     "Actor",
#     "ObjectType",
#     "MathematicalProperty",
#     "MathematicalObjectMapper",
#     "MathematicalProperties",
#     "Function",
#     # Matrix Operations
#     "MatrixOperationsManager",
#     "MatrixBackend",
#     "MatrixOperation",
#     "MatrixOperationResult",
#     "MatrixBackendInterface",
#     "NumPyBackend",
#     "create_matrix_manager",
#     "matrix_multiply",
#     "matrix_add",
#     "matrix_subtract",
#     "matrix_transpose",
#     "matrix_inverse",
#     "matrix_determinant",
#     "matrix_norm",
#     # Category Theory
#     "Functor",
#     "NaturalTransformation",
#     "Category",
#     "Applicative",
#     "ComposedFunctor",
#     "ListFunctor",
#     "MaybeFunctor",
#     "StateMonad",
#     "SetCategory",
#     "FunctionCategory",
#     "CategoryTheoryRegistry",
#     # Execution components re-exported for convenience
#     "BytecodeProgram",
#     "Instruction",
#     "InstructionType",
#     "create_mathematical_object",
#     # Error classes
#     "SerializationError",
# ]
