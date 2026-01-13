# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Noodle Deployment DSL Parser
# Parses deployment, validate, observe, and task blocks for AI model deployment.
# """

import re
import dataclasses.dataclass,
import enum.Enum
import typing.Any,


class ParallelMode(Enum)
    TENSOR = "tensor"
    PIPELINE = "pipeline"
    REPLICA = "replica"


class BackendType(Enum)
    VLLM = "vllm"
    TENSORRT = "tensorrt"
    ONNXRUNTIME = "onnxruntime"


class ExportType(Enum)
    PROMETHEUS = "prometheus"
    JSON = "json"
    CSV = "csv"


# @dataclass
class ParallelConfig
    #     mode: ParallelMode
    tensor_size: Optional[int] = None
    replicas: Optional[int] = None
    gpus_per_node: int = 1
    nodes: int = 1


# @dataclass
class RuntimeConfig
    #     max_batch: int
    #     max_tokens: int
    temperature: float = 0.7
    top_p: float = 0.9


# @dataclass
class DeploymentSpec
    #     name: str
    #     model: str
    #     backend: BackendType
    #     image: str
    #     parallel: ParallelConfig
    #     runtime: RuntimeConfig
    quant: Optional[str] = None
    dtype: Optional[str] = None
    constraints: Dict[str, Any] = field(default_factory=dict)


# @dataclass
class ValidationRule
    #     name: str
    require_power_of_two: bool = False
    supported_modes: List[ParallelMode] = field(default_factory=list)
    max_gpus_per_node: Optional[int] = None
    min_gpus_required: Optional[int] = None

    #     def __post_init__(self):
    #         if not self.supported_modes:
    self.supported_modes = [
    #                 ParallelMode.TENSOR,
    #                 ParallelMode.PIPELINE,
    #                 ParallelMode.REPLICA,
    #             ]


# @dataclass
class ProfileConfig
    #     name: str
    #     input_sample: str
    #     trials: int
    #     output: str
    #     metrics: List[str]


# @dataclass
class ObserveConfig
    #     name: str
    #     metrics: List[str]
    #     export: ExportType
    trace_level: str = "basic"
    interval: int = 30


# @dataclass
class TaskConfig
    #     name: str
    #     plan: str  # Reference to deployment spec
    #     on_approve: List[str]
    #     on_reject: List[str]
    #     on_error: List[str]


# @dataclass
class TestEndpointConfig
    #     url: str
    #     model: str
    #     prompt: str
    #     max_tokens: int
    temperature: float = 0.7


class DeploymentDSLParser
    #     def __init__(self):
    self.current_file = ""
    self.tokens = []
    self.pos = 0

    #     def parse_file(self, file_path: str) -> Dict[str, Any]:
    #         """Parse a Noodle deployment DSL file"""
    self.current_file = file_path

    #         with open(file_path, "r") as f:
    content = f.read()

    #         # Tokenize
    self.tokens = self._tokenize(content)
    self.pos = 0

    #         # Parse top-level structures
    result = {
    #             "deployments": [],
    #             "validations": [],
    #             "profiles": [],
    #             "observations": [],
    #             "tasks": [],
    #         }

    #         while self.pos < len(self.tokens):
    token = self.peek()

    #             if token == "deploy":
    deployment = self._parse_deployment()
                    result["deployments"].append(deployment)
    #             elif token == "validate":
    validation = self._parse_validation()
                    result["validations"].append(validation)
    #             elif token == "profile":
    profile = self._parse_profile()
                    result["profiles"].append(profile)
    #             elif token == "observe":
    observe = self._parse_observe()
                    result["observations"].append(observe)
    #             elif token == "task":
    task = self._parse_task()
                    result["tasks"].append(task)
    #             else:
                    self.advance()  # Skip unknown tokens

    #         return result

    #     def _tokenize(self, content: str) -> List[str]:
    #         """Tokenize the DSL content"""
    #         # Remove comments
    content = re.sub(r"//.*$", "", content, flags=re.MULTILINE)

    #         # Tokenize
    tokens = []
    current_token = ""

    #         for char in content:
    #             if char in " \t\n\r(){}[]:;,=<>":
    #                 if current_token:
                        tokens.append(current_token)
    current_token = ""
    #                 if char not in " \t\n\r":
                        tokens.append(char)
    #             else:
    current_token + = char

    #         if current_token:
                tokens.append(current_token)

    #         return tokens

    #     def peek(self) -> Optional[str]:
    #         """Peek at current token without advancing"""
    #         if self.pos >= len(self.tokens):
    #             return None
    #         return self.tokens[self.pos]

    #     def advance(self):
    #         """Advance to next token"""
    self.pos + = 1

    #     def expect(self, expected: str) -> str:
    #         """Expect specific token, advance if found"""
    token = self.peek()
    #         if token != expected:
                raise ValueError(
    #                 f"Expected '{expected}', got '{token}' at position {self.pos} in {self.current_file}"
    #             )
            self.advance()
    #         return token

    #     def _parse_deployment(self) -> DeploymentSpec:
    #         """Parse deployment block"""
            self.expect("deploy")

    #         # Parse "model <name>"
            self.expect("model")
    model_name = self.expect_string()

    #         # Parse opening brace
            self.expect("{")

    #         # Parse properties
    properties = {}
    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "backend":
    value = self.advance()
    properties["backend"] = BackendType(value)
    #             elif key == "image":
    properties["image"] = self.expect_string()
    #             elif key == "quant":
    properties["quant"] = self.advance()
    #             elif key == "dtype":
    properties["dtype"] = self.advance()
    #             elif key == "parallel":
    properties["parallel"] = self._parse_parallel_config()
    #             elif key == "runtime":
    properties["runtime"] = self._parse_runtime_config()
    #             else:
    #                 # Generic key-value pair
    self.expect(" = ")
    properties[key] = self._parse_value()

    #             # Skip comma if not last item
    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")  # Closing brace

    #         # Build deployment spec
            return DeploymentSpec(
    name = model_name,
    model = model_name,
    backend = properties.get("backend", BackendType.VLLM),
    image = properties.get("image", "vllm/vllm-openai:latest"),
    quant = properties.get("quant"),
    dtype = properties.get("dtype"),
    parallel = properties.get(
    "parallel", ParallelConfig(mode = ParallelMode.TENSOR)
    #             ),
    runtime = properties.get(
    "runtime", RuntimeConfig(max_batch = 8, max_tokens=4096)
    #             ),
    constraints = {},
    #         )

    #     def _parse_parallel_config(self) -> ParallelConfig:
    #         """Parse parallel configuration block"""
            self.expect("{")

    mode = ParallelMode.TENSOR
    tensor_size = None
    replicas = None
    gpus_per_node = 1
    nodes = 1

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "mode":
    self.expect(" = ")
    mode = ParallelMode(self.advance())
    #             elif key == "tensor_size":
    self.expect(" = ")
    tensor_size = int(self.advance())
    #             elif key == "replicas":
    self.expect(" = ")
    replicas = int(self.advance())
    #             elif key == "gpus_per_node":
    self.expect(" = ")
    gpus_per_node = int(self.advance())
    #             elif key == "nodes":
    self.expect(" = ")
    nodes = int(self.advance())
    #             else:
                    raise ValueError(f"Unknown parallel config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

    #         if mode == ParallelMode.TENSOR and tensor_size is None:
    #             raise ValueError("tensor_size is required for tensor parallelism")
    #         if mode == ParallelMode.REPLICA and replicas is None:
    #             raise ValueError("replicas is required for replica mode")

            return ParallelConfig(
    mode = mode,
    tensor_size = tensor_size,
    replicas = replicas,
    gpus_per_node = gpus_per_node,
    nodes = nodes,
    #         )

    #     def _parse_runtime_config(self) -> RuntimeConfig:
    #         """Parse runtime configuration block"""
            self.expect("{")

    max_batch = 8
    max_tokens = 4096
    temperature = 0.7

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "max_batch":
    self.expect(" = ")
    max_batch = int(self.advance())
    #             elif key == "max_tokens":
    self.expect(" = ")
    max_tokens = int(self.advance())
    #             elif key == "temperature":
    self.expect(" = ")
    temperature = float(self.advance())
    #             else:
                    raise ValueError(f"Unknown runtime config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

            return RuntimeConfig(
    max_batch = max_batch, max_tokens=max_tokens, temperature=temperature
    #         )

    #     def _parse_validation(self) -> ValidationRule:
    #         """Parse validation block"""
            self.expect("validate")
    #         self.expect("_parallel")  # Assuming validate_parallel for now

    #         # Parse validation name
            self.expect("(")
    name = self.expect_string()
            self.expect(")")

            self.expect("{")

    require_power_of_two = False
    supported_modes = [
    #             ParallelMode.TENSOR,
    #             ParallelMode.PIPELINE,
    #             ParallelMode.REPLICA,
    #         ]
    max_gpus_per_node = None
    min_gpus_required = None

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "require_power_of_two":
    self.expect(" = ")
    require_power_of_two = self.advance() == "true"
    #             elif key == "supported_modes":
    self.expect(" = ")
    #                 supported_modes = [ParallelMode(mode) for mode in self._parse_array()]
    #             elif key == "max_gpus_per_node":
    self.expect(" = ")
    max_gpus_per_node = int(self.advance())
    #             elif key == "min_gpus_required":
    self.expect(" = ")
    min_gpus_required = int(self.advance())
    #             else:
                    raise ValueError(f"Unknown validation config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

            return ValidationRule(
    name = name,
    require_power_of_two = require_power_of_two,
    supported_modes = supported_modes,
    max_gpus_per_node = max_gpus_per_node,
    min_gpus_required = min_gpus_required,
    #         )

    #     def _parse_profile(self) -> ProfileConfig:
    #         """Parse profile block"""
            self.expect("profile")
            self.expect("model")

    #         # Parse profile name
            self.expect("(")
    name = self.expect_string()
            self.expect(")")

            self.expect("{")

    input_sample = ""
    trials = 1
    output = ""
    metrics = []

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "input_sample":
    self.expect(" = ")
    input_sample = self.expect_string()
    #             elif key == "trials":
    self.expect(" = ")
    trials = int(self.advance())
    #             elif key == "output":
    self.expect(" = ")
    output = self.expect_string()
    #             elif key == "metrics":
    self.expect(" = ")
    metrics = self._parse_array()
    #             else:
                    raise ValueError(f"Unknown profile config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

            return ProfileConfig(
    name = name,
    input_sample = input_sample,
    trials = trials,
    output = output,
    metrics = metrics,
    #         )

    #     def _parse_observe(self) -> ObserveConfig:
    #         """Parse observe block"""
            self.expect("observe")
            self.expect("deploy")

    #         # Parse observe name
            self.expect("(")
    name = self.expect_string()
            self.expect(")")

            self.expect("{")

    metrics = []
    export = ExportType.PROMETHEUS
    trace_level = "basic"
    interval = 30

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "metrics":
    self.expect(" = ")
    metrics = self._parse_array()
    #             elif key == "export":
    self.expect(" = ")
    export = ExportType(self.advance())
    #             elif key == "trace_level":
    self.expect(" = ")
    trace_level = self.advance()
    #             elif key == "interval":
    self.expect(" = ")
    interval = int(self.advance())
    #             else:
                    raise ValueError(f"Unknown observe config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

            return ObserveConfig(
    name = name,
    metrics = metrics,
    export = export,
    trace_level = trace_level,
    interval = interval,
    #         )

    #     def _parse_task(self) -> TaskConfig:
    #         """Parse task block"""
            self.expect("task")

    #         # Parse task name
            self.expect("(")
    name = self.expect_string()
            self.expect(")")

            self.expect("{")

    plan = ""
    on_approve = []
    on_reject = []
    on_error = []

    #         while self.peek() != "}":
    key = self.advance()

    #             if key == "plan":
    self.expect(" = ")
    plan = self.advance()
    #             elif key == "on":
    #                 # Handle on_approve, on_reject, on_error
    event_type = self.advance()
                    self.expect("{")

    actions = []
    #                 while self.peek() != "}":
    action = self._parse_value()
                        actions.append(action)

    #                     if self.peek() == ",":
                            self.advance()

                    self.expect("}")

    #                 if event_type == "approve":
    on_approve = actions
    #                 elif event_type == "reject":
    on_reject = actions
    #                 elif event_type == "error":
    on_error = actions
    #                 else:
                        raise ValueError(f"Unknown task event type: {event_type}")
    #             else:
                    raise ValueError(f"Unknown task config key: {key}")

    #             if self.peek() == ",":
                    self.advance()

            self.expect("}")

            return TaskConfig(
    name = name,
    plan = plan,
    on_approve = on_approve,
    on_reject = on_reject,
    on_error = on_error,
    #         )

    #     def expect_string(self) -> str:
    #         """Expect a string token (with or without quotes)"""
    token = self.advance()
    #         if (token.startswith('"') and token.endswith('"')) or (
                token.startswith("'") and token.endswith("'")
    #         ):
    #             return token[1:-1]
    #         return token

    #     def _parse_array(self) -> List[str]:
    #         """Parse array of values"""
            self.expect("[")

    values = []
    #         while self.peek() != "]":
    value = self.advance()
    #             # Remove quotes if present
    #             if (value.startswith('"') and value.endswith('"')) or (
                    value.startswith("'") and value.endswith("'")
    #             ):
    value = math.subtract(value[1:, 1])
                values.append(value)

    #             if self.peek() == ",":
                    self.advance()

            self.expect("]")
    #         return values

    #     def _parse_value(self) -> str:
            """Parse a value (string, number, or boolean)"""
    token = self.advance()

    #         # Remove quotes if present
    #         if (token.startswith('"') and token.endswith('"')) or (
                token.startswith("'") and token.endswith("'")
    #         ):
    #             return token[1:-1]

    #         # Check for boolean
    #         if token in ["true", "false"]:
    #             return token

    #         # Check for number
    #         try:
                float(token)  # Try to parse as number
    #             return token
    #         except ValueError:
    #             pass

    #         return token


# Example usage
if __name__ == "__main__"
    parser = DeploymentDSLParser()

    #     # Parse the example file
    result = parser.parse_file("noodle-dev/examples/deploy-vllm.noodle")

        print("Parsed Deployments:")
    #     for deploy in result["deployments"]:
            print(f"  Model: {deploy.model}")
            print(f"  Backend: {deploy.backend}")
            print(f"  Parallel: {deploy.parallel.mode}")
            print()

        print("Parsed Validations:")
    #     for validation in result["validations"]:
            print(f"  Name: {validation.name}")
            print(f"  Require Power of Two: {validation.require_power_of_two}")
            print()

        print("Parsed Profiles:")
    #     for profile in result["profiles"]:
            print(f"  Name: {profile.name}")
            print(f"  Metrics: {profile.metrics}")
            print()

        print("Parsed Observations:")
    #     for observe in result["observations"]:
            print(f"  Name: {observe.name}")
            print(f"  Export: {observe.export}")
            print()

        print("Parsed Tasks:")
    #     for task in result["tasks"]:
            print(f"  Name: {task.name}")
            print(f"  Plan: {task.plan}")
            print()
