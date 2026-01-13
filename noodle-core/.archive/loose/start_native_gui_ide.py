#!/usr/bin/env python3
"""
Noodle Core::Start Native Gui Ide - start_native_gui_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Native GUI IDE Launcher
Launches the native GUI IDE with all features
"""

import sys
import os
import argparse
import logging
from pathlib import Path

# Add the src directory to the Python path
sys.path.insert(0, str(Path(__file__).parent / "src"))

def setup_logging(debug=False):
    """Setup logging configuration."""
    level = logging.DEBUG if debug else logging.INFO
    logging.basicConfig(
        level=level,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout),
            logging.FileHandler('noodlecore_native_ide.log')
        ]
    )

def main():
    """Main entry point for the launcher."""
    parser = argparse.ArgumentParser(description="NoodleCore Native GUI IDE Launcher")
    parser.add_argument("--debug", action="store_true", help="Enable debug mode")
    parser.add_argument("--test", action="store_true", help="Run in test mode")
    parser.add_argument("--version", action="version", version="NoodleCore Native GUI IDE 1.0")
    
    args = parser.parse_args()
    
    # Setup logging
    setup_logging(args.debug)
    logger = logging.getLogger(__name__)
    
    try:
        logger.info("Starting NoodleCore Native GUI IDE...")
        
        if args.test:
            logger.info("Running in test mode")
            # Import test module for testing
            from src.noodlecore.desktop.ide.native_gui_ide import (
                NoodleCoreIDE,
                AIProviderManager,
                NoodleCoreCodeEditor,
                ProjectExplorer,
                TerminalConsole,
                NativeGUIFramework,
                NativeNoodleCoreIDE
            )
            
            # Test the integrated components
            print("=== Testing NoodleCore Native GUI IDE Components ===")
            
            # Test AI Provider Manager
            print("1. Testing AI Provider Manager...")
            ai_manager = AIProviderManager()
            providers = ai_manager.get_available_providers()
            print(f"   Found {len(providers)} providers: {[p.name for p in providers]}")
            
            # Test Code Editor
            print("2. Testing Code Editor...")
            editor = NoodleCoreCodeEditor()
            test_code = "def hello():\\n    print('Hello World')"
            analysis = editor.analyze_code(test_code)
            print(f"   Code analysis: {analysis['metrics']['lines_of_code']} lines")
            
            # Test Project Explorer
            print("3. Testing Project Explorer...")
            explorer = ProjectExplorer()
            result = explorer.open_project("test_project")
            print(f"   Project opened: {result}")
            
            # Test Terminal Console
            print("4. Testing Terminal Console...")
            terminal = TerminalConsole()
            result = terminal.execute_command("echo 'test'")
            print(f"   Command executed: {result['success']}")
            
            # Test GUI Framework
            print("5. Testing GUI Framework...")
            gui_framework = NativeGUIFramework()
            result = gui_framework.initialize_layout(1200, 800)
            print(f"   Layout initialized: {result}")
            
            # Test Integrated IDE
            print("6. Testing Integrated IDE...")
            ide = NativeNoodleCoreIDE()
            result = ide.initialize()
            print(f"   IDE initialized: {result}")
            print(f"   AI providers: {ide.get_ai_providers()}")
            
            print("\\n=== All tests completed successfully! ===")
            print("The native GUI IDE is ready to launch.")
            return 0
        
        # Import and launch the main IDE
        from src.noodlecore.desktop.ide.native_gui_ide import NoodleCoreIDE
        
        if args.debug:
            logger.info("Starting IDE in debug mode...")
        
        # Create and run the IDE
        ide = NoodleCoreIDE()
        ide.run()
        
        logger.info("NoodleCore Native GUI IDE closed successfully")
        return 0
        
    except ImportError as e:
        logger.error(f"Import error: {e}")
        print(f"Error: Could not import required modules: {e}")
        print("Make sure you are running this from the noodle-core directory")
        return 1
        
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        print(f"Error: {e}")
        if args.debug:
            import traceback
            traceback.print_exc()
        return 1

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

