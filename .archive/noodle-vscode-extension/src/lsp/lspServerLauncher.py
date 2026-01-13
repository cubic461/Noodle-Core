"""
Lsp::Lspserverlauncher - lspServerLauncher.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore LSP Server Launcher

This script launches the NoodleCore Language Server Protocol server
for the VS Code extension. It handles environment setup,
path resolution, and server startup with proper error handling.
"""

import os
import sys
import json
import logging
import traceback
from pathlib import Path

# Add the noodle-core source to Python path
def setup_python_path():
    """Setup Python path to include noodle-core modules"""
    # Get the directory containing this launcher script
    launcher_dir = Path(__file__).parent
    
    # Navigate to the noodle-core source directory
    noodle_core_src = launcher_dir.parent.parent / 'noodle-core' / 'src'
    
    if noodle_core_src.exists():
        noodle_core_path = str(noodle_core_src.absolute())
        if noodle_core_path not in sys.path:
            sys.path.insert(0, noodle_core_path)
            print(f"Added to Python path: {noodle_core_path}", file=sys.stderr)
    else:
        print(f"Warning: noodle-core source not found at {noodle_core_src}", file=sys.stderr)

def main():
    """Main entry point for LSP server launcher"""
    try:
        # Setup Python path
        setup_python_path()
        
        # Configure logging
        log_level = os.environ.get('NOODLE_LOG_LEVEL', 'INFO').upper()
        logging.basicConfig(
            level=getattr(logging, log_level, logging.INFO),
            format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
            datefmt='%Y-%m-%d %H:%M:%S'
        )
        
        logger = logging.getLogger('noodle-lsp-launcher')
        logger.info("Starting NoodleCore Language Server launcher")
        
        # Import and start the LSP server
        try:
            from noodlecore.lsp.noodle_lsp_server import main as lsp_main
            logger.info("Successfully imported NoodleCore LSP server")
            lsp_main()
        except ImportError as e:
            logger.error(f"Failed to import NoodleCore LSP server: {e}")
            logger.error(traceback.format_exc())
            
            # Try to provide helpful error message
            print("Error: Could not import NoodleCore LSP server", file=sys.stderr)
            print("Please ensure noodle-core is properly installed and accessible", file=sys.stderr)
            print(f"Python path: {sys.path}", file=sys.stderr)
            sys.exit(1)
            
    except Exception as e:
        logger.error(f"Unexpected error in LSP launcher: {e}")
        logger.error(traceback.format_exc())
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()

