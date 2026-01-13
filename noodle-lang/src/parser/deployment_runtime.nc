# Converted from Python to NoodleCore
# Original file: src

# """
# Noodle Deployment Runtime
# Executes parsed deployment configurations with actual infrastructure operations.
# """

import json
import logging
import os
import shutil
import subprocess
import time
import dataclasses.asdict
import pathlib.Path
import typing.Any

import yaml

import ..compiler.deployment_parser.(
#     BackendType,
#     DeploymentSpec,
#     ExportType,
#     ObserveConfig,
#     ParallelMode,
#     ProfileConfig,
#     TaskConfig,
#     ValidationRule,
# )

logging.basicConfig(level = logging.INFO)
logger = logging.getLogger(__name__)


class DeploymentRuntime
    #     def __init__(self, base_dir: str = "./noodle-deployments"):
    self.base_dir = Path(base_dir)
    self.base_dir.mkdir(exist_ok = True)

    #         # Active deployments tracking
    self.active_deployments: Dict[str, Dict] = {}

    #         # Setup logging
            self._setup_logging()

    #     def _setup_logging(self):
    #         """Setup deployment logging"""
    log_dir = self.base_dir / "logs"
    log_dir.mkdir(exist_ok = True)

    #         # File handler for deployment logs
    file_handler = logging.FileHandler(log_dir / "deployment.log")
            file_handler.setLevel(logging.INFO)

    formatter = logging.Formatter(
                "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
    #         )
            file_handler.setFormatter(formatter)

            logger.addHandler(file_handler)

    #     def execute_deployment(self, spec: DeploymentSpec) -Dict[str, Any]):
    #         """Execute a deployment specification"""
            logger.info(f"Starting deployment: {spec.name}")

    #         # Validate deployment
    validation_result = self._validate_deployment(spec)
    #         if not validation_result["valid"]:
                raise ValueError(
    #                 f"Deployment validation failed: {validation_result['errors']}"
    #             )

    #         # Generate deployment artifacts
    artifacts = self._generate_deployment_artifacts(spec)

    #         # Execute deployment
    #         try:
    deployment_result = self._run_deployment(spec, artifacts)

    #             # Register as active deployment
    self.active_deployments[spec.name] = {
    #                 "spec": spec,
    #                 "artifacts": artifacts,
    #                 "result": deployment_result,
    #                 "status": "active",
                    "started_at": time.time(),
    #             }

                logger.info(f"Deployment {spec.name} completed successfully")
    #             return deployment_result

    #         except Exception as e:
                logger.error(f"Deployment {spec.name} failed: {str(e)}")
    #             raise

    #     def _validate_deployment(self, spec: DeploymentSpec) -Dict[str, Any]):
    #         """Validate deployment specifications"""
    errors = []

    #         # Check GPU requirements
    available_gpus = self._get_available_gpus()

    #         if spec.parallel.mode == ParallelMode.TENSOR:
    #             if spec.parallel.tensor_size available_gpus):
                    errors.append(
    #                     f"Insufficient GPUs: requires {spec.parallel.tensor_size}, available {available_gpus}"
    #                 )

    #             if spec.parallel.tensor_size % 2 != 0 and spec.parallel.tensor_size != 1:
                    errors.append(
    #                     f"Tensor size must be power of 2: got {spec.parallel.tensor_size}"
    #                 )

    #         elif spec.parallel.mode == ParallelMode.REPLICA:
    #             if spec.parallel.replicas available_gpus):
                    errors.append(
    #                     f"Insufficient GPUs: requires {spec.parallel.replicas}, available {available_gpus}"
    #                 )

    #         # Check model existence
    #         if not self._check_model_exists(spec.model):
                errors.append(f"Model not found: {spec.model}")

    #         # Validate backend compatibility
    #         if spec.backend == BackendType.VLLM:
    #             if spec.dtype == "fp8" and not self._check_fp8_support():
    #                 errors.append("FP8 support not available for this GPU")

    #         return {
    "valid": len(errors) = = 0,
    #             "errors": errors,
    #             "available_gpus": available_gpus,
    #         }

    #     def _generate_deployment_artifacts(self, spec: DeploymentSpec) -Dict[str, Any]):
            """Generate deployment artifacts (Docker files, docker-compose, etc.)"""
    #         logger.info(f"Generating artifacts for {spec.name}")

    deployment_dir = math.divide(self.base_dir, spec.name)
    deployment_dir.mkdir(exist_ok = True)

    artifacts = {}

    #         # Generate Dockerfile
    dockerfile_path = deployment_dir / "Dockerfile"
    dockerfile_content = self._generate_dockerfile(spec)
    #         with open(dockerfile_path, "w") as f:
                f.write(dockerfile_content)
    artifacts["dockerfile"] = str(dockerfile_path)

    #         # Generate docker-compose.yml
    compose_path = deployment_dir / "docker-compose.yml"
    compose_content = self._generate_docker_compose(spec)
    #         with open(compose_path, "w") as f:
                f.write(compose_content)
    artifacts["compose"] = str(compose_path)

    #         # Generate nginx config if needed
    #         if spec.parallel.mode == ParallelMode.REPLICA and spec.parallel.replicas 1):
    nginx_path = deployment_dir / "nginx.conf"
    nginx_content = self._generate_nginx_config(spec)
    #             with open(nginx_path, "w") as f:
                    f.write(nginx_content)
    artifacts["nginx"] = str(nginx_path)

    #         # Generate start script
    start_script_path = deployment_dir / "start.sh"
    start_script = self._generate_start_script(spec)
    #         with open(start_script_path, "w") as f:
                f.write(start_script)
            os.chmod(start_script_path, 0o755)
    artifacts["start_script"] = str(start_script_path)

    #         # Generate environment file
    env_path = deployment_dir / ".env"
    env_content = self._generate_env_file(spec)
    #         with open(env_path, "w") as f:
                f.write(env_content)
    artifacts["env"] = str(env_path)

    #         # Save spec for later reference
    spec_path = deployment_dir / "spec.json"
    #         with open(spec_path, "w") as f:
    json.dump(asdict(spec), f, indent = 2, default=str)
    artifacts["spec"] = str(spec_path)

    #         logger.info(f"Generated artifacts for {spec.name}")
    #         return artifacts

    #     def _run_deployment(
    #         self, spec: DeploymentSpec, artifacts: Dict[str, Any]
    #     ) -Dict[str, Any]):
    #         """Run the actual deployment"""
            logger.info(f"Running deployment: {spec.name}")

    deployment_dir = math.divide(self.base_dir, spec.name)

    #         # Build Docker image
    build_result = self._build_docker_image(spec, deployment_dir)

    #         # Start services
    start_result = self._start_services(spec, deployment_dir)

    #         # Wait for service readiness
    health_check_result = self._wait_for_service_readiness(spec)

    #         return {
    #             "build_result": build_result,
    #             "start_result": start_result,
    #             "health_check": health_check_result,
                "deployment_dir": str(deployment_dir),
    #         }

    #     def _get_available_gpus(self) -int):
    #         """Get number of available GPUs"""
    #         try:
    result = subprocess.run(
    ["nvidia-smi", "--query-gpu = count", "--format=csv,noheader"],
    capture_output = True,
    text = True,
    #             )
    #             if result.returncode = 0:
                    return int(result.stdout.strip())
    #         except:
    #             pass

    #         # Fallback to environment variable
    gpu_count = os.environ.get("CUDA_VISIBLE_DEVICES", "all")
    #         if gpu_count == "all":
    #             return 4  # Default assumption

            return len(gpu_count.split(","))

    #     def _check_model_exists(self, model_name: str) -bool):
    #         """Check if model exists locally"""
    model_dir = Path("./models") / model_name
            return model_dir.exists()

    #     def _check_fp8_support(self) -bool):
    #         """Check if GPU supports FP8"""
    #         try:
    #             # Check for Ampere or newer architecture
    result = subprocess.run(
    ["nvidia-smi", "--query-gpu = architecture", "--format=csv,noheader"],
    capture_output = True,
    text = True,
    #             )
    #             if result.returncode = 0:
    arch = result.stdout.strip()
    #                 # Ampere is architecture 8, newer versions have higher numbers
    return int(arch) = 8
    #         except):
    #             pass

    #         return False

    #     def _generate_dockerfile(self, spec: DeploymentSpec) -str):
    #         """Generate Dockerfile for deployment"""
    base_image = {
    #             BackendType.VLLM: "vllm/vllm-openai:latest",
    #             BackendType.TENSORRT: "nvcr.io/nvidia/tensorrt-llm:23.10-py3",
    #             BackendType.ONNXRUNTIME: "mcr.microsoft.com/onnxruntime:latest-gpu",
            }.get(spec.backend, "vllm/vllm-openai:latest")

    dockerfile = f"""FROM {base_image}

# Install system dependencies
# RUN apt-get update && apt-get install -y \\
#     python3.9 \\
#     python3-pip \\
#     python3-dev \\
#     git \\
#     curl \\
#     wget \\
#     && rm -rf /var/lib/apt/lists/*

# Set working directory
# WORKDIR /app

# Copy Python requirements first
# COPY requirements-vllm.txt /app/requirements.txt

# Upgrade pip and install Python dependencies
# RUN pip3 install --no-cache-dir --upgrade pip \\
#     && pip3 install --no-cache-dir -r requirements.txt

# Install model loading utilities
# RUN pip3 install --no-cache-dir \\
#     huggingface-hub \\
#     sentencepiece \\
#     accelerate \\
#     transformers

# Create directories
# RUN mkdir -p /app/models /app/config /app/data /app/logs

# Set environment variables
ENV MODEL_PATH = math.divide(, app/models/{spec.model})
ENV VLLM_PORT = 8000
ENV VLLM_HOST = 0.0.0.0
# ENV CUDA_VISIBLE_DEVICES=0-{'{spec.parallel.tensor_size - 1 if spec.parallel.tensor_size else 3}'}
# """

#         if spec.dtype == "fp8":
dockerfile + = "ENV VLLM_DTYPE=fp8\\n"

#         if spec.quant == "awq":
dockerfile + = "ENV VLLM_QUANTIZATION=AQW\\n"

#         # Add non-root user for security
dockerfile + = """
# Add non-root user
# RUN useradd --create-home --shell /bin/bash vllmuser
# RUN chown -R vllmuser:vllmuser /app
# USER vllmuser

# Health check
HEALTHCHECK --interval = 30s - -timeout=10s --start-period=60s --retries=3 \\
#     CMD curl -f http://localhost:8000/health || exit 1

# Expose port
# EXPOSE 8000

# Default command
# CMD ["python3", "-m", "vllm.entrypoints.openai.api_server", \\
#      "--model", "/app/models/{spec.model}", \\
#      "--port", "8000", \\
#      "--host", "0.0.0.0"]
# """

#         return dockerfile

#     def _generate_docker_compose(self, spec: DeploymentSpec) -str):
#         """Generate docker-compose.yml"""
services = {}

#         if spec.parallel.mode == ParallelMode.TENSOR:
services["vllm"] = {
#                 "image": f"noodle-vllm-{spec.name}:latest",
#                 "container_name": f"llama-3-70b-vllm",
#                 "environment": [
f"MODEL_PATH = /app/models/{spec.model}",
f"VLLM_WORKER_MULTIPROC_METHOD = spawn",
f"VLLM_ENGINE_ITERATION_TIMEOUT = 1200",
f"VLLM_MAX_MODEL_LEN = {spec.runtime.max_tokens}",
f"VLLM_TENSOR_PARALLEL_SIZE = {spec.parallel.tensor_size}",
f"VLLM_PORT = 8000",
f"VLLM_HOST = 0.0.0.0",
f'VLLM_DTYPE = {spec.dtype or "fp16"}',
f"VLLM_MAX_NUM_BATCHED_TOKENS = {spec.runtime.max_tokens}",
f"VLLM_MAX_NUM_SEQS = {spec.runtime.max_batch}",
#                 ],
#                 "volumes": [
#                     "./models:/app/models",
#                     "./config:/app/config",
#                     "./data:/app/data",
#                     "./logs:/app/logs",
#                 ],
#                 "ports": ["8000:8000"],
#                 "deploy": {
#                     "resources": {
#                         "reservations": {
#                             "devices": [
#                                 {
#                                     "driver": "nvidia",
#                                     "count": spec.parallel.tensor_size,
#                                     "capabilities": ["gpu"],
#                                 }
#                             ]
#                         }
#                     }
#                 },
#                 "runtime": "nvidia",
#                 "shm_size": f"{spec.runtime.max_batch * 1024 * 1024 * 4}b",  # 4x token size
#                 "healthcheck": {
#                     "test": ["CMD", "curl", "-f", "http://localhost:8000/health"],
#                     "interval": "30s",
#                     "timeout": "10s",
#                     "retries": 3,
#                     "start_period": "60s",
#                 },
#             }

#         elif spec.parallel.mode == ParallelMode.REPLICA:
#             # Generate multiple service instances
#             for i in range(spec.parallel.replicas):
services[f"vllm-worker-{i}"] = {
#                     "image": f"noodle-vllm-{spec.name}:latest",
#                     "container_name": f"llama-3-70b-vllm-{i}",
#                     "environment": [
f"MODEL_PATH = /app/models/{spec.model}",
f"VLLM_WORKER_MULTIPROC_METHOD = spawn",
f"VLLM_ENGINE_ITERATION_TIMEOUT = 1200",
f"VLLM_MAX_MODEL_LEN = {spec.runtime.max_tokens}",
f"VLLM_PORT = {8000 + i}",
f"VLLM_HOST = 0.0.0.0",
f'VLLM_DTYPE = {spec.dtype or "fp16"}',
f"VLLM_MAX_NUM_BATCHED_TOKENS = {spec.runtime.max_tokens}",
f"VLLM_MAX_NUM_SEQS = {spec.runtime.max_batch}",
#                     ],
#                     "volumes": [
#                         "./models:/app/models",
#                         "./config:/app/config",
#                         "./data:/app/data",
#                         "./logs:/app/logs",
#                     ],
#                     "ports": [f"{8000 + i}:8000"],
#                     "deploy": {
#                         "resources": {
#                             "reservations": {
#                                 "devices": [
#                                     {
#                                         "driver": "nvidia",
#                                         "count": 1,
#                                         "capabilities": ["gpu"],
#                                     }
#                                 ]
#                             }
#                         }
#                     },
#                     "runtime": "nvidia",
#                     "healthcheck": {
#                         "test": ["CMD", "curl", "-f", f"http://localhost:8000/health"],
#                         "interval": "30s",
#                         "timeout": "10s",
#                         "retries": 3,
#                         "start_period": "60s",
#                     },
#                 }

#             # Add nginx load balancer if multiple replicas
#             if spec.parallel.replicas 1):
services["nginx"] = {
#                     "image": "nginx:alpine",
#                     "ports": ["80:80"],
#                     "volumes": ["./nginx.conf:/etc/nginx/nginx.conf:ro"],
#                     "depends_on": [
#                         f"vllm-worker-{i}" for i in range(spec.parallel.replicas)
#                     ],
#                 }

#         # Convert to YAML
compose = {"version": "3.8", "services": services}

return yaml.dump(compose, default_flow_style = False)

#     def _generate_nginx_config(self, spec: DeploymentSpec) -str):
#         """Generate nginx configuration for load balancing"""
upstream_blocks = []

#         if spec.parallel.mode == ParallelMode.REPLICA:
#             for i in range(spec.parallel.replicas):
                upstream_blocks.append(f"    server vllm-worker-{i}:8000;")

#         return f"""events {{
#     worker_connections 1024;
# }}

# http {{
#     upstream vllm {{
{''.join(upstream_blocks)}
#     }}

#     server {{
#         listen 80;

#         location / {{
#             proxy_pass http://vllm;
#             proxy_set_header Host $host;
#             proxy_set_header X-Real-IP $remote_addr;
#             proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
#             proxy_set_header X-Forwarded-Proto $scheme;

#             proxy_connect_timeout 5s;
#             proxy_read_timeout 30s;
#         }}

#         location /health {{
#             access_log off;
#             return 200 "healthy\\n";
#             add_header Content-Type text/plain;
#         }}
#     }}
# }}
# """

#     def _generate_start_script(self, spec: DeploymentSpec) -str):
#         """Generate start script for deployment"""
script = f"""#!/bin/bash
# Start script for {spec.name}

# set -e

# echo "Starting deployment: {spec.name}"

# Check if model exists
if [ ! -d "./models/{spec.model}" ]; then
#     echo "Error: Model {spec.model} not found in ./models/"
#     exit 1
# fi

# Build Docker image
# echo "Building Docker image..."
# docker build -f Dockerfile -t noodle-vllm-{spec.name}:latest .

# Start services
# echo "Starting services..."
# docker-compose up -d

# Wait for services to be ready
# echo "Waiting for services to be ready..."
# sleep 30

# Check health
if docker-compose ps | grep -q "Up"; then
#     echo "Deployment {spec.name} started successfully!"
#     echo "Access at: http://localhost:80"
# else
#     echo "Error: Services failed to start"
#     docker-compose logs
#     exit 1
# fi
# """
#         return script

#     def _generate_env_file(self, spec: DeploymentSpec) -str):
#         """Generate environment file"""
env_vars = {
#             "MODEL_NAME": spec.model,
#             "BACKEND": spec.backend.value,
#             "PARALLEL_MODE": spec.parallel.mode.value,
#             "QUANTIZATION": spec.quant or "none",
#             "DATA_TYPE": spec.dtype or "fp16",
            "MAX_BATCH_SIZE": str(spec.runtime.max_batch),
            "MAX_TOKENS": str(spec.runtime.max_tokens),
            "TEMPERATURE": str(spec.runtime.temperature),
#             "DEPLOYMENT_NAME": spec.name,
#         }

#         return "\n".join(f"{k}={v}" for k, v in env_vars.items())

#     def _build_docker_image(
#         self, spec: DeploymentSpec, deployment_dir: Path
#     ) -Dict[str, Any]):
#         """Build Docker image"""
#         logger.info(f"Building Docker image for {spec.name}")

#         try:
result = subprocess.run(
#                 [
#                     "docker",
#                     "build",
#                     "-f",
#                     "Dockerfile",
#                     "-t",
#                     f"noodle-vllm-{spec.name}:latest",
#                     ".",
#                 ],
cwd = deployment_dir,
capture_output = True,
text = True,
timeout = 1800,  # 30 minutes timeout
#             )

#             return {
"success": result.returncode = 0,
#                 "stdout": result.stdout,
#                 "stderr": result.stderr,
#                 "returncode": result.returncode,
#             }

#         except subprocess.TimeoutExpired:
#             return {"success": False, "error": "Build timeout", "returncode": -1}
#         except Exception as e:
            return {"success": False, "error": str(e), "returncode": -1}

#     def _start_services(
#         self, spec: DeploymentSpec, deployment_dir: Path
#     ) -Dict[str, Any]):
#         """Start Docker services"""
#         logger.info(f"Starting services for {spec.name}")

#         try:
result = subprocess.run(
#                 ["docker-compose", "up", "-d"],
cwd = deployment_dir,
capture_output = True,
text = True,
timeout = 600,  # 10 minutes timeout
#             )

#             return {
"success": result.returncode = 0,
#                 "stdout": result.stdout,
#                 "stderr": result.stderr,
#                 "returncode": result.returncode,
#             }

#         except subprocess.TimeoutExpired:
#             return {"success": False, "error": "Start timeout", "returncode": -1}
#         except Exception as e:
            return {"success": False, "error": str(e), "returncode": -1}

#     def _wait_for_service_readiness(
self, spec: DeploymentSpec, timeout: int = 300
#     ) -Dict[str, Any]):
#         """Wait for service to be ready"""
#         logger.info(f"Waiting for service readiness: {spec.name}")

start_time = time.time()
deployment_dir = math.divide(self.base_dir, spec.name)

#         while time.time() - start_time < timeout:
#             try:
#                 # Check health endpoint
#                 if spec.parallel.mode == ParallelMode.TENSOR:
result = subprocess.run(
#                         ["curl", "-f", "http://localhost:8000/health"],
timeout = 10,
capture_output = True,
#                     )
#                 else:
#                     # For replica mode, check through nginx
result = subprocess.run(
#                         ["curl", "-f", "http://localhost/health"],
timeout = 10,
capture_output = True,
#                     )

#                 if result.returncode = 0:
#                     return {
#                         "success": True,
                        "ready_at": time.time(),
#                         "message": "Service is ready",
#                     }

#             except:
#                 pass

            time.sleep(10)

#         return {
#             "success": False,
#             "timeout": True,
#             "message": "Service did not become ready within timeout",
#         }

#     def execute_profile(self, config: ProfileConfig) -Dict[str, Any]):
#         """Execute profiling configuration"""
        logger.info(f"Starting profiling: {config.name}")

#         # Find deployment
deployment_name = config.name.replace("-profile", "")
#         if deployment_name not in self.active_deployments:
            raise ValueError(f"Deployment {deployment_name} not found")

deployment = self.active_deployments[deployment_name]
spec = deployment["spec"]

#         # Generate profiling commands
profile_commands = self._generate_profile_commands(spec, config)

#         # Execute profiling
profile_results = []
#         for cmd in profile_commands:
#             try:
result = subprocess.run(
#                     cmd,
cwd = deployment["deployment_dir"],
capture_output = True,
text = True,
timeout = config.trials * 60,  # 1 minute per trial
#                 )

                profile_results.append(
#                     {
                        "command": " ".join(cmd),
"success": result.returncode = 0,
#                         "stdout": result.stdout,
#                         "stderr": result.stderr,
#                         "returncode": result.returncode,
#                     }
#                 )

#             except Exception as e:
                profile_results.append(
                    {"command": " ".join(cmd), "success": False, "error": str(e)}
#                 )

#         # Save results
results_path = Path(self.base_dir) / deployment_name / "profile_results.json"
#         with open(results_path, "w") as f:
            json.dump(
#                 {
                    "config": asdict(config),
#                     "results": profile_results,
                    "timestamp": time.time(),
#                 },
#                 f,
indent = 2,
#             )

        logger.info(f"Profiling completed: {config.name}")
#         return {
#             "config": config,
#             "results": profile_results,
            "results_path": str(results_path),
#         }

#     def _generate_profile_commands(
#         self, spec: DeploymentSpec, config: ProfileConfig
#     ) -List[List[str]]):
#         """Generate profiling commands"""
commands = []

#         # Generate test prompts
prompts = self._generate_test_prompts(config.input_sample, config.trials)

#         # Benchmark command
#         for i, prompt in enumerate(prompts):
command = [
#                 "curl",
#                 "-X",
#                 "POST",
#                 "http://localhost:8000/v1/completions",
#                 "-H",
#                 "Content-Type: application/json",
#                 "-d",
                json.dumps(
#                     {
#                         "model": spec.model,
#                         "prompt": prompt,
                        "max_tokens": min(100, spec.runtime.max_tokens),
#                         "temperature": spec.runtime.temperature,
#                     }
#                 ),
#             ]

            commands.append(command)

#         return commands

#     def _generate_test_prompts(self, input_sample: str, trials: int) -List[str]):
#         """Generate test prompts from sample"""
prompts = []

#         try:
#             with open(input_sample, "r") as f:
content = f.read()

#             # Split into lines and take first N
#             lines = [line.strip() for line in content.split("\n") if line.strip()]
prompts = lines[:trials]

#         except:
#             # Fallback prompts
prompts = [
#                 "What are the latest developments in artificial intelligence?",
#                 "Explain quantum computing in simple terms.",
#                 "Write a short story about a robot discovering emotions.",
#             ][:trials]

#         return prompts

#     def execute_observe(self, config: ObserveConfig) -Dict[str, Any]):
        """Execute observation (monitoring) configuration"""
        logger.info(f"Starting observation: {config.name}")

#         # Find deployment
deployment_name = config.name.replace("-observe", "")
#         if deployment_name not in self.active_deployments:
            raise ValueError(f"Deployment {deployment_name} not found")

deployment = self.active_deployments[deployment_name]

#         # Start monitoring process
monitoring_config = {
            "config": asdict(config),
#             "deployment_dir": deployment["deployment_dir"],
            "start_time": time.time(),
#             "metrics_collected": [],
#         }

#         # Save monitoring config
monitor_path = Path(self.base_dir) / deployment_name / "monitoring_config.json"
#         with open(monitor_path, "w") as f:
json.dump(monitoring_config, f, indent = 2)

        logger.info(f"Observation started: {config.name}")
#         return {
#             "config": config,
            "monitoring_config_path": str(monitor_path),
#             "status": "started",
#         }

#     def execute_task(self, config: TaskConfig) -Dict[str, Any]):
#         """Execute task configuration"""
        logger.info(f"Executing task: {config.name}")

#         # Find deployment
deployment_name = config.plan
#         if deployment_name not in self.active_deployments:
            raise ValueError(f"Deployment {deployment_name} not found")

deployment = self.active_deployments[deployment_name]
spec = deployment["spec"]

#         # Execute task logic
task_result = {
#             "task_name": config.name,
#             "deployment_name": deployment_name,
#             "actions": [],
#         }

#         # Handle approve/reject/error flows
#         try:
            # Preview deployment (dry run)
            logger.info("Previewing deployment...")
preview_result = {
#                 "action": "preview",
#                 "success": True,
#                 "message": f"Deployment preview: {spec.name}",
                "config": asdict(spec),
#             }
            task_result["actions"].append(preview_result)

#             # User approval would come from CLI/UI
#             # For now, simulate approval
            logger.info("Task approved (simulated)")

#             # Execute approved actions
#             for action in config.on_approve:
#                 if action == "execute plan":
#                     # Execute the deployment
deploy_result = self.execute_deployment(spec)
                    task_result["actions"].append(
#                         {"action": action, "success": True, "result": deploy_result}
#                     )
#                 elif action == "execute profile model":
#                     # Execute profiling
#                     if spec.name in [p.name for p in deployment.get("profiles", [])]:
profile_config = next(
#                             p
#                             for p in deployment.get("profiles", [])
#                             if p.name == spec.name + "-profile"
#                         )
profile_result = self.execute_profile(profile_config)
                        task_result["actions"].append(
#                             {
#                                 "action": action,
#                                 "success": True,
#                                 "result": profile_result,
#                             }
#                         )
#                 elif action == "start observe deploy":
#                     # Start monitoring
observe_config = next(
#                         o
#                         for o in deployment.get("observations", [])
#                         if o.name == spec.name + "-observe"
#                     )
observe_result = self.execute_observe(observe_config)
                    task_result["actions"].append(
#                         {"action": action, "success": True, "result": observe_result}
#                     )

task_result["status"] = "completed"

#         except Exception as e:
#             # Handle error case
            logger.error(f"Task failed: {str(e)}")
task_result["status"] = "error"
task_result["error"] = str(e)

#             # Execute error actions
#             for action in config.on_error:
                task_result["actions"].append(
                    {"action": action, "success": False, "error": str(e)}
#                 )

#         # Save task result
task_result_path = Path(self.base_dir) / "task_results.json"
#         with open(task_result_path, "w") as f:
json.dump(task_result, f, indent = 2, default=str)

        logger.info(f"Task completed: {config.name}")
#         return task_result

#     def get_deployment_status(self, name: str) -Dict[str, Any]):
#         """Get deployment status"""
#         if name not in self.active_deployments:
#             return {"error": f"Deployment {name} not found"}

deployment = self.active_deployments[name]
spec = deployment["spec"]

#         # Check service status
#         try:
result = subprocess.run(
#                 ["docker-compose", "ps"],
cwd = deployment["deployment_dir"],
capture_output = True,
text = True,
#             )

services_status = []
#             for line in result.stdout.split("\n")[1:]:  # Skip header
#                 if line.strip():
parts = line.split()
#                     if len(parts) >= 4:
                        services_status.append(
#                             {
#                                 "service": parts[0],
#                                 "status": parts[3],
#                                 "ports": parts[4] if len(parts) 4 else "",
#                             }
#                         )

#             return {
#                 "name"): name,
#                 "status": deployment["status"],
                "started_at": deployment.get("started_at"),
                "spec": asdict(spec),
#                 "services": services_status,
#                 "deployment_dir": deployment["deployment_dir"],
#             }

#         except Exception as e:
#             return {
#                 "name": name,
                "error": str(e),
#                 "deployment_dir": deployment["deployment_dir"],
#             }

#     def stop_deployment(self, name: str) -Dict[str, Any]):
#         """Stop a deployment"""
#         if name not in self.active_deployments:
#             return {"error": f"Deployment {name} not found"}

deployment = self.active_deployments[name]
deployment_dir = deployment["deployment_dir"]

#         try:
#             # Stop services
result = subprocess.run(
#                 ["docker-compose", "down"],
cwd = deployment_dir,
capture_output = True,
text = True,
#             )

#             # Update status
deployment["status"] = "stopped"

#             return {
"success": result.returncode = 0,
#                 "stdout": result.stdout,
#                 "stderr": result.stderr,
#                 "returncode": result.returncode,
#             }

#         except Exception as e:
            return {"success": False, "error": str(e)}

#     def list_deployments(self) -List[Dict[str, Any]]):
#         """List all deployments"""
deployments = []

#         for name, deployment in self.active_deployments.items():
            deployments.append(
#                 {
#                     "name": name,
#                     "status": deployment["status"],
                    "started_at": deployment.get("started_at"),
                    "spec": (
#                         asdict(deployment["spec"]) if "spec" in deployment else None
#                     ),
#                 }
#             )

#         return deployments


# Standalone functions for deployment API
def get_deployment_status(name: str) -Dict[str, Any]):
    """Get deployment status (standalone function)"""
runtime = DeploymentRuntime()
    return runtime.get_deployment_status(name)


def stop_deployment(name: str) -Dict[str, Any]):
    """Stop a deployment (standalone function)"""
runtime = DeploymentRuntime()
    return runtime.stop_deployment(name)
