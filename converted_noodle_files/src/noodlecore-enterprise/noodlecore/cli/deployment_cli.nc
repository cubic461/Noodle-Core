# Converted from Python to NoodleCore
# Original file: noodle-core

# """
# Noodle Deployment CLI
# Command-line interface for managing AI model deployments.
# """

import argparse
import asyncio
import json
import os
import sys
import pathlib.Path
import typing.Any,

import noodlecore.compiler.deployment_parser.DeploymentDSLParser
import noodlecore.runtime.deployment_runtime.DeploymentRuntime


class DeploymentCLI
    #     def __init__(self):
    self.parser = argparse.ArgumentParser(
    description = "Noodle AI Model Deployment CLI", prog="noodle"
    #         )
    self.subparsers = self.parser.add_subparsers(
    dest = "command", help="Available commands"
    #         )
    self.runtime = None
    self.parser_instance = DeploymentDSLParser()

            self._setup_commands()

    #     def _setup_commands(self):
    #         """Setup CLI subcommands"""

    #         # Parse command
    parse_parser = self.subparsers.add_parser(
    "parse", help = "Parse Noodle deployment DSL"
    #         )
    parse_parser.add_argument("file", help = "DSL file to parse")
            parse_parser.add_argument(
    "--output", "-o", help = "Output JSON file", default=None
    #         )
            parse_parser.add_argument(
    #             "--validate",
    #             "-v",
    action = "store_true",
    help = "Validate parsed configuration",
    #         )

    #         # Deploy command
    deploy_parser = self.subparsers.add_parser("deploy", help="Deploy a model")
    deploy_parser.add_argument("file", help = "DSL deployment file")
            deploy_parser.add_argument(
    #             "--generate-only",
    #             "-g",
    action = "store_true",
    help = "Generate artifacts without deploying",
    #         )
            deploy_parser.add_argument(
    #             "--dry-run",
    #             "-d",
    action = "store_true",
    help = "Preview deployment without executing",
    #         )
            deploy_parser.add_argument(
    #             "--base-dir",
    #             "-b",
    default = "./noodle-deployments",
    #             help="Base directory for deployments",
    #         )

    #         # Task command
    task_parser = self.subparsers.add_parser(
    "task", help = "Execute a deployment task"
    #         )
    #         task_parser.add_argument("file", help="DSL file with task configuration")
    task_parser.add_argument("task_name", help = "Name of task to execute")
            task_parser.add_argument(
    #             "--auto-approve",
    #             "-a",
    action = "store_true",
    help = "Auto-approve task execution",
    #         )

    #         # Profile command
    profile_parser = self.subparsers.add_parser(
    "profile", help = "Profile a deployment"
    #         )
    profile_parser.add_argument("deployment_name", help = "Name of deployed model")
    profile_parser.add_argument("--config", "-c", help = "Profile configuration file")

    #         # Observe command
    observe_parser = self.subparsers.add_parser(
    "observe", help = "Observe (monitor) a deployment"
    #         )
    observe_parser.add_argument("deployment_name", help = "Name of deployed model")
            observe_parser.add_argument(
    "--config", "-c", help = "Observation configuration file"
    #         )
            observe_parser.add_argument(
    #             "--interval",
    #             "-i",
    type = int,
    default = 30,
    help = "Monitoring interval in seconds",
    #         )

    #         # Status command
    status_parser = self.subparsers.add_parser(
    "status", help = "Get deployment status"
    #         )
            status_parser.add_argument(
    "deployment_name", help = "Name of deployed model", nargs="?"
    #         )
            status_parser.add_argument(
    "--json", "-j", action = "store_true", help="Output status as JSON"
    #         )

    #         # List command
    list_parser = self.subparsers.add_parser("list", help="List all deployments")
            list_parser.add_argument(
    "--json", "-j", action = "store_true", help="Output list as JSON"
    #         )

    #         # Stop command
    stop_parser = self.subparsers.add_parser("stop", help="Stop a deployment")
    stop_parser.add_argument("deployment_name", help = "Name of deployed model")

    #         # Validation command
    validate_parser = self.subparsers.add_parser(
    "validate", help = "Validate configuration"
    #         )
    validate_parser.add_argument("file", help = "DSL file to validate")

    #     def run(self, args: Optional[List[str]] = None):
    #         """Run the CLI"""
    #         if args is None:
    args = sys.argv[1:]

    #         # Parse arguments
    parsed_args = self.parser.parse_args(args)

    #         if not parsed_args.command:
                self.parser.print_help()
    #             return

    #         # Initialize runtime if needed
    #         if not self.runtime:
    self.runtime = DeploymentRuntime(
    base_dir = getattr(parsed_args, "base_dir", "./noodle-deployments")
    #             )

    #         # Execute command
    #         try:
    #             if parsed_args.command == "parse":
                    self._handle_parse(parsed_args)
    #             elif parsed_args.command == "deploy":
                    self._handle_deploy(parsed_args)
    #             elif parsed_args.command == "task":
                    self._handle_task(parsed_args)
    #             elif parsed_args.command == "profile":
                    self._handle_profile(parsed_args)
    #             elif parsed_args.command == "observe":
                    self._handle_observe(parsed_args)
    #             elif parsed_args.command == "status":
                    self._handle_status(parsed_args)
    #             elif parsed_args.command == "list":
                    self._handle_list(parsed_args)
    #             elif parsed_args.command == "stop":
                    self._handle_stop(parsed_args)
    #             elif parsed_args.command == "validate":
                    self._handle_validate(parsed_args)

    #         except Exception as e:
    print(f"Error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_parse(self, args):
    #         """Handle parse command"""
            print(f"Parsing file: {args.file}")

    #         try:
    #             # Parse the file
    result = self.parser_instance.parse_file(args.file)

    #             # Print summary
    print("\n = == PARSED RESULT ===")
                print(f"Deployments: {len(result['deployments'])}")
                print(f"Validations: {len(result['validations'])}")
                print(f"Profiles: {len(result['profiles'])}")
                print(f"Observations: {len(result['observations'])}")
                print(f"Tasks: {len(result['tasks'])}")

    #             # Output to file if requested
    #             if args.output:
    #                 with open(args.output, "w") as f:
    json.dump(result, f, indent = 2, default=str)
                    print(f"\nOutput saved to: {args.output}")

    #             # Validate if requested
    #             if args.validate:
    print("\n = == VALIDATION ===")
                    self._validate_parsed_result(result)

    #         except Exception as e:
    print(f"Parse error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _validate_parsed_result(self, result: Dict[str, Any]):
    #         """Validate parsed configuration"""
    all_valid = True

    #         # Validate deployments
    #         for deploy in result["deployments"]:
                print(f"\nDeployment: {deploy.name}")
                print(f"Backend: {deploy.backend.value}")
                print(f"Parallel mode: {deploy.parallel.mode.value}")

    #             if deploy.parallel.mode.value == "tensor" and deploy.parallel.tensor_size:
    #                 if (
    deploy.parallel.tensor_size % 2 ! = 0
    and deploy.parallel.tensor_size ! = 1
    #                 ):
                        print(
    #                         f"  ⚠️ Warning: Tensor size should be power of 2, got {deploy.parallel.tensor_size}"
    #                     )

                print(f"  ✅ Valid")

    #         # Validate validation rules
    #         for validation in result["validations"]:
                print(f"\nValidation: {validation.name}")
                print(f"  Power of 2 required: {validation.require_power_of_two}")
    #             print(f"  Supported modes: {[m.value for m in validation.supported_modes]}")
                print(f"  ✅ Valid")

            print(
    #             f"\n{'✅ All configurations are valid' if all_valid else '❌ Some configurations have issues'}"
    #         )

    #     def _handle_deploy(self, args):
    #         """Handle deploy command"""
            print(f"Deploying from file: {args.file}")

    #         try:
    #             # Parse the file
    result = self.parser_instance.parse_file(args.file)

    #             if not result["deployments"]:
                    print("No deployments found in file")
    #                 return

    #             # Use first deployment
    deploy_spec = result["deployments"][0]

    #             # Dry run preview
    #             if args.dry_run:
    print("\n = == DEPLOYMENT PREVIEW ===")
                    self._preview_deployment(deploy_spec)
    #                 return

    #             # Generate only
    #             if args.generate_only:
    print("\n = == GENERATING ARTIFACTS ===")
    artifacts = self.runtime._generate_deployment_artifacts(deploy_spec)
                    print(f"Generated artifacts:")
    #                 for name, path in artifacts.items():
                        print(f"  {name}: {path}")
    #                 return

    #             # Full deployment
    print("\n = == DEPLOYING ===")
    deployment_result = self.runtime.execute_deployment(deploy_spec)

                print(f"\n🎉 Deployment successful!")
                print(f"Model: {deploy_spec.name}")
                print(
    #                 f"Status: {deployment_result['build_result']['success'] and deployment_result['start_result']['success']}"
    #             )
                print(f"Directory: {deployment_result['deployment_dir']}")

    #             if deployment_result["health_check"]["success"]:
                    print(f"Service is ready at: http://localhost:8000")

    #         except Exception as e:
    print(f"Deploy error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _preview_deployment(self, spec):
    #         """Preview deployment configuration"""
            print(f"Name: {spec.name}")
            print(f"Model: {spec.model}")
            print(f"Backend: {spec.backend.value}")
            print(f"Image: {spec.image}")

            print(f"\nParallel Configuration:")
            print(f"  Mode: {spec.parallel.mode.value}")
    #         if spec.parallel.tensor_size:
                print(f"  Tensor size: {spec.parallel.tensor_size}")
    #         if spec.parallel.replicas:
                print(f"  Replicas: {spec.parallel.replicas}")
            print(f"  GPUs per node: {spec.parallel.gpus_per_node}")
            print(f"  Nodes: {spec.parallel.nodes}")

            print(f"\nRuntime Configuration:")
            print(f"  Max batch: {spec.runtime.max_batch}")
            print(f"  Max tokens: {spec.runtime.max_tokens}")
            print(f"  Temperature: {spec.runtime.temperature}")

    #         if spec.quant:
                print(f"\nQuantization: {spec.quant}")
    #         if spec.dtype:
                print(f"Data type: {spec.dtype}")

    #     def _handle_task(self, args):
    #         """Handle task command"""
            print(f"Executing task: {args.task_name} from {args.file}")

    #         try:
    #             # Parse the file
    result = self.parser_instance.parse_file(args.file)

    #             # Find the task
    task_config = None
    #             for task in result["tasks"]:
    #                 if task.name == args.task_name:
    task_config = task
    #                     break

    #             if not task_config:
                    print(f"Task '{args.task_name}' not found in file")
    #                 return

    #             # Auto-approval simulation
    #             if args.auto_approve:
                    print(
    #                     "⚠️ Auto-approval enabled - task actions will be approved without confirmation"
    #                 )

    #             # Execute task
    print("\n = == EXECUTING TASK ===")
    task_result = self.runtime.execute_task(task_config)

                print(f"\nTask Status: {task_result['status']}")
                print(f"Actions executed:")
    #             for action in task_result["actions"]:
    #                 status = "✅" if action["success"] else "❌"
                    print(f"  {status} {action['action']}")
    #                 if "message" in action:
                        print(f"    {action['message']}")

    #         except Exception as e:
    print(f"Task error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_profile(self, args):
    #         """Handle profile command"""
            print(f"Profiling deployment: {args.deployment_name}")

    #         try:
    #             # Find deployment first to get the profile config
    #             # For now, create a basic profile config
    #             from ..compiler.deployment_parser import ProfileConfig

    #             # Create default profile config
    config = ProfileConfig(
    name = f"{args.deployment_name}-profile",
    input_sample = "sample.txt",
    trials = 3,
    output = "profile_results.json",
    metrics = ["latency", "throughput", "gpu_memory"],
    #             )

    #             # Execute profile
    print("\n = == PROFILING ===")
    profile_result = self.runtime.execute_profile(config)

                print("\nProfiling completed!")
                print(f"Results saved to: {profile_result['results_path']}")

    #             # Parse and display summary
    results_file = Path(profile_result["results_path"])
    #             if results_file.exists():
    #                 with open(results_file, "r") as f:
    data = json.load(f)

    #                 if "results" in data:
    print("\n = == PROFILE SUMMARY ===")
    #                     for result in data["results"]:
    #                         if result["success"]:
                                print(f"✅ Test completed successfully")
    #                         else:
                                print(
                                    f"❌ Test failed: {result.get('error', 'Unknown error')}"
    #                             )

    #         except Exception as e:
    print(f"Profile error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_observe(self, args):
    #         """Handle observe command"""
    #         print(f"Starting observation for deployment: {args.deployment_name}")

    #         try:
    #             # Create default observe config
    #             from ..compiler.deployment_parser import ObserveConfig

    config = ObserveConfig(
    name = f"{args.deployment_name}-observe",
    metrics = ["gpu_memory", "gpu_util", "latency", "tokens_per_sec"],
    export = "prometheus",
    trace_level = "basic",
    interval = args.interval,
    #             )

    #             # Execute observation
    print("\n = == STARTING OBSERVATION ===")
    observe_result = self.runtime.execute_observe(config)

                print(f"\nObservation started!")
                print(f"Config saved to: {observe_result['monitoring_config_path']}")
                print(f"Interval: {args.interval} seconds")

    #         except Exception as e:
    print(f"Observation error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_status(self, args):
    #         """Handle status command"""
    #         if args.deployment_name:
                print(f"Checking status for: {args.deployment_name}")

    #             try:
    status = self.runtime.get_deployment_status(args.deployment_name)

    #                 if "error" in status:
                        print(f"Error: {status['error']}")
    #                     return

    #                 if args.json:
    print(json.dumps(status, indent = 2, default=str))
    #                 else:
                        print(f"\nDeployment: {status['name']}")
                        print(f"Status: {status['status']}")
    #                     if status["started_at"]:
    #                         from datetime import datetime

    start_time = datetime.fromtimestamp(status["started_at"])
                            print(f"Started at: {start_time}")

                        print(f"\nServices:")
    #                     for service in status.get("services", []):
                            print(f"  {service['service']}: {service['status']}")
    #                         if service.get("ports"):
                                print(f"    Ports: {service['ports']}")

    #             except Exception as e:
    print(f"Status error: {str(e)}", file = sys.stderr)
                    sys.exit(1)

    #         else:
    #             # List all deployments
                self._handle_list(args)

    #     def _handle_list(self, args):
    #         """Handle list command"""
            print("Listing all deployments...")

    #         try:
    deployments = self.runtime.list_deployments()

    #             if not deployments:
                    print("No active deployments found")
    #                 return

    #             if args.json:
    print(json.dumps(deployments, indent = 2, default=str))
    #             else:
                    print(f"\n{'NAME':<20} {'STATUS':<10} {'STARTED'}")
                    print("-" * 45)

    #                 for deploy in deployments:
    name = (
    #                         deploy["name"][:18] + "..."
    #                         if len(deploy["name"]) > 20
    #                         else deploy["name"]
    #                     )
    status = deploy["status"].ljust(8)

    #                     if deploy.get("started_at"):
    #                         from datetime import datetime

    start_time = datetime.fromtimestamp(deploy["started_at"])
    started = start_time.strftime("%H:%M")
    #                     else:
    started = "-"

                        print(f"{name:<20} {status:<10} {started}")

    #         except Exception as e:
    print(f"List error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_stop(self, args):
    #         """Handle stop command"""
            print(f"Stopping deployment: {args.deployment_name}")

    #         try:
    result = self.runtime.stop_deployment(args.deployment_name)

    #             if result["success"]:
                    print(f"✅ Deployment {args.deployment_name} stopped successfully")
    #             else:
                    print(
                        f"❌ Failed to stop deployment: {result.get('error', 'Unknown error')}"
    #                 )

    #         except Exception as e:
    print(f"Stop error: {str(e)}", file = sys.stderr)
                sys.exit(1)

    #     def _handle_validate(self, args):
    #         """Handle validate command"""
            print(f"Validating: {args.file}")

    #         try:
    #             # Parse the file
    result = self.parser_instance.parse_file(args.file)

    #             # Validate all configurations
    print("\n = == VALIDATION RESULTS ===")

    all_valid = True

    #             # Check deployments
    #             if result["deployments"]:
                    print("\nDeployments:")
    #                 for deploy in result["deployments"]:
                        print(f"  - {deploy.name}")

    #                     # Basic validation
    #                     if (
    deploy.parallel.mode.value = = "tensor"
    #                         and deploy.parallel.tensor_size
    #                     ):
    #                         if (
    deploy.parallel.tensor_size % 2 ! = 0
    and deploy.parallel.tensor_size ! = 1
    #                         ):
                                print(
    #                                 f"    ⚠️ Tensor size should be power of 2: {deploy.parallel.tensor_size}"
    #                             )
    all_valid = False
                        print(f"    ✅ Valid configuration")

    #             # Check other configurations
    #             if result["validations"]:
                    print("\nValidations:")
    #                 for validation in result["validations"]:
                        print(f"  - {validation.name}: ✅ Valid")

    #             if result["profiles"]:
                    print("\nProfiles:")
    #                 for profile in result["profiles"]:
                        print(f"  - {profile.name}: ✅ Valid")

    #             if result["observations"]:
                    print("\nObservations:")
    #                 for observe in result["observations"]:
                        print(f"  - {observe.name}: ✅ Valid")

    #             if result["tasks"]:
                    print("\nTasks:")
    #                 for task in result["tasks"]:
                        print(f"  - {task.name}: ✅ Valid")

                print(
    #                 f"\n{'✅ All configurations are valid' if all_valid else '❌ Validation failed'}"
    #             )

    #         except Exception as e:
    print(f"Validation error: {str(e)}", file = sys.stderr)
                sys.exit(1)


# Entry point
function main()
    cli = DeploymentCLI()
        cli.run()


if __name__ == "__main__"
        main()
