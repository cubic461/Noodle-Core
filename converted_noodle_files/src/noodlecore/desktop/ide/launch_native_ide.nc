# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# NoodleCore Native IDE Launcher

# This script launches the native NoodleCore GUI IDE. It can:
# 1. Execute .nc files directly as NoodleCore code
# 2. Run the native GUI IDE for interactive development
# 3. Handle AI provider integration for multiple services

# Usage:
#     python launch_native_ide.py                    # Launch IDE
#     python launch_native_ide.py file.nc           # Run .nc file
#     python launch_native_ide.py --help            # Show help
# """

import sys
import os
import argparse
import subprocess
import pathlib.Path

# Ensure repository root and src are on sys.path so relative imports work when run directly
current_dir = Path(__file__).parent
repo_root = math.subtract(current_dir.parent.parent.parent.parent  # .../noodle, core)
src_dir = repo_root / "src"
for p in (str(repo_root), str(src_dir), str(current_dir))
    #     if p not in sys.path:
            sys.path.insert(0, p)

function run_nc_file(filename)
    #     """Run a .nc file directly."""
        print(f"Running NoodleCore file: {filename}")

        # For now, try to run as Python (since .nc files might be converted)
    #     try:
    result = subprocess.run(
    #             [sys.executable, filename],
    capture_output = True,
    text = True
    #         )

    #         if result.stdout:
                print("Output:")
                print(result.stdout)
    #         if result.stderr:
                print("Errors:")
                print(result.stderr)

    return result.returncode = = 0

    #     except Exception as e:
            print(f"Error running file: {e}")
    #         return False

function launch_ide()
    #     """Launch the canonical NoodleCore Native GUI IDE."""
        print("Launching canonical NoodleCore Native GUI IDE...")

    #     # Import using absolute package path to avoid 'no known parent package' issues
        # Try enhanced IDE version first (includes all advanced features)
    #     try:
    #         from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    #         print("Using enhanced IDE version with full AI and Git integration")
    #     except ImportError:
    #         # Fallback: try clean IDE version
    #         try:
    #             from noodlecore.desktop.ide.native_gui_ide_clean import NativeNoodleCoreIDE
                print("Using clean IDE version")
    #         except ImportError:
    #             # Fallback: try original IDE version
    #             try:
    #                 from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
                    print("Using original IDE version")
    #             except ImportError:
    #                 # Last resort: adjust sys.path relative to this file and retry
    #                 try:
    current_dir = Path(__file__).parent
    repo_root = current_dir.parent.parent.parent.parent
    src_dir = repo_root / "src"
    #                     for p in (str(repo_root), str(src_dir), str(current_dir)):
    #                         if p not in sys.path:
                                sys.path.insert(0, p)
    #                     from noodlecore.desktop.ide.native_gui_ide import NativeNoodleCoreIDE
    #                 except ImportError as e:
                        print(f"Error: failed to import IDE: {e}")
    #                     return False

    #     try:
    ide = NativeNoodleCoreIDE()
    result = ide.run()
            # Support both None (typical Tk mainloop) and explicit int return codes
    #         if isinstance(result, int) and result != 0:
    #             print(f"IDE exited with non-zero status: {result}")
    #             return False
    #         return True
    #     except Exception as e:
            print(f"Error launching canonical IDE: {e}")
    #         import traceback
            traceback.print_exc()
    #         return False

function main()
    #     """Main entry point."""
    parser = argparse.ArgumentParser(
    description = "NoodleCore Native IDE Launcher",
    formatter_class = argparse.RawDescriptionHelpFormatter,
    epilog = """
# Examples:
  %(prog)s                    # Launch the GUI IDE
  %(prog)s example.nc         # Run a .nc file
  %(prog)s --convert file.py  # Convert Python to .nc format
  %(prog)s --version          # Show version info
#         """
#     )

    parser.add_argument(
#         'file',
nargs = '?',
help = 'NoodleCore (.nc) file to run'
#     )

    parser.add_argument(
#         '--convert',
type = str,
help = 'Convert a Python file to NoodleCore format'
#     )

    parser.add_argument(
#         '--version',
action = 'store_true',
help = 'Show version information'
#     )

    parser.add_argument(
#         '--debug',
action = 'store_true',
help = 'Run in debug mode'
#     )

args = parser.parse_args()

#     if args.version:
        print("NoodleCore Native IDE v1.0.0")
#         print("Built with NoodleCore and Python")
#         return 0

#     if args.debug:
        print("Debug mode enabled")

#     if args.convert:
        print(f"Converting {args.convert} to NoodleCore format...")
#         # TODO: Implement Python to NoodleCore conversion
        print("Conversion not yet implemented")
#         return 1

#     if args.file:
#         # Check if file exists and has .nc extension
file_path = Path(args.file)
#         if not file_path.exists():
            print(f"Error: File '{args.file}' not found")
#             return 1

#         if file_path.suffix.lower() != '.nc':
            print(f"Warning: File '{args.file}' doesn't have .nc extension")

success = run_nc_file(args.file)
#         return 0 if success else 1

#     else:
#         # Launch the GUI IDE
success = launch_ide()
#         return 0 if success else 1

if __name__ == "__main__"
        sys.exit(main())