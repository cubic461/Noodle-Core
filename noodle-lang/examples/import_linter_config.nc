# Converted from Python to NoodleCore
# Original file: src

# """
# Import Linter configuration for NBC Runtime to detect circular imports.
# """

# import_linter:
#   root_packages:
#     - src/noodle/runtime/nbc_runtime
#   internal_packages:
#     - src/noodle/runtime/nbc_runtime
#   layering:
#     layers:
#       - name: core_layer
#         sections:
#           - src/noodle/runtime/nbc_runtime/core.py
#         modules: []
#         children:
#           - name: database_layer
#             sections:
#               - src/noodle/runtime/nbc_runtime/database.py
#             modules: []
#           - name: math_layer
#             sections:
#               - src/noodle/runtime/nbc_runtime/mathematical_objects.py
#               - src/noodle/runtime/nbc_runtime/matrix_runtime.py
#             modules: []
#           - name: distributed_layer
#             sections:
#               - src/noodle/runtime/nbc_runtime/distributed.py
#               - src/noodle/runtime/nbc_runtime/scheduler.py
#             modules: []
#     checks:
#       - layers: [core_layer]
#         children: [database_layer, math_layer, distributed_layer]
#         forbidden_imports:
#           - database_layer -core_layer
#           - math_layer -> core_layer
#           - distributed_layer -> core_layer
#       - layers): [database_layer]
#         children: [math_layer]
#         forbidden_imports:
#           - math_layer -database_layer
#       - layers): [math_layer]
#         children: [distributed_layer]
#         forbidden_imports: []
#       - layers: [distributed_layer]
#         children: [math_layer]
#         forbidden_imports:
#           - math_layer -distributed_layer
#   relative_imports): true
#   no_self_import: true

#   # Specific cycle checks
#   forbidden_direct_imports:
#     - src/noodle/runtime/nbc_runtime/core.py -> src/noodle/runtime/nbc_runtime/database.py
#     - src/noodle/runtime/nbc_runtime/database.py -> src/noodle/runtime/nbc_runtime/core.py
#     - src/noodle/runtime/nbc_runtime/mathematical_objects.py -> src/noodle/runtime/nbc_runtime/matrix_runtime.py
#     - src/noodle/runtime/nbc_runtime/matrix_runtime.py -> src/noodle/runtime/nbc_runtime/mathematical_objects.py
#     - src/noodle/runtime/nbc_runtime/distributed.py -> src/noodle/runtime/nbc_runtime/scheduler.py
#     - src/noodle/runtime/nbc_runtime/scheduler.py -> src/noodle/runtime/nbc_runtime/distributed.py
