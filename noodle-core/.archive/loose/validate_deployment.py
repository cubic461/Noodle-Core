#!/usr/bin/env python3
"""
Noodle Core::Validate Deployment - validate_deployment.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Deployment Validation Script for NoodleCore Distributed System
This script validates the deployment readiness of all components.
"""

import os
import sys
from pathlib import Path

def validate_file_structure():
    """Validate the file structure and components."""
    print("ðŸ” Validating NoodleCore Distributed System Structure...")
    
    base_path = Path("./src/noodlecore/distributed")
    
    # Required directories
    required_dirs = [
        "controller",
        "communication", 
        "coordination",
        "utils",
        "test_files"
    ]
    
    # Required files
    required_files = [
        "main_system.py",
        "ai_role_integration.py",
        "test_system.py",
        "IMPLEMENTATION_DOCUMENTATION.md",
        "controller/central_controller.py",
        "controller/task_orchestrator.py", 
        "controller/performance_optimizer.py",
        "communication/actor_model.py",
        "coordination/flag_system.py",
        "coordination/task_system.py",
        "utils/logging_utils.py",
        "utils/validation_utils.py"
    ]
    
    validation_results = {"success": True, "errors": []}
    
    # Check directory structure
    print("\nðŸ“ Checking directory structure...")
    for dir_name in required_dirs:
        dir_path = base_path / dir_name
        if dir_path.exists() and dir_path.is_dir():
            print(f"âœ… {dir_name}/ directory found")
        else:
            print(f"âŒ {dir_name}/ directory missing")
            validation_results["errors"].append(f"Missing directory: {dir_name}")
            validation_results["success"] = False
    
    # Check required files
    print("\nðŸ“„ Checking required files...")
    for file_name in required_files:
        file_path = base_path / file_name
        if file_path.exists() and file_path.is_file():
            size = file_path.stat().st_size
            print(f"âœ… {file_name} ({size:,} bytes)")
        else:
            print(f"âŒ {file_name} missing")
            validation_results["errors"].append(f"Missing file: {file_name}")
            validation_results["success"] = False
    
    return validation_results

def validate_imports():
    """Validate basic imports without async operations."""
    print("\nðŸ”Œ Validating module imports...")
    
    import_tests = [
        ("CentralController", "from src.noodlecore.distributed.controller.central_controller import CentralController"),
        ("TaskOrchestrator", "from src.noodlecore.distributed.controller.task_orchestrator import TaskOrchestrator"),
        ("PerformanceOptimizer", "from src.noodlecore.distributed.controller.performance_optimizer import PerformanceOptimizer"),
        ("ActorModel", "from src.noodlecore.distributed.communication.actor_model import ActorModel"),
        ("FlagSystem", "from src.noodlecore.distributed.coordination.flag_system import FlagSystem"),
        ("TaskSystem", "from src.noodlecore.distributed.coordination.task_system import TaskSystem"),
        ("LoggingUtils", "from src.noodlecore.distributed.utils.logging_utils import LoggingUtils"),
        ("Validator", "from src.noodlecore.distributed.utils.validation_utils import Validator"),
    ]
    
    import_results = {"success": True, "errors": []}
    
    sys.path.insert(0, '.')
    
    for name, import_stmt in import_tests:
        try:
            exec(import_stmt)
            print(f"âœ… {name} import successful")
        except Exception as e:
            print(f"âŒ {name} import failed: {e}")
            import_results["errors"].append(f"{name} import error: {e}")
            import_results["success"] = False
    
    return import_results

def generate_deployment_report():
    """Generate a comprehensive deployment report."""
    print("\nðŸ“Š Generating deployment report...")
    
    # File structure validation
    structure_validation = validate_file_structure()
    
    # Import validation
    import_validation = validate_imports()
    
    # Overall status
    overall_success = structure_validation["success"] and import_validation["success"]
    
    print(f"\n{'='*70}")
    print("ðŸš€ NOODLECORE DISTRIBUTED SYSTEM - DEPLOYMENT REPORT")
    print(f"{'='*70}")
    
    print(f"\nðŸ“‹ Summary:")
    print(f"   File Structure: {'âœ… PASS' if structure_validation['success'] else 'âŒ FAIL'}")
    print(f"   Module Imports: {'âœ… PASS' if import_validation['success'] else 'âŒ FAIL'}")
    print(f"   Overall Status: {'âœ… DEPLOYMENT READY' if overall_success else 'âŒ ISSUES FOUND'}")
    
    if not overall_success:
        print(f"\nðŸš¨ Issues Found:")
        all_errors = structure_validation["errors"] + import_validation["errors"]
        for i, error in enumerate(all_errors, 1):
            print(f"   {i}. {error}")
    
    print(f"\nðŸ“ˆ System Components:")
    components = [
        ("Central Controller", "Master coordination system"),
        ("Task Orchestrator", "Intelligent task distribution"),
        ("Performance Optimizer", "NBC runtime optimization"),
        ("Actor Model", "Distributed communication"),
        ("Flag System", "Role activity tracking"),
        ("Task System", "Matrix-based task breakdown"),
        ("AI Role Integration", "Existing system bridge"),
        ("Utility Modules", "Logging and validation")
    ]
    
    for component, description in components:
        print(f"   âœ… {component}: {description}")
    
    print(f"\nðŸ§ª Testing Status:")
    test_files = [
        ("test_system.py", "Comprehensive test suite"),
        ("IMPLEMENTATION_DOCUMENTATION.md", "Complete usage guide")
    ]
    
    for test_file, description in test_files:
        if (Path("./src/noodlecore/distributed") / test_file).exists():
            print(f"   âœ… {test_file}: {description}")
        else:
            print(f"   âŒ {test_file}: Missing")
    
    print(f"\nðŸ”— Integration Points:")
    integration_points = [
        ("NoodleCore Runtime", "Matrix operations and optimization"),
        ("Existing Role Manager", "AIRoleManager integration"),
        ("IDE Integration", "Role document management"),
        ("Chat System", "Role context injection")
    ]
    
    for point, description in integration_points:
        print(f"   ðŸ”— {point}: {description}")
    
    print(f"\nðŸ“ Next Steps:")
    if overall_success:
        print("   1. Run comprehensive test suite")
        print("   2. Deploy to production environment")  
        print("   3. Configure monitoring and logging")
        print("   4. Begin user training and documentation")
    else:
        print("   1. Address identified issues")
        print("   2. Re-run validation")
        print("   3. Deploy when all checks pass")
    
    print(f"\n{'='*70}")
    print(f"Report generated: {__import__('datetime').datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print(f"{'='*70}")
    
    return {
        "overall_success": overall_success,
        "structure_valid": structure_validation["success"],
        "imports_valid": import_validation["success"],
        "structure_errors": structure_validation["errors"],
        "import_errors": import_validation["errors"]
    }

if __name__ == "__main__":
    report = generate_deployment_report()
    
    # Exit with appropriate code
    sys.exit(0 if report["overall_success"] else 1)

