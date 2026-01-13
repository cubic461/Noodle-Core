#!/usr/bin/env python3
"""
Test Suite::Noodle Lang - test_compiler.py
Copyright Â© 2025 Michael van Erp. All rights reserved.

This file is part of the NoodleCore project.
Licensed under the MIT License - see LICENSE file for details.

Unauthorized copying, distribution, or modification is prohibited.
"""

"""
NoodleCore Compiler Integration Test
====================================

Compileert .nc source naar NBC bytecode voor de DeployableUnit integratie.

Dit is het VERBINDINGSPUNT tussen jouw NoodleCore compiler en het deployment system!

Usage:
    python test_compiler.py --input examples/integration_test_sample.nc
    python test_compiler.py --input examples/integration_test_sample.nc --to-python
"""

import os
import sys
import json
from pathlib import Path

# Voeg compiler toe aan pad
sys.path.insert(0, str(Path(__file__).parent / "src"))

from noodle_lang.compiler import NoodleCompiler, CompilationResult
from noodle_lang.lexer import NoodleLexer
from noodle_lang.parser import NoodleParser


def compile_noodle_to_nbc(source_file: str) -> CompilationResult:
    """
    Compileer een .nc file naar NBC bytecode.
    
    Returns:
        CompilationResult met bytecode die geladen kan worden in NBC Runtime
    """
    print(f"ðŸ”„ Compileren van {source_file}...")
    
    compiler = NoodleCompiler(optimize=True, debug=False)
    result = compiler.compile_file(source_file)
    
    if result.success:
        print(f"âœ… Compilatie gelukt!")
        print(f"   Tijd: {result.compilation_time:.3f}s")
        print(f"   Instructies: {result.statistics['instructions']}")
        print(f"   Constants: {result.statistics['constants']}")
        print(f"   Optimizations: {result.statistics['optimizations']}")
        
        # Sla bytecode op voor gebruik met DeployableUnit
        output_file = source_file.replace('.nc', '.nbc')
        if result.bytecode:
            result.bytecode.save(output_file)
            print(f"   Bytecode opgeslagen: {output_file}")
        
        return result
    else:
        print(f"âŒ Compilatie mislukt:")
        for error in result.errors:
            print(f"   Error: {error.location.file}:{error.location.line}:{error.location.column}: {error.message}")
        return result


def compile_noodle_to_python(source_file: str) -> str:
    """
    Compileer .nc naar Python code voor integratie.
    Dit is een BRUG totdat NBC Runtime klaar is.
    """
    print(f"ðŸ”„ Compileren naar Python: {source_file}...")
    
    # Lees source
    with open(source_file, 'r') as f:
        source = f.read()
    
    # Lexical analysis
    lexer = NoodleLexer(source, source_file)
    tokens = lexer.tokenize()
    
    if lexer.errors:
        print("âŒ Lexer errors:")
        for error in lexer.errors:
            print(f"   {error.message} at line {error.location.line}")
        return None
    
    # Parsing
    parser = NoodleParser(tokens)
    ast = parser.parse()
    
    if parser.errors:
        print("âŒ Parser errors:")
        for error in parser.errors:
            print(f"   {error.message}")
        return None
    
    # Generate Python code
    python_code = generate_python_from_ast(ast)
    
    return python_code


def generate_python_from_ast(ast: dict) -> str:
    """Genereer Python code van AST (vereenvoudigd)"""
    lines = [
        "# Generated Python code from NoodleCore AST",
        "#",
        ""
    ]
    
    # Walk the AST
    for stmt in ast.get('statements', []):
        if stmt['type'] == 'function_definition':
            lines.append(f"def {stmt['name']}({', '.join([p['name'] for p in stmt['parameters']])}):")
            
            # Generate body (simplified)
            for body_stmt in stmt['body']:
                if body_stmt['type'] == 'return_statement':
                    if body_stmt.get('value'):
                        lines.append(f"    return {body_stmt['value']}")
                    else:
                        lines.append(f"    return")
            
            lines.append("")
    
    return "\n".join(lines)


def run_compiler_test():
    """Test de complete compile pipeline"""
    print("="*80)
    print("ðŸ”§ NOODLECORE â†’ NBC COMPILER INTEGRATIE TEST")
    print("="*80)
    
    # Test file
    test_file = "examples/integration_test_sample.nc"
    
    if not os.path.exists(test_file):
        print(f"âŒ Test file niet gevonden: {test_file}")
        print("ðŸ“ Maak eerst de test file aan...")
        return
    
    # 1. Compileer naar NBC
    print("\n1ï¸âƒ£  Compileren naar NBC bytecode...")
    nbc_result = compile_noodle_to_nbc(test_file)
    
    if nbc_result.success:
        print("âœ… NBC compile gelukt!")
        print(f"   {test_file}.nc â†’ {test_file}.nbc")
        
        # Toon statistics
        stats = nbc_result.statistics
        print(f"\nðŸ“Š Compile statistics:")
        print(f"   Tokens: {stats.get('tokens', 0)}")
        print(f"   AST nodes: {stats.get('ast_nodes', 0)}")
        print(f"   Instructions: {stats.get('instructions', 0)}")
        print(f"   Constants: {stats.get('constants', 0)}")
        print(f"   Compile time: {nbc_result.compilation_time:.3f}s")
        
        # Controleer bytecode
        if nbc_result.bytecode:
            print(f"\nðŸ” Bytecode gedetailleerd:")
            print(f"   Instrucies: {len(nbc_result.bytecode.instructions)}")
            print(f"   Constants pool: {len(nbc_result.bytecode.constants)}")
            
            # Toon paar voorbeeld instructies
            if nbc_result.bytecode.instructions:
                print(f"\nðŸ“‹ Voorbeeld instructies:")
                for i, instr in enumerate(nbc_result.bytecode.instructions[:5]):
                    print(f"   [{i}] {instr.opcode}: {instr.operand}")
    else:
        print("âŒ NBC compile mislukt - zie errors hierboven")
        return None
    
    # 2. Compileer naar Python (voor snelle integratie)
    print(f"\n2ï¸âƒ£  Compileren naar Python (brug-oplossing)...")
    python_code = compile_noodle_to_python(test_file)
    
    if python_code:
        # Sla Python output op
        py_file = test_file.replace('.nc', '_generated.py')
        with open(py_file, 'w') as f:
            f.write(python_code)
        
        print(f"âœ… Python code gegenereerd: {py_file}")
        print(f"\nðŸ“ Python output:")
        print("-" * 40)
        print(python_code[:200] + ("..." if len(python_code) > 200 else ""))
        print("-" * 40)
    else:
        print("âŒ Python generatie mislukt")
    
    # 3. Test de output in DeployableUnit
    print(f"\n3ï¸âƒ£  Klaar voor DeployableUnit integratie!")
    
    if nbc_result.success and nbc_result.bytecode:
        print(f"\nðŸš€ Volgende stappen:")
        print(f"   1. Load bytecode in DeployableUnit:")
        print(f"      unit = DeployableUnit(")
        print(f"          unit_id='integration-test',")
        print(f"          version='1.0.0',")
        print(f"          bytecode=lezen_van('{test_file}.nbc'),")
        print(f"          entrypoint='hello_world'")
        print(f"      )")
        print(f"")
        print(f"   2. Laad in NBC Runtime:")
        print(f"      unit.load(nbc_runtime)")
        print(f"")
        print(f"   3. Activeer:")
        print(f"      unit.activate()")
        print(f"")
        print(f"   4. Roep aan:")
        print(f"      result = unit.call('hello_world')")
        print(f"      print(result)  # 'Hallo vanuit NoodleCore!'")
    
    print("")
    print("="*80)
    print("âœ… COMPILER INTEGRATIE TEST COMPLEET!")
    print("="*80)


if __name__ == "__main__":
    import argparse
    
    parser = argparse.ArgumentParser(
        description="Test NoodleCore compiler voor NBC/DeployableUnit integratie"
    )
    parser.add_argument('--input', default='examples/integration_test_sample.nc',
                        help='Input .nc file (standaard: examples/integration_test_sample.nc)')
    parser.add_argument('--to-nbc', action='store_true', 
                        help='Compileer naar NBC bytecode')
    parser.add_argument('--to-python', action='store_true',
                        help='Compileer naar Python (brug)')
    parser.add_argument('--test', action='store_true', default=True,
                        help='Draai complete test suite')
    
    args = parser.parse_args()
    
    if args.test:
        run_compiler_test()
    
    elif args.input:
        if args.to_nbc:
            compile_noodle_to_nbc(args.input)
        elif args.to_python:
            result = compile_noodle_to_python(args.input)
            if result:
                print(result)
        else:
            run_compiler_test()


