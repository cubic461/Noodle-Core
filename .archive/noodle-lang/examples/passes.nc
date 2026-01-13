# Converted from Python to NoodleCore
# Original file: src

import typing.Dict

import .ir.AddOp


class Pass
    #     def run(self, module: Module) -Module):
    #         raise NotImplementedError


class ConstantFoldingPass(Pass)
    #     def run(self, module: Module) -Module):
    new_blocks = []
    #         for block in module.blocks:
    new_ops = []
    #             for op in block.operations:
    #                 if isinstance(op, AddOp) and all(
    #                     isinstance(operand.op, ConstantOp) for operand in op.operands
    #                 ):
    #                     # Fold constants: lhs.value + rhs.value
    lhs_val = (
    #                         op.operands[0].op.attributes[0].value
    #                         if op.operands[0].op.attributes
    #                         else 0
    #                     )
    rhs_val = (
    #                         op.operands[1].op.attributes[0].value
    #                         if op.operands[1].op.attributes
    #                         else 0
    #                     )
    folded_type = op.operands[0].type
    folded_op = ConstantOp(lhs_val + rhs_val, folded_type, op.location)
                        new_ops.append(folded_op)
    #                     # Update uses to point to folded value
    #                     for result in op.results:
    result.op = folded_op
    #                 else:
                        new_ops.append(op)
    new_block = Block(operations=new_ops, arguments=block.arguments)
                new_blocks.append(new_block)
    module.blocks = new_blocks
    #         return module


class DeadCodeElimPass(Pass)
    #     def run(self, module: Module) -Module):
    #         # Track uses: Value → count of references
    uses: Dict[Value, int] = {}

    #         def count_uses(op: Operation):
    #             for operand in op.operands:
    #                 if operand in uses:
    uses[operand] + = 1
    #                 else:
    uses[operand] = 1
    #             for result in op.results:
    uses[result] = 0  # Self - use not counted

    #         for block in module.blocks:
    #             for op in block.operations:
                    count_uses(op)

    new_blocks = []
    #         for block in module.blocks:
    kept_ops = [
    #                 op
    #                 for op in block.operations
    #                 if any(uses.get(result, 0) > 0 for result in op.results)
    #             ]
    new_block = Block(operations=kept_ops, arguments=block.arguments)
                new_blocks.append(new_block)
    module.blocks = new_blocks
    #         return module
