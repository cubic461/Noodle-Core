# Converted from Python to NoodleCore
# Original file: src

# """
# Backward Compatibility Wrappers
# --------------------------------
# This module provides backward compatibility wrappers for functions that were renamed
# during the naming convention standardization process.
# """

import warnings
import typing.Any

import .core.NBCRuntime
import .instructions.InstructionHandler
import .mathematical_objects.(
#     MathematicalObject,
#     Matrix,
#     ObjectType,
#     SimpleMathematicalObject,
#     Tensor,
#     create_mathematical_object,
#     get_mathematical_object_type,
# )


class BackwardCompatibility
    #     """Backward compatibility wrapper for renamed functions and methods."""

    #     @staticmethod
    #     def warn_deprecation(old_name: str, new_name: str):""Issue a deprecation warning."""
            warnings.warn(
    #             f"'{old_name}' is deprecated and will be removed in a future version. "
    #             f"Use '{new_name}' instead.",
    #             DeprecationWarning,
    stacklevel = 3,
    #         )

    #     # NBC Runtime Core compatibility
    #     @staticmethod
    #     def init_python_ffi(runtime: NBCRuntime) -None):
    #         """Backward compatibility for _init_python_ffi."""
            BackwardCompatibility.warn_deprecation("init_python_ffi", "_init_python_ffi")
            runtime._init_python_ffi()

    #     @staticmethod
    #     def init_matrix_runtime(runtime: NBCRuntime) -None):
    #         """Backward compatibility for _init_matrix_runtime."""
            BackwardCompatibility.warn_deprecation(
    #             "init_matrix_runtime", "_init_matrix_runtime"
    #         )
            runtime._init_matrix_runtime()

    #     @staticmethod
    #     def init_mathematical_objects(runtime: NBCRuntime) -None):
    #         """Backward compatibility for _init_mathematical_objects."""
            BackwardCompatibility.warn_deprecation(
    #             "init_mathematical_objects", "_init_mathematical_objects"
    #         )
            runtime._init_mathematical_objects()

    #     @staticmethod
    #     def init_tensor_system(runtime: NBCRuntime) -None):
    #         """Backward compatibility for _init_tensor_system."""
            BackwardCompatibility.warn_deprecation(
    #             "init_tensor_system", "_init_tensor_system"
    #         )
            runtime._init_tensor_system()

    #     # Instruction Handler compatibility
    #     @staticmethod
    #     def op_tensor_create(
    #         handler: InstructionHandler,
    #         tensor_id: str,
    #         shape: tuple,
    #         data: Any,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_create."""
            BackwardCompatibility.warn_deprecation("op_tensor_create", "_op_tensor_create")
            return handler._op_tensor_create(tensor_id, shape, data, debug)

    #     @staticmethod
    #     def op_distributed_allreduce(
    #         handler: InstructionHandler,
    #         tensor_id: str,
    operation: str = "sum",
    security_enabled: bool = True,
    #     ) -str):
    #         """Backward compatibility for op_distributed_allreduce."""
            BackwardCompatibility.warn_deprecation(
    #             "op_distributed_allreduce", "_op_distributed_allreduce"
    #         )
            return handler._op_distributed_allreduce(tensor_id, operation, security_enabled)

    #     @staticmethod
    #     def op_matrix_multiply(
    #         handler: InstructionHandler,
    #         matrix_a_id: str,
    #         matrix_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_matrix_multiply."""
            BackwardCompatibility.warn_deprecation(
    #             "op_matrix_multiply", "_op_matrix_multiply"
    #         )
            return handler._op_matrix_multiply(matrix_a_id, matrix_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_add(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_add."""
            BackwardCompatibility.warn_deprecation("op_tensor_add", "_op_tensor_add")
            return handler._op_tensor_add(tensor_a_id, tensor_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_subtract(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_subtract."""
            BackwardCompatibility.warn_deprecation(
    #             "op_tensor_subtract", "_op_tensor_subtract"
    #         )
            return handler._op_tensor_subtract(tensor_a_id, tensor_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_multiply(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_multiply."""
            BackwardCompatibility.warn_deprecation(
    #             "op_tensor_multiply", "_op_tensor_multiply"
    #         )
            return handler._op_tensor_multiply(tensor_a_id, tensor_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_divide(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_divide."""
            BackwardCompatibility.warn_deprecation("op_tensor_divide", "_op_tensor_divide")
            return handler._op_tensor_divide(tensor_a_id, tensor_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_transpose(
    handler: InstructionHandler, tensor_id: str, result_id: str, debug: bool = False
    #     ) -str):
    #         """Backward compatibility for op_tensor_transpose."""
            BackwardCompatibility.warn_deprecation(
    #             "op_tensor_transpose", "_op_tensor_transpose"
    #         )
            return handler._op_tensor_transpose(tensor_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_dot(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_dot."""
            BackwardCompatibility.warn_deprecation("op_tensor_dot", "_op_tensor_dot")
            return handler._op_tensor_dot(tensor_a_id, tensor_b_id, result_id, debug)

    #     @staticmethod
    #     def op_tensor_contract(
    #         handler: InstructionHandler,
    #         tensor_a_id: str,
    #         tensor_b_id: str,
    #         result_id: str,
    #         axes: tuple,
    debug: bool = False,
    #     ) -str):
    #         """Backward compatibility for op_tensor_contract."""
            BackwardCompatibility.warn_deprecation(
    #             "op_tensor_contract", "_op_tensor_contract"
    #         )
            return handler._op_tensor_contract(
    #             tensor_a_id, tensor_b_id, result_id, axes, debug
    #         )

    #     # Mathematical Objects compatibility
    #     @staticmethod
    #     def create_math_object(
    obj_type: ObjectType, data: Any, context: Optional[Dict[str, Any]] = None
    #     ) -MathematicalObject):
    #         """Backward compatibility for create_mathematical_object."""
            BackwardCompatibility.warn_deprecation(
    #             "create_math_object", "create_mathematical_object"
    #         )
            return create_mathematical_object(obj_type, data, context)

    #     @staticmethod
    #     def get_math_object_type(obj: MathematicalObject) -ObjectType):
    #         """Backward compatibility for get_mathematical_object_type."""
            BackwardCompatibility.warn_deprecation(
    #             "get_math_object_type", "get_mathematical_object_type"
    #         )
            return get_mathematical_object_type(obj)

    #     # Database Query Interface compatibility
    #     @staticmethod
    #     def execute_query(
    interface: Any, query: str, params: Optional[Dict[str, Any]] = None
    #     ) -Any):
    #         """Backward compatibility for execute_query with renamed parameters."""
            BackwardCompatibility.warn_deprecation("execute_query", "execute_query")
            return interface.execute_query(query, params)

    #     # Distributed Scheduler compatibility
    #     @staticmethod
    #     def submit_task(scheduler: Any, task: Any) -str):
    #         """Backward compatibility for submit_task with renamed parameters."""
            BackwardCompatibility.warn_deprecation("submit_task", "submit_task")
            return scheduler.submit_task(task)

    #     @staticmethod
    #     def get_task_result(
    scheduler: Any, task_id: str, timeout: Optional[float] = None
    #     ) -Any):
    #         """Backward compatibility for get_task_result with renamed parameters."""
            BackwardCompatibility.warn_deprecation("get_task_result", "get_task_result")
            return scheduler.get_task_result(task_id, timeout)

    #     @staticmethod
    #     def cancel_task(scheduler: Any, task_id: str) -bool):
    #         """Backward compatibility for cancel_task with renamed parameters."""
            BackwardCompatibility.warn_deprecation("cancel_task", "cancel_task")
            return scheduler.cancel_task(task_id)

    #     @staticmethod
    #     def get_system_status(scheduler: Any) -Dict[str, Any]):
    #         """Backward compatibility for get_system_status with renamed parameters."""
            BackwardCompatibility.warn_deprecation("get_system_status", "get_system_status")
            return scheduler.get_system_status()

    #     # Placement Engine compatibility
    #     @staticmethod
    #     def place_tensor(
    #         placement_engine: Any,
    #         tensor_id: str,
    constraints: Optional[List[Any]] = None,
    strategy: Optional[Any] = None,
    preferred_nodes: Optional[List[str]] = None,
    #     ) -Dict[str, Any]):
    #         """Backward compatibility for place_tensor with renamed parameters."""
            BackwardCompatibility.warn_deprecation("place_tensor", "place_tensor")
            return placement_engine.place_tensor(
    #             tensor_id, constraints, strategy, preferred_nodes
    #         )

    #     @staticmethod
    #     def place_matrix(
    #         placement_engine: Any,
    #         matrix_id: str,
    constraints: Optional[List[Any]] = None,
    strategy: Optional[Any] = None,
    preferred_nodes: Optional[List[str]] = None,
    #     ) -Dict[str, Any]):
    #         """Backward compatibility for place_matrix with renamed parameters."""
            BackwardCompatibility.warn_deprecation("place_matrix", "place_matrix")
            return placement_engine.place_matrix(
    #             matrix_id, constraints, strategy, preferred_nodes
    #         )

    #     @staticmethod
    #     def get_placement_stats(placement_engine: Any) -Dict[str, float]):
    #         """Backward compatibility for get_placement_stats with renamed parameters."""
            BackwardCompatibility.warn_deprecation(
    #             "get_placement_stats", "get_placement_stats"
    #         )
            return placement_engine.get_placement_stats()

    #     @staticmethod
    #     def optimize_placement(
    #         placement_engine: Any,
    #         tensor_id: str,
    constraints: Optional[List[Any]] = None,
    strategy: Optional[Any] = None,
    #     ) -Dict[str, float]):
    #         """Backward compatibility for optimize_placement with renamed parameters."""
            BackwardCompatibility.warn_deprecation(
    #             "optimize_placement", "optimize_placement"
    #         )
            return placement_engine.optimize_placement(tensor_id, constraints, strategy)
