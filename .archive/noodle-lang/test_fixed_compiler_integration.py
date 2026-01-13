#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - test_fixed_compiler_integration.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
Full Compiler Integration Test - FASE 2 (FIXED)

Test complete NoodleCore â†’ NBC integratie:
1. Parse Noodle source (.nc) â†’ AST
2. AST â†’ NBC bytecode
3. NBC bytecode â†’ VM execution
4. Validate output

Usage:
    python test_fixed_compiler_integration.py
"""

import os
import sys
from pathlib import Path

# Voeg noodle_lang toe aan pad
sys.path.insert(0, str(Path(__file__).parent / "src"))

try:
    from noodle_lang.lexer import NoodleLexer
    from noodle_lang.parser import NoodleParser, parse_source
    from noodle_lang.nbc_generator import NBCGenerator
    from noodle_lang.nbc_vm import NBCVM
    
    print("âœ… Alle modules geladen!")
    
except ImportError as e:
    print(f"âŒ Import fout: {e}")
    sys.exit(1)


def test_simple_noodle_code():
    """Test 1: Simpele 'Hello World' Noodle code"""
    print("\n" + "="*60)
    print("Test 1: Compile & Execute SIMPELE NOODLE CODE")
    print("="*60)
    
    # Simpele Noodle source code
    source_code = '''
def main() {
    let greeting = "Hallo vanuit NoodleCore!";
    return greeting;
}
'''
    
    print(f"\n--- Noodle Source Code ---")
    print(source_code.strip())
    
    print(f"\n--- Stap 1: Lexical Analysis (Tokenizing) ---")
    
    # Stap 1: Lexical Analysis
    lexer = NoodleLexer(source_code, "<test>")
    tokens = lexer.tokenize()
    
    if lexer.errors:
        print(f"âŒ Lexer errors:")
        for error in lexer.errors:
            print(f"   {error.message} at line {error.location.line}")
        return False
    
    print(f"   âœ… Tokenizing gelukt! {len(tokens)} tokens gegenereerd")
    
    # Toon voorbeeld tokens
    print(f"   ðŸ“‹ Eerste 10 tokens:")
    for i, token in enumerate(tokens[:10]):
        print(f"      [{i}] {token[0]}: '{token[1]}'")
    
    print(f"\n--- Stap 2: Parsing (AST) ---")
    
    # Stap 2: Parsing - GEFIXT: gebruik source string
    parser = NoodleParser(source_code, "<test>")
    ast_program = parser.parse()
    
    if parser.errors:
        print(f"âŒ Parser errors:")
        for error in parser.errors:
            print(f"   {error.message}")
        return False
    
    print(f"   âœ… Parsing gelukt!")
    print(f"   ðŸ“‹ AST: statements={len(ast_program.statements)}")
    
    # Print simplified AST
    for i, stmt in enumerate(ast_program.statements):
        print(f"      [{i}] {stmt.type.value}: {getattr(stmt, 'name', 'N/A')}")
    
    # Convert to dict voor NBC generator
    ast = ast_program.to_dict()
    
    print(f"\n--- Stap 3: NBC Code Generation ---")
    
    # Stap 3: Generate NBC bytecode
    generator = NBCGenerator()
    
    try:
        bytecode = generator.generate(ast)
        print(f"   âœ… NBC generatie gelukt!")
        print(f"   ðŸ“‹ Bytecode statistieken:")
        print(f"      Instructions: {len(bytecode.instructions)}")
        print(f"      Constants: {len(bytecode.constants)}")
        print(f"      Names: {len(bytecode.names)}")
        print(f"      Entry point: {bytecode.entry_point}")
    
    except NotImplementedError as e:
        print(f"   âŒ NBC generatie mislukt (niet geÃ¯mplementeerd): {e}")
        return False
    except Exception as e:
        print(f"   âŒ NBC generatie mislukt: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        return False
    
    # Toon gegenereerde bytecode
    print(f"\n--- Stap 4: NBC Bytecode ---")
    print(bytecode.disassemble())
    
    print(f"\n--- Stap 5: VM Execution ---")
    
    # Stap 5: Execute in VM
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    
    try:
        result = vm.execute()
        
        print(f"   âœ… Execution gelukt!")
        print(f"   ðŸ“‹ Resultaat: {result!r}")
        print(f"   ðŸ“‹ VM statistieken:")
        print(f"      Instructions uitgevoerd: {vm.instructions_executed}")
        print(f"      Max stack depth: {vm.max_stack_depth}")
        
        # Validate result
        expected = "Hallo vanuit NoodleCore!"
        if result == expected:
            print(f"   âœ… Output correct! (verwacht: {expected!r})")
            return True
        else:
            print(f"   âŒ Output incorrect! (verwacht: {expected!r}, kreeg: {result!r})")
            return False
    
    except Exception as e:
        print(f"   âŒ Execution mislukt: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        return False


def test_arithmetic_expression():
    """Test 2: Rekenkundige expressies"""
    print("\n" + "="*60)
    print("Test 2: ARITHMETIC EXPRESSION (5 + 3 * 2)")
    print("="*60)
    
    source_code = '''
def calculate() {
    let x = 5 + 3 * 2;
    return x;
}
'''
    
    print(f"\nNoodle source:")
    print(source_code.strip())
    
    # Compile chain - GEFIXT
    lexer = NoodleLexer(source_code, "<test>")
    tokens = lexer.tokenize()
    
    if lexer.errors:
        print(f"âŒ Lexer errors: {len(lexer.errors)}")
        return False
    
    parser = NoodleParser(source_code, "<test>")
    ast_program = parser.parse()
    
    if parser.errors:
        print(f"âŒ Parser errors: {len(parser.errors)}")
        return False
    
    ast = ast_program.to_dict()
    generator = NBCGenerator()
    bytecode = generator.generate(ast)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    print(f"   Resultaat: {result}")
    print(f"   Verwacht: 11 (want 5 + (3*2) = 11)")
    
    if result == 11:
        print(f"   âœ… Rekenkundige expressie correct!")
        return True
    else:
        print(f"   âŒ Resultaat incorrect (verwacht 11)")
        return False


def test_variable_assignment():
    """Test 3: Variabelen toewijzing"""
    print("\n" + "="*60)
    print("Test 3: VARIABLE ASSIGNMENT")
    print("="*60)
    
    source_code = '''
def test() {
    let a = 10;
    let b = 20;
    let result = a + b;
    return result;
}
'''
    
    print(f"\nNoodle source:")
    print(source_code.strip())
    
    # Compile chain - GEFIXT
    lexer = NoodleLexer(source_code, "<test>")
    tokens = lexer.tokenize()
    
    parser = NoodleParser(source_code, "<test>")
    ast_program = parser.parse()
    
    if parser.errors:
        print(f"âŒ Parser errors: {len(parser.errors)}")
        return False
    
    ast = ast_program.to_dict()
    generator = NBCGenerator()
    bytecode = generator.generate(ast)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    print(f"   Resultaat: {result}")
    print(f"   Verwacht: 30 (10 + 20)")
    
    if result == 30:
        print(f"   âœ… Variable expressie correct!")
        return True
    else:
        print(f"   âŒ Resultaat incorrect (verwacht 30)")
        return False


def test_with_file(filename: str):
    """Test with actual .nc file"""
    print("\n" + "="*60)
    print(f"Test FILE: {filename}")
    print("="*60)
    
    filepath = Path(__file__).parent / "examples" / filename
    
    if not filepath.exists():
        print(f"âŒ Bestand niet gevonden: {filepath}")
        return False
    
    with open(filepath, 'r', encoding='utf-8') as f:
        source_code = f.read()
    
    print(f"\nSource from {filename}:")
    print("-" * 40)
    print(source_code[:300] + ("..." if len(source_code) > 300 else ""))
    print("-" * 40)
    
    # Full compile chain - GEFIXT
    lexer = NoodleLexer(source_code, str(filepath))
    tokens = lexer.tokenize()
    
    if lexer.errors:
        print(f"âŒ Lexer errors: {len(lexer.errors)}")
        for error in lexer.errors[:3]:
            print(f"   {error.message} at {error.location}")
        return False
    
    parser = NoodleParser(source_code, str(filepath))
    ast_program = parser.parse()
    
    if parser.errors:
        print(f"âŒ Parser errors: {len(parser.errors)}")
        for error in parser.errors[:3]:
            print(f"   {error.message}")
        return False
    
    ast = ast_program.to_dict()
    generator = NBCGenerator()
    bytecode = generator.generate(ast)
    
    vm = NBCVM()
    vm.load_bytecode(bytecode)
    result = vm.execute()
    
    print(f"   Resultaat: {result!r}")
    print(f"   âœ… Bestand gecompileerd en uitgevoerd!")
    
    return True


def run_all_tests():
    """Run all integration tests"""
    tests = [
        ("Simpele Noodle Code", test_simple_noodle_code),
        ("Arithmetic Expression", test_arithmetic_expression),
        ("Variable Assignment", test_variable_assignment),
    ]
    
    print("="*60)
    print("NOODLECORE â†’ NBC FULL INTEGRATION TEST")
    print("="*60)
    
    print("\nðŸŽ¯ FASE 2: COMPILER INTEGRATIE (FIXED)")
    print("   Chain: .nc â†’ Lexer â†’ Parser â†’ NBC Generator â†’ NBC VM")
    print()
    
    passed = 0
    failed = 0
    
    # Run tests
    for test_name, test_func in tests:
        try:
            if test_func():
                passed += 1
            else:
                failed += 1
        except Exception as e:
            failed += 1
            print(f"\n   âŒ {test_name} CRASHED: {type(e).__name__}: {e}")
            import traceback
            traceback.print_exc()
    
    # Extra: Test met hello_world_fix.nc als die bestaat
    if (Path(__file__).parent / "examples" / "hello_world_fix.nc").exists():
        try:
            if test_with_file("hello_world_fix.nc"):
                passed += 1
            else:
                failed += 1
        except Exception as e:
            failed += 1
            print(f"\n   âŒ File test CRASHED: {e}")
    
    print(f"\n{'='*60}")
    print(f"RESULTS: {passed} passed, {failed} failed")
    
    if failed == 0:
        print(f"{'='*60}")
        print("\nðŸŽ‰ ALLE TESTS GESLAAGD!")
        print("\nðŸš€ NOODLECORE â†’ NBC KETEN IS COMPLEET!")
        print("   âœ… Lexer werkt (source â†’ tokens)")
        print("   âœ… Parser werkt (source â†’ AST)")
        print("   âœ… NBC Generator werkt (AST â†’ bytecode)")
        print("   âœ… NBC VM werkt (bytecode â†’ execution)")
        print()
        print("ðŸª„ Klaar voor DeployableUnit integratie (FASE 3)!")
        return 0
    else:
        print(f"\nâŒ {failed} test(s) gefaald")
        return 1


if __name__ == "__main__":
    try:
        sys.exit(run_all_tests())
    
    except KeyboardInterrupt:
        print("\n\nâš ï¸  Test onderbroken door gebruiker")
        sys.exit(1)
    
    except Exception as e:
        print(f"\nðŸ’¥ FATALE FOUD: {type(e).__name__}: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)


