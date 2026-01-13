#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - test_nbc_vm.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Test Suite voor NBC VM - FASE 1

Test de NBC runtime met verschillende scenario's:
1. Simpele constant loading
2. Arithmetic operations  
3. Variable storage and loading
4. Control flow (loops, conditionals)
5. List building
6. Error handling

Usage:
    python test_nbc_vm.py          # Run all tests
    python test_nbc_vm.py -v       # Verbose output
    python test_nbc_vm.py test_5   # Run specific test
"""

import sys
from pathlib import Path

# Voeg noodle_lang toe aan pad
sys.path.insert(0, str(Path(__file__).parent / "src"))

from noodle_lang.nbc_vm import *


def test_1_load_const():
    """Test 1: LOAD_CONST and RETURN_VALUE"""
    print("\\n=== Test 1: LOAD_CONST and RETURN_VALUE ===")
    
    bytecode = NBCBytecode()
    const_idx = bytecode.add_constant("Hallo vanuit NBC!")
    bytecode.add_instruction(Opcode.LOAD_CONST, const_idx)
    bytecode.add_instruction(Opcode.RETURN_VALUE)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    assert result == "Hallo vanuit NBC!", f"Expected 'Hallo vanuit NBC!', got {result!r}"
    print(f"   âœ… PASS: Returned '{result}'")
    return True


def test_2_arithmetic():
    """Test 2: Basic arithmetic operations"""
    print("\\n=== Test 2: Arithmetic Operations ===")
    
    bytecode = NBCBytecode()
    
    # 5 + 3 * 2
    c5 = bytecode.add_constant(5)
    c3 = bytecode.add_constant(3)
    c2 = bytecode.add_constant(2)
    
    # 3 * 2 = 6
    bytecode.add_instruction(Opcode.LOAD_CONST, c3)
    bytecode.add_instruction(Opcode.LOAD_CONST, c2)
    bytecode.add_instruction(Opcode.BINARY_MULTIPLY)
    
    # 5 + 6 = 11
    bytecode.add_instruction(Opcode.LOAD_CONST, c5)
    bytecode.add_instruction(Opcode.BINARY_ADD)
    
    bytecode.add_instruction(Opcode.RETURN_VALUE)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    assert result == 11, f"Expected 11, got {result}"
    print(f"   âœ… PASS: 5 + 3 * 2 = {result}")
    return True


def test_3_variables():
    """Test 3: Variable storage and loading"""
    print("\\n=== Test 3: Variables ===")
    
    bytecode = NBCBytecode()
    
    # Store variable 'x' with value 42, then load it
    c42 = bytecode.add_constant(42)
    x_idx = bytecode.add_name("x")
    y_idx = bytecode.add_name("y")
    
    # x = 42
    bytecode.add_instruction(Opcode.LOAD_CONST, c42)
    bytecode.add_instruction(Opcode.STORE_NAME, x_idx)
    
    # y = x (load x and store in y)
    bytecode.add_instruction(Opcode.LOAD_NAME, x_idx)
    bytecode.add_instruction(Opcode.STORE_NAME, y_idx)
    
    # Return y
    bytecode.add_instruction(Opcode.LOAD_NAME, y_idx)
    bytecode.add_instruction(Opcode.RETURN_VALUE)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    assert result == 42, f"Expected 42, got {result}"
    print(f"   âœ… PASS: Variable handling works (x=42, y=x, return y = {result})")
    print(f"   Heap state: {vm.get_heap_dump()}")
    return True


def test_4_comparison():
    """Test 4: Comparison operations"""
    print("\\n=== Test 4: Comparisons ===")
    
    test_cases = [
        (5, 3, ">", True),
        (5, 5, "==", True),
        (3, 5, "<", True),
        (5, 3, "!=", True),
        (5, 10, "<=", True),
    ]
    
    for a, b, op, expected in test_cases:
        bytecode = NBCBytecode()
        
        ca = bytecode.add_constant(a)
        cb = bytecode.add_constant(b)
        
        bytecode.add_instruction(Opcode.LOAD_CONST, ca)
        bytecode.add_instruction(Opcode.LOAD_CONST, cb)
        bytecode.add_instruction(Opcode.COMPARE_OP, op)
        bytecode.add_instruction(Opcode.RETURN_VALUE)
        
        vm = NBCVM()
        vm.load_bytecode(bytecode)
        result = vm.execute()
        
        assert result == expected, f"Expected {a} {op} {b} = {expected}, got {result}"
    
    print(f"   âœ… PASS: All comparison tests passed")
    return True


def test_5_conditionals():
    """Test 5: Conditional jumps"""
    print("\\n=== Test 5: Conditionals ===")
    
    # Simulate: if 5 > 3 then return 10 else return 20
    bytecode = NBCBytecode()
    
    c5 = bytecode.add_constant(5)
    c3 = bytecode.add_constant(3)
    c10 = bytecode.add_constant(10)
    c20 = bytecode.add_constant(20)
    
    # Compare 5 > 3
    bytecode.add_instruction(Opcode.LOAD_CONST, c5)
    bytecode.add_instruction(Opcode.LOAD_CONST, c3)
    bytecode.add_instruction(Opcode.COMPARE_OP, ">")
    
    # If false (5 not > 3), jump to else block
    # Target: instruction 8 (the else block)
    bytecode.add_instruction(Opcode.POP_JUMP_IF_FALSE, 8)
    
    # Then block: return 10
    bytecode.add_instruction(Opcode.LOAD_CONST, c10)  # IP=5
    bytecode.add_instruction(Opcode.RETURN_VALUE)      # IP=6
    
    # Else block: return 20
    bytecode.add_instruction(Opcode.LOAD_CONST, c20)  # IP=7
    bytecode.add_instruction(Opcode.RETURN_VALUE)      # IP=8
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    assert result == 10, f"Expected 10 (because 5>3 is true), got {result}"
    print(f"   âœ… PASS: Conditional logic works (5>3 â†’ return 10 = {result})")
    return True


def test_6_lists():
    """Test 6: List building"""
    print("\\n=== Test 6: Lists ===")
    
    bytecode = NBCBytecode()
    
    # Build list [10, 20, 30]
    c10 = bytecode.add_constant(10)
    c20 = bytecode.add_constant(20)
    c30 = bytecode.add_constant(30)
    
    # Push elements onto stack
    bytecode.add_instruction(Opcode.LOAD_CONST, c10)
    bytecode.add_instruction(Opcode.LOAD_CONST, c20)
    bytecode.add_instruction(Opcode.LOAD_CONST, c30)
    
    # Build list with 3 elements
    bytecode.add_instruction(Opcode.BUILD_LIST, 3)
    bytecode.add_instruction(Opcode.RETURN_VALUE)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    expected = [10, 20, 30]
    assert result == expected, f"Expected {expected}, got {result}"
    print(f"   âœ… PASS: List building works: {result}")
    return True


def test_7_hello_world():
    """Test 7: Hello World in NBC - integrated test"""
    print("\\n=== Test 7: Hello World ===")
    
    # Define a hello world function in NBC bytecode
    bytecode = NBCBytecode()
    
    # Constants
    hello_str = bytecode.add_constant("Hallo vanuit NoodleCore!")
    greeting_idx = bytecode.add_name("greeting")
    
    # Simulate: let greeting = "Hallo vanuit NoodleCore!"
    #           return greeting
    
    bytecode.add_instruction(Opcode.LOAD_CONST, hello_str)  # Push string
    bytecode.add_instruction(Opcode.STORE_NAME, greeting_idx)  # Store in greeting
    bytecode.add_instruction(Opcode.LOAD_NAME, greeting_idx)   # Load greeting
    bytecode.add_instruction(Opcode.RETURN_VALUE)  # Return
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    expected = "Hallo vanuit NoodleCore!"
    assert result == expected, f"Expected {expected!r}, got {result!r}"
    print(f"   âœ… PASS: Hello World works!")
    print(f"   Output: '{result}'")
    print(f"   VM state: {vm.instructions_executed} instructions, max_stack={vm.max_stack_depth}")
    return True


def test_error_cases():
    """Test error cases and exception handling"""
    print("\\n=== Test Error Cases ===")
    
    # Test 1: Division by zero
    bytecode = NBCBytecode()
    c5 = bytecode.add_constant(5)
    c0 = bytecode.add_constant(0)
    
    bytecode.add_instruction(Opcode.LOAD_CONST, c5)
    bytecode.add_instruction(Opcode.LOAD_CONST, c0)
    bytecode.add_instruction(Opcode.BINARY_DIVIDE)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    
    try:
        result = vm.execute()
        print(f"   âŒ FAIL: Should have raised error for division by zero")
        return False
    except NBCRuntimeError as e:
        if "Division by zero" in str(e):
            print(f"   âœ… PASS: Division by zero caught: {e}")
        else:
            print(f"   âŒ FAIL: Wrong error message: {e}")
            return False
    
    # Test 2: Undefined variable
    bytecode = NBCBytecode()
    idx = bytecode.add_name("undefined_var")
    bytecode.add_instruction(Opcode.LOAD_NAME, idx)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    
    try:
        result = vm.execute()
        print(f"   âŒ FAIL: Should have raised error for undefined variable")
        return False
    except NBCRuntimeError as e:
        print(f"   âœ… PASS: Undefined variable caught: {e}")
    
    return True


def run_all_tests():
    """Run all tests"""
    tests = [
        ("LOAD_CONST & RETURN", test_1_load_const),
        ("ARITHMETIC", test_2_arithmetic),
        ("VARIABLES", test_3_variables),
        ("COMPARISONS", test_4_comparison),
        ("CONDITIONALS", test_5_conditionals),
        ("LISTS", test_6_lists),
        ("HELLO_WORLD", test_7_hello_world),
        ("ERROR_CASES", test_error_cases),
    ]
    
    print("=" * 60)
    print("NBC VM Test Suite - FASE 1")
    print("=" * 60)
    
    passed = 0
    failed = 0
    
    for test_name, test_func in tests:
        try:
            if test_func():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            failed += 1
            print(f"   âŒ FAIL: {type(e).__name__}: {e}")
    
    print(f"\\n{'='*60}")
    print(f"RESULTS: {passed} passed, {failed} failed")
    print(f"{'='*60}")
    
    if failed == 0:
        print("\\nâœ… ALL TESTS PASSED! NBC VM FASE 1 is operationeel!")
        print("\\nðŸš€ Klaar voor integratie met NoodleCore compiler!")
        return 0
    else:
        print(f"\\nâŒ {failed} test(s) gefaald")
        return 1


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(description="Test NBC VM")
    parser.add_argument("test", nargs="?", help="Run specific test (e.g., test_1)")
    parser.add_argument("-v", "--verbose", action="store_true", help="Verbose output")
    
    args = parser.parse_args()
    
    if args.test:
        # Run specific test
        test_map = {
            "test_1": test_1_load_const,
            "test_2": test_2_arithmetic,
            "test_3": test_3_variables,
            "test_4": test_4_comparison,
            "test_5": test_5_conditionals,
            "test_6": test_6_lists,
            "test_7": test_7_hello_world,
            "errors": test_error_cases,
        }
        
        test_func = test_map.get(args.test)
        if test_func:
            success = test_func()
            sys.exit(0 if success else 1)
        else:
            print(f"âŒ Test '{args.test}' niet gevonden")
            sys.exit(1)
    else:
        # Run all tests
        sys.exit(run_all_tests())


