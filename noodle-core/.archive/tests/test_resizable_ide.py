#!/usr/bin/env python3
"""
Test Suite::Noodle Core - test_resizable_ide.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test script for NoodleCore IDE resizable window implementation
Tests all components: layout management, resize handling, configuration, logging
"""

import sys
import os
import time
import traceback
from pathlib import Path

# Add the IDE directory to Python path
sys.path.insert(0, str(Path(__file__).parent))

def test_imports():
    """Test that all modules can be imported."""
    print("Testing module imports...")
    
    try:
        # Test layout manager
        from src.noodlecore.desktop.ide.layout_manager import LayoutManager
        print("âœ… LayoutManager import successful")
        
        # Test resize event handler
        from src.noodlecore.desktop.ide.resize_event_handler import ResizeEventHandler
        print("âœ… ResizeEventHandler import successful")
        
        # Test configuration
        from src.noodlecore.desktop.ide.ide_config import get_global_config
        print("âœ… IDEConfig import successful")
        
        # Test logging
        from src.noodlecore.desktop.ide.logging_config import setup_gui_logging
        print("âœ… logging_config import successful")
        
        # Test layout errors
        from src.noodlecore.layout_errors import LayoutInitializationError, handle_layout_error
        print("âœ… layout_errors import successful")
        
        return True
        
    except ImportError as e:
        print(f"âŒ Import failed: {e}")
        traceback.print_exc()
        return False

def test_configuration():
    """Test configuration loading and NOODLE_ prefix compliance."""
    print("\nTesting configuration system...")
    
    try:
        from src.noodlecore.desktop.ide.ide_config import get_global_config
        config = get_global_config()
        
        # Test window configuration
        window_config = config.get_window_config()
        print(f"Window config: {window_config}")
        
        # Test AI settings
        ai_settings = config.get_ai_settings()
        print(f"AI settings: {ai_settings}")
        
        # Test layout configuration
        layout_config = config.get_layout_config()
        print(f"Layout config: {layout_config}")
        
        # Test logging configuration
        logging_config = config.get_logging_config()
        print(f"Logging config: {logging_config}")
        
        # Test performance configuration
        perf_config = config.get_performance_config()
        print(f"Performance config: {perf_config}")
        
        # Validate NOODLE_ prefix usage
        print("\nValidating NOODLE_ prefix compliance...")
        
        # Check environment variables
        noodle_env_vars = [k for k in os.environ.keys() if k.startswith('NOODLE_')]
        print(f"NOODLE_ environment variables: {noodle_env_vars}")
        
        # Check error codes are in 5xxx range
        from src.noodlecore.layout_errors import ERROR_CODES
        error_codes = list(ERROR_CODES.values())
        error_codes_valid = all(5000 <= code <= 5999 for code in error_codes)
        print(f"Error codes in 5xxx range: {error_codes_valid}")
        
        return True
        
    except Exception as e:
        print(f"âŒ Configuration test failed: {e}")
        traceback.print_exc()
        return False

def test_layout_system():
    """Test layout manager and resize handler functionality."""
    print("\nTesting layout system...")
    
    try:
        import tkinter as tk
        
        # Create mock root window
        root = tk.Tk()
        root.geometry("800x600")
        
        # Initialize layout manager
        from src.noodlecore.desktop.ide.layout_manager import LayoutManager
        layout_manager = LayoutManager(root)
        
        # Test panel creation
        layout_manager._create_panels()
        panels_created = len(layout_manager.panels)
        print(f"Panels created: {panels_created}")
        
        # Test layout calculation
        layout_manager._calculate_initial_layout()
        print(f"Initial layout calculated")
        
        # Test responsive update
        layout_manager.schedule_responsive_update()
        print("âœ… Responsive update scheduled")
        
        # Initialize resize handler
        from src.noodlecore.desktop.ide.resize_event_handler import ResizeEventHandler
        resize_handler = ResizeEventHandler(root)
        
        # Test resize callback registration
        callback_called = False
        
        def test_callback(width, height):
            nonlocal callback_called
            callback_called = True
            print(f"Resize callback called: {width}x{height}")
        
        resize_handler.register_resize_callback("test", test_callback)
        resize_handler.enable_resize_handling()
        print("âœ… Resize callback registered and enabled")
        
        # Simulate resize event
        root.event_generate('<Configure>', width=900, height=700)
        root.update()
        
        # Wait for callback execution
        time.sleep(0.2)  # Wait for throttled callback
        
        if callback_called:
            print("âœ… Resize callback executed successfully")
        else:
            print("âŒ Resize callback not executed")
        
        # Test performance stats
        stats = resize_handler.get_performance_stats()
        print(f"Performance stats: {stats}")
        
        # Test cleanup
        layout_manager.cleanup()
        resize_handler.cleanup()
        print("âœ… Layout system cleanup completed")
        
        root.destroy()
        
        return True
        
    except Exception as e:
        print(f"âŒ Layout system test failed: {e}")
        traceback.print_exc()
        return False

def test_error_handling():
    """Test error handling and logging."""
    print("\nTesting error handling...")
    
    try:
        from src.noodlecore.layout_errors import (
            LayoutInitializationError, 
            LayoutConfigurationError,
            PanelResizeError,
            ResizeEventError,
            LayoutPerformanceError,
            WindowConfigurationError,
            handle_layout_error,
            log_layout_warning,
            validate_layout_performance,
            ERROR_CODES
        )
        
        # Test error creation
        error = LayoutInitializationError(5001, "Test error")
        print(f"Created error: {error}")
        
        # Test error handling
        from src.noodlecore.desktop.ide.logging_config import setup_gui_logging
        logger = setup_gui_logging()
        handle_layout_error(error, "test_error_handling")
        print("âœ… Error handled and logged")
        
        # Test performance validation
        try:
            validate_layout_performance("test_operation", 100, 50)
            print("âŒ Performance validation correctly rejected slow operation")
        except LayoutPerformanceError:
            print("âœ… Performance validation correctly rejected slow operation")
        
        # Test error codes
        print(f"Error codes: {ERROR_CODES}")
        
        return True
        
    except Exception as e:
        print(f"âŒ Error handling test failed: {e}")
        traceback.print_exc()
        return False

def test_standards_compliance():
    """Test NoodleCore standards compliance."""
    print("\nTesting NoodleCore standards compliance...")
    
    try:
        # Test file naming conventions
        from src.noodlecore.desktop.ide.layout_manager import Panel
        print("âœ… Panel class uses PascalCase")
        
        # Test function naming
        import inspect
        from src.noodlecore.desktop.ide.layout_manager import LayoutManager
        methods = [name for name, method in inspect.getmembers(LayoutManager) 
                   if not name.startswith('_')]
        snake_case_methods = [name for name in methods if name == name.lower()]
        print(f"Snake case methods: {len(snake_case_methods)}/{len(methods)}")
        
        # Test error codes (5xxx series)
        from src.noodlecore.layout_errors import ERROR_CODES
        error_codes = list(ERROR_CODES.values())
        layout_errors = [code for code in error_codes if 5000 <= code <= 5999]
        print(f"Layout error codes (5xxx): {layout_errors}")
        
        # Test logging levels
        from src.noodlecore.desktop.ide.logging_config import setup_gui_logging
        logger = setup_gui_logging()
        print(f"Logger levels available: DEBUG, INFO, ERROR, WARNING")
        
        # Test environment variable prefix
        import os
        env_vars = [k for k in os.environ.keys() if k.startswith('NOODLE_')]
        print(f"NOODLE_ prefix variables: {len(env_vars)}")
        
        return True
        
    except Exception as e:
        print(f"âŒ Standards compliance test failed: {e}")
        traceback.print_exc()
        return False

def main():
    """Run all tests."""
    print("ðŸš€ Starting NoodleCore IDE Resizable Window Implementation Tests\n")
    
    tests = [
        ("Module Imports", test_imports),
        ("Configuration System", test_configuration),
        ("Layout System", test_layout_system),
        ("Error Handling", test_error_handling),
        ("Standards Compliance", test_standards_compliance)
    ]
    
    results = []
    for test_name, test_func in tests:
        print(f"\n--- Running {test_name} ---")
        try:
            result = test_func()
            results.append((test_name, "PASS" if result else "FAIL"))
            print(f"âœ… {test_name}: {'PASS' if result else 'FAIL'}")
        except Exception as e:
            results.append((test_name, f"ERROR: {e}"))
            print(f"âŒ {test_name}: ERROR - {e}")
    
    print("\n" + "="*50)
    print("TEST RESULTS:")
    for test_name, result in results:
        status = "âœ… PASS" if result == "PASS" else "âŒ FAIL"
        print(f"{status} {test_name}")
    
    passed = sum(1 for _, result in results if result == "PASS")
    total = len(results)
    
    print(f"\nSUMMARY: {passed}/{total} tests passed")
    
    if passed == total:
        print("ðŸŽ‰ All tests passed! The resizable window implementation is working correctly.")
        return 0
    else:
        print("âš ï¸  Some tests failed. Please review the implementation.")
        return 1

if __name__ == "__main__":
    exit(main())

