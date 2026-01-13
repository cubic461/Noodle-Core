#!/usr/bin/env python3
"""
Noodle Core::Self Improvement Monitor - self_improvement_monitor.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Real-time Self-Improvement System Monitor
Shows actual performance data and optimization results
"""

import os
import sys
import time
import json
import psutil
import threading
from pathlib import Path
from typing import Dict, List, Any, Optional
from datetime import datetime
import subprocess

class SelfImprovementMonitor:
    """Real-time monitor for NoodleCore self-improvement system."""
    
    def __init__(self):
        self.monitoring = True
        self.performance_data = []
        self.optimization_results = []
        self.start_time = time.time()
        
        # Add current directory to path for imports
        current_dir = Path(__file__).parent
        sys.path.insert(0, str(current_dir))
        
        print("ðŸ” Self-Improvement Monitor initialized")
        print(f"ðŸ“Š Monitoring started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        
    def get_system_performance(self) -> Dict[str, Any]:
        """Get real system performance metrics."""
        return {
            "timestamp": datetime.now().isoformat(),
            "cpu_percent": psutil.cpu_percent(interval=1),
            "memory_percent": psutil.virtual_memory().percent,
            "memory_used_gb": psutil.virtual_memory().used / (1024**3),
            "disk_io": psutil.disk_io_counters()._asdict() if psutil.disk_io_counters() else {},
            "network_io": psutil.net_io_counters()._asdict() if psutil.net_io_counters() else {},
            "process_count": len(psutil.pids())
        }
    
    def check_self_improvement_processes(self) -> List[Dict[str, Any]]:
        """Check for running self-improvement processes."""
        processes = []
        
        # Check for Python processes related to self-improvement
        for proc in psutil.process_iter(['pid', 'name', 'cmdline']):
            try:
                cmdline = ' '.join(proc.info['cmdline'] or [])
                if any(keyword in cmdline.lower() for keyword in ['self_improvement', 'noodlecore', 'trm_agent']):
                    processes.append({
                        "pid": proc.info['pid'],
                        "name": proc.info['name'],
                        "cmdline": cmdline,
                        "cpu_percent": proc.cpu_percent(),
                        "memory_mb": proc.memory_info().rss / (1024*1024)
                    })
            except (psutil.NoSuchProcess, psutil.AccessDenied):
                continue
                
        return processes
    
    def analyze_code_files(self) -> Dict[str, Any]:
        """Analyze actual code files for optimization opportunities."""
        noodlecore_dir = Path("noodle-core/src/noodlecore")
        if not noodlecore_dir.exists():
            return {"error": "NoodleCore directory not found"}
        
        analysis = {
            "total_files": 0,
            "python_files": 0,
            "total_lines": 0,
            "complex_functions": 0,
            "large_files": [],
            "recent_changes": []
        }
        
        # Count files and lines
        for py_file in noodlecore_dir.rglob("*.py"):
            analysis["python_files"] += 1
            try:
                with open(py_file, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                    analysis["total_lines"] += len(lines)
                    
                    # Check for complex functions (>50 lines)
                    in_function = False
                    function_lines = 0
                    for line in lines:
                        if line.strip().startswith('def '):
                            in_function = True
                            function_lines = 0
                        elif in_function and line.strip():
                            function_lines += 1
                            if function_lines > 50:
                                analysis["complex_functions"] += 1
                                in_function = False
                        elif in_function and not line.strip() and function_lines == 0:
                            pass
                        elif in_function and line.strip().startswith(('def ', 'class ')):
                            in_function = False
                    
                    # Track large files
                    if len(lines) > 500:
                        analysis["large_files"].append({
                            "file": str(py_file.relative_to(noodlecore_dir)),
                            "lines": len(lines)
                        })
                        
            except Exception as e:
                print(f"Error analyzing {py_file}: {e}")
        
        analysis["total_files"] = analysis["python_files"]
        return analysis
    
    def run_optimization_test(self) -> Dict[str, Any]:
        """Run actual optimization test on a sample file."""
        test_file = Path("noodle-core/src/noodlecore/desktop/ide/native_gui_ide.py")
        if not test_file.exists():
            return {"error": "Test file not found"}
        
        # Measure performance before optimization
        start_time = time.time()
        
        try:
            # Read and parse the file
            with open(test_file, 'r', encoding='utf-8') as f:
                content = f.read()
            
            # Simulate optimization analysis
            lines = content.split('\n')
            issues_found = []
            
            # Check for common issues
            for i, line in enumerate(lines, 1):
                if 'import *' in line:
                    issues_found.append(f"Line {i}: Wildcard import")
                elif line.strip().startswith('print(') and 'print(' not in line.strip():
                    issues_found.append(f"Line {i}: Debug print statement")
                elif len(line) > 120:
                    issues_found.append(f"Line {i}: Line too long ({len(line)} chars)")
            
            parse_time = time.time() - start_time
            
            # Simulate optimization suggestions
            optimizations = []
            if issues_found:
                optimizations = [
                    {
                        "type": "Code Quality",
                        "issues": len(issues_found),
                        "suggestions": "Remove debug prints, fix imports, break long lines"
                    }
                ]
            
            return {
                "file": str(test_file),
                "lines_analyzed": len(lines),
                "issues_found": len(issues_found),
                "optimization_potential": len(optimizations),
                "analysis_time_ms": round(parse_time * 1000, 2),
                "optimizations": optimizations
            }
            
        except Exception as e:
            return {"error": f"Analysis failed: {e}"}
    
    def display_real_time_data(self):
        """Display real-time monitoring data."""
        while self.monitoring:
            os.system('cls' if os.name == 'nt' else 'clear')
            
            print("=" * 80)
            print("ðŸ¤– NOODLECORE SELF-IMPROVEMENT MONITOR - REAL DATA")
            print("=" * 80)
            
            # System Performance
            perf = self.get_system_performance()
            print(f"\nðŸ“Š SYSTEM PERFORMANCE (Real-time)")
            print(f"CPU: {perf['cpu_percent']:.1f}% | Memory: {perf['memory_percent']:.1f}% ({perf['memory_used_gb']:.2f}GB)")
            print(f"Processes: {perf['process_count']} | Time: {datetime.now().strftime('%H:%M:%S')}")
            
            # Self-Improvement Processes
            processes = self.check_self_improvement_processes()
            print(f"\nðŸ” ACTIVE SELF-IMPROVEMENT PROCESSES")
            if processes:
                for proc in processes:
                    print(f"PID {proc['pid']}: {proc['name']} (CPU: {proc['cpu_percent']:.1f}%, MEM: {proc['memory_mb']:.1f}MB)")
                    print(f"  Command: {proc['cmdline'][:80]}...")
            else:
                print("âŒ No self-improvement processes found")
            
            # Code Analysis
            code_analysis = self.analyze_code_files()
            if "error" not in code_analysis:
                print(f"\nðŸ“ CODEBASE ANALYSIS")
                print(f"Python files: {code_analysis['python_files']} | Total lines: {code_analysis['total_lines']}")
                print(f"Complex functions: {code_analysis['complex_functions']} | Large files: {len(code_analysis['large_files'])}")
            
            # Optimization Test
            opt_result = self.run_optimization_test()
            if "error" not in opt_result:
                print(f"\nâš¡ OPTIMIZATION TEST RESULTS")
                print(f"File: {opt_result['file'].split('/')[-1]}")
                print(f"Lines analyzed: {opt_result['lines_analyzed']} | Issues found: {opt_result['issues_found']}")
                print(f"Analysis time: {opt_result['analysis_time_ms']}ms")
                if opt_result['optimizations']:
                    for opt in opt_result['optimizations']:
                        print(f"ðŸ’¡ {opt['type']}: {opt['suggestions']}")
            
            # Performance History
            self.performance_data.append(perf)
            if len(self.performance_data) > 10:
                self.performance_data.pop(0)
            
            if len(self.performance_data) > 1:
                avg_cpu = sum(p['cpu_percent'] for p in self.performance_data) / len(self.performance_data)
                avg_mem = sum(p['memory_percent'] for p in self.performance_data) / len(self.performance_data)
                print(f"\nðŸ“ˆ PERFORMANCE HISTORY (Last {len(self.performance_data)} samples)")
                print(f"Avg CPU: {avg_cpu:.1f}% | Avg Memory: {avg_mem:.1f}%")
            
            print("\n" + "=" * 80)
            print("Press Ctrl+C to stop monitoring...")
            
            time.sleep(2)
    
    def start_monitoring(self):
        """Start the real-time monitoring."""
        try:
            self.display_real_time_data()
        except KeyboardInterrupt:
            self.monitoring = False
            print("\n\nâœ… Monitoring stopped by user")
            
            # Final summary
            total_time = time.time() - self.start_time
            print(f"\nðŸ“‹ MONITORING SUMMARY")
            print(f"Total monitoring time: {total_time:.1f} seconds")
            print(f"Performance samples collected: {len(self.performance_data)}")
            
            if self.performance_data:
                avg_cpu = sum(p['cpu_percent'] for p in self.performance_data) / len(self.performance_data)
                avg_mem = sum(p['memory_percent'] for p in self.performance_data) / len(self.performance_data)
                print(f"Average CPU usage: {avg_cpu:.1f}%")
                print(f"Average Memory usage: {avg_mem:.1f}%")

if __name__ == "__main__":
    monitor = SelfImprovementMonitor()
    monitor.start_monitoring()

