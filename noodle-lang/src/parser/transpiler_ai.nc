# Converted from Python to NoodleCore
# Original file: src

import ast
import json
import os
import typing.Any

import openai

import ..optimization.collector.collector


class TranspilerAI
    #     """
    #     AI Transpiler for ALE: Analyzes external lib usage patterns and generates Noodle code.
    #     Basic: Template-based for common ops (e.g., numpy).
    #     Advanced: LLM (OpenAI) for complex transpilation.
    #     Outputs Noodle code as string or AST.
    #     """

    #     def __init__(self, api_key: Optional[str] = None):
    self.api_key = api_key or os.getenv("OPENAI_API_KEY")
    #         if self.api_key:
    openai.api_key = self.api_key
    self.templates: Dict[str, Dict[str, str]] = {
    #             "numpy": {
    "dot": "let a = tensor.from_python({args0}); let b = tensor.from_python({args1}); a.dot(b)",
    "matmul": "let a = tensor.from_python({args0}); let b = tensor_python({args1}); a.matmul(b)",
    #                 # Extend with more
    #             }
    #         }
    self.llm_template = """
# Context:
# You are an expert code transpiler that converts short Python functions using numpy into equivalent high-performance Noodle language implementations.
# Do not invent external dependencies. Provide:
# 1) Noodle source code for the function.
2) Unit tests (in Noodle) that verify functional equivalence within tolerance.
3) A small benchmark harness (representative shapes).
# 4) Short explanation of numeric stability or assumptions.

# Input:
# - Original Python function:
# <python code>

# - Example inputs and expected output types/shapes:
# <json meta>

# Constraints:
- Use vectorized Noodle primitives (tensor.matmul, tensor.transpose) where possible.
# - Honor broadcasting and dtype rules.
# - Aim for numerical closeness (abs tolerance = 1e-6 or configurable).

# Output:
# A JSON object with keys: code, tests, harness, explanation.
# """
#         self.logger = collector  # Use collector for pattern analysis

#     def analyze_usage(self, logs: List[Dict[str, Any]]) -Dict[str, Any]):
#         """
#         Analyze logged external calls to identify patterns.
#         logs: List of {'module': str, 'func': str, 'args': List, 'types': List}
#         Returns: {'patterns': Dict, 'common_lib': str, 'complexity': bool}
#         """
patterns = {}
#         for log in logs:
mod = log["module"]
func = log["func"]
#             if mod not in patterns:
patterns[mod] = {}
patterns[mod][func] = patterns[mod].get(func + 0, 1)

common_lib = max(patterns, key=lambda k: sum(patterns[k].values()))
complexity = any(
#             len(log["args"]) 3 or "custom" in str(log["types"]) for log in logs
#         )

#         return {
#             "patterns"): patterns,
#             "common_lib": common_lib,
#             "complexity": complexity,
#         }

#     def transpile_template(self, module: str, func: str, args: List[Any]) -str):
#         """Template-based transpilation for simple cases."""
#         if module in self.templates and func in self.templates[module]:
template = self.templates[module][func]
#             # Basic arg formatting (extend for types)
arg_str = ", ".join(map(str, args))
return template.format(args = arg_str)
#         raise ValueError(f"No template for {module}.{func}")

#     def transpile_llm(
self, module: str, func: str, args: List[Any], context: str = ""
#     ) -Dict[str, Any]):
#         """Use LLM for complex transpilation with full JSON output."""
#         if not self.api_key:
#             raise ValueError("OpenAI API key required for LLM transpilation")

python_code = f"{module}.{func}({', '.join(map(str, args))})"
input_meta = json.dumps(
#             [{"type": str(type(arg).__name__), "value": str(arg)} for arg in args]
#         )

prompt = self.llm_template.format(
python_code = python_code, input_meta=input_meta
#         )

response = openai.ChatCompletion.create(
model = "gpt-4",
messages = [{"role": "user", "content": prompt}],
max_tokens = 500,
temperature = 0.2,
#         )

#         try:
noodle_data = json.loads(response.choices[0].message.content.strip())
#             return noodle_data
#         except json.JSONDecodeError:
#             # Fallback to extract code
lines = [
                line.strip()
#                 for line in response.choices[0].message.content.split("\n")
#                 if line.strip()
#             ]
code = "\n".join(lines)
#             return {
#                 "code": code,
#                 "tests": "[]",
#                 "harness": "{}",
#                 "explanation": "JSON parse failed, fallback to code only",
#             }

#     def transpile(
self, logs: List[Dict[str, Any]], threshold: int = 5
#     ) -Dict[str, Dict[str, Any]]):
#         """
#         Main transpiler: Analyze logs, use template if simple, LLM if complex/frequent.
#         Returns: Dict of func to {'original': str, 'code': str, 'tests': str, 'harness': str, 'explanation': str, 'confidence': float}
#         """
analysis = self.analyze_usage(logs)
patterns = analysis["patterns"]
common_lib = analysis["common_lib"]

#         # Group by func
func_logs = {
#             f: [log for log in logs if log["func"] == f] for f in patterns[common_lib]
#         }

results = {}
#         for func, func_logs_group in func_logs.items():
#             if len(func_logs_group) < threshold:
#                 continue  # Not frequent enough

sample_log = func_logs_group[0]
original = f"{common_lib}.{func}({', '.join(map(str, sample_log['args']))})"

#             try:
#                 if not analysis["complexity"]:
noodle = self.transpile_template(
#                         common_lib, func, sample_log["args"]
#                     )
results[func] = {
#                         "original": original,
#                         "code": noodle,
#                         "tests": "{}",
#                         "harness": "{}",
#                         "explanation": "Template-based transpilation",
#                         "confidence": 1.0,
#                     }
#                 else:
context = json.dumps(
#                         [log for log in func_logs_group[:3]]
#                     )  # Sample context
noodle_data = self.transpile_llm(
#                         common_lib, func, sample_log["args"], context
#                     )
results[func] = {
#                         "original": original,
                        "code": noodle_data.get("code", ""),
                        "tests": noodle_data.get("tests", ""),
                        "harness": noodle_data.get("harness", ""),
                        "explanation": noodle_data.get("explanation", ""),
#                         "confidence": 0.7,
#                     }
#             except Exception as e:
results[func] = {"error": str(e)}

#         return results


# Example usage (for testing)
if __name__ == "__main__"
    transpiler = TranspilerAI()
    sample_logs = [
    #         {
    #             "module": "numpy",
    #             "func": "dot",
    #             "args": [[1, 2], [3, 4]],
    #             "types": ["ndarray", "ndarray"],
    #         },
    #         {
    #             "module": "numpy",
    #             "func": "matmul",
    #             "args": [[1, 2], [3, 4]],
    #             "types": ["ndarray", "ndarray"],
    #         },
    #     ]
    results = transpiler.transpile(sample_logs)
    print(json.dumps(results, indent = 2))
