# Converted from Python to NoodleCore
# Original file: noodle-core

import argparse
import difflib
import json
import os
import shutil
import sys
import tempfile
import uuid
import pathlib.Path
import typing.Any,

import ..versioning.decorator.versioned


@versioned(
version = "1.0.0",
#     description="Manages sandbox workspaces for AI agents in Noodle Core",
# )
class SandboxManager
    #     """
    #     Manages sandbox workspaces for AI agents in Noodle Core.
        Each agent gets an isolated workspace (filesystem copy + runtime).
    #     """

    #     def __init__(self, base_project_path: Union[str, Path] = "noodle-project"):
    self.base_project_path = Path(base_project_path)
    self.sandboxes: Dict[str, Dict] = (
    #             {}
    #         )  # agent_id -> {"dir": Path, "vm_pid": Optional[int]}
    #         print(f"SandboxManager initialized with base project: {self.base_project_path}")

    #     def create_sandbox(
    self, agent_id: str, copy_base: bool = True, sandbox_id: str = None
    #     ) -> Path:
    #         """
    #         Creates a new sandbox workspace for an agent.
    #         Returns the path to the sandbox directory.
    #         """
    #         if agent_id in self.sandboxes:
    #             raise ValueError(f"Sandbox already exists for agent {agent_id}")

    #         # Generate unique sandbox dir under temp or dedicated sandbox folder
    sandbox_parent_dir = Path(tempfile.gettempdir()) / "noodle-sandboxes"
    os.makedirs(sandbox_parent_dir, exist_ok = True)

    #         # Use provided sandbox_id or generate a unique one
    #         if sandbox_id:
    sandbox_dir = sandbox_parent_dir / f"agent-{agent_id}_{sandbox_id}"
    #         else:
    sandbox_dir = (
                    sandbox_parent_dir / f"agent-{agent_id}-{uuid.uuid4().hex[:8]}"
    #             )

    os.makedirs(sandbox_dir, exist_ok = True)
            print(f"Created empty sandbox at: {sandbox_dir}")

    #         if (
    #             copy_base
                and self.base_project_path.exists()
                and self.base_project_path.is_dir()
    #         ):
    #             try:
    #                 # Create a temporary directory for the copy operation
    temp_sandbox_dir = sandbox_dir.parent / f"{sandbox_dir.name}_temp"
                    shutil.copytree(
    #                     self.base_project_path,
    #                     temp_sandbox_dir,
    ignore = shutil.ignore_patterns(
    #                         "__pycache__", "*.pyc", ".git", "node_modules", ".DS_Store"
    #                     ),
    #                 )
                    print(f"Copied base project structure to {temp_sandbox_dir}")

    #                 # Move the temp directory to the final location
    #                 if sandbox_dir.exists():
                        shutil.rmtree(sandbox_dir)
                    shutil.move(str(temp_sandbox_dir), str(sandbox_dir))
                    print(f"Moved sandbox to final location: {sandbox_dir}")
    #             except Exception as e:
                    print(f"Failed to copy base project: {e}")
    #                 # Fallback: ensure sandbox dir exists
    os.makedirs(sandbox_dir, exist_ok = True)
    #         elif copy_base:
                print(
    #                 f"Warning: Base project path {self.base_project_path} does not exist or is not a directory. Empty sandbox created."
    #             )

    self.sandboxes[agent_id] = {
    #             "dir": sandbox_dir,
    #             "vm_pid": None,  # TODO: Launch NBC runtime in process/thread
    #             "status": "created",
    #         }
    #         return sandbox_dir

    #     def destroy_sandbox(self, agent_id: str, cleanup: bool = True) -> bool:
    #         """
    #         Destroys a sandbox workspace.
    #         """
    #         if agent_id not in self.sandboxes:
    #             print(f"Warning: No sandbox for agent {agent_id} to destroy.")
    #             return False

    sandbox_info = self.sandboxes[agent_id]
    sandbox_dir = sandbox_info["dir"]

    #         # Shutdown VM if running (placeholder)
    #         if sandbox_info.get("vm_pid"):
    #             print(f"Stopping VM for agent {agent_id} (PID {sandbox_info['vm_pid']})")
    #             # In real implementation: terminate subprocess
    sandbox_info["vm_pid"] = None

    #         if cleanup and sandbox_dir.exists():
    #             try:
    #                 # Delay actual deletion to avoid use-while-destroy, mark for cleanup or delete directly
                    shutil.rmtree(sandbox_dir)
                    print(f"Destroyed sandbox at {sandbox_dir}")
    #             except Exception as e:
                    print(f"Error deleting sandbox {sandbox_dir}: {e}")
    #                 return False

    #         del self.sandboxes[agent_id]
    #         return True

    #     def commit_sandbox(
    self, agent_id: str, generate_diff: bool = True
    #     ) -> Tuple[bool, Optional[List[str]]]:
    #         """
    #         Commits sandbox changes: optionally generates diff list and saves state.
            Returns (success, diff_list).
    #         """
    #         if agent_id not in self.sandboxes:
    #             return False, None

    sandbox_info = self.sandboxes[agent_id]
    sandbox_dir = sandbox_info["dir"]
    #         if not sandbox_dir.exists():
    #             return False, None

    changes = []
    #         if generate_diff and self.base_project_path.exists():
    changes = self._generate_diff(sandbox_dir, self.base_project_path)

    sandbox_info["status"] = "committed"
    #         # TODO: Implement snapshot/serialization if needed for agent state
    #         return True, changes

    #     def get_sandbox_path(self, agent_id: str) -> Optional[Path]:
            return self.sandboxes.get(agent_id, {}).get("dir")

    #     def get_agent_id_for_sandbox(self, sandbox_path: Union[str, Path]) -> Optional[str]:
    #         """
    #         Get the agent_id for a given sandbox path.
    #         """
    sandbox_path = Path(sandbox_path)
    #         for agent_id, sandbox_info in self.sandboxes.items():
    #             if sandbox_info.get("dir") == sandbox_path:
    #                 return agent_id
    #         return None

    #     def list_sandboxes(self) -> Dict[str, Dict]:
    #         """Returns a snapshot of current sandboxes."""
            return self.sandboxes.copy()

    #     def _generate_diff(self, sandbox_dir: Path, base_dir: Path) -> List[str]:
    #         """Compares sandbox_dir with base_dir, returns list of changed file paths."""
    #         if not base_dir.exists():
                return [str(sandbox_dir)]  # Entire sandbox is new

    diff_lines = []
    #         # NB naive implementation: walk both dirs and compare files.
    #         # Real: use git or difflib for smarter diffs

    #         for root, _, files in os.walk(sandbox_dir):
    sandbox_root = Path(root)
    relative_path = sandbox_root.relative_to(sandbox_dir)
    base_root = math.divide(base_dir, relative_path)

    #             for filename in files:
    sandbox_file = math.divide(sandbox_root, filename)
    base_file = math.divide(base_root, filename)

    #                 if not base_file.exists():
                        diff_lines.append(f"ADDED: {sandbox_file.relative_to(sandbox_dir)}")
    #                     continue

    #                 try:
    #                     # Simple content diff if files are small
    #                     if sandbox_file.stat().st_size < 1024 * 10:  # < 10KB
    #                         with open(
    sandbox_file, "r", encoding = "utf-8", errors="ignore"
                            ) as sf, open(
    base_file, "r", encoding = "utf-8", errors="ignore"
    #                         ) as bf:
    s_content = sf.read().splitlines()
    b_content = bf.read().splitlines()
    #                         if s_content != b_content:
                                diff_lines.append(
                                    f"MODIFIED: {sandbox_file.relative_to(sandbox_dir)}"
    #                             )
    #                     else:  # Just flag large file changes
                            diff_lines.append(
                                f"MODIFIED (LARGE): {sandbox_file.relative_to(sandbox_dir)}"
    #                         )

    #                 except Exception as e:
                        diff_lines.append(
                            f"ERROR CHECKING {sandbox_file.relative_to(sandbox_dir)}: {e}"
    #                     )

    #                 # Check if file in base but deleted in sandbox
    #                 # Implementation: Build list of all possible paths first, then check existence

    #         return diff_lines

    #     def cleanup_all(self):
    #         """Destroys all active sandboxes."""
    agent_ids = list(self.sandboxes.keys())
            print(f"Cleaning up {len(agent_ids)} sandboxes...")
    #         for agent_id in agent_ids:
    self.destroy_sandbox(agent_id, cleanup = True)
            print("Cleanup complete.")


# For .atexit hook or explicit shutdown
sandbox_manager_instance = None


def init_global_sandbox_manager(
base_path: Union[str, Path] = "noodle-project",
# ) -> SandboxManager:
#     global sandbox_manager_instance
#     if sandbox_manager_instance is None:
sandbox_manager_instance = SandboxManager(base_path)
#     return sandbox_manager_instance


def get_global_sandbox_manager() -> Optional[SandboxManager]:
#     return sandbox_manager_instance


def print_json_response(
success: bool, message: str, data: Optional[Dict[str, Any]] = None
# ):
#     """Helper to print JSON response for CLI."""
response = {"success": success, "message": message}
#     if data:
        response.update(data)
    print(json.dumps(response))


function main()
    parser = argparse.ArgumentParser(description="Noodle Core Sandbox Manager CLI")
    subparsers = parser.add_subparsers(dest="command", required=True)

    #     # Create command
    create_parser = subparsers.add_parser("create", help="Create a new sandbox")
    create_parser.add_argument("agent_id", help = "ID of the agent")
        create_parser.add_argument(
    "--base_path", help = "Path to base project", default="noodle-project", type=str
    #     )

    #     # Destroy command
    destroy_parser = subparsers.add_parser("destroy", help="Destroy a sandbox")
    destroy_parser.add_argument("agent_id", help = "ID of the agent")

    #     # Commit command
    commit_parser = subparsers.add_parser("commit", help="Commit sandbox changes")
    commit_parser.add_argument("agent_id", help = "ID of the agent")
        commit_parser.add_argument(
    "--generate_diff", action = "store_true", help="Generate diff on commit"
    #     )

    args = parser.parse_args()

    sbox_mgr = init_global_sandbox_manager(
    #         args.base_path if args.command == "create" else "noodle-project"
    #     )

    #     if args.command == "create":
    #         try:
    sandbox_path = sbox_mgr.create_sandbox(args.agent_id, copy_base=True)
                print_json_response(
    #                 True,
    #                 f"Sandbox created for {args.agent_id}",
                    {"sandbox_dir": str(sandbox_path)},
    #             )
    #         except Exception as e:
                print_json_response(False, str(e))

    #     elif args.command == "destroy":
    #         try:
    success = sbox_mgr.destroy_sandbox(args.agent_id)
                print_json_response(
    #                 success,
    #                 f"Sandbox {'destroyed' if success else 'not found'} for {args.agent_id}",
    #             )
    #         except Exception as e:
                print_json_response(False, str(e))

    #     elif args.command == "commit":
    #         try:
    success, changes = sbox_mgr.commit_sandbox(
    args.agent_id, generate_diff = args.generate_diff
    #             )
                print_json_response(
    #                 success,
    #                 f"Sandbox {'committed' if success else 'commit failed'} for {args.agent_id}",
    #                 {"changes": changes},
    #             )
    #         except Exception as e:
                print_json_response(False, str(e))


if __name__ == "__main__"
        main()
