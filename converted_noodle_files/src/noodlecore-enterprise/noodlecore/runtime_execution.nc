# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Runtime Execution for Noodle Language
# -------------------------------------
# Provides the execution logic for statements and expressions.
# """

import typing.Any,
import .runtime_types.Value,
import .runtime_stack.StackFrame,
import .runtime_values.ValueOperations,


class StatementExecutor
    #     """Executes statements in the runtime"""

    #     def __init__(self, runtime: "RuntimeEnvironment"):
    self.runtime = runtime

    #     def execute_statement(self, statement: Any, frame: StackFrame) -> Optional[Value]:
    #         """Execute a single statement"""
    #         if isinstance(statement, dict):
    stmt_type = statement.get('type')

    #             if stmt_type == 'expression':
                    return self.execute_expression(statement['value'], frame)
    #             elif stmt_type == 'assignment':
                    return self.execute_assignment(statement, frame)
    #             elif stmt_type == 'if':
                    return self.execute_if(statement, frame)
    #             elif stmt_type == 'while':
                    return self.execute_while(statement, frame)
    #             elif stmt_type == 'for':
                    return self.execute_for(statement, frame)
    #             elif stmt_type == 'return':
                    return self.execute_return(statement, frame)
    #             elif stmt_type == 'break':
                    return self.execute_break(statement, frame)
    #             elif stmt_type == 'continue':
                    return self.execute_continue(statement, frame)
    #             elif stmt_type == 'import':
                    return self.execute_import(statement, frame)
    #             elif stmt_type == 'function':
                    return self.execute_function(statement, frame)
    #             elif stmt_type == 'class':
                    return self.execute_class(statement, frame)
    #             else:
                    raise ExecutionError(f"Unknown statement type: {stmt_type}")

    #         elif isinstance(statement, list):
    #             # Execute multiple statements
    result = None
    #             for stmt in statement:
    result = self.execute_statement(stmt, frame)
    #             return result

    #         else:
    #             # Treat as expression
                return self.execute_expression(statement, frame)

    #     def execute_expression(self, expression: Any, frame: StackFrame) -> Value:
    #         """Execute an expression"""
    #         if isinstance(expression, dict):
    expr_type = expression.get('type')

    #             if expr_type == 'literal':
                    return self.execute_literal(expression['value'], expression['type'])
    #             elif expr_type == 'variable':
                    return self.execute_variable(expression['name'], frame)
    #             elif expr_type == 'binary':
                    return self.execute_binary(expression, frame)
    #             elif expr_type == 'unary':
                    return self.execute_unary(expression, frame)
    #             elif expr_type == 'call':
                    return self.execute_call(expression, frame)
    #             elif expr_type == 'attribute':
                    return self.execute_attribute(expression, frame)
    #             elif expr_type == 'index':
                    return self.execute_index(expression, frame)
    #             elif expr_type == 'slice':
                    return self.execute_slice(expression, frame)
    #             elif expr_type == 'list':
                    return self.execute_list(expression, frame)
    #             elif expr_type == 'dict':
                    return self.execute_dict(expression, frame)
    #             else:
                    raise ExecutionError(f"Unknown expression type: {expr_type}")

    #         elif isinstance(expression, (int, float, str, bool)) or expression is None:
    #             # Literal value
                return ValueOperations.python_to_value(expression)

    #         else:
                raise ExecutionError(f"Invalid expression: {expression}")

    #     def execute_literal(self, value: Any, type_name: str) -> Value:
    #         """Execute a literal value"""
    #         if type_name == 'integer':
                return Value(RuntimeType.INTEGER, value)
    #         elif type_name == 'float':
                return Value(RuntimeType.FLOAT, value)
    #         elif type_name == 'string':
                return Value(RuntimeType.STRING, value)
    #         elif type_name == 'boolean':
                return Value(RuntimeType.BOOLEAN, value)
    #         elif type_name == 'none':
                return Value(RuntimeType.NONE, None)
    #         else:
                raise ExecutionError(f"Unknown literal type: {type_name}")

    #     def execute_variable(self, name: str, frame: StackFrame) -> Value:
    #         """Execute a variable reference"""
            return frame.get_variable(name)

    #     def execute_binary(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute a binary operation"""
    left = self.execute_expression(expr['left'], frame)
    right = self.execute_expression(expr['right'], frame)
    op = expr['operator']

            return ValueOperations.binary_operation(left, right, op)

    #     def execute_unary(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute a unary operation"""
    operand = self.execute_expression(expr['operand'], frame)
    op = expr['operator']

            return ValueOperations.unary_operation(operand, op)

    #     def execute_call(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute a function call"""
    func = self.execute_expression(expr['function'], frame)
    #         arguments = [self.execute_expression(arg, frame) for arg in expr['arguments']]

            return ValueOperations.call_function(func, arguments, self.runtime)

    #     def execute_attribute(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute attribute access"""
    obj = self.execute_expression(expr['object'], frame)
    attr_name = expr['attribute']

            return ValueOperations.get_attribute(obj, attr_name)

    #     def execute_index(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute index access"""
    obj = self.execute_expression(expr['object'], frame)
    index = self.execute_expression(expr['index'], frame)

            return ValueOperations.get_index(obj, index)

    #     def execute_slice(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute slice operation"""
    obj = self.execute_expression(expr['object'], frame)
    #         start = self.execute_expression(expr.get('start'), frame) if 'start' in expr else None
    #         stop = self.execute_expression(expr.get('stop'), frame) if 'stop' in expr else None
    #         step = self.execute_expression(expr.get('step'), frame) if 'step' in expr else None

    #         if obj.type not in [RuntimeType.LIST, RuntimeType.STRING]:
                raise ExecutionError("Can only slice lists and strings")

    #         # Convert start, stop, step to Python values
    #         py_start = start.data if start else None
    #         py_stop = stop.data if stop else None
    #         py_step = step.data if step else None

    #         try:
    result = obj.data[py_start:py_stop:py_step]
                return ValueOperations.python_to_value(result)
    #         except Exception as e:
                raise ExecutionError(f"Slice error: {str(e)}")

    #     def execute_list(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute list creation"""
    #         elements = [self.execute_expression(elem, frame) for elem in expr['elements']]
            return ValueOperations.create_list(elements)

    #     def execute_dict(self, expr: Dict, frame: StackFrame) -> Value:
    #         """Execute dictionary creation"""
    pairs = []
    #         for key, value in expr['pairs']:
    key_value = self.execute_expression(key, frame)
    value_value = self.execute_expression(value, frame)
                pairs.append((key_value, value_value))

            return ValueOperations.create_dict(pairs)

    #     def execute_assignment(self, stmt: Dict, frame: StackFrame) -> None:
    #         """Execute assignment statement"""
    target = stmt['target']
    value = self.execute_expression(stmt['value'], frame)

    #         if target['type'] == 'variable':
    #             # Simple variable assignment
                frame.set_variable(target['name'], value)

    #         elif target['type'] == 'attribute':
    #             # Attribute assignment
    obj = self.execute_expression(target['object'], frame)
    attr_name = target['attribute']

                ValueOperations.set_attribute(obj, attr_name, value)

    #         elif target['type'] == 'index':
    #             # Index assignment
    obj = self.execute_expression(target['object'], frame)
    index = self.execute_expression(target['index'], frame)

                ValueOperations.set_index(obj, index, value)

    #         else:
                raise ExecutionError(f"Unknown assignment target type: {target['type']}")

    #     def execute_if(self, stmt: Dict, frame: StackFrame) -> Optional[Value]:
    #         """Execute if statement"""
    condition = self.execute_expression(stmt['condition'], frame)

    #         if condition.truthy():
                return self.execute_statement(stmt['body'], frame)
    #         elif 'else' in stmt:
                return self.execute_statement(stmt['else'], frame)

    #         return None

    #     def execute_while(self, stmt: Dict, frame: StackFrame) -> Optional[Value]:
    #         """Execute while statement"""
    #         while True:
    condition = self.execute_expression(stmt['condition'], frame)

    #             if not condition.truthy():
    #                 break

    result = self.execute_statement(stmt['body'], frame)

    #             # Check for break/continue
    #             if result and hasattr(result.data, '__name__') and result.data.__name__ in ['break_stmt', 'continue_stmt']:
    #                 break

    #         return None

    #     def execute_for(self, stmt: Dict, frame: StackFrame) -> Optional[Value]:
    #         """Execute for statement"""
    iterable = self.execute_expression(stmt['iterable'], frame)

    #         if iterable.type not in [RuntimeType.LIST, RuntimeType.STRING]:
                raise ExecutionError("Can only iterate over lists and strings")

    #         for item in iterable.data:
    #             # Create iteration variable
                frame.set_variable(stmt['variable'], ValueOperations.python_to_value(item))

    #             # Execute body
    result = self.execute_statement(stmt['body'], frame)

    #             # Check for break/continue
    #             if result and hasattr(result.data, '__name__') and result.data.__name__ in ['break_stmt', 'continue_stmt']:
    #                 break

    #         return None

    #     def execute_return(self, stmt: Dict, frame: StackFrame) -> Value:
    #         """Execute return statement"""
    #         if 'value' in stmt:
    value = self.execute_expression(stmt['value'], frame)
    #         else:
    value = Value(RuntimeType.NONE, None)

    #         # Set return value in frame
            frame.set_variable('__return__', value)

    #         # Raise special exception to return from function
            raise ExecutionError("Return")

    #     def execute_break(self, stmt: Dict, frame: StackFrame) -> Value:
    #         """Execute break statement"""
    #         # Set break flag in frame
            frame.set_variable('__break__', Value(RuntimeType.BOOLEAN, True))

    #         # Raise special exception to break from loop
            raise ExecutionError("Break")

    #     def execute_continue(self, stmt: Dict, frame: StackFrame) -> Value:
    #         """Execute continue statement"""
    #         # Set continue flag in frame
            frame.set_variable('__continue__', Value(RuntimeType.BOOLEAN, True))

    #         # Raise special exception to continue to next iteration
            raise ExecutionError("Continue")

    #     def execute_import(self, stmt: Dict, frame: StackFrame) -> None:
    #         """Execute import statement"""
    module_name = stmt['module']

    #         if module_name in self.runtime.modules:
    #             # Already imported
    #             return

    #         try:
    #             # Import module
    module = __import__(module_name)

    #             # Create module value
    module_value = Value(RuntimeType.MODULE, module)

    #             # Add to global frame
                frame.set_variable(module_name, module_value)

    #             # Store in modules dict
    self.runtime.modules[module_name] = module

    #         except ImportError as e:
                raise ExecutionError(f"Failed to import module '{module_name}': {str(e)}")

    #     def execute_function(self, stmt: Dict, frame: StackFrame) -> Value:
    #         """Execute function definition"""
    name = stmt['name']
    parameters = stmt['parameters']
    body = stmt['body']

    #         # Create function
    func = Function(
    name = name,
    parameters = parameters,
    body = body,
    closure = frame.variables.copy()
    #         )

    #         # Add to current frame
            frame.set_variable(name, Value(RuntimeType.FUNCTION, func))

            return Value(RuntimeType.NONE, None)

    #     def execute_class(self, stmt: Dict, frame: StackFrame) -> Value:
    #         """Execute class definition"""
    name = stmt['name']
    bases = stmt.get('bases', [])

    #         # Evaluate base classes
    base_classes = []
    #         for base_expr in bases:
    base_value = self.execute_expression(base_expr, frame)
    #             if base_value.type != RuntimeType.CLASS:
    #                 raise ExecutionError("Base class must be a class")
                base_classes.append(base_value.data)

    #         # Create class
    cls = Class(
    name = name,
    bases = base_classes,
    methods = {},
    attributes = {},
    class_attributes = {}
    #         )

    #         # Execute class body in new frame
    class_frame = StackFrame(f"class.{name}", frame.variables.copy())

    #         for stmt_item in stmt['body']:
    result = self.execute_statement(stmt_item, class_frame)

    #             # Check if it's a method definition
    #             if (isinstance(stmt_item, dict) and stmt_item.get('type') == 'function' and
                    stmt_item.get('name') and stmt_item['name'] not in ['__init__', '__str__', '__repr__']):

    #                 # It's a method definition
    method_name = stmt_item['name']
    method_func = Function(
    name = method_name,
    parameters = stmt_item['parameters'],
    body = stmt_item['body'],
    closure = class_frame.variables.copy()
    #                 )
    cls.methods[method_name] = method_func

    #         # Add class to current frame
            frame.set_variable(name, Value(RuntimeType.CLASS, cls))

            return Value(RuntimeType.NONE, None)
