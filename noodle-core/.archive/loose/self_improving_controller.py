#!/usr/bin/env python3
"""
Noodle Core::Self Improving Controller - self_improving_controller.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Self-Improving System Controller
Easy start/stop control for all NoodleCore self-improvement systems
"""

import subprocess
import sys
import time
import os
from pathlib import Path

class NoodleCoreController:
    """Controller for NoodleCore self-improving systems."""
    
    def __init__(self):
        self.base_path = Path.cwd()
        self.scripts = {
            "performance_monitor": "noodlecore_performance_monitor.py",
            "optimization_engine": "noodlecore_optimization_engine.py", 
            "learning_loop": "noodlecore_learning_loop.py"
        }
        self.processes = {}
    
    def start_all(self):
        """Start all NoodleCore self-improving systems."""
        print("ðŸš€ Starting NoodleCore Self-Improving System...")
        print("="*50)
        
        # Start all systems in background
        for name, script in self.scripts.items():
            try:
                print(f"Starting {name}...")
                process = subprocess.Popen(
                    [sys.executable, script],
                    cwd=self.base_path,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE
                )
                self.processes[name] = process
                print(f"âœ… {name} started (PID: {process.pid})")
                time.sleep(1)  # Small delay between starts
                
            except Exception as e:
                print(f"âŒ Failed to start {name}: {e}")
        
        print("\nðŸŽ‰ All systems started!")
        print("\nActive systems:")
        for name, process in self.processes.items():
            print(f"  â€¢ {name}: Running (PID: {process.pid})")
        
        print(f"\nTo stop systems: python {__file__} stop")
        return True
    
    def stop_all(self):
        """Stop all NoodleCore self-improving systems."""
        print("ðŸ›‘ Stopping NoodleCore Self-Improving System...")
        print("="*50)
        
        stopped_count = 0
        for name, process in self.processes.items():
            try:
                print(f"Stopping {name}...")
                process.terminate()
                process.wait(timeout=10)
                print(f"âœ… {name} stopped")
                stopped_count += 1
                
            except subprocess.TimeoutExpired:
                print(f"âš ï¸ Force killing {name}...")
                process.kill()
                process.wait()
                print(f"âœ… {name} force stopped")
                stopped_count += 1
                
            except Exception as e:
                print(f"âŒ Error stopping {name}: {e}")
        
        self.processes.clear()
        print(f"\nðŸ›‘ Stopped {stopped_count} systems")
        return True
    
    def status(self):
        """Check status of all systems."""
        print("ðŸ“Š NoodleCore Self-Improving System Status")
        print("="*50)
        
        running_count = 0
        for name, process in self.processes.items():
            if process.poll() is None:
                print(f"âœ… {name}: Running (PID: {process.pid})")
                running_count += 1
            else:
                print(f"âŒ {name}: Stopped")
        
        if running_count == 0:
            print("\nðŸ›‘ No systems are running")
            print("\nTo start systems: python self_improving_controller.py start")
        else:
            print(f"\nðŸŽ¯ {running_count}/{len(self.scripts)} systems running")
            print("\nTo stop systems: python self_improving_controller.py stop")
        
        return running_count > 0
    
    def start_single(self, system_name):
        """Start a single system."""
        if system_name not in self.scripts:
            print(f"âŒ Unknown system: {system_name}")
            print(f"Available systems: {', '.join(self.scripts.keys())}")
            return False
        
        script = self.scripts[system_name]
        try:
            print(f"ðŸš€ Starting {system_name}...")
            process = subprocess.Popen(
                [sys.executable, script],
                cwd=self.base_path,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE
            )
            self.processes[system_name] = process
            print(f"âœ… {system_name} started (PID: {process.pid})")
            return True
            
        except Exception as e:
            print(f"âŒ Failed to start {system_name}: {e}")
            return False
    
    def stop_single(self, system_name):
        """Stop a single system."""
        if system_name not in self.processes:
            print(f"âŒ {system_name} is not running")
            return False
        
        process = self.processes[system_name]
        try:
            print(f"ðŸ›‘ Stopping {system_name}...")
            process.terminate()
            process.wait(timeout=10)
            print(f"âœ… {system_name} stopped")
            del self.processes[system_name]
            return True
            
        except subprocess.TimeoutExpired:
            print(f"âš ï¸ Force killing {system_name}...")
            process.kill()
            process.wait()
            print(f"âœ… {system_name} force stopped")
            del self.processes[system_name]
            return True
            
        except Exception as e:
            print(f"âŒ Error stopping {system_name}: {e}")
            return False

def main():
    """Main entry point."""
    controller = NoodleCoreController()
    
    if len(sys.argv) < 2:
        print("NoodleCore Self-Improving System Controller")
        print("="*50)
        print("Usage:")
        print("  python self_improving_controller.py start    - Start all systems")
        print("  python self_improving_controller.py stop     - Stop all systems") 
        print("  python self_improving_controller.py status   - Check status")
        print("  python self_improving_controller.py start <system>  - Start single system")
        print("  python self_improving_controller.py stop <system>   - Stop single system")
        print("\nAvailable systems:")
        for name in controller.scripts.keys():
            print(f"  â€¢ {name}")
        return
    
    command = sys.argv[1].lower()
    
    if command == "start":
        if len(sys.argv) > 2:
            # Start single system
            system_name = sys.argv[2]
            controller.start_single(system_name)
        else:
            # Start all systems
            controller.start_all()
    
    elif command == "stop":
        if len(sys.argv) > 2:
            # Stop single system
            system_name = sys.argv[2]
            controller.stop_single(system_name)
        else:
            # Stop all systems
            controller.stop_all()
    
    elif command == "status":
        controller.status()
    
    else:
        print(f"âŒ Unknown command: {command}")
        print("Use: start, stop, or status")

if __name__ == "__main__":
    main()

