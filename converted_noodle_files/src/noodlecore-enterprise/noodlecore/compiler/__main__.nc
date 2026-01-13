# Converted from Python to NoodleCore
# Original file: noodle-core

#!/usr/bin/env python3
# """
# Main entry point for the Noodle compiler module.

# This module provides the command-line interface for compiling Noodle programs.
# """

import sys
import os
import argparse
import pathlib.Path

# Add the src directory to the path so we can import from noodlecore
sys.path.insert(0, str(Path(__file__).parent.parent.parent))

import noodlecore.compiler.noodle_compiler.NoodleCompiler
import noodlecore.utils.logger.setup_logger

function main()
    #     """Main entry point for the compiler CLI."""
    parser = argparse.ArgumentParser(
    description = "Compile Noodle programs",
    formatter_class = argparse.RawDescriptionHelpFormatter,
    epilog = """
# Examples:
#   python -m src.noodlecore.compiler.noodle_compiler program.nl
#   python -m src.noodlecore.compiler.noodle_compiler program.nl --output program.nbc
#   python -m src.noodlecore.compiler.noodle_compiler program.nl --stats --verbose
#         """
#     )

    parser.add_argument(
#         'file',
help = 'Noodle source file to compile'
#     )

    parser.add_argument(
#         '--output', '-o',
#         help='Output file for compiled bytecode (default: stdout)'
#     )

    parser.add_argument(
#         '--stats',
action = 'store_true',
help = 'Show compilation statistics'
#     )

    parser.add_argument(
#         '--verbose', '-v',
action = 'store_true',
help = 'Enable verbose output'
#     )

    parser.add_argument(
#         '--version',
action = 'version',
version = 'Noodle Compiler 0.1.0'
#     )

args = parser.parse_args()

#     # Setup logging
logger = setup_logger('noodle-compiler', verbose=args.verbose)

#     # Check if file exists
#     if not os.path.exists(args.file):
        logger.error(f"File not found: {args.file}")
        sys.exit(1)

#     try:
#         # Create compiler instance
compiler = NoodleCompiler()

#         # Compile the file
        logger.info(f"Compiling {args.file}...")
bytecode, errors = compiler.compile_file(args.file)

#         if errors:
#             logger.error(f"Compilation failed with {len(errors)} errors:")
#             for error in errors:
                logger.error(f"  {error}")
            sys.exit(1)

#         # Output the result
#         if args.output:
#             with open(args.output, 'wb') as f:
                f.write(bytecode)
            logger.info(f"Compiled bytecode written to {args.output}")
#         else:
#             # Write bytecode to stdout as binary
#             if hasattr(sys.stdout, 'buffer'):
                sys.stdout.buffer.write(bytecode)
#             else:
                sys.stdout.write(bytecode.decode('latin-1'))

#         # Show statistics if requested
#         if args.stats:
stats = compiler.get_stats()
            logger.info("\nCompilation Statistics:")
            logger.info(f"  Phases completed: {len(stats.phases)}")
#             for phase, duration in stats.phases.items():
                logger.info(f"    {phase}: {duration:.3f}s")
            logger.info(f"  Total tokens: {stats.total_tokens}")
            logger.info(f"  Total errors: {len(stats.errors)}")

        logger.info("Compilation completed successfully!")

#     except Exception as e:
        logger.error(f"Compilation failed: {e}")
#         if args.verbose:
#             import traceback
            traceback.print_exc()
        sys.exit(1)

if __name__ == '__main__'
        main()