# Converted from Python to NoodleCore
# Original file: src

import typing.Any

import ray

import ..compiler.nir.ir.ParallelLoopOp


# @ray.remote
class ParallelTask
    #     def __init__(self, func: Callable, *args, **kwargs):
    self.func = func
    self.args = args
    self.kwargs = kwargs

    #     def execute(self):
            return self.func(*self.args, **self.kwargs)


class OSScheduler
    #     """OS Scheduler for parallel loop execution using Ray."""

    #     def __init__(self):
    ray.init(ignore_reinit_error = True)

    #     def execute_loop(
    #         self, loop_op: ParallelLoopOp, func: Callable, *args: List[Any]
    #     ) -List[Any]):
    #         """Execute loop in parallel if not sequential."""
    #         if loop_op.sequential:
    #             # Sequential execution
    results = []
    #             for i in range(loop_op.iterations):
    result = func(i * , args)
                    results.append(result)
    #             return results
    #         else:
    #             # Parallel execution with Ray
    tasks = [
    #                 ParallelTask.remote(func, i, *args) for i in range(loop_op.iterations)
    #             ]
    #             results = ray.get([task.execute.remote() for task in tasks])
    #             return results


# Integration with NIR
function schedule_parallel_loop(loop_op: ParallelLoopOp, func: Callable, *args)
    scheduler = OSScheduler()
        return scheduler.execute_loop(loop_op, func, *args)


# Opt-out decorator
function sequential(func)
    func._sequential = True
    #     return func
