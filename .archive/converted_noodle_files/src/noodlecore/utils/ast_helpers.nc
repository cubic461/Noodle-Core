# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# AST Helpers for NoodleCore

# This module provides AST helper functions for NoodleCore (.nc) files.
# """

function process_conditional(builder, expr, true_block, false_block)
    #     """
    #     Process conditional expressions in NoodleCore AST.

    #     Args:
    #         builder: IR builder instance
    #         expr: Expression to evaluate
    #         true_block: Block to execute if expression is true
    #         false_block: Block to execute if expression is false

    #     Returns:
    #         None
    #     """
    #     # Simplified implementation for NoodleCore
    #     if hasattr(expr, 'op') and expr.op in ["and", "or"]:
    #         if expr.op == "and":
    #             # Short circuit 'and' in a conditional context
    new_block = builder.BasicBlock()
                process_conditional(builder, expr.left, new_block, false_block)
                builder.activate_block(new_block)
                process_conditional(builder, expr.right, true_block, false_block)
    #         else:
    #             # Short circuit 'or' in a conditional context
    new_block = builder.BasicBlock()
                process_conditional(builder, expr.left, true_block, new_block)
                builder.activate_block(new_block)
                process_conditional(builder, expr.right, true_block, false_block)
    #     elif hasattr(expr, 'op') and expr.op == "not":
            process_conditional(builder, expr.expr, false_block, true_block)
    #     else:
    #         # Catch-all for arbitrary expressions
    reg = builder.accept(expr)
            builder.add_bool_branch(reg, true_block, false_block)


function is_borrow_friendly_expr(builder, expr)
    #     """
    #     Check if expression result can be borrowed temporarily.

    #     Args:
    #         builder: IR builder instance
    #         expr: Expression to check

    #     Returns:
    #         bool: True if expression can be borrowed
    #     """
    #     # Simplified implementation for NoodleCore
    #     if hasattr(expr, '__class__'):
    #         expr_class = expr.__class__.__name__
    #         if expr_class in ['IntExpr', 'FloatExpr', 'StrExpr', 'BytesExpr']:
    #             # Literals are immortal and can always be borrowed
    #             return True
    #         if expr_class in ['UnaryExpr', 'OpExpr', 'NameExpr', 'MemberExpr']:
    #             # Check if expression can be constant folded
    #             if hasattr(builder, 'constant_fold_expr'):
    #                 try:
    #                     if builder.constant_fold_expr(expr) is not None:
    #                         return True
    #                 except:
    #                     pass
    #             return True
    #         if expr_class == 'NameExpr':
    #             if hasattr(expr, 'node'):
    #                 # Local variable reference can be borrowed
    #                 return True
    #         if expr_class == 'MemberExpr':
    #             if hasattr(builder, 'is_native_attr_ref'):
    #                 if builder.is_native_attr_ref(expr):
    #                     return True

    #     return False