
# Native NoodleCore Runtime Integration for IDE
#
# This module integrates the native NoodleCore runtime directly into the IDE,
# allowing .nc files to be executed without Python dependency using the
# built-in NoodleCore runtime environment.

import tkinter as tk
from tkinter import ttk, messagebox, filedialog
import subprocess
import threading
import os
import sys
import json
from pathlib import Path

class NoodleCoreRuntime:
    """Wrapper for native NoodleCore runtime execution."""
    
    def __init__(self):
        self.runtime_path = "src/noodlecore/runtime"
        self.interpreter_path = "src/noodlecore/runtime/simple_interpreter.py"
        self.extended_runtime_path = "src/noodlecore/runtime/noodlecore_runtime.nc"
        
    def is_available(self):
        """Check if NoodleCore runtime is available."""
        try:
            # Check for interpreter files
            interpreter_exists = os.path.exists(self.interpreter_path)
            runtime_exists = os.path.exists(self.extended_runtime_path)
            
            return interpreter_exists or runtime_exists
        except:
            return False
            
    def execute_nc_file(self, file_path, args=None, callback=None):
        """Execute a .nc file using native NoodleCore runtime."""
        try:
            if not os.path.exists(file_path):
                raise FileNotFoundError(f"NoodleCore file not found: {file_path}")
                
            # Method 1: Try using simple_interpreter.py
            if os.path.exists(self.interpreter_path):
                return self._execute_with_interpreter(file_path, args, callback)
            
            # Method 2: Try using native .nc runtime
            elif os.path.exists(self.extended_runtime_path):
                return self._execute_with_native_runtime(file_path, args, callback)
            
            # Method 3: Fallback to Python execution (if .nc contains valid Python)
            else:
                return self._execute_as_python(file_path, args, callback)
                
        except Exception as e:
            error_msg = f"Failed to execute {file_path}: {str(e)}"
            if callback:
                callback(error_msg, is_error=True)
            return False
            
    def _execute_with_interpreter(self, file_path, args, callback):
        """Execute using simple_interpreter.py."""
        try:
            cmd = [sys.executable, self.interpreter_path, file_path]
            if args:
                cmd.extend(args)
                
            # Run in thread to prevent blocking
            thread = threading.Thread(
                target=self._run_command,
                args=(cmd, callback),
                daemon=True
            )
            thread.start()
            return True
            
        except Exception as e:
            if callback:
                callback(f"Interpreter execution failed: {str(e)}", is_error=True)
            return False
            
    def _execute_with_native_runtime(self, file_path, args, callback):
        """Execute using native .nc runtime."""
        try:
            # For now, fall back to interpreter method
            # In a full implementation, this would use the .nc runtime directly
            return self._execute_with_interpreter(file_path, args, callback)
            
        except Exception as e:
            if callback:
                callback(f"Native runtime execution failed: {str(e)}", is_error=True)
            return False
            
    def _execute_as_python(self, file_path, args, callback):
        """Execute .nc file as Python (fallback)."""
        try:
            cmd = [sys.executable, file_path]
            if args:
                cmd.extend(args)
                
            thread = threading.Thread(
                target=self._run_command,
                args=(cmd, callback),
                daemon=True
            )
            thread.start()
            return True
            
        except Exception as e:
            if callback:
                callback(f"Python execution failed: {str(e)}", is_error=True)
            return False
            
    def _run_command(self, cmd, callback):
        """Run command and handle output."""
        try:
            process = subprocess.Popen(
                cmd,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True,
                universal_newlines=True
            )
            
            # Send output to callback
            for line in iter(process.stdout.readline, ''):
                if callback:
                    callback(line.strip(), is_error=False)
                    
            stderr_output = process.stderr.read()
            if stderr_output and callback:
                callback(stderr_output.strip(), is_error=True)
                
            return_code = process.wait()
            
            if callback:
                callback(f"Process completed with return code: {return_code}", 
                        is_error=return_code != 0)
                
        except Exception as e:
            if callback:
                callback(f"Execution error: {str(e)}", is_error=True)

class NoodleCoreTerminal(tk.Frame):
    """Enhanced terminal that uses native NoodleCore runtime."""
    
    def __init__(self, parent, **kwargs):
        super().__init__(parent, **kwargs)
        
        self.runtime = NoodleCoreRuntime()
        self.setup_ui()
        self.setup_commands()
        
    def setup_ui(self):
        """Setup terminal UI."""
        # Terminal output area
        self.output_text = tk.Text(
            self, 
            wrap=tk.WORD, 
            bg='black', 
            fg='white',
            font=('Consolas', 10),
            state=tk.DISABLED
        )
        self.output_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=(5, 0))
        
        # Input area
        input_frame = tk.Frame(self)
        input_frame.pack(fill=tk.X, padx=5, pady=5)
        
        tk.Label(input_frame, text="$ ", font=('Consolas', 10), bg='black', fg='white').pack(side=tk.LEFT)
        
        self.input_var = tk.StringVar()
        self.input_entry = tk.Entry(
            input_frame, 
            textvariable=self.input_var,
            font=('Consolas', 10),
            bg='black',
            fg='white',
            insertbackground='white'
        )
        self.input_entry.pack(side=tk.LEFT, fill=tk.X, expand=True)
        self.input_entry.bind('<Return>', self.handle_command)
        
        # Runtime status
        status_frame = tk.Frame(self)
        status_frame.pack(fill=tk.X, padx=5, pady=(0, 5))
        
        self.runtime_status = tk.Label(
            status_frame, 
            text="Checking NoodleCore Runtime...",
            font=('Consolas', 8)
        )
       