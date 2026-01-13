#!/usr/bin/env python3
"""
Noodle Core::Launch Enhanced Ide - launch_enhanced_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Enhanced NoodleCore Native GUI IDE Launcher
Complete IDE with all requested features
"""

import sys
import os
import subprocess
import tkinter as tk
from tkinter import messagebox

def check_dependencies():
    """Check if required dependencies are available."""
    required_packages = ['aiohttp']
    missing_packages = []
    
    for package in required_packages:
        try:
            __import__(package)
        except ImportError:
            missing_packages.append(package)
    
    return missing_packages

def install_dependencies():
    """Install missing dependencies."""
    print("Installing missing dependencies...")
    try:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "aiohttp"])
        return True
    except subprocess.CalledProcessError:
        return False

def main():
    """Main launcher function."""
    print("ðŸš€ Enhanced NoodleCore Native GUI IDE Launcher")
    print("=" * 50)
    
    # Check dependencies
    missing = check_dependencies()
    if missing:
        print(f"âŒ Missing dependencies: {', '.join(missing)}")
        
        # Ask user if they want to install
        root = tk.Tk()
        root.withdraw()
        result = messagebox.askyesno(
            "Install Dependencies",
            f"Missing required packages: {', '.join(missing)}\n\nInstall them automatically?"
        )
        
        if result:
            if install_dependencies():
                print("âœ… Dependencies installed successfully")
            else:
                messagebox.showerror(
                    "Installation Failed",
                    "Failed to install dependencies automatically.\n\nPlease install manually:\npip install aiohttp"
                )
                return 1
        else:
            messagebox.showinfo(
                "Manual Installation Required",
                "Please install manually:\npip install aiohttp"
            )
            return 1
    
    # Launch the IDE
    print("âœ… All dependencies found")
    print("ðŸš€ Starting Enhanced NoodleCore IDE...")
    
    # Import and run the IDE
    try:
        # Add current directory to Python path
        current_dir = os.path.dirname(os.path.abspath(__file__))
        if current_dir not in sys.path:
            sys.path.insert(0, current_dir)
        
        # Import the IDE module
        from src.noodlecore.desktop.ide.enhanced_native_ide_complete import EnhancedNativeNoodleCoreIDE
        
        # Create and run IDE
        ide = EnhancedNativeNoodleCoreIDE()
        ide.run()
        
    except ImportError as e:
        print(f"âŒ Import error: {e}")
        messagebox.showerror(
            "Import Error", 
            f"Could not import IDE module:\n{str(e)}\n\nMake sure you're running from the correct directory."
        )
        return 1
        
    except Exception as e:
        print(f"âŒ Failed to start IDE: {e}")
        messagebox.showerror(
            "IDE Error", 
            f"Failed to start Enhanced NoodleCore IDE:\n\n{str(e)}"
        )
        return 1
    
    return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)

