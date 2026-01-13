#!/usr/bin/env python3
"""
Noodle::Capability System Demo - capability_system_demo.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Demo: Capability Enforcement System
Shows the complete capability enforcement system in action.
"""

import sys
import os
from pathlib import Path

# Import capability enforcement
from capability_enforcement import (
    CapabilityEnforcer,
    RESTRICTED_PROFILE,
    PERMISSIVE_PROFILE,
    CapabilityViolationError,
    ResourceLimits
)

def demo_restricted_execution():
    """Demonstrate restricted capability execution."""
    print("\n" + "=" * 80)
    print(" DEMO 1: Restricted Capability Profile")
    print("=" * 80)
    
    enforcer = CapabilityEnforcer(RESTRICTED_PROFILE)
    
    try:
        with enforcer:
            print("\nâœ“ RESTRICTED profile active")
            print("  - Only current directory and /tmp access")
            print("  - No subprocess creation")
            print("  - No system commands")
            print("  - Resource limits: 512MB memory, 120s execution")
            
            # Allowed operation: write to current directory
            print("\n Test 1: Write to current directory (ALLOWED)")
            with open("demo_output.txt", "w") as f:
                f.write("Capability test - this is allowed")
            print(" âœ“ Successfully wrote to demo_output.txt")
            
            # Resource monitoring
            print("\n Test 2: Resource monitoring")
            stats = enforcer.get_resource_stats()
            print(f"   Execution time: {stats.get('elapsed_time', 0):.3f}s")
            print(f"   Peak memory: {stats.get('peak_memory_mb', 0):.1f}MB")
            print(f"   Violations so far: {stats.get('violations', 0)}")
            
            # Blocked operation: subprocess
            print("\n Test 3: Subprocess creation (BLOCKED)")
            try:
                import subprocess
                subprocess.run(["echo", "test"])
                print(" âœ— ERROR: Should have been blocked!")
            except Exception as e:
                print(f" âœ“ Correctly blocked: {type(e).__name__}")
            
            # Blocked operation: system command
            print("\n Test 4: System command (BLOCKED)")
            try:
                result = os.system("echo test")
                print(" âœ— ERROR: Should have been blocked!")
            except Exception:
                print(" âœ“ Correctly blocked system command")
            
            print("\nðŸ›¡ï¸ Resource usage at end:")
            final_stats = enforcer.get_resource_stats()
            print(f"   Total violations: {final_stats.get('violations', 0)}")
            print(f"   Memory used: {final_stats.get('peak_memory_mb', 0):.1f}MB")
    
    except Exception as e:
        print(f"Error: {e}")
    
    # Show violations
    violations = enforcer.get_violations()
    print(f"\nðŸš¨ Total violations detected: {len(violations)}")
    for i, v in enumerate(violations, 1):
        print(f"   {i}. [{v.level.value.upper()}] {v.violation_type.value}: {v.message}")


def demo_permissive_execution():
    """Demonstrate permissive capability profile."""
    print("\n" + "=" * 80)
    print(" DEMO 2: Permissive Capability Profile")
    print("=" * 80)
    
    enforcer = CapabilityEnforcer(PERMISSIVE_PROFILE)
    
    try:
        with enforcer:
            print("\nâœ“ PERMISSIVE profile active")
            print("  - Full file system access")
            print("  - Subprocess creation allowed (limited)")
            print("  - Resource limits still enforced")
            
            print("\n Test 1: File operations (ALLOWED)")
            with open("demo_permissive.txt", "w") as f:
                f.write("Permissive mode allows more operations")
            print(" âœ“ Successfully wrote file")
            
            print("\n Resource monitoring still active:")
            stats = enforcer.get_resource_stats()
            print(f"   Time: {stats.get('elapsed_time', 0):.3f}s")
            print(f"   Memory: {stats.get('peak_memory_mb', 0):.1f}MB")
    
    except Exception as e:
        print(f"Error: {e}")
    
    violations = enforcer.get_violations()
    print(f"\nâœ“ Violations in permissive mode: {len(violations)}")


def demo_custom_profile():
    """Demonstrate custom capability profile."""
    print("\n" + "=" * 80)
    print(" DEMO 3: Custom Capability Profile")
    print("=" * 80)
    
    # Create custom strict profile
    strict_limits = ResourceLimits(
        max_memory_mb=100,
        max_execution_time=5,
        max_disk_writes_mb=5,
        max_cpu_time=3
    )
    
    from capability_enforcement import CapabilityProfile
    
    custom_profile = CapabilityProfile(
        name="super_strict",
        resources=strict_limits
    )
    
    enforcer = CapabilityEnforcer(custom_profile)
    
    try:
        with enforcer:
            print("\nâœ“ SUPER_STRICT profile active")
            print("  - 100MB memory limit")
            print("  - 5 second execution time limit")
            print("  - 3 second CPU time limit")
            print("  - 5MB disk writes limit")
            
            print("\n Test 1: Normal file operation")
            with open("demo_custom.txt", "w") as f:
                f.write("Custom profile test")
            print(" âœ“ File write successful")
            
            print("\n Resource limits enforced:")
            stats = enforcer.get_resource_stats()
            print(f"   Memory: {stats.get('current_memory_mb', 0):.1f}MB / {strict_limits.max_memory_mb}MB")
            print(f"   Time: {stats.get('elapsed_time', 0):.2f}s / {strict_limits.max_execution_time}s")
    
    except Exception as e:
        print(f"Error: {e}")
    
    violations = enforcer.get_violations()
    print(f"\nâœ“ Violations: {len(violations)}")


def demo_integration_with_runtime_adapter():
    """Demo how capability enforcement integrates with Python runtime adapter."""
    print("\n" + "=" * 80)
    print(" DEMO 4: Integration with Python Runtime Adapter")
    print("=" * 80)
    
    print("\nConceptual integration:")
    print("  The PythonRuntimeAdapter uses CapabilityEnforcer to:")
    print("  1. Set up capability restrictions before script execution")
    print("  2. Monitor resource usage during execution")
    print("  3. Collect violations and add to trace")
    print("  4. Clean up and restore original functions")
    
    print("\n Integration code would look like:")
    code_example = '''
class PythonRuntimeAdapter:
    def observe(self, script_path, args=None):
        # Initialize capability enforcement
        enforcer = CapabilityEnforcer(RESTRICTED_PROFILE)
        
        try:
            with enforcer:
                # Execute script with capability restrictions
                result = self._execute_script(script_path, args)
                
                # Collect violations and add to trace
                violations = enforcer.get_violations()
                for violation in violations:
                    self.trace.add_violation(violation)
                
                # Add resource stats to trace
                stats = enforcer.get_resource_stats()
                self.trace.add_resource_stats(stats)
                
        finally:
            # Enforcement automatically cleaned up by context manager
            pass
    '''
    print(code_example)


def main():
    """Run all capability enforcement demos."""
    print("\n" + "â–’" * 80)
    print(" " * 20 + "CAPABILITY ENFORCEMENT SYSTEM DEMONSTRATION")
    print("â–’" * 80)
    
    print("\nðŸ”’ This system provides:")
    print("   - File system access control")
    print("   - Resource usage monitoring (CPU, memory, disk, time)")
    print("   - Subprocess creation restrictions")
    print("   - Network access control (network features not shown here)")
    print("   - Violation detection and enforcement")
    print("   - Flexible profile configuration")
    
    # Run demonstrations
    demo_restricted_execution()
    demo_permissive_execution()
    demo_custom_profile()
    demo_integration_with_runtime_adapter()
    
    # Summary
    print("\n" + "â–’" * 80)
    print(" " * 25 + "DEMONSTRATION COMPLETE")
    print("â–’" * 80)
    
    print("\nâœ… Capability enforcement system is ready!")
    print("\nNext steps:")
    print("  1. Integrate with PythonRuntimeAdapter")
    print("  2. Add network capability hooks")
    print("  3. Implement sandbox isolation")
    print("  4. Add configuration file support")
    print("  5. Create capability profiles for different migration scenarios")
    print()


if __name__ == "__main__":
    # Change to the source_harness directory for imports
    os.chdir(Path(__file__).parent)
    main()


