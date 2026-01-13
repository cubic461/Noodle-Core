# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Standalone cost_model.py for backend selection based on learned preferences.
# Used by ai_optimizer for updates.
# """

import typing.Any,


class CostModel
    #     def __init__(self):
    self.preferences: Dict[str, str] = {
    #             "agg": "sql",
    #             "matrix": "matrix",
    #         }  # op_type -> preferred_backend

    #     def get_preferred_backend(
    self, op_type: str, query_params: Dict[str, Any] = None
    #     ) -> str:
    #         """
    #         Get preferred backend for op_type, fallback to 'sql'.
    #         Future: Use query_params for dynamic cost calculation.
    #         """
            return self.preferences.get(op_type, "sql")

    #     def update_preference(self, op_type: str, backend: str):
    #         """
    #         Update learned preference for op_type.
    #         """
    self.preferences[op_type] = backend


# Global instance for module use
cost_model = CostModel()
