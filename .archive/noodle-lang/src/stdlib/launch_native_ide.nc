# """
# NoodleCore Desktop GUI IDE - Native Launcher
# 
# This script launches the NoodleCore IDE natively without any browser
# or web server dependencies. Runs completely on NoodleCore.
# """

import sys
import os
import logging
from pathlib import Path

# Set up logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)


def check_noodlecore_requirements():
    """Check if NoodleCore requirements are met."""
    try:
        # Check Python version
        if sys.version_info < (3, 9):
            print("❌ Error: Python 3.9+ required")
            return False
        
        # Check if we're in the right directory
        current_dir = Path.cwd()
        if not (current_dir / "src" / "noodlecore").exists():
            print("❌ Error: Must run from noodle-core directory")
            return False
        
        print("✅ NoodleCore requirements check passed")
        return True
        
    except Exception as e:
        print(f"❌ Error checking requirements: {e}")
        return False


def setup_python_path():
    """Set up Python path to find NoodleCore modules."""
    try:
        # Add src directory to Python path
        src_path = Path.cwd() / "src"
        if str(src_path) not in sys.path:
            sys.path.insert(0, str(src_path))
        
        # Add current directory to Python path for imports
        current_dir = Path.cwd()
        if str(current_dir) not in sys.path:
            sys.path.insert(0, str(current_dir))
        
        print("✅ Python path configured")
        return True
        
    except Exception as e:
        print(f"❌ Error setting up Python path: {e}")
        return False


def import_noodlecore_ide():
    """Import NoodleCore IDE components."""
    try:
        # Try importing the new .nc format first
        try:
            from src.noodlecore.desktop.ide.ide_main import NoodleCoreIDE
            print("✅ Loaded native .nc IDE")
            return NoodleCoreIDE, "nc"
        except ImportError:
            pass
        
        # Fallback to Python format if available
        try:
            from noodlecore.desktop.ide.ide_main import NoodleCoreIDE
            print("✅ Loaded Python IDE (fallback)")
            return NoodleCoreIDE, "py"
        except ImportError as e:
            print(f"❌ Error importing NoodleCore IDE: {e}")
            return None, None
        
    except Exception as e:
        print(f"❌ Error importing NoodleCore IDE: {e}")
        return None, None


def create_launcher_ui():
    """Create a simple launcher UI to choose options."""
    try:
        print("\n" + "="*60)
        print("🚀 NOODLECORE NATIVE IDE LAUNCHER")
        print("="*60)
        print("🎯 Pure NoodleCore - No Browser Dependencies")
        print("🖥️  Native Desktop Window")
        print("⚡ Fast & Lightweight")
        print("="*60)
        print("\nChoose launch mode:")
        print("1. Standard IDE (Recommended)")
        print("2. Debug Mode")  
        print("3. Demo Mode")
        print("4. Development Mode")
        print("5. Full Featured IDE")
        print("\nEnter your choice (1-5) or press Enter for standard mode: ", end="")
        
        choice = input().strip()
        
        # Default to standard mode
        if not choice:
            choice = "1"
        
        return int(choice) if choice.isdigit() else 1
        
    except (KeyboardInterrupt, EOFError):
        print("\n\n👋 Launch cancelled")
        sys.exit(0)
    except Exception as e:
        print(f"❌ Error in launcher UI: {e}")
        return 1


def get_ide_configuration(mode_choice: int):
    """Get IDE configuration based on launch mode."""
    from src.noodlecore.desktop.ide.ide_main import IDEConfiguration
    
    config = IDEConfiguration()
    
    # Configure based on mode
    if mode_choice == 2:  # Debug Mode
        config.debug_mode = True
        config.log_level = "DEBUG"
        config.show_performance_metrics = True
        print("🐛 Debug mode enabled")
        
    elif mode_choice == 3:  # Demo Mode
        config.theme = "dark"
        config.show_file_explorer = True
        config.show_ai_panel = True
        config.show_terminal = True
        print("🎭 Demo mode enabled")
        
    elif mode_choice == 4:  # Development Mode
        config.debug_mode = True
        config.enable_performance_monitoring = True
        config.log_level = "DEBUG"
        config.show_performance_metrics = True
        print("🔧 Development mode enabled")
        
    elif mode_choice == 5:  # Full Featured IDE
        config.theme = "dark"
        config.show_file_explorer = True
        config.show_ai_panel = True
        config.show_terminal = True
        config.enable_ai_features = True
        config.enable_performance_monitoring = True
        config.show_performance_metrics = True
        print("🚀 Full featured mode enabled")
    
    return config


def launch_ide():
    """Main launcher function."""
    try:
        print("\n🔍 Checking system requirements...")
        if not check_noodlecore_requirements():
            sys.exit(1)
        
        print("\n⚙️  Setting up environment...")
        if not setup_python_path():
            sys.exit(1)
        
        print("\n📦 Loading NoodleCore IDE...")
        ide_class, ide_type = import_noodlecore_ide()
        if not ide_class:
            sys.exit(1)
        
        print(f"📝 IDE Type: {ide_type.upper()}")
        
        # Get launch mode
        mode_choice = create_launcher_ui()
        
        print("\n⚡ Configuring IDE...")
        config = get_ide_configuration(mode_choice)
        
        print("\n🚀 Launching NoodleCore Desktop IDE...")
        print("="*60)
        
        # Create and run IDE
        ide = ide_class(config=config)
        
        # Setup callbacks
        ide.set_initialization_callback(lambda: print("✅ IDE initialized successfully!"))
        ide.set_shutdown_callback(lambda: print("👋 IDE shutdown complete"))
        
        # Run the IDE
        if ide.run():
            print("🎉 NoodleCore Desktop GUI IDE is running!")
            print("💡 Features available:")
            print("   • File Explorer")
            print("   • Code Editor with syntax highlighting")
            print("   • AI-powered suggestions")
            print("   • Terminal Console")
            print("   • Multi-tab management")
            print("\n📋 Press Ctrl+C to shutdown")
            
            # Keep the program running
            try:
                import time
                while ide.is_running():
                    time.sleep(1)
            except KeyboardInterrupt:
                pass
            finally:
                print("\n🛑 Shutting down...")
                ide.shutdown()
                
        else:
            print("❌ Failed to start IDE")
            return 1
            
        return 0
        
    except KeyboardInterrupt:
        print("\n\n👋 Launch cancelled by user")
        return 0
    except Exception as e:
        print(f"\n❌ Error during IDE launch: {e}")
        logger.error(f"IDE launch error: {e}", exc_info=True)
        return 1


def main():
    """Main entry point."""
    try:
        print("🎯 NOODLECORE NATIVE IDE LAUNCHER")
        print("Pure NoodleCore - No Browser Dependencies")
        print("="*50)
        
        exit_code = launch_ide()
        sys.exit(exit_code)
        
    except Exception as e:
        print(f"❌ Fatal error: {e}")
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()